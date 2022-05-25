/**
*   Purpose         :   Test class for RunAllTestsResultsWrapper
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
private class Test_RunAllTestsResultsWrapper 
{
    static testMethod void testRunAllTestsResultsWrapper()
    {
        RunAllTestsResultsWrapper wrapper = new RunAllTestsResultsWrapper('Test', null);
    }
}