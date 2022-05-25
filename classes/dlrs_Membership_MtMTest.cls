/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Membership_MtMTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Membership_MtMTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Membership_MtM__c());
    }
}