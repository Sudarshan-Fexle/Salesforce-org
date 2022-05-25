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
 //V1.1 - Added By - Saurabh Kumar - 10/27/2020 - testVFPageForAssignToEvents
 //V1.2 - Added By - Abhishek Mishra - CR-20210517-15149 - 17/05/2021 - to increase code coverage
@isTest(seeAllData = false) 
private class Test_AssignStaffToEventsController {
    
	//Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Solutions Executive',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test2',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test3',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test4',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Event Coordinator',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Event Manager',Active__c = true, Institution__c = true, EAB_Event__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Onsite Manager',Active__c = true, Institution__c = true, EAB_Event__c = true));
        
        //Insert teamRoles
        insert teamRoles;
         
        //List of Account
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccounts1'));
        accounts.add(new Account(Name = 'TestAccounts2'));
        accounts.add(new Account(Name = 'TestAccounts3'));
        accounts.add(new Account(Name = 'TestAccounts4'));
       
        //Insert Accounts 
        insert accounts;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[1].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact3', LastName = 'Contact3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[2].Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact
        insert contacts;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'EAB_Event'];
        System.assert(recordTypes != null);
        
        //Added by Saurabh Kumar - CR-20200819-14449
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        Advisory_Event__c eabEvent1 = new Advisory_Event__c(Name = 'TestEabEvent1', Begins__c = Date.today()+10, 
                                                            Ends__c = Date.today()+20, Short_Name__c = 'TestEabEvent1');
        eabEvents.add(eabEvent1);

        insert eabEvents;
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
        Team_Membership__c teamMembership1 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[0].Id);
        teamMemberShips.add(teamMembership1);
        
        //Team Membership
        Team_Membership__c teamMembership2 = new Team_Membership__c(Name = 'TestTeamMember2', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Role__c = teamRoles[1].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[0].Id);
        
        teamMemberShips.add(teamMembership2);
        insert teamMemberShips;
    }
    //Test method to Assign Selected Staff Assignments to selected EAB Events.
    static testMethod void testVFPageForAssignToEvents(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Query Staff Assignments
        List<Team_Membership__c> staffAssignments = [SELECT ID, NAME, EAB_Event__c, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        
        String staffAssignmentIds = '';
        //To fill set of Staff Assignment Ids
        for(Team_Membership__c staffAssignment : staffAssignments){
            staffAssignmentIds+=staffAssignment.Id+'-';
        }

        //Added by Abhishek Mishra - CR-20210517-15149 - 17/05/2021
        List<Team_Membership__c> staffAssignments1 = [SELECT ID, NAME, EAB_Event__c, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
        					      EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                      WHERE EAB_Event__r.Short_Name__c = 'TestEabEven'];
        
        String staffAssignmentIds1 = '';
        //To fill set of Staff Assignment Ids
        for(Team_Membership__c staffAssignment : staffAssignments1){
            staffAssignmentIds1+=staffAssignment.Id+'-';
        }//Added by Abhishek Mishra - 17/05/2021 -- end
        
        
        Test.startTest();
        //Set 'AssignStaffToEvents' page and StandardSetController
        Test.setCurrentPage(Page.AssignStaffToEvents);
        ApexPages.currentPage().getParameters().put('id',staffAssignments[0].EAB_Event__c);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(staffAssignments);
        stdSetController.setSelected(staffAssignments);

        //Added by Abhishek Mishra - CR-20210517-15149 - 17/05/2021 -- Start
        ApexPages.StandardSetController stdSetController1 = new ApexPages.StandardSetController(staffAssignments1);
        stdSetController1.setSelected(staffAssignments1);
        //Added by Abhishek Mishra - 17/05/2021 -- end
        
        //Extension Controller
        AssignStaffToEventsController assignStaffToEventsController = new AssignStaffToEventsController(stdSetController);
        assignStaffToEventsController.loadAssignStaffToEventsLWCWithSelectedSARecords();
        //Assert for Load AssignStaff To Events Component
        System.assertEquals(true, assignStaffToEventsController.loadAssignStaffToEventsComponent);

        //Added by Abhishek Mishra - CR-20210517-15149 - 17/05/2021 -- Start
        AssignStaffToEventsController assignStaffToEventsController1 = new AssignStaffToEventsController(stdSetController1);
        assignStaffToEventsController1.loadAssignStaffToEventsLWCWithSelectedSARecords();
        
	//Assert for Load AssignStaff To Events Component
        System.assertEquals(false, assignStaffToEventsController1.loadAssignStaffToEventsComponent);
        //Added by Abhishek Mishra - 17/05/2021 -- end

        System.assertEquals('', assignStaffToEventsController1.selectedStaffAssignmentIds);
        if(assignStaffToEventsController1.selectedStaffAssignmentIds == ''){
            assignStaffToEventsController1.back();
        }
      


        System.assertNotEquals(null,StaffAssignmentManagementController.fetchSelectedStaffAssignmentRecords('', staffAssignmentIds));
        
        delete staffAssignments;
        //Assert for Custom Message 'No Staff Assignment To Display'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchSelectedStaffAssignmentRecords(staffAssignments[0].EAB_Event__c, ''));
        System.assertEquals(System.Label.No_Staff_Assignment_To_Display, StaffAssignmentManagementController.fetchSelectedStaffAssignmentRecords(staffAssignments[0].EAB_Event__c, '').message);
        
        undelete staffAssignments;
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchSelectedStaffAssignmentRecords(staffAssignments[0].EAB_Event__c, staffAssignmentIds));
        
        //Assert for Custom Message 'Insufficient Access To RecordId'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllEABEventRecords('', ''));
        System.assertEquals(Label.Insufficient_Access_To_RecordId,StaffAssignmentManagementController.fetchAllEABEventRecords('', '').message);
        
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllEABEventRecords(staffAssignments[0].EAB_Event__c, ''));
        
        //Assert for Custom Message 'No EAB Event To Display'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllEABEventRecords(staffAssignments[0].EAB_Event__c, 'Test'));
        System.assertEquals(System.Label.No_EAB_Event_To_Display, StaffAssignmentManagementController.fetchAllEABEventRecords(staffAssignments[0].EAB_Event__c, 'Test').message);
       
        Advisory_Event__c eabEvent2 = new Advisory_Event__c(Name = 'TestEabEvent2', Begins__c = Date.today()+10, 
                                                            Ends__c = Date.today()+20, Short_Name__c = 'TestEabEvent2');
        insert eabEvent2;
        
        //Assert for Search EAB Event records
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllEABEventRecords(staffAssignments[0].EAB_Event__c, 'Test'));
        
        List<Id> selectedEabEventIds = new List<Id>();
        selectedEabEventIds.add(eabEvent2.Id);
        
        List<Id> selectedsStaffAssignmentIds = new List<Id>();
        selectedsStaffAssignmentIds.add(staffAssignments[1].Id);
        
        //To associate selected Staff Assignments to selected EAB Events.
        System.assertNotEquals(null, StaffAssignmentManagementController.assignStaffToEvents(selectedEabEventIds, selectedsStaffAssignmentIds));
        Test.stopTest();
    }
}