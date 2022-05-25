/**
 * 
 *  Purpose         :   Unit tests for the sched calculatorPDFSync class
 *
 *  Revision Logs   :   V_1.0 - Created - 01/09/2018 - Victor Hanson - CR-20160414-9762
 * 		    :   V_1.1 - Modified by Neha Sharma - 07/01/2021 - CR-20210517-15151
 * 
**/
@isTest
private class TestSched_CalculatorPDFSync {
    
    //TODO: Create mock callout tests
    public static testMethod void testSyncPDF() {
        //system.assertEquals(true, false, 'TODO: Write unit test');
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'EAB Tech', Program__c = prog.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'Enrollment Services', Program__c = prog.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')); 
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
         
        //Insert
        insert products;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact record
        Contact contact = TestUtilities.CreateNewContact(account, true);
        
        //creating Contract record
        Contract__c contract = TestUtilities.CreateNewcontract(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
            
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB_Initiating');
        
        //Populated value of Account by Neha Sharma - 07/01/2021 - CR-20210517-15151
        opp.AccountId = account.Id;
        
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opp);
        
        //Update
        update opportunities;
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, Sync_Calculator_PDF__c = true,
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contact.Id, Is_Enrollment_Services__c = true,
                                         SBQQ__Account__c = account.Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        
        Util.BypassAllTriggers = false;
        
        //Insert list of Quote
        insert proposals;
        
        proposals = [Select Id, SBQQ__Type__c, SBQQ__Primary__c, SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c, Sync_Calculator_PDF__c, Is_Enrollment_Services__c, 
                     ApprovalStatus__c, SBQQ__EndDate__c, SBQQ__Status__c, SBQQ__PrimaryContact__c From SBQQ__Quote__c where Id =: proposals[0].Id];
        
        //Map of proposal
        Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>([Select Id, SBQQ__Type__c, SBQQ__Primary__c, SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c, Sync_Calculator_PDF__c, Is_Enrollment_Services__c, 
                     ApprovalStatus__c, SBQQ__EndDate__c, SBQQ__Status__c, SBQQ__PrimaryContact__c From SBQQ__Quote__c where Id =: proposals[0].Id]);
        
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals1 = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals1.add(new SBQQ__Quote__c(Id = proposals[0].Id, SBQQ__StartDate__c = Date.today()+10, SBQQ__SubscriptionTerm__c =24));
        
        //Test starts from here
        Test.startTest();
        
        Util.byPassAllTriggers = true;
        
        // Set mock callout class
		Test.setMock(HttpCalloutMock.class, new MockHTTPCallOutForAWS());
        
        //instance of Scheduler
        Sched_CalculatorPDFSync sh1 = new Sched_CalculatorPDFSync();
        
        Sched_CalculatorPDFSync.checkForSync(proposals1, mapProposals);
        Util.byPassAllTriggers = false;
        
        //Test stops from here
        Test.stopTest();
    }
}