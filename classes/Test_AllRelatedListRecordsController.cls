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
private  class Test_AllRelatedListRecordsController {
    
    /**
*  @description    :   The method is used to insert common data which are useful in testing
*  Create By       :   Dipesh Gupta
*  Created Date    :   27/05/2020
*  @args           :   
*  @return         :   void
*
**/   
    @testSetup static void dataSetup()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        test.startTest();
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test1', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test2', Status__c = 'Active' ));
        insert accounts;
        
        List<Account> accountList = [Select Id From Account];
        System.assertEquals(accountList.size(), 2 );
        
        //Get Record Type
        Id contactEmployeeRecordType = TestUtilities.FindRecordTypeId('Contact', 'Employee');
        
        //List to hold Institution records
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test1', AccountId = accounts[0].Id, Employee_ID__c = '12345'));
        contacts.add(new Contact(RecordTypeId = contactEmployeeRecordType, LastName = 'Test2', AccountId = accounts[1].Id, Employee_ID__c = '12346'));
        insert contacts;
        
        List<Contact> contactList = [Select Id,AccountId From Contact];
        System.assert(contactList[0].AccountId == accountList[0].Id);
        System.assertEquals(contactList.size(), 2 );
        
        //List to hold opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        opportunities.add(TestUtilities.CreateNewOpportunity(false));
        insert opportunities;
        
        List<Opportunity> opportunityList = [Select Id From Opportunity];
        System.assertEquals(opportunityList.size(), 2 );
        
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
        
        List<SBQQ__Quote__c> quoteList = [Select Id,SBQQ__PrimaryContact__c From SBQQ__Quote__c];
        System.assert(quoteList[0].SBQQ__PrimaryContact__c == contactList[0].Id);
        System.assertEquals(quoteList.size(), 1 );
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));
        contracts.add(new Contract(Status = 'Draft', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), ContractTerm = 30, AccountId = accounts[0].Id, SBQQ__Opportunity__c = opportunities[0].Id,
                SBQQ__Quote__c = quotes[0].Id));    
        
        insert contracts;
        
        List<Contract> contractList = [Select Id,SBQQ__Quote__c From Contract];
        System.assert(contractList[0].SBQQ__Quote__c == quoteList[0].Id);
        
        //Get Record Type
        Id subscriptionProgramRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Program');
        Id subscriptionComponentRecordType = TestUtilities.FindRecordTypeId('SBQQ__Subscription__c', 'Component');
        
        //List to hold Subscription records
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionProgramRecordType, SBQQ__Contract__c = contracts[0].Id, SBQQ__Quantity__c = 5));
        subscriptions.add(new SBQQ__Subscription__c(RecordTypeId = subscriptionComponentRecordType, SBQQ__Contract__c = contracts[1].Id, SBQQ__Quantity__c = 10));
        insert subscriptions;
        
        List<SBQQ__Subscription__c> subscriptionList = [Select Id,SBQQ__Contract__c From SBQQ__Subscription__c];
        System.assert(subscriptionList[0].SBQQ__Contract__c == contractList[0].Id);
        System.assertEquals(subscriptionList.size(), 2 );
        
        test.stopTest();
    }
    
    /**
*   Purpose         :   For "testing showRelatedListRecords" method
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   27/5/2020
**/  
    static testMethod void test_showRelatedListRecordsPositive() 
    {
       //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Contract> ContractList = [Select Id From Contract];
        
        test.startTest();
        AllRelatedListRecordsController contrl = new AllRelatedListRecordsController();
        PageReference page = Page.allRelatedListRecords; // Add your VF page Name here
        page.getParameters().put('objectName', String.valueOf('Subscription_Period__c'));
        page.getParameters().put('parentId', String.valueOf(ContractList[0].Id));
        Test.setCurrentPage(page);
        contrl .showRelatedListRecords();
        
        system.assertEquals(true,contrl.isSubscriptionPeriod);
        system.assertEquals(0,AllRelatedListRecordsController.listOfSubscriptionPeriod.size());
        
        
       AllRelatedListRecordsController contrl1 = new AllRelatedListRecordsController();
       
        page.getParameters().put('objectName', String.valueOf('SBQQ__Subscription__c'));
        page.getParameters().put('parentId', String.valueOf(ContractList[0].Id));
        page.getParameters().put('recordType', String.valueOf('Program'));
        Test.setCurrentPage(page);
        contrl1.showRelatedListRecords();
        contrl1.goBackToParentRecord();
        
        system.assertEquals(true,contrl1.isProgramSubscription);
        system.assertEquals(1,AllRelatedListRecordsController.listOfSBQQSubscription.size());
        
        AllRelatedListRecordsController contrl2 = new AllRelatedListRecordsController();
        
        page.getParameters().put('objectName', String.valueOf('SBQQ__Subscription__c'));
        page.getParameters().put('parentId', String.valueOf(ContractList[1].Id));
        page.getParameters().put('recordType', String.valueOf('Component'));
        Test.setCurrentPage(page);
        contrl2.showRelatedListRecords();
        contrl2.goBackToParentRecord();
        
        system.assertEquals(true,contrl2.isComponentSubscription);
        system.assertEquals(1,AllRelatedListRecordsController.listOfSBQQSubscription.size());
        
        test.stopTest();
    }
    
    static testMethod void test_showRelatedListRecordsNegative()
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        List<Contract> ContractList = [Select Id From Contract];
        
        test.startTest();
        AllRelatedListRecordsController contrl = new AllRelatedListRecordsController();
        contrl.showRelatedListRecords();
        contrl.returnFieldSetForSpecificObject('SBQQ__Subscription__c','');
        test.stopTest();
    }
    
}