/**
 *  Description     :   Batch Class is used to update token details on Account and Site Profile . 
 * 						This will run on the 1 Jan every year and reset the Token field values on Account/Site profile. 
 *
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   06/26/2019
 *
 *  Revision Logs   :   V_1.0 - Created - Eab.com Rebuild - CR-20190510-13101
 *                      
 **/
global class Batch_ResetSiteTokenOnSPAndInstitution implements Database.Batchable<sObject>, Database.Stateful  {
    
    //Debug Logs
    global String debugLog;
    public string QueryString;
    
    //Start method to query the Accounts. 
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if (QueryString == null) 
            QueryString = 'Select Id,Tokens__c From Account where Entity__c != \'HC\'';
        
        return Database.getQueryLocator(QueryString);
    }
    
    //Execute
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        //Set of Site Profile's Id  
       	Set<Id> setOfSiteProfileId = new Set<Id>();
        
        //List to hold the updated value of account.
       	List<Account> accountsToBeUpdated = new List<Account>(); 
        
        //Site Profile to be updated. 
        List<Site_Profile__c> siteProfileToBeUpdated = new List<Site_Profile__c>();
        
        //Loop on the account to get the token details 
        for(Account acc : scope){
            //If the Account token's value is less then 25 (default value) then reset the value to the 25 again.
            if(acc.Tokens__c < 25){
            	accountsToBeUpdated.add(new Account(Id = acc.Id, Tokens__c = 25));
            }
        }
        
        //Query related active contacts that has active site profile
        for(Contact con : [Select EAB_com_Site_Profile__c, EAB_com_Site_Profile__r.Tokens__c From Contact 
                           WHERE AccountId IN: scope AND Contact_Status__c = 'Active' 
                           AND EAB_com_Site_Profile__c != null
                           AND EAB_com_Site_Profile__r.Status__c ='Active']){
            
            //Adding Id in set
            setOfSiteProfileId.add(con.EAB_com_Site_Profile__c);
            
            //Check for the site profiles tokens
            if(con.EAB_com_Site_Profile__r.Tokens__c < 5)
                //Adding the site profile to the List. 
                siteProfileToBeUpdated.add(new Site_Profile__c(Id = con.EAB_com_Site_Profile__c, Tokens__c = 0));
        }
        
        //Calling 'updateTokenDetailsOnAccount' to update Site Profile and Account
        //This method will update the Tokens used YTD field on the Site profile based on the current year. 
        SiteTokenTriggerHelper.updateTokenDetailsOnAccount(setOfSiteProfileId);
        
        //Bypassing all the triggers. 
        Util.BypassAllTriggers = true;
        
        //Check for the site Profile list size.
        if(siteProfileToBeUpdated.size() > 0)
        	debugLog += Util.createLog(Database.update(siteProfileToBeUpdated , false));
        
        //Check for the Account List size.
        if(accountsToBeUpdated.size() > 0 )
        	debugLog += Util.createLog(Database.update(accountsToBeUpdated , false));
        
        Util.ByPassAllTriggers = false;
    }
    
    global void finish(Database.BatchableContext BC){
        
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLog != '') 
            Util.sendBatchStatus(bc.getJobId(), 'Batch_TokenReset', debugLog, Label.Salesforce_Admin_Email);	
    }  
}