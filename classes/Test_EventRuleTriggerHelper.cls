/**
 *   Description     :   Test class for EventRuleTriggerHelper
 * 
 *   Revision Logs   :   V1.0 - 06/23/2021 - Chirag Soni - CR-20210504-15118 - created Test_createMembershipMtMRecords method.
 **/

@isTest
private class Test_EventRuleTriggerHelper {
    
    @testSetup static void setup() {
        
        //Bypass all trigger 
        Util.bypassAllTriggers = true;
        
        // create two new account
        Account account1 = TestUtilities.CreateNewAccount(true);
        Account account2 = TestUtilities.CreateNewAccount(true);
        
        //Create four contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ;i<=4 ;i++){
            if(i<=2)
                contacts.add(testUtilities.CreateNewContact(account1, false));
            else
                contacts.add(testUtilities.CreateNewContact(account2, false));
        }
        
        insert contacts;
        
        //create two programs records 
        Program__c program = TestUtilities.CreateNewProgram(true);
        program = TestUtilities.CreateNewProgram(true);
        program = TestUtilities.CreateNewProgram(true);
        program = TestUtilities.CreateNewProgram(true);
        
        // create two EAB event records 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        // create event record using cohort record type
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent.Short_Name__c = 'Cohort EAB Event 1';
        eabEvent.Public_Name__c = 'Cohort Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(eabEvent);
        
        // create event record using event record type
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'Event 2 - EAB Event 2';
        eabEvent.Public_Name__c = 'Event 2 EAB Event 2';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(eabEvent);
        
        insert eabEvents;
        
        Util.bypassAllTriggers = false;
    }
    
    // Created by - Chirag Soni - 06/23/2021 - CR-20210504-15118
    static testMethod void Test_createMembershipMtMRecords()
    {
        // Query account from setup 
        List<Account> accounts = [SELECT Id FROM Account];
        
        //Query contacts from setup
        List<Contact> contacts = [SELECT Id FROM Contact];
        
        //Query program from setup
        List<Program__c> programs = [SELECT Id FROM Program__c];
        
        //Query EAB Event from setup
        List<Advisory_Event__c> eabEvents = [SELECT Id FROM Advisory_Event__c];
        
        //Bypass all trigger 
        Util.bypassAllTriggers = true;
        
        //create four membership records on both the account
        List<Membership__c> memberships = new List<Membership__c>();
        
        // two membership record on first account
        memberships.add(new Membership__c(Name = 'Test Membership1 Account 1', Account_Name__c = accounts[0].Id,
                                          Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -001'));
        memberships.add(new Membership__c(Name = 'Test Membership2 Account 1', Account_Name__c = accounts[1].Id,
                                          Program__c = programs[1].Id, Membership_Status_Text__c = 'Member -002'));
        
        insert memberships;
        
        // create four registration records 
        List<Registration__c> registrations = new List<Registration__c>();
        
        //two registration on first event
        registrations.add(new Registration__c (Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
        registrations.add(new Registration__c (Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
        
        //two registration on second event
        registrations.add(new Registration__c (Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registered'));
        registrations.add(new Registration__c (Contact__c = contacts[3].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registered'));
        
        insert registrations;
        
        //Create four rule records 
        List<Rule__c> rules = new  List<Rule__c>();
        
        //create two rules record on first event
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[0].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[1].Id));
        
        //create two rules record on second event
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[2].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[3].Id));
        
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS = false;
        insert rules;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS = true;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();
        
        //create event rule record and test whether membershipMTMrecord created under registration or not
        List<Event_Rule__c> evntRules = new List<Event_Rule__c>();
        
        //create two event rules on first eab event whose program matches to registration's contact's institue active membership program
        evntRules.add(new Event_Rule__c(Advisory_Event__c=eabEvents[0].Id, 	Rule__c = rules[0].Id));
        evntRules.add(new Event_Rule__c(Advisory_Event__c=eabEvents[0].Id, 	Rule__c = rules[1].Id));
        
        //create another two event rule on second eab event where program is different on registration's contact's institue active membership program
        // rule 2 and 3 have different programs.
        evntRules.add(new Event_Rule__c(Advisory_Event__c=eabEvents[1].Id, 	Rule__c = rules[2].Id));
        evntRules.add(new Event_Rule__c(Advisory_Event__c=eabEvents[1].Id, 	Rule__c = rules[3].Id));
        
        insert evntRules;
        
        //query crated record of membershipMtM
        List<Membership_MtM__c> membershipMtm = [SELECT Membership__c, Registration__c, Registration__r.EAB_Event__c FROM Membership_MtM__c WHERE Registration__c IN :registrations ]; 
        
        //only two membership record are created on registration of first event
        System.assertEquals(2, membershipMtm.size());
        
        //assert to check eab event where membershipmtm record created on registrations
        System.assertEquals(eabEvents[0].Id, membershipMtm[0].Registration__r.EAB_Event__c);
        System.assertEquals(eabEvents[0].Id, membershipMtm[1].Registration__r.EAB_Event__c);
        
        //assert to check membership id 
        System.assertEquals(memberships[0].Id, membershipMtm[0].Membership__c);
        System.assertEquals(memberships[0].Id, membershipMtm[1].Membership__c);
        
        //assert to check registration id 
        System.assertEquals(registrations[0].Id, membershipMtm[0].Registration__c);
        System.assertEquals(registrations[1].Id, membershipMtm[1].Registration__c);
        
        Test.stopTest();
    }
}