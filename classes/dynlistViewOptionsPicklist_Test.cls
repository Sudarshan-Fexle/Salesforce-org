/*
Purpose         :   Test Class for "dynlistViewOptionsPicklist" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
Dev Comment 	:   
*/
@isTest(seeAllData=false)
private without sharing class dynlistViewOptionsPicklist_Test 
{
    // this method is basically to test all the use cases associated with "dynlistViewOptionsPicklist.getDefaultValue" Method 
    @isTest(seeAllData=false)
    static void testGetDefaultValue()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistViewOptionsPicklist picklist = new dynlistViewOptionsPicklist();
        VisualEditor.DataRow rows = picklist.getDefaultValue();
        
        //Asserts
        System.assert(rows != null);
        System.assertEquals(dynlistConstants.VIEW_TYPE_TABLE_LABEL, rows.getLabel());
        System.assertEquals(dynlistConstants.VIEW_TYPE_TABLE, rows.getValue());
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistViewOptionsPicklist.getValues" Method 
    @isTest(seeAllData=false)
    static void testGetValues()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistViewOptionsPicklist picklist = new dynlistViewOptionsPicklist();
        VisualEditor.DynamicPickListRows rows = picklist.getValues();
        
        //Asserts
        System.assert(rows != null);
        System.assertEquals(dynlistConstants.VIEW_TYPE_TABLE_LABEL, rows.get(0).getLabel());
        System.assertEquals(dynlistConstants.VIEW_TYPE_TABLE, rows.get(0).getValue());
        System.assertEquals(dynlistConstants.VIEW_TYPE_TILE_LABEL, rows.get(1).getLabel());
        System.assertEquals(dynlistConstants.VIEW_TYPE_TILES, rows.get(1).getValue());
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
}