/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Line_Item_ScheduleTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Line_Item_ScheduleTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Line_Item_Schedule__c());
    }
}