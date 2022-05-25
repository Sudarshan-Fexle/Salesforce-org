/*
Purpose         :   Test class for Batch_MembershipPayerStatusDataUpdate

Create By       :   Mahendra Swarnakar

Created Date    :   08/19/2020

Current Version :   V1.0

Revision Log    :   V1.0 - Created - 08/19/2020 - CR-20200427-13986

Coverage        :   
*/
@isTest(seeAllData=false)
public class TestBatch_MemPayerStatusDataUpdate {
    
    @testSetup static void testSetupData()
    {
        util.bypassAllTriggers = true;  
        
        //Create test data
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acc.Id, true);
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acc.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Query on Subscription Record Types  
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName = 'Program' AND IsActive = true];
        
        //Membership
        Membership__c membership = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id);
        insert membership;
        
        //Subscription
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        programSubscription.Negotiated_Amount_Subscription__c = 400;
        programSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        
        insert programSubscription;
        
        Membership__c membership1 = new Membership__c(Name = 'Test Membership', Account_Name__c = acc.Id, Program__c = program.Id, Active_Contract_Idenfied__c = contract.Id,
                                                      Active_Subscription__c = programSubscription.Id);
        insert membership1;
        
        Util.byPassAllTriggers = false;
    }
    
    static testmethod void test_MembershipPayerStatusDataUpdate() 
    {
        Test.startTest();
        Database.executeBatch(new Batch_MembershipPayerStatusDataUpdate());
        Test.stopTest();
    }
    
}