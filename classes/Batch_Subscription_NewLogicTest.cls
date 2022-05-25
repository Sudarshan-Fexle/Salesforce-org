//This Batch is just to send the expacted files as a format of CSV. Mostly Used in the CPQ - Contact Subhash Garhwal before changing this. 
global class Batch_Subscription_NewLogicTest implements Database.Batchable<sObject>, Database.Stateful {
    
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = \'Program\'  ';
            
       	return Database.getQueryLocator(query);   
    }
	
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> subs ){
		
    	Update subs;
    }
    
    global void finish(Database.BatchableContext BC){
    }
       
}