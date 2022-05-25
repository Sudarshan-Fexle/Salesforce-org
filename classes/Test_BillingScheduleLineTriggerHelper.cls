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
private class Test_BillingScheduleLineTriggerHelper {
    
    @testSetup static void dataSetup() {
        
        // TO DO: implement unit test
        
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = Constants.ACCOUNT_RT_ID_US_EDUCATION; 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        System.assert(accounts.size() > 0);
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        System.assert(opportunities.size() > 0);
        
        //Program Package "EAB" Record Type Id
		Id programPackage_EAB_RTypeId = TestUtilities.FindRecordTypeId('Program_Package__c','EAB' );
		
		List<Program_Package__c> progPacks = new List<Program_Package__c>();
		
		progPacks.add(new Program_Package__c(Name = 'Test1', Account__c = accounts[0].Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()),
                                             Client_Status_New__c = Label.Client_Status_Secured, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
        progPacks.add(new Program_Package__c(Name = 'Test2', Account__c = accounts[1].Id, Fiscal_Year__c = String.valueOf(Date.Today().Year()+1),
                                             Client_Status_New__c = Label.Client_Status_At_Risk, Account_Status__c = 'Existing Client', RecordTypeId = programPackage_EAB_RTypeId));
	
		insert progPacks;
        
        //Get Record Type
        Id contactEmployeeRecordType = Constants.CONTACT_RT_ID_EMPLOYEE;
        
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
        
        //Insert Opportunity
        insert quotes;
        
        System.assert(quotes.size() > 0);
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                                   SBQQ__Quote__c = quotes[0].Id, Invoicing_Arrangement__c = 'Annual', Billing_Schedule_Automated_Status__c = 'Completed'));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                                   SBQQ__Quote__c = quotes[0].Id, Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'Annual'));    
        
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
        products[0].Family = 'Enrollment Services';
        
        products.add(TestUtilities.createNewProduct(programs[0].Id, false));
        products[1].ProductCode = 'Test Code';
        products[1].Name = 'Postage';
        products[0].Family = 'EAB Research';
        
        insert products;
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(accounts[0].Id, programs[0].Id, false);
        membership.RecordTypeId = Constants.Membership_Record_Type_Enrollment;
        
        insert membership;
        
        // Get the recordtype id for component type from SBQQ Subscription
        Id componentRecTypeId = Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT;
        Id progRecTypeId = Constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM;
        
        List<SBQQ__Subscription__c> Progsubscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        Progsubscriptions.add(new SBQQ__Subscription__c(RecordTypeId = progRecTypeId,
                                                        SBQQ__Quantity__c = 1, Opt_Out__c = 'One Point in Time Opt Out Without Penalty Fee',
                                                        SBQQ__ListPrice__c = 0, Stage_Period__c = 'Pending',SBQQ__Contract__c = contracts[0].Id,
                                                        SBQQ__Product__c = products[0].ID, Invoicing_Arrangement__c = 'Monthly',
                                                        SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                        Status__c = 'Committed', Invoice_Contact__c = contacts[0].Id));                                                     
        
        //Insert
        insert Progsubscriptions;
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        
        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(Progsubscriptions[0].Id, false);
        sPeriod.Institution__c = accounts[0].Id;
        sPeriod.Period_Start_Date__c = Date.Today().addDays(1);
        sPeriod.Period_End_Date__c = Date.Today().addYears(1);
        sPeriod.Contract__c = contracts[0].Id;
        sPeriod.Source_Opportunity__c = opportunities[0].Id;
        sPeriod.Membership_Lookup__c = membership.Id;
        sPeriod.Program_Package__c = progPacks[0].Id;
        subscriptionPeriods.add(sPeriod);
        
        insert subscriptionPeriods;
        
        //Creating Subscription record
        List<SBQQ__Subscription__c> programSubscriptions = new List<SBQQ__Subscription__c>();
        
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5),
                                                           Program_Subscription__c = Progsubscriptions[0].Id, SBQQ__SegmentStartDate__c = system.today(),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',
                                                           SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'Monthly', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[0].Id, 
                                                           Subscription_Period__c = subscriptionPeriods[0].Id));
        
        programSubscriptions.add(new SBQQ__Subscription__c(Membership__c = memberships[0].Id, SBQQ__ListPrice__c = 0, SBQQ__SegmentEndDate__c = system.today().addDays(5),
                                                           Program_Subscription__c = Progsubscriptions[0].Id, SBQQ__SegmentStartDate__c = system.today(),
                                                           SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2, 
                                                           Postage_Costs_m__c = 206, Media_Costs_m__c = 177, Postage_Adjustment_m__c = 110, Media_Adjustment_m__c = 210,
                                                           Invoice_Contact__c = contacts[0].Id,Status__c = 'Committed',
                                                           SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 2,
                                                           Invoicing_Arrangement__c = 'Monthly', SBQQ__SubscriptionStartDate__c = system.today().addDays(-30),
                                                           SBQQ__SubscriptionEndDate__c = system.today().addDays(30), RecordTypeId = componentRecTypeId, SBQQ__Product__c = products[1].Id,
                                                           Subscription_Period__c = subscriptionPeriods[0].Id));
        insert programSubscriptions;
        
        // Creating Billing_Schedule_Header__c records
        List<Billing_Schedule_Header__c> billingScheduleHeaders = new List<Billing_Schedule_Header__c>();
        billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[0].Id,
            Invoicing_Arrangement__c = 'Monthly',
            Institution__c = accounts[0].Id,
            Invoice_Contact__c = contacts[0].Id
        ));
        
        insert billingScheduleHeaders;
        
        // Creating Billing Schedule Periods records
        List<Billing_Schedule_Period__c> billingSchedulePeriods = new List<Billing_Schedule_Period__c>();
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period_Start_Date__c = system.today().addDays(-30),
            Billing_Schedule_Period_End_Date__c = system.today().addDays(50),
            Invoice_Sent__c = true,
            Installment__c = 1
        ));
        
        insert billingSchedulePeriods;
        
    }
    
    /**
    *   Purpose         :   Test class for BillingScheduleLineTriggerHelper
    *            
    *   Create By       :   Mahendra Swarnkar
    * 
    *   Created Date    :   01/10/2020
    *
    *   Revision Log    :   
    *
	**/ 
    @isTest static void unitTest(){
        
        Id progRecTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        Id componentRecTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        
        //List
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [Select Id From Billing_Schedule_Header__c];
        List<Billing_Schedule_Period__c> billingSchedulePeriods = [Select Id From Billing_Schedule_Period__c];
        List<SBQQ__Subscription__c> programSubscriptions = [Select Id From SBQQ__Subscription__c Where RecordTypeId =: progRecTypeId];
        List<SBQQ__Subscription__c> componentSubscriptions = [Select Id From SBQQ__Subscription__c Where RecordTypeId =: componentRecTypeId];

        //Assert
        System.assertEquals(1, billingScheduleHeaders.size());
        System.assertEquals(1, billingSchedulePeriods.size());
        System.assertEquals(1, programSubscriptions.size());
        System.assertEquals(2, componentSubscriptions.size());
        
        Util.BypassAllTriggers = false;
        
        // Creating Billing Schedule Line 
        List<Billing_Schedule_Line__c> billingScheduleLines = new List<Billing_Schedule_Line__c>();
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = componentSubscriptions[0].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Related_Subscription_Component__c = componentSubscriptions[1].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        insert billingScheduleLines;
        
		// This Change need to deploy for CR-20200424-13982
        //BillingScheduleLineTriggerHelper.updatBillingSchedulePeriodStartAndEndDate(billingScheduleLines,null);
        
        //verify billingScheduleLineTriggerHelper.updatePeriodType is working properly
        for (Billing_Schedule_Line__c bsl : [SELECT Id, Billing_Schedule_Period__r.Type__c FROM Billing_Schedule_Line__c WHERE Id IN :billingScheduleLines]) {
            system.assertEquals(null, bsl.Billing_Schedule_Period__r.Type__c);
        }
    }
    
    @isTest static void test_validateBLS(){ 
    Id progRecTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        Id componentRecTypeId = CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT;
        
        //List
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [Select Id From Billing_Schedule_Header__c];
        List<Billing_Schedule_Period__c> billingSchedulePeriods = [Select Id From Billing_Schedule_Period__c];
       
        Util.BypassAllTriggers = true;
        
        // Creating Billing Schedule Line 
        List<Billing_Schedule_Line__c> billingScheduleLines = new List<Billing_Schedule_Line__c>();
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        billingScheduleLines.add(new Billing_Schedule_Line__c(
            Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Billing_Amount__c = 500,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        insert billingScheduleLines;
        
       Test.startTest();
        Util.byPassAllTriggers = false;
        try{
          delete billingScheduleLines;
        }
        catch(exception e){
            system.assertEquals('You can not delete ' + billingScheduleLines[0].name,e.getMessage());
        }
        Test.stopTest();
   }
    
   
}