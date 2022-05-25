/*
Purpose         :   Test class for Batch_UpdateSubscriptionPeriodCTFields

Created By      :   Mahendra Swarnkar

Created Date    :   06/08/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - Mahendra Swarnkar - 06/08/2020

Code Coverage   : 

*/
@IsTest
private class Test_Batch_UpdateSPeriodCTFields 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        Account account = TestUtilities.CreateNewAccount(true);
        
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(Name = 'Test contract',Status = 'Draft', AccountId = account.Id, 
                                   StartDate = date.today(), ContractTerm = 1));
        contracts.add(new Contract(Name = 'Test contract2',Status = 'Draft', AccountId = account.Id,
                                   StartDate = date.today(), ContractTerm = 1));
        insert contracts;
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'New Names', Family = 'Enrollment Services', Program__c = program.Id, IsActive = true,
                                  ProductCode = 'ESNN',SBQQ__SortOrder__c = 2,SBQQ__Component__c = true));
        insert products;
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        insert subscriptions;
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Period_Start_Date__c=Date.today(), 
                                                           Period_End_Date__c=Date.today().addYears(1), CT_Assignment__c = UserInfo.getUserId(),
                                                           Program_Subscription__c = subscriptions[0].Id, Pool_Year__c = '2020', CT_Date_Passed__c = System.today()));
        
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP1',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Period_Start_Date__c=Date.today(), 
                                                           Period_End_Date__c=Date.today().addYears(1), Previous_Subscription_Period__c = subscriptionPeriods[0].Id,
                                                           Program_Subscription__c = subscriptions[0].Id, Pool_Year__c = '2020', CT_Date_Passed__c = System.today()));
        insert subscriptionPeriods;
        
        List<Event> eventList = new List<Event>();
        
        Id accountManagementRTId = Util.RecordTypeId('Event', 'Account Management');
        
        eventList.add(new Event(whatId = subscriptionPeriods[1].Id, Subject = 'Call', RecordTypeId = accountManagementRTId, StartDateTime = System.now(),
                                EndDateTime = System.now(), Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairman\''+'s Team'));
        
        eventList.add(new Event(whatId = subscriptionPeriods[1].Id, Subject = 'Call', RecordTypeId = accountManagementRTId, StartDateTime = System.now(),
                                EndDateTime = System.now(), Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairman\''+'s Team'));
        insert eventList;
        
                 
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void testForBatch_UpdateSPeriodCTFields ()
    {
        Test.startTest();
        
        Batch_UpdateSubscriptionPeriodCTFields  batchJob = new Batch_UpdateSubscriptionPeriodCTFields();
        Database.executeBatch(batchJob);
        
        Test.stopTest();
    }
}