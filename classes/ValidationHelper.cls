/** 
* Description   :   Helper class for performing Validation operations, Saving the results and hitting Heroku End Points for perfroming Validation.
*
* Created By    :   Rajeev Jain(Simplyforce)
*
* Created Date  :   03/15/2018
*
* Version       :   V1.0 Created
*                   
**/ 
public class ValidationHelper {
    
     /**
     * @Description :   Method to populate Validation Results if one attempt aleady have been made.
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/15/2018
     * 
     * @args        :   Deployment Process Summary Record Id
     * 
     * @Return      :   List<Package_Validation_Deployment_Result__c>
     * */
    public static List<Package_Validation_Deployment_Result__c> populateValidationResults(String validationSummaryId){
        
        //Query on Retreival Results
        List<Package_Validation_Deployment_Result__c> results = [SELECT Id, API_Name__c, Type__c, Line__c, Column__c, Error_Message__c, Resolution_Note__c, 
                                                                 Record_Type__c, Package_Validation_Summary__c, Package_Deployment_Summary__c 
                                                                 FROM Package_Validation_Deployment_Result__c
                                                                 where Package_Validation_Summary__c = :validationSummaryId];
        return results;
    }
    
    /**
     * @Description :   Method to hit Heroku WebService and Run the Package Validation Operations and Save the Validation Errors and Success Results Back to the Salesforce
     * 
     * @Modifcation :   Added By - Rajeev Jain - 03/28/2018
     * 
     * @args        :   Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return      :   List<Package_Retrieval_Result__c>
     * */
    @future(callout=true)
    public static void runValidation(String trackRef, String validationSummary, String validationType, String specificTestRunClasses){
        
        Deployment_Track__c trackRefX = (Deployment_Track__c)JSON.deserialize(trackRef, Deployment_Track__c.class);
        Deployment_Process_Summary__c summaryRef = (Deployment_Process_Summary__c)JSON.deserialize(validationSummary, Deployment_Process_Summary__c.class);
        HttpRequest request = OneClick_HttpRequestBuilder.CreateRequest(validationType,trackRefX, summaryRef); 
        Http http = new Http();
        if(!Test.isRunningTest())
        	HttpResponse httpResponse = http.send(request);  
    }
    
    /**
     * @Description :   Method to hit Heroku WebService and Run the Backup of the Target org and attach it on the Validation Summary Record
     * 
     * @Modifcation :   Added By - Rajeev Jain - 04/02/2018
     * 
     * @args        :   Deployment Track Reference, Prcoess Summary Instance
     * 
     * @Return      :   List<Package_Retrieval_Result__c>
     * */
    @future(callout=true)
    public static void runTargetBackup(String trackRef, String validationSummary){
        
        Deployment_Track__c trackRefX = (Deployment_Track__c)JSON.deserialize(trackRef, Deployment_Track__c.class);
        Deployment_Process_Summary__c summaryRef = (Deployment_Process_Summary__c)JSON.deserialize(validationSummary, Deployment_Process_Summary__c.class);
        HttpRequest request = OneClick_HttpRequestBuilder.CreateRequest(DeploymentWizardConstants.DEPLOYMENT_PROCESS_REQUEST_TYPE_TARGET_BACKUP,trackRefX, summaryRef); 
        Http http = new Http();
        if(!Test.isRunningTest())
        	HttpResponse httpResponse = http.send(request);  
    }
}