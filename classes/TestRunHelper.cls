/** 
* Description   :   Helper class for TesrRunController, perform TestRun Operations on DeploymentWizard App - OneClick Deploy
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   02/27/2018
*
* Version       :   V1.0 Created
					v1.2 Modify by Ishan Arora  03/07/2018- CR-20180702-12314 - issue resolved of 50001 rows error
*                   
**/
public class TestRunHelper {
	
     /**
     * @Description :	Method to Query Test Run Results and Display on the screens
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 02/27/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public Static List<Test_Result__c> populateTestResults(String recentTestRunId){
        
        //Query on Test Run Records
        //List to Hold the Test Results
        List<Test_Result__C> testResults = [SELECT Id, Main_Class_Id__c, Class_Type__c, Coverage__c, 
                                            Errors__c, Main_Class_Name__c, Method_Name__c, Result__c, 
                                            Stack_Trace__c, Test_Class_Id__c, Test_Class_Name__c, Total_Line__c, Total_Number_of_Covered_Line__c, 
                                            IS_System_Modification__c, IS_System_Modification__r.Name, Test_Run_Summary__c 
                                            FROM Test_Result__c where Test_Run_Summary__c = :recentTestRunId];
        
        return testResults;
    }
    /**
     * @Description :	Method to Query Test Run Status and Display on the screen
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/06/2018
     * 
     * @args		:	
     * 
     * @Return		:	Void
     * */
    public Static List<Test_Run_Status__c> populateTestRunStatus(String recentTestRunId){
        
        //Query on Test Run Records
        //List to Hold the Test Results
        List<Test_Run_Status__c> testResults = [SELECT Id, Main_Class__c, Main_Class__r.IS_System_Modification__c, Main_Class__r.IS_System_Modification__r.Name,
                                                Test_Class__c, Test_Class__r.IS_System_Modification__c, Test_Class__r.IS_System_Modification__r.Name, 
                                                Test_Summary__c, Code_Coverage__c, Method_Name__c, Test_Result__c, Error__c, Stack_Trace__c, 
                                                Main_Class_ID__c, Test_Class_Id__c, Main_Class_Name__c, Test_Class_Name__c, Total_Lines_Covered__c, Total_Lines__c 
                                            	FROM Test_Run_Status__c where Test_Summary__c = :recentTestRunId];
        
        return testResults;
    }
    /**
     * @Description :	Method to hit Heroku WebService and Run the Test Run in Source org and store the results in the Controlling Org.
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 03/29/2018
     * 
     * @args		:	Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return		:	List<Package_Retrieval_Result__c>
     * */
    @future(callout=true)
    public static void runTest(String trackRef, String testRunSummary){
        
        Deployment_Track__c trackRefX = (Deployment_Track__c)JSON.deserialize(trackRef, Deployment_Track__c.class);
        Deployment_Process_Summary__c summaryRef = (Deployment_Process_Summary__c)JSON.deserialize(testRunSummary, Deployment_Process_Summary__c.class);
        HttpRequest request = OneClick_HttpRequestBuilder.CreateRequest(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_TEST_RUN,trackRefX, summaryRef); 
        Http http = new Http();
        if(!Test.isRunningTest())
			HttpResponse httpResponse = http.send(request);  
    }
    
    /**
     * @Description :	Method to Check if Test Class Run is Required or not by querying on SFDC Mods
     * 
     * @Modifcation	:	Added By - Rajeev Jain - 04/11/2018
     * 
     * @args		:	Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return		:	Boolean flag
     * 
     * Version      :   V1.0 Created
     * 					V1.2 Modify by Rajeev Jain 03/07/2018- CR-20180702-12314
     * */
    public static Boolean isTestRunRequired(Deployment_Track__c deploymentTrackRef ){
        //Modify by Rajeev Jain  03/07/2018- CR-20180702-12314
        String releaseId = deploymentTrackRef.Deployment_Release_Project__c;
        String crId = deploymentTrackRef.Deployment_Change_Request__c;       
        
        //Query on Mods to filter out "Custom Object" mods 
        List<IS_System_Modification__c> apexClassesMods ;
        
        //Check if deployment track contains release id
        if(String.isNotBlank(releaseId)) 
            apexClassesMods = [select Id from IS_System_Modification__c 
                               where IS_System_Component__r.Object_Type__c IN :DeploymentWizardConstants.apexBasedComponents AND Change_Request__r.Release__c =:releaseId AND Delete_from_Design__c = false ];
        
        //Check if deployment track contains release id
        if(String.isNotBlank(crId)) 
            apexClassesMods = [select Id from IS_System_Modification__c 
                               where IS_System_Component__r.Object_Type__c IN :DeploymentWizardConstants.apexBasedComponents AND  Change_Request__c =: crId  AND Delete_from_Design__c = false];
        
        //Modify by Rajeev Jain 03/07/2018- CR-20180702-12314
        
        //If any Mod exist related to Apex, then Test Run is Required.
        if(apexClassesMods.size() > 0)
            return true;
        else
            return false;
    }
}