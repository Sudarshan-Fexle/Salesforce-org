/*
Purpose         :   Test Class for "dynlistConstants" apex class
Created By      :   Abhinav Sharma
Created Date    :   09/09/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 09/09/2021
*/
@isTest(seeAllData=false)
private without sharing class dynlistConstants_Test 
{
    @isTest(seeAllData=false)
    static void testConstants()
    {    
        //Start test from here
        Test.startTest();
        
        Map<String, String> mapOperatorTemplates = dynlistConstants.operatorTemplates;
        System.assert(dynlistConstants.operatorTemplates != null);
        
        List<Schema.DisplayType> quoteType = dynlistConstants.QUOTE_TYPES;
        System.assert(quoteType.size()>0);
        
        List<Schema.DisplayType> numberTypes = dynlistConstants.NUMBER_TYPES;
        System.assert(numberTypes.size()>0);
        
        List<Schema.DisplayType> nonStringTypes = dynlistConstants.NON_STRING_TYPES;
        System.assert(nonStringTypes.size()>0);
        
        List<Schema.DisplayType> stringTypes = dynlistConstants.STRING_TYPES;
        System.assert(stringTypes.size()>0);
        
        Set<String> setOfDecimalTypes = dynlistConstants.SET_OF_DECIMAL_TYPES;
        System.assert(setOfDecimalTypes.size()>0);
        
        Set<String> setOfSpecialReferenceFields = dynlistConstants.SET_OF_SPECIAL_REFERENCE_FIELDS;
        System.assert(setOfSpecialReferenceFields.size()>0);
        
        //End test here
        Test.stopTest();
    }
}