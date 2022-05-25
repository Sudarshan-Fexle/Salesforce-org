/**
*   Purpose         :    test class for ZoomWebhooks
*            
*   Create By       :	 Saurabh Kumar
* 
*   Created Date    :    04/23/2021
*
*   Revision Logs   :   V1.0 - 04/23/2021 - CR-20210319-15008 - Created By - Saurabh Kumar
*                       V1.1 - 07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented reference to Queueable_UpdateParticipantAttendance and Added Scheduler_UpdateParticipantAttendance call 
*			    	  
*   Coverage        :   87% to ZoomWebHook class and 91% Scheduler_UpdateParticipantAttendance class
**/ 

@isTest
public class Test_ZoomWebhooks {
    
    //Zoom type and ZoomId
    public static final String ZOOM_TYPE_MEETING = 'Meeting';
    public static final String ZOOM_TYPE_WEBINAR = 'Webinar';
    public static final String ZOOM_MEETING_ID = '21987654321';
    public static final String ZOOM_WEBINAR_ID = '12345678912';
    
    //event
    public static final String ZOOM_MEETING_STARTED = 'meeting.started';
    public static final String ZOOM_MEETING_ENDED = 'meeting.ended';
    public static final String ZOOM_WEBINAR_STARTED = 'webinar.started';
    public static final String ZOOM_WEBINAR_ENDED = 'webinar.ended';
    
    // URL for zoomWebhook
    public static final String ZOOM_WEBHOOK_SERVICE_URL = '/services/apexrest/zoomWebhookService';
    
    @testSetup  
    static void testSetup() {
        
        Util.bypassAllTriggers = true;
        
        //create account
        Account account = TestUtilities.CreateNewAccount(true);
        
        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=0 ; i<30; i++){
            
            Contact contact = testUtilities.CreateNewContact(account, false);
            contact.Email = 'testZoomSessions'+i+'@eab.edu';
            contacts.add(contact);
        }
        
        insert contacts;
        
        //create EAB Event 
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record for test zoom type meeting  
        Advisory_Event__c event = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event.Name = 'Test Zoom Session';
        event.Public_Name__c = 'Test Zoom Session';
        event.Short_Name__c = 'Test Zoom Session';
        event.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event.Event_Format__c = 'Virtual';
        event.Zoom_Type__c = ZOOM_TYPE_MEETING;
        event.Zoom_Meeting_ID__c = ZOOM_MEETING_ID;  
        event.Rules_Programs__c = 'Establish independent rules';
        
        eabEvents.add(event);
        
        //Create the new EAB event record for test zoom type webinar  
        Advisory_Event__c event2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        event2.Name = 'Test Zoom Session Webinar';
        event2.Public_Name__c = 'Test Zoom Session Webinar';
        event2.Short_Name__c = 'Test Zoom Session Webinar';
        event2.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        event2.Event_Format__c = 'Virtual';
        event2.Zoom_Type__c = ZOOM_TYPE_WEBINAR;
        event2.Zoom_Meeting_ID__c = ZOOM_WEBINAR_ID;  
        event2.Rules_Programs__c = 'Establish independent rules';
        
        eabEvents.add(event2);
        insert eabEvents;
        
        List<Registration__c> registrations = new List<Registration__c>();
        
        //create bulk registrations half for first EAB(Zoom meeting) and Half for second EAB(Zoom Webinar) 
        for(Integer i = 0 ; i< 30 ; i++){
            
            if(i < = 14)
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registered'));
            else
                registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[1].Id, Status__c = 'Registered'));
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        Util.bypassAllTriggers = false;
    }
    
    // method to test meeting.started and webinar.started
    // 07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni
    static testMethod void testProcessWebhookAndMeetingUpdates(){
        
        //Initialize mockResponse
        ZoomServicesMock mockService = new ZoomServicesMock();
        mockService.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mockService);
        
        Test.startTest();
       
        // test zoom type meeting
        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+ZOOM_WEBHOOK_SERVICE_URL;
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf(ZoomServicesMock.restResourceRequestBody(ZOOM_MEETING_ID, ZOOM_MEETING_STARTED));
        
        RestContext.request = request;
        
        ZoomWebhooks.doPost();
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
        //System.enqueueJob(new Queueable_UpdateParticipantAttendance(ZOOM_MEETING_ID, null));
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call
        Scheduler_UpdateParticipantAttendance.updateParticipantAttendance(ZOOM_MEETING_ID, null);
        
        //test zoom type webinar 
        RestRequest webinarRequest = new RestRequest();
        webinarRequest.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+ZOOM_WEBHOOK_SERVICE_URL;
        webinarRequest.httpMethod = 'POST';
        webinarRequest.requestBody = blob.valueOf(ZoomServicesMock.restResourceRequestBody(ZOOM_WEBINAR_ID, ZOOM_WEBINAR_STARTED));
        
        RestContext.request = webinarRequest;
        
        ZoomWebhooks.doPost();
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
        //System.enqueueJob(new Queueable_UpdateParticipantAttendance(ZOOM_WEBINAR_ID, null));
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call
        Scheduler_UpdateParticipantAttendance.updateParticipantAttendance(ZOOM_WEBINAR_ID, null);
        
        Test.stopTest();  
        
        //Query EAB Event
        List<Advisory_Event__c> eabEvents = [SELECT Id, Time_Started__c, Time_Ended__c, (SELECT Id, Web_Service_Method__c FROM Web_Service_Logs__r WHERE Web_Service_Method__c != 'updateParticipantAttendance') FROM Advisory_Event__c];  
        
        // check whether Time Started and ended is populated on EAB Event where zoom type is meeting
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 11, 53, 35), eabEvents[0].Time_Started__c);
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 14, 33, 40), eabEvents[0].Time_Ended__c);
        
        //check whether Time Started and ended is populated on EAB Event where zoom type is webinar
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 11, 53, 35), eabEvents[1].Time_Started__c);
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 14, 33, 40), eabEvents[1].Time_Ended__c);
        
        //check web service method of web service logs on eab event.
        System.assertEquals(ZOOM_MEETING_STARTED, eabEvents[0].Web_Service_Logs__r[0].Web_Service_Method__c);
        System.assertEquals(ZOOM_WEBINAR_STARTED, eabEvents[1].Web_Service_Logs__r[0].Web_Service_Method__c);
        
        
        Integer i = 1;
        for(Registration__c registration : [SELECT Id, Attended__c, Duration_Minutes__c, Time_Joined__c, Time_Left__c, (SELECT Id, Registrant__c, Time_Joined__c, Duration_Minutes__c, Time_Left__c FROM Zoom_Sessions__r),
                                            (SELECT Id, Registration__c, Zoom_Meeting_Id__c FROM Web_Service_Logs__r) FROM Registration__c]){
         
        // Assert for attended on registration and duration
        System.assertEquals(true, registration.Attended__c);
        
        // Assert to check only 1 zoom sessions created under 1 registration and registration id
        System.assertEquals(1, registration.Zoom_Sessions__r.size()); 
                                                
        // Assert to check time joined, time left, Duration minutes 
        System.assertEquals(registration.Time_Joined__c, registration.Zoom_Sessions__r[0].Time_Joined__c); 
        System.assertEquals(registration.Time_Left__c, registration.Zoom_Sessions__r[0].Time_Left__c); 
        System.assertEquals(registration.Duration_Minutes__c, registration.Zoom_Sessions__r[0].Duration_Minutes__c); 
         
        // assert to check web service logs for Id zoom meeting  
        if( i < = 15){
          
         // assert to check registration id and zoom meeting id  
         System.assertEquals(ZOOM_MEETING_ID, registration.Web_Service_Logs__r[0].Zoom_Meeting_Id__c);   
        }
        else{
         
         // assert to check registration id and zoom meeting id    
         System.assertEquals(ZOOM_WEBINAR_ID, registration.Web_Service_Logs__r[0].Zoom_Meeting_Id__c);  
        }
        i++; 
       
       }
    }
    
   // method to test meeting.ended and webinar.ended
   // 07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni
    static testMethod void testProcessWebhookAndMeetingUpdatesV2(){
        
        //Initialize mockResponse
        ZoomServicesMock mockService = new ZoomServicesMock();
        mockService.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, mockService);
        
        Test.startTest();
        
        // test zoom type meeting
        RestRequest request = new RestRequest();
        request.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+ZOOM_WEBHOOK_SERVICE_URL;
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf(ZoomServicesMock.restResourceRequestBody(ZOOM_MEETING_ID, ZOOM_MEETING_ENDED));
        
        RestContext.request = request;
        
        ZoomWebhooks.doPost();
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
        //System.enqueueJob(new Queueable_UpdateParticipantAttendance(ZOOM_MEETING_ID, null));
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call
        Scheduler_UpdateParticipantAttendance.updateParticipantAttendance(ZOOM_MEETING_ID, null);
        
        //test zoom type webinar 
        RestRequest webinarRequest = new RestRequest();
        webinarRequest.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+ZOOM_WEBHOOK_SERVICE_URL;
        webinarRequest.httpMethod = 'POST';
        webinarRequest.requestBody = blob.valueOf(ZoomServicesMock.restResourceRequestBody(ZOOM_WEBINAR_ID, ZOOM_WEBINAR_ENDED));
        
        RestContext.request = webinarRequest;
        
        ZoomWebhooks.doPost();
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - commented
        //System.enqueueJob(new Queueable_UpdateParticipantAttendance(ZOOM_WEBINAR_ID, null));
        
        //07/15/2021 - CR-20210709-15278 - Modified By - Chirag Soni - added this call 
        Scheduler_UpdateParticipantAttendance.updateParticipantAttendance(ZOOM_WEBINAR_ID, null);
        
        Test.stopTest();  
        
        //Query EAB Event
        List<Advisory_Event__c> eabEvents = [SELECT Id, Time_Started__c, Time_Ended__c, (SELECT Id, Web_Service_Method__c FROM Web_Service_Logs__r WHERE Web_Service_Method__c != 'updateParticipantAttendance') FROM Advisory_Event__c];  
        
        // check whether Time Started and ended is populated on EAB Event where zoom type is meeting
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 11, 53, 35), eabEvents[0].Time_Started__c);
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 14, 33, 40), eabEvents[0].Time_Ended__c);
        
        //check whether Time Started and ended is populated on EAB Event where zoom type is webinar
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 11, 53, 35), eabEvents[1].Time_Started__c);
        System.assertEquals(DateTime.newInstance(2021, 04, 29, 14, 33, 40), eabEvents[1].Time_Ended__c);
        
        //check web service method of web service logs on eab event.
        System.assertEquals(ZOOM_MEETING_ENDED, eabEvents[0].Web_Service_Logs__r[0].Web_Service_Method__c);
        System.assertEquals(ZOOM_WEBINAR_ENDED, eabEvents[1].Web_Service_Logs__r[0].Web_Service_Method__c);
        
        Integer i = 1;
        for(Registration__c registration : [SELECT Id, Attended__c, Duration_Minutes__c, Time_Joined__c, Time_Left__c, (SELECT Id, Registrant__c, Time_Joined__c, Duration_Minutes__c, Time_Left__c FROM Zoom_Sessions__r),
                                            (SELECT Id, Registration__c, Zoom_Meeting_Id__c FROM Web_Service_Logs__r) FROM Registration__c]){
         
        // Assert for attended on registration and duration
        System.assertEquals(true, registration.Attended__c);
        
        // Assert to check only 1 zoom sessions created under 1 registration and registration id
        System.assertEquals(1, registration.Zoom_Sessions__r.size()); 
                                                
        // Assert to check time joined, time left, Duration minutes 
        System.assertEquals(registration.Time_Joined__c, registration.Zoom_Sessions__r[0].Time_Joined__c); 
        System.assertEquals(registration.Time_Left__c, registration.Zoom_Sessions__r[0].Time_Left__c); 
        System.assertEquals(registration.Duration_Minutes__c, registration.Zoom_Sessions__r[0].Duration_Minutes__c); 
         
        // assert to check web service logs for Id zoom meeting  
        if( i < = 15){
          
         // assert to check registration id and zoom meeting id  
         System.assertEquals(ZOOM_MEETING_ID, registration.Web_Service_Logs__r[0].Zoom_Meeting_Id__c);   
        }
        else
        {
         
         // assert to check registration id and zoom meeting id    
         System.assertEquals(ZOOM_WEBINAR_ID, registration.Web_Service_Logs__r[0].Zoom_Meeting_Id__c);  
        }
        i++; 
     }
   } 
}