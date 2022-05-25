//Modified By  Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment 
//Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field

@istest
public class SFEventQueueProcessor_Test {
    public static testmethod void TestCreateGotomeetings() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Create';
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    public static testmethod void TestCreateGotomeetings2() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateFaultG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Create';
        q.Exchange_Action__c = null;
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
        
    static testmethod void TestUpdateGotomeetings() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Update';
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    static testmethod void TestUpdateGotomeetings2() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateFaultG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Update';
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    
    static testmethod void TestClearGotomeetings() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Clear';
        //q.Gotomeeting_Organizer__c =  ;
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    static testmethod void TestClearGotomeetings2() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateFaultG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Clear';
        //q.Gotomeeting_Organizer__c = 'bajsbbadb';
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    
    static testmethod void TestDeleteGotomeetings() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Delete';
        //q.Gotomeeting_Organizer__c = evnt.Gotomeeting_Organizer_Saved_Id__c + '';
        q.Gotomeeting_Id__c = 'G2MId';
        q.Gotomeeting_Hash__c = 'G2MId';
        q.Gotomeeting_Url__c = 'G2MId';
        q.Exchange_Action__c = 'Delete';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    static testmethod void TestDeleteGotomeetings2() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateFaultG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Delete';
        //q.Gotomeeting_Organizer__c = evnt.Gotomeeting_Organizer_Saved_Id__c + '';
        q.Gotomeeting_Id__c = 'G2MId';
        q.Gotomeeting_Hash__c = 'G2MId';
        q.Gotomeeting_Url__c = 'G2MId';
        q.Exchange_Action__c = 'Delete';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    
    static testmethod void TestRecreateGotomeetings() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Recreate';
        //q.Gotomeeting_Organizer__c =  'ccnsjdnajl';
        q.Gotomeeting_Id__c = 'G2MId';
        q.Gotomeeting_Hash__c = 'G2MId';
        q.Gotomeeting_Url__c = 'G2MId';
        q.Exchange_Action__c = 'Delete';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
    static testmethod void TestRecreateGotomeetings2() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateFaultG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Gotomeeting_Action__c = 'Recreate';
        //q.Gotomeeting_Organizer__c =  'trtrtrtrtr';
        q.Gotomeeting_Id__c = 'G2MId';
        q.Gotomeeting_Hash__c = 'G2MId';
        q.Gotomeeting_Url__c = 'G2MId';
        q.Exchange_Action__c = 'Delete';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessGTMQueue(qs);
    }
        
    public static testmethod void TestUpsertAppointments() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Exchange_Action__c = 'Upsert';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessSyncQueue(qs);
    }

    public static testmethod void TestDeleteAppointments() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = CreateG2MEvent();
        
        Event_Queue__c q = new Event_Queue__c();
        q.Event_Id__c = evnt.Id;
        q.Last_Action_Count__c = 10;
        q.Processed__c = false;
        q.Exchange_Action__c = 'Delete';
        insert q;
        System.assertNotEquals(q.Id, null);
        
        List<Event_Queue__c> qs = new List<Event_Queue__c>();
        qs.add(q);
        
        SFEventQueueProcessor.ProcessSyncQueue(qs);
    }
                
    static Event CreateG2MEvent() {
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.Subject = 'Test';
        event.StartDateTime = datetime.now().addDays(7);
        event.ActivityDateTime = event.StartDateTime;
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.IsAllDayEvent = false;
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        //event.Gotomeeting_Organizer_Saved_Id__c = u2.Id;
        //event.RecordTypeId = '012C0000000BkFE'; //Util.recordtypemap('Event').get('BI AM');
        insert event;
        System.assertNotEquals(event.Id, null);      
        return event;
    }
    
    static Event CreateFaultG2MEvent() {
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InFaultModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.Subject = 'Test';
        event.StartDateTime = datetime.now().addDays(7);
        event.ActivityDateTime = event.StartDateTime;
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.IsAllDayEvent = false;
        event.Event_Type__c = 'Internal Meeting';
        // event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        //event.Gotomeeting_Organizer_Saved_Id__c = u2.Id;
        //event.RecordTypeId = '012C0000000BkFE'; //Util.recordtypemap('Event').get('BI AM');
        insert event;
        System.assertNotEquals(event.Id, null);      
        return event;
    }
}