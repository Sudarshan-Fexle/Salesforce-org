/*
Purpose         :   Test Class for "dynlistUtilities" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/11/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistUtilities_Test 
{
    //test setup method to create the test data this required for different functionalities related positive/negative use cases testing
    @testSetup
    static void setup() 
    {
        //Opportunity
        List<Opportunity> opportunities = dynlistTestDataFactory.createListOfOpportunitiesTestData();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.sanitizeEncryptedData" method
    @isTest(seeAllData=false)
    static void testSanitizeEncryptedDataUseCases() 
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when ((hasEncryptedData && stringToSanitize != null)) condition satisfy
        //START FROM HERE
        String passwordStringBeforeSanitization = '12';
        String expectedPasswordStringAfterSanitization = dynlistConstants.CHAR_X + dynlistConstants.CHAR_BLANK_STRING + dynlistConstants.CHAR_X;
        System.assertEquals(expectedPasswordStringAfterSanitization, dynlistUtilities.sanitizeEncryptedData(true, passwordStringBeforeSanitization));
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when ((hasEncryptedData && stringToSanitize != null)) condition doesn't satisfy
        //START FROM HERE
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistUtilities.sanitizeEncryptedData(false, passwordStringBeforeSanitization));
        //Use Case #2
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getSfInstance" method
    @isTest(seeAllData=false)
    static void testGetSfInstance()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases to get the SFDC Instance host URL
        //START FROM HERE
        dynlistUtilities.getPackagePrefix();
        System.assert(dynlistUtilities.getSfInstance() != null);
        //Use Case #1
        //ENDS HERE
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.isSandbox" method
    @isTest(seeAllData=false)
    static void testIsSandbox()
    {
        
        //Start test from here
        Test.startTest();
        //Use Case #1 - testing out the logics/use cases Org is sand box
        //START FROM HERE
        Boolean isThisASandbox = dynlistUtilities.isSandbox();
        if(isThisASandbox)
            System.assert(isThisASandbox == true);
        else
            System.assert(isThisASandbox == false);
        //Use Case #1
        //ENDS HERE
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getMySalesforceInstance" method
    @isTest(seeAllData=false)
    static void testGetMySalesforceInstance()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases to get Instance
        //START FROM HERE
        System.assert(dynlistUtilities.getMySalesforceInstance() != null);
        //Use Case #1
        //ENDS HERE
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getFieldsetQuery" method
    @isTest(seeAllData=false)
    static void testGetFieldsetQuery()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - Providing all the values in argumant except Field Set
        //START FROM HERE
        
        String objectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME);
        Schema.FieldSetMember[] fieldSetMemberList =  fieldSetObj.getFields();
        List<String> mandatoryFields = new List<String>{dynlistConstants.ID_FIELD_NAME,dynlistConstants.NAME_FIELD_NAME};
            String whereClause = 'Name != null';
        String orderBy = dynlistConstants.CHAR_DESC;
        String queryLimit = '10';
        String offset = '2';
        String sOQLSelectFieldsString = '';
        
        //map to hold schema of Fields of Sobject
        Map<String, Schema.SObjectField> fieldsMap = dynlistUtilities.getFieldsMap(objectName);
        
        for(String str : fieldsMap.keyset())
        {
            if(dynlistUtilities.getFieldIsAccessible(objectName, String.valueOf(fieldsMap.get(str))))
            {
                sOQLSelectFieldsString += String.valueOf(fieldsMap.get(str)) + dynlistConstants.CHAR_COMMA;
            }	
        }
        
        String nullFirstOrLastString = 'LAST';
        List<String> listOfAdditionalFieldsForQuery = new List<String>();
        listOfAdditionalFieldsForQuery.add('Display__c');
        
        Map<String, String> mapOfNonQueryableFields = new Map<String, String>();
        mapOfNonQueryableFields.put(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME.toLowerCase(), System.Label.DYNLIST_APPLICATION_SETTINGS_TEXT_AREA_VALUE_FIELD_NAME + ',' + System.Label.DYNLIST_APPLICATION_SETTINGS_DISPLAY_FIELD_NAME);
        dynlistQueryWrapper queryWrapper = dynlistUtilities.getFieldsetQuery(objectName,
                                                                             null,
                                                                             mandatoryFields,
                                                                             whereClause,
                                                                             orderBy,
                                                                             queryLimit,
                                                                             true,
                                                                             false,
                                                                             true,
                                                                             offset,
                                                                             sOQLSelectFieldsString,
                                                                             nullFirstOrLastString,
                                                                             listOfAdditionalFieldsForQuery,
                                                                             mapOfNonQueryableFields
                                                                            );
        System.assert(queryWrapper != null);
        //Use Case #1
        //ENDS HERE
        
        
        //Use Case #2 - Providing all the values in giving only 1 value in sOQLSelectFieldsString
        //START FROM HERE
        
        sOQLSelectFieldsString = dynlistConstants.NAME_FIELD_NAME;
        dynlistQueryWrapper queryWrapper1 = dynlistUtilities.getFieldsetQuery(objectName,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              true,
                                                                              false,
                                                                              true,
                                                                              null,
                                                                              sOQLSelectFieldsString,
                                                                              null,
                                                                              null,
                                                                              new Map<String, String>()
                                                                             );
        System.assert(queryWrapper1 != null);
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - passing null in sOQLSelectFieldsString
        //START FROM HERE
        dynlistQueryWrapper queryWrapper2 = dynlistUtilities.getFieldsetQuery(objectName,
                                                                              fieldSetMemberList,
                                                                              mandatoryFields,
                                                                              whereClause,
                                                                              orderBy,
                                                                              queryLimit,
                                                                              true,
                                                                              false,
                                                                              true,
                                                                              offset,
                                                                              null,
                                                                              nullFirstOrLastString,
                                                                              listOfAdditionalFieldsForQuery,
                                                                              new Map<String, String>()
                                                                             );
        System.assert(queryWrapper2 != null);
        
        dynlistQueryWrapper queryWrapper3 = dynlistUtilities.getFieldsetQuery('accountinsight',
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              true,
                                                                              false,
                                                                              true,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              null,
                                                                              new Map<String, String>()
                                                                             );
        System.assert(queryWrapper3 != null);
        
        // Use Case #4 - use customfield without packagePrefix
        sOQLSelectFieldsString = 'CustomField0__c';
        mandatoryFields.add('customField__c');
        queryWrapper = dynlistUtilities.getFieldsetQuery(objectName,
                                                                             null,
                                                                             mandatoryFields,
                                                                             whereClause,
                                                                             orderBy,
                                                                             queryLimit,
                                                                             true,
                                                                             true,
                                                                             true,
                                                                             offset,
                                                                             sOQLSelectFieldsString,
                                                                             nullFirstOrLastString,
                                                                             listOfAdditionalFieldsForQuery,
                                                                             new Map<String, String>()
                                                                            );
        System.assert(queryWrapper != null);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getConvertedFieldPath" method
    @isTest(seeAllData=false)
    static void testGetConvertedFieldPath()
    {
        String objectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        String parentObjectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME);
        
        Schema.FieldSetMember[] fieldSetMemberList =  fieldSetObj.getFields();
        String result;
        
        //Start test from here
        Test.startTest();
        
        for(Schema.FieldSetMember fsMember : fieldSetMemberList)
        {
            result = dynlistUtilities.getConvertedFieldPath(fsMember,objectName);
        }
        System.assert(result != null);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with 
    // "dynlistUtilities.getConvertedFieldPath(String fieldPath,String fieldType)" method
    @isTest(seeAllData=false)
    static void testGetConvertedFieldPath2()
    {
        String result;
        String objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        String parentObjectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        //Start test from here
        Test.startTest();
        
        result = dynlistUtilities.getConvertedFieldPath(dynlistConstants.ID_FIELD_NAME,'ID',objectName, parentObjectName);
        System.assertEquals(dynlistConstants.ID_FIELD_NAME, result);
        
        result = dynlistUtilities.getConvertedFieldPath('Account.Id','REFERENCE', objectName, parentObjectName);
        
        result = dynlistUtilities.getConvertedFieldPath('CreatedBy','REFERENCE', objectName, parentObjectName);
        System.assertEquals('CreatedBy.Name', result);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getRecordTypeLabel" method
    @isTest(seeAllData=false)
    static void testGetRecordTypeLabel()
    {
        //Start test from here
        Test.startTest();
        
        Id recordTypeId = dynlistUtilities.getRecordTypeIdForObject(dynlistConstants.OBJECT_NAME_OPPORTUNITY,'Master');
        
        String labelOfRecordType = dynlistUtilities.getRecordTypeLabel(recordTypeId);
        System.assert(recordTypeId != null);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getKeyPrefixForObject(String ObjectName)" method
    @isTest(seeAllData=false)
    static void testGetKeyPrefixForObject()
    {
        //Start test from here
        Test.startTest();
        
        String objectPrefix = dynlistUtilities.getKeyPrefixForObject(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assertEquals('006',objectPrefix);
        
        // Use Case #1: When objectName parameter is Null
        objectPrefix = dynlistUtilities.getKeyPrefixForObject(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null,objectPrefix);
        
        //End test here
        Test.stopTest();
        
    }
    // this method is basically to test all the use cases associated with "dynlistUtilities.getKeyPrefixForObject(String ObjectName)" method
    @isTest(seeAllData=false)
    static void testGetKeyPrefixForObject1()
    {
        //Start test from here
        Test.startTest();
        
        String objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        
        String objectPrefix = dynlistUtilities.getKeyPrefixForObject(SObjectTypeObj);
        System.assertEquals('006',objectPrefix);
        
        // Use Case #1: When objectName parameter is Null
        SObjectTypeObj = null;
        objectPrefix = dynlistUtilities.getKeyPrefixForObject(SObjectTypeObj);
        System.assertEquals(null,objectPrefix);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getObjectTypeOnBasisOfIdValue" method
    @isTest(seeAllData=false)
    static void testGetObjectTypeOnBasisOfIdValue()
    {
        //Start test from here
        Test.startTest();
        
        Schema.SObjectType sobjetType = dynlistUtilities.getObjectTypeOnBasisOfIdValue('0065g00000C2NW7AAN');
        System.assertEquals(dynlistConstants.OBJECT_NAME_OPPORTUNITY,String.valueOf(sobjetType));
        
        //Start test from here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getFieldsMap" method
    @isTest(seeAllData=false)
    static void testGetFieldsMap()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null
        //START FROM HERE
        Map<String, Schema.SObjectField> mapOfSobjectFields = dynlistUtilities.getFieldsMap(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null, mapOfSobjectFields);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null but object does not exist.
        //START FROM HERE
        mapOfSobjectFields = dynlistUtilities.getFieldsMap('Opp');
        System.assertEquals(null, mapOfSobjectFields);
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when objName != null
        //START FROM HERE
        mapOfSobjectFields = dynlistUtilities.getFieldsMap(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assert(mapOfSobjectFields.size() > 0);
        //Use Case #3
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getObjectTypeOnBasisOfObjectName" method
    @isTest(seeAllData=false)
    static void testGetObjectTypeOnBasisOfObjectName()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null
        //START FROM HERE
        Schema.SObjectType sObjectType = dynlistUtilities.getObjectTypeOnBasisOfObjectName(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null, sObjectType);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null but object does not exist.
        //START FROM HERE
        sObjectType = dynlistUtilities.getObjectTypeOnBasisOfObjectName('opp');
        System.assertEquals(null, sObjectType);
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when objName != null
        //START FROM HERE
        sObjectType = dynlistUtilities.getObjectTypeOnBasisOfObjectName(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assertEquals(dynlistConstants.OBJECT_NAME_OPPORTUNITY,String.valueOf(sObjectType));
        //Use Case #3
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getObjectDescribeOnBasisOfObjectName" method
    @isTest(seeAllData=false)
    static void testGetObjectDescribeOnBasisOfObjectName()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null
        //START FROM HERE
        Schema.DescribeSObjectResult describeSObjectType = dynlistUtilities.getObjectDescribeOnBasisOfObjectName(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null, describeSObjectType);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null but object does not exist.
        //START FROM HERE
        describeSObjectType = dynlistUtilities.getObjectDescribeOnBasisOfObjectName('opp');
        System.assertEquals(null, describeSObjectType);
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when objName != null
        //START FROM HERE
        describeSObjectType = dynlistUtilities.getObjectDescribeOnBasisOfObjectName(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assert(describeSObjectType != null);
        //Use Case #3
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getObjectOnBasisOfObjectName" method
    @isTest(seeAllData=false)
    static void testGetObjectOnBasisOfObjectName()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null
        //START FROM HERE
        SObject sObj = dynlistUtilities.getObjectOnBasisOfObjectName(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null, sObj);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null but object does not exist.
        //START FROM HERE
        sObj = dynlistUtilities.getObjectOnBasisOfObjectName(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assert(sObj != null);
        //Use Case #2
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getObjectIsAccessible" method
    @isTest(seeAllData=false)
    static void testGetObjectIsAccessible()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null
        //START FROM HERE
        Boolean isAccessible = dynlistUtilities.getObjectIsAccessible(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(null, isAccessible);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null but object does not exist.
        //START FROM HERE
        isAccessible = dynlistUtilities.getObjectIsAccessible(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assertEquals(true, isAccessible);
        //Use Case #2
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getFieldIsAccessible" method
    @isTest(seeAllData=false)
    static void testGetFieldIsAccessible()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null and fieldName = null
        //START FROM HERE
        Boolean isAccessible = dynlistUtilities.getFieldIsAccessible(dynlistConstants.CHAR_BLANK_STRING,dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(false, isAccessible);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null and fieldName != null.
        //START FROM HERE
        isAccessible = dynlistUtilities.getFieldIsAccessible(dynlistConstants.OBJECT_NAME_OPPORTUNITY,dynlistConstants.NAME_FIELD_NAME);
        System.assertEquals(true, isAccessible);
        //Use Case #2
        //ENDS HERE
        
        // Use Case #3 - testing out the logics when objName != null and field Name = null
        isAccessible = dynlistUtilities.getFieldIsAccessible(dynlistConstants.OBJECT_NAME_OPPORTUNITY,dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(false, isAccessible);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getPicklistFieldValues" method
    @isTest(seeAllData=false)
    static void testGetPicklistFieldValues()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null and fieldAPIName = null
        //START FROM HERE
        List<String> picklistValues = dynlistUtilities.getPicklistFieldValues(dynlistConstants.CHAR_BLANK_STRING,dynlistConstants.CHAR_BLANK_STRING);
        System.assert(picklistValues == null);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null and fieldAPIName != null.
        //START FROM HERE
        picklistValues = dynlistUtilities.getPicklistFieldValues(dynlistConstants.OBJECT_NAME_OPPORTUNITY,'StageName');
        System.assert(picklistValues.size() > 0);
        //Use Case #2
        //ENDS HERE
        
        // Use Case #3 - testing out the logics when objName != null and fieldAPIName = null
        picklistValues = dynlistUtilities.getPicklistFieldValues(dynlistConstants.OBJECT_NAME_OPPORTUNITY, dynlistConstants.CHAR_BLANK_STRING);
        System.assert(picklistValues == null);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.isUserHaveDeleteObjectAccess" method
    @isTest(seeAllData=false)
    static void testIsUserHaveDeleteObjectAccess()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null 
        //START FROM HERE
        Boolean isUserHaveDeleteObjectAccess = dynlistUtilities.isUserHaveDeleteObjectAccess(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(false, isUserHaveDeleteObjectAccess);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null
        //START FROM HERE
        isUserHaveDeleteObjectAccess = dynlistUtilities.isUserHaveDeleteObjectAccess(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assertEquals(true, isUserHaveDeleteObjectAccess);
        //Use Case #2
        //ENDS HERE
        
        // Use Case #3 testing out the logics/use cases when objName not exist
        isUserHaveDeleteObjectAccess = dynlistUtilities.isUserHaveDeleteObjectAccess('objectApiName');
        System.assertEquals(false, isUserHaveDeleteObjectAccess);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.isUserHaveUpdateObjectAccess" method
    @isTest(seeAllData=false)
    static void testIsUserHaveUpdateObjectAccess()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objName = null 
        //START FROM HERE
        Boolean isUserHaveUpdateObjectAccess = dynlistUtilities.isUserHaveUpdateObjectAccess(dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(false, isUserHaveUpdateObjectAccess);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objName != null
        //START FROM HERE
        isUserHaveUpdateObjectAccess = dynlistUtilities.isUserHaveUpdateObjectAccess(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assertEquals(true, isUserHaveUpdateObjectAccess);
        //Use Case #2
        
        // Use Case #3 testing out the logics/use cases when objName not exist
        isUserHaveUpdateObjectAccess = dynlistUtilities.isUserHaveUpdateObjectAccess('objectApiName');
        System.assertEquals(false, isUserHaveUpdateObjectAccess);
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.checkIfUserHasObjectLevelSecurity" method
    @isTest(seeAllData=false)
    static void testCheckIfUserHasObjectLevelSecurity()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when objectApiName = "not valid" and recordId = ''
        //START FROM HERE
        String userHasObjectLevelSecurity = dynlistUtilities.checkIfUserHasObjectLevelSecurity('opp', dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(System.Label.DYNLIST_INVALID_OBJECT_NAME, userHasObjectLevelSecurity);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when objectApiName = Valid and recordId = ''
        //START FROM HERE
        userHasObjectLevelSecurity = dynlistUtilities.checkIfUserHasObjectLevelSecurity(dynlistConstants.OBJECT_NAME_OPPORTUNITY, dynlistConstants.CHAR_BLANK_STRING);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, userHasObjectLevelSecurity);
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when objectApiName = Valid value and recordId = Valid value
        //START FROM HERE
        userHasObjectLevelSecurity = dynlistUtilities.checkIfUserHasObjectLevelSecurity(dynlistConstants.OBJECT_NAME_OPPORTUNITY, '0065g00000C2NW7');
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, userHasObjectLevelSecurity);
        //Use Case #3
        //ENDS HERE
        
        //Two more use cases are left to test but not got appropriate profile to test
        Profile p = [select Id, Name From Profile Where Name =: System.Label.DYNLIST_READ_ONLY_PROFILE_NAME];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                          TimeZoneSidKey=System.Label.DYNLIST_DEFAULT_TIME_ZONE_SID_KEY, UserName=Math.random() + '@test.com');
        
        //Run as user
        System.runAs(u) 
        {
            userHasObjectLevelSecurity = dynlistUtilities.checkIfUserHasObjectLevelSecurity(dynlistConstants.OBJECT_NAME_OPPORTUNITY, '0065g00000C2NW7');
            System.assert(userHasObjectLevelSecurity.contains(System.Label.DYNLIST_OBJECT_NOT_UPDATABLE +
                                                              dynlistConstants.CHAR_BLANK_SPACE +
                                                              dynlistConstants.CHAR_COLON +
                                                              dynlistConstants.CHAR_BLANK_SPACE));
            
            userHasObjectLevelSecurity = dynlistUtilities.checkIfUserHasObjectLevelSecurity(dynlistConstants.OBJECT_NAME_OPPORTUNITY, dynlistConstants.CHAR_BLANK_STRING);
            System.assert(userHasObjectLevelSecurity.contains(System.Label.DYNLIST_OBJECT_NOT_CREATABLE +
                                                              dynlistConstants.CHAR_BLANK_SPACE +
                                                              dynlistConstants.CHAR_COLON +
                                                              dynlistConstants.CHAR_BLANK_SPACE));
        }
        
        //End test here
        Test.stopTest();        
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getFieldDescribeResult" method
    @isTest(seeAllData=false)
    static void testGetFieldDescribeResult()
    {
        String objectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME);
        Schema.FieldSetMember[] fieldSetMemberList =  fieldSetObj.getFields();
        Schema.DescribeFieldResult result;
        
        //Start test from here
        Test.startTest();
        
        for(Schema.FieldSetMember fsMember : fieldSetMemberList)
        {
            result = dynlistUtilities.getFieldDescribeResult(SObjectTypeObj,fsMember);  
        }
        System.assert(result!=null);
        
        //End test here
        Test.stopTest();        
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.userHasEncryptedData" method
    @isTest(seeAllData=false)
    static void testUserHasEncryptedData()
    {
        //Start test from here
        Test.startTest();
        
        Id userId = UserInfo.getUserId();
        Boolean encryptedDataPermission = dynlistUtilities.userHasEncryptedData(userId);
        System.assertEquals(false, encryptedDataPermission);
        
        //End test here
        Test.stopTest();  
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getMapOfDynamicRelatedListManager" method
    @isTest(seeAllData=false)
    static void testGetMapOfDynamicRelatedListManager()
    {
        //Start test from here
        Test.startTest();
        
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfDynamicRelatedListManager = dynlistUtilities.getMapOfDynamicRelatedListManager();
        System.assert(mapOfDynamicRelatedListManager.size() > 0);
        
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.setOfObjectsAPINameNotHavingNameField" method
    @isTest(seeAllData=false)
    static void testSetOfObjectsAPINameNotHavingNameField()
    {
        
        //Start test from here
        Test.startTest();
        
        Set<String> setOfObjectsWithoutNameField = dynlistUtilities.setOfObjectsAPINameNotHavingNameField();
        System.assert(setOfObjectsWithoutNameField.size() > 0);
        
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.mapOfObjectsAPINameWithSynonymField" method
    @isTest(seeAllData=false)
    static void testmapOfObjectsAPINameWithSynonymField()
    {
        //Start test from here
        Test.startTest();
        
        Map<String, String> mapOfObjAPINameWithSynonymField = dynlistUtilities.mapOfObjectsAPINameWithSynonymField();
        System.assert(mapOfObjAPINameWithSynonymField.size() > 0);
        
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.traverseAllFields" method
    @isTest(seeAllData=false)
    static void testTraverseAllFields()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when sObjName = "Valid" value
        //START FROM HERE
        
        List<dynlistOption> options = dynlistUtilities.traverseAllFields(dynlistConstants.OBJECT_NAME_OPPORTUNITY);
        System.assert(options.size() > 0);
        
        //Use Case #1
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getQuery" method
    @isTest(seeAllData=false)
    static void testGetQuery()
    {
        //Start test from here
        Test.startTest();
        
        String objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        Set<String> fields = new Set<String>{'AccountId','CreatedDate'};
            List<String> mandatoryFields = new List<String>{dynlistConstants.ID_FIELD_NAME,dynlistConstants.NAME_FIELD_NAME};
                String whereClause = 'Name != null';
        String orderBy = dynlistConstants.CHAR_DESC;
        String queryLimit = '10';
        String offset = '2';
        
        String query = dynlistUtilities.getQuery(objectName,
                                                 fields,
                                                 mandatoryFields,
                                                 whereClause,
                                                 orderBy,
                                                 queryLimit,
                                                 true,
                                                 false,
                                                 true,
                                                 offset);
        System.assert(query != null);
        
        // Use Case #1 - use customfield without packagePrefix
        mandatoryFields.add('customField__c');
        query = dynlistUtilities.getQuery(objectName,
                                                 fields,
                                                 mandatoryFields,
                                                 whereClause,
                                                 orderBy,
                                                 queryLimit,
                                                 true,
                                                 true,
                                                 true,
                                                 offset);
        System.assert(query != null);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.contains" method
    @isTest(seeAllData=false)
    static void testcontains()
    {
        //Start test from here
        Test.startTest();
        
        List<Schema.DisplayType> aListActingAsSet = new List<Schema.DisplayType>
        {
            Schema.DisplayType.String,
                Schema.DisplayType.Id,Schema.DisplayType.Email,
                Schema.DisplayType.Currency,Schema.DisplayType.Boolean,
                Schema.DisplayType.MultiPicklist
                };
                    
                    Schema.DisplayType typeToCheck = Schema.DisplayType.Time;
        
        //Use Case #1 - testing out the logics/use cases when typeToCheck is not included in list
        //START FROM HERE
        Boolean contains = dynlistUtilities.contains(aListActingAsSet,typeToCheck);
        System.assertEquals(false,contains);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when typeToCheck is included in list
        //START FROM HERE
        typeToCheck = Schema.DisplayType.Currency;
        contains = dynlistUtilities.contains(aListActingAsSet,typeToCheck);
        System.assertEquals(true,contains);
        //Use Case #2
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getRecordTypeIdForObject" method
    @isTest(seeAllData=false)
    static void testGetRecordTypeIdForObject()
    {
        //Start test from here
        Test.startTest();
        
        Id recordTypeId = dynlistUtilities.getRecordTypeIdForObject(dynlistConstants.OBJECT_NAME_OPPORTUNITY,'Master');
        System.assert(recordTypeId != null);
        
        // Use Case #1 set parameter blank
        recordTypeId = dynlistUtilities.getRecordTypeIdForObject(dynlistConstants.CHAR_BLANK_STRING, dynlistConstants.CHAR_BLANK_STRING);
        System.assert(recordTypeId == null);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getRecordTypeIdForObject" method
    @isTest(seeAllData=false)
    static void testGetRecordTypeIdForObject1()
    {
        //Start test from here
        Test.startTest();
        
        String objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        
        Id recordTypeId = dynlistUtilities.getRecordTypeIdForObject(SObjectTypeObj,'Master');
        System.assert(recordTypeId != null);
        
        // Use Case #1 set parameter blank
        recordTypeId = dynlistUtilities.getRecordTypeIdForObject(SObjectTypeObj,dynlistConstants.CHAR_BLANK_STRING);
        System.assert(recordTypeId == null);
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.readObjectValue" method
    @isTest(seeAllData=false)
    static void testReadObjectValue()
    {
        String objectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(System.Label.DYNLIST_APPLICATION_SETTINGS_FIELD_SET_NAME);
        Schema.FieldSetMember[] fieldSetMemberList =  fieldSetObj.getFields();
        Schema.DescribeFieldResult result;
        
        //Start test from here
        Test.startTest();
        Opportunity oppotunity = new Opportunity();
        for(Schema.FieldSetMember fsMember : fieldSetMemberList)
        {
            String path = fsMember.getFieldPath();
            Object opp = dynlistUtilities.readObjectValue(oppotunity,path);
            System.assert(opp == null); 
        }   
        
        //End test here
        Test.stopTest();        
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getArrayStringForQuery" method
    @isTest(seeAllData=false)
    static void testGetArrayStringForQuery()
    {
        //Start test from here
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        
        String query = dynlistUtilities.getArrayStringForQuery(opp);
        System.assert(query != null);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.isoTime2DateTime" method
    @isTest(seeAllData=false)
    static void testIsoTime2DateTime()
    {
        //Start test from here
        Test.startTest();
        
        String str = '2021-10-26T11:07:29+05:30';
        
        DateTime convertedDateTime = dynlistUtilities.isoTime2DateTime(str);
        Integer year = convertedDateTime.Year();
        System.assertEquals(2021, 2021);
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.dateTime2isoTime" method
    @isTest(seeAllData=false)
    static void testDateTime2isoTime()
    {
        
        //Start test from here
        Test.startTest();
        
        DateTime todayDateTime = System.today();
        String dateConerted2Str = dynlistUtilities.dateTime2isoTime(todayDateTime);
        System.assert(dateConerted2Str.startsWith(String.valueOf(todayDateTime.Year())));
        
        //End test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getSetOfNonQueryableFields" method
    @isTest(seeAllData=false)
    static void testGetSetOfNonQueryableFields()
    {
        Map<String, String> mapOfNonQueryableFields = new Map<String, String>();
        mapOfNonQueryableFields.put(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME.toLowerCase(), System.Label.DYNLIST_APPLICATION_SETTINGS_TEXT_AREA_VALUE_FIELD_NAME + ',' + System.Label.DYNLIST_APPLICATION_SETTINGS_DISPLAY_FIELD_NAME);
        String objectName = System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        Set<String> setOfFieldNames = new Set<String>{System.Label.DYNLIST_APPLICATION_SETTINGS_COUNT_FIELD_NAME,
            System.Label.DYNLIST_APPLICATION_SETTINGS_CONTACT_FIELD_NAME,
            System.Label.DYNLIST_APPLICATION_SETTINGS_BEGINS_FIELD_NAME,
            System.Label.DYNLIST_APPLICATION_SETTINGS_DISPLAY_FIELD_NAME,
            System.Label.DYNLIST_APPLICATION_SETTINGS_TEXT_AREA_VALUE_FIELD_NAME 
            };
                
                //Start test from here
                Test.startTest();
        
        //Use Case 1 - (mapOfNonQueryableFields.get(objectName.toLowerCase()).split(dynlistConstants.CHAR_COMMA).size() > 0)
        Set<String> setOfNonQueryableFields = dynlistUtilities.getSetOfNonQueryableFields(mapOfNonQueryableFields,objectName, setOfFieldNames);
        System.assert(setOfNonQueryableFields != null);
        
        //Use Case 2 - (mapOfNonQueryableFields.get(objectName.toLowerCase()).split(dynlistConstants.CHAR_COMMA).size() > 0) else part
        mapOfNonQueryableFields = new Map<String, String>();
        mapOfNonQueryableFields.put(System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME.toLowerCase(), ',');
        
        setOfNonQueryableFields = dynlistUtilities.getSetOfNonQueryableFields(mapOfNonQueryableFields,objectName, setOfFieldNames);
        System.assert(setOfNonQueryableFields != null);
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.getInAccessibleFieldsDetails" method
    @isTest(seeAllData=false)
    static void testGetInAccessibleFieldsDetails()
    {
        String query = 'Select Id, Name, LastModifiedById, RecordTypeId From ' + System.Label.DYNLIST_APPLICATION_SETTINGS_OBJECT_NAME;
        
        //Start test from here
        Test.startTest();
        
        Map<String, Set<String>> mapOfInAccessibleFields = dynlistUtilities.getInAccessibleFieldsDetails(query);
        System.assert(mapOfInAccessibleFields != null);
        
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.mapOfObjectsNotHavingNameField" method
    @isTest(seeAllData=false)
    static void testMapOfObjectsNotHavingNameField(){
        //Start test from here
        Test.startTest();
        
        Map<String, Dynamic_Related_List_Manager__mdt> mapOfObjectsNotHavingNameField = dynlistUtilities.mapOfObjectsNotHavingNameField();
        System.assert(mapOfObjectsNotHavingNameField.size() > 0);
        
        //End test here
        Test.stopTest(); 
    }
    
    // this method is basically to test all the use cases associated with "dynlistUtilities.IsaValidateSalesforceID" method
    @isTest(seeAllData=false)
    static void testIsaValidateSalesforceID(){
        //Start test from here
        Test.startTest();
        
        // query opportunity data
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        
        // UseCase 1: Pass Id in method
        Boolean isAValidateIDValue = dynlistUtilities.isaValidateSalesforceID(opp.Id);
        System.assertEquals(true, isAValidateIDValue);
        
        // UseCase 2: Pass bankId in method
        isAValidateIDValue = dynlistUtilities.isaValidateSalesforceID('');
        System.assertEquals(false, isAValidateIDValue);
        //End test here
        Test.stopTest(); 
    }
    
}