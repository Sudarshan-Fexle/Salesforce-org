/**
Purpose         :   Test Class for "dynlistLookupController" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
Dev Comment 	:   One use case is pending that is related to recordtype so when there is recordtype available for a object we will cover that part that time
*/
@isTest(seeAllData=false)
private without sharing class dynlistLookupController_Test 
{
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {
        //Accounts
        List<Account> accounts = dynlistTestDataFactory.createListOfAccountsTestData();
        
        //Opportunities
        List<Opportunity> opportunities = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        
        //Application Setting 
        Dynlist_Application_Setting__c applicationSetting = dynlistTestDataFactory.createApplicationSettingTestData();
        applicationSetting.RecordTypeId = Schema.SObjectType.Dynlist_Application_Setting__c.getRecordTypeInfosByName().get('Main').getRecordTypeId();
        update applicationSetting;
        
        //Create Contract Record  
        Contract contract = dynlistTestDataFactory.createContractTestData();
    }
    
    //this method is basically to test all the use cases associated with "dynlistLookupController.getResults" method
    @isTest(seeAllData=false)
    static void testGetResults()
    {
        List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Text_area_value__c From Dynlist_Application_Setting__c 
                                                                    Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME  
                                                                    LIMIT 1];
        
        List<Account> accounts = [SELECT ID, Name FROM Account];
        System.assert(accounts.size() > 0);
        // Update account Name
        for(Account acc : accounts){
            acc.Name = 'Burlington';
        }
	
	Util.BypassAllTriggers = true;
        update accounts;
        Util.BypassAllTriggers = false;
	
        //Start test from here
        Test.startTest();
        
        //Initializaing variable
        String objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        String searchValue = 'Burlington';
        String parentObjName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        String fieldName = System.Label.DYNLIST_DEFAULT_LOOKUP_FILTER_FIELD_NAME ;
        Boolean removeLookupFilters = false;
        //Master
        
        //Use Case #1 - testing out the logics/use cases when ((String.isNotBlank(parentObjName) && String.isNotBlank(objectName)) 
        //then (objectName.equalsIgnoreCase(dynlistConstants.RECORD_TYPE_API_NAME)) And String.isBlank(searchValue)) condition satisfy
        //START FROM HERE
        dynlistLookupController.SObjectResultsWrapper results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        System.assert(results != null);
        
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when ((String.isNotBlank(parentObjName) && String.isNotBlank(objectName)) 
        //then (objectName.equalsIgnoreCase(dynlistConstants.RECORD_TYPE_API_NAME) == false ) And String.isBlank(searchValue) == false) condition satisfy
        //START FROM HERE
        searchValue = 'test';
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, System.Label.DYNLIST_DEFAULT_LOOKUP_FILTER_FIELD_NAME, false, dynlistConstants.CHAR_TEN, null);
        System.assert(results.sObjectResults != null);
        System.assert(results.sObjectResults.size() == 0);
        
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - dynlistUtilities.mapOfObjectAPINameWithSynonymField != null
        //Initializaing variable
        objectName = dynlistConstants.OBJECT_NAME_CONTRACT;
        searchValue = dynlistConstants.CHAR_BLANK_STRING;
        parentObjName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        fieldName = dynlistConstants.NAME_FIELD_NAME;
        removeLookupFilters = false;
        
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        
        //Use Case #4 - search value is not blank
        searchValue = 'test';
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        System.assert(results != null);
        
        results = dynlistLookupController.getMoreResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, accounts[0].Id, dynlistConstants.CHAR_TWENTY_FIVE, Integer.valueOf(dynlistConstants.CHAR_TEN), null);
        
        // Use Case #5 requestMoreRecordsCount is blank.
        results = dynlistLookupController.getMoreResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, accounts[0].Id, '', Integer.valueOf(dynlistConstants.CHAR_TEN), null);

        // User Case #6 - objectName equals to Recordtype and searchValue not blank
        objectName = dynlistConstants.RECORD_TYPE_API_NAME;
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        System.assert(results!=null);
        
        // User Case #7 - objectName equals to Recordtype and searchValue set blank
        objectName = dynlistConstants.RECORD_TYPE_API_NAME;
        searchValue = dynlistConstants.CHAR_BLANK_STRING;
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        System.assert(results!=null);
        
        // Use Case #8 When search value blank
        objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        searchValue = dynlistConstants.CHAR_BLANK_STRING;
        parentObjName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        fieldName = System.Label.DYNLIST_DEFAULT_LOOKUP_FILTER_FIELD_NAME ;
        removeLookupFilters = false;
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, dynlistConstants.CHAR_TEN, null);
        System.assert(results!=null);
        
        // Use Case #9 When recordsToDisplayCount value blank
        
        objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        searchValue = dynlistConstants.CHAR_BLANK_STRING;
        parentObjName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        fieldName = System.Label.DYNLIST_DEFAULT_LOOKUP_FILTER_FIELD_NAME ;
        removeLookupFilters = false;
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, '', null);
        System.assert(results!=null);
        
        // Use Case #10 When recordsToDisplayCount value 1 i.e less than account records.
        objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        searchValue = dynlistConstants.CHAR_BLANK_STRING;
        parentObjName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        fieldName = System.Label.DYNLIST_DEFAULT_LOOKUP_FILTER_FIELD_NAME ;
        removeLookupFilters = false;
        results = dynlistLookupController.getResults(objectName, searchValue, parentObjName, fieldName, removeLookupFilters, '1', null);
        System.assert(results!=null);
        //Start test from here
        Test.stopTest();
    }
}