/**
* 
*	Purpose         :   Test class for Batch_AutomatedProjectAndRelated
*
*	Created By      :   Dipesh Gupta
*
*	Created Date    :   03/04/2020
*
*	Current Version :   v1.0
*
*	Revision Log    :   V_1.0 Created - Dipesh Gupta - 03/04/2020
*		   	    V_1.1 10/01/2020 - CR-20200626-14231 - Victor Hanson - updated to verify job code
*		            V_1.2 07/01/2021 - CR-20200924-14551 - Shalu Sharma - Check new Changes related to the CR
*	Code Coverage   : 
*
**/
@IsTest
private class Test_Batch_AutomatedProjectAndRelated
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
        //Modified By - Shalu Sharam - 07/01/2021 - Modified Contract Id Corresponding to the Subscription perirod
        subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[1].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[2].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        
         subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[0].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[2].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        
         subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[1].Id, Institution__c= account.Id,
                                                           Decision_Type__c = 'Fixed Term', Total_Paper_only_Contract_Quantity__c = 3,
                                                           Period_Start_Date__c=Date.today(), Period_End_Date__c=Date.today().addYears(1),
                                                           Program_Subscription__c = subscriptions[3].Id, Segment_Index__c = 3, Source_Opportunity__c = opp.Id,
                                                           Stage__c = 'Honorary'));
        
         subscriptionPeriods.add(new Subscription_Period__c(Name = 'Test SP',Year__c = '2020', Contract__c = contracts[1].Id, Institution__c= account.Id,
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
       
        Batch_AutomatedProjectAndRelated eSAR = new Batch_AutomatedProjectAndRelated(contractIDs);
        DataBase.executeBatch(eSAR);
        
        Test.stopTest();
        
        //10/01/2020 - CR-20200626-14231 - Victor Hanson - verify job code is populated
        List<Job_Ticket__c> jts = [SELECT Id, Job_Code__c, Subscription_Period__r.Job_No__c FROM Job_Ticket__c WHERE Subscription_Period__r.Job_No__c != null];
        system.assertNotEquals(0, jts.size());
        system.assertEquals(jts[0].Subscription_Period__r.Job_No__c, jts[0].Job_Code__c);
    }
    
    //Added by - 07/01/2021 - CR-20200924-14551 - Shalu Sharma - test class for the batch
    static testMethod void testForBatchAutomatedESCampAndRelated_1()
    {
        List<Contract> contractList = [SELECT Id FROM Contract];
        System.assertEquals(2, contractList.size());
                
        String query = 'SELECT Id, Batch_Status__c FROM Contract WHERE Id IN : contractIds';
        
        Set<Id> contractIDs = new Set<Id>();
        
    	Test.startTest();

        try{
            //Calling Batch
            Batch_AutomatedProjectAndRelated eSAR = new Batch_AutomatedProjectAndRelated(contractIDs, query);
            DataBase.executeBatch(eSAR);
        }
        Catch(exception e){
            //check exception
            System.assertEquals(System.Label.Set_Parameter_Value,e.getMessage());
        }
        
        //Loop Over the ContractList
        for(Contract cont : contractList)
        {
        	contractIDs.add(cont.Id);    
        }
        
        //Calling Batch Again
		Batch_AutomatedProjectAndRelated eSAR1 = new Batch_AutomatedProjectAndRelated(contractIDs, query); 
        
        try{
        	DataBase.executeBatch(eSAR1);
        }
        Catch(exception e){
            System.assertEquals(System.Label.Set_Parameter_Value,e.getMessage());
        }
        
        //Calling Batch Again
		Batch_AutomatedProjectAndRelated eSAR2 = new Batch_AutomatedProjectAndRelated(contractIDs, query);
        
        try{
            DataBase.executeBatch(eSAR2);
        }
        Catch(exception e){
            System.assertEquals(System.Label.Set_Parameter_Value,e.getMessage());
        }
        
        Test.stopTest();
        
        //Asserts on Project Records to check duplicate isn't created
        List<Project__c> projectRecords = [Select Contract2__c, Id, Fiscal_Year__c, Product2__c, Product__c, Subscription_Period__c From Project__c];
        System.assertEquals(2, projectRecords.size());
        System.assert(eSAR1.getUniqueKey(projectRecords[0]) != eSAR1.getUniqueKey(projectRecords[1]));
        
        //Asserts on JT Records to check duplicate isn't created
        List<Job_Ticket__c> jts = [SELECT Id, Job_Code__c, Subscription_Period__r.Job_No__c FROM Job_Ticket__c WHERE Subscription_Period__r.Job_No__c != null];
        system.assertNotEquals(0, jts.size());
        system.assertEquals(jts[0].Subscription_Period__r.Job_No__c, jts[0].Job_Code__c);

    }
    
}