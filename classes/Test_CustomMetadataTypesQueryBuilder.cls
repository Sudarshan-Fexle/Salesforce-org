/**
*   Purpose         :   Test class for CustomMetadataTypesQueryBuilder
*            
*   Create By       :   Abhinav Sharma
* 
*   Created Date    :   02/26/2020
*
*   Revision Log    :   V_1.0 - Created - Abhinav Sharma 
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_CustomMetadataTypesQueryBuilder 
{
    @testSetup static void dataSetup()
    {  
    }
    
    static testMethod void testCustomMetadataTypesQueryBuilderMethod()
    {
        Test.startTest();
        CustomMetadataTypesQueryBuilder.getJTMTypeJobTicketMappings();
        //CustomMetadataTypesQueryBuilder.getAFPMSColorWithHexColorMapping();
        CustomMetadataTypesQueryBuilder.getJTMToAssociatedFeaturesPicklistMapping();
        Test.stopTest();
    }
}