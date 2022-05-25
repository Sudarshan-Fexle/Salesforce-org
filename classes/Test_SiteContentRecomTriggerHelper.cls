/*
 * Purpose			:	Test class for SiteContentRecommendationTriggerHelper
 * 
 * CreatedDate		:	21/10/2019
 * 
 * RevisionLog		: 	V_1.0 - Created - Dipesh Gupta
 * 
 * Code Coverage	: 	93%
 * */
@IsTest
private class Test_SiteContentRecomTriggerHelper {
	
    @testSetup static void testSetupData()
    {
        // Create Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test'));
        accounts.add(new Account(Name = 'Test2'));
        insert accounts;
        
        
        //create contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 't', LastName = 'test', Email = 'test@mail.com', Title = 'test', Phone = '123456789', Company_Email__c = 'test@mail.com', Bypass_Domain_Validation__c = true));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 't1', LastName = 'test2', Email = 'test2@mail.com', Title = 'test', Phone = '123456789', Company_Email__c = 'test2@mail.com', Bypass_Domain_Validation__c = true));
        insert contacts;
        
        // Create Site Profile
        List<Site_Profile__c> siteProfiles = new List<Site_Profile__c>();
        siteProfiles.add(new Site_Profile__c(Contact__c = contacts[0].Id, r_Institution__c = accounts[0].Id, Username__c = contacts[0].Company_Email__c, Password__c = null, Site_User__c = null, Bypass_Domain_Validation__c = true));
        siteProfiles.add(new Site_Profile__c(Contact__c = contacts[1].Id, r_Institution__c = accounts[1].Id, Username__c = contacts[1].Company_Email__c, Password__c = null, Site_User__c = null, Bypass_Domain_Validation__c = true));
        insert siteProfiles;
        
    }
    
    @IsTest static void testSiteContentRecomTriggerHelper()
    {
        test.startTest();
        List<Site_Profile__c> siteProfiles = [SELECT Id, Contact__c, r_Institution__c, UserName__c FROM Site_Profile__c];
        
        List<Site_Content_Recommendation__c> scr = new List<Site_Content_Recommendation__c>();
        scr.add(new Site_Content_Recommendation__c(Contact__c = siteProfiles[0].Contact__c, Site_Profile__c = siteProfiles[0].Id));
        insert scr;
        
        scr[0].Contact__c = siteProfiles[1].Contact__c;
        update scr;
        
        test.stopTest();
    }
}