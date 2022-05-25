/*
Purpose         :   Test Class for "dynlistDataGridUtilities" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/12/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/12/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistDataGridUtilities_Test
{    
    //this method is to test all the use cases associated with "doPrimaryValidations" Method
    @isTest(seeAllData=false)
    static void testDoPrimaryValidations() 
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when (String.isBlank(DynlistDataGridRequest.View)) condition satisfy
        //START FROM HERE
        dynlistDataGridRequestWrapper DynlistDataGridRequest = new dynlistDataGridRequestWrapper();
        
        DynlistDataGridRequest.view = dynlistConstants.CHAR_BLANK_STRING;
        String DYNLIST = dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest);
        System.assertEquals(System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_DEFAULT_VIEW, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 - testing out the logics/use cases when ( DynlistDataGridRequest.pageSize == null ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.view = dynlistConstants.VIEW_TYPE_TABLE;
        DynlistDataGridRequest.pageSize = null ;
        System.assertEquals(System.Label.DYNLIST_PLEASE_SPECIFY_PAGE_SIZE, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when ( DynlistDataGridRequest.pageSize <= 0 ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.pageSize = -2 ;
        System.assertEquals(System.Label.DYNLIST_PLEASE_SPECIFY_VALID_PAGE_SIZE, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #3
        //ENDS HERE
        
        //Use Case #4 - testing out the logics/use cases when ( String.isBlank(DynlistDataGridRequest.objectName) ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.pageSize = 2 ;
        DynlistDataGridRequest.objectName = dynlistConstants.CHAR_BLANK_STRING;
        System.assertEquals(System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_OBJECT_NAME, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #4
        //ENDS HERE
        
        //Use Case #5 - testing out the logics/use cases when ( String.isBlank(DynlistDataGridRequest.defaultSortFieldName) ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.objectName = dynlistConstants.OBJECT_NAME_ACCOUNT;
        DynlistDataGridRequest.defaultSortFieldName = dynlistConstants.CHAR_BLANK_STRING;
        System.assertEquals(System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_SORT_BY_FIELD_NAME, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #5
        //ENDS HERE
        
        //Use Case #6 - testing out the logics/use cases when ( String.isBlank(DynlistDataGridRequest.defaultSortDirection) ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.defaultSortFieldName = dynlistConstants.NAME_FIELD_NAME;
        DynlistDataGridRequest.defaultSortDirection = dynlistConstants.CHAR_BLANK_STRING;
        System.assertEquals(System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_DEFAULT_SORT_DIRECTION, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #6
        //ENDS HERE
        
        //Use Case #7 - testing out the logics/use cases when ( String.isBlank(DynlistDataGridRequest.fieldSetName) && String.isBlank(DynlistDataGridRequest.sOQLSelectFieldsString) ) condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.defaultSortDirection = dynlistConstants.CHAR_ASC;
        DynlistDataGridRequest.fieldSetName = dynlistConstants.CHAR_BLANK_STRING;
        DynlistDataGridRequest.sOQLSelectFieldsString = dynlistConstants.CHAR_BLANK_STRING;
        System.assertEquals(System.Label.DYNLIST_ERROR_PLEASE_SPECIFY_EITHER_FIELD_SET_NAME_OR_SELECT_FIELDS, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #7
        //ENDS HERE
        
        //Use Case #8 - testing out the logics/use cases when there is no null values condition satisfy
        //START FROM HERE
        DynlistDataGridRequest.defaultSortFieldName = dynlistConstants.NAME_FIELD_NAME;
        DynlistDataGridRequest.defaultSortDirection = dynlistConstants.CHAR_ASC;
        DynlistDataGridRequest.fieldSetName = 'Dynamic_Related_List';
        DynlistDataGridRequest.sOQLSelectFieldsString = 'Name,Stagename';
        System.assertEquals(null, dynlistDataGridUtilities.doPrimaryValidations(DynlistDataGridRequest));
        //Use Case #8
        //ENDS HERE
        
        //End test here
        Test.stopTest();
    }
}