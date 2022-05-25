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
private class testRestrictionController {
/*
 *  Purpose         :   Test Class for RestrictionController
 *                
 *  Created By      :  
 *    
 *  Created Date    :   
 *    
 *  Revision Log    :   V1.0 Created
 *                      V1.1 - Bhavi SFContractor - 06/20/2012 - Added test method for CR-20120302-530
 *                      v1.2 - Modified By - Abhinav Sharma - 07/13/2016 - CR-20150202-8639
 *
 *  Coverage        :   v1.1 - 06/20/2012 - 77%
 *                      v1.2 - 07/13/2016 - 91%
 *                  
*/

    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out various functionalities/logics that will execute when the page will load.
    **/
    static testmethod void testInitializeController() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // Create a dummy restriction record and get the standard controller
        Restrictions__c restriction = new Restrictions__c();
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // set the page
        test.setCurrentPage(Page.Restriction);
        
        // set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        
        //Start test from here
        Test.startTest();
        
        //Calling standard controller
        RestrictionController controller = new RestrictionController(standardController);
        
        //Assert that there is only 1 item in the list of MTMs to display
        system.assertEquals(1, controller.RestrictionMTMsForDisplay.size());
        system.assertEquals(acc.Id, controller.RestrictionMTMsForDisplay[0].RestrictionMTM.Account__c);
        
        //Retrieving object types
        List<SelectOption> selectOptions = controller.ObjectTypes;
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out "Add Restriction" button related functionality.
    **/
    static testmethod void testAddRestrictionMTM() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // create a contact with a title
        Contact con = TestUtilities.CreateNewContact(false);
        con.Title = 'Head Honcho';
        insert con;
        
        // Create a dummy restriction record and get the standard controller
        Restrictions__c restriction = new Restrictions__c();
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // set the page
        test.setCurrentPage(Page.Restriction);
        
        // set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        
        //Start test from here
        Test.startTest();
        
        //Calling the standard controller instance
        RestrictionController controller = new RestrictionController(standardController);
        
        // add a MTM (simulate a click to the 'Add' button)
        controller.AddRestrictionMTM();
        
        // assert that there is only 1 item in the list of MTMs to display
        system.assertEquals(2, controller.RestrictionMTMsForDisplay.size());
        system.assertEquals(acc.Id, controller.RestrictionMTMsForDisplay[0].RestrictionMTM.Account__c);
        
        //Clicking on the add button one more time
        controller.AddRestrictionMTM(con.Id);
        
        //Asserting for the results
        system.assertEquals(3, controller.RestrictionMTMsForDisplay.size());
        
        //Click on "Cancel" button
        controller.Cancel();
        
        //Stop test here'
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out "Save" button related funcationality.
    **/
    static testmethod void testSave_Success() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // setup a fake return url
        string retUrl = 'http://www.google.com/';
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // Create a dummy restriction record and get the standard controller
        Restrictions__c restriction = new Restrictions__c();
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // set the page
        test.setCurrentPage(Page.Restriction);
        
        // set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('retURL',retUrl);
        
        //Start testing from here
        Test.startTest();
        
        //Calling standard controller
        RestrictionController controller = new RestrictionController(standardController);
        
        // without filling out any of the required fields, attempt to save.  should return null
        PageReference pg = Controller.Save();
        
        //Asserting for the results
        system.assertEquals(retUrl, pg.getUrl());
        
        //test will stop here
        Test.stopTest();
        
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out "Delete" button related funcationality.
    **/
    static testmethod void testDeleteMTM() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // setup a fake return url
        string retUrl = 'http://www.google.com/';
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // Create a dummy restriction record and get the standard controller
        Restrictions__c restriction = new Restrictions__c();
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // set the page
        test.setCurrentPage(Page.Restriction);
        
        // set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('retURL',retUrl);
        
        //Start test from here
        Test.startTest();
        
        //Calling standard controller
        RestrictionController controller = new RestrictionController(standardController);
        
        // add a MTM (simulate a click to the 'Add' button)
        controller.AddRestrictionMTM();
        
        // now delete the restrictionMTM
        controller.RestrictionMTMsForDisplay[1].IsDeleted = true;
        
        // assert that there is only 1 item in the list of MTMs to display
        system.assertEquals(1, controller.RestrictionMTMsForDisplay.size());
        system.assertEquals(acc.Id, controller.RestrictionMTMsForDisplay[0].RestrictionMTM.Account__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out "Edit Existing Restriction" related funcationality.
    **/
    static testmethod void testEditExistingRestriction() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // setup a fake return url
        string retUrl = 'http://www.google.com/';
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        // Create a restriction record
        Restrictions__c restriction = new Restrictions__c();
        insert restriction;
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // create a restriction mtm record to link to this restriction
        Restricted_MtM__c restrictionMTM = new Restricted_MtM__c();
        restrictionMTM.Account__c = acc.Id;
        restrictionMTM.Restriction__c = restriction.Id;
        insert restrictionMTM;
        
        // now load up the existing restriction
        test.setCurrentPage(Page.Restriction);
        
        // set the id to the existing restriction id
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.currentPage().getParameters().put('retURL',retUrl);
        
        //Start testing from here
        Test.startTest();
        
        //Calling controller
        RestrictionController controller = new RestrictionController(standardController);
        
        //Assert for the results
        system.assertEquals(1, controller.RestrictionMTMsForDisplay.size());
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8639 - To refactor the existing code
    /** Description : Method to test out the send email notification functionality - CR-20120302-530                    
    **/
    
    //Only coverage will be here as Salesforce can not send email from test methods
    static testmethod void testSendNotificationFunctionality() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // create an account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Create a contact record
        Contact contact = new Contact(LastName = 'Test', AccountId = acc.Id, Email = 'test@test.com', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Create a new opportunity record
        TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        // Create a restriction record
        Restrictions__c restriction = new Restrictions__c();
        insert restriction;
        
        //instantiate standard controller
        ApexPages.standardController standardController = new ApexPages.standardController(restriction);
        
        // create a restriction mtm record to link to this restriction
        Restricted_MtM__c restrictionMTM = new Restricted_MtM__c();
        restrictionMTM.Contact__c = contact.Id;
        restrictionMTM.Restriction__c = restriction.Id;
        insert restrictionMTM;
        
        // set the id to the existing restriction id
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        
        //start test from here
        Test.startTest();
        
        //Instantiate controller
        RestrictionController controller = new RestrictionController(standardController);
        
        //Set Email_Renewal_Opportunity_Owners_Summary__c flag
        controller.Restriction.Email_Renewal_Opportunity_Owners_Summary__c = true;
        
        //Clicking on the add button one more time
        controller.AddRestrictionMTM(contact.Id);
        
        //Call save method for coverage
        controller.Save();
        
        //Asserting for the results
        System.assert(controller.RestrictionMTMList != null);
        System.assertEquals(2, controller.RestrictionMTMList.size());
        
        //Setting object type
        String str = controller.RestrictionMTMList[0].ObjectType;
        
        controller.RestrictionMTMList[0].IsDeleted = true;
        
        //Call save method for coverage
        controller.Save();
        
        //Asserting for the results
        System.assert(controller.RestrictionMTMList != null);
        System.assertEquals(2, controller.RestrictionMTMList.size());
        
        //Setting objecttype to null
        controller.RestrictionMTMList[0].ObjectType = null;
        
        //Clicking on the add button one more time
        controller.AddRestrictionMTM(restrictionMTM.Id);
        
        //Stop test here
        Test.stopTest();
        
        //Call save method for coverage
        controller.Save();
        
        //Asserting for the results
        System.assert(controller.RestrictionMTMList != null);
        System.assertEquals(3, controller.RestrictionMTMList.size());
        
        
    }
}