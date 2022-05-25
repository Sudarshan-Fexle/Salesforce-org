/*
Purpose         :   Test Class for "dynlistDataGridController" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistDataGridController_Test 
{
    // this method is to test all the use cases associated with "dynlistDataGridController.getDataRecords" method
    @isTest(seeAllData=false)
    static void testGetDataRecords()
    {
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());
        
        List<Account> accList = [Select Id,Name From Account]; 
        
        //testing for Table view - Start
        Map<String,Object> dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => 'Stagename',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => dynlistConstants.CHAR_BLANK_STRING,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => dynlistConstants.CHAR_NULLS_LAST,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => '2',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => true,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
        dynlistDataGrid dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(3, dynlistGrid.body);
        //testing for Table view - End 
        
        //testing for kanban view - Start
        dataGridRequest = new Map<String,Object>{
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_KANBAN,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => dynlistConstants.CHAR_BLANK_STRING,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => 'Stagename',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => 'Stagename,Amount,AccountId',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => dynlistConstants.CHAR_NULLS_LAST,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => '2',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => true,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
        
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(3, dynlistGrid.body);
        //testing for kanban view - end
        
        //Start test from here
        Test.startTest();
        
        //testing for Table view - Start
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => dynlistConstants.CHAR_BLANK_STRING,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.CHAR_BLANK_STRING
        };
            
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(System.Label.DYNLIST_PLEASE_SPECIFY_PAGE_SIZE, dynlistGrid.messages[0]);
        //testing for Table view - End 
        
        //testing for Table view - Start
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => 'Name,StageName,Amount',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => false,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
        
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(5, dynlistGrid.body);
        //testing for Table view - End
        
        //testing for Table view - Start
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => 'Name,StageName,Amount',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => false,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => '0015g00000SR4h5AAD',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
		
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        
        //testing for Table view - Start
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => 'Op__c',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => 'Name,StageName,Amount',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => false,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
                    
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(System.Label.DYNLIST_INVALID_OBJECT_NAME,dynlistGrid.messages[0]);
        
        //testing for Table view - Start
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => 'DRL_Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => null,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => 'Name,StageName,Amount',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => null,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => false,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_PARENT_FIELD_NAME => 'AccountId'
        };
                    
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(System.Label.DYNLIST_INVALID_FIELD_SET_NAME,dynlistGrid.messages[0]);
        //testing for Table view - End
        
        //stop test here
        Test.stopTest();
        
        Map<String,Object> dataGridRequest1;
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest1);
        System.assertEquals(System.Label.DYNLIST_REQUEST_PARAMS_MISSING,dynlistGrid.messages[0]);
        
        dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => 'Tale',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => 'x'
         };
                    
         dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
    }
    
    // this method is to test all the use cases associated with "dynlistDataGridController.getDataRecords" method
    @isTest(seeAllData=false)
    static void testGetDataRecords2()
    {
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());
        
        List<Account> accList = [Select Id,Name From Account]; 
        
        //testing for Table view - Start
        Map<String,Object> dataGridRequest = new Map<String,Object>
        {
            dynlistConstants.DATA_GRID_REQUEST_PARAM_VIEW => dynlistConstants.VIEW_TYPE_TABLE,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_PAGE_SIZE => '5',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OBJECT_NAME => dynlistConstants.OBJECT_NAME_OPPORTUNITY,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_FIELD_SET_NAME => System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_WHERE_CLAUSE => 'Name != null',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_GROUP_BY_FIELD_NAME => 'Stagename',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SUMMARIZE_BY_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_SOQL_SELECT_FIELDS_NAME => dynlistConstants.CHAR_BLANK_STRING,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_FIELD_NAME => dynlistConstants.NAME_FIELD_NAME,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_DEFAULT_SORT_DIRECTION => dynlistConstants.CHAR_ASC,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_NULLS_FIRST_OR_LAST => dynlistConstants.CHAR_NULLS_LAST,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_LIMIT_STRING => '50',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_OFFSET_STRING => '2',
                dynlistConstants.DATA_GRID_REQUEST_PARAM_ENFORCE_WITH_SECURITY_MODE => true,
                dynlistConstants.IS_COLUMNS_AND_FILTERS_SECTION_NEEDED => true,
                dynlistConstants.DATA_GRID_REQUEST_PARAM_CURRENT_CONTEXT_RECORD_ID => String.valueOf(accList[0].Id),
                dynlistConstants.DATA_GRID_REQUEST_PARAM_SEARCH_BY => 'Test',
                dynlistConstants.RECORD_PAGE_PARENT_FIELD_API_NAME => 'AccountId',
                dynlistConstants.RECORD_PAGE_PARENT_OBJECT_API_NAME => 'Account',
                dynlistConstants.RECORD_PAGE_PARENT_TO_PARENT_FIELD_MAPPING => null,
                dynlistConstants.IS_SYSTEM_MODE => false
        };
            
        //Start test from here
        Test.startTest();
        
        dynlistDataGrid dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        System.assertEquals(3, dynlistGrid.body);
        
        dataGridRequest.put(dynlistConstants.RECORD_PAGE_PARENT_TO_PARENT_FIELD_MAPPING, 'OwnerId-->Account.OwnerId');
        
        dynlistGrid = dynlistDataGridController.getDataRecords(dataGridRequest);
        //testing for Table view - End 
        
        //Start test from here
        Test.stopTest();
    }    
    
    // this method is to test all the use cases associated with "dynlistDataGridController.saveRecordData" method
    @isTest(seeAllData=false)
    static void testSaveRecordData()
    {    
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());       
        
        //Converting the dynlistRow list in JSON
        String rowsWrapper = '[{"title":"0","summarizeByFieldValue":null,"selected":true,"rowNumber":1,"recId":"'+oppList[0].Id+'","isAlreadyProcessed":null,"groupByFieldValue":null,"fields":[{"viewable":null,"variant":"label-hidden","values":null,"valueField":null,"value":"'+oppList[0].Id
            +'","validity":null,"valid":null,"uniqueKey":"'+oppList[0].Id
            +'-Id","type":"ID","tooltip":null,"title":null,"timezone":null,"timeStyle":null,"timeAriaLabelledBy":null,"timeAriaDescribedBy":null,"timeAriaControls":null,"target":"_blank","tabindex":null,"styleClass":null,"style":null,"step":null,"spellcheck":null,"sourceLabel":"Available","sObjectName":null,"size":null,"shareWithEntityId":null,"shape":null,"selectedLabel":"Selected","selected":null,"scale":null,"rowNumber":1,"rev":null,"required":true,"relationshipName":null,"rel":null,"referenceTargetField":null,"referenceFieldValue":null,"referencedObjectPluralLabel":null,"referencedObjectName":null,"referencedObjectLabel":null,"recordId":"'+oppList[0].Id
            +'","readOnly":true,"precision":null,"placeholder":null,"pattern":null,"options":null,"optionalFilter":false,"operation":null,"name":"Id","multiple":null,"minLength":null,"minimumSignificantDigits":null,"minimumIntegerDigits":null,"minimumFractionDigits":null,"min":null,"messageWhenValueMissing":null,"messageWhenTypeMismatch":null,"messageWhenTooShort":null,"messageWhenTooLong":null,"messageWhenStepMismatch":null,"messageWhenRangeUnderflow":null,"messageWhenRangeOverflow":null,"messageWhenPatternMismatch":null,"messageWhenBadInput":null,"messageToggleInactive":null,"messageToggleActive":null,"maxLength":null,"maximumSignificantDigits":null,"maximumFractionDigits":null,"max":null,"lookupData":null,"localName":null,"linkify":null,"length":null,"lang":null,"labelVisible":null,"label":"Institution ID","isUpdateable":null,"isUnique":null,"isSortable":true,"isRecordTypeField":false,"isPermissionable":null,"isNillable":null,"isNamePointing":null,"isNameField":false,"isLoading":null,"isImageFormula":null,"isIdLookup":null,"isHtmlFormatted":null,"isHidden":null,"isGroupable":null,"isFilterable":null,"isExternalID":null,"isDropEnabled":null,"isDependentPicklist":null,"isDefaultedOnCreate":null,"isCustom":null,"isCreateable":null,"isCaseSensitive":null,"isCascadeDelete":null,"isCalculated":null,"isAutoNumber":null,"isAccessible":null,"id":"Id1","hyperlinkURL":null,"hyperlinkTitle":null,"hyperlinkLabel":null,"hreflang":null,"href":null,"hideIcon":null,"hidefocus":null,"headerTitle":null,"headerLabel":"Institution ID","fsMember":null,"formatter":null,"formatStyle":null,"formats":null,"formatFractionDigits":null,"format":null,"files":null,"fieldType":null,"fieldName":"Id","fieldLevelHelp":null,"fieldCellStyleClass":"ID","extraResultFields":null,"error":null,"editMode":false,"draggable":null,"displayValue":null,"displaySortingIcon":false,"displayArrowUpIcon":false,"displayArrowDownIcon":false,"disableLinkify":null,"disabledCategories":null,"disabled":null,"dir":null,"digits":null,"defaultValue":null,"dateStyle":null,"dateAriaLabelledBy":null,"dateAriaLabel":null,"dateAriaDescribedBy":null,"dateAriaControls":null,"customButtons":null,"currencyDisplayAs":null,"currencyCode":null,"cssStyle":null,"checked":null,"charset":null,"cellNumber":1,"autocomplete":null,"ariaLabelledBy":null,"ariaLabel":null,"ariaDescribedBy":null,"ariaControls":null,"accessKey":null,"accept":null},{"viewable":null,"variant":"label-hidden","values":null,"valueField":null,"value":"0","validity":null,"valid":null,"uniqueKey":"'+oppList[0].Id+'-Name","type":"STRING","tooltip":null,"title":"0","timezone":null,"timeStyle":null,"timeAriaLabelledBy":null,"timeAriaDescribedBy":null,"timeAriaControls":null,"target":"_blank","tabindex":null,"styleClass":null,"style":null,"step":null,"spellcheck":null,"sourceLabel":"Available","sObjectName":null,"size":null,"shareWithEntityId":null,"shape":null,"selectedLabel":"Selected","selected":null,"scale":null,"rowNumber":1,"rev":null,"required":true,"relationshipName":null,"rel":null,"referenceTargetField":null,"referenceFieldValue":null,"referencedObjectPluralLabel":null,"referencedObjectName":null,"referencedObjectLabel":null,"recordId":"'+oppList[0].Id+'","readOnly":false,"precision":null,"placeholder":null,"pattern":null,"options":null,"optionalFilter":false,"operation":null,"name":"Name","multiple":null,"minLength":null,"minimumSignificantDigits":null,"minimumIntegerDigits":null,"minimumFractionDigits":null,"min":null,"messageWhenValueMissing":null,"messageWhenTypeMismatch":null,"messageWhenTooShort":null,"messageWhenTooLong":null,"messageWhenStepMismatch":null,"messageWhenRangeUnderflow":null,"messageWhenRangeOverflow":null,"messageWhenPatternMismatch":null,"messageWhenBadInput":null,"messageToggleInactive":null,"messageToggleActive":null,"maxLength":null,"maximumSignificantDigits":null,"maximumFractionDigits":null,"max":null,"lookupData":{"selectRecordURL":"https://eab--dynlistph2.my.salesforce.com/'+oppList[0].Id+'","selectedRecordName":"0","selectedRecordId":"'+oppList[0].Id+'","objectName":null,"fieldName":null},"localName":null,"linkify":null,"length":null,"lang":null,"labelVisible":null,"label":"Institution Name","isUpdateable":null,"isUnique":null,"isSortable":true,"isRecordTypeField":false,"isPermissionable":null,"isNillable":null,"isNamePointing":null,"isNameField":true,"isLoading":null,"isImageFormula":null,"isIdLookup":null,"isHtmlFormatted":null,"isHidden":null,"isGroupable":null,"isFilterable":null,"isExternalID":null,"isDropEnabled":null,"isDependentPicklist":null,"isDefaultedOnCreate":null,"isCustom":null,"isCreateable":null,"isCaseSensitive":null,"isCascadeDelete":null,"isCalculated":null,"isAutoNumber":null,"isAccessible":null,"id":"Name2","hyperlinkURL":null,"hyperlinkTitle":null,"hyperlinkLabel":null,"hreflang":null,"href":null,"hideIcon":null,"hidefocus":null,"headerTitle":null,"headerLabel":"Institution Name","fsMember":null,"formatter":null,"formatStyle":null,"formats":null,"formatFractionDigits":null,"format":null,"files":null,"fieldType":null,"fieldName":"Name","fieldLevelHelp":null,"fieldCellStyleClass":"STRING","extraResultFields":null,"error":null,"editMode":false,"draggable":null,"displayValue":null,"displaySortingIcon":true,"displayArrowUpIcon":true,"displayArrowDownIcon":false,"disableLinkify":null,"disabledCategories":null,"disabled":null,"dir":null,"digits":null,"defaultValue":null,"dateStyle":null,"dateAriaLabelledBy":null,"dateAriaLabel":null,"dateAriaDescribedBy":null,"dateAriaControls":null,"customButtons":null,"currencyDisplayAs":null,"currencyCode":null,"cssStyle":null,"checked":null,"charset":null,"cellNumber":2,"autocomplete":null,"ariaLabelledBy":null,"ariaLabel":null,"ariaDescribedBy":null,"ariaControls":null,"accessKey":null,"accept":null}],"errorMessageForRow":null,"editMode":false}]';
        
        String sObjectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        
        dynlistDataGrid dynlistGrid = new dynlistDataGrid();
        dynlistGrid = dynlistDataGridController.saveRecordData(sObjectName,rowsWrapper);
        
        Profile p = [SELECT Id FROM Profile WHERE Name =: System.Label.DYNLIST_CHATTER_FREE_USER_PROFILE_NAME]; 
        User u = new User(Alias = 'standt', Email='standarduser876543@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing1234', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey=System.Label.DYNLIST_DEFAULT_TIME_ZONE_SID_KEY, 
                          UserName='standarduser78965@testorg.com');
        
        Util.BypassAllTriggers = true;
        insert u;
        Util.BypassAllTriggers = false;
        
        //Start test from here
        Test.startTest();
        
        System.runAs(u) 
        {
            dynlistDataGrid dynlistGrid1 = new dynlistDataGrid();
            dynlistGrid1 = dynlistDataGridController.saveRecordData(sObjectName,rowsWrapper);     
        }
        
        //Stop test here
        Test.stopTest();
    }
    
    // this method is to test all the use cases associated with "dynlistDataGridController.updateRecordOnDrop" method
    @isTest(seeAllData=false)
    static void testUpdateRecordOnDrop()
    {    
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());
        
        Id recId = oppList[0].Id;
        String kanbanField = dynlistConstants.NAME_FIELD_NAME;
        String kanbanNewValue = 'Test';
        
        //Start test from here
        Test.startTest();
        
        String updateRecord = dynlistDataGridController.updateRecordOnDrop(recId,kanbanField,kanbanNewValue);
        
        //Stop test here
        Test.stopTest();
    }
    
    // this method is to test all the use cases associated with "dynlistDataGridController.deleteRecordData" method
    @isTest(seeAllData=false)
    static void testDeleteRecordData()
    {    
        //List of Opportunity
        List<Opportunity> oppList = dynlistTestDataFactory.createListOfOpportunitiesTestData();
        System.assertEquals(5,oppList.size());
        
        String selectedRecord = String.valueOf(oppList[0].Id);
        //Converting the dynlistRow list in JSON
        String rowsWrapper = '[{"title":"0","summarizeByFieldValue":null,"selected":true,"rowNumber":1,"recId":"'+oppList[0].Id+'","isAlreadyProcessed":null,"groupByFieldValue":null,"fields":[{"viewable":null,"variant":"label-hidden","values":null,"valueField":null,"value":"'+oppList[0].Id
            +'","validity":null,"valid":null,"uniqueKey":"'+oppList[0].Id
            +'-Id","type":"ID","tooltip":null,"title":null,"timezone":null,"timeStyle":null,"timeAriaLabelledBy":null,"timeAriaDescribedBy":null,"timeAriaControls":null,"target":"_blank","tabindex":null,"styleClass":null,"style":null,"step":null,"spellcheck":null,"sourceLabel":"Available","sObjectName":null,"size":null,"shareWithEntityId":null,"shape":null,"selectedLabel":"Selected","selected":null,"scale":null,"rowNumber":1,"rev":null,"required":true,"relationshipName":null,"rel":null,"referenceTargetField":null,"referenceFieldValue":null,"referencedObjectPluralLabel":null,"referencedObjectName":null,"referencedObjectLabel":null,"recordId":"'+oppList[0].Id
            +'","readOnly":true,"precision":null,"placeholder":null,"pattern":null,"options":null,"optionalFilter":false,"operation":null,"name":"Id","multiple":null,"minLength":null,"minimumSignificantDigits":null,"minimumIntegerDigits":null,"minimumFractionDigits":null,"min":null,"messageWhenValueMissing":null,"messageWhenTypeMismatch":null,"messageWhenTooShort":null,"messageWhenTooLong":null,"messageWhenStepMismatch":null,"messageWhenRangeUnderflow":null,"messageWhenRangeOverflow":null,"messageWhenPatternMismatch":null,"messageWhenBadInput":null,"messageToggleInactive":null,"messageToggleActive":null,"maxLength":null,"maximumSignificantDigits":null,"maximumFractionDigits":null,"max":null,"lookupData":null,"localName":null,"linkify":null,"length":null,"lang":null,"labelVisible":null,"label":"Institution ID","isUpdateable":null,"isUnique":null,"isSortable":true,"isRecordTypeField":false,"isPermissionable":null,"isNillable":null,"isNamePointing":null,"isNameField":false,"isLoading":null,"isImageFormula":null,"isIdLookup":null,"isHtmlFormatted":null,"isHidden":null,"isGroupable":null,"isFilterable":null,"isExternalID":null,"isDropEnabled":null,"isDependentPicklist":null,"isDefaultedOnCreate":null,"isCustom":null,"isCreateable":null,"isCaseSensitive":null,"isCascadeDelete":null,"isCalculated":null,"isAutoNumber":null,"isAccessible":null,"id":"Id1","hyperlinkURL":null,"hyperlinkTitle":null,"hyperlinkLabel":null,"hreflang":null,"href":null,"hideIcon":null,"hidefocus":null,"headerTitle":null,"headerLabel":"Institution ID","fsMember":null,"formatter":null,"formatStyle":null,"formats":null,"formatFractionDigits":null,"format":null,"files":null,"fieldType":null,"fieldName":"Id","fieldLevelHelp":null,"fieldCellStyleClass":"ID","extraResultFields":null,"error":null,"editMode":false,"draggable":null,"displayValue":null,"displaySortingIcon":false,"displayArrowUpIcon":false,"displayArrowDownIcon":false,"disableLinkify":null,"disabledCategories":null,"disabled":null,"dir":null,"digits":null,"defaultValue":null,"dateStyle":null,"dateAriaLabelledBy":null,"dateAriaLabel":null,"dateAriaDescribedBy":null,"dateAriaControls":null,"customButtons":null,"currencyDisplayAs":null,"currencyCode":null,"cssStyle":null,"checked":null,"charset":null,"cellNumber":1,"autocomplete":null,"ariaLabelledBy":null,"ariaLabel":null,"ariaDescribedBy":null,"ariaControls":null,"accessKey":null,"accept":null},{"viewable":null,"variant":"label-hidden","values":null,"valueField":null,"value":"0","validity":null,"valid":null,"uniqueKey":"'+oppList[0].Id+'-Name","type":"STRING","tooltip":null,"title":"0","timezone":null,"timeStyle":null,"timeAriaLabelledBy":null,"timeAriaDescribedBy":null,"timeAriaControls":null,"target":"_blank","tabindex":null,"styleClass":null,"style":null,"step":null,"spellcheck":null,"sourceLabel":"Available","sObjectName":null,"size":null,"shareWithEntityId":null,"shape":null,"selectedLabel":"Selected","selected":null,"scale":null,"rowNumber":1,"rev":null,"required":true,"relationshipName":null,"rel":null,"referenceTargetField":null,"referenceFieldValue":null,"referencedObjectPluralLabel":null,"referencedObjectName":null,"referencedObjectLabel":null,"recordId":"'+oppList[0].Id+'","readOnly":false,"precision":null,"placeholder":null,"pattern":null,"options":null,"optionalFilter":false,"operation":null,"name":"Name","multiple":null,"minLength":null,"minimumSignificantDigits":null,"minimumIntegerDigits":null,"minimumFractionDigits":null,"min":null,"messageWhenValueMissing":null,"messageWhenTypeMismatch":null,"messageWhenTooShort":null,"messageWhenTooLong":null,"messageWhenStepMismatch":null,"messageWhenRangeUnderflow":null,"messageWhenRangeOverflow":null,"messageWhenPatternMismatch":null,"messageWhenBadInput":null,"messageToggleInactive":null,"messageToggleActive":null,"maxLength":null,"maximumSignificantDigits":null,"maximumFractionDigits":null,"max":null,"lookupData":{"selectRecordURL":"https://eab--dynlistph2.my.salesforce.com/'+oppList[0].Id+'","selectedRecordName":"0","selectedRecordId":"'+oppList[0].Id+'","objectName":null,"fieldName":null},"localName":null,"linkify":null,"length":null,"lang":null,"labelVisible":null,"label":"Institution Name","isUpdateable":null,"isUnique":null,"isSortable":true,"isRecordTypeField":false,"isPermissionable":null,"isNillable":null,"isNamePointing":null,"isNameField":true,"isLoading":null,"isImageFormula":null,"isIdLookup":null,"isHtmlFormatted":null,"isHidden":null,"isGroupable":null,"isFilterable":null,"isExternalID":null,"isDropEnabled":null,"isDependentPicklist":null,"isDefaultedOnCreate":null,"isCustom":null,"isCreateable":null,"isCaseSensitive":null,"isCascadeDelete":null,"isCalculated":null,"isAutoNumber":null,"isAccessible":null,"id":"Name2","hyperlinkURL":null,"hyperlinkTitle":null,"hyperlinkLabel":null,"hreflang":null,"href":null,"hideIcon":null,"hidefocus":null,"headerTitle":null,"headerLabel":"Institution Name","fsMember":null,"formatter":null,"formatStyle":null,"formats":null,"formatFractionDigits":null,"format":null,"files":null,"fieldType":null,"fieldName":"Name","fieldLevelHelp":null,"fieldCellStyleClass":"STRING","extraResultFields":null,"error":null,"editMode":false,"draggable":null,"displayValue":null,"displaySortingIcon":true,"displayArrowUpIcon":true,"displayArrowDownIcon":false,"disableLinkify":null,"disabledCategories":null,"disabled":null,"dir":null,"digits":null,"defaultValue":null,"dateStyle":null,"dateAriaLabelledBy":null,"dateAriaLabel":null,"dateAriaDescribedBy":null,"dateAriaControls":null,"customButtons":null,"currencyDisplayAs":null,"currencyCode":null,"cssStyle":null,"checked":null,"charset":null,"cellNumber":2,"autocomplete":null,"ariaLabelledBy":null,"ariaLabel":null,"ariaDescribedBy":null,"ariaControls":null,"accessKey":null,"accept":null}],"errorMessageForRow":null,"editMode":false}]';
        
        String sObjectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        
        dynlistDataGrid dynlistGrid = new dynlistDataGrid();
        dynlistGrid = dynlistDataGridController.deleteRecordData(sObjectName,rowsWrapper,selectedRecord);
        
        dynlistDataGrid dynlistGrid1 = new dynlistDataGrid();
        dynlistGrid1 = dynlistDataGridController.deleteRecordData(sObjectName,rowsWrapper,dynlistConstants.CHAR_BLANK_STRING);
        
        Profile p = [SELECT Id FROM Profile WHERE Name=: System.Label.DYNLIST_CHATTER_FREE_USER_PROFILE_NAME]; 
        User u = new User(Alias = 'standt', Email='standarduser876543@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing1234', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey=System.Label.DYNLIST_DEFAULT_TIME_ZONE_SID_KEY, 
                          UserName='standarduser78965@testorg.com');
        
        Util.BypassAllTriggers = true;
        insert u;
        Util.BypassAllTriggers = false;
        
        //Start test from here
        Test.startTest();
        
        System.runAs(u) 
        {
            dynlistDataGrid dynlistGrid3 = new dynlistDataGrid();
            dynlistGrid3 = dynlistDataGridController.deleteRecordData(sObjectName,rowsWrapper,selectedRecord);
        }
        
        //Stop test here
        Test.stopTest();
    }
    
    // this method is to test all the use cases associated with "dynlistDataGridController.refreshDataGridViewStates" method
    @isTest(seeAllData=false)
    static void testRefreshDataGridViewStates()
    {
        //Start test from here
        Test.startTest();
        
        String refreshDataGridViewStates = dynlistDataGridController.refreshDataGridViewStates();
        System.assert(refreshDataGridViewStates != null);
        
        //Start test from here
        Test.stopTest();
    }
}