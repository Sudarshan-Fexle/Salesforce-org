//Batch class to update the data. 
global class Batch_TokenDataUpdate implements Database.Batchable<sObject> {
 	
    public String query = null;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if (query == null)
            query = 'Select Id, Tokens__c From Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        //List to hold the account.
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Site_Profile__c> siteProfilesToBeUpdated = new List<Site_Profile__c>();
        
        //Sitecore setting.
        Sitecore_Settings__c siteCoreSettings = Sitecore_Settings__c.getInstance();
        
        //Account
        for(Account acc : scope){
            accountsToBeUpdated.add(new Account(Id = acc.Id, Tokens__c = siteCoreSettings.Tokens_Default_Institution__c));
        }
        
        //Getting Site Profiles 
        for(Site_Profile__c sP : [Select Id, Tokens__c From Site_Profile__c Where Contact__r.AccountId IN: scope]) {
            
            //Site Profile To Be Updated.
            siteProfilesToBeUpdated.add(new Site_Profile__c(Id = sP.Id, Tokens__c = siteCoreSettings.Tokens_Default_Site_Profile__c));
        }
        
        //Bypassing all the triggers. 
        Util.BypassAllTriggers = true;
        update accountsToBeUpdated;
        update siteProfilesToBeUpdated;
        Util.ByPassAllTriggers = false;
    }
    
    global void finish(Database.BatchableContext BC){}

}