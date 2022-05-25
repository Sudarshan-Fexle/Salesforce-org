/**
 *   Purpose        :   Test class for BudgetedCostCenterApexController
 *       
 *   Created By     :   Chirag Soni 
 *
 *   Created Date   :   05/28/2021
 *
 *   Revision Log   :   V1.0 - Created - CR-20210323-15018 
 * 						   
 *   Coverage       :   V1.0 - 87% 
 *                  
 **/

@isTest(seeAllData = false)
private class Test_BudgetedCostCenterApexController {
    
    // setup method
    @testSetup static void testSetupData()
    {
        //Bypass all trigger
        Util.BypassAllTriggers = true;
        
        //Create Account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // Created multiple dimension1 records inorder to search.
        List<c2g__codaDimension1__c> dimensionRecords = new List<c2g__codaDimension1__c>();
        dimensionRecords.add(new c2g__codaDimension1__c(Name = 'test 1 dimension', c2g__ReportingCode__c = 'c2G_001', Active__c = true));
        dimensionRecords.add(new c2g__codaDimension1__c(Name = 'test 2 dimension', c2g__ReportingCode__c = 'c2G_002', Active__c = true));
        dimensionRecords.add(new c2g__codaDimension1__c(Name = 'test 3 dimension', c2g__ReportingCode__c = 'c2G_003', Active__c = true));
        
        insert dimensionRecords;
        
        // Create EAB Event record 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Event_Type__c = 'Research Working Sessions';
        eabEvents.add(eSeries);
        insert eabEvents; 
        Util.BypassAllTriggers = false;
    }
    
    // Test method for getResults 
    static testMethod void testGetResults(){
        
        Test.startTest();
        
        //List of custom wrapper class in order hold search data 
        List<BudgetedCostCenterApexController.SObJectResult> sObjectResultList = new List<BudgetedCostCenterApexController.SObJectResult>();
        
        // call getResult method with searach keyword 'test'
        sObjectResultList = BudgetedCostCenterApexController.getResults('c2g__codaDimension1__c','Name','c2g__ReportingCode__c', 'test');
        
        // getting search results with 'test' keyword 
        System.assertEquals('test 1 dimension', sObjectResultList[0].recordName);
        System.assertEquals('c2G_001', sObjectResultList[0].reportingCode);
        
        System.assertEquals('test 2 dimension', sObjectResultList[1].recordName);
        System.assertEquals('c2G_002', sObjectResultList[1].reportingCode);
        
        System.assertEquals('test 3 dimension', sObjectResultList[2].recordName);
        System.assertEquals('c2G_003', sObjectResultList[2].reportingCode);
        
        Test.stopTest();
    }
    
    // test method for SaveAndUpdateEABEvent used to test whether correct value is updating on EAB Event or not.
    static testMethod void testSaveAndUpdateEABEvent(){
        
        //Query eab Event from setup method
        Advisory_Event__c eabEvent = [SELECT Id FROM Advisory_Event__c];
        
        // Query existing dimension1 records from setup
        List<c2g__codaDimension1__c> dimensionRecords = [SELECT Id, Name, c2g__ReportingCode__c FROM c2g__codaDimension1__c];
        
        Test.startTest();
        
        // call saveAndUpdateEABEvent method and pass parameters for selected record, we have select 0th record from list of dimension records
        String isSuccess =  BudgetedCostCenterApexController.saveAndUpdateEABEvent(eabEvent.Id, dimensionRecords[0].Name, dimensionRecords[0].c2g__ReportingCode__c, dimensionRecords[0].Id);
        
        // Query after updating eab event
        eabEvent = [SELECT Id, Budgeted_Cost_Center_ID__c, Budgeted_Cost_Center_Name__c, Budgeted_Cost_Center_Reporting_Code__c FROM Advisory_Event__c];
        
        // response message to check if it updated or not
        System.assertEquals('SUCCESS', isSuccess);
        
        // check updated fields on EAB Events
        System.assertEquals(dimensionRecords[0].Name, eabEvent.Budgeted_Cost_Center_Name__c);
        System.assertEquals(dimensionRecords[0].c2g__ReportingCode__c, eabEvent.Budgeted_Cost_Center_Reporting_Code__c);
        System.assertEquals(dimensionRecords[0].Id, eabEvent.Budgeted_Cost_Center_ID__c);
        
        Test.stopTest();
    }
}