/*
    Purpose         :   Test class for FieldSetHelper
    Created By      :   Abhinav Sharma
    Created Date    :   09/28/2020
    Current Version :   V_1.0
    Revision Log    :   V_1.0 Created - CR-20210924-15459
	Code Coverage   :    
*/
@IsTest
public class Test_FieldSetHelper 
{
    @testSetup static void testSetupData(){}
    
    @IsTest static void test_getFieldsFromFieldSet()
    {
        String fields = FieldSetHelper.getFieldsFromFieldSet('Inventory_Transaction__c','Add_Inventory_Print_Request_Field_Set');
        System.assert(fields != null);
        
        String getfields = FieldSetHelper.getFieldsFromFieldSet('','');
        System.assert(getfields == null);
    }
}