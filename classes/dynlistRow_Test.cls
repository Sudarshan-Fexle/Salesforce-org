/*
Purpose         :   Test Class for "dynlistRow" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
Dev Comment 	:   
*/
@isTest(seeAllData=false)
private without sharing class dynlistRow_Test 
{
    // this method is basically to test all the use cases associated with "dynlistRow.dynlistRow" constructor without any argument
    @isTest(seeAllData=false)
    static void testDynlistRowWithoutArguments()
    {
        //Variable initialization
        String groupByFieldValue = 'test';
        String summarizeByFieldValue = 'Summarize test';
        
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistRow dynlistRow = new dynlistRow();
        //Use Case #1
        //ENDS HERE
        
        //Setting the values for summarizeByFieldValue, groupByFieldValue
        //START FROM HERE
        dynlistRow.groupByFieldValue = groupByFieldValue ;
        dynlistRow.summarizeByFieldValue = summarizeByFieldValue;
        
        //Assert 
        System.assert(dynlistRow!=null);
        System.assertEquals(groupByFieldValue, dynlistRow.groupByFieldValue);
        System.assertEquals(summarizeByFieldValue, dynlistRow.summarizeByFieldValue);
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistRow.dynlistRow" constructor with two arguments - rowNo, recId
    @isTest(seeAllData=false)
    static void testDynlistRowWithTwoArguments()
    {
        //Variable initialization
        String recId = '001';
        Integer rowNo = 5;
        
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistRow dynlistRow = new dynlistRow(recId, rowNo);
        
        //Asserts
        //Asserts
        System.assertEquals(recId, dynlistRow.recId);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistRow.title);
        System.assertEquals(false, dynlistRow.selected);
        System.assertEquals(false, dynlistRow.editMode);
        System.assertEquals(0, dynlistRow.fields.size());
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistRow.dynlistRow" constructor with two arguments - rowNo, recId
    @isTest(seeAllData=false)
    static void testDynlistRowWithThreeArguments()
    {
        //Variable initialization
        String recId = '001';
        Integer rowNo = 5;
        String errorMessageForRow = 'error';
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistRow dynlistRow = new dynlistRow(recId, rowNo,errorMessageForRow);
        
        //Asserts
        //Asserts
        System.assertEquals(recId, dynlistRow.recId);
        System.assertEquals(dynlistConstants.CHAR_BLANK_STRING, dynlistRow.title);
        System.assertEquals(false, dynlistRow.selected);
        System.assertEquals(false, dynlistRow.editMode);
        System.assertEquals(0, dynlistRow.fields.size());
        System.assertEquals(errorMessageForRow, dynlistRow.errorMessageForRow);
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
}