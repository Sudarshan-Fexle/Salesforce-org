/**
 *	Purpose			:	When a Membership becomes Inactive and there are no other active Memberships at the Institution,
 *                      this batch job resets Site Profile Tokens = 0 and expires all Site Tokens that are associated with the Site Profiles on the Institution(s).
 *
 *	Rivision Log	:	V_1.1 - Created - 05/30/2019 - Victor Hanson
 *
 **/
global with sharing class Batch_TokenReset implements database.Batchable<sobject>, Database.Stateful {
    
    global String debugLog;
	public string QueryString;
    global Set<Id> acctIds;

    global Batch_TokenReset() {
        //reset debug log
        debugLog = '';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
		
        if (QueryString == null) QueryString = 'Select Id, Tokens__c, Tokens_Used_YTD__c From Site_Profile__c WHERE Contact__r.AccountId IN :acctIds';
       	return Database.getQueryLocator(QueryString);
    }

    global void execute(Database.BatchableContext BC, List<Site_Profile__c> scope){
        
       	//List to hold the Site Profiles & Site Tokens to be updated
        List<Site_Profile__c> sProfilesToBeUpdated = new List<Site_Profile__c>();
       	List<Site_Token__c> sTokensToBeUpdated = new List<Site_Token__c>();
        
        //Site Profiles
        for(Site_Profile__c sP : scope){
            sProfilesToBeUpdated.add(new Site_Profile__c(Id = sP.Id, Tokens__c = 0));
        }
        
        //Site Tokens
        for(Site_Token__c sT : [Select Id, Expiration_Date__c FROM Site_Token__c WHERE Site_Profile__c IN: scope AND Status__c = 'Active']) {
        	
            //Site Tokens To Be updated with expiration date of yesterday
            sTokensToBeUpdated.add(new Site_Token__c(Id = sT.Id, Expiration_Date__c = date.today().addDays(-1)));
        }
        
        //Bypassing all the triggers & perform updates
        Util.BypassAllTriggers = true;

        if (sProfilesToBeUpdated.size() > 0) {
            debugLog += Util.createLog(Database.update(sProfilesToBeUpdated , false));
        }

        if (sTokensToBeUpdated.size() > 0) {
            debugLog += Util.createLog(Database.update(sTokensToBeUpdated , false));
        }

        Util.ByPassAllTriggers = false;
 	}
    
    global void finish(Database.BatchableContext BC){
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_TokenReset', debugLog, Label.Salesforce_Admin_Email);	
    }
    
}