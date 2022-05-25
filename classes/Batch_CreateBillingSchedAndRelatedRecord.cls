global class Batch_CreateBillingSchedAndRelatedRecord implements Schedulable, Database.Batchable<sObject>, Database.Stateful  {
  
    // Schedule Job execute method
    global void execute(SchedulableContext ctx) {
        System.debug('@@@@ In Scheduler execute Method');
        
        // execute the batch
        Batch_CreateBillingSchedAndRelatedRecord batch = new Batch_CreateBillingSchedAndRelatedRecord();
        
        Database.executeBatch(batch, 1);
    }
    
    
    //Batch start
    global database.querylocator start(database.batchableContext bc) {
        System.debug('@@@@ In Batch Start Method');
        
        return database.getquerylocator('SELECT Id, Name,CreatedDate, Billing_Schedule_Automated_Status__c, Invoice_Contact__c, AccountId, Invoicing_Arrangement__c,'
                                         + '(SELECT Id, Name, SBQQ__Contract__c, Invoicing_Arrangement__c, SBQQ__Product__c, SBQQ__Product__r.Family FROM SBQQ__Subscriptions__r WHERE RecordType.Name = \'Program\') '
                                        + 'FROM Contract '
                                        + 'WHERE Billing_Schedule_Automated_Status__c = \'Awaiting Processing\'');
    }
    
    //Batch execute
    global void execute(database.batchablecontext bc, list<sobject> sc) {
        
        List<Contract> allContracts = (List<Contract>) sc;
        
        BillingScheduleUtilities.createBillingScheduleHeadersFromContract(allContracts);
    }
    
    //Batch finish
    global void finish(database.batchableContext bc) {
        
    }
}