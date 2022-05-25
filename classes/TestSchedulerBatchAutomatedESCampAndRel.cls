/*
Purpose         :   Test class for Scheduler_BatchAutomatedESCampAndRelated

Created By      :   Dipesh Gupta

Created Date    :   03/04/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - Dipesh Gupta - 03/04/2020

Code Coverage   : 

*/
@isTest
private class TestSchedulerBatchAutomatedESCampAndRel 
{
	@testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        Account account = TestUtilities.CreateNewAccount(true);
        
        List<Contract> contracts = new List<Contract>();
        contracts.add(new Contract(Name = 'Test contract',Status = 'Draft', AccountId = account.Id, 
                                  StartDate = date.today(), ContractTerm = 1,Batch_Status__c = System.Label.Ready_For_Batch));
        contracts.add(new Contract(Name = 'Test contract2',Status = 'Draft', AccountId = account.Id,
                                  StartDate = date.today(), ContractTerm = 1,Batch_Status__c = System.Label.Ready_For_Batch));
        insert contracts;
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = account.Id, Program__c = program.Id));
        insert memberships;
        
        List<Product2> products = new List<Product2>();
        products.add(new Product2(Name = 'New Names', Family = System.Label.Enrollment_Services, Program__c = program.Id, IsActive = true,
                                  ProductCode = 'ESNN',SBQQ__SortOrder__c = 2,SBQQ__Component__c = true, Disregard_for_Revenue_Automation__c = false
                                 ));
        insert products;
        
         List<SBQQ__ProductFeature__c> features = new List<SBQQ__ProductFeature__c>();
        features.add(new SBQQ__ProductFeature__c(Name = 'Annual Fee', SBQQ__Number__c = 10, SBQQ__MinOptionCount__c = 1, SBQQ__MaxOptionCount__c = 1,
                                                 SBQQ__ConfiguredSKU__c = products[0].Id));
        insert features;
        
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[0].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true,
                                                     Create_Deployment__c = true, Create_Job_Ticket__c = false));
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[0].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true,
                                                     Create_Deployment__c = true, Create_Job_Ticket__c = false));
        productOptions.add(new SBQQ__ProductOption__c(SBQQ__ConfiguredSKU__c = products[0].Id, SBQQ__OptionalSKU__c = products[0].Id,
                                                      SBQQ__Number__c = 10, SBQQ__Quantity__c = 1, SBQQ__Feature__c = features[0].Id,
                                                      SBQQ__Type__c = 'Component', SBQQ__Selected__c = true, SBQQ__Required__c = true,
                                                     Create_Deployment__c = false, Create_Job_Ticket__c = true));

        insert productOptions;
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Membership__c = memberships[0].Id,
                                                    Program__c = program.Id, SBQQ__RequiredByProduct__c = products[0].Id, SBQQ__ProductOption__c = productOptions[0].Id ));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 2, Previous_Period_Plus_Uplift__c = 500,
                                                    SBQQ__ListPrice__c = 0, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Membership__c = memberships[0].Id,
                                                    Program__c = program.Id, SBQQ__ProductOption__c = productOptions[1].Id ));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,
                                                    SBQQ__ListPrice__c = 0, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Membership__c = memberships[0].Id,
                                                    Program__c = program.Id, SBQQ__RequiredByProduct__c = products[0].Id, SBQQ__ProductOption__c = productOptions[2].Id ));
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 2, Previous_Period_Plus_Uplift__c = 500,
                                                    SBQQ__ListPrice__c = 0, SBQQ__Product__c = products[0].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), Membership__c = memberships[0].Id,
                                                    Program__c = program.Id, SBQQ__ProductOption__c = productOptions[2].Id ));
        insert subscriptions;
        
        List<Subscription_Period__c> subscriptionPeriods = new List<Subscription_Period__c>();
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[0].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[1].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[2].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
         subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[2].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
         subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[3].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        insert subscriptionPeriods;

        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void testForBatchAutomatedESCampAndRelated()
    {
        List<Contract> contractList = [SELECT Id FROM Contract];
        System.assertEquals(2, contractList.size());
        
        Set<Id> contractIDs = new Set<Id>();
        
        for(Contract cont : contractList)
        {
        	contractIDs.add(cont.Id);    
        }
        
    	Test.startTest();
        Scheduler_BatchAutomatedProjAndRelated sch = new Scheduler_BatchAutomatedProjAndRelated(contractIDs);
        sch.execute(null);
        Scheduler_BatchAutomatedProjAndRelated.scheduleAfterMinutes(15,contractIDs);
       	/*String schCronExp = '0 0/15 * 1/1 * ? *';
        Scheduler_BatchAutomatedESCampAndRelated schESCAR = new Scheduler_BatchAutomatedESCampAndRelated(contractIDs);
        System.schedule('Test Sch',schCronExp,schESCAR);*/
        
        Test.stopTest();
    }
}