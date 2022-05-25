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
private class Test_SubscriptionAdjustmentHelper {
        
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
        programs[0].Name = 'ESAM - Test Method';
        programs[0].Program_Acronym__c = 'ESAM';
        programs[0].Program_Formal_Name__c = 'Test Method';
        programs[0].Renewable__c = true; 
        programs[0].New_Business_Business__c = 'Royall';
        //programs[0].Type__c = 'Standard';
        programs[0].New_Business_Vertical__c = 'Royall';
        programs[0].Entity__c = 'EAB';
        programs[0].Program_Line__c = 'Royall';
        programs[0].Sector__c = 'Education';
        programs[0].Applicable_Segments__c = 'US Education';
        //programs[0].Solomon_Code__c = '851';
        //programs[0].New_Business_Marketer__c = 'HE SSC';
        programs[0].Create_memberships__c = 'NO';
        //programs[0].Renewal_Unit_Count__c = 1;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'Custom Application Marketing', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'ESAM', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Custom Application Marketing',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1, Allow_Subscription_Adjustments__c = true,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'New Names', IsActive = true, ProductCode = 'ESNN', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'New Names', Allow_Subscription_Adjustments__c = true,
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Program Costs', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'Program Costs',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert Mid Proposal line
        features.add(new SBQQ__ProductFeature__c(Name = 'Custom Application Marketing', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Add Feature record in list to insert Sub Proposal line
        features.add(new SBQQ__ProductFeature__c(Name = 'New Names', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[1].Id));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert Mid Proposal Line
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Add records in list to insert Sub Proposal Line
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 13, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert productOptions;
        
        //List to insert Product Options
        List<SBQQ__ConfigurationAttribute__c> configAttribute = new List<SBQQ__ConfigurationAttribute__c>();
        
        configAttribute.add(new SBQQ__ConfigurationAttribute__c(Name = 'Paper New Names' ,SBQQ__Product__c = products[0].Id, 
                                                                CSV_Map_Product__c = products[1].Id, SBQQ__Feature__c = features[0].Id,
                                                                CSV_Map_Field__c = 'Paper_New_Names_CSV__c', SBQQ__TargetField__c = 'Paper_New_Names__c',
                                                                RecordTypeId = Schema.SObjectType.SBQQ__ConfigurationAttribute__c.getRecordTypeInfosByName().get('Attribute Map').getRecordTypeId()
                                                               ));
        
        configAttribute.add(new SBQQ__ConfigurationAttribute__c(Name = 'Paper New Names' ,SBQQ__Product__c = products[1].Id, 
                                                                CSV_Map_Product__c = products[2].Id, SBQQ__Feature__c = features[1].Id,
                                                                CSV_Map_Field__c = 'Paper_New_Names_CSV__c', SBQQ__TargetField__c = 'Paper_New_Names__c',
                                                                RecordTypeId = Schema.SObjectType.SBQQ__ConfigurationAttribute__c.getRecordTypeInfosByName().get('Attribute Map').getRecordTypeId()
                                                               ));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert configAttribute;
        
        //Account
        Account acc = new Account(Name = 'Test AAccount');
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert acc;
        
        //Account
        Account account = new Account(Name = 'Test BAccount');
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert account;
        
        //SOQL over the opportunity Record Type
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = acc.Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert
        insert contact;
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = acc.Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert IBS
        insert invoices;
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Add record to list
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = acc.Id,
                                       Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Year with Opt Out'));
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = acc.Id,
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
    
    //Modified By - Mahendra Swarnakar - 07/19/2021 - CR-20210719-15297
    //Test method, un-comment the method.
    static testmethod void myUnitTest(){
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
        List<Product2> products = [Select Id, Name From Product2 ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(3, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c  From SBQQ__ProductOption__c ORDER BY CreatedDate  ASC];
        
        //Assert
        System.assertEquals(2, productsOptions.size());
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(2);
        eABInitOpp.StageName = '0-MQL';
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
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert midProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
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
        eABInitOpp.Contract_Signature_Date__c = Date.Today();
        eABInitOpp.SBQQ__Contracted__c = true;
        

        //Bypass
        Util.BypassAllTriggers = true;
        
        update eABInitOpp;
       
        //Testing stop here
        Test.Stoptest();
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id, SBQQ__Product__c, Program_Subscription__r.SBQQ__RequiredByProduct__c, 
                                                            SBQQ__RequiredByProduct__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__TerminatedDate__c  
                                                            From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Program' ];
        
        //Assert
        System.assertEquals(5, programSubscriptions.size());
        
        //List to hold Contract ABC
        List<Contract__c> contractABCs = [Select Id, RecordTypeId From Contract__c];
        
        // Insert componentSubscription
        List<RecordType> compRecordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT];
        
        List<SBQQ__Subscription__c> compSubs = new List<SBQQ__Subscription__c>();
        compSubs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,Program_Subscription__c = programSubscriptions[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = compRecordTypes[0].Id,SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        insert compSubs;
        
        //Get Subscriptions
        List<SBQQ__Subscription__c> componentSubscriptions = [Select Id, SBQQ__StartDate__c, Program_Subscription__c, SBQQ__EndDate__c, SBQQ__TerminatedDate__c  From SBQQ__Subscription__c Where RecordType.DeveloperName = 'Component' ]; 
        
        //Assert
        System.assertEquals(1, componentSubscriptions.size());
        
        //Add one parent program subscription to the program subscription.
        
        //Get Record Type
		Id ProgramSubscriptionRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');

        SBQQ__Subscription__c progSub = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = ProgramSubscriptionRecordType,
                                                    SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 0, 
                                                    SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert progSub;
        
        programSubscriptions[0].SBQQ__Product__c = products[1].Id;
        programSubscriptions[0].SBQQ__RequiredByProduct__c = products[0].Id;  //SBQQ__Product__c=product[1]
        programSubscriptions[0].Program_Subscription__c = progSub.Id;
        programSubscriptions[0].SBQQ__SegmentIndex__c = 10;
        programSubscriptions[0].Type__c = 'Amendment - Re-engagement';
        programSubscriptions[0].SBQQ__TerminatedDate__c = null;
        update programSubscriptions;
        
        // insert subscription period
        TestUtilities.createNewSubscriptionPeriod(programSubscriptions[0].Id, true);
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listOfSubscriptionPeriod = [Select Id, Program_Subscription__r.SBQQ__RequiredByProduct__c,
                                                                 Program_Subscription__r.Program_Subscription__c, Segment_Index__c
                                                                 From Subscription_Period__c Where  Program_Subscription__c =: programSubscriptions[0].Id];
        
        //Assert
        System.assertEquals(1, listOfSubscriptionPeriod.size());
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //update
        listOfSubscriptionPeriod[0].Segment_Index__c  = 10;
        update listOfSubscriptionPeriod;
        
        //List to hold the Subscription Period records
        List<Subscription_Adjustment__c> listOfSubscriptionAdjustment = new List<Subscription_Adjustment__c>();
        
        listOfSubscriptionAdjustment.add(new Subscription_Adjustment__c(Subscription_Period__c = listOfSubscriptionPeriod[0].Id, Type__c = 'Upsell', 
                                                                        Status__c = 'Draft', Discount_Requested__c = 'No', Paper__c = 100,
                                                                        E_Only__c = 100, Include_Media_cost__c = 'Yes', Program_Cost_Per_Thousand__c = 0,
                                                                        Postage_Cost_Per_Thousand__c = 0, Media_Cost_Per_Thousand__c = 0, Media_Cost__c = 0,
                                                                        Postage_Cost__c = 0, Program_Cost__c = 0,
                                                                        RecordTypeId = Schema.SObjectType.Subscription_Adjustment__c.getRecordTypeInfosByName().get('Request').getRecordTypeId()));
        
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert
        insert listOfSubscriptionAdjustment;
        
        listOfSubscriptionAdjustment[0].Paper__c = 1;
        listOfSubscriptionAdjustment[0].E_Only__c = 1;
        listOfSubscriptionAdjustment[0].Media_Cost__c = 1;
        listOfSubscriptionAdjustment[0].Postage_Cost__c = 1;
        listOfSubscriptionAdjustment[0].Program_Cost__c = 1;
        listOfSubscriptionAdjustment[0].Program_Cost_Per_Thousand__c = 1;
        listOfSubscriptionAdjustment[0].Postage_Cost_Per_Thousand__c = 1;
        listOfSubscriptionAdjustment[0].Media_Cost_Per_Thousand__c = 1;
        
        Util.byPassAllTriggers = false;
        SubscriptionAdjustmentHelper.hasExecutedCloneCompSub = false;
        
        //Update
        Update listOfSubscriptionAdjustment;
    }
    //Test method
    static testMethod void myUnitTest1() {
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
        List<Product2> products = [Select Id, Name From Product2 ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(3, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c  From SBQQ__ProductOption__c ORDER BY CreatedDate  ASC];
        
        //Assert
        System.assertEquals(2, productsOptions.size());
        
        List<SBQQ__ConfigurationAttribute__c> configAttributes = [Select Id , Name, SBQQ__Product__c From SBQQ__ConfigurationAttribute__c ORDER BY CreatedDate ASC];
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(2);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contacts[0].Id;
        eABInitOpp.Sales_Pursuit_Products__c = 'APS';
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
        //Standard Contract
        Contract contract = testUtilities.createNewStandardContract(accounts[0].Id, false);
        insert contract;
        
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
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert midProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert subProposalLines;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c progSub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert progSub1;
        
        SBQQ__Subscription__c progSub2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    Program_Subscription__c = progSub1.Id, SBQQ__Contract__c = contract.Id, SBQQ__Account__c = accounts[0].Id,
													SBQQ__Product__c = products[1].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__RequiredByProduct__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert progSub2;
        
        SBQQ__Subscription__c compSub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, Program_Subscription__c = progSub2.Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Component').getRecordTypeId(),
                                                    SBQQ__RequiredByProduct__c = products[1].Id, SBQQ__SegmentIndex__c = 10, SBQQ__Product__c = products[2].Id,
                                                    SBQQ__Contract__c = contract.Id, SBQQ__Account__c = accounts[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today());
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert compSub1;
        
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        
        Subscription_Period__c subPeriod = new Subscription_Period__c(Program_Subscription__c = progSub2.Id, Period_Start_Date__c = Date.Today(), 
                                                                      Period_End_Date__c = Date.Today() + 5, Stage__c = 'ATL', Segment_Index__c = 10, 
                                                                      Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id);
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert subPeriod;
        
        
        Subscription_Adjustment__c subAdjustment = new Subscription_Adjustment__c(Subscription_Period__c = subPeriod.Id, Type__c = 'Upsell', 
                                                                        Status__c = 'Draft', Discount_Requested__c = 'No', Paper__c = 100,
                                                                        E_Only__c = 100, Include_Media_cost__c = 'Yes',Program_Cost_Per_Thousand__c = 0,
                                                                        Postage_Cost_Per_Thousand__c = 0, Media_Cost_Per_Thousand__c = 0, Media_Cost__c = 0,
                                                                        Postage_Cost__c = 0, Program_Cost__c = 0,
                                                                        RecordTypeId = Schema.SObjectType.Subscription_Adjustment__c.getRecordTypeInfosByName().get('Request').getRecordTypeId());
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert
        insert subAdjustment;      
            
        subAdjustment.Paper__c = 1;
        subAdjustment.E_Only__c = 1;
        subAdjustment.Media_Cost__c = 1;
        subAdjustment.Postage_Cost__c = 1;
        subAdjustment.Program_Cost__c = 1;
        subAdjustment.Program_Cost_Per_Thousand__c = 1;
        subAdjustment.Postage_Cost_Per_Thousand__c = 1;
        subAdjustment.Media_Cost_Per_Thousand__c = 1;
                
        
        Util.byPassAllTriggers = false;
        SubscriptionAdjustmentHelper.hasExecutedCloneCompSub = false;
        
        //Update
        Update subAdjustment;        
        
    }
    
    // Code coverage increase starts  here
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
        List<Product2> products = [Select Id, Name From Product2 ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(3, products.size());
        
        //Get Program
        List<Program__c> programs = [select Id From Program__c];
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c  From SBQQ__ProductOption__c ORDER BY CreatedDate  ASC];
        
        //Assert
        System.assertEquals(2, productsOptions.size());
        
        List<SBQQ__ConfigurationAttribute__c> configAttributes = [Select Id , Name, SBQQ__Product__c, SBQQ__TargetField__c From SBQQ__ConfigurationAttribute__c ORDER BY CreatedDate ASC];
        for(SBQQ__ConfigurationAttribute__c ca: configAttributes){
            ca.SBQQ__TargetField__c = 'Paper_New_Names_CSV__c';
            ca.CSV_Map_Field__c = 'Paper_New_Names__c';
        }
        update configAttributes;
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(2);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contacts[0].Id;
        eABInitOpp.Sales_Pursuit_Products__c = 'APS';
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
        //Standard Contract
        Contract contract = testUtilities.createNewStandardContract(accounts[0].Id, false);
        insert contract;
        
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
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert midProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert subProposalLines;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c progSub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Paper_New_Names_CSV_m__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"4|4|4|4|4|4|4|4|4|4","requiredByProductId":"01t2K000008XOgVQAW"}');
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert progSub1;
        
        SBQQ__Subscription__c progSub2 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                    Program_Subscription__c = progSub1.Id, SBQQ__Contract__c = contract.Id, SBQQ__Account__c = accounts[0].Id,
													SBQQ__Product__c = products[1].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__RequiredByProduct__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Paper_New_Names_CSV_m__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"4324|4324|4324","requiredByProductId":"01t2K000008XOgVQAW"}');
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert progSub2;
        
        SBQQ__Subscription__c compSub1 = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, Program_Subscription__c = progSub2.Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Component').getRecordTypeId(),
                                                    SBQQ__RequiredByProduct__c = products[1].Id, SBQQ__SegmentIndex__c = 10, SBQQ__Product__c = products[2].Id,
                                                    SBQQ__Contract__c = contract.Id, SBQQ__Account__c = accounts[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(),Paper_New_Names_CSV_m__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"56|56|56|56|56","requiredByProductId":"01t2K000006GX38QAG"}');
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert compSub1;
        
        List<User> usrs = [Select Id, Name From User Order By Name ASC Limit 2];
        
        Subscription_Period__c subPeriod = new Subscription_Period__c(Program_Subscription__c = progSub2.Id, Period_Start_Date__c = Date.Today(), 
                                                                      Period_End_Date__c = Date.Today() + 5, Stage__c = 'ATL', Segment_Index__c = 10, 
                                                                      Opt_Out_Date__c = Date.today(), Renewal_Owner__c = usrs[0].Id, Research_Strategic_Leader__c = usrs[0].Id);
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert subPeriod;
        
        
        Subscription_Adjustment__c subAdjustment = new Subscription_Adjustment__c(Subscription_Period__c = subPeriod.Id, Type__c = 'Upsell', 
                                                                        Status__c = 'Draft', Discount_Requested__c = 'No', Paper__c = 100,
                                                                        E_Only__c = 100, Include_Media_cost__c = 'Yes',Program_Cost_Per_Thousand__c = 0,
                                                                        Postage_Cost_Per_Thousand__c = 0, Media_Cost_Per_Thousand__c = 0, Media_Cost__c = 0,
                                                                        Postage_Cost__c = 0, Program_Cost__c = 0,
                                                                        RecordTypeId = Schema.SObjectType.Subscription_Adjustment__c.getRecordTypeInfosByName().get('Request').getRecordTypeId());
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert
        insert subAdjustment;      
    }
}