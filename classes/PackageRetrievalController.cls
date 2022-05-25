/** 
* Description   :   Controller to run the Package Retrieval and Identify Modification error before the crosscheck process happen.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/12/2018
*
* Version       :   V1.0 Created
*                   
**/
public class PackageRetrievalController {
	
    //================= Package Retrieval Properties ========================================
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    
    //Hold the Reference of App Properties
    public DeploymentWizardBean appPropertiesRef{get;set;}
        
    //Attachent Record to Show the Deployment Package for Download
    public Attachment deploymentPackage{
        get{
            if(deploymentPackage == null){
            	
                if(processSummary != null && String.isNotBlank(processSummary.Id)){
                    return DeploymentWizardHelper.getAttachment(processSummary.Id );	    
                }
            }
            return deploymentPackage;
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
                	
                    //if Package Retrieval has run at least one time on the screen, then it must have Package Retrieval Summary Populated on it.
                    if(deploymentTrackRef.Recent_Package_Retrieval__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Package_Retrieval__c);                        
                    }else
                        //If There is no attempt to run the Package Retrieval
                        processSummary = new Deployment_Process_Summary__c();
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
        			processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Package Retrieval Record Type Id
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
            	return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_PACKAGE_RETRIEVAL_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    
    //List to hold the Test Results
    public List<Package_Retrieval_Result__c> retrievalResults{
        get{
            if(retrievalResults == null){
            	if(processSummary.Id != null)
                	retrievalResults = PackageRetrievalHelper.populateRetrievalResults(processSummary.Id);
                else
                	retrievalResults = new List<Package_Retrieval_Result__c>();    
            }
            return retrievalResults;
        }
        set;
	}
    
    //List to hold the Excluded Mods which are not part of the Deployment - Display on the screen to show to deployer
    public List<IS_System_Modification__c> excludedMods{
        get{
            if(excludedMods == null){
            	
                excludedMods = PackageRetrievalHelper.getExcludedModsList(deploymentTrackRef, appPropertiesRef);
            }
            return excludedMods; 
        }
        set;
    }
    /**
     * @Description :	Method for creating the package.xml and attaching it on the Summary Record
     * 				:	Method for hitting on the Package Retrieval end Point and 
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/20/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void retrievePackage(){
    	
        //ReInitialize Retrieval Errors
        retrievalResults = new List<Package_Retrieval_Result__c>();
        
        Deployment_Process_Summary__c previousRetrievalSummary = processSummary;
        
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
        
        //Populate Cr and Releaase Status
		DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrackRef,processSummary);
        
        //Insert the record
        insert processSummary;
        
        //Stamp this Record as latest Test Run Summary
        deploymentTrackRef.Recent_Package_Retrieval__c = processSummary.Id;
        
        //Update the Deployment Track
        update deploymentTrackRef;
        
        String attachmentId = PackageRetrievalHelper.createPackageAndAttach(deploymentTrackRef, processSummary, appPropertiesRef, excludedMods);
        
        //Update the Process Summary Record before hitting to the callout to hold the "Total Component" information.
        update processSummary;
        
        String str1 = JSON.serialize(deploymentTrackRef);
        String str2 = JSON.serialize(processSummary);
        //String str3 = JSON.serialize(appPropertiesRef);
        
        //Call WebService End Point to Hit the Heroku Services and Run the Package Retrieval Command
        PackageRetrievalHelper.retrievePackage(str1, str2);
        
    }
    
    /**
     * @Description :	Method for Checking Package Retrieval Status And show the progress till the Status is not found as Completed for Recent Package Retrieval
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/22/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void checkRetrievalStatus(){
    	
        //Get updated data from Process Summary Record
        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(processSummary.Id);
		
        if(processSummary.Status__c == 'Completed'){
            
            //Populate Retrieval Results
            retrievalResults = PackageRetrievalHelper.populateRetrievalResults(processSummary.Id);
            
            //Get Latest Retrieved Package file attached on Most Recent Package Retrieval Summary Record and make avialble to download it.
           	deploymentPackage = DeploymentWizardHelper.getAttachment(processSummary.Id);
            
            processSummary.Total_Failures__c = retrievalResults.size();
            
            //If Retreivel Results size is 0 that means there is no Retrieval Error
            if(retrievalResults.size() == 0)
            	processSummary.Retrieval_Errors_Fixed__c = true;
            
            //update the Process Summary Record to hold the infomration of Total Failures
            update processSummary;
        }
    }
}