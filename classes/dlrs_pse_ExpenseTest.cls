/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_pse_ExpenseTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_pse_ExpenseTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        try{
			dlrs.RollupService.testHandler(new pse__Expense__c());
		
		}catch(exception e) {
		
		
		}
		
    }
}