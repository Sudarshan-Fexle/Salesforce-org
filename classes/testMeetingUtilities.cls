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
//@Version - Modified By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - Removed travel compensation field references and added new method testCreateMUMTM() - to increase code coverage
@isTest
private class testMeetingUtilities {
	
	// pretty basic test to see if the meeting count is working properly
    static testmethod void testMeetingUtilizationCount() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Account a = TestUtilities.CreateNewAccount(true);
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, true);
        
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
        currentMeeting.Membership__c = membership.Id;
        currentMeeting.Start_Date__c = system.today().addDays(-5);
        currentMeeting.End_Date__c = system.today().addDays(-5);
        meetings.add(currentMeeting);
        
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        List<Utilization_Data_Object__c> teleconferencesToInsert = new List<Utilization_Data_Object__c>();
        // create a teleconf utilization record
        Utilization_Data_Object__c teleconfUtilization = new Utilization_Data_Object__c();
        teleconfUtilization.Membership__c = membership.Id;
        teleconfUtilization.Start_Date__c = system.today().addDays(5);
        teleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferencesToInsert.add(teleconfUtilization);
        Utilization_Data_Object__c teleconfUtilization2 = new Utilization_Data_Object__c();
        teleconfUtilization2.Membership__c = membership.Id;
        teleconfUtilization2.Start_Date__c = system.today().addDays(-5);
        teleconfUtilization2.End_Date__c = system.today().addDays(-5);
        teleconferencesToInsert.add(teleconfUtilization2);
        // insert the meetings
        test.startTest();
        	insert meetings;
        	insert teleconferencesToInsert;
        test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	system.assertEquals(1, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(futuremeeting.Start_Date__c, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(currentMeeting.End_Date__c, membership.Closest_Active_Meeting_End_Date__c);
    }
    
    static testmethod void testMeetingUtilizationCount_Delete() { 
        //Bypass Dupeblocker
        Util.IsTest(true);
    	Account a = TestUtilities.CreateNewAccount(true);
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, true);
        
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
        currentMeeting.Membership__c = membership.Id;
        currentMeeting.Start_Date__c = system.today().addDays(-5);
        currentMeeting.End_Date__c = system.today().addDays(-5);
        meetings.add(currentMeeting);
        
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        List<Utilization_Data_Object__c> teleconferencesToInsert = new List<Utilization_Data_Object__c>();
        // create a teleconf utilization record
        Utilization_Data_Object__c teleconfUtilization = new Utilization_Data_Object__c();
        teleconfUtilization.Membership__c = membership.Id;
        teleconfUtilization.Start_Date__c = system.today().addDays(5);
        teleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferencesToInsert.add(teleconfUtilization);
        Utilization_Data_Object__c teleconfUtilization2 = new Utilization_Data_Object__c();
        teleconfUtilization2.Membership__c = membership.Id;
        teleconfUtilization2.Start_Date__c = system.today().addDays(-5);
        teleconfUtilization2.End_Date__c = system.today().addDays(-5);
        teleconferencesToInsert.add(teleconfUtilization2);
        // insert the meetings
        test.startTest();
        	insert meetings;
        	insert teleconferencesToInsert;
        	delete meetings;
        	delete teleconferencesToInsert;
        test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	system.assertEquals(0, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(null, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(null, membership.Closest_Active_Meeting_End_Date__c);
    	
    	system.assertEquals(0, membership.Membership_Teleconf_Util_last_12_Mo__c);
    	system.assertEquals(null, membership.Next_Teleconf_Start_Date__c);
    	system.assertEquals(null, membership.Closest_Teleconf_End_Date__c);
    }
    
    //02/14/2014 - CR-20120823-1396 - Remove subquery in Batch_MeetingUtilizations - Updated By Abhinav Sharma for making testing senario more bulkified
    // test the MeetingUtilizations batch that will run nightly
    // to ensure all meeting utilization counts are up to date on memberships
    static testmethod void testBatch_MeetingUtilizations() { 
    	
        //Bypass Dupeblocker
        Util.IsTest(true);
    	
    	//Account
    	Account a = TestUtilities.CreateNewAccount(true);
    	
    	//Program
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
    	insert prog;
        
        //Create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(a.Id, prog.Id, false);
        membership.Next_Meeting_Start_Date__c = system.today().addDays(-5);
        
        // bypass all triggers so we can insert this membership with a date < today in the Next_Meeting_Start_Date field
        // This will ensure that our membership gets processed in the batch
        Util.BypassAllTriggers = true;
        	insert membership;
        Util.BypassAllTriggers = false;
        
        //List to hold the "Meeting Utilities" records
        List<Meeting_Utilization__c> meetings = new List<Meeting_Utilization__c>();
        
        //Inserting more than 200 meeting utilization records
        for(Integer i=0; i< 201; i++) {
        	// create a couple of meeting utilization records
	        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
	        currentMeeting.Membership__c = membership.Id;
	        currentMeeting.Start_Date__c = system.today().addDays(-5);
	        currentMeeting.End_Date__c = system.today().addDays(-5);
	        meetings.add(currentMeeting);    
        }
        
        //Adding future meeting
        Meeting_Utilization__c futureMeeting = new Meeting_Utilization__c();
        futureMeeting.Membership__c = membership.Id;
        futureMeeting.Start_Date__c = system.today().addDays(5);
        futureMeeting.End_Date__c = system.today().addDays(5);
        meetings.add(futureMeeting);
        
        // bypass all triggers when inserting so that the trigger doesn't auto-populate the meeting dates/numbers
        Util.BypassAllTriggers = true;
        insert meetings;
        Util.BypassAllTriggers = false;
        
        //List to hold the "Teleconference Utilities" records
        List<Utilization_Data_Object__c> teleconferences = new List<Utilization_Data_Object__c>();
        
        //Inserting more than 200 meeting utilization records
        for(Integer i=0; i< 201; i++) {
        	Utilization_Data_Object__c currentteleconfUtilization = new Utilization_Data_Object__c();
    		currentteleconfUtilization.Membership__c = membership.Id;
	        currentteleconfUtilization.Start_Date__c = system.today().addDays(-5);
	        currentteleconfUtilization.End_Date__c = system.today().addDays(-5);
	        teleconferences.add(currentteleconfUtilization);
        }
        
        //Create a teleconf utilization record
        Utilization_Data_Object__c futureteleconfUtilization = new Utilization_Data_Object__c();
        futureteleconfUtilization.Membership__c = membership.Id;
        futureteleconfUtilization.Start_Date__c = system.today().addDays(5);
        futureteleconfUtilization.End_Date__c = system.today().addDays(5);
        teleconferences.add(futureteleconfUtilization);
        
        // bypass all triggers when inserting so that the trigger doesn't auto-populate the meeting dates/numbers
        Util.BypassAllTriggers = true;
        insert teleconferences;
        Util.BypassAllTriggers = false;
        
        // run the Batch_MeetingUtilizations to set these records correctly
        Test.startTest();
        
    	//Constructor Initialization
    	Batch_MeetingUtilizations batch = new Batch_MeetingUtilizations();
        	
    	// override the standard query so that we only pull our membership record
    	/*batch.Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
			'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c,' +
			'(Select Start_Date__c, End_Date__c, Id FROM Meeting_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)), ' +
			'(SELECT Start_Date__c, End_Date__c  FROM Teleconference_Utilizations__r WHERE (Start_Date__c >= LAST_N_DAYS:365)) FROM Membership__c ' +
			'WHERE ((Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY) ' +
			'OR (Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365)) AND Id = \'' + membership.Id + '\'';*/
		
		batch.Query='SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,' +
			'Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c FROM Membership__c ' +
			'WHERE ((Next_Teleconf_Start_Date__c < TODAY OR Next_Meeting_Start_Date__c < TODAY) ' +
			'OR (Closest_Active_Meeting_End_Date__c < LAST_N_DAYS:365 OR Closest_Teleconf_End_Date__c < LAST_N_DAYS:365)) AND Id = \'' + membership.Id + '\'';
		
    	//Execute Batch
    	Database.executebatch(batch);
        	
        //Stop test here
        Test.stopTest();
        
        // grab the newly updated membership
		membership = [SELECT Name, Id, Membership_Meeting_Util_last_12_Mo__c, Membership_Teleconf_Util_last_12_Mo__c ,
					Next_Teleconf_Start_Date__c, Next_Meeting_Start_Date__c, Closest_Active_Meeting_End_Date__c, Closest_Teleconf_End_Date__c
					FROM Membership__c WHERE Id = :membership.Id];
    	
    	//Assert result for membership count's , with the correct Next Meeting Start/End dates
    	system.assertEquals(202, meetings.size());
    	system.assertEquals(201, membership.Membership_Meeting_Util_last_12_Mo__c);
    	system.assertEquals(meetings[201].Start_Date__c, membership.Next_Meeting_Start_Date__c);
    	system.assertEquals(meetings[200].End_Date__c, membership.Closest_Active_Meeting_End_Date__c);
    	system.assertEquals(202, teleconferences.size());
    	system.assertEquals(201, membership.Membership_Teleconf_Util_last_12_Mo__c);
    	system.assertEquals(teleconferences[201].Start_Date__c, membership.Next_Teleconf_Start_Date__c);
    	system.assertEquals(teleconferences[200].End_Date__c, membership.Closest_Teleconf_End_Date__c);
    }
    
    //01/23/2018 - Modified By - Mahendra Swarnkar - CR-20180116-11885
 	//Added By - Mahendra Swarnkar - CR-20170509-10928 - 08/14/2017 
    //Commented By - Chirag Soni - 07/27/2021  - CR-20210511-15133 - changes related to Travel assistance are moved to registration - Remove field References
    /*
    static testmethod void myUnitTest() { 
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;
            
        Profile SysAdmin = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        //Create Test User
        User user = new User(FirstName = 'The', LastName = 'Great Ohioan', Alias = 'TGO', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', Email = 'test@eab.com', ProfileId = SysAdmin.Id, department = 'STP',
                             TimeZoneSidKey = 'America/Los_Angeles', Username = 'thegreatohioan@test.com', Travel_Comp_Approver__c  = true, Entity__c = 'EAB');
        insert user;
         
        Account acc = TestUtilities.CreateNewAccount(false);
        acc.Entity__c = 'EAB';
        insert acc;
        
        //Create Test Contact
		Contact conta = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc1', Employee_User_Record__c = user.Id, Entity__c = 'EAB', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert conta;
        
        //Create Program record
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
        prog.Entity__c = 'EAB';
    	insert prog;
        
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, prog.Id, false); 
        membership.Entity__c = 'EAB';
        insert membership;
        
        //Create Meeting utilization
        List<Meeting_Utilization__c> listMeetingUtilization = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        listMeetingUtilization.add(new Meeting_Utilization__c(Membership__c = membership.Id, Start_Date__c = system.today().addDays(19),
                                                      End_Date__c = system.today().addDays(20), Department_Authorization__c =  user.Id,
                                                      Requester_Name__c =  user.Id, Travel_Assistance_Request__c = true, 
                                                      Main_Contact_and_or_Decision_Maker__c = true, Is_There_a_Meeting_Scheduled_With_Guest__c = 'Will be Scheduled', 
                                                      Reason_for_Extending_Assistance__c = 'Test ABC 1', What_Travel_is_Being_Offered__c = 'Hotel',
                                                      Maximum_Hotel_Nights__c = '1', Entity__c = 'EAB'));
        
        listMeetingUtilization.add(new Meeting_Utilization__c(Membership__c = membership.Id, Start_Date__c = system.today().addDays(3),
                                                      End_Date__c = system.today().addDays(20), Department_Authorization__c =  user.Id,
                                                      Requester_Name__c =  user.Id, Travel_Assistance_Request__c = true, 
                                                      Main_Contact_and_or_Decision_Maker__c = true, Is_There_a_Meeting_Scheduled_With_Guest__c = 'Will be Scheduled', 
                                                      Reason_for_Extending_Assistance__c = 'Test ABC 2', What_Travel_is_Being_Offered__c = 'Hotel',
                                                      Maximum_Hotel_Nights__c = '1', Entity__c = 'EAB'));
		
        listMeetingUtilization.add(new Meeting_Utilization__c(Membership__c = membership.Id, Start_Date__c = system.today().addDays(19),
                                                      End_Date__c = system.today().addDays(20), Department_Authorization__c =  user.Id,
                                                      Requester_Name__c =  user.Id, Travel_Assistance_Request__c = true, 
                                                      Main_Contact_and_or_Decision_Maker__c = true, Is_There_a_Meeting_Scheduled_With_Guest__c = 'Will be Scheduled', 
                                                      Reason_for_Extending_Assistance__c = 'Test ABC 3', What_Travel_is_Being_Offered__c = 'Hotel',
                                                      Maximum_Hotel_Nights__c = '1', Entity__c = 'EAB'));
        //Test Starts from here
        Test.startTest();
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = false;
        
        //Insert Meeting utilization
        insert listMeetingUtilization;
        
        //Query record
        List<Meeting_Utilization__c> listMeeting = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Approval_Status__c, Is_Esclated__c From Meeting_Utilization__c where Id IN : listMeetingUtilization ORDER By CreatedDate ASC ];
        
        //Asserts on results
        System.assertEquals(3, listMeetingUtilization.size());
        System.assertEquals('Test ABC 1', listMeetingUtilization[0].Reason_for_Extending_Assistance__c);
        System.assertEquals(conta.Id, listMeeting[0].Department_Authorization_Contact__c);
        system.assertEquals(conta.Id, listMeeting[0].Requester_Name_Contact__c);
        system.assertEquals('Pending', listMeeting[0].Approval_Status__c);
        system.assertEquals(false, listMeeting[0].Is_Esclated__c);
        
        System.assertEquals('Test ABC 2', listMeetingUtilization[1].Reason_for_Extending_Assistance__c);
        System.assertEquals(conta.Id, listMeeting[1].Department_Authorization_Contact__c);
        system.assertEquals(conta.Id, listMeeting[1].Requester_Name_Contact__c);
        system.assertEquals('Pending', listMeeting[1].Approval_Status__c);
        system.assertEquals(true, listMeeting[1].Is_Esclated__c);
        
        System.assertEquals('Test ABC 3', listMeetingUtilization[2].Reason_for_Extending_Assistance__c);
        System.assertEquals(conta.Id, listMeeting[2].Department_Authorization_Contact__c);
        system.assertEquals(conta.Id, listMeeting[2].Requester_Name_Contact__c);
        system.assertEquals('Pending', listMeeting[2].Approval_Status__c);
        system.assertEquals(false, listMeeting[2].Is_Esclated__c);
        
        //Bypass All Triggers to bypass the Meeting Utilization trigger.
        Util.BypassAllTriggers = false;
        
        //Rejection of Approval process Starts from here
        List<ProcessInstance> processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: listMeeting[0].Id AND Status='Pending'];
        
        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : processInstanceList]
		) {
			//String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            
            //Check for the Prefix and ten Reject the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                
                Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                req1.setWorkItemId(workItem.id);
                req1.setAction('Reject'); // This means to remove/recall Approval Request
                req1.setComments('Rejected Status');
                req1.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
                
				Approval.ProcessResult result = Approval.process(req1);   
              
            }
        }
        //Rejection of Approval process Ends here
        
        //Asserts on results
        listMeeting = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Approval_Status__c, Is_Esclated__c From Meeting_Utilization__c where Id =: listMeetingUtilization[0].Id  ];
        system.assertEquals('Rejected', listMeeting[0].Approval_Status__c);
        
        //Approval of Approval process Starts from here
        processInstanceList =  [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: listMeetingUtilization[2].Id AND Status='Pending'];
        
        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : processInstanceList]
		) {
			//String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            
            //Check for the Prefix and ten Reject the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                
                Approval.ProcessWorkItemRequest req2 = new Approval.ProcessWorkItemRequest();
                req2.setWorkItemId(workItem.id);
                req2.setAction('Approve'); // This means to remove/recall Approval Request
                req2.setComments('Approved Status');
                req2.setNextApproverIds(new Id[] {UserInfo.getUserId()}); 
				Approval.ProcessResult result = Approval.process(req2);   
            }
        }
        //Approval of Approval process Ends here
        
        //Asserts on results
        listMeeting = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Approval_Status__c, Is_Esclated__c From Meeting_Utilization__c where Id =: listMeetingUtilization[2].Id  ];
        system.assertEquals('Approved', listMeeting[0].Approval_Status__c);
        
        //Test Ends here
        Test.stopTest();
        
        //Bypass All Triggers to bypass the Meeting Utilization trigger.
        Util.BypassAllTriggers = false;
        
        //Update Meeting Utlilization records to switch the Approval Process from Non-Escalated to Escalated one
        listMeetingUtilization[1].Start_Date__c = system.today().addDays(2);
        listMeetingUtilization[1].Is_Esclated__c = false;
        update listMeetingUtilization[1];
        
        //Asserts on results
        listMeeting = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Approval_Status__c, Is_Esclated__c, Contact__c, Start_Date__c, Travel_Assistance_Request__c From Meeting_Utilization__c where Id =: listMeetingUtilization[1].Id ];
        system.assertEquals('Pending', listMeeting[0].Approval_Status__c);
        system.assertEquals(true, listMeeting[0].Is_Esclated__c);
        
        //Insert Contact record
        Contact conta1 = new Contact(LastName = 'TestCo', AccountId = acc.Id, Employee_ID__c = 'abc', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Employee_User_Record__c = user.Id, Entity__c = 'EAB');
        insert conta1;
		
        //update the Meeting utilization record for checking the change cases
		listMeetingUtilization[1].Contact__c = conta1.Id;
        listMeetingUtilization[1].Start_Date__c = Date.today().addDays(4);
        listMeetingUtilization[1].Travel_Assistance_Request__c = true;
        listMeetingUtilization[1].Approval_Status__c = 'Approved';
        listMeetingUtilization[1].Is_Esclated__c = false;
        
        //Map to hold the Meeting utilization records
        Map<Id, Meeting_Utilization__c> mapMeetingUtilizOld = new Map<Id, Meeting_Utilization__c>();
        mapMeetingUtilizOld.put(listMeeting[0].Id, listMeeting[0]);
        
        //List to hold the meeting utilization records
        List<Meeting_Utilization__c> listMeetingUtilizNew = new List<Meeting_Utilization__c>{listMeetingUtilization[1]};
        
        //Bypass All Triggers to bypass the Meeting Utilization trigger.
        Util.BypassAllTriggers = false;
        Update listMeetingUtilizNew;
        
        //Method calls
        //MeetingUtilities.sentEmailTOAllTravelMemberReceipients(listMeetingUtilizNew, mapMeetingUtilizOld);
        //MeetingUtilities.UpdateInteractionInformation(listMeetingUtilizNew, null);
        //MeetingUtilities.UpdateInteractionInformation(listMeetingUtilizNew, mapMeetingUtilizOld);
        //MeetingUtilities.UpdateInteractionInformation(null, mapMeetingUtilizOld);
    }*/   
    
    //Added by - Chirag Soni - 11/25/2021 - CR-20210511-15133 - Coverage increase - method to test createMUMTM
    static testmethod void testCreateMUMTM() { 
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = true;
            
        Profile SysAdmin = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        //Create Test User
        User user = new User(FirstName = 'The', LastName = 'Great Ohioan', Alias = 'TGO', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', Email = 'test@eab.com', ProfileId = SysAdmin.Id, department = 'STP',
                             TimeZoneSidKey = 'America/Los_Angeles', Username = 'thegreatohioan@test.com', Travel_Comp_Approver__c  = true, Entity__c = 'EAB');
        insert user;
         
        Account acc = TestUtilities.CreateNewAccount(false);
        acc.Entity__c = 'EAB';
        insert acc;
        
        //Create Test Contact
		Contact conta = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc1', Employee_User_Record__c = user.Id, Entity__c = 'EAB', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert conta;
        
        //Create Program record
    	Program__c prog = TestUtilities.CreateNewProgram(false);
    	prog.Create_memberships__c = 'No';
        prog.Entity__c = 'EAB';
    	insert prog;
        
        //Record types for "Rule__c" object
        List<RecordType> rdTypes2 = [SELECT ID FROM RecordType 
                                    WHERE IsActive = true 
                                    AND SobjectType = 'Rule__c' And RecordType.DeveloperName = 'Program' LIMIT 1];
        
        //Create Eab Event
        Advisory_Event__c eABEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eABEvent.Event_Type__c = 'Research Working Sessions';
        eABEvent.Public_Name__c = 'Test';
		eABEvent.Short_Name__c = 'Test';
		eABEvent.Status__c = 'Open - Registration';
		eABEvent.Begins__c = System.today();
		eABEvent.Ends__c = System.today();
        insert eABEvent;
        
        //Create Rule string
        Rule__c ruleString = new Rule__c();
        ruleString.Program__c = prog.Id;
        ruleString.Advisory_Event__c = eABEvent.Id;
        ruleString.RecordTypeId = rdTypes2[0].Id;
        insert ruleString;
        
        //Inserting Event Rule
        Event_Rule__c evtRule = new Event_Rule__c();
        evtRule.Advisory_Event__c = eABEvent.Id;
        evtRule.Rule__c = ruleString.Id;
        insert evtRule;
        
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, prog.Id, false); 
        membership.Entity__c = 'EAB';
        insert membership;
        
        //Create Meeting utilization
        List<Meeting_Utilization__c> listMeetingUtilization = new List<Meeting_Utilization__c>();
        
        // create a couple of meeting utilization records
        listMeetingUtilization.add(new Meeting_Utilization__c(Membership__c = membership.Id, Start_Date__c = system.today().addDays(19),EAB_Event__c = eABEvent.Id,
                                                      End_Date__c = system.today().addDays(20)));
        
        listMeetingUtilization.add(new Meeting_Utilization__c(Membership__c = membership.Id, Start_Date__c = system.today().addDays(3),EAB_Event__c = eABEvent.Id,
                                                      End_Date__c = system.today().addDays(20)));
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //insert meeting utilization
        insert listMeetingUtilization;
        //fetch meeting Utilization MTM records 
        List<Meeting_Utilization_MtM__c> mUMTM = [Select Id, Meeting_Utilization__c, Event_Rule__c From Meeting_Utilization_MtM__c];
        
        //assert
        System.assert(mUMTM.size()>0);
        System.assertEquals(listMeetingUtilization[0].ID, mUMTM[0].Meeting_Utilization__c);
        
        Test.stopTest();
    }
}