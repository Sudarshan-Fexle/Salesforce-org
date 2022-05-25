/**
Purpose         :   Test Class for "dynlistFieldSetHelper" apex class
Created By      :   Abhinav Sharma
Created Date    :   11/24/2021
Current Version :   v1.0
Revision Log    :   V_1.0 Created - Abhinav Sharma - 11/24/2021
Dev Comment 	:   Field Set Helper - Standard Table Test Class
*/
@isTest(seeAllData=false)
private without sharing class dynlistFieldSetHelper_Test 
{
    //this method is basically to test all the use cases associated with "dynlistFieldSetHelper.getFieldsAndRecords" method
    @isTest(seeAllData=false)
    static void testGetFieldsAndRecords()
    {
        String strObjectApiName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        String strfieldSetName = System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME;
        String criteriaField = dynlistConstants.NAME_FIELD_NAME;
        String criteriaFieldValue = 'Test Opportunity';
        
        //Start test from here
        Test.startTest();
        
        //Use Case 1 - !String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)
        //Calling the Method
        String result = dynlistFieldSetHelper.getFieldsAndRecords(strObjectApiName, strfieldSetName, criteriaField, criteriaFieldValue);
        System.assert(result!=null);
        
        //Use Case 2 - String.isEmpty(strObjectApiName) && String.isEmpty(strfieldSetName)
        strObjectApiName = '';
        strfieldSetName = '';
        
        //Calling the Method
        result = dynlistFieldSetHelper.getFieldsAndRecords(strObjectApiName, strfieldSetName, criteriaField, criteriaFieldValue);
        System.assert(result == null);
        
        // Use Case 3 - When user not have access permission on object
        // i.e sObjType.getDescribe().isAccessible() = false
        strObjectApiName = dynlistConstants.OBJECT_NAME_OPPORTUNITY;
        strfieldSetName = System.Label.DYNLIST_DEFAULT_FIELD_SET_NAME;
        
        // create a user
        User newUser = dynlistTestDataFactory.createUserTestData();
        
        System.runAs(newUser){
            // Calling method.
            result = dynlistFieldSetHelper.getFieldsAndRecords(strObjectApiName, strfieldSetName, criteriaField, criteriaFieldValue);
            System.assert(result == null);
        }
        //stop test here
        Test.stopTest();
    }
}