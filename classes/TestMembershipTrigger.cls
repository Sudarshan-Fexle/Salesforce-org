/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
private class TestMembershipTrigger {
    
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    private static String meetingGUID = '000-000-001';
    
/*
    Purpose         :   Test class for Trigger_Membership
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/19/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        V1.1 - Modified By - CR-20111122-239
                        V1.3 - Modified By - Bhavi - 06/15/2012 - Test Methid added for CR-20120518-905
                        v1.1 - Modified By - (SUNJ 12/19/13) - CR-20130118-2218
                        V1.4 - Modified By - Mahendra Swarnkar - 3/30/2016 - CR-20160107-9497
                        V1.5 - Modified By - Mahendra Swarnkar - 05/08/2017 - CR-20170327-10781 - Added a new test Method "testPopulateOpportunityAndProjectFieldsFromMembership"
                        V1.6 - Modified By - Colin McGloin - 09/04/2018 - CR-20180731-12476 - Commented out all references to Opportunity fields Value Advisor, Value Management Director, Value Management Lead, Practice Partner due to their removal as part of Opp Lookup Cleanup
                        V1.7 - Modified By - Saurabh Kumar - 10/13/2020 - CR-20200819-14447 - Replaced Meeting with EAB Event
			V1.8 - Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021

    Coverage        :   Trigger_Membership - 100%
                        MembershipTriggerHelper - 97%
*/
    
    @testSetup static void setup() {
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Saweda';
        update user1;
        
    }
    
    static testmethod void testMembershipRelationshipGradeNotes() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Util class methods
        util.resetRecordtypeSettings();
        
        //Create test data
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Enabling Triggers again for testing
        Util.byPassAllTriggers = false;
        
        //Membership
        Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
        
        //Update Membership
        insert member;
        
        //Assert the result
        member = [Select Id, Owner_Associate__c from Membership__c where Id =: member.Id];
        
        //insert membership record and assert the result
        test.startTest();
        
        //Associate Opportunity to the Membership
        opportunity.Membership__c = member.Id;
        update opportunity;
        
        // update the membership's relationship grade notes
        // member.Relationship_Grade_Notes__c = 'New Grade Notes!';
        update member;
        
        //Stop Test here
        test.stopTest();
        
        //Querying Opportunity record details
        opportunity = [SELECT Id, Relationship_Grade_Notes__c, Membership__c FROM Opportunity WHERE Id = :opportunity.Id];
        member = [Select Id/*, Relationship_Grade_Notes__c*/ from Membership__c where Id =: member.Id];
        system.assertEquals(member.Id, opportunity.Membership__c);
        //system.assertEquals('New Grade Notes!', member.Relationship_Grade_Notes__c);
    }
    
    static testmethod void myUnitTest1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Util class methods
        util.resetRecordtypeSettings();
        
        //Fecth active user
        List<User> listUser = [Select id from User where IsActive = true AND Id !=: UserInfo.getUserId() limit 1];
        
        //Checking list for its size value
        if(listUser.size() > 0) {
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = true;
            
            //Update User
            User user = new User(Id = UserInfo.getUserId(), Associate__c = listUser[0].Id);
            update user;
            
            //Create test data
            Account acc = TestUtilities.CreateNewAccount(true);
            
            //Program
            Program__c program = TestUtilities.CreateNewProgram(true);
            
            //Opportunity
            Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
            
            //Contract
            Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                                   End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
            insert contract;
            
            //Membership
            Membership__c member = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
            
            //Enabling Triggers
            Util.byPassAllTriggers = false;
            
            //insert membership record and assert the result
            insert member;
            
            //Assert the result
            member = [Select Id, Owner_Associate__c from Membership__c where Id =: member.Id];
            System.assertEquals(user.Associate__c, member.Owner_Associate__c);
            
            //Bypassing Triggers 
            Util.byPassAllTriggers = true;
            
            //Update Earliest_Contract__r on contract
            contract.Start__c = Date.today() + 7;
            update contract;
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = false;
            
            //Update Earliest Contract
            member.Earliest_Contract__c = contract.Id;
            
            //update membership record
            update member;
            
            //start test from here
            Test.startTest();
            
            //assert for the result
            member = [Select Id, Earliest_Contract__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.PROSPECT_PENDING_FUTURE_START_DATE, member.Membership_Status_Text__c);
            
            //Update Active_Contract_Idenfied__c on contract
            contract.Start__c = Date.today() - 7;
            contract.End__c = Date.today() + 7;
            contract.Status__c = Constants.HONORARY;
            update contract;
            member.Active_Contract_Idenfied__c = contract.Id;
            
            //update membership record
            update member;
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals(Constants.MEMBER_HONORARY, member.Membership_Status_Text__c);
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = true;
            
            contract.Status__c = Constants.CLOSED;
            update contract;
            
            //Bypassing Triggers so then test data can be made easily
            Util.byPassAllTriggers = false;
            
            //update membership record
            member.Account_Name__c = acc.Id;
            update member;
            
            //stop test here
            Test.stopTest();
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
            System.assertEquals('Member - Payer', member.Membership_Status_Text__c);
            
            //assert for the result
            member = [Select Id, Active_Contract_Idenfied__c, Membership_Status_Text__c from Membership__c where Id =: member.Id];
        }
    }
    
    //Test method to test the delete functionality of Mambership Key Contact sfor Non Membership records
    static testmethod void testDeleteMembershipKeyContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Utility method
        util.resetRecordtypeSettings();
        
        //Create test data
        Account acc = new Account(Name = 'Test Account Data');
        insert acc;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Prepare data
        for(Integer i = 0; i < 20; i++) {
            memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, 
                                              Active_Contract_Idenfied__c = contract.Id));
        }
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        
        //insert membership record and assert the result
        insert memberships;
        
        //Create a list of membership records
        List<Membership_Key_Contact__c> membershipKeyContacts = new List<Membership_Key_Contact__c>();
        
        //Add membership Records for Contacts
        for(Membership__c membership : memberships) {
            
            //add record in list
            membershipKeyContacts.add(new Membership_Key_Contact__c(Membership__c = membership.id, Name='Test 1', Role_Type__c = 'PT', 
                                                                    Role__c = 'Exec Sponsor'));
        }
        
        /* Test Insert */
        insert membershipKeyContacts;
        
        //Start Test from here
        Test.startTest();
        
        //Update membership records
        update memberships;
        
        //check if membership key Contacts has been associated with Contacts
        Integer counter = [Select count() from Membership_Key_Contact__c where Id IN: membershipKeyContacts and Membership__c != null];
        System.assertEquals(memberships.size(), counter);
        
        //Update contract record
        contract.Start__c = Date.today() - 7;
        contract.End__c = Date.today() - 7;
        contract.Status__c = Constants.CLOSED;
        update contract;
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        //Loop through the results
        for(Membership__c membership : memberships) {
            
            System.assertEquals(Constants.PROSPECT_PURE, membership.Membership_Status__c);
        }
        
        //Stop Test here
        Test.stopTest();
    }
    
    //V1.5 - Added by - Mahendra Swarnkar - 05/08/2017 - CR-20170327-10781 -
    //Commented out Project changes due to process no longer running on Projects anymore - Spring Cleaning - Colin McGloin
  	//Test method to test the population of fields on opportunity & Project object from membership
    static testmethod void testPopulateOpportunityAndProjectFieldsFromMembership() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be made easily
        Util.byPassAllTriggers = true;
        
        //Calling Utility method
        util.resetRecordtypeSettings();
        
        //Create test data
        Account acc = new Account(Name = 'Test Account Data');
        insert acc;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Get Contract LOA record type
        List<RecordType> recordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'BI_Contract_Renewal' ORDER BY DeveloperName ASC];
        System.assert(recordTypes != null);
        
        //Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp.Name = 'Test Opportunity1';
        opp.RecordTypeId = recordTypes[0].Id;
        opp.Batch_Status__c = 'Testing1';
        opp.Pool_Year__c = string.valueOf(system.today().year());
        
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp1.Name = 'Test Opportunity2';
        opp1.RecordTypeId = recordTypes[0].Id;
        opp1.Batch_Status__c = 'Testing2';
        opp1.Pool_Year__c = string.valueOf(system.today().year()+1);
        
        opportunities.add(opp);
        opportunities.add(opp1);
        insert opportunities;
        
        //Project Record type Id
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        Id projRtypeId = Util.RecordTypeId('Project__c', 'Tech'); 
        
        //Project
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(Name = 'Test_1', RecordTypeId = projRtypeId, Product__c = program.Id ));
        
        insert projects;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile 
                     WHERE Name='System Administrator']; 
        System.assert(p != null);
        
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                          TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
        
        //Users
        List<User> users = new list<user>();
        
        
        // The following code runs as user 'u'
        User u1 = new User(Alias = 'standt', Email='standarduse676r@testorg.com', Employee_Id__c = 'Testing 1',
                           EmailEncodingKey='UTF-8', LastName='Testing45465656', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                           UserName=Math.random() + '@test.com');
        users.add(u1);
        insert users;
        
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, 
                                          Primary_Project__c = projects[0].Id, Active_Renewal_Opportunity__c = opportunities[0].Id
                                          /*Value_Management_Director__c = users[0].Id, Value_Management_Lead__c = users[0].Id,
                                            Value_Advisor__c = users[0].Id, Practice_Partner__c = users[0].Id, 
                                            Relationship_Advisor__c =  users[0].Id */));
        
        //Test Starts from here
        Test.startTest();
        
        //Enables All triggers
        Util.BypassAllTriggers = false;
        
        //Insert Memberships
        insert memberships;
        
        test.stopTest();
        
        //Query opportunity records 
        List<Opportunity> opportunities1 = [Select id /* Relationship_Advisor__c , Executive_Sales_Support__c, Value_Advisor__c, 
											Value_Management_Director__c, Value_Management_Lead__c*/
                                            From opportunity Where Id =: opportunities[0].Id ];
        
        //Asserts on results
        System.assertEquals(1, opportunities1.size());
        
        //Update Membership
        memberships[0].Active_Renewal_Opportunity__c = opportunities[1].Id;
        
        update memberships;
        
        //Query opportunity records 
        opportunities1 = [Select id /*, Relationship_Advisor__c, Executive_Sales_Support__c, Value_Advisor__c, 
						  Value_Management_Director__c, Value_Management_Lead__c*/ 
                          From opportunity 
                          Order By Batch_Status__c ASC];
        
        //Asserts on results
        System.assertEquals(2, opportunities1.size()); 
    }
    
    //Added by Saurabh Kumar - 10/01/2020 - CR-20200821-14453 
    /**
     *  @use cases  :   This method is used to sync Partner Status field on Registration in case of insert, delete & update
     **/
    static testMethod void testSyncRegistrationPartnerStatus() {
    	//Modified By - Neha Sharma - CR-20210608-15200 - 08/12/2021 - Initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        
        PermissionSet ps = [SELECT Id, Label 
                            FROM PermissionSet
                            WHERE Label = 'EAB Event Manager'];
        
        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = user1.Id, PermissionSetId = ps.Id);
        insert assignPS; 
        System.runAs(user1) {
            
            Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
            system.assertEquals(true, isEABEventManager);
            
            util.bypassAllTriggers = true;
            
            //Create the new account record
            Account account = TestUtilities.CreateNewAccount(true);
            //Create the new contact record
            Contact contact = testUtilities.CreateNewContact(false);
            contact.AccountId = account.Id;
            insert contact;
            
            //Create the new program record
            Program__c program = TestUtilities.CreateNewProgram(true);
            
            //Create the new program record
            Program__c program1 = TestUtilities.CreateNewProgram(true);
            
            //Create the new event record
            Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eSeries.Event_Type__c = 'Research Working Sessions';
            eSeries.Primary_Program__c  = program1.Id;
            eSeries.Rules_Programs__c = 'Establish independent rules';
            eSeries.Public_Name__c = 'Test';
            eSeries.Short_Name__c = 'Test';
            eSeries.Status__c = 'Open - Registration';
            eSeries.Begins__c = System.today();
            eSeries.Ends__c = System.today();
            insert eSeries;
            
            //Create the new Opp record
            Opportunity testOpp = TestUtilities.CreateNewOpportunity(account.Id, false);
            testOpp.Main_Contact__c = contact.Id;
            insert testOpp;
            
            //Create the new Contract record
            Contract__c testContract1 = new Contract__c(
                Name='Test Contract1', Payer_Account__c = account.Id, Program__c = program.Id, 
                Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
                Contract_Renewal_Opportunity__c = testOpp.Id
            );
            
            insert testContract1;
            
            //Create the new Registration record
            Registration__c registration = new Registration__c();
            registration.Contact__c = contact.Id;
            //registration.Meeting__c = parentMeeting.Id;
            registration.EAB_Event__c = eSeries.Id;
            registration.Status__c = RegistrationHelper.STATUS_REGISTERED;
            insert registration;
            
            //Create the new rule record
            Rule__c rule = new Rule__c();
            rule.Advisory_Event__c = eSeries.Id;
            rule.Program__c = program.Id;
            rule.Primary__c = true;
            insert rule;
            
            //Create the new Membership record
            List<Membership__c> memberships = new List<Membership__c>();
            Membership__c member1 = new Membership__c( Name = 'Test Membership 1', Account_Name__c = account.Id,
                                                      Program__c = program.Id, Active_Contract_Idenfied__c =
                                                      testContract1.Id, Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member1);
            
            Membership__c member2 = new Membership__c( Name = 'Test Membership 2', Account_Name__c = account.Id,
                                                      Program__c = program.Id, Assigned_Marketer__c = usr.Id,
                                                      Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member2);
            
            test.startTest(); 
            
            util.bypassAllTriggers = false;     
            insert memberships;
            
            test.stopTest();     
            
            util.bypassAllTriggers = true;     
            List<Registration__c> registrations = [SELECT ID, Partner_Status__c  FROM Registration__c WHERE ID =: registration.Id];
            
            //Assert for Partner Status
            System.assertEquals('Partner',registrations[0].Partner_Status__c );
            
        }
        
    }
    //Added by Saurabh Kumar - 10/01/2020 - To increase coverage 
    static testMethod void testPopulateMostRecentQACall() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                            WHERE (DeveloperName = 'Core_AM' OR DeveloperName = 'BI_QA_Call') 
                                            AND SObjectType = 'Event' AND IsActive = true];
        
        //Query through Opportunity RecordTypes
        List<RecordType> membershipRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                 WHERE DeveloperName = 'Enrollment'
                                                 AND SObjectType = 'Membership__c' AND IsActive = true];
        
        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapMemRecordType =  new Map<String,Id>();
        
        //Populate mapEventRecordType
        for(RecordType rt : membershipRecordType){
            mapMemRecordType .put(rt.DeveloperName , rt.Id);
        }                                        
        
        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();
        
        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType){
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        }
        
        
        //Create the new account record
        Account account = TestUtilities.CreateNewAccount(true);
        //Create the new contact record
        Contact contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        insert contact;
        
        //Create the new program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        
        //Create the new opp record
        Opportunity testOpp = TestUtilities.CreateNewOpportunity(account.Id, false);
        testOpp.Main_Contact__c = contact.Id;
        insert testOpp;
        
        //Create the new contract record
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = account.Id, Program__c = program.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = testOpp.Id
        );
        
        insert testContract1;
        
        //Create the new Membership records
        List<Membership__c> memberships = new List<Membership__c>();
        Membership__c member1 = new Membership__c( RecordTypeId = mapMemRecordType.get('Enrollment'), Name = 'Test Membership 1', Account_Name__c = account.Id,
                                                  Program__c = program.Id, Active_Contract_Idenfied__c =
                                                  testContract1.Id, Membership_Status_Text__c = 'Member -001');
        memberships.add(member1);
        
        insert memberships;
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today(), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'PT QA Call', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes'));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today()+4, 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'CM QA Call', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes'));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today()+3, 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'RI QA Call', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes'));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today()+2, 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'BI QA Call', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes'));
        
        events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_AM') ,StartDateTime = system.today(), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Phone Appointment', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes',
                             Event_Purpose__c = 'Evergreen Action'));
        events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_AM') ,StartDateTime = system.today(), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = memberships[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'In Person Visit', Visit_Location__c = 'EAB Hosted Event', Membership__c =  memberships[0].Id, Project_Sponsor_On_Call__c = 'Yes',
                             Event_Purpose__c = 'Evergreen Action'));                     
        test.startTest();
        insert events;
        
        
        
        Set<Id> memIds = new Set<Id>();
        for(Membership__c membership : memberships){
            memIds.add(membership.Id);
        }
        
        MembershipTriggerHelper.PopulateMostRecentQACall(memIds);
        test.stopTest();
        MembershipTriggerHelper.PopulateMostRecentQACallForESMembership(events);
        
    }
}