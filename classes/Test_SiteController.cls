/**
Desription      :   

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   V1.1 - Created
                :   V1.2 - Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
                :   V1.3 - Modified By - Dipesh Gupta - 08/13/2019 - Fixed the method testSearchInstitution
                :   V1.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
                :   V1.5 - Modified By - Chirag Soni - 08/19/2021 - Commented assert in method testSiteProfileManageSubscriptions_EligibleSubOptions_SiteProfile
                :   V1.6 - Modified By - Subhash Garhwal - CR-20211012-15511
				:   V1.7 - Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Commented references for AdvAdmin_ManageSubscriptions and AdvisorySite vf page 
**/ 
@isTest
private class Test_SiteController {
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    Step 1: Create a Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Execute the 'search' command on the Site_Json VF Page
     *                  Step 3: Verify that the contact is returned
     **/
    static testmethod void testSearchSiteProfiles() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        
        //Site Profile
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get the site profile's contact
        Contact c = [SELECT Id, FirstName, LastName, Email, Primary_City__c, Primary_State_Province__c, Primary_Country__c FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //get the site profile's user id
        sProfile = [SELECT Id, User_Id__c, Type__c FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = c.Email;
        sUser.First_Name = c.FirstName;
        sUser.Last_Name = c.LastName;
        sUser.City = c.Primary_City__c;
        sUser.State = c.Primary_State_Province__c;
        sUser.Country = c.Primary_Country__c;
        sUser.User_Id = Integer.valueOf(sProfile.User_Id__c);
        sUser.Command = 'search';
        sUser.Site = SiteUserHelper.SITE_EAB;
        
        // search for non-inactive site profiles (ie: status = active, in progress, hard bounce)
        sUser.User_Status = 'non-inactive';
        
        //Serailizing site user instance
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        //Start test from here
        Test.startTest();
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        system.debug('@@controller.JSONResponseDecrypted:' + EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse)));
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
                
        //Start test from here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Execute the 'SearchOrganization' command on the SiteProfileSearch VF Page
     *                  Step 3: Verify the correct institution was returned
     **/
    static testMethod void testSearchInstitution() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new institution with state "OH"
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        acct.Primary_State_Province__c = 'OH';
        acct.RecordTypeId = Constants.ACCOUNT_RT_ID_US_EDUCATION;
        insert acct;
        
        // create a siteUser
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        //create the search string
        String searchString = '{"Command":"SearchOrganization","State":"OH"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start testing from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileSearch;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // make sure we found the right contact
        system.assertEquals(1, controller.sUser.Institutions.size());
        system.assertEquals('OH', controller.sUser.Institutions[0].Primary_State_Province__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Execute the 'SearchOrganization' command on the SiteProfileSearch VF Page
     *                  Step 3: Verify the correct institution was returned
     **/
    static testMethod void testSearchInstitution_Contacts() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new institution with state "OH"
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        acct.Primary_State_Province__c = 'OH';
        insert acct;
        
        // create a siteUser
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
        //create the search string
        String searchString = '{"Command":"SearchOrganization","State":"OH"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start test from here
        Test.startTest();
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Commented references for AdvisorySite vf page 
        // set the page reference
        //PageReference pageRef = Page.AdvisorySite;
        //Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // set the institution id
        controller.InstitutionId = string.valueOf(acct.Id);
        controller.FindInstitutionContacts();
        
        // make sure we found the contact
        system.assertEquals(1, controller.sUser.ContactWrappers.size());
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    Step 1: Create an Institution, Contact, Site User, and Site Profile with eligible domain for Advisory.com & EAB.com.
     *                  Step 2: Execute the '' command on the SiteProfileSearch VF Page
     *                  Step 3: Verify the 
     **/
    static testMethod void testAdvAdmin_GeneralInfo() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c 
                        FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        //Start test from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileInfo;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedSearchString);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    step 1) Create an EAB Site Profile
     *                  step 2) Create a Program where Applicable Segment contains "Education" - this ensures it is picked up as an EAB Program
     *                  step 3) Create an active membership and associate that to the EAB program
     *                  step 4) Create Subscription Options and Eligible Subscription Options related to the EAB Program and Subscription Option
     *                  step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     *                  step 6) Verify the eligible subscription options are present.
     * 
     *			Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp
     *                  Modified By - Chirag Soni - 08/19/2021 - Commented assert for countAdvisorySubscriptions because its reference has been commented.
     **/
    static testMethod void testSiteProfileManageSubscriptions_EligibleSubOptions_SiteProfile() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                        Type__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Start test from here
        test.startTest();
        
        //Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
                
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // make sure we found the right subscriptions
        system.assertEquals(false, controller.isGuestUser);
        
        //Stop test here
        test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:    step 1) Create an Advisory Site Profile
     *                  step 2) Create a Program where Applicable Segment does not contains "Education" - this ensures it is picked up as an Advisory Program
     *                  step 3) Create an active membership and associate that to the Advisory program
     *                  step 4) Create Subscription Options and Eligible Subscription Options related to the Advisory Program and Subscription Option
     *                  step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     *                  step 6) Verify the eligible subscription options are present.
     * 
     **/
    static testMethod void testSiteProfileManageSubscriptions_Contact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        //membership
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Start test from here
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // put the contact's id in the parameters
        pageRef.getParameters().put('id', sProfile.Contact__c);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        //Stop test here
        test.stopTest();
        
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /**
     * @description:	step 1) Create an EAB Site Profile
     * 					step 2) Create a Program where Applicable Segment contains "Education" - this ensures it is picked up as an EAB Program
     * 					step 3) Create an active membership and associate that to the EAB program
     * 					step 4) Create Subscription Options and Eligible Subscription Options related to the EAB Program and Subscription Option
     * 					step 5) Instantiate the controller and pass an encrypted string containing the userDetail command + user Id
     * 					step 6) Verify the eligible subscription options are present.
     *
     * Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp
     **/
    static testMethod void testAdvAdmin_ManageSubscriptions_Create() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c 
                    WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        //membership
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Start test from here
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
        
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        
        //Set current page reference
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        SiteController controller = new SiteController();

        // toggle the selection
        controller.TempSubscriptionCreate = true;

        //Stop test here
        test.stopTest();
    }
    
    //Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
    /*
     * Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp
    */
    static testMethod void testAdvAdmin_ManageSubscriptions_Delete() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                    Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Start test from here
        test.startTest();
        
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
                
        //create the search string
        String searchString = '{"Command":"UserDetails","User_Id":"' + sProfile.User_Id__c + '"}';
        String encryptedSearchString = EncryptionHelper.EncryptString(searchString);
        
        // set the page reference
        PageReference pageRef = Page.SiteProfileManageSubscriptions;
        
        // Add the encrypted request parameter to page URL 
        pageRef.getParameters().put('req', encryptedSearchString);
        Test.setCurrentPage(pageRef);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // toggle the selection
        controller.TempSubscriptionCreate = false;
        
        //Stop test here
        test.stopTest();

    }
    
	//Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
	/*
	 * Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp
	 * Modified By - Chirag Soni - CR-20220310-16004 - 04/14/2022 - Commented references for zzzAdvAdmin_ManageSubscriptions vf page 
	*/
    static testMethod void testAdvAdmin_ManageSubscriptions_SubscribeAll() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an EAB.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                        Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        insert prog;
        
        //Membership
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        insert membership;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        //Start test from here
        test.startTest();
        
        //Contract
        Contract__c testContract1 = new Contract__c(
            Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
            Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
            Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
            Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
        insert testContract1;
		        
        //Modified By - Chirag Soni - CR-20220310-16004 - 04/14/2022 - Commented references for zzzAdvAdmin_ManageSubscriptions vf page 
         /*        
        // set the page reference
        PageReference pageRef = Page.AdvAdmin_ManageSubscriptions;
        
        // put the contact's id in the parameters
        pageRef.getParameters().put('id', sProfile.Contact__c);
        Test.setCurrentPage(pageRef);
        */
        
        //Added By - Chirag Soni - CR-20220310-16004 - 4/29/2022 - 
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('id', sProfile.Contact__c);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        
        // subscribe to all TOPIC
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_TOPIC;
        controller.SubscribeAll();
        
        // subscribe to all PRODUCT
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_PRODUCT;
        controller.SubscribeAll();
        
        // subscribe to all BLOG
        controller.SectionName = Sitecontroller.SUBSCRIPTION_CATEGORY_BLOG;
        controller.SectionType = 'EAB.com';
        controller.SubscribeAll();
        
        //Stop test here
        test.stopTest();
        
    }
    /*
     * Code coverage updated - Subhash CR-20211012-15511
     */
    static testMethod void test_showDebugInfo(){
        
        // setup an account and contact
        Account acct = Test_SiteUserHelper.createNewAccount(true);
        
        // instantiate the controller
        Sitecontroller controller = new Sitecontroller();
        //controller.ToggleTempSubscription();
        Boolean data = controller.showDebugInfo;
        
        Test.startTest();
        Sitecore_Settings__c siteSettings = controller.sitecoreSettings;
        String UnsubscribeStatus = controller.UnsubscribeStatus;
        List<Advisory_Twitter_Feed__c> TwitterFeeds = controller.TwitterFeeds;
        map<string, string> categoryToDisplayName = controller.categoryToDisplayName;
        integer countAdvisorySubscriptions = controller.countAdvisorySubscriptions;
        integer countEABSubscriptions = controller.countEABSubscriptions;
        boolean isUpdate = controller.isUpdate;
        
        try{
            controller.str = String.valueOf( Blob.valueOf('1234567890123456') );
            
            PageReference encryptPageRef =  controller.encrypt();
            PageReference decryptPageRef =  controller.decrypt();
        } catch(Exception e){
            System.debug(e.getMessage() + '****' + e.getLineNumber());
        }
        Test.stopTest();
    }
}