@isTest(seeAllData=false)
private class Test_Batch_InitialVisitDateUpdate {
    
    
   /** Description : Method to test out the logic which is responsible to populate "Initial_Visit_Date__c" field.
    * Revision logs: Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    **/
    static testmethod void myUnitTest() { 

        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact con = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Create test data
        List<Opportunity> oppList = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Populating list with opportunity records instances
        for(integer i=1; i< 4; i++) {
            oppList.add(new Opportunity(Name='Test Opp' + i,Main_Contact__c = con.Id,Sales_Pursuit_Products__c = 'APS', CloseDate = system.today()+7, How_many_prewires_were_completed__c = 0, StageName = 'Pending'));
        }
        insert oppList;
        
        //Asserting for the results
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        
        List<Event> evntList = new List<Event>();
        Id oppId = oppList[1].Id;
        DateTime DTStart = System.Now();
        Date DStart = Date.newInstance(DTStart.year(), DTStart.month(), DTStart.day());

        for(integer i=1; i<=5; i++) {
            Event evnt  = new Event( WhatId = oppId, StartDateTime = DTStart, ActivityDateTime = DTStart,Cancelled_Did_Not_Occur__c = false,
            ActivityDate = DStart, EndDateTime = DTStart, Event_Type__c = Constants.EVENT_TYPE_IN_PERSON_VISIT,
            Event_Purpose__c = Constants.EVENT_PURPOSE_INITIAL, Executive_Type__c = 'CXO', Visit_Location__c = 'Campus');
            evntList.add(evnt);
        }
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
       
        //Insert data in bulk
        insert evntList;
        
        //Asserting for the results
        System.assert(evntList != null);
        System.assert(evntList.size() > 0);

        //Start testing from here
        Test.startTest();
        //loop through the events and update the cancelled flag as true and assert the results
        for(Event evnt : evntList) {
            evnt.Event_Purpose__c = Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT;
        }
        //Disabling triggers
        Util.byPassAllTriggers = True;
        //Update the events
        update evntList;
        
        //Test bacth service
        Batch_InitialVisitDateUpdate batchJob = new Batch_InitialVisitDateUpdate();
        database.executeBatch(batchJob, 100);


        ///Assert for the result if opportunity Initial Visit date is latest one
        oppList = [SELECT Initial_Visit_Date__c FROM Opportunity WHERE Id =: oppId];
                            
        //Asserting for the results
        //System.assertEquals(null, oppList[0].Initial_Visit_Date__c);
        //stop test here
        Test.stopTest();
    }
}