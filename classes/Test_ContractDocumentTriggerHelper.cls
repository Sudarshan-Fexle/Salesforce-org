/**
*   Purpose         :   Test class for ContractDocumentTriggerHelper
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   06/04/2020
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0
*
**/
@isTest(seeAllData = false)
private class Test_ContractDocumentTriggerHelper 
{
    static testMethod void test_populateUserOfLatestContractDocument()
    {
        Account acct = TestUtilities.CreateNewAccount(true);
        
        List<Program_Package__c> listOfProgramPackage = new List<Program_Package__c>();
        listOfProgramPackage.add(new Program_Package__c(Name = 'TestProgramPackage', Account__c = acct.Id, Fiscal_Year__c = '2020'));
        insert listOfProgramPackage;
        
        List<Contract_Document__c> listOfContDoc = new List<Contract_Document__c>();
        listOfContDoc.add(new Contract_Document__c(Name = 'Test Contract', Name__c ='Test Contract', Program_Package_Royall__c = listOfProgramPackage[0].Id));
        insert listOfContDoc;
    }
    
}