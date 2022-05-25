/** 
* Description   :   Controller to run the Deployment Package Validation in target org.
*				:	Used in DeploymentWizard App - OneClick Deploy
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/15/2018
*
* Version       :   V1.0 Created
*                   
**/
public class PackageDeploymentController {
	
    //================= Deployment Screen Properties ========================================
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
    //Populate Validation Summary Record
    public Deployment_Process_Summary__c validationSummary{get;set;}
    
    //Get Deployment Process Summary Instance
    public Deployment_Process_Summary__c processSummary{
        get{
            //If Instance is null then instantiate it.
            if(processSummary == null){
                
                //Check if Deployment Track Record Exist in the Database
                if(deploymentTrackRef != null && deploymentTrackRef.Id != null){
                	
                    //if Deployment has run at least one time on the screen, then it must have Recent Deployment Populated on it.
                    if(deploymentTrackRef.Recent_Deployment__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Deployment__c); 
                    }else
                        //If There is no attempt to run the Deployment
                        processSummary = new Deployment_Process_Summary__c();
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
        			processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Validation Summary Record Type Id
                    processSummary.RecordTypeId = processRecordTypeId;
                    
                    //Populate Most Recent Validation Summary Record
                    if(deploymentTrackRef.Recent_Validation__c != null)
                        validationSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Validation__c);
                    else 
                        validationSummary = new Deployment_Process_Summary__c();
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
            	return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_DEPLOYMENT_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    
    //List to hold the Test Results
    public List<Package_Validation_Deployment_Result__c> deploymentResults{
        get{
            if(deploymentResults == null && processSummary.Id != null){
            	
                deploymentResults = ValidationHelper.populateValidationResults(processSummary.Id);
            }else
                deploymentResults = new List<Package_Validation_Deployment_Result__c>();
            return deploymentResults;
        }
        set;
	}
    
     //Boolean Property to Tell About if is there any Pre Validation Step exsit
    public Boolean isPreDeploymentStep{
        get{
            if(isPreDeploymentStep == null){
                return DeploymentWizardHelper.checkForManualStep(deploymentTrackRef, appPropertiesRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_DEPLOYMENT);
            }
            return true;
        } 
        set;
    }
    
    //Boolean Property to Tell About if is there any Pre Validation Step exsit
    public Boolean isPostDeploymentStep{
        get{
            if(isPostDeploymentStep == null){
                return DeploymentWizardHelper.checkForManualStep(deploymentTrackRef, appPropertiesRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_POST_DEPLOYMENT);
            }
            return true;
        } 
        set;
    }

    //Report Link for Manual Step, Populate Dynamically
    public String reportURL{
        get{
            if(String.isBlank(reportURL)){
                reportURL = DeploymentWizardHelper.getManualStepReportLink(deploymentTrackRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_PRE_DEPLOYMENT);
            }
            return reportURL;
        }
        set;
    }
    
    //Report Link for Manual Step for Post Deployment, Populate Dynamically
    public String reportURLPostDeployment{
        get{
            if(String.isBlank(reportURLPostDeployment)){
                reportURLPostDeployment = DeploymentWizardHelper.getManualStepReportLink(deploymentTrackRef, DeploymentWizardConstants.MANUAL_STEP_TIMING_POST_DEPLOYMENT);
            }
            return reportURLPostDeployment;
        }
        set;
    }
    
    //Prop to Show Quick Deploy button and Quick Deploy Message
    public Boolean isForQuickDeploy{
        get{
            if(isForQuickDeploy == null){
                if(validationSummary != null && String.isNotBlank(validationSummary.Id)){
                    Decimal daysUntilValidated = DeploymentWizardHelper.daysDifferenceBetweenDateTimes(DateTime.now(),validationSummary.End_Date__c);
                    if(validationSummary.Available_for_Quick_Deploy__c && daysUntilValidated <= DeploymentWizardConstants.QUICK_DEPLOYMENT_OPTION_DAYS_LIMIT)
                        isForQuickDeploy = true; 
                    else
                        isForQuickDeploy = false;
                }
            }
            return isForQuickDeploy;
		}
        set;
    }
    
    //It gives the Target backup attachment for the download
    public Attachment targetBackup{
        get{
            if(targetBackup == null){
                
                //If not any Validation attempt made yet that means get "Deployment Package" from Previous Method
                //Assuming Deployer would have performed, Crosscheck at least once or Defaul find from default crosscheck record and package must be stamped overthere
                if(validationSummary != null && String.isNotBlank(validationSummary.Id)){
                    return DeploymentWizardHelper.getTargetBackup(validationSummary.Id );	    
                }else
                    return new Attachment();
            }
            return targetBackup; 
        }
        set;
    }
    
    //It gives the attachment for the download of the Deployment Package
    public Attachment downloadAttachment{
        get{
            if(downloadAttachment == null){
                
                //If not any deployment attempt made yet, that means get "Deployment Package" from Previous Method pr from Validation Summary
                //Assuming Deployer would have performed, Crosscheck at least once or Defaul find from default crosscheck record and package must be stamped overthere
                if(String.isBlank(deploymentTrackRef.Recent_Deployment__c) && validationSummary != null && String.isNotBlank(validationSummary.Id)){
                	return DeploymentWizardHelper.getAttachment(validationSummary.Id);	    
                }
                if(processSummary != null && String.isNotBlank(processSummary.Id)){
                    return DeploymentWizardHelper.getAttachment(processSummary.Id );	    
                }
            }
            return downloadAttachment;
        }
        set;
    }
    
    /**
     * @Description :	Method for Hitting Deploy Heroku Web Service and Deploy the Deployment Package in Target Org
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/03/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
	private void doDeployment(String deploymentType){
 		
        //Reset Validation Results
        deploymentResults = new List<Package_Validation_Deployment_Result__c>();
        
        //Hold the Previous Summary Record for further operations
        Deployment_Process_Summary__c previousDeploymentSummary = processSummary;
        
        //Insert Process Summary Record
        //DeploymentWizardHelper.insertProcessSummary(deploymentTrackRef, processSummary, appPropertiesRef, processRecordTypeId);
       	
        //Insert New Summary Record and Stamp it on the latest Deployment Track Record
        //On each time run of deployment and stamp it on the Deployment Track record id
        processSummary = new Deployment_Process_Summary__c();
        processSummary.Deployment_Track__c = deploymentTrackRef.Id;
        processSummary.RecordTypeId = processRecordTypeId;
        processSummary.Run_By__c = UserInfo.getUserId();
        processSummary.Start_Date__c = DateTime.now();
        processSummary.Release_Project__c = deploymentTrackRef.Deployment_Release_Project__c;
        processSummary.Change_Request__c = deploymentTrackRef.Deployment_Change_Request__c;
        processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED;
        processSummary.Deployment_Type__c = deploymentType;
        processSummary.ValidationId__c = validationSummary.ValidationId__c;
        processSummary.Available_for_Quick_Deploy__c = validationSummary.Available_for_Quick_Deploy__c;
        
        //Populate Cr and Releaase Status
		DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrackRef,processSummary);
        
        //Insert the record
        insert processSummary;
        
        //Stamp this Record as latest Test Run Summary
        deploymentTrackRef.Recent_Deployment__c = processSummary.Id;
        
        //Update the Deployment Track
        update deploymentTrackRef;
        
        //With Each New Process Summary Record Insertion, Stamp it as Parent Id on the Attachment of the Last Crosscheck summary record.
        //Since Last Crosscheck summary will have uploaded package if any.
        Attachment attch;
          
        if(previousDeploymentSummary.Id != null){
        	
            //Get Attachment from Previous Crosscheck Record and Stamp it on the Newer One
            attch = DeploymentWizardHelper.getAttachment(previousDeploymentSummary.Id);
            
        }else if(deploymentTrackRef.Recent_Validation__c != null){
            
            //Case when there is no previous crosscheck done yet, or fresh crosscheck run, 
            //that means Latest Deployment Package should be stamped through Recent Package Retrieval Record from Last Step
            //Get attached package from it.
            attch = DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Validation__c);
        }
        if(attch.Id != null ){
            Attachment insertAttachment = new Attachment();
            insertAttachment.Body = attch.Body;
            insertAttachment.ParentId = processSummary.Id;
            insertAttachment.Name = attch.Name;
            insert insertAttachment;
        }
        
        //Make the Objects to Serialize to pass them in Future method for making callout to Heroku WebService to Run the validation process
        String str1 = JSON.serialize(deploymentTrackRef);
        String str2 = JSON.serialize(processSummary);
        
        //ValidationHelper.runValidation(str1, str2, validationType , '');
        PackageDeploymentHelper.runDeployment(str1, str2, deploymentType);
    }
    
    /**
     * @Description :	Method for Hitting Deploy Heroku Web Service for running quick deployment.
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/03/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void doQuickDeployment(){
    	
        doDeployment(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_QUICK_DEPLOY);
    }
    
    /**
     * @Description :	Method for Hitting Deploy Heroku Web Service for ruuning full deployment
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/03/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void doFullDeployment(){
        doDeployment(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_DEPLOY);
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
    public void checkDeploymentStatus(){
    	
        //Query on Latest Package Retrieval Summary record and Keep checking status of Retrieval.
        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(processSummary.Id);
        
        if(processSummary.Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED){
            
            //Populate Retrieval Results
            deploymentResults = PackageDeploymentHelper.populateDeploymentResults(processSummary.Id);
        }
    }
}