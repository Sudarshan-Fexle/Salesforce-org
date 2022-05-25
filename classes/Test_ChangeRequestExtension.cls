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
@isTest(seeAllData = false)
public class Test_ChangeRequestExtension {
    
/**
    Purpose         :   Test class for ChangeRequestExtension
                
    Create By       :   Abhinav Sharma 
    
    Created Date    :   06/06/2016
    
    Revision Log    :   v1.0 - Created - Abhinav Sharma - CR-20150202-8629

    Coverage        :   v1.0 - ChangeRequestExtension - 92%
**/
    
    /**
     * @description: Common method to invoke various setup methods for creating the test data.
    **/
    //Setup test data
    @testSetup static void setup() {
        Test_ChangeRequestExtension.setupTestData();
    }
        
    /**
     * @description: 1) Creating "Employee" type contact record.
    **/
    @TestVisible private static void setupTestData() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Employee Contact record type
        Id contactEmployeeRTTypeId = Util.RecordTypeId(TestUtilities.CONTACT_OBJECT, TestUtilities.CONTACT_EMPLOYEE_RECORD_TYPE);
        System.assert(contactEmployeeRTTypeId != null);
        
        //create new Contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.RecordTypeId = contactEmployeeRTTypeId;
        insert contact;
        
        //Assert for result
        System.assert(contact != null);
    }
    
    /**
     * @description : Test method to check for various use cases associated with a change request insert/update events.
     *                a) When "IS_Team_Involved__c" field is containing duplicate names with it and should results as an error.
     *                b) When "IS_Team_Involved__c" field is containing unqiue names with it and should not results as an error.
     *                c) Few other associated sub use cases.    
     * 
    **/
    static testMethod void testSaveOverrideFuncationality(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List of contacts
        List<Contact> contacts = [SELECT ID, LastName FROM Contact LIMIT 2];
        
        //Asserting for the results
        System.assert(contacts != null);
        System.assertEquals(1, contacts.size());
        
        //Level II Change Request record type
        Id changeRequestLIIRTTypeId = Util.RecordTypeId(TestUtilities.CHANGE_REQUEST_OBJECT, TestUtilities.CHANGE_REQUEST_RECORD_TYPE_LEVEL_II);
        System.assert(changeRequestLIIRTTypeId != null);
        
        //Create a Change Request record
        SFDC_Change_Request__c changeRequest = TestUtilities.CreateChangeRequest(false);
        changeRequest.RecordTypeId = changeRequestLIIRTTypeId;
        changeRequest.IS_Team_Involved__c = 'Testing, Testing, Testing1, Testing2,';
        insert changeRequest;
        
        //Asserting for the results
        System.assertNotEquals(null, changeRequest);
        
        //Setting URL paramters
        ApexPages.currentPage().getParameters().put('RecordType', changeRequestLIIRTTypeId);
        ApexPages.currentPage().getParameters().put('save_new', '1');
        ApexPages.currentPage().getParameters().put('retURL','www.testing.com');
        
        //Instance of controller extension class
        ChangeRequestExtension controller;
        
        //Start test from here
        Test.startTest();
        
        //Invoke the VF page
        controller = new ChangeRequestExtension(new ApexPages.StandardController(changeRequest));
        
        //Invoking "SaveOverride" method
        Pagereference pg = controller.SaveOverride();
        
        //Asserting for results
        System.assert(pg == null);
        System.assert(ApexPages.hasMessages());
        System.assert(ApexPages.getMessages() != null);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assert(controller.AllUsers != null);
        System.assertEquals(1, controller.AllUsers.size());
        System.assert(controller.errorString != null);
        //System.assertEquals(true, controller.IsLevel2);
        //System.assertEquals(false, controller.IsLevel3);
        System.assertEquals(true, controller.IsNew);
        System.assertEquals(false, controller.IsSystemOutage);
        System.assert(controller.ReturnURL != null);
        System.assertEquals(String.valueOf(changeRequestLIIRTTypeId), controller.RecordTypeId);
        System.assert(controller.redirectToView() != null);
        
        //Calling controller's method
        pg = controller.redirect();
        //System.assert(pg == null);   
        
        //Calling controller method
        controller.IsLevel2 = false;
        pg = controller.redirect();
        System.assert(!controller.IsLevel2);
        System.assert(!controller.IsLevel3);
        System.assert(!controller.IsSystemOutage);
        System.assert(pg != null);
        
        //Re-Initializng change request instance
        changeRequest = new SFDC_Change_Request__c();
        changeRequest = TestUtilities.CreateChangeRequest(false);
        changeRequest.RecordTypeId = changeRequestLIIRTTypeId;
        changeRequest.IS_Team_Involved__c = 'Testing,';
        insert changeRequest;
        
        //Invoke the VF page
        controller = new ChangeRequestExtension(new ApexPages.StandardController(changeRequest));
        controller.ChangeRequest = changeRequest;
        
        //Invoking "SaveOverride" method
        pg = controller.SaveOverride();
        
        //Asserting for results
        System.assert(pg != null);
        System.assert(controller.AllUsers != null);
        System.assert(controller.errorString == null);
        //System.assertEquals(true, controller.IsLevel2);
        //System.assertEquals(false, controller.IsLevel3);
        System.assertEquals(true, controller.IsNew);
        System.assertEquals(false, controller.IsSystemOutage);
        System.assert(controller.ReturnURL != null);
        System.assertEquals(String.valueOf(changeRequestLIIRTTypeId), controller.RecordTypeId);
        System.assert(controller.redirectToView() != null);
        System.assert(ApexPages.getMessages() != null);
        System.assertEquals(1, ApexPages.getMessages().size());
        
        //Creating instance on Change Request
        SFDC_Change_Request__c ch = new SFDC_Change_Request__c();
        
        //Re-intilization controller
        controller = new ChangeRequestExtension(new ApexPages.StandardController(ch));
        
        //Calling controller's method
        pg = controller.SaveOverride();
        controller.IsLevel2 = false;
        String recordTypeId = controller.RecordTypeId;
        pg = controller.redirect();
        //System.assert(pg != null);
    } 
    
    /**
     * @description : Test method to get coverage and assertions for miscellaneous code logic.
     * 
    **/
    static testMethod void testMiscellaneousFunctionalities() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List of contacts
        List<Contact> contacts = [SELECT ID, LastName FROM Contact LIMIT 2];
        
        //Asserting for the results
        System.assert(contacts != null);
        System.assertEquals(1, contacts.size());
        
        //Level III Change Request record type
        Id changeRequestLIIIRTTypeId = Util.RecordTypeId(TestUtilities.CHANGE_REQUEST_OBJECT, TestUtilities.CHANGE_REQUEST_RECORD_TYPE_LEVEL_II);
        System.assert(changeRequestLIIIRTTypeId != null);
        
        //Create a Change Request record
        SFDC_Change_Request__c changeRequest = TestUtilities.CreateChangeRequest(false);
        changeRequest.RecordTypeId = changeRequestLIIIRTTypeId;
        changeRequest.IS_Team_Involved__c = 'Testing,Testing1';
        insert changeRequest;
        
        //Asserting for the results
        System.assertNotEquals(null, changeRequest);
        
        //Setting URL paramters
        ApexPages.currentPage().getParameters().put('save_new', '0');
        ApexPages.currentPage().getParameters().put('retURL','www.testing.com');
        
        //Instance of controller extension class
        ChangeRequestExtension controller;
        
        //Start test from here
        Test.startTest();
        
        //Invoke the VF page
        controller = new ChangeRequestExtension(new ApexPages.StandardController(changeRequest));
        
        //Invoking "SaveOverride" method
        Pagereference pg = controller.SaveOverride();
        
        //Asserting for results
        System.assert(pg != null);
        System.assert(controller.AllUsers != null);
        System.assert(controller.errorString == null);
        //System.assertEquals(false, controller.IsLevel2);
        //System.assertEquals(true, controller.IsLevel3);
        System.assertEquals(false, controller.IsNew);
        System.assertEquals(false, controller.IsSystemOutage);
        System.assert(controller.ReturnURL != null);
        System.assert(controller.redirectToView() != null);
        //System.assert(controller.redirect() == null);
       
        //Stop test here
        Test.stopTest();    
    }    
}