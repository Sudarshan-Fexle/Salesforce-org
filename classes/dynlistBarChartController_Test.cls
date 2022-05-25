/*
Purpose         :   Test Class for "dynlistBarChartController" apex class
Created By      :   Abhinav Sharma
Created Date    :   11/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/09/2021   
*/
@isTest(seeAllData=false)
private without sharing class dynlistBarChartController_Test
{    
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {  
        List<Opportunity> opportunities = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        for(Opportunity opp: opportunities)
        {
            opp.Amount = 50;
        }
        update opportunities;
    }
    
    //this method is basically to test all the use cases associated with "dynlistBarChartController.getOpportunities" method
    @isTest(seeAllData=false)
    static void testGetOpportunities()
    {
        List<Opportunity> opportunities = [Select Id From Opportunity];
        String selectedRecordsIds = dynlistConstants.CHAR_BLANK_STRING;
        for(Opportunity opp: opportunities)
        {
            selectedRecordsIds = selectedRecordsIds + opp.Id + dynlistConstants.CHAR_COMMA;
        }
        
        //Test start here
        //Use Case 1 - String.isNotBlank(selectedRecordsIds)
        Test.startTest();
        selectedRecordsIds = selectedRecordsIds.removeEnd(dynlistConstants.CHAR_COMMA);
        
        List<AggregateResult> results  = dynlistBarChartController.getOpportunities(selectedRecordsIds);
        System.assert(results!=null);
        System.assert(results.size()==1);
        //Use Case 1 - End here
        
        //Use Case 2 - String.isBlank(selectedRecordsIds)
        //Test start here
        selectedRecordsIds = dynlistConstants.CHAR_BLANK_STRING;
        results  = dynlistBarChartController.getOpportunities(selectedRecordsIds);
        System.assert(results==null);
        //Use case 2 - end Here
        
        //Test Stop Here
        Test.stopTest();
    }
}