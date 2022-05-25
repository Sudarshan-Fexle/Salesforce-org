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
//Modified By - Abhishekh Mishra - CR-20210517-15149 - 06/01/2021 - For Code coverage increase
//Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426 - Updated the duplicate Product Code.
@isTest(seeAllData = false)
private class Test_Batch_ImplementationFeeIssue {
    
    static testMethod void testDoCloneProposal() {
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
	
        //Add Institution records into list
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test3', Status__c = 'Active' ));
        
	//insert Institution records
        insert accounts;

        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
	//Add Contact records into list
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test3', AccountId = accounts[2].Id, Employee_ID__c = '12347'));
        
	//insert Contact records
        insert contacts;

        //Inserting opportunity on particular record type
        //Commented by -  chirag Soni - CR-20211112-15582 - 11/16/2021 - Commented Legacy Cappex record type
        //List<RecordType> recordTypes = [SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = 'Opportunity' AND Name = 'Legacy Cappex' LIMIT 1];
        
	//List to hold Opportunity records
        List<Opportunity> opportunities = new List<Opportunity>();
        
       	//ByPass flag
        Util.byPassAllTriggers = true;
        
	//Add Opportunity records into list
	//Modified by -  Chirag Soni - CR-20211112-15582 - 11/16/2021 - Added the constant for the record type and use the Royall Record type - From Here
        opportunities.add(new Opportunity(Name = 'test', AccountId = accounts[0].Id, StageName = 'Verbal Yes', CloseDate = SYSTEM.TODAY().addDays(3), 
                                         Main_Contact__c = contacts[0].Id, RecordTypeId = Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL, Amount = 2000.0, Opp_Type_CX__c = 'Upgrade'));
        opportunities.add(new Opportunity(Name = 'test2', AccountId = accounts[1].Id, StageName = 'Prospect', CloseDate = SYSTEM.TODAY().addDays(4), 
                                         Main_Contact__c = contacts[1].Id, RecordTypeId = Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL, Amount = 2000.0, Opp_Type_CX__c = 'Upgrade'));
        opportunities.add(new Opportunity(Name = 'test3', AccountId = accounts[2].Id, StageName = 'Outreach', CloseDate = SYSTEM.TODAY().addDays(5), 
                                         Main_Contact__c = contacts[2].Id, RecordTypeId = Constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL, Amount = 2000.0, Opp_Type_CX__c = 'Renewal'));
	//Modified by -  Chirag Soni - CR-20211112-15582 - 11/16/2021 - Added the constant for the record type and use the Royall Record type - Till Here
        
        //insert Opportunity records
        insert opportunities;
		
        //ByPass flag
        Util.byPassAllTriggers = false;
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List to hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
	//Add proposal records into list
	quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual', Legacy_Migrated_ES_Client__c = null, SBQQ__FirstSegmentTermEndDate__c = System.Today()));
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'In Review', 
                                      SBQQ__StartDate__c = Date.today().addDays(1) , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[1].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Semi-Annual', Legacy_Migrated_ES_Client__c = null, SBQQ__FirstSegmentTermEndDate__c = System.Today().addDays(1)));
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[2].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Approved', 
                                      SBQQ__StartDate__c = Date.today().addDays(2) , SBQQ__EndDate__c = Date.today().addDays(3), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[2].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Quarterly', Legacy_Migrated_ES_Client__c = null, SBQQ__FirstSegmentTermEndDate__c = System.Today().addDays(2)));
        //Diabling triggers
        Util.byPassAllTriggers = true;
        
	//Insert proposal
        insert quotes;
        
	//Enabling triggers
        Util.byPassAllTriggers = false;

        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        //Add Contract records in list 
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[1].Id, SBQQ__Opportunity__c = opportunities[1].Id,
                SBQQ__Quote__c = quotes[1].Id));   
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(4), EndDate = System.today().addDays(14), ContractTerm = 28, AccountId = accounts[2].Id, SBQQ__Opportunity__c = opportunities[2].Id,
                SBQQ__Quote__c = quotes[2].Id));   
        
        //Insert Contract records
        insert contracts;

        //Update LOA contract Value 
        opportunities[0].LOA_Contract__c = contracts[0].Id;
        opportunities[0].LOA_Contract__c = contracts[1].Id;
        opportunities[0].LOA_Contract__c = contracts[2].Id;
        update opportunities;
        
        //List to hold Proposal Line Group
        List<SBQQ__QuoteLineGroup__c> proposalLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        //Add proposal line group records into list
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-5), SBQQ__EndDate__c = System.Today().addDays(-3), SBQQ__Quote__c = quotes[0].Id));
        proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = null, SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[1].Id));
      	proposalLineGroup.add(new SBQQ__QuoteLineGroup__c(SBQQ__StartDate__c = System.Today().addDays(-3), SBQQ__EndDate__c = null, SBQQ__Quote__c = quotes[2].Id));
        System.assertNotEquals(null, proposalLineGroup[0].SBQQ__EndDate__c);
        System.assertNotEquals(null, proposalLineGroup[0].SBQQ__StartDate__c);
        System.assertEquals(null,proposalLineGroup[1].SBQQ__EndDate__c);
        System.assertEquals(null,proposalLineGroup[1].SBQQ__StartDate__c);
        //insert proposal line group records
        insert proposalLineGroup;

        //Inserting program
        Program__c prog = new Program__c();
        
        //Creating list to add products
        List<Product2> products = new List<Product2>();
        //Creating Product records
        products.add(new Product2(Name = 'EDIF - Independent School Executive Forum', ProductCode = 'ImplementationFeeSS',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'RI', IsActive = true,
                                 Program__c = prog.Id, c2g__CODASalesTaxStatus__c = 'Taxable'));
        
        products.add(new Product2(Name = 'EDSF - Independent School Executive Forum', ProductCode = 'ImplementationFee',
                                 Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                 Family = 'Enrollment Services', IsActive = true,
                                 Program__c = prog.Id, c2g__CODASalesTaxStatus__c = 'Exempt for Qualifying Accounts'));
        
        //Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426 - Updated the duplicate Product Code - ProductCode = 'ImplementationFeeSS' to 'ImplementationFeeSS1'
       	products.add(new Product2(Name = 'EDMF - Independent School Executive Forum', ProductCode = 'ImplementationFeeSS1',
                                  Program_Name_Member_Facing__c = 'Independent School Executive Forum',
                                  Family = 'EAB Tech', IsActive = true,
                                  Program__c = prog.Id, c2g__CODASalesTaxStatus__c = 'Exempt'));
        //insert product records
        insert products;
        
        //List to hold the Proposal Line records
        List<SBQQ__Quoteline__c> quoteLines = new List<SBQQ__Quoteline__c>();
        //Add proposal line records into list
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
        SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
        SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List', SBQQ__StartDate__c =  System.Today().addDays(-2), SBQQ__EndDate__c =System.Today().addDays(-4), SBQQ__Group__c = proposalLineGroup[0].Id));
     
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[1].Id, SBQQ__Product__c = products[1].Id, SBQQ__Number__c = 12,
        SBQQ__Quantity__c = 2, SBQQ__ProrateMultiplier__c = 5, SBQQ__SpecialPrice__c = 1,
        SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 6, Calculator__c = 'Calculator - BHAN : 12 : NCC',
        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 13, SBQQ__SubscriptionBase__c = 'List', SBQQ__StartDate__c =  System.Today().addDays(-3), SBQQ__EndDate__c =System.Today().addDays(-5), SBQQ__Group__c = proposalLineGroup[1].Id));
       
        quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quotes[2].Id, SBQQ__Product__c = products[2].Id, SBQQ__Number__c = 13,
        SBQQ__Quantity__c = 3, SBQQ__ProrateMultiplier__c = 6, SBQQ__SpecialPrice__c = 2,
        SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 7, Calculator__c = 'Calculator - BHAN : 12 : BCC',
        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 13, SBQQ__SubscriptionBase__c = 'List', SBQQ__StartDate__c =  System.Today().addDays(-4), SBQQ__EndDate__c =System.Today().addDays(-6), SBQQ__Group__c = proposalLineGroup[2].Id));
       
        //Test Start
        Test.startTest();
	
        //Diabling triggers
        Util.byPassAllTriggers = true;
	
        //insert proposal line records
        insert quoteLines;
	
        //Enabling triggers
        Util.byPassAllTriggers = false;
     
      	//Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        
        //List to hold Subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        //List to hold the record's type 
        List<RecordType> recordTypesSub = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                           AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
		
        //Add subscription records into list
	subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__SegmentIndex__c = 10,
                                                   SBQQ__Contract__c = contracts[0].Id, SBQQ__Account__c = accounts[0].Id,
                                                    SBQQ__Product__c = products[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypesSub[0].Id,SBQQ__RequiredByProduct__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(),   SBQQ__SegmentStartDate__c = System.Today().addDays(1), SBQQ__SegmentEndDate__c = System.Today().addDays(2), SBQQ__QuoteLine__c =  quoteLines[0].Id));
       	subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 12, Previous_Period_Plus_Uplift__c = 2000, SBQQ__SegmentIndex__c = 8,
                                                   SBQQ__Contract__c = contracts[1].Id, SBQQ__Account__c = accounts[1].Id,
                                                    SBQQ__Product__c = products[1].Id,
                                                    SBQQ__ListPrice__c = 2, RecordTypeId = recordTypesSub[0].Id,SBQQ__RequiredByProduct__c = products[1].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(),   SBQQ__SegmentStartDate__c = System.Today().addDays(3), SBQQ__SegmentEndDate__c = System.Today().addDays(4), SBQQ__QuoteLine__c =  quoteLines[1].Id));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 10, Previous_Period_Plus_Uplift__c = 2000, SBQQ__SegmentIndex__c = 6,
                                                   SBQQ__Contract__c = contracts[2].Id, SBQQ__Account__c = accounts[2].Id,
                                                    SBQQ__Product__c = products[2].Id,
                                                    SBQQ__ListPrice__c = 3, RecordTypeId = recordTypesSub[0].Id,SBQQ__RequiredByProduct__c = products[2].Id,
                                                    SBQQ__NetPrice__c = 4, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(),   SBQQ__SegmentStartDate__c = System.Today().addDays(5), SBQQ__SegmentEndDate__c = System.Today().addDays(6), SBQQ__QuoteLine__c =  quoteLines[2].Id));
        //insert subscription records
        insert subscriptions;
        
        
        //Calling Batch
        Batch_ImplementationFeeIssue bc = new Batch_ImplementationFeeIssue();
        bc.isUpdate = true;
        bc.isUpdateComponents = false;
        bc.recordsLimit = 3;
        
        //bc.contractIdsExternal = contractIds;
        database.executeBatch(bc, 200);
        Test.stopTest();
        
        List<SBQQ__Quoteline__c> listProposalLine = [Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c From SBQQ__Quoteline__c];
	    
        System.assertEquals(System.Today().addDays(-5),listProposalLine[0].SBQQ__StartDate__c); 
        System.assertEquals(System.Today(),listProposalLine[0].SBQQ__EndDate__c);
        
        System.assertEquals(System.today().addDays(1),listProposalLine[1].SBQQ__StartDate__c);
        System.assertEquals(System.Today().addDays(2),listProposalLine[1].SBQQ__EndDate__c);
        
        //Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426
        System.assertEquals(System.Today().addDays(-4),listProposalLine[2].SBQQ__StartDate__c);
        System.assertEquals(System.Today().addDays(-6),listProposalLine[2].SBQQ__EndDate__c); 
        
        //CR-20210910-15426
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(contracts[0].Id);
        contractIds.add(contracts[1].Id);
        contractIds.add(contracts[2].Id);
        bc = new Batch_ImplementationFeeIssue();
        bc.isUpdate = false;
        bc.isUpdateComponents = false;
        bc.recordsLimit = 3;
        bc.contractIdsExternal = contractIds;
        database.executeBatch(bc, 200);
           
    }
}