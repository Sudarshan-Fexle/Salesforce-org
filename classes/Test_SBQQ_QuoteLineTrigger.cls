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
private class Test_SBQQ_QuoteLineTrigger {
    /**
*  Description     :   Test class to test the functionality of QuoteLine Trigger
*            
*  Create By       :   Subhash Garhwal
*
*  Created Date    :   06/24/2016
*
*  Revision Log    :   V_1.0 - Created - CR-20160414-9762
*            	       V_1.1 - Modified By - Deepak Kumar - 01/16/2018
*        	       V_1.2 - Modified By - Subhash Garhwal - 08/10/2018 - CR-20180607-12271
*		       V_1.3 - Modified By - Mahendra Swarnkar - 11/04/2020 - CR-20200611-14175
*		       V_1.4 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*  Coverage        :    
*
**/
    
    //Setup Test data
    @testSetup static void setupTestData() {
        
        //Set Flag
        Util.BypassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = 'RY';
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        
        programs[0].Large_Contract_Threshold__c =  12;
        programs[1].Large_Contract_Threshold__c =  15;
        programs[2].Large_Contract_Threshold__c =  17;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'Custom Application Marketing', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'ESAM',SBQQ__SortOrder__c = 0,SBQQ__Component__c = true));
       
        //Add new Products in List
        products.add(new Product2(Name = 'New Names', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'ESNN',SBQQ__SortOrder__c = 2,SBQQ__Component__c = true));
        products.add(new Product2(Name = 'Program Costs', Family = 'Enrollment Services', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'Program Costs',SBQQ__SortOrder__c = 4,SBQQ__Component__c = true));
        products.add(new Product2(Name = 'One Point in Time Opt Out Without Penalty Fee', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'One Point in Time Opt Out Without Penalty Fee', Product_Category__c = 'Opt Out', Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                  SBQQ__DefaultQuantity__c = 1));
        products.add(new Product2(Name = 'Implementation Fee', IsActive = true, ProductCode = 'ImplementationFee', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'Implementation Fee', Product_Category__c = 'Implementation Fee', 
                                  SBQQ__DefaultQuantity__c = 1));
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
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
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[3].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
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
        
        //Parent Opportunity
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                        AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_CPQ_RT_DEVELOPER_NAME ORDER BY DeveloperName];
        
        List<RecordType> rdTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                    AND DeveloperName IN : CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES ORDER BY DeveloperName];
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = '0-MQL', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id,Sales_Pursuit_Products__c = 'APS'));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = '0-MQL', CloseDate = System.today(),
                                                RecordTypeId = recordTypes[0].Id,Sales_Pursuit_Products__c = 'APS'));
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = '0-MQL', CloseDate = System.today(),
                                                RecordTypeId = rdTypes[0].Id,Sales_Pursuit_Products__c = 'APS'));    
        
        parentOpportunities.add(new Opportunity(Name = 'Will Auto Populate', AccountId = acc.Id, StageName = '0-MQL', CloseDate = System.today(),
                                                RecordTypeId = rdTypes[0].Id,Sales_Pursuit_Products__c = 'APS'));

        //Set Opportunity trigger flag (We don't need to execute opportunity trigger)
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        Util.BypassAllTriggers = true;
       
        //Insert List of Opportunity
        insert parentOpportunities;
        
    }
    
    //Test method
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2 ORDER BY CreatedDate  ASC];
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY CreatedDate  ASC];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true,
                                      SBQQ__Opportunity2__c = parentOpportunities[0].Id,
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, 
                                      SBQQ__Opportunity2__c = parentOpportunities[0].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                      SBQQ__Opportunity2__c = parentOpportunities[1].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        
        
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Test Start from here
        Test.startTest();
        
        //Insert list of Quote
        insert quotes;
        
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        
                
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        
        
        
        //Insert list of Quote
        insert subProposalLines;
        
        //Test Stop Here
        Test.stopTest();
        
        //Set of proposal Id
        Set<Id> setProposalIds = new Set<Id>();
        
        for(SBQQ__Quoteline__c qLine: subProposalLines){
            setProposalIds.add(qLine.SBQQ__Quote__c);
        }
        
        Sched_QuoteLinesTrigger schedQuoteLines = new Sched_QuoteLinesTrigger(setProposalIds, subProposalLines,false,false,false,false, true, false);
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, schedQuoteLines);
        
        //schedQuoteLines.scheduleQuotelineTrigger(setProposalIds, subProposalLines,true,false,false,false, true, false);
        //boolean BYPASS_SORT_ORDER_METHOD, boolean BYPASS_UPDATEPREVIOUSSEGMENTPRICE, boolean BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE, boolean executeSyncProgramOpportunitiesLogic, boolean IsInsert, boolean isUpdate
        
        mainProposalLine.SBQQ__Quantity__c = 2;
        mainProposalLine.Calculator_Error_Message__c = 'Error';
        //update Quoteline
        update mainProposalLine;
        
        List<SBQQ__QuoteLine__c> quoteLine = [Select Id, Calculator_Error_Message__c, SBQQ__RequiredBy__c, SBQQ__PackageTotal__c, SBQQ__UpgradedSubscription__c From SBQQ__QuoteLine__c];
        Map<Id, SBQQ__QuoteLine__c> mapQuoteLine = new Map<Id, SBQQ__QuoteLine__c>([Select Id, Calculator_Error_Message__c, SBQQ__RequiredBy__c, SBQQ__PackageTotal__c, SBQQ__UpgradedSubscription__c From SBQQ__QuoteLine__c]);
        
        //Delete Quote line
        //delete subProposalLines[2];
        
        
    }
    
    /**
    * Description  : Test method for update Quote line
    **/ 
    
    //Test method
    static testMethod void TestQuoteLineUpdate() {
        
        //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
    
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500));
        
        //Test Start from here
        Test.startTest();
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;
        
        //Test Stop Here
        Test.stopTest();
        
        //Query through the Opportunity records to get the details about program Opportunities
        List<Opportunity> programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        //System.assertEquals(1, programOpps.size());
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        //System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
        
        //Delete Quote line
        //delete quoteLines[0];
        
        //After deleting on Quote line
        //Query through the Opportunity records to get the details about program Opportunities
        programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        //System.assertEquals(1, programOpps.size());
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        //System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
    
    }
    
    /**
     * Description  : Test method for update Quote line
     **/ 
     
    //Test method
    static testMethod void TestQuoteLineUpdate1() {
       
       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
         //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
       
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id));
        
        
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
    
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Modified By - Subhash Garhwal - 08/10/2018 - CR-20180607-12271
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__StartDate__c = Date.today(), SBQQ__NetPrice__c = 100, X1st_Year_Type__c = 'Annual'));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__StartDate__c = Date.today(), SBQQ__NetPrice__c = 500, X1st_Year_Type__c = 'Travel'));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__StartDate__c = Date.today(), SBQQ__NetPrice__c = 500, X1st_Year_Type__c = 'Implementation'));
        
        //Test Start from here
        Test.startTest();
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;
                     
        //Test Stop Here
        Test.stopTest();
        
        //Modified By - Subhash Garhwal - 08/10/2018 - CR-20180607-12271
        //Executin Batch 
        Batch_UpdateFirstYearFees b = new Batch_UpdateFirstYearFees();
        Database.executeBatch(b, 5);
        
        //Query through the Opportunity records to get the details about program Opportunities
        List<Opportunity> programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[0].Id];

        //Commented By -- Subhash Garhwal -- 6/26/2017 -- Main class code comment
        //Assert
        //System.assertEquals(1, programOpps.size());
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ACTIVE_IN_SLOWTRACK, programOpps[0].StageName);
        //System.assertEquals(programOpps[0].Parent_Opportunity__r.CloseDate, programOpps[0].Closedate);
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE, programOpps[0].Parent_Opportunity__r.StageName);
        
        Util.BypassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Update Quote Lines
        quoteLines[0].SBQQ__Product__c = products[1].Id;
        update quoteLines;
        
        //Query through the Opportunity records to get the details about program Opportunities
        programOpps = [Select Id, StageName, AccountId, Source_Stage__c, Closedate, Parent_Opportunity__r.StageName,
                                                Parent_Opportunity__r.CloseDate, Amount From Opportunity Where Parent_Opportunity__c =: parentOpportunities[1].Id];
        
        //Assert
        System.assertEquals(0, programOpps.size());
    }
    
    //Test method
    static testMethod void Test_updateThresholdValueOnOpportunity() {
       
       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode,SBQQ__SortOrder__c From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[2].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[2].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[3].Id));
        
        
        
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Insert list of Quote
        insert quotes;
    
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100 ));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500));
                
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;

        //Test Start from here
        Test.startTest();
    
        //Get Parent Opportunities
        List<Opportunity> Opportunities = [Select Id, Name, AccountId, StageName, CloseDate, Program_Threshold_Value__c, RecordTypeId From Opportunity];

        //Test Stop Here
        Test.stopTest();     
      
    }
    static testMethod void  Test_checkErrorsOnQuoteLine() {

       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
         //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
       
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id,
                        Standard_Price_Percentage__c = 0));
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id,
                        Standard_Price_Percentage__c = 10));
        
        //Set Opportunity flag
        Util.BypassAllTriggers = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
    
        //Insert list of Quote
        insert quotes;    
    
        Util.BypassAllTriggers = false;
        
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 100, ConfirmedBigDealNotification__c = true,
                    SBQQ__ComponentTotal__c  = 9999999));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500, ConfirmedBigDealNotification__c = true,
                    SBQQ__ComponentTotal__c  = 9999999,SBQQ__Existing__c= false,SBQQ__Renewal__c = true));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500, ConfirmedBigDealNotification__c = true,
                    SBQQ__Existing__c= false,SBQQ__Renewal__c = true));
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500, ConfirmedBigDealNotification__c = true,
                    SBQQ__Existing__c= false,SBQQ__Renewal__c = true, SBQQ__SubscriptionCategory__c = CPQConstants.QUOTE_LINE_PROGRAM_SUBSCRIPTIONCATEGORY_ANNUAL_FEE));
        //Execute triggers
        Util.BypassAllTriggers = false;

      //Tesing start here
      Test.startTest();
          
          //Insert
          insert quoteLines;
      //Testing stop here
      Test.stopTest();
  }
    
    //Added by - Deepak Kumawat - 01/12/2018 
    /*static testMethod void  myUnitTest1() {

       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Account
        Account acc = new Account(Name = 'Test Account');

        //Insert
        insert acc;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        //Added the records into list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = acc.Id, SBQQ__Opportunity__c = parentOpportunities[0].Id));
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = acc.Id, SBQQ__Opportunity__c = parentOpportunities[0].Id));    
        
        //Insert the contracts list
        insert contracts;
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[0].Id, 
                                      SBQQ__MasterContract__c = contracts[0].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Amendment', SBQQ__Primary__c = false, SBQQ__Opportunity2__c = parentOpportunities[0].Id,
                                      Standard_Price_Percentage__c = 0, SBQQ__MasterContract__c = contracts[0].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, SBQQ__Opportunity2__c = parentOpportunities[1].Id,
                                      Standard_Price_Percentage__c = 10, SBQQ__MasterContract__c = contracts[0].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        //Set Opportunity flag
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
    
        //Insert list of Quote
        insert quotes;   
        
        //List of Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,SBQQ__ListPrice__c = 0, 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed'));
        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 0,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed'));        

        //Insert
        insert subscriptions; 
        
        //Create the test data for QuoteLine/ Propopsal Line
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100, 
                                                              ConfirmedBigDealNotification__c = true, SBQQ__ComponentTotal__c  = 9999999, SBQQ__RenewedSubscription__c = subscriptions[0].Id, 
                                                              SBQQ__SegmentKey__c = 'test123', SBQQ__SegmentLabel__c = 'testLabel2', Product_Category__c = 'Opt Out', SBQQ__SegmentIndex__c = 1,
                                                              SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test');
        
    
        //Insert the quoteLine 
        insert quoteLine;
        
        Util.BypassAllTriggers = false;
  
        //List of quote line item to insert
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        //Add new Quote lines n list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100, ConfirmedBigDealNotification__c = true,
                    SBQQ__ComponentTotal__c  = 9999999, SBQQ__RenewedSubscription__c = subscriptions[0].Id, SBQQ__SegmentKey__c = 'test1234', SBQQ__SegmentLabel__c = 'testLabel0',
                    Product_Category__c = 'Opt Out', SBQQ__RequiredBy__c = quoteLine.Id, SBQQ__SegmentIndex__c = 2, SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test'));
        
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[2].Id, SBQQ__NetPrice__c = 500, ConfirmedBigDealNotification__c = true,
                    SBQQ__ComponentTotal__c  = 9999999,SBQQ__Existing__c= false,SBQQ__Renewal__c = true, SBQQ__RenewedSubscription__c = subscriptions[1].Id, 
                    SBQQ__SegmentKey__c = 'test12345', SBQQ__SegmentLabel__c = 'testLabel1', SBQQ__SegmentIndex__c = 3, SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test'));
        
        //Test Starts from here
        Test.startTest();
        
        //Execute triggers
        Util.BypassAllTriggers = false;
        
        //Insert
        insert quoteLines;
        
        //Testing stop here
        Test.stopTest();
    }*/
    
    static testMethod void testpopulateESLinesOnAmendment() {
       
       //Bypass Dupeblocker     
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Get Products
        List<Product2> products = [Select Id, Name, Family, Program__c, IsActive, ProductCode From Product2 ORDER BY CreatedDate  ASC];
        
        //Get Product Option
        List<SBQQ__ProductOption__c> productsOptions = [Select Id, Name From SBQQ__ProductOption__c ORDER BY CreatedDate  ASC];
        
        //Get Parent Opportunities
        List<Opportunity> parentOpportunities = [Select Id, Name, AccountId, StageName, CloseDate, RecordTypeId From Opportunity];
        
        //Get Account
        List<Account> acc = [Select Id From Account];
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        //Added the records into list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = acc[0].Id, SBQQ__Opportunity__c = parentOpportunities[0].Id));    
        
        //Insert the contracts list
        insert contracts;
        
        
        //List of Quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add new quote record in list
        quotes.add(new SBQQ__Quote__c(SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true,
                                      SBQQ__Opportunity2__c = parentOpportunities[0].Id, SBQQ__MasterContract__c = contracts[0].Id, 
                                      SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
      
        //Set Opportunity flag
        //Util.BypassAllTriggers = false;
        
        //Insert list of Quote
        insert quotes;
    
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,SBQQ__SegmentIndex__c =10,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List',
                                                                     SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productsOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,SBQQ__Existing__c = True,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Existing__c = false,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List',
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Existing__c = false,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List',
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Existing__c = false,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productsOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', 
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        
        //Test Start from here
        Test.startTest();
        
        //Set Opportunity flag
        Util.BypassAllTriggers = false;
        
        //Insert list of Quote
        insert subProposalLines;
        
        //Test Stop Here
        Test.stopTest();
        
    	//Modified By - Rajeev Jain - CPQ Release 25 - 01/17/2021
        List<SBQQ__QuoteLine__c> quoteLines = [Select Id, Opportunity_Contracted__c, SBQQ__Existing__c, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Number__c, SBQQ__Quantity__c, SBQQ__ProductOption__c,
                                               SBQQ__RequiredBy__c, SBQQ__StartDate__c, SBQQ__EndDate__c,Calculator_Error_Message__c, SBQQ__PackageTotal__c, SBQQ__UpgradedSubscription__c From SBQQ__QuoteLine__c Where Id IN: subProposalLines ORDER BY CreatedDate  ASC];
        
        Map<Id, SBQQ__QuoteLine__c> mapQuoteLine = new Map<Id, SBQQ__QuoteLine__c>([Select Id, SBQQ__Existing__c, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Number__c, SBQQ__Quantity__c, SBQQ__ProductOption__c,
                                               SBQQ__RequiredBy__c, SBQQ__StartDate__c, SBQQ__EndDate__c,Calculator_Error_Message__c, SBQQ__PackageTotal__c, SBQQ__UpgradedSubscription__c From SBQQ__QuoteLine__c  Where Id IN: subProposalLines ORDER BY CreatedDate  ASC]);
        
        Map<Id, SBQQ__Quote__c> mapQuote = new Map<Id, SBQQ__Quote__c>([Select Id, SBQQ__MasterContract__c From SBQQ__Quote__c Where Id IN: quotes]);
        
        
        SBQQ_QuoteLineTriggerHelper.populateESLinesOnAmendment(quoteLines);
        //SBQQ_QuoteLineTriggerHelper.checkErrorsOnQuoteLine(quoteLines);
        //SBQQ_QuoteLineTriggerHelper.validateLargeDeals(quoteLines);
        SBQQ_QuoteLineTriggerHelper.getQuoteLineUniqueKeyMap(quoteLines, mapQuote, true);
        SBQQ_QuoteLineTriggerHelper.updateProSubscriptionStatusForAmendment(quoteLines, mapQuoteLine);
        SBQQ_QuoteLineTriggerHelper.checkRenewalInitialPrice(quoteLines, mapQuoteLine);
        
    }
    
    static testMethod void testvalidateGradeCriteriaCommittedTermLength(){
        
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

        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'TMBH - Test Method', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productOptions;
        
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
        
        //Insert
        insert contact;
        
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        
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
        
        //Insert the contract ABC
        insert contracts;
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-Exploring';
         eABInitOpp.Main_Contact__c = contact.Id;
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     Early_Termination_Date__c = System.today().addYears(2).addDays(12),
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'
                                                                     );
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
       
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    Early_Termination_Date__c = System.today().addYears(1),
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
        
        test.startTest();
        
        Util.BypassAllTriggers = false;
        
        //Insert list of Quote
        insert subProposalLines;
        
        subProposalLines[0].Penalty_Fee_Amount__c = 100;
        subProposalLines[0].SBQQ__AdditionalDiscountAmount__c = 10;
        
        //Update
        update subProposalLines;
        
        test.stopTest();
    }
    
    static testMethod void testValidateESAMAndESOAMProducts(){
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
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
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Paper_New_Names__c = 100,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Paper_New_Names__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Paper_New_Names__c = 100,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        //Insert list of Quote
        insert subProposalLines;
        
        subProposalLines[0].Paper_New_Names__c = 200;
        subProposalLines[1].Paper_New_Names__c = 200;
        subProposalLines[2].Paper_New_Names__c = 200;
            
        //Update
        update subProposalLines;
        
        test.stopTest(); 
        
    }
    
    static testMethod void testOptOut(){
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
        
        products.add(new Product2(Name = 'One Point in Time Opt Out Without Penalty Fee', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'One Point in Time Opt Out Without Penalty Fee', Product_Category__c = 'Opt Out', Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                  SBQQ__DefaultQuantity__c = 1));
        
        //Add new Opt-out Product
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'TMBH - Test Method', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
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
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(32);
        eABInitOpp.StageName = 'Prospact'; //'Pending';
	eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        Util.BypassAllTriggers = true;
       
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     Early_Termination_Date__c = System.today().addYears(2).addDays(12),
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'
                                                                     );
        
        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        //Insert list of Quote
        insert mainProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 3, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    Early_Termination_Date__c = System.today().addYears(1),SBQQ__NetPrice__c = 100,ConfirmedBigDealNotification__c = true,SBQQ__ComponentTotal__c  = 9999999,
                                                    /*SBQQ__RenewedSubscription__c = subscriptions[0].Id,*/Product_Category__c = 'Opt Out',SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        /*SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[3].Id, SBQQ__NetPrice__c = 100, 
                                                              ConfirmedBigDealNotification__c = true, SBQQ__ComponentTotal__c  = 9999999, SBQQ__RenewedSubscription__c = subscriptions[0].Id, 
                                                              SBQQ__SegmentKey__c = 'test123', SBQQ__SegmentLabel__c = 'testLabel2', Product_Category__c = 'Opt Out', SBQQ__SegmentIndex__c = 1,
                                                              SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test'
        
        */
        
             
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[0].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));
		
    	
        
        //Insert list of Quote
        insert subProposalLines;
         
        test.stopTest();
        
        subProposalLines[0].Penalty_Fee_Amount__c = 100;
        subProposalLines[0].SBQQ__AdditionalDiscountAmount__c = 10;
        
        //Update
        update subProposalLines;
  
    }
    static testMethod void test_blankOptOutAndEarlyTerminationDateOnMainProposalLine(){      
        
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
        //Add new Products in List
        products.add(new Product2(Name = 'Annual Fee', IsActive = true, ProductCode = 'AnnualFee', SBQQ__Component__c = true,
                                  Product_Category__c = 'Annual Fee', Program_Name_Member_Facing__c = 'Annual Fee',
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
                
    }
     static testMethod void test_updatePreviousSegmentPrice(){
         
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
        
        products.add(new Product2(Name = 'One Point in Time Opt Out Without Penalty Fee', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,
                                  Program_Name_Member_Facing__c = 'One Point in Time Opt Out Without Penalty Fee', Product_Category__c = 'Opt Out', Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                  SBQQ__DefaultQuantity__c = 1));
        
        //Add new Opt-out Product
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert
        features.add(new SBQQ__ProductFeature__c(Name = 'TMBH - Test Method', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        //Add records in list to insert
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[2].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Insert
        insert productOptions;
        
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
        
        //Insert
        insert contact;
        
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        
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
        
        //Insert the contract ABC
        insert contracts;
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = 'Prospact';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
                
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'
                                                                     );
        
        //Test Start here 
        Test.startTest();
         
        Util.BypassAllTriggers = false;
                
        //Insert list of Quote
        insert mainProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        //Add Proposal lines in list
        //Add Annual Fee products
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 3, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Program_or_Component__c = 'Annual Fee',
                                                    Penalty_Fee_Amount__c  = 0, SBQQ__AdditionalDiscountAmount__c = 0,
                                                    SBQQ__NetPrice__c = 100,ConfirmedBigDealNotification__c = true,SBQQ__ComponentTotal__c  = 9999999,
                                                    SBQQ__CustomerPrice__c = 0, Calculator_Error_Message__c = 'Test'
                                                    ));
        
        //Insert list of Quote
        insert subProposalLines;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
         
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
         
        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                       
        //Insert
        insert subscriptions;        
        System.assertEquals(2,subscriptions.size());
         
        //Test Start here 
        Test.stopTest();
        
        Util.byPassAllTriggers = false;
         
        //List to hold the Subscription Period records
        List<Subscription_Period__c> listSusbcriptionPeriod  = new List<Subscription_Period__c>();
        
        //Add the new 
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today(), 
                                                                Stage__c = 'Pending', Opt_Out_Date__c =  Date.Today() ));
        listSusbcriptionPeriod.add(new  Subscription_Period__c(Program_Subscription__c = subscriptions[0].Id, Period_Start_Date__c = Date.Today() + 1, 
                                                                Stage__c = 'ATL', Opt_Out_Date__c =  Date.Today()));                                                     
        
        
        

        
        //Insert the listOfSubscriptionPeriod
        insert listSusbcriptionPeriod;
        
        listSusbcriptionPeriod[0].Negotiated_Amount_Period__c = 2000;
        listSusbcriptionPeriod[0].Period_Start_Date__c = Date.Today().addDays(1);

        update listSusbcriptionPeriod[0];

		
		
        
    }
    
    //test method - Added by Mahendra Swarnkar - 12/27/2019
    static testMethod void testpopulatePrevContractLastYearTotalQuantityAndValue(){
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
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
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    Paper_New_Names__c = 100,
                                                    Previous_Period_Negotiated__c = 1111, Is_Eligible_For_Approval__c = true, 
          											Total_Paper_E_Only_Quantity__c = 1111, E_Only_New_Names_CSV__c = '1111', 
                                                    Paper_New_Names_CSV__c = '1111', E_Only_PRE_Names_CSV__c = '1111', Paper_PRE_Names_CSV__c = '1111', 
                                                    Paper_Inquiry_Pool_CSV__c = '1111', E_Only_Inquiry_Pool_CSV__c = '1111', 
		  											Paper_Client_Provided_Inquiries_CSV__c = '1111', E_Only_Client_Provided_Inquiries_CSV__c = '1111',
                                                    Paper_EAB_Generated_Inquiries_CSV__c = '1111', E_Only_EAB_Generated_Inquiries_CSV__c = '1111', 
                                                    Paper_Transfer_Marketing_CSV__c = '1111', E_only_Transfer_Marketing_CSV__c = '1111', 
		  											Paper_Quantity_Fulfillment_CSV__c = '1111', E_Only_Quantity_Fulfillment_CSV__c = '1111',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    Paper_New_Names__c = 100,
                                                    Previous_Period_Negotiated__c = 1111, Is_Eligible_For_Approval__c = true, 
          											Total_Paper_E_Only_Quantity__c = 1111, E_Only_New_Names_CSV__c = '1111', 
                                                    Paper_New_Names_CSV__c = '1111', E_Only_PRE_Names_CSV__c = '1111', Paper_PRE_Names_CSV__c = '1111', 
                                                    Paper_Inquiry_Pool_CSV__c = '1111', E_Only_Inquiry_Pool_CSV__c = '1111', 
		  											Paper_Client_Provided_Inquiries_CSV__c = '1111', E_Only_Client_Provided_Inquiries_CSV__c = '1111',
                                                    Paper_EAB_Generated_Inquiries_CSV__c = '1111', E_Only_EAB_Generated_Inquiries_CSV__c = '1111', 
                                                    Paper_Transfer_Marketing_CSV__c = '1111', E_only_Transfer_Marketing_CSV__c = '1111', 
		  											Paper_Quantity_Fulfillment_CSV__c = '1111', E_Only_Quantity_Fulfillment_CSV__c = '1111',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
         
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    Paper_New_Names__c = 100,
                                                    Previous_Period_Negotiated__c = 1111, Is_Eligible_For_Approval__c = true, 
          											Total_Paper_E_Only_Quantity__c = 1111, E_Only_New_Names_CSV__c = '1111', 
                                                    Paper_New_Names_CSV__c = '1111', E_Only_PRE_Names_CSV__c = '1111', Paper_PRE_Names_CSV__c = '1111', 
                                                    Paper_Inquiry_Pool_CSV__c = '1111', E_Only_Inquiry_Pool_CSV__c = '1111', 
		  											Paper_Client_Provided_Inquiries_CSV__c = '1111', E_Only_Client_Provided_Inquiries_CSV__c = '1111',
                                                    Paper_EAB_Generated_Inquiries_CSV__c = '1111', E_Only_EAB_Generated_Inquiries_CSV__c = '1111', 
                                                    Paper_Transfer_Marketing_CSV__c = '1111', E_only_Transfer_Marketing_CSV__c = '1111', 
		  											Paper_Quantity_Fulfillment_CSV__c = '1111', E_Only_Quantity_Fulfillment_CSV__c = '1111',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        //Insert list of Quote
        insert subProposalLines;
        
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  /*recordTypes[0].Id*/, 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        Util.BypassAllTriggers = true;
        //insert
        insert subscriptions; 
        
        subProposalLines[0].Paper_New_Names__c = 200;
        subProposalLines[1].Paper_New_Names__c = 200;
        subProposalLines[2].Paper_New_Names__c = 200;
        subProposalLines[0].SBQQ__RenewedSubscription__c  = subscriptions[0].Id;
        subProposalLines[1].SBQQ__RenewedSubscription__c  = subscriptions[0].Id;
        subProposalLines[2].SBQQ__RenewedSubscription__c  = subscriptions[0].Id;
            
        Util.BypassAllTriggers = false;
        //Update
        update subProposalLines;
        
        test.stopTest();
        
        //Added by Mahendra Swarnakr - 12/27/2019
        SBQQ_QuoteLineTriggerHelper.populatePrevContractLastYearTotalQuantityAndValue(subProposalLines);
		

    }
    
     /**
     * 
     *  @description    :   This method used to test populateCSVFieldsOnMainProposalLines method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/20/2020  by Subhash Garhwal
     * 
     **/
    static testMethod void test_populateCSVFieldsOnMainProposalLines()
    {
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,Legacy_Migrated_ES_Client__c = 'Migrated',
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
        test.startTest();
        //Util.BypassAllTriggers = false;
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        
        //Insert list of Quote
        insert midProposalLine;
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
         
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        Util.BypassAllTriggers = false;
        
        //test.startTest();
        
        //Insert list of Quote
        insert subProposalLines;
        
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM , 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        Util.BypassAllTriggers = true;
        //insert
        insert subscriptions; 

      test.stopTest();  
        
    }
    
    /**
     * 
     *  @description    :   This method used to test updateProrateMultiplier method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/19/2020  by Subhash Garhwal
     * 
     **/
    static testMethod void test_updateProrateMultiplier()
    {
        
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
                                  Program_Name_Member_Facing__c = 'New Names', Allow_Subscription_Adjustments__c = true,Default_Prorate_Multiplier_to_1__c = true,
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Program Costs', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = true,Default_Prorate_Multiplier_to_1__c  = true,
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
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
        test.startTest();
        //Util.BypassAllTriggers = false;
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,SBQQ__Discount__c = 32.98,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__Discount__c = 32.98,
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__Discount__c = 32.98,
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
         
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        Util.BypassAllTriggers = false;
        
        //test.startTest();
        
        //Insert list of Quote
        insert subProposalLines;
        
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  /*recordTypes[0].Id*/, 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        Util.BypassAllTriggers = true;
        //insert
        insert subscriptions; 

      test.stopTest();
    }
    
     /**
     * 
     *  @description    :   This method used to test blankOptOutAndEarlyTerminationDateOnMainProposalLine method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/20/2020  by Subhash Garhwal
     * 
     **/
    static testMethod void test_blankOptOutAndEarlyTerminationDateOnMainProposalLine2()
    {
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
        products.add(new Product2(Name = 'New Names', IsActive = true, ProductCode = 'ESNN', SBQQ__Component__c = false,
                                  Program_Name_Member_Facing__c = 'New Names', Allow_Subscription_Adjustments__c = true,Default_Prorate_Multiplier_to_1__c = true,
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        //Add new Products in List
        products.add(new Product2(Name = 'Program Costs', IsActive = true, ProductCode = 'Program Costs', SBQQ__Component__c = false,Default_Prorate_Multiplier_to_1__c  = true,
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
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
          //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  /*recordTypes[0].Id*/, 
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        Util.BypassAllTriggers = true;
        //insert
        insert subscriptions; 
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
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
        test.startTest();
        //Util.BypassAllTriggers = false;
        //Insert list of Quote
        insert mainProposalLine;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c midProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                    SBQQ__RequiredBy__c = mainProposalLine.Id, SBQQ__ProductOption__c = productOptions[0].Id,
                                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,SBQQ__Discount__c = 32.98,
                                                                    SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5,
                                                                    SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');

        
        //Insert list of Quote
        insert midProposalLine;
        
        
        //List to insert Annual Fee and Trevel fee Proposal Lines
        List<SBQQ__QuoteLine__c> subProposalLines = new List<SBQQ__QuoteLine__c>();
        
        //Add Proposal lines in list
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    SBQQ__RequiredBy__c = midProposalLine.Id, SBQQ__PricingMethod__c = 'List',
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__Discount__c = 32.98,
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 1,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 1',
                                                    SBQQ__StartDate__c = System.today(),SBQQ__EndDate__c = System.today().addYears(1)));
        
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 1, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    /*SBQQ__RequiredBy__c = midProposalLine.Id,*/ SBQQ__PricingMethod__c = 'List',SBQQ__RenewedSubscription__c = subscriptions[0].Id,
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__Discount__c = 32.98,
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 2,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 2',
                                                    SBQQ__StartDate__c = System.today().addYears(1).addDays(1),SBQQ__EndDate__c = System.today().addYears(2)));
         
        subProposalLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 1,
                                                    SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 0.5861, SBQQ__ProductOption__c = productOptions[1].Id,
                                                    /*SBQQ__RequiredBy__c = midProposalLine.Id,*/ SBQQ__PricingMethod__c = 'List',SBQQ__RenewedSubscription__c = subscriptions[0].Id,
                                                    Annual_Increase__c = 5,SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                    SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__SegmentIndex__c = 3,
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
                                                    SBQQ__StartDate__c = System.today().addYears(2).addDays(1),SBQQ__EndDate__c = System.today().addYears(3)));

        Util.BypassAllTriggers = false;
        
        //test.startTest();
        
        //Insert list of Quote
        insert subProposalLines;
        
      test.stopTest();
        
    }

    /**
     * 
     *  @description    :   This method used to test validateBHDRonProposal method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - Mahendra Swarnkar - 11/04/2020 - CR-20200611-14175
     * 
     **/
    static testMethod void test_validateBHDRonProposal()
    {
        Util.byPassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values for BHAP
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[0].Status__c = 'Active';
        programs[0].Name = 'BHAP - Test Method';
        programs[0].Program_Acronym__c = 'BHAP';
        programs[0].Program_Formal_Name__c = 'Test Method';
        programs[0].Renewable__c = true; 
        programs[0].New_Business_Business__c = 'Royall';
        programs[0].New_Business_Vertical__c = 'Royall';
        programs[0].Entity__c = 'EAB';
        programs[0].Program_Line__c = 'Royall';
        programs[0].Sector__c = 'Education';
        programs[0].Applicable_Segments__c = 'US Education';
        programs[0].Create_memberships__c = 'YES';
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values for BHDR
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[1].Status__c = 'Active';
        programs[1].Name = 'BHDR - Test Method';
        programs[1].Program_Acronym__c = 'BHDR';
        programs[1].Program_Formal_Name__c = 'Test Method';
        programs[1].Renewable__c = true; 
        programs[1].New_Business_Business__c = 'Royall';
        programs[1].New_Business_Vertical__c = 'Royall';
        programs[1].Entity__c = 'EAB';
        programs[1].Program_Line__c = 'Royall';
        programs[1].Sector__c = 'Education';
        programs[1].Applicable_Segments__c = 'US Education';
        programs[1].Create_memberships__c = 'NO';
        
        //Insert
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'BHAP - Student Success Collaborative (SSC) - Academic Planning', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'BHAP', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Collaborative (SSC) - Academic Planning',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1, Allow_Subscription_Adjustments__c = true,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        
        //Add new Products in List
        products.add(new Product2(Name = 'BHDR - Degree Rules Integration', IsActive = true, ProductCode = 'BHDR', SBQQ__Component__c = false, Program__c = programs[1].Id,
                                  Program_Name_Member_Facing__c = 'Degree Rules Integration', Allow_Subscription_Adjustments__c = true,Default_Prorate_Multiplier_to_1__c = true,
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //List to insert Feature
        List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        
        //Add Feature record in list to insert Mid Proposal line
        features.add(new SBQQ__ProductFeature__c(Name = 'Student Success Collaborative (SSC) - Academic Planning', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        
        //Add Feature record in list to insert Sub Proposal line
        features.add(new SBQQ__ProductFeature__c(Name = 'Degree Rules Integration', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[1].Id));
        
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert features;
        
        //List to insert Product Options
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        
        //Add records in list to insert Mid Proposal Line
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[0].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //Add records in list to insert Sub Proposal Line
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[1].Id, SBQQ__OptionalSKU__c = products[1].Id,
                                                      SBQQ__Number__c = 13, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[1].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true));
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert productOptions;
        
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
        
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addDays(1);
        eABInitOpp.StageName = '0-MQL';
        eABInitOpp.Main_Contact__c = contact.Id;
        
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
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id,
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        List<SBQQ__QuoteLine__c> mainProposalLine = new List<SBQQ__QuoteLine__c>(); 
        mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHDR : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        test.startTest();
        
        try{
            //Insert list of Quote
            insert mainProposalLine;
        }
        catch(Exception ex){
            System.assertEquals(true, ex.getMessage().contains('The Institution don\'t have an active BHAP membership'));           
        }
        
        try{
            
            //Add Proposal Lines under the Proposal
            mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                        SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                        SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAP : 12 : NBB',
                                                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                                );
            
            //Add Proposal Lines under the Proposal
            mainProposalLine.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 11,
                                                        SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                        SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHDR : 12 : NBB',
                                                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List')
                                 );
            //Insert list of Quote
            insert mainProposalLine;
        }
        catch(Exception ex){
            System.assertEquals(true, ex.getMessage().contains('The proposal already includes the BHDR product.'));           
        }
        
        test.stopTest();
        
    }
    
    static testMethod void test_populateStartDateOnImplementationFee(){
        
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        // create quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__StartDate__c = date.today();
        quote.SBQQ__EndDate__c = date.today()+30;
        quotes.add(quote);
        insert quotes;
        System.assert(quotes.size() == 1);
        
        //List to hold Proposal Line Group
        List<SBQQ__QuoteLineGroup__c> proposalLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        //Add proposal line group records into list
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-5), SBQQ__EndDate__c = System.Today().addDays(-3), SBQQ__Quote__c = quotes[0].Id));
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = null, SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
      	proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-3), SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
        insert proposalLineGroup;
        
        // query product
        List<Product2> products = [Select Id, Name, Family, ProductCode From Product2];
        System.assert(products.size() > 0);
        products[0].ProductCode = 'ImplementationFee';
        products[1].ProductCode = 'ImplementationFeeSS';
        products[2].ProductCode = 'ImplementationFee';
        products[3].ProductCode = 'ImplementationFeeSS';
        update products;
        
        Util.BypassAllTriggers = true;
        // Create quoteLine
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c ql1 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql1.SBQQ__Product__c = products[0].Id;
        ql1.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql1.SBQQ__SegmentIndex__c = 2;
        quoteLines.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql2.SBQQ__Product__c = products[0].Id;
        ql2.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql2.SBQQ__SegmentIndex__c = 2;
        quoteLines.add(ql2);
        
        SBQQ__QuoteLine__c ql3 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql3.SBQQ__Product__c = products[1].Id;
        ql3.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql3.SBQQ__SegmentIndex__c = 2;
        quoteLines.add(ql3);
        
        SBQQ__QuoteLine__c ql4 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql4.SBQQ__Product__c = products[1].Id;
        ql4.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql4.SBQQ__SegmentIndex__c = 2;
        quoteLines.add(ql4);
        
        Test.startTest();
        SBQQ_QuoteLineTriggerHelper.populateStartDateOnImplementationFee(quoteLines ,null);
        insert quoteLines;
        Test.stopTest();
        
        List<SBQQ__QuoteLine__c> qls = [Select Id, SBQQ__StartDate__c From SBQQ__QuoteLine__c Where SBQQ__StartDate__c != null];
        System.assert(qls.size() > 0);
    }
    
    static testMethod void test_updateFieldsForMainProductLines(){
        
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        // query opportunity
        List<Opportunity> opportunities = [Select Id, Name From Opportunity];
        System.assert(opportunities.size() > 0);
        // query product
        List<Product2> products = [Select Id, Name, Family, ProductCode From Product2];
        System.assert(products.size() > 0);
        products[0].ProductCode = 'ESOAM';
        products[0].SBQQ__Component__c = false;
        products[1].ProductCode = 'ESAM';
        products[1].SBQQ__Component__c = false;
        products[2].ProductCode = 'ESPAA';
        products[2].SBQQ__Component__c = false;
        products[3].ProductCode = 'ESSEOM';
        products[3].SBQQ__Component__c = false;
        update products;
        
         // create quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(TestUtilities.createNewSbqqQuote(true));
        System.assert(quotes.size() == 1);

        //List to hold Proposal Line Group
        List<SBQQ__QuoteLineGroup__c> proposalLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        //Add proposal line group records into list
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-5), SBQQ__EndDate__c = System.Today().addDays(-3), SBQQ__Quote__c = quotes[0].Id));
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = null, SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
      	proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-3), SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
        insert proposalLineGroup;
        
        Util.BypassAllTriggers = true;
        // Create quoteLine
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c ql1 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql1.SBQQ__Product__c = products[0].Id;
        ql1.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql1.SBQQ__SegmentIndex__c = 2;
        ql1.SBQQ__ListPrice__c = 500;
        quoteLines.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql2.SBQQ__Product__c = products[0].Id;
        ql2.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql2.SBQQ__SegmentIndex__c = 2;
        ql2.SBQQ__ListPrice__c = 500;
        quoteLines.add(ql2);
        
        SBQQ__QuoteLine__c ql3 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql3.SBQQ__Product__c = products[1].Id;
        ql3.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql3.SBQQ__SegmentIndex__c = 2;
        ql3.SBQQ__ListPrice__c = 500;
        quoteLines.add(ql3);
        
        SBQQ__QuoteLine__c ql4 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql4.SBQQ__Product__c = products[2].Id;
        ql4.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql4.SBQQ__SegmentIndex__c = 2;
        ql4.SBQQ__ListPrice__c = 500;
        quoteLines.add(ql4);
        
        Test.startTest();
        SBQQ_QuoteLineTriggerHelper.updateFieldsForMainProductLines(quoteLines);
        insert quoteLines;
        Test.stopTest();
        
        List<SBQQ__QuoteLine__c> qls = [Select Id, SBQQ__CustomerPrice__c From SBQQ__QuoteLine__c Where SBQQ__CustomerPrice__c = 0];
        System.assert(qls.size() > 0);
        
    }
	
    static testMethod void test_populatePrevContractLastYearTotalQuantityAndValue(){
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
		
		//List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        insert programs;      
        System.assert(programs.size() > 0);
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        insert accounts;
        System.assert(accounts.size() > 0);
        
        Membership__c membership = TestUtilities.CreateNewMembership(accounts[0].Id, programs[0].Id, true);
        System.assert(membership.Id != null);
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, true);
        System.assert(subscription.Id != null);
        
        // query opportunity
        List<Opportunity> opportunities = [Select Id, Name From Opportunity];
        System.assert(opportunities.size() > 0);
        // query product
        List<Product2> products = [Select Id, Name, Family, ProductCode From Product2];
        System.assert(products.size() > 0);
        products[0].ProductCode = 'ESOAM';
        products[0].SBQQ__Component__c = false;
        products[1].ProductCode = 'ESAM';
        products[1].SBQQ__Component__c = false;
        products[2].ProductCode = 'ESPAA';
        products[2].SBQQ__Component__c = false;
        products[3].ProductCode = 'ESSEOM';
        products[3].SBQQ__Component__c = false;
        update products;
        
         // create quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(TestUtilities.createNewSbqqQuote(true));
        System.assert(quotes.size() == 1);

        //List to hold Proposal Line Group
        List<SBQQ__QuoteLineGroup__c> proposalLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        //Add proposal line group records into list
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-5), SBQQ__EndDate__c = System.Today().addDays(-3), SBQQ__Quote__c = quotes[0].Id));
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = null, SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
      	proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-3), SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
        insert proposalLineGroup;
        
        Util.BypassAllTriggers = true;
        // Create quoteLine
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c ql1 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql1.SBQQ__Product__c = products[0].Id;
        ql1.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql1.SBQQ__SegmentIndex__c = 2;
        ql1.SBQQ__ListPrice__c = 500;
        ql1.SBQQ__RenewedSubscription__c = subscription.Id;
        quoteLines.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql2.SBQQ__Product__c = products[0].Id;
        ql2.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql2.SBQQ__SegmentIndex__c = 2;
        ql2.SBQQ__ListPrice__c = 500;
        ql2.SBQQ__RenewedSubscription__c = subscription.Id;
        quoteLines.add(ql2);
        
        SBQQ__QuoteLine__c ql3 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql3.SBQQ__Product__c = products[1].Id;
        ql3.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql3.SBQQ__SegmentIndex__c = 2;
        ql3.SBQQ__ListPrice__c = 500;
        ql3.SBQQ__RenewedSubscription__c = subscription.Id;
        quoteLines.add(ql3);
        
        SBQQ__QuoteLine__c ql4 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql4.SBQQ__Product__c = products[2].Id;
        ql4.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql4.SBQQ__SegmentIndex__c = 2;
        ql4.SBQQ__ListPrice__c = 500;
        ql4.SBQQ__RenewedSubscription__c = subscription.Id;
        quoteLines.add(ql4);
        insert quoteLines;
        Test.startTest();
        Util.BypassAllTriggers = true;
        List<SBQQ__QuoteLine__c> qLines = [Select Id, SBQQ__RequiredBy__c,SBQQ__Product__c, SBQQ__Quote__c, SBQQ__RenewedSubscription__c, Opportunity_Contracted__c From SBQQ__QuoteLine__c];
        System.assert(qLines.size() == 4);
        qLines[3].SBQQ__RequiredBy__c = qLines[2].Id;
        qLines[2].SBQQ__RequiredBy__c = qLines[1].Id;
        qLines[0].Paper_New_Names_CSV__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"111|111|111","requiredByProductId":"'+qLines[2].SBQQ__Product__c+'"}';
        qLines[1].Paper_New_Names_CSV__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"111|111|111","requiredByProductId":"'+qLines[2].SBQQ__Product__c+'"}';
        qLines[2].Paper_New_Names_CSV__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"111|111|111","requiredByProductId":"'+qLines[2].SBQQ__Product__c+'"}';
        qLines[3].Paper_New_Names_CSV__c = '{"csvFieldName":"Paper_New_Names__c","yearValues":"111|111|111","requiredByProductId":"'+qLines[2].SBQQ__Product__c+'"}';
        
        Update qLines;
        
        SBQQ_QuoteLineTriggerHelper.populatePrevContractLastYearTotalQuantityAndValue(qLines);
        Test.stopTest();
    }
    
    static testMethod void test_populateRenewalPriceFields(){
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        insert programs;      
        System.assert(programs.size() > 0);
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        insert accounts;
        System.assert(accounts.size() > 0);
        
        // query product
        List<Product2> products = [Select Id, Name, Family, ProductCode From Product2];
        System.assert(products.size() > 0);
        products[0].ProductCode = 'ESOAM';
        products[0].SBQQ__Component__c = false;
        products[0].Product_Category__c = 'Annual Fee';
        products[1].ProductCode = 'ESAM';
        products[1].SBQQ__Component__c = false;
        products[1].Product_Category__c = 'Annual Fee';
        products[2].ProductCode = 'ESPAA';
        products[2].SBQQ__Component__c = false;
        products[2].Product_Category__c = 'Annual Fee';
        products[3].ProductCode = 'Additional Discount';
        products[3].SBQQ__Component__c = false;
        products[3].Product_Category__c = 'Annual Fee';
        update products;
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  

        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM , SBQQ__RenewalPrice__c = 200,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, SBQQ__Product__c = products[3].Id,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Account__c = accounts[0].Id, Program__c = programs[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM  , SBQQ__RenewalPrice__c = 300,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, SBQQ__Product__c = products[3].Id,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        Util.BypassAllTriggers = true;
        //insert
        insert subscriptions; 
        
         // query opportunity
        List<Opportunity> opportunities = [Select Id, Name From Opportunity];
        System.assert(opportunities.size() > 0);
        
        
         // create quote
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Type__c = CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL;
        quotes.add(quote);
        insert quotes;
        
        System.assert(quotes.size() == 1);

        //List to hold Proposal Line Group
        List<SBQQ__QuoteLineGroup__c> proposalLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        //Add proposal line group records into list
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-5), SBQQ__EndDate__c = System.Today().addDays(-3), SBQQ__Quote__c = quotes[0].Id));
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = null, SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
      	proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-3), SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[0].Id));
        insert proposalLineGroup;
        
        Util.BypassAllTriggers = true;
        // Create quoteLine
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c ql1 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql1.SBQQ__Product__c = products[0].Id;
        ql1.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql1.SBQQ__SegmentIndex__c = 1;
        ql1.SBQQ__ListPrice__c = 500;
        ql1.SBQQ__RenewedSubscription__c = subscriptions[0].Id;
        ql1.Product_Category__c = 'Annual Fee';
        quoteLines.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql2.SBQQ__Product__c = products[0].Id;
        ql2.SBQQ__Group__c = proposalLineGroup[0].Id;
        ql2.SBQQ__SegmentIndex__c = 1;
        ql2.SBQQ__ListPrice__c = 500;
        ql2.SBQQ__RenewedSubscription__c = subscriptions[0].Id;
        ql2.Product_Category__c = 'Annual Fee';
        quoteLines.add(ql2);
        
        SBQQ__QuoteLine__c ql3 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql3.SBQQ__Product__c = products[1].Id;
        ql3.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql3.SBQQ__SegmentIndex__c = 1;
        ql3.SBQQ__ListPrice__c = 500;
        ql3.SBQQ__RenewedSubscription__c = subscriptions[1].Id;
        ql3.Product_Category__c = 'Annual Fee';
        quoteLines.add(ql3);
        
        SBQQ__QuoteLine__c ql4 = TestUtilities.createNewQuoteLine(quotes[0].Id, false);
        ql4.SBQQ__Product__c = products[2].Id;
        ql4.SBQQ__Group__c = proposalLineGroup[1].Id;
        ql4.SBQQ__SegmentIndex__c = 1;
        ql4.SBQQ__ListPrice__c = 500;
        ql4.SBQQ__RenewedSubscription__c = subscriptions[1].Id;
        ql4.Product_Category__c = 'Annual Fee';
        quoteLines.add(ql4);
        insert quoteLines;
        Test.startTest();
        
        Util.BypassAllTriggers = true;
        List<SBQQ__QuoteLine__c> qLines = [Select Id, SBQQ__RequiredBy__c,SBQQ__Product__c, SBQQ__Quote__c, SBQQ__RenewedSubscription__c, Opportunity_Contracted__c, Proposal_Type__c,
                                           SBQQ__SegmentIndex__c, Product_Category__c, SBQQ__SpecialPriceType__c
                                           From SBQQ__QuoteLine__c];
        System.assert(qLines.size() == 4);
        qLines[3].SBQQ__RequiredBy__c = qLines[2].Id;
        qLines[2].SBQQ__RequiredBy__c = qLines[1].Id;
        qLines[1].SBQQ__RequiredBy__c = qLines[0].Id;
        update qLines;
        
        //Sched_QuoteLinesTrigger.quoteLineTriggerFromScheduler = true;
        SBQQ_QuoteLineTriggerHelper.populateRenewalPriceFields(qLines, null, null, true, false);
        Test.stopTest();
        
    }
}