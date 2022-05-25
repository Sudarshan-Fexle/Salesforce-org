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
 //V1.1 - Added By - Saurabh Kumar - 10/27/2020 - testVFPageForAddEditStaff
@isTest(seeAllData = false) 
private class Test_AddEditStaffAssignmentsController {
    
	//Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Event Coordinator',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Event Manager',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Onsite Manager',Active__c = true, Institution__c = true));
        
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
        
        //EAB Events
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        Advisory_Event__c eabEvent1 = new Advisory_Event__c(Name = 'TestEabEvent1', Begins__c = Date.today(), 
                                                            Ends__c = Date.today(), Short_Name__c = 'TestEabEvent1');
        eabEvents.add(eabEvent1);
        Advisory_Event__c eabEvent2 = new Advisory_Event__c(Name = 'TestEabEvent2', Begins__c = Date.today(), 
                                                            Ends__c = Date.today(), Short_Name__c = 'TestEabEvent2');
        eabEvents.add(eabEvent2);
        insert eabEvents;
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
        Team_Membership__c teamMembership1 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[0].Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[0].Id);
        teamMemberShips.add(teamMembership1);
        
        //Team Membership
        Team_Membership__c teamMembership2 = new Team_Membership__c(Name = 'TestTeamMember2', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[0].Id, Role__c = teamRoles[1].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[0].Id);
        
        teamMemberShips.add(teamMembership2);
        insert teamMemberShips;
    }
    //Test method to Add/Edit/Delete Staff Assignment Functionality 
    static testMethod void testVFPageForAddEditStaff(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Query Contacts, Team Roles and Staff Assignments
        List<Contact> contacts = [SELECT ID, NAME FROM Contact];
        List<Team_Role__c> teamRoles = [SELECT ID, NAME FROM Team_Role__c WHERE Name = 'Event Coordinator' OR
                                        Name = 'Event Manager' OR Name = 'Onsite Manager'];
        List<Team_Membership__c> staffAssignments = [SELECT ID, NAME, EAB_Event__c, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        //To hold Staff Assignment Ids To delete records
        List<Id> staffAssignmentIdsToDelete = new List<Id>();
        
        Test.startTest();
        //Set 'AddEditStaffAssignments' page and StandardSetController
        Test.setCurrentPage(Page.AddEditStaffAssignments);
        ApexPages.currentPage().getParameters().put('id',staffAssignments[0].EAB_Event__c);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(staffAssignments);
        stdSetController.setSelected(staffAssignments);
        
        //Extension Controller
        AddEditStaffAssignmentsController addEditStaffAssignmentsController = new AddEditStaffAssignmentsController(stdSetController);
        //Assert for EAB Event Id
        System.assertNotEquals(null, addEditStaffAssignmentsController.eabEventId);
        
        //Assert for Custom Message 'No Role To Display'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllAssignedRoleRecords());
        System.assertEquals(System.Label.No_Role_To_Display, StaffAssignmentManagementController.fetchAllAssignedRoleRecords().message);
        
        teamRoles[0].EAB_Event__c = true;
        teamRoles[1].EAB_Event__c = true;
        teamRoles[2].EAB_Event__c = true;
        update teamRoles;
        
        //Assert for Assigned Roles records
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchAllAssignedRoleRecords());
        
        //Assert for Custom Message 'Insufficient Access To RecordId'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchStaffAssignmentRecords(''));
        System.assertEquals(System.Label.Insufficient_Access_To_RecordId, StaffAssignmentManagementController.fetchStaffAssignmentRecords('').message);
        
        delete staffAssignments;
        
        //Assert for Custom Message 'No Staff Assignment To Display'
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchStaffAssignmentRecords(addEditStaffAssignmentsController.eabEventId));
        System.assertEquals(System.Label.No_Staff_Assignment_To_Display, StaffAssignmentManagementController.fetchStaffAssignmentRecords(addEditStaffAssignmentsController.eabEventId).message);
        
        undelete staffAssignments;
        System.assertNotEquals(null,StaffAssignmentManagementController.fetchStaffAssignmentRecords(addEditStaffAssignmentsController.eabEventId));
        
        System.assertNotEquals(null, StaffAssignmentManagementController.saveStaffAssignmentRecords(null, '', null));
        
        //Assert for Custom Message 'No Staff Assignment To Create Update Delete'
        System.assertNotEquals(null, StaffAssignmentManagementController.saveStaffAssignmentRecords(
            addEditStaffAssignmentsController.eabEventId, null, staffAssignmentIdsToDelete));
        System.assertEquals(System.Label.No_Staff_Assignment_To_Create_Update_Delete, 
                            StaffAssignmentManagementController.saveStaffAssignmentRecords(
                                addEditStaffAssignmentsController.eabEventId, null, staffAssignmentIdsToDelete).message);
        
        //To fill StaffAssignmentWrapper to insert / delete Staff Assignment records
        List<StaffAssignmentManagementController.StaffAssignmentWrapper> staffAssignmentWrapper = new List<StaffAssignmentManagementController.StaffAssignmentWrapper>();
        staffAssignmentWrapper.add(new StaffAssignmentManagementController.StaffAssignmentWrapper(staffAssignments[0].Id, 
                                                              staffAssignments[0].NAME, contacts[1].Id,
                                                              contacts[1].NAME, teamRoles[1].Id, teamRoles[1].NAME));
        staffAssignmentWrapper.add(new StaffAssignmentManagementController.StaffAssignmentWrapper(null, 
                                                              null, contacts[1].Id,
                                                              contacts[1].NAME, teamRoles[1].Id, teamRoles[1].NAME));
        
        
        String staffAssignmentJson = JSON.serialize(staffAssignmentWrapper); 
        
        staffAssignmentIdsToDelete.add(staffAssignments[0].Id);
        //Assert for Save functionality
        System.assertNotEquals(null, StaffAssignmentManagementController.saveStaffAssignmentRecords(addEditStaffAssignmentsController.eabEventId, staffAssignmentJson, staffAssignmentIdsToDelete));
        Test.stopTest();
    }
}