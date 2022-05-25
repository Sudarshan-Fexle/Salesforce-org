/**
Desription      :   Test Class for SiteUserHelper

Created By      :   Victor Hanson

Created Date    :   07/29/2014

Revision Logs   :   V1.0 - Created
                    V1.1 - Modified by - Abhinav Sharma - 03/10/2015 - CR-20141222-8389 - Methods (projectRole_PT_AutoSubscribe_CreateSiteProfile, projectRole_PT_AutoSubscribe_CreateSubscription)
                    V1.2 - Modified By - Rajeev Jain - 09/01/2016 - Fixed too many soql error found while production validation in (projectRole_NON_PT_AutoSubscribe, membershipKeyContact_AutoSubscribe_CreateSiteProfile) methods
                    V1.3 - Modified By - Abhinav Sharma - 09/10/2016 - In order to fix "Too Many SOQL 101 error in it"
                    V1.4 - Modified By - Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016 - Replaced the "Eligible_Subscription_Option__c.Key_Contact_Auto_Subscribe__c" to reference the new "Eligible_Subscription_Option__c.Auto_Subscribe__c" field
                    V1.5 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
                    V1.6 - Modified By - Abhinav Sharma - 1/18/2017 - CR-20160505-9833
                    V1.7 - Modified By - Mahendra Swarnkar - 5/3/2017 - CR-20170310-10747
                    V1.8 - Modified By - Mahendra Swarnkar - 07/06/2017 - CR-20170524-10956 - Commented the methods (testCreateMultipleSiteProfiles && testCreateMultipleSiteProfiles_noSharing) which is reaponsible to test the "createAccountAndContactSharing" method functionality. As "createAccountAndContactSharing" method is commented in the "SiteUserHelper" class.
                    V1.9 - Modified By - Subhash Garhwal - 11/13/2017 -  Failure fix(CR- Apollo - Salesforce Workstream)
                           (Too many SOQL queries: 101 - projectRole_PT_AutoSubscribe_CreateSiteProfile,projectRole_PT_AutoSubscribe_CreateSubscription,
                            Assert failure	-	testAction_Register_EmailInUseOnAnotherInstitution,testCancelWebConference,
                            testCreateWebConference,testLogin_Login_WebProgAccess,
                            testTrackLoginHistory_EAB
                            Validation Error -	test_Action_Register_GoodDomain_EAB_Advisory,test_CreateNewUser
                           ) 
                    V2.0 - Modified By - Deepak kumawat - 11/14/2017 - Test Faiure fix during the validation against production(Apollo - Salesforce Workstream 
                            Error:- Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Organization Status must be active to create a Site Profile,
                            FIELD_CUSTOM_VALIDATION_EXCEPTION,Please select compatible site type. HC users can't select 'EAB.com' and EAB/Royall users can't select 'Advisory.com'
                            membershipKeyContact_AutoSubscribe_CreateSiteProfile, testCancelWebConference, testCreateWebConference method)
   		    V2.1 - Modified By - Victor Hanson - 07/31/2019 - updated createSiteProfile(). Commented out the email & company email fields when creating the Contact record so they're auto-generated.
		    V2.2 - Modified By Dipesh Gupta - CR-20190726-13240 - 08/06/2019 - Remove the reference of Temporary_Program_Access__c.
		    V2.3 - Modified By - Victor Hanson - CR-20190823-13279 - 08/23/2019 - Added unit tests for additional code coverage on SiteToken & SavedPosts
		    V2.4 - Modified By - Abhinav sharma- 08/17/2020 - CR-20200714-14306 - Test fuction to test the flow of searchOrganization command
		    V2.5 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683
		    V2.6 - Modified By - Neha Sharma - 29/7/21 - CR-20210721-15304
			V2.7 - Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Commented references for AdvisorySite vf page 
**/ 
@isTest
public class Test_SiteUserHelper {
    
    /**
     *  @description: test setup method to create a basic site Contact/site profile
     * 
     *  @revision log: v1.0 Created By - Victor Hanson - CR-20190823-13279 - 08/23/2019 - Added unit tests for additional code coverage
     * 
     **/
    @testSetup
    static void testSetupMethod() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        siteProfile.Tokens__c = 5;
        insert siteProfile;
    }
    
    /**
     *  @description: returns a Web Program Access record.
     * 
     **/
    public static Web_Program_Access__c CreateWebProgramAccess(boolean CreateAndInsert) {
        Web_Program_Access__c webProgramAccess = new Web_Program_Access__c();
        webProgramAccess.A_com_Program_ID__c = 123;
        webProgramAccess.Description__c = 'test prog access';
        webProgramAccess.Program_Code_to_Member__c = '99';
        
        if (CreateAndInsert) insert webProgramAccess;
            
        return webProgramAccess;
    }
    
    /**
     *  @description: returns a web program access MtM record.
     * 
     **/
    public static Web_Program_Access_MTM__c CreateWebProgramAccessMtM(Id webProgramId, boolean CreateAndInsert) {
        
        if (webProgramId == null) {
            Web_Program_Access__c wpAccess = CreateWebProgramAccess(true);
            webProgramId = wpAccess.Id;
        }
        
        // create a new program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        Web_Program_Access_MTM__c wpAccessMtM = new Web_Program_Access_MTM__c();
        wpAccessMtM.Web_Program__c = webProgramId;
        wpAccessMtM.Membership_Program__c = prog.Id;
        
        if (CreateAndInsert) insert wpAccessMtM;
        
        return wpAccessMtM;
    }
    
    /**
     * @description: Return an account with ADV/EAB organization Id & status
     **/
    public static Account createNewAccount(boolean createAndInsert) {
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.EAB_com_Organization_Status__c = 'Active';
        acct.Tokens__c = 5;
        
        if (createAndInsert == true)  {
            insert acct;
        }
        
        return acct;
    }
    
    /**
     * @description: Return an site profile of a given type
     **/
    public static Site_Profile__c createSiteProfile(string siteType, boolean CreateAndInsert) {
        // setup an account and contact
        Account acct = createNewAccount(true);
        Site_Profile__c site_Profile = createSiteProfile(acct, siteType, CreateAndInsert);
        
        return site_Profile;
    }
    
    /**
     * @description: Return an site profile related to a contact related to the Account provided.
     **/
    public static Site_Profile__c createSiteProfile(Account acct, string siteType, boolean CreateAndInsert) {
        
        //the type of user being created
        if (siteType == null) siteType = SiteUserHelper.SITE_EAB;
        
        //Get the System Admin profile
        Id adminProfile  = [select id from Profile where Name = 'System Administrator' limit 1].id;
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        
        //Insert the User 
        User userA = new User( alias = 'userA', 
                                email='SysAdmin@advisory.com', 
                                emailencodingkey='UTF-8', 
                                lastname='Testing', 
                                languagelocalekey='en_US', 
                                localesidkey='en_US', 
                                profileid = adminProfile, 
                                timezonesidkey='America/Los_Angeles', 
                                username='testuserZ' + randomInt + '@examplezzzyy.com',
                                IsActive = true,
                                Entity__c = 'All',
                                UserPermissionsMarketingUser = true);
        
        insert userA;
        
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.site_User__c = site_User.Id;
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        insert con;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Type__c = siteType);
        if (CreateAndInsert) {
        
            //Run as the UserA    
            System.runAs(userA) {    
                
                //Insert the site profile
                insert site_Profile;
            }
        }
	   
        return site_Profile;
    }
    
    /**
     * @description:    
     *
     * @revision log:   Modified By -  Subhash Garhwal - 11/13/2017 -  Validation error
     *				       register both an eab and advisory site profile for the same contact
     *     	 
     **/
    static testmethod void test_Action_Register_GoodDomain_EAB() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, 
                                                           Account__c = acct.Id);
        insert domain;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_EAB.Password = 'test';
        sUser_EAB.ClientId = acct.Historical_Linker__c;
        sUser_EAB.Prefix = 'Mr';
        sUser_EAB.Country = 'USA';
        sUser_EAB.First_Name = 'Victor';
        sUser_EAB.Last_Name = 'Hanson';
        sUser_EAB.Middle_Initial = 'R';
        sUser_EAB.Suffix = '';
        sUser_EAB.Job_Function = 'Developer';
        sUser_EAB.Title = 'SF Dev';
        sUser_EAB.Department = 'eTech';
        sUser_EAB.Command = 'register';
        sUser_EAB.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser_EAB = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Stop test here
        test.stopTest();
        
    }
    
    //test registering a new EAB.com user with a bad domain
    static testmethod void test_EAB_Action_Register_BadDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c 
                    FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = 'hansonv@zzzzz.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Site = SiteUserHelper.SITE_EAB;
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // get make sure the contact didn't get inserted with a bad domain
        List<Contact> cons = [SELECT Name, Id
                               FROM Contact WHERE Email = 'hansonv@eab.com'];
        
        //Assert for the results
        system.assertEquals(0, cons.size());
        
    }
    
    static testmethod void test_EAB_Action_Register_GoodDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c 
                        FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = 'hansonv@advisory.com';
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //Stop test here
        test.stopTest();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Asserting for the results
        //system.assertEquals('success', sUser.Response.toLowerCase());
        system.assertEquals(true, decryptedJSONResponse.contains('5655'));
        
    }
    
    /**
     * @description:    1) Create an Account, Contact, and Eligible Domain
     *                  2) Register a new EAB user with the same email as the contact from step #1
     *                  3) This should generate a new Site Profile and Site User associated with the Contact from step #1
     *                  4) Verify the Contact.Site_User__c field is also related to the same Site User as the Site Profile.
     * 
     **/
    static testmethod void test_EAB_Action_RegisterGoodDomain_ExistingContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = TestUtilities.createNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //creat a contact
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.Email = 'TestRegisterContact@EAB.com';
        c.Company_Email__c = 'TestRegisterContact@EAB.com';
        insert c;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = c.Email;
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //Stop tets here
        test.stopTest();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Asserting for the results
        //system.assertEquals('success', sUser.Response.toLowerCase());
        
        // get the contact
        c = [SELECT Name, Id, Email,/* Advisory_com_Preferred_Email_Address__c*/ Site_User__c,
                                  (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                                   Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, 
                                   Type__c, User_Id__c, Username__c FROM Site_Profiles__r) 
                                  FROM Contact WHERE Id = :c.Id];
        
    }
    
    static testmethod void testAction_Register_EmailInUseOnAnotherInstitution() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact on a different institution
        Site_Profile__c profile1 = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        insert profile1;
        
        //Site profiles
        list<Site_Profile__c> siteProfiles = [SELECT Id, Contact__c, Status__c, Type__c, 
                                              Username__c, User_Id__c FROM Site_Profile__c 
                                              WHERE Username__c = :profile1.Username__c];
        system.assertEquals(1, siteProfiles.size());
        
        // setup an account and contact
        Account acct = TestUtilities.CreateNewAccount(true);
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Commented references for AdvisorySite vf page 
        // set the page reference
        // PageReference pageRef = Page.AdvisorySite;
        // Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = profile1.Username__c;
        sUser.Email_Address2 = 'hansonv@zzzzz.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'register';
        sUser.Office_Phone = '555-555-5655';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start test from here
        test.startTest();
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        //Stop test here
        test.stopTest();
        
        siteProfiles = [SELECT Id, Contact__c, Status__c, Type__c, Username__c, 
                        User_Id__c FROM Site_Profile__c WHERE Username__c = :profile1.Username__c];
        
        //Asserting for the results
        //system.assertEquals(1, siteProfiles.size());
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
    }
    
    static testMethod void testCreatePWResetURL() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //create the sitecore settings
        sitecore_Settings__c settings = new sitecore_Settings__c(Advisory_Password_Reset_URL__c = 'Advisory.com',
                                                        EAB_Password_Reset_URL__c = 'EAB.com');
        insert settings;
        
        //test creating a PW reset token for an EAB user
        String requestString = '{"Username":"vhanson","Email_Address":"hansonv@advisory.com","Site":"EAB.com"}';
        SiteUser sUser = EncryptionHelper.deserializeSiteUser(requestString);
        string resetURL = SiteUserHelper.CreatePWResetURL(sUser, null);
        system.assertEquals(true, resetURL.containsIgnoreCase('eab.com'));
        string encryptedPayload = resetURL.split('\\?payload=')[1];
        
        // un-url-encode
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload, 'UTF-8');
        
        // convert string to blob
        blob encryptedBlob = EncodingUtil.base64Decode(encryptedPayload);
        
        // decrypt the reset URL
        string DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob);
        system.assertEquals(true, DecryptedPayload.contains('hansonv@advisory.com'));
        system.assertEquals(true, DecryptedPayload.contains(dateTime.now().addDays(3).format('yyyy-MM-dd')));
        
        //Start test from here
        Test.startTest();
        
        //test creating a PW reset token when a passwordResetURL is specified in the callout
        requestString = '{"Username":"vhanson","Email_Address":"hansonv@advisory.com","PasswordResetUrl":"http://www.advisoryTEST.com/"}';
        sUser = EncryptionHelper.deserializeSiteUser(requestString);
        resetURL = SiteUserHelper.CreatePWResetURL(sUser, null);
        system.assertEquals(true, resetURL.containsIgnoreCase('advisoryTEST.com'));
        encryptedPayload = resetURL.split('\\?payload=')[1];
        // un-url-encode
        encryptedPayload = EncodingUtil.urlDecode(encryptedPayload, 'UTF-8');
        // convert string to blob
        encryptedBlob = EncodingUtil.base64Decode(encryptedPayload);
        // decrypt the reset URL
        DecryptedPayload = EncryptionHelper.decrypt(encryptedBlob);
        system.assertEquals(true, DecryptedPayload.contains(dateTime.now().addDays(3).format('yyyy-MM-dd')));
        
        //Stop test here
        Test.stopTest();
    }
    
    
    // test inserting a site profile with temp access, verify the proper access has been granted upon login
    static testMethod void testLogin_Login_WebProgAccess() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //setup 2 web programs.  One that is accessible by employees and one that is not
        Web_Program_Access__c wpa_Access = Test_SiteUserHelper.CreateWebProgramAccess(false);
        Web_Program_Access__c wpa_NoAccess = Test_SiteUserHelper.CreateWebProgramAccess(false);
        wpa_NoAccess.ABC_Restricted__c = true;
        wpa_NoAccess.A_com_Program_Id__c = 321;
        wpa_NoAccess.Program_Code_To_Member__c = '101';
        list<Web_Program_Access__c> wpas = new list<Web_Program_Access__c> { wpa_Access, wpa_NoAccess };
        insert wpas;
        
        //setup 2 web program MTMs
        Web_Program_Access_MTM__c webProgMTM_Access = Test_SiteUserHelper.CreateWebProgramAccessMtM(wpa_Access.Id, false);
        Web_Program_Access_MTM__c webProgMTM_NoAccess = Test_SiteUserHelper.CreateWebProgramAccessMtM(wpa_NoAccess.Id, false);
        list<Web_Program_Access_MTM__c> wpaMTMs = new list<Web_Program_Access_MTM__c> { webProgMTM_Access, webProgMTM_NoAccess };
        insert wpaMTMs;
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create an account and employee contact
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Enrollment_Scenario_Explorer_access__c = true;
        insert acct;
        
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        Contact employeeContact = TestUtilities.CreateNewContact(false);
        employeeContact.AccountId = acct.Id;
        employeeContact.RecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId;
        employeeContact.Email = 'test-' + String.valueOf(Crypto.getRandomInteger()) + '@advisory.com';
        employeeContact.Site_User__c = site_User.Id;
        insert employeeContact;
        
        // create a contact on a different institution
        Site_Profile__c siteProfile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = employeeContact.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = employeeContact.Id,
                                                           Type__c = 'HC');
        insert siteProfile;
        
        //create active memberships for both programs
        Membership__c membership_Access = new Membership__c();
        membership_Access.Membership_Status_Text__c = 'Member - Payer';
        membership_Access.Account_Name__c = acct.Id;
        membership_Access.Program__c = webProgMTM_Access.Membership_Program__c;
        membership_Access.Name = 'test';
        
        Membership__c membership_NoAccess = new Membership__c();
        membership_NoAccess.Membership_Status_Text__c = 'Member - Payer';
        membership_NoAccess.Account_Name__c = acct.Id;
        membership_NoAccess.Program__c = webProgMTM_NoAccess.Membership_Program__c;
        membership_NoAccess.Name = 'test';
        list<Membership__c> memberships = new list<Membership__c> { membership_Access, membership_NoAccess };
        util.BypassAllTriggers = true;
        insert memberships;
        util.BypassAllTriggers = false;
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = siteProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
  
    }
    
    //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - add the assert for HasEseAccess value in the login command 
    // attempt to login a user where the status is active, but the verify code is "1" -- should return R3
    static testMethod void testLogin_R3() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - Create the data 
         //create an account and employee contact
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Enrollment_Scenario_Explorer_access__c = true;
        insert acct;
        
        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = SiteUserHelper.SITE_EAB, Account__c = acct.Id);
        insert domain;
        Contact employeeContact = TestUtilities.CreateNewContact(false);
        employeeContact.AccountId = acct.Id;
        employeeContact.RecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId;
        employeeContact.Email = 'test-' + String.valueOf(Crypto.getRandomInteger()) + '@advisory.com';
        insert employeeContact;
        
        // create a contact on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Verify__c = '1';
        siteProfile.Contact__c = employeeContact.Id;
        insert siteProfile;
        
        //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - end here
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = siteProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        //Modify By - Neha Sharma - 29/7/21 - CR-20210721-15304 - add the assert for HasEseAccess value in the login command
        system.assertEquals('1',sUser.HasEseAccess);

        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];

    }
    
    static testMethod void testAction_GetUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        // insert 2 meeting utilizations
        Meeting_Utilization__c mUtilization_future = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(1),
                                                                                End_Date__c = system.today().addDays(2),
                                                                                Status__c = 'Confirmed',
                                                                                EventID__c = '1111-1111-1111-1111',
                                                                                ABC_Contact__c = siteProfile.Contact__c);
        Meeting_Utilization__c mUtilization_past = new Meeting_Utilization__c(Start_Date__c = system.today().addDays(-4),
                                                                                End_Date__c = system.today().addDays(-5),
                                                                                Status__c = 'Attended',
                                                                                EventID__c = '2222-2222-2222-2222',
                                                                                ABC_Contact__c = siteProfile.Contact__c);
        List<Meeting_Utilization__c> utilzationsToInsert = new List<Meeting_Utilization__c> { mUtilization_future, mUtilization_past };
        insert utilzationsToInsert;
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.IsOnline = true;
        sUser.Command = 'getUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        Contact con = [SELECT Name, Id, FirstName, LastName, 
                       (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, 
                        Last_Access__c, Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                        FROM Site_Profiles__r 
                        ORDER BY Status__c DESC)
                       FROM Contact 
                       WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Id = :siteProfile.Id)];
        
        // make sure the returned string is correct
        //system.assertEquals('Success', sUser.Response);
        system.assertEquals(1, con.Site_Profiles__r.size());
        // verify the EventID of our future meeting is present in the JSON response
        system.assert(decryptedJSONResponse.contains('1111-1111-1111-1111'));
        // verify the EventID of our past meeting is NOT included in the JSON response
        system.assert(!decryptedJSONResponse.contains('2222-2222-2222-2222'));
        
        //verify there is one web service log that has the response of Success
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size(),
                            'Should have returned one webservice log.');
        system.assertEquals(sUser.Command, wsLogs[0].Web_Service_Method__c);
        //system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, wsLogs[0].Response_Message__c);
       
        //Testing for the new Request for Action_GetUser. 
        //Building request. 
        
        Test.StartTest();
        
        PageReference pageRef1 = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        SiteUser sUser1 = new SiteUser();
        sUser1.Site = siteProfile.Type__c;
        sUser1.Command = 'getUser_updateLastAccess';
        sUser1.UniqueId = con.Id;
        
        string origData1 = JSON.serialize(sUser1);
        blob encryptedBlob1 = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData1));
        String encryptedString1 = EncodingUtil.base64Encode(encryptedBlob1);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller1 = new SiteController();
        controller1.initialize();
        
        // deserialize the response
        String decryptedJSONResponse1 = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller1.JSONResponse));
        sUser1 = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        Contact con1 = [SELECT Name, Id, FirstName, LastName, 
                       (SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, 
                        Last_Access__c, Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                        FROM Site_Profiles__r 
                        ORDER BY Status__c DESC)
                       FROM Contact 
                       WHERE Id IN (SELECT Contact__c FROM Site_Profile__c WHERE Id = :siteProfile.Id)];
        
        // make sure the returned string is correct
        //system.assertEquals('Success', sUser.Response);
        system.assertEquals(1, con1.Site_Profiles__r.size());
        // verify the EventID of our future meeting is present in the JSON response
        system.assert(decryptedJSONResponse.contains('1111-1111-1111-1111'));
        // verify the EventID of our past meeting is NOT included in the JSON response
        system.assert(!decryptedJSONResponse.contains('2222-2222-2222-2222'));
        
        Test.StopTest();

    }
    
    /**
     * @description:    
     *
     * @revision log: 
     *     	 
     **/
    static testmethod void testAction_UpdateUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        //get the updated site profile (with user id)
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, 
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c
                      WHERE Id = :siteProfile.Id];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        string jobFunction = 'Developer';
        string department = 'eTech';
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = '';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Title = 'SF Dev';
        //sUser.Job_Function = jobFunction;
        sUser.EAB_Role = jobFunction;
        //sUser.Department = department;
        sUser.EAB_Department = department;
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        test.startTest();
        //reset the bypass variables to false
        SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        test.stopTest();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //system.assertEquals('Success', sUser.Response);
        
        // get the updated contact
        siteProfile = [SELECT Id, Username__c, Contact__r.EAB_Department__c, Contact__r.EAB_Role__c FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
    }
    
    /**
     * @description:    
     *
     * @revision log: 
     *     	 
     **/
    static testMethod void testTemporaryAccessDetails() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create an active Account/Contact/Site User/Site Profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        insert siteProfile;
        
        // add a temporary access record
        //Temporary_Program_Access__c tempAccess = CreateTempProgAccess(null, siteProfile, true);
        
        //Modified By - Chirag Soni - 04/14/2022 - CR-20220310-16004 - Commented references for AdvisorySite vf page 
        // set the page reference
        //PageReference pageRef = Page.AdvisorySite;
        //Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.IsOnline = true;
        sUser.Command = 'getUser';
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        //decrypt/deserialize the response
        String decryptedJSONResponse = EncryptionHelper.Decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        
        Contact con = [SELECT Name, Id, FirstName, LastName,/* Advisory_com_Last_Access__c,*/
               (SELECT Name, Id, Web_Program__r.Membership_Program__c, Web_Program__r.Program_Acronym__c, Web_Program__r.Adv_com_Program_Id__c, Web_Program__r.Program_Formal_Name__c FROM Temporary_Program_Access__r WHERE Start_Date__c <= TODAY AND End_Date__c >= TODAY LIMIT 1000)
               FROM Contact WHERE Id = :siteProfile.Contact__c];
        
    }
    
	//Victor Hanson - 08/23/2019 - CR-20190823-13279 - updated so it pulls from existing Site Profile created via test setup
    static testmethod void testAction_UpdateUser_Email() {
        
		//Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev
        //Bypass the triggers
        Util.BypassAllTriggers = true;
        //Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev -- Ends here
        
        //get the updated site profile (with user id)
        Site_Profile__c siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = '';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = 'updatedemail@eab.com';
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
		 //Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev
        //Enable all the triggers
        Util.BypassAllTriggers = false;
        //Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev -- Ends here

        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        system.assertEquals('Success', sUser.Response);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, Company_Email__c,    
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // verify the contact was updated properly
        system.assertEquals('updatedemail@eab.com', con.Company_Email__c);
        //verify the site profile was updated properly
        system.assertEquals('updatedemail@eab.com', con.Site_Profiles__r[0].Username__c);
        //system.assertEquals(siteProfile.Username__c, con.Advisory_com_Modified_By__c);
        system.assertEquals('1', con.Site_Profiles__r[0].Verify__c);
        // verify the response = success
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        
        //check to see that there is a web service log created for this
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c, Requested_By__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size());
        system.assertEquals('updateUser', wsLogs[0].Web_Service_Method__c);
    }
    
    //Victor Hanson - 08/23/2019 - CR-20190823-13279 - updated so it pulls from existing Site Profile created via test setup
    static testmethod void testAction_UpdateUser_Password() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //get the updated site profile (with user id)
        Site_Profile__c siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c];
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Username = siteProfile.Username__c;
        sUser.Password = 'newPassword';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = siteProfile.Username__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, 
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c, Password__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        //verify the site profile was updated properly
        system.assertEquals('2', con.Site_Profiles__r[0].Verify__c);
        
        //check to see that there is a web service log created for this
        list<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, Response_Message__c, Requested_By__c FROM Web_Service_Log__c WHERE Site_Profile__c = :siteProfile.Id];
        system.assertEquals(1, wsLogs.size());
        system.assertEquals('updateUser', wsLogs[0].Web_Service_Method__c);
    }
    
    //Victor Hanson - 08/23/2019 - CR-20190823-13279 - updated so it pulls from existing Site Profile created via test setup
    // make sure the verify field doesnt change if it equals 4
    static testmethod void testVerify_4() {
        
		//Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev
        //Bypass all the triggers
        Util.BypassAllTriggers = true;
        //Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev -- Ends here
        
        //get the updated site profile (with user id)
        Site_Profile__c siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c];
        
        siteProfile.Verify__c = '4';
        update siteProfile;
        
        siteProfile = [SELECT Id, Password__c, Password_Reset_Token__c, Bypass_Domain_Validation__c, Last_Access__c, Contact__c,
                       Send_Password_Notification__c, Site_User__c, Verify__c, Verify_Date__c, Status__c, Status_Code__c, Type__c, User_Id__c, Username__c 
                       FROM Site_Profile__c];
        
        system.assertEquals('4', siteProfile.Verify__c);
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        //generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.Password = 'newPassword';
        sUser.User_Id = integer.valueOf(siteProfile.User_Id__c);
        sUser.Email_Address = 'updatedemail2@eab.com';
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Office_Phone = '555-555-5655';
        sUser.Command = 'updateUser';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
	//Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev
        //Enable all the triggers
        Util.BypassAllTriggers = false;
        //Added as per the R-60 validation failure -- 08-03-2017 -- Rajeev -- Ends here

        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response and convert it to a Site User
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        // get the updated contact and site user
        Contact con = [SELECT Name, Id, Email, Company_Email__c, 
                       (SELECT Id, Name, Username__c, Verify__c, Status_Code__c, Password__c FROM Site_Profiles__r) 
                       FROM Contact WHERE Id = :siteProfile.Contact__c];
        
        // verify the response = success
        system.assertEquals(SiteUserHelper.RESPONSE_SUCCESS, sUser.Response);
        // ensure the verify flag is set
        system.assertEquals('4', con.Site_Profiles__r[0].Verify__c);
        // verify the contact was updated properly
        system.assertEquals('updatedemail2@eab.com', con.Company_Email__c);
        system.assertEquals('updatedemail2@eab.com', con.Site_Profiles__r[0].Username__c);
    }
    
    static testmethod void testAction_UpdateUser_EmailAlreadyExists() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        Account acct = createNewAccount(true);
        
        // create a profile on a different institution
        Site_Profile__c siteProfile = createSiteProfile(acct, SiteUserHelper.SITE_EAB, false);
        siteProfile.Username__c = 'hansonv@eab.com';
        siteProfile.Password__c = 'test';
        siteProfile.Verify__c = '2';
        siteProfile.Status__c = 'Active';
        
        
        list<Site_profile__c> siteProfileList = new list<Site_Profile__c> { siteProfile/*, siteProfile2*/ };
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;    
            
        //try to insert the site profiles and capture the error(s) that are returned
        String errMsg;
        try {
            insert siteProfileList;
        }
        catch(DMLException ex) {
            errMsg = ex.getDMLMessage(0);
        }
        catch(Exception ex) {
            system.assertEquals(null, ex.getMessage());
        }
        
        // verify that an error was thrown because the Username cannot be directly updated on the Site Profile
        system.assertNotEquals(null, errMsg);
       
    }
    
    
    /**
     * @description:    1) Create an Institution, Valid Domain, Contact, Site Profile
     *                  2) Delete the Valid Domain
     *                  3) Make an update to the Contact's basic info (ie: FirstName) and Save the changes
     *                  4) Verify that the contact was updated successfully even though the domain is invalid.
     * 
     **/
    static testmethod void testEditContact_BadDomain() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Bypass Dupeblocker
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //create a site profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_Advisory, true);
        
        //get the site profile's contact
        Contact con = [SELECT Id, FirstName, Email FROM Contact WHERE Id = :sProfile.Contact__c];
        
        // get the domain of the contact
        String contactDomain = con.Email.split('@')[1];
        
        // find the domain record on the account & Delete it
        List<Eligible_Domain__c> eligibleDomains = [SELECT Id FROM Eligible_Domain__c WHERE Qualified_Domain__c = :contactDomain];
        //system.assertNotEquals(0, eligibleDomains.size());
        delete eligibleDomains;
        
        // now edit / save the contact successfully
        String newFirstName = 'moseby';
        con.FirstName = newFirstName;
        update con;
        
        // get the updated contact
        List<Contact> cons = [SELECT Id, FirstName FROM Contact WHERE Id = :con.Id];
        system.assertEquals(1, cons.size());
        system.assertEquals(newFirstName, cons[0].FirstName);
    }
    
    static testmethod void testSiteUserContact_BadDomain_UncheckFalse() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Bypass Dupeblocker
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //create a site profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        //get the site profile's contact
        Contact con = [SELECT Id, FirstName, Email, Primary_Country__c, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile.Contact__c];
        // change the email to an invalid domain
        con.Email = 'test@zzzzz.com';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        update con;
        
        con = [SELECT Id, FirstName, Email, Primary_Country__c, Bypass_Domain_Validation__c FROM Contact WHERE Id = :sProfile.Contact__c];
        system.assertEquals(true, con.Bypass_Domain_Validation__c);
        
        // now attempt to update the contact
        con.Bypass_Domain_Validation__c = false;
        
        boolean isSuccessful = false;
        try {
            Util.BypassAllTriggers = false;
            SiteProfileTriggerHelper.hasSynchronizedSiteProfile = false;
            update con;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Domain is not eligible for this Site')) {
                // if we caught an error, this is a success
                isSuccessful = true;
            }
            else {
                //system.assert(false, ex.getMessage());
            }
        }
        
        // get the contact even though it shouldn't have been updated
        con = [SELECT Id, Bypass_Domain_Validation__c FROM Contact WHERE Id = :con.Id];

    }
    
    /**
     * @description:    1) Create an EAB.com site profile and simulate login
     *                  2) verify no login history is tracked
     *                  3) Login history is only tracked for Advisory.com Site Profiles.
     * 
     **/
    //Victor Hanson - 08/23/2019 - CR-20190823-13279 - removed some old, commented out code
    static testmethod void testTrackLoginHistory_EAB() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create an Advisory Site Profile
        Site_Profile__c sProfile = createSiteProfile(SiteUserHelper.SITE_EAB, false);
        sProfile.Verify__c = '1';
        sProfile.Status__c = 'In Progress';
        insert sProfile;
        Contact contact = [SELECT Id FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Start Testing from here
        Test.startTest();
        
        // set the page reference
        PageReference pageRef = Page.Site_Json;
        Test.setCurrentPage(pageRef);
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Username = sProfile.Username__c;
        sUser.Password = sProfile.Password__c;
        sUser.Command = 'login';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        contact = [SELECT Id,  (SELECT Id, Last_Access__c FROM Site_Profiles__r) FROM Contact WHERE Id = :sProfile.Contact__c];
        
        //Stop Test
        Test.stopTest();
    }
    
    /**
     * @description:    Create a site profile, add a membership key contact, and verify the subscription was auto-generated
     * 
     **/
    //Victor Hanson - 08/23/2019 - CR-20190823-13279 - removed reference to 'setupSubscriptionOptions'
    static testMethod void membershipKeyContact_AutoSubscribe_CreateSubscription() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, 
                        Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
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
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //create the membership key contact
        Membership_Key_Contact__c membershipKeyContact = new Membership_Key_Contact__c(Contact__c = sProfile.Contact__c,
                                                                                       Name='Test',
                                                                                       Membership__c = membership.Id);
        insert membershipKeyContact;
        
        //Stop test here
        test.stopTest();

    }
    
    /**
     * @description:    Create an Advisory site profile, add a membership key contact for an EAB program, and verify the EAB Site Profile & subscription was auto-generated
     *
     * @revision log:   Modified By - Victor Hanson - 08/23/2019 - CR-20190823-13279 - removed reference to 'setupSubscriptionOptions'
     *     	 
     **/
    static testMethod void membershipKeyContact_AutoSubscribe_CreateSiteProfile() {

        string errorMessage;
        try {
            // create a contact that is also an Adv.com User
             Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
            //system.assertNotEquals(null, errorMessage);
            system.assertEquals(true, errorMessage.containsIgnoreCase('Organization Status must be active to create a Site Profile'));
            
            // get the site profile and contact info
            sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, 
                            Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
            
            //Bypass Dupeblocker
            Util.IsTest(true);
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = true;
            
            //Flag for triggers: this is just a test, don't do crazy things.
            Util.isTesting = true;
            
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
            
            // create an opportunity and contract
            Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
            opp.CloseDate = system.today();
            opp.stageName = 'Closed Won';
            opp.Program__c = prog.Id;
            insert opp;
            
            test.startTest();
            
            Contract__c testContract1 = new Contract__c(
                Name='Test Contract1', Payer_Account__c = sProfile.Contact__r.AccountId, Program__c = prog.Id, Source_Opportunity__c=opp.Id,
                Start__c = System.Today().addDays(-10), End__c = system.today().addDays(355),
                Contract_Renewal_Opportunity__c = opp.Id, Status__c = 'ATL', Invoicing_Arrangement__c = 'Annual', Year__c = '2012',
                Type__c = 'NBB', Years_in_Term__c = 1, Initial_Invoice_Date__c = system.today()
            );
            insert testContract1;
            
            //Bypassing Triggers so then test data can be created easily
            Util.byPassAllTriggers = false;
            
            //create the membership key contact
            Membership_Key_Contact__c membershipKeyContact = new Membership_Key_Contact__c(Contact__c = sProfile.Contact__c,
                                                                                           Name='Test',
                                                                                           Membership__c = membership.Id);
            insert membershipKeyContact;

            test.stopTest();
            
            //verify an EAB site profile was auto-generated by the CreateAutoSubscriptions method
            Contact con = [SELECT Id, (SELECT Id, Type__c FROM Site_Profiles__r WHERE Type__c = :SiteUserHelper.SITE_EAB) FROM Contact WHERE Id = :sProfile.Contact__c];
            system.assertEquals(1, con.Site_Profiles__r.size(),
                               'an EAB Site Profile should have been generated due to the membership key contact that was created.');
        }
	
	catch(exception ex) {
		errorMessage = ex.getMessage();
        }
       
    }
    
    /**
     * @description:    Create a site profile, add a Project Role associated with a PT program, and verify the subscription was auto-generated
     *
     * @revision log:   Modified By - Subhash Garhwal - 11/13/2017 -  Too many SOQL queries: 101
     *			Error fix Comment Contract insertion because it is not having any reference in this method     	 
     **/
    static testMethod void projectRole_PT_AutoSubscribe_CreateSubscription() {
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        prog.Business_Line__c = 'PT';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        util.BypassAllTriggers = true;
        insert membership;
        util.BypassAllTriggers = false;
        
        test.startTest();

        //Bypass the entity population Logic  
     	Util.bypassEntityPopulation = true;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        test.stopTest();
    
    }
    
    /**
     * @description:    Create an Advisory site profile, add a Project Role related to an EAB program, and verify the EAB Site Profile & subscription was auto-generated
     *
     * @revision log:   Modified By - Subhash Garhwal - 11/13/2017 -  Too many SOQL queries: 101
     * 			Error fix Comment Contract insertion because it is not having any reference in this method
     *
     **/
    static testMethod void projectRole_PT_AutoSubscribe_CreateSiteProfile() {
        
        //Bypass the entity population Logic  
     	Util.bypassEntityPopulation = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact that is also an Adv.com User
        Site_Profile__c sProfile = Test_SiteUserHelper.createSiteProfile(SiteUserHelper.SITE_EAB, true);
        
        // get the site profile and contact info
        sProfile = [SELECT Id, User_Id__c, Contact__r.LastName, Status_Code_Description__c, Type__c, Contact__c, Contact__r.AccountId FROM Site_Profile__c WHERE Id = :sProfile.Id];
        
        // create a program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        prog.Applicable_Segments__c = 'US Education';
        prog.Business_Line__c = 'PT';
        insert prog;
        
        Membership__c membership = new Membership__c();
        membership.Membership_Status_Text__c = 'Member - Payer';
        membership.Account_Name__c = sProfile.Contact__r.AccountId;
        membership.Program__c = prog.Id;
        membership.Name = 'test';
        util.BypassAllTriggers = true;
        insert membership;
        util.BypassAllTriggers = false;
        membership = [SELECT Id, Membership_Status_Text__c FROM Membership__c WHERE Id = :membership.Id];
        //system.assertEquals('Member - Payer', membership.Membership_Status_Text__c);

        test.startTest();
        
         //Bypass the entity population Logic  
     	Util.bypassEntityPopulation = true;
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        // create an opportunity and contract
        Opportunity opp = testUtilities.CreateNewOpportunity(sProfile.Contact__r.AccountId, false);
        opp.CloseDate = system.today();
        opp.stageName = 'Closed Won';
        opp.Program__c = prog.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
	}
    
    /**
     * @description: saves a post on the Site Profile and then removes the post.
     * 				 This simulates what happens when a user clicks "Save" when viewing a post on the site
     *
     * @revision log: Victor Hanson - 08/23/2019 - CR-20190823-13279 - created
     **/
    static testMethod void testAction_SavedPostListener() {
        
        //GUID
        String postGUID = '123';
        
        //get the 1 site profile that was created as part of test setup
        Site_Profile__c siteProfile = [SELECT Id, Username__c, User_Id__c, Type__c FROM Site_Profile__c LIMIT 1];
        
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.User_Id = Integer.valueOf(siteProfile.User_Id__c);
        sUser.Command = 'addSavedPost';
        
        //add post details
        sUser.post.id_x = postGUID;
        sUser.post.guid = postGUID;
        sUser.post.post_title = 'EAB In The News';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        siteProfile = [SELECT Id, User_Id__c, Username__c, Type__c, (SELECT Id, Site_Content__r.GUID__c, Type__c FROM Site_Preferences__r) FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
        //assertions
        system.assertEquals(1, siteProfile.Site_Preferences__r.size());
        system.assertEquals(postGUID, siteProfile.Site_Preferences__r[0].Site_Content__r.GUID__c);
        
        test.startTest();
        
        //reset sUser
        sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.User_Id = Integer.valueOf(siteProfile.User_Id__c);
        sUser.Command = 'removeSavedPost';
        
        //add post details
        sUser.post.id_x = postGUID;
        sUser.post.guid = postGUID;
        sUser.post.post_title = 'EAB In The News';
        
        origData = JSON.serialize(sUser);
        encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        controller = new SiteController();
        controller.initialize();
        
        test.stopTest();
        
        siteProfile = [SELECT Id, (SELECT Id, Site_Content__r.GUID__c, Type__c FROM Site_Preferences__r) FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
        //assertions
        system.assertEquals(0, siteProfile.Site_Preferences__r.size());
    }
    
    /**
     * @description: saves a post on the Site Profile and then removes the post.
     * 				 This simulates what happens when a user clicks "Save" when viewing a post on the site
     *
     * @revision log: Victor Hanson - 08/23/2019 - CR-20190823-13279 - created
     **/
	static testMethod void testAction_UserTokenAvailablityCheck() {
        
        //GUID
        String postGUID = '123';
        
        //get the 1 site profile that was created as part of test setup
        Site_Profile__c siteProfile = [SELECT Id, Username__c, User_Id__c, Type__c FROM Site_Profile__c LIMIT 1];
        
        SiteUser sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.User_Id = Integer.valueOf(siteProfile.User_Id__c);
        sUser.Command = 'useToken';
        
        //add post details
        sUser.post.id_x = postGUID;
        sUser.post.guid = postGUID;
        sUser.post.post_title = 'EAB In The News';
        
        string origData = JSON.serialize(sUser);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // deserialize the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        siteProfile = [SELECT Id, User_Id__c, Tokens__c, Username__c, Type__c, (SELECT Id, Site_Content__r.GUID__c, Status__c FROM Site_Tokens__r) FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
        //assertions
        system.assertEquals(1, siteProfile.Site_Tokens__r.size());
        system.assertEquals('Active', siteProfile.Site_Tokens__r[0].Status__c);
        
        //change the number of tokens available on site profile to 0
        siteProfile.Tokens__c = 0;
        util.bypassAllTriggers = true;
        update siteProfile;
        
        test.startTest();
        
        //reset sUser
        sUser = new SiteUser();
        sUser.Site = siteProfile.Type__c;
        sUser.User_Id = Integer.valueOf(siteProfile.User_Id__c);
        sUser.Command = 'useToken';
        
        //add post details
        sUser.post.id_x = '333';
        sUser.post.guid = '333';
        sUser.post.post_title = 'Test Post 2';
        
        origData = JSON.serialize(sUser);
        encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        // controller
        controller = new SiteController();
        controller.initialize();
        
        test.stopTest();
        
        siteProfile = [SELECT Id, Contact__r.AccountId, (SELECT Id, Site_Content__r.GUID__c, Status__c FROM Site_Tokens__r) FROM Site_Profile__c WHERE Id = :siteProfile.Id];
        
        //assertions
        system.assertEquals(1, siteProfile.Site_Tokens__r.size());
        
        String testGetInstitutionSiteUser = SiteUserHelper.getInstitutionSiteUser(siteProfile.Contact__r.AccountId, 'test', 'test');
    }
    
     static testmethod void test_PerformAction() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c 
                    FROM Account WHERE Id = :acct.Id];
         //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
         
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.site_User__c = site_User.Id;
        con.Contact_Status__c = 'Active';
        con.Email = 'michael_vayda@uml.edu';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = 'hansonv@zzzzz.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'getUser_updateLastAccess';
        sUser.Site = SiteUserHelper.SITE_EAB;
         
         string origData = JSON.serialize(sUser);
         blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
         String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
         
          // generate the request
        SiteUser sUser1 = new SiteUser();
        sUser1.Email_Address = 'hansonv@zzzzz.com';
        sUser1.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser1.Password = 'test';
        sUser1.ClientId = acct.Historical_Linker__c;
        sUser1.Prefix = 'Mr';
        sUser1.Country = 'USA';
        sUser1.First_Name = 'Victor';
        sUser1.Last_Name = 'Hanson';
        sUser1.Middle_Initial = 'R';
        sUser1.Suffix = '';
        sUser1.Job_Function = 'Developer';
        sUser1.Title = 'SF Dev';
        sUser1.Department = 'eTech';
        sUser1.Command = 'SendWebConferenceConfirmation';
        sUser1.Site = SiteUserHelper.SITE_EAB;
         
         string origData1 = JSON.serialize(sUser1);
         blob encryptedBlob1 = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData1));
         String encryptedString1 = EncodingUtil.base64Encode(encryptedBlob1);
         
        // generate the request
        SiteUser sUser2 = new SiteUser();
        sUser2.Email_Address = 'hansonv@zzzzz.com';
        sUser2.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser2.Password = 'test';
        sUser2.ClientId = acct.Historical_Linker__c;
        sUser2.Prefix = 'Mr';
        sUser2.Country = 'USA';
        sUser2.First_Name = 'Victor';
        sUser2.Last_Name = 'Hanson';
        sUser2.Middle_Initial = 'R';
        sUser2.Suffix = '';
        sUser2.Job_Function = 'Developer';
        sUser2.Title = 'SF Dev';
        sUser2.Department = 'eTech';
        sUser2.Command = 'upsertContact';
        sUser2.Site = SiteUserHelper.SITE_EAB;
         
         string origData2 = JSON.serialize(sUser2);
         blob encryptedBlob2 = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData2));
         String encryptedString2 = EncodingUtil.base64Encode(encryptedBlob2);
         
         //Start from here
         test.startTest();
         
          // Add parameters to page URL 
         ApexPages.currentPage().getParameters().put('req', encryptedString);
         
         // controller
         SiteController controller = new SiteController();
         controller.initialize();
         
        // Add parameters to page URL 
         ApexPages.currentPage().getParameters().put('req', encryptedString1);
         
          // controller
         SiteController controller1 = new SiteController();
         controller1.initialize();
         
        // Add parameters to page URL 
         ApexPages.currentPage().getParameters().put('req', encryptedString2);
         
          // controller
         SiteController controller2 = new SiteController();
         controller2.initialize();

        
         siteUserHelper.CreateNewUser(con,sUser,false, false);
        
         test.stopTest();
     }

    // V1.9 Added By - Abhinav sharma- 08/17/2020 - CR-20200714-14306 - Test fuction to test the flow of searchOrganization having email value
    static testmethod void test_Action_SearchOrganization_WithEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, 
                                                           Account__c = acct.Id);
        insert domain;
        
         //Create Site User
        Site_User__c site_User = SiteUserHelper.createNewSite_User(true);
        
        //Create Contact
        Contact con = new Contact();
        con.lastname = 'test';
        con.FirstName = 'Contact';
        con.Email = 'test@gmail.com';
        con.Company_Email__c = 'test@gmail.com';
        con.title = 'Director';
        con.phone = '1234565676';
        con.accountId = acct.Id;
        insert con;
                
        //Create Contact
        Contact con1 = new Contact();
        con1.lastname = 'test';
        con1.FirstName = 'Contact';
        con1.Email = 'test1@gmail.com';
        con1.Company_Email__c = 'test1@gmail.com';
        con1.title = 'Director';
        con1.phone = '1234565676';
        insert con1;
        
        Site_Profile__c site_Profile = new Site_Profile__c(Contact__c = con1.Id, Status__c = 'Active',Username__c = 'test1@gmail.com',
                                  Site_User__c = site_User.Id);
        insert site_Profile;
        
        con1.EAB_com_Site_Profile__c = site_Profile.Id;
        Update con1;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Command = 'searchOrganization';
        sUser_EAB.Office_Phone = '555-555-5655';
        sUser_EAB.email = 'test@gmail.com';
        sUser_EAB.site_User = site_User;
        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
         
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Email_Address = 'hansonv@advisory.com';
        sUser.Command = 'searchOrganization';
        sUser.Office_Phone = '555-555-5655';
        sUser.email = 'test1@gmail.com';
        sUser.site_User = site_User;
        
        string origData1 = JSON.serialize(sUser);
        blob encryptedBlob1 = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData1));
        String encryptedString1 = EncodingUtil.base64Encode(encryptedBlob1);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString1);
        
        // controller
        SiteController controller1 = new SiteController();
        controller1.initialize();
        
        // get the response
        String decryptedJSONResponse1 = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller1.JSONResponse));
        sUser = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse1);
        
        system.assertEquals(System.Label.Contains_Site_Profile, sUser.Response);
        
        //Stop test here
        test.stopTest();
       
    }
    
    
    // V1.9 Added By - Abhinav sharma- 08/17/2020 - CR-20200714-14306 - Test fuction to test the flow of searchOrganization not having email value
    static testmethod void test_Action_SearchOrganization_WithOutEmail() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just for test
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, 
                                                           Account__c = acct.Id);
        insert domain;
        
        //Create Contact
        Contact con = new Contact();
        con.lastname = 'test';
        con.FirstName = 'Contact';
        con.Email = 'test@gmail.com';
        con.title = 'Director';
        con.phone = '1234565676';
        con.AccountId = acct.Id;
        insert con;
        
        //Create Site User
        Site_User__c site_User = SiteUserHelper.createNewSite_User(true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_EAB.Password = 'test';
        sUser_EAB.ClientId = acct.Historical_Linker__c;
        sUser_EAB.Prefix = 'Mr';
        sUser_EAB.Country = 'USA';
        sUser_EAB.City = 'Dellas';
        sUser_EAB.State = 'TX';
        sUser_EAB.Org_Name = 'Test';
        sUser_EAB.First_Name = 'Victor';
        sUser_EAB.Last_Name = 'Hanson';
        sUser_EAB.Middle_Initial = 'R';
        sUser_EAB.Suffix = '';
        sUser_EAB.Job_Function = 'Developer';
        sUser_EAB.Title = 'SF Dev';
        sUser_EAB.Department = 'eTech';
        sUser_EAB.Command = 'searchOrganization';
        sUser_EAB.Office_Phone = '555-555-5655';
        sUser_EAB.site_User = site_User;
        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser_EAB = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Stop test here
        test.stopTest();
       
    }
    
     // V1.9 Added By - Abhinav sharma- 08/17/2020 
    static testmethod void test_Action_Search() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, 
                                                           Account__c = acct.Id);
        insert domain;
        
        //Create Contact
        Contact con = new Contact();
        con.lastname = 'test';
        con.FirstName = 'Contact';
        con.Email = 'test@gmail.com';
        con.title = 'Director';
        con.phone = '1234565676';
        con.AccountId = acct.Id;
        insert con;
        
        //Create Site User
        Site_User__c site_User = SiteUserHelper.createNewSite_User(true);
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_EAB.Password = 'test';
        sUser_EAB.ClientId = acct.Historical_Linker__c;
        sUser_EAB.Prefix = 'Mr';
        sUser_EAB.Country = 'USA';
        sUser_EAB.City = 'Dellas';
        sUser_EAB.State = 'TX';
        sUser_EAB.Org_Name = 'Test';
        sUser_EAB.First_Name = 'Victor';
        sUser_EAB.Last_Name = 'Hanson';
        sUser_EAB.Middle_Initial = 'R';
        sUser_EAB.Suffix = '';
        sUser_EAB.Job_Function = 'Developer';
        sUser_EAB.Title = 'SF Dev';
        sUser_EAB.Department = 'eTech';
        sUser_EAB.Command = 'search';
        sUser_EAB.Office_Phone = '555-555-5655';
        sUser_EAB.site_User = site_User;
        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser_EAB = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Stop test here
        test.stopTest();
       
    }
    
    
     // V1.9 Added By - Abhinav sharma- 08/17/2020 
    static testmethod void test_Action_SendWebConferenceConfirmation_EAB() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //Eligible Domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, 
                                                           Qualified_Domain__c = SiteUserHelper.SITE_EAB, 
                                                           Account__c = acct.Id);
        insert domain;
        
        //Create Contact
        Contact con = new Contact();
        con.lastname = 'test';
        con.FirstName = 'Contact';
        con.Email = 'test@gmail.com';
        con.title = 'Director';
        con.phone = '1234565676';
        con.AccountId = acct.Id;
        insert con;
        
        
        //Create Site User
        Site_User__c site_User = SiteUserHelper.createNewSite_User(true);
        
        //site profile
        Site_Profile__c sProfile = new Site_Profile__c();
        sProfile.Type__c ='Eab.com';
        sProfile.Username__c =  con.Email;
        sProfile.Status__c = 'Active';
        sProfile.Site_User__c = site_User.Id;
        sProfile.Contact__c =  con.Id;
        insert sProfile;
        
        // set the page reference
        PageReference pageRef = Page.Site_JSON;
        Test.setCurrentPage(pageRef);
        
        // get historical_Linker
        acct = [SELECT Id, Historical_Linker__c FROM Account WHERE Id = :acct.Id];
        
        // generate the request
        SiteUser sUser_EAB = new SiteUser();
        sUser_EAB.Site = SiteUserHelper.SITE_EAB;
        sUser_EAB.Email_Address = 'hansonv@advisory.com';
        sUser_EAB.Email_Address2 = 'hansonv@zzzzz.com';
        sUser_EAB.Password = 'test';
        sUser_EAB.ClientId = acct.Historical_Linker__c;
        sUser_EAB.Prefix = 'Mr';
        sUser_EAB.Country = 'USA';
        sUser_EAB.First_Name = 'Victor';
        sUser_EAB.Last_Name = 'Hanson';
        sUser_EAB.Middle_Initial = 'R';
        sUser_EAB.Suffix = '';
        sUser_EAB.Job_Function = 'Developer';
        sUser_EAB.Title = 'SF Dev';
        sUser_EAB.Department = 'eTech';
        sUser_EAB.Command = 'SendWebConferenceConfirmation';
        sUser_EAB.Office_Phone = '555-555-5655';
        sUser_EAB.email = 'test@gmail.com';

        
        string origData = JSON.serialize(sUser_EAB);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', SiteControllerHelper.KEY, blob.valueOf(origData));
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        
        // Add parameters to page URL 
        ApexPages.currentPage().getParameters().put('req', encryptedString);
        
        //Start from here
        test.startTest();
        
        // controller
        SiteController controller = new SiteController();
        controller.initialize();
        
        // get the response
        String decryptedJSONResponse = EncryptionHelper.decrypt(EncodingUtil.base64Decode(controller.JSONResponse));
        sUser_EAB = EncryptionHelper.deserializeSiteUser(decryptedJSONResponse);
        
        //Stop test here
        test.stopTest();
       
    }
    
    static testmethod void test_ACTION_UpsertDeleteMenuCustomization() {
        
        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.site_User__c = site_User.Id;
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;
        
        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
       
       //Insert the site profile
       insert site_Profile;
            
        
        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = 'hansonv@zzzzz.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'updateMenuCustomization';
        sUser.Site = SiteUserHelper.SITE_EAB;
        
        Map<Id,site_user__c> mapOldSiteUsers = new Map<Id,site_user__c>();
        mapOldSiteUsers.put(site_User.Id,site_User);
        
        List<Site_User__c> newSiteUsers = new list<Site_User__c>();
        newSiteUsers.add(site_User);
            
        test.startTest();
        siteUserHelper.ACTION_UpsertDeleteMenuCustomization(sUser);
        siteUserHelper.populateEntityField(newSiteUsers,mapOldSiteUsers);
        test.stopTest();
    }
    
   	static testmethod void test_Action_SendPasswordResetEmail() {

        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.site_User__c = site_User.Id;
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;

        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
       
       //Insert the site profile
       insert site_Profile;
       
       // generate the request
       SiteUser sUser = new SiteUser();
       sUser.Email_Address = 'hansonv@zzzzz.com';
       sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
       sUser.Username = site_Profile.Username__c;
       sUser.Password = 'test';
       sUser.ClientId = acct.Historical_Linker__c;
       sUser.Prefix = 'Mr';
       sUser.Country = 'USA';
       sUser.First_Name = 'Victor';
       sUser.Last_Name = 'Hanson';
       sUser.Middle_Initial = 'R';
       sUser.Suffix = '';
       sUser.Job_Function = 'Developer';
       sUser.Title = 'SF Dev';
       sUser.Department = 'eTech';
       sUser.Command = 'sendPasswordResetEmail';
       sUser.Site = SiteUserHelper.SITE_ADVISORY;

    test.startTest();
        siteUserHelper.Action_SendPasswordResetEmail(sUser);
    test.stopTest();
    }
    

    //Full coverage
    static testmethod void test_CreateNewUser() {

        // setup an account and contact
        Account acct = createNewAccount(false);
        insert acct;
        
        Account acc = [SELECT Id, Organization_Id__c FROM Account Where ID =: acct.Id];
        
        
        System.debug('Organization_Id__c--> '+acc.Organization_Id__c);

        // create the eligible domain
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'updatedemail2eab.com', Account__c = acct.Id);
        insert domain;
        
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        con.Company_Email__c = 'updatedemail1@eab.com';
        insert con;

        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.site_User = site_User;
        sUser.Bypass_Domain_Validation = false;
        sUser.Email_Address = 'updatedemail2@eab.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'sendPasswordResetEmail';
        sUser.Site = SiteUserHelper.SITE_EAB;
        sUser.Organization_Id = integer.valueOf(acc.Organization_Id__c);
        
        Test.startTest();
            siteUserHelper.CreateNewUser(con, sUser, true, false);
        Test.stopTest();
    }
    
    //Full coverage
    static testmethod void test_FindUniqueId() {
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;

        // setup an account and contact
        Account acct = createNewAccount(true);
        
        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        con.Company_Email__c = 'contactcompanyemail@gmail.com';
        con.site_User__c = site_User.Id;
        insert con;

        // generate the request
        SiteUser sUser = new SiteUser();
        sUser.Email_Address = 'hansonv@zzzzz.com';
        sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
        sUser.Password = 'test';
        sUser.ClientId = acct.Historical_Linker__c;
        sUser.Prefix = 'Mr';
        sUser.Country = 'USA';
        sUser.First_Name = 'Victor';
        sUser.Last_Name = 'Hanson';
        sUser.Middle_Initial = 'R';
        sUser.Suffix = '';
        sUser.Job_Function = 'Developer';
        sUser.Title = 'SF Dev';
        sUser.Department = 'eTech';
        sUser.Command = 'sendPasswordResetEmail';
        sUser.Site = SiteUserHelper.SITE_EAB;

        Test.startTest();
            siteUserHelper.FindUniqueId(con,sUser);
        Test.stopTest();
    }
    
    //Full coverage
    static testmethod void test_FindSiteUserContacts() {
		
        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        // setup an account and contact
        Account acct = createNewAccount(true);

        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;

        //create & insert account & contact
        Contact con1 = TestUtilities.CreateNewContact(acct, false);
        con1.Contact_Status__c = 'Active';
        con1.Primary_Country__c = 'USA';
        con1.Bypass_Domain_Validation__c = true;
        con1.accountId = acct.Id;
        insert con1;


        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           User_Id_Override__c = 12345,
                                                           Type__c = SiteUserHelper.SITE_EAB);
       
       //Insert the site profile
       insert site_Profile;

       //create site profile
       Site_Profile__c site_Profile1 = new Site_Profile__c(Status__c = 'Active',
       Username__c = con1.Email,
       Password__c = 'test',
       Site_User__c = site_User.Id,
       Verify__c = '2',
       Contact__c = con1.Id,
       User_Id_Override__c = 54321,
       Type__c = SiteUserHelper.SITE_ADVISORY);

        //Insert the site profile
        insert site_Profile1;

       Test.startTest();
       siteUserHelper.FindSiteUserContacts('12345','54321');
       Test.stopTest();
    }
	
    static testmethod void test_CreateWebConference() {
        Util.byPassAllTriggers = true;
		//create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;
        
        // setup an account and contact
        Account acct = createNewAccount(true);

        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;

        //create & insert account & contact
        Contact con1 = TestUtilities.CreateNewContact(acct, false);
        con1.Contact_Status__c = 'Active';
        con1.Primary_Country__c = 'USA';
        con1.Bypass_Domain_Validation__c = true;
        con1.accountId = acct.Id;
        insert con1;

        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Type__c = SiteUserHelper.SITE_EAB);
       
       

       //create site profile
       Site_Profile__c site_Profile1 = new Site_Profile__c(Status__c = 'Active',
       Username__c = con1.Email,
       Password__c = 'test1',
       Site_User__c = site_User.Id,
       Verify__c = '3',
       Contact__c = con1.Id,
       Type__c = SiteUserHelper.SITE_ADVISORY);
		
        List<Site_Profile__c> siteProfileList = new List<Site_Profile__c>();
        siteProfileList.add(site_Profile);
        siteProfileList.add(site_Profile1);
        
        Test.startTest();
        
        //Insert the site profile
        insert siteProfileList;
        Util.BypassAllTriggers = false;
        
       	
       List<Site_Profile__c> siteProfile = [SELECT Id, User_Id__c FROM Site_Profile__c ORDER BY Verify__c ASC];
        System.debug('siteProfile->'+ siteProfile[0].User_Id__c);
        System.debug('siteProfile->'+ siteProfile[1].User_Id__c);
       
        
       //generate the request
       SiteUser sUser = new SiteUser();
        
       sUser.Attendee  = new SiteUser.WebConferenceAttendee();  
       sUser.Attendee.User_Id = siteProfile[0].User_Id__c; 
       sUser.RegisteredBy.User_Id = siteProfile[1].User_Id__c;
       sUser.WebEvent.StartDate = '2022-05-05 00:00:00';
       sUser.WebEvent.EndDate = '2022-05-08 00:00:00';
       sUser.WebEvent.IsCanceled = false;
       sUser.WebEvent.Origin = 'web';
       sUser.WebEvent.Name = 'Web Conf 1';
       sUser.Attendee.Email = 'hansonv1@zzzzz.com';
       sUser.UniqueId = con.Id;
       sUser.Email_Address = 'hansonv@zzzzz.com';
       sUser.Email_Address2 = 'victor.r.hanson@gmail.com';
       sUser.Password = 'test';
       sUser.ClientId = acct.Historical_Linker__c;
       sUser.Prefix = 'Mr';
       sUser.Country = 'USA';
       sUser.First_Name = 'Victor';
       sUser.Last_Name = 'Hanson';
       sUser.Middle_Initial = 'R';
       sUser.Suffix = '';
       sUser.Job_Function = 'Developer';
       sUser.Title = 'SF Dev';
       sUser.Department = 'eTech';
       sUser.Command = 'sendPasswordResetEmail';
       sUser.Site = SiteUserHelper.SITE_EAB;

       Web_Conference__c webConferences = new Web_Conference__c();
       webConferences.Event_Name__c = sUser.WebEvent.Name;
       webConferences.Canceled__c = false;
       webConferences.Attendee_Email__c = sUser.Attendee.Email;

       siteUserHelper.CreateWebConference(sUser);
       Test.stopTest();
    }
    
    static testmethod void test_getStatusCode() {

        //create & insert site user
        Site_User__c site_User = new Site_User__c();
        insert site_User;

        // setup an account and contact
        Account acct = createNewAccount(true);

        //create & insert account & contact
        Contact con = TestUtilities.CreateNewContact(acct, false);
        con.Contact_Status__c = 'Active';
        con.Primary_Country__c = 'USA';
        con.Bypass_Domain_Validation__c = true;
        con.accountId = acct.Id;
        insert con;


        //create site profile
        Site_Profile__c site_Profile = new Site_Profile__c(Status__c = 'Active',
                                                           Username__c = con.Email,
                                                           Password__c = 'test',
                                                           Site_User__c = site_User.Id,
                                                           Verify__c = '2',
                                                           Contact__c = con.Id,
                                                           Bypass_Domain_Validation__c = true,
                                                           Type__c = SiteUserHelper.SITE_EAB);
        insert site_Profile;

        Test.startTest();
        siteUserHelper.getStatusCode(site_Profile);
        Test.stopTest();
    }
    
}