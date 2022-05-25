@isTest(seeAllData=false)
private class Test_Batch_UpdateCountOnOpportunity {
  
    
    // test the next decision date on a membership based on the next renewal opp
    static testmethod void testupdateOpportunities() {
    
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
        opp.Start__c = system.today();
        opp.RecordTypeId = constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL;
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.StageName = 'Pending- Renewal Call Comp & Evaluating';
        oppList.add(opp);
        
        insert oppList;
        
        list<Event> eveList = new List<event>();
        Event event = new Event();
        event.Subject = 'Test';
        event.whatId = oppList[0].id;
        event.StartDateTime = datetime.now();
        event.EndDateTime = datetime.now();
        event.Event_Type__c = 'In Person Visit';
        event.Cancelled_Did_Not_Occur__c = false;
        event.Visit_Location__c = 'Campus';
        eveList.add(event);
        
        Event event1 = new Event();
        event1.Subject = 'Test';
        event1.whatId = oppList[0].id;
        event1.StartDateTime = datetime.now().addDays(7);
        event1.EndDateTime = System.now().addDays(7);
        event1.Event_Type__c = 'Phone Appointment';
        event1.Cancelled_Did_Not_Occur__c = false;
        eveList.add(event1);
        
        Event event2 = new Event();
        event2.Subject = 'Test';
        event2.whatId = oppList[0].id;
        event2.StartDateTime = datetime.now().addDays(7);
        event2.EndDateTime = System.now().addDays(7);
        event2.Event_Type__c = 'Web Visit';
        event2.Cancelled_Did_Not_Occur__c = false;
        event2.Event_Purpose__c = 'Follow Up';
        eveList.add(event2);
        
        Event event3 = new Event();
        event3.Subject = 'Test';
        event3.whatId = oppList[0].id;
        event3.StartDateTime = datetime.now().addDays(7);
        event3.EndDateTime = System.now().addDays(7);
        event3.Event_Type__c = 'Web Visit';
        event3.Cancelled_Did_Not_Occur__c = false;
        event3.Event_Purpose__c = 'Initial';
        eveList.add(event3);
        
        insert eveList;
        
        Batch_UpdateCountOnOpportunity batch = new Batch_UpdateCountOnOpportunity();
        database.executeBatch(batch,200);
    }
}