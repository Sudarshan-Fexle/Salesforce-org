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
private class Test_TriggerEvent {

    /**
    *  Purpose     :    Test class for EventTriggerHelper to test the population of "Next Activity Date" field value on the Opportunity.
    *
    *  Created By   :   Mahendra Swarnkar
    *
    *  Created Date:    11/16/2013
    *
    *  Revision Log:    V1.0 - Created
    *
    *  Coverage    :    V1.0 - Created
    *                   v1.1 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20140613-5790
    *                   v1.2 - Modified By - Abhinav Sharma - 09/07/2015 - CR-20140613-9161
    *                   v1.3 - Modified By - Abhinav Sharma - 11/25/2015 - CR-20150929-9281 - 95% Code Coverage
    *                   v1.4 - Modified By - Mahendra Swarnkar - 2/9/2016 - CR-20151221-9474 
    *                   v1.5 - Modified By - Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
    *                   v1.6 - Modified By - Abhinav Sharma - 12/10/2016 - CR-20160111-9502
    *                   v1.7 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
    *           	v1.8 - Modified By - Abhinav Sharma - 03/15/2017 - CR-20170307-10743
    * 			v1.9 - Modified By - Dipesh Gupta - 01/24/2020 - CR-20200110-13610
    * 			v2.0 - Modified By - Dipesh Gupta - 01/30/2020 - CR-20200102-13583
    *                   v2.1 - Modified By - Dipesh Gupta - 06/11/2020 - CR-20190607-13171 - Spring Cleaning - Advisory.com Account Reference Update
    *                   v2.2 - Modified By - Neha Sharma - 14/04/2021 - CR-20210202-14862
    **/
    
    static testMethod void testUpdateNextActivityDate() {

        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];

        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();

        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType){
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        }
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');

        System.runAs(u) {
        
            //Insert Opportunity Records
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(3),Sales_Pursuit_Products__c = 'APS' ));
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(4),Sales_Pursuit_Products__c = 'APS' ));
            Insert oppList;
            
            //List to hold Events
            List<Event> events = new List<Event>();
            
            //Populate List
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(4), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(3), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(5), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            events.add(new Event(RecordTypeId = mapEventRecordType.get('BI_QA_Call') ,StartDateTime = system.today().addDays(2), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
             events.add(new Event(Credit__c = 9 ,StartDateTime = system.today().addDays(2), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            
            //Test Start from here
            Test.startTest();
            
            //Enables all the triggers
            Util.BypassAllTriggers = false;
            
            //Insert Events
            insert events;
            
            //Query through Opportunity for validate Next_Activity_Date field value
            List<Opportunity> oppResultList = [SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[0].Id];
            
            //Assert for result
            /*system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c );
            
            //Update Event records
            events[0].StartDateTime = system.today().addDays(2);
        
            //Update Events
            update events[0];
        
            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[0].Id ];

            //Assert for result
            system.assertEquals(system.today().addDays(2) , oppResultList[0].Next_Activity_Date__c );

            //Update Event records
            events[1].WhatId = oppList[1].Id ;
        
            //Update events
            update events[1];

            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[1].Id ];

            //Assert for result
            system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c );
        
            //Test stops here
            Test.stopTest();
            
            //Delete events
           delete events;

            //Query through Opportunity for validate Next_Activity_Date field value
            oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: oppList[1].Id OR Id =: oppList[0].Id ];

            //Assert for result
            system.assertEquals(null , oppResultList[0].Next_Activity_Date__c );
            system.assertEquals(null , oppResultList[1].Next_Activity_Date__c );*/
        }
    }
    
    //Modified by Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903
    //Test method to validate population of "Most Recent QA Call Date" field value on membership records
    static testMethod void testPopulateMostRecentQACallDate() {

        //Setting flag value to bypass manage package code execution while testing
        //CRMfusionDBR101.DB_Globals.triggersDisabled = true;
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);

        //Account
        Account a = new Account(Name = 'testacct');
        insert a;

        //Program
        Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
        insert p;

        //Membership
        Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem;
        Membership__c mem2 = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
        insert mem2;
        
        //Query the Event record type details
        List<RecordType> listEventRTypes = [Select Id, DeveloperName From RecordType 
                                                where SobjectType = 'Event' 
                                                AND IsActive = true 
                                                AND DeveloperName IN (/*'RI_QA_Call', */'BI_QA_Call')];
        Id eventPTRecordType;
        //Id eventRIRecordType;
        if(listEventRTypes[0].DeveloperName == 'RI_QA_Call'){
            //eventRIRecordType = listEventRTypes[0].Id;
            eventPTRecordType = listEventRTypes[1].Id;
        }
        else{
            //eventRIRecordType = listEventRTypes[1].Id;
            eventPTRecordType = listEventRTypes[0].Id;
        }
            
        
        //Event
        List<Event> evntList = new List<Event>();

        //Setting date time variables
        DateTime DTStart = System.Now().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)-2);
        Date DStart = DTStart.date();

        //Event s
        evntList.add(new Event(WhatId = mem.Id, recordTypeID = eventPTRecordType, StartDateTime = DTStart, ActivityDateTime = DTStart, ActivityDate = DStart, EndDateTime = DTStart, Event_Type__c = 'PT QA Call', Grade__c = 'C'));
        evntList.add(new Event(WhatId = mem.Id, recordTypeID = eventPTRecordType, StartDateTime = DTStart.addDays(-1), ActivityDateTime = DTStart.addDays(-1), ActivityDate = DStart.addDays(-1), EndDateTime = DTStart.addDays(-1), Event_Type__c = 'PT QA Call', Grade__c = 'C'));
        /*evntList.add(new Event( whatId = mem.Id, recordTypeID = eventRIRecordType, Event_Type__c = 'RI QA Call', Executive_Type__c = 'N/A', Grade__c = 'c', Would_Refer__c = '8', Would_Buy_Again__c = '9', 
                                StartDateTime = DTStart, ActivityDateTime = DTStart, ActivityDate = DStart, Project_Sponsor_On_Call__c = 'Yes',
                                EndDateTime = DTStart.addDays(1)));*/
        
        //Start testing from here
        Test.startTest();
        
        //Setting flag values and enabling triggers
        Util.byPassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Inserting the event records will execute the event trigger and that will update the membership data
        insert evntList;

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];

        //Asserting for the field value 
        System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);

        //Update the exisitng event
        evntList[0].WhatId = mem2.Id;
        evntList[1].recordTypeID = eventPTRecordType;
        //evntList[2].Event_Type__c = 'CM QA Call';
        
        update evntList;

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];
        mem2 = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem2.id];
        
        //Asserting for the field value
        //System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);
        //System.assertEquals(DStart, mem2.Most_Recent_QA_Call_Date__c);

        //Stop Test here
        Test.stopTest();
        
        //delete case
        delete evntList[0];

        //Querying for membership record
        mem = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem.id];
        mem2 = [select Id, Most_Recent_QA_Call_Date__c FROM Membership__c where Id = :mem2.id];

        //Asserting for the field value
        //System.assertEquals(DStart, mem.Most_Recent_QA_Call_Date__c);
        //System.assertEquals(null, mem2.Most_Recent_QA_Call_Date__c); 
    }
    
    //Modified By - Abhinav Sharma - CR-20151008-9304 - In order to fix 101 SOQL error occred in test class itself
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20140613-5790
    static testMethod void testpopulatePAsAndActivityFieldsOnWarmLead() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            Date todayDate = Date.newInstance(2015, 9, 4);
            DateTime todayDateTime = DateTime.newInstance(2015, 9, 4, 8, 6, 16);
            
            //Create Opportunity record
            Opportunity opportunity_1 = new Opportunity(Name = 'Opportunity Test1', StageName = '0-Exploring', Amount = 4.00,
                                                         CloseDate = todayDate, RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(3),
                                                         Competitor_Notes__c = 'Test 1',Sales_Pursuit_Products__c = 'APS'
                                                       );
            
            //Create Opportunity record
            Opportunity opportunity_2 = new Opportunity(Name = 'Opportunity Test2', StageName = '0-Exploring', Amount = 4.00, 
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(2),
                                                         Initial_Activity_Date__c = todayDate.addDays(5),
                                                         Competitor_Notes__c = 'Test 2',Sales_Pursuit_Products__c = 'APS');
                                                         
            //Create Opportunity record
            Opportunity opportunity_3 = new Opportunity(Name = 'Opportunity Test3', StageName = '0-Exploring', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Initial_Activity_Date__c = null,
                                                         Competitor_Notes__c = 'Test 3',Sales_Pursuit_Products__c = 'APS');
            
            //Create Opportunity record
            Opportunity opportunity_4 = new Opportunity(Name = 'Opportunity Test4', StageName = '0-Exploring', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = todayDate.addDays(5),
                                                         Initial_Activity_Date__c = todayDate.addDays(3),
                                                         Competitor_Notes__c = 'Test 4',Sales_Pursuit_Products__c = 'APS');
                                                         
            //Create Opportunity record
            Opportunity opportunity_5 = new Opportunity(Name = 'Opportunity Test5', StageName = '0-Exploring', Amount = 4.00,
                                                         CloseDate = todayDate.addDays(4), RecordTypeId = recordTypes[0],
                                                         Initial_PA_Date__c = null, Competitor_Notes__c = 'Test 5',
                                                         Initial_Activity_Date__c = todayDate.addDays(5),Sales_Pursuit_Products__c = 'APS');
            
            //Adding records in the list
            opportunities.add(opportunity_1);
            opportunities.add(opportunity_2);
            opportunities.add(opportunity_3);
            opportunities.add(opportunity_4);
            opportunities.add(opportunity_5);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert Opprotunity
            insert opportunities;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c, Competitor_Notes__c FROM Opportunity
                                ORDER BY Competitor_Notes__c ASC];
            
            //Program__c prog = [select id from Program__c limit 1];
            Program__c prog = new Program__c(Name = 'TestProg', Program_Acronym__c = 'TEST', Status__c = 'Active', 
                                                Create_Memberships__c = 'Yes');
            
            //insert program
            Util.byPassAllTriggers = true;
            insert prog;
        
            //List to hold the warm lead records
            List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
            
            //Warm lead
            Warm_Lead__c warmLead_1 = new Warm_Lead__c(Name = 'Test Warm Lead 1', Grade__c = '1', Lead_Date__c = todayDate,
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
            
            Warm_Lead__c warmLead_2 = new Warm_Lead__c(Name = 'Test Warm Lead 2', Grade__c = '2', Lead_Date__c = todayDate,
                                                        Lead_Channel__c = 'Breakout', Contact_level__c = 'CXO', 
                                                        Marketing_Associate_Assignment__c = usr.Id,
                                                        Marketer_Assignment__c = usr.Id, Status__c = 'Pending', 
                                                        Primary_Program__c = prog.Id);
                                                        
            //Adding records into the list
            warmLeads.add(warmLead_1);
            warmLeads.add(warmLead_2);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert warm leads
            insert warmLeads;
            
            //List to hold the warm lead record
            List<Warm_Lead_MtM__c> warmLeadMtMs = new List<Warm_Lead_MtM__c>(); 
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_1 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[0].Id);
        
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_3 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[1].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_2 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[2].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_4 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[0].Id, Opportunity__c = opportunities[3].Id);
            
            //Create WarmLeadMtM record
            Warm_Lead_MtM__c warmLeadMtM_5 = new Warm_Lead_MtM__c(Warm_Lead__c = warmLeads[1].Id, Opportunity__c = opportunities[4].Id);
            
            //Populating list with records
            warmLeadMtMs.add(warmLeadMtM_1);
            warmLeadMtMs.add(warmLeadMtM_2);
            warmLeadMtMs.add(warmLeadMtM_3);
            warmLeadMtMs.add(warmLeadMtM_4);
            warmLeadMtMs.add(warmLeadMtM_5);
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //Insert Warm lead Mtm's
            insert warmLeadMtMs;
            
            //Warm Lead MTMs
            warmLeadMtMs = [SELECT ID, Opportunity_Initial_PA__c, Opportunity_Initial_Activity__c, Opportunity__c,
                                Opportunity__r.Competitor_Notes__c FROM Warm_Lead_MtM__c
                                WHERE Opportunity__c != null ORDER BY Opportunity__c ASC];
            
            //Asserting for the results
            System.assertEquals(5, warmLeadMtMs.size());
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[0].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[1].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[1].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[2].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[2].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_PA__c);
            System.assertEquals(null, warmLeadMtMs[3].Opportunity_Initial_Activity__c);            
            
            //List of event records
            List<Event> events = new List<Event>();
            
            //Event 1
            Event evt_1 = new Event(WhatId = opportunities[0].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_2 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime.addDays(2), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(2), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Intro PA');
            Event evt_3 = new Event(WhatId = opportunities[2].Id, StartDateTime = todayDateTime.addDays(-2), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-2), 
                                    Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
            Event evt_4 = new Event(WhatId = opportunities[3].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Initial');
            Event evt_5 = new Event(WhatId = opportunities[4].Id, StartDateTime = todayDateTime.addDays(-400), 
                                    Cancelled_Did_Not_Occur__c = true,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-400), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_6 = new Event(WhatId = opportunities[0].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Follow Up');
            Event evt_7 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Follow Up');
            Event evt_8 = new Event(WhatId = opportunities[2].Id, StartDateTime = todayDateTime, 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1), 
                                    Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial', Visit_Location__c = 'Campus');
            Event evt_9 = new Event(WhatId = opportunities[3].Id, StartDateTime = todayDateTime.addDays(110), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(110), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
            Event evt_10 = new Event(WhatId = opportunities[4].Id, StartDateTime = todayDateTime.addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false,
                                    EndDateTime = todayDateTime.addHours(1).addDays(-10), 
                                    Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Intro PA');
            
            //Adding records into the list
            events.add(evt_1);
            events.add(evt_2);
            events.add(evt_3);
            events.add(evt_4);
            events.add(evt_5);
            events.add(evt_6);
            events.add(evt_7);
            events.add(evt_8);
            events.add(evt_9);
            events.add(evt_10);
            
            //Test will start from here
            Test.startTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            
            //Insert events
            insert events;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c 
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(todayDate, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(todayDate, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(110), opportunities[3].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(110), opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(-10), opportunities[4].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-10), opportunities[4].Initial_Activity_Date__c);
             
            //Stop Test here
            Test.stopTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            
            //delete events
            List<Event> eventsToDeleteOrUpdate = new List<Event>();
            eventsToDeleteOrUpdate.add(events[0]);
            eventsToDeleteOrUpdate.add(events[6]);
            eventsToDeleteOrUpdate.add(events[7]);
            eventsToDeleteOrUpdate.add(events[8]);
            eventsToDeleteOrUpdate.add(events[9]);
	    delete eventsToDeleteOrUpdate;
            
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(null, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[3].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[4].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[4].Initial_Activity_Date__c);
                                
            //Update events
            events[5].Event_Purpose__c = 'Initial';
            events[4].Cancelled_Did_Not_Occur__c = false;
            events[2].Event_Purpose__c = 'Intro PA';
            events[1].StartDateTime = todayDateTime.addDays(360);
            events[1].EndDateTime = todayDateTime.addDays(360).addHours(1);
                                
            eventsToDeleteOrUpdate = new List<Event>();  
            eventsToDeleteOrUpdate.add(events[5]);
            eventsToDeleteOrUpdate.add(events[4]);
            eventsToDeleteOrUpdate.add(events[2]);
            eventsToDeleteOrUpdate.add(events[1]);
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
            update eventsToDeleteOrUpdate;
                                
            //Querying for opportunity records
            opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c 
                             FROM Opportunity
                             ORDER BY Competitor_Notes__c ASC];
            
            //Asserts for the results
            System.assertEquals(5, opportunities.size());
            
            System.assertEquals(todayDate, opportunities[0].Initial_PA_Date__c);
            System.assertEquals(todayDate, opportunities[0].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(360), opportunities[1].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(360), opportunities[1].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
            
            System.assertEquals(null, opportunities[3].Initial_PA_Date__c);
            System.assertEquals(null, opportunities[3].Initial_Activity_Date__c);
            
            System.assertEquals(todayDate.addDays(-400), opportunities[4].Initial_PA_Date__c);
            System.assertEquals(todayDate.addDays(-400), opportunities[4].Initial_Activity_Date__c);
        }
    } 
    
   //Added By - Abhinav Sharma - 09/07/2015 - CR-20140613-9161
   static testMethod void updateEventHistoryTrackingFields() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //Account
            Account a = new Account(Name = 'testacct');
            insert a;
            
            //Modified By - Dipesh Gupta - 01/30/2020 - CR-20200102-13583 start
            //Contact
            contact con = new Contact (LastName = 'testName',Contact_Status__c ='Active',Email = 'testtdd@gmail.com', Title = 'testtingTitle', Phone = '23456787');
            insert con;
    
            //Program
            Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
            insert p;
        
            //Membership
            Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
            insert mem;
            
            //Event
            List<Event> evntList = new List<Event>();
    
            //Setting date time variables
            DateTime DTStart = System.Now().addDays(62);
            Date DStart = DTStart.date();
            
            //Query through Opportunity RecordTypes
            List<RecordType> recordTypes = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

            //Event s
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, WhoId = con.Id, RecordTypeId = recordTypes[0].Id, StartDateTime = System.Now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, 
                                   Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.Now().addHours(1), Event_Type__c = 'In Person Visit',Visit_Location__c = 'Campus', Executive_Type__c = 'CXO'));
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, WhoId = con.Id, RecordTypeId = recordTypes[0].Id, StartDateTime = System.Now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, 
                                   Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.Now().addHours(1), Event_Type__c = 'In Person Visit',Visit_Location__c = 'Campus', Executive_Type__c = 'CXO'));
    
            //Modified By - Dipesh Gupta - 01/30/2020 - CR-20200102-13583 end
            //Start testing from here
            Test.startTest();
    
            //Inserting the event records will execute the event trigger and that will update the membership data
            insert evntList;
            
            //update event
            evntList[0].StartDateTime = System.Today().addDays(4);
            evntList[0].EndDateTime =   System.Today().addDays(4);
            evntList[0].EndDateTime = evntList[0].EndDateTime.addHours(1);
            
            //Setting flag values and enabling triggers
            Util.byPassAllTriggers = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
            OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

            //update event list
            update evntList;
            
            //List or query result
            List<Event> listEvent = [Select Id , Cancelled_Did_Not_Occur_Last_Modify_Date__c, Start_Date_Time_Last_Modified_Date__c                
            //Spring Clean Up - of_Times_Start_Date_Time_Updated__c 
            FROM Event WHERE WhatId =: mem.Id and Id =: evntList[0].Id];
            
            //assert here                                                   
            //system.assertEquals(1, listEvent[0].of_Times_Start_Date_Time_Updated__c);
            system.assertEquals(null, listEvent[0].Cancelled_Did_Not_Occur_Last_Modify_Date__c);
            
            //Test stop here
            Test.stopTest();
            
            //Enable triggers
            util.byPassAlltriggers = true;
            
            //update event
            evntList[0].StartDateTime = System.Today().addDays(6);
            evntList[0].EndDateTime =   System.Today().addDays(6);
            evntList[0].EndDateTime = evntList[0].EndDateTime.addHours(1);
            evntList[0].Cancelled_Did_Not_Occur__c = true;
            
            //Enable triggers
            Util.byPassAlltriggers = false;
            
            //update event list
            update evntList;
            
            //Query list of event
            listEvent = [Select Id , start_date_time_last_modified_date__c,
                            Cancelled_Did_Not_Occur_Last_Modify_Date__c
                            FROM Event WHERE WhatId =: mem.Id and Id =: evntList[0].Id];
            
            //assert here
            //system.assertEquals(2, listEvent[0].of_Times_Start_Date_Time_Updated__c);
        }
    }
    
    //Added By - Abhinav Sharma - 11/25/2015 - CR-20150929-9281
    static testMethod void testPopulateinitialStartDate() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
                            TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
        
            //Account
            Account a = new Account(Name = 'testacct');
            insert a;
    
            //Program
            Program__c p = new Program__c(Name = 'testprog', Program_Acronym__c = 'test');
            insert p;
        
            //Membership
            Membership__c mem = new Membership__c(Account_Name__c = a.id, Program__c = p.id);
            insert mem;
            
            //Event
            List<Event> evntList = new List<Event>();
    
            //Setting date time variables
            DateTime DTStart = System.Now().addDays(62);
            Date DStart = DTStart.date();
            
            //Query through Opportunity RecordTypes
            List<RecordType> recordTypes = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'BI_Marketing' OR DeveloperName = 'BI_QA_Call') 
                                                AND SObjectType = 'Event' AND IsActive = true];

            //Event s
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, 
                                    StartDateTime = System.now().addDays(-10), 
                                    Cancelled_Did_Not_Occur__c = false, 
                                   Initial_Start_Date_Time__c = null,
                                    EndDateTime = System.now().addHours(1), Event_Type__c = 'Testing', 
                                    Executive_Type__c = 'CXO'));
            evntList.add(new Event(OwnerId = usr.Id, WhatId = mem.Id, RecordTypeId = recordTypes[0].Id, 
                                   StartDateTime = System.now().addDays(-10), 
                                   Cancelled_Did_Not_Occur__c = false, 
                                   Initial_Start_Date_Time__c = null,
                                   EndDateTime = System.now().addHours(1), 
                                   Event_Type__c = 'In Person Visit', Visit_Location__c = 'Campus', Executive_Type__c = 'CXO'));
            
            //Start Test from here
            Test.startTest();
            
            //Enabling triggers again
            Util.byPassAllTriggers = false;
            try {
            	
                //Insert events
                insert evntList;
                
                //Querying for the results and applying asserts
                evntList = [SELECT ID, Event_Type__c,
                            Initial_Start_Date_Time__c
                                , StartDateTime
                                FROM Event ORDER BY Event_Type__c ASC];
                
                //Asserting for the results
                System.assertEquals('In Person Visit', evntList[0].Event_Type__c);
                System.assertEquals('Testing', evntList[1].Event_Type__c);
                /*System.assertEquals(evntList[0].StartDateTime, evntList[0].Initial_Start_Date_Time__c);
                System.assertEquals(null, evntList[1].Initial_Start_Date_Time__c); */
                
                //Updating event
                evntList[0].StartDateTime = System.now();
                evntList[1].Event_Type__c = 'In Person Visit';
                evntList[1].Visit_Location__c = 'Campus';
                update evntList;
                
                //Querying for the results and applying asserts
                evntList = [SELECT ID, Event_Type__c, StartDateTime
                                FROM Event ORDER BY StartDateTime ASC];
                
                //Asserting for the results
                System.assertEquals('In Person Visit', evntList[0].Event_Type__c);
                System.assertEquals('In Person Visit', evntList[1].Event_Type__c);
               /* System.assert(evntList[0].Initial_Start_Date_Time__c != null);
                System.assert(evntList[1].Initial_Start_Date_Time__c != null);
                System.assertNotEquals(System.now(), evntList[0].Initial_Start_Date_Time__c);
                System.assertNotEquals(evntList[1].StartDateTime, evntList[1].Initial_Start_Date_Time__c); */
                
                //Stop Test here
                Test.stopTest();
           
            }catch (Exception e) {
                
            }
            
        }        
    }
    
    //Added By - Mahendra Swarnkar - 2/9/2016 - CR-20151221-9474
    static testMethod void testpopulateVisitActivityField() {
        
        //Bypassing all trigger so then test data can be easily created
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Running test in context of system admin user
        System.runAs(usr) {
            
            //Create account records
            List<Account> accList = new list<Account>();
            accList.add(new Account(Name = 'Test_Account1', Account_Formal_Name__c = 'TestAccount1 ascbamdvlamcajzxmmzxjsjzxczxmczmzmxzmxzmxjjncnncncncncnnvvnvnvnvnvnvnvnvnvnvnnvnvnvnvnvnvnvnvnvncscnscknjsncknsjnjscnjncjncnmnmznxmzmnxzmnmznxmznxzmnmznxmznmnxmznxmzxnmznxmzxnmzxnmznxmzxnzmnxmznxzmnxmzxnmzxnmznxmznmnxjhshdgdncnnccnbvhdkjcmcjv' ));
            accList.add(new Account(Name = 'Test_Account2', Account_Formal_Name__c = 'TestAccountFormalName2' ));
            
            //Insert Account records
            insert accList;
            
            //Assert for the results
            System.assert(accList != null);
            System.assertEquals(2, accList.size());
            
            //list to hold the opportunity records
            List<Opportunity> opportunities = new List<Opportunity>();
            
            // get one record type name
            List<Id> recordTypes = new List<Id>();
            recordTypes.add(Util.RecordTypeId('Opportunity',Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE));
            
            //Create Opportunity record
            opportunities.add(new Opportunity(Name = 'Opportunity Test1', StageName = '0-Exploring', Amount = 4.00,
                                              AccountId = accList[0].Id, CloseDate = system.today(),    
                                              RecordTypeId = recordTypes[0], Sales_Pursuit_Products__c = 'APS'));
            opportunities.add(new Opportunity(Name = 'Opportunity Test2', StageName = '0-Exploring', Amount = 4.00,
                                              AccountId = accList[1].Id, CloseDate = system.today().addDays(4), 
                                              RecordTypeId = recordTypes[0],Sales_Pursuit_Products__c = 'APS'));
            
            //Disabling triggers
            Util.byPassAllTriggers = true;
            
            //insert Opprotunities
            insert opportunities;
            
            //Assert for the results
            System.assert(opportunities != null);
            System.assertEquals(2, opportunities.size());
            
            //Create Event records
            List<Event> events = new List<Event>();
            events.add(new Event(WhatId = opportunities[0].Id, StartDateTime = system.now(),
                                 EndDateTime = system.now().addHours(1), 
                                 Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial'));
            events.add(new Event(WhatId = opportunities[1].Id, StartDateTime = system.now(),
                                 EndDateTime = system.now().addHours(1), 
                                 Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial'));
            
            //Test will start from here
            Test.startTest();
            
            //Disabling triggers and setting flag value
            Util.byPassAllTriggers = false;
            
            //Insert events
            insert events;
            
            //Querying for event records
            events = [SELECT ID,  WhatID, EndDateTime FROM Event];
            
            //Querying for opportunity records
            Map<Id,Opportunity> mapOpp  = new Map<Id,Opportunity>([SELECT ID, Name, Account.Account_Formal_Name__c 
                                                                   FROM Opportunity]);
            
            //Asserts for the results
            System.assertEquals(2, events.size());
            
            //String to hold expected Visit fields value for events[0]
            String str = ((String.valueOf(events[0].EndDateTime.month()).length() == 1 ? '0' + String.valueOf(events[0].EndDateTime.month()) : String.valueOf(events[0].EndDateTime.month())) +  
                                '/' + (String.valueOf(events[0].EndDateTime.day()).length() == 1 ? '0' + String.valueOf(events[0].EndDateTime.day()) : String.valueOf(events[0].EndDateTime.day())) + 
                                '/' + events[0].EndDateTime.year() + ' - ' + mapOpp.get(events[0].WhatId).Account.Account_Formal_Name__c).trim();
            
            //Assert for the result
            //System.assertEquals(str.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH) ? str.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) : str, events[0].Visit__c);
             
            //String to hold expected Visit fields value for events[1]
            str = ((String.valueOf(events[1].EndDateTime.month()).length() == 1 ? '0' + String.valueOf(events[1].EndDateTime.month()) : String.valueOf(events[1].EndDateTime.month())) +  
                                '/' + (String.valueOf(events[1].EndDateTime.day()).length() == 1 ? '0' + String.valueOf(events[1].EndDateTime.day()) : String.valueOf(events[1].EndDateTime.day())) + 
                                '/' + events[1].EndDateTime.year() + ' - ' + mapOpp.get(events[1].WhatId).Account.Account_Formal_Name__c).trim();
            
            //Assert for the result                    
           // System.assertEquals( str.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH) ? str.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) : str, events[1].Visit__c);
  
           //Stop Test here
           Test.stopTest(); 
        }
    } 
    
   //Commented By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Because as per the new "PSS process" it is no longer needed. 
   //Added By - Abhinav Sharma - 12/10/2016 - CR-20160111-9502
  /***static testMethod void testsyncUpPSSrequestsFields() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile 
                        WHERE Name='System Administrator']; 
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        //Users
        List<User> users = new list<user>();
        
        //Run in this user context
        System.runAs(u) {
        
            // The following code runs as user 'u'
            User u1 = new User(Alias = 'standt', Email='standarduse676r@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing45465656', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com', Employee_ID__c = 'Testing 1');
            User u2 = new User(Alias = 'standt', Email='standarduser656@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing656556', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com', Employee_ID__c = 'Testing 2');
            users.add(u1);
            users.add(u2);
            insert users;
        }
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
        //program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        insert prog;
        
        //Membership
        Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, true);
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',
                                       Employee_Id__c = 'Testing 1');
        Contact contact2 = new Contact(LastName = 'TestT', FirstName = 'ConT', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',
                                       Employee_Id__c = 'Testing 2');
        contacts.add(contact);
        contacts.add(contact2);                               
        insert contacts;
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];
        System.assert(oppRecord.size() > 0);

        //Insert Opportunity Records
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                    CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                    AccountID = account.Id
                                   ));
        insert oppList;    
        
        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'Core_Marketing' OR DeveloperName = 'Core_AM') 
                                                AND SObjectType = 'Event' AND IsActive = true];
        System.assert(eventRecordType.size() > 0);
        
        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();

        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType){
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        }
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_Marketing') ,StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
        insert events;
        
        //Query through Opportunity RecordTypes
        List<RecordType> pSSRequestRecordType = [SELECT Id, Name, SObjectType, DeveloperName FROM RecordType 
                                                    WHERE DeveloperName = 'AM_EAB' 
                                                    AND SObjectType = 'PSS_Request__c' AND IsActive = true];
        System.assert(pSSRequestRecordType.size() > 0);
        
        //List Record Type custom setting        
        list<Recordtype_Setting__c> rdTypeSettings = new list<Recordtype_Setting__c>();
        Recordtype_Setting__c rdS = new Recordtype_Setting__c(SFID__c = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name__c = pSSRequestRecordType[0].Name,
                                                                SObjectType__c = pSSRequestRecordType[0].SObjectType);
        rdTypeSettings.add(rdS);
        insert rdS;
        
        //List of PSS Requests
        List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
        
        //PSS Request
        PSS_Request__c pSSRequest = new PSS_Request__c();
        pSSRequest.Activity_ID__c = events[0].ID;
        pSSRequest.Opportunity__c = events[0].WhatID;
        
        //Adding PSS Request records into the list
        pSSRequests.add(pSSRequest);
        
        //Start test from here
        Test.startTest();
        
        //Insert PSS Requests
        insert pSSRequests;
        
        //Querying for the results
        List<PSS_Request__c> pSSRequestsForAsserts = [SELECT ID, Subject__c, Event_Type__c, Activity_ID__c, Opportunity__c
                                                      FROM PSS_Request__c];
        
        //Asserting for the results
        System.assertEquals(1, pSSRequestsForAsserts.size());
        System.assertEquals(null, pSSRequestsForAsserts[0].Subject__c);
        System.assertEquals(null, pSSRequestsForAsserts[0].Event_Type__c);
        System.assertEquals(events[0].ID, pSSRequestsForAsserts[0].Activity_ID__c);
        System.assertEquals(events[0].WhatID, pSSRequestsForAsserts[0].Opportunity__c);
        
        //Enabling Triggers
        Util.byPassAllTriggers = false;
        
        //Update event
        events[0].Event_Type__c = 'Testttttt';
      update events;
        
        //Querying "PSS Request" records
        pSSRequestsForAsserts = [SELECT ID, Subject__c, Event_Type__c
                                                      FROM PSS_Request__c];
        
        //Stop here
        Test.stopTest();
    }
  **/ 
 //Commented By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Because as per the new "PSS process" it is no longer needed. -- Ends here
  
    //Added By - Abhinav Sharma - 03/15/2017 - CR-20170307-10743
    static testMethod void testRestrictProfilesFromDeletingTheEvents_1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile 
                        WHERE Name='System Administrator']; 
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        
        //Run in this user context
        System.runAs(u) {
            
            //Account
            Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
            insert account;
        
            //program
            Program__c prog = TestUtilities.CreateNewProgram(false);
            insert prog;
            
            //Membership
            Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, true);
        
            //Query through Opportunity RecordTypes
            List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                            WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                            AND SObjectType = 'Opportunity'
                                            AND IsActive = true];
            System.assert(oppRecord.size() > 0);

            //Insert Opportunity Records
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                        StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                        CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                        AccountID = account.Id,Sales_Pursuit_Products__c = 'APS'
                                       ));
            insert oppList;    
        
            //Query through Opportunity RecordTypes
            List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                    WHERE (DeveloperName = 'Core_Marketing' OR DeveloperName = 'Core_AM') 
                                                    AND SObjectType = 'Event' AND IsActive = true];
            System.assert(eventRecordType.size() > 0);
            
            //Map to hold record type DeveloperName as key and record type Id as value
            Map<String,Id> mapEventRecordType =  new Map<String,Id>();
    
            //Populate mapEventRecordType
            for(RecordType rt : eventRecordType){
                mapEventRecordType.put(rt.DeveloperName , rt.Id);
            }
        
            //List to hold Events
            List<Event> events = new List<Event>();
            
            //Populate List
            events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_Marketing') ,StartDateTime = system.today().addDays(4), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit' ));
            insert events;
        
            //Start test from here
            Test.startTest();
        
            //Enabling Triggers
            Util.byPassAllTriggers = false;
        
            try {
                delete events;
            } catch(Exception ex) {
                //System.assert(ex.getMessage().contains(System.Label.ERROR_DO_NOT_HAVE_ACCESS_TO_DELETE_EVENT));
            }
            
            //Stop here
            Test.stopTest();
        }
  }
    
    //Added By - Abhinav Sharma - 03/15/2017 - CR-20170307-10743
    static testMethod void testRestrictProfilesFromDeletingTheEvents_2() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile 
                        WHERE Name='System Administrator']; 
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        
        //Run in this user context
        System.runAs(u) {
            
            //Modified By - Dipesh Gupta - 06/11/2020 - CR-20190607-13171 - Spring Cleaning - Advisory.com Account Reference Update
            //Changed the Name From 'The Advisory Board Company' to EAB
            //Account
            Account account = new Account(Name = 'EAB',Account_Formal_Name__c = 'EAB');
            insert account;

      //Create Contact
            List<Contact> contacts = new List<Contact>();
            Contact contact = new Contact(LastName = 'Test', FirstName = 'Con',Contact_Status__c ='Active', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',
                                          Employee_Id__c = 'Testing 1');
            contacts.add(contact);
            
            insert contacts;
            
            //program
            Program__c prog = TestUtilities.CreateNewProgram(false);
            insert prog;
            
            //Membership
            Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, true);
        
            //Query through Opportunity RecordTypes
            List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                            WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                            AND SObjectType = 'Opportunity'
                                            AND IsActive = true];
            System.assert(oppRecord.size() > 0);

            //Insert Opportunity Records
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                        StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                        CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                        AccountID = account.Id,Sales_Pursuit_Products__c = 'APS'
                                       ));
            insert oppList;    
        
            //Query through Opportunity RecordTypes
            List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                    WHERE (DeveloperName = 'Core_Marketing' OR DeveloperName = 'Core_AM') 
                                                    AND SObjectType = 'Event' AND IsActive = true];
            System.assert(eventRecordType.size() > 0);
            
            //Map to hold record type DeveloperName as key and record type Id as value
            Map<String,Id> mapEventRecordType =  new Map<String,Id>();
    
            //Populate mapEventRecordType
            for(RecordType rt : eventRecordType){
                mapEventRecordType.put(rt.DeveloperName , rt.Id);
            }

          List<RecordType> pSSRequestRecordType = [SELECT Id, Name, SObjectType, DeveloperName FROM RecordType 
                                                      WHERE DeveloperName = 'AM_EAB' 
                                                      AND SObjectType = 'PSS_Request__c' AND IsActive = true];
          System.assert(pSSRequestRecordType.size() > 0);

          //List of PSS Requests
          List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
          
          //PSS Request
          PSS_Request__c pSSRequest = new PSS_Request__c();
          pSSRequest.PSS_Resource__c = contacts[0].Id;
          pSSRequest.Approver__c = contacts[0].Id;
          pSSRequest.Reason_Requested__c ='testing';

          //Adding PSS Request records into the list  
          pSSRequests.add(pSSRequest);

      insert pSSRequests;
        
            //List to hold Events
            List<Event> events = new List<Event>();
            
            //Populate List
            events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_Marketing') ,StartDateTime = system.today().addDays(4), 
                                 EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                                 Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                                 Event_Type__c = 'Web Visit'));
            insert events;
        
            //Start test from here
            Test.startTest();
        
            //Enabling Triggers
            Util.byPassAllTriggers = false;

      events[0].WhatId = pSSRequests[0].Id;
      events[0].whoId = contacts[0].Id ;
      update events;

            //Delete events
           delete events;
            
            //Query and asserting for the results
            events = [SELECT ID FROM Event LIMIT 2];
            System.assertEquals(0, events.size()); 
            
            //Stop here
            Test.stopTest();
        }
  }
    /**
     * 
     *  @description    :   This method used to test updateFieldsOnDevActivity method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/06/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testmethod void testPrimaryProposalRequiredForEvent() {

    //Enable triggers again
    Util.BypassAllTriggers = true;

    //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);

    //Create Contract
    Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
    insert StdContract;

    //List to hold the record's type 
       List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                       AND DeveloperName ='EAB_Initiating'];

    //Opportunity
    List<Opportunity> opportunities = new List<Opportunity>();
    opportunities.add( TestUtilities.CreateNewOpportunity(false));
    opportunities[0].SBQQ__AmendedContract__c = StdContract.Id;
    opportunities[0].recordTypeId =  recordTypes[0].Id;
    insert opportunities;
        
        //proposal
        SBQQ__Quote__c proposal = TestUtilities.createNewSbqqQuote(false);
        proposal.SBQQ__Opportunity2__c = opportunities[0].Id;
        proposal.SBQQ__Primary__c = true;
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        Product2 product = TestUtilities.createNewProduct(program.Id, true);
        
        util.BypassAllTriggers = true;
        insert proposal;
        SBQQ__QuoteLine__c quoteLine = TestUtilities.createNewQuoteLine(proposal.Id, false);
        quoteLine.SBQQ__SegmentIndex__c = 1;
        quoteLine.Product_Category__c = 'Annual Fee';
        quoteLine.SBQQ__Product__c = product.Id;
        quoteLine.Program_Opportunity__c = opportunities[0].Id;
        quoteLine.Program_or_Component__c = 'PT';
        insert quoteLine;
        
        opportunities[0].SBQQ__PrimaryQuote__c = proposal.Id;
        
    System.assert(opportunities != null);

        //Task record
    Event event_1 = new Event(Subject = 'testSubject 1', ActivityDateTime = System.today(),
                                       //Notify_Task_Creator__c = false, 
                                       ActivityDate = System.today().addDays(1),
                                       StartDateTime = System.today(), EndDateTime = System.today(),
                                       WhatId = opportunities[0].Id, Event_Type__c = 'test');

    //Testing start here 
    Test.startTest();

        //Enable triggers again
        Util.BypassAllTriggers = false;

    try {                

      //Insert
      insert event_1;
                
          //Asserting for the results
          System.assert(event_1 != null);

        }
        catch(Exception e) {

      String message = e.getMessage();
      system.assert(message.contains('Activity can\'t be saved on the opportunity, without the opportunity having an active primary proposal'), 'message=' + message);
        }

    //Testing stop here 
    Test.stopTest();
    }
    
    /**
     * 
     *  @description    :   This method used to test SyncWithPSS  method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created
     * 
     **/
    @isTest static void testSyncWithPss() {
        
        //Bypassing Trigger
        Util.ByPassAllTriggers = true;
        
        //Creating a opportunity. 
        Opportunity opp = TestUtilities.CreateNewOpportunity(true);
        
        Contact c = new Contact();
        c.Lastname = 'test Contact';
        c.Employee_User_Record__c = UserInfo.getUserId();
        c.Email = 'Test'+Math.random()+'@eab.com';
        c.Title = 'Test';
        c.Phone = '614-555-8855';

        insert c;    
        
        //Bypass false
        Util.ByPassAllTriggers = false;
        
        //Creating a SME Request. 
        Pss_Request__c smeRequest = new Pss_Request__c();
        smeRequest.Opportunity__c = opp.Id;
        smeRequest.AMA__c = 'Test';
        smeRequest.Dedicated_Advisor__c = 'Test';
        smeRequest.Contacts__c = 'Test';
        smeRequest.Meeting_History__c = 'Test';
        smeRequest.Reason_Requested__c = 'Test';
        smeRequest.PSS_Request_Notes__c = 'test'; 
        smeRequest.Approver__c = c.Id; 
        smeRequest.PSS_Rank__c = 'Primary';
        smeRequest.Reason_Requested__c = 'Testing is going on, Developer is getting fever/cold etc.';
        
        //Inserting sme Request. 
        insert smeRequest;
        
        //Approving SME Request. 
        smeRequest.Approved__c = True;
        smeRequest.PSS_Resource__c = c.Id;
        smeRequest.Approval_Status__c = 'Approved';
        update smeRequest;
        
        Test.starttest();
        
        List<RecordType> rTypes = [Select Id From RecordType Where SObjectType = 'Event' AND DeveloperName = 'Member_Success'];
        
        //Creating an Event. 
        Event ev = new Event();  
        ev.Subject = 'test';
        ev.WhatId = smeRequest.Id;
        ev.RecordTypeId = rTypes[0].Id;
        ev.StartDateTime = System.now();
        ev.EndDateTime = System.now().addMinutes(8);  
        ev.Event_Purpose__c = 'Check In';
        ev.Event_Type__c = 'In person Visit';
        ev.Visit_Location__c = 'Campus';
        
        insert ev;
            
        Test.stopTest();
        
        //Asserts
        List<Event> events = [Select Id, WhatId, SME_Request__c From Event Where Id =: ev.Id];
        
        //System.assertEquals(opp.Id, events[0].WhatId);
        //System.assertEquals(smeRequest.Id, events[0].SME_Request__c);
    }
    
    
    //Added for CR-20200102-13583 Start
    /**
     * 
     *  @description    :   This method used to test populateProjectFields method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created
     * 
     **/
    @isTest static void testPopulateProjectFields() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        //Modified By - Dipesh Gupta - 01/30/2020 - CR-20200102-13583 start
        //Contact
        contact con = new Contact (LastName = 'testName',Contact_Status__c ='Active',Email = 'testtdd@gmail.com', Title = 'testtingTitle', Phone = '23456787');
        insert con;
        
        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
        
        
        //Member Success Record Type Id 
        Id memberSuccessRTId = Util.RecordTypeId('Event', 'Member Success');
        
        //Member Success Record Type Id 
        Id techRTId = Util.RecordTypeId('Project__c', 'Tech');
        
        //Create a Project record
        Project__c project1 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id,RecordTypeId = techRTId,
                                             Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        insert project1;
        
        //Create a Project record
        Project__c project2 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id, CreatedDate = date.newinstance(2019, 09, 01),
                                             RecordTypeId = techRTId, Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        insert project2;
        System.assert(project2!= null);
        
        //Create a Project record
        Project__c project3 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id,
                                             RecordTypeId = techRTId, Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);
        
        insert project3;
        List<Event> evntList = new List<Event>();
        
        
        for(integer i=1; i<=5; i++)
        {
            DateTime DTStart1 = System.Now().addDays(-i);
            Date DStart1 = Date.newInstance(DTStart1.year(), DTStart1.month(), DTStart1.day());
            
            Event tsk1 = new Event(
                whatId = project1.Id,
                WhoId = con.Id,
                Subject = 'Executive Update',
                RecordTypeId = memberSuccessRTId,
                StartDateTime = DTStart1,
                ActivityDateTime = DTStart1,
                ActivityDate = DStart1,
                EndDateTime = DTStart1.addDays(1),
                Event_Type__c = 'Internal Event',
                Event_Purpose__c = 'Internal Discussion');
            
            evntList.add(tsk1);
        }
       
        for(integer i=1; i<=5; i++)
        {
            DateTime DTStart3 = System.Now().addDays(-i);
            Date DStart3 = Date.newInstance(DTStart3.year(), DTStart3.month(), DTStart3.day());
            
            Event tsk2 = new Event(
                Subject = 'Executive Update',
                whatId = project3.Id,
                WhoId = con.Id,
                RecordTypeId = memberSuccessRTId,
                StartDateTime = DTStart3,
                ActivityDateTime = DTStart3,
                ActivityDate = DStart3,
                EndDateTime = DTStart3.addDays(1),
                Event_Type__c = 'In Person Visit',
                Event_Purpose__c = 'Check In',
                Visit_Location__c = 'Campus' );
            
            evntList.add(tsk2);
        }
       //Modified By - Dipesh Gupta - 01/30/2020 - CR-20200102-13583 end
        //Start testing here
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        insert evntList;
        
        
        //Stop test here
        Test.stopTest();
        
        DateTime DTStart2 = System.Now().addDays(-1);
        Date DStart2 = Date.newInstance(DTStart2.year(), DTStart2.month(), DTStart2.day());
        
        Project__c pro1 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project1.Id LIMIT 1];
        System.assertEquals(DStart2, pro1.Last_Internal_Check_In__c);
        
       
        Project__c pro3 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project3.Id LIMIT 1];
        System.assertEquals(DStart2, pro3.Last_Executive_Update__c);
        
        evntList[0].whatId = project2.Id;
        
        update evntList;
        
        Project__c pro2 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project2.Id LIMIT 1];
        System.assertEquals(DStart2, pro2.Last_Internal_Check_In__c);
        
        DateTime DTStart3 = System.Now().addDays(-2);
        Date DStart3 = Date.newInstance(DTStart3.year(), DTStart3.month(), DTStart3.day());
        
        Project__c pro4 = [Select Id,Last_Executive_Update__c,Last_Internal_Check_In__c from Project__c WHERE Id =: project1.Id LIMIT 1];
        System.assertEquals(DStart3, pro4.Last_Internal_Check_In__c);
        
    }
    //Added for CR-20200102-13583 End
    
    //Added By - Dipesh Gupta - 01/24/2020 - CR-20200110-13610 Start
    static testMethod void testvalidateContactStatus() 
    {
        //Bypassing Trigger
        Util.BypassAllTriggers = true;
        
        //Find user with Profile = System Administrator
        Profile sysAdminProfile = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Create user
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
                            TimeZoneSidKey='America/Los_Angeles',UserName=Math.random()+'@testorg.com');
        
        //insert user
        insert usr;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating Contact records
        List<Contact> con = new List<Contact>();
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData1',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test1',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Active',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData2',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test2',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Inactive - Moved Institutions',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData3',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test3',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Inactive - No Activity',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData4',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test4',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Inactive – Contact Not At Institution',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData5',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test5',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Inactive – Other',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        con.add(new Contact(AccountId = account.Id,
                            LastName = 'testingData6',
                            Email = 'Test'+Math.random()+'@eab.com',
                            Title = 'Test6',
                            Phone = '614-555-8855',
                            Contact_Status__c = 'Inactive - No Contact',
                            CurrencyIsoCode = 'USD',
                            Primary_Address_Line_1__c = '2445 M Street NW',
                            Primary_City__c = 'Washington',
                            Primary_Country__c = 'United States',
                            Primary_Postal_Code__c = '20037',
                            Primary_State_Province__c = 'DC'
                           )
               );
        insert con;
        //Assert for the results
        System.assert(con != null);
        System.assertEquals(6, con.size());
        
        //Insert Opportunity Records
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name = 'Test Opportunity0' ,Main_Contact__c = con[0].Id, Sales_Pursuit_Products__c = 'APS',
                                    StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(32)));
        Insert oppList;
        //Assert for the results
        System.assert(oppList != null);
        System.assertEquals(1, oppList.size());
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',
                             Event_Type__c = 'Web Visit',
                             Event_Purpose__c = 'Check In',
                             Status__c = 'Requested',
                             StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7), 
                             WhatId = oppList[0].Id,
                             Type = 'Phone Appointment',
                             WhoId = con[0].Id
                            )
                  );
        
        //Test Start from here
        Test.startTest();
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        try 
        {
            insert events;
            //Assert for the results
            System.assert(events != null);
            System.assertEquals(1, events.size());
         } 
        catch(Exception ex)
        {
        }
        
        //Populate List
        events.add(new Event(OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',
                             Event_Type__c = 'Web Visit',
                             Event_Purpose__c = 'Check In',
                             Status__c = 'Requested',
                             StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7), 
                             WhatId = oppList[0].Id,
                             Type = 'Phone Appointment',
                             WhoId = con[1].Id
                            )
                  );
        
        try
        {
            //Insert Events
            insert events[1];
        }
        Catch(Exception e)
        {
            String message = e.getMessage();
            system.assert(message.contains('You can not create or update event for inactive contacts.'));
        }
        
        //Stop test here
        Test.stopTest();
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        // Query on Contact
        List<Contact> conActiveData = [Select Id, Contact_Status__c FROM Contact WHERE Contact_Status__c = 'Active' Limit 1];
        conActiveData[0].Contact_Status__c = 'Inactive - No Contact';
        update conActiveData;
        //Assert for the results
        System.assertEquals('Inactive - No Contact', conActiveData[0].Contact_Status__c);
        
        // Query on Event
        List<Event> evnActiveConData = [Select Id, OwnerId, Subject, Event_Type__c , Event_Purpose__c, Status__c, StartDateTime, EndDateTime, WhatId, Type, WhoId
                                        FROM Event
                                        WHERE WhoId =: conActiveData[0].Id Limit 1];
        
        // Bypass false
        Util.BypassAllTriggers = false;
        try
        {
            evnActiveConData[0].Type = 'In Person Visit';
            update evnActiveConData;
        }
        Catch(Exception e)
        {
            String message = e.getMessage();
            system.assert(message.contains('You can not create or update event for inactive contacts.'));  
        }
    }
    //Added By - Dipesh Gupta - 01/24/2020 - CR-20200110-13610 END
    
    //Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
    @isTest static void test_PopulateCTFieldsOnSubsciptionPeriod() 
    {
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        Id accountManagementRTId = Util.RecordTypeId('Event', 'Account Management');
        
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        contact con = new Contact (LastName = 'testName',Contact_Status__c ='Active',Email = 'testtdd@gmail.com', Title = 'testtingTitle', Phone = '23456787');
        insert con;
        
        Contract StdContract = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, program.Id, true);
        
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>(); 
        subscriptions.add(TestUtilities.createNewSubscription(membership.Id, false));
        subscriptions[0].recordTypeId = recordTypes[0].Id;
        insert subscriptions;
        
        List<RecordType> recordTypeSP = [Select Id, Name from RecordType Where SobjectType = 'Subscription_Period__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB];
        
        List<Subscription_Period__c> speriods = new List<Subscription_Period__c>();
        
        speriods.add(new Subscription_Period__c(Name = 'Test SPeriod', Program_Subscription__c = subscriptions[0].Id, recordTypeId = recordTypeSP[0].Id));
        insert speriods;
        
        List<Event> evntList = new List<Event>();
        DateTime DTStart1 = System.Now().addDays(-1);
        DateTime DTStart2 = System.Now().addDays(-1);
        DateTime DTStart3 = System.Now().addDays(-1);
        Date DStart1 = Date.newInstance(DTStart1.year(), DTStart1.month(), DTStart1.day());
        
        evntList.add(new Event(whatId = speriods[0].Id, Subject = 'Call', RecordTypeId = accountManagementRTId, StartDateTime = DTStart1,
                                             EndDateTime = DTStart1, Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairman\''+'s Team'));
        
        evntList.add(new Event(whatId = speriods[0].Id, Subject = 'Call', RecordTypeId = accountManagementRTId, StartDateTime = DTStart2,
                                             EndDateTime = DTStart2, Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Chairman\''+'s Team'));
        Util.BypassAllTriggers = false;
        insert evntList;

	Test.startTest(); 
        
        evntList[0].Event_Type__c = 'In Person Visit';
        evntList[0].Visit_Location__c = 'Campus';
        update evntList;
        
        Test.stopTest(); 
        
        List<Subscription_Period__c> listOfSP = [SELECT Id, CT_Date_PA_Happens__c, CT_Date_Visit_Happens__c FROM
                                                 Subscription_Period__c];
    }
    
     //Added By - Mahendra Swarnakar - 07/13/2020 - CR-20200420-13963
    static testMethod void testhandleGoogleEvent() 
    {
         Test.startTest();
        //Bypassing Trigger
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = new List<Account>();
    
        //Add to list
        accounts.add(new Account(Name = 'Child Account1'));
        accounts.add(new Account(Name = 'Child Account2'));
      
      //Insert child Account
      insert accounts;

      //Creating Contact record 
      Contact con = TestUtilities.CreateNewContact(false);
      con.AccountId = accounts[0].Id;
      insert con;
      
      Contact cont = TestUtilities.CreateNewContact(true);
   
        //PSS Request
        PSS_Request__c pSSRequest1 = new PSS_Request__c();
        pSSRequest1.Approver__c = con.Id;
        pSSRequest1.Reason_Requested__c = 'Test';
        pSSRequest1.Resource_Requested__c = true;
        pSSRequest1.PSS_Resource__c = con.Id;
        pSSRequest1.By_Pass_Process_Builder__c = true;
        insert pSSRequest1;
        
        List<Opportunity> opportunities = new List<Opportunity>();

            //Add record to list
            Opportunities.add(new Opportunity(StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED, Name = 'Test 1', Main_Contact__c = con.Id,
                                                Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                                 Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', Sales_Pursuit_Products__c = 'APS',
                                                CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id, SBQQ__Renewal__c = true));
                                                
             insert opportunities ;
 
        
        List<Event> events = new List<Event>();
         events.add(new Event(
                             Subject = 'Will Auto-Populate',
                             Event_Type__c = 'Web Visit',
                             Event_Purpose__c = 'Check In',
                             Status__c = 'Requested',
                             StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7), 
                             WhatId = opportunities[0].Id,
                             Type = 'Phone Appointment',
                             WhoId = con.Id,
                             SME_Request__c  = pSSRequest1.Id
                            )
                  );
        
        //Bypassing Trigger
        Util.BypassAllTriggers = false;
        
        insert events;
        
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        system.assertEquals(1, invocations);
        
        }
    
    //Added By - Neha Sharma - 14/04/2021 - CR-20210202-14862 - check the event count on opportunity
    static testMethod void testpopulateCountOnOpportunityFields() 
    {
        
        //Bypassing Trigger
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = new List<Account>();
    
        //Add to list
        accounts.add(new Account(Name = 'Child Account1'));
    	accounts.add(new Account(Name = 'Child Account2'));
      
      	//Insert child Account
      	insert accounts;

      	//Creating Contact record 
      	Contact con = TestUtilities.CreateNewContact(false);
      	con.AccountId = accounts[0].Id;
      	insert con;
      
      	Contact cont = TestUtilities.CreateNewContact(true);
   
        //PSS Request
        PSS_Request__c pSSRequest1 = new PSS_Request__c();
        pSSRequest1.Approver__c = con.Id;
        pSSRequest1.Reason_Requested__c = 'Test';
        pSSRequest1.Resource_Requested__c = true;
        pSSRequest1.PSS_Resource__c = con.Id;
        pSSRequest1.By_Pass_Process_Builder__c = true;
        insert pSSRequest1;
        
        List<Opportunity> opportunities = new List<Opportunity>();

        //Add record to list
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED, Name = 'Test 1', Main_Contact__c = con.Id,
        				  Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                          Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                          CT_Reneg_Attempt__c = 'No', AccountId = accounts[0].Id, SBQQ__Renewal__c = true,
                                          Sales_Pursuit_Products__c = 'ALR'));
        
        Opportunities.add(new Opportunity(StageName = CPQConstants.OPP_STAGE_SENT_TO_CREDITED, Name = 'Test 2', Main_Contact__c = con.Id,
                                                Opportunity_Nickname__c = 'Renewal Opp 1', Amount = 0, CloseDate = Date.today(),
                                                 Competitor_Notes__c = 'ABC 1', CT_Pass_Status__c = 'Assigned', 
                                                CT_Reneg_Attempt__c = 'No', AccountId = accounts[1].Id, SBQQ__Renewal__c = true,
                                             	Sales_Pursuit_Products__c = 'ALR'));
                                                
        insert opportunities;
 
        List<Event> events = new List<Event>();
        events.add(new Event(Subject = 'Will Auto-Populate', Event_Type__c = 'Web Visit',Event_Purpose__c = 'Check In',
                             Status__c = 'Requested', StartDateTime = system.today().addDays(4), EndDateTime = system.today().addDays(7), 
                             WhatId = opportunities[0].Id,Type = 'Phone Appointment', WhoId = con.Id, SME_Request__c  = pSSRequest1.Id ));
        events.add(new Event(Subject = 'Will Auto-Populate', Event_Type__c = 'Phone Appointment',Event_Purpose__c = 'Check In',
                             Status__c = 'Requested', StartDateTime = system.today().addDays(-4), EndDateTime = system.today().addDays(-4), 
                             WhatId = opportunities[0].Id,Type = 'Phone Appointment', WhoId = con.Id, SME_Request__c  = pSSRequest1.Id ));
        events.add(new Event(Subject = 'Will Auto-Populate', Event_Type__c = 'In Person Visit',Event_Purpose__c = 'Follow up',
                             Status__c = 'Requested', StartDateTime = system.today().addDays(4), Visit_Location__c = 'Campus', EndDateTime = system.today().addDays(7), 
                             WhatId = opportunities[0].Id,Type = 'Phone Appointment', WhoId = con.Id, SME_Request__c  = pSSRequest1.Id ));
        events.add(new Event(Subject = 'Will Auto-Populate', Event_Type__c = 'Web Visit',Event_Purpose__c = 'Check In',
                             Status__c = 'Requested', StartDateTime = system.today().addDays(4), EndDateTime = system.today().addDays(7), 
                             WhatId = opportunities[0].Id,Type = 'Phone Appointment', Cancelled_Did_Not_Occur__c = true,WhoId = con.Id, SME_Request__c  = pSSRequest1.Id ));
        
        
        
        Test.startTest();
        //Bypassing Trigger
        Util.BypassAllTriggers = false;
        
        insert events;
        
        List<opportunity> oppList = [Select Id,Total_Completed_Activities__c, Total_Upcoming_Activities__c,Total_In_Person_Activities__c,
                                     Total_Web_Activities__c,Total_Phone_Activities__c, Total_Activities__c from Opportunity];
        
        system.assertEquals(1, oppList[0].Total_Completed_Activities__c);
        system.assertEquals(2, oppList[0].Total_Upcoming_Activities__c);
        system.assertEquals(1, oppList[0].Total_In_Person_Activities__c);
        system.assertEquals(1, oppList[0].Total_Web_Activities__c);
        system.assertEquals(1, oppList[0].Total_Phone_Activities__c);
        system.assertEquals(3, oppList[0].Total_Activities__c);
        
        events[0].WhatId = oppList[1].Id;
        Update events;
        
        system.assertEquals(2, oppList[0].Total_Upcoming_Activities__c);
        system.assertEquals(1, oppList[0].Total_In_Person_Activities__c);
        
        Delete events [0];
        
        test.stopTest();
        }
	
	
    //Added By - Shalu - 04/20/2021 - CR-20210407-15063
    static testMethod void testSendEmailNotification(){
        
	//Bypassing Trigger
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = new List<Account>();
        
        //Add to list
        accounts.add(new Account(Name = 'Child Account1'));
        accounts.add(new Account(Name = 'Child Account2'));
        
        //Insert child Account
        insert accounts;
        
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(false);
        con.AccountId = accounts[0].Id;
        insert con;
        
        Review_Call__c rc = new Review_Call__c(Name = 'TestRC');
        insert rc;
        
        List<RecordType> eventRecordType = [SELECT Id,DeveloperName FROM RecordType 
        				    WHERE (DeveloperName ='CX_QA_Survey' /*'Syndicated_Research'*/) 
                                            AND SObjectType = 'Event' AND IsActive = true];
        
        List<Event> events = new List<Event>();
         events.add(new Event(
         		     RecordTypeId = eventRecordType[0].Id,
                             Subject = 'Will Auto-Populate',
                             Event_Type__c = 'Web Visit',
                             Event_Purpose__c = 'Check In',
                             Status__c = 'Requested',
                             StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7), 
                             Type = 'Phone Appointment',
                             WhoId = con.Id,
             		     WhatId = rc.Id
                            )
                  );
        
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        insert events;
        
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        system.assertEquals(1, invocations);
    }
    
}