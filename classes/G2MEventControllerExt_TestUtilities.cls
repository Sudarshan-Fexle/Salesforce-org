//Modified By  Rajeev jain - 07/11/2018 - CR-20180604-12258 - Resolving test failure on the Deployment 
//Modified By Dipesh Gupta - on 08/05/2019 - CR-20190522-13122- removed references of 'Gotomeeting_Organizer__c' field

@isTest
private class G2MEventControllerExt_TestUtilities {
    static testmethod void hasG2MLoginTest()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);

        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        insert evnt;

        Profile p = [select id from profile where name='System Administrator'];
        User u1 = new User(alias = 'user1', email='user1@advisory.com', emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username='user1@advisory.com');

        System.runAs(u1) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            System.assertEquals(ctl.hasG2MLogin, false);
        }

        User u2 = new User(alias = 'user2', email='user2@advisory.com', emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username='user2@advisory.com', GotomeetingPassword__c = 'password');
        System.runAs(u2) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            System.assertEquals(ctl.hasG2MLogin, true);
        }
    }

    static testmethod void testCancel()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        insert evnt;
        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));

        System.assertNotEquals(ctl.cancel(), null);
    }

    static testmethod void testGetEventHash()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';

       /* System.assertEquals(G2MEventControllerExt.GetEventHash(evnt),
            '(' + startTime.Format('yyyy/M/d h:mm a') + ' - ' + endtime.Format('yyyy/M/d h:mm a') + ' EST)');*/
    }

    static testmethod void testLoad1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
        ctl.load();
        System.assertNotEquals(ctl.NextAction, 'No gotomeeting action is needed.');
    }
    static testmethod void testLoad1_synchG2M1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        insert evnt;
        
        SFListenerHelper.TriggerIsRunning = true;
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        update evnt;

        Id evntId = evnt.id;

        Profile p = [select id from profile where name='System Administrator'];

        test.startTest();
        User u1 = new User(alias = 'user1', email='user1@advisory.com', emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username='user1@advisory.com');
        insert u1;
        System.runAs(u1) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            PageReference page = ctl.synchG2M();
            if(!ApexPages.hasMessages())
                System.assert(false, 'Should have message');
            System.assertEquals(page, null);
        }
        test.stopTest();
    }

    static testmethod void testLoad1_synchG2M2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        insert evnt;
        
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        SFListenerHelper.TriggerIsRunning = true;
        update evnt;

        Id evntId = evnt.id;

        Profile p = [select id from profile where name='System Administrator'];

        test.startTest();
        User u1 = new User(alias = 'user1', email='user1@advisory.com', emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username='user1@advisory.com', GotomeetingPassword__c = 'password');
        insert u1;
        System.runAs(u1) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            PageReference page = ctl.synchG2M();
            if(!ApexPages.hasMessages())
                System.assert(false, 'Should have message');
            System.assertEquals(page, null);
        }
        test.stopTest();
    }
    static testmethod void testLoad1_synchG2M3()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        insert evnt;
        
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        SFListenerHelper.TriggerIsRunning = true;
        update evnt;

        Id evntId = evnt.id;

        Profile p = [select id from profile where name='System Administrator'];

        test.startTest();
        User u1 = new User(alias = 'user1', email=G2MClient.InTestModeUserId, emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username=G2MClient.InTestModeUserId, GotomeetingPassword__c = 'password');
        insert u1;
        System.runAs(u1) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            PageReference page = ctl.synchG2M();
            if(ApexPages.hasMessages())
                System.assert(false, 'Should have no message');
            System.assertNotEquals(page, null);
        }
        test.stopTest();
    }
    
    static testmethod void testLoad2()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
        ctl.load();
        System.assertNotEquals(ctl.NextAction, 'No gotomeeting action is needed.');
    }
    static testmethod void testLoad2_synchG2M1()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        insert evnt;

        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        SFListenerHelper.TriggerIsRunning = true;
        update evnt;
        
        Id evntId = evnt.id;

        Profile p = [select id from profile where name='System Administrator'];

        test.startTest();
        User u1 = new User(alias = 'user1', email=G2MClient.InTestModeUserId, emailencodingkey='UTF-8', lastname='Testing',
            languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles',
            username=G2MClient.InTestModeUserId, GotomeetingPassword__c = 'password');
        insert u1;
        System.runAs(u1) {
            G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
            PageReference page = ctl.synchG2M();
            /*if(!ApexPages.hasMessages())
                System.assert(false, 'Should have no message');
            System.assertEquals(page, null);*/
        }
        test.stopTest();
    }


    static testmethod void testLoad3()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        //evnt.Gotomeeting_Hash__c = 'Name';
        //evnt.Gotomeeting_Organizer_Saved_Id__c = UserInfo.getUserId();

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
        ctl.load();
        System.assertNotEquals(ctl.NextAction, 'No gotomeeting action is needed.');
    }

    static testmethod void testLoad4()
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = true;
        //evnt.Gotomeeting_Meeting_Name__c = 'Name';
        //evnt.Gotomeeting_Hash__c = G2MEventControllerExt.GetEventHash(evnt);
        //evnt.Gotomeeting_Organizer_Saved_Id__c = UserInfo.getUserId();

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
        ctl.load();
        //System.assertEquals(ctl.NextAction, 'No gotomeeting action is needed.');
    }

    static testmethod void testLoad5()  
    { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        datetime startTime = datetime.now().addDays(7);
        datetime endtime = startTime.addHours(1);
        Event evnt = new Event();
        evnt.StartDateTime = startTime;
        evnt.EndDateTime = endtime;
        evnt.Subject = 'Test Event';
        evnt.Location = 'Test Location';
        //evnt.gotomeeting_Id__c = 'meetingId';
        //evnt.Gotomeeting__c = false;

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(evnt));
        ctl.load();
        System.assertNotEquals(ctl.NextAction, 'No gotomeeting action is needed.');
    }

    static testmethod void testLoad_ClearG2M() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
        Event event = CreateG2MEvent();

        G2MEventControllerExt ctl = new G2MEventControllerExt(new ApexPages.StandardController(event));
        PageReference page = ctl.synchG2M();
        //System.assertNotEquals(page, null);
    }

    static Event CreateG2MEvent() {
        Profile p = [select id from profile where name='System Administrator'];
        User u2 = new User(alias = 'G2MUser2',
            email = G2MClient.InTestModeUserId2,
            emailencodingkey = 'UTF-8', lastname = 'User2', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId2,
            GotomeetingPassword__c = 'password');
        insert u2;
        User u = new User(alias = 'G2MUser',
            email = G2MClient.InTestModeUserId,
            emailencodingkey = 'UTF-8', lastname = 'User', languagelocalekey = 'en_US', localesidkey = 'en_US',
            profileid = p.Id, timezonesidkey = 'America/Los_Angeles',
            username = G2MClient.InTestModeUserId,
            GotomeetingPassword__c = 'password');
        insert u;

        Event event = new Event();
        event.OwnerId = u2.Id;
        event.Subject = 'Test';
        event.StartDateTime = datetime.now().addDays(7);
        event.ActivityDateTime = event.StartDateTime;
        event.EndDateTime = event.StartDateTime.addHours(1);
        event.IsAllDayEvent = false;
        event.Event_Type__c = 'Internal Meeting';
        //event.Gotomeeting_Meeting_Name__c = 'Test Event';
        
        //Modified By Dipesh Gupta - CR-20190522-13122- removing references of 'Gotomeeting_Organizer__c' field
        //event.Gotomeeting_Organizer__c = 'Assigned To';
        //event.Gotomeeting_Id__c = 'G2M Id';
        //event.Gotomeeting__c = true;
        insert event;

        //event.Gotomeeting_Organizer_Saved_Id__c = u.Id;
        System.assertNotEquals(event.Id, null);
        //System.assertNotEquals(event.Gotomeeting_Organizer_Id__c, event.Gotomeeting_Organizer_Saved_Id__c);
        return event;
    }
}