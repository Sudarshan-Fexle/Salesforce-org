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
//Modified By - Deepak Kumawat - Apollo Test Failures Fixes 
////Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
@isTest(seeAllData=false)
private class testOpportunityTriggerUtilities {
  
    
    // test the next decision date on a membership based on the next renewal opp
    static testmethod void testNextDecisionDate_OptOut() {
    
        Date dateTomorrow = system.today().addDays(1);
        Date nextWeek = system.today().addDays(7);
        
        // bypass dupeblocker
        Util.IsTest(true);
        Util.ResetRecordTypeSettings();
        
        //Bypassing all triggers so then test data can be create
        Util.byPassAllTriggers = true;
        
        //List of Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        
        // test setup
        Date optOutDate = system.today().addDays(5);
        
        //Account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(null, 'ABC', 'Yes', 'PT', true);
        
        //Membership
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, program.Id, true);
        
        //Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp.Program__c = program.Id;
        opp.Membership__c = membership.Id;
        opp.Opt_Out_Date__c = optOutDate;
        opp.Start__c = dateTomorrow;
        opp.StageName = 'Pending- Renewal Call Comp & Evaluating';
        oppList.add(opp);
        
        Opportunity opp2 = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp2.Program__c = program.Id;
        opp2.Membership__c = membership.Id;
        opp2.Start__c = nextWeek;
        opp2.StageName = 'Pending- Renewal Call Comp & Evaluating';
        oppList.add(opp2);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //Insert list of opportunities
        insert oppList;
        
        //Retrieving opportunity details
        Opportunity updatedOpp = [SELECT Name, Id, Status__c FROM  Opportunity WHERE Membership__c = :membership.id LIMIT 1];
        system.assertEquals('Pending', updatedOpp.Status__c);
        
        // perform test
        test.startTest();
            
        //Query string
        String queryString = 'SELECT Id, Next_Decision_Date__c, (SELECT Id, Opt_Out_Date__c, Start__c FROM Opportunities__r WHERE Status__c = \'Pending\' ORDER BY Start__c ASC) FROM Membership__c WHERE Next_Decision_Date__c != null AND Id = \'' + membership.Id +'\'';
        
        //Executing the Batch Job
        //create an instance of the batch that will populate next decision date
        Batch_MembershipNextActivityDate batch = new Batch_MembershipNextActivityDate(queryString);
        database.executeBatch(batch);
        
        //Stop Test here
        test.stopTest();
        
        // get the updated membership
        membership = [SELECT Id, Next_Decision_Date__c FROM Membership__c WHERE Id = :membership.Id];
        //system.assertEquals(optOutDate, membership.Next_Decision_Date__c);
    }
    
    // test the next decision date on a membership based on the next renewal opp
    static testmethod void testNextDecisionDate_NoOptOut() {
    
        Date dateTomorrow = system.today().addDays(1);
        Date nextWeek = system.today().addDays(7);
        
        // bypass dupeblocker
        Util.IsTest(true);
        Util.ResetRecordTypeSettings();
    
        //Bypassing all triggers so then test data can be create
        Util.byPassAllTriggers = true;
        
        //List of Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        
        // test setup
        Date optOutDate = system.today().addDays(5);
        
        //Account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //Program
        Program__c program = TestUtilities.CreateNewProgram(null, 'ABC', 'Yes', 'PT', true);
        
        //Membership
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, program.Id, true);
        
        //Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp.Program__c = program.Id;
        opp.Membership__c = membership.Id;
        opp.Start__c = dateTomorrow;
        opp.StageName = 'Pending- Renewal Call Comp & Evaluating';
        oppList.add(opp);
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
        
        //Insert list of opportunity
        insert oppList;
        
        //Opportunity
        Opportunity opp2 = TestUtilities.CreateNewOpportunity(acc.Id, false);
        opp2.Program__c = program.Id;
        opp2.Membership__c = membership.Id;
        opp2.Start__c = nextWeek;
        opp2.StageName = 'Pending- Renewal Call Comp & Evaluating';
        oppList.add(opp2);
       
        Opportunity updatedOpp = [SELECT Name, Id, Status__c FROM  Opportunity WHERE Membership__c = :membership.id LIMIT 1];
        system.assertEquals('Pending', updatedOpp.Status__c);
        
        // perform test
        test.startTest();
        
        //Query string
        String queryString = 'SELECT Id, Next_Decision_Date__c, (SELECT Id, Opt_Out_Date__c, Start__c FROM Opportunities__r WHERE Status__c = \'Pending\' ORDER BY Start__c ASC) FROM Membership__c WHERE Next_Decision_Date__c != null AND Id = \'' + membership.Id +'\'';
        
        //Execute Batch
        // create an instance of the batch that will populate next decision date
        Batch_MembershipNextActivityDate batch = new Batch_MembershipNextActivityDate(queryString);
        database.executeBatch(batch);
        
        //test will stop Here
        test.stopTest();
        
        // get the updated membership
        membership = [SELECT Id, Next_Decision_Date__c FROM Membership__c WHERE Id = :membership.Id];
        //system.assertEquals(opp.Start__c.addDays(-1), membership.Next_Decision_Date__c);
        
    }
    
    static testmethod void testUpdateInitialVisitDateByEventDate() {
     	
        //Bypass all the Triggers
		Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;

        Date dtToday = system.today();
        Date dtYesterday = system.today().addDays(-1);
        Date dtLastWeek = system.today().addDays(-7);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        // create an opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        // create in person visit associated with the new opp
        Event evtYesterday = TestUtilities.CreateNewEvent(false);
        evtYesterday.WhatId = opp.Id;
        evtYesterday.StartDateTime = dtYesterday;
        evtYesterday.Event_Type__c = 'In Person Visit';
        evtYesterday.Visit_Location__c = 'Campus';
        insert evtYesterday;
        
        // Oops, forgot that I also visited them last week but never recorded it
        Event evtLastWeek = TestUtilities.CreateNewEvent(false);
        evtLastWeek.WhatId = opp.Id;
        evtLastWeek.StartDateTime = dtLastWeek;
        evtLastWeek.Event_Type__c = 'In Person Visit';
        evtLastWeek.Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT;
        evtLastWeek.Executive_Type__c = 'CXO';
        evtLastWeek.Visit_Location__c = 'Campus';
        insert evtLastWeek;
        
        // and i visited them today -- better record that too
        Event evtToday = TestUtilities.CreateNewEvent(false);
        evtToday.WhatId = opp.Id;
        evtToday.StartDateTime = dtToday;
        evtToday.Event_Type__c = 'In Person Visit';
        evtToday.Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT;
        evtToday.Executive_Type__c = 'CXO';
        evtToday.Visit_Location__c = 'Campus';
        insert evtToday;
        
        //Start test from here
        Test.startTest();
        
        // get the updated opportunity
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        
        //Stop Test Here
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateInitialVisitDateByEventDate_DeleteEvent() { 
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        Date dtYesterday = system.today().addDays(-1);
        
        // create an opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        // create in person visit associated with the new opp
        Event evtYesterday = TestUtilities.CreateNewEvent(false);
        evtYesterday.WhatId = opp.Id;
        evtYesterday.StartDateTime = dtYesterday;
        evtYesterday.Event_Type__c = 'In Person Visit';
        evtYesterday.Visit_Location__c = 'Campus';
        insert evtYesterday;
        
        // now delete the event -- this should clear out the initial visit date on the Opportunity
        delete evtYesterday;
        
        //Start Test from here
        Test.startTest();
        
        // get the updated opportunity
        opp = [SELECT Id, Initial_Visit_Date__c FROM Opportunity WHERE Id = :opp.Id];
        
        //Stop Test Here
        Test.stopTest();
        
        // make sure that the Initial Visit Date is the EARLIEST of all of these visits
        system.assertEquals(null, opp.Initial_Visit_Date__c);
    }
    
    //Modified By Abhinav Sharma - 04/16/2014 - CR-20140321-4841 - Unable to change Opportunity Program if related Event is deleted
    static testmethod void testUpdateEventProgramAcronym() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.byPassAllTriggers= true;
        
        //Yesterday Date
        Date dtYesterday = system.today().addDays(-1);
        
        //String variable to hold the acronyms value
        String programAcronym = 'TYGH';
        
        //List to hold the event record
        List<Event> events = new List<Event>();
        
        //Create two programs
        Program__c program = TestUtilities.CreateNewProgram(true);
        Program__c program2 = TestUtilities.CreateNewProgram('RI Marketer', programAcronym, 'No', 'PT', false);
        insert program2;
        
        //Assert for the results
        System.assertNotEquals(null,program.id); 
        System.assertNotEquals(null,program2.id);   
        program2 = [select id, Program_Acronym__c from Program__c where id=:program2.id];
        System.assertEquals(programAcronym,program2.Program_Acronym__c);
        
        //Create an opportunity that references the HCAB program
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Program__c = program.Id;
        
        //Disable all other triggers
        Util.byPassAllTriggers= false;
        
        insert opp;
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Start Test from here
        Test.startTest();
        
        /*opp = [select id, program__c,program_acronym__c from Opportunity where id=:opp.id];
        System.debug('***** OPPORTUNITY: '+opp);
        System.assertNotEquals(null,opp.id);
        System.assertNotEquals(null,opp.Program__c);
        System.assertNotEquals(null,opp.Program_Acronym__c);
        
        //Create in person visit associated with the new opp
        Event evtYesterday = TestUtilities.CreateNewEvent(false);
        evtYesterday.WhatId = opp.Id;
        evtYesterday.StartDateTime = dtYesterday;
        evtYesterday.Event_Type__c = 'In Person Visit';
        insert evtYesterday;
        
        System.assertNotEquals(null,evtYesterday.id);
        evtYesterday = [select id, program__c from Event where whatId=:opp.id];
        System.assertEquals(opp.Program_acronym__c,evtYesterday.Program__c);
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Change the opportunity to reference the TYHG program
        Opportunity oppUpdated = [select id, Program__c from Opportunity where id=:opp.id];
        oppUpdated.Program__c = program2.id;
        update oppUpdated;
        
        oppUpdated = [select id, Program__c, Program_Acronym__c from Opportunity where id=:oppUpdated.id];
        System.assertEquals(oppUpdated.program__c,program2.id);
        
        //Verify that the program__c field on each child event matches the Program_acronym__c of the 
        //parent opportunity
        for(Event e : [select id, program__c from event where whatid=:oppUpdated.id]) {
            System.debug('***** OPP PROGRAM ACRONYM: ' + opp.Program_acronym__c + '***** EVENT PROGRAM ACRONYM: ' + e.Program__c);
            System.assertEquals(oppUpdated.Program_Acronym__c, e.program__c);
        }
        
        //Deleting the existing event associated on opportunity record
        delete evtYesterday;
        
        //Querying for related events (Activities) associated to the opportunity record
        events = [select id, program__c from event where whatid=:oppUpdated.id];
        System.assertEquals(0, events.size());
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Changing the Program reference on the opportunity record after activity record got deleted
        oppUpdated.Program__c = program.Id;
        update oppUpdated;
        
        //Asserting for the result for successful update once related activity got deleted
        System.assert(oppUpdated.Program__c == program.Id);*/
        
        //Stop Test Here
        Test.stopTest();
    }
    
    //Test method to test email send to sfAdmin Funtionality when any failure occurs during the batch
    static testmethod void testSendEmailFunctionality() {
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;

        //Bypass Dupeblocker
        Util.IsTest(true); 
               
        //Yesterday Date
        Date dtYesterday = system.today().addDays(-1);
        
        //Account
        Account account = TestUtilities.CreateNewAccount(true);
        System.assertNotEquals(null,account.id);
        
        //Programs
        Program__c program = TestUtilities.CreateNewProgram(true);
        System.assertNotEquals(null,program.id);
        
        //Start Test FROM here
        Test.startTest();
        
        //Membership
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.ID, false);
        membership.Next_Decision_Date__c = dtYesterday;
        insert membership;
        System.assertNotEquals(null,membership.id);
        
		 //Bypass the entity population Logic  
		Util.bypassAllTriggers = true;

        // create an opportunity that references the HCAB program
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.Membership__c = membership.Id;
        opp.Start__c = System.today().addDays(2);
        Opp.StageName = 'Pending- Renewal Call Not Yet Occured';
        opp.Opt_Out_Date__c = dtYesterday;
        insert opp;
        
		 //Bypass the entity population Logic  
		Util.bypassAllTriggers = false;


        //Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
        //Assigning fake Id into a look field for generating error while batch run
        //membership.HW_Lead__c = account.ID;
        
        //Execute Batch
        Batch_MembershipNextActivityDate controller = new Batch_MembershipNextActivityDate(null);
        ID batchID = Database.executeBatch(controller, 200);
        
        System.debug('@@@ debugLog ' + controller.debugLog);
        System.assertEquals('', controller.debugLog);
        
        //Stop Test Here
        Test.stopTest();
        
        //Calling Util class method for send email
        Util.sendBatchStatus(batchID, 'Batch_MembershipNextActivityDate', 'Test', 'test@test.com');
        
    }
}