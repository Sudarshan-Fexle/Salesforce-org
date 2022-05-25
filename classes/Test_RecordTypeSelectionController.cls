/**
*	Purpose            :    Test class for RecordTypeSelectionController 
*
*	Created By         :    Chirag Soni
*
*	Current Version    :    V1.0
*
*	Created Date       :    10/13/2021
*
*	Revision Log       :    V1.0 - Created - Chirag Soni - CR-20211012-15511 - 10/13/2021 - code coverage increase
*
**/
@isTest(seeAllData = false)
private class  Test_RecordTypeSelectionController
{
    
    //Create By -  Chirag Soni - CR-20211012-15511 - 10/13/2021 - test method to ObtainAvailableRecordType constructor
    static testMethod void testObtainAvailableRecordType()
    {
        
        Test.startTest();
        //Use Case 1 -  When Check value is true
        List<String> listofAvailableRecordTypes = RecordTypeSelectionController.ObtainAvailableRecordType('Account', true);
        System.assert(listofAvailableRecordTypes.size()>0);
        
        //Use Case 2 -  When Check value is false
        List<String> listofAvailableRecordTypes1 = RecordTypeSelectionController.ObtainAvailableRecordType('Account', false);
        System.assert(listofAvailableRecordTypes1.size()>0);
        
        Test.stopTest();
    }
    
     //Create By -  Chirag Soni - CR-20211012-15511 - 10/13/2021 - test method to getRecordType constructor
    static testMethod void testGetRecordType()
    {
        
        Test.startTest();
        //Use Case 1 -  When Check value is true
        Map<String,String> mapOfRecordTypeNames = RecordTypeSelectionController.getRecordType('Account');
        System.assert(mapOfRecordTypeNames.size()>0);
        
        Test.stopTest();
    }
    
     //Create By -  Chirag Soni - CR-20211012-15511 - 10/13/2021 - test method to getDefaultRecordType constructor
    static testMethod void testGetDefaultRecordType()
    {
        
        Test.startTest();
        //Use Case 1 -  When Check value is true
        Map<String,String> mapOfRecordTypeNames = RecordTypeSelectionController.getDefaultRecordType('Account');
        System.assert(mapOfRecordTypeNames.size()>0);
        
        Test.stopTest();
    }
}