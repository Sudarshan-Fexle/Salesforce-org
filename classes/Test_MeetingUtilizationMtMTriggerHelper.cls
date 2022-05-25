/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*/

@isTest(seeAllData = false)
private class Test_MeetingUtilizationMtMTriggerHelper {
    
    /*
    Purpose         :   This method for Test MeetingUtilizationMtMTriggerHelper class.
                
    Create By       :   Dipesh Gupta
    
    Created Date    :   11/02/2020

	*/
    static testMethod void testUnit()
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // Account
        Account acc = TestUtilities.CreateNewAccount(true);
        List<Account> accList = [Select Id From Account];
        //Asserting for the results
        System.assert(accList != null);
        System.assert(accList.size() > 0);
        
        // Program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        List<Program__c> programList = [Select Id From Program__c];
        //Asserting for the results
        System.assert(programList != null);
        System.assert(programList.size() > 0);
        
        // Membership
        Membership__c mem = TestUtilities.CreateNewMembership(acc.Id, prog.Id, false);
        insert mem;
        
        List<Membership__c> membershipList = [Select Id From Membership__c];
        //Asserting for the results
        System.assert(membershipList != null);
        System.assert(membershipList.size() > 0);
        
        //Record types for "Advisory_Event__c" object
        List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                    WHERE IsActive = true 
                                    AND SobjectType = 'Advisory_Event__c' LIMIT 1];
        //Asserting for the results
        System.assert(rdTypes != null);
        System.assert(rdTypes.size() > 0);
      
        // Advisory_Event__c
        Advisory_Event__c advEvent = new Advisory_Event__c();
        advEvent.Begins__c = System.today();
        advEvent.Budget__c = 5534;
        advEvent.RecordTypeId = rdTypes[0].Id;
        insert advEvent;
        
        List<Advisory_Event__c> advEventList = [Select Id From Advisory_Event__c];
        //Asserting for the results
        System.assert(advEventList != null);
        System.assert(advEventList.size() > 0);
        
        //Record types for "Rule__c" object
        List<RecordType> rdTypes2 = [SELECT ID FROM RecordType 
                                    WHERE IsActive = true 
                                    AND SobjectType = 'Rule__c' LIMIT 1];
        
        //Asserting for the results
        System.assert(rdTypes2 != null);
        System.assert(rdTypes2.size() > 0);
        
        
        // Rule__c
        // byPass Trigger
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = false;
        Rule__c ruleString = new Rule__c();
        ruleString.Program__c = prog.Id;
        ruleString.Advisory_Event__c = advEvent.Id;
        ruleString.RecordTypeId = rdTypes2[0].Id;
        insert ruleString;
        
        List<Rule__c> ruleList = [Select Id From Rule__c];
        //Asserting for the results
        System.assert(ruleList != null);
        System.assert(ruleList.size() > 0);
        
        // Event_Rule__c
        Event_Rule__c evtRule = new Event_Rule__c();
        evtRule.Advisory_Event__c = advEvent.Id;
        evtRule.Rule__c = ruleString.Id;
        insert evtRule;
        
        List<Event_Rule__c> eventRuleList = [Select Id From Event_Rule__c];
        //Asserting for the results
        System.assert(eventRuleList != null);
        System.assert(eventRuleList.size() > 0);
        
        Meeting_Utilization__c mU = new Meeting_Utilization__c();
        mU.Name = 'test';
        insert mU;
        
        List<Meeting_Utilization__c> meetingUtilList = [Select Id From Meeting_Utilization__c];
        //Asserting for the results
        System.assert(meetingUtilList != null);
        System.assert(meetingUtilList.size() > 0);
        
        
        //List of Meeting Utilization MtM to be update
        List<Meeting_Utilization_MtM__c> listOfMUMtM = new List<Meeting_Utilization_MtM__c>();
        listOfMUMtM.add( new Meeting_Utilization_MtM__c (Meeting_Utilization__c = mU.Id,Membership__c = mem.Id, Event_Rule__c = evtRule.Id));
        
        insert listOfMUMtM;
        
        
        
        
    }
    

}