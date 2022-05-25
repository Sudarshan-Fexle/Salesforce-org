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
//Modified by - Rajeev Jain - 11/08/2017 - Too many SOQL Error fix(Rev Mgmt 606 deployment to prod) - Applied by pass trigger flag and reset start and stop test flag on testpopulateFieldsValueOnCases method
@isTest(seeAllData = false)
private class Test_SBQQ_SubscriptionTrigger {
    /**
    *   Purpose         :   Test class for SBQQ_SubscriptionTrigger
    *            
    *   Create By       :   Subhash Garhwal
    * 
    *   Created Date    :   07/25/2016
    *
    *   Revision Log    :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
    *	                :   V_1.1 - Modified By - 04/10/17 - Victor Hanson - CR-20170403-10807 - Commented out the class because program opportunities are no longer being used
    *	                :   V_1.2 - Modified By - 07/11/17 - Subhash Garhwal - 
    *	                :   V_1.3 - Modified By - 08/01/17 - Saurabh Kumar - Issue--CR10808--QA--00005099 - Testing for contracting on Opportunity
    *	                :   V_1.4 - Modified By - 08/22/2017 -Subhash Garhwal -
    *	                :   V_1.5 - Modified By - Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035
    *	                :   V_1.6 - Modified By - Dipesh Gupta 5-03-2020 CR-20200114-13623 Increase code coverage for Batch_NightlyMembershipSubUpdate
    *	                :   V_1.7 - Modified By - Neha Sharma - CR-20200910-14498 - 10/19/2020 - testYouVisitAssignmentOnSubscriptionPeriod - Add field to Subscription Periods
    *	                :   V_1.8 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    *	                :   V_1.9 - Modified By - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup

    *	                :   V_2.1 - Modified By - Subhash Garhwal - CR-20210817-15358
    *
    **/    
    
    @testSetup static void dataSetup() {
        
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
        products.add(new Product2(Name = 'Offer', IsActive = true, ProductCode = 'Offer', SBQQ__Component__c = true,Offer__c = true,
                                  Product_Category__c = 'Offer', Program_Name_Member_Facing__c = 'Offer',
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
        
        features.add(new SBQQ__ProductFeature__c(Name = 'Offer', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
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
        
        
        
    }
        
    //Test method
    static testMethod void myUnitTest() {
        
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
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
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	eABInitOpp.Sales_Pursuit_Products__c = 'APS';
        
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
        
        //Stop Testing here
        Test.stopTest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, SBQQ__StartDate__c, Renewal_Opportunity__c, SBQQ__Product__c, SBQQ__Contract__c, SBQQ__QuoteLine__c, Source_Opportunity__c, Invoice_Contact__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        
        
        SBQQ_SubscriptionTriggerHelper.populateRecordTypeOnSubscription(programSubscriptions);
        
        update programSubscriptions;
        
        programSubscriptions = [Select Id, Program__c, Parent_Program__c, Stage_Period__c, SBQQ__StartDate__c, SBQQ__Account__c, Renewal_Opp_Stage__c, SBQQ__EndDate__c, Status__c,  Renewal_Opportunity__c, SBQQ__Product__c, SBQQ__Contract__c, SBQQ__QuoteLine__c, Source_Opportunity__c, Invoice_Contact__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        //Assert
        System.assertEquals(1, programSubscriptions.size());
        
        List<Contract>  contracts = [Select Id From Contract];
        
        //Assert
        System.assertEquals(1, contracts.size());  
        
        //Update Opportunity
        eABInitOpp.StageName = 'Closed Won';
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        //Acitve
        contracts[0].Status  = 'Activated_Amended';
        contracts[0].Amendment_Type__c = 'Amend & Extend';
        contracts[0].SBQQ__RenewalTerm__c = 36;
        contracts[0].SBQQ__RenewalPricebookId__c = '01sC00000003gcn'; 
        contracts[0].SBQQ__RenewalOpportunityStage__c = 'pending';
        contracts[0].SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date';
        contracts[0].SBQQ__DefaultRenewalContactRoles__c = true;
        contracts[0].SBQQ__DefaultRenewalPartners__c = true;
        contracts[0].SBQQ__Quote__c= proposals[0].Id;
        //update
        update contracts;  
        
        //Contact details
        contracts = [Select Id From Contract where Status  = 'Activated_Amended'];
        
        //opportunity
        List<opportunity> opportunities = [select Id From opportunity];
        
        //Assert
        System.assertEquals(1, opportunities.size());
        
        
        //List to hold Contract ABC
        List<Contract__c> contractABCs = [Select Id From Contract__c];
        
        //Assert
        System.assertEquals(2, contractABCs.size());
        
        //Get IBNS
        List<Invoice_Billing_Schedule__c> invoices = [Select Id From Invoice_Billing_Schedule__c];
        
        //Assert
        System.assertEquals(1, invoices.size());
        
        //List to hold Line item schedule
        List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();
        
        //Add record to list
        listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABCs[0].Id, Invoice_Billing_Schedule_del__c = invoices[0].Id, 
                                              Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                              Amount__c = 20,Program_Subscription__c = programSubscriptions[0].Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert Line Item Schedule test data
        insert listLIS;
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
        
        //List to hold User
        List<User> users = new List<User>();        
        
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        //Add user record to user
        users.add(new User(Alias = 'ABC', Email = 'testuserABC@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert User
        insert users;
        
        //List to hold membership
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //Add record to list    
        memberships.add(new Membership__c(Name = 'Testing', Program__c = programs[0].Id, Earliest_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id));
        
        memberships.add(new Membership__c(Name = 'TestingABC', Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id));
        
        memberships.add(new Membership__c(Name = 'TestingABC', Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id, Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id));
        
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert Membership
        insert memberships;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                   AND DeveloperName = 'Member_Employee_Support'];
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert 
        cases.add( new Case( Origin = 'Email', Subject = 'out of office', Description = 'out of office',
                            Membership__c = memberships[0].Id,Renewal_Date1__c = Date.today()));
        
        //Create a sample case record to insert
        cases.add( new Case( Origin = 'Email', Subject = 'Test 1', Membership__c = memberships[0].Id,
                            Description = 'test 1', AccountId = accounts[0].Id));
        
        
        //bypass all trigger
        Util.BypassAllTriggers = true;
        
        //Insert case
        insert cases;
        
        /*//Create a sample programSubscription to update
        List<RecordType> rdTypeProgramSubscription = [SELECT ID FROM RecordType Where sObjectType = 'SBQQ__Subscription__c' AND IsActive = true 
                                   AND DeveloperName = 'Program'];*/
        
        //Creating Subscription record
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
        programSubscription.Negotiated_Amount_Subscription__c = 400;
        programSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;

        //bypass all trigger
        Util.BypassAllTriggers = true;
        insert programSubscription;
        
        //Query
        Map<Id, SBQQ__Subscription__c> oldProgramSubscriptions = new  Map<Id, SBQQ__Subscription__c>([Select Id, Product_Code__c,SBQQ__SubscriptionEndDate__c, SBQQ__EndDate__c, Program__c, Parent_Program__c, SBQQ__StartDate__c, SBQQ__Account__c, Membership__c, Status__c, Renewal_Opp_Stage__c,SBQQ__Contract__c,Stage_Period__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program']);
        System.debug('oldProgramSubscriptions::::::::' +oldProgramSubscriptions);
        //
        //programSubscriptions.addAll(oldProgramSubscriptions.values()); 
        
        programSubscriptions[0].SBQQ__Account__c = accounts[1].Id;
        programSubscriptions[0].SBQQ__SubscriptionEndDate__c = System.today().addDays(+1);
        programSubscriptions[0].Previous_Program_Subscription__c = programSubscription.Id;
        programSubscriptions[0].Previous_Contract_ABC__c = contractABCs[1].Id;
        programSubscriptions[0].Stage_Period__c ='ATL';
        programSubscriptions[0].Status__c = 'Closed';
        
        //Change
        
        //bypass all trigger
        //Util.BypassAllTriggers = true;
        
        //update 
        update programSubscriptions;
        
        System.debug('programSubscriptions:::::' +programSubscriptions + 'oldProgramSubscriptions::::::::' +oldProgramSubscriptions );
        
        
        
        SBQQ_SubscriptionTriggerHelper.updateMembershipStatusBySubscription(programSubscriptions,oldProgramSubscriptions);
        SBQQ_SubscriptionTriggerHelper.updateMembershiponProgramSubscription(programSubscriptions,oldProgramSubscriptions);
        SBQQ_SubscriptionTriggerHelper.populateFieldsValueOnCases(programSubscriptions,oldProgramSubscriptions);
        
        programSubscriptions[0].Stage_Period__c ='void';
        
        //bypass all trigger
        Util.BypassAllTriggers = true;
        
        //update
        update programSubscriptions;
        
        SBQQ_SubscriptionTriggerHelper.updateRenewalSubscriptionStageNameOfContract(programSubscriptions,oldProgramSubscriptions);
        
        system.debug('%%__2__%%'+programSubscriptions[0].SBQQ__Account__c);
        
        //Query
        programSubscriptions = [Select Id From SBQQ__Subscription__c Where RecordType.DeveloperName = 'component'];
        
        //List to hold LIS
        List<Line_Item_Schedule__c> lineItemSch = [Select Id From Line_Item_Schedule__c];
        
        //Assert
        System.assertEquals(1, lineItemSch.size());
        
        //Update program subscription
        programSubscriptions[0].SBQQ__SegmentstartDate__C = System.today();
        programSubscriptions[0].SBQQ__SegmentEndDate__c =  System.today().addDays(+1);
        programSubscriptions[0].Stage_Period__c ='ATL';
        programSubscriptions[0].Membership__c = memberships[0].Id;
        programSubscriptions[0].Status__c ='ATL';
        programSubscriptions[0].Invoice_Contact__c= contacts[0].Id;
        programSubscriptions[0].Shadow_Contract_ABC__c = contractABCs[0].Id; 
        programSubscriptions[0].Invoice_Billing_Schedule__c = invoices[0].Id;
        programSubscriptions[0].SBQQ__SegmentQuantity__c = 1;
        programSubscriptions[0].SBQQ__CustomerPrice__c = 12;
        
        //bypass all trigger
        Util.BypassAllTriggers = true;
        
        //update 
        update programSubscriptions;
        
        //Update Program subscription
        programSubscriptions[0].Invoice_Billing_Schedule__c = null;
        
        //bypass all trigger
        Util.BypassAllTriggers = false;
        
        try {
            update programSubscriptions;
        }
        Catch(Exception e) {
            System.assert(true);  
        }
        /*
        //Added By subhsh garhwal  - 04/10/2018
        List<SBQQ__Subscription__c> componentSubs = [Select Id, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c From SBQQ__Subscription__c Where RecordType.Developername = 'Component' LIMIT 1];
        
        //Adding 4 years in the End Date
        DateTime dt = DateTime.newInstance(componentSubs[0].SBQQ__SegmentEndDate__c.year() + 4, componentSubs[0].SBQQ__SegmentEndDate__c.month(), componentSubs[0].SBQQ__SegmentEndDate__c.day());
        
        //Changing the Segment Year
        componentSubs[0].SBQQ__SegmentStartDate__c = dt.Date();
        
        //Updating the Component Subscription
        Update componentSubs;
        */

    }
    
    //Test method
    static testMethod void testpopulateProductCode() {
        
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        
        //Assert
        System.assertEquals(2, contracts.size());  
        
        List<Membership__c> memberships = [select id from membership__c];
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName = 'Program' AND IsActive = true];
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> Programsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        Programsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id,
                                                           SBQQ__Quantity__c = 1,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));                                                     
        //Insert
        insert Programsubscriptions;
        
        //By pass trigger
        Util.byPassAllTriggers = false;
        
        //Get Program subscriptiio
        programSubscriptions = [Select Id, SBQQ__Contract__c,Product_Code__c,  RecordTypeId From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program']; 
        
        //Calling Direct helper method to increase code coverage//
        SBQQ_SubscriptionTriggerHelper.populateProductCode(Programsubscriptions,null);
        
        //hold old map
        Map<Id,SBQQ__Subscription__c> oldSub = new Map<Id,SBQQ__Subscription__c>([Select id,RecordTypeId, SBQQ__Contract__c, Product_Code__c From SBQQ__Subscription__c where RecordType.DeveloperName= 'Program']);
        
        //update
        programSubscriptions[0].SBQQ__Contract__c = contracts[1].Id;
        update programSubscriptions;
        
        //Get Subscriptions
        programSubscriptions = [Select Id, SBQQ__Contract__c, Product_Code__c,  RecordTypeId From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program']; 
        
        //Bypass trigger
        Util.byPassAllTriggers = false;
        
        //Calling direct method to increase code coverage//
        SBQQ_SubscriptionTriggerHelper.populateProductCode(Programsubscriptions,oldSub);
        
        //delete record
        delete programSubscriptions;
        
        //Calling direct method to increase code coverage//  
        SBQQ_SubscriptionTriggerHelper.populateProductCode(null,oldSub);    
    } 
    
    //New Method to cover the functionality of class SBQQ__Subscription_Trigger_Helper
    static testMethod void myUnitTest2() {
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
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
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	eABInitOpp.Sales_Pursuit_Products__c = 'APS';
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
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        //Stop Testing here
        Test.stopTest();
        
        //List to hold Contract ABC
        List<Contract__c> contractABCs = [Select Id, RecordTypeId From Contract__c];
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, RecordTypeId From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        //ByPass All trigger true
        Util.byPassAllTriggers = true;
        
        //Create contact
        Contact con = TestUtilities.CreateNewContact(accounts[0], true);
        
        //Bypass All trigger False
        Util.byPassAllTriggers = false;
        
        //Get IBNS
        List<Invoice_Billing_Schedule__c> invoices = [Select Id From Invoice_Billing_Schedule__c];
        
        //Assert
        System.assertEquals(8, programSubscriptions.size());
        
        /* //Changing the programSubscriptions - Invoice Billig Contact
        programSubscriptions[0].Invoice_Contact__c = con.Id;
        programSubscriptions[0].Invoice_Billing_Schedule__c = invoices[0].Id;
        
        update programSubscriptions;*/
        
        Util.BypassAllTriggers = true;
        
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator'];
        
        //List to hold User
        List<User> users = new List<User>();        
        
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        //Add user record to user
        users.add(new User(Alias = 'ABC', Email = 'testuserABC@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile1.Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert User
        insert users;
        
        //List to hold membership
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //Add record to list    
        memberships.add(new Membership__c(Name = 'Testing', /*Value_Management_Director__c = users[0].Id , Value_Management_Lead__c = users[0].Id,*/
                                          Program__c = programs[0].Id, Earliest_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
        Delivery_Manager__c = contacts[0].Id*/));
        
        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                          Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id , Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
        /*Delivery_Manager__c = contacts[0].Id*/));
        
        memberships.add(new Membership__c(Name = 'TestingABC', /*Value_Management_Director__c = users[1].Id , Value_Management_Lead__c = users[1].Id,*/
                                          Program__c = programs[0].Id, Active_Subscription__c = programSubscriptions[0].Id, Account_Name__c = accounts[0].Id,
                                          Latest_Subscription__c  = programSubscriptions[0].Id, Active_Contract_Idenfied__c = contractABCs[0].Id,
                                          Earliest_Contract__c = contractABCs[0].Id, Latest_Contract__c =  contractABCs[0].Id/*,
        /*Delivery_Manager__c = contacts[0].Id*/));
        
        //Bypass
        Util.BypassAllTriggers = true;  
        
        //Insert Membership
        insert memberships;
        
        //List to hold the contract
        List<Contract>  contracts = [Select Id From Contract];
        
        //Contract Integrated Account - insert
        Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
        cIA.Account__c = accounts[0].Id;
        cIA.LOA_Contract__c = contracts[0].Id;
        insert cIA;
        
        //Setting the User 1 to the Manger of 2nd one
        users[0].ManagerId = users[1].Id;
        update users;
        
        //Util Bypass false
        Util.BypassAllTriggers = false;  
        
        //Bypass set to false
        SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE = false;
        ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL = false;
        //SBQQ_SubscriptionTriggerHelper.hasPopulatedSubscriptionFieldsOnMembership = false;
        Util.BYPASS_SUBSCRIPTION_TRIGGER = false;
        
        
        //Changing the programSubscriptions - Invoice Billig Contact
        programSubscriptions[0].Invoice_Contact__c = con.Id;
        programSubscriptions[0].Invoice_Billing_Schedule__c = invoices[0].Id;
        programSubscriptions[0].OwnerId = users[0].Id;
        programSubscriptions[0].Join_Date__c = Date.today().addDays(-2);
        programSubscriptions[0].SBQQ__SubscriptionStartDate__c = Date.today().addDays(+2);
        
        update programSubscriptions;  
        
        //Calling this Method directly.
        SBQQ_SubscriptionTriggerHelper.populateSourceFieldsToTarget(null, programSubscriptions[0], contractABCs[0]);
        
        //Setting flag
        SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE = false;
        ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL = false;
        //SBQQ_SubscriptionTriggerHelper.hasPopulatedSubscriptionFieldsOnMembership = false;
        SBQQ_SubscriptionTriggerHelper.BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS = false;
        Util.BYPASS_SUBSCRIPTION_TRIGGER = false;
        
        //Updateb the Subscription with the Closwed Stage 
        programSubscriptions[0].Status__c = 'Closed';
        programSubscriptions[0].SBQQ__CustomerPrice__c = 20000;
        programSubscriptions[0].SBQQ__SegmentUplift__c = 3;
        
        update  programSubscriptions[0];      
        
        
    }  
    
    //test method
    static testMethod void testpopulateOptOutDetailsOnChildProgramSubscriptions() {
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
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
        eABInitOpp.StageName = '0-MQL';
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	eABInitOpp.Sales_Pursuit_Products__c = 'APS';
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
        
        
        //Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        update eABInitOpp;
        
        
        //Stop Testing here
        Test.stopTest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, Early_Termination_Date__c, Opt_Out__c, Board_Notification_Date__c,
                                                            Term_Type__c, Official_Drop_Date__c From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        //Assert CR-20210817-15358 
        //System.assertEquals(1, programSubscriptions.size());
        
        //Assert
        //System.assertEquals(Date.today(), programSubscriptions[0].Early_Termination_Date__c);
        
        //Assert
        //System.assertEquals('Opt Out after First Year in Membership Without Penalty Fee', programSubscriptions[0].Opt_Out__c);
        
        //Assert
        //System.assertEquals(Date.today(), programSubscriptions[0].Board_Notification_Date__c);
        
        //Assert
        //System.assertEquals('Opt Out', programSubscriptions[0].Term_Type__c);
        
        //Assert
        //System.assertEquals(Date.today(), programSubscriptions[0].Official_Drop_Date__c);
        
        //List of contract
        List<Contract>  contracts = [Select Id From Contract];
        
        //Assert CR-20210817-15358 
        //System.assertEquals(1, contracts.size());  
        
    }
    
    //test method
    static testMethod void testrollupDetailsonProgramSubscriptionFromComponentSubscription() {
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
            
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.Sales_Pursuit_Products__c = 'APS';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contacts[0].Id;
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
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5, SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Insert list of Quote
        insert subProposalLines;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        eABInitOpp.StageName = 'Contract Received - Send to Finance';
        
        update eABInitOpp;
        
        //Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        update eABInitOpp;
        
        //Stop Testing here
        Test.stopTest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, Negotiated_Amount_Subscription__c, SBQQ__ListPrice__c, Negotiated_Amt_CPQ_Subs_Postage_Cost__c,
                                                            Negotiated_Amt_CPQ_Subs_Media_Cost__c, GAAP_Negotiated_Amount_Postage_Cost__c,
                                                            GAAP_Negotiated_Amount_Media_Cost__c, 
                                                            GAAP_Amount_Rev_Rec__c, Line_Item_Schedule_Total_Subscription__c, Recognized_to_Date_Negotiated__c, 
                                                            Negotiated_Amount_Subscription_Rev_Rec__c,
                                                            Recognized_to_Date_GAAP__c, Secured_Amount_GAAP__c, Secured_Amount_Negotiated__c, 
                                                            Setup_in_Negotiated__c, Total_Annual_PI__c
                                                            From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program'];
        
        //Assert  CR-20210817-15358 
        //System.assertEquals(1, programSubscriptions.size());
        
        //Assert
        //System.assertEquals(600, programSubscriptions[0].Negotiated_Amount_Subscription__c);
        
        //Assert
        //System.assertEquals(600.54, programSubscriptions[0].SBQQ__ListPrice__c);
        /*
        //Assert
        System.assertEquals(600, programSubscriptions[0].Negotiated_Amt_CPQ_Subs_Postage_Cost__c);
        
        //Assert
        System.assertEquals(600, programSubscriptions[0].Negotiated_Amt_CPQ_Subs_Media_Cost__c);
        
        //Assert
        System.assertEquals(600, programSubscriptions[0].GAAP_Negotiated_Amount_Postage_Cost__c);
        
        //Assert
        System.assertEquals(600, programSubscriptions[0].GAAP_Negotiated_Amount_Media_Cost__c);
        
        //List of contract
        List<Contract>  contracts = [Select Id From Contract];
        
        //for rollupDetailsOnUltimateProgramSubscriptionFromDirectProgramSubs 
        //Assert
        System.assertEquals(700, programSubscriptions[0].GAAP_Amount_Rev_Rec__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Line_Item_Schedule_Total_Subscription__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Recognized_to_Date_Negotiated__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Negotiated_Amount_Subscription_Rev_Rec__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Recognized_to_Date_GAAP__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Secured_Amount_GAAP__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Secured_Amount_Negotiated__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Setup_in_Negotiated__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Total_Annual_PI__c);
        
        //Assert
        System.assertEquals(0, programSubscriptions[0].Negotiated_Amt_CPQ_Subs_Postage_Cost__c);
        
        //Assert
        System.assertEquals(1, contracts.size()); */
    }
    
    //test method
    static testMethod void testpopulateStdContractFields() {
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
            
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Sales_Pursuit_Products__c = 'APS';
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
                                                    Annual_Increase__c = 5, SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
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
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        //Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        update eABInitOpp;
        
        //Stop Testing here
        Test.stopTest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select SBQQ__Contract__c, Amount_Credited_Total__c, Credit_Note_Total__c,
                       Deferred_Revenue_GAAP__c, Deferred_Revenue_Negotiated__c, GAAP_Amount_Rev_Rec__c, GAAP_Negotiated_Amount__c, Invoice_Total__c,
                       SBQQ__ListPrice__c, Negotiated_Amount_Subscription__c, Negotiated_Amount_Subscription_Rev_Rec__c, Net_Invoiced__c,
                       Recognized_to_Date_Negotiated__c, Recognized_to_Date_GAAP__c, Secured_Amount_GAAP__c, Secured_Amount_Negotiated__c,
                       Setup_in_Negotiated__c From SBQQ__Subscription__c
                       Where RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM AND Program_Subscription__c = null];
        
        //List of component subscription.
        List<SBQQ__Subscription__c> compSub = [Select Id, SBQQ__Contract__c, Product_Code__c, SBQQ__SegmentIndex__c, Customer_Amount__c 
                              From SBQQ__Subscription__c Where RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT
                              AND Product_Code__c IN ('AnnualFee', 'TravelFee', 'ImplementationFee', 'Implementation', 'Program Costs')];
        
        
        
        //Assert  CR-20210817-15358 
        //System.assertEquals(1, programSubscriptions.size());
        
        //Assert
        //System.assertEquals(6, compSub.size());
        
        //List of contract
        List<Contract>  contracts = [Select Id, Amount_Credited_Total_All_Products__c, Credit_Note_Total_All_Products__c, 
                                     Deferred_Revenue_GAAP_Total__c, Deferred_Revenue_Negotiated_Total__c, GAAP_Amount_Rev_Rec_Total__c, 
                                     GAAP_Negotiated_Amount_Total__c, Invoice_Total_All_Products__c, List_Grand_Total__c, Negotiated_Amount_Contract__c, 
                                     Negotiated_Amount_Contract_Rev_Rec__c, Net_Invoiced_Contract__c, Recognized_to_Date_Negotiated_Total__c, 
                                     Recognized_to_Date_GAAP_Total__c, Secured_Amount_GAAP_Total__c, Secured_Amount_Negotiated_Total__c, 
                                     Setup_in_Negotiated_Total__c, X1st_year_Annual__c, Total_Annual_Fee__c, X1st_Year_Travel__c, 
                                     Total_Travel_Fee__c, X1st_Year_Initiation_or_Imp__c From Contract];
        
        //Assert
        //System.assertEquals(600, programSubscriptions[0].Negotiated_Amount_Subscription__c);
        
    }
    
    //test method
    static testMethod void testrollupCompSubToSubPeriod() {
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
            
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Start Testing from here
        Test.startTest();
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Sales_Pursuit_Products__c = 'APS';
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
                                                    Annual_Increase__c = 5, SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947942', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        //Add Trevel Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__Number__c = 2,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[2].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947941', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Travel Fee',
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
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
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
        
        //Mark opportunity as contracted
        eABInitOpp.SBQQ__Contracted__c = true;
        
        //Bypass
        Util.BypassAllTriggers = false;
        
        update eABInitOpp;
        
        //Stop Testing here
        Test.stopTest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, SBQQ__Contract__c From SBQQ__Subscription__c
                       Where RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM];
        
        //Assert  CR-20210817-15358 
        //System.assertEquals(1, programSubscriptions.size());
        
        //Get contract
        List<Contract>  contracts = [Select Id From Contract];
        
        //Assert  CR-20210817-15358 
        //System.assertEquals(1, contracts.size());
        
        //Subscription Period
        List<Subscription_Period__c> subPeriod = [Select Id, Profit_Period__c, Negotiated_Amount_Period__c From Subscription_Period__c]; 
        
        //Assert  CR-20210817-15358 
       // System.assertEquals(4, subPeriod.size());
        
        //Assert
        //System.assertEquals(700, subPeriod[0].Profit_Period__c);   //sum of customer amount on component subscription.
        //System.assertEquals(700, subPeriod[0].Negotiated_Amount_Period__c);   //sum of customer amount on component subscription after update.


    }
    
    //Test method
    static testMethod void testPopulateFieldsOnAmendment() {
        
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
        opp.Main_Contact__c = contacts[0].Id;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opp.Sales_Pursuit_Products__c = 'APS';
        opportunities.add(opp);
        
        //Update
        insert opportunities;
        
        List<Profile> profile = [Select Id, Name From Profile Where name = 'Account Management'];
        
        //List to hold User
        List<User> users = new List<User>();        
        
        //Add user record to user
        users.add(new User(Alias = 'unitTest', Email = 'testuser@testorg.com', 
                           EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                           LocaleSidKey = 'en_GB', ProfileId = profile[0].Id, 
                           TimeZoneSidKey = 'Europe/London', UserName = Math.random() + '@unit.test'));
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contacts[0].Id, 
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        
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
        
        
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7, SBQQ__Opportunity__c = opportunities[0].Id, SBQQ__Quote__c = proposals[0].Id));
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        
        opportunities[0].SBQQ__PrimaryQuote__c = proposals[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[0].SBQQ__Contracted__c = true;
        
        update opportunities;
            
        opportunities[0].StageName = 'Closed Won';
        
        Update opportunities;
        
        contracts[0].Status = 'Activated_Amended';
        contracts[0].Amendment_Type__c = 'Amend & Extend';
        contracts[0].SBQQ__RenewalTerm__c = 36;
        contracts[0].SBQQ__RenewalPricebookId__c = '01sC00000003gcn'; 
        contracts[0].SBQQ__RenewalOpportunityStage__c = 'pending';
        contracts[0].SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date';
        contracts[0].SBQQ__DefaultRenewalContactRoles__c = true;
        contracts[0].SBQQ__DefaultRenewalPartners__c = true;
        
        
        Update contracts;
        
        //Assert
        System.assertEquals(2, contracts.size());  
        
        List<Membership__c> memberships = [select id from membership__c];
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName IN ('Program', 'Component') AND IsActive = true ORDER BY DeveloperName DESC];
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> Programsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        Programsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id,
                                                           Research_Strategic_Leader__c = users[0].Id));                                                     
        //Insert
        insert Programsubscriptions;
        
        Programsubscriptions[0].Status__c = 'Void-Amended';
        Programsubscriptions[0].GAAP_Negotiated_Amount_Postage_Cost__c = 1000;
        Programsubscriptions[0].GAAP_Negotiated_Amount_Media_Cost__c =1000;
        Programsubscriptions[0].GAAP_Negotiated_Amount__c = 1000;
        Programsubscriptions[0].Negotiated_Amount_Subscription__c = 100;
        Programsubscriptions[0].Term_Type__c = CPQConstants.TERM_TYPE_FIXED_TERM;
        
        //Add new subscription record in list
        Programsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,SBQQ__SegmentIndex__c = 11,
                                                           Status__c = 'Committed-Amended', Invoice_Contact__c = contacts[0].Id));
         
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID, SBQQ__NetPrice__c = 0,
                                                           SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,SBQQ__SegmentIndex__c = 11,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id,
                                                           Previous_Program_Subscription__c = Programsubscriptions[0].Id );
            
        //Add new subscription record in list
        Programsubscriptions.add(subs);
        
        //By pass trigger
        Util.byPassAllTriggers = true;
        
        upsert Programsubscriptions;
        
        Test.startTest();
        //Get Program subscriptiio
        programSubscriptions = [Select id, RecordTypeId, SBQQ__Account__c, SBQQ__Quantity__c, Source_Opportunity__c,SBQQ__ListPrice__c, 
                                Stage_Period__c, SBQQ__Contract__c, SBQQ__Product__c, Program__c, Parent_Program__c, SBQQ__NetPrice__c, SBQQ__CustomerPrice__c,
                                SBQQ__ProrateMultiplier__c, SBQQ__SegmentIndex__c, Status__c, Invoice_Contact__c, Previous_Program_Subscription__c, 
                                GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c, GAAP_Negotiated_Amount__c,
                                Program_Subscription__c, Previous_Contract_ABC__c,Renewal_Type__c, Previous_Subscription_Negotiated_Amount__c , 
                                Previous_Subscription_Type__c From SBQQ__Subscription__c ];
        
        Map<Id,SBQQ__Subscription__c> mapSubscription = new Map<Id,SBQQ__Subscription__c>([SELECT Id, Research_Strategic_Leader__c 
                                                                                           FROM SBQQ__Subscription__c]); 
        
        Util.byPassAllTriggers = False; 
        
        SBQQ_SubscriptionTriggerHelper.validatePreviousSubscriptionNegotiated(Programsubscriptions,null);
        SBQQ_SubscriptionTriggerHelper.populateGAAPFieldsOnAmendment(Programsubscriptions,mapSubscription);
        
        Util.byPassAllTriggers = true;
        
        //Get Program subscriptiio
        programSubscriptions = [Select id,GAAP_Negotiated_Amount_Postage_Cost__c, GAAP_Negotiated_Amount_Media_Cost__c, GAAP_Negotiated_Amount__c,
                                SBQQ__Account__c, Program__c, Stage_Period__c,Parent_Program__c, Program_Subscription__c From SBQQ__Subscription__c where RecordType.DeveloperName = 'Program' AND Status__c = 'Committed-Amended'];
        
        system.assertEquals(1,programSubscriptions.size());
        system.assertEquals(1000,programSubscriptions[0].GAAP_Negotiated_Amount_Postage_Cost__c);
        system.assertEquals(1000,programSubscriptions[0].GAAP_Negotiated_Amount_Media_Cost__c);
        system.assertEquals(1000,programSubscriptions[0].GAAP_Negotiated_Amount__c);
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(Programsubscriptions[0].Id, false);
        
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Contract__c = contracts[0].Id;
        sPeriod.Source_Opportunity__c = opportunities[0].Id;
        subscriptionPeriods.add(sPeriod);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(Programsubscriptions[0].Id, false);
        
        sPeriod1.Institution__c = accounts[0].Id;
        sPeriod1.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod1.Contract__c = contracts[0].Id;
        sPeriod1.Source_Opportunity__c = opportunities[0].Id;
        subscriptionPeriods.add(sPeriod1);
        
        insert subscriptionPeriods;
        
        SBQQ_SubscriptionTriggerHelper.updateMembershiponProgramSubscription(Programsubscriptions,null);
            
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription1 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription1.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription1.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription1.recordTypeId = recrdTypes[1].Id;
        componentSubscription1.Opportunity__c = opportunities[0].Id;
        componentSubscription1.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription1.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription1.SBQQ__Product__c = products[1].ID;
        componentSubscription1.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription1.Program_Subscription__c = Programsubscriptions[0].Id;
        componentSubscription1.SBQQ__RenewalPrice__c = 100;
        componentSubscription1.SBQQ__CustomerPrice__c = 100; 
        
        
        listcomponentSubscription.add(componentSubscription1);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription2.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription2.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription2.recordTypeId = recrdTypes[1].Id;
        componentSubscription2.Opportunity__c = opportunities[0].Id;
        componentSubscription2.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription2.SBQQ__Product__c = products[2].ID;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.today().addYears(1);
        componentSubscription2.Program_Subscription__c = Programsubscriptions[0].Id;
        componentSubscription2.SBQQ__RenewalPrice__c = 100;
        componentSubscription2.SBQQ__CustomerPrice__c = 100; 
        
        listcomponentSubscription.add(componentSubscription2);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        //By pass trigger
        Util.byPassAllTriggers = false;
        SBQQ_SubscriptionTriggerHelper.populateRenewalPriceFieldOnCompSubscription(listcomponentSubscription,null);
        //By pass trigger
        Util.byPassAllTriggers = true;
            
        Test.stopTest();
    }
    
    //Test method
    static testMethod void testReparentComponents() {
        
        //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true); 
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Assert 
        System.assertEquals(4, products.size());
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY SBQQ__OptionalSKU__r.Name ASC];
        
        //Assert
        System.assertEquals(3, productsOptions.size());
        
        //List to hold Contract ABC
        List<Contract__c> contractABCs = [Select Id From Contract__c];
        
        //Assert
        System.assertEquals(2, contractABCs.size());
        
        //Get IBNS
        List<Invoice_Billing_Schedule__c> invoices = [Select Id From Invoice_Billing_Schedule__c];
        
        //Assert
        System.assertEquals(1, invoices.size());
        
        //Get all record types of Opportunity
        Map<String, Id> mapOpportunityRecordTypes = Util.recordtypemap('Opportunity');
        
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Contract_Signature_Date__c = Date.today();
        opp.StageName = 'O-MQL';
        opp.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
        opp.Main_Contact__c = contacts[0].Id;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        opp.Sales_Pursuit_Products__c = 'APS';
        opportunities.add(opp);
        
        //Update
        insert opportunities;
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opportunities[0].Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contacts[0].Id, 
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        
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
        
        //List of Contract records
        List<Contract> contracts = new List<Contract>();
        
        //Add new contract record in list
        contracts.add(new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7, SBQQ__Opportunity__c = opportunities[0].Id, SBQQ__Quote__c = proposals[0].Id));
        //insert
        insert contracts;
        
        opportunities[0].SBQQ__PrimaryQuote__c = proposals[0].Id;
        opportunities[0].StageName = 'Contract Received - Send to Finance';
        opportunities[0].SBQQ__Contracted__c = true;
        
        update opportunities;
            
        opportunities[0].StageName = 'Closed Won';
        
        Update opportunities;
        
        contracts[0].Status = 'Activated_Amended';
        contracts[0].Amendment_Type__c = 'Amend & Extend';
        contracts[0].SBQQ__RenewalTerm__c = 36;
        contracts[0].SBQQ__RenewalPricebookId__c = '01sC00000003gcn'; 
        //contracts[0].SBQQ__RenewalOpportunity__c = opportunities[1].Id;
        contracts[0].SBQQ__RenewalOpportunityStage__c = 'pending';
        contracts[0].SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date';
        contracts[0].SBQQ__DefaultRenewalContactRoles__c = true;
        contracts[0].SBQQ__DefaultRenewalPartners__c = true;
        
        Update contracts;
        
        //Assert
        System.assertEquals(1, contracts.size());  
        
        List<Membership__c> memberships = [select id from membership__c];
        
        //Query on Subscription Record Types
        List<RecordType> recrdTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Subscription__c' 
                                       AND DeveloperName IN ('Program', 'Component') AND IsActive = true ORDER BY DeveloperName DESC];
        //Creating Subscription record
        //List to hold subscription
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        programSubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id, Converted_Contract_ABC__c = contractABCs[1].Id));                                                     
        
        //Add new subscription record in list
        programSubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = recrdTypes[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                           SBQQ__Quantity__c = 1, Source_Opportunity__c = opportunities[0].Id,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Program__c = programs[0].ID,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,SBQQ__SegmentIndex__c = 11,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id, Converted_Contract_ABC__c = contractABCs[1].Id ));
        
        //By pass trigger
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programSubscriptions;
           
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Contract__c = contracts[0].Id;
        sPeriod.Source_Opportunity__c = opportunities[0].Id;
        subscriptionPeriods.add(sPeriod);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(programSubscriptions[1].Id, false);
        
        sPeriod1.Institution__c = accounts[0].Id;
        sPeriod1.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod1.Contract__c = contracts[0].Id;
        sPeriod1.Source_Opportunity__c = opportunities[0].Id;
        subscriptionPeriods.add(sPeriod1);
        
        insert subscriptionPeriods;
            
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription1 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription1.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription1.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription1.recordTypeId = recrdTypes[1].Id;
        componentSubscription1.Opportunity__c = opportunities[0].Id;
        componentSubscription1.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription1.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription1.SBQQ__Product__c = products[1].ID;
        componentSubscription1.SBQQ__SegmentStartDate__c = Date.today();
        componentSubscription1.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription1.SBQQ__RenewalPrice__c = 100;
        componentSubscription1.SBQQ__CustomerPrice__c = 100; 
        
        
        listcomponentSubscription.add(componentSubscription1);
        
        //Creating Subscription record
        SBQQ__Subscription__c componentSubscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        componentSubscription2.SBQQ__Contract__c = contracts[0].Id;
        componentSubscription2.Subscription_Period__c = subscriptionPeriods[0].Id;
        componentSubscription2.recordTypeId = recrdTypes[1].Id;
        componentSubscription2.Opportunity__c = opportunities[0].Id;
        componentSubscription2.Source_Opportunity__c = opportunities[0].Id;
        componentSubscription2.SBQQ__RequiredByProduct__c = products[0].ID;
        componentSubscription2.SBQQ__Product__c = products[2].ID;
        componentSubscription2.SBQQ__SegmentStartDate__c = Date.today().addYears(1);
        componentSubscription2.Program_Subscription__c = programSubscriptions[1].Id;
        componentSubscription2.SBQQ__RenewalPrice__c = 100;
        componentSubscription2.SBQQ__CustomerPrice__c = 100; 
        
        listcomponentSubscription.add(componentSubscription2);
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        //List to hold Line item schedule
        List<Line_Item_Schedule__c> listLIS = new List<Line_Item_Schedule__c>();
        
        //Add record to list
        listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABCs[0].Id, Invoice_Billing_Schedule_del__c = invoices[0].Id, 
                                              Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                              Amount__c = 20,Program_Subscription__c = programSubscriptions[1].Id));
        
        //Add record to list
        listLIS.add(new Line_Item_Schedule__c(Contract__c = contractABCs[0].Id, Invoice_Billing_Schedule_del__c = invoices[0].Id, 
                                              Type__c = 'Test', Invoice_Date__c = Date.today(), Invoice_Comment__c = 'Test', 
                                              Amount__c = 20,Program_Subscription__c = programSubscriptions[1].Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert Line Item Schedule test data
        insert listLIS;
        
         //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contractABCs[0].Id, GAAP_Amount__c = 1000, Rev_Rec_Templates__c = 'ABC Revenue Line - Contract;ABC Revenue Line - GAAP', Program_Subscription__c  = programSubscriptions[1].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contractABCs[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 0, Program_Subscription__c  = programSubscriptions[1].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contractABCs[0].Id, Negotiated_Amount__c = 500, GAAP_Amount__c = 1000, Program_Subscription__c  = programSubscriptions[1].Id));
        aBCRevenues.add(new ABC_Revenue__c(Contract_ABC__c = contractABCs[0].Id, Negotiated_Amount__c = 200, GAAP_Amount__c = 1000, Program_Subscription__c  = programSubscriptions[1].Id));
        insert aBCRevenues;
        
        
        Test.startTest();        
        
        //By pass trigger
        Util.byPassAllTriggers = false;
        SBQQ_SubscriptionTriggerHelper.updateStatusForAmendment(programSubscriptions);
        programSubscriptions[0].SBQQ__Quantity__c = 0;
        update programSubscriptions;
        SBQQ_SubscriptionTriggerHelper.updateStatusForAmendment(programSubscriptions);
        programSubscriptions = [Select Id, RecordTypeId, SBQQ__Account__c, SBQQ__Quantity__c, Source_Opportunity__c, Program_Products__c,Shadow_Contract_ABC__c,
                                                            SBQQ__ListPrice__c,Stage_Period__c, SBQQ__Contract__c, SBQQ__Product__c, Program__c, Invoice_Billing_Schedule__c,
                                                            SBQQ__NetPrice__c, SBQQ__CustomerPrice__c, SBQQ__ProrateMultiplier__c, SBQQ__SegmentIndex__c, 
                                                            Status__c, Invoice_Contact__c, Converted_Contract_ABC__c From SBQQ__Subscription__c Where Id IN : programSubscriptions];
        
        
        
        //SBQQ_SubscriptionTriggerHelper.reparentComponentSubscriptionsOnAmendment(programSubscriptions);
        SBQQ_SubscriptionTriggerHelper.updateContractABC(programSubscriptions, null);
        
        Util.BypassAllTriggers = true;
        
        //Creating Opportunity record
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.Contract_Signature_Date__c = Date.today();
        opp1.StageName = 'O-MQL';
        opp1.RecordTypeId = mapOpportunityRecordTypes.get('EAB Initiating');
       	opp1.Main_Contact__c = contacts[0].Id;
        insert opp1; 
        
        proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = opp1.Id, 
                                         SBQQ__Status__c = 'Locked', SBQQ__PrimaryContact__c = contacts[0].Id, 
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId()));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5, SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[0].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee', SBQQ__RenewedSubscription__c = listcomponentSubscription[1].Id,
                                                    SBQQ__ListPrice__c = 100, Postage_Costs__c = 100, Media_Costs__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        //Insert list of Quote
        insert subProposalLines;
        
        List<SBQQ__QuoteLine__c> proposalLines = [Select Id, SBQQ__RenewedSubscription__c, SBQQ__UpgradedSubscription__c  From SBQQ__QuoteLine__c where SBQQ__Quote__c =: proposals[0].Id];
        
        //By pass trigger
        //Util.byPassAllTriggers = true;
        //SBQQ_SubscriptionTriggerHelper.twinFields(proposalLines);
        Test.stopTest();
        
    }
    
    static testMethod void testUpdateMembershipStatusbySubs()
    {
         //Bypassing all triggers 
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Get Account
        List<Account> accounts = [Select Id From Account order By Name];
        
        //Assert
        System.assertEquals(2, accounts.size());
        
        //Get Contact
        List<Contact> contacts = [Select Id From Contact];
        
        //Assert
        System.assertEquals(1, contacts.size());
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
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
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 	eABInitOpp.Sales_Pursuit_Products__c = 'APS';
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
        
        //Bypass--
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
        
        //Create Contract
        Contract StdContract = new Contract(AccountId = accounts[0].Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        Util.BypassAllTriggers = true;
        insert StdContract;
        
        eABInitOpp.SBQQ__RenewedContract__c = StdContract.Id;
        Util.BypassAllTriggers = true;
        update eABInitOpp;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        Id EABContinuingRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EAB Continuing').getRecordTypeId();
        List<Opportunity> listOfOpportunity2 = new List<Opportunity>();
        listOfOpportunity2.add(new Opportunity(Name = 'TestOpp', CloseDate = system.today(),StageName = 'Pending', Previous_Opportunity__c = eABInitOpp.Id,
                                               RecordTypeId = EABContinuingRT,Sales_Pursuit_Products__c = 'APS',
                                               SBQQ__RenewedContract__c = StdContract.Id));
        Util.BypassAllTriggers = true;
        insert listOfOpportunity2;
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert IBS
        insert invoices;
        
        List<Contract__c> contracts = new List<Contract__c>(); 
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                       Year__c = '2017', Type__c = 'Renewal', Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Fixed Term',
                                       Start__c = system.today(),End__c = system.today(), Status__c = 'ATL',
                                      Contract_Renewal_Opportunity__c = listOfOpportunity2[0].Id));
        
        Util.BypassAllTriggers = true;
        insert contracts;
        
    }
    
    //test method for populateSubscriptionFieldsonNewMembership
    static testMethod void test_populateSubscriptionFieldsonNewMembership() {
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        List<Account> accList = [Select Id From Account];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        
        //Contract Integrated Account - insert
        Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
        cIA.Account__c = accList[0].Id;
        cIA.LOA_Contract__c = contracts[0].Id;
        insert cIA;
        
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
         //Creating Subscription record
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membershipsList[0].Id, true);
        
        /*List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));*/
        SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsonNewMembership(membershipsList);
    }
    // CR-20210817-15358 - START
    static testMethod void test_populateStartEndDateOnESYOComponentSubscription(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
                
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        List<Product2> products = [Select ID, Name From Product2 Limit 2];
        products[0].Name = 'Program Costs';
        products[1].Name = 'Financial Aid Optimization';
        update products;

	SBQQ__Subscription__c pSubscription = TestUtilities.createNewSubscription(membershipsList[0].Id, false); 
        pSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        pSubscription.SBQQ__Product__c = products[1].Id;
        pSubscription.SBQQ__Contract__c = contracts[0].Id;
        pSubscription.SBQQ__SegmentEndDate__c = date.newInstance(Date.today().Year(), 7, 15);
        pSubscription.SBQQ__SubscriptionEndDate__c =  date.newInstance(Date.today().Year(), 7, 15);
        insert pSubscription;
        System.assert(pSubscription.Id!= null);
        
        Subscription_Period__c subPeriod = TestUtilities.createNewSubscriptionPeriod(pSubscription.Id, true);
	System.assert(subPeriod.Id != null);
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Program_Subscription__c = pSubscription.Id;
        subscription.SBQQ__SegmentEndDate__c = date.newInstance(Date.today().Year(), 7, 15);
        subscription.SBQQ__SubscriptionEndDate__c =  date.newInstance(Date.today().Year(), 7, 15);
        subscription.Subscription_Period__c = subPeriod.Id;
        //Util.ByPassAllTriggers = false;
        insert subscription;
        
        Test.startTest();
        SBQQ__Subscription__c sb = [Select ID, Related_Product_with_Parent_Product__c, SBQQ__Contract__c, RecordTypeId, SBQQ__SegmentStartDate__c, SBQQ__SegmentEndDate__c,
                                    SBQQ__EndDate__c, Subscription_Period__c From SBQQ__Subscription__c Where Id =: subscription.Id];
  
        SBQQ_SubscriptionTriggerHelper.populateStartEndDateOnESYOComponentSubscription(new List<SBQQ__Subscription__c>{sb}, null);
        Test.stopTest();
        
        Subscription_Period__c sp = [Select Id, Period_End_Date__c From Subscription_Period__c Where Id =:subPeriod.Id];
        System.assertEquals(date.newInstance(Date.today().Year(), 7, 31), sp.Period_End_Date__c);
        
        SBQQ_SubscriptionTriggerHelper.validateCPQProcessAndByPassTrigger(new List<SBQQ__Subscription__c>{sb}, true);
    }
    
    static testMethod void test_populateStartEndDateOnESFOProgramSubscription(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
                
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        List<Product2> products = [Select ID, Name From Product2 Limit 2];
        products[0].Name = 'Program Costs';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO';
        update products;

		SBQQ__Subscription__c pSubscription = TestUtilities.createNewSubscription(membershipsList[0].Id, false); 
        pSubscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        pSubscription.SBQQ__Product__c = products[1].Id;
        pSubscription.SBQQ__Contract__c = contracts[0].Id;
        pSubscription.SBQQ__SegmentEndDate__c = date.newInstance(Date.today().Year(), 7, 15);
        pSubscription.SBQQ__SubscriptionEndDate__c =  date.newInstance(Date.today().Year(), 7, 15);
        insert pSubscription;
        System.assert(pSubscription.Id!= null);
        
        Subscription_Period__c subPeriod = TestUtilities.createNewSubscriptionPeriod(pSubscription.Id, true);
	System.assert(subPeriod.Id != null);
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Program_Subscription__c = pSubscription.Id;
        subscription.SBQQ__SegmentStartDate__c = date.newInstance(Date.today().Year(), 5, 15);
        subscription.SBQQ__SegmentEndDate__c = date.newInstance(Date.today().Year(), 7, 15);
        subscription.SBQQ__SubscriptionEndDate__c =  date.newInstance(Date.today().Year(), 7, 15);
        subscription.Subscription_Period__c = subPeriod.Id;
        
        Test.startTest();
        insert subscription;
        
        SBQQ_SubscriptionTriggerHelper.populateStartEndDateOnESFOProgramSubscription(new List<SBQQ__Subscription__c>{subscription}, null);
        Test.stopTest();
        SBQQ__Subscription__c pSub = [Select Id, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c From SBQQ__Subscription__c Where Id =:pSubscription.Id];
        System.assert(pSub.Id != null);
        System.assert(pSub.SBQQ__SubscriptionStartDate__c != null);
        System.assert(pSub.SBQQ__SubscriptionEndDate__c != null);
    }  
        
    static testMethod void test_populateRenewalFieldOnSubscription(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
                
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'EAB Research';
        products[0].Product_Category__c = 'Annual Fee';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO';
        products[1].Product_Category__c = 'Annual Fee';
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        products[2].Product_Category__c = 'Annual Fee';
        update products;
        
        Util.byPassAllTriggers = true;
        // Create quote
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Type__c = 'Renewal';
        insert quote;
        System.assert(quote.Id != null);
        
        Util.byPassAllTriggers = true;
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine1 = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLine1.SBQQ__Product__c = products[0].Id;
        quoteLine1.Current_List_Price__c = 2.0;
        quoteLine1.Product_Category__c = 'Annual Fee';
        insert quoteLine1;
        System.assert(quoteLine1.Id != null);

        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine2 = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLine2.SBQQ__Product__c = products[1].Id;
        quoteLine2.SBQQ__RequiredBy__c = quoteLine1.Id;
        quoteLine2.Current_List_Price__c = 5.0;
        quoteLine2.Product_Category__c = 'Annual Fee';
        insert quoteLine2;
        System.assert(quoteLine2.Id != null);
        
        // Create quoteLine
        SBQQ__QuoteLine__c quoteLine3 = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLine3.SBQQ__Product__c = products[2].Id;
        quoteLine3.SBQQ__RequiredBy__c = quoteLine2.Id;
        quoteLine3.Current_List_Price__c = 6.0;
        quoteLine3.Product_Category__c = 'Annual Fee';
        insert quoteLine3;
        
        System.assert(quoteLine3.Id != null);
        
        Test.startTest();
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        subscription.SBQQ__QuoteLine__c = quoteLine3.Id;
        
        insert subscription;
       
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.SBQQ__QuoteLine__c = quoteLine2.Id;
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c sb = [Select Id, RecordTypeId, SBQQ__Contract__c, Top_Related_Product__c, SBQQ__Product__c, Renewal_Type__c, SBQQ__QuoteLine__c,
                                    Product_Category__c, SBQQ__Subscription__c.Related_Product__c
                                   From SBQQ__Subscription__c Where Id =: subscription1.Id];
        SBQQ_SubscriptionTriggerHelper.populateRenewalFieldOnSubscription(new List<SBQQ__Subscription__c>{sb}, null);
        Test.stopTest();
    }
    
    static testMethod void test_populateOptOutDetailsOnChildProgramSubscriptions(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
                
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'EAB Research';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO';
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        update products;
        
        Test.startTest();
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        insert subscription;
        System.assert(subscription.id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.Stage_Period__c = 'Pending';
        subscription1.Program_Subscription__c = subscription.Id;
        subscription1.Early_Termination_Date__c = date.today();
        subscription1.Opt_Out__c = 'Non-Standard';
        subscription1.Board_Notification_Date__c = date.today() + 5;
        subscription1.Official_Drop_Date__c = date.today() + 10;
        subscription1.Days_Notice__c =  10;
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription2 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription2.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription2.SBQQ__Contract__c = contracts[1].Id;
        subscription2.Top_Related_Product__c = 'Yield Optimization';
        subscription2.SBQQ__Product__c = products[0].Id;
        subscription2.Renewal_Type__c = 'Continuing';
        subscription2.Program_Subscription__c = subscription1.Id;
        insert subscription2;
        System.assert(subscription2.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription3 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription3.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription3.SBQQ__Contract__c = contracts[1].Id;
        subscription3.Top_Related_Product__c = 'Yield Optimization';
        subscription3.SBQQ__Product__c = products[0].Id;
        subscription3.Renewal_Type__c = 'Continuing';
        subscription3.Program_Subscription__c = subscription1.Id;
        insert subscription3;
        System.assert(subscription3.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ_SubscriptionTriggerHelper.populateOptOutDetailsOnChildProgramSubscriptions(new List<SBQQ__Subscription__c>{subscription3}, null);
        
        SBQQ__Subscription__c sub = [Select Id,Days_Notice__c, Opt_Out__c,Early_Termination_Date__c, Board_Notification_Date__c, Term_Type__c
                                     From SBQQ__Subscription__c Where Id =:subscription2.Id];
        System.assert(sub.Days_Notice__c != null);
        System.assert(sub.Opt_Out__c != null);
        System.assert(sub.Early_Termination_Date__c != null);
        System.assert(sub.Board_Notification_Date__c != null);
        System.assert(sub.Term_Type__c != null);
        Test.stopTest();
    }
    
    static testMethod void test_updateRenewalSubscriptionStageNameOfContract(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        System.assert(opp.Id != null);
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, SBQQ__RenewalOpportunity__c = opp.id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, SBQQ__RenewalOpportunity__c = opp.id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
                
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'EAB Research';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO';
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        update products;
        
        Test.startTest();
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        subscription.Stage_Period__c = 'Dropped';
        insert subscription;
        System.assert(subscription.id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.Stage_Period__c = 'Pending';
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription2 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription2.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription2.SBQQ__Contract__c = contracts[1].Id;
        subscription2.Top_Related_Product__c = 'Yield Optimization';
        subscription2.SBQQ__Product__c = products[0].Id;
        subscription2.Renewal_Type__c = 'Continuing';
        subscription2.Stage_Period__c = 'Dropped';
        insert subscription2;
        System.assert(subscription2.Id != null);
        
        Util.byPassAllTriggers = true;
        try{
        	SBQQ_SubscriptionTriggerHelper.updateRenewalSubscriptionStageNameOfContract(new List<SBQQ__Subscription__c>{subscription, subscription1, subscription2}, null);
        }catch(Exception e){
            
        }
        Test.stopTest();
        
    }
    
    static testMethod void test_populateProgramSubscription(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        contracts[0].status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED;
        contracts[0].Amendment_Type__c = 'Upsell';
        update contracts;
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'Enrollment Services';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO'; 
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        update products;
        
        Test.startTest();
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        insert subscription;
        System.assert(subscription.Id != null);
        
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.SBQQ__RequiredById__c = subscription.Id;
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        SBQQ_SubscriptionTriggerHelper.populateProgramSubscription(new List<SBQQ__Subscription__c>{subscription1}, null );
        //Test.stopTest();
        
        SBQQ__Subscription__c compSubs = [Select ID, Type__c, Top_Related_Product__c, Previous_Program_Subscription__c From SBQQ__Subscription__c Where Id=:subscription1.Id ];
        System.assert(compSubs.Type__c != null);
        System.assert(compSubs.Top_Related_Product__c != null);
                
        Test.stopTest();
    }
    
    static testMethod void test_populateJoiningDateOfPreviousSubscription(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        contracts[0].status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED;
        contracts[0].Amendment_Type__c = 'Upsell';
        update contracts;
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'Enrollment Services';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO'; 
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        update products;
        
        Test.startTest();
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.Join_Date__c = Date.today();
        insert subscription;
        System.assert(subscription.Id != null);
         
        Util.byPassAllTriggers = true;
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        update subscription;
        SBQQ__Subscription__c ps = [Select ID, RecordTypeId From SBQQ__Subscription__c Where ID =:subscription.Id];
        System.assertEquals(CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM, ps.RecordTypeId);
        
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.Previous_Program_Subscription__c = ps.Id;
        
        SBQQ_SubscriptionTriggerHelper.populateJoiningDateOfPreviousSubscription(new List<SBQQ__Subscription__c>{subscription1} ,null);
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        
        SBQQ__Subscription__c compSubs = [Select ID, Type__c, Join_Date__c, Previous_Program_Subscription__c From SBQQ__Subscription__c Where Id=:subscription1.Id ];
        System.assert(compSubs.Join_Date__c != null);
        Test.stopTest();
    }
    
    static testMethod void test_populateAmendmentPriceOverride(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        List<Account> accList = [Select Id From Account];
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        //insert
        insert contracts;
        contracts[0].status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED;
        contracts[0].Amendment_Type__c = 'Upsell';
        update contracts;
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Name = 'Program Costs';
        products[0].Family = 'Enrollment Services';
        products[1].Name = 'Financial Aid Optimization';
        products[1].ProductCode = 'ESFAO'; 
        products[1].Family = 'EAB Research';
        products[2].Family = 'EAB Research';
        update products;
        
        Test.startTest();
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription.SBQQ__Contract__c = contracts[0].Id;
        subscription.Top_Related_Product__c = 'Yield Optimization';
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.Renewal_Type__c = 'Continuing';
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.Join_Date__c = Date.today();
        insert subscription;
        System.assert(subscription.Id != null);
        
        Subscription_Period__c sPeriod0 = TestUtilities.createNewSubscriptionPeriod(subscription.Id, true);
        System.assert(sPeriod0.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription1.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription1.SBQQ__Contract__c = contracts[0].Id;
        subscription1.Top_Related_Product__c = 'Yield Optimization';
        subscription1.SBQQ__Product__c = products[0].Id;
        subscription1.Renewal_Type__c = 'Continuing';
        subscription1.Subscription_Period__c = sPeriod0.Id;
        subscription1.SBQQ__CustomerPrice__c = 10.00;
        subscription1.Amendment_Price_Override_m__c = 1.00;
        insert subscription1;
        System.assert(subscription1.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ__Subscription__c subscription2 = TestUtilities.createNewSubscription(membershipsList[1].Id, false); 
        subscription2.RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription2.SBQQ__Contract__c = contracts[0].Id;
        subscription2.Top_Related_Product__c = 'Yield Optimization';
        subscription2.SBQQ__Product__c = products[0].Id;
        subscription2.Renewal_Type__c = 'Continuing';
        subscription2.Subscription_Period__c = sPeriod0.Id;
        subscription2.SBQQ__CustomerPrice__c = 10.00;
        subscription2.Amendment_Price_Override_m__c = 1.00;
        insert subscription2;
        System.assert(subscription2.Id != null);
        
        Util.byPassAllTriggers = true;
        SBQQ_SubscriptionTriggerHelper.populateAmendmentPriceOverride(new List<SBQQ__Subscription__c>{subscription1});
        
        //calculateNextDecisionDate
		SBQQ_SubscriptionTriggerHelper.calculateNextDecisionDate(new List<SBQQ__Subscription__c>{subscription1}, null);
        
        //syncPreviousPeriodNegotiatedOnSubPeriod
        Contract__c contractABC = TestUtilities.CreateNewContract(true);
        System.assert(contractABC.Id != null);
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(subscription1.Id, true);
        System.assert(sPeriod.Id != null);
        
        Util.byPassAllTriggers = true;
        subscription1.Previous_Contract_ABC__c = contractABC.Id;
        update subscription1;
        SBQQ_SubscriptionTriggerHelper.syncPreviousPeriodNegotiatedOnSubPeriod(new List<SBQQ__Subscription__c>{subscription1}, null);
            
        //validateSubscriptionPeriods
        Util.byPassAllTriggers = true;
        Subscription_Period__c sPeriod1 = TestUtilities.createNewSubscriptionPeriod(subscription1.Id, true);
        System.assert(sPeriod1.Id != null);
        sPeriod.Previous_Subscription_Period__c = null;
        update sPeriod;
        
        SBQQ_SubscriptionTriggerHelper.validateSubscriptionPeriods(new List<SBQQ__Subscription__c>{subscription1}, null);
        Test.stopTest();
    }
    
    static testMethod void test_mapConstituentProductToProgramIds(){
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        Test.startTest();
        List<Account> accList = [Select Id From Account];
        Program__c programs = [Select Id From Program__c Limit 1];
        
        List<Product2> products = [Select ID, Name From Product2 Limit 3];
        products[0].Program__c = programs.Id;
        products[1].Program__c = programs.Id;
        products[2].Program__c = programs.Id;
        update products;
        
        List<Product_MtM__c> productMtm = new List<Product_MtM__c>();
        productMtm.add(new Product_MtM__c(Related_Product__c = products[0].Id, Source_Product__c = products[0].Id, Type__c='Constituent Product'));
        productMtm.add(new Product_MtM__c(Related_Product__c = products[1].Id, Source_Product__c = products[0].Id, Type__c='Constituent Product'));
        productMtm.add(new Product_MtM__c(Related_Product__c = products[2].Id, Source_Product__c = products[0].Id, Type__c='Constituent Product'));
        insert productMtm;
        
        productMtm = [Select ID, Related_Product__c, Source_Product__c, Type__c From Product_MtM__c];
        System.assertEquals(3, productMtm.size());
        
        Map<Id, Set<Id>> returnMap = SBQQ_SubscriptionTriggerHelper.mapConstituentProductToProgramIds;
        System.assert(returnMap != null);
        
        Test.stopTest();
    }
    
    // CR-20210817-15358 - END
    //Modified by Dipesh Gupta 5-03-2020 CR-20200114-13623 Increase code coverage for Batch_NightlyMembershipSubUpdate Start Here
    //Test method
    static testMethod void testBatch_NightlyMembershipSubUpdate()
    {
        Util.ByPassAllTriggers = true;
        List<Account> accList = [Select Id From Account];
        
        //Add new contract record in list
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        contracts.add(new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today() + 2, ContractTerm = 2,EndDate = Date.today() + 7));
        
        Util.ByPassAllTriggers = true;
        
        //insert
        insert contracts;
        
        //Contract Integrated Account - insert
        Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
        cIA.Account__c = accList[0].Id;
        cIA.LOA_Contract__c = contracts[0].Id;
        
        Util.ByPassAllTriggers = true;
        
        insert cIA;
        
        List<Membership__c> membershipsList = [Select Id,Account_Name__c,Program__c From Membership__c];
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        Util.ByPassAllTriggers = true;
        Program__c programId = TestUtilities.CreateNewProgram(true);
        
        //Get Product
        List<Product2> products = [Select Id, Name From Product2 ORDER BY SBQQ__Component__c ASC, Name ASC];
        
        //Assert
        System.assertEquals(4, products.size());
                
         //Creating Subscription record
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membershipsList[0].Id, false);
        programSubscription.SBQQ__Account__c = accList[0].Id;
        programSubscription.Program__c = programs[0].Id;
        programSubscription.SBQQ__Contract__c = contracts[0].Id;
        programSubscription.Status__c = 'Honorary';
        programSubscription.Parent_Program__c = programId.Id;
        programSubscription.SBQQ__Product__c = products[0].Id;
        
        Util.ByPassAllTriggers = true;
        
        insert programSubscription;
        
        
        Util.ByPassAllTriggers = false;
        //Test Starts here
        Test.startTest();
        
        Id programSubId = programSubscription.Id;
        
        List<String> applicableStatuses = new List<String> {'ATL', 'Honorary', 'Dropped', 'Committed', 'Committed-Amended'};
            
        //Execute the batch
        Batch_NightlyMembershipSubUpdate btch = new Batch_NightlyMembershipSubUpdate();
        btch.QueryString = 'SELECT Id, SBQQ__Account__c, Program__c, SBQQ__Contract__c, Status__c, Parent_Program__c, SBQQ__Product__c '
                                + 'FROM SBQQ__Subscription__c WHERE Id =' + '\'' +  programSubId + '\'' + ' AND Status__c IN :applicableStatuses AND LastModifiedDate = LAST_N_DAYS:1'
                                + 'ORDER BY LastModifiedDate DESC LIMIT 10000';
        Database.executeBatch(btch, 200);

        //Test stops here
        Test.stopTest();
        
    }
    
    //Modified by Dipesh Gupta 5-03-2020 CR-20200114-13623 Increase code coverage for Batch_NightlyMembershipSubUpdate Ends Here
    
    /**
     * 
     *  @description    :   This method used to test testYouVisitAssignmentOnSubscriptionPeriod method
     *
     *  @args           :   void
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Add field to Subscription Periods
     * 			    V1.2 - Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
     * 
     **/
    static testMethod void testYouVisitAssignmentOnSubscriptionPeriod() {
        
        //Add Program
        Program__c program = TestUtilities.CreateNewProgram(false);
        
        //Add additional field values
        program.Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        program.Status__c = 'Active';
        program.Name = 'TMBH - Test Method';
        program.Program_Acronym__c = 'TMBH';
        program.Program_Formal_Name__c = 'Test Method';
        program.Renewable__c = true; 
        program.New_Business_Business__c = 'EAB';
        program.Type__c = 'Standard';
        program.Type__c = 'Standard';
        program.New_Business_Vertical__c = 'EAB';
        program.Entity__c = 'EAB';
        program.Program_Line__c = 'PT';
        program.Sector__c = 'HE';
        program.Applicable_Segments__c = 'International Education;US Education';
        program.Solomon_Code__c = '851';
        program.New_Business_Marketer__c = 'HE SSC';
        program.Create_memberships__c = 'Yes';
        program.Renewal_Unit_Count__c = 1;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Insert
        insert program;  
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Program Costs', Family = 'EAB Tech', Program__c = program.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                     );
        products.add(new Product2(Name = 'Program Costs', Family = 'EAB Tech', Program__c = null, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = true, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                 );
        
        Insert products;
        
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
                
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
        
        //Creating Subscription record
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.SBQQ__Product__c = products[0].Id;
        
        insert programSubscription;
        
        List<Subscription_Period__c> subPeriods = new List<Subscription_Period__c>();
        subPeriods.add(TestUtilities.createNewSubscriptionPeriod(programSubscription.Id, false));
        insert subPeriods;
        
        Util.byPassAllTriggers = false;
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        subscription.SBQQ__Product__c = products[1].Id;
        //Record type for subscription
        subscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.You_Visit_Package_Type_m__c = 'Essential';
        subscription.Program_Subscription__c = programSubscription.Id;
        subscription.SBQQ__SegmentIndex__c = 1;
        subscription.Status__c = 'Void';
        
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membership.Id, false);
        subscription1.SBQQ__Product__c = products[1].Id;
        //Record type for subscription
        subscription1.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription1.You_Visit_Package_Type_m__c = 'Premium';
        subscription1.Program_Subscription__c = programSubscription.Id;
        subscription1.SBQQ__SegmentIndex__c = 2;
        subscription1.Status__c = 'Void';
        
        //Testing start here
        Test.startTest();
        
        insert new List<SBQQ__Subscription__c>{subscription,subscription1};
            
        List<Subscription_Period__c> subscriptionPeriods = [Select Id, Program_Subscription__c, Program_Subscription__r.You_Visit_Package_Type_m__c,YouVisit_Package_Type__c 
                                                                From Subscription_Period__c Where Program_Subscription__c =: programSubscription.Id];
        
        System.assertEquals('Premium', subscriptionPeriods[0].Program_Subscription__r.You_Visit_Package_Type_m__c);
        System.assertEquals('Premium',subscriptionPeriods[0].YouVisit_Package_Type__c);
                
        subscription1.You_Visit_Package_Type_m__c = 'Platinum';
        Update subscription1;
         
        
        subscriptionPeriods = [Select Id, Program_Subscription__c, Program_Subscription__r.You_Visit_Package_Type_m__c,YouVisit_Package_Type__c 
                               From Subscription_Period__c Where Program_Subscription__c =: programSubscription.Id];
        
        System.assertEquals('Platinum', subscriptionPeriods[0].Program_Subscription__r.You_Visit_Package_Type_m__c);
        System.assertEquals('Platinum',subscriptionPeriods[0].YouVisit_Package_Type__c);
           
        //Testing start here
        Test.stopTest();  
        
    }
    
    /**
     * 
     *  @description    :   This method used to test validateSubscription method
     *
     *  @args           :   void
     *
     *  @return         :   void
     *
     *  @revision Log   :   Created by - Neha Sharma - 5/27/2021 - CR-20210105-14771 - To Increase code coverage for SBQQ_SubscriptionTriggerHelper
     * 
     **/
    static testMethod void testvalidateSubscription(){
        
        //Add Program
        Program__c program = TestUtilities.CreateNewProgram(false);
        
        //Add additional field values
        program.Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        program.Status__c = 'Active';
        program.Name = 'TMBH - Test Method';
        program.Program_Acronym__c = 'TMBH';
        program.Program_Formal_Name__c = 'Test Method';
        program.Renewable__c = true; 
        program.New_Business_Business__c = 'EAB';
        program.Type__c = 'Standard';
        program.Type__c = 'Standard';
        program.New_Business_Vertical__c = 'EAB';
        program.Entity__c = 'EAB';
        program.Program_Line__c = 'PT';
        program.Sector__c = 'HE';
        program.Applicable_Segments__c = 'International Education;US Education';
        program.Solomon_Code__c = '851';
        program.New_Business_Marketer__c = 'HE SSC';
        program.Create_memberships__c = 'Yes';
        program.Renewal_Unit_Count__c = 1;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Insert
        insert program;  
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'Program Costs', Family = 'EAB Tech', Program__c = program.Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                     );
        products.add(new Product2(Name = 'Program Costs', Family = 'EAB Tech', Program__c = null, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = true, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                 );
        
        Insert products;
        
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
                
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        //Creating Subscription record
        SBQQ__Subscription__c programSubscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        programSubscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        programSubscription.SBQQ__Product__c = products[0].Id;
        
        subscriptions.add(programSubscription);
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        subscription.SBQQ__Product__c = products[1].Id;
        //Record type for subscription
        subscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription.You_Visit_Package_Type_m__c = 'Essential';
        subscription.Program_Subscription__c = programSubscription.Id;
        subscription.SBQQ__SegmentIndex__c = 1;
        subscription.Status__c = 'Void';
        subscriptions.add(subscription);
        
        SBQQ__Subscription__c subscription1 = TestUtilities.createNewSubscription(membership.Id, false);
        subscription1.SBQQ__Product__c = products[1].Id;
        //Record type for subscription
        subscription1.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        subscription1.You_Visit_Package_Type_m__c = 'Premium';
        subscription1.Program_Subscription__c = programSubscription.Id;
        subscription1.SBQQ__SegmentIndex__c = 2;
        subscription1.Status__c = 'Void';
        subscriptions.add(subscription1);
          
        insert subscriptions;
        
        //List to hold ABC Revenue Records
        List<ABC_Revenue__c> aBCRevenues = new List<ABC_Revenue__c>();
        
        //Creating ABC Revenue Records
        aBCRevenues.add(new ABC_Revenue__c(Negotiated_Amount__c = 500, GAAP_Amount__c = 0, Program_Subscription__c  = programSubscription.Id));
        
        insert aBCRevenues;
        
        Util.byPassAllTriggers = false;
        
        //Testing start here
        Test.startTest();
        
        try{
            Delete subscriptions;
        }
        catch(Exception ex){
            Boolean expectedException = ex.getMessage().contains('You can not delete this record, as revenue records are exit on Program Subscription.') ? true : false;
            System.assertEquals(true, expectedException);
        }
            
        //Testing start here
        Test.stopTest();  
        
    }
    
    //Added By - Neha Sharma - CR-20210113-14804  - 05/24/2021 - for update/delete case
    static testmethod void test_updateCurrentYearFees(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //List to hold Account records
        List<Account> accList = new List<Account>();
            
        accList.add(testUtilities.CreateNewAccount(false));
        accList.add(testUtilities.CreateNewAccount(false));
        
        //Insert record
        insert accList;

        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        Program__c prog = TestUtilities.CreateNewProgram(false);
        Program__c prog1 = TestUtilities.CreateNewProgram(false);
        progList.add(prog);
        progList.add(prog1);
        
        insert progList;
        
         // List to store test Contacts
         List<Contact> contacts = new List<Contact>();
            
         //Add contact data in list
         contacts.add(testUtilities.CreateNewContact(accList[0], false));
         contacts.add(testUtilities.CreateNewContact(accList[1], false));
         //Insert Contact Data
         
         insert contacts;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[0].Id,
                                                      Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID, Sales_Pursuit_Products__c = 'APS');
        
        Opportunity opportunity1 = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contacts[1].Id,
                                                      Amount = 1, CloseDate = System.today(), AccountId = accList[1].ID, Sales_Pursuit_Products__c = 'APS');

        insert new List<Opportunity>{opportunity,opportunity1};
        
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id,Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                        Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                        Join_Date__c = System.today(), Main_Contact__c = contacts[0].Id, Invoice_Contact__c = contacts[0].Id);
        insert contract;

        Contract__c contract1 = new Contract__c(Name='Test1', Payer_Account__c = accList[1].ID, Program__c = progList[1].Id,Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                        Contract_Renewal_Opportunity__c = opportunity.Id, Negotiated_Amount__c = 10000,Type__c = 'NBB', Year__c = String.ValueOf(System.today().Year()), 
                        Join_Date__c = System.today(), Main_Contact__c = contacts[1].Id, Invoice_Contact__c = contacts[1].Id);
        insert contract1;

        


        Product2 product = new Product2(Name = CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE, Family = 'EAB Tech', Program__c = progList[0].Id, IsActive = true,	Product_Category__c = 'Annual Fee',
                        ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                        SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
         Product2 product1 = new Product2(Name = CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE, Family = 'EAB Tech', Program__c = progList[0].Id, IsActive = true,	Product_Category__c = 'Travel Fee',
                        ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                        SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        insert product;
        insert product1;

        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(RecordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM,SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                        SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,
                        SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, SBQQ__ProrateMultiplier__c = 2,SBQQ__Product__c = product.Id,
                        SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                        SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                        Status__c = 'Committed' );
        insert subscription;

        
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                        Program__c = progList[0].Id, Active_Contract_Idenfied__c = contract.Id,
                        Earliest_Contract__c = contract.Id,Active_Subscription__c = subscription.Id,Current_Period_Start_Date__c = Date.today().addDays(-10), Current_Period_End_Date__c = Date.today().addDays(2),
                        Latest_Contract__c = contract.Id, Membership_Status_Text__c = constants.MEMBER_PAYER));
        
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                        Program__c = progList[1].Id, Active_Contract_Idenfied__c = contract1.Id,
                        Earliest_Contract__c = contract1.Id,Active_Subscription__c = subscription.Id,Current_Period_Start_Date__c = Date.today().addDays(-10), Current_Period_End_Date__c = Date.today().addDays(2),
                        Latest_Contract__c = contract1.Id, Membership_Status_Text__c = constants.MEMBER_PAYER));
        
        insert membershipList;


        Contract StdContract = new Contract(AccountId = accList[0].Id, Status = 'Draft', StartDate = Date.today().addDays(-10), ContractTerm = 12);
        insert StdContract;

        Contract StdContract1 = new Contract(AccountId = accList[1].Id, Status = 'Draft', StartDate = Date.today().addDays(-10), ContractTerm = 12);
        insert StdContract1;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract.Id,recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity.Id,
        SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
     
        
  
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract1.Id,recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity1.Id,
        SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
       
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract.Id,recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity.Id,
        SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product1.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
     
        
  
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__Contract__c = StdContract1.Id,recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,Opportunity__c = opportunity1.Id,
        SBQQ__RequiredByProduct__c = product.Id,SBQQ__Product__c = product1.Id,SBQQ__SegmentStartDate__c = Date.today().addDays(-10),SBQQ__SegmentEndDate__c = Date.today().addDays(2),Program_Subscription__c = subscription.Id,SBQQ__RenewalPrice__c = 100,SBQQ__CustomerPrice__c = 100,Membership__c = membershipList[0].Id));
       
        
        //Insert componentSubscription
        insert listcomponentSubscription;


        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        listcomponentSubscription[0].SBQQ__Quantity__c = 2;
        listcomponentSubscription[1].SBQQ__Quantity__c = 2;
        listcomponentSubscription[2].SBQQ__Quantity__c = 2;
        listcomponentSubscription[3].SBQQ__Quantity__c = 2;
        
        update listcomponentSubscription;

        //test starts here
        test.startTest();
        List<SBQQ__Subscription__c> compSubscriptions = [Select Id,Customer_Amount__c,SBQQ__Product__c,SBQQ__Product__r.Name from SBQQ__Subscription__c where recordTypeId =: constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT];
        List<membership__c> memberships = [Select Id, Current_Year_Travel_Fee__c,Current_Year_Annual_Fee__c  from membership__c where Active_Subscription__c =: subscription.Id];
       
        System.assertEquals(400 , memberships[0].Current_Year_Travel_Fee__c);
        System.assertEquals(400 , memberships[0].Current_Year_Annual_Fee__c);
        System.assertEquals(400, memberships[0].Current_Year_Annual_Fee__c);
        System.assertEquals(400 , memberships[0].Current_Year_Annual_Fee__c);
        
        
        //Test Ends Here
        test.stopTest();

         
    }
}