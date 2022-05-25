/**
 *   Description     :   test class for RegistrationHelper
 * 
 *   Revision Logs   :   V1.0 - 03/31/2020 - Victor Hanson - Created
 *               	 V1.1 - 05/04/2020 - Dipesh Gupta modified (modify : testCheckRegistrations & Add: testSendCalendarInvites)
 *               	 V1.2 - 05/12/2020 - Victor Hanson - CR-20200507-14026 - updated tests and added testZoomServices_updateParticipantAttendance
 *               	 V1.3 - 09/14/2020 - Victor Hanson - CR-20200914-14505 - updated to check for web service logs
 *               	 V1.4 - 09/24/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Advisory_Event__c.Meeting__c field
 *              	 V1.5 - 10/01/2020 - Saurabh Kumar - CR-20200821-14453 - Created populatePartnerStatus, updatePartnerStatus & createMembershipMtMRecords methods.
 *              	 V1.6 - 10/06/2020 - Saurabh Kumar - CR-20200821-14460 - Created populateRegistrationField method.
 *              	 V1.7 - 10/10/2020 - Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
 *              	 V1.8 - 10/29/2020 - Saurabh Kumar modified - CR-20200908-14493 - testCheckRegistrations
 *              	 V1.9 - 10/29/2020 - Saurabh Kumar modified - CR-20200424-13983 - testSendCalendarInvites 
 *              	 V2.0 - 10/30/2020 - Saurabh Kumar - CR-20200821-14454 - Added new methods testCreateRegistrationsForChildEABEvents, testValidateRegistrations
 *              	 V2.1 - 11/11/2020 - Saurabh Kumar - Replaced Status 'Scheduled' with 'Registration Requested' (Not Exist Scheduled picklist value)
 *              	 V2.2 - 11/11/2020 - Saurabh Kumar - CR-20200821-14454 - CR-20200820-14451 - Added Status 'Open - Waitlist Only' On EAB Event(Registration is allowed to save for this EAB Event's Status) and Updated populateRegistrationField() method 
 *              	 V2.3 - 11/13/2020 - Saurabh Kumar - CR-20201106-14675 - Replaced Origin__c's picklist values from Microsite with EAB.com & Manual with Salesforce.
 *              	 V2.4 - 11/17/2020 - Saurabh Kumar - CR-20200821-14461 - Add new method testZoomWebhook_meetingJoined
 *              	 V2.5 - 11/19/2020 - Saurabh Kumar - CR-20200821-14465 - Updated populateRegistrationField() method.
 * 			 V2.6 - 02/23/2021 - Saurabh Kumar - CR-20210217-14921 - Created testCreateRegistrationsForChildEABEventsV2() method
 * 			 V2.7 - 03/11/2021 - Saurabh Kumar - CR-20210308-14971 - Updated various methods to fix all failures.
 *			 V2.8 - 04/08/2021 - Neha Sharma - CR-20210324-15020 - MRS test class update
 *			 V2.9 - 04/12/2021 - Saurabh Kumar - CR-20210324-15021 - Created and Updated various methods.
 *			 V3.0 - 04/16/2021 - Neha Sharma  - CR-20210324-15023 - MRS test class update
 *			 V3.1 - 04/12/2021 - Neha Sharma  - CR-20210324-15022 - MRS test class update
 *			 V3.2 - Modified By - Saurabh Kumar - 03/31/2021 - CR-20201116-14696
 *			 V3.3 - Modified By - Saurabh Kumar - CR-20210318-15005
 *			 V3.4 - Modified By - Saurabh Kumar - CR-20210312-14994
 *			 V3.5 - Modified By - Saurabh Kumar - CR-20210224-14940
 *			 V3.6 - Modified By - Saurabh Kumar - CR-20210128-14854
 *			 V3.7 - Modified By - Saurabh Kumar - CR-20210114-14812
 *			 V3.8 - Modified By - Chirag Soni - CR-20210716-15294 - 07/30/2021 - Added code to test Calendar Invite for Elevated Meal and Modified the method to increase code coverage
 *		         V3.9 - Modified By - Chirag Soni - CR-20210408-15071 - 06/01/2021 - Created testCancelParentsEligibleRegistrations() method.
 *                       V4.0 - Modified By - Chirag Soni - CR-20210628-15254 - 07/30/2021 - Added a new method - testSendCalendarInvitesV2() - to test different Communication Template and updated setup() method
 *			 V4.1 - Modified By - Chirag Soni - 08/12/2021 - CR-20210614-15213 - Created testPopulateElevatedMealRSVPFieldOnParentEvent() Method.
 *			 V4.2 - Modified By - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Added new Advisory child Event
 *			 V4.3 - Modified By - Chirag Soni - 07/09/2021 - CR-20210511-15133 - Created testPopulateTravelCompensationFields() method.
 *			 V4.4 - Modified By - Chirag Soni - CR-20210606-15193
 *
 **/
@isTest
private class Test_RegistrationHelper {
    
    //Service Mock instance
    public static ZoomServicesMock mockService = new ZoomServicesMock();
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    static User usr = [select id from User where isActive = true AND UserType = 'Standard' limit 1];
    
    private static String meetingGUID = '000-000-001';
    private static String zoomMeetingId = '123-345-678';
    public static final String calendarInviteRecordType = Schema.SObjectType.Communication_Template__c.getRecordTypeInfosByDeveloperName().get('Calendar_Invite').getRecordTypeId();
    
    
/**
 * 
 * @description : setup the registration and supporting records
 * @Version	: V1.0 - Modified By -  Chirag Soni - CR-20210628-15254 -  09/20/2021 - updated the communication template name to match the filter criteria
 **/
    @testSetup static void setup() {
        Util.bypassAllTriggers = true;
        
        Test.setMock(HttpCalloutMock.class, new MockAcquiaHTTPCallout());
        
        // create a Communication Template
        Communication_Template__c newCommunicationTemplate = new Communication_Template__c();
        //Modified By -  Chirag Soni - CR-20210628-15254 -  09/20/2021 - updated the communication template name From "Zoom National" to "Virtual Event"  to match the filter criteria
        newCommunicationTemplate.Name = 'Virtual Event';
        newCommunicationTemplate.Event_Type__c = 'Virtual National Meeting';
        newCommunicationTemplate.RecordTypeId = calendarInviteRecordType;
        insert newCommunicationTemplate;
        
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Meeting_GUID__c = meetingGUID;
        eSeries.Event_Type__c = 'Research Working Sessions';
        insert eSeries;
        
        //create meetings that correspond to the advisory event structure that was just created
        //Meeting__c parentMeeting = Test_SiteMeetingController.CreateMeeting(false);
        Advisory_Event__c parentEABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        parentEABEvent.Parent_Event__c = eSeries.Id;
        parentEABEvent.Meeting_GUID__c = meetingGUID;
        parentEABEvent.Event_Type__c = 'Research Working Sessions';
        parentEABEvent.Public_Name__c = 'Test';
        parentEABEvent.Short_Name__c = 'Test';
        parentEABEvent.Status__c = 'Open - Registration';
        parentEABEvent.Begins__c = System.today();
        parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        Util.bypassAllTriggers = false;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true); 
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(parentEABEvent.Id, newContact.Id, true); 
        
    }
    
    //test updateRegistrationCount
     // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testUpdateRegistrationCount() {
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //get the registration
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c WHERE EAB_Event__r.Meeting_GUID__c != null ];
        System.assert(reg.EAB_Event__c != null);
        test.startTest();
        
        //update registration
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        update reg;
        
        test.stopTest();
        //Meeting__c meeting = [SELECT Id, EAB_Event__c, EAB_Event__r.Current_Registration_Count__c FROM Meeting__c WHERE Meeting_GUID__c = :meetingGUID];
        Advisory_Event__c eabEvent = [Select Id, Current_Registration_Count__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c];
        
        //assertions
        system.assertEquals(1, eabEvent.Current_Registration_Count__c);
    }
    
    //Added by Saurabh Kumar  10-01-2020 - CR-20200908-14493 - test checkRegistrations - Insert
    static testMethod void testCheckRegistrations() {
        
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id FROM Advisory_Event__c Limit 1];
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Zoom_Type__c = 'Meeting';
        update eSeries;
        
        //Meeting__c meeting = [SELECT Id FROM Meeting__c WHERE Meeting_GUID__c = :meetingGUID];
        Advisory_Event__c eabEvent = [SELECT Id FROM Advisory_Event__c Limit 1];
        Contact con = [SELECT Id FROM Contact];
        
        test.startTest();
        
        //util.bypassAllTriggers = false;
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = con.Id;
        registration.EAB_Event__c = eabEvent.Id;
        registration.Status__c = RegistrationHelper.STATUS_REGISTERED;
        
        insert registration;
        System.assertNotEquals(null, registration.Id);
        
        registration = [SELECT Id, Zoom_Registrant_ID__c, Zoom_Participant_URL__c FROM Registration__c WHERE Id = :registration.Id];
        
        test.stopTest();

    }
    
    //Modified By - Neha Sharma - 04/16/2021 - CR-20210324-15023
    //test checkRegistrations
     // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testUpdateZoomRegistrantStatus() {
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //bypass triggers
        util.bypassAllTriggers = true;
        
        List<Account> accounts = [Select Id From Account];
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        
        Insert contacts;
        
        //create Events
        List<Advisory_Event__c> events = new List<Advisory_Event__c>();
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test1';
        event.Short_Name__c = 'Test1';
        event.Status__c = 'Open - Registration';
        event.Begins__c = System.today();
        event.Ends__c = System.today().addDays(1);
        event.Zoom_Type__c = 'Webinar';
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
        events.add(event);
        
        //create child event
        event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test2';
        event.Short_Name__c = 'Test2';
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Begins__c = System.today();
        event.Ends__c = System.today();
        event.Zoom_Type__c = null;
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
	events.add(event);
        
        Insert events;
        
        //create the registration
        List<Registration__c> registrations = new List<Registration__c>();
        Registration__c registr = Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[0].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[1].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[2].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[3].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        Insert registrations;
        
        util.bypassAllTriggers = false;
        
        test.startTest();
        
        for(Registration__c reg :registrations){
            //Update registration status = cancelled, which will send callout to zoom
            reg.Status__c = RegistrationHelper.STATUS_CANCELLED;
            reg.Cancellation_Reason__c = 'Normal Reason';
        }
        update registrations;
        
        registrations = [SELECT Id, Zoom_Registrant_ID__c, Zoom_Participant_URL__c FROM Registration__c WHERE Id IN :registrations];
        
        test.stopTest();
        
        //assertions
        system.assertEquals(null, registrations[0].Zoom_Registrant_ID__c, 'registration is cancelled, so zoom registration id should be null');
        system.assertEquals(null, registrations[0].Zoom_Participant_URL__c);
    }

    
    //Modified By - Neha Sharma - 04/16/2021 - CR-20210324-15023
    //test checkRegistrations
    static testMethod void testUpdateZoomRegistrantStatusV2() {
        
        //bypass triggers
        util.bypassAllTriggers = true;
        
        List<Account> accounts = [Select Id From Account];
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        
        Insert contacts;
        
        //create Events
        List<Advisory_Event__c> events = new List<Advisory_Event__c>();
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test1';
        event.Short_Name__c = 'Test1';
        event.Status__c = 'Open - Registration';
        event.Begins__c = System.today();
        event.Ends__c = System.today().addDays(1);
        event.Zoom_Type__c = 'Webinar';
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
        event.OwnerId = UserInfo.getUserId();
        events.add(event);
        
        //create child event
        event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test2';
        event.Short_Name__c = 'Test2';
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Begins__c = System.today();
        event.Ends__c = System.today();
        event.Zoom_Type__c = null;
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
        event.OwnerId = UserInfo.getUserId();
	events.add(event);
        
        Insert events;
        
        //create the registration
        List<Registration__c> registrations = new List<Registration__c>();
        Registration__c registr = Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[0].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[1].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[2].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        registr = Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[3].Id, false);
        registr.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registrations.add(registr);
        
        Insert registrations;
        
        //registration Ids
        Set<Id> regIds = new Set<Id>{registrations[0].Id, registrations[1].Id, registrations[2].Id, registrations[3].Id};
        util.bypassAllTriggers = false;
        
        try{
            //Initialize mock response
            mockService.methodName = 'addZoomRegistrant';
            mockService.statusCode = 400;
            HttpService.response = mockService.respond(httpReq);
            Test.setMock(HttpCalloutMock.class, mockService);
            
            test.startTest();
            ZoomServices.updateZoomRegistrantStatus(regIds, RegistrationHelper.STATUS_CANCELLED);
            test.stopTest();
        }
        catch(Exception ex){
            System.assertEquals(true, ex.getMessage().contains('Email address is invalid'));
        }
        
        try{
            //Initialize mock response
            mockService.methodName = 'addZoomRegistrant';
            mockService.statusCode = 201;
            HttpService.response = mockService.respond(httpReq);
            Test.setMock(HttpCalloutMock.class, mockService);
                        
            //get Updated registration
            registrations = [SELECT Id, Status__c, Zoom_Registrant_ID__c, Zoom_Participant_URL__c FROM Registration__c WHERE Id IN :registrations];
            
            for(Registration__c reg :registrations){
                //assertions
                system.assertEquals(null, reg.Zoom_Registrant_ID__c);
                system.assertEquals(null, reg.Zoom_Participant_URL__c);
            }
            
        }
        catch(Exception ex){
            System.assertEquals(null, ex.getMessage());
        }
    }
    
    //test zoomWebhooks.doPost() & processWebhook
    static testMethod void testZoomWebhook_meetingStarted() {
        
        // Modified by Rajeev On 04/6/2020 Start Here for (Skinny MRS - Phase 2 Release Bug Fix During Deployment)
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        // Modified by Rajeev On 04/6/2020 Ends Here 
        
        //get the registration
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c WHERE EAB_Event__r.Meeting_GUID__c != null];

        String reqBody = '{"event":"meeting.started","payload":{"account_id":"o8KK_AAACq6BBEyA70CA","operator":"someemail@email.com","object":{"uuid":"czLF6FFFoQOKgAB99DlDb9g==","id":"'+zoomMeetingId.replaceAll('-', '')+'","host_id":"uLoRgfbbTayCX6r2Q_qQsQ","topic":"My Meeting","type":2,"start_time":"2019-07-09T17:00:00Z","duration":60,"timezone":"America/Los_Angeles"}}}';

        util.BypassAllTriggers = true;

        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c FROM Advisory_Event__c Limit 1];
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Zoom_Type__c = 'Meeting';
        update eSeries;
        
        Test.setMock(HttpCalloutMock.class, mockService);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/zoomWebhookService';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(reqBody);
        RestContext.request = req;
        RestContext.response= res;

        test.startTest();

        //execute the callout
        ZoomWebhooks.doPost();

        test.stopTest();

    } 

    //Modified By Saurabh Kumar to increase coverage
    //Modified By - Chirag Soni - CR-20210716-15294 - 07/30/2021 - Added code to test Calendar Invite for Elevated Meal
    //Modified by - Chirag soni - 10/19/2021 - CR-20210628-15254 - Test class issue fixes - Moved the stop test
    static testMethod void testSendCalendarInvites() {
        
        //Initialize mock response
        mockService.methodName = 'callWebServiceToSendCommunicationtTemplate';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);

        Communication_Template__c newCommTemplate = [SELECT Id, Name, Event_Type__c, RecordTypeId FROM Communication_Template__c];

        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c FROM Advisory_Event__c Limit 1];
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Zoom_Type__c = 'Meeting';
        eSeries.Communication_Template__c = newCommTemplate.Id;
        eSeries.Public_Name__c = 'SAF/EMF Working Session Meeting Four';
        eSeries.Zoom_DialIn_Number__c = '+1 (312) 626-6799';
        eSeries.Event_Website__c = 'eab.test.com';
        update eSeries;
        
        //Meeting__c meeting = [SELECT Id, EAB_Event__c, EAB_Event__r.Current_Registration_Count__c FROM Meeting__c WHERE Meeting_GUID__c = :meetingGUID];
        Advisory_Event__c eabEvent = [SELECT Id, Communication_Template__c, Current_Registration_Count__c FROM Advisory_Event__c Limit 1];
        eabEvent.Begins__c = Datetime.now();
        eabEvent.Ends__c = Datetime.now().addDays(10);
        update eabEvent;
        
        //util.bypassAllTriggers = true;
        Contact newCon = [SELECT Id, Name FROM Contact];
        newCon.Company_Email__c = math.random() + '@gmail.com';
        newCon.Asst_Email__c = math.random() + '@gmail.com';
        update newCon;

        //Added By - Chirag Soni - CR-20210716-15294 - 07/30/2021 - added new contact and Registration to test Cancelled Registration Case - From here
        //create a new contact
        Contact newContact = testUtilities.CreateNewContact(true); 

        //update contact
        newContact.Company_Email__c = math.random() + '@gmail.com';
        newContact.Asst_Email__c = math.random() + '@gmail.com';

        //update contact
        update newContact;
        
        //Added Flags 
        util.bypassAllTriggers = false;
             
        test.startTest();

        //new Registration
        Registration__c registration =  new Registration__c(EAB_Event__c = eabEvent.Id, Contact__c = newContact.Id, Status__c = 'Registration Requested');
        insert registration; 
        
        registration = [SELECT Id, Status__c, EAB_Event__c, EAB_Event__r.Zoom_Type__c,
                               EAB_Event__r.Zoom_Meeting_ID__c, Zoom_Registrant_ID__c, Zoom_Participant_URL__c, Contact__c , EAB_Event__r.Communication_Template__c 
                               FROM Registration__c Where Id =: registration.Id Limit 1];

        //update Registration status
        registration.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registration.Zoom_Participant_URL__c = 'https://zoom.us/';

        //update registration
        update registration;

        //update Registration status to cancelled
        registration.Status__c = RegistrationHelper.STATUS_CANCELLED;
        registration.Cancellation_Reason__c = 'Testing';

        //update registration
        update registration;
        //Added By - Chirag Soni - CR-20210716-15294 - 07/30/2021 - added new contact and Registration to test Cancelled Registration Case - From here
        
        //util.bypassAllTriggers = true;
        //get the registration
        Registration__c reg = [SELECT Id, Status__c, EAB_Event__c, EAB_Event__r.Zoom_Type__c,
                               EAB_Event__r.Zoom_Meeting_ID__c, Zoom_Registrant_ID__c, Zoom_Participant_URL__c, Contact__c , EAB_Event__r.Communication_Template__c 
                               FROM Registration__c Where Id !=:registration.Id Limit 1];
       
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        reg.Zoom_Participant_URL__c = 'https://zoom.us/';
        reg.EAB_Event__c = eabEvent.Id;// Added by Saurabh Kumar -Template exist On EAB Event
        //util.bypassAllTriggers = false;

        //Added Flags
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = true;
        //update registration
        update reg;                

        //Added By -  Chirag Soni - CR-20210716-15294 - 07/28/2021 - to test Calendar Invite for Elevated Meal - Start Here
        util.bypassAllTriggers = true;
        eabEvent = [SELECT Id, Communication_Template__c, RecordTypeId FROM Advisory_Event__c Limit 1];
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;

        update eabEvent;
        util.bypassAllTriggers = false;
	
    	test.stopTest();
	
        //Update Registration RecordType
        reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL;
        update reg;

        //Update Registration 
        reg = [SELECT Id, Status__c, EAB_Event__c, Zoom_Participant_URL__c, RecordTypeId FROM Registration__c Limit 1];
        reg.Elevated_Meal_RSVP__c = 'Yes';
        update reg;

        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = false;
        //Added By -  Chirag Soni - CR-20210716-15294 - 07/28/2021 - to test Calendar Invite for Elevated Meal - Till Here
       
        //assertions
        system.assertNotEquals(null, reg.Status__c);
        system.assertNotEquals(null, reg.EAB_Event__c);
        system.assertNotEquals(null, reg.Zoom_Participant_URL__c);
    }
    
    //Added by -  Chirag Soni - CR-20210628-15254 -  09/20/2021 - added method for calendar Invite
    //Modified by - Chirag soni - 10/19/2021 - CR-20210628-15254 - Test class issue fixes CR-20210628-15254 - Removed the Account record 
    static testMethod void testSendCalendarInvitesV2() {
        
        //Initialize mock response
        mockService.methodName = 'callWebServiceToSendCommunicationtTemplate';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);

        util.bypassAllTriggers = true;
        
        Communication_Template__c newCommTemplate = [SELECT Id, Name, Event_Type__c, RecordTypeId FROM Communication_Template__c];
        
        //Added by -  Chirag Soni - CR-20210628-15254 -  09/20/2021 - added new communication template
        List<Communication_Template__c> communicationTemplates = new List<Communication_Template__c>();
        communicationTemplates.add(new Communication_Template__c(Name = 'Dinner'));
        communicationTemplates.add(new Communication_Template__c(Name = 'In-Person Event'));
        communicationTemplates.add(new Communication_Template__c(Name = 'Reception'));
        
        //insert communicationTemplate
        insert communicationTemplates;
        //communicationTemplates = [SELECT Id, Name, Event_Type__c FROM Communication_Template__c ORDER BY Name ASC];
        
        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id, Zoom_Meeting_ID__c, Zoom_Type__c FROM Advisory_Event__c Limit 1];
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Zoom_Type__c = 'Meeting';
        eSeries.Communication_Template__c = communicationTemplates[0].Id;
        eSeries.Public_Name__c = 'SAF/EMF Working Session Meeting Four';
        eSeries.Zoom_DialIn_Number__c = '+1 (312) 626-6799';
        eSeries.Event_Website__c = 'eab.test.com';
        update eSeries;
            
        Advisory_Event__c eabEvent = [SELECT Id, Communication_Template__c, Current_Registration_Count__c FROM Advisory_Event__c Limit 1];
        eabEvent.Begins__c = Datetime.now();
        eabEvent.Ends__c = Datetime.now().addDays(10);
        update eabEvent;
        
        //util.bypassAllTriggers = true;
        Contact newCon = [SELECT Id, Name FROM Contact];
        newCon.Company_Email__c = math.random() + '@gmail.com';
        newCon.Asst_Email__c = math.random() + '@gmail.com';
        update newCon;

        //added new contact and Registration to test Cancelled Registration Case - From here
        //create a new contact
        Contact newContact = testUtilities.CreateNewContact(false); 

        //update contact
        newContact.Company_Email__c = math.random() + '@gmail.com';
        newContact.Asst_Email__c = math.random() + '@gmail.com';

        //update contact
        insert newContact;
        
        //Added Flags 
        util.bypassAllTriggers = false;
             
        test.startTest();

        //new Registration
        Registration__c registration =  new Registration__c(EAB_Event__c = eabEvent.Id, Contact__c = newContact.Id, Status__c = 'Registration Requested');
        insert registration; 
        
        registration = [SELECT Id, Status__c, Approval_Status__c, EAB_Event__c, EAB_Event__r.Zoom_Type__c,
        		EAB_Event__r.Zoom_Meeting_ID__c, Zoom_Registrant_ID__c, Zoom_Participant_URL__c, Contact__c , EAB_Event__r.Communication_Template__c 
                        FROM Registration__c Where Id =: registration.Id Limit 1];

        //update Registration status
        registration.Status__c = RegistrationHelper.STATUS_REGISTERED;
        registration.Zoom_Participant_URL__c = 'https://zoom.us/';
	registration.Approval_Status__c = 'Approved';

        //update Registration status to cancelled
        registration.Status__c = RegistrationHelper.STATUS_CANCELLED;
        registration.Cancellation_Reason__c = 'Testing';
	registration.Approval_Status__c = null;
        
        //update registration
        update registration;
        
        //get the registration
        Registration__c reg = [SELECT Id, Approval_Status__c, Status__c, EAB_Event__c, EAB_Event__r.Zoom_Type__c,
                               EAB_Event__r.Zoom_Meeting_ID__c, Zoom_Registrant_ID__c, Zoom_Participant_URL__c, Contact__c , EAB_Event__r.Communication_Template__c 
                               FROM Registration__c Where Id !=:registration.Id Limit 1];
       
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        reg.Zoom_Participant_URL__c = 'https://zoom.us/';
        registration.Approval_Status__c = 'Approved';
        reg.EAB_Event__c = eabEvent.Id;
        //util.bypassAllTriggers = false;

        //Added Flags
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = true;
        //update registration
        update reg;                

        //Added By -  Chirag Soni - CR-20210716-15294 - 07/28/2021 - to test Calendar Invite for Elevated Meal - Start Here
        util.bypassAllTriggers = true;
        eabEvent = [SELECT Id, Communication_Template__c, RecordTypeId FROM Advisory_Event__c Limit 1];
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;
	eabEvent.Communication_Template__c = communicationTemplates[1].Id;
        update eabEvent;
        util.bypassAllTriggers = false;

        //Update Registration RecordType
        reg.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL;
        update reg;
		
        //Added By -  Chirag Soni - CR-20210716-15294 - 07/28/2021 - to test Calendar Invite for Elevated Meal - Start Here
        util.bypassAllTriggers = true;
        eabEvent = [SELECT Id, Communication_Template__c, RecordTypeId FROM Advisory_Event__c Limit 1];
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;
	eabEvent.Communication_Template__c = communicationTemplates[2].Id;
        update eabEvent;
        util.bypassAllTriggers = false;
        
        //Update Registration 
        reg = [SELECT Id, Status__c, EAB_Event__c, Zoom_Participant_URL__c, RecordTypeId FROM Registration__c Limit 1];
        reg.Elevated_Meal_RSVP__c = 'Yes';
        update reg;

        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = false;
        //Added By -  Chirag Soni - CR-20210716-15294 - 07/28/2021 - to test Calendar Invite for Elevated Meal - Till Here
        test.stopTest();
        //assertions
        system.assertNotEquals(null, reg.Status__c);
        system.assertNotEquals(null, reg.EAB_Event__c);
        system.assertNotEquals(null, reg.Zoom_Participant_URL__c);
    }
    
    //test update participantAttendance
    //05/12/2020 - VH - CR-20200507-14026
    static testMethod void testZoomServices_updateParticipantAttendance() {
        
    //Initialize mock response
        mockService.methodName = 'getParticipants';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id FROM Advisory_Event__c LIMIT 1];
        eSeries.Zoom_Type__c = 'Meeting';
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Status__c = 'Open - Registration';
        util.bypassAllTriggers = true;
        update eSeries;
        
        util.bypassAllTriggers = true;
                
        util.bypassAllTriggers = true;
        Contact newCon = [SELECT Id, Name FROM Contact];
        newCon.email = 'testParticipant@eab.com';
        update newCon;
        
        //get the registration
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c, Contact__c FROM Registration__c LIMIT 1];
        reg.EAB_Event__c = eSeries.Id;
        reg.Contact__c = newCon.Id;
        reg.Status__c = 'Registered';
        util.BypassAllTriggers = true;
        update reg;

        //02/16/2021 - CR-20210216-14920 - Victor Hanson - added to test duplicate zoom session fix
        Zoom_Session__c zSession = new Zoom_Session__c(Registrant__c = reg.Id,
                                                        Time_Joined__c = DateTime.now(),
                                                        Time_Left__c = DateTime.now().addHours(5),
                                                        EAB_Event__c = eSeries.Id,
                                                        UUID__c = '33555456');
        insert zSession;
        
        List<Registration__c> registrants = [SELECT Id, Time_Joined__c, Time_Left__c, Contact__r.Email, Attended__c, Status__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c
                                            FROM Registration__c 
                                            WHERE Contact__r.Email = 'testParticipant@eab.com' AND EAB_Event__r.Zoom_Meeting_ID_Formula__c = '123345678'];
        system.assertEquals(1, registrants.size());
        system.assertEquals(zoomMeetingId.replaceAll('-', ''), registrants[0].EAB_Event__r.Zoom_Meeting_ID_Formula__c);
        
        test.startTest();

        //execute the callout
        ZoomServices zService = new ZoomServices();
        
        zService.updateParticipantAttendance(zoomMeetingId.replaceAll('-', ''), null);
        
        test.stopTest();
        
        //get the zoom session and verify the details match
        List<Zoom_Session__c> zSessions = [SELECT Id, Registrant__c, Time_Joined__c, Time_Left__c, Registrant__r.Time_Joined__c, Registrant__r.Time_Left__c, Registrant__r.Attended__c FROM Zoom_Session__c WHERE Registrant__c = :reg.Id];
        system.assertEquals(2, zSessions.size(), '2 zoom sessions was expected');
        system.assertEquals(true, zSessions[0].Registrant__r.Attended__c);
        DateTime earliestJoined = (DateTime) JSON.deserialize('"2021-02-10T18:57:48Z"', DateTime.class);
        DateTime latestLeft = (DateTime) JSON.deserialize('"2021-02-10T19:45:59Z"', DateTime.class);
        system.assertEquals(earliestJoined, zSessions[0].Registrant__r.Time_Joined__c);
        system.assertEquals(latestLeft, zSessions[0].Registrant__r.Time_Left__c, 'Time Left should have been overwritten by zoomServicesMock value');
    }
        
    //Created by Neha Sharma - 04/12/2021 - CR-20210324-15022
    //test update participantAttendance
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    // Modified by - Neha Sharma - 07/21/2021 - Issue Fixes - CR-20210625-15241
    static testMethod void testZoomServices_updateParticipantAttendanceV2() {
        
        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id FROM Advisory_Event__c LIMIT 1];
        eSeries.Zoom_Type__c = 'Webinar';
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Status__c = 'Open - Registration';
        
        Update eSeries;
        
        Contact newCon = [SELECT Id, Name FROM Contact];
        //update contact email
        newCon.email = 'testParticipant@eab.com';
        update newCon;
        
        //get the registration
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c, Contact__c FROM Registration__c LIMIT 1];
        reg.EAB_Event__c = eSeries.Id;
        reg.Contact__c = newCon.Id;
        reg.Status__c = 'Registered';
        
        Update reg;
        
        //02/16/2021 - CR-20210216-14920 - Victor Hanson - added to test duplicate zoom session fix
        Zoom_Session__c zSession = new Zoom_Session__c(Registrant__c = reg.Id,
                                                       Time_Joined__c = DateTime.now(),
                                                       Time_Left__c = DateTime.now().addHours(5),
                                                       EAB_Event__c = eSeries.Id,
                                                       UUID__c = '33555456');
        insert zSession;
        
        List<Registration__c> registrants = [SELECT Id, Time_Joined__c, Time_Left__c, Contact__r.Email, Attended__c, Status__c, EAB_Event__r.Zoom_Meeting_ID_Formula__c
                                             FROM Registration__c 
                                             WHERE EAB_Event__r.Zoom_Meeting_ID_Formula__c = '123345678'];
        system.assertEquals(1, registrants.size());
        system.assertEquals(zoomMeetingId.replaceAll('-', ''), registrants[0].EAB_Event__r.Zoom_Meeting_ID_Formula__c);
        
        //execute the callout
        ZoomServices zService = new ZoomServices();
        
        try{
            
            //Initialize mock response with error response
            mockService.methodName = 'getParticipants';
            mockService.statusCode = 400;
            HttpService.response = mockService.respond(httpReq);
            Test.setMock(HttpCalloutMock.class, mockService);
            
            test.startTest();
            zService.updateParticipantAttendance(zoomMeetingId.replaceAll('-', ''), null);
            
            test.stopTest();
            
        }
        catch(Exception ex){
            //check error
            System.assertEquals(true, ex.getMessage().contains('Error: 400'));
        }
        
        try{
            
            //Initialize mock response
            mockService.methodName = 'getParticipants';
            mockService.statusCode = 201;
            HttpService.response = mockService.respond(httpReq);
            Test.setMock(HttpCalloutMock.class, mockService);
                        
            //execute the callout
            //ZoomServices zService = new ZoomServices();
            
            zService.updateParticipantAttendance(zoomMeetingId.replaceAll('-', ''), null);
            
            test.stopTest();
            
            //get the zoom session and verify the details match
            List<Zoom_Session__c> zSessions = [SELECT Id, Registrant__c, Time_Joined__c, Time_Left__c, Registrant__r.Time_Joined__c, Registrant__r.Time_Left__c, Registrant__r.Attended__c FROM Zoom_Session__c WHERE Registrant__c = :reg.Id];
            system.assertEquals(2, zSessions.size(), '2 zoom sessions was expected');
            system.assertEquals(true, zSessions[0].Registrant__r.Attended__c);
            DateTime earliestJoined = (DateTime) JSON.deserialize('"2021-02-10T18:57:48Z"', DateTime.class);
            DateTime latestLeft = (DateTime) JSON.deserialize('"2021-02-10T19:45:59Z"', DateTime.class);
            system.assertEquals(earliestJoined, zSessions[0].Registrant__r.Time_Joined__c);
            system.assertEquals(latestLeft, zSessions[0].Registrant__r.Time_Left__c, 'Time Left should have been overwritten by zoomServicesMock value');
            
            //Modified by - Neha Sharma - 07/21/2021 - Added where clause in query
            //get Web_Service_Log__c 
            List<Web_Service_Log__c> webServiceLogs = [Select Request_Sent__c,EAB_Event__c,Web_Service_Method__c,Registration__c From Web_Service_Log__c Where Registration__c != null];
	    System.assertEquals(2, webServiceLogs.size());
            System.assertEquals(eSeries.Id, webServiceLogs[1].EAB_Event__c);
            System.assertEquals('updateParticipantAttendance', webServiceLogs[1].Web_Service_Method__c);
            
        }
        catch(Exception ex){
            //check error
            System.assertEquals(null, ex.getMessage());
        }
        
    }
    
    //Created by Neha Sharma - 04/15/2021 - CR-20210324-15023
    //Added by Saurabh Kumar  10-01-2020 - CR-20200821-14453
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testCreateMembershipMtMRecords() {
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //bypass triggers
        util.bypassAllTriggers = true;
        
        //get Account & contacts
        List<Account> accounts = [SELECT ID FROM Account];
        List<Contact> contacts = new List<Contact>();
        
        //create a account
        accounts.add(TestUtilities.createNewAccount(true));
        
        //create contacts
        contacts.add(TestUtilities.createNewContact(accounts[0], false));
        //create contact without account
        Contact cont = TestUtilities.createNewContact(accounts[0], false);
        cont.AccountId = null;
        contacts.add(cont);
        
        Insert contacts;
        
        //Create the new Program records
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'Test Program1', Program_Acronym__c = 'TEST1'));
        programs.add(new Program__c(Name = 'Test Program2', Program_Acronym__c = 'TEST2'));
        
        Insert programs;
        
        //Create the new Membership records
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership 1', Account_Name__c = accounts[0].Id,
                                          Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 2', Account_Name__c = accounts[0].Id,
                                          Program__c = programs[1].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 3', Account_Name__c = accounts[1].Id,
                                          Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 4', Account_Name__c = accounts[1].Id,
                                          Program__c = programs[1].Id, Membership_Status_Text__c = 'Member -Payer'));
        
        Insert memberships;
        
        // create new EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Primary_Program__c  = programs[0].Id;
        event.Rules_Programs__c = 'Establish independent rules';
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test';
        event.Short_Name__c = 'Test';
        event.Begins__c = System.today();
        event.Ends__c = System.today();
        eabEvents.add(event);
        
        event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Primary_Program__c  = programs[1].Id;
        event.Rules_Programs__c = 'Establish independent rules';
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test';
        event.Short_Name__c = 'Test';
        event.Begins__c = System.today();
        event.Ends__c = System.today();
        eabEvents.add(event);
        
        Insert eabEvents;
        Test.startTest();
        
        // create rules
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[0].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[1].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[0].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[1].Id, Primary__c = true));
        
        Insert rules;
        
        //stop bypass trigger
        util.bypassAllTriggers = false;
               
        //create registrations
        List<Registration__c> registrations = new List<Registration__c>();
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(eabEvents[1].Id, contacts[1].Id, false));
        
        insert registrations;
        
        Test.stopTest();
        
        //assert on MtM that is created under Registration
        List<Membership_MtM__c> membershipMTMs = [SELECT ID,Registration__c,Membership__c FROM Membership_MtM__c];
        System.assertEquals(4, membershipMTMs.size());
        //for 1st registration
        System.assertEquals(memberships[0].Id, membershipMTMs[0].Membership__c);
        System.assertEquals(memberships[1].Id, membershipMTMs[1].Membership__c);
        System.assertEquals(registrations[0].Id, membershipMTMs[0].Registration__c);
        System.assertEquals(registrations[0].Id, membershipMTMs[1].Registration__c);
        
        //for2nd registration
        System.assertEquals(memberships[0].Id, membershipMTMs[2].Membership__c);
        System.assertEquals(memberships[1].Id, membershipMTMs[3].Membership__c);
        System.assertEquals(registrations[2].Id, membershipMTMs[2].Registration__c);
        System.assertEquals(registrations[2].Id, membershipMTMs[3].Registration__c);
        
    }
    
    //Added by Saurabh Kumar - 10/30/2020 - CR-20200821-14454
    //Modified By - Neha Sharma -04/08/2021 - CR-20210324-15020 - More robust unit tests for MRS 2.0
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testCreateRegistrationsForChildEABEvents(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //To by pass all trigger
        util.bypassAllTriggers = true;
        //To hold contact records
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(false));
        contacts.add(testUtilities.CreateNewContact(false));
        insert contacts;
        
        List<Advisory_Event__c> childEABEvents = [SELECT ID, Mirror_Registrations__c, Event_Type__c, Parent_Event__c 
                                                  FROM Advisory_Event__c WHERE Parent_Event__c != null];
        
        //To update Mirror Registrations with EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT on Child EAB Event
        childEABEvents[0].Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        eabEvents.add(childEABEvents[0]);
        eabEvents.add(new Advisory_Event__c(Id = childEABEvents[0].Parent_Event__c, Approval_Required__c = true, Status__c = 'Open - Registration', Zoom_Type__c = 'Webinar', Zoom_Meeting_ID__c = '000-000-1111'));
        update eabEvents;
        
        util.bypassAllTriggers = false;
        
        Test.startTest();
        
        //Create the new Registration record
        Registration__c regForParentEvent = new Registration__c();
        regForParentEvent.Contact__c = contacts[0].Id;
        regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert regForParentEvent;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        List<Registration__c> regsCreatedForEachChildEABEvents = [SELECT ID FROM Registration__c 
                                                                  WHERE EAB_Event__c =: childEABEvents[0].Parent_Event__c];
        
        //Assert for registartion records for Child EAB Events
        System.assertEquals(1, regsCreatedForEachChildEABEvents.size());
        
        //get registration for child event
        List<Registration__c> regForChildEABEvents = [SELECT ID,Parent_Registration__c,EAB_Event__c,Duplicate_Matching__c,Automated_Update__c
        					      FROM Registration__c 
                                                      WHERE Parent_Registration__c =: regForParentEvent.Id And EAB_Event__c =: childEABEvents[0].Id ];
						      
        //Assert for registartion records for Child EAB Events
        System.assertEquals(1, regForChildEABEvents.size());
        System.assertEquals(regForParentEvent.Id, regForChildEABEvents[0].Parent_Registration__c);
        System.assertEquals(childEABEvents[0].Id, regForChildEABEvents[0].EAB_Event__c);
        System.assertEquals(regForParentEvent.Contact__c + '-' + childEABEvents[0].Id, regForChildEABEvents[0].Duplicate_Matching__c);
        System.assertEquals(false, regForChildEABEvents[0].Automated_Update__c);
        
        //create new registration on child event
        Registration__c regForChildEvent = new Registration__c();
        regForChildEvent.Contact__c = contacts[1].Id;
        regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
        
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert regForChildEvent;
        
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        //get registration for child event
        List<Registration__c> newRegForChildEABEvents = [SELECT ID,Parent_Registration__c,EAB_Event__c,Duplicate_Matching__c,Automated_Update__c
        						 FROM Registration__c 
                                                         WHERE Parent_Registration__c =: regForChildEvent.Id And EAB_Event__c =: childEABEvents[0].Id ];
        //Assert for registartion records for Child EAB Events
        System.assertEquals(0, newRegForChildEABEvents.size());
        
        Test.stopTest();
    }
    
    //Created By - Neha Sharma -04/08/2021 - CR-20210324-15020 - More robust unit tests for MRS 2.0
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testCreateRegistrationsForChildEABEventsV3(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
       
        //To by pass all trigger
        util.bypassAllTriggers = true;
        //To hold contact records
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(false));
        contacts.add(testUtilities.CreateNewContact(false));
        insert contacts;
        
        List<Advisory_Event__c> childEABEvents = [SELECT ID, Mirror_Registrations__c, Event_Type__c, Parent_Event__c 
                                                  FROM Advisory_Event__c WHERE Parent_Event__c != null];
        
        //To update Mirror Registrations with EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT on Child EAB Event
        childEABEvents[0].Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        eabEvents.add(childEABEvents[0]);
        eabEvents.add(new Advisory_Event__c(Id = childEABEvents[0].Parent_Event__c, Approval_Required__c = true, Status__c = 'Open - Registration', Zoom_Type__c = 'Webinar', Zoom_Meeting_ID__c = '000-000-1111'));
        update eabEvents;
        
        util.bypassAllTriggers = false;
        
        Test.startTest();
        
        //Create the new Registration record on Parent
        Registration__c regForParentEvent1 = new Registration__c();
        regForParentEvent1.Contact__c = contacts[1].Id;
        regForParentEvent1.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert regForParentEvent1;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        //get registration for child event
        List<Registration__c> newRegForChildEABEvents = [SELECT ID FROM Registration__c 
                                   WHERE Parent_Registration__c =: regForParentEvent1.Id And EAB_Event__c =: childEABEvents[0].Id ];
        //Assert for registartion records for Child EAB Events
        System.assertEquals(0, newRegForChildEABEvents.size());
        
        Test.stopTest();
    }
    
    //Modified By - Neha Sharma - 04/19/2021 - CR-20210324-15023
    //Added by Saurabh Kumar - 10/30/2020 - CR-20200821-14454
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testValidateRegistrations(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //To by pass all trigger
        util.bypassAllTriggers = true;
        
        //To hold account records
        Account account = [SELECT Id FROM Account];
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        Contact cont = TestUtilities.CreateNewContact(account, false);
        cont.RecordTypeId = Constants.CONTACT_RECORD_TYPE_ID_EMPLOYEE;
        contacts.add(cont);
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        
        insert contacts;
        
        //To hold child EAB Event records
        List<Advisory_Event__c> childEABEvents = [SELECT ID, Mirror_Registrations__c, Parent_Event__c FROM Advisory_Event__c WHERE Parent_Event__c != null];
        
        //To update Mirror Registrations with EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT on Child EAB Event
        childEABEvents[0].Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        update childEABEvents[0];
        
        Test.startTest();
        util.bypassAllTriggers = false;
        
        //Create the new Registration record for child EAB Event
        List<Registration__c> registrations = new List<Registration__c>();
        Registration__c regForChildEvent = new Registration__c();
        regForChildEvent.Contact__c = contacts[0].Id;
        regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
        registrations.add(regForChildEvent);
        
        regForChildEvent = new Registration__c();
        regForChildEvent.Contact__c = contacts[1].Id;
        regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
        registrations.add(regForChildEvent);
        
        regForChildEvent = new Registration__c();
        regForChildEvent.Contact__c = contacts[2].Id;
        regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
        registrations.add(regForChildEvent);
        
        regForChildEvent = new Registration__c();
        regForChildEvent.Contact__c = contacts[3].Id;
        regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
        registrations.add(regForChildEvent);
        
        try{
            //try to insert registrations whose associated contact is not registered on Parent Event           
            insert registrations;
        }
        catch(Exception e){
            
            //If Parent EAB Event does not have registration record then throw error
            System.assertEquals(true, e.getMessage().contains(Label.ERROR_CONTACT_NOT_ELIGIBLE_FOR_REGISTRATION));
        } 
        
        try{
            //To by pass all trigger
            util.bypassAllTriggers = true;
            
            //create contacts whose registration is not created yet
            cont = TestUtilities.CreateNewContact(account, true);
            
            //create registration on Parent Event but contact registartion is not exist on child event
            Registration__c regForParentEvent = new Registration__c();
            regForParentEvent.Contact__c = cont.Id;
            regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
            insert regForParentEvent;
            
            //stop bypass trigger
            util.bypassAllTriggers = false;
                        
            //insert registration
            Insert registrations;
            
        }
        catch(Exception e){
            
            //If Parent EAB Event have registration record but different contact then throw error
            System.assertEquals(true, e.getMessage().contains(Label.ERROR_CONTACT_NOT_ELIGIBLE_FOR_REGISTRATION));
            
        }
        
        try{
            //To by pass all trigger
            util.bypassAllTriggers = true;
            
            //create employee type contacts
            List<Contact> employeeContacts = new List<Contact>();
            cont = TestUtilities.CreateNewContact(account, false);
            cont.RecordTypeId = Constants.CONTACT_RECORD_TYPE_ID_EMPLOYEE;
            employeeContacts.add(cont);
            
            cont = TestUtilities.CreateNewContact(account, false);
            cont.RecordTypeId = Constants.CONTACT_RECORD_TYPE_ID_EMPLOYEE;
            employeeContacts.add(cont);
            
            //insert contact
            insert employeeContacts;
            
            //stop bypass trigger
            util.bypassAllTriggers = false;
            
            //create registartion on child event for employees
            List<Registration__c> internalAttendeeRegistrations = new List<Registration__c>();
            regForChildEvent = new Registration__c();
            regForChildEvent.Contact__c = employeeContacts[0].Id;
            regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
            regForChildEvent.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE;
            internalAttendeeRegistrations.add(regForChildEvent);
            
            regForChildEvent = new Registration__c();
            regForChildEvent.Contact__c = employeeContacts[1].Id;
            regForChildEvent.EAB_Event__c = childEABEvents[0].Id;
            regForChildEvent.RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE;
            internalAttendeeRegistrations.add(regForChildEvent);
            
            //insert registration
            Insert regForChildEvent;
                        
            
        }
        catch(Exception e){
            
            //if registration associated contact is employee then no error will going to throw
            System.assertEquals(null, e.getMessage());
        } 
        
        //To by pass all trigger
        util.bypassAllTriggers = true;
        
        //If Parent EAB Event does not have registration record then throw error
        //To resolved this we create registration record for Parent EAB Event 
        //record for same contact to resolved all type of exceptions
        List<Registration__c> registrationsForParentEvent = new List<Registration__c>();
        Registration__c regForParentEvent = new Registration__c();
        regForParentEvent.Contact__c = contacts[0].Id;
        regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        registrationsForParentEvent.add(regForParentEvent);
        
        regForParentEvent = new Registration__c();
        regForParentEvent.Contact__c = contacts[1].Id;
        regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        registrationsForParentEvent.add(regForParentEvent);
        
        regForParentEvent = new Registration__c();
        regForParentEvent.Contact__c = contacts[2].Id;
        regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        registrationsForParentEvent.add(regForParentEvent);
        
        regForParentEvent = new Registration__c();
        regForParentEvent.Contact__c = contacts[3].Id;
        regForParentEvent.EAB_Event__c = childEABEvents[0].Parent_Event__c;
        registrationsForParentEvent.add(regForParentEvent);
        insert registrationsForParentEvent;
        
        util.bypassAllTriggers = false;
        
        //Create the another new Registration record for child EAB Event
        Insert registrations;
        
        Test.stopTest();
    }
    
    //Modified By - Neha Sharma - 04/09/2021 - CR-20210324-15020 - More robust unit tests for MRS 2.0
    //Added by Saurabh Kumar - 10/26/2020 - CR-20200821-14454
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testPopulateStatusAndApprovalReason(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //To by pass all trigger
        util.bypassAllTriggers = true;
        //To hold account records
        Account account = [SELECT ID FROM Account];
        //To hold contact records
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        contacts.add(TestUtilities.CreateNewContact(account, false));
        
        insert contacts;
        
        //To hold child EAB Event records
        List<Advisory_Event__c> eaBEvents = [SELECT ID FROM Advisory_Event__c];
        
        //create campaigns
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        Campaign camp2 = new Campaign(Name = 'Test Campaign 2', IsActive = True);
        insert new List<Campaign>{camp1,camp2};
        
        //create campaign members
        CampaignMember testCampMemb1 = new CampaignMember();
        testCampMemb1.CampaignId = camp1.Id;
        testCampMemb1.ContactId = contacts[0].Id;
        testCampMemb1.Status = 'Sent';
        insert testCampMemb1;
        
        CampaignMember testCampMemb2 = new CampaignMember();
        testCampMemb2.CampaignId = camp2.Id;
        testCampMemb2.ContactId = contacts[0].Id;
        testCampMemb2.Status = 'Sent';
        insert testCampMemb2;
        
        Test.startTest();
        
        //To update Invite List with Campaign Id on EAB Event
        eaBEvents[0].Invite_List__c  = camp1.Id;
        eaBEvents[0].Approval_Required__c = true;
        eaBEvents[0].Cap_Per_Institution__c =3.0;
        eaBEvents[0].Institution__c = account.Id;
        
        //Modified by Saurabh Kumar - 11/11/2020 - CR-20200821-14454 - Added Status 'Open - Waitlist Only' On EAB Event(Registration is allowed to save for this EAB Event's Status)
        eaBEvents[0].Status__c = 'Open - Waitlist Only';
        update eaBEvents[0];
        
        //To by pass all trigger
        util.bypassAllTriggers = false;
        
        //create registrations
        Registration__c registration1 = new Registration__c();
        registration1.Contact__c = contacts[0].Id;
        registration1.EAB_Event__c = eaBEvents[0].Id;
        registration1.Origin__c = Constants.REGISTRATION_ORIGIN_SALESFORCE;
        
        Registration__c registration2 = new Registration__c();
        registration2.Contact__c = contacts[1].Id;
        registration2.EAB_Event__c = eaBEvents[0].Id;
        registration2.Origin__c = Constants.REGISTRATION_ORIGIN_SALESFORCE;
        
        Registration__c registration3 = new Registration__c();
        registration3.Contact__c = contacts[2].Id;
        registration3.EAB_Event__c = eaBEvents[0].Id;
        registration3.Origin__c = Constants.REGISTRATION_ORIGIN_SALESFORCE;
        
        Registration__c registration4 = new Registration__c();
        registration4.Contact__c = contacts[3].Id;
        registration4.EAB_Event__c = eaBEvents[0].Id;
        registration4.Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM;
        
        Registration__c registration5 = new Registration__c();
        registration5.Contact__c = contacts[4].Id;
        registration5.EAB_Event__c = eaBEvents[0].Id;
        registration5.Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM;
                
        List<Registration__c> registartions = new List<Registration__c>{registration1,registration2,registration3,registration4,registration5};
        INSERT registartions;

        registartions = [Select Id, Origin__c,Status__c From Registration__c Where Id IN: registartions];
        
        //assert for origin
        System.assertEquals(Constants.REGISTRATION_ORIGIN_SALESFORCE, registartions[0].Origin__c);
        
        //update registration origin
        registration4.Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM;
        registration5.Origin__c = Constants.REGISTRATION_ORIGIN_EAB_DOT_COM;
        
        Update new List<Registration__c>{registration4,registration5};
        
        registartions = [Select Id, Origin__c,Status__c From Registration__c Where Id IN: registartions];
        //check origin is EAB.com
        System.assertEquals(Constants.REGISTRATION_ORIGIN_EAB_DOT_COM, registartions[3].Origin__c);
        
        ///assert on Status
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTERED, registartions[0].Status__c); //already in invite list
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED, registartions[1].Status__c);//Origin is Salesforce but not in invite list 
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED, registartions[3].Status__c);//Origin is Eab.com but not in invite list
        
        Test.stopTest();
    }
    
    //Added by Saurabh Kumar - 10/30/2020 - CR-20200821-14454
    //Modified by Saurabh Kumar - 04/08/2021 - CR-20210324-15021
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testPopulateCampaignMemberRegistrationField(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        Util.BypassAllTriggers = true;
        
         Account account1 = [SELECT Id FROM Account LIMIT 1];
        
        // Create contacts 
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(testUtilities.CreateNewContact(account1,false));
        contacts.add(testUtilities.CreateNewContact(account1,false));
        contacts.add(testUtilities.CreateNewContact(account1,false));
        contacts.add(testUtilities.CreateNewContact(account1,false));
        contacts.add(testUtilities.CreateNewContact(account1,false));
        
        insert contacts;
        
         Id recordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        
        //Create two campaigns
        List<Campaign> campaigns = new List<Campaign>();
        campaigns.add(new Campaign(Name = ' test campaign', IsActive = True, CampaignMemberRecordTypeId = recordTypeId));
        Util.bypassEntityPopulation = true;
        insert campaigns;
        Util.bypassEntityPopulation = false;
        // create three campaign members under above campaign
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
                
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[0].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[1].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[2].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[3].Id, Status = 'Registered'));

        insert campaignMembers;
        
        // create two EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Invite_List__c = campaigns[0].Id;
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Invite_List__c = campaigns[0].Id;
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        List<Registration__c> registrations = new List<Registration__c>();
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id));
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[1].Id));
        registrations.add(new Registration__c(Contact__c = contacts[3].Id, EAB_Event__c = eabEvents[1].Id));
        registrations.add(new Registration__c(Contact__c = contacts[4].Id, EAB_Event__c = eabEvents[0].Id));
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        insert registrations;
        RegistrationHelper.bypassRegistrationDLRS = false;
        
        List<CampaignMember> updatedCampaignMembers = [SELECT Id, Registration__c FROM CampaignMember WHERE CampaignId = :campaigns[0].Id];
        
        // campaign member whose contact not matched to any of registration
        System.assertEquals(null, updatedCampaignMembers[0].Registration__c);
        // assert to check populated registrations 
        System.assertEquals(registrations[0].Id, updatedCampaignMembers[1].Registration__c);
        System.assertEquals(registrations[1].Id, updatedCampaignMembers[2].Registration__c);
        System.assertEquals(registrations[2].Id, updatedCampaignMembers[3].Registration__c);
        
        // cover related methods by creating campaign member
       
        CampaignMember cmp1 =  new CampaignMember(CampaignId = campaigns[0].Id, ContactId = contacts[4].Id, Status = 'Sent');
        insert cmp1;
        
        // query populated campaign member beacause registration of this contact already exist.
        CampaignMember populatedCmp = [SELECT Id, Registration__c FROM CampaignMember WHERE Id = :cmp1.Id];
        
        // assert to check that correct registration__c id is populated
        System.assertEquals(registrations[3].Id, populatedCmp.Registration__c); 
        
        Test.stopTest(); 
    }

    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testProcessWebhookException() {
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);

        util.bypassAllTriggers = true;
        //update the eab event with zoom info
        Advisory_Event__c eSeries = [SELECT Id FROM Advisory_Event__c Limit 1];
        eSeries.Zoom_Meeting_ID__c = zoomMeetingId;
        eSeries.Zoom_Type__c = 'Meeting';
        update eSeries;
        
        ZoomEventWrapper zWrapper = new ZoomEventWrapper();
        zWrapper.payload = new ZoomEventWrapper.cls_payload();
        zWrapper.payload.cls_object = new ZoomEventWrapper.cls_object();
        zWrapper.payload.cls_object.id = zoomMeetingId;
        ZoomWebhooks.processWebhook(zWrapper);
        List<Web_Service_Log__c> wsls = [SELECT Id FROM Web_Service_Log__c WHERE EAB_Event__c = :eSeries.id];
        system.assertEquals(1, wsls.size());
    }
    
    //Created by Saurabh Kumar - 02/23/2021 - CR-20210217-14921: There are scenarios where cohort registrants are added after a cohort launches.  We need to be able to add people to the cohort level and just exclude events where the earlier ones are closed - completed.
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    //Modified by - Chirag soni - 10/19/2021 - CR-20210628-15254 - Test class issue fixes  - Moved the stop test 
    static testMethod void testCreateRegistrationsForChildEABEventsV2(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
       
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile analystProfile = [SELECT Id FROM Profile WHERE Name = 'Analyst'];
        User analystUser = testUtilities.CreateNewUser(analystProfile, true);
        
        //Get SysAdmin Profile Id
        List<Profile> sysProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Need to run insert of permission set as SystemRunAs due to mixed dml error
        User adminUser = [SELECT Id FROM User WHERE ProfileId = :sysProfile[0].Id AND IsActive = True LIMIT 1];
        
        System.runAs(adminUser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Advisory_Event_Manager'];
            insert new PermissionSetAssignment(AssigneeId = analystUser.Id, PermissionSetId = ps.Id);
        }
        
        Advisory_Event__c cohortEvent = [Select Id, Status__c From Advisory_Event__c Where RecordTypeId =: Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT LIMIT 1];
        cohortEvent.Event_Type__c = 'Research Working Sessions';
        cohortEvent.Public_Name__c = 'Cohort';
	cohortEvent.Short_Name__c = 'Cohort';
	cohortEvent.Status__c = 'Open - Waitlist Only';
        cohortEvent.Begins__c = System.today();
	cohortEvent.Ends__c = System.today();
        update cohortEvent;
        
        Advisory_Event__c closedEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        closedEvent.Parent_Event__c = cohortEvent.Id;
        closedEvent.Event_Type__c = 'Research Working Sessions';
        closedEvent.Public_Name__c = 'Closed Event';
        closedEvent.Short_Name__c = 'Closed Event';
        closedEvent.Status__c = 'Closed - Completed';
        closedEvent.Begins__c = System.today();
        closedEvent.Ends__c = System.today();
        closedEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        
        Advisory_Event__c restrictedRegistrationEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        restrictedRegistrationEvent.Parent_Event__c = cohortEvent.Id;
        restrictedRegistrationEvent.Event_Type__c = 'Research Working Sessions';
        restrictedRegistrationEvent.Public_Name__c = 'Open';
        restrictedRegistrationEvent.Short_Name__c = 'Open';
        restrictedRegistrationEvent.Status__c = 'Open - Registration Restricted';
        restrictedRegistrationEvent.Begins__c = System.today();
        restrictedRegistrationEvent.Ends__c = System.today();
        restrictedRegistrationEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Added new Advisory child Event - From Here 
        Advisory_Event__c elevatedMealEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        elevatedMealEvent.Parent_Event__c = cohortEvent.Id;
        elevatedMealEvent.Event_Type__c = 'Research Working Sessions';
        elevatedMealEvent.Public_Name__c = 'Test Elevated Meal Event';
        elevatedMealEvent.Short_Name__c = 'Test Elevated Meal Event';
        elevatedMealEvent.Status__c = 'Open - Registration';
        elevatedMealEvent.Begins__c = System.today();
        elevatedMealEvent.Ends__c = System.today();
        elevatedMealEvent.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;
        elevatedMealEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Added new Advisory child Event - Till Here
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>{closedEvent,restrictedRegistrationEvent, elevatedMealEvent};
        insert eabEvents;
        
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Moved the contact record inside the byPass flag -  test class issue fixes - From Here
        //create new contact
        Contact con = testUtilities.CreateNewContact(true);
        
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(cohortEvent.Id, con.Id, false);
        reg.Status__c = 'Waitlist';
        reg.Origin__c = 'Salesforce';
        
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Moved the contact record inside the byPass flag -  test class issue fixes - Till Here
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        //insert registration
        insert reg;
        
        List<Registration__c> registrations = [Select Id, EAB_Event__c, Status__c, Origin__c From Registration__c Where EAB_Event__c =: cohortEvent.Id];
        System.assertEquals('Waitlist', registrations[0].Status__c);
        
        registrations = [Select Id, EAB_Event__c, Status__c, Origin__c From Registration__c Where EAB_Event__c =: closedEvent.Id];
        System.assertEquals(0, registrations.size(), 'No registration should have been created for this closed event');
        
        registrations = [Select Id, EAB_Event__c, Status__c, Origin__c From Registration__c Where EAB_Event__c =: restrictedRegistrationEvent.Id];
        System.assertEquals('Waitlist', registrations[0].Status__c);
		 
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Added assert for record type check
        registrations = [Select Id, EAB_Event__c, RecordTypeId From Registration__c Where EAB_Event__c =: elevatedMealEvent.Id];
        System.assertEquals(Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL, registrations[0].RecordTypeId);
        //Added by - Chirag Soni - CR-20210511-15137 - 11/01/2021 - Added assert for record type check
        
        //Test stop here
        Test.stopTest(); 
    }
    
    //Created by - Neha Sharma - 04/05/2021 - CR-20210324-15020
    //Modified By -  Chirag Soni - 08/04/2021 - Used the Contants variable and test class issue fixes
    //Modified by - Chirag soni - 10/19/2021 - CR-20210628-15254 - Test class issue fixes - moved the stop test
    static testMethod void testUpdateRelatedRegistrationStatus(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //bypass triggers
        Util.BypassAllTriggers = true;
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;

        //create Events
        Advisory_Event__c eabEvent1 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent1.Event_Type__c = 'Research Working Sessions';
        eabEvent1.Public_Name__c = 'Test1';
        eabEvent1.Short_Name__c = 'Test1';
        //Modified By -  Chirag Soni - 08/04/2021 - Used the Contants variable
        eabEvent1.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent1.Begins__c = System.today();
        eabEvent1.Ends__c = System.today().addDays(1);
        insert eabEvent1;
                
        //create child event
        Advisory_Event__c childEabEvent1 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEabEvent1.Event_Type__c = 'Research Working Sessions';
        childEabEvent1.Public_Name__c = 'Test2';
        childEabEvent1.Short_Name__c = 'Test2';
        childEabEvent1.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        childEabEvent1.Begins__c = System.today();
        childEabEvent1.Ends__c = System.today();
        childEabEvent1.Parent_Event__c = eabEvent1.Id;
        childEabEvent1.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        
        Advisory_Event__c childEabEvent2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEabEvent2.Event_Type__c = 'Research Working Sessions';
        childEabEvent2.Public_Name__c = 'Test2';
        childEabEvent2.Short_Name__c = 'Test2';
        childEabEvent2.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        childEabEvent2.Begins__c = System.today().addDays(1);
        childEabEvent2.Ends__c = System.today().addDays(1);
        childEabEvent2.Parent_Event__c = eabEvent1.Id;
        childEabEvent2.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_INHERIT_ALL_FROM_PARENT;
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>{childEabEvent1, childEabEvent2};
        insert eabEvents;

        //create contact
        //Modified By - Chirag Soni - 08/04/2021 - test class issue fixes
        Contact con1 = testUtilities.CreateNewContact(true);
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        List<Registration__c> registrations = new List<Registration__c>();
        //create registration
        registrations.add(new Registration__c(EAB_Event__c = eabEvent1.Id, Contact__c = con1.Id, 
                                               Origin__c = Constants.REGISTRATION_ORIGIN_SALESFORCE));
        
        insert registrations;
        
        //get updated status
        List<Registration__c> childRegistration = [Select Id, Status__c From Registration__c Where Parent_Registration__c IN: registrations];
        
        //Assert to check all child event registration status is equals to parent Event registration status when contact is same on all
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED, childRegistration[0].Status__c);
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTRATION_REQUESTED, childRegistration[1].Status__c);
        
        registrations[0].Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
        RegistrationHelper.updateRelatedRegistrationStatus(registrations,null);
        
        //get updated status
        childRegistration = [Select Id, Status__c From Registration__c Where Parent_Registration__c IN: registrations limit 2];
                   
        //Assert to check all child event registration status is equals to parent Event registration status when contact is same on all
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTERED, childRegistration[0].Status__c);
        System.assertEquals(Constants.REGISTRATION_STATUS_REGISTERED, childRegistration[1].Status__c);
        
        Test.stopTest(); 
    }
    
    
    //Added by Saurabh Kumar - 04/06/2021 - CR-20210324-15021 - More robust unit tests for MRS 2.0
    //Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    //Modified by - Chirag soni - 10/19/2021 - CR-20210628-15254 - Test class issue fixes
    static testMethod void testPopulateIsOnInviteList() {
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
       
        //bypass trigger
        Util.ByPassAllTriggers = true;
        
        //get an account
        Account account1 = [SELECT Id FROM Account LIMIT 1];
        
        // Create contacts 
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(testUtilities.CreateNewContact(account1, false));
        contacts.add(testUtilities.CreateNewContact(account1, false));
        contacts.add(testUtilities.CreateNewContact(account1, false));
        
        insert contacts;
        //get Event Invite List Member RT id
        Id recordTypeId = Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        
        // create a campaign
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', IsActive = True, CampaignMemberRecordTypeId = recordTypeId);
        Util.bypassEntityPopulation = true; 
        insert campaign;
        Util.bypassEntityPopulation = false;
        
        // create campaign members under above campaign
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        
        campaignMembers.add(new CampaignMember(CampaignId =campaign.Id, ContactId = contacts[1].Id, Status = 'Registered'));
        campaignMembers.add(new CampaignMember(CampaignId = campaign.Id, ContactId = contacts[2].Id, Status = 'Registered'));
        
        insert campaignMembers;
        
        // create EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Invite_List__c = campaign.Id;
        eabEvents.add(cohortEvent);
        
        //Modified by - Chirag Soni - CR-20210628-15254 - Modified the event variable 
        Advisory_Event__c cohortEvent1 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Invite_List__c = campaign.Id;
        eabEvents.add(cohortEvent1);
        
        insert eabEvents;
        
        Util.ByPassAllTriggers = false;
        
        Test.startTest();
        
        //test for insertion of registration on two different EAB Events.
        List<Registration__c> registrations = new List<Registration__c>();
        //Modified by -  Chirag Soni - CR-20210628-15254 - 10/19/2021 - Test classs issue fixes - update the EABEvent ids
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id, Status__c = Constants.REGISTRATION_STATUS_REGISTERED));
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[0].Id, Status__c = Constants.REGISTRATION_STATUS_REGISTERED));
        
        //RegistrationHelper.bypassRegistrationDLRS = true;
        insert registrations;
        
        //RegistrationHelper.bypassRegistrationDLRS = false;
        
        List<Registration__c> insertedRegistrations = [SELECT Id, Is_On_Invite_List__c FROM Registration__c WHERE Id IN :registrations];
        
        // Assert to check both Is On invite list in insertion case where one contact of registration is already exist in campaign member
        //Modified by -  Chirag Soni - CR-20210628-15254 - 10/19/2021 - Test classs issue fixes
        System.assertEquals('Yes', insertedRegistrations[0].Is_On_Invite_List__c);
        System.assertEquals('Yes', insertedRegistrations[1].Is_On_Invite_List__c);
        
        // update registration with contact 2 
        //Modified by -  Chirag Soni - CR-20210628-15254 - 10/19/2021 - Test classs issue fixes - update the contact Id
        Registration__c registration = new Registration__c(Id = insertedRegistrations[0].Id, Contact__c = contacts[0].Id);
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        update registration; 
        RegistrationHelper.bypassRegistrationDLRS = false;    
        
        Registration__c updatedRegistration = [SELECT Id, Is_On_Invite_List__c FROM Registration__c WHERE Id = :registration.Id];
        
        //Modified by -  Chirag Soni - CR-20210628-15254 - 10/19/2021 - Test classs issue fixes
        // assert to check updated registration whose contact linked to campaign member
        System.assertEquals('No', updatedRegistration.Is_On_Invite_List__c);
        
        // update with EAB Event with no invite list and update registration to check value of Is on Invite list
        Util.BypassAllTriggers = true;
        update new Advisory_Event__c(Id = eabEvents[0].Id, Invite_List__c = null);
        Util.BypassAllTriggers = false;
        
        // update registration with contact 1 
        Registration__c registration1= new Registration__c(Id = insertedRegistrations[0].Id, Contact__c = contacts[1].Id);
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        update registration1; 
        RegistrationHelper.bypassRegistrationDLRS = false;
        
        Registration__c registrationUpdated = [SELECT Id, Is_On_Invite_List__c FROM Registration__c WHERE Id = :registration1.Id];
        
        // assert to check updated registration whose contact linked to campaign member
        System.assertEquals(null , registrationUpdated.Is_On_Invite_List__c);
        
        //update invite list with campaign id 
        Util.BypassAllTriggers = true;
        update new Advisory_Event__c(Id = eabEvents[0].Id, Invite_List__c = campaign.Id);
        Util.BypassAllTriggers = false;
        
        // update registration's other field instead of contact and EAB Event where registration's contact is matched to campaign member's contact
        Registration__c registration2= new Registration__c(Id = insertedRegistrations[0].Id, Status__c = Constants.REGISTRATION_STATUS_REGISTERED);
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        update registration2; 
        RegistrationHelper.bypassRegistrationDLRS = false;
        
        Registration__c registrationSecondUpdated = [SELECT Id, Is_On_Invite_List__c FROM Registration__c WHERE Id = :registration1.Id];
        
        // both the contacts matched after updating invite list of EAB Event but registration's other field is updated instead of contact and EAB EVENT
        // assert to check updated registration whose contact linked to campaign member
        System.assertEquals(null , registrationSecondUpdated.Is_On_Invite_List__c);
        
        Test.stopTest();
    }
    
    // Created by - Saurabh Kumar - 03/31/2021 - CR-20201116-14696
    static testMethod void testCreateAndPopulateCampaignMemberStatus(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        Util.BypassAllTriggers = true;
        //Create the new account record
        Account account = [Select Id From Account];
        
        //Create two new contact record
        Contact contact = testUtilities.CreateNewContact(account, false);
        insert contact;
        
        //Create two new contact record
        Contact contact2 = testUtilities.CreateNewContact(account, false);
        insert contact2;
        
        // Create campaign Record of Marketo record type
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketo').getRecordTypeId();
        
        Campaign marketoCampaign = new Campaign(Name = 'Marketo Campaign', 
                                                Status = 'Planned', 
                                                Type = 'Event',
                                                Subtype__c = 'Conference',
                                                RecordTypeId = recordTypeId);
        insert marketoCampaign;
        
        
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Marketo_Campaign__c = marketoCampaign.id;
        insert cohortEvent;
        
        Util.BypassAllTriggers = false;
        test.startTest();
        
        // Create two registration on cohortEvent with different status 
        List<Registration__c> testRegistrations = new List<Registration__c>();
        testRegistrations.add(new Registration__c(Contact__c = contact.id, EAB_Event__c = cohortEvent.id, Status__c ='Registered'));
        testRegistrations.add(new Registration__c(Contact__c = contact2.id, EAB_Event__c = cohortEvent.id, Status__c ='No Show'));
        insert  testRegistrations;
        
        // Query Campaign members on marketo campaign and check whether two campaign member created or not
        List<CampaignMember> listofCampaignMember = [SELECT Id, Status, Registration__c, ContactId
                                                     FROM CampaignMember WHERE CampaignId = :marketoCampaign.id];
        
        // assert to check created campaign member where status is same as registration status 
        System.assertEquals('No Show', listofCampaignMember[0].Status);
        System.assertEquals('Registered', listofCampaignMember[1].Status);
        
        // assert to check whether campaign member is created with same contact as created in registration 
        System.assertEquals(contact2.id,  listofCampaignMember[0].ContactId);
        System.assertEquals(contact.id,  listofCampaignMember[1].ContactId);
        
        // update status of one registration and again check whether that campaign member status is updated or not.
        Registration__c updatedRegistration = new Registration__c(Id = testRegistrations[1].Id, Status__c = 'Attended');
        update updatedRegistration;
        
        List<CampaignMember> updatedCampaignMember = [SELECT Id, Status, Registration__c, ContactId
                                                      FROM CampaignMember WHERE CampaignId = :marketoCampaign.id];
        
        //check contact & updated status of campaign member after registration status is updated
        System.assertEquals(contact2.id, updatedCampaignMember[0].ContactId);
        System.assertEquals(contact.id,  updatedCampaignMember[1].ContactId);
          
        System.assertEquals('Attended', updatedCampaignMember[0].Status);
        System.assertEquals('Registered', updatedCampaignMember[1].Status);
        test.stopTest();
    }
    
    //Added by Saurabh Kumar - 04/07/2021 - CR-20210324-15021
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testPopulatePartnerStatus(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
       
        //Bypass trigger
        Util.BypassAllTriggers = true;
        
        
        //Create the new account record
        List<Account> accounts = new List<Account>();
        accounts.add(TestUtilities.CreateNewAccount(false));
        accounts.add(TestUtilities.CreateNewAccount(false));
        accounts.add(TestUtilities.CreateNewAccount(false));
        
        insert accounts;
        
        // Create contacts 
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[1], false));
        contacts.add(testUtilities.CreateNewContact(accounts[1], false)); 
        contacts.add(testUtilities.CreateNewContact(accounts[2], false)); 
        
        insert contacts;
        
        // create four programs 
        List<Program__c> programs = new List<Program__c>();
        programs.add(new Program__c(Name = 'Test Program1', Program_Acronym__c = 'TEST1'));
        programs.add(new Program__c(Name = 'Test Program2', Program_Acronym__c = 'TEST2'));
        programs.add(new Program__c(Name = 'Test Program3', Program_Acronym__c = 'TEST3'));
        programs.add(new Program__c(Name = 'Test Program4', Program_Acronym__c = 'TEST4'));
        insert programs;
        
        //Create the new Membership records
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership 1', Account_Name__c = accounts[0].Id,
                                          Program__c = programs[0].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 2', Account_Name__c = accounts[0].Id,
                                          Program__c = programs[1].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 3', Account_Name__c = accounts[1].Id,
                                          Program__c = programs[2].Id, Membership_Status_Text__c = 'Member -Payer'));
        memberships.add(new Membership__c(Name = 'Test Membership 4', Account_Name__c = accounts[1].Id,
                                          Program__c = programs[3].Id, Membership_Status_Text__c = 'Member -Payer'));
        
        insert memberships;
        
        // create two EAB events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = programs[1].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Primary_Program__c  = programs[1].Id;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
        // create rules
        List<Rule__c> rules = new List<Rule__c>();
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[0].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[1].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[2].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[0].Id, Program__c = programs[3].Id));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[0].Id, Primary__c = true));
        rules.add(new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[1].Id));
        
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS = false;
        insert rules;
        RuleTriggerHelper.EXECUTE_RULE_UNIQUENESS = true;
        Test.startTest();
        
        User userA = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];
        Id assigneeId = userInfo.getUserId();
        System.runAs(userA) {
            
            PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
            
            PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = assigneeId , PermissionSetId = ps.Id);
            insert assignPS;  
        } 
        
        Util.BypassAllTriggers = false;
        
       
        
        List<Registration__c> registrations = new List<Registration__c>();
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        registrations.add(new Registration__c(Contact__c = contacts[3].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        registrations.add(new Registration__c(Contact__c = contacts[4].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        RegistrationHelper.bypassRegistrationDLRS = false;
        
        List<Registration__c> insertedRegistrations = [SELECT Id, Contact__c, EAB_Event__c,  Partner_Status__c FROM Registration__c WHERE Id IN :registrations];
        
        // Assert for registrations partner status
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, insertedRegistrations[0].Partner_Status__c); 
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, insertedRegistrations[1].Partner_Status__c);
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, insertedRegistrations[2].Partner_Status__c); 
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, insertedRegistrations[3].Partner_Status__c);
        
        // registration whose contact's institute does not have any active membership associated with program so value will be default prospect 
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, insertedRegistrations[4].Partner_Status__c);
        
        // update registration with EAB Event 
        List<Registration__c> updateRegis = new List<Registration__c>();
        //updateRegis.add(new Registration__c (Id = registrations[0].Id, Contact__c = contacts[2].Id));
        updateRegis.add(new Registration__c(Id = registrations[2].Id ,EAB_Event__c = eabEvents[1].Id));
        updateRegis.add(new Registration__c(Id = registrations[3].Id ,EAB_Event__c = eabEvents[1].Id));
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        update updateRegis;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        List<Registration__c> updatedRegistrations = [SELECT Id, Contact__c, EAB_Event__c, Partner_Status__c FROM Registration__c WHERE Id IN :updateRegis];
        
        // Assert EAB event's registrations partner status
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, updatedRegistrations[0].Partner_Status__c); 
        System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PROSPECT, updatedRegistrations[1].Partner_Status__c);
        
        User userB = [SELECT Id FROM User WHERE Id = :userInfo.getUserId()];
        
        System.runAs(userB){
            
            Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
            system.assertEquals(true, isEABEventManager);
            
            // In order to cover related method insert a new rule  with program 3 on EAB Event 1 so that partner status will become partner from prospect on both of registrations 
            Rule__c partnerRule =  new Rule__c(Advisory_Event__c = eabEvents[1].Id, Program__c = programs[3].Id, Primary__c = true);
            insert partnerRule;
            
            List<Registration__c> partnerRegistrations = [SELECT Id, Partner_Status__c FROM Registration__c WHERE EAB_Event__c = :eabEvents[1].Id];
            
            // Assert for second EAB event's registrations partner status when inserting rule 
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, partnerRegistrations[0].Partner_Status__c); 
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, partnerRegistrations[1].Partner_Status__c);
            
        }
         Test.stopTest();
    } 
    
    //version of testPopulatePartnerStatus - Created by - Saurabh Kumar - 03/31/2021 - CR-20210224-14940/CR-20210324-15021
    static testMethod void testPopulatePartnerStatusV2(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        Util.BypassAllTriggers = true;
        //Create the new account record
        Account firstAccount = TestUtilities.CreateNewAccount(true);
        Account SecondAccount = TestUtilities.CreateNewAccount(true);
        
        //Create the new contact record
        Contact contact = testUtilities.CreateNewContact(firstAccount, false);
        insert contact;
        
        //Create the new program record
        Program__c program1 = TestUtilities.CreateNewProgram(true);
        
        //Create the new Membership record
        List<Membership__c> testMemberships = new List<Membership__c>();
        Membership__c member1 = new Membership__c(Name = 'Test Membership', Account_Name__c = SecondAccount.Id,
                                                  Program__c = program1.Id, Membership_Status_Text__c = 'Member - Payer');
        testMemberships.add(member1);
        insert testMemberships;
        
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Short_Name__c = 'EAB 1';
        eSeries.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eSeries.Primary_Program__c  = program1.Id;
        eSeries.Rules_Programs__c = 'Establish independent rules';
        
        insert eSeries;
        Test.startTest();
        
        //Create the new Registration record
        Registration__c registration = new Registration__c();
        registration.Contact__c = contact.Id;
        registration.EAB_Event__c = eSeries.Id;
        registration.Status__c = RegistrationHelper.STATUS_REGISTERED;
        insert registration;
        
        //Create the new rule record
        Rule__c rule = new Rule__c();
        rule.Advisory_Event__c = eSeries.Id;
        rule.Program__c = program1.Id;
        rule.Primary__c = true;
        
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = false;
        insert rule;
        RuleTriggerHelper.EXECUTE_RULE_TRIGGER = true; 
      
        
        User userA = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];
        Id assigneeId = userInfo.getUserId();
        System.runAs(userA) {
            
            PermissionSet ps = [SELECT Id, Label FROM PermissionSet WHERE Label = 'EAB Event Manager'];
            
            PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = assigneeId , PermissionSetId = ps.Id);
            insert assignPS;  
        }
        
        Util.BypassAllTriggers = false;
        
        User userB = [SELECT Id FROM User WHERE Id = :userInfo.getUserId()];
        
        System.runAs(userB){
            
            Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
            system.assertEquals(true, isEABEventManager);
            
            update new Contact(Id = contact.Id, AccountId = SecondAccount.Id);
            Registration__c updatedRegistration = [SELECT ID, Partner_Status__c  FROM Registration__c WHERE ID =: registration.Id];
            
            //Assert for Partner Status
            System.assertEquals(Constants.REGISTRATION_PARTNER_STATUS_PARTNER, updatedRegistration.Partner_Status__c );
            
        }      
        
        Test.stopTest();
    }
    
    // Modified by - Chirag soni - 05/12/2021 - text method CR-20201116-14696. 
    static testMethod void testPostChatterOnStatusMismatch(){ 
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        Util.BypassAllTriggers = true;
        //Create the new account record
        Account account = [Select Id From Account limit 1];
        
        //Create two new contact record
        Contact contact = testUtilities.CreateNewContact(account, false);
        insert contact;
        
        //Create two new contact record
        Contact contact2 = testUtilities.CreateNewContact(account, false);
        insert contact2;
        
        // Create campaign Record of Marketo record type
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketo').getRecordTypeId();
        
        Campaign marketoCampaign = new Campaign(Name = 'Marketo Campaign', StartDate = System.today(), EndDate = System.today().addDays(5),IsActive = true,
                                                Status = 'Planned',
                                                Type = 'Event',
                                                Subtype__c = 'Conference',
                                                RecordTypeId = recordTypeId);
        insert marketoCampaign;
        
        Delete [SELECT Id FROM CampaignMemberStatus WHERE Label = 'Attended' AND CampaignId = :marketoCampaign.Id];
        
        CampaignMemberStatus  cms = new CampaignMemberStatus (IsDefault = true, Label = 'MisMatch', HasResponded = true, CampaignId = marketoCampaign.Id);
        insert cms;
        
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Marketo_Campaign__c = marketoCampaign.id;
        cohortEvent.Event_Manager__c = usr.Id;
        insert cohortEvent;
        
        // Create two registration on cohortEvent with different status 
        List<Registration__c> testRegistrations = new List<Registration__c>();
        testRegistrations.add(new Registration__c(Contact__c = contact.id, EAB_Event__c = cohortEvent.id, Status__c ='Registration Requested'));
        testRegistrations.add(new Registration__c(Contact__c = contact2.id, EAB_Event__c = cohortEvent.id, Status__c ='Registration Requested'));
        insert  testRegistrations;
        
        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        // now update registration with some strange value which is not in campaign member status.
         List<Registration__c> registrationToBeUpdate = new List<Registration__c>();
        registrationToBeUpdate.add(new Registration__c(Id = testRegistrations[0].Id ,Contact__c = contact.id, EAB_Event__c = cohortEvent.id, Status__c ='Attended'));
        registrationToBeUpdate.add(new Registration__c(Id = testRegistrations[1].Id ,Contact__c = contact2.id, EAB_Event__c = cohortEvent.id, Status__c ='Attended'));
        update registrationToBeUpdate;
        
        // now partial attended status is not in campaignmemberstatus so campaign member's status will be updated to default value which is responded 
        // And both registration and campaign member status is mis match so it will post chatter 
        
         List<CampaignMember> updatedCampaignMember = [SELECT Id, Status, Registration__c, ContactId
                                                      FROM CampaignMember WHERE CampaignId = :marketoCampaign.id];
        
        // assert to check updated campaign member where status is not same as registration status 
        System.assertEquals('MisMatch', updatedCampaignMember[0].Status);
        System.assertEquals('MisMatch', updatedCampaignMember[1].Status);
        
        // assert to check whether campaign member is created with same contact as created in registration 
        System.assertEquals(contact.id,  updatedCampaignMember[0].ContactId);
        System.assertEquals(contact2.id,  updatedCampaignMember[1].ContactId);
        
        test.stopTest();
    }
    
    
    //Created by Neha Sharma - 04/12/2021 - CR-20210324-15022
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testPopulateInstitutionRegistrationCount(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
       
        
        //bypass triggers
        Util.BypassAllTriggers = true;
        
        //get child Event
        List<Advisory_Event__c> eabEvents = [Select Id From Advisory_Event__c WHERE Parent_Event__c != Null];
       
        //create 1 more account 
        Account acc = testUtilities.CreateNewAccount(true);
        List<Account> accounts = [Select Id From Account];
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        
        //add Employee type contact
        Contact cont = testUtilities.CreateNewContact(accounts[0], false);
        cont.RecordTypeId = Constants.CONTACT_RT_ID_EMPLOYEE;
        contacts.add(cont);
        
        contacts.add(testUtilities.CreateNewContact(accounts[1], false));
        contacts.add(testUtilities.CreateNewContact(accounts[1], false));
        
        Insert contacts;
        
        //set flag to false
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //create registrations
        Registration__c reg1 = Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[0].Id, false);
        reg1.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
        
        Registration__c reg2 = Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[1].Id, false);
        Registration__c reg3 = Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[2].Id, false);
        Registration__c reg4 = Test_SiteMeetingController.CreateRegistration(eabEvents[0].Id, contacts[3].Id, false);
        
        List<Registration__c> registrations = new List<Registration__c>{reg1, reg2, reg3, reg4};
        Insert registrations;
        
        //get updated registration
        registrations = [Select Id, Status__c,Institution_Registration_Count__c From Registration__c Where Id IN: registrations];
        
        //Assert to check Institution count
        System.assertEquals(1, registrations[0].Institution_Registration_Count__c);
        System.assertEquals(1, registrations[1].Institution_Registration_Count__c);
        System.assertEquals(0, registrations[2].Institution_Registration_Count__c);
        System.assertEquals(0, registrations[3].Institution_Registration_Count__c);
        
        //update status to registered
        reg1.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
        reg3.Status__c = Constants.REGISTRATION_STATUS_REGISTERED;
        
        Update new List<Registration__c>{reg1, reg3};
        
        //get updated registration
        registrations = [Select Id, Status__c,Institution_Registration_Count__c From Registration__c Where Id IN: registrations];
        
        //Assert to check Institution count
        System.assertEquals(1, registrations[0].Institution_Registration_Count__c);
        System.assertEquals(1, registrations[1].Institution_Registration_Count__c);
        System.assertEquals(1, registrations[2].Institution_Registration_Count__c);
        System.assertEquals(1, registrations[3].Institution_Registration_Count__c);
        
        Test.stopTest();
    }
    
    // Created by - Saurabh Kumar - 04/14/2021 - CR-20210128-14854
    // Modified by Chirag Soni - CR-20210606-15193
    static testMethod void testSyncContactAndRegistrationsWithAcquia(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Query account from setup method
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        Util.BypassAllTriggers = true;
        
        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ; i<=46; i++){
            
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        insert contacts;
        
        // create EAB Event
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
         // insert bulk registration to update 
        List<Registration__c> insertRegistrationsToUpdate = new List<Registration__c>();
        
        for(Integer i=0 ; i < 23 ; i++ ){
            
            insertRegistrationsToUpdate.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
            
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert insertRegistrationsToUpdate; // bypass trigger and insert to test update case
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
       
        Util.BypassAllTriggers = false;
        Test.startTest();
        
        List<Registration__c> registrations = new List<Registration__c>();
        // remaining 23 registrations
        for(Integer i = 23 ; i < 46 ; i++){
            
         registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));

        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;// for insert case 
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        // update registration fields and check synced values 
        List<Registration__c> registrationsToBeUpdate = new List<Registration__c>();
        
        for(Registration__c registration :  insertRegistrationsToUpdate){
            
            registrationsToBeUpdate.add(new Registration__c(Id = registration.Id, Partner_Status__c = Constants.REGISTRATION_PARTNER_STATUS_PARTNER));
            
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        update registrationsToBeUpdate; // for update case
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        Test.stopTest();
        
        // ----- for insert case ----- //
        for(Registration__c registration : [SELECT Id, Acquia_Id__c, Requires_Acquia_Sync__c 
                                            /*Contact__r.Acquia_Id__c, Contact__r.Requires_Acquia_Sync__c*/ 
                                            FROM Registration__c WHERE Id IN :registrations]){
                                                
        // assert to check updated acquia id and Requires acquia sync of contacts
                                                
        // assert to check updated Requires acquia syn on registrations
        System.assertEquals(false, registration.Requires_Acquia_Sync__c);

        }
        
        // ----- for update case ----- //
        for(Registration__c updatedRegistration : [SELECT Id, Acquia_Id__c, Requires_Acquia_Sync__c 
                                                   /*Contact__r.Acquia_Id__c, Contact__r.Requires_Acquia_Sync__c*/ 
                                                   FROM Registration__c WHERE Id IN :registrationsToBeUpdate]){
                                                       
        // assert to check updated acquia id and Requires acquia sync of contacts
                                                
        // assert to check updated Requires acquia syn on registrations
        System.assertEquals(false, updatedRegistration.Requires_Acquia_Sync__c);
                                               
        }
        
        // check web service logs
        for(Web_Service_Log__c webServiceLogs :  [SELECT Response_Message__c 
                                                  FROM Web_Service_Log__c WHERE Contact__c = :contacts]){
                                                      
        // assert to check status coded   
        System.assertEquals('201', webServiceLogs.Response_Message__c);                                                                                         
        
       }
        
    } 
    
    //Created by Neha Sharma - 04/16/2021 - CR-20210324-15023
    //test addZoomRegistrant
    // Modified by - Chirag soni - 05/12/2021 - text method issue fixes w.r.t CR-20210128-14854. 
    static testMethod void testZoomServices_addZoomRegistrant() {
        
        //bypass triggers
        util.bypassAllTriggers = true;
        
        List<Account> accounts = [Select Id From Account];
        
        //create contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        contacts.add(testUtilities.CreateNewContact(accounts[0], false));
        
        Insert contacts;
        
        //create Events
        List<Advisory_Event__c> events = new List<Advisory_Event__c>();
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test1';
        event.Short_Name__c = 'Test1';
        event.Status__c = 'Open - Registration';
        event.Begins__c = System.today();
        event.Ends__c = System.today().addDays(1);
        event.Zoom_Type__c = 'Webinar';
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
        events.add(event);
        
        //create child event
        event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Event_Type__c = 'Research Working Sessions';
        event.Public_Name__c = 'Test2';
        event.Short_Name__c = 'Test2';
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Begins__c = System.today();
        event.Ends__c = System.today();
        event.Zoom_Type__c = null;
        event.Zoom_Meeting_ID__c = zoomMeetingId;
        event.Status__c = 'Open - Registration';
	events.add(event);
        
        Insert events;
        
        
        //create the registration
        List<Registration__c> registrations = new List<Registration__c>();
        registrations.add(Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[0].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(events[0].Id, contacts[1].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[2].Id, false));
        registrations.add(Test_SiteMeetingController.CreateRegistration(events[1].Id, contacts[3].Id, false));
        
        Insert registrations;
        
        Set<Id> regIds = new Set<Id>{registrations[0].Id,registrations[1].Id,registrations[2].Id,registrations[3].Id};
            
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        test.startTest();
        ZoomServices.addZoomRegistrant(regIds);
        test.stopTest();
        
        //get update registartion
        registrations = [Select Zoom_Participant_URL__c, Zoom_Registrant_ID__c From Registration__c Where Id IN: regIds];
        system.assertEquals('https://zoom.us/', registrations[0].Zoom_Participant_URL__c);
        system.assertEquals('85746065', registrations[0].Zoom_Registrant_ID__c);
        
        //Modified by - Neha Sharma - 07/21/2021 - Issue Fixes - CR-20210625-15241
        //get Web_Service_Log__c 
        List<Web_Service_Log__c> webServiceLogs = [Select Request_Sent__c,EAB_Event__c,Web_Service_Method__c,Registration__c From Web_Service_Log__c Where Registration__c != null];
        system.assertEquals(4, webServiceLogs.size());
        System.assertEquals(events[0].Id, webServiceLogs[1].EAB_Event__c); 
        System.assertEquals('addZoomRegistrant', webServiceLogs[2].Web_Service_Method__c);
         
    }
    
    // Created by - Saurabh Kumar - 04/20/2021 - CR-20210318-15005
    static testMethod void testManageRegistrationFields(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        // Query Account 
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //bypass all triggers 
        Util.BypassAllTriggers = true;
        
        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ; i<=45; i++){
            
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        insert contacts;
        
        // create EAB Event
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(cohortEvent);
        
        cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 2';
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        cohortEvent.Auto_Approve_Partners__c = true;
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //create bulk registration to test insert use cases.
        List<Registration__c> registrations = new List<Registration__c>();
        
        for(Integer i=0 ; i<45; i++){
            
            if(i <= 14)
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested', Approval_Status__c = 'Approved', Automated_Update__c = true));
            
            else if(i <= 29)
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested', Approval_Status__c = 'Waitlist' , Automated_Update__c = true));
            
            else if(i <= 44)
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested', Approval_Status__c = 'Declined', Automated_Update__c = true));
            
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;// for insert case 
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        for(Registration__c registration : [SELECT Id, Status__c, Declined_Reason__c, Registration_Request_Date__c, 
                                            Automated_Update__c, Approval_Status__c
                                            FROM Registration__c WHERE Id IN :registrations]){
                                                
                                                if(registration.Approval_Status__c == 'Approved' ){
                                                    
                                                    // asserts to check  Declined reason and Registration status According to Approval status.
                                                    System.assertEquals(Constants.REGISTRATION_STATUS_REGISTERED, registration.Status__c);
                                                    
                                                    // assert to check Registration requested date when reistration status is Registration requested
                                                    System.assertEquals(System.today(), registration.Registration_Request_Date__c);
                                                    
                                                    //assert to check automated update of registration 
                                                    System.assertEquals(false, registration.Automated_Update__c);
                                                    
                                                }else if(registration.Approval_Status__c == 'Waitlist'){
                                                    
                                                    // asserts to check  Declined reason and Registration status According to Approval status.
                                                    System.assertEquals(Constants.REGISTRATION_STATUS_WAITLIST, registration.Status__c);
                                                    System.assertEquals(Constants.REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY, registration.Declined_Reason__c);
                                                    
                                                    // assert to check Registration requested date when reistration status is Registration requested
                                                    System.assertEquals(System.today(), registration.Registration_Request_Date__c);
                                                    
                                                    //assert to check automated update of registration 
                                                    System.assertEquals(false, registration.Automated_Update__c);
                                                    
                                                }else if(registration.Approval_Status__c == 'Declined'){
                                                    
                                                    // asserts to check  Declined reason and Registration status According to Approval status.
                                                    System.assertEquals(Constants.REGISTRATION_STATUS_DECLINED, registration.Status__c);
                                                    System.assertEquals(Constants.REGISTRATION_WAITLIST_DECLINED_REASON_EVENT_REG_CAPACITY, registration.Declined_Reason__c);
                                                    
                                                    // assert to check Registration requested date when reistration status is Registration requested
                                                    System.assertEquals(System.today(), registration.Registration_Request_Date__c);
                                                    
                                                    //assert to check automated update of registration 
                                                    System.assertEquals(false, registration.Automated_Update__c);
                                                }
                                                
                                            }
        
        // update all the registration and check status 
        List<Registration__c> registrationsToBeUpdate = new List<Registration__c>();
        
        for(Registration__c registration : registrations){
            
            registrationsToBeUpdate.add(new Registration__c(Id =  registration.Id,  EAB_Event__c = eabEvents[1].Id, Status__c = 'Registration Requested', Approval_Status__c = '', Partner_Status__c = Constants.REGISTRATION_PARTNER_STATUS_PARTNER));
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        update registrationsToBeUpdate;// for update case 
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        for(Registration__c registration : [SELECT Id, Approval_Status__c, Status__c, Automated_Update__c, 
                                            Approval_Reason__c, Approval_Type__c
                                            FROM Registration__c WHERE Id IN :registrationsToBeUpdate]){
                                                
                                                //status of registration should be registered when EAB Event's Auto Approval partner is true and Registration partner status = partner 
                                                System.assertEquals(Constants.REGISTRATION_STATUS_REGISTERED, registration.Status__c);
                                                
                                                //approval status should be approved 
                                                System.assertEquals(Constants.KEYWORD_APPROVED, registration.Approval_Status__c);
                                                
                                                //approval reason should be null
                                                System.assertEquals(null, registration.Approval_Reason__c);
                                                
                                                // approval type should be Auto Approve Partner 
                                                System.assertEquals(Constants.REGISTRATION_APPROVAL_TYPE_AUTO_APPROVE_PARTNER, registration.Approval_Type__c);
                                                
                                            }
        Test.stopTest();
    }
    
    //04/20/2021 - Saurabh Kumar - CR-20210312-14994 - Created testSyncMeetingUtilization() method.
    static testMethod void testSyncMeetingUtilization(){
        
        //Query Account
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //byPass All triggers 
        Util.BypassAllTriggers = true;
        
        //Create the new Program records
        Program__c program = TestUtilities.CreateNewProgram(true);

        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ; i<=20; i++){
            
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        // create two eab Event 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'EAB 1';
        eabEvent.Public_Name__c = 'EAB 1 public event';
        eabEvent.Primary_Program__c = program.Id;
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(eabEvent);
	
	//04/15/2021 - CR-20210312-14994 - Saurabh Kumar - Updated syncMeetingUtilization() method to bypass creating Meeting Utilization for Onsite & Conference eab event record types.
	eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_EAB_EVENT_ONSITE, null, false);
        eabEvent.Short_Name__c = 'EAB 2';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Auto_Approve_Partners__c = true;
        eabEvents.add(eabEvent);
        
        insert eabEvents;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //now create set of 10 registrations on each of EAB Event and check meeting utilization id
        List<Registration__c> registrations = new List<Registration__c>();
        
        for(Integer i = 0; i< contacts.size() ; i++ ){
            
            if(i <= 9) //first 10 registration will be on EAB Event where record type is Event 
                
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
            
            else if (i<= 19)//second 10 registration will be on EAB Event where record type is Onsite
                
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registration Requested'));
            
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;// for insert case 
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        List<Registration__c> insertedRegistrations = [SELECT Id, EAB_Event__r.RecordTypeId, Meeting_Utilization__c 
                                                       FROM Registration__c];
        
        for(Registration__c registration : insertedRegistrations){
            
            if(registration.EAB_Event__r.RecordTypeId == Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT){
                
                // check whether meeting utilization is created and populated
                // when eab event record type is event 
                System.assertNotEquals(null , registration.Meeting_Utilization__c);
            }
            else{
                
                // when eab event record type is onsite or Confrence or cohort, 
                // meeting utilization should not created.
                System.assertEquals(null , registration.Meeting_Utilization__c);
                
            }
        }
        
        Test.stopTest();
    }
    
    //06/01/2021 - Chirag Soni - CR-20210408-15071 - Created testCancelParentsEligibleRegistrations() method.
    static testMethod void testCancelParentsEligibleRegistrations(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Query Account
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //byPass All triggers 
        Util.BypassAllTriggers = true;
        
        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ; i<=6; i++){
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        insert contacts;
        
        // create two Parent eab Event 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new Parent EAB event 1 record
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent.Short_Name__c = 'Parent EAB Event 1';
        eabEvent.Public_Name__c = 'Parent Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(eabEvent);
        
        //Create the new Parent EAB event 2 record
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent.Short_Name__c = 'Parent EAB Event 2';
        eabEvent.Public_Name__c = 'Parent Event 2';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(eabEvent);
        
        //Insert parent eab events
        insert eabEvents;
        
        List<Registration__c> registrations = new List<Registration__c>();
        //Insert registrations for parent eab events
        for(Integer i = 0; i< contacts.size() ; i++ ){
            
            if(i <= 2) //first 3 registration will be on Parent EAB Event 1 and other 3 will be on event 2
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
            else
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registration Requested'));
        }
        
        insert registrations;
        
        // create two child eab events for parent event 1
        List<Advisory_Event__c> childEabEvents = new List<Advisory_Event__c>();
        
        //Create two child event for parent event 1
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'child 1 - EAB Event 1';
        eabEvent.Public_Name__c = 'child 1 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Parent_Event__c = eabEvents[0].Id;
        eabEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        childEabEvents.add(eabEvent);
        
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'child 2 - EAB Event 1';
        eabEvent.Public_Name__c = 'child 2 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Parent_Event__c = eabEvents[0].Id;
        eabEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        childEabEvents.add(eabEvent);
        
        //Create two child event for parent event 2
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'child 1 - EAB Event 2';
        eabEvent.Public_Name__c = 'child 1 EAB Event 2';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Parent_Event__c = eabEvents[1].Id;
        eabEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        childEabEvents.add(eabEvent);
        
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'child 2 - EAB Event 2';
        eabEvent.Public_Name__c = 'child 2 EAB Event 2';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Parent_Event__c = eabEvents[1].Id;
        eabEvent.Mirror_Registrations__c = Constants.EAB_EVENT_INHERI_REGISTRATION_PARENT_REGISTRATIONS_ELIGIBLE;
        childEabEvents.add(eabEvent);
        
        //insert child events
        insert childEabEvents;
        
        List<Registration__c> child1registrations = new List<Registration__c>();
        
        //Insert registrations for parent eab events
        for(Integer i = 0; i< contacts.size() ; i++ )
        {
            if(i <= 2) 
            {   // create registrations on child events for first parent event.
                child1registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = childEabEvents[0].Id, Status__c = 'Registration Requested'));
                child1registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = childEabEvents[1].Id, Status__c = 'Registration Requested'));
            }
            else{
                // create registrations on child events for second parent event.
                child1registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = childEabEvents[2].Id, Status__c = 'Registration Requested'));
                child1registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = childEabEvents[3].Id, Status__c = 'Registration Requested'));
            }
        }
        
        insert child1registrations;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //Update registration status of 1st parent event and check status on registrations of child events 
        List<Registration__c> registrationsTobeUpdated = new List<Registration__c>();
        
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[0].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable Registrations'));
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[1].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable Registrations'));
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[2].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable Registrations'));
        
        update registrationsTobeUpdated;
        
        //Query registrations of child event based on first parent event id
        registrationsTobeUpdated = [SELECT Id, Status__c, Cancellation_Reason__c FROM Registration__c WHERE EAB_Event__r.Parent_Event__c = : eabEvents[0].Id];
        
        System.assertEquals(6, registrationsTobeUpdated.size());
        
        // three registrations on first child event
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[0].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[1].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[2].Status__c);
        
        // another three registrations on second child event
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[3].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[4].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[5].Status__c);
        
        registrationsTobeUpdated = new List<Registration__c>();
        
        //Update registration status of 2nd parent event and check status on registrations of child events 
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[3].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable 2 Registrations'));
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[4].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable 2 Registrations'));
        registrationsTobeUpdated.add(new Registration__c(Id = registrations[5].Id, Status__c = Constants.STATUS_CANCELLED, Cancellation_Reason__c = 'Testing Parents Enable 2 Registrations'));
        
        update registrationsTobeUpdated;
        
        //Query registrations of child event based on parent event id
        registrationsTobeUpdated = [SELECT Id, Status__c, Cancellation_Reason__c FROM Registration__c WHERE EAB_Event__r.Parent_Event__c = : eabEvents[1].Id];
        
        System.assertEquals(6, registrationsTobeUpdated.size());
        
        // status of registration on first child event will be changed to cancelled 
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[0].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[1].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[2].Status__c);
        
        // status of registration on second child event will be changed to cancelled 
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[4].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[5].Status__c);
        System.assertEquals(Constants.STATUS_CANCELLED, registrationsTobeUpdated[3].Status__c);
        
        Test.stopTest();
    }
 
    //07/09/2021 - Chirag Soni - CR-20210511-15133 - Created testCancelParentsEligibleRegistrations() method.
    static testMethod void testPopulateTravelCompensationFields(){
        
         //initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, Travel_Comp_Approver__c = true, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User4', FirstName='Test3', Email='testuser4@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Insert user records
        insert userList;
        
        //Assert for result
        System.assert(userList.size() > 0);

        //Query Account
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
                
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = userList[0].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = userList[1].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = userList[2].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact4', Email = 'test@test.com', AccountId = account.Id, Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;
        
        //Assert for result
        System.assert(contacts.size() > 0);
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        
        //Insert
        insert programs;
       
        // create two eab events for parent event 1
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        
        //Create two event
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'test 1 - EAB Event 1';
        eabEvent.Public_Name__c = 'test 1 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Allow_Employee_Registrations__c = true;
        eabEvent.Begins__c = system.today().addDays(6);
        eabEvent.Ends__c = system.today().addDays(20);
        eabEvents.add(eabEvent);
        
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'test 2 - EAB Event 1';
        eabEvent.Public_Name__c = 'test 2 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Allow_Employee_Registrations__c = true;
        eabEvent.Begins__c = system.today().addDays(10);
        eabEvent.Ends__c = system.today().addDays(20);
        eabEvents.add(eabEvent);

        //insert events
        insert eabEvents;
    
        Util.BypassAllTriggers = false;
        
        //testing
        Test.startTest();
        //List to hold the registrations record
        List<Registration__c> registrations = new List<Registration__c>();
        
        // create registrations on child events for first parent event.
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              ,Department_Authorization__c = userList[0].Id ,Requester_Name__c = userList[1].Id, Travel_Assistance_Request__c = true));
        
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              , Department_Authorization__c = userList[1].Id ,Requester_Name__c = userList[2].Id , Travel_Assistance_Request__c = true));
        
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              , Department_Authorization__c = userList[2].Id ,Requester_Name__c = userList[0].Id, Travel_Assistance_Request__c = true));

        registrations.add(new Registration__c(Contact__c = contacts[3].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2',Travel_Assistance_Request__c = true
                                              , Department_Authorization__c = userList[3].Id ,Requester_Name__c = userList[0].Id));

        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = true;
        insert registrations;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        RegistrationHelper.isAlreadyChatterPostedForRegistrationAndCamapignMemberStatusMissMatch = false;

        //Query to registration records
        registrations = [Select Id, Contact__c, Is_Escalated__c,Travel_Compensation_Approval_Status__c, EAB_Event__c, Status__c, Department_Authorization__c, Requester_Name__c,
                         Requester_Name_Contact__c,Department_Authorization_Contact__c From Registration__c Order By Contact__r.LastName];
        
        system.assertEquals('Pending', registrations[3].Travel_Compensation_Approval_Status__c);
        
        Test.stopTest();
        //Fetching registrations records
        registrations = [Select Id, Contact__c, Is_Escalated__c,Travel_Compensation_Approval_Status__c, EAB_Event__c, Status__c, Department_Authorization__c, Requester_Name__c,
                         Requester_Name_Contact__c,Department_Authorization_Contact__c From Registration__c Order By Contact__r.LastName];
        
        System.assertEquals(contacts[0].Id, registrations[0].Department_Authorization_Contact__c);
        System.assertEquals(contacts[1].Id, registrations[1].Department_Authorization_Contact__c);
        System.assertEquals(contacts[2].Id, registrations[2].Department_Authorization_Contact__c);
        
        system.assertEquals('Pending', registrations[0].Travel_Compensation_Approval_Status__c);
        system.assertEquals('Pending', registrations[1].Travel_Compensation_Approval_Status__c);
        system.assertEquals('Pending', registrations[2].Travel_Compensation_Approval_Status__c);
        system.assertEquals(true, registrations[0].Is_Escalated__c);
        system.assertEquals(false, registrations[1].Is_Escalated__c);
        system.assertEquals(true, registrations[2].Is_Escalated__c);
        system.assertEquals(true, registrations[3].Is_Escalated__c);
    
        
        System.assertEquals(contacts[1].Id, registrations[0].Requester_Name_Contact__c);
        System.assertEquals(contacts[2].Id, registrations[1].Requester_Name_Contact__c);
        System.assertEquals(contacts[0].Id, registrations[2].Requester_Name_Contact__c);
      

        //Bypass All Triggers to bypass the Meeting Utilization trigger.
        Util.BypassAllTriggers = false;

        //Rejection of Approval process Starts from here
        List<ProcessInstance> processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: registrations[0].Id AND Status='Pending'];
        
        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : processInstanceList]
		) {
			//String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            
            //Check for the Prefix and ten Reject the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                
                Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                req1.setWorkItemId(workItem.id);
                req1.setAction('Reject'); // This means to remove/recall Approval Request
                req1.setComments('Rejected Status');
                req1.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
                
				Approval.ProcessResult result = Approval.process(req1);   
              
            }
        }
        //Rejection of Approval process Ends here
        
        //Asserts on results
        List<Registration__c> registration = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Travel_Compensation_Approval_Status__c, Is_Escalated__c From Registration__c where Id =: registrations[0].Id];
        system.assertEquals('Rejected', registration[0].Travel_Compensation_Approval_Status__c);

        //Rejection of Approval process without comments for rejection Starts from here
        processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: registrations[2].Id AND Status='Pending'];

        Boolean expectedExceptionThrown;

        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : processInstanceList]
		) {
			//String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            
            //Check for the Prefix and ten Reject the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                try{
                    Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                    req1.setWorkItemId(workItem.id);
                    req1.setAction('Reject'); // This means to remove/recall Approval Request
                    req1.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
                    
                    Approval.ProcessResult result = Approval.process(req1); 

                }catch(Exception e){
                    expectedExceptionThrown =  e.getMessage().contains('rejection reason') ? true : false;
                    System.debug('##@@ Exception --> '+ e.getMessage());
                }
              
            }
        }
        //Rejection of Approval process Ends here
        System.assertEquals(expectedExceptionThrown, true);

        //Asserts on results
        //registration = [Select Id, Department_Authorization_Contact__c,error Requester_Name_Contact__c, Travel_Compensation_Approval_Status__c, Is_Escalated__c From Registration__c where Id =: registrations[2].Id];
        //system.assertEquals(System.label.Registration_Approval_Rejected_Error, registration[0].error);
        
        //list to hold Process Submit Request
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();

        //Approval of Approval process Starts from here
        processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: registrations[1].Id AND Status='Pending'];
        
        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : processInstanceList]
		) {
			//String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            //Check for the Prefix and then Approve the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                
                Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
                req2.setWorkItemId(workItem.id);
                req2.setAction('Approve'); // This means to remove/recall Approval Request
                req2.setComments('Approved Status');
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
                
                //add Approval Request to list
                //approvalRequestList.add(approvalRequest);
				Approval.ProcessResult result = Approval.process(req2);   
               
            }
        }

        //Asserts on results
        registration = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Travel_Compensation_Approval_Status__c, Is_Escalated__c From Registration__c where Id =: registrations[1].Id];
        system.assertEquals('Approved', registration[0].Travel_Compensation_Approval_Status__c);

        //Approval.process(approvalRequestList);
        processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: registrations[1].Id AND Status='Pending'];

    }
    
    //Created by - Chirag Soni - 10/28/2021 - CR-20210614-15213 - Method to test "populateElevatedMealRSVPFieldOnParentEvent"
    @isTest
    static void testPopulateElevatedMealRSVPFieldOnParentEvent(){
        
	//initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Bypass Dupeblocker
        //Util.IsTest(true);
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, Travel_Comp_Approver__c = true,
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));

        //Insert user records
        insert userList;

        //Assert for result
        System.assert(userList.size() > 0);

        //Query Account
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
                
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test@test.com', AccountId = account.Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test@test.com', AccountId = account.Id, Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;

        // create two Parent eab Event 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();

        //Create the new Parent EAB event 1 record
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eabEvent.Short_Name__c = 'Parent EAB Event 1';
        eabEvent.Public_Name__c = 'Parent Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvents.add(eabEvent);
        
        //Insert parent eab events
        insert eabEvents;
        
        List<Registration__c> registrations = new List<Registration__c>();
        //Insert registrations for parent eab events
        for(Integer i = 0; i< contacts.size() ; i++ )
        {
            registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        }

        //insert registrations
        insert registrations;
        Util.BypassAllTriggers = false;
        // create two child eab events for parent event 1
        List<Advisory_Event__c> childEabEvents = new List<Advisory_Event__c>();
        
        //Create two child event for parent event 1
        eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'child 1 - EAB Event 1';
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL;
        eabEvent.Public_Name__c = 'child 1 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Parent_Event__c = eabEvents[0].Id;
        childEabEvents.add(eabEvent);
        //Bypass EAB Event
 	Util.byPassAllTriggers = true;
        //insert child events
        insert childEabEvents;
        Util.BypassAllTriggers = false;
        
        //test start here
        Test.startTest();
        
        List<Registration__c> child1registrations = new List<Registration__c>();
        //insert registrations
        child1registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = childEabEvents[0].Id, Status__c = 'Registration Requested', 
                                                    RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL, RSVP__c = 'Yes'));
        child1registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = childEabEvents[0].Id, Status__c = 'Registration Requested', 
                                                    RecordTypeId = Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL, RSVP__c = 'No'));
	//insert registrations
        insert child1registrations;

        List<Registration__c> listOfRegistrationOnParentEvent = [Select Id, Elevated_Meal_RSVP__c From Registration__c 
                                                                 Where EAB_Event__c =: eabEvents[0].Id Order BY Contact__r.LastName];
        
	System.assert(listOfRegistrationOnParentEvent.size()==2);
        System.assertEquals(child1registrations[0].RSVP__c, listOfRegistrationOnParentEvent[0].Elevated_Meal_RSVP__c);
        System.assertEquals(child1registrations[1].RSVP__c, listOfRegistrationOnParentEvent[1].Elevated_Meal_RSVP__c);
		
        //test stop here
        Test.stopTest();
        
        child1registrations = [Select Id, Elevated_Meal_RSVP__c From Registration__c Where EAB_Event__c =: childEabEvents[0].Id Order BY Contact__r.LastName];
        //Update child registrations
        child1registrations[0].RSVP__c = 'No';
        child1registrations[1].RSVP__c = 'Maybe';

        //update registrations
        update child1registrations;
        
        //Parent event's registrations
        listOfRegistrationOnParentEvent = [Select Id, Elevated_Meal_RSVP__c From Registration__c 
                                           Where EAB_Event__c =: eabEvents[0].Id Order BY Contact__r.LastName];

        System.assertEquals(child1registrations[0].RSVP__c, listOfRegistrationOnParentEvent[0].Elevated_Meal_RSVP__c);
        System.assertEquals(child1registrations[1].RSVP__c, listOfRegistrationOnParentEvent[1].Elevated_Meal_RSVP__c);
      
    }
    
}