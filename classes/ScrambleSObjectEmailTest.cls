/**
 * @description: Test class for Scramble SObject Email
 *
 *  Create By       :   Dipesh Gupta
 *
 *  Created Date    :   04/16/2019
 *
 *  Revision Logs   :   V_1.0 - Created.
 *			V_1.1 - Modified By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Modify duplicate check for contacts To 'Tech'

*
 **/
@isTest
private class ScrambleSObjectEmailTest {
	 
    /**
     * Setup a Lead, Contact, and Site Profile with emails that need to be scrambled
     **/
    @testSetup
    static void methodName() {
        
        //Create Lead data
        Lead lead1 = new Lead(LastName = 'Testing', Company = 'Testing', Address_Line_1__c = 'Testing 604', City__c = 'Dallas', 
                             State_Province__c = 'CA', Country__c = 'USA', Postal_Code__c = '12345', Email = 'lead2@example.com');
        Lead lead2 = lead1.clone();
        lead2.Email = 'lead2@example.com';
        List<Lead> leads = new List<Lead>{ Lead1, Lead2 };
        insert leads;
            
        //Create Contact data
        list<Contact> cons = new List<Contact>();
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Primary_State_Province__c = null;
        con1.Asst_Email__c = 'asst1@example.com';
        //con1.Advisory_com_Preferred_Email_Address__c = 'preferred1@example.com';
        cons.add(con1);
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.Primary_State_Province__c = null;
        con2.Asst_Email__c = 'asst2@example.com';
       // con2.Advisory_com_Preferred_Email_Address__c = 'preferred2@example.com';
        cons.add(con2);
        insert cons;
        
        Set<Id> acctIds = new Set<Id> { con1.AccountId, con2.AccountId };
        
        
        //activate the institution's Org Status
        List<Account> accts = [SELECT Id, EAB_com_Organization_Status__c FROM Account WHERE Id IN :acctIds];
        for (Account a : accts) a.EAB_com_Organization_Status__c = 'active';
        update accts;
        
        //create Site Profile data
        Site_Profile__c sp1 = new Site_Profile__c(Status__c = 'Active',
                                                  Username__c = con1.Email,
                                                  Password__c = 'test',
                                                  //Site_User__c = site_User.Id,
                                                  Verify__c = '2',
                                                  Contact__c = con1.Id,
                                                  Bypass_Domain_Validation__c = true,
                                                  Type__c = 'EAB.com');
        //create Site Profile data
        Site_Profile__c sp2 = new Site_Profile__c(Status__c = 'Active',
                                                  Username__c = con2.Email,
                                                  Password__c = 'test',
                                                  //Site_User__c = site_User.Id,
                                                  Verify__c = '2',
                                                  Contact__c = con2.Id,
                                                  Bypass_Domain_Validation__c = true,
                                                  Type__c = 'EAB.com');
        List<Site_Profile__c> siteProfiles = new List<Site_Profile__c>();
        siteProfiles.add(sp1);
        siteProfiles.add(sp2);
        insert siteProfiles;
    }
    
    //Test the Lead scramble batch
    static testMethod void testLeadScramble() {
        
        test.startTest();
        
        //scramble lead emails
        database.executeBatch(new ScrambleSObjectEmail(Lead.SObjectType, Lead.Email, null, '@', '@junkEAB',null, false));
        
        test.stopTest();
        
        List<Lead> leads = [SELECT Id, Email FROM Lead WHERE Email LIKE '%@junkEAB%'];
        system.assertEquals(2, leads.size());
    }
    
    //Test the Contact / Site Profile scramble batch
    static testMethod void testContactSiteProfileScramble() {
        
        //define a few extra email fields to scramble on contact
        Set<Schema.SObjectField> additionalContactEmailFields = new Set<Schema.SObjectField>();
        additionalContactEmailFields.add(Contact.Asst_Email__c);
       // additionalContactEmailFields.add(Contact.Advisory_com_Preferred_Email_Address__c);
        
        test.startTest();
        
        //scramble contact emails
        database.executeBatch(new ScrambleSObjectEmail(Contact.SObjectType, Contact.Email, additionalContactEmailFields, '@', '@junkEAB',null, false));
        
        //scramble site profile emails
        database.executeBatch(new ScrambleSObjectEmail(Site_Profile__c.SObjectType, Site_Profile__c.Username__c, null, '@', '@junkEAB',null, false));
        
        test.stopTest();
        
        //verify contacts were scrambled
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email LIKE '%@junkEAB%'];
        system.assertEquals(2, contacts.size());
        
        //verify contacts were scrambled
        List<Site_Profile__c> siteProfiles = [SELECT Id, Username__c FROM Site_Profile__c WHERE Username__c LIKE '%@junkEAB%'];
        system.assertEquals(2, siteProfiles.size());
    }
    
    //Test the Contact / Site Profile scramble batch
    static testMethod void testContactSiteProfileScramble_OutlookEmailBypass() {
        
        List<Contact> cons = [Select Id, Email, Company_Email__c From Contact LIMIT 1];
        List<Site_Profile__c> siteProfiles = [Select Id, Username__c From Site_Profile__c Where Contact__c =: cons[0].Id];
        
        Util.bypassAllTriggers = true;
        
        //Updating the contact email and site profile UsetName to outlook.com
        cons[0].Email = 'test-bhan@outlook.com';
        cons[0].Company_Email__c = 'test-bhan@outlook.com';
        update cons;
        
        //Updating site Profile for the same.
        siteProfiles[0].Username__c = 'test-bhan@outlook.com';
        update siteProfiles[0];
        
        Util.bypassAllTriggers = false;
        
        //define a few extra email fields to scramble on contact
        Set<Schema.SObjectField> additionalContactEmailFields = new Set<Schema.SObjectField>();
        additionalContactEmailFields.add(Contact.Asst_Email__c);
        additionalContactEmailFields.add(Contact.Company_Email__c);
        
        
        test.startTest();
        
        //scramble contact emails
        database.executeBatch(new ScrambleSObjectEmail(Contact.SObjectType, Contact.Email, additionalContactEmailFields, '@', '@junkEAB',null, false));
        
        //scramble site profile emails
        database.executeBatch(new ScrambleSObjectEmail(Site_Profile__c.SObjectType, Site_Profile__c.Username__c, null, '@', '@junkEAB',null, false));
        
        test.stopTest();
        
        //verify contacts were scrambled
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email LIKE '%@junkEAB%'];
        system.assertEquals(1, contacts.size());
        
        //verify contacts were scrambled
        List<Site_Profile__c> siteProfiles1 = [SELECT Id, Username__c FROM Site_Profile__c WHERE Username__c LIKE '%@junkEAB%'];
        system.assertEquals(1, siteProfiles1.size());
    }
    
    //Created By - Neha Sharma - 02/03/2021 - CR-20200625-14228 - Modify duplicate check for contacts To 'Tech'
    //Test the Contact scramble batch where Entity is HC
    static testMethod void testEntityHCTypeContactScramble() {

        Util.bypassAllTriggers = true;
        
        Account account = TestUtilities.CreateNewAccount(true);
        
        //create contact
        //Entity is HC
        Contact con1 = TestUtilities.CreateNewContact(account, false);
        con1.Entity__c = 'HC';
        con1.Asst_Email__c = 'asst1@example.com';
        con1.Contact_Status__c = 'Active';
        
        //Entity is not HC
        Contact con2 = TestUtilities.CreateNewContact(account, false);
        con2.Entity__c = 'All';
        con2.Asst_Email__c = 'asst2@example.com';
        con2.Contact_Status__c = 'Active';
        
        List<Contact> contactsToScramble = new List<Contact>{con1,con2};
        INSERT contactsToScramble;
        
        contactsToScramble[0].Entity__c = 'HC';
        Update contactsToScramble[0];
        Util.bypassAllTriggers = false;
        
        //Assert before scramble/deactivate records
        System.assertEquals(false, contactsToScramble[0].Email.contains('@junkeab'));
        System.assertEquals(false, contactsToScramble[1].Email.contains('@junkeab'));
        
        test.startTest();
        Set<Schema.SObjectField> additionalContactEmailFields = new Set<Schema.SObjectField>();
        additionalContactEmailFields.add(Contact.Company_Email__c);
        
        
        String str = 'SELECT Id,Contact_Status__c, Email,company_Email__c,Primary_State_Province__c FROM Contact WHERE Entity__c != null AND Entity__c =\'HC\'';
        
        //scramble contact emails where entity is HC
        database.executeBatch(new ScrambleSObjectEmail(Contact.SObjectType, Contact.Email, additionalContactEmailFields, '@', '@junkEAB',str, true));
                
        test.stopTest();
        
        //contacts id
        List<Id> contactIds = new List<Id>{contactsToScramble[0].Id, contactsToScramble[1].Id};
            
        //verify contacts were scrambled
        List<Contact> contacts = [SELECT Id, Email,Contact_Status__c,Asst_Email__c,Entity__c FROM Contact 
                                  WHERE ID IN :contactIds AND Entity__c = 'HC'];
        
        //Assert before scramble/deactivate records
        System.assertEquals(true, contacts[0].Email.contains('@junkeab'));
        System.assertEquals(false, contacts[0].Asst_Email__c.contains('@junkeab'));
        
        //verify contacts were scrambled
        List<Contact> contactList = [SELECT Id, Email,Contact_Status__c,Asst_Email__c,Entity__c FROM Contact 
                                  WHERE ID IN :contactIds AND Entity__c != 'HC'];
        
        
        System.assertEquals('Inactive – Other', contacts[0].Contact_Status__c);
        System.assertEquals('Active', contactList[0].Contact_Status__c);
        
    }
}