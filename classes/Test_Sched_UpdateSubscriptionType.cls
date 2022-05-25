/**
 *  @description    :   This is test class for Sched_UpdateSubscriptionType class
 *  Create By       :   Nikita Kumari - CR-20211005-15489
 *  Created Date    :   07/09/2021
 **/ 
@isTest(seeAllData = false)
public with sharing class Test_Sched_UpdateSubscriptionType {
    static testMethod void Test_Sched_UpdateSubscriptionType() {
        
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
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
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert programs;
        
        //Insert Products
        List<Product2> products = new List<Product2>();
        
        //Add new Products in List
        products.add(new Product2(Name = 'TMBH - Test Method', Family = 'EAB Tech', Program__c = programs[0].Id, IsActive = true,
                                  ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                  SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                  SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List'));
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert products;
        
        //Get Record Type
        Id accountUSCorporateRecordType = TestUtilities.FindRecordTypeId('Account', 'US Education'); 
        
        //List to hold Institution records
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test AAccount', Status__c = 'Active' ));
        accounts.add(new Account(RecordTypeId = accountUSCorporateRecordType, Name = 'Test BAccount', Status__c = 'Active' ));
        
        //Insert
        insert accounts;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Account_Name__c = accounts[0].Id, Program__c = programs[0].Id));
        memberships.add(new Membership__c(Account_Name__c = accounts[1].Id, Program__c = programs[0].Id));
        
        insert memberships;
        
        //SOQL over the opportunity Record Type0
        List<RecordType> conRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Contact' AND DeveloperName = 'Employee' AND IsActive = true];
        
        //Create contact
        Contact contact = new Contact(FirstName = 'Sub Test', LastName = 'Contact', AccountId = accounts[0].Id, Contact_Status__c = 'Active', recordTypeId = conRType[0].Id);
        
        //Insert
        insert contact;
        
        //List to hold Invoice Billing Schedule
        List<Invoice_Billing_Schedule__c> invoices = new List<Invoice_Billing_Schedule__c>();
        
        //Add record to list
        invoices.add(new Invoice_Billing_Schedule__c(Institution__c = accounts[0].Id));
        
        //Insert IBS
        insert invoices;
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        
        //Add record to list
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                       Year__c = '2021', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Year with Opt Out'));
        contracts.add( new Contract__c(Name = 'TestContract1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                       Year__c = '2021', Type__c = 'NBB', Main_Contact__c = contact.Id, Invoice_Contact__c = contact.Id,
                                       Negotiated_Amount__c = 12, Invoice_Billing_Schedule__c = invoices[0].Id,Term_Type__c ='Fixed Term'));
        //Insert the contract ABC
        insert contracts;
        
        //SOQL over the opportunity Record Type
        List<RecordType> oppRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'EAB_Initiating' AND IsActive = true];
        
        //Insert Opportunity
        Opportunity eABInitOpp = TestUtilities.CreateNewOpportunity(false);
        eABInitOpp.RecordTypeId = oppRTypes[0].Id;
        eABInitOpp.AccountId = accounts[0].Id;
        eABInitOpp.Name = 'Sub Test Opp';
        eABInitOpp.CloseDate = System.today().addMonths(1);
        eABInitOpp.StageName = '0-Exploring';
        eABInitOpp.Main_Contact__c = contact.Id;
        
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Insert
        insert eABInitOpp;
        
        //SOQL over the Proposal record types
        List<RecordType> proposalRTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'SBQQ__Quote__c' AND DeveloperName IN ('Open', 'Locked') AND IsActive = true ORDER BY DeveloperName DESC];
        
        //List of Proposal
        List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
        
        //Add new proposal record in list
        proposals.add(new SBQQ__Quote__c(SBQQ__Type__c = 'Quote', SBQQ__Primary__c = true, 
                                         SBQQ__StartDate__c = Date.today(), SBQQ__SubscriptionTerm__c =36,
                                         SBQQ__EndDate__c = System.today().addYears(3), SBQQ__Opportunity2__c = eABInitOpp.Id, 
                                         SBQQ__Status__c = 'Draft', SBQQ__PrimaryContact__c = contact.Id,
                                         SBQQ__Account__c = accounts[0].Id, SBQQ__SalesRep__c = Userinfo.getUserId(),RecordTypeId = proposalRTypes[0].Id, 
                                         SBQQ__Pricebook__c = Test.getStandardPricebookId(), SBQQ__PricebookId__c=Test.getStandardPricebookId()));
        
        
        
        //Insert list of Quote
        insert proposals;
        
        //Add Proposal Lines under the Proposal
        SBQQ__QuoteLine__c mainProposalLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = proposals[0].Id, SBQQ__Product__c = products[0].Id, SBQQ__Number__c = 11,
                                                                     SBQQ__Quantity__c = 1, SBQQ__ProrateMultiplier__c = 4, SBQQ__SpecialPrice__c = 0,
                                                                     SBQQ__PricingMethod__c = 'List', Annual_Increase__c = 5, Calculator__c = 'Calculator - BHAN : 12 : NBB',
                                                                     SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        //Insert list of Quote
        insert mainProposalLine;
        
        //Update Proposal
        proposals[0].ApprovalStatus__c = 'Approved';
        proposals[0].SBQQ__Status__c = 'Approved';
        proposals[0].SBQQ__DocumentStatus__c = 'Signed - Manual Upload';
        
        update proposals;
        
        //Update Proposal
        proposals[0].SBQQ__Status__c = 'Locked';
        proposals[0].RecordTypeId = proposalRTypes[1].Id;
        
        update proposals;
        
        //Update Opportunity
        eABInitOpp.StageName = 'Contract Received - Send to Finance';
        eABInitOpp.Contract_Signature_Date__c = System.today();
        eABInitOpp.SBQQ__Contracted__c = true;
        
        update eABInitOpp;
        
        eABInitOpp.StageName = 'Closed Won';
        eABInitOpp.Signed_Opportunity_Contract__c = contracts[0].Id;
        
        update eABInitOpp;
        
        
        // contract
        List<Contract> stdContract = new List<Contract>();
        stdContract.add(new Contract(AccountId = accounts[0].Id, SBQQ__Opportunity__c = eABInitOpp.Id, SBQQ__Quote__c = proposals[0].Id,Status = 'Draft'));
        stdContract.add(new Contract(AccountId = accounts[0].Id, SBQQ__Opportunity__c = eABInitOpp.Id, SBQQ__Quote__c = proposals[0].Id,Status = 'Draft'));
        
        //Insert
        insert stdContract;
        
        stdContract[0].Status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED;
        stdContract[0].Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_UPSELL;
        stdContract[1].Status = CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED;
        stdContract[1].Amendment_Type__c = CPQConstants.CONTRACT_AMENDMENT_TYPE_UPSELL;
        
        //Insert
        update stdContract;
        
        
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription.Opportunity__c = eABInitOpp.Id;
        subscription.Source_Opportunity__c = eABInitOpp.Id;
        subscription.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription.SBQQ__Product__c = products[0].Id;
        subscription.SBQQ__SegmentStartDate__c = Date.today();
        subscription.Profit_m__c = 788;
        subscription.SBQQ__Contract__c = stdContract[0].Id;
        subscription.Status__c = 'Void-Amended';
        
        SBQQ__Subscription__c subscription2 = TestUtilities.createNewSubscription(memberships[0].Id, false);
        
        //Record type for subscription
        subscription2.recordTypeId = CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM;
        subscription2.Opportunity__c = eABInitOpp.Id;
        subscription2.Source_Opportunity__c = eABInitOpp.Id;
        subscription2.SBQQ__RequiredByProduct__c = products[0].Id;
        subscription2.SBQQ__Product__c = products[0].Id;
        subscription2.SBQQ__SegmentStartDate__c = Date.today();
        subscription2.Profit_m__c = 788;
        subscription2.SBQQ__Contract__c = stdContract[0].Id;
        subscription2.Status__c = 'Void-Amended';
        
        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
        listSubscriptions.add(subscription);
        listSubscriptions.add(subscription2); 
        
        //Insert Subscriptions
        insert listSubscriptions;
        
        Util.BypassAllTriggers = false;
        
        test.startTest();
        //Schedule the Job
        System.Schedule('Test Sched_UpdateSubscriptionType','0 0 * * * ?', new Sched_UpdateSubscriptionType());
        test.stopTest();
        
        List<AsyncApexJob> asyncApexJob = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        
        System.assertEquals('Sched_UpdateSubscriptionType', asyncApexJob[0].ApexClass.Name);
        System.assertEquals('Sched_UpdateSubscriptionType', jobsApexBatch[0].ApexClass.Name);
        
    }
}