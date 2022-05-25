/*
 * Description	:	Test classs for the code coverage of importdataTranslationcontroller
 * 
 * Created By 	:	Neha Sharma
 * 
 * Created Date	: 	19/1/2022
 * 
 * RevisionLog	:	V_1.0 - Created - Neha Sharma 
 * 
 * Code Coverage:	100%	 	
 * */

@isTest
private class Test_ImportDataTranslationDetailContr 
{
    @isTest static void testinsertDataTranslationDetailRecords()
    {
        Competitor_and_Tech_System__c comp = new Competitor_and_Tech_System__c();
        comp.name = 'test';
        comp.RecordTypeId = Schema.SObjectType.Competitor_and_Tech_System__c.getRecordTypeInfosByName().get('External System').getRecordTypeId();
        insert comp;
        
        Data_Translation_Set__c dtSet = new Data_Translation_Set__c();
        dtSet.Persistant_Student_ID__c = comp.Id;
        insert dtSet;
        
        List<String> selectedGroupingValues = new List<String>{'FAO__c'};
        List<String> selectedGroupingLabels = new List<String>{'FAO'};
        String recordId = dtSet.Id;
        
        LightningResponseEntity test = ImportDataTranslationDetailController.insertDataTranslationDetailRecords(selectedGroupingValues,selectedGroupingLabels,recordId) ;
     
        ImportDataTranslationDetailController.getselectOptions(recordId);
        
    }
  
}