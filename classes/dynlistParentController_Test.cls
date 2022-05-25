/*
Purpose         :   Test Class for "dynlistParentController" apex class
Created By      :   Abhinav Sharma
Created Date    :   11/12/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/12/2021
Dev Comment 	:  
*/
@isTest(seeAllData=false)
private without sharing class dynlistParentController_Test 
{
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {
        //Accounts
        List<Account> accounts = dynlistTestDataFactory.createListOfAccountsTestData();
        
        //Create Contact record for testings
        Contact contact = dynlistTestDataFactory.createContactTestData();
    }
    
    //this method is basically to test all the use cases associated with "dynlistParentController.dynlistParentController" constructor
    @isTest(seeAllData=false)
    static void testDynlistParentController()
    {
        //Start test from here
        Test.startTest();
        
        //Calling constructor
        dynlistParentController constructor = new dynlistParentController();
        System.assert(constructor!=null);
        
        //Test end here
        Test.stopTest();
    }
    
    //this method is basically to test all the use cases associated with "dynlistParentController.queryRecords" method
    @isTest(seeAllData=false)
    static void testQueryRecords()
    {
        //Calling constructor
        dynlistParentController constructor = new dynlistParentController();
        constructor.respectSharing = true;
        
        //Start test from here
        Test.startTest();
        
        //Use Case 1 - When respectSharing = true
        constructor.queryRecords();
        System.assert(constructor.modeExecuted == 'With Sharing');
        //Use Case 1 - End here
        
        //Use Case 2 - When respectSharing = false
        constructor.respectSharing = false;
        constructor.queryRecords();
        System.assert(constructor.modeExecuted == 'Without Sharing');
        //Use Case 2 - End here
        
        //Test end here
        Test.stopTest();
    }
}