/**
*  Description     :  Batch class to update TopParentProduct field on proposal line.
*
*  Created By      :  Mahendra Swarnkar
*
*  Created Date    :  09/17/2019
*
*/
global class Batch_TopParentProduct implements Database.Batchable<SObject>, Database.Stateful  {
    
    public string query = '';
    
    /*global Batch_TopParentProduct(String query) {
        this.query = query;
        
    }*/
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        
        //if(String.isBlank(query))
        	query = 'Select Id, SBQQ__Quote__c, SBQQ__RequiredBy__c, Top_Parent_Product__c, SBQQ__Product__c, SBQQ__Product__r.Parent_Product__c,SBQQ__RequiredBy__r.Top_Parent_Product__c From SBQQ__QuoteLine__c Where Top_Parent_Product__c = null';
        
        return Database.getQueryLocator(query);
    }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
		SBQQ_QuoteLineTriggerHelper.populateTopParentOnQuoteLines(scope);
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
    }
}