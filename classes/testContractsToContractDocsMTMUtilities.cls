/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class testContractsToContractDocsMTMUtilities {

    static testmethod void testCreateNewDoc() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        // Create a new contract_ABC record
        Contract__c contract = TestUtilities.CreateNewContract(true);
        
        /** start test **/
        test.startTest();
        
        // Create a new opportunity (this opportunity is 'booked' from the contract)
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Signed_Opportunity_Contract__c = contract.Id;
        insert opp;
        
        Contract_Document__c conDoc = new Contract_Document__c(Account__c = opp.AccountId, Name__c='testdoc1');
        insert conDoc;
        
        // create a contract to document mtm record
        Contract_Docs_to_Opps_MtM__c docMTM = new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opp.Id, Contract_Documents__c = conDoc.Id);
        insert docMTM;
        // now that the record is inserted, the opportunity related to this contract
        // should have this new Contract doc MTM record associated with it
        test.stopTest();
        /** stop test **/
        
        List<Contract_Docs_to_Opps_MtM__c> contractToOppsMTM = [SELECT Id FROM Contract_Docs_to_Opps_MtM__c WHERE Opportunity__c = :opp.Id];
        system.assertEquals(1, contractToOppsMTM.size());
    }
    
    static testmethod void testAddDocsToContract() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        // Create a new contract_ABC record
        Contract__c contract = TestUtilities.CreateNewContract(true);
        
        /** start test **/
        test.startTest();
        
        // Create a new opportunity (this opportunity is 'booked' from the contract)
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Signed_Opportunity_Contract__c = contract.Id;
        insert opp;
        
        Contract_Document__c conDoc = new Contract_Document__c(Account__c = opp.AccountId, Name__c='testdoc1');
        insert conDoc;
        
        // create a contract doc to Opp mtm record
        Contract_Docs_to_Opps_MtM__c docMTM = new Contract_Docs_to_Opps_MtM__c(Opportunity__c = opp.Id, Contract_Documents__c = conDoc.Id);
        insert docMTM;
        // now that the record is inserted, the opportunity related to this contract
        // should have this new Contract doc MTM record associated with it
        test.stopTest();
        /** stop test **/
        
        List<Contracts_to_Contract_Docs_MtM__c> conToConDocs = [SELECT Id FROM Contracts_to_Contract_Docs_MtM__c WHERE Contracts_ABC__c = :contract.Id];
        system.assertEquals(1, conToConDocs.size());
    }
}