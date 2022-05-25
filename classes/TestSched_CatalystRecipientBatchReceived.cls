/** 
    *  Purpose         :  Helper class for Sched_CatalystRecipientBatchReceived
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    *
    *  Code Coverage   :  100%
    **/
@isTest(seeAllData = false)
public class TestSched_CatalystRecipientBatchReceived 
{
    @IsTest static void test_Sched_CatalystRecipientBatchReceived ()
    {
        Test.startTest();
        Sched_CatalystRecipientBatchReceived sched = new Sched_CatalystRecipientBatchReceived(); 
        sched.execute(null);
        Test.stopTest();
    } 
}