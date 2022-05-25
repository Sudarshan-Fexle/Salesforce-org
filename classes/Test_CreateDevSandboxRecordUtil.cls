/**
*   Purpose         :   Test class for CreateDevSandboxRecordUtil
*            
*   Create By       :   Mahendar Swarnkar
* 
*   Created Date    :   09/10/2021
*
*   Revision Log    :   V_1.0 - Created - CR-20210901-15400
*   
*   Coverage        :   100%
*
**/
@isTest(seeAllData = false)
public class Test_CreateDevSandboxRecordUtil 
{
    @testSetup static void dataSetup() {}
    
    @isTest static void test_parseJSONstring()
    {
        Test.startTest();
        List<Create_Dev_Sandbox_Record__mdt> metadataRecord = [SELECT ID, Object_API_Name__c, Records__c
                                                               FROM Create_Dev_Sandbox_Record__mdt
                                                               WHERE Active__c =: true 
                                                               AND Process_Belongs_To__c =: Constants.PRINT_PROCESS_OE_BRE
                                                               AND Object_API_Name__c = 'Account'];
        Map<String, Sobject> result = CreateDevSandboxRecordUtil.parseJSONstring(metadataRecord[0].Records__c,metadataRecord[0].Object_API_Name__c);
        System.assert(result != null);
        Test.stopTest();
    }
}