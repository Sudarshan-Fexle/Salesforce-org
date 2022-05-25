/*
Purpose         :   Test Class for "dynlistPageSizeOptionsPicklist" apex class
Created By      :   Abhinav Sharma
Created Date    :   09/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 09/09/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistPageSizeOptionsPicklist_Test 
{
    // this method is basically to test all the use cases associated with "dynlistPageSizeOptionsPicklist.getDefaultValue" Method 
    @isTest(seeAllData=false)
    static void testGetDefaultValue()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the getDefaultValue
        //START FROM HERE
        dynlistPageSizeOptionsPicklist pageSizepicklist = new dynlistPageSizeOptionsPicklist();
        VisualEditor.DataRow rows = pageSizepicklist.getDefaultValue();
        
        //Asserts
        System.assert(rows != null);
        
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
    
    // this method is basically to test all the use cases associated with "dynlistPageSizeOptionsPicklist.getValues" Method 
    @isTest(seeAllData=false)
    static void testGetValues()
    {
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the getValues
        //START FROM HERE
        dynlistPageSizeOptionsPicklist pageSizepicklist = new dynlistPageSizeOptionsPicklist();
        VisualEditor.DynamicPickListRows rows = pageSizepicklist.getValues();
        
        //Asserts
        System.assert(rows != null);
        
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
}