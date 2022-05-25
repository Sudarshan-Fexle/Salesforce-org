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
 //V1.1 - Added By - Saurabh Kumar - 10/27/2020 - Lookup Controller - testGetResults
@isTest(seeAllData = false) 
private class Test_AdvancedLookupController {
    
	//Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
      
        //List of Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccounts1'));
        accounts.add(new Account(Name = 'TestAccounts2'));
        accounts.add(new Account(Name = 'TestAccounts3'));
        accounts.add(new Account(Name = 'TestAccounts4'));
       
        //Insert Accounts 
        insert accounts;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[1].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact3', LastName = 'Contact3', Email = ' Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[2].Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact
        insert contacts;
      
    }
    //Test method to perform Lookup Functionality 
    static testMethod void testGetResults(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        Test.startTest();
        System.assertEquals(1, AdvancedLookupController.getResults('Contact','TestContact1', '').size());
        System.assertEquals(3, AdvancedLookupController.getResults('Contact','', '').size());
        System.assertEquals(1, AdvancedLookupController.getResults('Contact','Contact3', 'LastName = \'' + String.escapeSingleQuotes('Contact3')+ '\'').size());
        System.assertEquals(1, AdvancedLookupController.getResults('Contact','', 'LastName = \'' + String.escapeSingleQuotes('Contact3')+ '\'').size());
        Test.stopTest();
    }
}