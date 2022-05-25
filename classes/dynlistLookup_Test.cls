/*
Purpose         :   Test Class for "dynlistLookup" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistLookup_Test 
{
    // this method is basically to test all the use cases associated with "dynlistLookup.dynlistLookup" constructor without any argument
    @isTest(seeAllData=false)
    static void testDynlistLookupWithoutArgument()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the use case whene there is no condition
        //START FROM HERE
        dynlistLookup dynlistLookupWithOutArgument = new dynlistLookup();
        
        //Asserts
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistLookupWithOutArgument.selectedRecordName);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistLookupWithOutArgument.selectedRecordId);
        
        //Use Case #1
        //ENDS HERE
        
        //Start test from here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistLookup.dynlistLookup" constructor with two arguments - selectedRecordId,selectedRecordName
    @isTest(seeAllData=false)
    static void testDynlistLookupWithTwoArguments()
    {
        //Variable initialization
        String selectedRecordName = 'test';
        String selectedRecordId = '001';
        
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when ((selectedRecordId != null)) condition satisfy
        //START FROM HERE
        dynlistLookup dynlistLookupWithOutArgument = new dynlistLookup(selectedRecordId,selectedRecordName);
        
        //Asserts
        System.assertEquals(dynlistUtilities.DYNLIST_ORG_HOST_URL + selectedRecordId, dynlistLookupWithOutArgument.selectRecordURL);        
        System.assertEquals(selectedRecordName, dynlistLookupWithOutArgument.selectedRecordName);
        System.assertEquals(selectedRecordId, dynlistLookupWithOutArgument.selectedRecordId);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when ((selectedRecordId == null)) condition satisfy
        //START FROM HERE
        selectedRecordId = null;
        dynlistLookup dynlistLookupWithOutArgument1 = new dynlistLookup(selectedRecordId,selectedRecordName);
        
        //Asserts
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistLookupWithOutArgument1.selectRecordURL);
        System.assertEquals(selectedRecordName, dynlistLookupWithOutArgument1.selectedRecordName);
        System.assertEquals(selectedRecordId, dynlistLookupWithOutArgument1.selectedRecordId);
        //Use Case #2
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistLookup.dynlistLookup" constructor with four arguments - fieldName, objectName, selectedRecordId,selectedRecordName
    @isTest(seeAllData=false)
    static void testDynlistLookupWithFourArguments()
    {
        //Variable initialization
        String selectedRecordName = 'test';
        String selectedRecordId = '001';
        String objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        String fieldName = dynlistConstants.RECORD_TYPE_ID_FIELD_NAME;
        
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when ((selectedRecordId != null) then (String.isNotBlank(fieldName) && fieldName == dynlistConstants.RECORD_TYPE_ID_FIELD_NAME)) condition satisfy
        //START FROM HERE
        dynlistLookup dynlistLookupWithOutArgument = new dynlistLookup(selectedRecordId,selectedRecordName,fieldName,objectName);
        
        String recordUrl = dynlistUtilities.DYNLIST_RECORD_TYPE_HOST_URL + dynlistConstants.CHAR_BACK_SLASH + objectName +
            dynlistConstants.TEXT_RECORD_TYPES_WITH_BACK_SLASHES + selectedRecordId + dynlistConstants.TEXT_VIEW_WITH_BACK_SLASH;
        //Asserts
        System.assertEquals(recordUrl, dynlistLookupWithOutArgument.selectRecordURL);
        System.assertEquals(selectedRecordName, dynlistLookupWithOutArgument.selectedRecordName);
        System.assertEquals(selectedRecordId, dynlistLookupWithOutArgument.selectedRecordId);
        System.assertEquals(objectName, dynlistLookupWithOutArgument.objectName);
        System.assertEquals(fieldName, dynlistLookupWithOutArgument.fieldName);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when ((selectedRecordId != null) then (String.isNotBlank(fieldName) && fieldName != dynlistConstants.RECORD_TYPE_ID_FIELD_NAME)) condition satisfy
        //START FROM HERE
        fieldName = '';
        dynlistLookup dynlistLookupWithOutArgument1 = new dynlistLookup(selectedRecordId,selectedRecordName,fieldName,objectName);
        
        recordUrl = dynlistUtilities.DYNLIST_ORG_HOST_URL + selectedRecordId;
        
        //Asserts
        System.assertEquals(recordUrl, dynlistLookupWithOutArgument1.selectRecordURL);
        System.assertEquals(selectedRecordName, dynlistLookupWithOutArgument1.selectedRecordName);
        System.assertEquals(selectedRecordId, dynlistLookupWithOutArgument1.selectedRecordId);
        System.assertEquals(objectName, dynlistLookupWithOutArgument.objectName);
        System.assertEquals(dynlistConstants.RECORD_TYPE_ID_FIELD_NAME, dynlistLookupWithOutArgument.fieldName);
        //Use Case #1
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when ((selectedRecordId == null)) condition satisfy
        //START FROM HERE
        selectedRecordId = null;
        dynlistLookup dynlistLookupWithOutArgument2 = new dynlistLookup(selectedRecordId,selectedRecordName,fieldName,objectName);
        
        recordUrl = dynlistConstants.CHAR_BLANK_STRING;
        //Asserts
        System.assertEquals(recordUrl, dynlistLookupWithOutArgument2.selectRecordURL);
        System.assertEquals(selectedRecordName, dynlistLookupWithOutArgument2.selectedRecordName);
        System.assertEquals(selectedRecordId, dynlistLookupWithOutArgument2.selectedRecordId);
        System.assertEquals(objectName, dynlistLookupWithOutArgument2.objectName);
        System.assertEquals(fieldName, dynlistLookupWithOutArgument2.fieldName);
        
        //Use Case #3
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
}