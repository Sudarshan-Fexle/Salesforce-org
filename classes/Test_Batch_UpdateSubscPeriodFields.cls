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
 **/

 
/**
 *  @description    :   This is test class for Batch_UpdateSubscriptionPeriodFields class
 *  Create By       :   Subhash Garhwal
 *  Created Date    :   07/15/2020
 **/ 
@isTest(seeAllData = false)
private class Test_Batch_UpdateSubscPeriodFields 
{
    
    @testSetup static void dataSetup()
    {
        // TO DO: implement unit test
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[0].Status__c = 'Active';
        programs[0].Name = 'TMBH - Test Method';
        programs[0].Program_Acronym__c = 'TMBH';
        programs[0].Program_Formal_Name__c = 'Test Method';
        programs[0].Renewable__c = true; 
        programs[0].New_Business_Business__c = 'EAB';
        programs[0].Type__c = 'Standard';
        programs[0].Type__c = 'Standard';
        programs[0].New_Business_Vertical__c = 'EAB';
        programs[0].Entity__c = 'EAB';
        programs[0].Program_Line__c = 'PT';
        programs[0].Sector__c = 'HE';
        programs[0].Applicable_Segments__c = 'International Education;US Education';
        programs[0].Solomon_Code__c = '851';
        programs[0].New_Business_Marketer__c = 'HE SSC';
        programs[0].Create_memberships__c = 'Yes';
        programs[0].Renewal_Unit_Count__c = 1;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Travel Fee', IsActive = true, ProductCode = 'TravelFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Travel Fee', Program_Name_Member_Facing__c = 'Travel Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Implementation Fee', IsActive = true, ProductCode = 'ImplementationFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Implementation Fee', Program_Name_Member_Facing__c = 'ImplementationFee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Trevel Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Implementation Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[3].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert productOptions;
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        
        //Insert
        insert accounts;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
        
        insert memberships;
        
        //SOQL over the opportunity Record Type0
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert contact;
        
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert IBS
        insert invoices;
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Add record to list
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                       Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Year with Opt Out'));
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                       Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Fixed Term'));
               
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert the contract ABC
        insert contracts;
        
        //Creating new Custom setting Data 
        List<Sync_Field__c> syncFields = new List<Sync_Field__c>();
        syncFields.add(new Sync_Field__c(Name = 'Test', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Program', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        syncFields.add(new Sync_Field__c(Name = 'Test1', Source_Field_API_Name__c = 'Program__c', Source_Object_API_Name__c = 'SBQQ__Subscription__c', Source_Record_Type_Developer_Name__c = 'Component', 
                                         Target_Field_API_Name__c = 'Program__c', Target_Object_API_Name__c = 'SBQQ__Subscription__c'));
        
        insert syncFields;
        
        //Get Account
        List<Account> listOfAccounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Get Product
        List<Product2> listOfProducts = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> listOfpPograms = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-Exploring';
        eABInitOpp.Main_Contact__c = contacts[0].Id;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contacts[0].Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert subProposalLines;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update proposals;
        
        //Update Opportunity
        eABInitOpp.StageName = 'Contract Received - Send to Finance';
        eABInitOpp.Contract_Signature_Date__c = System.today();
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Start Testing from here
        Test.startTest();
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        // update opp
        //Update Opportunity
        eABInitOpp.StageName = 'Closed Won';
        eABInitOpp.Signed_Opportunity_Contract__c = contracts[0].Id;
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        // contract
        List<Contract> stdContract = new List<Contract>();
		stdContract.add(new Contract(AccountId = accounts[0].Id, SBQQ__Opportunity__c = eABInitOpp.Id, SBQQ__Quote__c = proposals[0].Id));
        stdContract.add(new Contract(AccountId = accounts[0].Id, SBQQ__Opportunity__c = eABInitOpp.Id, SBQQ__Quote__c = proposals[0].Id));
        
        //Insert
        insert stdContract;
        
        List<Contract> listOfstdContract = [Select Id From Contract];
        System.assert(listOfstdContract.size() > 0 );
        
        //Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        //Get Record Type
        Id subscriptionComponentRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Component');
        
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = subscriptionProgramRecordType;
        subscription.Opportunity__c = eABInitOpp.Id;
        subscription.Source_Opportunity__c = eABInitOpp.Id;
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.SBQQ__Product__c = products[1].Id;
        subscription.SBQQ__SegmentStartDate__c = Date.today();
        subscription.Profit_m__c = 788;
        subscription.SBQQ__Contract__c = listOfstdContract[0].Id;
        subscription.Previous_Contract_ABC__c = contracts[0].Id;
        
        // 2nd prog subscription
        //Record type for subscription
        //Creating Subscription record
        SBQQ__Subscription__c subscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        subscription2.recordTypeId = subscriptionProgramRecordType;
        subscription2.Opportunity__c = eABInitOpp.Id;
        subscription2.Source_Opportunity__c = eABInitOpp.Id;
        subscription2.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription2.SBQQ__Product__c = products[1].Id;
        subscription2.SBQQ__SegmentStartDate__c = Date.today();
        //subscription2.Previous_Contract_ABC__c = contracts[0].Id; Commented by Rajeev Jain - 09/16/2020 - CR-20200218-13769
        subscription2.Profit_m__c = 788;
        subscription2.SBQQ__Contract__c = listOfstdContract[0].Id;
        

        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
		listSubscriptions.add(subscription);
        listSubscriptions.add(subscription2); 
        
        //Insert Subscriptions
        insert listSubscriptions;
        
        //Creating Component Subscription record
        SBQQ__Subscription__c componentSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription.recordTypeId = subscriptionComponentRecordType;
        componentSubscription.Opportunity__c = eABInitOpp.Id;
        componentSubscription.Source_Opportunity__c = eABInitOpp.Id;
        componentSubscription.SBQQ__RequiredByProduct__c = products[0].Id;
        componentSubscription.SBQQ__Product__c = products[1].Id;
        componentSubscription.SBQQ__SegmentUplift__c = 4;
        componentSubscription.SBQQ__SegmentStartDate__c = Date.Today().addYears(-3).addDays(1);
        componentSubscription.SBQQ__SegmentEndDate__c = Date.today().addYears(-2);
        componentSubscription.SBQQ__CustomerPrice__c = 788;
        componentSubscription.SBQQ__Quantity__c = 3;
        componentSubscription.Profit_m__c = 788;  
        componentSubscription.SBQQ__SegmentIndex__c = 1;
        componentSubscription.Program_Subscription__c = listSubscriptions[0].Id;
        componentSubscription.SBQQ__Contract__c = listOfstdContract[0].Id;
        
        // 2nd
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription2.recordTypeId = subscriptionComponentRecordType;
        componentSubscription2.Opportunity__c = eABInitOpp.Id;
        componentSubscription2.Source_Opportunity__c = eABInitOpp.Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[0].Id;
        componentSubscription2.SBQQ__Product__c = products[1].Id;
        componentSubscription2.SBQQ__SegmentUplift__c = 4;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.Today().addYears(-2).addDays(1);
        componentSubscription2.SBQQ__SegmentEndDate__c = Date.today().addYears(-1);
        componentSubscription2.SBQQ__CustomerPrice__c = 788;
        componentSubscription2.SBQQ__Quantity__c = 3;
        componentSubscription2.Profit_m__c = 788;  
        componentSubscription2.SBQQ__SegmentIndex__c = 2;
        componentSubscription2.Program_Subscription__c = listSubscriptions[1].Id;
        componentSubscription2.SBQQ__Contract__c = listOfstdContract[0].Id;
        
        // 3rd
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription3 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription3.recordTypeId = subscriptionComponentRecordType;
        componentSubscription3.Opportunity__c = eABInitOpp.Id;
        componentSubscription3.Source_Opportunity__c = eABInitOpp.Id;
        componentSubscription3.SBQQ__RequiredByProduct__c = products[0].Id;
        componentSubscription3.SBQQ__Product__c = products[1].Id;
        componentSubscription3.SBQQ__SegmentUplift__c = 4;
        componentSubscription3.SBQQ__SegmentStartDate__c = Date.Today().addYears(-1).addDays(1);
        componentSubscription3.SBQQ__SegmentEndDate__c = Date.today();
        componentSubscription3.SBQQ__CustomerPrice__c = 788;
        componentSubscription3.SBQQ__Quantity__c = 3;
        componentSubscription3.Profit_m__c = 788;  
        componentSubscription3.SBQQ__SegmentIndex__c = 3;
        componentSubscription3.Program_Subscription__c = listSubscriptions[1].Id;
        componentSubscription3.SBQQ__Contract__c = listOfstdContract[0].Id;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
		listcomponentSubscription.add(componentSubscription);
        listcomponentSubscription.add(componentSubscription2);
        listcomponentSubscription.add(componentSubscription3);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        List<SBQQ__Subscription__c> componentSubscriptionList = [Select Id,Profit_m__c From SBQQ__Subscription__c ];
        System.assert(componentSubscriptionList.size() > 0 );
        
        //Variable to hold the Current fiscal year 
        integer currentFY = shift_get_fiscal_year.current();
        
        //Create Membership Period records
        Program_Package__c ppkTemp = new Program_Package__c ( Account__c = accounts[0].id, Name = 'ShiftTest', Membership__c = memberships[0].Id,
                                                              Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                              Client_Status_New__c = 'In Play');
        
        //Insert Program package
        insert ppkTemp;
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_Start_Date__c = Date.Today().addYears(-3).addDays(1);
        sPeriod.Period_End_Date__c = Date.Today().addYears(-2).addDays(1);
        sPeriod.Membership_Lookup__c =  memberships[0].Id;
        sPeriod.Program_Package__c = ppkTemp.Id;
        sPeriod.Program_Subscription__c = listSubscriptions[0].Id;
        sPeriod.Contract__c = stdContract[0].Id;
        //sPeriod.Profit_Period__c = 70;
        sPeriod.Segment_Index__c = 1;
        //sPeriod.Previous_Contract_ABC__c = contracts[0].Id; Commented by Rajeev Jain - 09/16/2020 - CR-20200218-13769
        sPeriod.Contract__c = listOfstdContract[0].Id;
        //2nd Creating Subscription Period record
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod2.Institution__c = accounts[0].Id;
        sPeriod2.Period_Start_Date__c = Date.Today().addYears(-2).addDays(1);
        sPeriod2.Period_End_Date__c = Date.Today().addYears(-1).addDays(1);
        sPeriod2.Membership_Lookup__c =  memberships[0].Id;
        sPeriod2.Program_Package__c = ppkTemp.Id;
        sPeriod2.Program_Subscription__c = listSubscriptions[0].Id;
        sPeriod2.Contract__c = stdContract[0].Id;
        //sPeriod2.Profit_Period__c = 70;
        sPeriod2.Segment_Index__c = 2;
        sPeriod2.Contract__c = listOfstdContract[0].Id;
        
        //3rd Creating Subscription Period record
        Subscription_Period__c sPeriod3 = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod3.Institution__c = accounts[0].Id;
        sPeriod.Period_Start_Date__c = Date.Today().addYears(-1).addDays(1);
        sPeriod2.Period_End_Date__c = Date.Today();
        sPeriod3.Membership_Lookup__c =  memberships[0].Id;
        sPeriod3.Program_Package__c = ppkTemp.Id;
        sPeriod3.Contract__c = stdContract[0].Id;
        //sPeriod3.Profit_Period__c = 70;
        sPeriod3.Segment_Index__c = 3;
        sPeriod3.Contract__c = listOfstdContract[0].Id;
        
        //4rth Creating Subscription Period record
        Subscription_Period__c sPeriod4 = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod4.Institution__c = accounts[0].Id;
        sPeriod4.Period_Start_Date__c = Date.Today();
        sPeriod4.Period_End_Date__c = Date.Today().addYears(+1);
        sPeriod4.Membership_Lookup__c =  memberships[0].Id;
        sPeriod4.Program_Package__c = ppkTemp.Id;
        sPeriod4.Contract__c = stdContract[0].Id;
        sPeriod4.Stage__c = 'Pending';
        sPeriod4.Decision_Type__c = 'Need New LOA';
        sPeriod4.Program_Subscription__c = listSubscriptions[0].Id;
        //sPeriod4.Previous_Contract_ABC__c = privcontract.Id;
        //sPeriod4.Profit_Period__c = 70;
        sPeriod4.Contract__c = listOfstdContract[0].Id;
        
        //List of subscription Period.
        List<Subscription_Period__c> listSubscriptionPeriods = new List<Subscription_Period__c>();
		listSubscriptionPeriods.add(sPeriod);
        listSubscriptionPeriods.add(sPeriod2);
        listSubscriptionPeriods.add(sPeriod3);
        listSubscriptionPeriods.add(sPeriod4);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        insert listSubscriptionPeriods;
        
		//Insert the listOfSubscriptionPeriod
        
        List<Subscription_Period__c> subscriptionPeriodsList = [Select Id From Subscription_Period__c];
        System.assert(subscriptionPeriodsList.size() > 0 );
        
        // update subsperiod
        subscriptionPeriodsList[1].Previous_Subscription_Period__c = subscriptionPeriodsList[0].Id;
        subscriptionPeriodsList[2].Previous_Subscription_Period__c = subscriptionPeriodsList[1].Id;
        subscriptionPeriodsList[3].Previous_Subscription_Period__c = subscriptionPeriodsList[2].Id;
        update subscriptionPeriodsList;
        
        // update the subComponent
        List<SBQQ__Subscription__c> listToBeUpdate = new List<SBQQ__Subscription__c>();
        /*for(SBQQ__Subscription__c subs : componentSubscriptionList)
        {
            subs.Subscription_Period__c = subscriptionPeriodsList[0].Id;
            listToBeUpdate.Add(subs);
        }
		update listToBeUpdate;
		*/
        componentSubscriptionList[0].Subscription_Period__c = subscriptionPeriodsList[0].Id;
        componentSubscriptionList[1].Subscription_Period__c = subscriptionPeriodsList[1].Id;
        componentSubscriptionList[2].Subscription_Period__c = subscriptionPeriodsList[2].Id;
        update componentSubscriptionList;
        
        //Bypassing Triggers so then test data can be created easily
        //Util.byPassAllTriggers = true;
        
        //Stop Testing here
        Test.stopTest();
        
        
    }
    
    static testMethod void test_dataUpdate()
    {
        List<Contract> listOfContract = [Select Id From Contract];
        Set<Id> setOfContractId = new Set<Id>();
        for(Contract contr: listOfContract)
        {
            setOfContractId.add(contr.Id);
        }
        
         test.startTest();
        Batch_UpdateSubscriptionPeriodFields batch = new Batch_UpdateSubscriptionPeriodFields(setOfContractId);
        //batch.setContractIds =setOfContractId; 
        database.executeBatch(batch);
        
            
        //Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        //Get Record Type
        Id subscriptionComponentRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Component');
        
        List<Subscription_Period__c> subscriptionPeriodsList = [Select Id,Renewal_Negotiated__c,Negotiated_Amount_Period__c,Previous_Period_Negotiated__c,Previous_Period_Negotiated_Components__c From Subscription_Period__c];
        List<SBQQ__Subscription__c> lsitOfCompSubscription = [Select Id,Customer_Amount__c From  SBQQ__Subscription__c Where RecordTypeId = : subscriptionComponentRecordType];
        System.assert(subscriptionPeriodsList[0].Negotiated_Amount_Period__c != null);
        //System.assertEquals(lsitOfCompSubscription[0].Customer_Amount__c, subscriptionPeriodsList[1].Negotiated_Amount_Period__c);
        System.assert(subscriptionPeriodsList[0].Previous_Period_Negotiated_Components__c != null); 
        System.assert(subscriptionPeriodsList[0].Previous_Period_Negotiated__c != null);
        System.assert(subscriptionPeriodsList[0].Renewal_Negotiated__c != null);
      
        test.stopTest();
    }
    
    static testMethod void test_scheduleSPFieldUpdate()
    {
        List<Contract> listOfContract = [Select Id From Contract];
        Set<Id> setOfContractId = new Set<Id>();
        for(Contract contr: listOfContract)
        {
            setOfContractId.add(contr.Id);
        }
        
        test.startTest();
        //Batch_UpdateSubscriptionPeriodFields.scheduleSPFieldUpdate(setOfContractId);
        test.stopTest();
    }

}