/**
 * 	Description 	:	test class for SendMemberAndGoTravelEmailController
 * 
 * 	Revision Logs	:	V1.0 - CR-20210511-15133 - 10/26/2021 - Chirag Soni - Created			
 * 
 **/
@isTest
private class SendMemberAndGoTravelEmailControllerTest {
    
	@testSetup static void setup() {
    	util.bypassAllTriggers = true;
            
        //Insert Program
        Program__c prog = new Program__c(Name = 'TestProg', Entity__c = 'All',Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog; 
        
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
		parentEABEvent.Short_Name__c = 'Test';
        parentEABEvent.Public_Name__c = 'Test';
		parentEABEvent.Status__c = 'Open - Registration';
		//parentEABEvent.Begins__c = System.today();
		//parentEABEvent.Ends__c = System.today();
        insert parentEABEvent;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(false); 
        newContact.Email = 'test@eabtest.com';
        newContact.Company_Email__c = 'test@eabtest.com';
        insert newContact;
        
        Account acc = testUtilities.CreateNewAccount(false);
        acc.Name = 'Washington - DC - Washington - DC';
        acc.Type = 'Corporation';
        acc.Event_Venue__c = true;
        acc.RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENUE;
        acc.Account_Formal_Name__c = 'Washington - DC';
        acc.Primary_Address_Line_1__c = 'United States of America';
        acc.Primary_Address_Line_2__c = 'test';
        acc.Primary_City__c = 'Washington';
        acc.Primary_Country__c = 'United States';
        acc.Status__c = 'Active';
        insert acc;
        
        //Fetch Profile
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        Venue__c venue = new Venue__c(Name = 'Washington - DC',RecordTypeId = Constants.RECORD_TYPE_ID_VENUE_EVENT_VENUE,
                            		  Primary__c = true, Room_Use__c = 'General Session',Advisory_Event__c = parentEABEvent.Id,Venue__c = acc.Id);
		insert venue;
        //Create user record 
        User user = new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId = testProfile[0].Id, Travel_Comp_Approver__c = true,
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true);
        insert user;
        
        //Create Registration
        Registration__c reg = new Registration__c(Contact__c = newContact.Id, EAB_Event__c = parentEABEvent.Id, Status__c = 'Registration Requested'
                                              ,Reason_for_Extending_Assistance__c = 'test', Is_there_a_meeting_scheduled_with_guest__c = 'Yes',
                                              What_Travel_is_being_offered__c = 'Hotel', Maximum_Hotel_Nights__c = '2'
                                              ,Department_Authorization__c = user.Id ,Requester_Name__c = user.Id, Travel_Assistance_Request__c = true);
        insert reg;
        
        Util.bypassAllTriggers = false; 
    }
    
    //Modified by - Chirag Soni - 10/19/2021 - CR-20210511-15133 - Created
    static testMethod void testSendMemberAndGoTravelEmailCallout() {

        //test start here
        test.startTest();
        Util.bypassAllTriggers = True; 

        //Use case 1 - (reg.Travel_Assistance_Request__c == false)
        Registration__c reg = [SELECT Id, Contact__c, Status__c, Travel_Assistance_Request__c FROM Registration__c LIMIT 1];
        String recordId = '{"record":"'+reg.Id+'"}';
        reg.Travel_Assistance_Request__c = false;
        update reg;
        LightningResponseEntity lightningResEntity = SendMemberAndGoTravelEmailController.SendMemberAndGoTravelEmailCallout(recordId);
        System.assertEquals( 'Travel Assistance is not requested.',lightningResEntity.message);
   		
        //Use case 2 - (reg.Travel_Compensation_Approval_Status__c !='Approved')
        //Update registration 
        reg = [SELECT Id, Travel_Assistance_Request__c FROM Registration__c LIMIT 1];
        reg.Travel_Assistance_Request__c = true;
        update reg;
        
        lightningResEntity = SendMemberAndGoTravelEmailController.SendMemberAndGoTravelEmailCallout(recordId);
        System.assertEquals( 'Travel compensation request not approved',lightningResEntity.message);
        //Bypass Flag
        Util.bypassAllTriggers = false; 
        
        test.stopTest();
    }
    //Modified by - Chirag Soni - 10/19/2021 - CR-20210511-15133 - Created
    static testMethod void testSendMemberAndGoTravelEmailCalloutV2() {
        
        //Update EAB Event
        Advisory_Event__c eabEvent = [SELECT Id, Public_Name__c,Begins__c, Ends__c FROM Advisory_Event__c Order By CreatedDate DESC Limit 1];
        eabEvent.Begins__c = Datetime.now().addDays(-5);
        eabEvent.Ends__c = Datetime.now().addDays(5);
        update eabEvent;
        
        //Update registration
        Registration__c reg = [SELECT Id FROM Registration__c LIMIT 1];
        reg.Travel_Assistance_Request__c = true;
        reg.Travel_Compensation_Approval_Status__c = 'Approved';
        reg.Must_Arrive_at_Meeting_Location_By__c = System.now().addDays(1);
        reg.Must_Depart_No_Earlier_Than__c = System.now().addDays(4);
        update reg;       
        
        String recordId = '{"record":"'+reg.Id+'"}';
        LightningResponseEntity lightningResEntity = SendMemberAndGoTravelEmailController.SendMemberAndGoTravelEmailCallout(recordId);
        System.assertEquals('Request sent Successfully.',lightningResEntity.message);
    }
}