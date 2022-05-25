//Modified by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
//Modified by Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced EAB Event's Type with EAB Event's Event Type
//Modified by Saurabh Kumar - 11/10/2020 - Replaced Series Record Type with Cohort Record Type
@isTest
private class TestCrimsonSummit_Attendee_Service {
    private static Registration__c CreateRegistration(boolean CreateAndInsert) {
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c registration = CreateRegistration(newContact.Id, CreateAndInsert);
        return registration;
    }
    
    //Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    private static Registration__c CreateRegistration(Id contactId, boolean CreateAndInsert) {
        // create the meeting
        //Meeting__c meeting = CreateMeeting(true);
        Advisory_Event__c eabEvent = createEABEvent(true);
        // create the registration
        Registration__c registration = CreateRegistration(eabEvent.Id, contactId, CreateAndInsert);
        
        return registration;
    }
    
    //Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    private static Registration__c CreateRegistration(Id EABEventId, Id contactId, boolean CreateAndInsert) {
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.EAB_Event__c = EABEventId;
        registration.Status__c = 'Registered';
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    //Added by Saurabh Kumar - 10/09/2020 - CR-20200819-14447
    private static Advisory_Event__c createEABEvent(boolean CreateAndInsert){
        
        //Modified by Saurabh Kumar - 11/10/2020 - Replaced Series Record Type with Cohort Record Type
        //Modified by Saurabh Kumar - 11/09/2020 - CR-20201105-14664: Replaced EAB Event's Type with EAB Event's Event Type
        //bypass triggers
        Util.bypassAllTriggers = true;
        Advisory_Event__c eabEvent = new Advisory_Event__c(Name = 'AdvisEvent1',
                                                          Begins__c = system.now(),
                                                          Event_Type__c = 'Research Webinar',
                                                          RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT);
        if (CreateAndInsert) insert eabEvent;
        return eabEvent;
        
        
    }
    
    /*private static Meeting__c CreateMeeting(boolean CreateAndInsert) {
        //bypass triggers
        util.bypassAllTriggers = true;
        
        // Modified by Rajeev Jain for Skinny MRS - Phase 1 Release bug Fix Starts Here
        Advisory_Event__c advisoryEvnt = new Advisory_Event__c(Name = 'AdvisEvent1');
        insert advisoryEvnt;
        
        // create the meeting
        Meeting__c meeting = new Meeting__c();
        meeting.DateTime__c = system.now();
        meeting.Type__c = 'Onsite';
        meeting.Name = 'Test';
        meeting.EAB_Event__c =advisoryEvnt.Id;
        if (CreateAndInsert) insert meeting;
        return meeting;
    }*/
    
    //Added by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    static testmethod void testGet() {
        
         //bypass triggers
        util.bypassAllTriggers = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        // create a child meeting from the one created above
        //Meeting__c childMeeting1 = CreateMeeting(false);
      
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT;
        insert childEABEvent1;
        
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = childEABEvent1.Id;
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION;
        insert childEABEvent2;
        
        Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        //Added by Saurabh Kumar    
        String name = '- Cohort'; 
        req.requestURI = '/services/apexrest/Attendee/'+name;
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.stopTest();
        
        List<CrimsonSummit_Attendee_Service.Attendee> result = CrimsonSummit_Attendee_Service.getAll();
        //system.assertEquals(1, result.size());
    }
    
    //Added by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    static testmethod void testGet2() {
        
        //bypass triggers
        util.bypassAllTriggers = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        // create a child meeting from the one created above
        //Meeting__c childMeeting1 = CreateMeeting(false);
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent1.Location__c = 'Location 1';
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT;
        insert childEABEvent1;
        
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = childEABEvent1.Id;
        //childMeeting2.Display_On_Badge__c = True;
        childEABEvent2.Location__c = 'Location 2';
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION;
        insert childEABEvent2;
        
        Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        // Commented by Mahendar Swrankar as per the requirement - CR-20190826-13284 - 30/10/2019 - Reason - Speaker_Note__c field is flagged as delete
        /*registration1.Speaker_Note__c = 'Speaker Note 1';
        registration2.Speaker_Note__c = 'Speaker Note 2';*/
        
        Contact c = [SELECT Suffix__c FROM Contact WHERE ID= :registration1.Contact__c];
        c.Suffix__c = 'S';
        UPDATE c;
        test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        //Added by Saurabh Kumar
        String name = '- Cohort'; 
        req.requestURI = '/services/apexrest/Attendee/'+name;
        
        RestContext.request = req;
        RestContext.response = res;
        test.stopTest();
        
        List<CrimsonSummit_Attendee_Service.Attendee> result = CrimsonSummit_Attendee_Service.getAll();
        

        //system.assertEquals(1, result.size());
    }
}