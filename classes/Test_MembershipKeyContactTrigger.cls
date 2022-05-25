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
@isTest
private class Test_MembershipKeyContactTrigger {
    /*
Purpose         :   Test class for Trigger_MembershipKeyContact

Create By       :   Simplyforce Technology

Created Date    :   12/16/2012

Current Version :   V1.0

Revision Log    :   V1.0 - Created
v1.1 - (SUNJ 12/19/13) - CR-20130118-2218
v1.2 - Modified by - Mahendra Swarnakar - 12/21/2016 - Release-55 Apply the check for bypassing the unwanted triggers execution for the Test class 
v1.3 - Added test method by - Mahendra Swarnakar - 1/21/2017 - To check updatePubMeetingStatusValue method functionality
v1.4 - Modified by - Mahendra Swarnkar - 03/22/2021 - CR-20210212-14911 - Update membership status on subscription dropped
v1.5 - Modified by - Victor Hanson - 03/30/2021 - CR-20210330-15043 - added test_membershipKeyContactMPOC to test MPOC
v1.6 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
v1.7 - Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169 - Added test_checkForSingleMembershipKeyContactRelatedToMembership()
Coverage        :   Trigger_MembershipKeyContact - 100%
MembershipKeyContactTriggerHelper - 100%
*/
    static User usr = new User(Id = UserInfo.getUserId()); //[select id from User where isActive = true AND ID =: UserInfo.getUserId() limit 1];
    
    static testMethod void myUnitTest() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        // setup the custom setting
        Util.resetRecordtypeSettings();
        
        system.debug('### Test Case 1 ###');
        
        Account acc = new Account(Name = 'Test Case Account 1', RecordTypeId = Util.recordtypemap('Account').get('US Corporate'), Academy_Programs_Available_for_Outreach__c = '', BI_Programs_Available_for_Outreach__c = '', Core_Programs_Available_for_Outreach__c = '');
        insert acc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(acc, True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        Program__c testProg1 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='ZZZ', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg1;
        
        Program__c testProg2 = new Program__c(Name='Test Trigger Program', New_Business_Marketer__c = 'RI Marketer', Program_Acronym__c='Test Update', Create_memberships__c='No', Business_line__c = 'PT');
        insert testProg2;
        
        AccountTeamMember accMember = new AccountTeamMember(
            UserId = usr.Id,
            AccountId = acc.Id,
            TeamMemberRole = testProg1.New_Business_Marketer__c);
        //AccountAccessLevel = 'Read');
        insert accMember;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity testOpp = new Opportunity(Sales_Pursuit_Products__c = 'APS',Name='Test Opp', Main_Contact__c = cont.Id, StageName = '0-Exploring', Amount=1, CloseDate = System.today().addDays(32), AccountId = acc.Id);
        insert testOpp;
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = acc.Id, Program__c = testProg1.Id, 
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = testOpp.Id
        );
        
        insert testContract1;
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        Membership__c member1 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id
            /*Active_Contract_Idenfied__c = testContract1.Id*/);
        
        memberships.add(member1);
        
        Membership__c member2 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            OwnerId = usr.Id,
            Assigned_Marketer__c = usr.Id, 
            Program__c = testProg1.Id
            /*Active_Contract_Idenfied__c = testContract1.Id*/
        );
        
        memberships.add(member2);
        
        Membership__c member3 = new Membership__c(
            Name = 'Test Membership',
            Account_Name__c = acc.Id,
            Program__c = testProg1.Id,
            OwnerId = usr.Id,
            Assigned_Marketer__c = usr.Id);
        memberships.add(member3);
        //Enable the triggers
        Util.BypassAllTriggers = False;
        Util.IsBatch = false;
        Util.IsTrigger_ContractFieldUpdate = false;
        Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = false;
        Util.IsTrigger_EventPrewire = false;
        Util.IsTrigger_EventUpdateFields = false;
        Util.IsTrigger_ContractIntegratedAcctRunning = false;
        
        //Test.startTest
        Test.startTest();
        
        insert memberships;
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        Site_Profile__c sProfile = Test_SiteUserHelper.CreateSiteProfile(acc, SiteUserHelper.SITE_EAB, true);
        
        Contact con = [SELECT Id, Name, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Enable the triggers
        Util.BypassAllTriggers = false;
        
        //Test Case for - CR-20121019-1641
        //update member2;
        
        //Insert membership key contact record
        Membership_Key_Contact__c testMembershipKeyContact = new Membership_Key_Contact__c(
            Contact__c = con.id,
            Name='Test 1', 
            Role_Type__c = 'PT', 
            Role__c = 'Exec Sponsor', 
            Membership__c = member2.Id,
            Pubs__c = true,
            Meetings__c = true);
        insert testMembershipKeyContact;
        
        //Stop test here    
        Test.stopTest();
        //Modified by - Mahendra Swarnkar - 03/22/2021 - CR-20210212-14911 - Update membership status on subscription dropped
        member2 = [select id, Membership_Status__c, OwnerId, Assigned_Marketer__c /*Active_Contract_Idenfied__c, Latest_Contract__c, Earliest_Contract__c*/ from Membership__c where Id = :member2.Id];
        system.debug('\n\nm2.Membership_Status__c ' + member2.Membership_Status__c);
        
        //Assert for the result
        con = [Select Id, Membership_Contact_Pubs__c, Membership_Contact_Meetings__c from Contact where Id =: con.Id];
        //System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Pubs__c);
        //System.assertEquals(testProg1.Program_Acronym__c, con.Membership_Contact_Meetings__c);
    }
    
    //03/30/2021 - CR-20210330-15043  - Victor Hanson - added to test MPOC
    static testMethod void test_membershipKeyContactMPOC() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        
        Account acc = TestUtilities.CreateNewAccount(false);    
        acc.EAB_com_Organization_Status__c = 'Active';
        insert acc;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test1@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c = 'Active', Title = 'Test', Phone = '614-555-8855'));
        
        Util.BYPassAllTriggers = false;
        //Insert
        insert contacts;
        Util.BYPassAllTriggers = true;
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        //memberships.add(new Membership__c(Name = 'Test Membership1', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        
        //Inssert the list records
        insert memberships;
        
        //List to hold the membership key contact
        List<Membership_Key_Contact__c> mKCs = new List<Membership_Key_Contact__c>();
        
        //Add the records to the list
        mKCs.add(new Membership_Key_Contact__c(Name='Test 1', Membership__c = memberships[0].Id, Contact__c = contacts[0].id, Pubs__c = false, Meetings__c = true, Key_Contact_Status__c = 'Active', Role__c = 'MPOC')); 
        
        insert mKCs;
        
        system.assertEquals(MKCs.size(), 1);
    }
    
    //Added By - Mahendra Swarnkar - 1/21/2017 - CR-20160907-10171
    //To check updatePubMeetingStatusValue method functionality
    static testMethod void test_updatePubMeetingStatusValue() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        
        Account acc = TestUtilities.CreateNewAccount(false);    
        acc.EAB_com_Organization_Status__c = 'Active';
        insert acc;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test1@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c = 'Active', Title = 'Test', Phone = '614-555-8855'));
        // contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test2@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c = 'Active', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), Email = 'test3@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c  = 'Active', Title = 'Test', Phone = '614-555-8855'));
        
        Util.BYPassAllTriggers = false;
        //Insert
        insert contacts;
        Util.BYPassAllTriggers = true;
        
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        memberships.add(new Membership__c(Name = 'Test Membership1', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        
        //Inssert the list records
        insert memberships;
        
        //List to hold the membership key contact
        List<Membership_Key_Contact__c> mKCs = new List<Membership_Key_Contact__c>();
        
        //Add the records to the list
        mKCs.add(new Membership_Key_Contact__c(Name='Test 1', Membership__c = memberships[0].Id, Contact__c = contacts[0].id, Pubs__c = false, Meetings__c = true, Key_Contact_Status__c = 'Active'));
        // mKCs.add(new Membership_Key_Contact__c(Name='Test 2', Membership__c = memberships[0].Id, Contact__c = contacts[0].id, Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Active'));
        mKCs.add(new Membership_Key_Contact__c(Name='Test 3', Membership__c = memberships[1].Id, Contact__c = contacts[1].id, Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Active'));
        
        //Query on the User to get only those User which has role = Shard Swervice so that Validation rule can be Bypass.
        List<User> u = [Select Id From user Where UserRole.Name = 'Shared Services' AND IsActive = true AND Profile.Name = 'System Administrator'];
        System.runAs(u[0]) {   
            
            insert mKCs;
            
            //Test.startTest
            Test.startTest();
            
            //Enable the triggers
            Util.BypassAllTriggers = false;
            
            //update with inactive contact
            mKCs[0].Contact__c = contacts[0].Id;
            mKCs[0].Pubs__c = true;
            mKCs[0].Meetings__c = false;
            mKCs[0].Key_Contact_Status__c = 'Inactive';
            
            //update the membership key contact
            update mKCs;
            
            //Query through the membership key contact
            mKCs = [Select Id, Contact__c, Pubs__c, Meetings__c, Key_Contact_Status__c  From 
                    Membership_Key_Contact__c where Id =: mKCs[0].Id];
            
            //Assert for the result     
            System.assertEquals('Inactive', mKCs[0].Key_Contact_Status__c);   
            System.assertEquals(true, mKCs[0].Pubs__c);
            System.assertEquals(false, mKCs[0].Meetings__c);
            
            //re-initialization of list
            mKCs = new List<Membership_Key_Contact__c>();
            mKCs.add(new Membership_Key_Contact__c(Name='Test 2', Membership__c = memberships[0].Id, Contact__c = contacts[0].id, Pubs__c = true, Meetings__c = true, Key_Contact_Status__c = 'Active')); 
            
            //update 
            insert mKCs;
        }
        //Query through the membership key contact
        mKCs = [Select Id, Contact__c, Pubs__c, Meetings__c, Key_Contact_Status__c  From 
                Membership_Key_Contact__c where Id =: mKCs[0].Id];
        
        //Assert for the result  
        System.assertEquals('Active', mKCs[0].Key_Contact_Status__c);   
        System.assertEquals(true, mKCs[0].Pubs__c);
        System.assertEquals(true, mKCs[0].Meetings__c);
        
    }
    

	//V_1.1 - Added By - Neha Sharma - 4/28/2022 - CR-20210520-15169
    @isTest 
    static void test_checkForSingleMembershipKeyContactRelatedToMembership(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        
        Account acc = TestUtilities.CreateNewAccount(false);    
        acc.EAB_com_Organization_Status__c = 'Active';
        insert acc;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new contacts in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact 1', Email = 'test1@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c = 'Active', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact 3', Email = 'test3@test.com', Bypass_Domain_Validation__c = true, AccountId = acc.Id, Contact_Status__c  = 'Active', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;
     
        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        List<Membership__c> memberships = new List<Membership__c>();
        
        memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        memberships.add(new Membership__c(Name = 'Test Membership1', Account_Name__c = acc.Id, Program__c = testProgram.Id));
        
        //Inssert the list records
        insert memberships;
        
        Membership_Key_Contact__c mkc1 = new Membership_Key_Contact__c();
        mkc1.Name='Test 1'; 
        mkc1.Membership__c = memberships[0].Id; 
        mkc1.Contact__c = contacts[0].id;
        mkc1.Pubs__c = false;
        mkc1.Meetings__c = true; 
        mkc1.Key_Contact_Status__c = 'Active'; 
        mkc1.Primary__c = true;
        
        insert mkc1;
        
        Membership_Key_Contact__c mkc2 = new Membership_Key_Contact__c();
        mkc2.Name='Test 2'; 
        mkc2.Membership__c = memberships[0].Id; 
        mkc2.Contact__c = contacts[0].id;
        mkc2.Pubs__c = false;
        mkc2.Meetings__c = true; 
        mkc2.Key_Contact_Status__c = 'Active'; 
        mkc2.Primary__c = true;
        
        Membership_Key_Contact__c mkc3 = new Membership_Key_Contact__c();
        mkc3.Name='Test 3'; 
        mkc3.Membership__c = memberships[0].Id; 
        mkc3.Contact__c = contacts[0].id;
        mkc3.Pubs__c = false;
        mkc3.Meetings__c = true; 
        mkc3.Key_Contact_Status__c = 'Inactive'; 
        mkc3.Primary__c = True;
        insert mkc3;
        Util.BYPassAllTriggers = false;
        
        Membership_Key_Contact__c mkc4 = new Membership_Key_Contact__c();
        mkc4.Name='Test 2'; 
        mkc4.Membership__c = memberships[0].Id; 
        mkc4.Contact__c = contacts[0].id;
        mkc4.Pubs__c = false;
        mkc4.Meetings__c = true; 
        mkc4.Key_Contact_Status__c = 'Active'; 
        mkc4.Primary__c = true;
        
        Test.startTest();
        try {
            insert mkc2;            
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('Membership can not have more than one primary Membership Key Contact'));
        } 
        //Update case 
        try
        {
            mkc3.Key_Contact_Status__c = 'Active'; 
            update mkc3;
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Membership can not have more than one primary Membership Key Contact'));
        } 
        //Bulk insert case 
        try
        { 
            Delete mkc1;
            Delete mkc3;
            List<Membership_Key_Contact__c> insertMembershipKyContact = new  List<Membership_Key_Contact__c>{mkc2, mkc4};
            insert insertMembershipKyContact;
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Membership can not have more than one primary Membership Key Contact'));
        } 
        Test.stopTest();
    }
}