/**
*   Purpose         :   Test class for OverallOrgCodeCoverageDetailsWrapper
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
private class OverallOrgCodeCoverageDetailsWrapperTest
{
    static testMethod void testOverallOrgCodeCoverageDetailsWrapper()
    {
        Test.startTest();
        
        OverallOrgCodeCoverageDetailsWrapper oAOrgCodeCoverageWrapper = new OverallOrgCodeCoverageDetailsWrapper();
        oAOrgCodeCoverageWrapper.size = 10;
        oAOrgCodeCoverageWrapper.totalSize = 15;
        oAOrgCodeCoverageWrapper.records = null;        
        OverallOrgCodeCoverageDetailsWrapper.Records recordWrapper = new OverallOrgCodeCoverageDetailsWrapper.Records();
        recordWrapper.Id = null;
        recordWrapper.PercentCovered = 100;
        
        Test.stopTest();
    }
}