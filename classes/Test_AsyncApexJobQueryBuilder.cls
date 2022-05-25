/**
*   Purpose         :   Test class for AsyncApexJobQueryBuilder
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 100%
*
**/
@isTest(seeAllData = false)
private class Test_AsyncApexJobQueryBuilder 
{
    static testMethod void testAsyncApexJobQueryBuilder()
    {
        Test.startTest();
        AsyncApexJobQueryBuilder.getJobsRelatedToBatch(null);
        Test.stopTest();
    }
}