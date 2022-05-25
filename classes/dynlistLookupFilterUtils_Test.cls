/*
Purpose         :   Test Class for "dynlistLookupFilterUtils" apex class
Created By      :   Abhinav Sharma
Created Date    :   11/02/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/02/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistLookupFilterUtils_Test
{
    private static final String LOOKUP_FILTER_JSON = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"LookupFilter",'
        +'"records":[{"attributes":{"type":"LookupFilter","url":"/services/data/v43.0/tooling/sobjects/LookupFilter/0DG3B0000004becWAA"},'
        +'"SourceFieldDefinition":{"attributes":{"type":"FieldDefinition","url":"/services/data/v43.0/tooling/sobjects/FieldDefinition/Account.Owner"},'
        +'"FullName":"Account.OwnerId"},"TargetEntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v43.0/tooling/sobjects/'
        +'EntityDefinition/User"},"FullName":"User"},"Metadata":{"booleanFilter":"((1 OR 2 OR 5) AND (3 OR 4) AND (6 OR 7 OR 8) AND 9 AND 10)","filterItems"'
        +':[{"field":"$Source.AccountSource","operation":"equals","value":"Web","valueField":null},{"field":"$Profile.Name","operation":"equals","value":'
        +'"System Administrator","valueField":null},{"field":"User.ContactId","operation":"notEqual","value":"null","valueField":null},{"field":'
        +'"$Source.Industry","operation":"notEqual","value":null,"valueField":"$Source.AccountSource"},{"field":"$User.Country","operation":"equals",'
        +'"value":null,"valueField":"$Source.Industry"},{"field":"$Source.Industry","operation":"equals","value":null,"valueField":'
        +'"User.CompanyName"},{"field":"$UserRole.Name","operation":"notEqual","value":null,"valueField":"User.Division"},'
        +'{"field":"User.CompanyName","operation":"notEqual","value":null,"valueField":"$User.CompanyName"},{'
        +'"field":"User.City","operation":"equals","value":null,"valueField":"$User.City"},{"field":"User.Profile.Name","operation":"equals"'
        +',"value":null,"valueField":"$User.LastName"}],"active":true,"description":null,"errorMessage":null,"infoMessage":null,"isOptional":false}}]}';
    
    private static final String LOOKUP_DEVELOPERNAME_JSON = '{"size":17,"totalSize":17,"done":true,"queryLocator":null,"entityTypeName":"LookupFilter",'
        +'"records":[{"attributes":{"type":"LookupFilter","url":"/services/data/v43.0/tooling/sobjects/LookupFilter/0DG1D0000004Io7WAE"},'
        +'"DeveloperName":"nf_01I1D000000Dd5LUAS_00N1D0000028ygDUAQ"}]}';
    
    private static Account acc;
    private static List<dynlistField> uiRecordFields;
    private static dynlistSOQLBuilder builder;
    private static String sourceObjectName;
    private static String lookupSobjectName;
    private static String sourceFieldName;
    static 
    {
        acc = new Account();
        acc.name = 'Test';
        Util.BypassAllTriggers = true;
        insert acc;
        Util.BypassAllTriggers = false;
        
        builder = dynlistSOQLBuilder.create()
            .addSelect(new String[]{'Id', 'Name'})
            .addFrom('User')
            .setLimit(20);
        sourceObjectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        lookupSobjectName = 'User';
        sourceFieldName = 'OwnerId';
        dynlistField f = new dynlistField('AccountSource', 'Account Source', null, 'Picklist', false, true, false, 'Web', null);
        uiRecordFields = new List<dynlistField>{f};
            }
    
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {
        //Accounts
        List<Account> accounts = dynlistTestDataFactory.createListOfAccountsTestData();
        
        //Opportunities
        List<Opportunity> opportunities = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        
        //Application Setting 
        Dynlist_Application_Setting__c applicationSetting = dynlistTestDataFactory.createApplicationSettingTestDataV2();
    }
    
    //this method is to test all the use cases associated with "dynlistLookupFilterUtils.dynlistLookupFilterUtils"
    @isTest(seeAllData=false)
    static void testDynlistLookupFilterUtils()
    {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new dynlistMockHttpResponseGenerator());
        
        dynlistLookupFilterUtils.upsertLookupFilters();
        
        //Use case - 1  - test constructor without argument 
        //Starts from here
        dynlistLookupFilterUtils constructor = new dynlistLookupFilterUtils();
        //Use Case - 1  - test constructor without argument      
        //End Here
        
        //Use case - 2  - test constructor with argument 
        //Starts from here
        Set<String> remainingDeveloperNames = new Set<String>{'nf_01I5g000002v2UKEAY_00N5g00000Rrc14EAB'}; //filter field name 1
            List<String> lookupFilters = new List<String>(); // Lookup filter name 2 -  Generates error when we will add a lookup filter name 
        String session_Id = UserInfo.getSessionId().SubString(15);
        
        constructor = new dynlistLookupFilterUtils(remainingDeveloperNames,lookupFilters, session_Id);
        //Use Case - 2  - test constructor with argument      
        //End Here
        System.assert(constructor!=null);
        System.enqueueJob(constructor);
    }
    
    @isTest
    static void testUpsertLookupFilters() 
    {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new dynlistMockHttpCallout(LOOKUP_DEVELOPERNAME_JSON,LOOKUP_FILTER_JSON));
        dynlistLookupFilterUtils.upsertLookupFilters();
        List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Text_area_value__c From Dynlist_Application_Setting__c 
                                                                    Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME 
                                                                    LIMIT 1];
        
        System.assert(applicationSettings.size() == 1,'Should return 1 ['+applicationSettings.size()+']');
        System.assert(String.isNotBlank(applicationSettings[0].Text_area_value__c),'Should not return blank ['+applicationSettings[0].Text_area_value__c+']');
        Test.stopTest();
    }
    
    @isTest
    static void testUpsertLookupFilters1(){
        Test.startTest();
        
        String description = '';
        for(Integer i=0; i<2300; i++){
            description += 'This is for testing the length greater then long text area.';
        }
        // When response greater then textAreaLimit.
        String LOOKUP_FILTER_JSON2 = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"LookupFilter",'
        +'"records":[{"attributes":{"type":"LookupFilter","url":"/services/data/v43.0/tooling/sobjects/LookupFilter/0DG3B0000004becWAA"},'
        +'"SourceFieldDefinition":{"attributes":{"type":"FieldDefinition","url":"/services/data/v43.0/tooling/sobjects/FieldDefinition/Account.Owner"},'
        +'"FullName":"Account.OwnerId"},"TargetEntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v43.0/tooling/sobjects/'
        +'EntityDefinition/User"},"FullName":"User"},"Metadata":{"booleanFilter":"((1 OR 2 OR 5) AND (3 OR 4) AND (6 OR 7 OR 8) AND 9 AND 10)","filterItems"'
        +':[{"field":"$Source.AccountSource","operation":"equals","value":"Web","valueField":null},{"field":"$Profile.Name","operation":"equals","value":'
        +'"System Administrator","valueField":null},{"field":"User.ContactId","operation":"notEqual","value":"null","valueField":null},{"field":'
        +'"$Source.Industry","operation":"notEqual","value":null,"valueField":"$Source.AccountSource"},{"field":"$User.Country","operation":"equals",'
        +'"value":null,"valueField":"$Source.Industry"},{"field":"$Source.Industry","operation":"equals","value":null,"valueField":'
        +'"User.CompanyName"},{"field":"$UserRole.Name","operation":"notEqual","value":null,"valueField":"User.Division"},'
        +'{"field":"User.CompanyName","operation":"notEqual","value":null,"valueField":"$User.CompanyName"},{'
        +'"field":"User.City","operation":"equals","value":null,"valueField":"$User.City"},{"field":"User.Profile.Name","operation":"equals"'
        +',"value":null,"valueField":"$User.LastName"}],"active":true,"description":"'+description+'","errorMessage":null,"infoMessage":null,"isOptional":false}}]}';
       
        Test.setMock(HttpCalloutMock.class, new dynlistMockHttpCallout(LOOKUP_DEVELOPERNAME_JSON,LOOKUP_FILTER_JSON2));
        dynlistLookupFilterUtils.upsertLookupFilters();
        List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Text_area_value__c From Dynlist_Application_Setting__c 
                                                                    Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME 
                                                                    LIMIT 1];
        
        System.assert(applicationSettings.size() == 1,'Should return 1 ['+applicationSettings.size()+']');
        System.assert(String.isNotBlank(applicationSettings[0].Text_area_value__c),'Should not return blank ['+applicationSettings[0].Text_area_value__c+']');
        Test.stopTest();
    }
    
    @isTest
    static void testUpsertLookupFilters2(){
        Test.startTest();
        
        String description = '';
        for(Integer i=0; i<5000; i++){
            description += 'This is for testing the length greater then long text area.';
        }
        // When response twice greater then textAreaLimit.
        String LOOKUP_FILTER_JSON2 = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"LookupFilter",'
        +'"records":[{"attributes":{"type":"LookupFilter","url":"/services/data/v43.0/tooling/sobjects/LookupFilter/0DG3B0000004becWAA"},'
        +'"SourceFieldDefinition":{"attributes":{"type":"FieldDefinition","url":"/services/data/v43.0/tooling/sobjects/FieldDefinition/Account.Owner"},'
        +'"FullName":"Account.OwnerId"},"TargetEntityDefinition":{"attributes":{"type":"EntityDefinition","url":"/services/data/v43.0/tooling/sobjects/'
        +'EntityDefinition/User"},"FullName":"User"},"Metadata":{"booleanFilter":"((1 OR 2 OR 5) AND (3 OR 4) AND (6 OR 7 OR 8) AND 9 AND 10)","filterItems"'
        +':[{"field":"$Source.AccountSource","operation":"equals","value":"Web","valueField":null},{"field":"$Profile.Name","operation":"equals","value":'
        +'"System Administrator","valueField":null},{"field":"User.ContactId","operation":"notEqual","value":"null","valueField":null},{"field":'
        +'"$Source.Industry","operation":"notEqual","value":null,"valueField":"$Source.AccountSource"},{"field":"$User.Country","operation":"equals",'
        +'"value":null,"valueField":"$Source.Industry"},{"field":"$Source.Industry","operation":"equals","value":null,"valueField":'
        +'"User.CompanyName"},{"field":"$UserRole.Name","operation":"notEqual","value":null,"valueField":"User.Division"},'
        +'{"field":"User.CompanyName","operation":"notEqual","value":null,"valueField":"$User.CompanyName"},{'
        +'"field":"User.City","operation":"equals","value":null,"valueField":"$User.City"},{"field":"User.Profile.Name","operation":"equals"'
        +',"value":null,"valueField":"$User.LastName"}],"active":true,"description":"'+description+'","errorMessage":null,"infoMessage":null,"isOptional":false}}]}';
       
        Test.setMock(HttpCalloutMock.class, new dynlistMockHttpCallout(LOOKUP_DEVELOPERNAME_JSON,LOOKUP_FILTER_JSON2));
        dynlistLookupFilterUtils.upsertLookupFilters();
        List<Dynlist_Application_Setting__c> applicationSettings = [Select Id, Text_area_value__c From Dynlist_Application_Setting__c 
                                                                    Where Name =: System.Label.DYNLIST_LOOKUP_FILTERS_RECORD_NAME 
                                                                    LIMIT 1];
        
        System.assert(applicationSettings.size() == 1,'Should return 1 ['+applicationSettings.size()+']');
        System.assert(String.isNotBlank(applicationSettings[0].Text_area_value__c),'Should not return blank ['+applicationSettings[0].Text_area_value__c+']');
        Test.stopTest();
    }
    
    @isTest
    static void testGetLookupAddLookupFilters() 
    {
        Test.startTest();
        dynlistLookupFilterUtils.LookupFilter lookupJson = (dynlistLookupFilterUtils.LookupFilter) JSON.deserialize(LOOKUP_FILTER_JSON, dynlistLookupFilterUtils.LookupFilter.class);
        String sobjectLookupFilterJson = dynlistLookupFilterUtils.getLookupFilterForField(lookupJson,lookupSobjectName,sourceObjectName,sourceFieldName,uiRecordFields,acc.Id);
        dynlistLookupFilterUtils.SobjectLookupFilter sobjectLookupFilter = (dynlistLookupFilterUtils.SobjectLookupFilter)JSON.deserialize(sobjectLookupFilterJson, dynlistLookupFilterUtils.SobjectLookupFilter.class);
        
        System.assert(sobjectLookupFilter.targetObjectName.endsWithIgnoreCase(lookupSobjectName),'Should contain '+lookupSobjectName+'['+sobjectLookupFilter.targetObjectName+']');
        System.assert(sobjectLookupFilter.sourceObjectName.endsWithIgnoreCase(sourceObjectName),'Should contain '+sourceObjectName+'['+sobjectLookupFilter.sourceObjectName+']');
        System.assert(sobjectLookupFilter.sourceFieldName.endsWithIgnoreCase(sourceFieldName),'Should contain '+sourceFieldName+'['+sobjectLookupFilter.sourceFieldName+']');
        System.assert(sobjectLookupFilter.currentFieldOnUI.size() == 1,'Size of sobjectLookupFilter.currentFieldOnUI should be 1['+sobjectLookupFilter.currentFieldOnUI.size()+']');
        System.assert(sobjectLookupFilter.currentFieldNotOnUI.size() == 1,'Size of sobjectLookupFilter.currentFieldNotOnUI should be 1['+sobjectLookupFilter.currentFieldNotOnUI.size()+']');
        System.assert(sobjectLookupFilter.userFieldsData.size() == 6,'Size of sobjectLookupFilter.userFieldsData should be 6['+sobjectLookupFilter.userFieldsData.size()+']');
        System.assert(sobjectLookupFilter.currentFieldNotOnUIData.size() == 1,'Size of sobjectLookupFilter.currentFieldNotOnUIData should be 1['+sobjectLookupFilter.currentFieldNotOnUIData.size()+']');
        System.assert(sobjectLookupFilter.fieldsDataType.size() == 10,'Size of sobjectLookupFilter.fieldsDataType should be 10['+sobjectLookupFilter.fieldsDataType.size()+']');
        
        dynlistLookupFilterUtils.addLookupFilters(builder,sobjectLookupFilter,uiRecordFields, lookupSobjectName);
        Boolean isException;
        String exceptionMessage;
        try 
        {
            List<SObject> results = Database.query(builder.toQuery());
            isException = false;
        }
        catch(Exception e)
        {
            isException = true;
            exceptionMessage = e.getMessage();
        }
        System.assert(!isException,'Should not throw any exception['+exceptionMessage+']');
        
        dynlistSOQLBuilder sBuilder = dynlistLookupFilterUtils.processLookupFilters(builder, sobjectLookupFilter,uiRecordFields, lookupSobjectName);
        System.assert(sBuilder != null);
        
        Test.stopTest();
    }
    
    @isTest
    static void testAddFilterWhereClauseByType() 
    {
        Test.startTest();
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','XYZ','null',Schema.DisplayType.STRING,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','Alias','ABC',Schema.DisplayType.STRING,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','199','550',Schema.DisplayType.Currency,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','25','25',Schema.DisplayType.Integer,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','2018-08-30','2018-08-30',Schema.DisplayType.Date,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','2018-08-30 00:00:00','2018-08-30 00:00:00',Schema.DisplayType.DateTime,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','CreatedDate','2018-08-30T00:00:00Z',Schema.DisplayType.DateTime,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','CreatedDate','2018-08-30 00:00:00',Schema.DisplayType.DateTime,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','a0I3B000001Q9DOUA0','a0I3B000001Q9DO',Schema.DisplayType.Reference,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','CreatedById','a0I3B000001Q9DOUA0',Schema.DisplayType.Reference,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','Male','Male',Schema.DisplayType.Picklist,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','LocaleSidKey','en_US',Schema.DisplayType.Picklist,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'notEqual','LocaleSidKey','en_US',Schema.DisplayType.Picklist,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'contains','LocaleSidKey','en_US',Schema.DisplayType.Picklist,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','true','True',Schema.DisplayType.Boolean,true, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder,'equals','IsActive','True',Schema.DisplayType.Boolean,false, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        Boolean isException;
        String exceptionMessage;
        try 
        {
            List<SObject> results = Database.query(builder.toQuery());
            isException = false;
        }
        catch(Exception e)
        {
            isException = true;
            exceptionMessage = e.getMessage();
        }
        System.assert(!isException,'Should not throw any exception['+exceptionMessage+']');
        Test.stopTest();
    }
    
    @isTest
    static void testAddIdFilter() 
    {
        Test.startTest();
        dynlistLookupFilterUtils.addIdFilter(builder, true);
        dynlistLookupFilterUtils.addIdFilter(builder, false);
        Boolean isException;
        String exceptionMessage;
        try 
        {
            List<SObject> results = Database.query(builder.toQuery());
            isException = false;
        }
        catch(Exception e)
        {
            isException = true;
            exceptionMessage = e.getMessage();
        }
        System.assert(!isException,'Should not throw any exception['+exceptionMessage+']');
        Test.stopTest();
    }
    
    @isTest
    static void testAddFilterWhereClause() 
    {
        Test.startTest();
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'equals','Alias','ABC', dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'notEqual','Alias','XYZ', dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'greaterThan','Alias','', dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'greaterOrEqual','CreatedDate',null, dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'contains','Alias','C', dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'notContain','Alias','P', dynlistConstants.OBJECT_NAME_ACCOUNT);
        dynlistLookupFilterUtils.addFilterWhereClause(builder,'startsWith','Alias','A', dynlistConstants.OBJECT_NAME_ACCOUNT);
        Boolean isException;
        String exceptionMessage;
        try 
        {
            List<SObject> results = Database.query(builder.toQuery());
            isException = false;
        }
        catch(Exception e)
        {
            isException = true;
            exceptionMessage = e.getMessage();
        }
        System.assert(!isException,'Should not throw any exception['+exceptionMessage+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareDoubleValues() 
    {
        Test.startTest();
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('equals', 15, 15),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('equals', 15, 15)+']');
        System.assert(!dynlistLookupFilterUtils.compareDoubleValues('notEqual', 15, 15),'Should return false['+dynlistLookupFilterUtils.compareDoubleValues('notEqual', 15, 15)+']');
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('greaterThan', 15, null),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('greaterThan', 15, null)+']');
        System.assert(!dynlistLookupFilterUtils.compareDoubleValues('greaterThan', 15, 19),'Should return false['+dynlistLookupFilterUtils.compareDoubleValues('greaterThan', 15, 19)+']');
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('greaterOrEqual', 15, 15),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('greaterOrEqual', 15, 15)+']');
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('lessThan', 12, 15),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('lessThan', 12, 15)+']');
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('lessOrEqual', 15, 15),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('lessOrEqual', 15, 15)+']');
        System.assert(dynlistLookupFilterUtils.compareDoubleValues('contains', 15, 15),'Should return true['+dynlistLookupFilterUtils.compareDoubleValues('contains', 15, 15)+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareDateValues() 
    {
        Test.startTest();
        System.assert(dynlistLookupFilterUtils.compareDateValues('equals', Date.today(), Date.today()),'Should return true['+dynlistLookupFilterUtils.compareDateValues('equals', Date.today(), Date.today())+']');
        System.assert(!dynlistLookupFilterUtils.compareDateValues('notEqual', Date.today(), Date.today()),'Should return false['+dynlistLookupFilterUtils.compareDateValues('notEqual', Date.today(), Date.today())+']');
        System.assert(dynlistLookupFilterUtils.compareDateValues('greaterThan', Date.today(), null),'Should return true['+dynlistLookupFilterUtils.compareDateValues('greaterThan', Date.today(), null)+']');
        System.assert(!dynlistLookupFilterUtils.compareDateValues('greaterThan', Date.today(), Date.today()+1),'Should return false['+dynlistLookupFilterUtils.compareDateValues('greaterThan', Date.today(), Date.today()+1)+']');
        System.assert(dynlistLookupFilterUtils.compareDateValues('greaterOrEqual', Date.today(), Date.today()),'Should return true['+dynlistLookupFilterUtils.compareDateValues('greaterOrEqual', Date.today(), Date.today())+']');
        System.assert(dynlistLookupFilterUtils.compareDateValues('lessThan', Date.today()-1, Date.today()),'Should return true['+dynlistLookupFilterUtils.compareDateValues('lessThan', Date.today()-1, Date.today())+']');
        System.assert(dynlistLookupFilterUtils.compareDateValues('lessOrEqual', Date.today(), Date.today()),'Should return true['+dynlistLookupFilterUtils.compareDateValues('lessOrEqual', Date.today(), Date.today())+']');
        System.assert(dynlistLookupFilterUtils.compareDateValues('contains', Date.today(), Date.today()),'Should return true['+dynlistLookupFilterUtils.compareDateValues('contains', Date.today(), Date.today())+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareDateTimeValues() 
    {
        Test.startTest();
        System.assert(!dynlistLookupFilterUtils.compareDateTimeValues('equals', DateTime.now(), DateTime.now()-1),'Should return false['+dynlistLookupFilterUtils.compareDateTimeValues('equals', DateTime.now(), DateTime.now()-1)+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('notEqual', DateTime.now()-1, DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('notEqual', DateTime.now()-1, DateTime.now())+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('greaterThan', DateTime.now(), null),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('greaterThan', DateTime.now(), null)+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('greaterThan', DateTime.now()+1, DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('greaterThan', DateTime.now()+1, DateTime.now())+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('greaterOrEqual', DateTime.now()+1, DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('greaterOrEqual', DateTime.now()+1, DateTime.now())+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('lessThan', DateTime.now()-1, DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('lessThan', DateTime.now()-1, DateTime.now())+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('lessOrEqual', DateTime.now(), DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('lessOrEqual', DateTime.now(), DateTime.now())+']');
        System.assert(dynlistLookupFilterUtils.compareDateTimeValues('contains', DateTime.now(), DateTime.now()),'Should return true['+dynlistLookupFilterUtils.compareDateTimeValues('contains', DateTime.now(), DateTime.now())+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareReferenceValues() 
    {
        Test.startTest();
        System.assert(dynlistLookupFilterUtils.compareReferenceValues('equals', 'a0I3B000001Q9DOUA0', 'a0I3B000001Q9DO'),'Should return true['+dynlistLookupFilterUtils.compareReferenceValues('equals', 'a0I3B000001Q9DOUA0', 'a0I3B000001Q9DO')+']');
        System.assert(!dynlistLookupFilterUtils.compareReferenceValues('notEqual', 'a0I3B000001Q9DOUA0', 'a0I3B000001Q9DO'),'Should return false['+dynlistLookupFilterUtils.compareReferenceValues('notEqual', 'a0I3B000001Q9DOUA0', 'a0I3B000001Q9DO')+']');
        System.assert(dynlistLookupFilterUtils.compareReferenceValues('contains', 'a0I3B000001Q9DOUA0', null),'Should return true['+dynlistLookupFilterUtils.compareReferenceValues('greaterThan', 'a0I3B000001Q9DOUA0', null)+']');
        System.assert(dynlistLookupFilterUtils.compareReferenceValues('startsWith', 'a0I3B000001Q9DOUA0', 'a0I'),'Should return true['+dynlistLookupFilterUtils.compareReferenceValues('contains', 'a0I3B000001Q9DOUA0', 'a0I')+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareStringValues() 
    {
        Schema.DisplayType fieldType = Schema.DisplayType.STRING;
        Test.startTest();
        System.assert(dynlistLookupFilterUtils.compareStringValues('equals', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return true['+dynlistLookupFilterUtils.compareStringValues('equals', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(!dynlistLookupFilterUtils.compareStringValues('notEqual', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return false['+dynlistLookupFilterUtils.compareStringValues('notEqual', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(dynlistLookupFilterUtils.compareStringValues('contains', 'ABC', null, fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return true['+dynlistLookupFilterUtils.compareStringValues('contains', 'ABC', null, fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(!dynlistLookupFilterUtils.compareStringValues('startsWith', 'ABC', 'X', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return false['+dynlistLookupFilterUtils.compareStringValues('startsWith', 'ABC', 'X', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(dynlistLookupFilterUtils.compareStringValues('contains', 'ABC', 'A', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return true['+dynlistLookupFilterUtils.compareStringValues('contains', 'ABC', 'A', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(dynlistLookupFilterUtils.compareStringValues('notContain', 'ABC', 'Z', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return true['+dynlistLookupFilterUtils.compareStringValues('notContain', 'ABC', 'Z', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        System.assert(dynlistLookupFilterUtils.compareStringValues('lessOrEqual', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME),'Should return true['+dynlistLookupFilterUtils.compareStringValues('lessOrEqual', 'ABC', 'ABC', fieldType, dynlistConstants.NAME_FIELD_NAME)+']');
        Test.stopTest();
    }
    
    @isTest
    static void testCompareNullvalues() 
    {
        Test.startTest();
        System.assert(dynlistLookupFilterUtils.compareNullvalues('greaterThan'),'Should return true['+dynlistLookupFilterUtils.compareNullvalues('greaterThan')+']');
        System.assert(!dynlistLookupFilterUtils.compareNullvalues('notContain'),'Should return false['+dynlistLookupFilterUtils.compareNullvalues('notContain')+']');
        Test.stopTest();
    }
    
    //this method is to test all the use cases associated with "dynlistLookupFilterUtils.addFilterWhereClause" 
    @isTest(seeAllData=false)
    static void testAddFilterWhereClauseByType1()
    {
        //dynlistSOQLBuilder instance
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom(dynlistConstants.OBJECT_NAME_ACCOUNT).setLinebreaks(false);
        //Variable declaration
        String operation = 'equals';
        String column = '80';
        Boolean isCompare = true;
        String value = '80';
        //assert
        System.assert(builder!=null);
        
        Account acc = dynlistTestDataFactory.createAccountTestData();
        
        String objType = dynlistConstants.OBJECT_NAME_ACCOUNT;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType accountSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = accountSchema.getDescribe().fields.getMap();
        
        //get all the fields label for Account Object
        String fieldLabel = fieldMap.get('AnnualRevenue').getDescribe().getLabel();
        
        //get data types of field
        Schema.DisplayType fielddataType = fieldMap.get('AnnualRevenue').getDescribe().getType();
        
        //Test start Here
        Test.startTest();
        
        //Use Case 1 -  (String.isNotBlank(value) && value.equalsIgnoreCase('null'))
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, 'null', null, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //assert
        System.assert(builder!=null);
        //use Case 1 - end here
        
        //Use Case 2 -  (Schema.DisplayType.Currency==fieldType || Schema.DisplayType.Double==fieldType)
        value = '80';
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        
        //Use Case 2.1 - Test When isCompare = false
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 2.1 - end here
        //Use Case 2 - end here
        
        //Use Case 3 -  (Schema.DisplayType.Integer==fieldType)
        //get data types of field
        isCompare = true;
        fielddataType = fieldMap.get('NumberOfEmployees').getDescribe().getType();
        isCompare = true;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Testing when -  isCompare =  false
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 3 - end here
        
        //Use Case 4 -  (Schema.DisplayType.Date==fieldType)        
        column = ''+System.Now();
        isCompare = true;
        value = ''+System.Now();
        //Use Case 4.1 - get data types for "Date" field
        fielddataType = fieldMap.get('LastActivityDate').getDescribe().getType();
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 4.1 - end here
        
        //Use Case 4.2 - Testing DateTime Value with ISO Date time
        value = ''+datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 4.2 - end here
        
        //Use Case 4.3 - Testing when isCompare = false
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 4.3 - end here
        
        //Use Case 4 -  end Here
        
        //Use Case 5 -  (Schema.DisplayType.DateTime==fieldType) 
        column = ''+System.Now();
        isCompare = true;
        value = ''+System.Now();
        //Use Case 5.1 - get data types for "DateTime" field
        fielddataType = fieldMap.get('CreatedDate').getDescribe().getType();
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 5.1  - end here
        
        //Use Case 5.2 - Testing DateTime Value with ISO Date time
        value = ''+datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 5.2 - end here
        
        //Use Case 5.3 Testing when isCompare = false
        isCompare = true;
        fielddataType = fieldMap.get('LastModifiedById').getDescribe().getType();
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        
        //testing when use case - isCompare = false
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);        
        //Use Case 5.3 - end here
        
        //Use Case 5 - end here
        
        //Use Case 6 -  (Schema.DisplayType.Reference==fieldType)
        Operation = 'greaterThan';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 6 - end here
        
        //Use Case 7 -  (Schema.DisplayType.Picklist==fieldType)
        column = 'Type';
        isCompare = true;
        value = 'Prospect';
        
        //Use Case 7.1 - get data types for "IsDeleted" field
        fielddataType = fieldMap.get('Type').getDescribe().getType();
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 7.1 - End here
        
        //Use Case 7.2 - Test when (operation == 'notEqual' && String.isNotBlank(value)
        isCompare = false;
        operation = 'notEqual';
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 7.2 - end here
        
        //Use Case 7.3 - Test when (operation == 'equals' && String.isNotBlank(value)
        operation = 'equals';
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 7.3 - end here
        
        //Use Case 7.4  - Test when above all cases fails
        operation = 'contains';
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        
        //When isCompare is true
        isCompare = true;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 7.4 -  end Here
        
        //Use Case 7 -  end Here
        
        //Use Case 8 -  (Schema.DisplayType.Boolean==fieldType)
        column = 'IsDeleted';
        isCompare = true;
        value = 'true';
        //get data types for "IsDeleted" field
        fielddataType = fieldMap.get('IsDeleted').getDescribe().getType();
        
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        
        //test when isCompare = false;
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, fielddataType, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 8 - end here
        
        //Use Case 9 - else part when isCompare=false and fielddataType =  null
        isCompare = false;
        dynlistLookupFilterUtils.addFilterWhereClauseByType(builder, operation, column, value, null, isCompare, dynlistConstants.OBJECT_NAME_ACCOUNT, dynlistConstants.NAME_FIELD_NAME, dynlistConstants.NAME_FIELD_NAME);
        //Use Case 9 - end here
        
        //assert
        System.assert(builder!=null);
        
        //Test stop here
        Test.stopTest();
    }
    
    //this method is to test all the use cases associated with "dynlistLookupFilterUtils.addFilterWhereClause" 
    @isTest(seeAllData=false)
    static void testAddFilterWhereClause1()
    {
        //dynlistSOQLBuilder instance
        dynlistSOQLBuilder builder = dynlistSOQLBuilder.create().addFrom(dynlistConstants.OBJECT_NAME_ACCOUNT).setLinebreaks(false);
        //Variable declaration
        String operation = 'equals';
        String column = 'Name';
        Account acc = dynlistTestDataFactory.createAccountTestData();
        
        //Test start Here
        Test.startTest();
        //Use Case 1 -  (operation == 'equals' && String.isNotBlank(column))
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        System.assert(builder!=null);
        //Use Case 1 - end here
        
        //Use Case 2 -  (operation == 'notEqual' && String.isNotBlank(column))
        Operation = 'notEqual';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        System.assert(builder!=null);
        //Use Case 2 - end here
        
        //Use Case 3 -  (String.isBlank(String.valueOf(val))) And (operation == 'greaterThan' || operation == 'lessThan' || operation == 'contains' || operation == 'startsWith') 
        Operation = 'greaterThan';
        acc = null;
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        System.assert(builder!=null);
        //Use Case 3 -  end Here
        
        //Use Case 4 -  (String.isBlank(String.valueOf(val))) And  (operation == 'greaterOrEqual' || operation == 'notContain' || operation == 'lessOrEqual') 
        Operation = 'greaterOrEqual';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 4 -  end Here
        
        //Use Case 5 -  (operation == 'notEqual' && String.isNotBlank(column))
        Operation = 'greaterThan';
        acc = dynlistTestDataFactory.createAccountTestData();
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 5 - end here
        
        //Use Case 6 -  (operation == 'greaterThan' && String.isNotBlank(column))
        Operation = 'greaterThan';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 6 - end here
        
        //Use Case 7 -  (operation == 'greaterOrEqual' && String.isNotBlank(column))
        Operation = 'greaterOrEqual';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 7 - end here
        
        //Use Case 8 -  (operation == 'lessThan' && String.isNotBlank(column))
        Operation = 'lessThan';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 8 - end here
        
        //Use Case 9 -  (operation == 'lessOrEqual' && String.isNotBlank(column))
        Operation = 'lessOrEqual';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 9 - end here
        
        //Use Case 10 -  (operation == 'contains' && String.isNotBlank(column))
        Operation = 'contains';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 10 - end here
        
        //Use Case 11 -  (operation == 'notContain' && String.isNotBlank(column))
        Operation = 'notContain';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 11 - end here
        
        //Use Case 11 -  (operation == 'startsWith' && String.isNotBlank(column))
        Operation = 'startsWith';
        dynlistLookupFilterUtils.addFilterWhereClause(builder, operation, column, acc, dynlistConstants.OBJECT_NAME_ACCOUNT);
        //Use Case 11 - end here
        System.assert(builder!=null);
        
        //Test stop here
        Test.stopTest();
    }
}