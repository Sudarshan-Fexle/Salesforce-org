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
private class testContactExtension {
/**
    Purpose         :   Test class for ContactExtension
                
    Created By      :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
                        v2.0 - 07/07/2016 - Abhinav Sharma - CR-20150202-8631 - Code refactor CR

    Coverage Log    :   v1.0 - ContactExtension - 61%
                        v2.0 - ContactExtension - 91%
**/
    
	//Modified by - Abhinav Sharma - CR-20150202-8631 - 07/07/2016 - To refactor the existing code
    /**
     * @description : Method to test out the callout in case of existing user that will invoke by saveOverride method.
    **/
    static testMethod void testSaveOverride_ExistingUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Test converage for the ContactEdit visualforce page
        PageReference pageRef = Page.ContactEdit;
        Test.setCurrentPageReference(pageRef);
        
        //Create Account
        Account newAccount = TestUtilities.CreateNewAccount(true);
        
        //create first contact
        Contact myContact = TestUtilities.CreateNewContact(true);
        
        //Sitecore setting record
        //Creating a record of Sitecore_Settings__c custom setting
        Sitecore_Settings__c siteCoreSetting = new Sitecore_Settings__c();
        siteCoreSetting.name = 'Testing';
        siteCoreSetting.AdvAdmin_URL__c = 'www.testing.com';
        siteCoreSetting.Advisory_com_SF_URL__c = 'www.testing1.com';
        siteCoreSetting.Advisory_Password_Reset_URL__c = 'www.testing2.com';
        siteCoreSetting.EAB_Password_Reset_URL__c = 'www.testing3.com';
        insert siteCoreSetting;
        
        //Setting contact ID in the URL
        pageRef.getParameters().put('id', myContact.Id);
        
        //Calling standard controller
        ApexPages.StandardController stdCon = new ApexPages.standardController(myContact);
        
        //Start testing from here
        Test.startTest();
        
        // create an instance of the controller
        ContactExtension controller = new ContactExtension(stdCon);
        
        //Setting redirect URL
        controller.RedirectURL = 'http://www.google.com';
        
        //Asserting for the results
        //Check to see if the ContactQueue record's values match the values from the contact we are modifying
        //Spring Clean Up
        //system.assertEquals(myContact.FirstName, controller.ContactQueue.First_Name__c);
        
        // make some changes to the contact queue record
        // Spring CleanUp
        //controller.ContactQueue.First_Name__c = 'TestContactExtension';
        
        //Site User instance
        /* spring cleanup
        SiteUser sUser = new SiteUser();
        sUser = SiteUserHelper.PopulateSiteUserFromConQueue(controller.Con, Controller.ContactQueue, sUser);
        */
        //Asserting for the results
        //Spring CleanUp
        //system.assertEquals('TestContactExtension', sUser.First_Name);
        
        // Set mock callout class
		//Test.setMock(HttpCalloutMock.class, new ContactExtensionMock());

        // save the contact queue
        PageReference savedPageRef = controller.SaveOverride();
        
        //Setting controller's variable
        List<SelectOption> eabRoleOptions = controller.EABRoleOptions;
        
        //Asserting for the results
        System.assertNotEquals(null, eabRoleOptions);
        System.assertNotEquals(0, eabRoleOptions.size());
        
        //Setting controller's variable
        List<SelectOption> eabDepartmentOptions = controller.EABDepartmentOptions;
        
        //Asserting for the results
        System.assertNotEquals(null, eabDepartmentOptions);
        System.assertNotEquals(0, eabDepartmentOptions.size());
        
        //Setting controller's variable
        User user = controller.ContactOwner;
        System.assertNotEquals(null,user);
        
        //Calling controller's method
        pageRef = controller.Redirect();
        System.assertNotEquals(null, pageRef);
            
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8631 - 07/07/2016 - To refactor the existing code
    /**
     * @description : Method to test out the callout in case of new user that will invoke by saveOverride method.
     * Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp
    **/
    static testMethod void testSaveOverride_NewUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating a record of Sitecore_Settings__c custom setting
        Sitecore_Settings__c siteCoreSetting = new Sitecore_Settings__c();
        siteCoreSetting.name = 'Testing';
        siteCoreSetting.AdvAdmin_URL__c = 'www.testing.com';
        siteCoreSetting.Advisory_com_SF_URL__c = 'www.testing1.com';
        siteCoreSetting.Advisory_Password_Reset_URL__c = 'www.testing2.com';
        siteCoreSetting.EAB_Password_Reset_URL__c = 'www.testing3.com';
        insert siteCoreSetting;
        
        //Test converage for the ContactEdit visualforce page
        PageReference pageRef = Page.ContactEdit;
        Test.setCurrentPageReference(pageRef);
        
        //Create Account
        Account newAccount = TestUtilities.CreateNewAccount(true);
        
        //create a new contact
        Contact myContact = new Contact();
        
        //Calling controller
        ApexPages.StandardController stdCon = new ApexPages.standardController(myContact);
        
        // create an instance of the controller
        ContactExtension controller = new ContactExtension(stdCon);
        
        // create but do not insert a contact
        Contact con = TestUtilities.CreateNewContact(newAccount, false);
        
        // create a contact queue record
        //#Spring CleanUp 
        //Contact_Queue__c conQueue = SiteUserHelper.PopulateContactQueueFromContact(Con);
        
        //Start testing from here
        Test.startTest();
        
        // create the sUser
        SiteUser sUser = new SiteUser();
        //#Spring CleanUp
       //	 sUser = SiteUserHelper.PopulateSiteUserFromConQueue(Con, conQueue, sUser);
        
		/*
        // update the sUser
        sUser = SiteUserHelper.Action_UpsertContact(sUser);
        system.assertEquals('Success', sUser.Response);
        
        //Asserting for the results
        List<Contact> cons = [SELECT Id, Owner.Name FROM Contact WHERE AccountId = :newAccount.Id];
        system.assertEquals(1, cons.size());
        system.assertEquals('Salesforce Administrator', cons[0].Owner.Name);
        
        // Set mock callout class
		Test.setMock(HttpCalloutMock.class, new ContactExtensionMock());
        
        //Calling controller method for invoking the integration
        pageRef = controller.SaveOverride();
        */
        //Stop Test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8631 - 07/07/2016 - To refactor the existing code
    /**
     * @description : Method to test out verify the contactQueue's Institution field defaulted to the Account Id we passed in.
    **/
    static testMethod void testSaveOverride_PopulateAccount() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Test converage for the ContactEdit visualforce page
        PageReference pageRef = Page.ContactEdit;
        Test.setCurrentPageReference(pageRef);
        
        //Create account
        Account newAccount = TestUtilities.CreateNewAccount(true);
        
        //create a new contact
        Contact myContact = new Contact();
        
        //Add the AccountId param to page URL - this should auto-populate some of the contact queue fields
        ApexPages.currentPage().getParameters().put('AccountId', newAccount.Id);
        
        //Start test from here
        Test.startTest();
        
        //Calling Controller
        ApexPages.StandardController stdCon = new ApexPages.standardController(myContact);
        
        // create an instance of the controller
        ContactExtension controller = new ContactExtension(stdCon);
        
        //verify the contactQueue's Institution field defaulted to the Account Id we passed in
        //Spring CleanUp
        //system.assertEquals(newAccount.Id, controller.ContactQueue.Institution_Name__c);
        system.assertNotEquals(0, controller.ConstituencyOptions.size(), 'The Constituency field should contain at least 1 picklist value.');
        system.assertNotEquals(0, controller.ManagementLevelOptions.size(), 'The Management Level field should contain at least 1 picklist value.');
    	controller = new ContactExtension();
        controller.Redirect();
        
    	//Stop test here
    	Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8631 - 07/07/2016 - To refactor the existing code
    /**
     * @description : Method to test out:-
     *              a) check to see if the ContactQueue record's values match the values from the contact we are modifying
     *              b) make some changes to the contact queue record so that it is no longer valid -- should return an error
     *Modified By - Seemu Saikia -CR-20190501-13072- 05/03/2019 - #Spring CleanUp                
    **/
    static testMethod void testSaveOverride_Error() {
        	
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Test converage for the ContactEdit visualforce page
        PageReference pageRef = Page.ContactEdit;
        Test.setCurrentPageReference(pageRef);
        
        //Create account
        Account newAccount = TestUtilities.CreateNewAccount(true);
        
        //create first contact
        Contact myContact = TestUtilities.CreateNewContact(true);
        
        //Setting URL parameters
        pageRef.getParameters().put('id', myContact.Id);
        
        //Calling controller
        ApexPages.StandardController stdCon = new ApexPages.standardController(myContact);
        
        //Start testing from here
        Test.startTest();
        
        // create an instance of the controller
        ContactExtension controller = new ContactExtension(stdCon);
        controller.RedirectURL = 'http://www.google.com';
        
        //Asserting for the results
        // check to see if the ContactQueue record's values match the values from the contact we are modifying
        //Spring CleanUp
        //system.assertEquals(myContact.FirstName, controller.ContactQueue.First_Name__c);
        
        // make some changes to the contact queue record so that it is no longer valid -- should return an error
        //Spring CleanUp
        //controller.ContactQueue.Primary_Address_Line_1__c = null; //note: this is a required field, so when we attempt to upsert, should return null
        
        // save the contact queue
        PageReference savedPageRef = controller.SaveOverride();
        
        // make sure we returned null
        system.assertEquals(null, savedPageRef);
    	
        //Stop Testing here
        Test.stopTest();
    }
}