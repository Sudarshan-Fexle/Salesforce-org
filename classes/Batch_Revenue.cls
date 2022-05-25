/**
 *	Purpose		:	Batch is used to associate the Deployment/Project/Site Live Date with Revenue records which have not been associated
                                with any of these records so far. 
 *
 *	Created By	:	Colin McGloin
 *
 *	Created Date	:	02/27/2019	
 *
 *	Rivision Log	:	V_1.1 - Created
 *			:       V_1.2 - Modified By - Neha Sharma - CR-20191014-13410
 *
 **/

global class Batch_Revenue implements database.Batchable<sobject>, Database.Stateful {
	
    //Debug Log
    global String debugLog;
    public string QueryString;
    public static Boolean EXECUTE_ABC_REVENUE_TRIGGER_VIA_BATCH_REVENUE = false;

    /**
     * @description: Get All of our Revenue Records for the Batch
     **/
    global database.querylocator start(database.batchableContext bc) {

        //Set to hold the Revenue Statuses we want to include in the Batch Job
		Set<String> statusesToInclude = new Set<String>{'Draft', 'Pending', 'Reviewed'};

        if (QueryString == null)
            QueryString = 'SELECT Id, Deployment__c, Site_Live_Date__c, Project__c, Program_Subscription__c, Line_Status__c FROM ABC_Revenue__c WHERE (Deployment__c = NULL AND Line_Status__c IN :statusesToInclude)';
            debugLog = '';
        return database.getquerylocator(QueryString);
    }

     /**
     * @description: Update the Revenue records which will kick off the Site Live Logic upon update
     **/
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        EXECUTE_ABC_REVENUE_TRIGGER_VIA_BATCH_REVENUE = true;
        list<ABC_Revenue__c> revenueRecords = (list<ABC_Revenue__c>) sc;
        //Update  Revenue records
        debugLog += Util.createLog(Database.update(revenueRecords , false));
    }

    global void finish(database.batchableContext bc) {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_Revenue', debugLog, Label.Salesforce_Admin_Email);	
    }

}