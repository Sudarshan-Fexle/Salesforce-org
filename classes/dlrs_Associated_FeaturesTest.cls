/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Associated_FeaturesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Associated_FeaturesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Associated_Features__c());
    }
}