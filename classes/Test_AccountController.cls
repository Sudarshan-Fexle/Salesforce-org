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
@isTest(seeAllData = false)
class Test_AccountController {

    /*
    Purpose     :   Test AccountController Apex Class - CR -20130117-2187
    
    Create By   :   Bhavi Sharma - 02/18/2013
    
    Revision Log:   v1.0 - (AW) Created Code
                    v1.1 -  Modified By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
                    v1.2 - Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350 - Updated the query to fetch southwind record type details with the help of DeveloperName of it in place of Name.
                    v1.3 - Modified By - Subhash Garhwal - 08/16/2016 - CR-20160414-9762 - Change Opportunity Stage value to correct one.
                    v1.4 - Modified By - Abhinav Sharma - 07/05/2017 - Q2C Release based changes
                    v1.5 - Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
		    v1.6 - Modified By Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
		    v1.7 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
                  
  Code Coverage: 02/18/2013: 100%
  Code Coverage: 07/05/2017: 88%
    */

    static testmethod void myUnitTest() {
  
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
    
        //Creating Test Data
      
        //Getting Record Type Id for Account
        ID accRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'US Education'].Id;
        
        //Modified by - Abhinav Sharma - 12/23/2015 - CR-20150706-9060 - Updated SF Admin opportunity record type reference 
        //with some other record type reference. Since it is mark eligible for deletion cycle.
        //Creating Test Date
        //Getting Record Type Id Value for opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity'
                              // No such field on Opportunity : Modified By : Seemu 05/03/2019
                              //AND IsActive = true
                              AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                              ORDER BY DeveloperName ASC LIMIT 1].Id;
         
        //Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350
        //Start from here
        //Getting Record Type Id Value for opportunity
        ID southWindRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                    and DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                    ORDER BY DeveloperName ASC LIMIT 1 ].Id;
        //Ends here
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
         //Program 
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = prog.Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        insert products;
        //Contact
        Contact contact = new Contact(FirstName = 'Main', LastName = 'Test Contact', Email = 'mainTest@tes.com', 
                                      AccountId = account.Id, Title = 'Test', Phone = '614-555-8855');
        
        //Insert
        insert contact;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Subhash Garhwal - 08/16/2016 - CR-20160414-9762 - Change Opportunity Stage from "Contract Received – Send to Finance" to "Contract Received - Send to Finance"
        //List to hold opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test', CloseDate = System.today(), AccountId = account.Id, StageName = '0-MQL',
                                          RecordTypeID = southWindRecordTypeId,
                                          Main_Contact__c = contact.Id /*Sell_Type__c = 'Net New'*/));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = account.Id, StageName = '0-MQL',
                                          CloseDate = System.today().addDays(7), RecordTypeID = oppRecordTypeId, 
                                          Name = 'Test', Pool_Month__c = '1', Main_Contact__c = contact.Id,/* Sell_Type__c = 'Net New',*/
                                          Pool_Year__c = String.valueOf(Date.Today().Year())));                             
          
        //Insert Opportunities
        insert opportunities;
                
        System.assertEquals(2, opportunities.size());
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', RecordTypeId = proposalRTypes[0].Id));
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[1].Id, 
                                      SBQQ__Status__c = 'Draft', RecordTypeId = proposalRTypes[0].Id));
        
        
        //Insert list of Quote
        insert proposals;
        
         List<SBQQ__QuoteLine__c> mainProposalLine = new List<SBQQ__QuoteLine__c>();
        //Add Proposal Lines under the Proposal
         mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id,SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        //Add Proposal Lines under the Proposal
         mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[1].Id,SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        proposals[1].ApprovalStatus__c = 'Approved';
        proposals[1].SBQQ__Status__c = 'Approved';
        proposals[1].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        proposals[1].SBQQ__Status__c = 'Locked';
        proposals[1].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[1].StageName = 'Contract Received - Send to Finance';
    
        update opportunities;
        
        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = account.Id, Active__c = true, Start__c = System.today(), End__c = System.today().addDays(20));
        insert contractABC;
        
       //Membership
        Util.BypassAllTriggers = false;
        
        Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, false);
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //mem.Cohort_Start_Date__c = System.today().addDays(-2);
        mem.Active_Contract_Idenfied__c = contractABC.Id;
        insert mem;
          
        //Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        
        // set the page
        test.setCurrentPage(Page.Account_US_Provider_Strategic);
        
        //Start Test from Here
        Test.startTest();
          
        //Calling Constructor
        AccountController controller = new AccountController(sc);
        
         //Getting Values
        opportunities = controller.openNBBOpportunities;
        
        //Assert for the result
        //System.assertEquals(1, opportunities.size());
    
        opportunities = controller.currentRenewalOpportunities;
        
        //Assert for the result
        //System.assertEquals(2, opportunities.size());
        
        //Assert for results
        //System.assertEquals(1, controller.contractABCs.size());
        //System.assertEquals(1, controller.memberships.size());
        
        //Stop Test Here
        Test.stopTest();  
    } 
    
    // verify that when the record type is US Provider - System or US Provider - Hospital that a redirect occurs
    static testmethod void testRedirectTo() {
        /*
        // temporarily bypass all triggers
        Util.BypassAllTriggers = true;
        
        // create a new institution with record type = us provider - system
        Account acct_provider_system = testUtilities.CreateNewAccount(false);
        acct_provider_system.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - System');
        insert acct_provider_system;
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(acct_provider_system);
        test.setCurrentPage(Page.Account_US_Provider_Strategic);
        AccountController controller = new AccountController(standardController);
        
        // verify the redirectTo returns the VF page
        system.assertEquals(true, controller.redirectTo().getUrl().contains('Account_US_Provider_Strategic'), 
                            'Record type US Provider - System should cause a redirect to Account_US_Provider_Strategic VF Page.');
                            
        // create a new institution with record type = us provider - hospital
        Account acct_provider_hospital = testUtilities.CreateNewAccount(false);
        acct_provider_hospital.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - Hospital');
        insert acct_provider_hospital;
        
        // instantiate the controller and set the page
        standardController = new ApexPages.standardController(acct_provider_hospital);
        controller = new AccountController(standardController);
        
        // verify the redirectTo returns the VF page
        system.assertEquals(true, controller.redirectTo().getUrl().contains('Account_US_Provider_Strategic'), 
                            'Record type US Provider - Hospital should cause a redirect to Account_US_Provider_Strategic VF Page.');*/
    }
    
    // verify that when the record type is US Provider - Hospital and a Account Standard Layout record 
    // exists for that profile/record type combo, the use is directed to the standard Institution layout.
    static testmethod void testRedirectTo_noRedirect() {
        /*
        // temporarily bypass all triggers
        Util.BypassAllTriggers = true;
        
        // create a new institution with record type = us provider - hospital
        Account acct_provider_hospital = testUtilities.CreateNewAccount(false);
        acct_provider_hospital.RecordTypeId = Util.RecordTypeId('Account', 'US Provider - Hospital');
        insert acct_provider_hospital;
        
        // create a new Account Standard Layout record
        Account_Standard_Layouts__c acctStandardLayout = new Account_Standard_Layouts__c(Name = 'sys admin - US Provider Hospital',
                                                                                         Record_Type_API_Name__c = 'US_Provider',
                                                                                         Profile_ID__c = UserInfo.getProfileId());
        //insert acctStandardLayout;
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(acct_provider_hospital);
        test.setCurrentPage(Page.Account_Detail_Page);
        AccountController controller = new AccountController(standardController);
        
        // verify the redirectTo returns the standard layout
        system.assertEquals(true, controller.redirectTo().getUrl().contains('nooverride=1'), 
                            'Record type US Provider - Hospital should NOT cause a redirect to Account_US_Provider_Strategic ' +
                            'VF Page when a Account Standard Layout is present for that profile and record type.');*/
    }
    
    
    static testmethod void testUSProviderSystem_showMoreRelatedList() {
        
        // temporarily bypass all triggers
        Util.BypassAllTriggers = true;
        
        // create a new institution with record type = us provider - system
        Account acct_system = testUtilities.CreateNewAccount(false);
        acct_system.RecordTypeId = Util.RecordTypeId('Account', 'US Education');
        insert acct_system;
        
        // create 2 child hospitals
        Account acct_hospital_1 = testUtilities.CreateNewAccount(false);
        acct_hospital_1.RecordTypeId = Util.RecordTypeId('Account', 'US Education'); //changed US Provider - Hospital(deactive)
        acct_hospital_1.ParentId = acct_system.Id;
        Account acct_hospital_2 = testUtilities.CreateNewAccount(false);
        acct_hospital_2.RecordTypeId = Util.RecordTypeId('Account', 'US Education'); //changed US Provider - Hospital(deactive)
        acct_hospital_2.ParentId = acct_system.Id;
        list<Account> hospitalAcctList = new list<Account> { acct_hospital_1, acct_hospital_2 };
        insert hospitalAcctList;
        
        // create activities for all 3 Institutions
        list<Event> events = new list<Event>();
        list<Task> tasks = new list<Task>();
        for (integer i = 0; i < 30; i++) {
            
            Event evt1_system = TestUtilities.createEvent(false, system.now().addDays(-3), acct_system.Id);
            Event evt2_system = TestUtilities.createEvent(false, system.now().addDays(-5), acct_system.Id);
            Event evt_hospital_1 = TestUtilities.createEvent(false, system.now().addDays(-3), acct_hospital_1.Id);
            Event evt_hospital_2 = TestUtilities.createEvent(false, system.now().addDays(5), acct_hospital_2.Id);
            events.add(evt1_system);
            events.add(evt2_system);
            events.add(evt_hospital_1);
            events.add(evt_hospital_2);
            
            Task tsk_system = testUtilities.createTask(false, acct_system.Id);
            Task tsk_hospital_1 = testUtilities.createTask(false, acct_hospital_1.Id);
            tasks.add(tsk_system);
            tasks.add(tsk_hospital_1);
        }
        insert events;
        insert tasks;
        
        // create opportunities and contracts for the 2 child institutions
        Opportunity renewalOpp = TestUtilities.CreateNewOpportunity(acct_hospital_1.Id, false);
        renewalOpp.RecordTypeId = Util.RecordTypeId('Opportunity', 'PT Contract Renewal');
        renewalOpp.Pool_Year__c = string.valueOf(system.today().addDays(5).year());
        renewalOpp.Pool_Month__c = string.valueOf(system.today().addDays(5).Month());
        Opportunity nbbOpp = TestUtilities.CreateNewOpportunity(acct_hospital_2.Id, false);
        nbbOpp.RecordTypeId = Util.RecordTypeId('Opportunity', 'PT Marketing');
        list<Opportunity> opps = new list<Opportunity> { renewalOpp, nbbOpp };
        insert opps;
        
        // create contracts
        Contract__c contractABC = TestUtilities.CreateNewContract(false);
        contractABC.Payer_Account__c = acct_hospital_1.Id;
        Contract__c contractABC2 = TestUtilities.CreateNewContract(acct_hospital_2.Id, 
                                                                    contractABC.Main_Contact__c, 
                                                                    contractABC.Program__c, 
                                                                    false);
        list<Contract__c> contractABCs = new list<Contract__c> { contractABC, contractABC2 };
        insert contractABCs;
        
        // instantiate the controller and set the page
        ApexPages.standardController standardController = new ApexPages.standardController(acct_system);
        test.setCurrentPage(Page.Account_US_Provider_Strategic);
        AccountController controller = new AccountController(standardController);
        
        // make sure the child tasks are present
        system.assertEquals(90, controller.numChildActivities);
        system.assertEquals(15, controller.childActivities.size());
        
        // display more child activities
        controller.showMoreChildActivities();
        system.assertEquals(30, controller.childActivities.size());
        controller.showMoreChildActivities();
        system.assertEquals(45, controller.childActivities.size());
        
        system.assertEquals(1, controller.openNBBChildOpportunities.size());
        system.assertEquals(1, controller.currentChildRenewalOpportunities.size());
        
        system.assertEquals(2, controller.activeChildContracts.size());
        system.assertEquals(1, controller.openNBBChildOpportunities.size());
        system.assertEquals(1, controller.currentChildRenewalOpportunities.size());
        
        controller.showMoreChildActivities();
        system.assertEquals(60, controller.childActivities.size());
    }
    
    //Method added by the Abhinav Sharma - 03/20/2014 - To Test the Pagination Functionality - CR-20140201-4431
    static testmethod void testNavigation() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
    
        //Commented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756
        //Creating Test Data
        //Getting Record Type Id for Account
        //ID accRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'US Provider Strategic'].Id;
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
        //Creating Contract ABC test data
        List<Contract__c> contractsList = new List<Contract__c>();
        for(Integer i=0; i<35; i++) {
            Contract__c contractABC = new Contract__c(Payer_Account__c = account.Id, Active__c = true, Start__c = System.today(), End__c = System.today().addDays(20));
            contractsList.add(contractABC);
        }
        
        if(contractsList.size() > 0)
            insert contractsList;
        
        //Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        
        // set the page
        test.setCurrentPage(Page.Account_US_Provider_Strategic);
        
        //Start Test from here
        Test.startTest();
          
        //Calling Constructor
        AccountController controller = new AccountController(sc);
        
        //Assert for results
        System.assertEquals(10, controller.contractABCs.size());
        System.assertEquals(35, controller.totalContractABCsCount);
        
        //Assert for the results
        System.assert(controller.displayShowMoreForContractABCs);
        
        //Calling method to get the coverage
        controller.object_Name = 'ContractABC';
        
        //Click On Show More
        controller.showMoreRecords();
        
        //Getting value
        contractsList = controller.contractABCs;
        
        //Assert for the results
        System.assertEquals(20, contractsList.size());
        System.assert(controller.displayShowMoreForContractABCs);
        
        //Click On Show More
        controller.showMoreRecords();
        
        //Getting value
        contractsList = controller.contractABCs;
        
        //Assert for the results
        System.assertEquals(30, contractsList.size());
        System.assert(controller.displayShowMoreForContractABCs);
        
        //Click On Show More
        controller.showMoreRecords();
        
        //Getting value
        contractsList = controller.contractABCs;
        
        //Assert for the results
        System.assertEquals(35, contractsList.size());
        System.assert(!controller.displayShowMoreForContractABCs);
        
        controller.object_Name = 'OpenNBBChildOpportunity';
        controller.showMoreRecords();
            
        
        //Stop Test Here
        Test.stopTest();
    }   
    
    //Method added by the Abhinav Sharma - 07/03/2017
    static testmethod void testSubscriptionNavigation() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //List to hold the record's type 
       List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                       AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM ];
      
       //create Test data for Account object as an institute
        Account account = new Account(Name = 'AccountTest1');
        insert account;
        
        Profile p = [SELECT ID FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        Account_Standard_Layouts__c aSL = new Account_Standard_Layouts__c();
        aSL.Name = 'ABC Dataloader-US_Provz';
        aSL.Profile_ID__c = p.ID;
        aSL.Record_Type_API_Name__c = 'US_Provider';
        insert aSL;
        
        Institution_Roles__c iR = new Institution_Roles__c();
        iR.Institution__c = account.ID;
        iR.Name = 'Test';
        insert iR;
        
        //Create contact
        Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, 
                    Email = 'Test'+Math.random()+'@eab.com', 
                    Title = 'Test', Phone = '614-555-8855');
    
        insert contact;

        //List to insert Program records
        List<Program__c> programList = new List<Program__c>();
        
        //Add Program Record in list
        programList.add(TestUtilities.CreateNewProgram(false));
        programList.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programList[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programList[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        
        //Insert the program records
        insert programList;
        
        //List of Product
        List<Product2> listOfProduct = new List<Product2>();
        
        //Add new Products in List
        listOfProduct.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programList[0].Id, IsActive = true,
                           SBQQ__Component__c = true, ProductCode = 'RIPRO'));
        
        listOfProduct.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programList[1].Id, IsActive = true,
                            SBQQ__Component__c = true, ProductCode = 'PTPRO'));
        
        //Insert the productlist 
        insert listOfProduct;
         
        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = account.Id,
                                                Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                                Negotiated_Amount__c = 12 );
    //Insert the contract ABC
        insert contractABC;
        
        //Program Susbcription record  
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                    SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,  
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed' );
        //Insert 
        insert subscription;
        
        //Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        
        // set the page
        test.setCurrentPage(Page.Account_US_Provider_Strategic);

    //start test from here
        Test.startTest();
        
        //Calling Constructor
        AccountController controller = new AccountController(sc);
        list<SBQQ__Subscription__c> accChildren = controller.activeChildSubscriptions;
        list<SBQQ__Subscription__c> subs = controller.subscriptions;
        list<Institution_Roles__c> accRoles = controller.accountRoles;
        List<Restricted_MtM__c> activeRestrictions = controller.activeRestrictions;
            
        //Stop test here
        Test.stopTest();
    }   
    
    @isTest
    static void test_memberships(){

         //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
    
        //Creating Test Data
      
        //Getting Record Type Id for Account
        ID accRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Account' and Name = 'US Education'].Id;
        
        //Modified by - Abhinav Sharma - 12/23/2015 - CR-20150706-9060 - Updated SF Admin opportunity record type reference 
        //with some other record type reference. Since it is mark eligible for deletion cycle.
        //Creating Test Date
        //Getting Record Type Id Value for opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity'
                              // No such field on Opportunity : Modified By : Seemu 05/03/2019
                              //AND IsActive = true
                              AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                              ORDER BY DeveloperName ASC LIMIT 1].Id;
         
        //Modified by - Mahendra Swarnkar - 12/04/2015 - CR-20151022-9350
        //Start from here
        //Getting Record Type Id Value for opportunity
        ID southWindRecordTypeId = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                    and DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME 
                                    ORDER BY DeveloperName ASC LIMIT 1 ].Id;
        //Ends here
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
         //Program 
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'EDIF',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = prog.Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        insert products;
        //Contact
        Contact contact = new Contact(FirstName = 'Main', LastName = 'Test Contact', Email = 'mainTest@tes.com', 
                                      AccountId = account.Id, Title = 'Test', Phone = '614-555-8855');
        
        //Insert
        insert contact;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Subhash Garhwal - 08/16/2016 - CR-20160414-9762 - Change Opportunity Stage from "Contract Received – Send to Finance" to "Contract Received - Send to Finance"
        //List to hold opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test', CloseDate = System.today(), AccountId = account.Id, StageName = '0-MQL',
                                          RecordTypeID = southWindRecordTypeId,
                                          Main_Contact__c = contact.Id /*Sell_Type__c = 'Net New'*/));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',AccountId = account.Id, StageName = '0-MQL',
                                          CloseDate = System.today().addDays(7), RecordTypeID = oppRecordTypeId, 
                                          Name = 'Test', Pool_Month__c = '1', Main_Contact__c = contact.Id,/* Sell_Type__c = 'Net New',*/
                                          Pool_Year__c = String.valueOf(Date.Today().Year())));                             
          
        //Insert Opportunities
        insert opportunities;
                
        System.assertEquals(2, opportunities.size());
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
      
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                      SBQQ__Status__c = 'Draft', RecordTypeId = proposalRTypes[0].Id));
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                      SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[1].Id, 
                                      SBQQ__Status__c = 'Draft', RecordTypeId = proposalRTypes[0].Id));
        
        
        //Insert list of Quote
        insert proposals;
        
         List<SBQQ__QuoteLine__c> mainProposalLine = new List<SBQQ__QuoteLine__c>();
        //Add Proposal Lines under the Proposal
         mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id,SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        //Add Proposal Lines under the Proposal
         mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[1].Id,SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                       SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                       SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                       SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
    
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        proposals[1].ApprovalStatus__c = 'Approved';
        proposals[1].SBQQ__Status__c = 'Approved';
        proposals[1].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        proposals[1].SBQQ__Status__c = 'Locked';
        proposals[1].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[1].StageName = 'Contract Received - Send to Finance';
    
        update opportunities;
        
        //create Contract ABC test data
        Contract__c contractABC = new Contract__c(Payer_Account__c = account.Id, Active__c = true, Start__c = System.today(), End__c = System.today().addDays(20));
        insert contractABC;
        
       //Membership
        Util.BypassAllTriggers = false;
        
        Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, false);
        mem.Active_Contract_Idenfied__c = contractABC.Id;
        insert mem;
          
        //Standard Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(account);

        test.setCurrentPage(Page.Account_US_Provider_Strategic);

        Test.startTest();

        AccountController controller = new AccountController(sc);
        List<Membership__c> listOfMembs = new  List<Membership__c>();

        listOfMembs = controller.memberships;

        Test.stopTest();

        Membership__c membershipIns = [SELECT Id, Name, Program__c, Membership_Status__c FROM Membership__c LIMIT 1];

        system.assert(listOfMembs != null);
        system.assertEquals(membershipIns.ID, listOfMembs[0].ID);
        system.assertEquals(membershipIns.Membership_Status__c, listOfMembs[0].Membership_Status__c);
        system.assertEquals(membershipIns.Name, listOfMembs[0].Name);

    }

    @isTest
    static void test_redirectTo(){

        Util.BypassAllTriggers = true;
        
        
        Test.startTest();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        update user1;
        
        system.runAs(user1){
            Account acct_system = testUtilities.CreateNewAccount(false);
            acct_system.RecordTypeId = Util.RecordTypeId('Account', 'US Education');
            insert acct_system;

            ApexPages.standardController standardController = new ApexPages.standardController(acct_system);
            test.setCurrentPage(Page.Account_US_Provider_Strategic);
            AccountController controller = new AccountController(standardController);

            controller.redirectTo();

            system.assertEquals(true, controller.redirectTo().getUrl().contains('nooverride=1'));
            system.assertEquals(true, controller.redirectTo().getUrl().contains(acct_system.ID));

        }
        // create a new institution with record type = us provider - system
        
        Test.stopTest();
    }
}