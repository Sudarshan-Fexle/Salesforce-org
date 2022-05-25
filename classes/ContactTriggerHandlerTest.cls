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
 * 	Description     :   This class is for test triggers on Contact.
 *            
 *  Create By       :   Sudarshan Singh
 *
 *  Created Date    :   03/03/2022 
 *
 *  Revision Log    :   V_1.0 - Created - Fexle service
 *
 *  Coverage        :   100%
 *
 **/
@isTest(seeAllData = false)
public without sharing class ContactTriggerHandlerTest {
    
    //Make testSetUp data for testing purpose
    @TestSetup
    static void setUp(){

        //Create Accounts 
        List<Account> acc = new List<Account>();
        acc.add(new Account(Name = 'Test 1'));
        acc.add(new Account(Name = 'Test 2'));
        acc.add(new Account(Name = 'Test 3'));

        //Insert Account
		insert acc;

        //Create Contacts under accounts
        List<Contact> listOfContact = new List<Contact>();
        listOfContact.add(new Contact(AccountId = acc[0].Id, FirstName = 'Test 1', LastName = 'Contact 1', Status__c = 'Active'));
        listOfContact.add(new Contact(AccountId = acc[0].Id, FirstName = 'Test 2', LastName = 'Contact 2', Status__c = 'In Active'));
        listOfContact.add(new Contact(AccountId = acc[0].Id, FirstName = 'Test 3', LastName = 'Contact 3', Status__c = 'In Active'));
        listOfContact.add(new Contact(AccountId = acc[1].Id, FirstName = 'Test 4', LastName = 'Contact 4', Status__c = 'Active'));
        listOfContact.add(new Contact(AccountId = acc[1].Id, FirstName = 'Test 5', LastName = 'Contact 5', Status__c = 'In Active'));
        listOfContact.add(new Contact(AccountId = acc[1].Id, FirstName = 'Test 6', LastName = 'Contact 6', Status__c = 'Active'));
        listOfContact.add(new Contact(AccountId = acc[2].Id, FirstName = 'Test 7', LastName = 'Contact 7', Status__c = 'In Active'));

        //Insert Contact
        insert listOfContact;

    }

    /**
    * 
    *   @description    :   Test a trigger to populate Total Active Contact and Total In Active Contacts field with the total Active and inactive contacts under the Account.
    *
    *   @args           :   none
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 03/05/2022 - Sudarshan singh - Comment
    * 
    **/
    @isTest
    static void testUpdateActiveInActiveFields(){        
        
        //Test start here
        Test.startTest();
        
        List<Account> listOfAccounts = [SELECT Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account];
        System.assertEquals( 1, listOfAccounts[0].Total_Active_Contacts__c);
        System.assertEquals( 2, listOfAccounts[0].Total_In_Active_Contacts__c);

        System.assertEquals( 2, listOfAccounts[1].Total_Active_Contacts__c);
        System.assertEquals( 1, listOfAccounts[1].Total_In_Active_Contacts__c);

        System.assertEquals( 0, listOfAccounts[2].Total_Active_Contacts__c);
        System.assertEquals( 1, listOfAccounts[2].Total_In_Active_Contacts__c);

        //Insert new contact in Account where name is Test 3
        Contact newCon = new Contact(AccountId = listOfAccounts[2].Id, FirstName = 'Test 8', LastName = 'Contact 8', Status__c = 'Active');
        insert newCon;

        //Fetch updated Account and check Active and In Active Contacts.
        Account updatedAccount3 = [SELECT Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account WHERE Name = 'Test 3'];
        System.assertEquals( 1, updatedAccount3.Total_Active_Contacts__c);

        //Fetch contact to update status field
        Contact updateCon = [SELECT Status__c FROM Contact WHERE LastName = 'Contact 4'];
        updateCon.Status__c = 'In Active';
        update updateCon;

        //Fetch Account and check Active and In Active Contacts.
        Account updatedAccount2 = [SELECT Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account WHERE Name = 'Test 2'];
        System.assertEquals( 1, updatedAccount2.Total_Active_Contacts__c);
        
        //Fetch all the Contacts that under Test 3 Account
        List<Contact> deleteCon = [SELECT Id FROM Contact WHERE Account.Name = 'Test 3'];
        delete deleteCon;

        //check Active and In Active Contacts.
        Account deletedContactOfAccount3 = [SELECT Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account WHERE Name = 'Test 3'];
        System.assertEquals( 0, deletedContactOfAccount3.Total_Active_Contacts__c);

        //Test end here
        Test.stopTest();

    }
}