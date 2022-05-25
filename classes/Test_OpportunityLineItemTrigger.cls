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
@isTest(seeAllData = false)
private class Test_OpportunityLineItemTrigger 
{
   /**
    *  Description     :   Test class to test the functionality of OpportunityLineItemTrigger Trigger
    *            
    *  Create By       :   Subhash Garhwal
    *
    *  Created Date    :   07/11/2016
    *
    *  Revision Log    :   V_1.0 - Created 
    *		       :   V_1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    *		       :   V_1.2 - Modified By - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - Test Class Fixes
    *  Coverage        :   V_1.0 - 100% 
    *
    **/
    
    //Modified By - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - Test Class Fixes
    static testMethod void myUnitTest() 
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
                                  ProductCode = 'PTPRO'));
        
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[2].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO'));
        
        //Insert
        insert products;
        
        //Added By - Nikita Kumari - 08/10/2021 - CR-20211005-15489
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        //Create new account
        Account acc = new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' );
        Insert acc;
        
        //SOQL over the opportunity Record Type
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = acc.Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Insert
        insert contact;
        
        //Std Price Book Id
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = products[0].Id, UnitPrice = 10.00, IsActive = true);
        insert standardPrice;
        
        //Price Book
        PriceBook2 cPB = new PriceBook2 (Name='custom priceBook',Description = 'test',IsActive = true);
        
        //Insert
        insert cPB;
        
        //Insert test data of price  book entry
        PricebookEntry CustomPrice = new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = cPB.Id, UnitPrice = 12.00, IsActive = true);
        insert CustomPrice;
        //Added By - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - end
        
        //Parent Opportunity
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true AND DeveloperName = 'BI_Marketing'];        
        //List of Opportunity for Test 
        List<Opportunity> parentOpportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Modified By - Nikita Sharma  - 08/10/2021 - CR-20211005-15489 - Test class fixes (july)
        //Add Parent (Contract LOA) opportunities in list
        parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', Name = 'Will Auto Populate', AccountId = acc.Id,StageName = '0-Exploring', SBQQ__Renewal__c = true, CloseDate = System.today().addMonths(1),
                                                RecordTypeId = recordTypes[0].Id,Main_Contact__c = contact.Id,pricebook2Id = cPB.Id));
        
        parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS', Name = 'Will Auto Populate', AccountId = acc.Id, StageName = '0-Exploring', SBQQ__Renewal__c = true, CloseDate = System.today().addMonths(1),
                                                RecordTypeId = recordTypes[0].Id,Main_Contact__c = contact.Id,pricebook2Id = cPB.Id));
        
        //Modified By - Nikita Sharma  - 08/10/2021 - CR-20211005-15489 - Test class fixes (july) - end
        //Insert List of Opportunity
        insert parentOpportunities;
        
        //Added By - Nikita Kumari - 08/10/2021 - CR-20211005-15489
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = parentOpportunities[0].Id, 
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = acc.Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = cPB.Id , SBQQ__PricebookId__c= cPB.Id));
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,SBQQ__CustomerPrice__c = 90,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Added By - Nikita Kumari - 08/10/2021 - CR-20210706-15276 - end
        
        
        //Test start here
        Test.startTest();
        
        //Execute trigger
        Util.byPassAllTriggers = false;
        
        //Comented By - Nikita Kumari - 08/10/2021 - Moved this part of code above with modifications.
        /* //Insert Test data of Price book
        PriceBook2 pB = new PriceBook2 (Name='Standard priceBook',Description = 'test');
        
        //Insert
        insert pB;
        
        //Std Price Book Id
        Id pricebookId = Test.getStandardPricebookId();
        
        //List of PriceBookEntry
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        
        //Insert test data of price  book entry
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pricebookId,Isactive = true, UnitPrice = 20.00));
        priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pB.Id,
        UnitPrice = 20.00,UseStandardPrice = false, Isactive = true));
        //insert
        insert priceBookEntries;
        */
        //Comented By - Nikita Kumari - 08/10/2021 - end
        
        //modified By - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - added SBQQ__QuoteLine__c
        //Test data of opportunity line item
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = CustomPrice.Id, Quantity = 1,
                                                                  UnitPrice = CustomPrice.UnitPrice, ServiceDate = System.today(),SBQQ__QuoteLine__c = mainProposalLine.Id);
        //Insert OpportunityLine Item
        insert oppLineItem;
        
        //Query Program opportunity created after insert Opportunity Line Item insert
        List<Opportunity> opportunity = [Select Id, Amount, OwnerId, AccountId, Probability, StageName, Source_Stage__c, Parent_Opportunity__c,
                                         Program__c, CloseDate, RecordTypeId from Opportunity where Parent_Opportunity__c =: parentOpportunities[0].Id];
        
        //Assert
        //System.assertEquals(1,opportunity.size());
        //System.assertEquals(0,opportunity[0].Amount);
        //System.assertEquals(acc.Id,opportunity[0].AccountId);
        //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_PENDING,opportunity[0].StageName);
        //System.assertEquals(products[0].Program__c,opportunity[0].Program__c);
        //System.assertEquals(System.today(),opportunity[0].CloseDate);
        
        //Test stop
        Test.stopTest(); 
        //Added By - Nikita Kumari - 08/10/2021 - CR-20211005-15489
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals('Sched_validateUnitPriceWithCustomerPrice', asyncApexJob[0].ApexClass.Name);
        //Added By - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - end
    }
    
    //Commented by - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - Refactring - same method is implemented above 
    //Test repeated opportunity line item
    /*static testMethod void myUnitTest1() 
    {
    //Bypass Dupeblocker
    Util.IsTest(true);
    
    //Bypassing Triggers so then test data can be created easily
    Util.byPassAllTriggers = true;
    
    //Flag for triggers: this is just a test, don't do crazy things.
    Util.isTesting = true;
    
    //List to insert Program records
    List<Program__c> programs = new List<Program__c>();
    
    //Add Program Record in list
    programs.add(TestUtilities.CreateNewProgram(false));
    programs.add(TestUtilities.CreateNewProgram(false));
    programs.add(TestUtilities.CreateNewProgram(false));
    
    //Add additional field values
    programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
    programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
    programs[2].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
    
    //Insert
    insert programs;
    
    //List of Product
    List<Product2> products = new List<Product2>();
    
    //Add new Products in List
    products.add(new Product2(Name = 'RI Product', Family = 'RI', Program__c = programs[0].Id, IsActive = true,
    ProductCode = 'RIPRO'));
    
    products.add(new Product2(Name = 'PT Product', Family = 'PT', Program__c = programs[1].Id, IsActive = true,
    ProductCode = 'PTPRO'));
    
    products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[2].Id,
    IsActive = true, ProductCode = 'ConsultingPRO'));
    
    //Insert
    insert products;
    
    //Parent Opportunity
    List<RecordType> recordTypes = [Select Id,Name from RecordType where SobjectType = 'Opportunity' AND isActive = true AND DeveloperName = 'BI_Marketing'];
    
    //Create new account
    Account acc = TestUtilities.CreateNewAccount(true);
    
    //List of Opportunity for Test 
    List<Opportunity> parentOpportunities = new List<Opportunity>();
    //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    //Add Parent (Contract LOA) opportunities in list
    parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', AccountId = acc.Id,StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
    RecordTypeId = recordTypes[0].Id));
    
    parentOpportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will Auto Populate', AccountId = acc.Id, StageName = 'On Deck', SBQQ__Renewal__c = true, CloseDate = System.today(),
    RecordTypeId = recordTypes[0].Id));
    
    //Set Opportunity flag
    OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
    OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
    
    //Test start here
    Test.startTest();
    
    //Execute trigger
    Util.byPassAllTriggers = false;
    
    //Insert List of Opportunity
    insert parentOpportunities;
    
    //Price Book
    PriceBook2 pB = new PriceBook2 (Name='Standard priceBook',Description = 'test');
    
    //Insert
    insert pB;
    
    //Std Price Book Id
    Id pricebookId = Test.getStandardPricebookId();
    
    //List of PriceBookEntry
    List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
    
    //Insert test data of price  book entry
    priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pricebookId, Isactive = true, UnitPrice = 20.00));
    priceBookEntries.add(new PricebookEntry(Product2Id = products[0].Id, PriceBook2Id = pB.Id,
    UnitPrice = 20.00,UseStandardPrice = false, Isactive = true));
    //insert
    insert priceBookEntries;
    
    //List of OpportunityLineItem
    List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
    
    //Test data of opportunity line item
    oppLineItems.add(new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = priceBookEntries[1].Id, Quantity = 1,
    UnitPrice = priceBookEntries[1].UnitPrice, ServiceDate = System.today()));
    
    //Test data of opportunity line item
    oppLineItems.add(new OpportunityLineItem(OpportunityId = parentOpportunities[0].Id, PricebookEntryId = priceBookEntries[1].Id, Quantity = 1,
    UnitPrice = priceBookEntries[1].UnitPrice, ServiceDate = System.today()));
    
    //Insert
    insert oppLineItems;
    
    //Query Program opportunity created after insert Opportunity Line Item insert
    List<Opportunity> opportunity = [Select Id, Amount, OwnerId, AccountId, Probability, StageName, Source_Stage__c, Parent_Opportunity__c,
    Program__c, CloseDate, RecordTypeId from Opportunity where Parent_Opportunity__c =: parentOpportunities[0].Id];
    
    //Assert
    //System.assertEquals(1,opportunity.size());
    //System.assertEquals(0,opportunity[0].Amount);
    //System.assertEquals(acc.Id,opportunity[0].AccountId);
    //System.assertEquals(CPQConstants.OPPORTUNITY_STAGE_PENDING,opportunity[0].StageName);
    //System.assertEquals(products[0].Program__c,opportunity[0].Program__c);
    //System.assertEquals(System.today(),opportunity[0].CloseDate);
    
    //Test stop
    Test.stopTest(); 
    }*/
    //Commented by - Nikita Kumari - 08/10/2021 - CR-20211005-15489 - End Here
}