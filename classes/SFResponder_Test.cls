//Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
@istest
private class SFResponder_Test {
    static testMethod void testUpdateEvent() {
        Event event = CreateFaksEvent();
            
        SFResponder.EventUpdate ewsAppointment = new SFResponder.EventUpdate();
        ewsAppointment.SFEventId = event.Id;
        ewsAppointment.IsAllDayEvent = false;
        ewsAppointment.StartDateTime = event.StartDateTime.addDays(1);
        ewsAppointment.StartDateTime = event.EndDateTime.addDays(1);
        
        String result = SFResponder.UpdateEvent(ewsAppointment);
        
        System.assertEquals('', result);
    }
    
    static testMethod void testGetEventDetail() {
        Event event = CreateFaksEvent();
        
        SFResponder.EventDetail result = SFResponder.GetEventDetail(event.Id);
        
        System.assertNotEquals('', result.Body);
        System.assertEquals(event.StartDateTime, result.StartDateTime);
        System.assertEquals(event.EndDateTime, result.EndDateTime);
        System.assertEquals(event.IsAllDayEvent, result.IsAllDayEvent);
        System.assertEquals(event.Subject, result.Subject);
        System.assertEquals(event.Location, result.Location);               
    }
    static testMethod void testGetEventDetail2() {
        SFResponder.EventDetail result = SFResponder.GetEventDetail('');
        System.assertEquals(result.IsValid, false);               
    }
    
    static testMethod void testProcessSyncQueue() {
        SFResponder.ProcessSyncQueue();
    }

    static testMethod void testProcessGTMQueue() {
        SFResponder.ProcessGTMQueue();
    }
            
    static Event CreateFaksEvent() {
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
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.IsAllDayEvent = false;
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        
        return event;
    }
}