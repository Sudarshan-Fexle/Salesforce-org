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
 *  Purpose     :   Test class for Test_TriggerRule.
 *               
 *  Create By   :   
 *   
 *  Created Date:   
 *   
 *  Revision Log:   V1.1 - Created
 *                  V1.2 - Modified By Saurabh Kumar - CR-20200819-14447 - 10/13/2020: Replaced Meeting with EAB Event
 *                  V1.3 - Modified By Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
 *                  V1.4 - Modified By Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
 *                  V1.5 - Modified By - Neha Sharma - 04/14/2021 - CR-20210324-15023
 *                  V1.6 - Modified By - Chirag Soni - 08/19/2021 - modified setup method 
 *                  V1.7 - Modified By - Nikita Kumari - 09/28/2021 - CR-20210910-15426 - updated Duplicate Program Acronym
 *                  V1.8 - Modified By - Chirag Soni - CR-20210608-15200 - 08/12/2021
**/
@isTest
private class Test_TriggerRule {
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    private static String meetingGUID = '000-000-001';
    
    @testSetup static void setup() {
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Saweda';
        update user1;
        
        Util.BypassAllTriggers = true;
        
        //Create the new account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create the new contact record
        Contact contact = testUtilities.CreateNewContact(false);
        contact.AccountId = account.Id;
        insert contact;
        
        //Create a test program record
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'Test Program KT', Program_Acronym__c = '01'));
        programs.add(new Program__c(Name = 'Test Program SecondKT', Program_Acronym__c = '02'));
        insert programs;
        
        //Create the new event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Primary_Program__c  = programs[0].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY;
        insert cohortEvent;
        
        //create the child record
        Advisory_Event__c childEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEvent.Rules_Programs__c =  Constants.EAB_EVENT_RULE_PROGRAMS_USE_PARENT_RULES;
        childEvent.Parent_Event__c = cohortEvent.Id;
        insert childEvent;
        
        //Create the new Membership records
        Membership__c membership = new Membership__c( Name = 'Test Membership 1', Account_Name__c = account.Id,
                                                     Program__c = programs[0].Id,Membership_Status_Text__c = 'Member -001');
        
        insert membership;
        
        // Commented by Chirag Soni - 08/19/2021 - Commented because below registration record to prevent unnecessary mock  call out 
        //Create the new Registration record
        /*  Registration__c registration = new Registration__c();
            registration.Contact__c = contact.Id;
            registration.EAB_Event__c = cohortEvent.Id;
            insert registration; */
        
        Util.BypassAllTriggers = false; 
        
    }
    
    
    //test Uniqueness of rules
    static testMethod void testValidateRulesUniqueness() {
        
        //Start test from here
        Test.startTest();
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Create the new records
        rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should throw an error for unique data
        try {
            RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
            insert rules;
            
            //Fail test method, if records were passed
            System.assert(false, 'This was supposed to throw exception');
            
        } catch(Exception e) {
            
            //Pass the test
            System.assert(true);
        }
        
        //Stop test here
        Test.stopTest();
        
        //Query rules from database and assert for results
        rules = [Select Id from Rule__c];
        System.assertEquals(1, rules.size());
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testValidatePrimaryRuleWhenNoRuleExistAlready() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
                                        where SObjectType = 'Rule__c' 
                                        AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM 
                                        AND IsActive = true];
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        
        //Start test from here
        Test.startTest();
        
        //Modified By - Neha Sharma - 04/26/2021 - MRS 2.0 Test class fixes
        //Create a Rule record
        Rule__c rule = new Rule__c(Name = 'Test', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1,Primary__c=true);
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rule;
        
        //Stop Test here
        Test.stopTest();
        
        //This rule should be marked as Primary
        rule = [Select Primary__c, Advisory_Event__r.Primary_Program__c from Rule__c where Id =: rule.Id];
        System.assert(rule.Primary__c);
        System.assertEquals(program.Id, rule.Advisory_Event__r.Primary_Program__c);
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testValidatePrimaryRuleWhenPrimaryRulesExistAlready() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
                                        where SObjectType = 'Rule__c' 
                                        AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_PROGRAM 
                                        AND IsActive = true];
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        //Modified By - Nikita Kumari - 09/28/2021 - CR-20210910-15426 - Program_Acronym__c = 'Test' to 'Test1'
        Program__c program2 = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test1');
        insert program2;
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;

        //Create a Rule record
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Name = 'ATest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'A-Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1, Primary__c = true));
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Start Test
        Test.startTest();
        
        //Create a Rule record
        rules = new List<Rule__c>();
        rules.add(new Rule__c(Name = 'BTest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'B-Test', Threshold_Type__c = 'Test', Program__c = program2.Id, Threshold_Number__c = 1, Primary__c = true));
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Stop Test here
        Test.stopTest();
        
        //Fetch the rules order by created date, firstone should be set to not primary and secont one as Primary. 
        //Meeting record should be updated with Second Rule Program
        rules = [Select Primary__c, Advisory_Event__r.Primary_Program__c from Rule__c where Advisory_Event__c = : meeting.Id Order by Job_Function__c ASC];
        System.assert(!rules[0].Primary__c);
        System.assert(rules[1].Primary__c);
        System.assertEquals(program2.Id, rules[1].Advisory_Event__r.Primary_Program__c);
    }
    
    //test validatePrimaryRule and updateMeeting
    static testMethod void testUpdateMeeting() {
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Record RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE Type inactivated 
        //Fetch the record Types from database
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType 
                                        where SObjectType = 'Rule__c' 
                                        //AND DeveloperName =: RuleTriggerHelper.RECORD_TYPE_RULE_DEVELOPER_NAME_TITLE
                                        AND IsActive = true];
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c meeting = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        meeting.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //meeting.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert meeting;
        
        //Create the new program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Create the new event record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Event_Type__c = 'Research Working Sessions';
        eSeries.Primary_Program__c  = program.Id;
        eSeries.Rules_Programs__c = 'Establish independent rules';
        insert eSeries;
        
        //Create a Rule record
        Rule__c rule1 = new Rule__c(Name = 'ATest', Advisory_Event__c =  meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'A-Test', Threshold_Type__c = 'Test', Threshold_Number__c = 1, Primary__c = true);
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        rule1.Program__c = program.Id;
        insert rule1;
        
        //Start Test
        Test.startTest();
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals('A-Test', meeting.Title_String__c);
        
        //Create a test program record
        Program__c newProgram = new Program__c(Name = 'Test New Prog', Program_Acronym__c = 'Test');
        insert newProgram;
        
        //Create a Rule record
        Rule__c rule2 = new Rule__c(Name = 'BTest', Advisory_Event__c = meeting.Id, RecordTypeId = recordTypes[0].Id, Job_Function__c = 'B-Test', Threshold_Type__c = 'Test', Threshold_Number__c = 1, Primary__c = true);
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        rule2.Program__c = newProgram.Id;
        insert rule2;
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals('A-Test///B-Test', meeting.Title_String__c);
        
        //Update Use Case
        rule2.Job_Function__c = 'C-Test';
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        //update rule2;
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals('A-Test///C-Test', meeting.Title_String__c);
        
        //Update Case, Not Null
        rule2.Job_Function__c = 'B-Test';
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        //update rule2;
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals('A-Test///B-Test', meeting.Title_String__c);
        
        //Delete case
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        delete rule2;
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals('A-Test', meeting.Title_String__c);
        
        //Delete case
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS= true;
        delete rule1;
        
        //Modified by Saurabh Kumar - CR-20201105-14664 - 11/10/2020: Removed references of Title_String__c field
        //Check for the Title_String Value on Meeting 
        //meeting = [Select Title_String__c from Advisory_Event__c where Id =: meeting.Id];
        //System.assertEquals(null, meeting.Title_String__c);
        
        //Stop Test here
        Test.stopTest();
    }
    
    /**
     *  @use cases  :   1. Parent Rule's should be cloned to child on insert if Rule- field is Use Parent's Rule 
     *			2. Nothing should happen if  Rule- field is not set to Use Parent's Rule
     *                  3. Parent Rule's should be cloned to child on insert if Rule- field is updated to Use Parent's Rule
    **/
    static testMethod void testValidateRulesBeforeInsert() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020: Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Start testing from here
        Test.startTest();
        
        //Try inserting the rules, it should throw exception
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        
        try {
            
            //Insert
            insert rules;
            
            //Fail the test method if records get inserted
            System.assert(false);
        } catch(Exception e) {
            
            //Chekc for the exception message
            System.assert(e.getMessage().containsIgnoreCase(Label.ERROR_BLOCKED_INSERT_USE_PARENT_S_RULE));
        }
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified By - Chirag Soni - 08/19/2021 - Test classes issue fixes
    //Modified By - Neha Sharma - 04/14/2021 - CR-20210324-15023
    //Added by Saurabh Kumar - 10/01/2020 - CR-20200821-14453 
    /**
     *  @use cases  :   This method is used to sync Partner Status field on Registration in case of insert, delete & update
    **/
    static testMethod void testSyncRegistrationPartnerStatus() {
        
        //bypass trigger
        util.bypassAllTriggers = true;
        //get an user
        User user1 = [SELECT Id, LastName FROM USER WHERE LastName = 'Saweda'];
        //get permission set
        PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
        
        //assign EAB Event Manager permission set
        PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = user1.Id, PermissionSetId = ps.Id);
        Insert assignPS; 
        
        System.runAs(user1) {
            
            //check Eab Event Manager
            Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
            system.assertEquals(true, isEABEventManager);
            
            //Create the new account record
            List<Account> accounts = new List<Account>();
            accounts.add(TestUtilities.CreateNewAccount(false));
            accounts.add(TestUtilities.CreateNewAccount(false));
            Insert accounts;
            
            //Create the new contact record
            List<Contact> contacts = new List<Contact>();
            contacts.add(testUtilities.CreateNewContact(accounts[0],false));
            contacts.add(testUtilities.CreateNewContact(accounts[1],false));
            insert contacts;
            
            //Create the new program record
            List<Program__c> programs = new List<Program__c>();
            programs.add(TestUtilities.CreateNewProgram(false));
            programs.add(TestUtilities.CreateNewProgram(false));
            programs.add(TestUtilities.CreateNewProgram(false));
            
            Insert programs;
            
            //Create the new event record
            List<Advisory_Event__c> events = new List<Advisory_Event__c>();
            Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eSeries.Event_Type__c = 'Research Working Sessions';
            eSeries.Rules_Programs__c = 'Establish independent rules';
            eSeries.Primary_Program__c = programs[0].Id;
            eSeries.Public_Name__c = 'Test';
            eSeries.Short_Name__c = 'Test';
            eSeries.Status__c = 'Open - Registration';
            eSeries.Begins__c = System.today();
            eSeries.Ends__c = System.today().addDays(2);
            events.add(eSeries);
            
            eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
            eSeries.Event_Type__c = 'Research Working Sessions';
            eSeries.Rules_Programs__c = 'Establish independent rules';
            eSeries.Public_Name__c = 'Test';
            eSeries.Primary_Program__c = programs[2].Id;
            eSeries.Short_Name__c = 'Test';
            eSeries.Status__c = 'Open - Registration';
            eSeries.Begins__c = System.today();
            eSeries.Ends__c = System.today();
            events.add(eSeries);
            
            Insert events;
            
            //Create the new Registration record
            List<Registration__c> registrations = new List<Registration__c>();
            Registration__c registration = new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = events[0].Id,Status__c = RegistrationHelper.STATUS_REGISTERED);
            registrations.add(registration);
            registration = new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = events[0].Id,Status__c = RegistrationHelper.STATUS_REGISTERED);
            registrations.add(registration);
            registration = new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = events[1].Id,Status__c = RegistrationHelper.STATUS_REGISTERED);
            registrations.add(registration);
            registration = new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = events[1].Id,Status__c = RegistrationHelper.STATUS_REGISTERED);
            registrations.add(registration);
            Insert registrations;
            
            //Create the new Membership record
            List<Membership__c> memberships = new List<Membership__c>();
            Membership__c member = new Membership__c( Name = 'Test Membership 1', Account_Name__c = accounts[0].Id,
                                                     Program__c = programs[0].Id, Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member);
            
            member = new Membership__c( Name = 'Test Membership 2', Account_Name__c = accounts[0].Id,
                                       Program__c = programs[1].Id, Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member);
            
            member = new Membership__c( Name = 'Test Membership 3', Account_Name__c = accounts[1].Id,
                                       Program__c = programs[0].Id, Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member);
            
            member = new Membership__c( Name = 'Test Membership 4', Account_Name__c = accounts[1].Id,
                                       Program__c = programs[1].Id, Membership_Status_Text__c = 'Member - Payer');
            memberships.add(member);
            insert memberships;

            test.startTest(); 

            //Create the new rule record
            List<Rule__c> rules = new List<Rule__c>();
            
            rules.add(new Rule__c(Advisory_Event__c = events[0].Id, Program__c = programs[0].Id, Primary__c = true));
            rules.add(new Rule__c(Advisory_Event__c = events[1].Id, Program__c = programs[2].Id, Primary__c = true));

            insert rules;
            
            //stop bypass trigger
            util.bypassAllTriggers = false; // added by - Chirag soni - 08/19/2021 - added check to bypass registration trigger.
            
            //get updated partner status
            registrations = [SELECT ID, Partner_Status__c  FROM Registration__c WHERE ID IN: registrations];
            
            //check status of registration after insert
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            
            //insert rule
            Rule__c rule = new Rule__c();
            rule.Advisory_Event__c = events[0].Id;
            rule.Program__c = programs[1].Id;
            rules.add(rule);
            //update rules
            rules[0].Program__c = programs[2].Id;
            Upsert rules;
            
            //get updated partner status
            registrations = [SELECT ID, Partner_Status__c  FROM Registration__c WHERE ID IN: registrations];
            
            //check status of registration after Update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            
            //delete rules
            delete rules;
            
            //get updated partner status
            registrations = [SELECT ID, Partner_Status__c  FROM Registration__c WHERE ID IN: registrations];
            
            //check status of registration after delete
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[1].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            test.stopTest();     
            
        }
    }
    
    static testmethod void testPopulateProgramNamesOnEABEvent(){
        
        //Get Program Created from Setup
        Program__c program_01 = [SELECT Id FROM Program__c WHERE Name = 'Test Program KT' LIMIT 1 ];
        
        test.startTest();
        
        //Get EAB Event from Setup 
        Advisory_Event__c eabEvent = [SELECT Id FROM Advisory_Event__c WHERE 
                                      RecordTypeId = :Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT
                                      LIMIT 1];
        
        // Create rule to test populateProgramNamesOnEABEvent method.
        Rule__c ruleToBeTest = new Rule__c(Advisory_Event__c = eabEvent.Id, Program__c = program_01.Id);
        insert ruleToBeTest;
        
        //Get Updated EAB Event with Associated Program 
        Advisory_Event__c updatedEabEvent = [SELECT Id, Associated_Programs__c FROM Advisory_Event__c LIMIT 1];
        
        //check whether program is populated on EAB Event Associated Program or not.
        System.assertEquals('Test Program KT',updatedEabEvent.Associated_Programs__c);
        
        test.stopTest();
    }
    
    static testmethod void testCreateEventRules(){
        
        //Get EAB Event from Setup
        Advisory_Event__c cohortEabEvent = [SELECT Id FROM Advisory_Event__c WHERE 
                                            RecordTypeId = :Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT
                                            LIMIT 1];
        
        //Get Program Created from Setup
        Program__c program_01 = [SELECT Id FROM Program__c WHERE Name = 'Test Program KT' LIMIT 1 ];
        
        test.startTest();
        
        // Create rule to test createEventRules method.
        Rule__c ruleToBeTested = new Rule__c(Advisory_Event__c = cohortEabEvent.Id, Program__c = program_01.Id);
        insert ruleToBeTested;
        
        Advisory_Event__c childEvent = [SELECT Id FROM Advisory_Event__c WHERE Parent_Event__c = :cohortEabEvent.id];
        
        //Query new created event rule on child event 
        Event_Rule__c eventRule = [SELECT Id, Rule__c FROM Event_Rule__c WHERE Advisory_Event__c = :childEvent.id];
        
        // check whether same rule created on child event rule or not.
        System.assertEquals(ruleToBeTested.Id, eventRule.Rule__c);
        
        test.stopTest();
    }
}