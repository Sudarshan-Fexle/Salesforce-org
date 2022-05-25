/*
Purpose         :   Test Class for "dynlistOption" apex class
Created By      :   Abhinav Sharma
Created Date    :   08/13/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 08/13/2021
Dev Comment 	:   
*/
@isTest(seeAllData=false)
private without sharing class dynlistOption_Test 
{
    // this method is basically to test all the use cases associated with "dynlistOption.dynlistOption" constructor with two arguments - value, label
    @isTest(seeAllData=false)
    static void testDynlistOptionWithTwoArguments()
    {
        //Variable initialization
        String label = 'test';
        String value = '5';
        
        //Start test from here
        Test.startTest();
        
        //Use Case #1 - testing out the constructor
        //START FROM HERE
        dynlistOption dynlistOptionWithThreeArguments = new dynlistOption(value,label);
        
        //Asserts
        System.assertEquals(value, dynlistOptionWithThreeArguments.value);
        System.assertEquals(label, dynlistOptionWithThreeArguments.label);
        
        //Use Case #1
        //ENDS HERE
        
        //stop test here
        Test.stopTest();
    }
}