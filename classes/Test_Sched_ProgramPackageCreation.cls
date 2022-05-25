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
/**
 *  Purpose         :   Test class for Sched_SubscriptionPeriodCreation
 *
 *  Created By      :   Mahendra Swarnkar
 *  
 *  Created Date    :   07/23/2019 
 *
 *  Revision Log    :   V1.0 -
 *			V1.1 - 07/30/2021 - Modified By - Subhash Garhawal - CR-20210726-15311 - Added a new Method getFiscalYear
 *
 *  Code Coverage   :	
 *
 **/
@isTest(SeeAllData = false)
private class Test_Sched_ProgramPackageCreation {

    static testMethod void myUnitTest() {
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Variable to hold the Current fiscal year 
        integer currentFY = shift_get_fiscal_year.current();

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
        
        //Create Membership Period records
        Program_Package__c ppkTemp = new Program_Package__c ( Account__c = account.id, Name = 'ShiftTest', Membership__c = membership.Id,
                                                              Fiscal_Year__c = string.ValueOf(currentFY - 1) ,
                                                              Client_Status_New__c = 'In Play');
        
        //Insert Program package
        insert ppkTemp;
        
        //Modified By - Subhash Garhawal - CR-20210726-15311
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Creating Opportunity record
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        // insert quote
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);  
        quote.LOA_Signature_Date__c = date.today();
        quote.Sync_Calculator_Update_Date__c = date.today()+10;
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;
        
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.Contract_Signature_Date__c = Date.today();
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        //List of opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(opp);
        
        //Update
        update opportunities;
        
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = recordTypes[0].Id;
        subscription.Opportunity__c = opportunities[0].Id;

        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
	listSubscriptions.add(subscription);
        
        //Insert Subscriptions
        insert listSubscriptions;

        //Creating Subscription Period record
        Subscription_Period__c sPeriod = TestUtilities.createNewSubscriptionPeriod(listSubscriptions[0].Id, false);
        
        sPeriod.Institution__c = account.Id;
        sPeriod.Period_End_Date__c = Date.Today();
        sPeriod.Membership_Lookup__c =  membership.Id;
        sPeriod.Program_Package__c = ppkTemp.Id;
        
        //List of subscription Period.
        List<Subscription_Period__c> listSubscriptionPeriods = new List<Subscription_Period__c>();
	listSubscriptionPeriods.add(sPeriod);
        
	//Insert the listOfSubscriptionPeriod
        insert listSubscriptionPeriods;
        
	// update subscription with subscription period.
	listSubscriptions[0].Subscription_Period__c = listSubscriptionPeriods[0].Id;
        listSubscriptions[0].Source_Opportunity__c = opportunities[0].Id;
        update listSubscriptions;
        
        //Test starts from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        
        //instance of Scheduler
        Sched_ProgramPackageCreation sh1 = new Sched_ProgramPackageCreation(listSubscriptionPeriods);
        //Sched_ProgramPackageCreation.scheduleProgramPackageCreation(listSubscriptionPeriods);
        
        //Cron expression string
        String sch = '0 0 23 * * ?';
        
        //schedule the scheduler
        system.schedule('Test Schedule', sch, sh1);
        
	//Modified By - Subhash Garhawal - CR-20210726-15311
        String year = Sched_ProgramPackageCreation.getFiscalYear(date.today());
        System.assertEquals(String.valueOf(date.today().Year()), year);
        //Test stops from here
        Test.stopTest(); 
        
        List<Program_Package__c> pPackages = [Select Id, Contract_Sent__c, Proposal_Sent__c From Program_Package__c];
        System.assert(pPackages.size() == 2);
        
        for(Program_Package__c pp: pPackages){
            if(pp.Contract_Sent__c != null){
                System.assertEquals(pp.Contract_Sent__c, quote.LOA_Signature_Date__c);
            }
            if(pp.Proposal_Sent__c != null){
                System.assertEquals(pp.Proposal_Sent__c, quote.Sync_Calculator_Update_Date__c);
            }
        }
        
    }
}