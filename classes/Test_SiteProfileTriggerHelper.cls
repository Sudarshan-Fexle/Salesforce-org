/**
Desription      :   

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   v1 - Created
				 	v1.1 - Modified - 11/08/2017 - Rajeev Jain - Too many SOQL Error fix(Rev Mgmt 606 deployment to prod) - Applied by pass trigger flag and Added missed start and stop test flag on testCreateSiteProfile_EmailUpdate_EligibleDomain method
                    v1.2 - Modified - 05/28/2019 - Victor Hanson - CR-20190520-13117 - changed references from E3 to R3 because we allow guest access
**/ 
@isTest
private class Test_SiteProfileTriggerHelper {
    
    /**
     * @description: [ROYALL] Creates a Contact, Site User, Royall Site Profile with a domain that is only eligible on the Institution lookup, 
     *                         but not the Contact's Institution and verifies they can register successfully
     **/
    private static testMethod void createSiteProfile_EligibleDomain_MyRoyall() {
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(true);
        Account eligibleParentAcct = TestUtilities.CreateNewAccount(false);
        eligibleParentAcct.r_School_Id__c = 12332; //VH 8/25/16: school id is required for myRoyall site profile institutions
        insert eligibleParentAcct;
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'royall.com', Account__c = eligibleParentAcct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@royall.com';
        c.Company_Email__c = 'mike@royall.com';
        c.Bypass_Domain_Validation__c = true;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Company_Email__c,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           r_Institution__c = eligibleParentAcct.Id,
                                                           RecordTypeId = Test_SiteProfileActionController.SITE_PROFILE_RT_ID_ROYALL,
                                                           Type__c = SiteUserHelper.SITE_ROYALL);
        
        //record the error message
        string errMessage;
        
        try {
            test.startTest();
            SiteUserHelper.IsTriggerContact = false; //reset this so the code is triggered correctly
            insert site_Profile;
            test.stopTest();
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Royall_com_Site_Profile_Count__c, Site_User__c, (SELECT Id, Type__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(null, errMessage, 'The Site Profile should have been inserted successfully because the RecordType is MyRoyall and the r_Institution__c it is related to has an eligible domain.');
        system.assertEquals(1, c.Royall_com_Site_Profile_Count__c, 'Royall.com Site Profile Count should be 1.');
    }
    
    /**
     * @description: Creates an Contact, Site User, and Site Profile with eligible domain and verifies they can register
     **/
    private static testMethod void testCreateSiteProfile_EligibleDomain() {
        
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Contact__c = c.Id,
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = null,
                                                                   Site_User__c = null,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        test.startTest();
        insert siteProfile_Advisory;
        test.stopTest();
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, 
             (SELECT Id, Type__c, Username__c, Site_User__c, Status_Code__c, Status__c, Password_Reset_Token__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(1, c.Site_Profiles__r.size());
        system.assertNotEquals(null, c.Site_User__c);
        system.assertEquals(c.Site_User__c, c.Site_Profiles__r[0].Site_User__c);
        system.assertNotEquals(null, c.Site_Profiles__r[0].Password_Reset_Token__c);
        system.assertEquals('In Progress', c.Site_Profiles__r[0].Status__c);
        system.assertEquals('R3', c.Site_Profiles__r[0].Status_Code__c);
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, (SELECT Id, Type__c, Username__c, Site_User__c, Site_Profile_Created_By__c, Contact__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(1, c.Site_Profiles__r.size());
        system.assertNotEquals(null, c.Site_User__c);
        
        //verify that each site profile is related to a single Site User associated with the Contact.
        for (Site_Profile__c sProfile : c.Site_Profiles__r) {
            system.assertEquals(userInfo.getName(), sProfile.Site_Profile_Created_By__c, 'Site Profile Created By should always be populated.');
            system.assertEquals(c.Site_User__c, sProfile.Site_User__c);
            system.assertEquals(c.Id, sProfile.Contact__c);
        }
    }
    
    /**
     * @description: bypass all triggers and insert a site profile is inserted via adv.com or eab.com site.
     *              Verify the Site Profile Created By field is populated.
     **/
    private static testMethod void testSiteProfileCreatedBy() {
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@advisory.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Contact__c = c.Id,
                                                                   Username__c = c.Email,
                                                                   Password__c = null,
                                                                   Site_User__c = null,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        test.startTest();
        //bypass triggers to simulate how a site profile is inserted via adv.com or eab.com site
        Util.BypassAllTriggers = true;
        insert siteProfile_Advisory;
        test.stopTest();
        
        siteProfile_Advisory = [SELECT Id, Site_Profile_Created_By__c FROM Site_Profile__c WHERE Id = :siteProfile_Advisory.Id];
        //system.assertEquals(userInfo.getName(), siteProfile_Advisory.Site_Profile_Created_By__c, 'Site Profile Created By should always be populated, even if bypass all triggers is true.');
    }
    
    
    /**
     * @description: 1) Creates an Contact, Site User, and Site Profile with eligible domain
     *               2) Verify the Site User is created and linked to the contact but no password reset should be sent
     **/
    private static testMethod void testCreateSiteProfile_EligibleDomain_DontSendPWReset() {
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Contact__c = c.Id,
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Status__c = SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE,
                                                                   Verify__c = '2',
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        test.startTest();
        insert siteProfile_Advisory;
        test.stopTest();
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, 
             (SELECT Id, Type__c, Username__c, Site_User__c, Status_Code__c, Status__c, Password_Reset_Token__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(1, c.Site_Profiles__r.size());
        system.assertNotEquals(null, c.Site_User__c);
        system.assertEquals(c.Site_User__c, c.Site_Profiles__r[0].Site_User__c);
        system.assertEquals(null, c.Site_Profiles__r[0].Password_Reset_Token__c);
        system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE, c.Site_Profiles__r[0].Status__c);
        system.assertEquals('L2', c.Site_Profiles__r[0].Status_Code__c);
        
      
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, (SELECT Id, Type__c, Username__c, Site_User__c, Contact__c, Password_Reset_Token__c, Status_Code__c, Status__c, Verify__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(1, c.Site_Profiles__r.size());
        system.assertNotEquals(null, c.Site_User__c);
        
        //verify that each site profile is related to a single Site User associated with the Contact.
        for (Site_Profile__c sProfile : c.Site_Profiles__r) {
            system.assertEquals(c.Site_User__c, sProfile.Site_User__c);
            system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_ACTIVE, sProfile.Status__c);
            system.assertEquals('2', sProfile.Verify__c);
            system.assertEquals('L2', sProfile.Status_Code__c);
            system.assertEquals(null, sProfile.Password_Reset_Token__c);
        }
    }
    
    /**
     * @description: Creates a Contact, Site User, and Site Profile with a domain that is not eligible and verifies they cannot register
     **/
    private static testMethod void createSiteProfile_Not_EligibleDomain() {
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@yahoo.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Company_Email__c,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_ADVISORY);
        
        //record the error message
        string errMessage;
        
        try {
            insert site_Profile;
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, (SELECT Id, Type__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        //system.assertEquals(Label.ERROR_SITE_PROFILE_INVALID_DOMAIN, errMessage);
    }
    
    /**
     * @description:    Step 1: Creates an Contact with eligible domain.
     *                  Step 2: Attempt to add a new Site Profile with a domain that is not eligible.
     *                  Step 3: Verify that an error was received due to the non-eligible domain.
     **/
    private static testMethod void updateSiteProfile_Not_EligibleDomain() {
        
        string email_Eligible = 'william@advisory.com';
        string email_Not_Eligible = 'bill@yahoo.com';
        
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = email_Eligible;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = email_Not_Eligible,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_ADVISORY);
        
        //record the error message
        string errMessage;
        
        try {
            insert site_Profile;
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        system.assertEquals(Label.ERROR_SITE_PROFILE_INVALID_DOMAIN, errMessage);
    }
    
    /**
     * @description:    Step 1: Creates an Contact with eligible domain.
     *                  Step 2: Insert a new Site Profile with a different email address with a valid domain.
     *                  Step 3: Verify that a the site profile was created and the contact's email was updated to match the site profile username.
     **/    
    private static testMethod void testCreateSiteProfile_EmailUpdate_EligibleDomain() {
        
        string email_Eligible = 'william@eab.com';
        string email_Eligible2 = 'bill@eab.com';
        
		//Bypass trigger
		Util.ByPassAllTriggers = true;
		
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
		acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
            
		//Bypass trigger
		Util.ByPassAllTriggers = false;
		
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
		//Start Test
		Test.startTest();
		
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = email_Eligible;
        c.Company_Email__c = email_Eligible;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = email_Eligible,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        
        insert site_Profile;
        
        c.Email = email_Eligible2;
        update c;
        
		//Stop Test 
		Test.stopTest();
		
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, (SELECT Id, Type__c, Username__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        system.assertEquals(email_Eligible2, c.Email);
        system.assertEquals(1, c.Site_Profiles__r.size());
        //system.assertEquals(email_Eligible2, c.Site_Profiles__r[0].Username__c);
    }
    
    /**
     * @description:    Step 1: Creates an Contact with eligible domain.
     *                  Step 2: Attempt to add a new Site Profile with Bypass Domain checkbox selected and a domain that is not eligible.
     *                  Step 3: Verify the site profile is inserted successfully and the contact and other site profile all have updated email and bypass domain checked.
     **/
    private static testMethod void testCreateSiteProfile_EmailUpdate_BypassDomain() {
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;

        string email_Eligible = 'william@eab.com';
        string email_Not_Eligible = 'bill@eab.com';
        
        // create account and eligible domain
       	Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = email_Eligible;
        c.Company_Email__c = email_Eligible;
        insert c;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = email_Eligible,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Bypass_Domain_Validation__c = true,
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        
        
        insert site_Profile;
        
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        
        //update the contact's email to a non-eligible domain and check the bypass domain validation checkbox
        c.Email = email_Not_Eligible;
        c.Bypass_Domain_Validation__c = true;
        update c;
        
        //get the contact and all related site profiles
        c = [SELECT Id, Bypass_Domain_Validation__c, Email, (SELECT Id, Username__c, Bypass_Domain_Validation__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        //system.assertEquals(true, c.Bypass_Domain_Validation__c, 
                          //  'Bypass domain validation should have been updated on the contact since it was updated on the related Site Profile');
        //system.assertEquals(c.Site_Profiles__r.size(), 1);
        //system.assertEquals(email_Not_Eligible, c.Site_Profiles__r[0].Username__c);
    }
    
    /**
     * @description:    Step 1: Creates an Contact with eligible domain.
     *                  Step 2: Attempt to add a new Site Profile with Bypass Domain checkbox selected and a domain that is not eligible.
     *                  Step 3: Verify the site profile is inserted successfully and the contact and other site profile all have updated email and bypass domain checked.
     **/
    private static testMethod void testCreateSiteProfile_UpdateBypassDomain() {
        
        //create site profile
        Site_Profile__c sProfile_Advisory = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
       /* Site_Profile__c sProfile_EAB = new Site_Profile__c(Type__c = SiteUserHelper.SITE_EAB,
                                                          Username__c = 'EAB'+ sProfile_Advisory.Username__c,
                                                          Contact__c = sProfile_Advisory.Contact__c);*/
        
        list<Site_Profile__c> sProfiles = new list<Site_Profile__c> { sProfile_Advisory };
        insert sProfiles;
        
        //reset variables
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        SiteUserHelper.IsTriggerContact = false;
        
        Util.BypassAllTriggers = false;
        test.startTest();
        sProfile_Advisory.Bypass_Domain_Validation__c = true;
        update sProfile_Advisory;
        test.stopTest();
        
        //get the contact and all related site profiles
        Contact c = [SELECT Id, Bypass_Domain_Validation__c, Email, (SELECT Id, Username__c, Bypass_Domain_Validation__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :sProfile_Advisory.Contact__c];
        
        system.assertEquals(true, c.Bypass_Domain_Validation__c, 
                            'Bypass domain validation should have been updated on the contact since it was updated on the related Site Profile');
        system.assertEquals(c.Site_Profiles__r.size(), 1);
        
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            system.assertEquals(true, sp.Bypass_Domain_Validation__c, 
                                'Bypass domain validation should have been updated on all related site profiles');
        }
    }
    
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com.
     *                  Step 2: Attempt to insert a new Site Profile related to the same site (Advisory.com) for that contact.
     *                  Step 3: Verify that a the an error was returned because two site profiles for one site cannot be related to the same Contact.
     **/
    private static testMethod void testCreateSiteProfile_Duplicate_Site_Type() {
        
        // create account and eligible domain
       Account acct = TestUtilities.CreateNewAccount(false);
       acct.EAB_com_Organization_Status__c = 'Active';
       insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        
        insert siteProfile_Advisory;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, 
                (SELECT Id, Type__c, Username__c, Site_User__c FROM Site_Profiles__r) 
             FROM Contact WHERE Id = :c.Id];
        
        //Asserting for the results
        system.assertEquals(1, c.Site_Profiles__r.size());
        
        //create a duplicate site profile
        Site_Profile__c siteProfile_ADVISORY_DUPLICATE = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = c.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = null,
                                                           Verify__c = '2',
                                                           Contact__c = c.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        
        //Error message string
        string errMessage;
        
        try {
            insert siteProfile_ADVISORY_DUPLICATE;
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        //asserting for results
        system.assert(errMessage != null);
        system.assert(errMessage.contains(System.Label.ERROR_A_SITE_PROFILE_WITH_SAME_USERNAME_AND_TYPE_ALREADY_EXIST));
    }
    
    /**
     * @description: create 2 contacts with 1 profile for the same Site on each with the same email address and verify that we receive an error
     * 
     **/
    private static testMethod void testCreateSiteProfile_Duplicate_Site_Email() {
        
        
        // create account and eligible domain
       Account acct = TestUtilities.CreateNewAccount(false);
       acct.EAB_com_Organization_Status__c = 'Active';
       insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //create contact 1
        Contact c1 = TestUtilities.CreateNewContact(acct, false);
        c1.Email = 'mike@eab.com';
        c1.Company_Email__c = 'mike@eab.com';
        
        //create contact 2
        Contact c2 = TestUtilities.CreateNewContact(acct, false);
        c2.Email = 'mike@eab.com';
         c2.Company_Email__c = 'mike@eab.com';
        
        list<Contact> contacts = new list<Contact> { c1, c2 };
        insert contacts;
        
        //enabling triggers
        Util.byPassAlltriggers = false;
            
        //create site profile
        Site_Profile__c c1_SiteProfile_Advisory = new Site_Profile__c(Username__c = c1.Company_Email__c,
                                                                       Contact__c = c1.Id,
                                                                       Type__c = SiteUserHelper.SITE_EAB);
        
        insert c1_SiteProfile_Advisory;
        
        //create the duplicate site profile
        Site_Profile__c c2_SiteProfile_Advisory = new Site_Profile__c(Username__c = c2.Company_Email__c,
                                                                       Contact__c = c2.Id,
                                                                       Type__c = SiteUserHelper.SITE_EAB);
        
        //try to insert the duplicate site profile and catcht the error message
        string errMessage;
        
        try {
            insert c2_SiteProfile_Advisory;
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        //get the contact, site user, and site profile
        contacts = [SELECT Id, Site_User__c, Email, 
                        (SELECT Id, Type__c, Username__c, Site_User__c FROM Site_Profiles__r) 
                    FROM Contact 
                    WHERE Id IN :contacts];
        
        //Site Profiles
        Site_Profile__c sp = [SELECT id, Name, Username__c, Contact__c, Contact__r.Name 
                              FROM Site_Profile__c 
                              WHERE Id = :c1_SiteProfile_Advisory.Id];
        
        //Asserting for the results
        system.assertEquals(2, contacts.size());
        
        //Looping through contact records
        for (Contact c : contacts) {
            if (c.Id == c1.Id)
                system.assertEquals(1, c.Site_Profiles__r.size(),
                                   '1 site profile should have been generated.');
            else if (c.Id == c2.Id)
                system.assertEquals(0, c.Site_Profiles__r.size(),
                                   'This site profile was a duplicate and should not have been created.');
        }
        
        //asserting for results
        system.assert(errMessage != null);
        system.assert(errMessage.contains(System.Label.ERROR_A_SITE_PROFILE_WITH_SAME_USERNAME_AND_TYPE_ALREADY_EXIST));
    }
    
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update one Site Profile username
     *                  Step 3: Verify that an error is thrown because username on the Site Profile should not be editable
     **/
    private static testMethod void testUpdateSiteProfileUsername() {
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
         c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        
        test.startTest();
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory };
        
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        insert siteProfiles;
        
        //update the Site Profile's Email address
        siteProfile_Advisory.Username__c = 'newemail@advisory.com';
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        
        SiteUserHelper.IsTriggerContact = false;
        
        string errMessage;
        try {
            update siteProfile_Advisory;
        }
        catch(DMLException e) {
            errMessage = e.getDMLMessage(0);
        }
        catch(Exception e) {
            errMessage = e.getMessage();
        }
        
        test.stopTest();
        
        system.assertNotEquals(null, errMessage, 'The Site Profile\'s username was changed directly, which should have thrown an error.');
        
        //get the contact record
        c = [SELECT Id,/* Advisory_com_Site_Profile_Count__c , */EAB_com_Site_Profile_Count__c FROM Contact WHERE Id = :c.Id];
        //system.assertEquals(1, c.EAB_com_Site_Profile_Count__c);
        
        //delete one of the site profiles
        delete siteProfile_Advisory;
        
        //verify the site profile count on the contact was updated
        c = [SELECT Id,/* Advisory_com_Site_Profile_Count__c,*/ EAB_com_Site_Profile_Count__c FROM Contact WHERE Id = :c.Id];
        //system.assertEquals(0, c.EAB_com_Site_Profile_Count__c);
    }
    
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update the Contact's Email
     *                  Step 3: Verify that the related Site Profiles are also updated with the new Username (ie: Contact's email).
     **/
    private static testMethod void testUpdateContactEmail() {
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory};
        insert siteProfiles;
        
        //update the Contact's Email address
        c.Email = 'newemail@eab.com';
        
        //flip these back to false so the trigger_Contact fires
        Util.BypassAllTriggers = false;
        SiteUserHelper.IsTriggerContact = false;
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        update c;
        
        //get the contact, site user, and site profile
        c = [SELECT Id, Site_User__c, Email, Company_Email__c, (SELECT Id, Type__c, Username__c, Site_User__c FROM Site_Profiles__r) FROM Contact WHERE Id = :c.Id];
        
        //verify that all site profiles have the new username
        for (Site_Profile__c sp : c.Site_Profiles__r) {
            system.assertEquals(c.Company_Email__c, sp.Username__c);
        }
    }
    
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update the Contact's Email with an invalid domain
     *                  Step 3: Verify that an error is returned
     **/
    private static testMethod void testUpdateContactEmail_InvalidDomain() {
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create account and eligible domain
       
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory };
        insert siteProfiles;
        
        //Start Test from Here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        //update the Site Profile's Email address
        c.Email = 'newemail@invaliddomain.com';
        
        string errMsg;
        try {
            //flip these back to false so the trigger_Contact fires
            Util.BypassAllTriggers = false;
            SiteUserHelper.IsTriggerContact = false;
            SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
            SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
            update c;
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();
        }
        
        //Start Test from Here
        Test.stopTest();
        
        //verify that an error was returned
        //system.assertNotEquals(null, errMsg);
    }
    
    /**
     * @description:    Step 1: Create an Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Update the Site Profile's Username with an invalid domain
     *                  Step 3: Verify that an error is returned
     **/
    private static testMethod void testUpdateSiteProfileUsername_InvalidDomain() {
        
        // create account and eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
          
        //create contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'mike@eab.com';
        c.Company_Email__c = 'mike@eab.com';
        insert c;
        
        //create Advisory.com site profile
        Site_Profile__c siteProfile_Advisory = new Site_Profile__c(Status__c = 'Active',
                                                                   Username__c = c.Company_Email__c,
                                                                   Password__c = 'test',
                                                                   Site_User__c = null,
                                                                   Verify__c = '2',
                                                                   Contact__c = c.Id,
                                                                   Type__c = SiteUserHelper.SITE_EAB);
        
        list<Site_Profile__c> siteProfiles = new list<Site_Profile__c> { siteProfile_Advisory };
        insert siteProfiles;
        
        string errMsg;
        try {
            SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
            SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
            update siteProfile_Advisory;
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();
        }
    }
    
    /**
     * @description:    Step 1: Create an Institution with Organization Status = inactive
     *                  Step 2: Create a Site Profile related to the Contact
     *                  Step 3: Verify the site profile is created with Status Code = R3
    **/
    static testmethod void newSiteProfile_Status_R3() {
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        insert acct;
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        // create a site profile
        Site_Profile__c sp = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        //make the account's organization status inactive
        acct.EAB_com_Organization_Status__c = 'inactive';
        update acct;
        
        //remove the password reset token from the site profile so we can verify that it wasn't added back in later
        sp.Password_Reset_Token__c = null;
        update sp;
        
        //send a password reset - this should return an error and update the status code to E3
        SiteUser sUser = new SiteUser();
        sUser.Username = sp.Username__c;
        sUser.Site = sp.Type__c;
        sUser.Command = 'sendPasswordResetEmail';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);

        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        // deserialize the response
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // make sure the returned string is correct
        //system.assertEquals('Organization Status Inactive(response TBD)', sUser.Response);
        system.assertEquals('L1', sUser.Status_Code);
        system.assertEquals('Success', sUser.Response);
        
        //get the updated site profile
        sp = [SELECT Id, Status_Code__c, Password_Reset_Token__c FROM Site_Profile__c WHERE Id = :sp.Id];
        
        system.assertEquals('L1', sp.Status_Code__c);
        system.assertNotEquals(null, sp.Password_Reset_Token__c,
                           'The password reset token should be populated.');
    }
    
    /**
     * @description:    Step 1: Create an Institution and Site Profile
     *                  Step 2: Update Institution Organization Status to Inactive
     *                  Step 3: Attempt to login & Verify E3 is returned
    **/
    static testmethod void newSiteProfile_InactiveOrgStatus_Login_R3() {
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        insert acct;
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        // create a site profile
        Site_Profile__c sp = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        
        //make the account's organization status inactive
        acct.Advisory_com_Organization_Status__c = 'inactive';
        update acct;
        
        //send a password reset - this should return an error and update the status code to R3
        SiteUser sUser = new SiteUser();
        sUser.Username = sp.Username__c;
        sUser.Password = sp.Password__c;
        sUser.Site = sp.Type__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);

        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        // deserialize the response
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // make sure the returned string is correct
        system.assertEquals('L1', sUser.Status_Code);
        system.assertEquals('Success', sUser.Response);
        
        //get the updated site profile
        sp = [SELECT Id, Status_Code__c, Last_Access__c FROM Site_Profile__c WHERE Id = :sp.Id];
        
        system.assertEquals('L1', sp.Status_Code__c);
        system.assertNotEquals(null, sp.Last_Access__c,
                           'The Last Access date should be populated because this was a successful login.');
    }
    
    /**
     * @description:    Step 1: Create an Institution with Organization Status = inactive
     *                  Step 2: Attempt to create a site profile associated with a contact on that institution
     *                  Step 3: Verify an error is returned when attempting to insert
    **/
    static testmethod void newSiteProfile_Inactive_Org_Status() {
        
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        acct.Advisory_com_Organization_Status__c = 'inactive';
        insert acct;
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        string errorMessage;
        try {
            // create a site profile
            Site_Profile__c sp = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_ADVISORY, true);
        }
        catch(exception ex) {
            errorMessage = ex.getMessage();
        }
        
        system.assertEquals(null, errorMessage);
        //system.assertEquals(true, errorMessage.containsIgnoreCase('Organization Status must be active to create a Site Profile'));
    }
    
    /**
     * @description:    Step 1: Create an Institution, Contact, and Site Profile
     *                  Step 2: Create a Site Profile related to the Contact
     *                  Step 3: Verify the site profile is created with Status Code = R3
    **/
    static testmethod void testNewSiteProfile_Status_R3() {
        
        // create a site profile
        Site_Profile__c sp = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
        sp.Verify__c = null;
        sp.Status__c = null;
        sp.Password__c = null;
        insert sp;
        
        //get the updated site profile
        sp = [SELECT Id, Status_Code__c, Status__c FROM Site_Profile__c WHERE Id = :sp.Id];
        
        system.assertEquals('L1', sp.Status_Code__c);
        system.assertEquals('In Progress', sp.Status__c);
    }
    
    /**
     * @description:    Step 1: Create an Institution, Contact, and Site Profile
     *                  Step 2: Create a Site Profile related to the Contact and Login - verify the status code is updated
     *                  Step 3: Verify the site profile is created with Status Code = R3
    **/
    static testmethod void testNewSiteProfile_Status_R3_to_L2() {
        
        // create a site profile
        Site_Profile__c siteProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Verify__c = null;
        siteProfile.Status__c = null;
        siteProfile.Password__c = null;
        insert siteProfile;
        
        //get the updated site profile
        siteProfile = [SELECT Id, Status_Code__c, Type__c, Username__c, Password__c, User_Id__c FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        //system.assertEquals('R3', siteProfile.Status_Code__c);
        
        //simulate an updateUser call to update the password
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = 'testPassword';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        SiteProfileTriggerHelper.bypassSiteProfileTrigger = false;
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        system.assertEquals('Success', controller.sUser.Response);
        
        //get the updated site profile
        siteProfile = [SELECT Id, Status_Code__c, Type__c, Username__c, Password__c, User_Id__c FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        //system.assertEquals('L2', siteProfile.Status_Code__c);
    }
    
    /**
     * @description:    simulate importing site profiles in mass. Verify the site profile gets setup properly even in a mass import scenario.
     **/
    static testmethod void massInsertSiteProfiles() {
        // create the account & eligible domain
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        insert acct;
        	
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //create & insert account & contact
        Contact con1 = TestUtilities.CreateNewContact(acct, false);
        con1.Email = 'testUser1@eab.com';
        con1.Company_Email__c = 'testUser1@eab.com';
        
        Contact con2 = TestUtilities.CreateNewContact(acct, false);
        con2.Email = 'testUser2@eab.com';
        con2.Company_Email__c = 'testUser2@eab.com';
        
        Contact con3 = TestUtilities.CreateNewContact(acct, false);
        con3.Email = 'testUser3@eab.com';
        con3.Company_Email__c = 'testUser3@eab.com';
        
        list<Contact> contactsToInsert = new list<Contact>{ con1, con2, con3 };
        insert contactsToInsert;
            
        test.startTest();
        //Change the Type from advisory.com to eab.com due to the production failure of -
        //ERROR - Please select a compatible site type. HC users can't select 'EAB.com' and EAB/Royall users can't select 'Advisory.com'.: [Type__c] 
        //create & inset the site profile
        Site_Profile__c sProfile1 = new Site_Profile__c(Contact__c = con1.Id,
                                                      Username__c = con1.Company_Email__c,
                                                      Type__c = SiteUserHelper.SITE_EAB);
        Site_Profile__c sProfile2 = new Site_Profile__c(Contact__c = con2.Id,
                                                      Username__c = con2.Company_Email__c,
                                                      Type__c = SiteUserHelper.SITE_EAB);
        Site_Profile__c sProfile3 = new Site_Profile__c(Contact__c = con3.Id,
                                                      Username__c = con3.Company_Email__c,
                                                      Type__c = SiteUserHelper.SITE_EAB);
        list<Site_Profile__c> sProfilesToInsert = new list<Site_Profile__c>{ sProfile1, sProfile2, sProfile3 };
        insert sProfilesToInsert;
        test.stopTest();
        
        list<Contact> contacts = [SELECT Id, Site_User__c, (SELECT Id, Site_User__c, Verify__c, Password_Reset_Token__c, Status__c FROM Site_Profiles__r) FROM Contact WHERE Id IN :contactsToInsert];
        for (Contact con : contacts) {
            system.assertEquals(con.Site_User__c, con.Site_Profiles__r[0].Site_User__c,
                                'Contact and Site Profile should share the same Site User');
            system.assertNotEquals(null, con.Site_Profiles__r[0].Password_Reset_Token__c,
                                   'Password reset token should be populated');
            system.assertEquals('1', con.Site_Profiles__r[0].Verify__c);
            system.assertEquals(SiteProfileTriggerHelper.SITE_PROFILE_STATUS_IN_PROGRESS, con.Site_Profiles__r[0].Status__c);
        }
    }
}