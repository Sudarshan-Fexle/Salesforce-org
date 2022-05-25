/**
*   Purpose         :     Test class for ScheduleJob_ZoomServices class
*            
*   Create By       :	  Chirag Soni
* 
*   Created Date    :     07/14/2021
*
*   Revision Log    :     V_1.0 - Created - CR-20210709-15278
*                   :     V_1.1 - Modified By - Chirag Soni - CR-20211112-15583 - 11/18/2021 - Test class update 
*			    	  
*   Coverage        :     100%
**/ 

@isTest (SeeAllData = false)
private class Test_ScheduleJob_ZoomServices {
    
    //Zoom Service Mock instance
    public static ZoomServicesMock mockService = new ZoomServicesMock();
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    
    public static final String ZOOM_TYPE_WEBINAR = 'Webinar';
    public static final String MOCK_REGISTRANT_ID = '85746065';
    public static final String PARTICIPANT_URL = 'https://zoom.us/';
    
    @testSetup static void setup() {
        Util.IsTest(true);
        //ByPass All triggers 
        Util.ByPassAllTriggers = true;
        
        //Create Account
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Create Contact
        List<Contact> contacts = new List<Contact>();
        
        for(integer i=0 ; i< 60; i++)
        {
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
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
        
        //Create registrations bulk registrations        
        List<Registration__c> registrations = new List<Registration__c>();
        for(integer i=0 ; i< 60; i++)
        {
            registrations.add(new Registration__c(Contact__c = contacts[i].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'));
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert registrations;
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        Util.ByPassAllTriggers = false;
    }
    
    static testmethod void testInvokeRegistrantsZoomService(){
        
        //Initialize mock response
        mockService.methodName = 'addZoomRegistrant';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        //create list of registration to test
        List<Registration__c> registrationsToTest = new List<Registration__c>();
        
        //set of ids which holds registration ids for sync, cancel and approved with zoom 
        Map<Integer, Set<Id>> mapOfRegistrationIdsToSyncWithZoom = new Map<Integer, Set<Id>>();
        Map<Integer, Set<Id>> mapOfRegistrationIdsToCancelInZoom = new Map<Integer, Set<Id>>();
        Map<Integer, Set<Id>> mapOfRegistrationIdsToUpdateApprovedInZoom = new Map<Integer, Set<Id>>();
        
        //Query all the registrations 
        List<Registration__c> registrationToBeUpdate = [SELECT Id, Status__c, Cancellation_Reason__c, Zoom_Participant_URL__c, Zoom_Registrant_ID__c FROM Registration__c];
        
        //update registrations to for approved case 
        for(integer i=0 ; i< 30; i++)
        {
            
            if(i<10) // these registration going to registered from registration requested
            {
                registrationToBeUpdate[i].Status__c = 'Registered';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToSyncWithZoom.containsKey(1))
                    mapOfRegistrationIdsToSyncWithZoom.put(1, new Set<Id>());
                
                mapOfRegistrationIdsToSyncWithZoom.get(1).add(registrationToBeUpdate[i].Id);
            }
            if(i>9 && i<20) // these registrations going to cancelled from registered, these are already registered
            {  
                registrationToBeUpdate[i].Zoom_Participant_URL__c = PARTICIPANT_URL;
                registrationToBeUpdate[i].Zoom_Registrant_ID__c = MOCK_REGISTRANT_ID;
                registrationToBeUpdate[i].Status__c = 'Cancelled';
                registrationToBeUpdate[i].Cancellation_Reason__c = 'For testing';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToCancelInZoom.containsKey(1))
                    mapOfRegistrationIdsToCancelInZoom.put(1, new Set<Id>());
                
                mapOfRegistrationIdsToCancelInZoom.get(1).add(registrationToBeUpdate[i].Id);
            }
            if(i>19 && i<30)  // these registrations going to registered again from other status, these are already registered
            {  
                registrationToBeUpdate[i].Zoom_Participant_URL__c = PARTICIPANT_URL;
                registrationToBeUpdate[i].Zoom_Registrant_ID__c = MOCK_REGISTRANT_ID;
                registrationToBeUpdate[i].Status__c = 'Registered';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToUpdateApprovedInZoom.containsKey(1))
                    mapOfRegistrationIdsToUpdateApprovedInZoom.put(1, new Set<Id>());
                
                mapOfRegistrationIdsToUpdateApprovedInZoom.get(1).add(registrationToBeUpdate[i].Id);
            }
        }
        
        for(integer i=30 ; i< 60; i++)
        {
            
            if(i<40) // these registration going to registered from registration requested
            {
                registrationToBeUpdate[i].Status__c = 'Registered';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToSyncWithZoom.containsKey(2))
                    mapOfRegistrationIdsToSyncWithZoom.put(2, new Set<Id>());
                
                mapOfRegistrationIdsToSyncWithZoom.get(2).add(registrationToBeUpdate[i].Id);
            }
            if(i>39 && i<50) // these registrations going to cancelled from registered, these are already registered
            {  
                registrationToBeUpdate[i].Zoom_Participant_URL__c = PARTICIPANT_URL;
                registrationToBeUpdate[i].Zoom_Registrant_ID__c = MOCK_REGISTRANT_ID;
                registrationToBeUpdate[i].Status__c = 'Cancelled';
                registrationToBeUpdate[i].Cancellation_Reason__c = 'For testing';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToCancelInZoom.containsKey(2))
                    mapOfRegistrationIdsToCancelInZoom.put(2, new Set<Id>());
                
                mapOfRegistrationIdsToCancelInZoom.get(2).add(registrationToBeUpdate[i].Id);
            }
            if(i>49 && i<60)  // these registrations going to registered again from other status, these are already registered
            {  
                registrationToBeUpdate[i].Zoom_Participant_URL__c = PARTICIPANT_URL;
                registrationToBeUpdate[i].Zoom_Registrant_ID__c = MOCK_REGISTRANT_ID;
                registrationToBeUpdate[i].Status__c = 'Registered';
                registrationsToTest.add(registrationToBeUpdate[i]);
                
                if(!mapOfRegistrationIdsToUpdateApprovedInZoom.containsKey(2))
                    mapOfRegistrationIdsToUpdateApprovedInZoom.put(2, new Set<Id>());
                
                mapOfRegistrationIdsToUpdateApprovedInZoom.get(2).add(registrationToBeUpdate[i].Id);
            }
        }
        
        Util.BypassAllTriggers = true;
        update registrationsToTest;
        Util.BypassAllTriggers = false;
        
        //Cronj Exp to schedule class after every second 
        
        DateTime sysTime = dateTime.now().addSeconds(2);
        String cronj = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
        Test.startTest();
        // Commented by - Chirag Soni - CR-20211112-15583 - 11/18/2021 
        System.schedule('ScheduleJob_ZoomServices01',  cronj, new ScheduleJob_ZoomServices(mapOfRegistrationIdsToSyncWithZoom /*,new Map<Integer, Set<Id>>()/*,new Map<Integer, Set<Id>>()*/, 1));
        System.schedule('ScheduleJob_ZoomServices02',  cronj, new ScheduleJob_ZoomServices(new Map<Integer, Set<Id>>()/*,mapOfRegistrationIdsToCancelInZoom /*,new Map<Integer, Set<Id>>()*/, 1));
        //System.schedule('ScheduleJob_ZoomServices03',  cronj, new ScheduleJob_ZoomServices(new Map<Integer, Set<Id>>(), new Map<Integer, Set<Id>>(), mapOfRegistrationIdsToUpdateApprovedInZoom, 1));
        
        Test.stopTest();
        
        for(Registration__c registration : [SELECT Id, Status__c, Cancellation_Reason__c, Zoom_Participant_URL__c, Zoom_Registrant_ID__c FROM Registration__c])
        {
            if(registration.Status__c == 'Registered' && registration.Zoom_Participant_URL__c != null && registration.Zoom_Registrant_ID__c != null)
            {
                //assert for registered registration
                System.assertEquals('Registered', registration.Status__c);
                System.assertEquals(PARTICIPANT_URL, registration.Zoom_Participant_URL__c);
                System.assertEquals(MOCK_REGISTRANT_ID, registration.Zoom_Registrant_ID__c);
            }
            else if(registration.Status__c == 'Cancelled')
            {
                //assert for cancelled registration
                System.assertEquals('Cancelled', registration.Status__c);
                System.assertEquals('For testing', registration.Cancellation_Reason__c);
                System.assertEquals(PARTICIPANT_URL, registration.Zoom_Participant_URL__c);
                System.assertEquals(MOCK_REGISTRANT_ID, registration.Zoom_Registrant_ID__c);
            }
            else{
                // assert for approved registrations
                System.assertEquals('Registered', registration.Status__c);
                System.assertEquals(null, registration.Zoom_Participant_URL__c);
                System.assertEquals(null, registration.Zoom_Registrant_ID__c);
            }
        } 
    }
}