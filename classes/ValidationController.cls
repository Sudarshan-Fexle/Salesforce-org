/** 
* Description   :   Controller to run the Deployment Package Validation in target org.
*				:	Used in DeploymentWizard App - OneClick Deploy
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/12/2018
*
* Version       :   V1.0 Created
*                   
**/
public class ValidationController {
	
    //================= Validation Screen Properties ========================================
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
    //Two Properties to grab Partial Validation Information
    public String specificTestRunClasses{get;set;}
    public Boolean isDefaultRun{get;set;}
    
    //Get Deployment Process Summary Instance
    public Deployment_Process_Summary__c processSummary{
        get{
            //If Instance is null then instantiate it.
            if(processSummary == null){
                
                //Check if Deployment Track Record Exist in the Database
                if(deploymentTrackRef != null && deploymentTrackRef.Id != null){
                	
                    //if Validation has run at least one time on the screen, then it must have Validation Summary Populated on it.
                    if(deploymentTrackRef.Recent_Validation__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Validation__c);                        
                    }else
                        //If There is no attempt to run the Validation
                        processSummary = new Deployment_Process_Summary__c(); 
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
        			processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Validation Summary Record Type Id
                    processSummary.RecordTypeId = processRecordTypeId;
                }
            } 
            return processSummary;
        }                                            
		set;
	}
    
    //Get Process Record Type Id
    private Id processRecordTypeId{
        get{
            if(processRecordTypeId == null){
            	return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_VALIDATION_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    
    //List to hold the Validation Results
    public List<Package_Validation_Deployment_Result__c> validationResults{
        get{
            if(validationResults == null){
                if(processSummary.Id != null)
                    validationResults = ValidationHelper.populateValidationResults(processSummary.Id);
                else
                    validationResults = new List<Package_Validation_Deployment_Result__c>();
            }
            return validationResults;
        }
        set;
	}
    
    //Boolean Property to Tell About if is there any Pre Validation Step exsit
    public Boolean isPreValidationStep{
        get{
            if(isPreValidationStep == null){
                return DeploymentWizardHelper.checkForManualStep(deploymentTrackRef, appPropertiesRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_VALIDATION);
            }
            return true;
        } 
        set;
    }
    
    //Report Link for Manual Step, Populate Dynamically
    public String reportURL{
        get{
            if(String.isBlank(reportURL)){
                reportURL = DeploymentWizardHelper.getManualStepReportLink(deploymentTrackRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_VALIDATION);
            }
            return reportURL;
        }
        set;
    }
    
    //It gives the attachment for the download
    public Attachment downloadAttachment{
        get{
            if(downloadAttachment == null){
                
                //If not any Validation attempt made yet that means get "Deployment Package" from Previous Method
                //Assuming Deployer would have performed, Crosscheck at least once or Defaul find from default crosscheck record and package must be stamped overthere
                if(String.isBlank(deploymentTrackRef.Recent_Validation__c) && String.isNotBlank(deploymentTrackRef.Recent_Crosscheck__c)){
                	return DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Crosscheck__c);	    
                }
                if(processSummary != null && String.isNotBlank(processSummary.Id)){
                    return DeploymentWizardHelper.getAttachment(processSummary.Id );	    
                }
            }
            return downloadAttachment;
        }
        set;
    }
    //It gives the Target backup attachment for the download
    public Attachment targetBackup{
        get{
            if(targetBackup == null){
                
                //If not any Validation attempt made yet that means get "Deployment Package" from Previous Method
                //Assuming Deployer would have performed, Crosscheck at least once or Defaul find from default crosscheck record and package must be stamped overthere
                if(processSummary != null && String.isNotBlank(processSummary.Id)){
                    return DeploymentWizardHelper.getTargetBackup(processSummary.Id );	    
                }else
                    return new Attachment();
            }
            return targetBackup;
        }
        set;
    }
    
    //Initialize Upload Package Instance
    public Attachment uploadPackage{
        get{
            if(uploadPackage == null){
            	uploadPackage = new Attachment();    
            } 
            return uploadPackage;
        }
		set;
	}
    
    /**
     * @Description :	Method for Uploading Zip File as a Package on latest Prcoess Summary record
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/26/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public PageReference uploadPackage(){
    	return DeploymentWizardHelper.uploadPackage(deploymentTrackRef, processRecordTypeId, appPropertiesRef, uploadPackage, processSummary);
    }
    
    //Internal Private Method to do validation
    private void doValidate(String validationType){
    	
        //Reset Validation Results
        validationResults = new List<Package_Validation_Deployment_Result__c>();
        
        //Hold the Previous Summary Record for further operations
        Deployment_Process_Summary__c previousValidationSummary = processSummary;
        
        //Insert Process Summary Record
        //DeploymentWizardHelper.insertProcessSummary(deploymentTrackRef, processSummary, appPropertiesRef, processRecordTypeId);
       	
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
        processSummary.Validation_Type__c = validationType;
        processSummary.Validated_By__c = UserInfo.getUserId();
		processSummary.Is_Package_Manually_Uploaded__c = previousValidationSummary != null ? previousValidationSummary.Is_Package_Manually_Uploaded__c : false;
        
        //Populate Cr and Releaase Status
		DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrackRef,processSummary);
        
        if(validationType == DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_PARTIAL){
        	
            processSummary.Default_Run__c = isDefaultRun;
        	processSummary.Specific_Test_Run_Classes__c = specificTestRunClasses;
        }
        //Insert the record
        insert processSummary;
        
        //Stamp this Record as latest Test Run Summary
        deploymentTrackRef.Recent_Validation__c = processSummary.Id;
        
        //Update the Deployment Track
        update deploymentTrackRef;
        
        //With Each New Process Summary Record Insertion, Stamp it as Parent Id on the Attachment of the Last Crosscheck summary record.
        //Since Last Crosscheck summary will have uploaded package if any.
        Attachment attch;
        Attachment attach1;
          
        System.debug('previousValidationSummary===='+previousValidationSummary);

        if(previousValidationSummary.Id != null){
        	
            //Get Attachment from Previous Crosscheck Record and Stamp it on the Newer One
            attch = DeploymentWizardHelper.getAttachment(previousValidationSummary.Id);
            attach1 = DeploymentWizardHelper.getAttachmentPackageXml(previousValidationSummary.Id);
            
        }else if(deploymentTrackRef.Recent_Crosscheck__c != null){
            
            //Case when there is no previous crosscheck done yet, or fresh crosscheck run, 
            //that means Latest Deployment Package should be stamped through Recent Package Retrieval Record from Last Step
            //Get attached package from it.
            attch = DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Crosscheck__c);
        }else if(deploymentTrackRef.Is_Back_Sync__c && String.isNotBlank(deploymentTrackRef.Recent_Package_Retrieval__c)){
            attch = DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Package_Retrieval__c);
		}
        
        if(attch.Id != null ){
            Attachment insertAttachment = new Attachment();
            insertAttachment.Body = attch.Body;
            insertAttachment.ParentId = processSummary.Id;
            insertAttachment.Name = attch.Name;
            insert insertAttachment;
        }
        
        if(attach1 != null && attach1.Id != null ){
            Attachment insertAttachment = new Attachment();
            insertAttachment.Body = attach1.Body;
            insertAttachment.ParentId = processSummary.Id;
            insertAttachment.Name = attach1.Name;
            insert insertAttachment;
        }
        
        //Make the Objects to Serialize to pass them in Future method for making callout to Heroku WebService to Run the validation process
        String str1 = JSON.serialize(deploymentTrackRef);
        String str2 = JSON.serialize(processSummary);
        
        ValidationHelper.runValidation(str1, str2, validationType , '');
    }
    /**
     * @Description :	Method to validate latest deployment package based on what target selected.
     * 				:	For Success Validation 
     * 				: 	Patial Validation - It means it run specific test only while deploying in Target Org in case of Production/Developer Org	
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/28/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void doPartialValidate(){
        doValidate(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_PARTIAL);
    }
    
    /**
     * @Description :	Method to validate latest deployment package based on what target selected.
     * 				:	For Success Validation 
     * 					
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/28/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void fullValidate(){
		doValidate(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_VALIDATE_FULL);        
    }
    /**
     * @Description :	Method for Checking Validation Status And show the progress till the Status is not found as Completed for Recent Validation Attempt
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/29/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void checkValidationStatus(){
    	
        //Re Populate Process Summary Data.
        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(processSummary.Id);
        
        if(processSummary.Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED){
            
            //Populate Retrieval Results
            validationResults = ValidationHelper.populateValidationResults(processSummary.Id);
            
            //Get Latest Retrieved Package file attached on Most Recent Package Retrieval Summary Record and make avialble to download it.
           	downloadAttachment = DeploymentWizardHelper.getAttachment(processSummary.Id);
        }
    }
    
    /**
     * @Description :	Method to take backup of the Target Org, once validation got completed
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/02/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void runTargetBackup(){
    	
        processSummary.Target_Backup_Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED;
        
        //Make the Objects to Serialize to pass them in Future method for making callout to Heroku WebService to Run the validation process
        String str1 = JSON.serialize(deploymentTrackRef);
        String str2 = JSON.serialize(processSummary);
        
        ValidationHelper.runTargetBackup(str1, str2);
    }
    
    /**
     * @Description :	Method to check Target backup Status, if it is found as "Completed", Process is ready to move on the Deployment Screen
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/02/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void checkTargetBackupStatus(){
    	
        //Query on Latest Package Retrieval Summary record and Keep checking status of Retrieval.
        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(processSummary.Id);
        
        //Get Attachment Once Target Backup Completed
        if(processSummary.Target_Backup_Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED)
        	targetBackup = DeploymentWizardHelper.getTargetBackup(processSummary.Id);
    }
}