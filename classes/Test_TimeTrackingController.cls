/** Description     :   Test class for IntranetPollController.
  * 
  * Created Date    :   2/28/2017
  *
  * Created By      :   Victor Hanson  
  *  
  * Revision Logs   :   v1.0 - Created - Victor Hanson - 2/28/2017 - CR-20170217-10703
  *			V1.1 - Modified - Dipesh Gupta - 03/14/2017 - Q2c enhancement/bugs Release -FIELD_CUSTOM_VALIDATION_EXCEPTION line no 41
  * 			V1.2 - Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564
  **/   
@isTest
private class Test_TimeTrackingController {
	
	/**
	 * 
	 * @description: setup a Case, CR, and Release for use in the related test methods
	 * 
	 **/
    @testSetup
    static void setup() {
       	
        Util.BypassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
      	 
        //create an account
        Account a = TestUtilities.CreateNewAccount(true);
        Contact contact = TestUtilities.CreateNewContact(a, true);
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
        User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = 'testing@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        //create a case
        Case c = new Case(Origin = 'Email', Subject = 'Test Case', Status = '01-New',
                          Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        insert c;
        
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
        //create a release
		SFDC_Release__c release = new SFDC_Release__c(Name='Test Release', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id, Release_level__c = 'L2');
        insert release;
        
        //Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Ends Here
        
        //create a change request
        SFDC_Change_Request__c cr = TestUtilities.CreateChangeRequest(false);
        cr.Title__c = 'Test CR';
        //V1.1 - Modified - Dipesh Gupta - 03/14/2017 - Q2c enhancement/bugs Release -FIELD_CUSTOM_VALIDATION_EXCEPTION line no 41
		List<RecordType> recordTypes =[SELECT Name, Id, SobjectType FROM RecordType WHERE IsActive = true AND SobjectType = 'SFDC_Change_Request__c' AND
										developerName ='Level_II' LIMIT 1];
        
        
        cr.RecordTypeId =recordTypes[0].Id;
        cr.Release__c = release.Id;
        insert cr;
        
        /**
         * create the dependent picklists
         **/
        DP_Picklist__c picklist = new DP_Picklist__c(name='Time Tracking', Alpha_Sort__c=true);
        insert picklist;
        
        //create the case entry immediately because we need to reference the Id
        DP_Picklist_Entry__c plEntry_Case = new DP_Picklist_Entry__c(Picklist__c=picklist.Id, Name='Case', Display_Name__c='Case', Active__c=true);
        insert plEntry_Case;
        
        DP_Picklist_Entry__c plEntry_Administration = new DP_Picklist_Entry__c(Picklist__c=picklist.Id, Name='Administration', Display_Name__c='Administration', Active__c=true);//CASE-Administration
        insert plEntry_Administration;
        
        DP_Picklist_Entry__c plEntry_Troubleshooting = new DP_Picklist_Entry__c(Picklist__c=picklist.Id, Name='Troubleshooting', Display_Name__c='Troubleshooting', Active__c=true);//CASE-Troubleshooting
        insert plEntry_Troubleshooting;
        
        list<DP_Picklist_Dependency__c> dependencies = new list<DP_Picklist_Dependency__c>();
        dependencies.add(new DP_Picklist_Dependency__c(Controlling_Entry__c=plEntry_Case.Id, Dependent_Picklist__c=picklist.Id, Dependent_Entry__c=plEntry_Administration.Id));
        dependencies.add(new DP_Picklist_Dependency__c(Controlling_Entry__c=plEntry_Case.Id, Dependent_Picklist__c=picklist.Id, Dependent_Entry__c=plEntry_Troubleshooting.Id));
        insert dependencies;
        
        DP_Picklist_Usage__c picklistUsage = new DP_Picklist_Usage__c(Picklist__c=picklist.Id, Object__c='Task', Field__c='Type');
        insert picklistUsage;
        
         Util.BypassAllTriggers = false;
         Util.ByPassDLRSForTest = false;
        
     

    }
    
    /**
	 * 
	 * @description: create a Case and save a task against it.  Confirm the task is created and subject is correct.
	 * 
	 **/    
    static testMethod void testSave_Case() {
        //get the Test Case
        Case c = [SELECT Id FROM Case WHERE Subject = 'Test Case'];
         
        //instantiate the controller
        TimeTrackingController controller = new TimeTrackingController();
        
        //specify the case record id
        controller.idString = c.Id;
        
        system.assertEquals(TimeTrackingController.ALERT_ERROR, controller.alertClass, 'No hours added yet, so error string should be returned');
        system.assertEquals('Case', controller.objectAPIName, 'recordId is a Case, so Case should be returned as the objectLabel');
        system.assertEquals('Case', controller.objectLabel, 'recordId is a Case, so Case should be returned as the objectLabel');
        system.assertEquals(2, controller.typeOptions.size(), 
                            'Two dependent picklist entries were added for Case object in test setup, picklist should have 2 values');
        
        controller.task.Duration_in_Hours__c = 2;
        
        test.startTest();
        
        Util.BypassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
		
        //Save the record
        controller.save();
        
        Util.BypassAllTriggers = false;
         Util.ByPassDLRSForTest = false;
        
        test.stopTest();
        
        //reset the recordId
        controller.setLookup();
        
        //get the time tracking record
        list<Task> t = [SELECT Id, Subject FROM Task WHERE WhatId = :c.Id];
        system.assertEquals(1, t.size());
        system.assertEquals(true, t[0].subject == 'Time Entry - Case');
        system.assertEquals(2, controller.totalHours);
    }
    
    /**
	 * 
	 * @description: create a CR and save a task against it.  Confirm the task is created and subject is correct.
	 * 
	 **/    
    static testMethod void testSave_CR() {
        //get the Test Change Request
        SFDC_Change_Request__c cr = [SELECT Id FROM SFDC_Change_Request__c WHERE Title__c = 'Test CR'];
         
        //instantiate the controller
        TimeTrackingController controller = new TimeTrackingController();
        
        //specify the case record id
        controller.idString = cr.Id;
        
        system.assertEquals(TimeTrackingController.ALERT_ERROR, controller.alertClass, 'No hours added yet, so error string should be returned');
        system.assertEquals('SFDC_Change_Request__c', controller.objectAPIName, 'recordId is a CR, so CR should be returned as the objectLabel');
        system.assertEquals('Change Request', controller.objectLabel, 'recordId is a CR, so CR should be returned as the objectLabel');
        system.assertEquals(0, controller.typeOptions.size(), 
                            'Zero dependent picklist entries were added for CR object in test setup, picklist should have 0 values');
        controller.task.Type = 'Coding';//this will ensure time is added to the Coding Actual Hrs field on CR & Release
        controller.task.Duration_in_Hours__c = 2;
        
        test.startTest();
        
        Util.BypassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
		//Save the record
        controller.save();

        Util.BypassAllTriggers = false;
        Util.ByPassDLRSForTest = false;
        
        test.stopTest();
        
        //reset the recordId
        controller.setLookup();
        
        //get the time tracking record
        list<Task> t = [SELECT Id, Subject FROM Task WHERE WhatId = :cr.Id];
        system.assertEquals(1, t.size());
        system.assertEquals(true, t[0].subject == 'Time Entry - Change Request');
        //system.assertEquals(2, controller.totalHours);
        
        //get the dev activity
        list<SFDC_Request_Comment__c> devActivities = [SELECT Id, Time__c FROM SFDC_Request_Comment__c WHERE SFDC_Change_Request__c = :cr.Id];
        system.assertEquals(1, devActivities.size());
        system.assertEquals(2, devActivities[0].Time__c);
        
        //get the updated change request
        cr = [SELECT Id, Coding_Actual_Hours__c, Release__r.Coding_Actual_Hrs__c FROM SFDC_Change_Request__c WHERE Title__c = 'Test CR'];
        system.assertEquals(2, cr.Coding_Actual_Hours__c);
        system.assertEquals(2, cr.Release__r.Coding_Actual_Hrs__c);
    }
    
    /**
	 * 
	 * @description: create a Release and save a task against it.  Confirm the task is created and subject is correct.
	 * 
	 **/    
    static testMethod void testSave_Release() {
        //get the Test Change Request
        SFDC_Release__c release = [SELECT Id FROM SFDC_Release__c WHERE Name = 'Test Release'];
         
        //instantiate the controller
        TimeTrackingController controller = new TimeTrackingController();
        
        //specify the case record id
        controller.idString = release.Id;
        
        system.assertEquals(TimeTrackingController.ALERT_ERROR, controller.alertClass, 'No hours added yet, so error string should be returned');
        system.assertEquals('SFDC_Release__c', controller.objectAPIName, 'recordId is a Release, so Release should be returned as the objectLabel');
        //system.assertEquals('Release/Project', controller.objectLabel, 'recordId is a Release, so Release should be returned as the objectLabel');
        system.assertEquals(0, controller.typeOptions.size(), 
                            'Zero dependent picklist entries were added for Release object in test setup, picklist should have 0 values');
        
        controller.task.Duration_in_Hours__c = 2;
        
        test.startTest();
		
        
        Util.BypassAllTriggers = true;
         Util.ByPassDLRSForTest = true;
        
        //Save the record
        controller.save();
        
        Util.BypassAllTriggers = false;
		 Util.ByPassDLRSForTest = false;
        
        test.stopTest();
        
        //reset the recordId
        controller.setLookup();
        
        //get the time tracking record
        list<Task> t = [SELECT Id, Subject FROM Task WHERE WhatId = :release.Id];
        system.assertEquals(1, t.size());

        //system.assertEquals(true, t[0].subject == 'Time Entry - Release/Project');
        system.assertEquals(2, controller.totalHours);
    }
}