/**
    *  @description    :   This batch is used to Remove the Active Institution on Staff Assignment - 
    * 					   because Staff Assignment.Status is a Formula Field and can change the value with out DML on it. 
    * 					   So this batch Job will scheduled at night and check if any staff Assignment is Inavtive 
    * 					   and have the value in the Acttive Institution Field 
    * 					   then nullify the Active institution.  
    * 
    *  @args           :   List<Team_Membership__c>
    *
    *  @return         :   void
    * 
    *  Created By      :   V1.1 - Added by Rajeev Jain - CR-20170812-11145 - Update the Active Institution field
    *                      V1.2 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
    *
  **/ 
@isTest
public class Test_Batch_ActiveInstitutionStaffAssign {
	
    @isTest Static void myUnitTest() {
    	
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
      	//Create team role
        List<Team_Role__c> teamRoles = new List<Team_Role__c>();
        
        //Add Team Role in list
        teamRoles.add(new Team_Role__c(Name = 'Test1',Active__c = true, Institution__c = true));
        
        //Insert teamRoles
        insert teamRoles;
         
        //List of Account
        List<Account> account = new List<Account>();
        account.add(new Account(Name = 'TestAccounts1'));
        
        //Insert Account 
        insert account;
        
        //Added By - Mahendra swarnkar - 2/11/2016 - CR-20151022-9348
        //Starts fro here
        //Create a program record
        List<Program__c> prog  = new List<Program__c>();
        prog.add (new Program__c(Name = 'Test Program1'));
        
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
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp1', Program__c = prog[0].Id, /*Originator__c = users.Id,*/ AccountId = account[0].Id , CloseDate = system.today(),StageName = 'Prospect', RecordTypeId = oppoRecordType_Consulting_AND_Management[0].Id ));
        
        //Insert Opportunities
        insert opportunities;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'test1@test.com', 
		AccountId = account[0].Id, Employee_User_Record__c = Userinfo.getUserId(), 
		Title = 'Test', Phone = '614-555-8855'));
        
        //Insert Contact
        insert contacts;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(recordTypes != null);
        
        //Team Membership
        List<Team_Membership__c> teamMemberShips = new List<Team_Membership__c>();
           
        //Team Membership
        Team_Membership__c teamMembership3 = new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id,
                                                                    Employee__c = UserInfo.getUserId(), 
                                                                    Institution__c = account[0].Id, Role__c = teamRoles[0].Id, 
                                                                    Start_date__c = Date.today(), 
                                                                    End_date__c = Date.today().addDays(5),
                                                                    RecordTypeId = recordTypes[0].Id);
        
        //Utill ByPassAllTriggers = true
        Util.ByPassAllTriggers = true;
        
        //Insert teamMembership3
        teamMemberShips.add(teamMembership3);
        
        insert teamMemberShips;
        
        //Query on the Team Membership
        List<Team_Membership__c> teamMems = [Select Id, Institution__c, End_date__c,Active_institution__c, Status__c From Team_Membership__c];
        System.assertEquals('Active',teamMems[0].Status__c);
        System.assertEquals(teamMems[0].Institution__c,teamMems[0].Active_institution__c);
        
        //Adding a BYPass Logic for Current User to off the Trigger. 
        Bypass_Logic__c bypass = new Bypass_Logic__c();
        bypass.Bypass_Triggers__c = True;
        bypass.SetupOwnerId = UserInfo.getUserId();
        bypass.Objects_to_Bypass__c = 'Team_Membership__c';
        
        insert bypass;

        //Updating the Staff Assignments 
        teamMems[0].End_Date__c = Date.Today().addDays(-2);
        teamMems[0].Start_date__c = Date.today().addDays(-3);
        Update teamMems[0];
        
        //Deleting the Bypass Logic
        delete bypass;
        
        //Query on the Team Membership
        List<Team_Membership__c> teamMem = [Select Id, End_date__c, Status__c, Institution__c, Active_Institution__c  From Team_Membership__c];
        System.assertEquals('Inactive',teamMem[0].Status__c);
        System.assertEquals(teamMem[0].Institution__c,teamMem[0].Active_Institution__c);
        
        //Test Start
        Test.StartTest();
			
        	Batch_ActiveInstitutionStaffAssignment b = new Batch_ActiveInstitutionStaffAssignment();
        	Database.executeBatch(b, 100);
        	
        //Test Stop
        Test.stopTest();
        
        //Query on the Team Membership
        List<Team_Membership__c> teamMems1 = [Select Id, End_date__c, Status__c, Active_Institution__c From Team_Membership__c];
        
        //Asserts
        System.assertEquals(null, teamMems1[0].Active_Institution__c);
        
       
    }
}