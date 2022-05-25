/**
 * 
 *  Description     :   Test class for sending of registration reminders
 * 
 *  Revision Logs   :   v1.0 - 07/20/2020 - CR-20200708-14279 - Victor Hanson - Created
 *                      v1.1 - 07/29/2020 - CR-20200729-14380 - Victor Hanson - Updated to change reference to Batch_SendRegistrationReminder()
 *                      v1.2 - 12/08/2020 - CR-20200819-14447 - Saurabh Kumar - Replaced Meeting with EAB Event
 * 
 **/
@isTest
private class Test_Batch_SendRegistrationReminder {
    static testMethod void testCreateRegistrationForParentRegisteredContacts() {
        Test.setMock(HttpCalloutMock.class,new MockHTTPResponseGenerator());
        
        util.bypassAllTriggers = true;
        
        //create a program
        Program__c p = TestUtilities.CreateNewProgram(true);
        
        //create meeting and registration
        Advisory_Event__c eabEvent = new Advisory_Event__c(Begins__c = system.now().addDays(30),
                                                           Ends__c = system.now().addDays(31),
                                                           //Date_Begins__c = system.today().addDays(30),
                                                           //Date_Ends__c = system.today().addDays(31),
                                                           //Type__c = 'Webconference',
                                                           Zoom_Meeting_ID__c = '111-1111-111',
                                                           Zoom_Type__c = 'Meeting');
        util.BypassAllTriggers = true;
        insert eabEvent;
        
        /*Meeting__c meeting = new Meeting__c(DateTime__c = DateTime.now().addDays(30),
                                           End_DateTime__c = DateTime.now().addDays(31),
                                           EAB_Event__c = eabEvent.Id,
                                           Type__c = 'Meeting');
        insert meeting;*/
        util.BypassAllTriggers = true;
        
        //create an account
        Account a = TestUtilities.CreateNewAccount(false);
        a.Time_Zone_Id__c = 'America/New_York';
        a.Time_Zone_Name__c = 'Eastern Timezone';
        insert a;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(a, true);
        
        //create registration
        Registration__c reg = new Registration__c(Contact__c = c.Id,
                                                  EAB_Event__c = eabEvent.Id,
                                                  Status__c = 'Registered',
                                                  Approval_Status__c = 'Approved',
                                                  Zoom_Participant_URL__c = 'https://www.google.com/',
                                                  Zoom_Registrant_ID__c = 'abc123abc123');
        insert reg;
        
        Test.startTest();
        
    //07/29/2020 - CR-20200729-14380 - Victor Hanson - Updated to change reference to Batch_SendRegistrationReminder()
        //MeetingTriggerHelper.scheduleRegistrationReminder(new List<Meeting__c> { meeting }, null);
        //12/08/2020 - CR-20200819-14447 - Saurabh Kumar - Replaced Meeting with EAB Event
        Batch_SendRegistrationReminder b = new Batch_SendRegistrationReminder();
        b.queryString = 'SELECT Id, EAB_Event__r.Begins__c, Zoom_Participant_URL__c, Zoom_Reminder_Email_Sent__c, '
             + ' EAB_Event__r.Zoom_Meeting_ID__c, Contact__r.Account.Time_Zone_ID__c, EAB_Event__r.Public_Name__c, '
             + ' Contact__c, Contact__r.Email '
             + ' FROM Registration__c WHERE Id=\'' + reg.Id + '\'';
        database.executeBatch(b, 25);
        
        Test.stopTest();
        
        //get the registration
        reg = [SELECT Id, Zoom_Reminder_Email_Sent__c FROM Registration__c WHERE Id = :reg.Id];
        system.assertNotEquals(null, reg.Zoom_Reminder_Email_Sent__c);
    }
}