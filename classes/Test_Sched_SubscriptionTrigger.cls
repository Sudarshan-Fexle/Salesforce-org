/**
 *  Description     :   This Apex Test class used to test the class "Sched_SubscriptionTrigger" functionality.
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   07/23/2019
 * 
 *  Revision Logs   :   V_1.0 - Created (CR-20181019-12685) 
 *
 **/
@isTest(seeAllData=false)
public class Test_Sched_SubscriptionTrigger {
    
    static testMethod void unitTest1(){
    	
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;

        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
                
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        
        //Record type for subscription
        subscription.recordTypeId = recordTypes[0].Id;

        List<SBQQ__Subscription__c> listSubscriptions = new List<SBQQ__Subscription__c>();
		listSubscriptions.add(subscription);
        
        //Insert Subscriptions
        insert listSubscriptions;        
        
        //Testing start here
        Test.startTest();

        Util.byPassAllTriggers = false;
        Boolean isInsertCase = true;
        
        //Call Scheduler from here
        Sched_SubscriptionTrigger.scheduleSubscriptionTrigger(listSubscriptions, isInsertCase);
        
        //Testing start here
        Test.stopTest();
		
        
    }
}