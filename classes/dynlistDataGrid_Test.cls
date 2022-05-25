/*
Purpose         :   Test Class for "dynlistDataGrid" apex class
Created By      :   Abhinav Sharma
Created Date    :   09/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 09/09/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistDataGrid_Test 
{    
    // this method is basically to test all the use cases associated with "dynlistDataGrid.dynlistDataGrid" method
    @isTest(seeAllData=false)
    static void testdynlistDataGrid()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the logics/use cases when "Default dynlistDataGrid()" condition satisfy
        //START FROM HERE
        
        //creating list of dynlistColumn
        List<dynlistColumn> dynlistColumnList = new List<dynlistColumn>();
        
        //Creating object of dynlistColumn
        dynlistColumn dynlistColumn = new dynlistColumn();
        dynlistColumn.label = dynlistConstants.NAME_FIELD_NAME;
        dynlistColumn.name = dynlistConstants.NAME_FIELD_NAME;
        dynlistColumn.value = 'Test Opportunity';
        dynlistColumn.isDropEnabled = false;
        dynlistColumn.summarizedAmount = 10;
        dynlistColumn.totalRecordsCount = 100;
        dynlistColumn.isSortable = false;
        dynlistColumn.displaySortingIcon = false;
        dynlistColumn.displayArrowUpIcon = false;
        dynlistColumn.displayArrowDownIcon = false; 
        
        //Adding dynlistColumn in list
        dynlistColumnList.add(dynlistColumn);
        
        dynlistDataGrid dataGrid = new dynlistDataGrid();
        dataGrid.view = dynlistConstants.VIEW_TYPE_TABLE;
        dataGrid.pageSize = 5;
        dataGrid.columns = dynlistColumnList;
        dataGrid.allColumns = dynlistColumnList;
        dataGrid.body = 'Body';
        dataGrid.viewable = true;
        dataGrid.isObjAccessible = true;
        dataGrid.isObjUpdatable = true;
        dataGrid.isObjDeletable = true;
        dataGrid.isObjCreatable = true;
        dataGrid.isUndeletable = true;
        dataGrid.isCustom = true;
        dataGrid.nameSynonymFieldName = 'Name';
        
        System.assertEquals(true, dataGrid.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid.isSuccess);
        
        //Use Case #1
        //ENDS HERE
        
        //Use Case #2 -- testing out the logics/use cases when "dynlistDataGrid(List<String> errorMessages)" condition satisfy
        //START FROM HERE
        List<String> errorMessages = new List<String>();
        String error = 'Error Message';
        errorMessages.add(error);
        
        dynlistDataGrid dataGrid1 = new dynlistDataGrid(errorMessages);
        System.assertEquals(false, dataGrid1.isAllFieldsInAccessible);
        System.assertEquals(null, dataGrid1.isSuccess);
        
        //Use Case #2
        //ENDS HERE
        
        //Use Case #3 - testing out the logics/use cases when "dynlistDataGrid create()" condition satisfy
        //START FROM HERE
        dynlistDataGrid dataGrid2 = dynlistDataGrid.create();
        
        System.assertEquals(true, dataGrid2.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid2.isSuccess);
        //Use Case #3
        //ENDS HERE
        
        //Use Case #4 - testing out the logics/use cases when "dynlistDataGrid create(Object body)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid3 = dynlistDataGrid.create('Body');
        System.assertEquals(true, dataGrid3.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid3.isSuccess);
        
        //Use Case #4
        //ENDS HERE
        
        //Use Case #5 - testing out the logics/use cases when "dynlistDataGrid setSuccess(Boolean isSuccess)" condition satisfy
        //START FROM HERE
        
        dataGrid3.setSuccess(false);
        System.assertEquals(true, dataGrid3.isAllFieldsInAccessible);
        System.assertEquals(false, dataGrid3.isSuccess);
        System.assertEquals(dynlistConstants.ERROR,dataGrid3.status);
        
        //Use Case #5
        //ENDS HERE
        
        
        //Use Case #6 - testing out the logics/use cases when "dynlistDataGrid setError(String errorMessage)" condition satisfy
        //START FROM HERE
        dataGrid3.setError(error);
        System.assertEquals(true, dataGrid3.isAllFieldsInAccessible);
        System.assertEquals(false, dataGrid3.isSuccess);
        System.assertEquals(dynlistConstants.ERROR,dataGrid3.status);
        System.assertEquals(errorMessages,dataGrid3.messages);
        
        //Use Case #6
        //ENDS HERE
        
        //Use Case #7 - testing out the logics/use cases when "dynlistDataGrid setWarning(String warningMessage)" condition satisfy
        //START FROM HERE
        dynlistDataGrid dataGrid4 = dynlistDataGrid.create();
        dataGrid4.setWarning(error);
        System.assertEquals(dynlistConstants.WARNING,dataGrid4.status);
        System.assertEquals(errorMessages,dataGrid4.messages);
        
        //Use Case #7
        //ENDS HERE
        
        //Use Case #8 - testing out the logics/use cases when "dynlistDataGrid setMessage(String message)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid11 = dynlistDataGrid.create();
        dataGrid11.setMessage(error);
        System.assertEquals(errorMessages,dataGrid11.messages);
        
        //Use Case #8
        //ENDS HERE
        
        //Use Case #9 - testing out the logics/use cases when "dynlistDataGrid setBody(Object body)" condition satisfy
        //START FROM HERE
        
        dataGrid4.setBody('Test Body');
        System.assertEquals('Test Body',dataGrid4.body);
        
        //Use Case #9
        //ENDS HERE
        
        //Use Case #10 - testing out the logics/use cases when "dynlistDataGrid success(Object body)" condition satisfy
        //START FROM HERE
        
        Object obj = 'Test body';
        
        dynlistDataGrid dataGrid5 = dynlistDataGrid.success(obj);
        System.assertEquals(true, dataGrid5.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid5.isSuccess);
        System.assertEquals(dynlistConstants.SUCCESS,dataGrid5.status);
        System.assertEquals(obj,dataGrid5.body);
        
        //Use Case #10
        //ENDS HERE
        
        //Use Case #11 - testing out the logics/use cases when "dynlistDataGrid success(String successMessage)" condition satisfy
        //START FROM HERE
        
        List<String> successMessages = new List<String>();
        String success = 'Success Message';
        successMessages.add(success);
        
        dynlistDataGrid dataGrid6 = dynlistDataGrid.success(success);
        System.assertEquals(true, dataGrid6.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid6.isSuccess);
        System.assertEquals(dynlistConstants.SUCCESS,dataGrid6.status);
        System.assertEquals(successMessages,dataGrid6.messages);
        
        //Use Case #11
        //ENDS HERE
        
        //Use Case #12 - testing out the logics/use cases when "dynlistDataGrid success(Object body, String successMessage)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid7 = dynlistDataGrid.success(obj, success);
        System.assertEquals(true, dataGrid7.isAllFieldsInAccessible);
        System.assertEquals(true, dataGrid7.isSuccess);
        System.assertEquals(dynlistConstants.SUCCESS,dataGrid7.status);
        System.assertEquals(successMessages,dataGrid7.messages);
        System.assertEquals(obj,dataGrid7.body);
        
        //Use Case #12
        //ENDS HERE
        
        //Use Case #13 - testing out the logics/use cases when "dynlistDataGrid error(Object body)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid8 = dynlistDataGrid.error(obj);
        System.assertEquals(false, dataGrid8.isSuccess);
        System.assertEquals(dynlistConstants.ERROR,dataGrid8.status);
        System.assertEquals(obj,dataGrid8.body);
        
        //Use Case #13
        //ENDS HERE
        
        //Use Case #14 - testing out the logics/use cases when "dynlistDataGrid error(String errorMessage)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid9 = dynlistDataGrid.error(error);
        System.assertEquals(false, dataGrid9.isSuccess);
        System.assertEquals(dynlistConstants.ERROR,dataGrid9.status);
        
        //Use Case #14
        //ENDS HERE
        
        //Use Case #15 - testing out the logics/use cases when "dynlistDataGrid error(Object body, String errorMessage)" condition satisfy
        //START FROM HERE
        
        dynlistDataGrid dataGrid10 = dynlistDataGrid.error(obj,error);
        System.assertEquals(false, dataGrid10.isSuccess);
        System.assertEquals(dynlistConstants.ERROR,dataGrid10.status);
        System.assertEquals(errorMessages,dataGrid10.messages);
        System.assertEquals(obj,dataGrid10.body);
        
        //Use Case #15
        //ENDS HERE    
        
        //stop test here
        Test.stopTest();
    }
}