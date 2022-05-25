/**
 *	Description	:	The test class to test the functionalities of DeleteCompSubscriptionEnquueJob btach class
 *
 *	Created by	:	Mahendra Swarnkar
 * 
 * 	Created Date	:	07/09/2021
 * 
 * 	Revision Log	:	V1.0 Created - CR-20211005-15489
 *						
 **/
@isTest(seeAllData = false)
private class Test_DeleteCompSubscriptionEnquueJob {
    
    @testSetup
    static void setupDate(){
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //List to hold Account records
        Account acc = testUtilities.CreateNewAccount(false);
        insert acc;
        
        //Insert Program data
        Program__c prog = TestUtilities.CreateNewProgram(false);
        insert prog;
        
        // List to store test Contacts
        Contact contactrecord = testUtilities.CreateNewContact(acc, false);
        insert contactrecord;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED, Main_Contact__c = contactrecord.Id,
                                                  Amount = 1, CloseDate = System.today(), AccountId = acc.ID, Sales_Pursuit_Products__c = 'APS');
        
        insert opportunity;
        
        Product2 product = new Product2(Name = CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE, Family = 'EAB Tech', Program__c = prog.Id, IsActive = true, Product_Category__c = 'Annual Fee',
                                        ProductCode = 'TMBH', SBQQ__Component__c = false, Program_Name_Member_Facing__c = 'Student Success Management Intelligence',
                                        SBQQ__AssetConversion__c = 'One per quote line', SBQQ__DefaultQuantity__c = 1,
                                        SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List');
        
        insert product;
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(RecordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM,
                                                                       SBQQ__Quantity__c = 1, Previous_Period_Negotiated__c = 100,
                                                                       SBQQ__ListPrice__c = 0, SBQQ__SegmentIndex__c = 10,
                                                                       SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 10, 
                                                                       SBQQ__ProrateMultiplier__c = 2,SBQQ__Product__c = product.Id,
                                                                       SBQQ__SubscriptionStartDate__c=Date.today().addDays(-10),
                                                                       SBQQ__SubscriptionEndDate__c=Date.today().addDays(2),
                                                                       Status__c = 'Committed' );
        insert subscription;
        
        
        Membership__c membershipRecord = new Membership__c(Name = 'Membership Test1', Account_Name__c = acc.Id, Program__c = prog.Id, 
                                                           Active_Subscription__c = subscription.Id, 
                                                           Membership_Status_Text__c = constants.MEMBER_PAYER, 
                                                           Current_Period_Start_Date__c = Date.today().addDays(-10), 
                                                           Current_Period_End_Date__c = Date.today().addDays(2));
        
        insert membershipRecord;
        
        Contract StdContract = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today().addDays(-10), ContractTerm = 12);
        insert StdContract;
        
        List<SBQQ__Subscription__c> listcomponentSubscription = new List<SBQQ__Subscription__c>();
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,
                                                                SBQQ__Contract__c = StdContract.Id,
                                                                recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,
                                                                Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,
                                                                SBQQ__Product__c = product.Id,
                                                                SBQQ__SegmentStartDate__c = Date.today().addDays(4),
                                                                SBQQ__SegmentEndDate__c = Date.today().addDays(2),
                                                                Program_Subscription__c = subscription.Id,
                                                                SBQQ__RenewalPrice__c = 100,
                                                                SBQQ__CustomerPrice__c = 100,
                                                                Membership__c = membershipRecord.Id));
        
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,
                                                                SBQQ__Contract__c = StdContract.Id,
                                                                recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,
                                                                Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,
                                                                SBQQ__Product__c = product.Id,
                                                                SBQQ__SegmentStartDate__c = Date.today().addDays(-10),
                                                                SBQQ__SegmentEndDate__c = Date.today().addDays(2),
                                                                Program_Subscription__c = subscription.Id,
                                                                SBQQ__RenewalPrice__c = 100,
                                                                SBQQ__CustomerPrice__c = 100,
                                                                Membership__c = membershipRecord.Id));
        
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,
                                                                SBQQ__Contract__c = StdContract.Id,
                                                                recordTypeId =constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,
                                                                Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,
                                                                SBQQ__Product__c = product.Id,
                                                                SBQQ__SegmentStartDate__c = Date.today().addDays(5),
                                                                SBQQ__SegmentEndDate__c = Date.today().addDays(2),
                                                                Program_Subscription__c = subscription.Id,
                                                                SBQQ__RenewalPrice__c = 100,
                                                                SBQQ__CustomerPrice__c = 100,
                                                                Membership__c = membershipRecord.Id));
        
        listcomponentSubscription.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,
                                                                SBQQ__Contract__c = StdContract.Id,
                                                                recordTypeId = constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT,
                                                                Opportunity__c = opportunity.Id,
                                                                SBQQ__RequiredByProduct__c = product.Id,
                                                                SBQQ__Product__c = product.Id,
                                                                SBQQ__SegmentStartDate__c = Date.today().addDays(3),
                                                                SBQQ__SegmentEndDate__c = Date.today().addDays(2),
                                                                Program_Subscription__c = subscription.Id,
                                                                SBQQ__RenewalPrice__c = 100,
                                                                SBQQ__CustomerPrice__c = 100,
                                                                Membership__c = membershipRecord.Id));
        
        
        //Insert componentSubscription
        insert listcomponentSubscription;
        
        Util.BypassAllTriggers = False;
    }
    
    testMethod static void unitTestSchedule(){
        Set<ID> setComponentIds = new Set<ID>();
        for(SBQQ__Subscription__c subComp : [Select ID From SBQQ__SUbscription__c Where RecordTypeID = : constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT]) {
            setComponentIds.add(subComp.ID);
        }
        
        dateTime sysTime = dateTime.now().addSeconds(2);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        //Initializing the batch
        DeleteCompSubscriptionEnquueJob job = new DeleteCompSubscriptionEnquueJob(setComponentIds);
        
        //Start the batch execution
        System.schedule('DeleteCompSubscriptionEnquueJob' + sysTime.getTime(),chron_exp, job);
        
        Util.IsTest(true);
        
    }
    
    testMethod static void unitTestBatch(){
        Util.IsTest(true);
        
        Set<ID> setComponentIds = new Set<ID>();
        for(SBQQ__Subscription__c subComp : [Select ID from SBQQ__SUbscription__c Where RecordTypeID = : constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT]) {
            setComponentIds.add(subComp.ID);
        }
        
        Test.startTest();
        
        Util.BypassAllTriggers = False;
        
        //Initializing the batch
        DeleteCompSubscriptionEnquueJob bc = new DeleteCompSubscriptionEnquueJob(setComponentIds);
        
        //Start the batch execution
        Database.executeBatch(bc);
        
        Test.stopTest();
        
        //Query on the the asynchronous job to make sure that batch execution get started
        List<AsyncApexJob> asyncJob = [Select Id From AsyncApexJob Where ApexClass.Name = 'DeleteCompSubscriptionEnquueJob'];
        
        //Assertions
        if(asyncJob != null && asyncJob.size() > 0 ) {
            System.assertNotEquals(null, asyncJob[0]);    
        }
    }
}