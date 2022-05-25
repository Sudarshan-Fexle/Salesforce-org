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
private class TestCreateContractDocument {
    private static Blob body = Blob.valueOf('test');

    //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    static testMethod void testSign() {
        Util.BypassAllTriggers = true;
        test.startTest();
        Account account = new Account(Name='test');
        insert account;
        
         // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        // Test Class Fix Start Here 07/19/20 By: Mahendra Swarnakar - CR-20200218-13783
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(false);
        cont.AccountId = account.Id;
        insert cont;
        // Test Class Fix end Here 07/19/20 By: Mahendra Swarnakar
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        System.assertNotEquals(null, account);
		string recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Royall').getRecordTypeId();
		
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Opportunity opp = new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = account.Id, Main_Contact__c = cont.Id, Name = 'test', CloseDate = Date.today(), StageName = 'test', RecordTypeId = recordTypeId);
        insert opp;
        
        Util.BypassAllTriggers = false;
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c(Name='test', echosign_dev1__Account__c=account.Id, echosign_dev1__Status__c = 'Signed', echosign_dev1__Opportunity__c=opp.Id, Contract_Document_Type__c='Terms of Agreement');
        insert agreement;
         
        Attachment attachment = new Attachment(Name='Agreement - signed.pdf',Description='Test description',ParentId=agreement.Id,Body=body);
        insert attachment;
        
        //List<Contract_Document__c> contractDocument = [SELECT Id from Contract_Document__c where Account__c = :agreement.echosign_dev1__Account__c];
        
        //System.assertNotEquals(null, contractDocument[0]);
        
        //Contract_Docs_to_Opps_MtM__c docToOpp = [SELECT Id from Contract_Docs_to_Opps_MtM__c where Contract_Documents__c = :contractDocument[0].Id];
        
        //System.assertNotEquals(null, contractDocument[0]); 
        Test.stopTest();
    }
}