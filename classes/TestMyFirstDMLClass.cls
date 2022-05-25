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
 * 	Description     :   Test class to test the functionality of insert data through DML.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   02/20/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest(seeAllData = false)
private with sharing class TestMyFirstDMLClass {
    
    //Make testSetUp data for testing purpose
    @TestSetup
    static void setUp(){
        
        //Create Account 
        Account acc = new Account(Name = 'Test');

        //Insert Account 
        insert acc;
    }

    @isTest 
    private static void testStaticDMLs() {
        
        //Fetch data from Account WHERE name is Test
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test'];

        //Create list of contacts in Account.
        List<Contact> listOfContact = new List<Contact>();
        listOfContact.add(new Contact(LastName = 'Test Contact 1', AccountId = acc.Id));
        listOfContact.add(new Contact(LastName = 'Test Contact 2', AccountId = acc.Id));
        listOfContact.add(new Contact(LastName = 'Test Contact 3', AccountId = acc.Id));
        listOfContact.add(new Contact(LastName = 'Test Contact 4', AccountId = acc.Id));
        listOfContact.add(new Contact(LastName = 'Test Contact 5', AccountId = acc.Id));

        Test.startTest();
        //Insert Contacts
        insert listOfContact;

        MyFirstDMLClass.staticDMLs();
        
        Test.stopTest();
        //Fetch updated Account's Contact data. 
        Account updatedAccount = [SELECT Id, (SELECT LastName FROM Contacts) FROM Account WHERE Id =: acc.Id];

        //Check the output of updated Account's Contact and list of contacts are equal. 
        System.assertEquals(listOfContact, updatedAccount.Contacts);
    }

}