/*
    Purpose         -   Test Class for Batch_OpportunityPopulateRenewalFlag     
    
    Create By       -   Bhavi Sharma  
    
    Created Date    -   05/01/2013 
    
    Current Version -   v1.0 -  CR-20130408-2835 
                        V1.1 - Modified By - Nikita Kumari - CR-20211012-15511 - 08/11/2021 - Add the comment and Increase the coverage for Batch_OpportunityPopulateRenewalFlag
*/
@isTest
// Modified By - Nikita Kumari - CR-20211012-15511
private class Test_Batch_OpportunityPopulateRenFlag
{
    @testSetup static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        //Get Record Type
        Id accountUSCorporateRecordType = Constants.ACCOUNT_RT_ID_US_EDUCATION; 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        //Add Institution record into the list
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        //Add Institution record into the list
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        //inserting institution records
        insert accounts;
        
        // Modified by Nikita Kumari 08/11/2021 test class fix (july) - moved this part data from bottom - Start
        //List to hold Program records
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
       
        //Add record by Nikita kumari - 08/11/2021
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[1].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_PT;
        programs[1].Status__c = 'Active';
        programs[1].Name = 'TMAH - Test Method';
        programs[1].Program_Acronym__c = 'TMAH';
        programs[1].Program_Formal_Name__c = 'Test Method';
        programs[1].Renewable__c = true; 
        programs[1].New_Business_Business__c = 'EAB';
        programs[1].Type__c = 'Standard';
        programs[1].New_Business_Vertical__c = 'EAB';
        programs[1].Entity__c = 'EAB';
        programs[1].Program_Line__c = 'PT';
        programs[1].Sector__c = 'HE';
        programs[1].Applicable_Segments__c = 'International Education';
        programs[1].Solomon_Code__c = '851';
        programs[1].New_Business_Marketer__c = 'HE SSC';
        programs[1].Create_memberships__c = 'Yes';
        programs[1].Renewal_Unit_Count__c = 2;
       
        //Insert program records
        insert programs;
        
		//List to hold membership records
        List<Membership__c> memberships = new List<Membership__c>();
        //Add membership records into the list
        memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
        
        //inserting membership records
 	 	insert memberships;
        //Modified by Nikita Kumari - 08/11/2021 - Test Class fix (july) - end
        
        //updated opportunity record by Nikita Kumari -08/11/2021 - start
        //get record type name
        List<Id> recordTypes = new List<Id>();
        recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
        recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL));
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        //Add opportunity record into the list
        Opportunity opp1 = TestUtilities.CreateNewOpportunity(false);
        opp1.recordTypeId = recordTypes[0];
        opp1.Membership__c = memberships[0].Id;
        opp1.StageName = 'Auto Renewal';
        opp1.Pool_Month__c = String.valueOf(Date.today().month());
        opp1.Pool_Year__c = String.valueOf(Date.today().year()-1);
        opp1.Active_Renewal__c = true;
        opportunities.add(opp1);
        
        //Add opportunity record into the list
        Opportunity opp2 = TestUtilities.CreateNewOpportunity(false);
        opp2.recordTypeId = recordTypes[1];
        opp2.Membership__c = memberships[0].Id;
        opp2.StageName = '0-Exploring';
       	opp2.Pool_Month__c = String.valueOf(Date.today().month());
        opp2.Pool_Year__c = String.valueOf(Date.today().year()+1);
        opp2.Active_Renewal__c = true;
        opportunities.add(opp2);
     
        //insert opportunity records
        insert opportunities;
        
        ///updated opportunity record by Nikita Kumari -08/11/2021 - end
        
        //Program Package "EAB" Record Type Id
		Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
        
		//List to hold Program package records
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
        
		//Add Program package record into the list
		progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = accounts[0].Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        
        //Add Program package record into the list
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = accounts[1].Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
		//insert program pack records 
		insert progPacks;
        
        //Get Record Type
        Id contactEmployeeRecordType = Constants.CONTACT_RT_ID_EMPLOYEE;
        
        //List to hold Contact records
        List<Contact> contacts = new List<Contact>();
        
        //Add contact record into the list
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        
        //Added record by Nikita Kumari - 08/11/2021 - start
        //Add contact record into the list
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[1].Id, Employee_ID__c = '12345'));
        
        //insert contact records
        insert contacts;
        //Added record by Nikita Kumari - 08/11/2021 - end
        
        //Get Record Type
        Id QuoteOpenRecordType = TestUtilities.FindRecordTypeId('SBQQ__Quote__c', 'Open');
        
        //List to hold proposal 
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        
        //Add proposal record to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[0].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today() , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[0].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Added record by Nikita Kumari - 08/11/2021 - start
        //Add proposal record to list
        quotes.add(new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunities[1].Id, SBQQ__SalesRep__c = UserInfo.getUserId(), SBQQ__Status__c = 'Draft', 
                                      SBQQ__StartDate__c = Date.today().addDays(1) , SBQQ__EndDate__c = Date.today().addDays(2), recordTypeId = QuoteOpenRecordType,
                                      SBQQ__PrimaryContact__c = contacts[1].Id, SBQQ__Primary__c = true, Invoice_Frequency__c = 'Annual'));
        
        //Added record by Nikita Kumari - 08/11/2021 - end
        //Insert proposal records
        insert quotes;
       
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        //Add contract record into the list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                                   SBQQ__Quote__c = quotes[0].Id, Invoicing_Arrangement__c = 'Annual', Billing_Schedule_Automated_Status__c = 'Completed'));
        
         //Add contract record into the list
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[1].Id, SBQQ__Opportunity__c = opportunities[1].Id,
                                   SBQQ__Quote__c = quotes[1].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'Annual'));    
        
        //insert contract records
        insert contracts;
        //Added record by Nikita Kumari - 08/11/2021 - start
        opportunities[0].SBQQ__RenewedContract__c = contracts[0].Id;
        opportunities[1].SBQQ__RenewedContract__c = contracts[1].Id;
        
        //update opportunity records to populate contract into opportunities
        update opportunities;
        //Added record by Nikita Kumari - 08/11/2021 - end
        
        //Creating Product record //Id programId, Boolean createAndInsert
        List<Product2> products = new List<Product2>();
        
        //Add product record into the list
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[0].ProductCode = 'ImplementationFee';
        products[0].Name = 'Program Costs';
        products[0].Family = 'Enrollment Services';
        
       
        //Add product record into the list
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[1].ProductCode = 'Test Code';
        products[1].Name = 'Postage';
        products[1].Family = 'EAB Research';
        
        //insert product records
        insert products;
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(accounts[0].Id, programs[0].Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        
        insert membership;
        
        // Get the recordtype id for component type from SBQQ Subscription
        Id componentRecTypeId = Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT;
        Id progRecTypeId = Constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM;
        
        //List to hold program subscription records
        List<SBQQ__Subscription__c> Progsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add program subscription record in list
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                        SBQQ__Quantity__c = 1, Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                                        SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                        SBQQ__Product__c = products[0].ID, Invoicing_Arrangement__c = 'Monthly',
                                                        SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                        Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id)); 
         
        //Add program subscription record in list
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                        SBQQ__Quantity__c = 1, Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                                        SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[1].Id,
                                                        SBQQ__Product__c = products[1].ID, Invoicing_Arrangement__c = 'Monthly',
                                                        SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                        Status__c = 'Committed', Invoice_Contact__c = contacts[1].Id)); 
        
        //Insert program subscription records
        insert Progsubscriptions;
        
        //List to hold Subscription period records
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Add subscription period record into the list
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(Progsubscriptions[0].Id, false);
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_Start_Date__c = Date.Today().addDays(-2);
        sPeriod.Period_End_Date__c = Date.Today().addDays(3);
        sPeriod.Contract__c = contracts[0].Id;
        sPeriod.Source_Opportunity__c = opportunities[0].Id;
        sPeriod.Membership_Lookup__c = memberships[0].Id;
        sPeriod.Program_Package__c = progPacks[0].Id;
        subscriptionPeriods.add(sPeriod);
        
        //Added record by Nikita Kumari - 08/11/2021 - start
        //Add subscription period record into the list
        Subscription_Period__c sPeriod2 = TestUtilities.createNewSubscriptionPeriod(Progsubscriptions[0].Id, false);
        sPeriod2.Institution__c = accounts[1].Id;
        sPeriod2.Period_Start_Date__c = System.Today().addDays(-1);
        sPeriod2.Period_End_Date__c = System.Today().addDays(2);
        sPeriod2.Contract__c = contracts[1].Id;
        sPeriod2.Source_Opportunity__c = opportunities[1].Id;
        sPeriod2.Membership_Lookup__c = memberships[1].Id;
        sPeriod2.Program_Package__c = progPacks[1].Id;
        subscriptionPeriods.add(sPeriod2);
        
        //insert subscription period records
        insert subscriptionPeriods;
		//Added record by Nikita Kumari - 08/11/2021 - end
        
        //List to hold program subscription records
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        
        //Add program subscription record into the list
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5),
                                                           Program_Subscription__c = Progsubscriptions[0].Id, SBQQ__SegmentStartDate__c = system.today(),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',
                                                           SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'Monthly', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[0].Id, 
                                                           Subscription_Period__c = subscriptionPeriods[0].Id));
        
        //Add program subscription record into the list
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[1].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5),
                                                           Program_Subscription__c = Progsubscriptions[1].Id, SBQQ__SegmentStartDate__c = system.today(),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[1].Id,Status__c = 'Committed',
                                                           SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'Monthly', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[1].Id,
                                                           Subscription_Period__c = subscriptionPeriods[1].Id));
        //insert program subscription records
        insert programSubscriptions;        
        
        Util.BypassAllTriggers = False;
    }
    
    @isTest static void test_Batch_OpportunityPopulateRenewalFlag()
    {
        Test.startTest();
        
        //Call batch
        Database.executeBatch(new Batch_OpportunityPopulateRenewalFlag()); 
        
        Test.stopTest();
        
        //Added by Nikita kumari - 08/11/2021
        List<Subscription_Period__c> listSubPeriod = [Select Id,Contract__c, Membership_Lookup__c, Membership_Lookup__r.Active_Subscription_Period_Renewal__c, Source_Opportunity__c From Subscription_Period__c];
        System.assertEquals(listSubPeriod[0].Membership_Lookup__r.Active_Subscription_Period_Renewal__c,listSubPeriod[0].Id);
    }
}