/*
 * Purpose		:	Test class for the code coverage of BillingScheduleUtilities
 * 
 * Created Date		:	28/11/2019
 * 
 * Revision Log		:	V_1.0 - Created - Mahendra Swarnkar
 *                              V_1.1 - ModifiedBy - Mahendra Swarnkar - 3/27/2020
 * 				V_1.2 - ModifiedBy - Neha Sharma - 6/23/2021 - CR-20210517-15150 
 * 
 * Code Coverage	:	
 * */
@isTest(seeAllData = false)
private class Test_BillingScheduleUtilities {
	
    @testSetup static void testSetupData()
    {
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        
        //Added accounts by Neha Sharma - CR-20210517-15150 - To increase code coverage
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test3', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test4', Status__c = 'Active' ));
        insert accounts;
        
        System.assert(accounts.size() > 0);
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        
        //Added opportunities by Neha Sharma - CR-20210517-15150 - To increase code coverage
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        System.assert(opportunities.size() > 0);
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        
        //Added contacts by Neha Sharma - CR-20210517-15150 - To increase code coverage
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test3', AccountId = accounts[2].Id, Employee_ID__c = '12347'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test4', AccountId = accounts[3].Id, Employee_ID__c = '12348'));
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
                                      SBQQ__PrimaryContact__c = contacts[1].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'ES-75-25',Is_Enrollment_Services__c =true));

	//Added proposals by Neha Sharma - CR-20210517-15150 - To increase code coverage      
	quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[2].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(3), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[2].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'ES-75-25',Is_Enrollment_Services__c =true));
		
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[3].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(4), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[3].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'ES-75-25',Is_Enrollment_Services__c =true));


        //Insert quotes 
        insert quotes;
       
		
        System.assert(quotes.size() > 0);
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id, Invoicing_Arrangement__c = 'Annual', Billing_Schedule_Automated_Status__c = 'Completed'));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[1].Id,
                SBQQ__Quote__c = quotes[1].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));    
        
        //Added contracts by Neha Sharma - CR-20210517-15150 - To increase code coverage
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[2].Id, SBQQ__Opportunity__c = opportunities[2].Id,
                                   SBQQ__Quote__c = quotes[2].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));    
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[3].Id, SBQQ__Opportunity__c = opportunities[3].Id,
                                   SBQQ__Quote__c = quotes[3].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));
        
         contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[3].Id, SBQQ__Opportunity__c = opportunities[3].Id,
                                    SBQQ__Quote__c = quotes[3].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'ES-75-25'));
        
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
        
        //Added memberships by Neha Sharma - CR-20210517-15150  - To increase code coverage
        memberships.add(new Membership__c(Account_Name__c = accounts[2].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[3].Id, Program__c = programs[0].Id));
        insert memberships;
        
        // Creating Product record //Id programId, Boolean createAndInsert
        // Modified Products by populating product Family field - Neha Sharma - CR-20210517-15150 - To increase code coverage
        List<Product2> products = new List<Product2>();
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[0].ProductCode = 'ImplementationFee';
        products[0].Name = 'Program Costs';
        products[0].Family = 'Enrollment Services';
        
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[1].ProductCode = 'Test Code';
        products[1].Name = 'Postage';
        products[1].Family = 'YouVisit';
        
        //Added Products by Neha Sharma - CR-20210517-15150 - To increase code coverage
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[2].ProductCode = 'Test Code';
        products[2].Name = 'Program Costs';
        
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[3].ProductCode = 'Test Code';
        products[3].Name = 'Program Pages';
        
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
        //Add new subscription record by Neha Sharma - CR-20210517-15150 - To increase code coverage 
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                           SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[2].Id,
                                                           SBQQ__Product__c = products[0].ID, Invoicing_Arrangement__c = 'Annual', SBQQ__Quantity__c = 2,
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2,
                                                           Status__c = 'Committed', Invoice_Contact__c = contacts[2].Id));  
        //Insert
        insert Progsubscriptions;
        
        
        //Creating Subscription record
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5).addYears(1),
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
        
        //Added Program subscriptions by Neha Sharma - CR-20210517-15150 - To increase code coverage
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[1].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(-30),
                                                           Program_Subscription__c = Progsubscriptions[1].Id, SBQQ__SegmentStartDate__c = system.today().addDays(20),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'ES-75-25', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[0].Id));
                
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(30),
                                                           Program_Subscription__c = Progsubscriptions[1].Id, SBQQ__SegmentStartDate__c = system.today().addDays(-18),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'ES-75-25', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[0].Id));
        
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(30),
                                                           Program_Subscription__c = Progsubscriptions[1].Id, SBQQ__SegmentStartDate__c = system.today().addDays(-18),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'ES-75-25', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[2].Id));
        
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(30).addYears(1),
                                                           Program_Subscription__c = Progsubscriptions[2].Id, SBQQ__SegmentStartDate__c = system.today().addDays(-18),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 2, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',SBQQ__SegmentIndex__c =1,
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'ES-75-25', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[3].Id));
        
        
        insert programSubscriptions;
        
         // Creating Billing_Schedule_Header__c records
        List<Billing_Schedule_Header__c> billingScheduleHeaders = new List<Billing_Schedule_Header__c>();
        billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[0].Id,
            Invoicing_Arrangement__c = 'Monthly',
            Institution__c = accounts[0].Id,
            Invoice_Contact__c = contacts[0].Id,
            YouVisit_Product__c  = true
        ));
        
         billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[1].Id,
            Institution__c = accounts[0].Id,
            Invoice_Contact__c = contacts[0].Id,
            Enrollment_Services_Product__c  = true,
            Invoicing_Arrangement__c = 'ES-75-25'
        ));
         
        //Added Billing Schedule Headers by Neha Sharma - CR-20210517-15150 - To increase code coverage
         billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[2].Id,
            Institution__c = accounts[2].Id,
            Invoice_Contact__c = contacts[2].Id,
            Enrollment_Services_Product__c  = true,
            Invoicing_Arrangement__c = 'ES-75-25'
        ));
        
         billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[3].Id,
            Institution__c = accounts[3].Id,
            Invoice_Contact__c = contacts[3].Id,
            Enrollment_Services_Product__c  = true,
            Invoicing_Arrangement__c = 'ES-75-25'
        ));
        
        billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[4].Id,
            Institution__c = accounts[3].Id,
            Invoice_Contact__c = contacts[3].Id,
            Enrollment_Services_Product__c  = true,
            Invoicing_Arrangement__c = 'ES-75-25'
        ));
        
        insert billingScheduleHeaders; 
        
        // Creating Billing Schedule Periods records
        List<Billing_Schedule_Period__c> billingSchedulePeriods = new List<Billing_Schedule_Period__c>();
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period_Start_Date__c = system.today(),
            Billing_Schedule_Period_End_Date__c = system.today(),
          
            Invoice_Sent__c = true
            
        ));
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[1].Id,
            Billing_Schedule_Period_Start_Date__c = system.today(),
            Billing_Schedule_Period_End_Date__c = system.today(),
          
            Invoice_Sent__c = true
  
        ));
        
        //Added Billing Schedule Periods by Neha Sharma - 06/21/2021 - CR-20210517-15150 - To increase code coverage
         billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[2].Id,
            Billing_Schedule_Period_Start_Date__c = system.today(),
            Billing_Schedule_Period_End_Date__c = system.today(),
          
            Invoice_Sent__c = true
  
        ));
        
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[3].Id,
            Billing_Schedule_Period_Start_Date__c = system.today(),
            Billing_Schedule_Period_End_Date__c = system.today(),
          
            Invoice_Sent__c = true
  
        ));
         billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[3].Id,
            Billing_Schedule_Period_Start_Date__c = system.today(),
            Billing_Schedule_Period_End_Date__c = system.today().addDays(-45),
          
            Invoice_Sent__c = true
  
        ));
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[3].Id,
            Billing_Schedule_Period_Start_Date__c = system.today().addDays(-30),
            Billing_Schedule_Period_End_Date__c = system.today().addDays(-40),
          
            Invoice_Sent__c = true
  
        ));
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[4].Id,
            Billing_Schedule_Period_Start_Date__c = system.today().addDays(-30),
            Billing_Schedule_Period_End_Date__c = system.today().addDays(-40),
          
            Invoice_Sent__c = true
  
        ));
        insert billingSchedulePeriods;
        
        // Creating Billing Schedule Line 
       	List<Billing_Schedule_Line__c> billingScheduleLines = new List<Billing_Schedule_Line__c>();
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = programSubscriptions[1].Id,
            Billing_Amount__c = 500,
            Related_Component_Product_Override__c = 'Postage',
            Company__c = 'EAB',
            Installment__c = 2
        ));
	
         billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = programSubscriptions[1].Id,
            Billing_Amount__c = 500,
            Related_Component_Product_Override__c = 'Media',
            Company__c = 'EAB',
            Installment__c = 2
        ));
	
        //Added Billing Schedule Lines by Neha Sharma - CR-20210517-15150 - To increase code coverage
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = programSubscriptions[1].Id,
            Billing_Amount__c = 500,
            Related_Component_Product_Override__c = 'Program Costs',
            Company__c = 'EAB',
            Installment__c = 2
        ));
        
         billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = programSubscriptions[1].Id,
            Billing_Amount__c = 1000,
            Related_Component_Product_Override__c = 'Program',
            Company__c = 'EAB',
            Installment__c = 2
        ));
        
         billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = programSubscriptions[4].Id,
            Billing_Amount__c = 1000,
            Related_Component_Product_Override__c = 'Program',
            Company__c = 'EAB',
            Installment__c = 2
        ));
		
        insert billingScheduleLines;
        
        
        Util.BypassAllTriggers = false;
    }
    
    
    //test createBillingSchedulePeriods
    @isTest static void testcreateBillingSchedulePeriods()
    {
        // Modify By - Rajeev Jain - 16/July/2020 - CR-20200706-14267 System.SObjectException issue Fix (Add YouVisit_Product__c Field in the Query)
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c, Invoice_Contact__c, Enrollment_Services_Product__c, YouVisit_Product__c
                                                                  FROM Billing_Schedule_Header__c where Enrollment_Services_Product__c = false];

        Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>([SELECT Id, Billing_Schedule_Period_End_Date__c,
                                                                                                                 Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Installment__c
                                                                                                                 FROM Billing_Schedule_Period__c]);
        
        test.startTest();
        BillingScheduleUtilities.createBillingSchedulePeriods(billingScheduleHeaders, mapBillingSchedulePeriods);
        test.stopTest();
        
    }
    
    //test createBillingSchedulePeriods
    @isTest static void testcreateBillingSchedulePeriods1()
    {
        // Modify By - Rajeev Jain - 16/July/2020 - CR-20200706-14267 System.SObjectException issue Fix (Add YouVisit_Product__c Field in the Query)
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Name, Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c, Invoice_Contact__c, Enrollment_Services_Product__c, YouVisit_Product__c
                                                                  FROM Billing_Schedule_Header__c where Enrollment_Services_Product__c = true];

        //Modified By - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes -  Added Name in query
        Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>([SELECT Id, Name, Billing_Schedule_Period_End_Date__c,
                                                                                                                 Billing_Schedule_Header__c,Billing_Schedule_Header__r.Name,
														 Billing_Schedule_Period_Start_Date__c, Installment__c
                                                                                                                 FROM Billing_Schedule_Period__c]);
        
        test.startTest();
        BillingScheduleUtilities.createBillingSchedulePeriods(billingScheduleHeaders, mapBillingSchedulePeriods);
        test.stopTest();
        
    }
    
    // test createBillingScheduleHeadersFromContract with contracts
    @isTest static void testcreateBillingScheduleHeadersFromContract()
    {
        List<SBQQ__Subscription__c> subscriptions = [SELECT Id, Membership__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__CustomerPrice__c, SBQQ__Contract__c, 
                                                     Invoicing_Arrangement__c, Invoice_Contact__c, Program_Subscription__c, 
                                                     SBQQ__Contract__r.Status, SBQQ__Contract__r.StartDate, SBQQ__Contract__r.EndDate, SBQQ__Contract__r.ContractTerm,
                                                     SBQQ__Contract__r.AccountId, SBQQ__Contract__r.SBQQ__Opportunity__c, SBQQ__Contract__r.SBQQ__Quote__c,
                                                     SBQQ__Contract__r.Invoicing_Arrangement__c 
                                                     FROM SBQQ__Subscription__c];
        
        //Modified Assert by Neha Sharma - CR-20210517-15150 - To increase code coverage
        system.assertEquals(9, subscriptions.size());
        
        List<Contract> contracts = [SELECT Id, Status, StartDate, EndDate, ContractTerm, AccountId, SBQQ__Opportunity__c, SBQQ__Quote__c, Invoicing_Arrangement__c,
                                    (SELECT Id, Membership__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__CustomerPrice__c, SBQQ__Contract__c, 
                                     Invoicing_Arrangement__c, Invoice_Contact__c, Program_Subscription__c FROM SBQQ__Subscriptions__r) 
                                    FROM Contract WHERE Id =: subscriptions[2].SBQQ__Contract__c];
        test.startTest();
        //BillingScheduleUtilities.createBillingScheduleHeadersFromContract(contracts);
        test.stopTest();
        
    }
    
    // test createBillingScheduleHeadersFromContract without contracts
    @isTest static void createBillingScheduleHeadersFromContract_1()
    {
        test.startTest();
        BillingScheduleUtilities.createBillingScheduleHeadersFromContract(null);
        test.stopTest();
    }
    
    // test createBillingScheduleLines
    @isTest static void createBillingScheduleLines()
    {
        List<Billing_Schedule_Period__c> billingSchedulePeriods = [SELECT Id, Billing_Schedule_Period_End_Date__c,
                                                                   Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Installment__c 
                                                                   FROM Billing_Schedule_Period__c];
        
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c, Invoice_Contact__c
                                                                  FROM Billing_Schedule_Header__c];
        List<Billing_Schedule_Line__c> billingScheduleLines = [Select Id,Billing_Schedule_Header__c,Billing_Schedule_Period__c,Related_Subscription_Component__c,
        						       Billing_Amount__c,Company__c, Installment__c From Billing_Schedule_Line__c];
        
        Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>([SELECT Id, Billing_Schedule_Period_End_Date__c,
                                                                                                                 (SELECT Id, Name, Billing_Schedule_Header__c,Billing_Schedule_Period__c,
                                                                                                                  Related_Subscription_Component__c, Billing_Amount__c, Related_Component_Product__c,
                                                                                                                  Company__c, Installment__c FROM Billing_Schedule_Lines__r)
                                                                                                                 Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Installment__c 
                                                                                                                 FROM Billing_Schedule_Period__c]);
        
        test.startTest();
        BillingScheduleUtilities.createBillingScheduleLines(billingSchedulePeriods, billingScheduleHeaders, mapBillingSchedulePeriods);
        test.stopTest();
    }
    
    // test recalculateCreateBillingSchedulePeriodsFromBSH
    @isTest static void recalculateCreateBillingSchedulePeriodsFromBSH()
    {	
        // Modify By - Rajeev Jain - 16/July/2020 - CR-20200706-14267 System.SObjectException issue Fix (Add YouVisit_Product__c Field in the Query)
        Billing_Schedule_Header__c billingScheduleHeaders = [SELECT Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c,
                                                             Invoice_Contact__c, Enrollment_Services_Product__c, YouVisit_Product__c
                                                             FROM Billing_Schedule_Header__c LIMIT 1];
        test.startTest();
        BillingScheduleUtilities.recalculateCreateBillingSchedulePeriodsFromBSH(billingScheduleHeaders);
        test.stopTest();
    }
    
    
    // Testing without List of Contract
    @isTest static void testcreateBillingScheduleHeadersFromContractWithoutContract()
    {
        List<Contract> newContracts = [Select Id,Status, StartDate, EndDate,ContractTerm , AccountId, SBQQ__Opportunity__c,SBQQ__Quote__c, Invoicing_Arrangement__c,
                                       (Select Id,SBQQ__Contract__c,Invoicing_Arrangement__c,Membership__c, SBQQ__ListPrice__c, SBQQ__SegmentEndDate__c,
                                        SBQQ__NetPrice__c, SBQQ__CustomerPrice__c , SBQQ__ProrateMultiplier__c, 
                                        Invoice_Contact__c,Status__c, Postage_Costs_m__c,Postage_Adjustment_m__c, Media_Adjustment_m__c,
                                        SBQQ__Quantity__c, SBQQ__SegmentStartDate__c,SBQQ__SubscriptionStartDate__c,
                                        SBQQ__SubscriptionEndDate__c,SBQQ__Product__c, SBQQ__Product__r.Family From SBQQ__Subscriptions__r), 
                                       Billing_Schedule_Automated_Status__c,Invoice_Contact__c From Contract];
        
        test.startTest();
        BillingScheduleUtilities.createBillingScheduleHeadersFromContract(newContracts);
        test.stopTest();
        
    }
    
    // test createBillingScheduleLines
    @isTest static void testCreateBillingScheduleLines()
    {
        List<Billing_Schedule_Period__c> billingSchedulePeriods = [SELECT Id, Billing_Schedule_Period_End_Date__c, Billing_Schedule_Header__c,
                                                                   Billing_Schedule_Period_Start_Date__c, Installment__c
                                                                   FROM Billing_Schedule_Period__c];
        
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Id, Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c, Invoice_Contact__c 
                                                                   FROM Billing_Schedule_Header__c];
        
        Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>([SELECT Id, Billing_Schedule_Period_End_Date__c,
                                                                                                                 Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Installment__c
                                                                                                                 FROM Billing_Schedule_Period__c]);
        
        test.startTest();
        BillingScheduleUtilities.createBillingScheduleLines(billingSchedulePeriods, billingScheduleHeaders, mapBillingSchedulePeriods);
        test.stopTest();
    }
    
    // test calculatePeriodsForLines
    @isTest static void testCalculatePeriodsForLines()
    {
        //Modified By - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes - Added Type in query
        List<SBQQ__Subscription__c> programSubscriptions = [SELECT Id, Name, Membership__c, SBQQ__ListPrice__c, Type__c,
                                                           Program_Subscription__c, SBQQ__SegmentStartDate__c,
                                                           SBQQ__NetPrice__c , SBQQ__CustomerPrice__c, SBQQ__ProrateMultiplier__c, 
                                                           Invoice_Contact__c, Status__c, SBQQ__SegmentEndDate__c,
                                                           SBQQ__Contract__c, SBQQ__Quantity__c,
                                                           Invoicing_Arrangement__c, SBQQ__SubscriptionStartDate__c,
                                                           SBQQ__SubscriptionEndDate__c, RecordTypeId, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode FROM SBQQ__Subscription__c];
        
        Map<Id, Billing_Schedule_Period__c> mapBillingSchedulePeriods = new Map<Id, Billing_Schedule_Period__c>([SELECT Id, Billing_Schedule_Period_End_Date__c,
                                                                                                                 Billing_Schedule_Header__c, Billing_Schedule_Period_Start_Date__c, Installment__c
                                                                                                                 FROM Billing_Schedule_Period__c]);
        test.startTest();
        BillingScheduleUtilities.calculatePeriodsForLines(programSubscriptions, 'Monthly',mapBillingSchedulePeriods.values());
        test.stopTest();
    }
    
    // test recalculateCreateBillingSchedulePeriodsFromBSH
    @isTest static void testRecalculateCreateBillingSchedulePeriodsFromBSH()
    {	
        // Modify By - Rajeev Jain - 16/July/2020 - CR-20200706-14267 System.SObjectException issue Fix (Add YouVisit_Product__c Field in the Query)
        Billing_Schedule_Header__c billingScheduleHeaders = [SELECT Status__c, Standard_Contract__c, Invoicing_Arrangement__c, Institution__c,
                                                             Invoice_Contact__c, Enrollment_Services_Product__c, YouVisit_Product__c
                                                             FROM Billing_Schedule_Header__c LIMIT 1];
        test.startTest();
        BillingScheduleUtilities.recalculateCreateBillingSchedulePeriodsFromBSH(billingScheduleHeaders);
        test.stopTest();
    }
    
     @isTest static void testcalculateMonthDuration()
    {
       List<SBQQ__Subscription__c> programSubscriptions = [SELECT Id, Name, Membership__c, SBQQ__ListPrice__c, 
                                                           Program_Subscription__c, SBQQ__SegmentStartDate__c,
                                                           SBQQ__NetPrice__c , SBQQ__CustomerPrice__c, SBQQ__ProrateMultiplier__c, 
                                                           Invoice_Contact__c, Status__c, SBQQ__SegmentEndDate__c,
                                                           SBQQ__Contract__c, SBQQ__Quantity__c,
                                                           Invoicing_Arrangement__c, SBQQ__SubscriptionStartDate__c,
                                                           SBQQ__SubscriptionEndDate__c, RecordTypeId, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode FROM SBQQ__Subscription__c];
        test.startTest();
        BillingScheduleUtilities.calculateMonthDuration(programSubscriptions);
        test.stopTest();
    }
    
    //Added by Neha Sharma - 06/21/2021  - CR-20210517-15150 - To increase code coverage
    @isTest static void testExistingBillingSchedulePeriod()
    {
         List<Billing_Schedule_Period__c> listBillingSchedulePeriod = [Select Id, Billing_Schedule_Period_Start_Date__c, Billing_Schedule_Period_End_Date__c From Billing_Schedule_Period__c];
	 Date startDate = System.Today().addDays(-40);
         Date endDate = System.Today().addDays(-40);
         test.startTest();  
         BillingScheduleUtilities.existingBillingSchedulePeriod(listBillingSchedulePeriod, startDate, endDate);
         test.stopTest();
    }
}