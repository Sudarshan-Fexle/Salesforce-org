/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Billing_Schedule_PeriodTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Billing_Schedule_PeriodTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Billing_Schedule_Period__c());
    }
}