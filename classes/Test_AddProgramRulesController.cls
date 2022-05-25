//Created by Saurabh Kumar - V1.0 -CR-20201222-14763 - 03/18/2021 - To test use cases for Add Program Rules Quick Action Button Implementations
@isTest
public class Test_AddProgramRulesController {
    //Added by Saurabh Kumar - 03/18/2021 - CR-20201222-14763 - To test positive use cases for Add Program Rule Functionality
    static testmethod void testAddProgramRulesControllerLogic_Positive(){
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
         //create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, true);
        
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        //Create a test program record
        Program__c program_01 = new Program__c(Name = 'Test Program KT', Program_Acronym__c = '01');
        insert program_01;
        
        //Create a test program record
        Program__c program_02 = new Program__c(Name = 'Test Program MT', Program_Acronym__c = '02');
        insert program_02;
        
        //Reset variable
        Util.BypassAllTriggers = false;
        
         //Start our Test
        Test.startTest();
        
        //To get default program records 
        LightningResponseEntity defaultData = AddProgramRulesController.fetchAllProgramRecords(child.Id, null);
        List<AddProgramRulesController.AddProgramRulesWrapper>  defaultWrapper =(List<AddProgramRulesController.AddProgramRulesWrapper>)defaultData.body;  
        System.assertEquals(2, defaultWrapper.size());
        
        //To get all filter program records based on search keyword
        LightningResponseEntity filterData = AddProgramRulesController.fetchAllProgramRecords(child.Id, 'MT');
        List<AddProgramRulesController.AddProgramRulesWrapper> filterWrapper =(List<AddProgramRulesController.AddProgramRulesWrapper>)filterData.body;  
        System.assertEquals(1, filterWrapper.size());
        
        //Set one record as primary
        defaultWrapper[0].isPrimary = true;
        LightningResponseEntity newlyCreatedData = AddProgramRulesController.createProgramRuleRecords(child.Id, JSON.serialize(defaultWrapper));
        List<Rule__c> createdRules =(List<Rule__c>)newlyCreatedData.body;
        //Assert for newly created Rule records
        System.assertEquals(2, createdRules.size()); 
        //Stop our Test
        Test.stopTest();
    }
    
    //Added by Saurabh Kumar - 03/18/2021 - CR-20201222-14763 - To test nagative use cases for Add Program Rule Functionality
    static testmethod void testAddProgramRulesControllerLogic_Negative(){
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
         //create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, true);
        
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        
        //Reset variable
        Util.BypassAllTriggers = false;
        
         //Start our Test
        Test.startTest();
        
        //Assert for no Program records
        LightningResponseEntity defaultData_01 = AddProgramRulesController.fetchAllProgramRecords(null, null);  
        System.assertEquals('You do not have the sufficient access to the record ID.', defaultData_01.message);
        
        //Assert for no Program records
        LightningResponseEntity defaultData_02 = AddProgramRulesController.fetchAllProgramRecords(child.Id, null);  
        System.assertEquals('There is no Program records.', defaultData_02.message);
        
        //Assert for Invalid JSON
        LightningResponseEntity newlyCreatedData = AddProgramRulesController.createProgramRuleRecords(child.Id, 'Invalid Json');
        System.assertEquals(true, newlyCreatedData.message.contains('Unexpected character'));
        
        //Stop our Test
        Test.stopTest();
    }
    
}