/**
 *   Purpose		:   Test class for PreApprovedRegHelper
 *   
 *   Revision Log	:	V1.0 - 07/31/2019 - CR-20190611-13177 - Victor Hanson - Created
 * 		    			V1.1 - 10/10/2020 - CR-20200819-14447 - Saurabh Kumar: Updated code to replace Meeting reference with EAB Event
 * 		    			V1.2 - 11/09/2020 - CR-20201105-14664 - Saurabh Kumar: Updated code to replace Type reference with Event Type. Removed site, EAB Event
 *                 		V1.3 - 11/10/2020 - Saurabh Kumar: Replaced Status 'Scheduled' with 'Registration Requested' (Not Exist Scheduled picklist value)
 * 		    			V1.4 - 11/26/2020 - CR-20201119-14704 - Saurabh Kumar - Removed Registration's Meeting field
 * 						V1.5 - 01/07/2021 - Mahendra Swarnakar - (RunAllTest Bug Fix)
            
**/
@isTest
public class Test_PreApprovedRegHelper {
    
    /**
     * @description: verify that a pre approved registration record auto-updates the Status field on Registration
     **/
    static testMethod void testPreApprovedRegHelper() {
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        update user1;
        
        PermissionSet customPermission = [SELECT Id, Label 
                                              FROM PermissionSet
                                              WHERE Label = 'EAB Event Manager'];
        
        	PermissionSetAssignment assignPS = new PermissionSetAssignment (AssigneeId = user1.Id, PermissionSetId = customPermission.Id);
        	insert assignPS;
        
        System.runAs(user1) {
            
        	Advisory_Event__c advisoryEvnt = new Advisory_Event__c(Name = 'AdvisEvent1');
        	insert advisoryEvnt;
        	//create a meeting
        	Meeting__c meeting = new Meeting__c( Name = 'Meeting_1');
        	insert meeting;
        
        	//bypass triggers
        	util.bypassAllTriggers = true;
        
        	//create 2 Site Profiles
        	List<Site_Profile__c> sProfiles = new List<Site_Profile__c>();
        	Site_Profile__c spNotPreApproved = TestUtilities.createSiteProfile(false);
        	Site_Profile__c spPreApproved = TestUtilities.createSiteProfile(false);
        	sProfiles.add(spNotPreApproved);
        	sProfiles.add(spPreApproved);
        	insert sProfiles;
        
        	//create 1 pre-approved registration
        	Pre_Approved_Registration__c par = new Pre_Approved_Registration__c(Contact__c = spPreApproved.Contact__c, Meeting__c = meeting.Id);
        	insert par;
        
        	//Modified by Saurabh Kumar - 11/10/2020 - Replaced Status 'Scheduled' with 'Registration Requested'
        	//v1.4 - 11/26/2020 - CR-20201119-14704 - Saurabh Kumar - Removed Registration's Meeting field
        	//create 2 registration records
        	List<Registration__c> registrations = new List<Registration__c>();
        	Registration__c regNotPreApproved = new Registration__c(Contact__c = spNotPreApproved.Contact__c,
                                                                	//EAB_Event__c = advisoryEvnt.Id,
                                                                	Status__c = 'Registration Requested');
       	 	Registration__c regPreApproved = new Registration__c(Contact__c = spPreApproved.Contact__c,
                                                                //Meeting__c = meeting.Id,
                                                                //EAB_Event__c = advisoryEvnt.Id,
                                                                Status__c = 'Registration Requested');
        	registrations.add(regNotPreApproved);
        	registrations.add(regPreApproved);
        
        	test.startTest();
        
        	//reset triggers
        	util.bypassAllTriggers = false;
        
        	//insert registrations
        	insert registrations;
        
        	test.stopTest();
        
        	//get the registrations
        	registrations = [SELECT Id, Status__c, Contact__c FROM Registration__c WHERE Id IN :registrations];
        
        	//verify the status was updated to Registered on the pre-approved registration
        	for (Registration__c reg : registrations) {
            	if (reg.Id == regNotPreApproved.Id)
                	system.assertEquals('Registration Requested', reg.Status__c);
            //Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) - Method for status change is commented in main class
            //if (reg.Id == regPreApproved.Id)
            //   system.assertEquals('Registered', reg.Status__c, 'Status should be registered because there is a pre-approved registration for this contact/meeting');
        	//Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) - End Here
        	}
        
        	//get the pre-approved registration record
        	par = [SELECT Id, Registration__c FROM Pre_Approved_Registration__c WHERE Id = :par.Id];
        	//Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) Start From Here - Method for status change is commented in main class
        	//system.assertEquals(regPreApproved.Id, par.Registration__c);
        	System.assertEquals(null, par.Registration__c);
        	//Modified By - Mahendra Swarnakar - 01/07/2021 - (RunAllTest Bug Fix) -End Here
        }
    }
}