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
@isTest
private class TestBatch_Opportunity_VisitSummaries {
/*
    Purpose:    This class is to test Batch Opportunity Visit Summaries.(CR-20120118-322)
                
    Create By:  Simplyforce Technology
    
    Created Date:   04/12/2012
    
    Current Version:    v1.0
    
    Revision Log:   V1.0 - Created    
                    V1.1 - New test method added - Bhavi Sharma - 11/21/2013 - CR-20130807-3382
                    V1.1 - (SUNJ 12/19/13) - CR-20130118-2218
                    V1.2 - Replaced Task_Purpose__c field to Event_Purpose__c field - Ajit Surana - 02/27/2014 - CR-20121226-1992
                    V1.3 - Test method (testOpportunityCounterUpdation) modified - Ajit Surana - 05/23/2014 - CR-20140320-4833
                    V1.4 - Modified By -(Abhinav Sharma) - Finish Deleting fields from Release 29 - 06/02/2014 - CR-20131120-4008 
                    V1.5 - Modified By - Victor  Hanson - CR-20150827-9195 - Move the unit test out of the Batch_OpportunityEvaluationCounts class and place it in the TestBatch_Opportunity_VisitSummaries class.
		    V1.6 - Modified By - Neha sharma - CR-20201110-14683
            	    V1.7 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
                    
    Coverage:       96%
*/
    //(Bhavi) - CR-20120516-875
    static testMethod void testBatch_OutreachCount() {

        Util.IsTesting = true;
        
        //Setting flag to bypass all triggers so then test data can be created
        Util.ByPassAllTriggers = true;

        // Create Test Data
        Program__c testProg = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'ZZT');
        insert testProg;

        Account testacct = new Account(Name = 'Test_Acct');
        insert testAcct;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        set<string> oppRecTypes = new set<String>{ Util.recordtypemap('Opportunity').get('RI Marketing'), Util.recordtypemap('Opportunity').get('PT Marketing') };

        List<Opportunity> testOpps = new List<Opportunity>();

        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        for(integer i = 0; i < 2; i++)
        {
            for(string oppRec : oppRecTypes)
            {
                //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
                Opportunity o = new Opportunity(Name = 'TestOpp' + i.format(), Sales_Pursuit_Products__c  = 'APS',RecordTypeId = oppRec, Amount = 1, StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, CloseDate = System.today(), Program__c = testProg.Id, AccountId = testAcct.Id);

                testOpps.add(o);
            }
        }
        
        //Setting flag values
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = true;
        
        //Enabling triggers again
        Util.ByPassAllTriggers = false;
        
        insert(testOpps);
        
        //Disabling triggers
        Util.ByPassAllTriggers = true;

        //(Bhavi) - CR-20120516-875
        
        //Fix for L2 Release - May 2020 - Start Here
        //List<RecordType> taskRecordTypes = [select Id from RecordType where SobjectType = 'Task' and Name LIKE '%Marketing%'limit 1];
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
        
        //Assert for the record types
        //System.assertEquals(1, taskRecordTypes.size());

        //Create a list of Tasks. Sum of outreach count of these tasks will be then added to the appropriate opportunity record
        List<Task> tasks = new List<Task>();

        for(Integer x = 0 ; x < testOpps.size(); x++) {

            // Create test events {
            for(Integer i = 0; i < 13; i++) {

                //Replaced Task_Purpose__c field to Event_Purpose__c field - Ajit Surana - 02/27/2014 - CR-20121226-1992
                //Add task in list to be updated
                tasks.add(new Task(Subject = 'Test', Event_Purpose__c = 'Initial', Cancelled_Did_Not_Occur__c = false, WhatId = testOpps[x].Id,
                                        RecordTypeId = taskPTMarketingRecordType /*taskRecordTypes[0].Id*/));
            }
        }
        
        //Replaced Task_Purpose__c field to Event_Purpose__c field - Ajit Surana - 02/27/2014 - CR-20121226-1992
        //Add a one more record, which will not contribute in outreach count
        tasks.add(new Task(Subject = 'Test', Event_Purpose__c = 'Initial', Cancelled_Did_Not_Occur__c = true, WhatId = testOpps[0].Id,
                                RecordTypeId = taskPTMarketingRecordType /*taskRecordTypes[0].Id*/));
        
        //Fix for L2 Release - May 2020 - Ends Here
        
         //Enabling triggers
        Util.ByPassAllTriggers = false;

        //Insert the task list
        insert tasks;

        //Map of tasks
        //Set<Id> oppIds = (new Map<Id, Opportunity>(testOpps)).keySet();

        Batch_Opportunity_VisitSummaries batch = new Batch_Opportunity_VisitSummaries();

        System.debug('### Test Batch Query String: ' + batch.Query);

        Test.startTest();

        Id batchId = Database.executeBatch(batch);

        Test.stopTest();

        system.assertNotEquals(null, batchId);

        System.debug('### Launched Batch : '+ batchId);

        testOpps = [select Total_Outreach_Opp__c from Opportunity where Id in :testOpps];

        //Assert the Outreach count
        for(Opportunity opp : testOpps) {

            //System.assertEquals(13, opp.Total_Outreach_Opp__c);
        }
    }
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testMethod void testBatch_Batch_Opportunity_VisitSummaries_DeletedEvents() {
        Util.IsTesting = true;
        
        //Setting flag to bypass all triggers so then test data can be created
        Util.ByPassAllTriggers = true;
    
        //Bypass the entity population Logic  
        Util.bypassEntityPopulation = true;
        
        // Create Test Data
        Program__c testProg = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'ZZT');
        insert testProg;

        Account testacct = new Account(Name = 'Test_Acct');
        insert testAcct;
        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        set<string> oppRecTypes = new set<String>{ Util.recordtypemap('Opportunity').get('RI Marketing'), Util.recordtypemap('Opportunity').get('PT Marketing') };

        Test.startTest();
        
        List<Opportunity> testOpps = new List<Opportunity>();
       //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        for(integer i = 0; i<2; i++) {

            for(string oppRec : oppRecTypes) {
                //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
                Opportunity o = new Opportunity(Name = 'TestOpp' + i.format(), RecordTypeId = oppRec, Amount = 1, Sales_Pursuit_Products__c  = 'APS',StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, CloseDate = System.today(), Program__c = testProg.Id, AccountId = testAcct.Id);

                testOpps.add(o);
            }
        }
        
        insert(testOpps);

        Date startD = Date.newInstance(2004, System.Today().month(), System.Today().day());
        Time startT = System.now().time().addMinutes(-1);
        Time endT = System.now().time().addHours(2);

        DateTime startDateTime = DateTime.newInstance(startD, startT);

        Date startDate = Date.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day());
        DateTime endDateTime = DateTime.newInstance(startD, endT);

        set<String> eventTypes = new set<String>{ 'In Person Visit', 'Phone Appointment' };
        List<Event> testEvents = new List<Event>();
        List<Id> testOppIds = new List<Id>();

        // DAF - added 9-21-11
        RecordType rt = [select Id from RecordType where SobjectType = 'Event' and Name = 'Sales' limit 1];
        
        //Contact
        contact con = new Contact (LastName = 'testName',Contact_Status__c ='Active',Email = 'testtdd@gmail.com', Title = 'testtingTitle', Phone = '23456787');
        insert con;

        for(integer x = 0 ; x < testOpps.size(); x++) {

            // Add opportunity Id to list
            testOppIds.add(testOpps[x].Id);

            // Create test events
            for(integer i = 0; i < 13; i++) {

                for(string evtType : eventTypes) {
                    /*
                    Counted Event Types:
                    "In Person Visit",
                    "Opportunity Visit - For Opportunity Goal",
                    "Prospect Meeting Attendee - Count as Visit"
                    */
                    String visitLocation = '';
                    if(evtType == 'In Person Visit')
                        visitLocation = 'Campus';
                        

                    Event evnt = new Event(
                        whatId = testOpps[x].Id,
                        ActivityDate = startDate.addYears(i),
                        ActivityDateTime = startDateTime.addYears(i),
                        StartDateTime = startDateTime.addYears(i),
                        EndDateTime = endDateTime.addYears(i).addDays(1),
                        RecordTypeId = rt.Id,   // DAF - added 9-21-11
			Visit_Location__c = visitLocation,
			Event_Type__c = evtType,
                        Event_Purpose__c = 'AM Transition',
            		Cancelled_Did_Not_Occur__c = False,
            		WhoId = con.Id
                    	
                    );

                    testEvents.add(evnt);

                    if(x == 1)
                        break;
                }
            }
        }
        
        DateTime dtnow = System.now().addDays(-10);
        Event evntDel = new Event(
                        whatId = testOpps[0].Id,
                        ActivityDate = dtnow.date(),
                        ActivityDateTime = dtnow,
                        StartDateTime = dtnow,
                        EndDateTime = dtnow.addDays(1),
                        RecordTypeId = rt.Id,
                        Event_Type__c = 'In Person Visit',
			Visit_Location__c = 'Campus',
            		Event_Purpose__c = 'AM Transition',
            		Cancelled_Did_Not_Occur__c = False,
            		WhoId = con.Id
			);
        testEvents.add(evntDel);
        
        //Enabling triggers again
        Util.ByPassAllTriggers = true;
        
        insert testEvents;
        evntDel = [SELECT Id FROM Event WHERE Id = :evntDel.Id];
        // delete the event prior to running the batch
        delete evntDel;
        // Run Test Batch
        Batch_Opportunity_VisitSummaries batch = new Batch_Opportunity_VisitSummaries();

        
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();


        system.assertNotEquals(null, batchId);

        System.debug('### Launched Batch : '+ batchId);

        testOpps = [select id, Previous_YTD_Visits__c, Current_YTD_Visits__c from Opportunity where Id in :testOpps];

        system.assertEquals(4, testOpps.size());

        //system.assertEquals(1, testOpps[0].X2012_Visits__c);
        //system.assertEquals(1, testOpps[0].Current_YTD_Visits__c);
    }

    //Code added for testing counter fields updation on Opportunity - Bhavi Sharma - 11/21/2013 - CR-20130807-3382
    //Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
    static testMethod void testOpportunityCounterUpdation() {

        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        SFListenerHelper.TriggerIsRunning = true;
        Util.IsBatch = true;

        // Create Test Data
        Program__c program = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'ZZT');
        insert program;

        Account account = new Account(Name = 'Test_Acct');
        insert account;

        // ensure that the record type custom setting has been updated with the correct values
        Util.resetRecordtypeSettings();
        set<string> oppRecTypes = new set<String>{ Util.recordtypemap('Opportunity').get('RI Marketing')};

        List<Opportunity> opportunities = new List<Opportunity>();
         //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
        for(integer i = 0; i<2; i++) {

            for(String oppRec : oppRecTypes) {
                //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
                opportunities.add(new Opportunity(Name = 'TestOpp' + i.format(), Sales_Pursuit_Products__c  = 'APS',RecordTypeId = oppRec, Amount = 1, StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, CloseDate = System.today(), Program__c = program.Id, AccountId = account.Id));
            }
        }

        //Insert opportunities
        insert opportunities;
        
        //convert the GMT datetime to user's timezone.
        TimeZone tz = UserInfo.getTimeZone();
        DateTime localTime = DateTime.now().AddSeconds(tz.getOffset(DateTime.now())/1000);
        DateTime startDateTime = localTime;
        Date startDate = localTime.date();
        DateTime endDateTime = localTime;
        Date endDate = localTime.date();

        List<Event> events = new List<Event>();
        List<Id> opportunityIds = new List<Id>();


        //Varibable
        Integer daysIncrementor = 0;
        Integer daysDecrementor = 0;
        Integer yearsIncrementor = 0;
        Integer yearsDecrementor = 0;

                //Test Starts here
        Test.startTest();


        // DAF - added 9-21-11
        RecordType rt = [select Id from RecordType where SobjectType = 'Event' and Name = 'Sales' limit 1];

        //Loop till Opportunities list size
        for(integer x = 0 ; x < opportunities.size(); x++) {

            // Add opportunity Id to list
            opportunityIds.add(opportunities[x].Id);

            if(x == 0) {

                // Create test events
                for(integer i = 0; i <= 2; i++)
                {
                    if(i == 0){  
                        /*
                        Event_Type__c = "In Person Visit" or "Opportunity Visit - For Opportunity Goal" or "Prospect Meeting Attendee - Count as Visit"
                        Event_Purpose__c = "Initial" or " "
                        Cancelled_Did_Not_Occur__c = false
                        Count__c = 1
                        */
                        yearsDecrementor -= 1;
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(-1) - 1, ActivityDateTime = startDateTime.addYears(-1) -1,
                                                    StartDateTime = startDateTime.addYears(-1) -1 , EndDateTime = startDateTime.addYears(-1).addDays(3),
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Initial',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 2, ActivityDateTime = startDateTime + 2,
                                                    StartDateTime = startDateTime + 2, EndDateTime = endDateTime.addDays(3),
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Initial',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(1) + 3, ActivityDateTime = startDateTime.addYears(1) + 3,
                                                    StartDateTime = startDateTime.addYears(1) + 3, EndDateTime = endDateTime.addYears(1).addDays(3) + 3,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Initial',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(2) + 4, ActivityDateTime = startDateTime.addYears(2) + 4,
                                                    StartDateTime = startDateTime.addYears(2) + 4, EndDateTime = endDateTime.addYears(2).addDays(3) + 4,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Initial',
                                                    Cancelled_Did_Not_Occur__c = false));
                    } else if(i == 1) {

                        /*
                        Event Type = "In Person Visit"
                        Event_Purpose__c = Follow Up
                        Cancelled_Did_Not_Occur__c = False
                        Count__c = 1
                        */
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 5, ActivityDateTime = startDateTime + 5,
                                                    StartDateTime = startDateTime + 5, EndDateTime = endDateTime.addDays(3) + 5,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus',  Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(-1) - 6, ActivityDateTime = startDateTime.addYears(-1) - 6,
                                                    StartDateTime = startDateTime.addYears(-1) - 6, EndDateTime = endDateTime.addYears(-1).addDays(3) - 6,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit',  Visit_Location__c = 'Campus', Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate - 7, ActivityDateTime = startDateTime - 7,
                                                    StartDateTime = startDateTime - 7, EndDateTime = endDateTime.addDays(3) - 7,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit',  Visit_Location__c = 'Campus', Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(2) + 8, ActivityDateTime = startDateTime.addYears(2) + 8,
                                                    StartDateTime = startDateTime.addYears(2) + 8, EndDateTime = endDateTime.addYears(2).addDays(3) + 8,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit',  Visit_Location__c = 'Campus', Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 9, ActivityDateTime = startDateTime + 9,
                                                    StartDateTime = startDateTime + 9, EndDateTime = endDateTime.addDays(3) + 9,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(1) + 9, ActivityDateTime = startDateTime.addYears(1) + 9,
                                                    StartDateTime = startDateTime.addYears(1) + 9, EndDateTime = endDateTime.addYears(1).addDays(3) + 9,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Event_Purpose__c = 'Follow Up',
                                                    Cancelled_Did_Not_Occur__c = false));
                    } else {
                        /*
                        Event Type = "Phone Appointment"
                        */
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(1) + 9, ActivityDateTime = startDateTime.addYears(1) + 9,
                                                    StartDateTime = startDateTime.addYears(1) + 9, EndDateTime = endDateTime.addYears(1).addDays(3) + 9,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 10, ActivityDateTime = startDateTime + 10,
                                                    StartDateTime = startDateTime + 10, EndDateTime = endDateTime.addDays(3) + 10,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(1) + 11, ActivityDateTime = startDateTime.addYears(1) + 11,
                                                    StartDateTime = startDateTime.addYears(1) + 11, EndDateTime = endDateTime.addYears(1).addDays(3) + 11,
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 12, ActivityDateTime = startDateTime + 12,
                                                    StartDateTime = startDateTime + 12, EndDateTime = endDateTime.addDays(3 + 12),
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 12, ActivityDateTime = startDateTime + 12,
                                                    StartDateTime = startDateTime + 12, EndDateTime = endDateTime.addDays(3 + 12),
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                        events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 12, ActivityDateTime = startDateTime + 12,
                                                    StartDateTime = startDateTime + 12, EndDateTime = endDateTime.addDays(3 + 12),
                                                    RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment', Cancelled_Did_Not_Occur__c = false));
                                                    
                    }
                }
            } else {

                /*
                Counted Event Types:
                "In Person Visit",
                "Opportunity Visit - For Opportunity Goal",
                "Prospect Meeting Attendee - Count as Visit"
                */
                events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(-1) + 13, ActivityDateTime = startDateTime.addYears(-1) + 13,
                                            StartDateTime = startDateTime.addYears(-1) + 13, EndDateTime = endDateTime.addYears(-1).addDays(3) + 13,
                                            RecordTypeId = rt.Id, Event_Purpose__c = 'Follow Up',
                                            Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Cancelled_Did_Not_Occur__c = false));
                events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate + 14, ActivityDateTime = startDateTime + 14,
                                            StartDateTime = startDateTime + 14, EndDateTime = endDateTime.addDays(3) + 14,
                                            RecordTypeId = rt.Id, Event_Type__c = 'Opportunity Visit - For Opportunity Goal'));
                events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(1) + 15, ActivityDateTime = startDateTime.addYears(1) + 15,
                                            StartDateTime = startDateTime.addYears(1) + 15, EndDateTime = endDateTime.addYears(1).addDays(3) + 15,
                                            RecordTypeId = rt.Id, Event_Type__c = 'Prospect Meeting Attendee - Count as Visit'));
                events.add(new Event(WhatId = opportunities[x].Id, ActivityDate = startDate.addYears(2) + 16, ActivityDateTime = startDateTime.addYears(2) + 16,
                                            StartDateTime = startDateTime.addYears(2) + 16, EndDateTime = endDateTime.addYears(2).addDays(3) + 16,
                                            RecordTypeId = rt.Id, Event_Type__c = 'Phone Appointment'));
            }
        }

        insert events;


        //Execute the batch
        Database.executeBatch(new Batch_Opportunity_VisitSummaries(), 200);

        //Test stops here
        Test.stopTest();

        //Query result of Opprotunities
        opportunities = [SELECT id, Prev_YTD_PAs__c, Previous_Year_Visits__c, Previous_YTD_Visits__c, Current_YTD_Visits__c,
                            Num_Total_Visits__c, Current_Year_Visits__c, Next_Year_Visits__c, Scheduled_Visits__c, Total_Follow_Up_Visits__c,
                            Current_YTD_Follow_Up_Visits__c, Previous_Year_Follow_Up_Visits__c, Previous_YTD_Follow_Up_Visits__c,
                            Current_Year_Follow_Up_Visits__c, Next_Year_Follow_Up_Visits__c, Scheduled_Follow_Up_Visits__c, Current_Year_PAs__c,
                            Next_Year_PAs__c, Scheduled_PAs__c, Num_Total_PAs__c FROM Opportunity WHERE Id IN :opportunities ORDER BY Name];

        System.assertEquals(2, opportunities.size());

        //assert statements
        //Visits Counter
        //System.assertEquals(4, opportunities[0].Num_Total_Visits__c);
        //System.assertEquals(1, opportunities[0].Previous_YTD_Visits__c);
        
        date firstDateNextYear = date.newInstance(date.today().addYears(1).year(), 1, 1);
        integer daysToNewYear = date.today().daysBetween(firstDateNextYear);
        
        //only test these if today is more than 12 days from newyear.  Otherwise, the assertions below get thrown off due to the dates being so close to new year
        if (daysToNewYear >= 12) {
            
           /* System.assertEquals(1, opportunities[0].Current_Year_Visits__c);
            System.assertEquals(1, opportunities[0].Next_Year_Visits__c);
            System.assertEquals(3, opportunities[0].Scheduled_Visits__c);
            
            //Followup counter
            System.assertEquals(6, opportunities[0].Total_Follow_Up_Visits__c);
            //System.assertEquals(1, opportunities[0].Current_YTD_Follow_Up_Visits__c);
            System.assertEquals(1, opportunities[0].Previous_Year_Follow_Up_Visits__c);
            //System.assertEquals(1, opportunities[0].Previous_YTD_Follow_Up_Visits__c);
            //System.assertEquals(3, opportunities[0].Current_Year_Follow_Up_Visits__c);
            System.assertEquals(1, opportunities[0].Next_Year_Follow_Up_Visits__c);
            System.assertEquals(4, opportunities[0].Scheduled_Follow_Up_Visits__c);
            
            //PAs Counter
            System.assertEquals(4, opportunities[0].Num_Total_PAs__c);
            System.assertEquals(2, opportunities[0].Current_Year_PAs__c);
            System.assertEquals(2, opportunities[0].Next_Year_PAs__c);
            System.assertEquals(4, opportunities[0].Scheduled_PAs__c);
            System.assertEquals(1, opportunities[1].Previous_Year_Follow_Up_Visits__c);
            System.assertEquals(0, opportunities[1].Previous_YTD_Follow_Up_Visits__c);
            System.assertEquals(1, opportunities[1].Scheduled_PAs__c); */
        }
    }
    
    /**
     * 
     * @description: 	Create a PT Marketing opportunities with 2 future events.
     *               	execute the batch_Opportunity_VisitSummaries job
     *               	verify the Most_Recent_Activity__c and Number_of_Follow_Up_Activities__c fields were updated properly
     *               	VH Added 9/22/2015 - CR-20150827-9195
     * @Version     :	Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
     **/
    static testmethod void testBatch_OpportunityEvaluationCounts(){ 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.ByPassAllTriggers = true;

        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
       //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
       //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Test', Sales_Pursuit_Products__c  = 'APS',StageName = 'Pending', CloseDate = System.today(), Are_They_Evaluating__c = 'Yes', 
                                          Is_there_are_hard_next_step__c = 'Yes', Initial_Visit_Date__c = date.today(),
                                          RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PT Marketing').getRecordTypeId());
        insert opp;

        Event evt = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(4), EndDateTime = datetime.now().addDays(5));
        insert evt;             

        Event evt2 = new Event(WhatId = opp.Id, StartDateTime = datetime.now().addDays(5), Event_Type__c = 'Phone Appointment',EndDateTime = datetime.now().addDays(6));
        insert evt2;   
        
        Util.ByPassAllTriggers = false;             

        Batch_Opportunity_VisitSummaries batch = new Batch_Opportunity_VisitSummaries();

        //batch.Query = 'select Id, Initial_Visit_Date__c, Most_Recent_Activity__c, Number_of_Follow_Up_Activities__c from Opportunity where Id = \'' + opp.Id + '\'';
       
        test.startTest();
        id batchId = database.executeBatch(batch);
        test.stopTest();

        opp = [select Number_of_Follow_Up_Activities__c, Most_Recent_Activity__c from Opportunity where Id = :opp.Id];
        system.debug('DAF: ' + opp.Number_of_Follow_Up_Activities__c + '   ' + opp.Most_Recent_Activity__c);
        system.assertEquals(evt2.EndDateTime.date(), opp.Most_Recent_Activity__c);
        system.assertEquals(0, opp.Number_of_Follow_Up_Activities__c);
    }
}