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
 * 	Description     :   Test class to test the functionality of each methods of SOQL class.
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
private class TestSOQLQueryClass {

    //Make testSetUp data for testing purpose
    @TestSetup
    static void setUp(){

        //Create Account 
        Account acc = new Account();
        acc.Name = 'Test 1';
        acc.Website = 'Test2.com';

        //Insert Account
		insert acc;
    }
	
    @isTest 
    static void testNormalSOQL(){
        
        //Fetch data of Account where name is Test 1.
        Account acc = [SELECT Id, Name, Website FROM Account WHERE Name = 'Test 1'];

        //Create Contact
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact 1';
        con.AccountId = acc.Id;

        //Test Perform
        Test.startTest();
        
        //Insert contact
        insert con;
        
        //Call method for test.
        SOQLQueryClass.normalSOQL();
        
        //Test end here
        Test.stopTest();

        //Fetch updated Account.
        Contact updatedContact = [SELECT Account_Website__c FROM Contact WHERE AccountId =: acc.Id];
        System.assertEquals(acc.Website, updatedContact.Account_Website__c);
    }
    
    @isTest
    static void testInlineSOQLFunction(){
        
        //Fetch data of Account where name is Test 1.
        Account acc = [SELECT Id, Contact_Details__c FROM Account WHERE Name = 'Test 1'];

        //Create list of contact for account. 
        List<Contact> listOfContact = new List<Contact>();
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 1', LastName = 'Contact 1', Email = 'test1@test.com'));
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 2', LastName = 'Contact 2', Email = 'test2@test.com'));
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 3', LastName = 'Contact 3', Email = 'test3@test.com'));

        //Test perform
        Test.startTest();

        //Insert list of contacts
        insert listOfContact;

        String allContact = '';
        for(Contact con : listOfContact){
            allContact += 'FirstName =' + con.FirstName  + ', LastName =' + con.LastName + ', Email =' + con.Email + '\n';
        }
        
        List<Id> listOfId = new List<Id>{acc.Id}; 
        SOQLQueryClass.inlineSOQLFunction(listOfId);
       
        //Test end here.
        Test.stopTest();
		 
        //Fetch updated Account data.
        Account updatedAccount = [SELECT Id, Contact_Details__c FROM Account WHERE Id =: acc.Id];
        System.assertEquals(allContact, updatedAccount.Contact_Details__c + '\n');
    }

    @isTest
    static void testAggregateSOQL(){
        
        //Fetch data of Account where name is Test 1.
        Account acc = [SELECT Id, Name, Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account WHERE Name = 'Test 1'];

        //Create list of contact for account. 
        List<Contact> listOfContact = new List<Contact>();
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 1', LastName = 'Contact 1', Status__c = 'Active'));
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 2', LastName = 'Contact 2', Status__c = 'In Active'));
        listOfContact.add(new Contact(AccountId = acc.Id, FirstName = 'Test 3', LastName = 'Contact 3', Status__c = 'In Active'));
        
        //Test perform
        Test.startTest();

        //Insert list of Contact
        insert listOfContact;
        
        SOQLQueryClass.aggregateSOQL();
        
        //Test end here.
        Test.stopTest();


        //Fetch updated Account data.
        Account updatedAccounts = [SELECT Total_Active_Contacts__c, Total_In_Active_Contacts__c FROM Account WHERE Id =: acc.Id];
        System.assertEquals(1, updatedAccounts.Total_Active_Contacts__c);
    }
}