/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Royall_ProgramTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Royall_ProgramTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Royall_Program__c());
    }
}