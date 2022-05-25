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
/*
 *  Revision Log    :   V1.1 - Modified By - Saurabh Kumar - CR-20200819-14447 - 10/13/2020 : Replaced Meeting with EAB Event
 * 			V1.2 - Modified By - Saurabh Kumar - CR-20200821-14453 - 11/02/2020 : testSyncRegistrationPartnerStatus
 * 			V1.3 - Modified By - Saurabh Kumar - CR-20200821-14465 - 11/02/2020 : testPopulateRegistrationOnCampaignMember
 * 			V1.4 - Modified By - Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
 *			V1.5 - Modified By - Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
 * 			V1.6 - Modified By - Saurabh Kumar - 11/13/2020 - Replaced Origin__c's picklist values from Microsite with EAB.com & Manual with Salesforce.
 * 			V1.7 - Modified By - Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - Removed the references of Manager__c & Master_Event__c
 * 			V1.8 - Modified By - Saurabh Kumar - CR-20210324-15021 - 04/06/2021 - modifed method testPopulateRegistrationOnCampaignMember()
 *		 	V1.9 - Modified By - Neha Sharma - CR-20210324-15023 - 04/15/2021 
 * 			V2.0 - Modified By - Saurabh Kumar - CR-20210208-14884  - 03/05/2021 - fixed unit test.
 * 			V2.1 - Modified By - Saurabh Kumar - CR-20210128-14855 - 03/22/2021 
 * 			V2.2 - Modified By - Chirag Soni - CR-20210210-14902
 *			V2.3 - Modified By - Neha Sharma - CR-20201021-14627
 *			V2.4 - Modified By - Chirag Soni  - CR-20210511-15137 - 10/28/2021 - Added a method testCloneRegistrationsFromParentEventToChildEventV2() - added the use case to test clone elevated meal registrations logic
 */
@isTest
public class Test_AdvisoryEventTrigger {
	
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    private static String meetingGUID = '000-000-001';
    
    //Added By - Neha Sharma - 09/03/2021 - CR-20201021-14627 - Test Class fixes
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
     * @description: 	1) Create 3 meetings, the master, child, and grandchild.  
     * 			2) Verify that the child and grand child reference the same Master meeting record.
     * 			3) Delete the master
     * 			4) Verify the grandchild now references the child record (new master)
     */
    static testmethod void testPopulateTopParent() {
        //create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, true);
        
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        //create the grand child record
        Advisory_Event__c grandChild = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION, null, false);
        grandChild.Parent_Event__c = child.Id;
        insert grandChild;
        
        set<Id> meetingIds = new set<Id> { master.Id, child.Id, grandChild.Id };
        
        //get all meetings and verify the master event field on each
        list<Advisory_Event__c> meetings = [SELECT Id, Master_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        /*for (Advisory_Event__c m : meetings) {
            if (m.Id == master.Id) system.assertEquals(null, m.Master_Event__c);
            else if (m.Id == child.Id) system.assertEquals(master.Id, m.Master_Event__c);
            else if (m.Id == grandChild.Id) system.assertEquals(master.Id, m.Master_Event__c);
        }*/
        
        //delete the master
        /*delete child;
        
        //get all meetings and verify the master event field on each
        meetings = [SELECT Id, Master_Event__c, Parent_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        for (Advisory_Event__c m : meetings) {
            if (m.Id == grandChild.Id) {
                system.assertEquals(master.Id, m.Master_Event__c);
            }
        }*/
        
         //delete the master
        delete master;
        
        //get all meetings and verify the master event field on each
        /*meetings = [SELECT Id, Master_Event__c FROM Advisory_Event__c WHERE Id IN :meetingIds];
        for (Advisory_Event__c m : meetings) {
            if (m.Id == child.Id) system.assertEquals(null, m.Master_Event__c);
            //else if (m.Id == grandChild.Id) system.assertEquals(child.Id, m.Master_Event__c);
        }*/
		
    }
    
    //Test method for manageMeetingFollowers
    /**
     *	Use Cases	:	1. Add a new test method that will create two Meeting records.  
     						One of them should have the Manager initially set to a User and the other should have no Manager defined.  
     						In the test, set the Manager on both records to a new value.  
     						Verify that on the first record, the previous user is no longer following the Meeting feed, 
     						and that on both records, the new User is correctly following the record.
						2. Add another new test method that will create a new Meeting record with a Manager defined.  
							In the test, check if the user set as Manager is correctly following the record.  
							Set the Meeting Status to a Closed value.  
							Verify that the user set as Manager is no longer following the record after this change.
     
     **/
    static testMethod void testManageMeetingFollowers() {
    	
    	//Fetch existing user from database other than the current one
		List<User> managers = [Select Id from User where Profile.Name = 'System Administrator' AND IsActive = true AND Id !=: UserInfo.getUserId() LIMIT 1];
		
		//Create test data
		List<Advisory_Event__c> meetings = new List<Advisory_Event__c>();
		
        	//Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
		//Create Parent meeting records
		meetings.add(testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false));
		meetings.add(testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false));
		
		//Set the Manager in First meeting and keep the second meeting null
		//meetings[0].Manager__c = managers[0].Id;
		
		//Start testing from here
		Test.startTest();
		
		//Insert managers
		insert meetings;
		
		//Check only first meeting record should have Manager as follower
		List<EntitySubscription> eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
        
        	//Modified by Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - 
        	//Commented Asserts due to Removed the references of Manager__c & Master_Event__c
		//System.assertEquals(1, eS.size()); 
		//System.assertEquals(meetings[0].Id, eS[0].ParentId);
		
		//Update the manager on Second Record
		//meetings[1].Manager__c = managers[0].Id;
		update meetings[1];
		
		//Check only first meeting record should have Manager as follower
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
        
        	//Modified by Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - 
        	//Commented Asserts due to Removed the references of Manager__c & Master_Event__c
		//System.assertEquals(2, eS.size());
		//System.assert(meetings[0].Id == eS[0].ParentId || meetings[0].Id == eS[1].ParentId);
		//System.assert(meetings[1].Id == eS[0].ParentId || meetings[1].Id == eS[1].ParentId);
		
		//Remove Managers from meeting records
		//meetings[0].Manager__c = null;
		//meetings[1].Manager__c = null;
		update meetings;
		
		//Managers should be removed from Folloews list
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
		//System.assertEquals(0, eS.size());
		
        	//Modified by Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - 
        	//Commented Asserts due to Removed the references of Manager__c & Master_Event__c
		//Add the  Managers from meeting records
		//meetings[0].Manager__c = managers[0].Id;
		//meetings[1].Manager__c = managers[0].Id;
		update meetings;
		
		//Check meeting records should have Manager as follower
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
        	//Modified by Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - 
        	//Commented Asserts due to Removed the references of Manager__c & Master_Event__c
		//System.assertEquals(2, eS.size());
		//System.assert(meetings[0].Id == eS[0].ParentId || meetings[0].Id == eS[1].ParentId);
		//System.assert(meetings[1].Id == eS[0].ParentId || meetings[1].Id == eS[1].ParentId);
		
		//Update the records to Closed to True
		meetings[0].Status__c = 'Closed - Completed';
		meetings[1].Status__c = 'Closed - Completed';
		update meetings;
		
		//Stop Test here
		Test.stopTest();
			
		//Managers should be removed from Folloews list
		eS = [Select SubscriberId, ParentId from EntitySubscription where SubscriberId IN: managers];
        	//Modified by Saurabh Kumar - CR-20201105-14664 - 11/18/2020 - 
        	//Commented Assert due to Removed the references of Manager__c & Master_Event__c
		//System.assertEquals(0, eS.size());   
    }
 	
    /**
     * @description: 	1. Create a parent Event without Team member and veryfy it has Detfaults Team members Created
     					2. Update the team members data with Contact Information
     					3. Create a Child record to check if the Parent Team member Data has been copied to Chils
     					'Series' => new Map<String, String> {
																'Series Planner' => 'Series Planner', 
																'Series Coordinator' => 'Series Coordinator'
															},
						'Event' => new Map<String, String> {
																'Event Planner' => 'Series Planner', 
																'Event Coordinator' => 'Series Coordinator', 
																'On Site Planner' => 'Series Planner'
															},
						'Session' => new Map<String, String> {
																'Event Planner' => 'Event Planner', 
																'Event Coordinator' => 'Event Coordinator', 
																'On Site Planner' => 'Event Planner'
															}
    
     */
    static testmethod void testCreateDefaultTeamMembers() {
        
   	//Start Testing from here
   	Test.startTest();
   		
   	//create the master record
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, true);
        
        //Verify is default Team members have been created
        List<Team_Member__c> teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: master.Id ORDER BY Primary_Role__c ASC];
        
        //Commenented by Saurabh Kumar - To increase coverage later
        //It should have 2 records created
        /* System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assertEquals(null, teamMembers[0].Team_Member__c);
        System.assertEquals(null, teamMembers[1].Team_Member__c);
        
        //Create a list of Contatcs and Insert
		List<Contact> contacts = new List<Contact>();
		
		//Add contacts in list
		contacts.add(testUtilities.createNewContact(false));
		contacts.add(testUtilities.createNewContact(false));
		
		//Insert the contacts
		insert contacts;
		
		//Update the Team members with the contact instance
		teamMembers[0].Team_Member__c = contacts[0].Id;
		update teamMembers[0];
		
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
        //create the child record
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        child.Parent_Event__c = master.Id;
        insert child;
        
        //Verify is default Team members have been created
        teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: child.Id ORDER BY Primary_Role__c];
        
        //It should have 2 records created
        System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assert(teamMembers[0].Team_Member__c == contacts[0].Id || teamMembers[1].Team_Member__c == contacts[0].Id);
        System.assert(teamMembers[0].Team_Member__c == null || teamMembers[1].Team_Member__c == null);
        System.assert(teamMembers[0].Team_Member__c != teamMembers[1].Team_Member__c);
        
        //Update the Team members with the contact instance
		teamMembers[1].Team_Member__c = contacts[1].Id;
		update teamMembers[1]; 
		
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
	//create the child record
        Advisory_Event__c child2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        child2.Parent_Event__c = child.Id;
        insert child2;
        
        //Verify is default Team members have been created
        teamMembers = [Select Id, Advisory_Event__c, Primary_Role__c, Team_Member__c from Team_Member__c where Advisory_Event__c =: child2.Id ORDER BY Primary_Role__c];
        
        //It should have 2 records created
        System.assertEquals(2, teamMembers.size());
        System.assert(teamMembers[0].Primary_Role__c == 'Series Coordinator' || teamMembers[1].Primary_Role__c == 'Series Coordinator');
        System.assert(teamMembers[0].Primary_Role__c == 'Series Planner' || teamMembers[1].Primary_Role__c == 'Series Planner');
        System.assert(teamMembers[0].Primary_Role__c != teamMembers[1].Primary_Role__c);
        System.assert(teamMembers[0].Team_Member__c == contacts[0].Id || teamMembers[1].Team_Member__c == contacts[0].Id);
        System.assert(teamMembers[0].Team_Member__c == contacts[1].Id || teamMembers[1].Team_Member__c == contacts[1].Id);
        System.assert(teamMembers[0].Team_Member__c != teamMembers[1].Team_Member__c);
        */
        //Stop test here
        Test.stopTest();
    }
    
    /**
     * 	@use cases	:	1. Parent Rule's should be cloned to child on insert if Rule- field is Use Parent's Rule 
     					2. Nothing should happen if  Rule- field is not set to Use Parent's Rule
     *					3. Parent Rule's should be cloned to child on insert if Rule- field is updated to Use Parent's Rule
     **/
    static testMethod void testCloneRules() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName != 'Title')
            	rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        //Start testing from here
        Test.startTest();
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Breakout Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(1, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        //System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Check for the rules picklist value
        child = [Select Rules_Programs__c from Advisory_Event__c where Id =: child.Id];
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Programs__c);
        //System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Thresholds__c);
        //System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child.Rules_Titles__c);
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Breakout Record Type
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT, null, false);
        child2.Parent_Event__c = master.Id;
        insert child2;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child2.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Check for the rules picklist value
        child2 = [Select Rules_Programs__c from Advisory_Event__c where Id =: child2.Id];
        System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Programs__c);
        //System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Thresholds__c);
        //System.assertNotEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Titles__c);
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Update the rules
        child2.Rules_Programs__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        //child2.Rules_Thresholds__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        //child2.Rules_Titles__c = AdvisoryEventTriggerHelper.CLONE_PARENT_S_RULES;
        update child2;
        
        //Stop test here
        Test.stopTest();
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child2.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(1, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        //System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Check for the rules picklist value
        child2 = [Select Rules_Programs__c from Advisory_Event__c where Id =: child2.Id];
        System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Programs__c);
        //System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Thresholds__c);
        //System.assertEquals(AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES, child2.Rules_Titles__c);
    }
    
    /**
     * 	@use cases	:	1. Update the Meeting status to Use Parent's rule and verify related rules are deleted or not
     **/
    static testMethod void testDeleteRulesForUseForParent() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create a test program record
        Program__c program2 = new Program__c(Name = 'TestProg2', Program_Acronym__c = 'Test2');
        insert program2;
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: master.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(1, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        //System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        //System.assertEquals('Title', rules[2].RecordType.DeveloperName);
        
        //Check if Event Rules also have been created for Parent when Rules were created
        List<Event_Rule__c> eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id AND Rule__c IN: rules ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        
        //Start testing from here
        Test.startTest();
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Event Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id order by Rule__r.RecordType.DeveloperName ASC];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Create a list of new rules
        List<Rule__c> additionalRules = new List<Rule__c>();
        
        //Create another rule for Parent
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName == 'Title')
            	additionalRules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test2', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //As a new rule has been created on parent,
        //1. It should create new Event Rule on the On the parent
        //2. It should create the Event rule for Child reccord also
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert additionalRules;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
         //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Session Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create anotther Child Event
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c level2Child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION, null, false);
        level2Child.Parent_Event__c = child.Id;
        level2Child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //level2Child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //level2Child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert level2Child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Create a list of new rules
        additionalRules = new List<Rule__c>();
        
        //Create another rule for Parent
        for(RecordType rType : recordTypes) {
            
            //Data
            if(rType.DeveloperName == 'Program')
            	additionalRules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test2', Threshold_Type__c = 'Test2', Program__c = program2.Id, Threshold_Number__c = 1));
        }
        
        //As a new rule has been created on parent,
        //1. It should create new Event Rule on the On the parent
        //2. It should create the Event rule for Child reccord also
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert additionalRules;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Threshold', eRules[2].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[4].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        /*System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Now check if teh same event rule has been created on Child as well
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: level2Child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(2, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        System.assertEquals('Program', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[3].Rule__r.RecordType.DeveloperName);
        
        //Check if Primary Program is Same of all teh Events as All child records  have Use Parent Program
        List<Advisory_Event__c> meetings = [Select Id, Primary_Program__c from Advisory_Event__c ORDER BY CreatedDate ASC];
        System.assertEquals(3, meetings.size());
        System.assertEquals(program.Id, meetings[0].Primary_Program__c);
        System.assertEquals(program.Id, meetings[1].Primary_Program__c);
        System.assertEquals(program.Id, meetings[2].Primary_Program__c);
        */
	//Stop test here
	Test.stopTest();
    }
    
    /**
     * 	@use cases	:	1. Update the Meeting status to ESTABLISH_INDEPENDENT_RULES and verify related rules are deleted or not
     **/
    static testMethod void testDeleteRulesForEstablishIndependentRules() {
        
        //Fetch the record Types from database
        List<RecordType> recordTypes = RuleTriggerHelper.mapRuleRecordTypes.values();
        
        //Create a test program record
        Program__c program = new Program__c(Name = 'TestProg', Program_Acronym__c = 'Test');
        insert program;
        
        //Create a test program record
        Program__c program2 = new Program__c(Name = 'TestProg2', Program_Acronym__c = 'Test2');
        insert program2;
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Cohort Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create Parent meeting records
        Advisory_Event__c master = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        master.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //master.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        insert master;
        
        //Create a list of Rules
        List<Rule__c> rules = new List<Rule__c>();
        
        //2 Records for each record type
        for(RecordType rType : recordTypes) {
            
            //Data
            rules.add(new Rule__c(Name = 'Test', Advisory_Event__c = master.Id, RecordTypeId = rType.Id, Job_Function__c = 'Test', Threshold_Type__c = 'Test', Program__c = program.Id, Threshold_Number__c = 1));
        }
        
        //Try inserting the rules, it should be successfully inserted
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true;
        insert rules;
        
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: master.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(1, rules.size());
        System.assertEquals('Program', rules[0].RecordType.DeveloperName);
        //System.assertEquals('Threshold', rules[1].RecordType.DeveloperName);
        //System.assertEquals('Title', rules[2].RecordType.DeveloperName);
        
        //Check if Event Rules also have been created for Parent when Rules were created
        List<Event_Rule__c> eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: master.Id AND Rule__c IN: rules ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Threshold', eRules[1].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[2].Rule__r.RecordType.DeveloperName);
        
        //Start testing from here
        Test.startTest();
        
        //Modified by Saurabh Kumar - 11/09/2020 - Replaced Series Record Type with Breakout Record Type
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Create a new Child meeting record by setting Rules_Programs__c and Rules_Thresholds__c
        //As soon as this meeting inserts, it will clone the Meeting event recods parent meeting and will stamp them on child also
        Advisory_Event__c child = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT, null, false);
        child.Parent_Event__c = master.Id;
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        insert child;
        
        //Assert results
        rules = [Select Id, RecordType.DeveloperName from Rule__c where Advisory_Event__c =: child.Id ORDER BY RecordType.DeveloperName];
        System.assertEquals(0, rules.size());
      
      	//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Update the child with ESTABLISH_INDEPENDENT_RULES
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        update child;
                
		//Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        //System.assertEquals(1, eRules.size());
        //System.assertEquals('Title', eRules[0].Rule__r.RecordType.DeveloperName);
        
        // Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields
        //Update the child with ESTABLISH_INDEPENDENT_RULES
        child.Rules_Programs__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        update child;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(0, eRules.size());
		
	// Modified by Saurabh Kumar - CR-20200819-14450 - 11/03/2020 : Removed references of "Rules_Thresholds__c" and "Rules_Titles__c" fields       
      	child.Rules_Programs__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        //child.Rules_Thresholds__c = AdvisoryEventTriggerHelper.ESTABLISH_INDEPENDENT_RULES;
        //child.Rules_Titles__c = AdvisoryEventTriggerHelper.USE_PARENT_S_RULES;
        update child;
        
        //Check if Event Rules also have been created for Parent when Rules were created
        eRules = [Select Id, Rule__c, Rule__r.RecordType.DeveloperName, Advisory_Event__c from Event_Rule__c where Advisory_Event__c =: child.Id ORDER BY Rule__r.RecordType.DeveloperName];
        System.assertEquals(1, eRules.size());
        System.assertEquals('Program', eRules[0].Rule__r.RecordType.DeveloperName);
        //System.assertEquals('Title', eRules[1].Rule__r.RecordType.DeveloperName);
        
        //Stop test here
		Test.stopTest();
    }
	
    //Added by Saurabh Kumar - 11/02/2020 - CR-20200821-14465
    // Modified by Saurabh Kumar 11/25/2020
    // Modified by Saurabh Kumar 04/06/2021 - CR-20210324-15021
    static testMethod void testPopulateRegistrationOnCampaignMember() {
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //bypass trigger
        Util.BypassAllTriggers = true;
        //get account
        Account account1 = TestUtilities.CreateNewAccount(true);
        
        // create contacts 
        List<Contact> contacts = new List<Contact>();
       
        contacts.add(testUtilities.CreateNewContact(account1, false));
        contacts.add(testUtilities.CreateNewContact(account1, false));
        contacts.add(testUtilities.CreateNewContact(account1, false));
        contacts.add(testUtilities.CreateNewContact(account1, false));
        
        insert contacts;
        //get Event Invite List Member RT id
         Id recordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        
        //Create campaigns
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = 'Test Campaign 1', IsActive = True, CampaignMemberRecordTypeId = recordTypeId));
        campaigns.add(new Campaign(Name = 'Test Campaign 2', IsActive = True, CampaignMemberRecordTypeId = recordTypeId));
            
        insert campaigns;
        
        // create campaign members under above campaign
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[1].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[2].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[1].Id, ContactId = contacts[0].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[1].Id, ContactId = contacts[1].Id, Status = 'Registered'));

        insert campaignMembers;
        
        // create two EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
        List<Registration__c> registrations = new List<Registration__c>();
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id));
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id));
        // same registration on different EAB Event 
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[1].Id));
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[1].Id));
        registrations.add(new Registration__c(Contact__c = contacts[3].Id, EAB_Event__c = eabEvents[1].Id));
        insert registrations ; 
        
        //set flag to false
        Util.BypassAllTriggers = false;
        
        Test.startTest();
	
        // update EAB 1 and EAB 2 with same campaign ID
        List<Advisory_Event__c> listOfEabEventToBeUpdated = new List<Advisory_Event__c>();
        listOfEabEventToBeUpdated.add(new Advisory_Event__c(Id =  eabEvents[0].Id, Invite_List__c = campaigns[0].Id));
        listOfEabEventToBeUpdated.add(new Advisory_Event__c(Id =  eabEvents[1].Id, Invite_List__c = campaigns[0].Id));
        
        update listOfEabEventToBeUpdated;
        
        List<CampaignMember> updatedCampaignMembers = [SELECT Id, Registration__c, Registration__r.EAB_Event__c FROM CampaignMember WHERE CampaignId = :campaigns[0].Id];
        
        // Assert to check registrations of 1st and 2nd Campaign Members should be on is on different EAB Events.
        System.assertEquals(listOfEabEventToBeUpdated[0].Id, updatedCampaignMembers[0].Registration__r.EAB_Event__c);
        System.assertEquals(listOfEabEventToBeUpdated[1].Id, updatedCampaignMembers[1].Registration__r.EAB_Event__c);
        
        //Assert to check two registration ids of different EAB event populated in two campaign members.
        System.assertEquals(registrations[1].Id, updatedCampaignMembers[0].Registration__c);
        System.assertEquals(registrations[3].Id, updatedCampaignMembers[1].Registration__c);
        
        // registration's contacts which are not linked to any of campaign member 
        System.assertNotEquals(registrations[0].Id, updatedCampaignMembers[0].Registration__c);
        System.assertNotEquals(registrations[2].Id, updatedCampaignMembers[1].Registration__c);  
        
        // update Second campaign on one of the EAB Event
        Advisory_Event__c eabEvent =  new Advisory_Event__c(Id =  eabEvents[1].Id, Invite_List__c = campaigns[1].Id);
        
        update eabEvent;
        
        //insert one more registration to cover related method
        Registration__c matchedRegistration = new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[1].Id);
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        insert matchedRegistration;
        RegistrationHelper.bypassRegistrationDLRS = false;
        
        List<CampaignMember> updatedCM = [SELECT id, Registration__c FROM CampaignMember WHERE CampaignId = :eabEvent.Invite_List__c];
        
        // assert to check popluated registration on Campaign Member
          System.assertEquals(registrations[2].Id, updatedCM[0].Registration__c);
          System.assertEquals(matchedRegistration.Id, updatedCM[1].Registration__c);
         
        // assert to check that no more campaign member are there to populate any registration id
        System.assertEquals(2, updatedCM.size());
        
        // cover campaign member mathod 
        CampaignMember cmp1 =  new CampaignMember(CampaignId = campaigns[1].Id, ContactId = contacts[3].Id, Status = 'Sent');
        insert cmp1;
        
        // query populated campaign member beacause registration of this contact already exist.
        CampaignMember populatedCmp = [SELECT Id, Registration__c FROM CampaignMember WHERE Id = :cmp1.Id];
        
        // assert to check that correct registration__c id is populated
        System.assertEquals(registrations[4].Id, populatedCmp.Registration__c); 
        
        Test.stopTest();
    }
    
    //Added By - Neha Sharma - 04/15/2021 - CR-20210324-15023
    static testmethod void test_syncRegistrationPartnerStatus(){
        
        //Add By - Neha Sharma - 09/03/2021 - CR-20201021-14627 - Test Class fixes
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        User userA = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];
        Id assigneeId = userInfo.getUserId();
        System.runAs(userA) {
            
            PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
            
            PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = assigneeId , PermissionSetId = ps.Id);
            insert assignPS;  
        }
        
        //List to hold Account records
        List<Account> accList = new List<Account>();
        
        accList.add(TestUtilities.CreateNewAccount(false));
        accList.add(TestUtilities.CreateNewAccount(false));
        
        //Insert record
        insert accList;
        
        //Insert Program data
        List<Program__c> programs = new List<Program__c>();
        
        programs.add(TestUtilities.CreateNewProgram(false));     
        programs.add(TestUtilities.CreateNewProgram(false));
        insert programs;
        
        //Creating Contact record 
        // List to store test Contacts
        List<Contact> contacts = new List<Contact>();
        
        //Add contact data in list
        contacts.add(testUtilities.CreateNewContact(accList[0], false));
        contacts.add(testUtilities.CreateNewContact(accList[1], false));
        //Insert Contact Data
        
        insert contacts;
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = programs[0].Id, Membership_Status_Text__c = 'Member - Payer'));
        //No contract is created for Account
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = accList[1].Id, 
                                             Program__c = programs[1].Id, Membership_Status_Text__c = 'Member - Payer'));
        
        Insert membershipList;
        
        // create new EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Primary_Program__c  = programs[1].Id;
        event.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(event);
        
        event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Primary_Program__c  = programs[0].Id;
        eabEvents.add(event);
        
        insert eabEvents;
        
        User userB = [SELECT Id FROM User WHERE Id = :userInfo.getUserId()];
        
        System.runAs(userB){
            
            Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
            system.assertEquals(true, isEABEventManager);
            
            //create Registration
            List<Registration__c> registrations = new List<Registration__c>();
            
            //for cohort event
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false));
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false));
            //for event
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[0].Id, false));
            registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[1].Id, false));
            
            insert registrations;
            
            //stop bypassing trigger
            Util.byPassAllTriggers = false;
            
            //update program
            eabEvents[0].Primary_Program__c  = programs[0].Id;
            
            //Commented By - Neha Sharma - 09/03/2021 - CR-20201021-14627 - Test Class fixes
            //eabEvents[1].Primary_Program__c  = null;
            Update eabEvents;
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[1].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            
            //negative use case - update Short Name on event
            eabEvents[0].Short_Name__c = 'First EAB Event';
            eabEvents[1].Short_Name__c = 'Second EAB Event';
            
            //get registration
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update is not changed
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[1].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
            
            //delete an event
            Delete eabEvents[0];
            
            registrations = [Select Id, Partner_Status__c From Registration__c Where Id IN: registrations];
            
            //check status of registration after update
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[0].Partner_Status__c);
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[1].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[2].Partner_Status__c);
            //System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, registrations[3].Partner_Status__c);
        }
        
    }
    
    //Added by Saurabh Kumar - 02/18/2021 - CR-20210210-14902
    static testMethod void testCloneRegistrationsFromParentEventToChildEvent(){
       	
         // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        Util.bypassAllTriggers = true;
        
        //Create Parent Event
        Advisory_Event__c parentEABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        parentEABEvent.Event_Type__c = 'Research Working Sessions';
        parentEABEvent.Public_Name__c = 'Test';
	parentEABEvent.Short_Name__c = 'Test';
	parentEABEvent.Status__c = 'Open - Registration';
	parentEABEvent.Begins__c = System.today();
	parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        //get account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        // create contacts 
        List<Contact> contacts = new List<Contact>();
       
        contacts.add(testUtilities.CreateNewContact(acct, false));
        contacts.add(testUtilities.CreateNewContact(acct, false));
        contacts.add(testUtilities.CreateNewContact(acct, false));
        contacts.add(testUtilities.CreateNewContact(acct, false));
        contacts.add(testUtilities.CreateNewContact(acct, false));
        
        insert contacts;
        
        //Create Registration
        List<Registration__c> registrations = new List<Registration__c>();
        for(Integer i=0; i< 5; i++) 
            registrations.add(Test_SiteMeetingController.CreateRegistration(parentEABEvent.Id, contacts[i].Id, false));
        insert registrations;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();
        
        Advisory_Event__c childEABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEABEvent.Parent_Event__c = parentEABEvent.Id;
        childEABEvent.Event_Type__c = 'Research Working Sessions';
        childEABEvent.Public_Name__c = 'Test';
	childEABEvent.Short_Name__c = 'Test';
	childEABEvent.Status__c = 'Open - Registration';
	childEABEvent.Begins__c = System.today();
	childEABEvent.Ends__c = System.today();
        childEABEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        insert childEABEvent;
        
        List<Registration__c> createdRegistrations = [Select Id, EAB_Event__c From Registration__c Where EAB_Event__c =: childEABEvent.Id];
        System.assert(createdRegistrations.size() == 5);
        Test.stopTest();
    }
    
    //Created By -  Chirag Soni - 10/28/2021 - CR-20210511-15137 - added the use case to test clone elevated meal registrations logic
    static testMethod void testCloneRegistrationsFromParentEventToChildEventV2(){
       	
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass all triggers
        Util.bypassAllTriggers = true;
        
        //Create Parent Event
        Advisory_Event__c parentEABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        parentEABEvent.Event_Type__c = 'Research Working Sessions';
        parentEABEvent.Public_Name__c = 'Test';
	parentEABEvent.Short_Name__c = 'Test';
	parentEABEvent.Status__c = 'Open - Registration';
	parentEABEvent.Begins__c = System.today();
	parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create Contacts
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i = 1; i<= 5; i++){
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        insert contacts;
        
        System.debug(contacts.size());
        
        //Create Registration
        List<Registration__c> registrations = new List<Registration__c>();
        for(Integer i=0; i<contacts.size() ; i++){
            
            registrations.add(Test_SiteMeetingController.CreateRegistration(parentEABEvent.Id, contacts[i].Id, false));
        }
        insert registrations;
        
        Advisory_Event__c childEABEvent1 = new Advisory_Event__c();
        childEABEvent1.Parent_Event__c = parentEABEvent.Id;
        childEABEvent1.Event_Type__c = 'Research Working Sessions';
        childEABEvent1.Name = 'Test';
        childEABEvent1.Public_Name__c = 'Test1';
	childEABEvent1.Short_Name__c = 'Test1';
	childEABEvent1.Status__c = 'Open - Registration';
	childEABEvent1.Begins__c = System.today();
	childEABEvent1.Ends__c = System.today().addDays(10);
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;
        insert childEABEvent1;
        
        Util.bypassAllTriggers = false;
        
        Test.startTest();

        //Test For Elevated Meal
	childEABEvent1 = [Select Id,Mirror_Registrations__c From Advisory_Event__c Where Id =: childEABEvent1.Id];
        
        //Update Event 
        childEABEvent1.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        update childEABEvent1;
        
        List<Registration__c> createdRegistrations1 = [Select Id, EAB_Event__c,RecordTypeId From Registration__c Where EAB_Event__c =: childEABEvent1.Id];
        System.assert(createdRegistrations1.size() == 5);
        
        System.assert(createdRegistrations1[0].RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL);
        
        Test.stopTest();
    }
    
    //Added by Saurabh Kumar - 03/22/2021 - CR-20210128-14855
    public static testMethod void testGenerateAcquiaSegment(){
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockAcquiaHTTPCallout());
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        for(Integer i=0; i<50; i++){
            
            Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eabEvent.Event_Type__c = 'Research Working Sessions';
            eabEvent.Public_Name__c = 'Test';
            eabEvent.Short_Name__c = 'Test';
            eabEvent.Status__c = 'Open - Registration';
            eabEvent.Begins__c = System.today();
            eabEvent.Ends__c = System.today();
            eabEvent.Event_Format__c = 'Virtual';
            eabEvent.Campaign_Template__c = 'Virtual Cohort';
            eabEvents.add(eabEvent);
        }
        Util.BypassAllTriggers = true;
        insert eabEvents;
        
        Test.stopTest(); 
        
        Contact contact = TestUtilities.createNewContact(true);
        Registration__c registration = new Registration__c();
        registration.Contact__c = contact.Id;
        registration.EAB_Event__c = eabEvents[0].Id;
        insert registration;
        
        Util.BypassAllTriggers = false;
        
        Advisory_Event__c eabEvent = new Advisory_Event__c(Id = eabEvents[0].Id, Campaign_Template__c = 'Virtual Cohort Parent');
        
        try{
         	update eabEvent;   
        }catch(Exception e){
            System.assert(e.getMessage().contains(Label.ERROR_CAMPAIGN_TEMPLATE_CAN_NOT_EDIT_WHEN_REGISTRATION_THERE));
        }
        
    }
    
    //Added by Saurabh Kumar - 03/22/2021 - CR-20210128-14855
    public static testMethod void testReGenerateAcquiaCampaign(){
        
        Util.BypassAllTriggers = true;
        
        Test.setMock(HttpCalloutMock.class, new MockAcquiaHTTPCallout());
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        for(Integer i=0; i<50; i++){
            
            Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eabEvent.Event_Type__c = 'Research Working Sessions';
            eabEvent.Public_Name__c = 'Test';
            eabEvent.Short_Name__c = 'Test';
            eabEvent.Status__c = 'Open - Registration';
            eabEvent.Begins__c = System.today();
            eabEvent.Ends__c = System.today();
            eabEvent.Event_Format__c = 'Virtual';
            eabEvent.Acquia_Segment_Id__c = 10;
            eabEvent.External_Campaign_Id__c = 10;
            eabEvents.add(eabEvent);
        }
        
        insert eabEvents;
        
        Util.BypassAllTriggers = false;
        
        Map<Id, Advisory_Event__c> mapOfEABEvents = new Map<Id, Advisory_Event__c>([Select Id, Campaign_Template__c, Acquia_Segment_Id__c, External_Campaign_Id__c From Advisory_Event__c]);
        
        for(Advisory_Event__c eabEvent : mapOfEABEvents.values()){
            
            mapOfEABEvents.put(eabEvent.Id, new Advisory_Event__c(Id = eabEvent.Id, Campaign_Template__c = 'Virtual Event'));
        }
        
        Test.startTest();
        
        update mapOfEABEvents.values();
        
        Test.stopTest();
             
        for(Advisory_Event__c eabEvent : [Select Id, Campaign_Template__c, Acquia_Segment_Id__c, External_Campaign_Id__c From Advisory_Event__c Where Id IN : mapOfEABEvents.keySet()]){
        	
            System.assert(eabEvent.Acquia_Segment_Id__c == 10);//Acquia Segment Id should be same.
            // Currently we are not generating External Campaign Id By Automation
            //System.assert(eabEvent.External_Campaign_Id__c != 10);//Acquia Campaign Id should be regenerated.
        } 
       
    }
}