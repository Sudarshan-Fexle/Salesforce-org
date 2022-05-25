/**
*   Purpose         :   Test class for ProcessOverallOrgDetailsJob 
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   02/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_ProcessOverallOrgDetailsJob 
{
    
    
    static testMethod void  testProcessOverallOrgDetailsJob()
    {
        
        Test.startTest();
        RunAllTestsResultsWrapper wrapper = new RunAllTestsResultsWrapper('Test', null);
        Test.setMock(HttpCalloutMock.class,new MockHTTPResponseGenerator());
        ProcessOverallOrgDetailsJob procOverAllOrgDetails = new ProcessOverallOrgDetailsJob(wrapper);
        System.enqueueJob(procOverAllOrgDetails);
       	Test.stopTest();
    }
}