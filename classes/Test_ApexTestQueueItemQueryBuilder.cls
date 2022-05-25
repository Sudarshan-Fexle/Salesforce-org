/**
*   Purpose         :   Test class for ApexTestQueueItemQueryBuilder
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
private class Test_ApexTestQueueItemQueryBuilder 
{ 
    static testMethod void testApexTestQueueItemQueryBuilder()
    {
        Test.startTest();
        ApexTestQueueItemQueryBuilder.returnRunTestsItemsForAJob(null);
        ApexTestQueueItemQueryBuilder.returnRunTestsItemsRelatedToJob(null);
        Test.stopTest();
    }
}