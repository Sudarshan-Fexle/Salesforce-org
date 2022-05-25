/**
*   Purpose         :   Test class for BatchExecuteRunAllTests
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_BatchExecuteRunAllTests 
{
    static testMethod void testBatchExecuteRunAllTests()
    {
        Test.startTest();
        BatchExecuteRunAllTests batchExe = new BatchExecuteRunAllTests();
        DataBase.executeBatch(batchExe); 
        Test.stopTest();   
    }   
}