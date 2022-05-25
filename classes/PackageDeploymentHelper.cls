/** 
* Description   :   Helper class for performing Deployment operations, Saving the results and hitting Heroku End Points for perfroming Deployment.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/15/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class PackageDeploymentHelper {
    
    /**
     * @Description :   Method to populate Deployment Results if one attempt aleady have been made.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/15/2018
     * 
     * @args        :   Deployment Process Summary Record Id
     * 
     * @Return      :   List<Package_Validation_Deployment_Result__c>
     * */
    public static List<Package_Validation_Deployment_Result__c> populateDeploymentResults(String deploymentSummaryId){
        
        //Query on Retreival Results
        List<Package_Validation_Deployment_Result__c> results = [SELECT Id, API_Name__c, Type__c, Line__c, Column__c, Error_Message__c, Resolution_Note__c, 
                                                                 Record_Type__c, Package_Validation_Summary__c, Package_Deployment_Summary__c 
                                                                 FROM Package_Validation_Deployment_Result__c
                                                                 where Package_Deployment_Summary__c = :deploymentSummaryId];
        return results;
    }
    
     /**
     * @Description :   Method to hit Heroku WebService and Run the Package Validation Operations and Save the Validation Errors and Success Results Back to the Salesforce
     * 
     * @Modifcation :   Added By - Rajeev Jain - 04/03/2018
     * 
     * @args        :   Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return      :   List<Package_Retrieval_Result__c>
     * */
    @future(callout=true)
    public static void runDeployment(String trackRef, String deploymentSummary, String deploymentType){
        
        Deployment_Track__c trackRefX = (Deployment_Track__c)JSON.deserialize(trackRef, Deployment_Track__c.class);
        Deployment_Process_Summary__c summaryRef = (Deployment_Process_Summary__c)JSON.deserialize(deploymentSummary, Deployment_Process_Summary__c.class);
        HttpRequest request = OneClick_HttpRequestBuilder.CreateRequest(deploymentType,trackRefX, summaryRef); 
        Http http = new Http();
        if(!Test.isRunningTest())
        	HttpResponse httpResponse = http.send(request);  
    }
}