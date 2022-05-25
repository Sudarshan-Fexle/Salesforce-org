/**
*   Purpose         :   Test class for ApexClassesCoverageDetailsWrapper
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   01/01/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma
*   
*   Coverage        :   V_1.0 - 100%
*
**/
@isTest(seeAllData = false)
private class Test_ApexClassesCoverageDetailsWrapper 
{
    static testMethod void testApexClassesCoverageDetailsWrapper()
    {
        Test.startTest();
        ApexClassesCoverageDetailsWrapper apexClassDetailWrapper = new ApexClassesCoverageDetailsWrapper();
        apexClassDetailWrapper.size = 100;
        apexClassDetailWrapper.totalSize = 150;
        apexClassDetailWrapper.records = null;
        
        ApexClassesCoverageDetailsWrapper.Records recordWrapper = new ApexClassesCoverageDetailsWrapper.Records();
        recordWrapper.ApexClassOrTriggerId = 'Test';
        recordWrapper.NumLinesCovered = 10;
        recordWrapper.NumLinesUncovered = 0;
        recordWrapper.totalPercentageCoverage = 100;
        Test.stopTest();
    }
}