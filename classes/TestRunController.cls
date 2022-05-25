/** 
* Description   :   Controller to run the Test Methods in the Source Org from Test Run Screen on DeploymentWizard App - OneClick Deploy
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/27/2018
*
* Version       :   V1.0 Created
* 					v1.2 Modify by Rajeev Jain  03/07/2018- CR-20180702-12314 - issue resolved of 50001 rows error
*                   
**/
public class TestRunController {
	
    //================= Test Run Properties ========================================
    //Holding the Reference of the Deployment Track Object
    public Deployment_Track__c deploymentTrackRef{get;set;}
    public DeploymentWizardBean appPropertiesRef{get;set;}
    
    //List to hold the Test Results
    public List<Test_Result__c> testResults{
        get{
            if(testResults == null){
            	if(processSummary.Id != null)
                	testResults = TestRunHelper.populateTestResults(processSummary.Id);
                else
                	testResults = new List<Test_Result__c>();    
            }   
            return testResults;
        }
        set;
	}
    
    //List to hold the Test Results
    public List<Test_Run_Status__c> testRunStatus{
        get{
            if(testRunStatus == null){
            	if(processSummary.Id != null)
                	testRunStatus = TestRunHelper.populateTestRunStatus(processSummary.Id);
                else
                	testRunStatus = new List<Test_Run_Status__c>();    
            }   
            return testRunStatus;
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
                	
                    //if Test has run at least one time on the screen, then it must have Test Run Summary Populated on it.
                    if(deploymentTrackRef.Recent_Test_Run__c != null){
                        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(deploymentTrackRef.Recent_Test_Run__c);                        
                    }else
                        //If There is no attempt to run the Test 
                        processSummary = new Deployment_Process_Summary__c();
                    
                    //Populate Deployment Track Ref Record on the Process Summary Record
        			processSummary.Deployment_Track__c = deploymentTrackRef.Id;
                    
                    //Populate Test Run Record Type Id
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
            	return DeploymentWizardHelper.getRecordTypeId('Deployment_Process_Summary__c', DeploymentWizardConstants.DEPLOYMENT_PROCESS_TEST_RUN_SUMMARY);    
            }
            return processRecordTypeId;
        }
        set;
    }
    
    //Property to Tell on the screen, that any test class exist?
    public Boolean isTestRunRequired{
        get{
            if(isTestRunRequired == null){
                   // Modify by Rajeev Jain  03/07/2018- CR-20180702-12314 
                isTestRunRequired = TestRunHelper.isTestRunRequired(deploymentTrackRef /*, appPropertiesRef */); 
                deploymentTrackRef.Is_Test_Run_Required__c = isTestRunRequired;
            	return isTestRunRequired;
            }
            return isTestRunRequired;
        }
        set;
    }
    /**
     * @Description :	Method for running the Test Run in the Source based on the Test Classes and Main Classes attached
     * 					On Deployment CR or Deployment Release. Used on DeploymentWizard VF page
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/27/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void runTest(){
        
        //Reinitialize
        testRunStatus = new List<Test_Run_Status__c>();
        //testResults = new List<Test_Result__c>();
        
		Deployment_Process_Summary__c previousTestRunSummary = processSummary;
        
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
        
        //Populate CR and Release Status Respectively
        DeploymentWizardHelper.populateCRAndReleaseStatus(deploymentTrackRef, processSummary);
        
        //Insert the record
        insert processSummary;
        
        //Stamp this Record as latest Test Run Summary
        deploymentTrackRef.Recent_Test_Run__c = processSummary.Id;
        
        //Update the Deployment Track
        update deploymentTrackRef;
        
        String str1 = JSON.serialize(deploymentTrackRef);
        String str2 = JSON.serialize(processSummary);
        //String str3 = JSON.serialize(appPropertiesRef);
        
        //Call WebService End Point to Hit the Heroku Services and Run the Package Retrieval Command
        TestRunHelper.runTest(str1, str2);
    }
    
    /**
     * @Description :	Method for Checking Test Run Status if status is 'Completed', show the results on the Page.
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/22/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public void checkTestRunStatus(){
    	
        processSummary = DeploymentWizardHelper.populateDeploymentProcessSummary(processSummary.Id);
         
        //processSummary.Status__c = DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED;
        if(processSummary.Status__c == DeploymentWizardConstants.DEPLOYMENT_PROCESS_STATUS_COMPLETED){
            
            //Populate Retrieval Results
            //testResults = TestRunHelper.populateTestResults(processSummary.Id);
            testRunStatus = TestRunHelper.populateTestRunStatus(processSummary.Id);
        }
    }
}