/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
public class Test_SiteMeetingController {
    /**
    Purpose         :   Test class for SiteMeeting and SiteMeetingController classes
    
    Created By      :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
                        v1.1 - 06/13/2016 - Abhinav Sharma - CR-20150202-8633
                        v1.2 - 06/11/2019 - Victor Hanson - CR-20190611-13177 - added 
                        v1.3 - 03/30/2020 - Victor Hanson - CR-20200330-13895 - updated testPopulateMeetingLookup to check for meeting guid
                        v1.4 - Modify by - Abhinav Sharma - CR-20200729-14382 -10/26/2018 - Updated method is used to test the Registration Status when Event Type "Cohort" 
                        v1.5 - 09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c from Advisory_Event__c object
                        v1.6 - 10/10/2020 - Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
                        v1.7 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664 - Replaced EAB Event's Type with EAB Event's Event Type
                        v1.8 - 11/11/2020 - Saurabh Kumar - Replaced Status 'Scheduled' with 'Registration Requested' (Not Exist Scheduled picklist value)
                        v1.9 - 11/11/2020 - Saurabh Kumar - Modified testFindAllSubMeetings to increase coverage
						v2.0 - 01/08/2021 - Saurabh Kumar - CR-20210106-14781 - Modified testUpdateRegistration method to fix the failures. 
    **/
    public static Registration__c CreateRegistration(boolean CreateAndInsert) {
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c registration = CreateRegistration(newContact.Id, CreateAndInsert);
        return registration;
    }
    
    //Updated by Saurabh Kumar - 10/10/2020 - CR-20200819-14447 - Replaced Meeting with EAB Event
    public static Registration__c CreateRegistration(Id contactId, boolean CreateAndInsert) {
        
        // create the meeting
        //Meeting__c meeting = CreateMeeting(true);
        Advisory_Event__c eabEvent = createEABEvent(true);
        
        // create the registration
        Registration__c registration = CreateRegistration(eabEvent.Id, contactId, CreateAndInsert);
        
        return registration;
    }
    
    //Updated by Saurabh Kumar - 10/10/2020 - CR-20200819-14447 - Replaced Meeting with EAB Event
    public static Registration__c CreateRegistration(Id eabEvent, Id contactId, boolean CreateAndInsert) {
        
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.EAB_Event__c = eabEvent;
        //Modified by Saurabh Kumar - 11/11/2020 - Replaced Status 'Scheduled' with 'Registration Requested'
        registration.Status__c = 'Registration Requested';
        
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    //Added by Saurabh Kumar - 10/10/2020 - CR-20200819-14447
    public static Advisory_Event__c createEABEvent(boolean CreateAndInsert){
        
        Advisory_Event__c eabEvent = new Advisory_Event__c();
        eabEvent.Begins__c = system.now();
        eabEvent.Event_Type__c = 'Research Working Sessions';//v1.6 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664 - Replaced EAB Event's Type with EAB Event's Event Type
        //Added Cohort Record Type By Saurabh Kumar - 11/11/2020
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        if (CreateAndInsert) insert eabEvent;
        return eabEvent;
    }
    
    /*public static Meeting__c CreateMeeting(boolean CreateAndInsert) {
    
    // create the meeting
    Meeting__c meeting = new Meeting__c();
    meeting.DateTime__c = system.now();
    meeting.Type__c = 'Onsite';
    meeting.Site__c = 'EAB.com';
    
    if (CreateAndInsert) insert meeting;
    return meeting;
    }*/
    
    /**
    * @description     : test the populateMeetingLookup method
    * 
    * @revision log    : 06/11/2019 - Victor Hanson - Created for CR-20190611-13177
    : 03/30/2020 - Victor Hanson - CR-20200330-13895 - verify meeting_guid is populated on meeting wrappers
    : 10/10/2020 - Saurabh Kumar - CR-20200819-14447 - Replaced Meeting with EAB Event
    **/
    static testMethod void testPopulateMeetingLookup() {
        //Modified By Saurabh Kumar - 11/11/2020 - Replaced Series Record Type with Cohort Record Type
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Meeting_GUID__c = '000-000-001';
        insert eSeries;
        //create the 2 event records as child of series
        Advisory_Event__c childEvent1 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEvent1.Parent_Event__c = eSeries.Id;
        childEvent1.Meeting_GUID__c = '000-000-002';
        Advisory_Event__c childEvent2 = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        childEvent2.Parent_Event__c = eSeries.Id;
        childEvent2.Meeting_GUID__c = '000-000-003';
        List<Advisory_Event__c> childEvents = new List<Advisory_Event__c> { childEvent1, childEvent2 };
            insert childEvents;
        
        //create meetings that correspond to the advisory event structure that was just created
        //Meeting__c parentMeeting = CreateMeeting(false);
        Advisory_Event__c parentEABEvent = createEABEvent(false);
        parentEABEvent.Meeting_GUID__c = null; //test that this gets populated via populateEABEventLookup method
        //Modified By Saurabh Kumar - 11/11/2020 - Replaced Series Record Type with Cohort Record Type
        parentEABEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        insert parentEABEvent;
        //create 2 child meetings
        //Meeting__c childMeeting1 = CreateMeeting(false);
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = parentEABEvent.Id;
        childEABEvent1.Meeting_GUID__c = childEvent1.Meeting_GUID__c;
        //Modified By Saurabh Kumar - 11/11/2020 - Replaced Series Record Type with Breakout Record Type
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = parentEABEvent.Id;
        childEABEvent2.Meeting_GUID__c = childEvent2.Meeting_GUID__c;
        //Modified By Saurabh Kumar - 11/11/2020 - Replaced Series Record Type with Breakout Record Type
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        List<Advisory_Event__c> childEABEvents = new List<Advisory_Event__c> { childEABEvent1, childEABEvent2 };
            insert childEABEvents;
        
        //get the meetings
        List<Advisory_Event__c> eabEvents = [SELECT Id FROM Advisory_Event__c];
        system.assertEquals(6, eabEvents.size());
        
        //verify the field is populated correctly
        //for (Meeting__c m : meetings) {
        //  system.assertNotEquals(null, m.EAB_Event__c, 'EAB Event should be populated because the Meeting GUID is the same as an existing EAB Event');
        //}
        
        //get the EAB Events
        //v1.4 - 09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c
        List<Advisory_Event__c> eabEvnts = [SELECT Id FROM Advisory_Event__c];
        system.assertEquals(6, eabEvnts.size());
        
        //verify the field is populated correctly
        //v1.4 - 09/23/2020 - Saurabh Kumar - CR-20200819-14449 - Removed the reference of Meeting__c
        //for (Advisory_Event__c m : eabEvents) {
        //system.assertNotEquals(null, m.Meeting__c, 'Meeting should be populated because the Meeting GUID is the same as an existing meeting');
        //}
        
        //Start testing from here
        Test.startTest();
        
        parentEABEvent = [SELECT Id, Meeting_Guid__c, Website_Tag__c FROM Advisory_Event__c WHERE Id = :parentEABEvent.Id];
        
        //Creating our encrypted string with meeting id and contact Id
        String requestString = '{"MeetingGUID":"' + parentEABEvent.Meeting_GUID__c + '","WebsiteTagID":"'+parentEABEvent.Website_Tag__c+'","Command":"FindMeetings"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        //System.assertEquals(3, cMeeting.mWrapper.Meetings.size());
        // VH added 03/30/2020 to verify meeting guid
        //System.assertNotEquals(null, cMeeting.mWrapper.Meetings[0].meeting_guid);
        
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the decryption functionality of SiteMeeting class.
    * 
    **/
    static testMethod void testDecryption() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        List<Registration__c> registrations = [SELECT Id FROM Registration__c];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":"' + registration.Id + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Start test from here
        Test.startTest();
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the find registrations for registration Id based functionality 
    * 					of SiteMeeting class. 
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447 : Replaced Meeting with EAB Event
    **/
    static testMethod void testFindRegistrations_RegistrationId() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(false);
        newContact.FirstName = 'Joe';
        newContact.LastName = 'Testerson';
        insert newContact;
        
        // create a new registration
        Registration__c registration = CreateRegistration(newContact.Id, false);
        
        // create a second contact and a registration for the same meeting
        Contact contact2 = testUtilities.CreateNewContact(true);
        Registration__c registration2 = CreateRegistration(registration.EAB_Event__c, contact2.Id, false);
        
        // add both registrations to a list and insert them at the same time
        List<Registration__c> registrationsToInsert = new List<Registration__c> { registration, registration2 };
            insert registrationsToInsert;
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":"' + registration.Id + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns both of the registrations
        system.assertEquals(true, decryptedResponse.contains('Testerson'));
        system.assertEquals(2, cMeeting.mWrapper.Registrations.size());
        
        //Initilization inner class
        SiteMeeting.MeetingWrapper meetingWrapper = new SiteMeeting.MeetingWrapper();
        
        //Setting controller's variable
        meetingWrapper.EndpointURL = 'www.testing.com';
        meetingWrapper = cMeeting.mWrapper;
        
        //Asserting for the results
        System.assert(meetingWrapper != null);
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the find registrations for meeting Id based functionality 
    * 					of SiteMeeting class. 
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    **/
    static testMethod void testFindRegistrations_MeetingId() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(false);
        newContact.FirstName = 'Joe';
        newContact.LastName = 'Testerson';
        insert newContact;
        
        // create a new registration
        Registration__c registration = CreateRegistration(newContact.Id, false);
        
        // create a second contact and a registration for the same meeting
        Contact contact2 = testUtilities.CreateNewContact(true);
        Registration__c registration2 = CreateRegistration(registration.EAB_Event__c, contact2.Id, false);
        
        // add both registrations to a list and insert them at the same time
        List<Registration__c> registrationsToInsert = new List<Registration__c> { registration, registration2 };
            insert registrationsToInsert;
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","EABEventId":"' + registration.EAB_Event__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        system.assertEquals(true, decryptedResponse.contains('Registration Requested'));
        
        // make sure it returns the registration that was created
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(registration.Id).subString(0, 15)));
        
        // make sure it returns both of the registrations
        system.assertEquals(2, cMeeting.mWrapper.Registrations.size());
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check and assert for various use cases where find registration based
    * 					functionality will results as an error.
    **/
    static testMethod void testFindRegistrations_error() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","RegistrationId":""}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Start Test from here
        Test.startTest();
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('At least one of the following fields must be filled in'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check and assert for various use cases where find meetings based
    * 					functionality will results as an error.
    * 		    : Modified by - Saurabh Kumar - 10/10/2020 - CR-20200819-14447 : Replaced Meeting with EAB Event
    **/
    static testMethod void testFindMeetings_error() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a contact 
        Contact contact = testUtilities.CreateNewContact(true);
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        //Start testing here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":"' + contact.Id + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        //## system.assertEquals(true, decryptedResponse.contains('EAB Event Id and Contact Id or Registration Id are required'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the find meetings for registration Id based functionality 
    * 					of SiteMeeting class. 
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447 : Replaced Meeting with EAB Event
    **/
    static testMethod void testFindMeetings_RegistrationId() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        //Registration__c registration0 = CreateRegistration(true);
        Advisory_Event__c eabEvents0 = createEABEvent(false);
        eabEvents0.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        insert eabEvents0;
        
        // create a child meeting from the one created above
        //Meeting__c childMeeting1 = CreateMeeting(false);
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = eabEvents0.Id;
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent1;
        
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = eabEvents0.Id;
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent2;
        
        //Creating a Contact record
        Contact contact = testUtilities.CreateNewContact(true);
        
        Registration__c registration1 = CreateRegistration(childEABEvent1.Id, contact.Id, true);
        Registration__c registration2 = CreateRegistration(childEABEvent2.Id, contact.Id, true);
        
        //Start testing from here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegisteredSubMeetings","RegistrationId":"' + eabEvents0.Id + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        /*system.assertEquals(true, decryptedResponse.contains('Success'));

        // make sure it returns only 2 child registration
        system.assertEquals(2, cMeeting.mWrapper.Meetings.size());
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent1.Id).subString(0, 15)));
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent2.Id).subString(0, 15)));
        */
        //Creating our encrypted string with Contant Id and Meeting Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":"' + contact.Id + '","EABEventId":"' + eabEvents0.Id + '"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid registration Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":null,"EABEventId":"' + eabEvents0.Id + '","RegistrationId":"Test"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the find meetings by user based functionality 
    * 					of SiteMeeting class. 
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447 : Replaced Meeting with EAB Event
    **/
    static testMethod void testFindMeetingsByUser() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(true);
        
        // create a child meeting from the one created above
        //Meeting__c childMeeting1 = CreateMeeting(false);
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent1;
        
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent2.Begins__c = datetime.valueOf('2016-06-08 07:23:00');
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent2;
        
        Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        // create our encrypted string
        String requestString = '{"Command":"FindMeetingsByUser","ContactId":"' + registration0.Contact__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns only 2 child registration
        system.assertEquals(3, cMeeting.mWrapper.Meetings.size());
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent1.Id).subString(0, 15)));
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent2.Id).subString(0, 15)));
        
        //Creating our encrypted string with blank Contact Id
        requestString = '{"Command":"FindMeetingsByUser","ContactId":""}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Contact Id is required.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        system.assertEquals(true, decryptedResponse.contains('Contact Id is required.'));
        
        //create our encrypted string with invalid command
        requestString = '{"Command":"Testing","ContactId":""}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the resultss
        System.assertEquals('Testing', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals(true, cMeeting.mWrapper.Response.contains('Error: Unrecognized command:'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: Unrecognized command:'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check out for various use cases associated with the delete registration functionality 
    * 					of SiteMeeting class.
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447: Replaced Meeting with EAB Event 
    **/
    static testMethod void testDeleteRegistration() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        // create a new registration
        Registration__c registration = CreateRegistration(true);
        
        // delete the registration having ContactId as null
        String requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","ContactId":null,"Command":"DeleteRegistration"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        system.debug('@@decryptedResponse:' + decryptedResponse);
        
        // Attempt to find the original reg
        List<Registration__c> registrations = [SELECT Id FROM Registration__c WHERE Id = :registration.Id];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        system.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        //Start testing from here
        Test.startTest();
        
        //Creating our encrypted string 
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-initilization a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        
        //Creating our encrypted string having registration Id is null
        requestString = '{"MeetingId":"'+ registration.EAB_Event__c + '","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-initilization a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        //System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        //System.assertNotEquals(null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        //System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        //System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string having contact id is null
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","ContactId":null,"RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-initilization a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Invalid Registration Id.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Creating our encrypted string having registration Id is invalid
        requestString = '{"EABEventId":"test","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-initilization a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Invalid Meeting Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Meeting Id.'));
        
        //Creating our encrypted string having Contact Id is invalid
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","ContactId":"test" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-initilization a new SiteMeeting object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Invalid Contact Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Contact Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
    * @description : Test method to check and assert for FindAllSubMeetings method based use cases.
    * 		    : Modified by Saurabh Kumar - 10/10/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    * 
    **/
    static testMethod void testFindAllSubMeetings() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create a Meeting
        //Meeting__c parentMeeting = CreateMeeting(false);
        Advisory_Event__c parentEABEvent = createEABEvent(false);
        parentEABEvent.Begins__c = system.now();
        parentEABEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        insert parentEABEvent;
        System.assertNotEquals(null, parentEABEvent.Id);
        
        //Create a Meeting with parent
        //Meeting__c meeting = CreateMeeting(false);
        Advisory_Event__c eabEvent = createEABevent(false);
        eabEvent.Parent_Event__c = parentEABEvent.Id;
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert eabEvent;
        System.assertNotEquals(null,eabEvent.Id);
        
        //Create a Contact
        Contact contact = testUtilities.CreateNewContact(true);
        System.assertNotEquals(null, contact.Id);
        
        // create a new registration
        Registration__c registration = CreateRegistration(eabEvent.Id, contact.Id, true);
        System.assertNotEquals(null, registration.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Creating our encrypted string with meeting id and contact Id
        String requestString = '{"EABEventId":"' + parentEABEvent.Id + '","ContactId":"' + registration.Contact__c + '","Command":"FindAllSubMeetings"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        blob encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        String decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting registration with null MeetingId
        requestString = '{"EABEventId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindAllSubMeetings"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating encrypted string with Meeting Id and Registration Id are null
        requestString = '{"EABEventId": null ,"RegistrationId": null ,"Command":"FindAllSubMeetings"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('EAB Event Id or Registration Id are required.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('EAB Event Id or Registration Id are required.'));
        
        //Creating encrypted string with Meeting Id and Contact Id 
        requestString = '{"EABEventId":"'+ eabEvent + '","ContactId":"' + registration.Contact__c + '","Command":"FindMeetings"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting the registration with null MeetingId
        requestString = '{"EABEventId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with Parent Meeting Id
        requestString = '{"ParentMeetingId":"' + registration.EAB_Event__c + '","RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting))); 
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid Registration Id
        requestString = '{"EABEventId":null,"Command":"FindAllSubMeetings", "RegistrationId":"123"}';
        encryptedString = EncryptionHelper.encryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        System.assertNotEquals(Null, EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Generating exception
        cMeeting = new SiteMeeting(null);
        
        //Asserting for the results
        System.assertEquals(true,cMeeting.mWrapper.Response.contains('Error: '));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(EncryptionHelper.encryptString(JSON.serialize(cMeeting)));
        decryptedResponse = EncryptionHelper.decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: '));
        
        //Added By Saurabh Kumar - 11/11/2020 - To increase coverge
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        eabEvents.add(parentEABEvent);
        eabEvents.add(eabEvent);
        Map<Id,Advisory_Event__c> eabEventMap = new Map<Id,Advisory_Event__c>();
        eabEventMap.put(parentEABEvent.Id, parentEABEvent);
        eabEventMap.put(eabEvent.Id, eabEvent);
        SiteMeeting.checkMeetingSync(eabEvents,eabEventMap);
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8634 - To refactor the existing code
    /**
    * @description : Test method to check the functionality of Initialize method of SiteMeetingController class.
    * 
    **/
    static testMethod void testSiteMeetingController(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Setting current page parameter
        ApexPages.currentPage().getParameters().put('req','test');
        
        //Start testing from here
        Test.startTest();
        
        //Instantiate a new SiteMeetingController object
        SiteMeetingController controller = new SiteMeetingController();
        
        //Calling controller's method
        controller.Initialize();   
        
        //Asserting for the results
        System.assertNotEquals(null, controller.JSONResponse);
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20200729-14382 - update the existing code
    /**
    * @description : Test method to check and assert for UpsertRegistration method based use cases.
    * 
    **/
    static testMethod void testUpdateRegistration() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eSeries.Meeting_GUID__c = '000-000-001';
        
        //Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) - Picklist value is Inactive - Start From Here
        //eSeries.Event_Type__c = 'Cohort';
        eSeries.Event_Type__c = 'Cohort';
        //Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) - Method for status change is commented in main class
            
        insert eSeries;
        
        //Create a Meeting
        //Meeting__c parentMeeting = CreateMeeting(false);
        
        Advisory_Event__c parentEabEvent = createEABevent(false);
        parentEabEvent.Begins__c = system.now();
        parentEABEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;//Updated by Saurabh Kumar - 01/08/2021 - CR-20210106-14781: Updated record type from Breakout to Cohort
        insert parentEabEvent;
        
        System.assertNotEquals(null, parentEabEvent.Id);
        
        //Meeting__c meeting = CreateMeeting(false);
        Advisory_Event__c eabEvent = createEABevent(false);
        eabEvent.Parent_Event__c = parentEABEvent.Id;
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert eabEvent;
        
        
        //Create a Contact
        Contact contact = testUtilities.CreateNewContact(true);
        System.assertNotEquals(null, contact.Id);
        
        // create a new registration
        Registration__c registration = CreateRegistration(eabEvent.Id, contact.Id, true);
        registration.status__c = 'Registration Requested';
        registration.EAB_Event__c = eabEvent.Id;
        registration.Approval_Status__c = '';
        update registration;
        System.assertNotEquals(null, registration.Id);
        
        //Start testing from here  
        Test.startTest();
        
        //Creating our encrypted string with meeting id and contact Id
        String requestString = '{"EABEventId":"' + eabEvent.Parent_Event__c + '","Status":"' + registration.status__c + '","ContactId":"' + registration.Contact__c + '","Command":"upsertRegistration"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting cMeeting = new SiteMeeting(encryptedString);
        
        //Asserting for the results
        List<Registration__c> registrationList = [Select Approval_Status__c From Registration__c where Approval_Status__c != null];
        System.assertEquals('upsertRegistration', cMeeting.mWrapper.Command);
        //System.assertEquals('Approved', registrationList[0].Approval_Status__c );
        
        //Stop testing here
        Test.stopTest();
    }
}