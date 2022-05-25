/** 
* Description   :   Helper class for "DeploymentWizardController" class, it will be having mainly utility methods with it.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/14/2018
*
* Version       :   V1.0 Created
*               :   V1.1 - Created - Modified By Rajeev Jain - 07/17/2020 - CR-20200709-14282 - Reattempt Release/CR - Always check for existing deployment track
*				:   V1.2 - Modified By - Rajeev Jain - 08/07/2020 - CR-20200709-14283 - Back Promotion Path Approach
*                   
**/ 
public class DeploymentWizardHelper {
    
    /**
     * @Description :   Method to update the Environment Details while clicking on Continue Button.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   Deployment Track, Controller Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedEnvDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
          
        //Populate Connection Details
        deploymentTrack.Source_Org__c = appProperties.selectedSourceCon;
        deploymentTrack.Target_Org__c = appProperties.selectedTargetCon; 
        deploymentTrack.Start_Date__c = DateTime.now();
        deploymentTrack.Started_By__c = UserInfo.getUserId();
        //Modified By - Rajeev Jain - 08/07/2020 - CR-20200709-14283 - Back Promotion Path Approach
        deploymentTrack.Available_for_Back_Sync__c = deploymentTrack.Available_for_Back_Sync__c;
        //Check Connection validation condition, if Connection is valid then change "App State"
        //To Do - Add Connection validation check in if condition
        changeAppState(deploymentTrack,appProperties);
        
        //Mark this step completed once all validation on environment screen get passed.
        deploymentTrack.Is_Env_Setup_Completed__c = true;
        
        updateMaualStepsDetails(deploymentTrack);
        
        //Upsert the Envirnment Setup details
        insert deploymentTrack;  
            
        //It shows if Envirnment Setup completed
        appProperties.isEnvSetupCompleted = true;
    } 
    
    
    /**
     * @Description :   Method to update the Test Run Details while clicking on Continue Button.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/13/2018
     * 
     * @args        :   Deployment Track, Controller/App Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedTestRunDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        //Check if Most Recent Test Run Record Exist, if not then Insert the Test Run Record and Stamp as Most Recent Test Run Record.
         //Check if Most Recent Test Run Record Exist, if not then Insert the Test Run Record and Stamp as Most Recent Test Run Record.
        if(deploymentTrack.Recent_Test_Run__c == null){
            
            //Insert New Test Run Summary Record and Stamp it on the latest Deployment Track Record
            //On each time run of the Test Run and stamp it on the Deployment Track record id
            Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c();
            processSummary.Deployment_Track__c = deploymentTrack.Id;
            processSummary.RecordTypeId = DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_TEST_RUN_SUMMARY);
            processSummary.Release_Project__c = deploymentTrack.Deployment_Release_Project__c;
            processSummary.Change_Request__c = deploymentTrack.Deployment_Change_Request__c;
            processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_NOT_STARTED;
            
            //Populate Cr and Releaase Status
            DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
            
            //Check if Moved with Force Move then Update Force Move Reason and IS Force Move flag
            if(String.isNotBlank(appProperties.forceMove)){
                
                processSummary.Force_Move_Reason__c = appProperties.forceMove;
                processSummary.Force_Move__c = true;
                appProperties.forceMove = '';
            }
            
            //Insert the record
            insert processSummary;
            
            //Stamp this Record as latest Test Run Summary
            deploymentTrack.Recent_Test_Run__c = processSummary.Id;
            
        }else{
            
            //Query on Recent Test Run and Stamp Force Move Reason here
            if(String.isNotBlank(appProperties.forceMove)){
                Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c(Id = deploymentTrack.Recent_Test_Run__c, 
                                                                                                Force_Move_Reason__c = appProperties.forceMove,
                                                                                                Force_Move__c = true);
                //Populate Cr and Releaase Status
            	DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
                
                update processSummary;
            }
        }
        //Move to Next State
        changeAppState(deploymentTrack,appProperties);
        
        //Update the Deployment Track
        update deploymentTrack;
    }
    
    /**
     * @Description :   Method to update the package retrieval details
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/14/2018
     * 
     * @args        :   Deployment Track, Controller/App Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedPackageRetrievalDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        //Check if Most Recent Test Run Record Exist, if not then Insert the Test Run Record and Stamp as Most Recent Test Run Record.
        if(deploymentTrack.Recent_Package_Retrieval__c == null){
            
            //Insert New Test Run Summary Record and Stamp it on the latest Deployment Track Record
            //On each time run of the Test Run and stamp it on the Deployment Track record id
            Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c();
            processSummary.Deployment_Track__c = deploymentTrack.Id;
            processSummary.RecordTypeId = DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_PACKAGE_RETRIEVAL_SUMMARY);
            processSummary.Release_Project__c = deploymentTrack.Deployment_Release_Project__c;
            processSummary.Change_Request__c = deploymentTrack.Deployment_Change_Request__c;
            processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_NOT_STARTED;
            
            //Populate Cr and Releaase Status
            DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
            
            //Check if Moved with Force Move then Update Force Move Reason and IS Force Move flag
            if(String.isNotBlank(appProperties.forceMove)){
                
                processSummary.Force_Move_Reason__c = appProperties.forceMove;
                processSummary.Force_Move__c = true;
                appProperties.forceMove = '';
            }
            
            //Insert the record
            insert processSummary;
            
            //Stamp this Record as latest Test Run Summary
            deploymentTrack.Recent_Package_Retrieval__c = processSummary.Id;
        }else{
            
            //Query on Recent Test Run and Stamp Force Move Reason here
            if(String.isNotBlank(appProperties.forceMove)){
                Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c(Id = deploymentTrack.Recent_Package_Retrieval__c, 
                                                                                                Force_Move_Reason__c = appProperties.forceMove,
                                                                                                Force_Move__c = true);
                //Populate Cr and Releaase Status
            	DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
                
                update processSummary;
            }
        }
        //Move to Next State
        changeAppState(deploymentTrack,appProperties);
        
        //Update the Deployment Track
        update deploymentTrack;
    }
    
    /**
     * @Description :   Method to update the Crosscheck Summary details
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/14/2018
     * 
     * @args        :   Deployment Track, Controller/App Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedCrosscheckDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        //Check if Most Recent Test Run Record Exist, if not then Insert the Test Run Record and Stamp as Most Recent Test Run Record.
        if(deploymentTrack.Recent_Crosscheck__c == null){
            
            //Insert New Crosscheck Summary Record and Stamp it on the latest Deployment Track Record
            //On each time run of Crosscheck and stamp it on the Deployment Track record id 
            Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c();
            processSummary.Deployment_Track__c = deploymentTrack.Id;
            
            processSummary.RecordTypeId = DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_CROSSCHECK_SUMMARY);
            processSummary.Release_Project__c = deploymentTrack.Deployment_Release_Project__c;
            processSummary.Change_Request__c = deploymentTrack.Deployment_Change_Request__c;
            processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_NOT_STARTED;
            
            //Populate Cr and Releaase Status
            DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
            
            //Check if Moved with Force Move then Update Force Move Reason and IS Force Move flag
            if(String.isNotBlank(appProperties.forceMove)){
                
                processSummary.Force_Move_Reason__c = appProperties.forceMove;
                processSummary.Force_Move__c = true;
                appProperties.forceMove = '';
            }
            
            //Insert the record
            insert processSummary;
            
            //Stamp this Record as latest Test Run Summary
            deploymentTrack.Recent_Crosscheck__c = processSummary.Id;
            
            //Attach Package either from Previous crosscheck or previous Package retrieval record
            if(deploymentTrack.Recent_Package_Retrieval__c != null){
                
                //Get Attachment and Update Parent Id with Most Recent Corsscheck Run(Moving attachment from one record to other record)
                Attachment attach = DeploymentWizardHelper.getAttachment(deploymentTrack.Recent_Package_Retrieval__c);
                if(attach.Id != null){
                    Attachment insertAttach = new Attachment();
                    insertAttach.Body = attach.Body;
                    insertAttach.Name = attach.Name;
                    insertAttach.ParentId = processSummary.Id;
                    update attach;
                }
                    
            }
        }else{
            
            //Query on Recent Test Run and Stamp Force Move Reason here
            if(String.isNotBlank(appProperties.forceMove)){
                Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c(Id = deploymentTrack.Recent_Crosscheck__c, 
                                                                                                Force_Move_Reason__c = appProperties.forceMove,
                                                                                                Force_Move__c = true);
                //Populate Cr and Releaase Status
            	DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
                
                update processSummary;
            }
        }
        //Move to Next State
        changeAppState(deploymentTrack,appProperties);
        
        //Update the Deployment Track
        update deploymentTrack;
    }
    
    /**
     * @Description :   Method to update the Validation Summary details
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/15/2018
     * 
     * @args        :   Deployment Track, Controller/App Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedValidationDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        //Check if Most Recent Test Run Record Exist, if not then Insert the Test Run Record and Stamp as Most Recent Test Run Record.
        if(deploymentTrack.Recent_Validation__c == null){
            System.debug('Amazing');
            
            //Insert New Test Run Summary Record and Stamp it on the latest Deployment Track Record
            //On each time run of the Test Run and stamp it on the Deployment Track record id
            Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c();
            processSummary.Deployment_Track__c = deploymentTrack.Id;
            
            processSummary.RecordTypeId = DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_VALIDATION_SUMMARY);
            processSummary.Release_Project__c = deploymentTrack.Deployment_Release_Project__c;
            processSummary.Change_Request__c = deploymentTrack.Deployment_Change_Request__c;
            processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_NOT_STARTED;
            
            //Populate Cr and Releaase Status
            DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
            
            //Check if Moved with Force Move then Update Force Move Reason and IS Force Move flag
            if(String.isNotBlank(appProperties.forceMove)){
                
                processSummary.Force_Move_Reason__c = appProperties.forceMove;
                processSummary.Force_Move__c = true;
                appProperties.forceMove = '';
            }
            
            //Insert the record
            insert processSummary;
            
            //Stamp this Record as latest Test Run Summary
            deploymentTrack.Recent_Validation__c = processSummary.Id;
        }else{
              System.debug('Awesome');
            
            //Query on Recent Test Run and Stamp Force Move Reason here
            if(String.isNotBlank(appProperties.forceMove)){
                Deployment_Process_Summary__c processSummary = new Deployment_Process_Summary__c(Id = deploymentTrack.Recent_Validation__c, 
                                                                                                Force_Move_Reason__c = appProperties.forceMove,
                                                                                                Force_Move__c = true);
                //Populate Cr and Releaase Status
            	DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrack,processSummary);
                
                update processSummary;
            }
        }
        //Move to Next State
        changeAppState(deploymentTrack,appProperties);
        
        //Update the Deployment Track
        update deploymentTrack;
    }
    /**
     * @Description :   Method to update the Deployment Summary details
     * 
     * @Modifcation :   Added By - Rajeev Jain - 04/04/2018
     * 
     * @args        :   Deployment Track, Controller/App Properties
     * 
     * @Return      :   Void
     * */
    public static void updatedDeploymentDetails(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        deploymentTrack.Is_Deployment_Completed__c = true;
        deploymentTrack.End_Date__c = DateTime.now();
        
        //Move to Next State
        changeAppState(deploymentTrack,appProperties);
        
        //Update the Deployment Track
        update deploymentTrack;     
    }     
    
     /**
     * @Description :   Method to Change Application State based on what is current state on the Deployment Track object.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   Deployment Track, Controller Properties
     * 
     * @Return      :   Void
     * 				
     * Version      :   V1.0 Created
     * 					v1.2 Modify by Rajeev Jain  03/07/2018- CR-20180702-12314 - issue resolved of 50001 rows error
     * */
    public static void changeAppState(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        //System.assert(false, deploymentTrack +'App State @@ '+appProperties.appState);
       
        if(appProperties.appState == DeploymentWizardConstants.APP_STATE_NEW){
            //Check if manual mods exist
            Boolean check = verifyMaualModifications(deploymentTrack);
            System.debug('done');
            if(check == true ){
                
                 deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.APP_STATE_MANUAL_MODS; 	
            } 
            else{
                //Check if there are any test class to run
                if(TestRunHelper.isTestRunRequired(deploymentTrack/*, appProperties*/)){
                    System.debug('Test found');
                    deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_TEST_RUN;
                }
                else{
                    System.debug('Test NOT found');
                    deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_PACKAGE_RETRIEVAL;  
                }
            }
        }
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_TEST_RUN)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_PACKAGE_RETRIEVAL;    
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_PACKAGE_RETRIEVAL)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_CROSSCHECK;   
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_CROSSCHECK)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_VALIDATION;   
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_VALIDATION)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_DEPLOYMENT; 
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_MANUAL_MODS)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_DEPLOYMENT_SUMMARY;  
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_DEPLOYMENT)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_DEPLOYMENT_SUMMARY;   
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_DEPLOYMENT_SUMMARY)
            deploymentTrack.Deployment_Process__c = DeploymentWizardConstants.PROCESS_TEST_RUN;   
        populateApplicationProperties(deploymentTrack, appProperties);
    }
     /**
     * @Description :   Method to Query on Deployment Track object based on Id passed to it.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   Deployment Track Id
     * 
     * @Return      :   Deployment Track Instance
     * */
    public static Deployment_Track__c populateDeploymentTrack(String trackId){
        List<Deployment_Track__c> deploymentTracks = [SELECT Id, Name, Deployment_Change_Request__c, Deployment_Release_Project__c, 
                                                      Started_By__c, Sandbox_Refresh_Date__c, Source_Org__c, Target_Org__c, Deployment_Process__c, 
                                                      Is_Env_Setup_Completed__c, Recent_Crosscheck__c, Recent_Test_Run__c, 
                                                      Recent_Package_Retrieval__c, Recent_Validation__c, Recent_Deployment__c, 
                                                      Start_Date__c, End_Date__c, Deployed_By__c, Deployment_Progress__c, Is_Back_Sync__c,
													  Deployment_Entity__c, Is_Deployment_Completed__c,
                                                      Is_Test_Run_Required__c, Deployment_Change_Request__r.Status__c, Deployment_Release_Project__r.Status__c ,  
                                                      Deployment_Type__c, Available_for_Back_Sync__c
                                                      FROM Deployment_Track__c
                                                      where Id = :trackId]; 
        
        if(deploymentTracks.size() > 0)
            return deploymentTracks[0];
        else
            return new Deployment_Track__c();
        
    }
    
    /**
     * @Description :   Method to update the application properties, based on what App state
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   Deployment Track Reference, Application Properties
     * 
     * @Return      :   Void
     * */
    public static void populateApplicationProperties(Deployment_Track__c deploymentTrack, DeploymentWizardBean appProperties){
        
        //Populate Release Name and Change Request name
        if(String.isBlank(appProperties.releaseName) && deploymentTrack.Deployment_Release_Project__c != null){
           
            List<SFDC_Release__c> releases = [select Id, Name, Status__c from SFDC_Release__c where Id = :deploymentTrack.Deployment_Release_Project__c];
          
            if(releases.size() > 0){
                
                //Populate Release Name
                appProperties.releaseName = releases[0].Name;
                appProperties.releaseStatus = releases[0].Status__c;
              
            } 
        }else if(String.isBlank(appProperties.crName) && deploymentTrack.Deployment_Change_Request__c != null){
         
            List<SFDC_Change_Request__c> changeRequests = [select Id, Name, Status__c from SFDC_Change_Request__c where Id = :deploymentTrack.Deployment_Change_Request__c];
            
            if(changeRequests.size() > 0){
                //Populate CR Name
                appProperties.crName = changeRequests[0].Name;
                appProperties.crStatus = changeRequests[0].Status__c;
            }
            
        }
        
        //Commond Properties Which Are needed to Populate
        appProperties.selectedSourceCon = deploymentTrack.Source_Org__c;
        appProperties.selectedTargetCon = deploymentTrack.Target_Org__c;
        appProperties.isEnvSetupCompleted = deploymentTrack.Is_Env_Setup_Completed__c;
        
        if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_ENV_SETUP){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_NEW;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_ENV_SETUP;     
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_TEST_RUN){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_TEST_RUN;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_TEST_RUN; 
            
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_PACKAGE_RETRIEVAL){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_PACKAGE_RETRIEVAL;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_PACKAGE_RETRIEVAL; 
            
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_CROSSCHECK){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_CROSSCHECK;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_CROSSCHECK; 
            
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_VALIDATION){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_VALIDATION;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_VALIDATION; 
            
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_DEPLOYMENT){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_DEPLOYMENT;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_DEPLOYMENT; 
            
        }else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.PROCESS_DEPLOYMENT_SUMMARY){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_DEPLOYMENT_SUMMARY;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_DEPLOYMENT_SUMMARY; 
        }
        else if(deploymentTrack.Deployment_Process__c == DeploymentWizardConstants.APP_STATE_MANUAL_MODS){
            
            appProperties.appState = DeploymentWizardConstants.APP_STATE_MANUAL_MODS;
            appProperties.appScreenTitle = DeploymentWizardConstants.APP_SCREEN_TITLE_MANUAL_MODS; 
        }
    }
    
    /**
     * @Description :   Get Process Summary Instance(User this method to utilize Deployment Process Summary Data on All Screens)
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   Deployment Process Summary Id
     * 
     * @Return      :   Deployment Process Summary Instance
     * */
    public Static Deployment_Process_Summary__c populateDeploymentProcessSummary(String processId){
        
        //Query on Deployment Process Summary Record
        List<Deployment_Process_Summary__c> processSummaries = [SELECT Id, Deployment_Track__c, Change_Request__c, Release_Project__c, Assigned_To__c, 
                                                                Force_Move_Reason__c, Force_Move__c, CR_Status__c, Release_Project_Status__c, Run_By__c,
                                                                Total_Test_Run__c, Total_Passed_Classes__c, Total_Failed_Classes__c,Failed_Classes__c, 
                                                                Passed_Class__c, Overall_Coverage__c, Test_Methods_Fixed__c, Total_Failures__c, 
                                                                Retrieval_Errors_Fixed__c, Total_Component__c, Total_Overlapping_found__c, 
                                                                Overlapping_Adjusted__c, Pre_Validation_Steps__c, Pre_Validation_Step_Completed__c, 
                                                                Validation_Type__c, Validation_Status__c, Available_for_Quick_Deploy__c, Validated_By__c,
                                                                Start_Date__c, Post_Deployment_Steps__c, Deployed_By__c, Deployment_Status__c, 
                                                                Deployment_Type__c, End_Date__c, ValidationId__c, Status__c, 
                                                                Specific_Test_Run_Classes__c, Default_Run__c, Target_Backup_Status__c, Integration_Failure_Reason__c,
                                                                Post_Deployment_Step_Completed__c, Is_Package_Manually_Uploaded__c, Pre_Deployment_Step_Completed__c, Pre_Deployment_Steps__c, Deployment_Id__c
                                                                FROM Deployment_Process_Summary__c
                                                                where Id = :processId];
        if(processSummaries.size() > 0)
            return processSummaries[0];
        else
            return new Deployment_Process_Summary__c();
    }
    
    /**
     * @Description :   Method to get Record Type Instance based on Object Type and Developer name is passed to it
     * 
     * @Modifcation :   Added By - Rajeev Jain - 02/21/2018
     * 
     * @args        :   SObject Type(Like Deployment_Process_Summary__c or Account), Record Type Developer Name(Like Crosscheck_Summary)
     * 
     * @Return      :   RecordType
     * */
    public Static RecordType getRecordTypeIdForAnObject(String objectType, String recordTypeName){
        List<RecordType> recordTypes = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType=:objectType];
        Map<String, RecordType> mapRecordTypes = new Map<String, RecordType>();
        for(RecordType rt : recordTypes){
            mapRecordTypes.put(rt.DeveloperName, rt);
        }
        if(mapRecordTypes.size() > 0 && mapRecordTypes.containsKey(recordTypeName)){
            return mapRecordTypes.get(recordTypeName);
        }else
            return null;
    }
    
    //Get Record Type Id
    public Static String getRecordTypeId(String objectType, String recordTypeName){
        RecordType rt = getRecordTypeIdForAnObject(objectType,recordTypeName);
        if(rt != null)
            return rt.Id;
        else 
            return '';
    }
    
    /**
     * @Description :   Method to get latest Attached Deployment Package from Any Deployment Summary Record Based on Parent Id Passed to It.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/26/2018
     * 
     * @args        :   Attachment Parent Id
     * 
     * @Return      :   Attachment Record With Name and Id
     * */
    public static Attachment getAttachment(Id parentId){
        List<Attachment> attachments = [select Id, Name, ParentId, Body from Attachment where ParentId = :parentId AND Name = :DeploymentWizardConstants.DEPLOYMENT_PACKAFE_ATTACHMENT_NAME order by createdDate DESC LIMIT 1];
        if(attachments.size() > 0)
            return attachments[0]; 
        return new Attachment();
    }

    /**
     * @Description :   Method to get latest Attached Deployment Package from Any Deployment Summary Record Based on Parent Id Passed to It.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/26/2018
     * 
     * @args        :   Attachment Parent Id
     * 
     * @Return      :   Attachment Record With Name and Id
     * */
    public static Attachment getAttachmentPackageXml(Id parentId){
        List<Attachment> attachments = [select Id, Name, ParentId, Body from Attachment where ParentId = :parentId AND Name = :DeploymentWizardConstants.DEPLOYMENT_PACKAGE_XML order by createdDate DESC LIMIT 1];
        if(attachments.size() > 0)
            return attachments[0]; 
        return new Attachment();
    }
    
    /**
     * @Description :   Method to get latest Target Backup of Deployment Package once validation got completed
     * 
     * @Modifcation :   Added By - Rajeev Jain - 04/02/2018
     * 
     * @args        :   Attachment Parent Id
     * 
     * @Return      :   Attachment Record With Name and Id
     * */
    public static Attachment getTargetBackup(Id parentId){
        List<Attachment> attachments = [select Id, Name, ParentId, Body from Attachment where ParentId = :parentId AND Name = :DeploymentWizardConstants.DEPLOYMENT_PACKAFE_TARGET_BACKUP_NAME order by createdDate DESC LIMIT 1];
        if(attachments.size() > 0)
            return attachments[0]; 
        return new Attachment();
    }
    
    /**
     * @Description :   Method to create base query to get is system modification for Releasr or CR
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/27/2018
     * 
     * @args        :   Deployment Track Reference, Application Properties Reference
     * 
     * @Return      :   String - With Prepared Based Query with Where clause criteria
     * */
    public static String getBaseQueryForIsSystemMod(Deployment_Track__c deploymentTrackRef,  DeploymentWizardBean appProperties){
       
        String baseQuery = 'select Id from IS_System_Modification__c';
        String whereClause = '';
        String releaseName = appProperties.releaseName;
        //Check for ' in release name
        if(releaseName.contains('\''))
            releaseName = String.escapeSingleQuotes(releaseName);
        
        String crName = appProperties.crName;
      
        if (String.isNotBlank(appProperties.deploymentGroupId)) {
            Set<Id> setOfCRIds = fetchCRsOfAGroup(appProperties.deploymentGroupId);
            String changerequestIds = '(';
            if(setOfCRIds.size() > 0) {
                for(Id crid :setOfCRIds){
                    changerequestIds += '\'' + crid + '\',';
                }
            }
            changerequestIds = changerequestIds.removeEnd(',') + ')';
            
            whereClause =  whereClause + 'Change_Request__c IN '+ changerequestIds;
        }
        else if(String.isNotBlank(releaseName))
            whereClause = whereClause + ' Change_Request__r.Release__c != null AND Change_Request__r.Release__r.Name = \''+ releaseName + '\'';    
        else if(String.isNotBlank(crName))
            whereClause = whereClause + ' Change_Request__r.Name = \'' + crName +'\'';
        
        if(String.isNotBlank(whereClause)){
            
            whereClause = ' where ' + whereClause + ' AND Delete_from_Design__c = false';
        }
        
        String finalQuery = baseQuery + whereClause;
        
        finalQuery = finalQuery.replaceAll('\'','\\'+'\'');
        
        System.debug('Check Final Query :::@@@@@@ ' + finalQuery);
        
        return finalQuery;
    }
     /**
     * @Description :   Method to create base query to get is system modification for Releasr or CR
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/27/2018
     * 
     * @args        :   Deployment Track Reference, Application Properties Reference
     * 
     * @Return      :   String - With Prepared Based Query with Where clause criteria
     * */
    public static String getBaseQueryForIsSystemMod(Deployment_Track__c deploymentTrackRef){
        
        String baseQuery = 'select Id from IS_System_Modification__c';
        String whereClause = '';
        String releaseId = deploymentTrackRef.Deployment_Release_Project__c;
        String crId = deploymentTrackRef.Deployment_Change_Request__c;
        String groupId = deploymentTrackRef.Deployment_Group__c;

         //Check for CR/Release in query
         if (String.isNotBlank(groupId)) {
            Set<Id> setOfCRIds = fetchCRsOfAGroup(groupId);
            String changerequestIds = '(';
            if(setOfCRIds.size() > 0) {
                for(Id cId :setOfCRIds){
                    changerequestIds += '\'' + cId + '\',';
                }
            }
            changerequestIds = changerequestIds.removeEnd(',') + ')';
            
            whereClause =  whereClause + 'Change_Request__c IN '+ changerequestIds;
        }
        else if(String.isNotBlank(releaseId))
            whereClause = whereClause + ' Change_Request__r.Release__c != null AND Change_Request__r.Release__c = \''+ releaseId  + '\'';    
        else if(String.isNotBlank(crId))
            whereClause = whereClause + ' Change_Request__c = \'' + crId +'\'';
        
        if(String.isNotBlank(whereClause)){
            
            whereClause = ' where ' + whereClause + ' AND Delete_from_Design__c = false';
        }
        
        String finalQuery = baseQuery + whereClause;
        
        
        System.debug('Check Final Query ::: ' + finalQuery);
        
        return finalQuery;
    }
    
    /**
     * @Description :   Get CR Action items Dynamically
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/27/2018
     * 
     * @args        :   List of Is System Mods from Release or CR, Manual Steps Timing(Like  - Pre Validation, Pre Deployment, Post Deployment)
     * 
     * @Return      :   String - With Prepared Based Query with Where clause criteria
     * */
    public static List<Cr_Action_Item__c> getActionItems(List<Is_System_Modification__c> mods, String timing){
        
        return [select Id from CR_Action_Item__c where IS_System_Modification__c IN :mods 
                                                AND RecordType.DeveloperName = 'Deployment_Plan_Step'
                                                AND Timing__c = :timing];
    }
    
     /**
     * @Description :   Method to Create the Manual Steps Report URL, which will be used in Validation and Deployment Screen to perform the manual steps
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/28/2018
     * 
     * @args        :   Deployment Track Ref
     * 
     * @Return      :   String - With Prepared Based Query with Where clause criteria
     * */
    public static String getManualStepReportLink(Deployment_Track__c trackRef, String timing){
        timing = timing + ',Other';
        String reportUrl = DeploymentWizardConstants.MANUAL_STEPS_BLUE_PRINT_REPORT_BASE_URL;        
        if(String.isNotBlank(trackRef.Deployment_Release_Project__c))
            reportUrl = reportUrl + '?fv0=' + String.valueOf(trackRef.Deployment_Release_Project__c).substring(0, 15);
        else if(String.isNotBlank(trackRef.Deployment_Change_Request__c))
            reportUrl = reportUrl + '?fv1=' + String.valueOf(trackRef.Deployment_Change_Request__c).substring(0, 15);
        reportUrl = reportUrl + '&fv2='+ timing;
        return reportUrl;
    }
    
    /**
     * @Description :   Generic method to upload the package
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/28/2018
     * 
     * @args        :   Deployment Track Ref
     * 
     * @Return      :   String - With Prepared Based Query with Where clause criteria
     * */
    public static PageReference uploadPackage(Deployment_Track__c deploymentTrackRef, Id processRecordTypeId, DeploymentWizardBean appProperties, Attachment uploadPackage, Deployment_Process_Summary__c processSummary){
        
        PageReference pg = new PageReference(oneClickSettings.get(DeploymentWizardConstants.APPLICATION_PAGE_NAME).value__c + deploymentTrackRef.Id);
        
        //Insert the Process Summary Record if already not inserted otherwise stamp that record as Parent Id on the Attachment
        if(String.isNotBlank(processSummary.Id)){
            
            uploadPackage.ParentId = processSummary.Id; // the record the file is attached to
        }else{
            //Insert Process Summary Record and Stamp it on the attachment.
            processSummary = new Deployment_Process_Summary__c();
            processSummary.Deployment_Track__c = deploymentTrackRef.Id;
            processSummary.RecordTypeId = processRecordTypeId;
            processSummary.Release_Project__c = deploymentTrackRef.Deployment_Release_Project__c;
            processSummary.Change_Request__c = deploymentTrackRef.Deployment_Change_Request__c;
            processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_NOT_STARTED;
            insert processSummary;
            
            //Stamp this record as Most Recent Crosscheck on Deployment Track
            if(appProperties.appState == DeploymentWizardConstants.APP_STATE_CROSSCHECK)
                deploymentTrackRef.Recent_Crosscheck__c = processSummary.Id;
            else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_VALIDATION)
                deploymentTrackRef.Recent_Validation__c = processSummary.Id;
            
            update deploymentTrackRef;
            uploadPackage.ParentId = processSummary.Id;
        }
        uploadPackage.OwnerId = UserInfo.getUserId();
        uploadPackage.IsPrivate = true;
        
        Deployment_Process_Summary__c depProcessSum = new Deployment_Process_Summary__c();
        if(uploadPackage.Name.equalsIgnoreCase('package.xml')){
            depProcessSum = new Deployment_Process_Summary__c(Id = processSummary.Id, Is_Package_Manually_Uploaded__c = true);
            update depProcessSum;
        } 
        
        insert uploadPackage;
        
        
        //ReInitialize the Body so VF page don't throw View State Limit Exceed Error
        uploadPackage = new Attachment();
        pg.setRedirect(true);
        return pg;
        
    }
    
    /**
     * @Description :   Method to Check Existense of Manual Step on Release or Change Request Record
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/28/2018
     * 
     * @args        :   Deployment Track Ref, Application Properties and Manual Step Timing
     * 
     * @Return      :   Boolean Flag - Return true if Any manual step exist type of Pre, Post or Pre Deployment
     * 
     * */
    public static Boolean checkForManualStep(Deployment_Track__c deploymentTrackRef,  DeploymentWizardBean appProperties, String timing){
        
         //Get Release Or CR and query on Is System Modifications
        List<IS_System_Modification__c> mods = Database.query(DeploymentWizardHelper.getBaseQueryForIsSystemMod(deploymentTrackRef, appProperties));
        
        //Now query on CR Action items to check if any Manual Step exist, if yes, then Mark this flag as true;
        List<CR_Action_Item__c> actionItems = DeploymentWizardHelper.getActionItems(mods, timing);
        if(actionItems.size() > 0)
            return true;
        
        return false;
    }
    
    /**
     * @Description :   Method to Get Days Difference Between Two Date Time, This days helpful to identify "Quick Deploy" options if Package validated Successfully
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/28/2018
     * 
     * @args        :   Date Time for Start Date and End Date
     * 
     * @Return      :   Integer Value
     * 
     * */
    public static Decimal daysDifferenceBetweenDateTimes(DateTime startTime, DateTime endTime){
        
        //These two values depends on the date, so null value not make sense our all
        //So putting DateTime.now will make 0 days difference which make no sense to identify for quick deploy
        endTime = endTime == null ? DateTime.now() : endTime;
        startTime = startTime == null ? DateTime.now() : startTime;
        decimal millisecs = decimal.valueOf(endTime.getTime() - startTime.getTime());
        decimal dDays = millisecs/1000/60/60/24;
        return dDays;
    }
    /**
     * @Description :   Method to Insert Process Summary Record on each attempt of Process from different Deployment Process Screens
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/29/2018
     * 
     * @args        :   Deployment Track Ref, Application Properties
     * 
     * @Return      :   Boolean Flag - Return true if Any manual step exist type of Pre, Post or Pre Deployment
     * 
     * */
    public static void insertProcessSummary(Deployment_Track__c deploymentTrackRef,  Deployment_Process_Summary__c processSummary, DeploymentWizardBean appProperties, Id processRecordTypeId){
        
        //Insert New Test Run Summary Record and Stamp it on the latest Deployment Track Record
        //On each time run of the Test Run and stamp it on the Deployment Track record id
        processSummary = new Deployment_Process_Summary__c();
        processSummary.Deployment_Track__c = deploymentTrackRef.Id;
        processSummary.RecordTypeId = processRecordTypeId;
        processSummary.Run_By__c = UserInfo.getUserId();
        processSummary.Start_Date__c = DateTime.now();
        processSummary.Release_Project__c = deploymentTrackRef.Deployment_Release_Project__c;
        processSummary.Change_Request__c = deploymentTrackRef.Deployment_Change_Request__c;
        processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED;
        
        //Insert the record
        insert processSummary;
        
        //Stamp this Record as latest Test Run Summary
        //Stamp this record as Most Recent Crosscheck on Deployment Track
        if(appProperties.appState == DeploymentWizardConstants.APP_STATE_PACKAGE_RETRIEVAL)
            deploymentTrackRef.Recent_Package_Retrieval__c = processSummary.Id;
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_CROSSCHECK)
            deploymentTrackRef.Recent_Crosscheck__c = processSummary.Id;
        else if(appProperties.appState == DeploymentWizardConstants.APP_STATE_VALIDATION)
            deploymentTrackRef.Recent_Validation__c = processSummary.Id;
        
        //Update the Deployment Track
        update deploymentTrackRef;
    }
    /**
     * @Description :   Method to Get Connection Record Based on the Connection Name passed to it.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/29/2018
     * 
     * @args        :   Deployment Track Ref, Application Properties
     * 
     * @Return      :   Boolean Flag - Return true if Any manual step exist type of Pre, Post or Pre Deployment
     * 
     * */
    public static Connection__c getConnectionData(String conName){
        List<Connection__c> connections = [select Id, Name , Refresh_Token__c , Org_type__c, Instance_URL__c from Connection__c where Name = :conName];
        if(connections.size() > 0)
            return connections[0];
        return new Connection__c();
    }
    
    /**
     *  @description    :   Method to Get One click Custom Settings
     *
     *  @args           :   
     *
     *  @return         :   Map of One click settings
     *
     **/ 
    
    private static Map<String, OneClick_Settings__c> pOneClickSettings;
    public static Map<String,OneClick_Settings__c> oneClickSettings{
        get {
            if(pOneClickSettings == null) {
                pOneClickSettings = OneClick_Settings__c.getAll();
            }
            return pOneClickSettings;
        }
    }
    
    /**
     *  @description    :   Method to Populate CR Status and Release Status Respectively on each Process Summary Record Save or Update
     * 					:	This we can get idea of the status of the CRs and Release while running specific deployment processes for tracking.
     *
     *  @args           :   
     *
     *  @return         :   Track Reference, Process Summary Reference
     *
     **/
    public static void populateCRAndReleaseStatus(Deployment_Track__c track, Deployment_Process_Summary__c processSummary){
        
        //Get Updated Instance of Deployment Track Object.
        Deployment_Track__c updatedTrack = DeploymentWizardHelper.populateDeploymentTrack(track.Id);
        processSummary.CR_Status__c = updatedTrack.Deployment_Change_Request__r.Status__c;
        processSummary.Release_Project_Status__c = updatedTrack.Deployment_Release_Project__r.Status__c;
    }
     /**
     *  @description    :   Method to check id the inserted Cr/ Release contains ony maual mofificatins or not
     * 
     * @Modifcation :   Added By - Ishan Arora - 03/29/2018
     * 
     * @args        :   Deployment Track Ref
     *
     *  @return    	:   Track Reference, Process Summary Reference
     *
	**/
    public static Boolean verifyMaualModifications(Deployment_Track__c track){
         
        Boolean checkManual = true;
        //Get recordtype id of simple and complex record type id 
        String simpleRT = [Select id from RecordType where SObjectType = 'IS_System_Modification__c' AND DeveloperName = 'Simple' Limit 1][0].Id;
        String complexRT = [Select id from RecordType where SObjectType = 'IS_System_Modification__c' AND DeveloperName = 'Complex' Limit 1][0].Id;
        //Get release and CR id
        String releaseId = track.Deployment_Release_Project__c;
        String crId = track.Deployment_Change_Request__c;
        
        String baseQuery = 'select Id  from IS_System_Modification__c';
        String whereClause = '';
        
        if(String.isNotBlank(releaseId))
            whereClause = whereClause + ' Change_Request__r.Release__c != null AND Change_Request__r.Release__c = \''+ releaseId + '\'';    
        else if(String.isNotBlank(crId))
            whereClause = whereClause + ' Change_Request__c = \'' + crId +'\'';
        
        
        if(String.isNotBlank(whereClause)){
            
            whereClause = ' where ' + whereClause + ' AND ( Delete_from_Design__c = false  And RecordTypeId =\''+ simpleRT + '\')';
        }
        
        String finalQuery = baseQuery + whereClause;
        
        List<IS_System_Modification__c> nonManualDeployment = Database.query(finalQuery);
        
        if(nonManualDeployment.size() > 0){
            checkManual = false;
            track.Deployment_Type__c = 'Non - Manual';        
        }

        baseQuery = 'select Id, Include_in_Change_Set__c, Has_Manual_Step_s__c from IS_System_Modification__c';
        
        whereClause = '';
        if(String.isNotBlank(releaseId))
            whereClause = whereClause + ' Change_Request__r.Release__c != null AND Change_Request__r.Release__c = \''+ releaseId + '\'';    
        else if(String.isNotBlank(crId))
            whereClause = whereClause + ' Change_Request__c = \'' + crId +'\'';
        
        if(String.isNotBlank(whereClause)){
            
            whereClause = ' where ' + whereClause + ' AND ( Delete_from_Design__c = false  And (RecordTypeId =\''+ complexRT + '\' AND Include_in_Change_Set__c = true))';
            
        }
        
        finalQuery = baseQuery + whereClause;
        nonManualDeployment = Database.query(finalQuery);
        
        if(nonManualDeployment.size() > 0){
            checkManual = false; 
            track.Deployment_Type__c = 'Manual & Non Manual';
        }
        
        if(checkManual == true)
             track.Deployment_Type__c = 'Manual';
            
        
        return checkManual;
        
    }
        /**
     * @Description :   Method to update the manual styteos details present in a CR/ Release
     * 
     * @Modifcation :   Added By - Ishan Arora - 02/21/2018
     * 
     * @args        :   Deployment Track, Controller Properties
     * 
     * @Return      :   Void
     * */
    public static void updateMaualStepsDetails(Deployment_Track__c deploymentTrack){
        //List to get records of CR_Action_Item__c
        List<CR_Action_Item__c> manualSteps;
        
        //Release / CR detials
        String releaseId = deploymentTrack.Deployment_Release_Project__c;
        String crId = deploymentTrack.Deployment_Change_Request__c;
        
        //Base query
        String baseQuery = 'select Id  from CR_Action_Item__c';
        String whereClause = '';
        
        //Check for CR/Release in query
        if(String.isNotBlank(releaseId))
            whereClause = whereClause + ' Change_Request__r.Release__c != null AND Change_Request__r.Release__c = \''+ releaseId + '\'';    
        else if(String.isNotBlank(crId))
            whereClause = whereClause + ' Change_Request__c = \'' + crId +'\'';
        
        //String to hold timing clause for query
        String timingClause = null;
        
        //------Pre Validation Maual steps
        if(String.isNotBlank(whereClause)){
            
           whereClause = ' where ' + whereClause ;
           timingClause =  ' AND Timing__c =\'' + DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_VALIDATION +'\'';                
        }
        
        
        String finalQuery = baseQuery + whereClause + timingClause;
        //Get manual record data
        manualSteps = Database.query(finalQuery);
        //Set count of manual steps
        deploymentTrack.No_of_Pre_Validation_Steps__c = manualSteps.size();
        
        //------Post Deployyment Maual steps
        if(String.isNotBlank(whereClause)){
            
            timingClause =  ' AND Timing__c =\'' + DeploymentWizardConstants.MANUAL_STEP_TIMING_POST_DEPLOYMENT +'\'';                
        }
        
        finalQuery = baseQuery + whereClause + timingClause;
        //Get manual record data
        manualSteps = Database.query(finalQuery);
        //Set count of manual steps
        deploymentTrack.No_of_Post_Deployment_Steps__c = manualSteps.size();
        
        //------Pre Deployment Maual steps
        if(String.isNotBlank(whereClause)){
            
            timingClause =  ' AND Timing__c =\'' + DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_DEPLOYMENT +'\'';                
        }
        
        
        finalQuery = baseQuery + whereClause + timingClause;
        
        
        manualSteps = Database.query(finalQuery);
        //Set count of manual steps
        deploymentTrack.No_of_Pre_Deployment_Steps__c = manualSteps.size();

		if(String.isNotBlank(whereClause)){
            
            timingClause =  ' AND Timing__c =\'' + DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_DEPLOYMENT +'\'';                
        }
        
        
        finalQuery = baseQuery + whereClause + timingClause;
        
        //Get manual record data
        manualSteps = Database.query(finalQuery);
        //Set count of manual steps
        deploymentTrack.No_of_Pre_Deployment_Steps__c = manualSteps.size();
        
        //------Other Maual steps
        if(String.isNotBlank(whereClause)){
            
            timingClause =  ' AND Timing__c =\'' + DeploymentWizardConstants.MANUAL_STEP_TIMING_OTHER +'\'';                
        }
        
        finalQuery = baseQuery + whereClause + timingClause;
        
        //Get manual record data
        manualSteps = Database.query(finalQuery);
        //Set count of manual steps
        deploymentTrack.No_Of_Other_Manual_Steps__c = manualSteps.size();
        
        
    }
    
     /**
     * @Description :   Method to update the manual styteos details present in a CR/ Release
     * 
     * @Modifcation :   Added By - Ishan Arora - 02/21/2018
     * 
     * @args        :   Deployment Track
     * 
     * @Return      :   Void
     * */
    public static Deployment_Track__c getManualStepsData(Deployment_Track__c deploymentTrack){
        
        //Query to get manual steps details
        Deployment_Track__c track = [Select Id ,No_of_Pre_Validation_Steps__c,No_Of_Other_Manual_Steps__c, No_of_Pre_Deployment_Steps__c, No_of_Post_Deployment_Steps__c,Performed_By__c
 										from Deployment_Track__c where id =:deploymentTrack.Id ];
        //Return deployment track record
        return track;       
    }

    /**
     * @Description :   Method used to return the CR Ids of Deployment Track. 
     * 
     * @Modifcation :   Added By - Rajeev jain
     * 
     * @args        :   Deployment Group Id
     * 
     * @Return      :   Set<Id> setofCRIds
     * */
    public Static Set<Id>  fetchCRsOfAGroup(Id groupId) {
        
        //Set to hold the Ids of Change Request.
        Set<Id> setOfCRIds = new Set<Id>();

        if(String.isNotBlank(groupId)) {

            //Query on the sub group CRs where parent group is stamped as this. 
            for(Deployment_Group__c deploymentGroup : [Select Id, Change_Request__c From Deployment_Group__c
                                                      Where Parent_Deployment_Group__c =: groupId  
                                                      AND Change_Request__c != null AND RecordType.DeveloperName = 'Sub_Group']) {
                setOfCRIds.add(deploymentGroup.Id);
            }
        }

        return setOfCRIds;
    }       

    
     /**
     * @Description :   Method used to return the CR Numbers of Deployment Track. 
     * 
     * @Modifcation :   Added By - Rajeev jain
     * 
     * @args        :   Deployment Group Id
     * 
     * @Return      :   Set<String> setofCRNumbers
     * */
    public Static Set<String>  fetchCRNumbersOfAGroup(Id groupId) {
        
        //Set to hold the Ids of Change Request.
        Set<String> setOfCRNumbers = new Set<String>();

        if(String.isNotBlank(groupId)) {

            //Query on the sub group CRs where parent group is stamped as this. 
            for(Deployment_Group__c deploymentGroup : [Select Id, Change_Request__c, Change_Request__r.Name From Deployment_Group__c
                                                      Where Parent_Deployment_Group__c =: groupId  
                                                      AND Change_Request__c != null AND RecordType.DeveloperName = 'Sub_Group']) {
                setOfCRNumbers.add(deploymentGroup.Change_Request__r.Name);
            }
        }

        return setOfCRNumbers;
    }    
	
    Public static Boolean checkIfSingleApexAdded(String crId, String releaseId) {
    	
        Set<String> setOfApexComponent = new Set<String>{'Apex Class','Apex Trigger'};
        Boolean isSingleApexAdded = false; 
        
        if(String.isNotBlank(crId)) {
        	for(Is_System_Modification__c ism : [Select Id, Is_System_Component__r.Object_Type__c 
                                                 From Is_System_Modification__c 
                                                 Where Change_Request__c =: crId 
                                                 AND Include_In_Change_Set__c = true 
                                                 AND Delete_From_Design__c = false 
                                                 AND Is_System_Component__r.Object_Type__c IN: setOfApexComponent LIMIT 1]) {
                isSingleApexAdded = true;
                return isSingleApexAdded;                                     
            }
            
        }else if(String.isNotBlank(releaseId)) {
            
            for(Is_System_Modification__c ism : [Select Id, Is_System_Component__r.Object_Type__c 
                                                 From Is_System_Modification__c 
                                                 Where Change_Request__r.Release__c  =: releaseId 
                                                 AND Include_In_Change_Set__c = true 
                                                 AND Delete_From_Design__c = false 
                                                 AND Is_System_Component__r.Object_Type__c IN: setOfApexComponent LIMIT 1]) {
                                                     
            	isSingleApexAdded = true;
                return isSingleApexAdded;
           	}
        }
        
        return isSingleApexAdded; 
    }       
}