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
@isTest (seeAllData = false)
private class Test_CPQUseCases {

/**
 *   Purpose         :   Test class to cover all the use cases for UC - Use Cases - CPQ Wave 1 v0.3 sheet
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   06/14/2016
 *
 *   Revision Log    :   V_1.0 - Created - CR-20160414-9762
 *                   :  //Modified By  Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment   
 *
 **/
    
    //Setup Test Data to test use cases
    @testSetup
    static void setupTestData() {
        
        //Query through Opportunity Record Type
        List<RecordType> oppRType = [Select Id, DeveloperName From RecordType Where SobjectType = 'Opportunity' AND DeveloperName IN ('BI_Marketing') ORDER BY DeveloperName ASC];
        
        //Create new account
        Account acc = TestUtilities.CreateNewAccount(true);
        
        //List of Opportunity to insert
        List<Opportunity> opportunties = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Add new Opportunity Record in list to insert
        opportunties.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will auto-populate', RecordTypeId = oppRType[0].Id, AccountId = acc.Id,
                                         StageName = 'on Desk', Amount = 100, CloseDate = system.today().addDays(4), Competitor_Notes__c = 'Test 1', Next_PA_Date__c = system.today() + 1));
        
        opportunties.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will auto-populate', RecordTypeId = oppRType[0].Id, AccountId = acc.Id,
                                         StageName = 'on Desk', Amount = 100, CloseDate = system.today().addDays(5), Competitor_Notes__c = 'Test 2'));
        
        opportunties.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Will auto-populate', RecordTypeId = oppRType[0].Id, AccountId = acc.Id,
                                         StageName = 'on Desk', Amount = 100, CloseDate = system.today().addDays(6), Competitor_Notes__c = 'Test 3'));
        
        //Insert
        insert opportunties; 
        
    }
    //Test method to test use cases for CPQ project (UC - Use Cases - CPQ Wave 1 v0.3 sheet)
    static testMethod void myUnitTest() {
        
        //Query on opportunity
        List<Opportunity> opportunities = [Select Id From Opportunity ORDER BY CloseDate ASC];
        
        //Query through Event record types
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where SobjectType = 'Event' AND DeveloperName IN ('BI_QA_Call') ORDER BY DeveloperName ASC];
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(RecordTypeId = recordTypes[0].Id ,StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = opportunities[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = recordTypes[0].Id ,StartDateTime = system.today().addDays(3), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = opportunities[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = recordTypes[0].Id ,StartDateTime = system.today().addDays(5), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = opportunities[1].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
        events.add(new Event(RecordTypeId = recordTypes[0].Id ,StartDateTime = system.today().addDays(2), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = opportunities[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
                             
        //Start testing from here
        Test.startTest();
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
            
        //Insert Events
        insert events;
            
        //Query through Opportunity for validate Next_Activity_Date field value
        List<Opportunity> oppResultList = [SELECT Id ,Next_Activity_Date__c FROM Opportunity ORDER BY CloseDate ASC];
            
        //Assert for result
       // system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c );
        //system.assertEquals(system.today().addDays(5) , oppResultList[1].Next_Activity_Date__c );
            
        //Update Event records
        events[0].StartDateTime = system.today().addDays(2);
        
        //Update Events
        update events[0];
        
        //Query through Opportunity for validate Next_Activity_Date field value
        oppResultList = [SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: opportunities[0].Id];

        //Assert for result
       // system.assertEquals(system.today().addDays(2) , oppResultList[0].Next_Activity_Date__c );

        //Update Event records
        events[1].WhatId = opportunities[1].Id ;
        
        //Update events
        update events[1];
        
        //Query through Opportunity for validate Next_Activity_Date field value
        oppResultList = [ SELECT Id ,Next_Activity_Date__c FROM Opportunity WHERE Id =: opportunities[1].Id ];

        //Assert for result
        //system.assertEquals(system.today().addDays(3) , oppResultList[0].Next_Activity_Date__c ); 
        
        //Stop test here
        Test.stopTest();
    }
    
    static testMethod void myUnitTest1() {
        
        //Query on opportunity
        List<Opportunity> opportunities = [Select Id From Opportunity ORDER BY Competitor_Notes__c ASC];
        
        Date todayDate = Date.newInstance(2015, 9, 4);
        DateTime todayDateTime = DateTime.newInstance(2015, 9, 4, 8, 6, 16);
            
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
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
                                Cancelled_Did_Not_Occur__c = false,  Visit_Location__c = 'Campus',
                                EndDateTime = todayDateTime.addHours(1).addDays(-2), 
                                Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial');
        Event evt_4 = new Event(WhatId = opportunities[0].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Follow Up');
        Event evt_5 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Follow Up');
        Event evt_6 = new Event(WhatId = opportunities[2].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial' , Visit_Location__c = 'Campus');
        
        //Adding records into the list
        events.add(evt_1);
        events.add(evt_2);
        events.add(evt_3);
        events.add(evt_4);
        events.add(evt_5);
        events.add(evt_6);
        
        //Test will start from here
        Test.startTest();
        
        //Disabling triggers and setting flag value
        Util.byPassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Insert events
        insert events;
        
        //Querying for opportunity records
        opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c FROM Opportunity ORDER BY Competitor_Notes__c ASC];
        
        //Asserts for the results
        System.assertEquals(3, opportunities.size());
        
        System.assertEquals(todayDate, opportunities[0].Initial_PA_Date__c);
        System.assertEquals(todayDate, opportunities[0].Initial_Activity_Date__c);
        
        System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
        System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
        
        System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
        System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c);
        
        //Stop Test here
        Test.stopTest();
        
        //Disabling triggers and setting flag value
        Util.byPassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //delete events
        List<Event> eventsToDeleteOrUpdate = new List<Event>();
        eventsToDeleteOrUpdate.add(events[0]);
        eventsToDeleteOrUpdate.add(events[5]);
        
        delete eventsToDeleteOrUpdate;
        
        
        //Querying for opportunity records
        opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c
                         FROM Opportunity
                         ORDER BY Competitor_Notes__c ASC];
        
        //Asserts for the results
        System.assertEquals(3, opportunities.size());
        
        System.assertEquals(null, opportunities[0].Initial_PA_Date__c);
        System.assertEquals(null, opportunities[0].Initial_Activity_Date__c);
        
        System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_PA_Date__c);
        System.assertEquals(todayDate.addDays(2), opportunities[1].Initial_Activity_Date__c);
        
        System.assertEquals(null, opportunities[2].Initial_PA_Date__c);
        System.assertEquals(todayDate.addDays(-2), opportunities[2].Initial_Activity_Date__c); 
    }
    
    //Test method to cover test use cases for CPQ project (UC - Use Cases - CPQ Wave 1 v0.3 sheet 7-10)
    static testMethod void myUnitTest2() {
        
        //Query on opportunity
        List<Opportunity> opportunities = [Select Id From Opportunity ORDER BY Competitor_Notes__c ASC];
        
        // Id of Opportunity1
        Id oppId = opportunities[1].Id;
    
        //Date variables
        Date todayDate = Date.newInstance(2015, 9, 4);
        DateTime todayDateTime = DateTime.newInstance(2015, 9, 4, 8, 6, 16);
            
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //List of event records
        List<Event> events = new List<Event>();
        
        //Event 1
        Event evt_1 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Initial');
        Event evt_2 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime.addDays(2), 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1).addDays(2), 
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Intro PA');
        Event evt_3 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime.addDays(-2), 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1).addDays(-2), 
                                Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial' , Visit_Location__c = 'Campus');
        Event evt_4 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'Phone Appointment', Event_Purpose__c = 'Follow Up');
        Event evt_5 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'Additional Contact Meeting', Event_Purpose__c = 'Follow Up' );
        Event evt_6 = new Event(WhatId = opportunities[1].Id, StartDateTime = todayDateTime, 
                                Cancelled_Did_Not_Occur__c = false,
                                EndDateTime = todayDateTime.addHours(1), 
                                Event_Type__c = 'In Person Visit', Event_Purpose__c = 'Initial' , Visit_Location__c = 'Campus');
        
        //Adding records into the list
        events.add(evt_1);
        events.add(evt_2);
        events.add(evt_3);
        events.add(evt_4);
        events.add(evt_5);
        events.add(evt_6);
        
        //Test will start from here
        Test.startTest();
        
        //Disabling triggers and setting flag value
        Util.byPassAllTriggers = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
        OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;
        
        //Insert events
        insert events;
        
        //Querying for opportunity records
        opportunities = [SELECT ID, Name, Initial_PA_Date__c, Initial_Activity_Date__c FROM Opportunity ORDER BY Competitor_Notes__c ASC];
        
        //Asserts for the results
        System.assertEquals(3, opportunities.size());
        
        //Assign Next PA Date
        opportunities[0].Next_PA_Date__c = null;
        opportunities[1].Next_PA_Date__c = system.today().addDays(100);
        opportunities[2].Next_PA_Date__c = system.today().addDays(-100);
    
        //Update Opportunity
        update opportunities;
        
        // Querying Opportunity as dynamic String
        String qry = 'select id, Event_Type__c, Event_Purpose__c, ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId, What.Type from Event where (Event_Type__c = \'Phone Appointment\') and WhatId=\'' + oppId + '\' order by WhatId';

        // Calling Batch
        Batch_ActivityCount batch = new Batch_ActivityCount();
        batch.queryStr = qry;

        // Executing Batch
        Id batchId = Database.executeBatch(batch); 
     
        //Querying opportunity
        Opportunity opp = [select Id, Name, Next_PA_Date__c, Initial_Visit_Date__c, How_many_prewires_were_completed__c from Opportunity where Id =: oppId];
    
        //Assert for results
        System.assertEquals(System.today().addDays(100), opp.Next_PA_Date__c);
        System.assertNotEquals(null, opp.Initial_Visit_Date__c);
    
        //Stop Test here
        Test.stopTest();
    }
}