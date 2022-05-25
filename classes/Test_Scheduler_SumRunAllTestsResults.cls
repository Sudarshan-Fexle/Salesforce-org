/**
* Purpose : Test class for Scheduler_SumRunAllTestsResults
*
* Create By : Abhinav Sharma
*
* Created Date : 01/01/2020
*
* Revision Log : V_1.0 - Created - Abhinav Sharma
*
* Coverage : V_1.0 - Modified - Rajeev Jain - 09/03/2020 - L1 Weekly Release - 9/3 Bug Fixes
*
**/
@isTest(seeAllData = false)
private class Test_Scheduler_SumRunAllTestsResults
{
static testMethod void testSchedulerSummarizeRunAllTest()
{
    Test.startTest();
    Scheduler_SummarizeRunAllTestsResults scheduleApex = new Scheduler_SummarizeRunAllTestsResults(null,'Test',false,true);
    
    // Modified By - Rajeev Jain - 09/03/2020 - L1 Weekly Release - 9/3 Bug Fixes
    DateTime sysTime = dateTime.now().addHours(12);
    String cronExp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    String jobId = System.schedule('Test', cronExp, scheduleApex);
    Test.stopTest();
    }
}