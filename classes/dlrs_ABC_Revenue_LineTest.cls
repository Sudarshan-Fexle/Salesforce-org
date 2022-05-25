/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ABC_Revenue_LineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ABC_Revenue_LineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new ABC_Revenue_Line__c());
    }
}