/**
*   Purpose         :   Test class for CoreUtilities
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_CoreUtilities 
{
    static testMethod void testBatchExecuteRunAllTests()
    {
        List<String> listOfString = new List<String>{'Test1',';','Test2'};
        Datetime currentdate = System.now();
     	Test.startTest();
        CoreUtilities.listToSemiColonSeperatedString(listOfString);
        CoreUtilities.isValidEmailAddress('salesforce@fexle.com');
        CoreUtilities.parseNull(null);
        CoreUtilities.formatToAlphabatical('@Test1');
        CoreUtilities.HtmlToText('<h1>Hello world!</h1>');
        CoreUtilities.getChronExpressionFromDateTime(currentdate);
        CoreUtilities.unscheduleJobsWithoutNextFireDate();
        CoreUtilities.replaceAllCommaWithBlankString('Testing1');
        CoreUtilities.doPercentageCalculation(270,30,2);
        CoreUtilities.getInstanceName();
        Test.stopTest();   
    }
    
    static testMethod void NegCaseForBatchExecuteRunAllTests()
    {
    	Test.startTest();
        CoreUtilities.listToSemiColonSeperatedString(null);
        CoreUtilities.isValidEmailAddress('salesforce#fexle.com');
        CoreUtilities.parseNull('Test');
        CoreUtilities.formatToAlphabatical(null);
        CoreUtilities.replaceAllCommaWithBlankString(null);
        CoreUtilities.doPercentageCalculation(270,null,2);
        CoreUtilities.doPercentageCalculation(270,null,null);
        Test.stopTest();
    }
}