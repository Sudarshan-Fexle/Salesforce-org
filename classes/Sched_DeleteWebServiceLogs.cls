global class Sched_DeleteWebServiceLogs implements Schedulable
{
    /*
    Purpose            :    Schedular to query for all Web Service Logs with a Created Date greater than 30 days in the past.    
        
    Created By         :    Ajit Surana
    
    Current Version    :    v1.0
    
    Revision Log       :    v1.0 - Ajit Surana - CR-20150122-8591 - 02/23/2015
    */
    
    global void execute(SchedulableContext SC) {
        
        //Get record type Id for Internal_Tracking
        Id internal_TrackingRecordTypeId; 
        
        //List of record types
        List<RecordType> rTypes = [SELECT Id FROM RecordType 
                                       WHERE DeveloperName = 'Internal_Tracking' 
                                       AND sobjectType = 'Web_Service_Log__c' 
                                       AND IsActive = true];
        //Checking list for size
        if(rTypes != null && rTypes.size() > 0) {
        
            //Variable to hold the record type ID of "Internal Tracking" type
            internal_TrackingRecordTypeId = rTypes[0].ID;
            
            //Initializing batch instance and populating attributes with values
            Batch_DeleteSObjects sObj_DeletedRecords = new Batch_DeleteSObjects('Web_Service_Log__c');
            
            //Setting query string value
            sObj_DeletedRecords.Query = 'Select Id FROM Web_Service_Log__c Where createdDate < LAST_N_DAYS:30 AND RecordTypeId != '  + '\'' + internal_TrackingRecordTypeId + '\'';
            
            //Making a try to execute the batch
            try {    
                ID batchprocessid1 = Database.executeBatch(sObj_DeletedRecords, 200);
            }catch(Exception ex) {
                System.debug('Exception message ---- '+ex.getMessage());
            }
        }
    }    
}