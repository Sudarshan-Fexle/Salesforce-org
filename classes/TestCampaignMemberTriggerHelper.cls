/**
 *   Description     :   test class for TestCampaignMemberTriggerHelper
 * 
 *   Revision Logs   :   V1.1 : Simplyforce-Bhavi[12/13/2011] - Added method to test the CR-20111012-161
 *			 V1.2 : Modified By - Neha Sharma - 04/12/2021 - CR-20210324-15022 - More robust unit tests for MRS 2.0
 *			 V1.3 : Modified By - Saurabh Kumar - CR-20201116-14696 - 03/31/2021 - Added a method testCreateAndPopulateRegistration
 *			 V1.4 : Modified By - Chirag soni - CR-20210510-15128 
 *			 V1.5 : Modified By - Abhishek Mishra - CR-20210517-15149 - 06/09/2021 - Coverage Increase
 *			 V1.6 : Modified By - Chirag Soni - 09/03/2021 - CR-20210902-15405 - Updated the method testCreateAndPopulateRegistration() to test Waitlist status When EAB Event Status is not equal to waitlist
 * 
 **/
@isTest
private class TestCampaignMemberTriggerHelper {
    
    
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    
    @testSetup
    static void setup(){
        
        Util.BypassAllTriggers = true;
        
        //Create the new account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create two new contact record
        List<Contact> contacts = new List<Contact>();
        Contact newContact = testUtilities.CreateNewContact(account, false);
        contacts.add(newContact);
        
        newContact = testUtilities.CreateNewContact(account, false);
        contacts.add(newContact);
        
        newContact = testUtilities.CreateNewContact(account, false);
        contacts.add(newContact);
        
        newContact = testUtilities.CreateNewContact(account, false);
        contacts.add(newContact);
        
        insert contacts;
        
        // Create campaign Record of Marketo record type
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketo').getRecordTypeId();
        
        Campaign marketoCampaign = new Campaign(Name = 'Marketo Campaign', 
                                                Status = 'Planned', 
                                                Type = 'Event',
                                                Subtype__c = 'Conference',
                                                RecordTypeId = recordTypeId);
        insert marketoCampaign;
        
        Util.BypassAllTriggers = false;
    }
    
    //Modified By - Abhishek Mishra - CR-20210517-15149 - 06/09/2021 - Coverage Increase
    static testmethod void PopulateCampaignMemberLookupsTest() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        list<User> users = new list<User>();
        try {
            for (Integer i = 0; i <= 1; i++) {
                String digit = String.valueOf(i);
                users.add(new User(
                    alias = 'user' + digit, 
                    email='standarduser@advisory.com', 
                    emailencodingkey='UTF-8', 
                    lastname='Testing ' + digit, 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', 
                    profileid = prof.id, 
                    timezonesidkey='America/Los_Angeles', 
                    username='testuserxyz' + digit + '@advisory.com',
                    isActive = true));
            } 
            insert users; 
        } catch (Exception e) { // in case no more users can be added
            users = [select Id, Username from User where isActive = true limit 2]; 
        }
        
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            OwnerId = users[0].id);
        insert prog;
        
        Account a = new Account(Name = 'testacc');
        insert a;
        
        RecordType rtc = [select Id from RecordType where Name = 'External' and SobjectType = 'Contact' and IsActive = true];
        
        Contact con = new Contact(Firstname = 'Test', Lastname = 'Person', RecordTypeId = rtc.Id, AccountId = a.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //Modify By  - Abhishek Mishra - CR-20210517-15149 - 06/08/2021 - added Primary_Program__c in the campaign - Start Here
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'Test Campaign 1',Primary_Program__c = prog.Id,
                                   RecordTypeId = Schema.SObjectType.Campaign.RecordTypeInfosByName.get('Marketo').RecordTypeId,
                                   CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Marketo Campaign Member').RecordTypeId));
        
        campaigns.add(new Campaign(Name = 'Test Campaign 2'));
        insert campaigns;
        
        List<CampaignMember> cm = new List<CampaignMember>();
        cm.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = con.Id, 
                                  Marketer_Username__c = users[0].Username,  
                                  MA_Username__c = users[1].Username,  
                                  Program_Acronym__c = 'TEST'));
        cm.add(new CampaignMember(CampaignId = campaigns[1].Id, ContactId = con.Id, 
                                  Marketer_Username__c = users[0].Username,  
                                  MA_Username__c = users[1].Username,  
                                  Program_Acronym__c = 'TEST'));
        
        insert cm;
        
        List<CampaignMember> cmret = [select Marketer_Assignment__c, MA_Assignment__c, Primary_Program__c from CampaignMember Order By Campaign.Name ASC];
        
        system.assertEquals(users[0].Id, cmret[0].Marketer_Assignment__c);
        system.assertEquals(users[1].Id, cmret[0].MA_Assignment__c);
        system.assertEquals(prog.Id, cmret[0].Primary_Program__c);
        
        system.assertEquals(users[0].Id, cmret[1].Marketer_Assignment__c);
        system.assertEquals(users[1].Id, cmret[1].MA_Assignment__c);
        system.assertEquals(prog.Id, cmret[1].Primary_Program__c);
        //Modify By  - Abhishek Mishra - CR-20210517-15149 - 06/08/2021 - added Primary_Program__c in the campaign - Till Here
        
        //Stop Test here
        Test.stopTest();
    }
    
    static testmethod void PopulateInsensitiveCampaignMemberLookupsTest() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        list<User> users = new list<User>();
        try {
            for (Integer i = 0; i <= 1; i++) {
                String digit = String.valueOf(i);
                users.add(new User(
                    alias = 'user' + digit, 
                    email='standarduser@advisory.com', 
                    emailencodingkey='UTF-8', 
                    lastname='Testing ' + digit, 
                    languagelocalekey='en_US', 
                    localesidkey='en_US', 
                    profileid = prof.id, 
                    timezonesidkey='America/Los_Angeles', 
                    username='testuserxyz' + digit + '@advisory.com'));
            } 
            insert users; 
        } catch (Exception e) { // in case no more users can be added
            users = [select Id, Username from User where isActive = true limit 2]; 
        }
        
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            OwnerId = users[0].id);
        insert prog;
        
        Account a = new Account(Name = 'testacc');
        insert a;
        
        RecordType rtc = [select Id from RecordType where Name = 'External' and SobjectType = 'Contact' and IsActive = true];
        
        Contact con = new Contact(Firstname = 'Test', Lastname = 'Person', RecordTypeId = rtc.Id, AccountId = a.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con;
        
        //Test will start from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        Campaign c = new Campaign(Name = 'Test Campaign');
        insert c;
        
        CampaignMember cm = new CampaignMember(CampaignId = c.Id, ContactId = con.Id, 
                                               Marketer_Username__c = users[0].Username.toUpperCase(),  
                                               MA_Username__c = users[1].Username.toUpperCase(),  
                                               Program_Acronym__c = 'TEST', Status = 'Opened');
        insert cm;
        
        CampaignMember cmret = [select Marketer_Assignment__c, MA_Assignment__c, Primary_Program__c from CampaignMember where Id = :cm.Id];
        system.assertEquals(users[0].Id, cmret.Marketer_Assignment__c);
        system.assertEquals(users[1].Id, cmret.MA_Assignment__c);
        system.assertEquals(prog.Id, cmret.Primary_Program__c);
        
        cm.Status = 'Requested Demo';
        update cm;
        
        //Test will stop here
        Test.stopTest();
    }
    
    //Added By - Neha Sharma - 04/12/2021 - More robust unit tests for MRS 2.0
    static testMethod void testPopulateRegistration() { 
        
        // Modified By - Chirag soni - CR-20210510-15128 - initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        //create account 
        Account acc = testUtilities.CreateNewAccount(true);
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(acc, false));
        contacts.add(testUtilities.CreateNewContact(acc, false));
        contacts.add(testUtilities.CreateNewContact(acc, false));
        
        Insert contacts;
        
        Util.BypassAllTriggers = false;
        
        //create campaings
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId,
                                   RecordTypeId = Schema.SObjectType.Campaign.RecordTypeInfosByName.get('Event Invite List').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),IsActive = true));
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId,
                                   RecordTypeId = Schema.SObjectType.Campaign.RecordTypeInfosByName.get('Mailing Campaign').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(2),IsActive = true));
        insert campaigns;
        
        //create an event
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Meeting_GUID__c = '000-000-001';
        eabEvent.Event_Type__c = 'Research Working Sessions';
        eabEvent.Public_Name__c = 'Test';
        eabEvent.Short_Name__c = 'Test';
        eabEvent.Status__c = 'Open - Registration';
        eabEvent.Begins__c = System.today();
        eabEvent.Ends__c = System.today().addDays(3);
        eabEvent.Invite_List__c = campaigns[0].Id;
        insert eabEvent;
        
        //create registration
        Registration__c reg1 = Test_SiteMeetingController.CreateRegistration(eabEvent.Id, contacts[0].Id, false);
        Registration__c reg2 = Test_SiteMeetingController.CreateRegistration(eabEvent.Id, contacts[1].Id, false); 
        
        Insert new List<Registration__c>{reg1, reg2};
            
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        CampaignMember cm1 = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[0].Id, Status = 'Invited');
        CampaignMember cm2 = new CampaignMember(CampaignId = campaigns[1].Id, ContactId = contacts[0].Id, Status = 'Registered');
        CampaignMember cm3 = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[1].Id, Status = 'Registered');
        CampaignMember cm4 = new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[2].Id, Status = 'Invited');
        
        List<CampaignMember> campMembers = new List<CampaignMember>{cm1, cm2,cm3,cm4};
            insert campMembers;
        
        campMembers = [select Registration__c from CampaignMember where Id IN :campMembers];
        system.assertEquals(reg1.Id, campMembers[0].Registration__c);
        system.assertEquals(null, campMembers[1].Registration__c);
        system.assertEquals(reg2.Id, campMembers[2].Registration__c);
        system.assertEquals(null, campMembers[3].Registration__c);
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Added By - Abhishek Mishra - CR-20210517-15149 - 06/07/2021 - Code Coverage Increase
    static testMethod void testsendMailToProductOwner(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile prof = [select Id from Profile where Name = 'System Administrator'];
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        list<User> users = new list<User>();
        
        for (Integer i = 0; i <= 2; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prof.id, 
                timezonesidkey='America/Los_Angeles', 
                username='testuserxyz' + digit + '@advisory.com'));
        } 
        insert users; 
        
        //Setting Manager Id
        users[0].ManagerId = users[2].Id;
        users[1].ManagerId = users[2].Id;
        update users;
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true,
            OwnerId = users[0].id);
        insert prog;
        
        //create account 
        Account acc = testUtilities.CreateNewAccount(true);
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(acc, false));
        contacts.add(testUtilities.CreateNewContact(acc, false));
        contacts.add(testUtilities.CreateNewContact(acc, false));
        
        insert contacts;
        
        List<Product_Lead__c> productLeadList = new List<Product_Lead__c>();
        //Create a test Contact related Product Lead record
        productLeadList.add(new product_lead__c (Name = 'Test 1',Contact__c = contacts[0].Id,
                                                 Program__c = prog.Id,OwnerId = users[0].Id,
                                                 Stage__c = 'Inquiry', Action__c = 'Accept - Promote to TGL'));
        
        productLeadList.add(new product_lead__c (Name = 'Test 2',Contact__c = contacts[1].Id,
                                                 Program__c = prog.Id,OwnerId = users[1].Id,
                                                 Stage__c = 'Inquiry', Action__c = 'Accept - Promote to TGL'));
        
        insert productLeadList;
        
        //ProductLead Records
        productLeadList = [Select Name, Stage__c from Product_Lead__c ORDER BY Name ASC];
        productLeadList[0].Stage__c = 'AQL';
        productLeadList[1].Stage__c = 'AQL';
        update productLeadList;
        
        //Fetch Product lead List records
        productLeadList = [Select Name, Stage__c from Product_Lead__c ORDER BY Name ASC];
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        //create campaings
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true));
        
        campaigns.add(new Campaign(Name = 'Test Campaign 2', 
                                   CampaignMemberRecordTypeId = mailingCampaignMemberType,
                                   StartDate = System.today(), EndDate = System.today().addDays(2),
                                   IsActive = true));
        
        campaigns.add(new Campaign(Name = 'Test Campaign 3', 
                                   CampaignMemberRecordTypeId = mailingCampaignMemberType,
                                   StartDate = System.today(), EndDate = System.today().addDays(4),
                                   IsActive = true));
        
        campaigns.add(new Campaign(Name = 'Test Campaign 4',
                                   CampaignMemberRecordTypeId = mailingCampaignMemberType,
                                   StartDate = System.today(), EndDate = System.today().addDays(3),
                                   IsActive = true));
        //Insert campaign records
        insert campaigns;
        
        Util.BypassAllTriggers = false;
        
        //Campaign Member status 
        List<CampaignMemberStatus> campMemberstatus = new List<CampaignMemberStatus>();
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[0].Id,Label = 'Requested Follow Up'));
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[0].Id,Label = 'Requested Demo'));
        
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[1].Id,Label = 'Requested Follow Up'));
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[1].Id,Label = 'Requested Demo'));
        
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[2].Id,Label = 'Requested Follow Up'));
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[2].Id,Label = 'Requested Demo'));
        
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[3].Id,Label = 'Requested Follow Up'));
        campMemberstatus.add(new CampaignMemberStatus(CampaignId = campaigns[3].Id,Label = 'Requested Demo'));
        //insert campMemberstatus
        insert campMemberstatus;
        
        //Start Test from here
        Test.startTest();
        
        //list of campMembers
        List<CampaignMember> campMembers = new List<CampaignMember>();
        campMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[0].Id,
                                           Status = 'Requested Follow Up',
                                           Product_lead__c = productLeadList[0].Id));
        
        campMembers.add(new CampaignMember(CampaignId = campaigns[1].Id, ContactId = contacts[0].Id,
                                           Status = 'Requested Follow Up',
                                           Product_lead__c = productLeadList[0].Id));
        
        campMembers.add(new CampaignMember(CampaignId = campaigns[2].Id, ContactId = contacts[1].Id, 
                                           Status = 'Requested Demo',Product_lead__c = productLeadList[1].Id));
        
        campMembers.add(new CampaignMember(CampaignId = campaigns[3].Id, ContactId = contacts[2].Id,
                                           Status = 'Requested Demo',
                                           Product_lead__c = productLeadList[1].Id));
        //insert campMembers
        insert campMembers;
        
        //Fetch CampMembers Records
        campMembers = [select status,Request_Demo_Mail_Date__c from CampaignMember ORDER BY Campaign.Name ASC];
        
        //Asserts
        system.assertEquals(system.Today(),campMembers[0].Request_Demo_Mail_Date__c);
        system.assertEquals(system.Today(),campMembers[1].Request_Demo_Mail_Date__c);
        system.assertEquals(system.Today(),campMembers[2].Request_Demo_Mail_Date__c);
        system.assertEquals(system.Today(),campMembers[3].Request_Demo_Mail_Date__c);
        
        //udpate campaign Records
        campMembers = [select status from CampaignMember Order By Campaign.Name ASC];
        campMembers[0].status = 'Requested Demo';
        campMembers[1].status = 'Responded';
        campMembers[2].status = 'Requested Follow Up';
        campMembers[3].status = 'Sent';
        //update campaign members
        update campMembers;
        
        system.assertEquals(2,Limits.getEmailInvocations());
        
        //Fetch CampMembers Records
        campMembers = [select status,Request_Demo_Mail_Date__c from CampaignMember ORDER BY Campaign.Name ASC];
        
        system.assertEquals(system.Today(),campMembers[0].Request_Demo_Mail_Date__c);
        system.assertEquals(null,campMembers[1].Request_Demo_Mail_Date__c);
        system.assertEquals(system.Today(),campMembers[2].Request_Demo_Mail_Date__c);
        system.assertEquals(null,campMembers[3].Request_Demo_Mail_Date__c);
        
        //Stop Test here
        Test.stopTest(); 
        
    }
    
    //Added By -  Abhishek Mishra  - CR-20210517-15149 - 06/08/2021 - Coverage Increase
    static testMethod void testupdateUndeliverableMailings(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        //create account 
        Account acc = testUtilities.CreateNewAccount(true);
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(LastName='Test 1', Email='Test1@test.com', AccountId = acc.Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(LastName='Test 2', Email='Test2@test.com', AccountId = acc.Id, Title = 'Test', Phone = '614-555-8856'));
        contacts.add(new Contact(LastName='Test 3', Email='Test3@test.com', AccountId = acc.Id, Title = 'Test', Phone = '614-555-8857'));
        contacts.add(new Contact(LastName='Test 4', Email='Test4@test.com', AccountId = acc.Id, Title = 'Test', Phone = '614-555-8857'));
        
        insert contacts;
        
        //create campaings
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),IsActive = true));
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(2),IsActive = true));
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(4),IsActive = true));
        campaigns.add(new Campaign(Name = 'Test Campaign'+Crypto.getRandomInteger(), CampaignMemberRecordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId,
                                   StartDate = System.today(), EndDate = System.today().addDays(3),IsActive = true));
        insert campaigns;
        Util.BypassAllTriggers = false;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        List<CampaignMember> campMembers = new List<CampaignMember>();
        
        campMembers.add(new CampaignMember(CampaignId = campaigns[0].Id,ContactId = contacts[0].Id, Status = 'Registered',Undeliverable__c = true));
        campMembers.add(new CampaignMember(CampaignId = campaigns[1].Id,ContactId = contacts[1].Id, Status = 'Invited',Undeliverable__c = true));
        campMembers.add(new CampaignMember(CampaignId = campaigns[2].Id,ContactId = contacts[2].Id, Status = 'Registered',Undeliverable__c = true));
        campMembers.add(new CampaignMember(CampaignId = campaigns[3].Id,ContactId = contacts[3].Id, Status = 'Invited',Undeliverable__c = true));
        insert campMembers;
        
        contacts = [SELECT Id, Num_Undeliverable_Mailings__c FROM Contact Order By LastName ASC];
        system.assertEquals(1, contacts[0].Num_Undeliverable_Mailings__c);
        system.assertEquals(1, contacts[1].Num_Undeliverable_Mailings__c);
        system.assertEquals(1, contacts[2].Num_Undeliverable_Mailings__c);
        system.assertEquals(1, contacts[3].Num_Undeliverable_Mailings__c);
        
        campMembers = [select status from CampaignMember ORDER BY Contact.LastName ASC];
        campMembers[0].Undeliverable__c = false;
        campMembers[1].Undeliverable__c = false;
        campMembers[2].Undeliverable__c = false;
        campMembers[3].Undeliverable__c = false;
        //update campaign members
        update campMembers;
        
        //fetch Contacts
        contacts = [SELECT Id, Num_Undeliverable_Mailings__c FROM Contact Order By LastName ASC];
        system.assertEquals(0, contacts[0].Num_Undeliverable_Mailings__c);
        system.assertEquals(0, contacts[1].Num_Undeliverable_Mailings__c);
        system.assertEquals(0, contacts[2].Num_Undeliverable_Mailings__c);
        system.assertEquals(0, contacts[3].Num_Undeliverable_Mailings__c);
        
        //Fetch CampMembers Records
        campMembers = [select status from CampaignMember ORDER BY Contact.LastName ASC];
        campMembers[0].Undeliverable__c = true;
        campMembers[1].Undeliverable__c = false;
        campMembers[2].Undeliverable__c = true;
        campMembers[3].Undeliverable__c = false;
        //update campMembers
        update campMembers;
        
        //Fetch Contacts
        contacts = [SELECT Id, Num_Undeliverable_Mailings__c FROM Contact Order By LastName ASC];
        system.assertEquals(1, contacts[0].Num_Undeliverable_Mailings__c);
        system.assertEquals(0, contacts[1].Num_Undeliverable_Mailings__c);
        system.assertEquals(1, contacts[2].Num_Undeliverable_Mailings__c);
        system.assertEquals(0, contacts[3].Num_Undeliverable_Mailings__c);
        
        //Stop Test here
        Test.stopTest();
    }
    //V_1.1 - Modified By - Chirag Soni - 09/03/2021 - CR-20210902-15405 - Updated the method to test Waitlist status When EAB Event Status is not equal to waitlist
    static testmethod void testCreateAndPopulateRegistration(){
        
        //Modified By - Chirag soni - CR-20201116-14696 
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        // Query campaign
        Campaign marketoCampaign = [SELECT Id FROM Campaign WHERE Name = 'Marketo Campaign'];
        
        // Query contact in order to create campaign member
        List<Contact> contacts = [SELECT Id FROM Contact];
        //Added By - Chirag Soni - 09/03/2021 - CR-20210902-15405 - create new contact and get account record - From Here
        //Bypass flag
        Util.BypassAllTriggers = true;
        
        Account account = [Select Id From Account Limit 1];
        //Create new contact
        Contact newContact = testUtilities.CreateNewContact(account, false);
        insert newContact;
        
        Util.BypassAllTriggers = false;
        //Added By - Chirag Soni - 09/03/2021 - CR-20210902-15405 - create new contact and get account record - Till Here
        
        Util.BypassAllTriggers = true;
        //Create the new EAB event record
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY;
        eabEvent.Marketo_Campaign__c = marketoCampaign.id;
        eabEvent.Event_Manager__c = usr.Id;
        insert eabEvent;
        Util.BypassAllTriggers = false;
        
        test.startTest(); 
        
        // when campaign member inserted and EAB Event Status is Ope-waitlist only then regitration should be created with waitlist status
        
        List<CampaignMember> testCampaignMembers = new List<CampaignMember>();
        testCampaignMembers.add(New CampaignMember(CampaignId = marketoCampaign.Id ,ContactId= contacts[0].Id ,Status='Registered'));
        testCampaignMembers.add(New CampaignMember(CampaignId = marketoCampaign.Id ,ContactId= contacts[1].Id ,Status='Waitlisted')); 
        testCampaignMembers.add(New CampaignMember(CampaignId = marketoCampaign.Id ,ContactId= contacts[2].Id ,Status='Attended'));
        testCampaignMembers.add(New CampaignMember(CampaignId = marketoCampaign.Id ,ContactId= contacts[3].Id ,Status='No Show')); 
        insert testCampaignMembers;
        
        // Query Registrations created on EAB Event
        List<Registration__c> registrations = [SELECT Id, Contact__c, Status__c FROM Registration__c WHERE 
                                               EAB_Event__c = :eabEvent.Id];
        
        // check status both side 
        System.assertEquals('Waitlist', registrations[0].Status__c);
        System.assertEquals('Waitlist', registrations[1].Status__c);
        System.assertEquals('Waitlist', registrations[2].Status__c);
        System.assertEquals('Waitlist', registrations[3].Status__c);
        
        // check contact id both side
        System.assertEquals(testCampaignMembers[0].ContactId, registrations[0].Contact__c);
        System.assertEquals(testCampaignMembers[1].ContactId, registrations[1].Contact__c);
        System.assertEquals(testCampaignMembers[2].ContactId, registrations[2].Contact__c);
        System.assertEquals(testCampaignMembers[3].ContactId, registrations[3].Contact__c);
        
        //  assert to check populated value on CampaignMember 
        List<CampaignMember> populatedCm = [SELECT Id, Registration__c FROM CampaignMember WHERE CampaignId = :marketoCampaign.Id];
        
        //  assert to check populated value on CampaignMember 
        System.assertEquals(registrations[0].Id, populatedCm[3].Registration__c);
        System.assertEquals(registrations[1].Id, populatedCm[0].Registration__c);
        System.assertEquals( registrations[2].Id, populatedCm[1].Registration__c);
        System.assertEquals(registrations[3].Id, populatedCm[2].Registration__c); 
        
        //if campaign member is inserted or updated and EAB event status is open waitlist only and regitration not exist then create new registration with status waitlist.
        //if if campaign member is inserted or updated EAB event status is open waitlist only and registration already exist then status of registration should be same as campaign member status.
        
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        update eabEvent;
        
        List<CampaignMember> campaignMembersToBeUpdate = new List<CampaignMember>();
        campaignMembersToBeUpdate.add(new CampaignMember( Id = testCampaignMembers[0].Id,  Status='No Show'));
        campaignMembersToBeUpdate.add(new CampaignMember( Id = testCampaignMembers[1].Id, Status='Registered'));
        campaignMembersToBeUpdate.add(new CampaignMember( Id = testCampaignMembers[2].Id, Status='Waitlisted'));
        campaignMembersToBeUpdate.add(new CampaignMember( Id = testCampaignMembers[3].Id, Status='Attended'));
        update campaignMembersToBeUpdate;
        
        List<Registration__c> Updatedregistrations = [SELECT Id, Contact__c, Status__c FROM Registration__c WHERE 
                                                      EAB_Event__c = :eabEvent.Id];
        
        // check status both side after update
        System.assertEquals(campaignMembersToBeUpdate[0].Status, Updatedregistrations[0].Status__c);
        System.assertEquals(campaignMembersToBeUpdate[1].Status, Updatedregistrations[1].Status__c);
        System.assertEquals('Waitlist', Updatedregistrations[2].Status__c);
        System.assertEquals(campaignMembersToBeUpdate[3].Status, Updatedregistrations[3].Status__c);
        test.stopTest();
        
        //Added By -  Chirag Soni - 09/03/2021 - CR-20210902-15405 - Added the new Campaign Member to test Watilist status - From Here
        //ByPass flag
        Util.BypassAllTriggers = true;
        //Get Event record
        eabEvent = [Select Id, Status__c From Advisory_Event__c Where Id =: eabEvent.Id];
        //Updated EAB Event status
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION_RESTRICTED;
        //update eab event
        Update eabEvent;
        Util.BypassAllTriggers = false;
        
        CampaignMember campaignMember = new CampaignMember(CampaignId = marketoCampaign.Id ,ContactId= newContact.Id ,Status='Waitlisted');
        insert campaignMember;
        
        // Query Registrations created on EAB Event
        registrations = [SELECT Id, Contact__c, Status__c, Name FROM Registration__c WHERE EAB_Event__c = :eabEvent.Id 
                         AND Contact__c =: newContact.Id ];
        
        // check status both side 
        System.assertEquals('Waitlist', registrations[0].Status__c);
        
        // check contact id both side
        System.assertEquals(campaignMember.ContactId, registrations[0].Contact__c);
        //Added By -  Chirag Soni - 09/03/2021 - CR-20210902-15405 - Added the new Campaign Member to test Watilist status - Till Here
    }
    
}