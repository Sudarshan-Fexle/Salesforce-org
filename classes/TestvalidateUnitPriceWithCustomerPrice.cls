/**
 *  @description    :   This is test class for Sched_validateUnitPriceWithCustomerPrice class
 *  Create By       :   Nikita Kumari - CR-20211005-15489
 *  Created Date    :   07/08/2021
 **/ 
@isTest(seeAllData = false)
public with sharing class TestvalidateUnitPriceWithCustomerPrice {
    static testMethod void test_validateUnitPriceWithCustomerPrice()
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
        
        
        //Add additional field values
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_RI;
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        
        //Insert
        insert programs;
        
        //List of Product
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'RI Product',
                                  Family = 'RI',
                                  Program__c = programs[0].Id,
                                  IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        products.add(new Product2(Name = 'RI Product',
                                  Family = 'RI',
                                  Program__c = programs[1].Id,
                                  IsActive = true,
                                  ProductCode = 'RIPRO'));
        
        insert products;
        
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        
        //Insert
        insert accounts;
        
        
        //SOQL over the opportunity Record Type0
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Bypass
        Util.BypassAllTriggers = true;
        
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
        eABInitOpp.pricebook2Id = cPB.Id;
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote',
                                         SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(),
                                         SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3),
                                         SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                         SBQQ__Status__c = 'Draft',
                                         SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id,
                                         SBQQ__SalesRep__c = Userinfo.getUserId(),
                                         RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = cPB.Id ,
                                         SBQQ__PricebookId__c= cPB.Id));
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id,
                                                                     SBQQ__Product__c = products[0].Id,
                                                                     SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1,
                                                                     SBQQ__ProrateMultiplier__c = 4,
                                                                     SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__CustomerPrice__c = 90,
                                                                     SBQQ__PricingMethod__c = 'List',
                                                                     Annual_Increase__c = 5,
                                                                     Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price',
                                                                     SBQQ__DefaultSubscriptionTerm__c = 12,
                                                                     SBQQ__SubscriptionBase__c = 'List');
        
        Util.BypassAllTriggers = true;
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //List of OpportunityLineItem
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        //Test data of opportunity line item
        oppLineItems.add(new OpportunityLineItem(OpportunityId = eABInitOpp.Id,
                                                 PricebookEntryId = CustomPrice.Id,
                                                 Quantity = 1,
                                                 TotalPrice = 100,
                                                 SBQQ__QuoteLine__c = mainProposalLine.Id,
                                                 ServiceDate = System.today()));
        
        //Test data of opportunity line item
        oppLineItems.add(new OpportunityLineItem(OpportunityId = eABInitOpp.Id,
                                                 PricebookEntryId = CustomPrice.Id,
                                                 Quantity = 1,
                                                 SBQQ__QuoteLine__c = mainProposalLine.Id,
                                                 UnitPrice = CustomPrice.UnitPrice,
                                                 ServiceDate = System.today()));
        
        //Insert
        insert oppLineItems;
        
        test.startTest();
        
        Set<Id> setOpportunityProductIds = new Set<Id>();
        
        List<OpportunityLineItem> oppLineItemss = [Select Id From OpportunityLineItem];
        
        for(OpportunityLineItem oppListItms : oppLineItemss){
            setOpportunityProductIds.add(oppListItms.Id);
        }
        
        if(setOpportunityProductIds.size() > 0){
            
            dateTime sysTime = dateTime.now().addMinutes(1);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Sched_validateUnitPriceWithCustomerPrice job = new Sched_validateUnitPriceWithCustomerPrice();
            job.setOpportunityProductIds = setOpportunityProductIds;
            
            System.schedule('Sched_validateUnitPriceWithCustomerPrice' + sysTime.getTime(), chron_exp, job);
            
        }
        test.stopTest(); 
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals('Sched_validateUnitPriceWithCustomerPrice', asyncApexJob[0].ApexClass.Name);
    }
}