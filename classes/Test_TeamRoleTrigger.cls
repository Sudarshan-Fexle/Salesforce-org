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

//Updated the Test class to add Business Line Field at the time of Assignment Role creation. CR-20180917-12602 - 10/08/2018
//Updated the Test class to update EAB Event fields(Coordinator, Event Manager, Onsite Manager). CR-20200819-14449 - 09/30/2018
@isTest(seeAllData = false)
private class Test_TeamRoleTrigger {

    //Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
    
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'UniqueName', Active__c = true, Institution__c = true, Business_Line__c = 'Advancement'));
       
        //Insert teamRoles
        insert teamRoles;
        
        //Added by Saurabh Kumar - CR-20200819-14449 (Account, Profile, User, RecordType, Contact, Eab Event)
        //List of Account
        List<Account> account = new List<Account>();
        account.add(new Account(Name = 'TestAccounts1'));
        account.add(new Account(Name = 'TestAccounts2'));
        account.add(new Account(Name = 'TestAccounts3'));
       
        //Insert Account 
        insert account;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Create User record
        User users = new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                                Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                                timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true);  
        //insert users
        insert users;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'EAB_Event'];
        System.assert(recordTypes != null);
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[0].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[1].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact3', LastName = 'Contact3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[2].Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact
        insert contacts;
        
        List<Advisory_Event__c> eabEvents = new List<Advisory_Event__c>();
        Advisory_Event__c eabEvent1 = new Advisory_Event__c(Name = 'TestEabEvent1', Begins__c = Date.today(), 
                                                            Ends__c = Date.today(), Short_Name__c = 'TestEabEvent1');
        eabEvents.add(eabEvent1);
        Advisory_Event__c eabEvent2 = new Advisory_Event__c(Name = 'TestEabEvent2', Begins__c = Date.today(), 
                                                            Ends__c = Date.today(), Short_Name__c = 'TestEabEvent2');
        eabEvents.add(eabEvent2);
        insert eabEvents;
        
    }
    
    //Test method to check the valid Team role
    static testMethod void testValidateTeamRoles() {
        
        //Start Testing from here
        Test.startTest();
        
        //Create duplicate team role
        Team_Role__c teamRole = new Team_Role__c(Name = 'UniqueName', Institution__c = true, Business_Line__c = 'Advancement');
        
        //Try to insert team role
        try {
            
            insert teamRole;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Team Role was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_ROLE_NAME));
        }
        
        //Change the Name and the insert. It should be inserted successfully this time
        teamRole.Name = 'UniqueName II';
        insert teamRole;
        
        //Try to update the Name with a name already exists
        try {
        
            teamRole.Name = 'UniqueName';
            update teamRole;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplaicate Team Role was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_ROLE_NAME));
        }
        
        //Try to update  without changing anything, Just to amke sure record in not referencing it's own instance
        teamRole.Name = 'UniqueName II';
        update teamRole;
        
        //Try to update with a different name
        teamRole.Name = 'UniqueName I';
        update teamRole;
        
        //Stop Test
        Test.stopTest();
    }
    
    //Added by - Subhash Garhwal
    //Test method to test updateStaffAssignment methods functionality
	static testMethod void updateStaffAssignment() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
    
	    //Create account 
	    //List to hold Account records
	    List<Account> accounts = new List<Account>();
	    
	    //Add new accounts in list
	    accounts.add(new Account(Name = 'Test Account1'));
	    accounts.add(new Account(Name = 'Test Account2'));
	    accounts.add(new Account(Name = 'Test Account3'));
	        
	    //Insert 
	    insert accounts;
	    
	    //Create contact
	    List<Contact> contacts = new List<Contact>();
	    
	    //Add contacts in list
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[0].Id,Active_PSS__c = true));
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[1].Id,Active_PSS__c = true));
	    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 3',Employee_User_Record__c = Userinfo.getUserId(), Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = accounts[2].Id,Active_PSS__c = true));
	    
	    //Insert contact
	    insert contacts;
	    
	    //Create Team Role (Assignment Roles)
	    List<Team_Role__c> staffRoles = new List<Team_Role__c>();
	    
	    //Add new Team Roles in list
	    staffRoles.add(new Team_Role__c(Name = 'Test 1',Active__c = true, Institution__c = true));
	    staffRoles.add(new Team_Role__c(Name = 'Test 2',Active__c = true, Institution__c = true));
	    
	    //Insert
	    insert staffRoles;
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
	            
	    //Create staff Assignment 
	    List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
	    
	    //Add Staff Assignments in list
	    staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Staff_member__c = contacts[0].Id, 
                                                    Role__c = staffRoles[0].Id, Institution__c = accounts[0].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                   	RecordTypeId = tmRecordTypes[0].Id));
	    staffAssignments.add(new Team_Membership__c(Name = 'Test As 2',Staff_member__c = contacts[1].Id, 
                                                    Role__c = staffRoles[1].Id, Institution__c = accounts[1].Id , 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                   	RecordTypeId = tmRecordTypes[0].Id));
	    
	    //Insert
	    insert staffAssignments; 
	    
	    //Start tesing form here
	    Test.startTest();
	    
	    //Query through Staff Assignment
        List<Team_Membership__c> teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test 1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
        
        //Update
	    update staffRoles;
	    
	    //Query through Staff Assignment
        teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-Test 1', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
        
	    //Update staffRole
	    staffRoles[0].Name = 'TestChange';
	    
	    //Update
	    update staffRoles;
	    
	   //Query through Staff Assignment
        teamMemberships = [Select Id, Name From Team_Membership__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assertEquals(2, teamMemberships.size());
        System.assertEquals('Test Contact 1-TestChange', teamMemberships[0].Name);
        System.assertEquals('Test Contact 2-Test 2', teamMemberships[1].Name);
	   
	    Test.stopTest(); 
	}

    //Added by - Subhash Garhwal
    //Test method to test updateStaffAssignment methods functionality
    static testMethod void validateDelete() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add account in list
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert
        insert accounts;
        
        // Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add Contact in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = UserInfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = UserInfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create Team Role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new Team Roles in list
        staffRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test2',Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRoles;
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Create Staff Assignment 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Staff_member__c = contacts[0].Id, 
                                                    Institution__c = accounts[0].Id, Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Staff_member__c = contacts[1].Id,
                                                    Institution__c = accounts[0].Id, Role__c = staffRoles[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments;
        
        // Test method start
        Test.startTest();
        
        //Delete
        delete staffRoles[1];
        
        try {
        
	        // Delete    
	        delete staffRoles[0];
        
        } catch(Exception e){
            
            System.assert(e.getMessage().contains(Label.ASSIGNMENT_ROLE_IN_USE));
        }
        
        //Test method Stop
        Test.stopTest();
    }
    
    //Added by Saurabh Kumar - 9/30/2020 - CR-20200819-14449
    //Test method to update EAB Event fields(Coordinator, Event Manager, Onsite Manager)
    static testMethod void testSyncRelatedStaffAssignmentEABEventFields() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = [SELECT ID FROM Account];
        List<Advisory_Event__c> eabEvents = [SELECT ID, Short_Name__c FROM Advisory_Event__c 
                                             WHERE Short_Name__c = 'TestEabEvent1'];
       
        List<Contact> contacts = [SELECT ID, Employee_User_Record__c FROM Contact WHERE LASTNAME = 'Contact1' OR
                                  LASTNAME = 'Contact2' OR LASTNAME = 'Contact3'];
      
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'EAB_Event'];
        System.assert(recordTypes != null);
        
         
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        teamRoles.add(new Team_Role__c(Name = 'Test Role 1',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test Role 2',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = Constants.ASSIGNMENT_ROLE_NAME_ONSITE_EVENT_MANAGER,Active__c = true, Institution__c = true));
        
        insert teamRoles;
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
           
        Team_Membership__c teamMembership1 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[0].Id, Role__c = teamRoles[0].Id, 
                                                                    RecordTypeId = recordTypes[0].Id, EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership1);
        
        Team_Membership__c teamMembership2 = new Team_Membership__c(Name = 'TestTeamMember2', Staff_member__c = contacts[1].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[1].Id, Role__c = teamRoles[1].Id, 
                                                                    RecordTypeId = recordTypes[0].Id, EAB_Event__c = eabEvents[0].Id);
        
        teamMemberShips.add(teamMembership2);
        
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember3', Staff_member__c = contacts[2].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[2].Id, Role__c = teamRoles[2].Id, 
                                                                    RecordTypeId = recordTypes[0].Id, EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership3);
        
        insert teamMemberShips;
     
        Test.startTest();
        
        teamRoles = [SELECT ID FROM Team_Role__c WHERE Name = 'Test Role 1' OR Name = 'Test Role 2'];
       
        teamRoles[0].NAME = Constants.ASSIGNMENT_ROLE_NAME_EVENT_COORDINATOR;
        teamRoles[1].NAME = Constants.ASSIGNMENT_ROLE_NAME_EVENT_MANAGER;
      
        update teamRoles;
        
        eabEvents = [SELECT ID, Short_Name__c, Coordinator__c, Event_Manager__c, Onsite_Lead__c  FROM Advisory_Event__c 
                     					      WHERE Short_Name__c = 'TestEabEvent1'];
        
        //Assert for Eab Event's field in case of insert 
        system.assertEquals(contacts[0].Employee_User_Record__c, eabEvents[0].Coordinator__c);
        system.assertEquals(contacts[1].Employee_User_Record__c, eabEvents[0].Event_Manager__c);
        system.assertEquals(contacts[2].Employee_User_Record__c, eabEvents[0].Onsite_Lead__c);
        
        Test.stopTest();
    } 
}