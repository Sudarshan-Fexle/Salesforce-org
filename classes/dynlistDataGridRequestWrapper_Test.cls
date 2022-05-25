/*
Purpose         :   Test Class for "dynlistDataGridRequestWrapper" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/12/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/12/2021
*/
@isTest(seeAllData=false)
public without sharing class dynlistDataGridRequestWrapper_Test 
{
    // this method is to test all the use cases associated with "dynlistDataGridRequestWrapper" wrapper class
    @isTest(seeAllData=false)
    static void testDynlistDataGridRequestWrapper() 
    {
        //Start test from here
        Test.startTest();
        
        //Use Case Testing wrapper variables
        //START FROM HERE
        dynlistDataGridRequestWrapper dynlistDataGridRequest = new dynlistDataGridRequestWrapper();
        
        dynlistDataGridRequest.view = dynlistConstants.VIEW_TYPE_TABLE;
        dynlistDataGridRequest.pageSize = 5 ;
        dynlistDataGridRequest.objectName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        dynlistDataGridRequest.fieldSetName = 'Dynamic_Related_List';
        dynlistDataGridRequest.sOQLSelectFieldsString = 'Name,Stagename,Amount';
        dynlistDataGridRequest.whereClauseString = 'Name != null';
        dynlistDataGridRequest.groupByFieldName = 'Stagename';
        dynlistDataGridRequest.summarizeByFieldName = 'Amount';
        dynlistDataGridRequest.defaultSortFieldName = dynlistConstants.NAME_FIELD_NAME;
        dynlistDataGridRequest.defaultSortDirection = dynlistConstants.CHAR_ASC;
        dynlistDataGridRequest.nullFirstOrLastString = dynlistConstants.CHAR_NULLS_LAST;
        dynlistDataGridRequest.limitValue = 50;
        dynlistDataGridRequest.offSetValue = 2;
        dynlistDataGridRequest.correctContextRecordId = '0015g00000MuQbXAAV';
        dynlistDataGridRequest.searchByString = 'Test';
        dynlistDataGridRequest.recordPageParentFieldAPIName = 'AccountId';
        dynlistDataGridRequest.enforceWithSecurityMode = true;
        dynlistDataGridRequest.isColumnsAndFiltersSectionNeeded = true;
        dynlistDataGridRequest.isSystemMode = false;
        //ENDS HERE
        
        system.assert(dynlistDataGridRequest != null);
        
        //End test here
        Test.stopTest();
    }
}