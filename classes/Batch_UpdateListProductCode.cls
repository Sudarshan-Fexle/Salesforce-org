global class Batch_UpdateListProductCode implements database.Batchable<sobject> {
	
    global database.querylocator start(database.batchableContext bc) {
        
        return database.getquerylocator('Select Id, RecordTypeId, Product_Code__c, SBQQ__Contract__c From SBQQ__Subscription__c Where RecordType.DeveloperName = \'Program\'');
    }
    
    global void execute(database.batchablecontext bd, list<sobject> sc) {
        
        SBQQ_SubscriptionTriggerHelper.populateProductCode(sc, null);
    }
    
    global void finish(database.batchableContext bc) {}

}