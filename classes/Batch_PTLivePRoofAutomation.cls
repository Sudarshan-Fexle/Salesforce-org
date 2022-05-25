/**
 *  Purpose         :  This batch is used to update the PT Status to "Live proof" and Status detail to "Submitted", if
 * 		       a) If the sum of "data posted quantity" for all Recipient Batches of BatchType = 'LiveData" > X record count OR
 * 		       b) The earliest Data Posted Date for BatchType = "LiveData" is more than Y hours compared to TODAY()                         
 *                     
 *  Created By      :   Mahendra Swarnkar
 *
 *  Created Date    :   5/8/2021
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20210323-15016
 *                      
**/
global class Batch_PTLivePRoofAutomation implements Database.Batchable<sObject> {
    
    // Modified By - Victor Hanson - 07/16/2020 - CR-20200716-14325
    public String debugLogs = '';
    public string queryString;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
    	Date earliestDate = System.today();
        DateTime earliestDateTime = Datetime.newInstance(earliestDate.year(), earliestDate.month(), earliestDate.day(), 0, 0, 0);
        DateTime earliestDateTimeThreshold = earliestDateTime.addHours(Integer.valueOf(Label.Earliest_Data_Posted_Date_Threshold)); 
        
        if(String.isBlank(queryString))
        	queryString = 'Select Id, Initial_Count__c, Earliest_Data_Posted_Date_Time__c, Status__c, Status_Detail__c From Production_Tracking__c Where Initial_Count__c > ' + Label.Data_Posted_Quantity_Threshold + 'OR Earliest_Data_Posted_Date_Time__c > ' + earliestDateTimeThreshold ;
		
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext bc, List<Production_Tracking__c> listPTs) {
        
        try{
        	if(listPTs != null && listPTs.size() > 0) {
                
                //String variable to hold the error message string in case of any failure
                String logMessage = '';
                
                List<Production_Tracking__c> listProductionTrackingToUpdate = new List<Production_Tracking__c>();
                
                for(Production_Tracking__c prodTracking : listPTs){
                    prodTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
                    prodTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
                    listProductionTrackingToUpdate.add(prodTracking);
                }
                
                if(listProductionTrackingToUpdate.size() > 0){
                    //Making a try to update the list of records and recording error messages will be emailed to the SFAdmin 
                    logMessage = Util.createLog(Database.update((listProductionTrackingToUpdate),false));
                    
                    //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
                    if(logMessage != '') 
                        debugLogs += logMessage; 
                }
            }    
        } catch(Exception e) {
            debugLogs += e.getMessage();
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
        if(debugLogs != '')
        {
             Util.sendBatchStatus(BC.getJobId(), 'Batch_PTLivePRoofAutomation', debugLogs, Label.Salesforce_Admin_Email);      
        }
    }

}