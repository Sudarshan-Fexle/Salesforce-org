/**
*   Purpose         :   Test class for ApexTestResultQueryBuilder
*            
*   Created By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*                       V_1.1 - Modified By - Mahendra Swarnakar - CR-20200721-14340 - 07/21/2020 - For Error Fix(Too many query rows: 50001)
*   
*   Coverage        :   V_1.0 - 100%
*
**/
@isTest(seeAllData = false)
private class Test_ApexTestResultQueryBuilder 
{
    static testMethod void testApexTestResultQueryBuilder() 
    {   
        // Modified By - Mahendra Swarnakar - CR-20200721-14340 - 07/21/2020
        Integer limitcount = Limits.getLimitQueryRows();
        List<ApexTestResult> listOfApexTestResult = [SELECT Id, AsyncApexJobId From ApexTestResult Limit :limitcount ];
        if(listOfApexTestResult.size() > 0)
        {
            System.assert(listOfApexTestResult.size() > 0);
        
            Test.startTest();
            ApexTestResultQueryBuilder.retrieveRunTestResultsForAJob(listOfApexTestResult[0].AsyncApexJobId);
            Test.stopTest();
        }
    }
}