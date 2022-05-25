/**
 * 	Description 	:	test class for ResendAllCalendarInvitesController
 * 
 * 	Revision Logs	:	V1.0 - 02/17/2022 - Chirag Soni - CR-20211214-15627 -Created 										
 * 
 **/
@isTest
public class Test_ResendAllCalendarInvitesController {
    
    
    public static final String calendarInviteRecordType = Schema.SObjectType.Communication_Template__c.getRecordTypeInfosByDeveloperName().get('Calendar_Invite').getRecordTypeId();
    public static final String elevatedMealRecordType = Schema.SObjectType.Advisory_Event__c.getRecordTypeInfosByName().get('Elevated Meal').getRecordTypeId();
    public static final String elevatedMealRegistrationsRTId = Schema.SObjectType.Registration__c.getRecordTypeInfosByName().get('Elevated Meal Registration').getRecordTypeId();
    public static final String venueRType = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Event Venue').getRecordTypeId();
    
    @testSetup static void setup() {
        
        Util.ByPassAllTriggers = true;
        
        //Create Account
        Account newAccount = TestUtilities.CreateNewAccount('Event Venue',false);
        newAccount.Event_Venue__c = true;
        newAccount.Accommodations__c = true;
        newAccount.Type = 'EAB Office';
        insert newAccount;
        
        // create a Communication Template
        Communication_Template__c newCommunicationTemplate = new Communication_Template__c();
        newCommunicationTemplate.Name = 'Virtual Event';
        newCommunicationTemplate.RecordTypeId = calendarInviteRecordType;
        insert newCommunicationTemplate;
        
        Communication_Template__c newCommunication2Template = new Communication_Template__c();
        newCommunication2Template.Name = 'In-Person Event';
        newCommunication2Template.RecordTypeId = calendarInviteRecordType;
        insert newCommunication2Template;
        
        Advisory_Event__c testEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        testEvent.Meeting_GUID__c = '000-000-001';
        testEvent.Event_Type__c = 'Research Working Sessions';
        testEvent.Short_Name__c = 'testEvent';
        testEvent.Public_Name__c = 'testEvent';
        testEvent.Status__c = 'Open - Registration';
        testEvent.Begins__c = System.today()-3;
        testEvent.Ends__c = System.today()-1;
        insert testEvent;
        
        Advisory_Event__c testElevatedMealEvent = testUtilities.createEvent(elevatedMealRecordType, null, false);
        testElevatedMealEvent.Meeting_GUID__c = '000-000-001';
        testElevatedMealEvent.Event_Type__c = 'Research Working Sessions';
        testElevatedMealEvent.Short_Name__c = 'testEvent';
        testElevatedMealEvent.Public_Name__c = 'testEvent';
        testElevatedMealEvent.Status__c = 'Open - Registration';
        testElevatedMealEvent.Begins__c = System.today()-3;
        testElevatedMealEvent.Ends__c = System.today()-1;
        insert testElevatedMealEvent;
        
        
        //create 4 contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i=1; i<= 4 ; i++){
            Contact newContact = testUtilities.CreateNewContact(true); 
            contacts.add(newContact);
        }
        
        //create 4 registrations
        for(Contact contact : contacts) {
            Registration__c reg = Test_SiteMeetingController.CreateRegistration(testEvent.Id, contact.Id, true);
        }
        
        Util.ByPassAllTriggers = false;
    }
    
    static testMethod void testFetchEligibleRegistrationRecords(){
        
        //Lightning response entity instance 
        LightningResponseEntity res;
        
        //Get Registrations
        List<Registration__c> registrations = [SELECT Id, Status__c, EAB_Event__c,RecordTypeId, RSVP__c FROM Registration__c];
        
        //Usecase #1
        res = ResendAllCalendarInvitesController.fetchEligibleRegistrationRecords('');
        System.assertEquals(Label.Insufficient_Access_To_RecordId, res.message);
        
        //Usecase #2
        Util.ByPassAllTriggers = true;
        Advisory_Event__c eabEvent = [SELECT Id, Event_Format__c FROM Advisory_Event__c WHERE RecordTypeId = :elevatedMealRecordType];
        res = ResendAllCalendarInvitesController.fetchEligibleRegistrationRecords(eabEvent.Id);
        System.assertEquals('No Eligible Registrations Found on this EAB Event', res.message);
        
        for(Registration__c reg : registrations){
            reg.RecordTypeId = elevatedMealRegistrationsRTId;
            reg.RSVP__c = 'Yes';
            reg.EAB_Event__c = eabEvent.Id;
        }
        update registrations;
        res = ResendAllCalendarInvitesController.fetchEligibleRegistrationRecords(eabEvent.Id);
        Util.ByPassAllTriggers = false;
        
        //Usecase #3
        Util.ByPassAllTriggers = true;
        eabEvent = [SELECT Id, Event_Format__c FROM Advisory_Event__c WHERE RecordTypeId != :elevatedMealRecordType];
        eabEvent.Event_Format__c = 'Virtual';
        update eabEvent;
        res = ResendAllCalendarInvitesController.fetchEligibleRegistrationRecords(eabEvent.Id);
        System.assertEquals('No Eligible Registrations Found on this EAB Event', res.message);
        Util.ByPassAllTriggers = false;
        
        //Usecase #4
        Util.ByPassAllTriggers = true;
        eabEvent = [SELECT Id, Event_Format__c FROM Advisory_Event__c WHERE RecordTypeId != :elevatedMealRecordType];
        eabEvent.Event_Format__c = 'In-Person';
        update eabEvent;
        res = ResendAllCalendarInvitesController.fetchEligibleRegistrationRecords(eabEvent.Id);
        System.assertEquals('No Eligible Registrations Found on this EAB Event', res.message);
        Util.ByPassAllTriggers = false;
    }
    
    static testMethod void testSendCalenderInvites(){
        
        //Service Mock instance
        ZoomServicesMock mockService = new ZoomServicesMock();
        Httprequest httpReq = new Httprequest();
        //Initialize mock response
        mockService.methodName = 'callWebServiceToSendCommunicationtTemplate';
        mockService.statusCode = 201;
        HttpService.response = mockService.respond(httpReq);
        Test.setMock(HttpCalloutMock.class, mockService);
        
        Util.ByPassAllTriggers = true;
        
        //Lightning response entity instance 
        LightningResponseEntity res;
        
        //Get Registrations
        List<Registration__c> registrations = [SELECT Id, Status__c, EAB_Event__c,RecordTypeId, RSVP__c FROM Registration__c];
        
        //Usecase #1
        res = ResendAllCalendarInvitesController.sendCalenderInvites('',new List<Registration__c>());
        System.assertEquals('No eligible registrations found', res.message);
        
        //Usecase #2
        res = ResendAllCalendarInvitesController.sendCalenderInvites('',registrations);
        System.assertEquals(Label.Insufficient_Access_To_RecordId, res.message);
        
        //Usecase #3
        Advisory_Event__c eabEvent = [SELECT Id, Event_Format__c, Communication_Template__c, Ends__c, Zoom_Meeting_ID__c FROM Advisory_Event__c WHERE RecordTypeId = :elevatedMealRecordType];
        eabEvent.Communication_Template__c = null;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('Calendar Invite Template is blank on Event', res.message);
        
        Communication_Template__c inPersonCommTemp = [SELECT ID, Name FROM Communication_Template__c WHERE Name = 'In-Person Event' LIMIT 1];
        Communication_Template__c virtualCommTemp = [SELECT ID, Name FROM Communication_Template__c WHERE Name = 'Virtual Event' LIMIT 1];
        
        //Usecase #4
        eabEvent.Event_Format__c = 'Virtual';
        eabEvent.Communication_Template__c = inPersonCommTemp.Id;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('Event format is Virtual and calendar invite template is '+inPersonCommTemp.Name+'.', res.message);
        
        //Usecase #5
        eabEvent.Event_Format__c = 'In-Person';
        eabEvent.Communication_Template__c = virtualCommTemp.Id;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('Event format is In-Person and calendar invite template is '+virtualCommTemp.Name+'.', res.message);
        
        //Usecase #6
        eabEvent.Event_Format__c = 'Virtual';
        eabEvent.Communication_Template__c = virtualCommTemp.Id;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('Event Ends Time is in past', res.message);
        
        //Usecase #7
        eabEvent.Ends__c = System.today()+1;
        eabEvent.Zoom_Meeting_ID__c = null;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('Zoom information is not available on event', res.message);
        
        //Usecase #7
        eabEvent.Ends__c = System.today()+1;
        eabEvent.Event_Format__c = 'In-Person';
        eabEvent.Zoom_Meeting_ID__c = '00112244';
        eabEvent.Communication_Template__c = inPersonCommTemp.Id;
        update eabEvent;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        System.assertEquals('A primary venue must be associated with the EAB Event', res.message);
        
        //Usecase #8
        //crate primary venue
        Account account = [SELECT Id FROM Account WHERE RecordType.Name = 'Event Venue'];
        Venue__c venue = new Venue__c(Name = 'Test Venue', Venue__c = account.Id, Advisory_Event__c = eabEvent.Id, Primary__c = true, RecordTypeId = venueRType);
        insert venue;
        res = ResendAllCalendarInvitesController.sendCalenderInvites(eabEvent.Id,registrations);
        // bypass trigger to false
        Util.ByPassAllTriggers = false;
    }
}