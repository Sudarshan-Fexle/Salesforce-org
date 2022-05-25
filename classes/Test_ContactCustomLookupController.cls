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
private class Test_ContactCustomLookupController{
    /**
    *  Purpose         :  Test class for ContactCustomLookupController
    *               
    *  Created By      :  Dipesh Gupta
    *   
    *  Created Date    :  6/4/2020 
    *   
    *  Revision Log    :   v1.0  
    *                       
    *  Coverage        :    
    **/
    
    @testSetup static void setup() {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        
        //CustomLookupController.search();
        // create account
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        
        //Insert
        insert accounts;
        //
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        Contact con = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        contacts.add(contact);
        
        //Insert
        insert contacts;
        
        //Custom setting record
        ShipIt_Settings__c setting = new ShipIt_Settings__c();
        setting.Name = 'ContactSearchLimit';
        setting.Value__c = '1';
        insert setting ;
        
       }
        
       @isTest static void test_ContactCustomLookupControllerMethod(){
        
        Test.startTest();
        
         Test.setCurrentPageReference(new PageReference('Page.ContactCustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', 'Test Contact');
        System.currentPageReference().getParameters().put('lookupFor', 'Marketer');
        
        ContactCustomLookupController ctrl = new ContactCustomLookupController();
        ctrl.search();
        ctrl.getTextBox();
        ctrl.getFormTag();
        ctrl.clearSearchResults();
        
        system.assertEquals('Test Contact',ctrl.searchString);
        system.assertEquals(false,ctrl.isAnyListPopulated); 
        system.assertEquals(0,ctrl.results.size()); 
        Test.stopTest();
        
        }
        
        @isTest static void test_ContactCustomLookupWithBlankSrch(){
        
        Test.startTest();
        
         Test.setCurrentPageReference(new PageReference('Page.ContactCustomLookup')); 
        System.currentPageReference().getParameters().put('lksrch', '');
        System.currentPageReference().getParameters().put('lookupFor', 'Marketer');
        
        ContactCustomLookupController ctrl = new ContactCustomLookupController();
        ctrl.getTextBox();
        ctrl.getFormTag();
        ctrl.clearSearchResults();
        
        system.assertEquals('',ctrl.searchString);
        system.assertEquals(false,ctrl.isAnyListPopulated); 
        system.assertEquals(0,ctrl.results.size()); 
        Test.stopTest();
        
        }
}