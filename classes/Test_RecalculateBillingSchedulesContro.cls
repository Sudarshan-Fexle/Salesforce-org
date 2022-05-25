/*
 * Purpose			:	Test class for the code coverage of RecalculateBillingSchedulesController
 * 
 * Created Date		:	28/11/2019
 * 
 * Revision Log		:	V_1.0 - Created - Mahendra Swarnkar
 * 
 * Code Coverage	:	
 * */
@isTest
private class Test_RecalculateBillingSchedulesContro 
{
	@testSetup static void testSetuData()
    {
        Util.byPassAllTriggers = true;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        insert contacts;
        
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
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));    
        /*contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id, Technology_Change_Notification_Required__c = true));*/ 
        insert contracts;
        
        // Creating Billing_Schedule_Header__c records
        List<Billing_Schedule_Header__c> billingScheduleHeaders = new List<Billing_Schedule_Header__c>();
        billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Standard_Contract__c = contracts[0].Id,
            Invoicing_Arrangement__c = 'Quarterly',
            Institution__c = accounts[0].Id,
            Invoice_Contact__c = contacts[0].Id
        ));
        billingScheduleHeaders.add(new Billing_Schedule_Header__c(
            Status__c = 'Record In Sync',
            Invoicing_Arrangement__c = 'Quarterly',
            Institution__c = accounts[0].Id
        ));
        
        insert billingScheduleHeaders;
        
        Util.BypassAllTriggers = false;
    }
    
    // testing by passing billingScheduleHeaders id to the controller contructor
    @isTest static void testRecalculateBillingSchedulesControllerWithId()
    {
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Id, Name From Billing_Schedule_Header__c];
        
        System.assertEquals(2, billingScheduleHeaders.size());
        
        Test.setCurrentPageReference(new PageReference('Page.RecalculateBillingSchedules'));
        System.currentPageReference().getParameters().put('id', billingScheduleHeaders[0].Id);	
        
        test.startTest();
        RecalculateBillingSchedulesController rbsc = new RecalculateBillingSchedulesController();
        test.stopTest();
        
        Boolean billSchdId = Boolean.valueOf(ApexPages.currentPage().getParameters().get('id'));
        system.assertEquals(true, billSchdId != null);
    }
    
    // testing withoout passing billingScheduleHeaders id to the controller contructor
    @isTest static void testRecalculateBillingSchedulesControllerWithoutId()
    {
        Test.setCurrentPageReference(new PageReference('Page.RecalculateBillingSchedules'));
        System.currentPageReference().getParameters().put('id', null);	
        
        test.startTest();
        try{
            RecalculateBillingSchedulesController rbsc = new RecalculateBillingSchedulesController();
        }catch(Exception e) {
            
        }
        test.stopTest();
        
    }
    
    // test with Billing Scheduler Header Contract Id
    @isTest static void testRecalculateBillingSchedules()
    {
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Id, Name From Billing_Schedule_Header__c];
        
        System.assertEquals(2, billingScheduleHeaders.size());
        
        Test.setCurrentPageReference(new PageReference('Page.RecalculateBillingSchedules'));
        System.currentPageReference().getParameters().put('id', billingScheduleHeaders[0].Id);
        RecalculateBillingSchedulesController rbsc = new RecalculateBillingSchedulesController();
        
        test.startTest();
        rbsc.recalculateBillingSchedules();
        test.stopTest();
    }
    
    // test without Billing Schedule Header Contract Id
    @isTest static void testRecalculateBillingSchedulesWithoutBSHId()
    {
        List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Id, Name From Billing_Schedule_Header__c];
        
        System.assertEquals(2, billingScheduleHeaders.size());
        
        Test.setCurrentPageReference(new PageReference('Page.RecalculateBillingSchedules'));
        System.currentPageReference().getParameters().put('id', billingScheduleHeaders[1].Id);
        RecalculateBillingSchedulesController rbsc = new RecalculateBillingSchedulesController();
        
        test.startTest();
        rbsc.recalculateBillingSchedules();
        test.stopTest();
    }
    
    // test for validation error
    @isTest static void testRecalculateBillingScheduleValidation()
    {
        /*List<Billing_Schedule_Header__c> billingScheduleHeaders = [SELECT Id, Name From Billing_Schedule_Header__c];
        
        System.assertEquals(2, billingScheduleHeaders.size());
        
        Test.setCurrentPageReference(new PageReference('Page.RecalculateBillingSchedules'));
        System.currentPageReference().getParameters().put('id', billingScheduleHeaders[1].Id);
        RecalculateBillingSchedulesController rbsc = new RecalculateBillingSchedulesController();
        
        test.startTest();
        
        rbsc.recalculateBillingSchedules(); 
        test.stopTest();*/
    }
}