/*
 * Purpose		:	Test Class for the code coverage of BillingScheduleHierarchyController
 * 
 * Created Date	:	28/11/2019
 * 
 * Created By	:	Mahendra Swarnkar
 * 
 * Revision Log	:	V_1.0 - Created - Mahendra Swarnkar	
 * 
 * Code Coverage:	100%
 * */
@isTest
private class Test_BillingScheduleHierarchyController 
{
	@testSetup static void testSetupData()
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
        
        insert billingScheduleHeaders;
        
        // Creating Billing Schedule Periods records
        List<Billing_Schedule_Period__c> billingSchedulePeriods = new List<Billing_Schedule_Period__c>();
        billingSchedulePeriods.add(new Billing_Schedule_Period__c(
        	Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Installment__c = 1
        ));
        
        insert billingSchedulePeriods;
        
        // Creating Billing Schedule Line 
       	List<Billing_Schedule_Line__c> billingScheduleLines = new List<Billing_Schedule_Line__c>();
        billingScheduleLines.add(new Billing_Schedule_Line__c(
        	Billing_Schedule_Header__c = billingScheduleHeaders[0].Id,
            Billing_Schedule_Period__c = billingSchedulePeriods[0].Id,
            Company__c = 'EAB',
            Installment__c = 1
        ));
        
        insert billingScheduleLines;
        
        Util.BypassAllTriggers = false;
    }
    
    @isTest static void testBillingScheduleHierarchyInitialLoadWIthId()
    {
        List<Contract> contracts = [SELECT Id FROM Contract LIMIT 1];
        List<Billing_Schedule_Period__c> billingSchedulePeriods = [SELECT Id, Billing_Schedule_Header__c, (SELECT Id FROM Billing_Schedule_Lines__r) FROM Billing_Schedule_Period__c LIMIT 1];
        //List<Billing_Schedule_Lines__c> billingScheduleLines = [SELECT Id, Billing_Schedule_Header__c, Billing_Schedule_Period__c FROM Billing_Schedule_Lines__c LIMIT 1];
        test.startTest();
        String returnedValue = BillingScheduleHierarchyController.BillingScheduleHierarchyInitialLoad(contracts[0].Id);
        test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(returnedValue));
    }
    
    @isTest static void testBillingScheduleHierarchyInitialLoadWIthoutId()
    {
        List<Contract> contracts = [SELECT Id FROM Contract LIMIT 1];
        
        test.startTest();
        try{
            String returnedValue = BillingScheduleHierarchyController.BillingScheduleHierarchyInitialLoad(null);    
            System.assertEquals('', returnedValue);
        }catch(AuraHandledException ex){
            //System.assert(ex.getMessage().contains('Error:: Id Not Specifield'));
        }
        test.stopTest();
    }
    
    @isTest static void testgetColumns()
    {
        test.startTest();
        String returnedValue = BillingScheduleHierarchyController.getColumns();
        test.stopTest();
    }
    
    @isTest static void testgetRowData()
    {
        test.startTest();
        String returnedValue = BillingScheduleHierarchyController.getRowData();
        test.stopTest();
        System.assertEquals(null, returnedValue);
    }
}