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

 Revision Log    :	v1.0 - Test method added - Subhash Garhwal - 07/03/2015 - CR-20150618-9014
			v1.1 - Modified By - Mahendra swarnkar - 2/11/2016 - CR-20151022-9348 - Added a new Test method ie.
 			v1.2 - Modified By - Rajeev Jain - 05/29/2016 - Conflict found with Rlease 50 CR - 9224
 			v1.3 - Modified By - Rajeev Jain - 05/05/2016 - ISSP deployment E - Added new method testCreateIncentiveChangeLog
 			v1.4 - Modified By - Rajeev Jain - 02/17/2020 - CR-20190925-13366 -  Remove zzzSolution(Solution__c) field.
 			v1.5 - Modified By - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
			v1.6 - Modified By - Saurabh Kumar - 10/16/2020 - CR-20200821-14455 - Added a new method associateRecentRegistrationWithStaffAssignment
			v1.7 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
			v1.8 - Modified By - Chirag Soni - CR-20210510-15128 - initialize mock response
			v1.9 - Modified By - Chirag Soni - CR-20210308-14970 - 07/27/2021 - Update testUpdateRPPs method
			v2.0 - Modified By - Chirag Soni - CR-20210824-15376 - 10/27/2021 - Updated the setup data to meet updated condition in the main class
 */
@isTest(seeAllData = false) 
private class Test_TeamMembershipTrigger {
    
    //Setup test data first. This will be available in the entire class
    @testSetup static void setup() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Solutions Executive',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test2',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test3',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = 'Test4',Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = Constants.ASSIGNMENT_ROLE_NAME_EVENT_COORDINATOR,Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = Constants.ASSIGNMENT_ROLE_NAME_EVENT_MANAGER,Active__c = true, Institution__c = true));
        teamRoles.add(new Team_Role__c(Name = Constants.ASSIGNMENT_ROLE_NAME_ONSITE_EVENT_MANAGER,Active__c = true, Institution__c = true));
        
        //Insert teamRoles
        insert teamRoles;
         
        //List of Account
        List<Account> account = new List<Account>();
        account.add(new Account(Name = 'TestAccounts1'));
        account.add(new Account(Name = 'TestAccounts2'));
        account.add(new Account(Name = 'TestAccounts3'));
        account.add(new Account(Name = 'TestAccounts4'));
       
        //Insert Account 
        insert account;
        
        //Added By - Mahendra swarnkar - 2/11/2016 - CR-20151022-9348
        //Starts fro here
        //Create a program record
        List<Program__c> prog  = new List<Program__c>();
        prog.add (new Program__c(Name = 'Test Program1'));
        prog.add (new Program__c(Name = 'Test Program2'));
        prog.add (new Program__c(Name = 'Test Program3'));
        prog.add (new Program__c(Name = 'Test Program4'));
    
        //Insert Program
        insert prog;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Create User record
        User users = new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                                Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                                timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true);  
        //insert users
        insert users;
        
        //Fetch the Opportunity record type "Consulting & Management"
        List<RecordType> oppoRecordType_Consulting_AND_Management = [select Id, DeveloperName From RecordType 
                                                                     where SobjectType = 'Opportunity' 
                                                                     AND RecordType.DeveloperName = 'BI_Marketing' 
                                                                     AND IsActive = true];
        
        //List to hold opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
    
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Commented Originator__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp1', Program__c = prog[0].Id, /*Originator__c = users.Id, */ AccountId = account[0].Id , CloseDate = system.today(),StageName = 'Prospect', RecordTypeId = oppoRecordType_Consulting_AND_Management[0].Id ));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp2', Program__c = prog[1].Id, /*Originator__c = users.Id, */ AccountId = account[0].Id , CloseDate = system.today(),StageName = 'Prospect', RecordTypeId = oppoRecordType_Consulting_AND_Management[0].Id));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp3',Program__c = prog[2].Id,  /*Originator__c = users.Id, */ AccountId = account[0].Id , CloseDate = system.today(),StageName = 'Prospect', RecordTypeId = oppoRecordType_Consulting_AND_Management[0].Id));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp4', Program__c = prog[3].Id, /*Originator__c = users.Id, */ AccountId = account[0].Id , CloseDate = system.today(),StageName = 'Prospect', RecordTypeId = oppoRecordType_Consulting_AND_Management[0].Id));
        
        //Insert Opportunities
        insert opportunities;
        //Mahendra swarnkar - 2/11/2016 - CR-20151022-9348 - up to here
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[0].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[1].Id, Employee_User_Record__c = Userinfo.getUserId()));
        contacts.add(new Contact(FirstName = 'TestContact3', LastName = 'Contact3', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account[2].Id, Employee_User_Record__c = Userinfo.getUserId()));
        
        //Insert Contact
        insert contacts;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND (DeveloperName = 'Assigned' OR DeveloperName = 'EAB_Event')];
        System.assert(recordTypes != null);
        
        //Added by Saurabh Kumar - CR-20200819-14449
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
           
        //Team Membership
	//Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        Team_Membership__c teamMembership1 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[0].Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    RecordTypeId = recordTypes[0].Id,
                                                                    EAB_Event__c = eabEvents[0].Id);
        
        //Insert teamMembership1
        teamMemberShips.add(teamMembership1);
        
        //Team Membership2 with No start Date to check with Null Scenario
	//Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        Team_Membership__c teamMembership2 = new Team_Membership__c(Name = 'TestTeamMember2', Staff_member__c = contacts[1].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[1].Id, Role__c = teamRoles[1].Id, 
                                                                    Start_date__c = Date.today().addDays(7), 
                                                                    End_date__c = Date.today().addDays(10),
                                                                    RecordTypeId = recordTypes[0].Id,
                                                                    EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership2);
        
        //Added by Saurabh Kumar - CR-20200819-14449
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember3', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[1].Id, Role__c = teamRoles[4].Id, 
                                                                    RecordTypeId = recordTypes[1].Id, EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership3);
        
        Team_Membership__c teamMembership4 = new Team_Membership__c(Name = 'TestTeamMember4', Staff_member__c = contacts[1].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[1].Id, Role__c = teamRoles[5].Id, 
                                                                    RecordTypeId = recordTypes[1].Id, EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership4);
	//Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        //Bypass flag
        Util.BypassAllTriggers = true;
        insert teamMemberShips;
        
       
        //To membership for subsctitute of Edit role button finctionality work to make it LEX compatible. 
        Team_Membership__c teamMembership5 = new Team_Membership__c(Name = 'TestTeamMember5', Staff_member__c = contacts[1].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[0].Id, Role__c = teamRoles[4].Id, 
                                                                    Source_Staff_Assignment__c = teamMemberShips[0].Id,
                                                                    Start_date__c = Date.today().addDays(7), 
                                                                    End_date__c = Date.today().addDays(10),
                                                                    RecordTypeId = recordTypes[1].Id,
                                                                    Rpp_Clone_Needed__c = 'true'
                                                                   );
        
        teamMemberShips = new List<Team_Membership__c>();
        teamMemberShips.add(teamMembership5);
	//Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        //Bypass  flag
        Util.BypassAllTriggers = true;
        insert teamMemberShips;
        
    }
    
    //Test method to check the valid Team role
    static testMethod void testValidateTeamMemberships() {
        
        //Query Institution and Team role records and Contacts
        List<Account> account = [Select Id from Account];
        List<Contact> contacts = [Select Id from Contact];
        List<Team_Role__c> teamRole = [Select Id from Team_Role__c];
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        
        //List OF team Memebrship
        List<Team_Membership__c> teamMembership1 = [Select Id, Start_date__c From Team_Membership__c];
        teamMembership1[0].Start_date__c = Date.today().addDays(-2);
        teamMembership1[1].End_Date__c = Date.today().addDays(-1);
        teamMembership1[1].Start_date__c = Date.today().addDays(-1);
        Update teamMembership1;
        
        teamMembership1[1].End_Date__c = Date.today().addDays(3);
        teamMembership1[1].Start_date__c = Date.today().addDays(2);
        Update teamMembership1[1];
        
        
        //Team Membership
        Team_Membership__c teamMembership = new Team_Membership__c(Name = 'TestTeamMember3', Staff_member__c = contacts[1].id,
                                                                   Employee__c = UserInfo.getUserId(), 
                                                                   Institution__c = account[1].Id, 
                                                                   Role__c = teamRole[1].Id, 
                                                                   Start_date__c = Date.today().addDays(5), 
                                                                   End_date__c = Date.today().addDays(9),
                                                                   RecordTypeId = tmRecordTypes[0].Id);
        
        //Start Testing from here
        Test.startTest();
        
        //Try to insert team role
        try {
            
            //Insert teamMembership
            insert teamMembership;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            //System.assert(false, 'Duplicate Team Membership was added.');
            
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP));
        }
        
        //Change the Date crietirea. It should not be inserted successfully this time
        teamMembership.Start_date__c = Date.today().addDays(8);
        teamMembership.End_date__c = Date.today().addDays(9);
        
        try {
            
            insert teamMembership;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            System.assert(false, 'Duplicate Team Membership was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            //System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP));
        }
        
        //Change the Name and the insert. It should be inserted successfully this time
        teamMembership.Start_date__c = Date.today().addDays(12);
        teamMembership.End_date__c = Date.today().addDays(18);
        
        update teamMembership;
        
        //Try to update the Start Date with a date already exists
        try {
        
            teamMembership.Start_date__c = Date.today().addDays(9);
            teamMembership.End_date__c = Date.today().addDays(12);
            update teamMembership;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            //System.assert(false, 'Duplicate Team Membership was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP));
        }
        
        //Try to update the Start Date with a date already exists
        try {
        
            teamMembership.Start_date__c = Date.today().addDays(6);
            teamMembership.End_date__c = Date.today().addDays(12);
            update teamMembership;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            //System.assert(false, 'Duplicate Team Membership was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP));
        }
        
        //Try to update the Start Date with a date already exists
        try {
        
            teamMembership.Start_date__c = Date.today().addDays(7);
            teamMembership.End_date__c = Date.today().addDays(10);
            update teamMembership;
            
            //If the role get added, that means trigger is not working as expected and fail the test method
            //System.assert(false, 'Duplicate Team Membership was added.');
        
        } catch(Exception e) {
            
            //Check teh exception message and pass the test method
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP));
        }
        
        //Try to update  without changing anything, Just to amke sure record in not referencing it's own instance
        teamMembership.Start_date__c = Date.today() + 13;
        teamMembership.End_date__c = Date.today().addDays(20);
        update teamMembership;
            
        //Try to update with a different start date
        teamMembership.Start_date__c = Date.today() + 15;
        update teamMembership;
        
        //Stop Test
        Test.stopTest();
    }
    
    //Added by - Subhash Garhwal - CR-20150618-9014
    //Test method to test ValidateUpdate methods functionality
    static testMethod void testValidateUpdate() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create account 
        //List to hold Account records
        List<Account> account = new List<Account>();
        
        //Add new accounts in list
        account.add(new Account(Name = 'Test Account1'));
        account.add(new Account(Name = 'Test Account2'));
        account.add(new Account(Name = 'Test Account3'));
        
        //Insert 
        insert account;
        
        //Query to get contact list
        List<Contact> contacts = [Select Id from Contact];
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enabling trigger here
        util.BypassAllTriggers = false;
        

        //Create staff Assignment 
        List<Team_Membership__c> staffAssignment = new List<Team_Membership__c>();
        
        //Add Staff Assignments in list
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = account[0].Id , 
                                                   Staff_member__c = contacts[1].id ,
                                                   Start_date__c = System.today().addDays(-1), 
                                                   End_date__c = System.today().addDays(5),
                                                   RecordTypeId = tmRecordTypes[0].Id));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 2',Institution__c = account[1].Id , 
                                                   Staff_member__c = contacts[0].id, 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(5),
                                                   RecordTypeId = tmRecordTypes[0].Id));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 3',Institution__c = account[2].Id , 
                                                   Staff_member__c = contacts[2].id, 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(5),
                                                   RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignment;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new recrods in list
        perspectives.add(new Perspective__c(Name = 'perspective 1'));
        perspectives.add(new Perspective__c(Name = 'perspective '));
        
        //Insert
        insert perspectives;
        
        //Create Program Groups
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list
        programCollections.add(new Program_Group__c(Name = 'PC 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2'));
        
        //Insert
        insert programCollections;
        
        //Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new recrods in list
        programPerspectives.add(new Program_Perspective__c(Name = 'pp1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[0].Id));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[1].Id));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        
        //Insert Program Pespective
        insert programPerspectives;
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspective = new List<Role_Program_Perspective__c>();
        
        //Add new RPPs in list
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[0].Id, 
                                                                   Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4)));
        
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[1].Id,
                                                                   Effective_Start__c = System.today().addDays(1), Effective_End__c = System.today().addDays(5)));
                                                                   
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[1].Id, Program_Perspective__c = programPerspectives[2].Id,
                                                                   Effective_Start__c = System.today().addDays(-2),Effective_End__c = System.today().addDays(4)));
        
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 3',Staff_Assignment__c = staffAssignment[2].Id, Program_Perspective__c = programPerspectives[3].Id,
                                                                   Effective_Start__c = null, Effective_End__c = null));                                        
        
        //Insert 
        insert roleProgramPerspective;
        
        // Test Start here
        Test.startTest();
        
        //Query through RPPs
        List<Role_Program_Perspective__c> rPPs = [Select Id, Effective_Start__c, Effective_End__c From Role_Program_Perspective__c ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(4, rPPs.size());
        System.assertEquals(System.today(), rPPs[0].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[0].Effective_End__c);
        System.assertEquals(System.today().addDays(1), rPPs[1].Effective_Start__c);
        System.assertEquals(System.today().addDays(5), rPPs[1].Effective_End__c);
        System.assertEquals(System.today().addDays(-2), rPPs[2].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[2].Effective_End__c);
        
        //Update Staff Assignments
        update staffAssignment;
        
        //Query through RPPs
        rPPs = [Select Id, Effective_Start__c, Effective_End__c From Role_Program_Perspective__c ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(4, rPPs.size());
        System.assertEquals(System.today(), rPPs[0].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[0].Effective_End__c);
        System.assertEquals(System.today().addDays(1), rPPs[1].Effective_Start__c);
        System.assertEquals(System.today().addDays(5), rPPs[1].Effective_End__c);
        System.assertEquals(System.today().addDays(-2), rPPs[2].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[2].Effective_End__c);
        
        //update staffAssignment  
        staffAssignment[0].Start_date__c = System.today().addDays(+2);
        staffAssignment[0].End_date__c = System.today().addDays(4);
        staffAssignment[1].End_date__c = System.today().addDays(3);
        staffAssignment[2].Start_date__c = System.today().addDays(3);
        staffAssignment[2].End_date__c = System.today().addDays(4);
        
        //Update
        update staffAssignment; 
        
        //Query through RPPs
        rPPs = [Select Id, Effective_Start__c, Effective_End__c From Role_Program_Perspective__c ORDER BY CreatedDate ASC];
        
        //Assert
        System.assertEquals(4, rPPs.size());
        System.assertEquals(System.today().addDays(2), rPPs[0].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[0].Effective_End__c);
        System.assertEquals(System.today().addDays(2), rPPs[1].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[1].Effective_End__c);
        System.assertEquals(System.today().addDays(-2), rPPs[2].Effective_Start__c);
        System.assertEquals(System.today().addDays(3), rPPs[2].Effective_End__c);
        System.assertEquals(System.today().addDays(3), rPPs[3].Effective_Start__c);
        System.assertEquals(System.today().addDays(4), rPPs[3].Effective_End__c);
        
        // Test Stop here
        Test.stopTest(); 
    }
    
    //V_1.4 - Modified - Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Error In Update Program Collection record
    //Comment the "recalculateProgramPerspectives" method from TeamMembershipTriggerHelper and move the functionality in Batch and update batch test class "Test_Batch_UpdateProgramPerspectives"
    //Test method to test recalculateProgramPerspectives methods functionality
    /*static testMethod void testRecalculateProgramPerspectives() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create account 
        //List to hold Account records
        List<Account> accounts = new List<Account>();
        
        //Add new records in list
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2'));
        
        //Insert 
        insert accounts;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new record in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[1].Id));
    
        //Insert contact
        insert contacts;
        
        //Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new record in list
        programCollections.add(new Program_Group__c(Name = 'PC 1', Short_Name__c = 'short name 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2', Short_Name__c = 'short name 2'));
        programCollections.add(new Program_Group__c(Name = 'PC 3', Short_Name__c = 'short name 3'));
        
        //Insert
        insert programCollections;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        staffRoles.add(new Team_Role__c(Name = 'Test8', Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test5', Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRoles;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add records in list
        perspectives.add(new Perspective__c(Name = 'perspective 1'));
        perspectives.add(new Perspective__c(Name = 'perspective 2'));
        
        //Insert
        insert perspectives;
        
        //Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new records in list
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 3' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[2].Id));
        
        //Insert Program Pespective
        insert programPerspectives;
        
        //Create staff Assignment 
        List<Team_Membership__c> staffAssignment = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Enabling triggers here
        Util.BypassAllTriggers = false;
        
        //Add new records in list
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 1', Institution__c = accounts[0].Id , 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(+5),
                                                   RecordTypeId = tmRecordTypes[0].Id));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 2', Institution__c = accounts[1].Id, 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(+5),
                                                   RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignment;
        
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspective = new List<Role_Program_Perspective__c>();
        
        //Add new records in list
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[0].Id,
                                                                   Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3)));
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[1].Id,
                                                                   Effective_Start__c = System.today(),Effective_End__c = System.today().addDays(3)));
        
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 3',Staff_Assignment__c = staffAssignment[1].Id, Program_Perspective__c = programPerspectives[2].Id,
                                                                   Effective_Start__c = System.today(),Effective_End__c = System.today().addDays(3)));

        // Test method start here
        Test.startTest();
        
        //Insert 
        insert roleProgramPerspective;
        
        //Query through Staff Assignments
        List<Team_Membership__c> teamMemberships = [Select Id, Name, Program_Perspectives__c From Team_Membership__c 
                                                    Where Id IN : staffAssignment ORDER BY CreatedDate];
        
        //Asserts for result
        System.assertEquals(2, teamMemberships.size());
        System.assert(teamMemberships[0].Program_Perspectives__c.contains(programCollections[0].Short_Name__c));
        System.assert(teamMemberships[0].Program_Perspectives__c.contains(programCollections[1].Short_Name__c));  
        System.assertEquals(programCollections[2].Short_Name__c, teamMemberships[1].Program_Perspectives__c);
        
        // test method stop here 
        Test.stopTest();
    }*/
    
    //Added by - Subhash Garhwal
    //Test method to test updateRPPs methods functionality
    //Modified By - Chirag Soni - CR-20210308-14970 - 07/27/2021
    static testMethod void testUpdateRPPs() 
    {
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add new record
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert
        insert accounts;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new records in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new records in list
        staffRoles.add(new Team_Role__c(Name = 'Test12',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test22',Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRoles;
        
        //Enabling triggers here
        Util.BypassAllTriggers = false;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new recrods in list
        perspectives.add(new Perspective__c(Name = 'perspective 1'));
        perspectives.add(new Perspective__c(Name = 'perspective '));
        
        //Insert
        insert perspectives;
        
        //Create Program Groups
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list
        programCollections.add(new Program_Group__c(Name = 'PC 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2'));
        
        //Insert
        insert programCollections;
        
        //Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new recrods in list
        programPerspectives.add(new Program_Perspective__c(Name = 'pp1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        
        //Insert Program Pespective
        insert programPerspectives;
        
        //Create staff Assignment 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Add new recrods in list
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Staff_member__c = contacts[0].Id, 
                                                    Role__c = staffRoles[0].Id, Institution__c = accounts[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Staff_member__c = contacts[1].Id, 
                                                    Role__c = staffRoles[1].Id,Institution__c = accounts[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments;
        
        //Create role Program perspective 
        List<Role_Program_Perspective__c> rPPs = new List<Role_Program_Perspective__c>();
        
        //Add new recrods in list
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp1',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[0].Id));
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp2',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[1].Id));
        
        //Start testing from here
        Test.startTest();
        
        //Insert role Program perspective
        insert rPPs;
        
        //Update contact
        contacts[0].FirstName = 'TestCon';
        
        //update
        update contacts;
        
        //Query through RPPs
        List<Role_Program_Perspective__c> rPPList = [Select Id,Name From Role_Program_Perspective__c ORDER BY CreatedDate ASC];
        
        //Assert for result
        System.assert(rPPList != null);
        System.assertEquals(2,rPPList.size());
        
        //Modified By - Chirag Soni - CR-20210308-14970 - 07/27/2021 - To check the combination of name for RPPs
        System.assertEquals('Test1 Contact1-Test12-PC 1-perspective 1', rPPList[0].Name);
        
        //Test method Stop
        Test.stopTest();
    }
    
    //Added By - Mahendra swarnkar - 2/11/2016 - CR-20151022-9348
    //Test method to check the opportunity - Staff Assignments umiqueness()
    static testMethod void testTeamMembershipsWithOpportunity() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Query Institution, Opportunity, Contact and Team role records and Contacts
        List<Account> account = [Select Id from Account];
        List<Opportunity> opportunities = [Select Id from Opportunity];
        List<Contact> contacts = [Select Id from Contact];
        List<Team_Role__c> teamRole = [Select Id from Team_Role__c];
        
        //Looping over team role records and updating them
        for(Team_Role__c tR : teamRole) {
            tR.Opportunity__c = true;
        }
        update teamRole;
        
        //Create Team Membership records
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>(); 
        Team_Membership__c teamMembership1 = new Team_Membership__c(Name = 'TestTeamMember1', 
                                                                    Opportunity__c = opportunities[0].id, 
                                                                    Staff_member__c = contacts[0].id , 
                                                                    Institution__c = account[0].Id, Role__c = teamRole[0].Id, 
                                                                    RecordTypeId = TeamMembershipTriggerHelper.mapStaffAssignmentRecordTypes.get(TeamMembershipTriggerHelper.StaffAssignmentRTypes_Opportunity));
        Team_Membership__c teamMembership2 = new Team_Membership__c(Name = 'TestTeamMember2', 
                                                                    Opportunity__c = opportunities[1].id, 
                                                                    Staff_member__c = contacts[1].id , 
                                                                    Institution__c = account[1].Id, 
                                                                    Role__c = teamRole[1].Id, 
                                                                    RecordTypeId = TeamMembershipTriggerHelper.mapStaffAssignmentRecordTypes.get(TeamMembershipTriggerHelper.StaffAssignmentRTypes_Opportunity));
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember3', 
                                                                    Opportunity__c = opportunities[2].id, 
                                                                    Staff_member__c = contacts[0].id , 
                                                                    Institution__c = account[1].Id, 
                                                                    Role__c = teamRole[1].Id, 
                                                                    RecordTypeId = TeamMembershipTriggerHelper.mapStaffAssignmentRecordTypes.get(TeamMembershipTriggerHelper.StaffAssignmentRTypes_Opportunity));
        Team_Membership__c teamMembership4 = new Team_Membership__c(Name = 'TestTeamMember4', 
                                                                    Opportunity__c = opportunities[2].id, 
                                                                    Staff_member__c = contacts[1].id , 
                                                                    Institution__c = account[1].Id, 
                                                                    Role__c = teamRole[1].Id, 
                                                                    RecordTypeId = TeamMembershipTriggerHelper.mapStaffAssignmentRecordTypes.get(TeamMembershipTriggerHelper.StaffAssignmentRTypes_Opportunity));
        Team_Membership__c teamMembership5 = new Team_Membership__c(Name = 'TestTeamMember5', 
                                                                    Opportunity__c = opportunities[2].id, 
                                                                    Staff_member__c = contacts[1].id , 
                                                                    Institution__c = account[1].Id, 
                                                                    Role__c = teamRole[1].Id, 
                                                                    RecordTypeId = TeamMembershipTriggerHelper.mapStaffAssignmentRecordTypes.get(TeamMembershipTriggerHelper.StaffAssignmentRTypes_Opportunity));
    
        staffAssignments.add(teamMembership1);
        staffAssignments.add(teamMembership2);
        staffAssignments.add(teamMembership3);
        
        //Disables all the trigger
        Util.BypassAllTriggers = false;
    
        //Start Testing from here
        Test.startTest();
            
        //Insert teamMembership
        insert staffAssignments;
        
        //List to hold staff Assignments
        List<Team_Membership__c> staffAssignments1 = new List<Team_Membership__c>(); 
        
        staffAssignments1.add(teamMembership4);
        staffAssignments1.add(teamMembership5);
        
        //Try-Catch block
        try {
        
            //Disables all the trigger
            Util.BypassAllTriggers = false;
            
            //Insert staff assignments
            insert staffAssignments1;
        
        } catch(Exception e){
            
            //Assertion for results
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_WITH_OPPORTUNITY));
        }
        
        //Update the staff member
        teamMembership4.Staff_member__c = contacts[0].id;

        //Try-Catch block
        try {
        
            //Disables all the trigger
            Util.BypassAllTriggers = false;
            
            //Insert Staff assignment
            insert teamMembership4;
        
        } catch(Exception e){
        
            //Assertion for results
            System.assert(e.getMessage().contains(Label.ERROR_UNIQUENESS_TEAM_MEMBERSHIP_WITH_OPPORTUNITY));
        }
        
        //Stop Test
        Test.stopTest();
        
        //Apex class for the standard controller.
        ApexPages.StandardController sc = new ApexPages.StandardController(teamMembership4);
        
        //Check for the Autopopulation value
        WillAutoPopulateExtension controller = new WillAutoPopulateExtension(sc);
        controller.redirect();
        
    }
    
    
    ////V1.1 - Modified By - Rajeev Jain - 05/05/2016 - ISSP deployment E - Test CreateIncentiveChange log functionality
     /**
     *  @description    :   This method is used to Test Creat/Upddate Incentive Change Log, whenever a new Staff Assignement records insert and Date Rand Modified
     *  
     *  @args           :   List<Program_Relationship__c>, map<Id, Program_Relationship__c>
     *
     *  @return         :   void
     *                      Modified By - Seemu Saikia -CR-20190501-13072- 05/06/2019 - #Spring CleanUp
     *
     **/
     /*Spring CleanUp
    static testMethod void testCreateIncentiveChangeLogs() {
        
        //Since SA records are already inserted, then we just need to asserts for corrosponding ICL Records
         //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> iCG = [Select Id, Name, Contact__r.FirstName, Contact__r.LastName, Change_Type__c, Change_Element__c, Staff_Assignment__c, Contact__c From Incentive_Change_Log__c order by createddate];
        
        //Start Test from here
        Test.startTest();  
        
        //Three ICL Records for Contact and Two ICL Records for Staff Assignments will get inserts
        //Assert here for those records
        //System.assertEquals(2,iCG.size());
        //System.assertEquals('New',iCG[0].Change_Type__c);
        //System.assertEquals('New',iCG[1].Change_Type__c);
        
        //Stop Test from here
        Test.stopTest();
        
     }*/
    
     //Added by Saurabh Kumar - 9/30/2020 - CR-20200819-14449
     //Test method to update EAB Event fields(Coordinator, Event Manager, Onsite Manager)
     static testMethod void testPopulateEABEventFields(){
        
	//Modified By - Chirag Soni - CR-20210510-15128 - initialize mock response
        // initialize mock response
        Test.setMock(HttpCalloutMock.class, new MockAcquiaHTTPCallout());

        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        List<Account> accounts = [SELECT ID FROM Account];
        List<Advisory_Event__c> eabEvents = [SELECT ID, Short_Name__c FROM Advisory_Event__c 
                                             WHERE Short_Name__c = 'TestEabEvent1'];
       
        List<Team_Role__c> teamRoles = [SELECT ID FROM Team_Role__c WHERE Name = 'Event Coordinator' OR
                                        Name = 'Event Manager' OR Name = 'Onsite Event Manager'];
       
        List<Contact> contacts = [SELECT ID, Employee_User_Record__c FROM Contact WHERE LASTNAME = 'Contact1' OR
                                  LASTNAME = 'Contact2' OR LASTNAME = 'Contact3'];
       
        List<Team_Membership__c> teamMembers = [SELECT ID, NAME, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND (DeveloperName = 'Assigned' OR DeveloperName = 'EAB_Event')];
        System.assert(recordTypes != null);
   
        Test.startTest();
         
        //Assert for Eab Event's field in case of insert 
        system.assertEquals(contacts[0].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Coordinator__c);
        system.assertEquals(contacts[1].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Event_Manager__c);
        system.assertEquals(null, teamMembers[0].EAB_Event__r.Onsite_Lead__c);
        
        teamMembers[1].Role__c = teamRoles[2].Id;
        teamMembers[1].Staff_member__c = contacts[2].Id;
        update teamMembers[1];
        
        teamMembers = [SELECT ID, NAME, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        //Assert for Eab Event's field in case of update 
	//Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        system.assertEquals(contacts[0].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Coordinator__c);
        system.assertEquals(contacts[1].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Event_Manager__c);
        system.assertEquals(null, teamMembers[0].EAB_Event__r.Onsite_Lead__c);
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
        
        Team_Membership__c teamMembership6 = new Team_Membership__c(Name = 'TestTeamMember5', Staff_member__c = contacts[1].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = accounts[1].Id, Role__c = teamRoles[1].Id, 
                                                                    RecordTypeId = recordTypes[1].Id, EAB_Event__c = eabEvents[0].Id);
        teamMemberShips.add(teamMembership6);
        
        insert teamMemberShips;
        
        teamMembers = [SELECT ID, NAME, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        system.assertEquals(contacts[0].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Coordinator__c);
        //Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        system.assertEquals(contacts[1].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Event_Manager__c);
        system.assertEquals(null, teamMembers[0].EAB_Event__r.Onsite_Lead__c);
        
        delete teamMemberShips;
        
        teamMembers = [SELECT ID, NAME, EAB_Event__r.Coordinator__c, EAB_Event__r.Event_Manager__c, 
                                                EAB_Event__r.Onsite_Lead__c  FROM Team_Membership__c 
                                                WHERE EAB_Event__r.Short_Name__c = 'TestEabEvent1'];
        
        //Assert for Eab Event's field in case of delete  
        system.assertEquals(contacts[0].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Coordinator__c);
        //Updated by -  Chirag Soni - CR-20210824-15376 - test class issue fixes
        system.assertEquals(contacts[1].Employee_User_Record__c, teamMembers[0].EAB_Event__r.Event_Manager__c);
        system.assertEquals(null, teamMembers[0].EAB_Event__r.Onsite_Lead__c);
        
        Test.stopTest();
    }
    
    //Added by - Saurabh Kumar - To associate newly Or existing registration with Staff Assignment record
    static testMethod void testAssociateRecentRegistrationWithStaffAssignment(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
       
        List<Advisory_Event__c> eabEvents = [SELECT ID, Short_Name__c FROM Advisory_Event__c 
                                             WHERE Short_Name__c = 'TestEabEvent1'];
        List<Team_Role__c> teamRoles = [SELECT ID FROM Team_Role__c WHERE Name = 'Event Coordinator' OR
                                        Name = 'Event Manager' OR Name = 'Onsite Manager'];
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND (DeveloperName = 'Assigned' OR DeveloperName = 'EAB_Event')];
        System.assert(recordTypes != null);
    
        Account account = new Account(Name = 'TestAccounts5');
        insert account;
       
        Contact contact = new Contact(FirstName = 'TestContact4', LastName = 'Contact4', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        insert contact;
        
        Test.startTest();
        
        //Team Membership   
        Team_Membership__c teamMembership6 = new Team_Membership__c(Name = 'TestTeamMember6', Staff_member__c = contact.id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account.Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[1].Id);
        
        insert teamMembership6;
        
        //Assert for newly created registration record
        List<Registration__c> registrations = [SELECT ID, Status__c FROM Registration__c 
                                               WHERE Contact__c =: teamMembership6.Staff_member__c ];
        System.assertEquals(1, registrations.size());
        System.assertEquals('Registered', registrations[0].Status__c);
        
        //Team Membership
        Team_Membership__c teamMembership7 = new Team_Membership__c(Name = 'TestTeamMember7', Staff_member__c = contact.id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account.Id, Role__c = teamRoles[1].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    EAB_Event__c = eabEvents[0].Id,
                                                                    RecordTypeId = recordTypes[1].Id);
        
        insert teamMembership7;
        
        registrations = [SELECT ID, Status__c FROM Registration__c 
                                               WHERE Contact__c =: teamMembership7.Staff_member__c ];
        System.assertEquals(1, registrations.size());
        System.assertEquals('Registered', registrations[0].Status__c);
        
        delete teamMembership7;
        
        registrations = [SELECT ID, Status__c FROM Registration__c 
                                               WHERE Id =: registrations[0].Id];
        System.assertEquals(1, registrations.size());
        System.assertEquals('Registered', registrations[0].Status__c);
        
        delete teamMembership6;
        
        //Assert for updating status of registration 'Cancelled'
        registrations = [SELECT ID, Status__c FROM Registration__c 
                                               WHERE Id =: registrations[0].Id];
        System.assertEquals(1, registrations.size());
        System.assertEquals('Cancelled', registrations[0].Status__c);
            
        Test.stopTest();
        
    }
}