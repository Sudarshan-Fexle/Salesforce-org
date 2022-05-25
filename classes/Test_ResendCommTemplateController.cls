/**
 * 	Description 	:	test class for ResendCommTemplateController
 * 
 * 	Revision Logs	:	V1.0 - 05/04/2020 - Dipesh Gupta - Created
 * 				V1.1 - 08/04/2020 - CR-20200804-14400 - Victor Hanson - removed references to Calendar Hold Sent field as it is no longer in use
 *				V1.2 - 10/13/2020 - Saurabh Kumar - CR-20200819-14447 : Replaced Meeting with EAB Event
 *				V1.3 - 11/11/2020 - Saurabh Kumar - CR-20200819-14447 : Increase Coverage of testResendTemplatedCallout Method
 *				V1.4 - 09/01/2021 - Chirag Soni - Test class code coverage increase
 *				V1.5 - 10/12/2021 - Chirag Soni - CR-20210628-15254   - Modified the setup method - Updated Communication template Name From "Zoom National" to "Virtual Event"						
 *              		V1.6 - 01/13/2022 - CR-20220112-15701 - Chirag Soni -Commented test case for Event is not compatible to send the Template.
 **/
@isTest
public class Test_ResendCommTemplateController {
      
    //Service Mock instance
    public static ZoomServicesMock mockService = new ZoomServicesMock();
    
    public static LightningResponseEntity lightningResEntity = new LightningResponseEntity();
    
    //HttpRequest instance
    static Httprequest httpReq = new Httprequest();

    private static String meetingGUID = '000-000-001';
    private static String zoomMeetingId = '123-345-678';
    public static final String calendarInviteRecordType = Schema.SObjectType.Communication_Template__c.getRecordTypeInfosByDeveloperName().get('Calendar_Invite').getRecordTypeId();
    
    
    /**
     * 
     * @description : setup the registration and supporting records
     * @Version     : V_1.0 - Modified by - Chirag Soni - CR-20210628-15254 - 10/12/2021 - Updated the Communication template Name From "Zoom National" to "Virtual Event"
     **/
    @testSetup static void setup() {
        util.bypassAllTriggers = true;
        
        // create a Communication Template
        Communication_Template__c newCommunicationTemplate = new Communication_Template__c();
        //Updated by - Chirag Soni - CR-20210628-15254 - 10/12/2021 - Updated the Name From "Zoom National" to "Virtual Event"
        newCommunicationTemplate.Name = 'Virtual Event';
        newCommunicationTemplate.Event_Type__c = 'Virtual National Meeting';
        newCommunicationTemplate.RecordTypeId = calendarInviteRecordType;
        insert newCommunicationTemplate;
        
        //Insert Program
        Program__c prog = new Program__c(Name = 'TestProg', Entity__c = 'All',Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog; 
        
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Meeting_GUID__c = '000-000-001';
        eSeries.Event_Type__c = 'Research Working Sessions';
        insert eSeries;
        
        //create meetings that correspond to the advisory event structure that was just created
        //Meeting__c parentMeeting = Test_SiteMeetingController.CreateMeeting(false);
        Advisory_Event__c parentEABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        parentEABEvent.Parent_Event__c = eSeries.Id;
        parentEABEvent.Meeting_GUID__c = '000-000-001';
        parentEABEvent.Event_Type__c = 'Research Working Sessions';
        parentEABEvent.Short_Name__c = 'Test';
        parentEABEvent.Public_Name__c = 'Test2';
        parentEABEvent.Status__c = 'Open - Registration';
        parentEABEvent.Begins__c = System.today();
        parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        
        
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(parentEABEvent.Id, newContact.Id, true);
        
        Util.bypassAllTriggers = false;
        
    }
    //Modified by - Chirag Soni - 10/19/2021 - CR-20210628-15254 - Issue fixes and increased the code coverage (almost Method is modified)
    static testMethod void testResendTemplatedCallout() {
         
        //Initialize mock response
        mockService.methodName = 'callWebServiceToSendCommunicationtTemplate';
        mockService.statusCode = 200;
        HttpService.response = mockService.respond(httpReq);
        
        //System.assert(false, [SELECT Id, Meeting_GUID__c FROM Advisory_Event__c]);
        //meetingGUID = 'AAAAAAAA-0000-0000-0000-0000FF106258';
        //test start here
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, mockService);
        //get the registration
        //Use Case 1 -  EAB Event equal to null
        Registration__c reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.EAB_Event__c = null;
        String recordId = '{"record":"'+reg.Id+'"}';
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        update reg;
        
        //Update registration
        Advisory_Event__c eabEvent1 = [SELECT Id FROM Advisory_Event__c Order By CreatedDate DESC Limit 1];
        //Update registration
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.EAB_Event__c = eabEvent1.Id;
               
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('EAB Event is not added to the Registration.',lightningResEntity.message);
       
        //Use Case 2  -  Status__c != RegistrationHelper.STATUS_REGISTERED
        //Update Registration status
        util.bypassAllTriggers = true;
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.EAB_Event__c = eabEvent1.Id;
        reg.Status__c = RegistrationHelper.STATUS_CANCELLED;
        reg.Cancellation_Reason__c = 'test';
        update reg;
        
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Registration status should be registered before sending the Template.',lightningResEntity.message);
        
        /*
        //Use Case 3 - String.isblank(reg.Zoom_Participant_URL__c)
        util.bypassAllTriggers = true;
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.Zoom_Participant_URL__c = '';
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        update reg;
        recordId = '{"record":"'+reg.Id+'"}';
        
        
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Participant URL should not be blank before sending the Template.',lightningResEntity.message);*/
        
        //Use case 4 - String.isBlank(reg.EAB_Event__r.Communication_Template__r.Name)
        
        Communication_Template__c newCommTemplate = [SELECT Id, Name, Event_Type__c, RecordTypeId FROM Communication_Template__c];
   
        util.bypassAllTriggers = true;
       
        //Modified by Saurabh Kumar - 11/11/2020 - Populate Communication Template On EAB Event record
        Advisory_Event__c eSeries = [SELECT Id,Public_Name__c,Event_Type__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c ];
        eSeries.Communication_Template__c = null;
        
        update eSeries;
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        //reg.Zoom_Participant_URL__c = 'https://zoom.us/';
        //update reg
        update reg;
        
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('No Communication Template added to the Eab Event.',lightningResEntity.message);
        
        
        //Use case 5 - String.isBlank(reg.EAB_Event__r.Event_Type__c)
        
        util.bypassAllTriggers = true;
        
        //01/13/2022 - CR-20220112-15701 - Chirag Soni -Commented test case for Event is not compatible to send the Template.
    	/*eSeries.Communication_Template__c = newCommTemplate.Id;
        eSeries.Event_Type__c = '';
        
        update eSeries;
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Event is not compatible to send the Template.',lightningResEntity.message);
        
        
        eSeries.Event_Type__c = 'Virtual National Meeting';
        eSeries.Ends__c = Datetime.now().addDays(1);
        update eSeries;*/
        
        //Commented by - Chirag Soni - CR-20210628-15254 - 10/19/2021 - Use case moved into use case 15 - From Here
        /*
        //Use Case 7 -  String.isBlank(reg.EAB_Event__r.Zoom_DialIn_Number__c)
        util.bypassAllTriggers = true;
    	eSeries.Public_Name__c = 'test';
        eSeries.Zoom_DialIn_Number__c = '';
    	//update eabEvent
        update eSeries;

        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Dial In should have value on Eab Event',lightningResEntity.message);*/
        
        /*
        //Use Case 8 - String.isBlank(reg.EAB_Event__r.Zoom_Meeting_ID__c)
        util.bypassAllTriggers = true;
        eSeries.Zoom_Meeting_ID__c = '';
    	eSeries.Zoom_DialIn_Number__c = '+1 (312) 626-6799';
        update eSeries;
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Meeting Id should have value on Eab Event',lightningResEntity.message);*/
        //Commented by - Chirag Soni - CR-20210628-15254 - 10/19/2021 - Use case moved into use case 15 - Till Here
        
        //Use Case 9 - (reg.EAB_Event__r.Begins__c == null)
        util.bypassAllTriggers = true;
        //Meeting__c meeting = [SELECT Id FROM Meeting__c WHERE Meeting_GUID__c = :meetingGUID Limit 1];
        eSeries = [SELECT Id,Public_Name__c,Event_Type__c, Communication_Template__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c ];
        eSeries.Public_Name__c = 'test3';
        eSeries.Begins__c = null;
        eSeries.Communication_Template__c = newCommTemplate.Id;
        eSeries.Event_Type__c = 'Virtual National Meeting';
    	//eabEvent.Zoom_Meeting_ID__c = zoomMeetingId;
    	//Update eabEvent
        update eSeries;
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('EAB Event Start Time is should have value.',lightningResEntity.message);
        
        //Use Case 10 - (reg.EAB_Event__r.Ends__c == null)
        util.bypassAllTriggers = true;
        //Modified by Saurabh Kumar - 11/11/2020 - Added End date for null and apply assert for Meeting End Time
        eSeries.Begins__c = Datetime.now().addDays(-5);
        eSeries.Ends__c = null;

    	//update eabEvent
        update eSeries;

    	recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Meeting End Time is should have value.',lightningResEntity.message);
        
         //Use Case 6 - String.isBlank(reg.EAB_Event__r.Public_Name__c)
         /* Comment out this use case because public name can not be blank because of WF rule - Advisory Event: Default Public Name
        util.bypassAllTriggers = true;
    	eSeries.Public_Name__c = null;
        eSeries.Event_Type__c = 'Research Working Sessions';
        //update eabEvent
        update eSeries;
        System.debug('event '+eSeries.Id+' event public name '+eSeries.Public_Name__c+' Registration EAB Event '+reg.EAB_Event__c);
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Public Name should have value on Eab Event.',lightningResEntity.message); */
        
        
        //Use Case 11 - reg.EAB_Event__r.Ends__c < DateTime.now()
        util.bypassAllTriggers = true;
        //Modified by Saurabh Kumar - 11/11/2020 - Added End date for null and apply assert for Meeting End Time
        eSeries = [SELECT Id,Public_Name__c,Event_Type__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c ];
        eSeries.Ends__c = Datetime.now().addDays(-1);

    	//update eabEvent
        update eSeries;

    recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('EAB Event End Time is in the past.',lightningResEntity.message);
        
        //Use Case 12 - String.isBlank(reg.Contact__c)
        util.bypassAllTriggers = true;
        eSeries.Ends__c = Datetime.now().addDays(2);
        //update eabEvent
        update eSeries;
            
        reg.Contact__c = null;
        update reg;
        
    	recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Registration should have contact populated.',lightningResEntity.message);
        
        
        //Use Case 13 - String.isBlank(reg.Contact__r.Company_Email__c)
        util.bypassAllTriggers = true;
        Contact contact = [Select Id,Company_Email__c,Email From Contact Limit 1];
        contact.Email = null;
        reg.Contact__c = contact.Id;
    	//update eabEvent
        update contact;
        update reg;
    	recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Contact should have Email.',lightningResEntity.message);
        
        contact.Company_Email__c = 'test@abc.com';
        contact.Email = 'test@abc.com';
        update contact;
        
    
        //Use Case 14 - (reg.Status__c == RegistrationHelper.STATUS_VOID || reg.Status__c == RegistrationHelper.STATUS_CANCELLED);
        
        util.bypassAllTriggers = true;
        reg = [SELECT Id, Status__c,EAB_Event__c, Automated_Update__c FROM Registration__c WHERE Id=: reg.Id];
    	reg.Status__c = RegistrationHelper.STATUS_VOID;
        reg.Automated_Update__c = true;
        
        //Use Case 15  -  (reg.EAB_Event__r.Event_Format__c!= null && (reg.EAB_Event__r.Event_Format__c == 'Virtual' || reg.EAB_Event__r.Event_Format__c == 'Hybrid')
        eSeries = [SELECT Id,Event_Format__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c ];
        eSeries.Event_Format__c = 'Virtual';
        Update eSeries;
        //Use Case 15.1 - String.isblank(reg.Zoom_Participant_URL__c)
        util.bypassAllTriggers = true;
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        reg.Zoom_Participant_URL__c = '';
        reg.Status__c = RegistrationHelper.STATUS_REGISTERED;
        update reg;
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Participant URL should not be blank before sending the Template.',lightningResEntity.message);
        
        
        //Use Case 15.2 - String.isBlank(reg.EAB_Event__r.Zoom_DialIn_Number__c)
        util.bypassAllTriggers = true;
        eSeries.Zoom_DialIn_Number__c = '';
    	//update eabEvent
        update eSeries;
        //update zoom participant URL
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
    	reg.Zoom_Participant_URL__c = 'https://zoom.us/';
        update reg;
        
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Dial In should have value on Eab Event',lightningResEntity.message);
        
        //Use Case 15.3 - String.isBlank(reg.EAB_Event__r.Zoom_Meeting_ID__c)
        util.bypassAllTriggers = true;
        eSeries.Zoom_Meeting_ID__c = '';
    	eSeries.Zoom_DialIn_Number__c = '+1 (312) 626-6799';
        update eSeries;
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('Zoom Meeting Id should have value on Eab Event',lightningResEntity.message);
        
        
        //Use Case 16 - (String.isblank(venueName) && reg.EAB_Event__r.Event_Format__c == "In-Person")
        Advisory_Event__c eabEvent = [SELECT Id,Event_Format__c FROM Advisory_Event__c WHERE Id =: reg.EAB_Event__c];
        eabEvent.Event_Format__c = Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT;
    	eabEvent.Zoom_Meeting_ID__c = '91925865240';
        Update eabEvent;
        
        util.bypassAllTriggers = true;
        reg = [SELECT Id, EAB_Event__c, Status__c FROM Registration__c LIMIT 1];
        recordId = '{"record":"'+reg.Id+'"}';
        lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);
        System.assertEquals('A primary venue must be associated with the EAB Event if Event Format = In-Person',lightningResEntity.message);
        
        //Update reg;
        
        //recordId = '{"record":"'+reg.Id+'"}';
        //lightningResEntity = ResendCommTemplateController.resendTemplatedCallout(recordId);

        test.stopTest();   
    }
}