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
private class TestCrimsonMeetingController {
/**
    Purpose         :   Test class for CrimsonMeeting and CrimsonMeetingController classes
                
    Created By      :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
                        v2.0 - 06/13/2016 - Abhinav Sharma - CR-20150202-8633
                        v3.0 - 10/09/2020 - Saurabh Kumar - CR-20200819-14447: Replaced Meeting with EAB Event
			v4.0 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664: Replaced EAB Event's Type with EAB Event's Event
                        v5.0 - 11/10/2020 - Saurabh Kumar - Replaced Status 'Scheduled' with 'Registration Requested' (Not Exist Scheduled picklist value)
                        v6.0 - 11/10/2020 - Saurabh Kumar - Replaced Series Record Type with Cohort Record Type & Added Cohort for Parent Event and 
                        				    Breakout for Child Event

    Coverage Log    :   

**/
    public static Registration__c CreateRegistration(boolean CreateAndInsert) {
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c registration = CreateRegistration(newContact.Id, CreateAndInsert);
        return registration;
    }
    
    public static Registration__c CreateRegistration(Id contactId, boolean CreateAndInsert) {
        
        // create the meeting
        //Meeting__c meeting = CreateMeeting(true);
        Advisory_Event__c eabEvent = createEABEvent(true);
        // create the registration
        Registration__c registration = CreateRegistration(eabEvent.Id, contactId, CreateAndInsert);
        
        return registration;
    }
    
    public static Registration__c CreateRegistration(Id eabEventId, Id contactId, boolean CreateAndInsert) {
        
        //Modified by Saurabh Kumar - 11/10/2020 - Replaced Status 'Scheduled' with 'Registration Requested'
        // create the registration
        Registration__c registration = new Registration__c();
        registration.Contact__c = contactId;
        registration.EAB_Event__c = eabEventId;//Updated from Meeting to EAB Event
        registration.Status__c = 'Registration Requested';
        
        if (CreateAndInsert) insert registration;
        
        return registration;
    }
    
    //Added by Saurabh Kumar - CR-20200819-14447 - 10/09/2020: Added a method create EABEvent
    public static Advisory_Event__c createEABEvent(boolean createAndInsert){
        
        // create the EAB Event
        Advisory_Event__c eabEvent = new Advisory_Event__c();
        eabEvent.Begins__c = system.now();
        eabEvent.Event_Type__c = 'Research Webinar';//v4.0 - 11/09/2020 - Saurabh Kumar - CR-20201105-14664: Replaced EAB Event's Type with EAB Event's Event
        //Modified by Saurabh Kumar - 11/10/2020 - Added Cohort Record Type for Parent EAB Event
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        if (createAndInsert) insert eabEvent;
        return eabEvent;
        
    }
    /*public static Meeting__c CreateMeeting(boolean CreateAndInsert) {
        
        // create the meeting
        Meeting__c meeting = new Meeting__c();
        meeting.DateTime__c = system.now();
        meeting.Type__c = 'Onsite';
        
        if (CreateAndInsert) insert meeting;
        return meeting;
    }*/
    
    public static String EncryptString(String origData) {
        blob blobData = blob.valueOf(origData);
        blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', CrimsonMeeting.KEY, blobData);
        String encryptedString = EncodingUtil.base64Encode(encryptedBlob);
        return encryptedString;
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the decryption functionality of CrimsonMeeting class.
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
        String encryptedString = EncryptString(requestString);
        
        //Start test from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find registrations for registration Id based functionality 
     *                of CrimsonMeeting class. 
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
        String encryptedString = EncryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns both of the registrations
        system.assertEquals(true, decryptedResponse.contains('Testerson'));
        system.assertEquals(2, cMeeting.mWrapper.Registrations.size());
        
        //Initilization inner class
        CrimsonMeeting.MeetingWrapper meetingWrapper = new CrimsonMeeting.MeetingWrapper();
        
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
     *                of CrimsonMeeting class. 
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
        String encryptedString = EncryptString(requestString);
     
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Modified by Saurabh Kumar - 11/10/2020 - Replaced Status 'Scheduled' with 'Registration Requested'
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
     *                functionality will results as an error.
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
        String encryptedString = EncryptString(requestString);
        
        //Start Test from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegistrations', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('At least one of the following fields must be filled in'));
        
        //Stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check and assert for various use cases where find meetings based
     *                functionality will results as an error.
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
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
       
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('EAB Event Id and Contact Id or Registration Id are required.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find meetings for registration Id based functionality 
     *                of CrimsonMeeting class. 
     *                Updated by Saurabh Kumar - 10/08/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    **/
    static testMethod void testFindMeetings_RegistrationId() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Event_Type__c = 'Research Working Sessions';
        //Modified by Saurabh Kumar - 11/10/2020  - Added Cohort Record Type for Parent EAB Event
        eSeries.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        insert eSeries;

        // create a child meeting from the one created above
        //Meeting__c childMeeting1 = CreateMeeting(false);
        Advisory_Event__c childEABEvent1 = createEABEvent(false);
        childEABEvent1.Parent_Event__c = eSeries.Id;
        //Modified by Saurabh Kumar - 11/10/2020  - Added Breakout Record Type for Child EAB Event
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent1;
        
        //Meeting__c childMeeting2 = CreateMeeting(false);
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = eSeries.Id;
        //Modified by Saurabh Kumar - 11/10/2020  - Added Breakout Record Type for Child EAB Event
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent2;
    
         //Creating a Contact record
        Contact contact = testUtilities.CreateNewContact(true);
        
        // create a new registration
        Registration__c registration0 = CreateRegistration(contact.Id, false);
        insert registration0;
        
        //Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        //Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        //Start testing from here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"FindRegisteredSubMeetings","RegistrationId":"' + registration0.Id + '"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns only 2 child registration
        //system.assertEquals(2, cMeeting.mWrapper.Meetings.size());
        //system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent1.Id).subString(0, 15)));
        //system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent2.Id).subString(0, 15)));
        
        //Creating our encrypted string with Contant Id and Meeting Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":"' + contact.Id + '","EABEventId":"' + registration0.EAB_Event__c + '"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        //System.assertEquals('FindRegisteredSubMeetings', cMeeting.mWrapper.Command);
        //System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        //System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        //System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid registration Id
        requestString = '{"Command":"FindRegisteredSubMeetings","ContactId":null,"EABEventId":"' + registration0.Id + '","RegistrationId":"Test"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        //System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        //System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        //system.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        //System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the find meetings by user based functionality 
     *                of CrimsonMeeting class. 
     *                Updated by Saurabh Kumar - CR-20200819-14447 - 10/09/2020: Replaced Meeting with EAB Event
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
        //Modified by Saurabh Kumar - 11/10/2020  - Added Breakout Record Type for Child EAB Event
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent1;
        
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent2.Begins__c = datetime.valueOf('2016-06-08 07:23:00');
        //Modified by Saurabh Kumar - 11/10/2020  - Added Breakout Record Type for Child EAB Event
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert childEABEvent2;
        
        Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        // create our encrypted string
        String requestString = '{"Command":"FindMeetingsByUser","ContactId":"' + registration0.Contact__c + '"}';
        String encryptedString = EncryptString(requestString);
        
        //Start testing from here
        Test.startTest();
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        system.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        system.debug('@@decryptedResponse:' + decryptedResponse);
        system.assertEquals(true, decryptedResponse.contains('Success'));
        
        // make sure it returns only 2 child registration
        system.assertEquals(3, cMeeting.mWrapper.Meetings.size());
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent1.Id).subString(0, 15)));
        system.assertEquals(true, decryptedResponse.contains(string.valueOf(childEABEvent2.Id).subString(0, 15)));
        
        //Creating our encrypted string with blank Contact Id
        requestString = '{"Command":"FindMeetingsByUser","ContactId":""}';
        encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetingsByUser', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Contact Id is required.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.assertEquals(true, decryptedResponse.contains('Contact Id is required.'));
        
        //create our encrypted string with invalid command
        requestString = '{"Command":"Testing","ContactId":""}';
        encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the resultss
        System.assertEquals('Testing', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals(true, cMeeting.mWrapper.Response.contains('Error: Unrecognized command:'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: Unrecognized command:'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the create registration functionality 
     *                of CrimsonMeeting class. +
     *                Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
    **/
    static testMethod void testCreateRegistration() {
        
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
        //Modified by Saurabh Kumar - 11/10/2020  - Added Event Record Type for Child EAB Event
        childEABEvent1.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT;
        insert childEABEvent1;
        
        Advisory_Event__c childEABEvent2 = createEABEvent(false);
        childEABEvent2.Parent_Event__c = registration0.EAB_Event__c;
        childEABEvent2.Begins__c = datetime.valueOf('2016-06-08 07:23:00');
        //Modified by Saurabh Kumar - 11/10/2020  - Added Event Record Type for Child EAB Event
        childEABEvent2.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT;
        insert childEABEvent2;
        
         Advisory_Event__c childEABEvent3 = createEABEvent(false);
        //childMeeting3.Auto_Subscribe__c = false;
        childEABEvent3.Parent_Event__c = childEABEvent1.Id;
        //Modified by Saurabh Kumar - 11/10/2020  - Added Session Record Type for Child EAB Event
        childEABEvent3.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_SESSION;
        insert childEABEvent3;  
        
        //Registration__c registration1 = CreateRegistration(childEABEvent1.Id, registration0.Contact__c, true);
        //Registration__c registration2 = CreateRegistration(childEABEvent2.Id, registration0.Contact__c, true);
        
        
        //Start testing from here
        Test.startTest();
        
        // create our encrypted string
        String requestString = '{"Command":"CreateRegistration","ContactId":"' + registration0.Contact__c + '","EABEventId":"' + childEABEvent1.Id + '","Status":"Attended"}';
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        //system.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        //system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.debug('@@decryptedResponse:' + decryptedResponse);
        
        // get the registration record
        List<Registration__c> registrations = [SELECT Status__c, Id FROM Registration__c WHERE Status__c = 'Attended' AND EAB_Event__c =: childEABEvent2.Id];
        //system.assertEquals(1, registrations.size());
        
        // get the registration record
        registrations = [SELECT Id FROM Registration__c WHERE EAB_Event__c =: childEABEvent2.Id];
        //System.assert(registrations != null);
        //system.assertEquals(1, registrations.size());
        
        registrations = [SELECT Id FROM Registration__c WHERE EAB_Event__c =: childEABEvent3.Id];
        System.assert(registrations != null);
        //system.assertEquals(0, registrations.size());
        
        //Creating our encrypted string with invalid Id to generate a exception
        //requestString = '{"Command":"CreateRegistration","ContactId":"","EABEventId":"","Status":"Attended"}';
        //encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        //cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        //System.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        //System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        //System.assertEquals(true, cMeeting.mWrapper.Response.contains('Error:'));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        //System.assertEquals(true, decryptedResponse.contains('Error:'));
        
        // Creating our encrypted string with Meeting Id is null
        requestString = '{"Command":"CreateRegistration","ContactId":"' + registration0.Contact__c + '","EABEventId":null,"Status":"Attended"}';
        encryptedString = EncryptString(requestString);
        
        //Re-intilization the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        //System.assertEquals('CreateRegistration', cMeeting.mWrapper.Command);
        //System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        //System.assertEquals('EAB Event Id and Contact Id are required.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        //System.assertEquals(true, decryptedResponse.contains('EAB Event Id and Contact Id are required.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check out for various use cases associated with the delete registration functionality 
     *                of CrimsonMeeting class.
     *                Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
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
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        // decrypt the response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        system.debug('@@decryptedResponse:' + decryptedResponse);
        
        // Attempt to find the original reg
        List<Registration__c> registrations = [SELECT Id FROM Registration__c WHERE Id = :registration.Id];
        System.assert(registrations != null);
        system.assertEquals(1, registrations.size());
        system.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        system.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        //Start testing from here
        Test.startTest();
        
        //Creating our encrypted string 
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        
        //Creating our encrypted string having registration Id is null
        requestString = '{"EABEventId":"'+ registration.EAB_Event__c + '","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string having contact id is null
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","ContactId":null,"RegistrationId":"' + registration.Id + '","Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid Registration Id.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Creating our encrypted string having registration Id is invalid
        requestString = '{"EABEventId":"test","ContactId":"' + registration.Contact__c + '" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid EAB Event Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid EAB Event Id.'));
        
        //Creating our encrypted string having Contact Id is invalid
        requestString = '{"EABEventId":"' + registration.EAB_Event__c + '","ContactId":"test" ,"Command":"DeleteRegistration"}';
        encryptedString = EncryptString(requestString);
        
        //Re-initilization a new crimsonMeeting object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('DeleteRegistration', cMeeting.mWrapper.Command);
        System.assertNotEquals(null, cMeeting.ToEncryptedString());
        System.assertEquals('Invalid Contact Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Contact Id.'));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8633 - To refactor the existing code
    /**
     * @description : Test method to check and assert for FindAllSubMeetings method based use cases.
     * 
     *                Updated by Saurabh Kumar - 10/09/2020 - CR-20200819-14447: Replaced Meeting with EAB Event
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
        //Modified by Saurabh Kumar - 11/10/2020 - Added Cohort Record Type for Parent EAB Event
        parentEABEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT;
        insert parentEABEvent;
        System.assertNotEquals(null, parentEABEvent.Id);
        
        //Create a Meeting with parent
        //Meeting__c meeting = CreateMeeting(false);
        Advisory_Event__c eabEvent = createEABEvent(false);
        eabEvent.Parent_Event__c = parentEABEvent.Id;
        //Modified by Saurabh Kumar - 11/10/2020 - Added Breakout Record Type for Child EAB Event
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
        String encryptedString = EncryptString(requestString);
        
        // instantiate a new crimsonMeeting object
        CrimsonMeeting cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        blob encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        String decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting registration with null MeetingId
        requestString = '{"EABEventId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindAllSubMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating encrypted string with Meeting Id and Registration Id are null
        requestString = '{"EABEventId": null ,"RegistrationId": null ,"Command":"FindAllSubMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('EAB Event Id or Registration Id are required.',cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('EAB Event Id or Registration Id are required.'));
        
        //Creating encrypted string with Meeting Id and Contact Id 
        requestString = '{"EABEventId":"'+ eabEvent.Id+ '","ContactId":"' + registration.Contact__c + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Find all sub meeting the registration with null MeetingId
        requestString = '{"EABEventId": null ,"RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with Parent Meeting Id
        requestString = '{"ParentMeetingId":"' + registration.EAB_Event__c + '","RegistrationId":"' + registration.Id + '","Command":"FindMeetings"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertEquals('FindMeetings', cMeeting.mWrapper.Command);
        System.assertNotEquals(Null, cMeeting.ToEncryptedString()); 
        System.assertEquals('Success', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        System.assertEquals(true, decryptedResponse.contains('Success'));
        
        //Creating our encrypted string with invalid Registration Id
        requestString = '{"EABEventId":null,"Command":"FindAllSubMeetings", "RegistrationId":"123"}';
        encryptedString = EncryptString(requestString);
        
        //Re-instantiate the object
        cMeeting = new CrimsonMeeting(encryptedString);
        
        //Asserting for the results
        System.assertNotEquals(Null, cMeeting.ToEncryptedString());
        System.assertEquals('FindAllSubMeetings', cMeeting.mWrapper.Command);
        System.assertEquals('Invalid Registration Id.', cMeeting.mWrapper.Response);
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Invalid Registration Id.'));
        
        //Generating exception
        cMeeting = new CrimsonMeeting(null);
        
        //Asserting for the results
        System.assertEquals(true,cMeeting.mWrapper.Response.contains('Error: '));
        
        //Decryption of response
        encryptedBlob = EncodingUtil.base64Decode(cMeeting.ToEncryptedString());
        decryptedResponse = CrimsonMeeting.Decrypt(encryptedBlob);
        
        //Asserting for the results
        System.assertEquals(true, decryptedResponse.contains('Error: '));
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Added by - Abhinav Sharma - CR-20150202-8634 - To refactor the existing code
    /**
     * @description : Test method to check the functionality of Initialize method of CrimsonMeetingController class.
     * 
    **/
    static testMethod void testCrimsonMeetingController(){
        
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
        
        //Instantiate a new CrimsonMeetingController object
        CrimsonMeetingController controller = new CrimsonMeetingController();
        
        //Calling controller's method
        controller.Initialize();   
        
        //Asserting for the results
        System.assertNotEquals(null, controller.JSONResponse);
        
        //Stop testing here
        Test.stopTest();
    }
}