/**
 *   Purpose:           Test class for SiteProfileLogger
 *   
 *   Revision Log:      v1.0 - 02/09/2021 - CR-20210204-14872 - Victor Hanson - Created
 * 
**/
@isTest
private with sharing class Test_SiteProfileLogger {
    

    @TestSetup
    static void makeData(){
        Util.bypassAllTriggers = true;
        // create account and eligible domain
        Account acct = Test_SiteUserHelper.CreateNewAccount(false);
        insert acct;
        Eligible_Domain__c domain = new Eligible_Domain__c(Is_Included__c = true, Qualified_Domain__c = 'eab.com', Account__c = acct.Id);
        insert domain;
        
        // create a site profile
        Site_Profile__c sp = Test_SiteUserHelper.createSiteProfile(acct, SiteUserHelper.SITE_EAB, true);
        
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
        parentEABEvent.Public_Name__c = 'Test';
	parentEABEvent.Short_Name__c = 'Test';
	parentEABEvent.Status__c = 'Open - Registration';
	parentEABEvent.Begins__c = System.today();
	parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true); 
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(parentEABEvent.Id, newContact.Id, true);
        
    }

    static testMethod void testLogSiteUser() {
        Site_Profile__c sp = [SELECT Id, Type__c, Username__c, Bypass_Domain_Validation__c FROM Site_Profile__c LIMIT 1];

        //send a password reset - this should return an error and update the status code to E3
        SiteUser sUser = new SiteUser();
        sUser.Username = sp.Username__c;
        sUser.Site = sp.Type__c;
        sUser.Command = '';
        sUser.Site_Profile = sp;

        SiteProfileLogger.Log(sUser);
        List<Web_Service_Log__c> logs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, logs.size());
    }

    static testMethod void testLogInstitution() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

        system.assertNotEquals(null, SiteProfileLogger.wsLogInstitutionRTId);

        SiteProfileLogger.Log(acct.Id, '{}', 'test', 'test', 'test');
        List<Web_Service_Log__c> logs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, logs.size());
    }

    static testMethod void testLogSiteMeeting() {

        //get registration
        Registration__c registration = [SELECT Id, EAB_Event__c FROM Registration__c LIMIT 1];

        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","EABEventId":"' + registration.EAB_Event__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);
        
        // instantiate a new SiteMeeting object
        SiteMeeting sMeeting = new SiteMeeting(encryptedString);
        sMeeting.mWrapper.MeetingGUID = 'test';

        SiteProfileLogger.Log(sMeeting, sMeeting);
        List<Web_Service_Log__c> logs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, logs.size());
    }

    static testMethod void testLogSiteMeetingWithSiteUser() {

        //get registration
        Registration__c registration = [SELECT Id, EAB_Event__c FROM Registration__c LIMIT 1];

        // create our encrypted string
        String requestString = '{"Command":"FindRegistrations","EABEventId":"' + registration.EAB_Event__c + '"}';
        String encryptedString = EncryptionHelper.encryptString(requestString);

        //get site SiteProfile
        Site_Profile__c sp = [SELECT Id, Type__c, Username__c, Bypass_Domain_Validation__c FROM Site_Profile__c LIMIT 1];
        SiteUser sUser = new SiteUser();
        sUser.site_Profile = sp;
        
        // instantiate a new SiteMeeting object
        SiteMeeting sMeeting = new SiteMeeting(encryptedString);
        sMeeting.mWrapper.MeetingGUID = 'test';

        SiteProfileLogger.Log(sMeeting, sMeeting, sUser);
        List<Web_Service_Log__c> logs = [SELECT Id FROM Web_Service_Log__c];
        system.assertEquals(1, logs.size());
    }
}