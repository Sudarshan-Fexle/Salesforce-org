/*
Purpose         :   Batch to do the calculation and then update the milestone tracking due dates on production tracking records.

Created By      :   Neha Sharma

Created Date    :   02/09/2021

Current Version :   V1.0

Revision Log    :   V_1.0 Created - CR-20210122-14829 - 02/09/2021
*/
global class Batch_UpdateRTOnOpportunity implements database.Batchable<sobject>, Database.Stateful {
    
    //Debug Log
    global String debugLog ='';
    //get record id
    Id legacyABCOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Legacy ABC Opp').getRecordTypeId();
    
    global database.querylocator start(database.batchableContext bc) 
    {
        //query to get all opportunity
        String query = 'SELECT Id, RecordTypeId FROM Opportunity WHERE RecordTypeId = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bd, List<Opportunity> opportunities) 
    {
        //check list size
        if(opportunities.size() > 0) {
            
            for(Opportunity opp : opportunities) {
                //assign record type to all opps
                opp.RecordTypeId = legacyABCOppRTId;
            }
            
            Util.bypassAlltriggers = true;
            debugLog += Util.createLog(Database.update(opportunities, false));
            Util.bypassAlltriggers = false;
        }
    }     
    
    global void finish(Database.BatchableContext ctx)
    {
        //Checking logMessage string for blank value but if it does not have blank value with it then emailed it to user.
        if(debugLog != '') 
            Util.sendBatchStatus(ctx.getJobId(), 'Batch_UpdateRTOnOpportunity', debugLog, 'neha.piproniya@fexle.com');
    }
}