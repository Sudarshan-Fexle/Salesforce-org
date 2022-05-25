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
/**
*   Purpose         :   Test class for QuoteExtController.
*            
*   Create By       :   Mahendra Swarnkar  
*
*   Created Date    :   23/07/2019
*
*   Revision Log    :   V1.0 - Created - CR-20181019-12685
* 		    :   V1.1 - Modified By - Neha Sharma - 07/01/2021 - CR-20210517-15151
*	            :   V1.2 - Modified By - Prateek - 11-02-2021 - CR-20210414-15080
*   Coverage        :    
**/
@isTest(seeAllData = false)
public  class Test_QuoteExtController {
    
    //test method
    public static testMethod void unitTest() {
        
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
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB_Initiating');
        
        //Modified by Neha Sharma - 07/01/2021 - CR-20210517-15151
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
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = account.Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Test starts from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(proposals[0]);
        
        QuoteExtController quoteExt = new QuoteExtController(sc);
        quoteExt.onSubmit();
        quoteExt.onRecall();
        quoteExt.onPreview();
        
        //Test stops from here
        Test.stopTest();
    }
    
    //test method
    public static testMethod void unitTest1() {
        
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
        
        //Modified by Neha Sharma - 07/01/2021 - CR-20210517-15151
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
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = account.Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        Util.BypassAllTriggers = true;
        
        
        //Change stageName of opportunity.
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        
        Util.BypassAllTriggers = true;
        //Update
        update opportunities;
        
        //Test starts from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(proposals[0]);
        
        QuoteExtController quoteExt1 = new QuoteExtController(sc1);
        quoteExt1.onSubmit();
        quoteExt1.onRecall();
        quoteExt1.onPreview();
		 
	//CR-20210414-15080 Delete opportunity related to quote.
	Opportunity opp1 = new Opportunity(Id = proposals[0].SBQQ__Opportunity2__c);
	delete opp1;
        try{
            sc1 = new ApexPages.StandardController(proposals[0]);
            quoteExt1 = new QuoteExtController(sc1);
            quoteExt1.onSubmit();
            quoteExt1.onRecall();
            quoteExt1.onPreview();
        }catch(Exception e){
            
        }
        
        //Test stops from here
        Test.stopTest();
    }
    
}