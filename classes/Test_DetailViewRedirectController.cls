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
@isTest(seeAllData = false)
Private class Test_DetailViewRedirectController {
/*
 *  Purpose     :   Test the DetailViewRedirectController Apex Class
 *
 *  Create By   :   MAhendra Swarnkar
 *
 *  Revision Log:   V1.0 - Created - CR-9712 - 05/20/2016
 *                  V1.1 - Modified - 07/27/2016 - CR-CR-20160414-9762 - Subhash Garhwal
 *                  V1.1 Modified By - Rajeev Jain - 17/02/2020 - CR-20190925-13366 -  Remove zzzSolution(Solution__c) field.
 *		    V1.2 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
*/  
    @testSetup static void testSetupData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing triggers
        Util.BypassAllTriggers = true;
        
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //insert User record
        User users = new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                                Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                                timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true);  
        insert users;
        
        //Account record
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //Insert Program
        Program__c prog  = new Program__c(Name = 'Test Program1');
        insert prog;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Opportunity record
        List<Opportunity> opportunities = new List<Opportunity>();
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Commented Originator__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp1',Main_Contact__c = cont.Id, Program__c = prog.Id, /*Originator__c = users.Id,*/ AccountId = acc.Id , CloseDate = system.today().addDays(32),StageName = '0-Exploring', RecordTypeId = Util.RecordTypeId('Opportunity', 'EAB Initiating')));
        opportunities.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',Name = 'Test Opp2', Main_Contact__c = cont.Id,Program__c = prog.Id, /*Originator__c = users.Id, */ AccountId = acc.Id , CloseDate = system.today().addDays(32),StageName = '0-Exploring', RecordTypeId = Util.RecordTypeId('Opportunity', 'PT Marketing')));
        insert opportunities;
        
        //Insert Assignment Role
        Team_Role__c teamRole = new Team_Role__c(Name = 'Solution Partner', Opportunity__c = true, Active__c = true);
        insert teamRole;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
       
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1', Email = 'test1@test.com', AccountId = acc.Id, Employee_User_Record__c = Userinfo.getUserId(), Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'TestContact2', LastName = 'Contact2', Email = 'test2@test.com', AccountId = acc.Id, Employee_User_Record__c = Userinfo.getUserId(), Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'TestContact3', LastName = 'Contact3', Email = 'test3@test.com', AccountId = acc.Id, Employee_User_Record__c = Userinfo.getUserId(), Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'TestContact4', LastName = 'Contact4', Email = 'test3@test.com', AccountId = acc.Id, Employee_User_Record__c = Userinfo.getUserId(), Title = 'Test', Phone = '614-555-8855'));
        
        //Insert Contact
        insert contacts;
        
        //List ofTeam Memberships
        List<Team_Membership__c> teamMemberships = new List<Team_Membership__c>();
        teamMemberships.add(new Team_Membership__c(Name = 'TestTeamMember1', Staff_member__c = contacts[0].id ,Employee__c = UserInfo.getUserId(), Institution__c = acc.Id, Opportunity__c = opportunities[0].Id, Role__c = teamRole.Id, Start_date__c = Date.today(), RecordTypeId = Util.RecordTypeId('Team_Membership__c', 'Opportunity')));
        teamMemberships.add(new Team_Membership__c(Name = 'TestTeamMember2', Staff_member__c = contacts[1].id ,Employee__c = UserInfo.getUserId(), Institution__c = acc.Id, Opportunity__c = opportunities[0].Id, Role__c = teamRole.Id, Start_date__c = Date.today(), RecordTypeId = Util.RecordTypeId('Team_Membership__c', 'Opportunity')));
        teamMemberships.add(new Team_Membership__c(Name = 'TestTeamMember3', Staff_member__c = contacts[2].id ,Employee__c = UserInfo.getUserId(), Institution__c = acc.Id, Opportunity__c = opportunities[1].Id, Role__c = teamRole.Id, Start_date__c = Date.today(), RecordTypeId = Util.RecordTypeId('Team_Membership__c', 'Opportunity')));
        teamMemberships.add(new Team_Membership__c(Name = 'TestTeamMember4', Staff_member__c = contacts[3].id ,Employee__c = UserInfo.getUserId(), Institution__c = acc.Id, Opportunity__c = opportunities[1].Id, Role__c = teamRole.Id, Start_date__c = Date.today(), RecordTypeId = Util.RecordTypeId('Team_Membership__c', 'Opportunity')));
        
        //Insert teamMemberships
        insert teamMemberships;
        
        //Create Membership record
        Membership__c mem = TestUtilities.CreateNewMembership(acc.Id, prog.Id, true);
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
    }
      
    static testmethod void myUnitTest() {
        
        //Fetch the Opportunity records
        List<Opportunity> opportunityList = [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName FROM Opportunity];
        
        //Opportunity Instances
        Opportunity opp_C_M;
        Opportunity opp_NO_C_M;
        
        //Iterate over the Opportunity records
        for(Opportunity opp : opportunityList) {
            
            //Check for record type
            if(opp.RecordType.DeveloperName == 'EAB_Initiating'/*DetailViewRedirectController.OPP_RECORD_TYPE_SOUTHWIND*/)
                opp_C_M = opp;
            else
                opp_NO_C_M = opp;   
        }
        
        //Standard Controller with opportunity of record type PT Marketing
        ApexPages.StandardController standardController = new ApexPages.StandardController(opp_NO_C_M);
        
        //Start Test from Here
        Test.startTest();
        
        // set the current page Opportunity_Detail
         // CR-20190423-13017
        //test.setCurrentPage(Page.Opportunity_Detail);
        
        //Controller Instance
        DetailViewRedirectController controller = new DetailViewRedirectController(standardController);
        
        //The redirectTo stays on the same page ie. no redirect
        system.assertEquals(true, controller.redirectTo().getUrl().contains('StdOpportunityDetail'));
        
        //Reinstantiate the standard Controller with opportunity of record type Consulting & Management
        standardController = new ApexPages.StandardController(opp_C_M);
        
        // set the current page Opportunity_Consulting_And_Management
        test.setCurrentPage(Page.Opportunity_Consulting_And_Management);        
        
        //Reinstantiate the controller 
        controller = new DetailViewRedirectController(standardController); 
        
        //The redirectTo method redirects on the vf page ie. Opportunity_Consulting_And_Management
        //system.assertEquals(true, controller.redirectTo().getUrl().contains('Opportunity_Consulting_And_Management'));
        
        //Fetch the Membership records
        List<Membership__c> membershipList = [SELECT Id, Name, RecordTypeId, RecordType.DeveloperName FROM Membership__c];
        
        //Standard Controller with Membership of record type 
        standardController = new ApexPages.StandardController(membershipList[0]);
        
        // set the current page Membership_Detail
        test.setCurrentPage(Page.Membership_Detail);
        
        //Controller Instance
        controller = new DetailViewRedirectController(standardController);
        
        //The redirectTo method redirects on the vf page ie. MembershipView
        system.assertEquals(true, controller.redirectTo().getUrl().contains(DetailViewRedirectController.MEMBERSHIP_VIEW));
    
        //stop Test Here
        Test.stopTest();
    }
}