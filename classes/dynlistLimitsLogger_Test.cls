/*
Purpose         :   Test Class for "dynlistLimitsLogger" apex class
Created By      :   Abhinav Sharma
Created Date    :   01/10/2022
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 01/10/2022
*/
@isTest(seeAllData=false)
private without sharing class dynlistLimitsLogger_Test 
{
    @isTest(seeAllData=false)
    static void testUnitTests()
    {
        //Start test from here
        Test.startTest();
        
        Integer cnt = dynlistLimitsLogger.getMaxAllowedQueryRowsCount();
        System.assert(cnt != null);
        
        //stop test here
        Test.stopTest();
    }
}