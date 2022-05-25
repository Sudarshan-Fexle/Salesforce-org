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
    *  Purpose         :   Test class for Sched_SubscriptionPeriodCreation
    *
    *  Created By      :   Mahendra Swarnkar
    *  
    *  Created Date    :   07/23/2019 
    *
    *  Revision Log    :   V1.0
    *		       :   V1.1 - Modified By - Subhash Garhwal - CR-20210922-15455
    *
    *  Code Coverage   :	
    *
    **/
@isTest(SeeAllData = false)
private class Test_Sched_SubscriptionPeriodCreation {
    
    static testMethod void myUnitTest() {
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Variable to hold the Current fiscal year 
        integer currentFY = shift_get_fiscal_year.current();
        
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

        //Create Membership Period records
        Program_Package__c ppkTemp = new Program_Package__c ( Account__c = account.id, Name = 'ShiftTest', Membership__c = membership.Id,
                                                             Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                             Client_Status_New__c = 'In Play');
        Util.byPassAllTriggers = true;
        //Insert Program package
        insert ppkTemp;
        
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
        opp.Main_Contact__c = contact.Id;
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opp);
        
        Util.byPassAllTriggers = true;
        //Update
        insert opportunities;
        
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
        
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        quoteLine1.SBQQ__Product__c = products[0].Id;
        quoteLine1.Current_List_Price__c = 2.0;
        quoteLine1.Product_Category__c = 'Annual Fee';
        quoteLine1.SBQQ__Quote__c = proposals[0].Id;
        quoteLine1.SBQQ__Number__c = 11;
        quoteLine1.SBQQ__Quantity__c = 1; 
        quoteLine1.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine1.SBQQ__SpecialPrice__c = 0;
        quoteLine1.SBQQ__PricingMethod__c = 'List';
        quoteLine1.Annual_Increase__c = 5;
        quoteLine1.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine1.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine1.SBQQ__SubscriptionBase__c = 'List';
        
        insert quoteLine1;
        System.assert(quoteLine1.Id != null);
        
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Product__c = products[1].Id;
        quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
        quoteLine2.Current_List_Price__c = 5.0;
        quoteLine2.Product_Category__c = 'Annual Fee';
        quoteLine2.SBQQ__Quote__c = proposals[0].Id;
        quoteLine2.SBQQ__Number__c = 11;
        quoteLine2.SBQQ__Quantity__c = 1; 
        quoteLine2.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine2.SBQQ__SpecialPrice__c = 0;
        quoteLine2.SBQQ__PricingMethod__c = 'List';
        quoteLine2.Annual_Increase__c = 5;
        quoteLine2.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine2.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine2.SBQQ__SubscriptionBase__c = 'List';
        
        Util.byPassAllTriggers = true;
        insert quoteLine2;
        System.assert(quoteLine2.Id != null);
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c();
        quoteLine3.SBQQ__Product__c = products[2].Id;
        quoteLine3.SBQQ__RequiredBy__c = quoteLine2.Id;
        quoteLine3.Current_List_Price__c = 6.0;
        quoteLine3.Product_Category__c = 'Annual Fee';
        quoteLine3.SBQQ__Quote__c = proposals[0].Id;
        quoteLine3.SBQQ__Number__c = 11;
        quoteLine3.SBQQ__Quantity__c = 1; 
        quoteLine3.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine3.SBQQ__SpecialPrice__c = 0;
        quoteLine3.SBQQ__PricingMethod__c = 'List';
        quoteLine3.Annual_Increase__c = 5;
        quoteLine3.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine3.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine3.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine3.SBQQ__SubscriptionBase__c = 'List';
        
        Util.byPassAllTriggers = true;
        insert quoteLine3;
        
        List<Contract> stdContract = new List<Contract>();
        stdContract.add(new Contract(AccountId = account.Id, SBQQ__Opportunity__c = opportunities[0].Id, SBQQ__Quote__c = proposals[0].Id));
        
        //Insert
        insert stdContract;

        //Test starts from here
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = recordTypes[0].Id;
        subscription.Opportunity__c = opportunities[0].Id;
        subscription.Source_Opportunity__c = opportunities[0].Id;
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.SBQQ__Product__c = products[1].Id;
        subscription.SBQQ__SegmentStartDate__c = Date.today();
        subscription.SBQQ__QuoteLine__c = quoteLine3.Id;
        subscription.SBQQ__Contract__c = stdContract[0].Id;
        subscription.SBQQ__Account__c  = account.Id;
        subscription.Early_Termination_Date__c = Date.today();
        subscription.Opt_Out__c = 'Opt Out after First Year in Membership With Penalty Fee';

        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
        listSubscriptions.add(subscription);
        
        //Insert Subscriptions
        Util.byPassAllTriggers = true;
        insert listSubscriptions;
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription.Opportunity__c = opportunities[0].Id;
        componentSubscription.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription.SBQQ__RequiredByProduct__c = products[0].Id;
        componentSubscription.SBQQ__Product__c = products[1].Id;
        componentSubscription.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription.SBQQ__SegmentEndDate__c = Date.today();
        componentSubscription.Program_Subscription__c = listSubscriptions[0].Id;
        componentSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        componentSubscription.SBQQ__Contract__c = stdContract[0].Id;
        componentSubscription.Top_Related_Product__c = 'Yield Optimization';
        componentSubscription.Renewal_Type__c = 'Continuing';
        componentSubscription.SBQQ__QuoteLine__c = quoteLine2.Id;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        listcomponentSubscription.add(componentSubscription);
        
        Util.byPassAllTriggers = true;
        //Insert componentSubscription
        insert listcomponentSubscription;

        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = account.Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Membership_Lookup__c =  membership.Id;
        sPeriod.Program_Package__c = ppkTemp.Id;
        sPeriod.Contract__c = stdContract[0].Id;
        
        //List of subscription Period.
        List<Subscription_Period__c> listSubscriptionPeriods = new List<Subscription_Period__c>();
        listSubscriptionPeriods.add(sPeriod);
        
        Util.byPassAllTriggers = true;
        //Insert the listOfSubscriptionPeriod
        insert listSubscriptionPeriods;
        
        //set of ContaractId
        Set<Id> setContractIds = new Set<Id>();
        setContractIds.add(contract.Id);
        
        //Map to hold map to hold Component Subscription
        Map<String, SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomation = new Map<String,SubscriptionPeriodAutomationWrapper>();
        
        //Map to hold Program Subscription Id as key and value as key
        Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKey = new Map<Id, Set<String>>();
        
        //Get all record types of Subscription_Period__c
        Map<String, Id> mapSubscriptionPeriodRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SUBSCRIPTION_PERIOD);
        
        //Get Record Type
        String eABRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB);
        
        
        for(SBQQ__Subscription__c subscrpt : listcomponentSubscription){
            //Hold Unique Key Parent Product + Segment Start Date + Segment End Date + Segment Index + Contract
            String uniqueKey = subscrpt.SBQQ__Contract__c + '-' + subscrpt.Program_Products__c + '-'
                + subscrpt.SBQQ__SegmentStartDate__c + '-' + subscrpt.Segment_Label_Index__c;
            
            //Process if Key Contain in Map
            if(!mapUniqueKeySubscriptionPeriodAutomation.containsKey(uniqueKey)) {
                
                //Variable or Subscription Period
                SubscriptionPeriodAutomationWrapper sWrapper = new SubscriptionPeriodAutomationWrapper();
                
                //Hold Variable
                sWrapper.periodStartDate = subscrpt.SBQQ__SegmentStartDate__c;
                sWrapper.periodEndDate = subscrpt.SBQQ__SegmentEndDate__c;
                sWrapper.uniqueKey = uniqueKey;
                sWrapper.SubscriptionPeriodType = CPQConstants.SUBSCRIPTION_PERIOD_COMPONENT_TYPE;
                sWrapper.SegmentIndex = subscrpt.Segment_Label_Index__c;
                sWrapper.Stage = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL;
                sWrapper.Contract = subscrpt.SBQQ__Contract__c;
                sWrapper.programSubscription.Id = subscrpt.Program_Subscription__c;
                sWrapper.RecordType = eABRecordType;
                
                
                
                sWrapper.componentSubscription.add(subscription);
                mapUniqueKeySubscriptionPeriodAutomation.put(uniqueKey,sWrapper);
                
            } else
                mapUniqueKeySubscriptionPeriodAutomation.get(uniqueKey).componentSubscription.add(subscription);
            
            //Check the key in map
            if(!mapProgramSubscriptionwithUniqueKey.containsKey(subscrpt.Program_Subscription__c))
                mapProgramSubscriptionwithUniqueKey.put(subscrpt.Program_Subscription__c, new Set<String>());
            
            //Add Subscription Period in map
            mapProgramSubscriptionwithUniqueKey.get(subscrpt.Program_Subscription__c).add(uniqueKey);
        }
        
        Test.startTest();
        
        Util.ByPassAllTriggers = false;
        
        //instance of Scheduler
        Sched_SubscriptionPeriodCreation sh1 = new Sched_SubscriptionPeriodCreation(mapUniqueKeySubscriptionPeriodAutomation, mapProgramSubscriptionwithUniqueKey, setContractIds);
        //Sched_ProgramPackageCreation.scheduleProgramPackageCreation(listSubscriptionPeriods);
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest(); 
        
    }
    //Modified By - Subhash Garhwal - CR-20210922-15455
    static testMethod void myUnitTest1() {
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Variable to hold the Current fiscal year 
        integer currentFY = shift_get_fiscal_year.current();
        
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

        //Create Membership Period records
        Program_Package__c ppkTemp = new Program_Package__c ( Account__c = account.id, Name = 'ShiftTest', Membership__c = membership.Id,
                                                             Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                             Client_Status_New__c = 'In Play');
        
        Util.byPassAllTriggers = true;        
        //Insert Program package
        insert ppkTemp;
        
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
        opp.Main_Contact__c = contact.Id;
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opp);
        
        
        Util.byPassAllTriggers = true;
        //Update
        insert opportunities;
        
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
        
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        quoteLine1.SBQQ__Product__c = products[0].Id;
        quoteLine1.Current_List_Price__c = 2.0;
        quoteLine1.Product_Category__c = 'Annual Fee';
        quoteLine1.SBQQ__Quote__c = proposals[0].Id;
        quoteLine1.SBQQ__Number__c = 11;
        quoteLine1.SBQQ__Quantity__c = 1; 
        quoteLine1.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine1.SBQQ__SpecialPrice__c = 0;
        quoteLine1.SBQQ__PricingMethod__c = 'List';
        quoteLine1.Annual_Increase__c = 5;
        quoteLine1.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine1.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine1.SBQQ__SubscriptionBase__c = 'List';
        
        Util.byPassAllTriggers = true;
        insert quoteLine1;
        System.assert(quoteLine1.Id != null);
        
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Product__c = products[1].Id;
        quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
        quoteLine2.Current_List_Price__c = 5.0;
        quoteLine2.Product_Category__c = 'Annual Fee';
        quoteLine2.SBQQ__Quote__c = proposals[0].Id;
        quoteLine2.SBQQ__Number__c = 11;
        quoteLine2.SBQQ__Quantity__c = 1; 
        quoteLine2.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine2.SBQQ__SpecialPrice__c = 0;
        quoteLine2.SBQQ__PricingMethod__c = 'List';
        quoteLine2.Annual_Increase__c = 5;
        quoteLine2.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine2.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine2.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine2.SBQQ__SubscriptionBase__c = 'List';
        
        Util.byPassAllTriggers = true;        
        insert quoteLine2;
        System.assert(quoteLine2.Id != null);
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c();
        quoteLine3.SBQQ__Product__c = products[2].Id;
        quoteLine3.SBQQ__RequiredBy__c = quoteLine2.Id;
        quoteLine3.Current_List_Price__c = 6.0;
        quoteLine3.Product_Category__c = 'Annual Fee';
        quoteLine3.SBQQ__Quote__c = proposals[0].Id;
        quoteLine3.SBQQ__Number__c = 11;
        quoteLine3.SBQQ__Quantity__c = 1; 
        quoteLine3.SBQQ__ProrateMultiplier__c = 4; 
        quoteLine3.SBQQ__SpecialPrice__c = 0;
        quoteLine3.SBQQ__PricingMethod__c = 'List';
        quoteLine3.Annual_Increase__c = 5;
        quoteLine3.Calculator__c = 'Calculator - BHAN : 12 : NBB';
        quoteLine3.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine3.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLine3.SBQQ__SubscriptionBase__c = 'List';
        
        Util.byPassAllTriggers = true;
        insert quoteLine3;
        
        List<Contract> stdContract = new List<Contract>();
        stdContract.add(new Contract(AccountId = account.Id, SBQQ__Opportunity__c = opportunities[0].Id, SBQQ__Quote__c = proposals[0].Id));

        Util.byPassAllTriggers = true;
        //Insert
        insert stdContract;

        //Test starts from here
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = recordTypes[0].Id;
        subscription.Opportunity__c = opportunities[0].Id;
        subscription.Source_Opportunity__c = opportunities[0].Id;
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.SBQQ__Product__c = products[1].Id;
        subscription.SBQQ__SegmentStartDate__c = Date.today();
        subscription.SBQQ__QuoteLine__c = quoteLine3.Id;
        subscription.SBQQ__Contract__c = stdContract[0].Id;
        subscription.SBQQ__Account__c  = account.Id;
        subscription.Early_Termination_Date__c = Date.today();
        
        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
        listSubscriptions.add(subscription);
        
        Util.byPassAllTriggers = true;
        //Insert Subscriptions
        insert listSubscriptions;
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        componentSubscription.Opportunity__c = opportunities[0].Id;
        componentSubscription.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription.SBQQ__RequiredByProduct__c = products[0].Id;
        componentSubscription.SBQQ__Product__c = products[1].Id;
        componentSubscription.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription.SBQQ__SegmentEndDate__c = Date.today();
        componentSubscription.Program_Subscription__c = listSubscriptions[0].Id;
        componentSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        componentSubscription.SBQQ__Contract__c = stdContract[0].Id;
        componentSubscription.Top_Related_Product__c = 'Yield Optimization';
        componentSubscription.Renewal_Type__c = 'Continuing';
        componentSubscription.SBQQ__QuoteLine__c = quoteLine2.Id;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        listcomponentSubscription.add(componentSubscription);
        
        Util.byPassAllTriggers = true;
        //Insert componentSubscription
        insert listcomponentSubscription;
         
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = account.Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Period_Start_Date__c = Date.Today().adddays(-1);
        sPeriod.Membership_Lookup__c =  membership.Id;
        sPeriod.Program_Package__c = ppkTemp.Id;
        sPeriod.Contract__c = stdContract[0].Id;
        
        //List of subscription Period.
        List<Subscription_Period__c> listSubscriptionPeriods = new List<Subscription_Period__c>();
        listSubscriptionPeriods.add(sPeriod);
        
        Util.byPassAllTriggers = true;
        //Insert the listOfSubscriptionPeriod
        insert listSubscriptionPeriods;
        
        //set of ContaractId
        Set<Id> setContractIds = new Set<Id>();
        setContractIds.add(contract.Id);
        
        //Map to hold map to hold Component Subscription
        Map<String, SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomation = new Map<String,SubscriptionPeriodAutomationWrapper>();
        
        //Map to hold Program Subscription Id as key and value as key
        Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKey = new Map<Id, Set<String>>();
        
        //Get all record types of Subscription_Period__c
        Map<String, Id> mapSubscriptionPeriodRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SUBSCRIPTION_PERIOD);
        
        //Get Record Type
        String eABRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB);
        
        
        for(SBQQ__Subscription__c subscrpt : listcomponentSubscription){
            //Hold Unique Key Parent Product + Segment Start Date + Segment End Date + Segment Index + Contract
            String uniqueKey = subscrpt.SBQQ__Contract__c + '-' + subscrpt.Program_Products__c + '-'
                + subscrpt.SBQQ__SegmentStartDate__c + '-' + subscrpt.Segment_Label_Index__c;
            
            //Process if Key Contain in Map
            if(!mapUniqueKeySubscriptionPeriodAutomation.containsKey(uniqueKey)) {
                
                //Variable or Subscription Period
                SubscriptionPeriodAutomationWrapper sWrapper = new SubscriptionPeriodAutomationWrapper();
                
                //Hold Variable
                sWrapper.periodStartDate = subscrpt.SBQQ__SegmentStartDate__c;
                sWrapper.periodEndDate = subscrpt.SBQQ__SegmentEndDate__c;
                sWrapper.uniqueKey = uniqueKey;
                sWrapper.SubscriptionPeriodType = CPQConstants.SUBSCRIPTION_PERIOD_COMPONENT_TYPE;
                sWrapper.SegmentIndex = subscrpt.Segment_Label_Index__c;
                sWrapper.Stage = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL;
                sWrapper.Contract = subscrpt.SBQQ__Contract__c;
                sWrapper.programSubscription.Id = subscrpt.Program_Subscription__c;
                sWrapper.RecordType = eABRecordType;
                
                
                
                sWrapper.componentSubscription.add(subscrpt);
                mapUniqueKeySubscriptionPeriodAutomation.put(uniqueKey,sWrapper);
                
            } else
                mapUniqueKeySubscriptionPeriodAutomation.get(uniqueKey).componentSubscription.add(subscrpt);
            
            //Check the key in map
            if(!mapProgramSubscriptionwithUniqueKey.containsKey(subscrpt.Program_Subscription__c))
                mapProgramSubscriptionwithUniqueKey.put(subscrpt.Program_Subscription__c, new Set<String>());
            
            //Add Subscription Period in map
            mapProgramSubscriptionwithUniqueKey.get(subscrpt.Program_Subscription__c).add(uniqueKey);
        }
        
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        //instance of Scheduler
        Sched_SubscriptionPeriodCreation sh1 = new Sched_SubscriptionPeriodCreation(mapUniqueKeySubscriptionPeriodAutomation, mapProgramSubscriptionwithUniqueKey, setContractIds);
        //Sched_ProgramPackageCreation.scheduleProgramPackageCreation(listSubscriptionPeriods);
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
        //Test stops from here
        Test.stopTest();      
    }   
}