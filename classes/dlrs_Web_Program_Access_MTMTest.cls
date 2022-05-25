/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Web_Program_Access_MTMTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Web_Program_Access_MTMTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Web_Program_Access_MTM__c());
    }
}