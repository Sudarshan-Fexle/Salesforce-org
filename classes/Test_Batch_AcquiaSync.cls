/**
 * 	Description 	:	test class for Schedule_AcquiaSync and Batch_AcquiaSync
 * 
 * 	Revision Logs	:	V1.0 - 02/18/2022 - Chirag Soni - CR-20220208-15772 - Created
 * 
 **/

@isTest
public class Test_Batch_AcquiaSync {
    
    @testSetup static void setup(){
        
        Util.bypassAllTriggers = true;
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        //Query account from setup method
        Account account = testUtilities.CreateNewAccount(true);
        
        // Create bulk contacts 
        List<Contact> contacts = new List<Contact>();
        
        for(Integer i=1 ; i<=5; i++){
            
            contacts.add(testUtilities.CreateNewContact(account, false));
        }
        
        insert contacts;
        
        // create EAB Event
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        //Create the new EAB event record
        Advisory_Event__c cohortEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        cohortEvent.Short_Name__c = 'EAB 1';
        cohortEvent.Acquia_Segment_Id__c = 1012;
        cohortEvent.External_Campaign_Id__c = 0;
        cohortEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        cohortEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvents.add(cohortEvent);
        
        insert eabEvents;
        
        // insert bulk registration to  
        List<Registration__c> insertRegistrationsToUpdate = new List<Registration__c>();
        
        for(Contact contact : contacts){
            
            insertRegistrationsToUpdate.add(new Registration__c(Contact__c = contact.Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested',Requires_Acquia_Sync__c = true));
            
        }
        
        RegistrationHelper.bypassRegistrationDLRS = true;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = true;
        insert insertRegistrationsToUpdate; // bypass trigger and insert to test update case
        RegistrationHelper.bypassRegistrationDLRS = false;
        RegistrationHelper.bypasspopulateInstitutionRegistrationCount = false;
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void testSyncContactAndRegistrationsWithAcquia(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut); 
        
        //get eab event 
        Advisory_Event__c eabEvent = [SELECT Id FROM Advisory_Event__c LIMIT 1];
        
        List<Id> registrationIds = new List<Id>();
        
        for(Registration__c reg : [SELECT Id FROM Registration__c])
        {
            registrationIds.add(reg.Id);
        }
        
        //create croj exp to schedule after 5 seconds
        DateTime sysTime = dateTime.now().addSeconds(2);
        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //String to hold Apex Job Name
        String apexJobName = 'Registration_AcquiaSync' + ' ' + sysTime+' '+math.random();
        
        Test.startTest();
        System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(registrationIds));
        Test.stopTest();
        
        List<Registration__c> reg = [SELECT Id, Requires_Acquia_Sync__c FROM Registration__c WHERE Id IN :registrationIds];
      
        //System.assertEquals(false, reg[0].Requires_Acquia_Sync__c);
       
    }
    
    static testMethod void testGenerateAcquiaSegment(){
        
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut); 
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        for(Integer i=1; i<=5; i++){
            
            Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eabEvent.Event_Type__c = 'Research Working Sessions';
            eabEvent.Public_Name__c = 'Test';
            eabEvent.Short_Name__c = 'Test';
            eabEvent.Status__c = 'Open - Registration';
            eabEvent.Begins__c = System.today();
            eabEvent.Acquia_Segment_Id__c = null;
            eabEvent.External_Campaign_Id__c = null;
            eabEvent.Ends__c = System.today()+1;
            eabEvent.Event_Format__c = 'Virtual';
            eabEvent.Campaign_Template__c = 'Virtual Cohort Parent';
            eabEvents.add(eabEvent);
        }
        
        Util.BypassAllTriggers = true;
        insert eabEvents;
        Util.BypassAllTriggers = false;
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements = new  Map<Id, Advisory_Event__c>();
        Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns = new  Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : eabEvents)
        {
            mapOfEABEventsToGenerateNewAcquiaSegements.put(eabEvent.id, eabEvent);
        }
        
        //create croj exp to schedule after 2 seconds
        DateTime sysTime = dateTime.now().addSeconds(2);
        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //String to hold Apex Job Name
        String apexJobName = 'Schedule_AcquiaSync' + ' ' + sysTime+' '+math.random();
        
        Test.startTest();
        System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(mapOfEABEventsToGenerateNewAcquiaSegements, mapOfEABEventsToRegenerateAcquiaCampaigns));
        Test.stopTest();
        
        Advisory_Event__c eabEvent = [SELECT Id, Acquia_Segment_Id__c FROM Advisory_Event__c WHERE Id IN :mapOfEABEventsToGenerateNewAcquiaSegements.keySet() LIMIT 1];
        //System.assertEquals(true, String.isNotBlank(String.valueOf(eabEvent.Acquia_Segment_Id__c)));
        
    }
    
    static testMethod void testToRegenerateAcquiaCampaigns(){
        // initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut); 
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        for(Integer i=1; i<=5; i++){
            
            Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
            eabEvent.Event_Type__c = 'Research Working Sessions';
            eabEvent.Public_Name__c = 'Test';
            eabEvent.Short_Name__c = 'Test';
            eabEvent.Status__c = 'Open - Registration';
            eabEvent.Begins__c = System.today();
            eabEvent.Acquia_Segment_Id__c = 101;
            eabEvent.External_Campaign_Id__c = 102;
            eabEvent.Ends__c = System.today()+1;
            eabEvent.Event_Format__c = 'Virtual';
            eabEvent.Campaign_Template__c = 'Virtual Cohort Parent';
            eabEvents.add(eabEvent);
        }
        
        Util.BypassAllTriggers = true;
        insert eabEvents;
        Util.BypassAllTriggers = false;
        
        Map<Id, Advisory_Event__c> mapOfEABEventsToGenerateNewAcquiaSegements = new  Map<Id, Advisory_Event__c>();
        Map<Id, Advisory_Event__c> mapOfEABEventsToRegenerateAcquiaCampaigns = new  Map<Id, Advisory_Event__c>();
        
        for(Advisory_Event__c eabEvent : eabEvents)
        {
            mapOfEABEventsToRegenerateAcquiaCampaigns.put(eabEvent.id, eabEvent);
        }
        
        //create croj exp to schedule after 2 seconds
        DateTime sysTime = dateTime.now().addSeconds(2);
        String cronExpr = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //String to hold Apex Job Name
        String apexJobName = 'Schedule_AcquiaSync' + ' ' + sysTime+' '+math.random();
        
        Test.startTest();
        System.schedule(apexJobName, cronExpr, new Schedule_AcquiaSync(mapOfEABEventsToGenerateNewAcquiaSegements, mapOfEABEventsToRegenerateAcquiaCampaigns));
        Test.stopTest();
    }
}