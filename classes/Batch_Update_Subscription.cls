/** CR-20180323-12122 - Subhash Garhwal - Used to update the Historical Data**/
global class Batch_Update_Subscription implements Database.Batchable<sObject>, Database.Stateful {   
    
        
    global Database.QueryLocator start(Database.BatchableContext BC){  

     	return Database.getQueryLocator([Select Id, Account_Management_Group__c, Account_Management_Reporting_Business__c, Account_Management_Reporting_Vertical__c,	
     									Account_Management_Reporting_Group__c, New_Business_Marketer__c, New_Business_Group__c,
										Program__r.Account_Management_Group__c, Program__r.Account_Management_Reporting_Business__c, Program__r.Account_Management_Reporting_Vertical__c,
										Program__r.Account_Management_Reporting_Group__c, Program__r.New_Business_Marketer__c, Program__r.New_Business_Group__c
										From SBQQ__Subscription__c Where Program__c != null AND ( Program__r.Account_Management_Group__c != null
										 OR Program__r.Account_Management_Reporting_Business__c != null
										 OR Program__r.Account_Management_Reporting_Vertical__c != null 
										 OR Program__r.Account_Management_Reporting_Group__c != null
										 OR Program__r.New_Business_Marketer__c != null
										 OR Program__r.New_Business_Group__c != null)]);   
    }
	
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> subscriptions){
		
		List<SBQQ__Subscription__c> subsToBeUpdated = new List<SBQQ__Subscription__c>();
	
		for(SBQQ__Subscription__c sub : subscriptions) {
	
			subsToBeUpdated.add(new SBQQ__Subscription__c(Id = sub.Id, Account_Management_Group__c = sub.Program__r.Account_Management_Group__c,
								Account_Management_Reporting_Business__c = sub.Program__r.Account_Management_Reporting_Business__c,
								Account_Management_Reporting_Vertical__c = sub.Program__r.Account_Management_Reporting_Vertical__c,
								Account_Management_Reporting_Group__c = sub.Program__r.Account_Management_Reporting_Group__c,
								New_Business_Marketer__c = sub.Program__r.New_Business_Marketer__c,
								New_Business_Group__c = sub.Program__r.New_Business_Group__c));
		
		}
		if(subsToBeUpdated.size() > 0) {
			
			Util.byPassAllTriggers = true;
			update subsToBeUpdated;
			Util.byPassAllTriggers = false;
		}
    }
    
    global void finish(Database.BatchableContext BC){
        
        
    }
}