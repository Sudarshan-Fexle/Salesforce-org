/**
*   Purpose         :     Test class for Schedule_CommunicationTemplateService class
*            
*   Create By       :	  Chirag Soni
* 
*   Created Date    :     10/28/2021
*
*   Revision Log    :     V_1.0 - Created - CR-20211025-15548
*			    	  
*   Coverage        :     80%
**/ 

@isTest (SeeAllData = false)
private class Test_SchedCommunicationTemplateService {
    
    //Service Mock instance
    public static ZoomServicesMock mockService = new ZoomServicesMock();
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();
    public static final String calendarInviteRecordType = Schema.SObjectType.Communication_Template__c.getRecordTypeInfosByDeveloperName().get('Calendar_Invite').getRecordTypeId();
    
    @testSetup static void setup() {
        
        Util.BypassAllTriggers = true;
        
        // create a Communication Template
        Communication_Template__c newCommunicationTemplate = new Communication_Template__c();
        
        newCommunicationTemplate.Name = 'In-Person Event';
        newCommunicationTemplate.Event_Type__c = 'Virtual National Meeting';
        newCommunicationTemplate.RecordTypeId = calendarInviteRecordType;
        insert newCommunicationTemplate;
        
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Meeting_GUID__c = '000-000-001';
        eabEvent.Event_Type__c = 'Research Working Sessions';
        eabEvent.Short_Name__c = 'Test';
        eabEvent.Public_Name__c = 'Test';
        eabEvent.Status__c = 'Open - Registration';
        eabEvent.Begins__c = System.today();
        eabEvent.Ends__c = System.today();
        eabEvent.Event_Format__c = Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT;
        eabEvent.Communication_Template__c = newCommunicationTemplate.Id;
        eabEvent.Location__c = 'test';
        insert eabEvent;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(eabEvent.Id, newContact.Id, true);
        
        Util.BypassAllTriggers = false;
    }
    
    static testmethod void testCallCommunicationTemplateService(){
        
        //Initialize mock response
        mockService.methodName = 'callWebServiceToSendCommunicationtTemplate';
        mockService.statusCode = 200;
        HttpService.response = mockService.respond(httpReq);
        
        Util.BypassAllTriggers = true;
        
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        
        update reg;
        Util.BypassAllTriggers = false;
        
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, mockService);
        Schedule_CommunicationTemplateService schCommunication = new Schedule_CommunicationTemplateService(new set<Id>{reg.Id}, Constants.HTTP_REQUEST_POST_TYPE, false);  
        Schedule_CommunicationTemplateService.callCommunicationTemplateService(new set<Id>{reg.Id}, Constants.HTTP_REQUEST_POST_TYPE, false);
        
        test.stopTest();
        
        Registration__c registration = [SELECT Id, Calendar_Hold_Sent__c, Status__c FROM Registration__c LIMIT 1];
        
        System.assertEquals(true, String.isNotBlank(registration.Calendar_Hold_Sent__c));
        
    }
}