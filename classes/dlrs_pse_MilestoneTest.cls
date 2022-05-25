/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_pse_MilestoneTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_pse_MilestoneTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new pse__Milestone__c());
    }
}