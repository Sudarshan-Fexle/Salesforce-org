/** 
*  Purpose         :  Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
* 
*  Created By      :   Mahendra Swarnakar
*
*  Created Date    :   
*
*  Revision Logs   :   V_1.0 - Created  - CR-20210323-15016

**/
@IsTest
private class dlrs_Recipient_BatchTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Recipient_BatchTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Recipient_Batch__c());
    }
}