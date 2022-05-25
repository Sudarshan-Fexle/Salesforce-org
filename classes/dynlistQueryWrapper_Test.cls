/*
Purpose         :   Test Class for "dynlistQueryWrapper" apex class
Created By      :   Abhinav Sharma
Created Date    :   09/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 09/09/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistQueryWrapper_Test 
{
    //this method is basically to test all the use cases associated with "dynlistQueryWrapper" Class
    @isTest(seeAllData=false)
    static void testDynlistQueryWrapper()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case Testing wrapper Class
        //START FROM HERE
        
        dynlistQueryWrapper dynlistQuery = new dynlistQueryWrapper();
        dynlistQuery.queryString = 'Select Id,Name,AccountId From Contact';
        dynlistQuery.isAllFieldsInAccessible = true;
        system.assert(dynlistQuery != null);
        
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
}