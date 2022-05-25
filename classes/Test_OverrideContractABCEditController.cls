/**
*	Purpose            :    Test class for OverrideContractABCEditController 
*
*	Created By         :    Chirag Soni
*
*	Current Version    :    V1.0
*
*	Created Date       :    10/13/2021
*
*	Revision Log       :    V1.0 - Created - Chirag Soni - CR-20211012-15511 - 10/13/2021 - increase code coverage
*
**/
@isTest(seeAllData = false)
private class  Test_OverrideContractABCEditController
{
    @testSetup 
    static void dataSetup()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsBatch = true;
        Util.byPassAllTriggers = true;
        
        //insert account
        Account account = testUtilities.CreateNewAccount(true);
        
        //insert contact
        Contact contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        //insert
        insert contact;
        //insert Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        list<Contract__c> contracts = new list<Contract__c>();
        //create contract  
        contracts.add(new Contract__c(
            Payer_Account__c = account.id,
            Program__c = prog.id,
            Start__c = system.today().addDays(-100),
            End__c = system.today().addDays(265),
            Year__c = '2011',
            Record_Source__c = 'Shadow',
            Main_Contact__c = contact.id,
            Invoice_Contact__c = contact.id,
            Join_Date__c = system.today().addYears(-5),
            Type__c = 'NBB',
            Negotiated_Amount__c = 100,
            Active__c = False
        ));
        insert contracts;
    } 
    
    //Create By -  Chirag Soni - CR-20211012-15511 - 10/13/2021 - test method to OverrideContractABCEditController constructor
    static testMethod void testOverrideContractABCEditController()
    {
        Contract__c contract = [select Id,Name from Contract__c Limit 1];
        
        Test.startTest();
        
        //Use Case 1 -  setting standard controller
        ApexPages.StandardController controller = new ApexPages.StandardController(contract);

        //asserts
        System.assert(controller!=null);
    	
        //Use Case 2  -  fetch contract from controller
        OverrideContractABCEditController aBCEditController = new OverrideContractABCEditController(controller);
        //assert 
        System.assertEquals(contract.Id, aBCEditController.contract.Id);
        
        //Use case 3  - check for shadow record
        System.assertEquals(true, aBCEditController.isShadowRecord);
        
        //Use case 4  -  checkRecordSource 
        Pagereference page = aBCEditController.checkRecordSource();
        
        //Use case 5
        aBCEditController.isShadowRecord = false;
        page = aBCEditController.checkRecordSource();
        
        PageReference expectedPage  = new PageReference('/' + contract.Id +'/e?retURL=/'+contract.Id +'&nooverride=1');
        
        System.assert(page!=null);
        
        Test.stopTest();
    }   
}