@isTest(SeeAllData=false)
public class Test_Batch_WebProgAccOnInstitution {
   
    static testmethod void testWebProgAccOnInstitution() {
        
        
        Util.bypassAllTriggers = true;
        
        //create Institute
        Account acct = TestUtilities.CreateNewAccount(true);
        acct.Entity__c= 'EAB';
        update acct;
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Opportunity
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(acct.Id, true);
        
        //Program Susbcription record that is active due to the date range
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        //Insert 
        insert subscription;
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = acct.Id, Program__c = program.Id, Start__c = System.Today().addDays(-10), 
                                               End__c = System.Today().addDays(355), Contract_Renewal_Opportunity__c = opportunity.Id);
        insert contract;
        
        //Create a list of membership record to insert the data in bulk
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Prepare data
        for(Integer i = 0; i < 3; i++) {
            memberships.add(new Membership__c(Name = 'Test Membership', Account_Name__c = acct.Id, Program__c = program.Id, 
                                              Active_Contract_Idenfied__c = contract.Id, 
                                              Active_Subscription__c=subscription.Id));
        }        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        //insert membership record and assert the result
        insert memberships;
        Web_Program_Access__c wpAccess;
        //Start Test from here
        Test.startTest();
        
        //Update contract record so it's in the future
        contract.Start__c = Date.today() + 2;
        contract.End__c = Date.today() + 367;
        contract.Status__c = Constants.STATUS_ATL;
        update contract;
        
        //assert for the results
        memberships = [Select Membership_Status__c from Membership__c where Id IN: memberships];
        
        //Loop through the results
        for(Membership__c membership : memberships) {
            System.assertEquals('Member - Integrated', membership.Membership_Status__c, 'Membership Status should be Member - Payer, because the Active Subscription is active');
        }
        //create Web_Program_Access__c
        Web_Program_Access__c webPrgmAcc = new Web_Program_Access__c();
        webPrgmAcc.Name = 'Test';
        webPrgmAcc.Description__c = 'Testing';
        insert webPrgmAcc;
        
        //create Web_Program_Access_MTM__c
        Web_Program_Access_MTM__c webPrgmAccMTM = new  Web_Program_Access_MTM__c();
        webPrgmAccMTM.Membership_Program__c = program.Id;
        webPrgmAccMTM.Web_Program__c = webPrgmAcc.Id;
        insert webPrgmAccMTM ;
        
        wpAccess = [SELECT Program_Id_Autonumber__c FROM Web_Program_Access__c Where Id =: webPrgmAcc.Id];
        
        Batch_WebProgAccOnInstitution testBatch = new Batch_WebProgAccOnInstitution();
        Database.executeBatch(testBatch);
        Test.stopTest();
        
        //assert for the result
        /*List<Account> accUpdatedList = [SELECT Web_Program_Access__c FROM Account Where Id =: acct.Id];
        System.assertEquals(wpAccess.Program_Id_Autonumber__c,accUpdatedList[0].Web_Program_Access__c);*/
    }
}