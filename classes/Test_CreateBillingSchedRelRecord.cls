/*
 * Purpose			:	Test class for the code coverage of Batch_CreateBillingSchedAndRelatedRecord
 * 
 * Created Date		:	15/10/2020
 * 
 * Revision Log		:	V_1.0 - Created - Mahendra Swarnkar
 * 
 * Code Coverage	:	
 * */
@isTest(SeeAllData = false)
public class Test_CreateBillingSchedRelRecord {
    
    @isTest static void testBatch_CreateBillingSchedAndRelatedRecord()
    {
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        System.assert(accounts.size() > 0);
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        System.assert(opportunities.size() > 0);
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        insert contacts;
        
        System.assert(contacts.size() > 0);
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List ot hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
       
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'ES-75-25',Is_Enrollment_Services__c =true));
        
        //Insert Opportunity
        insert quotes;
       
        
        System.assert(quotes.size() > 0);
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id, Invoicing_Arrangement__c = 'Annual', Billing_Schedule_Automated_Status__c = 'Completed'));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[1].Id,
                SBQQ__Quote__c = quotes[1].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));    
        
        insert contracts;
        
        System.assert(contracts.size() > 0);
        
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
        
        // Creating Member Records
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
        
        insert memberships;
        
        // Creating Product record //Id programId, Boolean createAndInsert
        List<Product2> products = new List<Product2>();
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[0].ProductCode = 'ImplementationFee';
        products[0].Name = 'Program Costs';
        
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[1].ProductCode = 'Test Code';
        products[1].Name = 'Postage';
        
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[1].ProductCode = 'Test Code';
        products[1].Name = 'Program Costs';
        
        
        insert products;
        
        
        //Program Costs
        
        // Get the recordtype id for component type from SBQQ Subscription
        Id componentRecTypeId = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Component');
        
        Id progRecTypeId = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        
        
        
        List<SBQQ__Subscription__c> Progsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                           SBQQ__Product__c = products[0].ID, Invoicing_Arrangement__c = 'Monthly', SBQQ__Quantity__c = 2,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));    
        //Add new subscription record in list
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[1].Id,
                                                           SBQQ__Product__c = products[0].ID, Invoicing_Arrangement__c = 'ES-75-25', SBQQ__Quantity__c = 2,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));         
        //Insert
        insert Progsubscriptions;
        
        
        //Creating Subscription record
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 2, SBQQ__SegmentStartDate__c = system.today(),
                                                           Invoicing_Arrangement__c = 'Monthly', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = progRecTypeId, SBQQ__Product__c = products[1].Id));
        
        
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(-30),
                                                           Program_Subscription__c = Progsubscriptions[1].Id, SBQQ__SegmentStartDate__c = system.today().addDays(-30),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'ES-75-25', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[0].Id));
        
        insert programSubscriptions;
        
        //Start our Test
        Test.startTest();
        
        //Run our Batch
        Batch_CreateBillingSchedAndRelatedRecord testBatch = new Batch_CreateBillingSchedAndRelatedRecord();
        Database.executeBatch(testBatch);
        
        //Stop our Test
        Test.stopTest();
    }
    
    @isTest static void testBatch_CreateBillingSchedulerTest()
    {
        Test.startTest();
        DateTime sysTime = dateTime.now().addHours(24);
        String CRON_EXP = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule('Batch_CreateBillingSchedAndRelatedRecord',CRON_EXP,new Batch_CreateBillingSchedAndRelatedRecord());
        Test.stopTest();    
    }
}