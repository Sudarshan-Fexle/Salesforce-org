/**
 *	Purpose		:	This calss is used to test the functionality of MemberTravelCompSiteController.
 *
 *	Create By	:	Mahendra Swarnakar - 09/11/2017 - CR-20170509-10928
 *	
 *	Revision Log	:	V1.0 - Created By - Mahendra Swarnakar - 08/14/2017 - CR-20170509-10928
 * 				V1.1 - Modified By - Deepak kumawat - Apollo - Run Test Failures Fixes
 * 				V1.2 - Modified By - Chirag Soni - 07/30/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
 * 				V1.3 - Modified By - Chirag Soni - 10/27/2021 - CR-20210511-15133 - Commented out - Main controller class is commented by the CR15133
 *
**/
@istest
public class Test_MemberTravelCompSiteController {
    /*
    //Added By - Mahendra Swarnkar - CR-20170509-10928 - 08/14/2017 
    static testmethod void myUnitTest() { 
        
        //Added By - Chirag Soni  - 07/30/2021 - added the mock class for HTTP Callout - From Here
        //initialize mock response
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        //Added By - Chirag Soni  - 07/30/2021 - added the mock class for HTTP Callout - Till Here

        //Added By - Chirag Soni - 
        //Bypass all the Triggers
		Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
		Util.bypassEntityPopulation = true;
        
        Profile SysAdmin = [SELECT Id from Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        //Modified By - Mahendra Swarnkar - Apollo - Run Test Failures Fixes -- Added Entity field for user
        //Create Test User
        //Added By -  Chirag Soni - 07/30/2021 - Added userlist
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=SysAdmin.Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=SysAdmin.Id, Travel_Comp_Approver__c = true, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=SysAdmin.Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User4', FirstName='Test3', Email='testuser4@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=SysAdmin.Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Insert user records
        insert userList;
         
        //Insert Account
        Account acc = TestUtilities.CreateNewAccount(false);
        acc.Entity__c = 'EAB';
        insert acc;
        
        //Commented By -  Chirag Soni - 07/28/2021 - Changes performed from Meeting Utilization to Registration - From Here
        //Create Test Contact
	//Contact conta = new Contact(LastName = 'TestCon', AccountId = acc.Id, Employee_ID__c = 'abc', Employee_User_Record__c = user.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        //insert conta;
        //Commented By -  Chirag Soni - 07/28/2021 - Changes performed from Meeting Utilization to Registration - Till Here
        
         // Added By -  Chirag Soni - 07/28/2021 - Contacts
         //Create a Contact
         List<Contact> contacts = new List<Contact>();
                
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test@test.com', AccountId = acc.Id, Employee_User_Record__c = userList[0].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test@test.com', AccountId = acc.Id, Employee_User_Record__c = userList[1].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'test@test.com', AccountId = acc.Id, Employee_User_Record__c = userList[2].Id, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact4', Email = 'test@test.com', AccountId = acc.Id, Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contacts;

        //Insert Program
        //Commented By -  Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
    	//Program__c prog = TestUtilities.CreateNewProgram(false);
    	//prog.Create_memberships__c = 'No';
        //prog.Entity__c = 'EAB';
    	//insert prog;
        
        //Insert Programs
        //List of Program
        List<Program__c> programs = new List<Program__c>();

        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        
        //Insert
        insert programs;
        */
        //Commented By -  Chirag Soni - 07/28/2021 - CR-20210511-15133 - Changes performed from Meeting Utilization to Registration
        /*
        // create a membership
        Membership__c membership = TestUtilities.CreateNewMembership(acc.Id, prog.Id, false);
        membership.Entity__c = 'EAB';
        insert membership;
        
        // create a couple of meeting utilization records
        Meeting_Utilization__c currentMeeting = new Meeting_Utilization__c();
        currentMeeting.Membership__c = membership.Id;
        currentMeeting.Start_Date__c = system.today().addDays(20);
        currentMeeting.End_Date__c = system.today().addDays(20);
        currentMeeting.Department_Authorization__c =  user.Id;
        currentMeeting.Requester_Name__c =  user.Id;
        currentMeeting.Travel_Assistance_Request__c = true;
        currentMeeting.Main_Contact_and_or_Decision_Maker__c = true;
        currentMeeting.Is_There_a_Meeting_Scheduled_With_Guest__c = 'Will be Scheduled';
        currentMeeting.Reason_for_Extending_Assistance__c = 'Test';
        currentMeeting.What_Travel_is_Being_Offered__c = 'Hotel';
        currentMeeting.Maximum_Hotel_Nights__c = '1';
        currentMeeting.Entity__c = 'EAB';
        
        //Bypass all the Triggers
		Util.BypassAllTriggers = false;
        
        //Insert Meeting Utilization records
        insert currentMeeting;
        */
        // create two eab events for parent event 1
        //Added By -  Chirag Soni - 07/28/2021 - Create EAB Event for the registrations - From Here
        /*List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();

        //Create two event
        Advisory_Event__c eabEvent = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_EVENT, null, false);
        eabEvent.Short_Name__c = 'test 1 - EAB Event 1';
        eabEvent.Public_Name__c = 'test 1 EAB Event 1';
        eabEvent.Status__c = Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION;
        eabEvent.Rules_Programs__c = 'Establish independent rules';
        eabEvent.Allow_Employee_Registrations__c = true;
        eabEvent.Begins__c = system.today().addDays(10);
        eabEvent.Ends__c = system.today().addDays(20);
        eabEvents.add(eabEvent);

        //insert Eab Event
        insert eabEvents;

        //Create Registration
        List<Registration__c> registrations = new List<Registration__c>();
        
        // create registrations on child events for first parent event.
        registrations.add(new Registration__c(Contact__c = contacts[0].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              ,Department_Authorization__c = userList[0].Id ,Requester_Name__c = userList[1].Id, Travel_Assistance_Request__c = true));
        
        registrations.add(new Registration__c(Contact__c = contacts[1].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              , Department_Authorization__c = userList[1].Id ,Requester_Name__c = userList[2].Id , Travel_Assistance_Request__c = true));
        
        registrations.add(new Registration__c(Contact__c = contacts[2].Id, EAB_Event__c = eabEvents[0].Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              , Department_Authorization__c = userList[2].Id ,Requester_Name__c = userList[0].Id, Travel_Assistance_Request__c = true));
      
        //Bypass all the Triggers
		Util.BypassAllTriggers = false;

        insert registrations;

        //Update startDate
        //eabEvent.Begins__c = System.today().addDays(8);
        //update eabEvent;

        //Querry the Meeting_Utilization record
        //Commented By -  Chirag Soni - 07/28/2021 - Changes performed from Meeting Utilization to Registration - From Here
        //List<Meeting_Utilization__c> listMeeting = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Approval_Status__c From Meeting_Utilization__c where Id =: currentMeeting.Id  ];
        //Commented By -  Chirag Soni - 07/28/2021 - Changes performed from Meeting Utilization to Registration - Till Here
        
        //Added By -  Chirag Soni - 07/28/2021 - CR-20210511-15133 - Query over the registrations record - Till Here
        //Query to Registrations Record
        registrations = [Select Id, Contact__c, Is_Escalated__c,Travel_Compensation_Approval_Status__c, EAB_Event__c, Status__c, Department_Authorization__c, Requester_Name__c,
                                                Requester_Name_Contact__c,Department_Authorization_Contact__c From Registration__c Order By Contact__r.LastName];
        //Asserts
        //Modified By - Chirag Soni - 07/28/2021 - CR-20210511-15133 - changed List meeting to registrations
        System.assertEquals(contacts[0].Id, registrations[0].Department_Authorization_Contact__c);
        System.assertEquals(contacts[1].Id, registrations[1].Department_Authorization_Contact__c);
        System.assertEquals(contacts[2].Id, registrations[2].Department_Authorization_Contact__c);
        
        system.assertEquals('Pending', registrations[1].Travel_Compensation_Approval_Status__c);
        system.assertEquals(false, registrations[1].Is_Escalated__c);
        
        //Query the Process Instance
        Set<Id> setProcessInstanceIds = new Set<Id>();
        //Query all the existing Approval Process Instances for Meeting Utilization
        for(ProcessInstance pi : [SELECT Id, TargetObjectId 
                                  FROM ProcessInstance 
                                  WHERE TargetObjectId =: registrations[1].Id
                                  AND Status='Pending']
           ) {
               //Populate the set
               setProcessInstanceIds.add(pi.Id);
           }
        
        //Asserts
        system.assert(setProcessInstanceIds.size() > 0);
        
        //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                where ProcessInstanceId IN : setProcessInstanceIds]
        ) {
            //String to hold the id
            String OriginalActorIdstring = workItem.OriginalActorId;
            
            //Check for the Prefix and ten Approve the existing Approval Process
            if(!OriginalActorIdstring.contains('00G')) {
                
                Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                req1.setWorkItemId(workItem.id);
                req1.setAction('Approve'); // This means to remove/recall Approval Request
                req1.setComments('');
                
                System.debug('###setProcessInstanceIds : '+ setProcessInstanceIds + ' @@@@ workItem' + workItem);
                Approval.ProcessResult result = Approval.process(req1);
                
        	}
        }
       
        //Query the Meeting utilization record
        List<Registration__c> registration = [Select Id, Department_Authorization_Contact__c, Requester_Name_Contact__c, Travel_Compensation_Approval_Status__c From Registration__c where Id =: registrations[1].Id];
        
        //Asserts
        //System.debug('##@@ Approval Status '+ registration[0].Travel_Compensation_Approval_Status__c);
        system.assertEquals('Approved', registration[0].Travel_Compensation_Approval_Status__c);
        
        //Test Starts from here
        Test.startTest();
        
        //Initialising constractor
    	MemberTravelCompSiteController memberTravelCompSite = new MemberTravelCompSiteController();
        system.assertEquals(true,(String.isBlank(memberTravelCompSite.JSONResponse)));
        
        //Commented By - Chirag Soni - 07/29/2021 - CR-20210511-15133 - Performed changes for the registration object - Start here
        //Login as system Admin
		//system.runAs(userList[0]) {
        //Commented By - Chirag Soni - 07/29/2021 - CR-20210511-15133 - Performed changes for the registration object - Till here

        //Place Id of release
        //Modified By - Chirag Soni - 07/29/2021 - Modfied the changes for Meeting Utilization to registration
        ApexPages.currentPage().getParameters().put('id', registration[0].Id);
        memberTravelCompSite = new MemberTravelCompSiteController();
        system.assertEquals(true,(String.isNotBlank(memberTravelCompSite.JSONResponse)));
    
        //Test Ends here
        Test.stopTest();
    }*/
    /*
    static testMethod void testParseResponse() {
        
        //setup the XML Response
        String xmlResBody = '<?xml version="1.0" encoding="utf-8"?>'
            + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            + '<soap:Body><SendEmailsResponse xmlns="http://travelcompemails.advisory.com/SFListener">'
            + '<SendEmailsResult><Results><EmailResult><Success>false</Success><Error>Error: Can\'t read payload </Error></EmailResult></Results>'
            + '<message>The input is not a valid Base-64 string as it contains a non-base 64 character, more than two padding characters, or an illegal character among the padding characters. </message>'
            + '</SendEmailsResult></SendEmailsResponse>'
            + '</soap:Body></soap:Envelope>';
        httpResponse res = new HttpResponse();
        res.setBody(xmlResBody);
        
        boolean hasError = false;
        try {
            MemberTravelCompSiteController.parseResponse(res);
        }
        catch(Exception e) {
            hasError = true;
        }
        
        //verify that an error was thrown
        system.assertEquals(true, hasError);
    }*/
	
	private static testmethod void callClassTest()
	{
		MemberTravelCompSiteController obj = new MemberTravelCompSiteController ();
		system.assertNotEquals(null,obj);
	}
}