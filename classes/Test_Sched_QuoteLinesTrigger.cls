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
private class Test_Sched_QuoteLinesTrigger {
    /**
*  Description     :   Test class to test the functionality of Sched-QuoteLine
*            
*  Create By       :   Subhash Garhwal
*
*  Created Date    :   06/24/2016
*
*  Revision Log    :   V_1.0 - Created - CR-20160414-9762
*                      V_1.1 - Modified By - Deepak Kumar - 01/16/2018
*                      V_1.2 - Modified By - Subhash Garhwal - 08/10/2018 - CR-20180607-12271
*		       V_1.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*
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
                                                RecordTypeId = recordTypes[0].Id, Sales_Pursuit_Products__c = 'APS'));
        
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
        
        System.debug('@@@@midProposalLine' +midProposalLine);
        
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
                                                    SBQQ__SegmentKey__c = '1521788947795', SBQQ__SegmentLabel__c = 'Year 3',
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
        
		
       
    }
}