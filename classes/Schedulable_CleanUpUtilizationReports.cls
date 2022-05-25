/*
    Purpose            :    Schedulable to query for all Utilization Report Output records with a Created Date greater than 30 days in the past.    
        
    Created By         :    Colin McGloin
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Colin McGloin - CR-20180629-12311 - 09/10/2018
    */

global class Schedulable_CleanUpUtilizationReports implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        //Get record type Id for Utilization Report Output
        Id UtilizationReportOutputRecordTypeId; 
        
        //List of record types
        List<RecordType> rTypes = [SELECT Id FROM RecordType 
                                       WHERE DeveloperName = 'Utilization_Report_Output' 
                                       AND sobjectType = 'Utilization_Report__c' 
                                       AND IsActive = true];
        //Checking list for size
        if(rTypes != null && rTypes.size() > 0) {
        
            //Variable to hold the record type ID of "Utilization Report Output" type
            UtilizationReportOutputRecordTypeId = rTypes[0].ID;
            
            //Initializing batch instance and populating attributes with values
            Batch_DeleteSObjects sObj_DeletedRecords = new Batch_DeleteSObjects('Utilization_Report__c');
            
            //Setting query string value
            sObj_DeletedRecords.Query = 'Select Id FROM Utilization_Report__c Where createdDate < LAST_N_DAYS:30 AND RecordTypeId = '  + '\'' + UtilizationReportOutputRecordTypeId + '\'';
            
            //Making a try to execute the batch
            try {    
                ID batchprocessid1 = Database.executeBatch(sObj_DeletedRecords, 200);
            }catch(Exception ex) {
                System.debug('Exception message ---- '+ex.getMessage());
            }
        }
    }    
}