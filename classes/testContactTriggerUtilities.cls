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
**/
@isTest(seeAllData=false)
private class testContactTriggerUtilities {
   /** 
    *  Description     :   Test class for ContactTriggerUtilities
    *
    *  Created By      :   
    *
    *  Created Date    :   
    *
    *  Revision Logs   :   V_1.0 - Created
    *                      V_1.1 - Modified - 12/11/2014 - By Bhavi Sharma
    *                      V_1.2 - Modified - 11/26/2015 - By Mahendra Swarnkar - CR-20150831-9207 - added a new test method "testvalidateContactFieldsForInvalidPhrase"
    *			   V_1.3 - Modified - 06/30/2016 - By Mahendra Swarnkar - CR-20160219-9621 - updated the "testvalidateContactFieldsForInvalidPhrase**" methods  
    *                      V_1.4 - Modified - 07/22/2016 - By Abhinav Sharma - CR-20150202-8641 - A code refactor CR
    *                      V_1.4 - Modified - 11/07/2016 - By Colin McGloin - CR-20161103-10337 - Removed reference to "Delivery Chatter Plus - Restricted 15" profile and refined User Creation
    *                      V_1.5 - Modified - 01/23/2017 - By Mahendra Swarnkar - 1/23/2017 - CR-20160907-10171
    *                      V_1.6 - Modified - 04/24/2017 - By - Mahendra Swarnakar - CR-20170118-10625
    *                      V_1.7 - Modified - 04/24/2017 - By - Mahendra Swarnakar - updated "testContactSwitchInBetweenInActiveToActiveInstitution" method as per the Run All Test.
    *                      V_1.8 - Modified - Dipesh kumar - Apollo - Run All Test Failures Fixes
    *                      V_1.9 - Modified - 04/29/2019 - By Victor Hanson - CR-20190425-13033
    *                      V_2.0 - Modified - Mahendra Swarnkar 17-06-2019 CR-20190522-13123
    *			   V_2.1 - Modified - Neha Sharma - 11/24/2020 - CR-20200717-14328
    *			   V_2.2 - Modified - Mahendra Swarnkar - 03/05/2020 - CR-20200217-13756 - commented the code part
    *			   V_2.3 - Modified - Neha Sharma - 04/11/2021 - CR-20210324-15022 - MRS test class update
    *			   V_2.4 - Modified - Saurabh Kumar - 04/19/2021 - CR-20210128-14854 - added test method testSyncContactAndRegistrationsWithAcquia()
    *			   V_2.5 - Modified - Neha Sharma - CR-20210608-15200 - 08/12/2021
    *			   V_2.6 - Modified - Mahendra Swarnkar - 11/01/2021 - CR-20210930-15474 - created new method testValidateContactBeforeInactive().	
    *			   V_2.7 - Modified - Chirag Soni - 11/16/2021 - CR-20210930-15474 - Modified Method  -  testsyncRegistrationPartnerStatus() - test class issue fixes
    *			   V_2.8 - Modified - Chirag Soni - 12/22/2021 - CR-20210606-15193 - Commented methods testSyncContactAndRegistrationsWithAcquia()
    *			   V_2.9 - Modified - Neha Sharma - 5/09/2022 - Added testupdateRecordWithContactValues() to increase test coverage.  
    *
    **/
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * Description : Method to test out whether event title is populating as expected from associated contact record on insert. 
     **/
    static testmethod void testNewEventCreation() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List of Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccounts1'));
        insert accounts;
        
        Util.ByPassAllTriggers = false; 
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        con.Title = 'Head Honcho';
        con.Bypass_Domain_Validation__c =true;
        con.Email = 'Test'+Math.random()+'@eab.com';
        con.Phone = '614-555-8855';
        insert con;
        Util.ByPassAllTriggers = true; 
        
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true, Institution__c = true));
        insert teamRoles;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        AND IsActive = true 
                                        AND DeveloperName = 'Assigned'];
        System.assert(recordTypes != null);
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
        
        //Team Membership
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = con.id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[0].Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    RecordTypeId = recordTypes[0].Id);
        
        //Insert teamMembership3
        teamMemberShips.add(teamMembership3);
        insert teamMemberShips;
        
        // create an event with this contact as the 'WhoId'
        Event newEvent = new Event();
        newEvent.StartDateTime = system.now();
        newEvent.EndDateTime = system.now();
        newEvent.Subject = 'Phone Appointment';
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.whoId = con.Id;
        newEvent.Event_Type__c = 'Phone Appointment';
        newEvent.Event_Purpose__c = 'Collection Call';
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert event under contact record
        insert newEvent;
        
        // get the newly updated Event
        Event evt = [SELECT title__c, Id FROM Event WHERE Id = :newEvent.Id];
        
        //Update contact
        con.FirstName = 'XYZ';
        update con;
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
* Description : Method to test out whether event title is updating as expected from associated contact record on contact record update. 
**/
    static testmethod void testContactWithNewTitle() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true; 
        
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        con.Bypass_Domain_Validation__c = true;
        insert con;
        
        Util.byPassAllTriggers = true;
        // create an event with this contact as the 'WhoId'
        Event newEvent = new Event();
        newEvent.StartDateTime = system.now();
        newEvent.EndDateTime = system.now();
        newEvent.Subject = 'Phone Appointment';
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.whoId = con.Id;
        newEvent.Event_Type__c = 'Phone Appointment';
        newEvent.Event_Purpose__c = 'Collection Call';
        insert newEvent;
        
        // get the updated contact and update the title
        Contact updatedContact = [SELECT Name, Id, Title FROM Contact WHERE ID = :con.Id];
        updatedContact.Title = 'CIO';
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update contact record
        update updatedContact;
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * Description : Method to test out contact should never be created on an inactive institution. 
     **/
    static testmethod void insertContactWithInactiveInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new active and inactive institution
        Account acct_Active = TestUtilities.CreateNewAccount(false);
        acct_Active.RecordTypeId = Util.RecordTypeId('Account', 'External'); 
        acct_Active.Status__c = Constants.ACTIVE;
        Account acct_Inactive = TestUtilities.CreateNewAccount(false);
        acct_Inactive.RecordTypeId = Util.RecordTypeId('Account', 'External');
        acct_Inactive.Status__c = 'Inactive - Closed';
        list<Account> accts = new list<Account> { acct_Active, acct_Inactive };
            insert accts;
        
        // create a contact that will try to be added to the inactive institution first
        Contact con = TestUtilities.CreateNewContact(acct_Inactive, false);
        con.Bypass_Domain_Validation__c = true;
        
        // flag to determine if the contact errored successfully
        boolean hasError = false;
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert contact
        try {
            insert con;
        } catch(DMLException ex) {
            hasError = true;
            system.assertEquals(Constants.ERROR_CANNOT_ADD_CONTACT_TO_INACTIVE_INSTITUTION, ex.getDMLMessage(0));
        }
        
        //Asserting for the results
        // make sure the error was thrown
        system.assertEquals(true, hasError, 'Error was not thrown when inserting a contact on an inactive institution.');
        
        // now insert the contact on an active institution
        con.AccountId = acct_Active.Id;
        insert con;
        
        //Asserting for the results
        system.assertNotEquals(con.Id, null, 'The contact id is null even though it should have been inserted successfully.');
        
        //Stop Testing here
        Test.stopTest();
        
    }
    
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description:    1) setup 2 site profiles on different contacts.  Once site profile is active, the other is inactive.
     *                  2) Delete the contact with the inactive site profile - this should also delete the site profile and site user.
     *                  3) Delete the conact with the Active site profile - this should produce an error.
     **/
    static testmethod void validateContactBeforeDelete() {
        
        try {
            
            //Bypass Dupeblocker
            Util.IsTest(true);
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            //Flag for triggers: this is just a test, don't do crazy things.
            Util.isTesting = true;
            
            //Site profiles
            Site_Profile__c sProfile_Inactive = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
            sProfile_Inactive.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE;
            Site_Profile__c sProfile_Active = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
            sProfile_Active.Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE;
            list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile_Active, sProfile_Inactive };
                insert sProfiles;
            
            //get the site profile details for both
            map<Id, Site_Profile__c> sProfileMap = new map<Id, Site_Profile__c>([SELECT Id, Contact__c, Status__c FROM Site_Profile__c WHERE Id IN :sProfiles]);
            
            //delete the contact associated with the inactive site profile
            Contact c_Inactive = new Contact(Id = sProfileMap.get(sProfile_Inactive.Id).Contact__c, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
            string e;
            
            //Start testing from here
            Test.startTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            try {
                delete c_Inactive;
            }
            catch(Exception ex) {
                e = ex.getMessage();
            }
            
            //Asserting for the results
            system.assertEquals(null, e,
                                'The deletion of this contact should have been successful because it is only associated with an inactive site profile.');
            
            //delete the contact associated with the inactive site profile
            Contact c_Active = new Contact(Id = sProfileMap.get(sProfile_Active.Id).Contact__c);
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            try {
                delete c_Active;
            }
            catch(DMLException ex) {
                e = ex.getDMLMessage(0);
            }
            catch(Exception ex) {
                e = ex.getMessage();
            }
            
            //Asserting for the results
            system.assertNotEquals(null, e,'The deletion of this contact should have been thrown an error because it is associated with an active site profile.');
            
            //Stop test here
            Test.stopTest();   
        } catch(Exception ex) {
        }	                
    }
    
    //Modified By - 01/23/2017 - By Mahendra Swarnkar - 1/23/2017 - CR-20160907-10171
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added By Ajit Surana - 02/12/2014 - CR-20130807-3381
    /**
     * Description : Method to test out CR-20130807-3381 based functionality.
    **/
    static testmethod void testNewAdvUserContact_InstitutionChange() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        try {
            
            //Insert Account
            Account acct1 = TestUtilities.CreateNewAccount(false);
            acct1.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
            acct1.Status__c = Constants.ACTIVE;
            acct1.Name = 'Test Account 1';
            insert acct1;
            
            Account acct2 = TestUtilities.CreateNewAccount(false);
            acct2.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
            acct2.Status__c = Constants.ACTIVE;
            acct2.Name = 'Test Account 2';
            insert acct2;
            
            //Insert Eligible Domain
            Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory2.com', 
                                                               Account__c = acct2.Id);
            
            //Insert Eligible Domain
            Eligible_Domain__c domain1 = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory1.com', 
                                                                Account__c = acct1.Id);
            
            //Inserting list of eligible domains      
            list<Eligible_Domain__c> eligibleDomains = new list<Eligible_Domain__c>{ domain, domain1 };
                insert eligibleDomains;
            
            //Updated by Colin McGloin - CR-10337
            //Query through  profile to get Id Of Profile
            Profile profile = [SELECT Id FROM Profile WHERE Name = :Label.DeliveryAppSubscriptionUser];
            
            //User Insert
            User testUser = TestUtilities.CreateNewUser(profile, True);
            
            //Site profile
            Site_Profile__c sProfile1 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_EAB, false);
            sProfile1.Username__c = 'testUser1@eab.com';
            sProfile1.Status__c = 'Active';
            sProfile1.Password__c = 'test';
            sProfile1.Verify_Date__c = date.today();
            
            //Site profile
            Site_Profile__c sProfile2 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_EAB, false);
            sProfile2.Username__c = 'testUser2@eab.com';
            
            //Site profile
            Site_Profile__c sProfile3 = Test_SiteUserHelper.createSiteProfile(acct1, SiteUserHelper.SITE_EAB, false);
            sProfile3.Username__c = 'testUser3@eab.com';
            
            //List of site profiles
            list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile1, sProfile2, sProfile3 };
                insert sProfiles;
            
            //Contacts
            Contact con1 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile1.Contact__c];
            Contact con2 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile2.Contact__c];
            Contact con3 = [SELECT Id, AccountId, Email, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile3.Contact__c];
            
            //Retrieving updated information for the database
            list<Contact> historicalContacts = [SELECT ID, AccountID, (SELECT Id, Status__c FROM Site_Profiles__r) FROM Contact];
            system.assertEquals(3, historicalContacts.size());
            
            //Contact1 - Changing Institution, Email and Create_Advisory_com_User_Account__c flag
            //This should not throw any exception and contact should be get updated successfully
            con1.AccountId = acct2.Id;
            con1.Email = 'testUser1@advisory2.com';
            ContactSiteHelper.hasCheckedInstitutionChange = false;
            ContactSiteHelper.hasBeforeEventLogicGotExecuted = false;
            con1.Bypass_Domain_Validation__c = true;
            con1.Bypass_Filters__c = true;
            con1.Title = 'Test';
            con1.Phone = '614-555-8855';
            
            //Test starts from here
            Test.startTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            //Update contact record
            update con1;
            
            //Retrieving updated information for the database
            historicalContacts = [SELECT ID, AccountID, (SELECT Id, Status__c FROM Site_Profiles__r ORDER By Status__c ASC) FROM Contact 
                                  WHERE AccountID != null AND AccountId =: acct1.ID];
            
            //Asserting for the results
            system.assertEquals(2, historicalContacts.size());
            String statusConcStr = '';
            //Loop through contact records        
            for(Contact c : historicalContacts) {
                if(c.Site_Profiles__r != null && c.Site_Profiles__r.size() > 0)
                    statusConcStr += c.Site_Profiles__r[0].Status__c;
            }
            
            //Stop test here
            test.stopTest();
            
        } catch(Exception ex) {
            
        }	
        
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update the Eloqua Hard Bounce Email = Contact.Email
     *                  Step 3: Verify the Contact and related Site Profiles are updated with the Status = Hard Bounce
    **/
    private static testMethod void testContactUpdate_HardBounceEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = 'B'+ c.Email,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory };
        insert siteProfiles;
        
        //Start testing from here
        Test.startTest();
        
        //flip these back to false so the trigger_Contact fires
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact
        update c;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, 
             (SELECT Id, Type__c, Username__c, Status__c, Site_User__c FROM Site_Profiles__r) 
             FROM Contact 
             WHERE Id = :c.Id];
        
        //Asserting for the results
        //verify that all site profiles have the Status = Hard Bounce
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            //system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE, sp.Status__c);
        }
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description:     Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                   Step 2: Update the Eloqua Hard Bounce Email = Contact.Email
     *                   Step 3: Verify the Contact and related Site Profiles are updated with the Status = Hard Bounce
     *                   Step 4: Remove the eloqua hard bounce email
     *                   Step 5: Verify the related Site Profiles are updated with Status = In Progress and PW Reset is sent
    **/
    private static testMethod void testContactUpdate_HardBounce_To_Active() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'advisory.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@advisory.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE,
                                                                   Username__c = 'A'+ c.Email,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        //Insert site profiles
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory };
            insert siteProfiles;
        
        //flip these back to false so the trigger_Contact fires
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact
        update c;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email,   
             (SELECT Id, Type__c, Username__c, Status__c, Site_User__c FROM Site_Profiles__r) 
             FROM Contact 
             WHERE Id = :c.Id];
        
        //verify that all site profiles have the Status = Hard Bounce
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            //if (sp.Id == siteProfile_Advisory.Id)
            //system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_HARD_BOUNCE, sp.Status__c);
            /* else if (sp.Id == siteProfile_EAB.Id)
            system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_INACTIVE, sp.Status__c,
            'Site Profile status should remain Inactive because we should never auto-update an inactive Site Profile\'s status.');
            
            */
        }
        
        //Start test from here   
        Test.startTest();
        
        //reset trigger variables
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        
        //Enabling triggers
        Util.BypassAllTriggers = false;
        
        //Update contact
        update c;
        
        //get the contact and related site profiles
        c = [SELECT Id, Site_User__c, Email, 
             (SELECT Id, Type__c, Username__c, Status__c, Site_User__c, Password_Reset_Token__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        //Stop Test here
        Test.stopTest();
        
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added By VH - 02/25/2014 - CR-3003
    /**
     * @description : Method to test out CR-3003 based functionality.
    **/
    static testmethod void testNewAdvUserContact_InstitutionChange_TopParent() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Insert Account
        Account acct_TopParent = TestUtilities.CreateNewAccount(false);
        acct_TopParent.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct_TopParent.Status__c = Constants.ACTIVE;
        acct_TopParent.Name = 'Test Account 1';
        insert acct_TopParent;
        
        //Enabling triggers
        Util.bypassAllTriggers = false;
        
        Account acct_Child = TestUtilities.CreateNewAccount(false);
        acct_child.ParentId = acct_topParent.Id;
        acct_Child.RecordTypeId = Util.RecordTypeId('Account', 'US Corporate');
        acct_Child.Status__c = Constants.ACTIVE;
        acct_Child.Name = 'Test Account 2';
        insert acct_Child;
        
        // get the child acct and make sure the top parent field is populated correctly
        acct_Child = [SELECT Id, ParentId, Top_Parent_Institution__c FROM Account WHERE Id = :acct_Child.Id];
        system.assertEquals(acct_TopParent.Id, acct_Child.Top_Parent_Institution__c);
        
        //Diabling triggers
        Util.bypassAllTriggers = true;
        
        //Insert Eligible Domain
        Eligible_Domain__c domain_TopParent = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'testDomain.com', Account__c = acct_TopParent.Id);
        Eligible_Domain__c domain_Child = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'testDomain.com', Account__c = acct_Child.Id);
        list<Eligible_Domain__c> eligibleDomains = new list<Eligible_Domain__c> { domain_Child, domain_TopParent };
        insert eligibleDomains;
        
        //Insert contact1 and associate it with the child acct
        Contact con1 = TestUtilities.CreateAdvUserContact(acct_Child, false);
        con1.Email = 'con1Test@testDomain.com';
        con1.Title = 'Test';
        con1.Phone = '614-555-8855';
        
        Util.bypassAllTriggers = true;
        insert con1;
        
        //Insert contact2 and associate it with the topParent acct
        Contact con2 = TestUtilities.CreateAdvUserContact(acct_TopParent, false);
        con2.Email = 'con2Test@testDomain.com';
        con2.Title = 'Test';
        con2.Phone = '614-555-8855';
        Util.bypassAllTriggers = true;
        insert con2;
        
        //Test starts from here
        Test.startTest();
        
        //Changing Institution from acct_Child to acct_TopParent
        //This should not throw any exception and contact should be get updated successfully
        con1.AccountId = acct_TopParent.Id;
        
        //Enabling triggers
        Util.bypassAllTriggers = false;
        
        try {
            
            //Update contact record
            update con1;
            
        } catch(Exception e) {
            
            //Assert failed in case of exception
            system.assert(false, e.getMessage());
        }
        
        //Changing Institution from topParent to the Child acct
        con2.AccountId = acct_Child.Id;
        
        //Execute trigger
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Update contact record
        update con2;
        
        //Query to retreive Contact record
        List<Contact> contacts_at_child_acct = [Select Id, OwnerId FROM Contact WHERE AccountId =: acct_Child.Id];
        List<Contact> contacts_at_top_parent_acct = [Select Id, OwnerId FROM Contact WHERE AccountId =: acct_TopParent.Id];
        
        //Assert for results
        system.assert(contacts_at_child_acct != null);
        system.assert(contacts_at_top_parent_acct != null);
        system.assertEquals(1, contacts_at_child_acct.size());
        system.assertEquals(con2.Id, contacts_at_child_acct[0].Id);
        system.assertEquals(1, contacts_at_top_parent_acct.size());
        system.assertEquals(con1.Id, contacts_at_top_parent_acct[0].Id);
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    /**
     * @description : Test Method to test if on deletion of Account all associated children Restriction MtM records will be deleted or not.
    **/
    static testmethod void testDeleteAllRestrcitionMtmFuntionality() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List to hold the contact records
        List<Contact> contacts = new List<Contact>();
        
        // create a contact that will try to be added to the inactive institution first
        Contact con_1 = TestUtilities.CreateNewContact(false);
        con_1.Title = 'Head Honcho';
        con_1.Bypass_Domain_Validation__c = true;
        Contact con_2 = TestUtilities.CreateNewContact(false);
        con_2.Bypass_Domain_Validation__c = true;
        
        //Adding records into the list
        contacts.add(con_1);
        contacts.add(con_2);
        
        
        Util.BypassAllTriggers = false;
        //Insert contacts
        insert contacts;
        
        Util.BypassAllTriggers = true;
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Assert for results
        System.assert(contacts != null);
        System.assertEquals(2, contacts.size());
        
        //Restriction
        Restrictions__c restrict = new Restrictions__c();
        restrict.Category__c = 'Critical Background Information';
        restrict.Expiration_Date__c = system.today().addDays(10);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert restrictions
        insert restrict;
        
        //List Restriction Mtms
        List<Restricted_MtM__c> restrictionMtMs = new List<Restricted_MtM__c>();
        
        //Restriction MtMs
        Restricted_MtM__c rest_1 = new Restricted_MtM__c(Contact__c = contacts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_2 = new Restricted_MtM__c(Contact__c = contacts[0].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_3 = new Restricted_MtM__c(Contact__c = contacts[1].Id, Restriction__c = restrict.Id);
        Restricted_MtM__c rest_4 = new Restricted_MtM__c(Contact__c = contacts[1].Id, Restriction__c = restrict.Id);
        
        //Populating list with the records
        restrictionMtMs.add(rest_1);
        restrictionMtMs.add(rest_2);
        restrictionMtMs.add(rest_3);
        restrictionMtMs.add(rest_4);
        
        //Bypassing all the triggers
        Util.BypassAllTriggers = true;
        
        //Insert restriction
        insert restrictionMtMs;
        
        //Assert for the results
        System.assertEquals(4, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c =: contacts[0].Id];
        System.assert(restrictionMtMs != null);
        System.assertEquals(2, restrictionMtMs.size());
        restrictionMtMs = [SELECT ID FROM Restricted_MtM__c WHERE Contact__c =: contacts[1].Id];
        System.assert(restrictionMtMs != null);
        System.assertEquals(2, restrictionMtMs.size());
        
        //Test start From here
        Test.startTest();
        
        //Setting flag value
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        
        //Delete Accounts
        delete contacts;
        
        //Assert for results
        restrictionMtMs = [Select ID FROM Restricted_MtM__c];
        contacts = [Select ID FROM Contact];
        System.assert(restrictionMtMs != null);
        System.assert(contacts != null);
        System.assertEquals(0, restrictionMtMs.size());
        System.assertEquals(0, contacts.size());
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Modified By - 04/24/2017 - By - Mahendra Swarnakar - updated "testContactSwitchInBetweenInActiveToActiveInstitution" method as per the Run All Test.
    //Modified By - 01/23/2017 - By Mahendra Swarnkar - 1/23/2017 - CR-20160907-10171
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Modified By - Abhinav Sharma - 08/13/2014 - CR-20140604-5691
    /**
     * @description : //This method is to check if switching can take place for a contact record in between inactive institution record to active institution record
    **/
    static testMethod void testContactSwitchInBetweenInActiveToActiveInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        //List to hold the contact record types
        List<RecordType> contactRdTypes = [SELECT ID FROM RecordType 
                                           WHERE DeveloperName = 'External_Advisory_com_User' AND sObjectType = 'Contact' AND IsActive = true];
        
        //Asserting for the results
        System.assert(contactRdTypes != null);
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='ABC Dataloader'];
        System.assert(p != null);
        
        try {
            
            //User
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP', Entity__c = 'EAB',
                              TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');
            
            //Running the test in context of specialist user context
            System.runAs(u) {
                
                //Site profile
                Site_Profile__c sProfile1 = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_ADVISORY, false);
                sProfile1.Bypass_Domain_Validation__c = true;
                
                //Site profile
                Site_Profile__c sProfile2 = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_ADVISORY, false);
                sProfile2.Bypass_Domain_Validation__c = true;
                
                //List of site profiles
                list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile1, sProfile2 };
                    insert sProfiles;
                
                //Retrieving updated information from the database
                sProfiles = [SELECT Id, Bypass_Domain_Validation__c, Contact__r.AccountId, Contact__c 
                             FROM Site_Profile__c WHERE Id IN :sProfiles];
                
                //Asserting for the results
                for (Site_Profile__c sp : sProfiles)
                    system.assertEquals(true, sp.Bypass_Domain_Validation__c);
                
                //List to hold the contact records
                List<Contact> contacts = new List<Contact>();
                
                //Contact Instance
                Contact contact_1 = new Contact(Id = sProfile1.Contact__c);
                contact_1.FirstName = 'Contact';
                contact_1.LastName = 'Record1';
                contact_1.Email = 't1' + sProfile1.Username__c;
                contact_1.Contact_Status__c = 'Active';
                //contact_1.Advisory_com_Preferred_Email_Address__c = 'test2342243434@test.com';
                contact_1.Title = 'Test';
                contact_1.Phone = '614-555-8855';
                
                //Contact Instance
                Contact contact_2 = new Contact(Id = sProfile2.Contact__c);
                contact_2.FirstName = 'Contact';
                contact_2.LastName = 'Record2';
                contact_2.Email = 't2' + sProfile2.Username__c;
                contact_2.Contact_Status__c = 'Active';
                //contact_2.Advisory_com_Preferred_Email_Address__c = 'test23422434884@test.com';
                contact_2.Title = 'Test';
                contact_2.Phone = '614-555-8855';
                
                //Adding records into the list
                contacts.add(contact_1);
                contacts.add(contact_2);
                
                //Insert Accounts
                update contacts;
                
                //Disbaling triggers
                Util.bypassAllTriggers = false;
                
                //Restriction 
                Restrictions__c restriction = new Restrictions__c();
                restriction.Category__c = 'Critical Background Information';
                restriction.Source_Department__c = 'EA';
                restriction.Expiration_Date__c = System.today().addDays(6);
                insert restriction;
                
                //Restriction mTM
                Restricted_MtM__c restrictMTM = new Restricted_MtM__c();
                restrictMTM.Account__c = sProfiles[0].Contact__r.AccountId;
                restrictMTM.Contact__c = sProfiles[1].Contact__c;
                restrictMTM.Restriction__c = restriction.ID;
                
                //Start Test from Here
                Test.startTest();
                
                insert restrictMTM;
                
                //Enabling triggers again
                Util.BypassAllTriggers = false;
                
                //Updating contact record which was associated with Inactive institution
                Util.BypassAllTriggers = false;
                SiteUserHelper.IsTriggerContact = false;
                ContactSiteHelper.hasCheckedInstitutionChange = false;
                ContactSiteHelper.hasBeforeEventLogicGotExecuted = false;
                contacts[0].AccountId = sProfiles[1].Contact__r.AccountId;
                update contacts[0];
                
                //V_1.7 - Modified - 04/24/2017 - By - Mahendra Swarnakar - updated "testContactSwitchInBetweenInActiveToActiveInstitution" method as per the Run All Test.
                //Check for the status field is updatble by the specialist user 
                if(Account.Status__c.getDescribe().isUpdateable()) {
                    
                    //Changing Institution status to "Inactive"
                    Account acct1 = new Account(Id = sProfiles[0].Contact__r.AccountId);
                    acct1.Status__c = 'Inactive - Closed';
                    
                    //Update Accounts
                    update acct1;
                    
                    //Query for the contact records
                    contacts = [SELECT ID, Bypass_Filters__c, FirstName, LastName FROM Contact ORDER BY LastName ASC];
                    System.assert(contacts != null);
                    system.assertEquals(3, contacts.size());
                    
                    //Asserting for results
                    System.assert(!contacts[0].Bypass_Filters__c);
                    System.assert(contacts[1].Bypass_Filters__c);
                    System.assert(!contacts[2].Bypass_Filters__c);
                    System.assertEquals('Record1', contacts[0].LastName);
                    System.assertEquals('Record1', contacts[1].LastName);
                    System.assertEquals('Record2', contacts[2].LastName);    
                } 
                //Stop Test Here
                Test.stopTest();
            }
        }  catch(Exception e) { }    
    }
    
    
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
     * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseFirstName() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting 
        Invalid_Phrase_Characters__c invalidphraseCustomSeting = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                  Object_Name__c = 'Contact', 
                                                                                                  Name = '1');
        insert invalidphraseCustomSeting;
        
        //Create contact record
        Contact contactA = new Contact(FirstName = 'Test2', LastName = 'LastName1',  Email = 'abc@abc.com', Title = 'Test', Phone = '614-555-8855', 
                                       Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Bypass all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test2', contactA.FirstName);
        System.assertEquals('LastName1', contactA.LastName);
        System.assertEquals('abc@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB =new Contact(FirstName = 'Test2', LastName = 'LastNametest2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                      Bypass_Domain_Validation__c = true);
        
        //Making a try to insert the contact recird
        try {
            insert contactB;
        } catch(Exception e){
            system.debug('&&&&&'+ e.getMessage());
            system.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Create contact record
        Contact contactC = new Contact(FirstName = 'Test3', LastName = 'LastName3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', 
                                       Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Insert contact
        insert contactC;
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
     * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhrase_UpdateCase() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting
        List<Invalid_Phrase_Characters__c> invalidPhraseCustomSettingList = new List<Invalid_Phrase_Characters__c>();
        
        //Invaild Phrase Characters record
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_1 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                     Object_Name__c = 'Contact',
                                                                                                     Applicable_For__c = 'FirstName,LastName',
                                                                                                     Name = '1');
        
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_2 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '*', 
                                                                                                     Object_Name__c = 'Contact',
                                                                                                     Applicable_For__c = 'FirstName,LastName,Title,Email',
                                                                                                     Name = '2');        
        
        //Populating list with records
        invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_1);
        invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_2);                                                                                   
        insert invalidPhraseCustomSettingList;
        
        //Create contact record
        Contact contactA = new Contact( FirstName = 'Test', LastName = 'LastName1', Email = 'abc2@abc.com', Phone = '614-555-8855', Title = 'TestTitle2',
                                       Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = false);
        
        //Test starts from here
        Test.startTest();
        
        //Enables the trigger
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test', contactA.FirstName);
        System.assertEquals('LastName1', contactA.LastName);
        System.assertEquals('abc2@abc.com', contactA.Email);
        System.assertEquals('TestTitle2', contactA.Title);
        
        //Update the contact email
        contactA.Title = 'Test*Title2';
        
        try {
            
            //Enables the trigger
            Util.BypassAllTriggers = false;
            
            //Update contact
            update contactA;
            
        } catch(Exception e) {
            System.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
     * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseLastName() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting 
        Invalid_Phrase_Characters__c invalidphraseCustomSeting = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = 'Duplicate', 
                                                                                                  Object_Name__c = 'Contact',
                                                                                                  Applicable_For__c = 'FirstName,LastName,Email,Title', 
                                                                                                  Name = '1');
        insert invalidphraseCustomSeting;
        
        //Create contact record
        Contact contactA = new Contact( FirstName = 'Test', LastName = 'LastNameDuplicate', Email = 'abc@abc.com', Title = 'Test', Phone = '614-555-8855', 
                                       Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        System.assertEquals('Test', contactA.FirstName);
        System.assertEquals('LastNameDuplicate', contactA.LastName);
        System.assertEquals('abc@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB = new Contact(FirstName = 'Test2', LastName = 'LastNameDuplicate', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Bypass_Domain_Validation__c = true);
        
        try{
            insert contactB;
        } catch(Exception e){
            system.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Added - By Mahendra Swarnkar - CR-20150831-9207 - 11/26/2015 
    /**
     * @description : Test methods to test the CR-20150831-9207 based functionality.
    **/
    static testMethod void testvalidateContactFieldsForInvalidPhraseEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting Custom setting
        List<Invalid_Phrase_Characters__c> invalidPhraseCustomSettingList = new List<Invalid_Phrase_Characters__c>();
        
        //Invaild Phrase Characters record
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_1 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '2', 
                                                                                                     Object_Name__c = 'Contact',
                                                                                                     Applicable_For__c = 'FirstName,LastName',
                                                                                                     Name = '1');
        
        Invalid_Phrase_Characters__c invalidphraseCustomSetting_2 = new Invalid_Phrase_Characters__c(Invalid_Phrase__c = '*', 
                                                                                                     Object_Name__c = 'Contact',
                                                                                                     Applicable_For__c = 'FirstName,LastName,Title,Email',
                                                                                                     Name = '2');        
        
        //Populating list with records
        invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_1);
        invalidPhraseCustomSettingList.add(invalidphraseCustomSetting_2);                                                                                   
        insert invalidPhraseCustomSettingList;
        
        //Create contact record
        Contact contactA = new Contact(FirstName = 'Test', LastName = 'LastNameDuplicate', Email = 'abc*@abc.com', Title = 'Test', Phone = '614-555-8855', 
                                       Bypass_Domain_Validation__c = true, Is_Ignore_Phrase_Characters__c = true);
        
        //Test starts from here
        Test.startTest();
        
        //Enable all triggers
        Util.BypassAllTriggers = false;
        
        //Insert contact
        insert contactA;
        
        //Asserts on result
        System.assert(contactA != null);
        system.assertEquals('Test', contactA.FirstName);
        system.assertEquals('LastNameDuplicate', contactA.LastName);
        system.assertEquals('abc*@abc.com', contactA.Email);
        
        //Create contact record
        Contact contactB =new Contact(FirstName = 'Test', LastName = 'LastName', Email = 'abc*abc2@abc.com', 
                                      Bypass_Domain_Validation__c = true, Title = 'Test', Phone = '614-555-8855');
        try {
            //Insert contact
            insert contactB;
        } catch(Exception e){
            System.assertEquals(true, e.getMessage().contains(System.Label.Invalid_Phrase_Error_On_Contact));
        }
        
        //Test Ends here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - CR-20150202-8641 - To refactor the existing code
    //Merged the code from Test_Contact_Restriction_Status class as per the Refactor Release
    /**
     * @description : Test methods to test out the code logic written in Test_Contact_Restriction_Status apex trigger.
    **/
    static testmethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // List to store test Accounts
        List<Account> testAccts = new List<Account>();
        
        // Create a restricted account
        Account a = new Account(
            Name = 'Test Case Account 1',
            Account_Restriction_Status__c = 'Restricted: Permission Required');
        
        //Populating collection with the instance
        testAccts.add(a);
        
        //Account
        Account a1 = new Account(
            Name = 'Test Case Account 2');
        
        //Populating collection with the instance
        testAccts.add(a1);
        
        //Insert account records
        insert testAccts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        System.assert(externalRecordType != null);                                      
        
        // List to store test Contacts
        List<Contact> testContacts = new List<Contact>();
        
        // Create a test Contact
        Contact c = new Contact(accountid = a.id , Lastname = 'toto', recordtypeid = externalRecordType.ID, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        testContacts.add(c);
        
        Contact c1 = new Contact(accountid = a1.id, Lastname = 'toto', recordtypeid = externalRecordType.ID, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        testContacts.add(c1);
        
        //Test Starts From Here
        test.startTest();
        
        //Enable triggers
        Util.byPassAllTriggers = false;
        
        // Insert test Contact
        insert testContacts;
        
        //Test Ends Here
        test.stopTest();
        
        // Requery the Contact to retrive updates
        c = [select id, Contact_Restriction_Status__c from Contact where id = :c.id];
        c1 = [select id, Contact_Restriction_Status__c from Contact where id = :c1.id];
        
        // Assert that the Contacts are restricted or unrestricted based on their account
        //System.assertEquals('Account - Restricted: Permission Required', c.Contact_Restriction_Status__c);
        System.assertEquals(null, c1.Contact_Restriction_Status__c);
        
    }
    
    //Modified By - 01/23/2017 - By Mahendra Swarnkar - 1/23/2017 - CR-20160907-10171
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/08/2019 - #Spring CleanUp
    /** Description : Method to test out various use cases associated with Contact trigger to the delete 
     *                functionality of Mambership Key Contact sfor Inactive Contacts .
    **/
    static testmethod void testdeleteKeyMemberContactsForInActiveContacts() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 4', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added records in list 
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        accounts.add(new Account(Name = 'account 4'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType 
                                         WHERE SobjectType = 'Contact' AND IsActive = true 
                                         AND DeveloperName = 'External' LIMIT 1];
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(accountid = accounts[3].id , Lastname = 'contact 4', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert Contact Data
        insert contacts;
        
        //List to hold membership records
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Added records in list
        memberships.add(new Membership__c(Name = 'Membership 1',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 2',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 3',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Name = 'Membership 4',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        
        //Insert
        insert memberships;
        
        //Create a list of membership records
        List<Membership_Key_Contact__c> membershipKeyContacts = new List<Membership_Key_Contact__c>();
        
        //add record in list
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[0].id, Name='Test 1', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[1].id, Name='Test 2', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 3', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 4', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 5', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[2].id, Name='Test 6', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 7', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        membershipKeyContacts.add(new Membership_Key_Contact__c(Contact__c = contacts[3].id, Name='Test 8', Role_Type__c = 'PT', Role__c = 'Exec Sponsor', Membership__c = memberships[0].Id));
        
        //Insert
        insert membershipKeyContacts;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Query over Contactt
        List<Contact> ContactList = [Select Id,Name From Contact];
        
        //Update
        update contacts;
        
        //Query on Membership Key Contact
        LIst<Membership_Key_Contact__c> memberContactsList= [Select Id, Key_Contact_Status__c From Membership_Key_Contact__c];
        
        //Asserting for the results
        system.assert(memberContactsList != null);
        system.assertEquals(8, memberContactsList.size());
        
        //Loop through membership key contacts
        for(Membership_Key_Contact__c mKC : memberContactsList)
            System.assertEquals('Inactive', mKC.Key_Contact_Status__c);
        
        //Stop Test here
        Test.stopTest();
    }
    
    
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /**
     * Description : Method to test out various use cases associated with Contact trigger to update Syndicated Research Interaction Contact field.
    **/
    // Modified by Mahendra Swarnkar 17-06-2019 CR-20190522-13123
    static testMethod void testPopulateInstitutionLookUpFieldForNPD() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' 
                                         AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        system.assert(externalRecordType != null);                                  
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 4', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact Data
        insert contacts;
        
        //Set to hold the record type names
        Set<String> recordTypeNames = new Set<String>();
        recordTypeNames.add('NPD');
        recordTypeNames.add('Syndicated_Study');
        
        //List to hold recordstype of Syndicated Study
        List<RecordType> recordTypes = new List<RecordType>();
        
        //loop through record types and populating the collection with records
        for(RecordType rType : [Select Id FROM RecordType WHERE sobjectType = 'Syndicated_Study__c'
                                AND DeveloperName IN : recordTypeNames
                                AND IsActive = true]) {
                                    recordTypes.add(rType);
                                }
        
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assertEquals(2, recordTypes.size());
        
        //List to hold the Account records
        List<Syndicated_Study__c> sStudyList = new List<Syndicated_Study__c>();
        
        //Making data for Syndicated Study records
        sStudyList.add(new Syndicated_Study__c(Name = 'Test1', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test1'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test2', GPA__c = '', RecordTypeId = recordTypes[0].Id, Research_Type__c = 'Test2'));
        sStudyList.add(new Syndicated_Study__c(Name = 'Test3', Year__c = '2014', RecordTypeId = recordTypes[1].Id, Research_Type__c = 'Test3'));
        
        //Insert Syndicated study records
        insert sStudyList;
        
        //Asserts for results
        System.assert(sStudyList != null);
        System.assertEquals(3, sStudyList.size());
        
        //Start Test from here
        Test.startTest();
        
        //By pass trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        
        //Update
        update contacts[0];
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        
        //Update
        update contacts[0];
        
        //Set value to update
        contacts[0].Lastname = 'contact test 1';
        
        //Stop Test from here
        Test.stopTest();
        
        //Update
        update contacts[0];
        
        //Added by Saurabh Kumar to increase coverage of deleteOpportunityContactRole method
        contacts[0].Contact_Status__c  = 'Active';
        
        update contacts[0];
        
        contacts[0].Contact_Status__c = 'Inactive - Moved Institutions';
        update contacts[0];
        
    }
    
    //V_1.6 - Modified By - Mahendra Swarnakar - 04/24/2017 - CR-20170118-10625
    //Added by -  Mahendra Swarnkar - 7/16/2016 - CR-20150202-8641 
    /**
     * Description : Method to test out various use cases associated with Contact trigger to update "Contact Restriction Status" filed on Account change.
    **/
    static testMethod void testUpdateRestrictionStatus(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added record in list
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        accounts.add(new Account(Name = 'account 3'));
        
        //V_1.6 - Added By - Mahendra Swarnakar - 04/24/2017 - CR-20170118-10625
        accounts.add(new Account(Name = 'account 4', Account_Restriction_Status__c = 'Restricted: Permission Required'));
        accounts.add(new Account(Name = 'account 5', Account_Restriction_Status__c = 'test'));
        
        //Insert 
        insert accounts;
        
        //Retreiving "External" Record type for Contact object
        RecordType externalRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' 
                                         AND IsActive = true AND DeveloperName = 'External' LIMIT 1];
        
        //Asserts for results
        System.assert(externalRecordType != null);
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[1].id , Lastname = 'contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[2].id , Lastname = 'contact 3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //V_1.6 - Added By - Mahendra Swarnakar - 04/24/2017 - CR-20170118-10625
        contacts.add(new Contact(accountid = accounts[3].id ,Lastname = 'contact 4', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(accountid = accounts[0].id ,Lastname = 'contact 5', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', recordtypeid = externalRecordType.ID, Contact_Status__c = 'Inactive - Moved Institutions', Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact Data
        insert contacts;
        
        //Retreiving "Account Restriction" Record type for Restrictions MtM object
        RecordType accRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' 
                                               AND IsActive = true AND DeveloperName = 'Account_Restriction' LIMIT 1];
        
        //Retreiving "Contact Restriction" Record type for Restrictions MtM object
        RecordType conRestrictionRecordType = [SELECT ID, DeveloperName FROM RecordType WHERE SobjectType = 'Restricted_MtM__c' 
                                               AND IsActive = true AND DeveloperName = 'Contact_Restriction' LIMIT 1];
        
        //Asserts for results
        System.assert(accRestrictionRecordType != null);
        System.assert(conRestrictionRecordType != null);           
        
        //Create record for Restrictions
        Restrictions__c rest1 = new Restrictions__c();
        rest1.Category__c = 'Restricted: Permission Required';
        rest1.Expiration_Date__c = system.today().addDays(10);
        insert rest1;         
        
        //Create record for Restrictions
        Restrictions__c rest2 = new Restrictions__c();
        rest2.Category__c = 'Critical Background Information';
        rest2.Expiration_Date__c = system.today().addDays(10);
        insert rest2;
        
        //Create record for Restricted MtM
        List<Restricted_MtM__c> restrictedMTM = new List<Restricted_MtM__c>();
        
        //Added record in list
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest2.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Restriction_Expired__c = false, Contact__c = contacts[0].Id));
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest1.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[0].Id, Restriction_Expired__c = false, Contact__c = contacts[1].Id));
        restrictedMTM.add(new Restricted_MtM__c(Restriction__c = rest1.Id, RecordTypeId = accRestrictionRecordType.ID, Account__c = accounts[1].Id, Restriction_Expired__c = false, Contact__c = contacts[2].Id));
        
        //Insert records
        insert restrictedMTM;
        
        //Start Test from here
        Test.startTest();
        
        //By pass trigger
        Util.BypassAllTriggers = false;
        Util.BypassContactRestrictionTrigger = false;
        
        //Set value to update
        contacts[0].accountid = accounts[1].Id;
        contacts[1].accountid = accounts[2].Id;
        contacts[4].accountid = accounts[4].Id;
        
        //Update
        update contacts;
        
        //Query on Contact
        List<Contact> contactList = [Select Id from Contact WHERE Contact_Restriction_Status__c =: 'Critical Background Information'];
        
        //Assert for result
        System.assert(contactList != null);
        System.assertEquals(1, contactList.size());
        
        //Query on Contact
        contactList = [Select Id from Contact WHERE Contact_Restriction_Status__c =: 'Restricted: Permission Required'];
        
        //Assert for result
        System.assert(contactList != null);
        System.assertEquals(2, contactList.size());
        
        //V_1.6 - Added By - Mahendra Swarnakar - 04/24/2017 - CR-20170118-10625 - Start from here 
        
        //Query on Contact
        contactList = [Select Id from Contact WHERE Contact_Restriction_Status__c =: 'Account - Restricted: Permission Required'];
        
        //Assert for result
        System.assert(contactList != null);
        System.assertEquals(1, contactList.size());
        
        //Added By - Mahendra Swarnakar - 04/24/2017 - CR-20170118-10625 - Upto here
        //Stop Test from here
        Test.stopTest();
    }
    
    //Added by -  Neha Sharma - 11/24/2020 - CR-20200717-14328
    /** Description : Method to test out various use cases associated with Contact trigger to update "Exclude from Missing Timecards" fieled on Status change.**/
    
    static testMethod void testUpdateContactField(){
        
        //Create restricted accounts
        List<Account> accounts = new List<Account>();
        
        //Added record in list
        accounts.add(new Account(Name = 'account 1'));
        accounts.add(new Account(Name = 'account 2'));
        
        //Insert 
        insert accounts;
        
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(new Contact(accountid = accounts[0].id , Lastname = 'contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-0000', Is_Ignore_Phrase_Characters__c = true,pse__Exclude_From_Missing_Timecards__c = true, Contact_Status__c = 'Inactive'));
        //Insert Contact Data
        
        insert contacts;    
        
        List<Contact> con= [Select Id,pse__Exclude_From_Missing_Timecards__c From Contact where Name = 'contact 1'];
        
        system.assertEquals(false, con[0].pse__Exclude_From_Missing_Timecards__c);  
    }
    
    //Added By - Neha Sharma - 04/13/2021 - CR-20210324-15022
    //Modified by - Chriag Soni - 11/16/2021 - CR-20210930-15474 - test class issue fixes 
    static testMethod void testsyncRegistrationPartnerStatus(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create a user for running the process
        Profile dataloaderProfile = [SELECT Id FROM Profile WHERE Name = 'ABC Dataloader'];
        User dataloaderUser = testUtilities.CreateNewUser(dataloaderProfile, true);
        
        //Get SysAdmin Profile Id
        List<Profile> sysProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Need to run insert of permission set as SystemRunAs due to mixed dml error
        User adminUser = [SELECT Id FROM User WHERE ProfileId = :sysProfile[0].Id AND IsActive = True LIMIT 1];
        
        System.runAs(adminUser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Advisory_Event_Manager'];
            insert new PermissionSetAssignment(AssigneeId = dataloaderUser.Id, PermissionSetId = ps.Id);
        }
        
        System.runAs(dataloaderUser){
            
            
            //Create restricted accounts
            List<Account> accounts = new List<Account>();
            
            //Added record in list
            accounts.add(TestUtilities.CreateNewAccount(false));
            accounts.add(TestUtilities.CreateNewAccount(false));
            
            //Insert 
            insert accounts;
            
            // List to store test Contacts
            List<Contact> contacts = new List<Contact>();
            
            //Add contact data in list
            contacts.add(testUtilities.CreateNewContact(accounts[0], false));
            Contact contWithoutAccount = testUtilities.CreateNewContact(accounts[1], false);
            contWithoutAccount.AccountId = null;        
            contacts.add(contWithoutAccount);
            //Insert Contact Data
            
            insert contacts; 
            
            List<Program__c> programs = new List<Program__c>();
            programs.add(new Program__c(Name = 'testprog1', Program_Acronym__c = 'TEST1', Status__c = 'Active', Create_Memberships__c = 'Yes'));
            programs.add(new Program__c(Name = 'testprog2', Program_Acronym__c = 'TEST2', Status__c = 'Active', Create_Memberships__c = 'Yes'));
            insert programs;
            
            //Modified By - Neha Sharma - CR-20210608-15200 - 08/20/2021 - Test class issue fixes - Start
            List<Opportunity> opportunities = new List<Opportunity>();
            opportunities.add(new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[0].Id,
                                              Amount = 1, CloseDate = System.today(), AccountId = accounts[0].ID, Sales_Pursuit_Products__c = 'APS'));
            
            opportunities.add(new Opportunity(Name = 'Test Opp 1', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[1].Id,
                                              Amount = 1, CloseDate = System.today(), AccountId = accounts[1].ID, Sales_Pursuit_Products__c = 'APS'));
            
            insert opportunities;
            
            //Contract
            List<Contract__c> contracts = new List<Contract__c>();
            contracts.add(new Contract__c(Name='Test1', Payer_Account__c = accounts[0].ID, Program__c = programs[0].Id, 
                                          Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                          Contract_Renewal_Opportunity__c = opportunities[0].Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                          Join_Date__c = System.today(), Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id));
            contracts.add(new Contract__c(Name='Test2', Payer_Account__c = accounts[1].ID, Program__c = programs[1].Id, 
                                          Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                          Contract_Renewal_Opportunity__c = opportunities[1].Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                                          Join_Date__c = System.today(), Main_Contact__c = contacts[1].Id, Invoice_Contact__c = contacts[1].Id));
            
            insert contracts;
            //Added By - Neha Sharma - 08/20/2021 - Test class issue fixes - end
            
            // create two EAB events
            List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
            //Create the new EAB event record
            Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            cohortEvent.Short_Name__c = 'EAB 1';
            cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
            cohortEvent.Primary_Program__c  = programs[1].Id;
            cohortEvent.Rules_Programs__c = 'Establish independent rules';
            eabEvents.add(cohortEvent);
            
            cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
            cohortEvent.Short_Name__c = 'EAB 2';
            cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
            cohortEvent.Primary_Program__c  = programs[0].Id;
            eabEvents.add(cohortEvent);
            
            insert eabEvents;
            
            //Modified By - Neha Sharma - CR-20210608-15200 - 08/20/2021 - Added rules - start
            // create rules
            List<Rule__c> rules = new List<Rule__c>();
            rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[0].Id, Primary__c = true));
            rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[1].Id));
            rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[0].Id));
            rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[1].Id, Primary__c = true));
            
            Insert rules;
            //Modified By - Neha Sharma - 08/20/2021 - Added rules - end
            
            //create Registration
            List<Registration__c> registrations = new List<Registration__c>();
            //for cohort event
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false));
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false));
            //for event
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[0].Id, false));
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[1].Id, false));
            
            insert registrations;
            
            //Bypassing Triggers flag set to false
            Util.byPassAllTriggers = false;
            
            contacts[0].AccountId = accounts[1].Id;
            contacts[1].AccountId = accounts[0].Id;
            
            Update contacts;
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            for(Registration__c reg : registrations){
                // registration whose contact's institute does not have any active membership associated with program so value will be default prospect 
                System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, reg.Partner_Status__c);
            }
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            
            //Create the new Membership records
            List<Membership__c> memberships = new List<Membership__c>();
            memberships.add(new Membership__c(Name = 'Test Membership 1', Account_Name__c = accounts[0].Id,
                                              Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -Payer'));
            memberships.add(new Membership__c(Name = 'Test Membership 2', Account_Name__c = accounts[0].Id,
                                              Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -Payer'));
            Insert memberships;
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = false;
            
            contacts[0].AccountId = accounts[0].Id;
            contacts[1].AccountId = accounts[1].Id;
            
            Test.startTest();
            Update contacts;
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[2].Partner_Status__c);
            
            contacts[0].AccountId = accounts[1].Id;
            update contacts[0];
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after delete
            for(Registration__c reg : registrations){
                // registration whose contact is deleted
                System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, reg.Partner_Status__c);
            }
            
            //Added by - Chriag Soni - 11/16/2021 - CR-20210930-15474 - test class issue fixes - From Here
            //ByPass Flag
            Util.byPassAllTriggers = true;
            Contact contact = testUtilities.CreateNewContact(accounts[1], false);
            insert contact;
            
            //Update Opportunity -
            opportunities[1].Main_Contact__c = contact.Id;
            Update opportunities[1];
            Util.byPassAllTriggers = false;
            
            //Added by - Chriag Soni - 11/16/2021 - CR-20210930-15474 - test class issue fixes - Till Here
            
            //if other than Account is updated on Contact
            contacts[1].Contact_Status__c = 'Inactive - No Activity';
            Update contacts[1];
            
            Test.stopTest();
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after delete
            for(Registration__c reg : registrations){
                // registration whose contact is deleted
                System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, reg.Partner_Status__c);
            }
        }
    }
    
    //Added By - Neha Sharma - 05/09/2022 - Test coverage increase
    static testMethod void testupdateRecordWithContactValues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
         //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 4', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //List of Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccounts1'));
        insert accounts;
        
        Util.ByPassAllTriggers = false; 
		Opportunity Opp = TestUtilities.CreateNewOpportunity(accounts[0].Id, true); 
        Util.ByPassAllTriggers = true; 
        
        List<Contact> conList = [SELECT id, FirstName, LastName, Name FROM Contact WHERE Id =: Opp.Main_Contact__c];
        
        System.assert(true, conList.size() > 0);
        
        //List to hold membership records
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Added records in list
        memberships.add(new Membership__c(Name = 'Membership 1',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id, Active_Renewal_Opportunity__c = opp.Id, Active_Renewal_Opp_Main_Contact_Name__c  = conList[0].Name));
        memberships.add(new Membership__c(Name = 'Membership 2',Account_Name__c = accounts[0].Id, Program__c = programs[0].Id, Active_Renewal_Opportunity__c = opp.Id, Active_Renewal_Opp_Main_Contact_Name__c  = conList[0].Name));
        
        //Insert
        insert memberships;
        
        List<SBQQ__Subscription__c> subscriptionSBQQList = new List<SBQQ__Subscription__c>();
        
        subscriptionSBQQList.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0,
                                      SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                      Status__c = 'Committed', Renewal_Opportunity__c = opp.Id,Renewal_Opportunity_Main_Contact__c = conList[0].Name));
        insert subscriptionSBQQList;
        
        Contract__c contract = new Contract__c(Payer_Account__c = accounts[0].Id ,Main_Contact__c = conList[0].Id, Main_Contact_Name__c = conList[0].Name, Invoice_Contact__c=conList[0].Id, Program__c=programs[0].Id,
                                               Year__c = String.valueof(system.today().year()),Start__c = system.today().addDays(-1),End__c = system.today().addDays(2),Type__c = 'NBB',Negotiated_Amount__c = 1);
        insert contract;
		
        Util.ByPassAllTriggers = false; 
        
        Test.startTest();
        conList[0].FirstName = 'Test Contact -';   
        update conList[0];  

        conList = [SELECT id, Name FROM Contact WHERE Id =: Opp.Main_Contact__c];
        
        List<Opportunity> oppList = [SELECT Id, Main_Contact_Name_Text__c  FROM Opportunity WHERE Id =: opp.Id];
        
        System.assertEquals(conList[0].Name, oppList[0].Main_Contact_Name_Text__c);
        
        List<Membership__c >membershipsList = [SELECT id, Active_Renewal_Opp_Main_Contact_Name__c FROM Membership__c WHERE Id In : memberships];
        System.assertEquals(conList[0].Name, membershipsList[0].Active_Renewal_Opp_Main_Contact_Name__c);
        System.assertEquals(conList[0].Name, membershipsList[1].Active_Renewal_Opp_Main_Contact_Name__c);
        
        List<SBQQ__Subscription__c> subscriptionSBQQList1 = [SELECT id,Renewal_Opportunity_Main_Contact__c FROM SBQQ__Subscription__c WHERE Id IN : subscriptionSBQQList];
        System.assertEquals(conList[0].Name, subscriptionSBQQList1[0].Renewal_Opportunity_Main_Contact__c);
        
        Contract__c contract1 = [SELECT id, Main_Contact_Name__c FROM Contract__c WHERE Id =: contract.Id];
        System.assertEquals(conList[0].Name, contract1.Main_Contact_Name__c);
        
        Test.stopTest();
        
    }

}