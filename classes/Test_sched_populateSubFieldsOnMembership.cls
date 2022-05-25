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


// CreatedBy - Mahendra Swarnkar - 09/21/2021 - CR-20210831-15398
@isTest
private class Test_sched_populateSubFieldsOnMembership {
	
    @testSetup
    static void testDataSetup(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        //Creating account record
        Account account = TestUtilities.CreateNewAccount(false);
        account.MSA_Date__c = Date.today();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US Education').getRecordTypeId(); 
        insert account;
        
        Contract contract = TestUtilities.createNewStandardContract(account.Id, true);
        System.assert(contract.Id != null);
        
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
        programs[0].Large_Contract_Threshold__c =  17;
        
         //Inserting Program
         insert programs;
        
        //Insert product
        List<Product2> products = new List<Product2>();
         
        products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
        insert products;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //Insert Subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000, SBQQ__Contract__c = contract.Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id, Program__c = programs[0].Id, SBQQ__Account__c = account.Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Status__c = 'Committed', Official_Drop_Date__c = Date.today(), SBQQ__Product__c = products[0].Id));
        insert subscriptions;
        
        //Getting record type id
        List<RecordType> recordType = [Select Id From RecordType Where SobjectType = 'Opportunity' AND RecordType.DeveloperName = 'EAB_Initiating' LIMIT 1];
        
        //Creating Opportunity record
        Opportunity opportunity = TestUtilities.CreateNewOpportunity(false);
        opportunity.RecordTypeId = recordType[0].Id;
        opportunity.StageName = '0-MQL';
        insert opportunity;
    }
    
    static testMethod void test_populateSubscriptionFieldsOnMembershipFuture(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Account account = [Select Id From Account Limit 1];
        Program__c program = [Select Id From Program__c Limit 1];
        Contract contract = [Select Id From Contract Limit 1];
        
        SBQQ__Subscription__c subscription = [Select Id, Status__c From SBQQ__Subscription__c Limit 1];
        subscription.Status__c = 'Committed';
        update subscription;
        
        // Create Contract_Integrated_Accounts__c record.
        Contract_Integrated_Accounts__c cia = new Contract_Integrated_Accounts__c();
        cia.Account__c = account.Id;
        cia.LOA_Contract__c = contract.Id;
        insert cia;
        
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
        
        Test.startTest();
        
        
        sched_populateSubFieldsOnMembership.schedule_populateSubFieldsOnMembership(new Set<Id>{contract.Id}, null, false);
        
        Test.stopTest();
        membership = [Select Id, Earliest_Subscription__c From Membership__c Limit 1];
        System.assert(membership.Earliest_Subscription__c != null);
    }
    
    static testMethod void test_createMembershipsFuture(){
         //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        Account account = [Select Id From Account Limit 1];
        Program__c program = [Select Id From Program__c Limit 1];
        Contract contract = [Select Id From Contract Limit 1];
        
        Test.startTest();
        
        // Create Contract_Integrated_Accounts__c record.
        Contract_Integrated_Accounts__c cia = new Contract_Integrated_Accounts__c();
        cia.Account__c = account.Id;
        cia.LOA_Contract__c = contract.Id;
        insert cia;
        
        sched_populateSubFieldsOnMembership.schedule_populateSubFieldsOnMembership(null, new Set<Id>{cia.Id}, true);
        
        Test.stopTest();
        
        List<Membership__c> membership = [Select Id, Account_Name__c, Program__c, Membership_Status_Text__c From Membership__c];
        System.assertEquals(1, membership.size());
        System.assertEquals(account.Id, membership[0].Account_Name__c);
        System.assertEquals(program.Id, membership[0].Program__c);
        System.assertEquals('Membership Integrated', membership[0].Membership_Status_Text__c);
    }
}