/**
*  Description     :  Batch class to update custom 'twin' fields.  Use this in place of the standard CPQ twinning process on Subscription / QuoteLines
*
*  Created By      :  Victor Hanson
*
*  Created Date    :  03/18/2019
*
*/
global class Batch_TwinFields implements Database.Batchable<SObject>, Database.Stateful, Schedulable  {
    
    public string query = null;
    public Set<Id> recordIds;
    
    global Batch_TwinFields(String query, Set<Id> recordIds) {
        system.debug('@@@query:' + query);
        this.query = query;
        this.recordIds = recordIds;
    }
    
    //Start Method
    global Database.Querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query + ' WHERE Id IN :recordIds');
    }
    
    //Schedule method
    global void execute(SchedulableContext SC) {
        database.executeBatch(new Batch_TwinFields(query, recordIds), 200);
   }
    
    //Execute Method
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        //this can either be QuoteLines or Subscriptions
        //get the source object and target object types
        String sObjectType = string.valueOf(scope.getSObjectType());
        
        if (sObjectType.equalsIgnoreCase('SBQQ__Subscription__c')) {
            
            //instantiate subscriptions
            List<SBQQ__Subscription__c> newSubscriptions = (List<SBQQ__Subscription__c>) scope;
            
            //get all quoteline ids
            Set<Id> qlIds = new Set<Id>();
            for (SBQQ__Subscription__c sub : newSubscriptions) {
                if (sub.SBQQ__QuoteLine__c != null) qlIds.add(sub.SBQQ__QuoteLine__c);
            }
            
            if (qlIds.size() > 0) {
                //build query
                String qryString = 'SELECT Id, ' + String.join(New List<String>(FieldMappingHelper.getFields('QuoteLine_to_Subscription')),
                                                               ',')
                    + ' FROM SBQQ__QuoteLine__c WHERE Id IN :qlIds';
                Map<Id, SBQQ__QuoteLine__c> qlMap = new Map<Id, SBQQ__QuoteLine__c>((List<SBQQ__QuoteLine__c>)database.query(qryString));
                
                FieldMappingHelper.mapFields(newSubscriptions, qlMap);
                
                //Util.bypassAllTriggers = true;
                update newSubscriptions;
            }
        }
        
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) {
        Util.unscheduleJobsWithoutNextFireDate();
    }
}