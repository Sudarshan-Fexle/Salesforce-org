/**
 * 	Description 	:	test class for zoom services
 * 
 * 	Revision Logs	:	V1.0 - 03/30/2020 - Victor Hanson - Created
 * 			:	V1.1 - 11/09/2020 - Saurabh Kumar - Replaced EAB Event's Type with EAB Event's Event Type
 * 
 **/
@isTest
private class Test_ZoomServices {
    
    //Service Mock instance
    public static ZoomServicesMock mockService = new ZoomServicesMock();
    
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    
    // Zoom Type - Modified By - Chirag soni - CR-20210510-15128 - 05/11/2021 - to increase code coverage
    public static final String ZOOM_TYPE_WEBINAR = 'Webinar';
    public static final String MOCK_REGISTRANT_ID = '85746065';
    public static final String PARTICIPANT_URL = 'https://zoom.us/';


    @testSetup static void setupTest() {
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Event_Type__c = 'Research Webinar';
        
        Util.ByPassAllTriggers = true;
        insert eSeries;
        Util.ByPassAllTriggers = false;
    }
    
    static testMethod void testGetZoomInfo() {
        
        //Initialize mock response
        mockService.methodName = 'getMeeting';
        mockService.statusCode = 200;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        //get the eab event and update the webinar id
        Advisory_Event__c eabEvent = [SELECT Id, Zoom_Meeting_ID__c FROM Advisory_Event__c LIMIT 1];
        eabEvent.Zoom_Meeting_ID__c = '123-456-789';
        
        test.startTest();
        update eabEvent;
        test.stopTest();
        
        //get the updated eab event
        eabEvent = [SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c FROM Advisory_Event__c WHERE id = :eabEvent.Id];
        
        // Verify response received contains fake values
        system.assertNotEquals(null, eabEvent.Zoom_Type__c);
        system.assertNotEquals(null, eabEvent.Zoom_Type__c);
    }
    
    static testMethod void testGetZoomInfo_Error() {
        
        //Initialize mock response
        mockService.methodName = 'getMeetingError';
        mockService.statusCode = 404;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        //get the eab event and update the webinar id
        Advisory_Event__c eabEvent = [SELECT Id, Zoom_Meeting_ID__c FROM Advisory_Event__c LIMIT 1];
        eabEvent.Zoom_Meeting_ID__c = '123-456-789';
        
        test.startTest();
        update eabEvent;
        test.stopTest();
        
        //get the updated eab event
        eabEvent = [SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c FROM Advisory_Event__c WHERE id = :eabEvent.Id];
        
        // Verify response received contains fake values
        system.assertEquals(null, eabEvent.Zoom_Type__c);
    }
    
    //test the code that generates the JWToken for communicating with zoom api
    static testMethod void testGetJWToken() {
        String testClientId = 'ltury1hnfu3xkr8yxvxlt4wxuw6cv80x';
        String testSecret = 'xPLPl2AqwG4529cY38zCu7OUJwGhWDKX';
        String jwToken = ZoomServices.getJWToken(testClientId, testSecret);
        system.assertNotEquals(null, jwToken);
    }
    
    
    // Modified By - Chirag soni - CR-20210510-15128 - 05/11/2021
    static testMethod void testAddZoomRegistrant(){
        
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        
        //ByPass All triggers 
        Util.ByPassAllTriggers = true;
        
        //Create Account
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create Contact
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(testUtilities.CreateNewContact(account, false));
        contacts.add(testUtilities.CreateNewContact(account, false));
        contacts.add(testUtilities.CreateNewContact(account, false));
        
        insert contacts;
       
        //create EAB Event
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        //Create the new EAB event record for test zoom type webinar  
        Advisory_Event__c event2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event2.Name = 'Test Zoom Session Webinar';
        event2.Public_Name__c = 'Test Zoom Session Webinar';
        event2.Short_Name__c = 'Test Zoom Session Webinar';
        event2.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event2.Event_Format__c = 'Virtual';
        event2.Zoom_Type__c = ZOOM_TYPE_WEBINAR;
        event2.Zoom_Meeting_ID__c = '85746065';  
        event2.Rules_Programs__c = 'Establish independent rules';
        
        eabEvents.add(event2);
        
        insert eabEvents;
        
        //Create registrations         
        List<Registration__c> registrations = new List<Registration__c>();
         
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        Test.startTest();
        
        Set<Id> registrationsIds = new Set<Id>();
        
        for(Registration__c reg : [SELECT Id FROM Registration__c]){
            registrationsIds.add(reg.id);
        }
        
        ZoomServices.addZoomRegistrant(registrationsIds);
        
        Util.ByPassAllTriggers = false;
        
        Test.stopTest();
        
        List<Registration__c> updatedRegistrations  = [SELECT Id, Zoom_Participant_URL__c, Zoom_Registrant_ID__c FROM Registration__c];
        
        System.assertEquals(MOCK_REGISTRANT_ID, updatedRegistrations[0].Zoom_Registrant_ID__c);
        System.assertEquals(PARTICIPANT_URL, updatedRegistrations[0].Zoom_Participant_URL__c);
        
        System.assertEquals(MOCK_REGISTRANT_ID, updatedRegistrations[1].Zoom_Registrant_ID__c);
        System.assertEquals(PARTICIPANT_URL, updatedRegistrations[1].Zoom_Participant_URL__c);
        
        System.assertEquals(MOCK_REGISTRANT_ID, updatedRegistrations[2].Zoom_Registrant_ID__c);
        System.assertEquals(PARTICIPANT_URL, updatedRegistrations[2].Zoom_Participant_URL__c);
        
    } 
}