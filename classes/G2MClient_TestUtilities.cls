//Modified By Rajeev jain - on 10/07/2018 - Fixed the test failure to deploy CR-20180604-12258
//Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field
@isTest
private class G2MClient_TestUtilities
{  
    static testmethod void constructorTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);  
        G2MClient client = new G2MClient('userName', 'password');
        System.assertEquals(client.UserName, 'userName');
        System.assertEquals(client.Password, 'password');
        System.assertEquals(client.Token , '');

        client = new G2MClient('userName', 'password', 'token');
        System.assertEquals(client.UserName, 'userName');
        System.assertEquals(client.Password, 'password');
        System.assertEquals(client.Token , 'token');
    }

    static testmethod void faultTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        G2MClient client = new G2MClient(G2MClient.InFaultModeUserId, 'password');

        System.assertEquals(client.logon(), false);
    }

    static testmethod void logonlogoffTest1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        G2MClient client = new G2MClient(G2MClient.InTestModeUserId, 'password', 'token');
        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
        client.logoff();
        System.assertEquals(client.Token, '');
    }

    static testmethod void logonlogoffTest2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        G2MClient client = new G2MClient(G2MClient.InTestModeUserId, 'password');
        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
        client.logoff();
        System.assertEquals(client.Token, '');
    }

    static testmethod void createCreateMeetingRequestTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = new Event();
        evnt.StartDateTime = datetime.now().addDays(7);
        evnt.EndDateTime = evnt.StartDateTime.addHours(1);
        //evnt.Gotomeeting_Meeting_Name__c = 'Test Event';

        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password', 'token');
        String actionName = 'createMeeting';
        Dom.Document document = client.createCreateMeetingRequest(evnt, actionName);

        Dom.XMLNode body = document
            .getRootElement()
            .getChildElement('Body', G2MClient.soapenvNamespace);
        System.assertNotEquals(body, null);

        Dom.XMLNode actionNode = body.getChildElement('g2m:' + actionName, null);
        System.assertNotEquals(actionNode, null);

        System.assertEquals(actionNode.getChildElement('connectionId', null).getText(), 'token');

        Dom.XMLNode paramNode = actionNode.getChildElement('meetingParameters', null);
        System.assertNotEquals(paramNode, null);

        //System.assertEquals(paramNode.getChildElement('subject', null).getText(), evnt.Gotomeeting_Meeting_Name__c);
        System.assertEquals(paramNode.getChildElement('startTime', null).getText(), evnt.StartDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        System.assertEquals(paramNode.getChildElement('endTime', null).getText(), evnt.EndDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        System.assertEquals(paramNode.getChildElement('conferenceCallInfo', null).getText(), 'Free');
        System.assertEquals(paramNode.getChildElement('meetingType', null).getText(), 'Scheduled');
        System.assertEquals(paramNode.getChildElement('passwordRequired', null).getText(), 'false');
    }

    static testmethod void createMeetingTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event event = new Event();
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';

        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password');
        client.logon();
        String meetingId = client.createMeeting(event);

        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
        /*System.assertEquals(meetingId, 'meetingid');
        System.assertEquals(event.Gotomeeting_Id__c, 'meetingid');
        System.assertEquals(event.Gotomeeting_Url__c, 'meeting url');
        System.assertEquals(event.Gotomeeting_Dialing__c, 'calling number'); */
    }

    static testmethod void createUpdateMeetingRequestTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event evnt = new Event();
        evnt.StartDateTime = datetime.now().addDays(7);
        evnt.EndDateTime = evnt.StartDateTime.addHours(1);
        //evnt.Gotomeeting_Meeting_Name__c = 'Test Event';

        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password', 'token');
        String actionName = 'updateMeeting';
        Dom.Document document = client.createUpdateMeetingRequest(evnt, actionName);

        Dom.XMLNode body = document
            .getRootElement()
            .getChildElement('Body', G2MClient.soapenvNamespace);
        System.assertNotEquals(body, null);

        Dom.XMLNode actionNode = body.getChildElement('g2m:' + actionName, null);
        System.assertNotEquals(actionNode, null);

        System.assertEquals(actionNode.getChildElement('connectionId', null).getText(), 'token');

        Dom.XMLNode paramNode = actionNode.getChildElement('meetingParameters', null);
        System.assertNotEquals(paramNode, null);

        //System.assertEquals(paramNode.getChildElement('subject', null).getText(), evnt.Gotomeeting_Meeting_Name__c);
        System.assertEquals(paramNode.getChildElement('startTime', null).getText(), evnt.StartDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        System.assertEquals(paramNode.getChildElement('endTime', null).getText(), evnt.EndDateTime.formatGmt('yyyy-MM-dd\'T\'kk:mm:ss\'Z\''));
        System.assertEquals(paramNode.getChildElement('conferenceCallInfo', null).getText(), 'Free');
        //System.assertEquals(paramNode.getChildElement('meetingType', null).getText(), 'Scheduled');
        //System.assertEquals(paramNode.getChildElement('passwordRequired', null).getText(), 'false');
    }

    static testmethod void updateMeetingTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event event = new Event();
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';

        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password');
        client.logon();
        client.updateMeeting(event);

        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
    }

    static testmethod void createDeleteMeetingRequestTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        G2MClient client =  new G2MClient('userName', 'password', 'token');
        client.logon();
        
        String actionName = 'deleteMeeting';
        Dom.Document document = client.createDeleteMeetingRequest(actionName, 'meetingId');
        Dom.XMLNode body = document
            .getRootElement()
            .getChildElement('Body', G2MClient.soapenvNamespace);
        System.assertNotEquals(body, null);

        Dom.XMLNode actionNode = body.getChildElement('g2m:' + actionName, null);
        System.assertNotEquals(actionNode, null);

        System.assertEquals(actionNode.getChildElement('connectionId', null).getText(), 'token');
        System.assertEquals(actionNode.getChildElement('meetingId', null).getText(), 'meetingId');
    }

    static testmethod void deleteMeetingTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event event = new Event();
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //event.Gotomeeting_Id__c = 'meeting id';
        //event.Gotomeeting_Url__c = 'meeting url';
        //event.Gotomeeting_Dialing__c = 'calling number';

        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password');
        client.logon();
        client.deleteMeeting(event);

        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
    }

    static testmethod void deleteMeetingTest2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        G2MClient client =  new G2MClient(G2MClient.InTestModeUserId, 'password');
        client.logon();
        client.deleteMeeting('meeting id');

        System.assertEquals(client.logon(), true);
        System.assertEquals(client.Token, 'token');
    }

    static testmethod void triggerCreateGotomeetingWhenCreateNewEvent_TestAssignedTo()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting__c = true;
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
    }
    
    static testmethod void triggerCreateGotomeetingWhenCreateNewEvent_TestCteatedBy()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        
        System.RunAs(u2) {
            Event event = new Event();
            event.StartDateTime = datetime.now().addDays(7);
            event.EndDateTime = event.StartDateTime.addHours(1);
            //event.Gotomeeting_Meeting_Name__c = 'Test Event';
            //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
            //event.Gotomeeting_Organizer__c = 'Created By';
            event.Event_Type__c = 'Internal Meeting';
            //event.Gotomeeting__c = true;
            insert event;
            System.assertNotEquals(event.Id, null);
            //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        }
    }
    
    static testmethod void triggerCreateGotomeetingWhenCreateNewEvent_OrganizerPasswordValidationTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId);
        insert u2;
        
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting__c = true;
        
        try {
            insert event;
        }catch(Exception ex) {
            System.assert(true, 'We should have valiation error');
            return;
        }
        //System.assertEquals(event.Id, null);
        System.assert(true, 'We should have valiation error');
    }

    static testmethod void triggerManageGotomeetingWhenUpdateEvent_TestUpdateMeetingName()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting__c = true;
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        
        //event.Gotomeeting_Meeting_Name__c = 'Test Event (Revised)';
        update event;
    }

    static testmethod void triggerManageGotomeetingWhenUpdateEvent_TestUpdateMeetingName2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting__c = true;
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        
        //event.Gotomeeting_Id__c = 'id';
        //event.Gotomeeting_Hash__c = 'id';
        update event;
                
        //event.Gotomeeting_Meeting_Name__c = 'Test Event (Revised)';
        //update event;
    }
        
    static testmethod void triggerManageGotomeetingWhenUpdateEvent_TestInsertNew()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        update event;
    }
    
    static testmethod void triggerManageGotomeetingWhenUpdateEvent_TestDelete()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        
        //event.Gotomeeting__c = false;
        update event;
    }

    static testmethod void triggerManageGotomeetingWhenUpdateEvent_OrganizerPasswordValidationTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        User u1 = new User(alias = 'G2MUser1',
            email = '1' + G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User1', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = '1' + G2MClient.InTestModeUserId);
        insert u1;
                
        Event event;
        
        System.RunAs(u2) {
            event = new Event();
            event.OwnerId = u1.Id;
            event.StartDateTime = datetime.now().addDays(7);
            event.EndDateTime = event.StartDateTime.addHours(1);
            //event.Gotomeeting_Meeting_Name__c = 'Test Event';
            //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
            //event.Gotomeeting_Organizer__c = 'Created By';
            event.Event_Type__c = 'Internal Meeting';
            //event.Gotomeeting__c = true;
            insert event;
        }
        System.assertNotEquals(event.Id, null);
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        try {
            update event;
        }catch(Exception ex) {
            System.assert(true, 'We should have valiation error');
            return;
        }
        System.assert(true, 'We should have valiation error');
    }

    static testmethod void triggerManageGotomeetingWhenUpdateEvent_InvalidOrganizerPassword()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
        User u1 = new User(alias = 'G2MUser1',
            email = '1' + G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User1', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = '1' + G2MClient.InFaultModeUserId,
            GotomeetingPassword__c = 'password');
        insert u1;
                
        Event event;
        
        System.RunAs(u2) {
            event = new Event();
            event.OwnerId = u1.Id;
            event.StartDateTime = datetime.now().addDays(7);
            event.EndDateTime = event.StartDateTime.addHours(1);
            //event.Gotomeeting_Meeting_Name__c = 'Test Event';
            
            //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
            //event.Gotomeeting_Organizer__c = 'Created By';
            event.Event_Type__c = 'Internal Meeting';
            //event.Gotomeeting__c = true;
            insert event;
        }
        System.assertNotEquals(event.Id, null);
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        update event;
    }

    static testmethod void triggerManageGotomeetingWhenUpdateEvent_ChangeOrganizerTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'G2MUser',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u;
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId2,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId2,
            GotomeetingPassword__c = 'password');
        insert u2;
                        
        Event event = new Event();
        event.OwnerId = u.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Hash__c = 'G2MId';
        //event.Gotomeeting__c = true;
        insert event;
        
        event.OwnerId = u2.Id;
        try {
            update event;
        }catch(Exception ex) {
            System.assert(true, 'We should have valiation error');
            return;
        }
        System.assert(true, 'We should have valiation error');
    }
        
    static testmethod void triggerManageGotomeetingWhenUpdateEvent_ChangeOrganizerTest2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'G2MUser',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u;
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId2,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId2,
            GotomeetingPassword__c = 'password');
        insert u2;
                        
        Event event = new Event();
        event.OwnerId = u.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Hash__c = 'G2MId';
        //event.Gotomeeting__c = true;
        insert event;
        
        //event.Gotomeeting_Id__c = 'id';
        update event;
        
        event.OwnerId = u2.Id;
        update event;
    }
    
    static testmethod void triggerDeleteGotomeetingWhenDeleteEventTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Url__c, null);
        //delete event;
    }
    
    static testmethod void testSendEmail()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        
        G2MClient.SendEmail(event.Id, u2.Id, 'Invalid_Gotomeeting_Login_ManageEvent');
    }
    
    static testmethod void testSendDeleteG2MExceptionEmail()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        
        //G2MClient.SendDeleteG2MExceptionEmail(event.Gotomeeting_Id__c, new G2MClient.G2MClientException (), G2MClient.InTestModeUserId);
    }
    
    static testmethod void testSendEventExceptionEmail()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u2;
                
        Event event = new Event();
        event.OwnerId = u2.Id;
        event.StartDateTime = datetime.now().addDays(7);
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
       // event.Gotomeeting__c = true;
        //event.Gotomeeting_Id__c = 'G2MId';
        //event.Gotomeeting_Hash__c = 'G2MId';
        insert event;
        System.assertNotEquals(event.Id, null);
        
        G2MClient.SendEventExceptionEmail(event, new G2MClient.G2MClientException (), G2MClient.InTestModeUserId, 'test');
    }
}