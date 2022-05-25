/**
 * Desription      :   	Batch job runs nightly to check Memberships and update their Status accordingly as needed
 * 
 * Created By      :   	Colin McGloin
 * 
 * Created Date    :   	10/03/2019
 * 
 * Revision Logs   :   	v1.0 - Created
 **/

global with sharing class Batch_NightlyMembershipStatusCheck implements database.batchable<sobject> {

    //String for Query
    global String debugLog;
    public string QueryString;

    global Batch_NightlyMembershipStatusCheck() {

        //Query for the records 
        if (QueryString == null)
        QueryString = 'SELECT Id, Name, Active_Contract_Idenfied__c, Earliest_Contract__c, Latest_Contract__c, Earliest_Subscription__c,' +
                        'Active_Subscription__c, Latest_Subscription__c, Program_Business_Line__c, Membership_Status_Text__c, Membership_Status_Change_Date__c ' +
                        'FROM Membership__c WHERE (Active_Subscription__r.SBQQ__StartDate__c >= LAST_N_DAYS:3 OR Active_Contract_Idenfied__r.Start__c >= LAST_N_DAYS:3)' + 
                        'OR  (Active_Subscription__r.SBQQ__EndDate__c <= LAST_N_DAYS:3 OR Active_Contract_Idenfied__r.End__c <= LAST_N_DAYS:3)';

    }

    global database.querylocator start(database.batchableContext bc) {

        System.debug('QueryString' + QueryString);

        return database.getquerylocator(QueryString);
    }

    global void execute(database.batchablecontext bd, list<sobject> sc) {

        //Pass our values through to List
        list<Membership__c> memberships = (list<Membership__c>) sc;

        //Set the Util batch flag to True
        Util.isBatch = true;

        //Run our Update
        debugLog += Util.createLog(Database.update(memberships,false));

    }

    global void finish(database.batchableContext bc) {
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_NightlyMembershipStatusCheck', debugLog, Label.Salesforce_Admin_Email);	
    }
}