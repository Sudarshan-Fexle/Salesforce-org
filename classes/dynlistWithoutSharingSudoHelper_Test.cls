/*
Purpose         :   Test Class for "dynlistWithoutSharingSudoHelper" apex class
Created By      :   Abhinav Sharma
Created Date    :   11/12/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/12/2021
Dev Comment 	:  
*/
@isTest(seeAllData=false)
private without sharing class dynlistWithoutSharingSudoHelper_Test 
{
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {
        //Accounts
        List<Account> accounts = dynlistTestDataFactory.createListOfAccountsTestData();
    }
    
    //this method is basically to test all the use cases associated with "dynlistWithoutSharingSudoHelper.doQuery" method
    @isTest(seeAllData=false)
    static void testDoQuery()
    {
        //Create records for testings
        //Query
        String query = 'Select Id, Name From Account';
        
        //Start test from here
        Test.startTest();
        List<Account> accountRecords = (List<Account>)dynlistWithoutSharingSudoHelper.doQuery(query);
        System.assert(accountRecords.size()>0);
        
        //Test end here
        Test.stopTest();
    }
    
    //this method is basically to test all the use cases associated with "dynlistWithoutSharingSudoHelper.doInsert" method
    @isTest(seeAllData=false)
    static void testDoInsert()
    {
        //Create records for testings
        //Account
        Account account = (Account)dynlistSmartFactory.createSObject('Account');
        
        //Start test from here
        Test.startTest();
        //Use Case 1 - With one argument -  doInsert(sObject recordToInsert) 
        Database.SaveResult result = dynlistWithoutSharingSudoHelper.doInsert(account);
        System.assert(result.Id != null);
        //Use Case 1 - End here
        
        //Use Case 2 - With one argument -  doInsert(sObject recordToInsert, Boolean opt_allOrNone)
        Boolean opt_allOrNone = false;
        result = dynlistWithoutSharingSudoHelper.doInsert(account, opt_allOrNone);
        System.assert(result.Id == null);
        //Use Case 2 - End here
        
        //Test end here
        Test.stopTest();
    }
    
    //this method is basically to test all the use cases associated with "dynlistWithoutSharingSudoHelper.doUpdate" method
    @isTest(seeAllData=false)
    static void testDoUpdate()
    {
        //Create records for testings
        //Account for update
        Account acc = [Select Id, Name From Account Limit 1];
        acc.Name =  'Test Account';
        
        //Start test from here
        Test.startTest();
        //Use Case 1 -  doUpdate(sObject recordToInsert) 
        Database.SaveResult result = dynlistWithoutSharingSudoHelper.doUpdate(acc);
        System.assert(result.Id != null);
        //Use Case 1 -  End here
        
        //Use Case 2 - With one argument -  doUpdate(sObject recordToInsert, Boolean opt_allOrNone)
        Boolean opt_allOrNone = false;
        result = dynlistWithoutSharingSudoHelper.doUpdate(acc, opt_allOrNone);
        System.assert(result.Id != null);
        //Use Case 2 - End here
        
        //Test end here
        Test.stopTest();
    }
}