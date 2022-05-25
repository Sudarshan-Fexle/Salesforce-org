/*
Purpose         :   Test Class for "dynlistColumn" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/11/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/11/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistColumn_Test 
{
    // this method is basically to test all the use cases associated with "dynlistColumn.compareTo" method
    @isTest(seeAllData=false)
    static void testDynlistColumn()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when "Both Column have same label" condition satisfy
        //START FROM HERE
        dynlistColumn dynlistColumn1 = new dynlistColumn();
        dynlistColumn1.label = dynlistConstants.NAME_FIELD_NAME;
        dynlistColumn1.name = dynlistConstants.NAME_FIELD_NAME;
        dynlistColumn1.value = 'Test Opportunity';
        dynlistColumn1.isDropEnabled = false;
        dynlistColumn1.summarizedAmount = 10;
        dynlistColumn1.totalRecordsCount = 100;
        dynlistColumn1.isSortable = false;
        dynlistColumn1.displaySortingIcon = false;
        dynlistColumn1.displayArrowUpIcon = false;
        dynlistColumn1.displayArrowDownIcon = false;        
        
        dynlistColumn dynlistColumn2 = new dynlistColumn();
        dynlistColumn2.label = dynlistConstants.NAME_FIELD_NAME;
        System.assertEquals(0, dynlistColumn2.compareTo(dynlistColumn1));
        
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when "Both Column Dont have same value" condition satisfy
        //START FROM HERE
        dynlistColumn dynlistColumn3 = new dynlistColumn();
        dynlistColumn3.label = 'Account Number';
        
        System.assertEquals(1, dynlistColumn2.compareTo(dynlistColumn3));
        //Use Case #2
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
}