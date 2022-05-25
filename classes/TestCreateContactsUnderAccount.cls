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

/**
 * 	Description     :   Test class to test the functionality of validate contacts under Accounts.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   02/21/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest(seeAllData = false)
private with sharing class TestCreateContactsUnderAccount {
    
    //Make testSetUp data for testing purpose
    @TestSetup
    static void setUp(){
        
        //Create Account 
        Account acc = new Account(Name = 'Test', Contact_Details__c = 'FirstName = Test 1, LastName = Contact 1, Email = test1@test.com \n FirstName = Test 2, LastName = Contact 2, Email = test2@test.com');

        //Insert Account 
        insert acc;

        //Create Contacts under account.
        List<Contact> con = new List<Contact>();
        con.add(new Contact(AccountId = acc.id, FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com'));
        con.add(new Contact(AccountId = acc.id, FirstName = 'Test12', LastName = 'Contact12', Email = 'test12@test.com'));
        con.add(new Contact(AccountId = acc.id, FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test1@test.com'));
        insert con;
    }

    @isTest
    private static void testValidateContactsUnderAccount() {
        
        Account acc = [SELECT Id, Contact_Details__c FROM Account WHERE Name = 'Test'];
        
        //Create list of AccountId.
        List<Id> listOfId = new List<Id>{acc.Id};
        //Call the class method for test.
        CreateContactsUnderAccount.validateContactsUnderAccount(listOfId);
		
        //Fetch updated contact from Contacts.
        List<Contact> updatedContact = [SELECT AccountId, FirstName, LastName, Email FROM Contact WHERE AccountId =: acc.Id];
        System.assertEquals(2, updatedContact.size());
    }

}