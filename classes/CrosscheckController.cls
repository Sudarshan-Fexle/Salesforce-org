/** 
* Description   :   Controller for handling crosscheck functions on the crosscheck screen for the DeploymentWizard application in "OneClick Deploy"
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/22/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class CrosscheckController {
	
    //================ Crosscheck Properties ======================================
    
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
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
    
    public Attachment downloadAttachment{
        get{
            if(downloadAttachment == null){
                
                //If not any crosscheck attempt made yet that means get "Deployment Packge" from Previous Method
                //Assuming Deployer would have performed, package retrieval at least once and package must be stamped overthere
                if(String.isBlank(deploymentTrackRef.Recent_Crosscheck__c) && String.isNotBlank(deploymentTrackRef.Recent_Package_Retrieval__c)){
                	return DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Package_Retrieval__c);	    
                }
                if(processSummary != null && String.isNotBlank(processSummary.Id)){
                    return DeploymentWizardHelper.getAttachment(processSummary.Id );	    
                }
            }
            return downloadAttachment;
        }
        set;
    }
    
    //Get Deployment Process Summary Instance
    public Deployment_Process_Summary__c processSummary{
        get{
            //If Instance is null then instantiate it.
            if(processSummary == null){
                
                //Check if Deployment Track Record Exist in the Database
                if(deploymentTrackRef != null && deploymentTrackRef.Id != null){
                	
                    //if Crososcheck Process has run at least one time on the screen, then it must have Crosscheck Summary Populated on it.
                    if(deploymentTrackRef.Recent_Crosscheck__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Crosscheck__c);                        
                    }else
                        //If There is no attempt to run the crosscheck 
                        processSummary = new Deployment_Process_Summary__c();
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
        			processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Crosscheck Record Type Id
                    processSummary.RecordTypeId = processRecordTypeId;
                }
            } 
            return processSummary;
        }                                            
		set;
	}
    
    //Populate Crosscheck Results Data
    public List<CrosscheckResultsWrapper> resultsWrapper{
        get{
            if(resultsWrapper == null){
                if(processSummary.Id != null){
                    resultsWrapper = CrosscheckHelper.populateCrosscheckResults(processSummary.Id);    
                }else
                    resultsWrapper = new List<CrosscheckResultsWrapper>();
            }
            return resultsWrapper;
        }
		set;
    }
    
    //Get Process Record Type Id
    private Id processRecordTypeId{
        get{
            if(processRecordTypeId == null){
            	return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_CROSSCHECK_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    
    /**
     * @Description :	Method for running the crosscheck across the releases and CRs. Used on DeploymentWizard VF page
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/23/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void doCrosscheck(){
        
        Deployment_Process_Summary__c previousCrosscheckRecord = processSummary;
        
        //Insert New Crosscheck Summary Record and Stamp it on the latest Deployment Track Record
        //On each time run of the crosscheck insert Crosscheck Summary record and stamp it on the Deployment Track record id
        processSummary = new Deployment_Process_Summary__c();
        processSummary.Deployment_Track__c = deploymentTrackRef.Id;
        processSummary.RecordTypeId = processRecordTypeId;
        //processSummary.CR_Status__c = deploymentTrackRef.Deployment_Change_Request__c != null ? deploymentTrackRef.Deployment_Change_Request__r.Status__c : '';
        //processSummary.Release_Status__c = deploymentTrackRef.Deployment_Release_Project__c != null ? deploymentTrackRef.Deployment_Release_Project__r.Status__c : '';
        processSummary.Run_By__c = UserInfo.getUserId();
        processSummary.Start_Date__c = DateTime.now();
        processSummary.Release_Project__c = deploymentTrackRef.Deployment_Release_Project__c;
        processSummary.Change_Request__c = deploymentTrackRef.Deployment_Change_Request__c;
        processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_STARTED;
        
        //Populate Cr and Releaase Status
		DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrackRef,processSummary);
        
        //Insert the record
        insert processSummary;
       
        //Reset variables
        resultsWrapper = CrosscheckHelper.runAndSaveCrosscheckResults(deploymentTrackRef, processSummary);
        
        //Update the Process Summary Records As Well
        processSummary.Total_Overlapping_found__c = resultsWrapper.size();
        processSummary.End_Date__c = DateTime.now();
        processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED;
        
        //Populate Total Component Counter from Package Retrieval Summary Record
        if(deploymentTrackRef.Recent_Package_Retrieval__c != null){
            Deployment_Process_Summary__c retrievalSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Package_Retrieval__c);
            processSummary.Total_Component__c = retrievalSummary.Total_Component__c;
        }
            
        update processSummary;
            
        //Update with Recent Record
        //Update Deployment Track Ref as Latest Record
        deploymentTrackRef.Recent_Crosscheck__c = processSummary.Id;
        update deploymentTrackRef;
        
        //With Each New Process Summary Record Insertion, Stamp it as Parent Id on the Attachment of the Last Crosscheck summary record.
        //Since Last Crosscheck summary will have uploaded package if any.
        Attachment attch;
          
        if(previousCrosscheckRecord.Id != null){
        	
            //Get Attachment from Previous Crosscheck Record and Stamp it on the Newer One
            attch = DeploymentWizardHelper.getAttachment(previousCrosscheckRecord.Id);
        }else if(deploymentTrackRef.Recent_Package_Retrieval__c != null){
            
            //Case when there is no previous crosscheck done yet, or fresh crosscheck run, 
            //that means Latest Deployment Package should be stamped through Recent Package Retrieval Record from Last Step
            //Get attached package from it.
            attch = DeploymentWizardHelper.getAttachment(deploymentTrackRef.Recent_Package_Retrieval__c);
        }
        if(attch.Id != null ){
            Attachment insertAttachment = new Attachment();
            insertAttachment.Body = attch.Body;
            insertAttachment.ParentId = processSummary.Id;
            insertAttachment.Name = attch.Name;
            insert insertAttachment;
        }
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
        system.debug('deploymentTrackRef'+deploymentTrackRef);
        system.debug('processRecordTypeId'+processRecordTypeId);
        system.debug('appPropertiesRef'+appPropertiesRef);
        system.debug('uploadPackage'+uploadPackage);
        system.debug('processSummary'+processSummary);
        return DeploymentWizardHelper.uploadPackage(deploymentTrackRef, processRecordTypeId, appPropertiesRef, uploadPackage, processSummary);
    }
    
    //Get timezone offset to show the Corsscheck Results in the User Specific Timezone and format - Added By - Rajeev jain
    public Double offset{
        get{
            
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    	}
    }
}