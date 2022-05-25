/**
 * Desription      :   	batch job runs nightly to update the Memberships of Subscriptions which have been updated in the previous 24 hours
 *                      Goal is to act as a catch all for records where Trigger fails to update the Earliest/Active/Latest Subscriptions
 * 
 * Created By      :   	Colin McGloin
 * 
 * Created Date    :   	09/04/2019
 * 
 * Revision Logs   :   	v1.0 - Created
 **/

global class Batch_NightlyMembershipSubUpdate implements database.batchable<sobject> {

    //String for Query
    global String debugLog;
    public string QueryString;
    public static List<String> applicableStatuses = new List<String> {'ATL', 'Honorary', 'Dropped', 'Committed', 'Committed-Amended'};

    global Batch_NightlyMembershipSubUpdate() {

        //Query for the records 
        if (QueryString == null){
            
            //updated by mahendra Swarnkar - 02/26/2020 - CR-20200114-13623 - moved the default query into the custom label - Starts from here
            if(String.isNotBlank(Label.Query_Batch_NightlyMembershipSubUpdate))
                QueryString = Label.Query_Batch_NightlyMembershipSubUpdate;
            else 
                QueryString = 'SELECT Id, SBQQ__Account__c, Program__c, SBQQ__Contract__c, Status__c, Parent_Program__c, SBQQ__Product__c '
                                + 'FROM SBQQ__Subscription__c WHERE Status__c IN :applicableStatuses AND LastModifiedDate = LAST_N_DAYS:1'
                                + 'ORDER BY LastModifiedDate DESC LIMIT 10000';
            
            //updated by mahendra Swarnkar - 02/26/2020 - CR-20200114-13623 - Ends here
        }
    }

    global database.querylocator start(database.batchableContext bc) {

        System.debug('QueryString' + QueryString);

        return database.getquerylocator(QueryString);
    }

    global void execute(database.batchablecontext bd, list<sobject> sc) {

        //Pass our values through to List
        list<SBQQ__Subscription__c> subs = (list<SBQQ__Subscription__c>) sc;

        //Set the Util batch flag to True
        Util.isBatch = true;

        //If we have Subscriptuon records to work with then pass them through to our method for updating the Earlest/Latest/Active Subscriptions
        if (subs.size() > 0){

            //Kick off our recalculate logic
            SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(subs, null);
        }
    }

    global void finish(Database.BatchableContext ctx){

        //User Instance
        List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];

        //Send an email with the results of the batch
        Util.sendBatchStatus(ctx.getJobId(), 'Batch_NightlyMembershipSubUpdate', debugLog , sfAdminUser[0].Email);

    }

}