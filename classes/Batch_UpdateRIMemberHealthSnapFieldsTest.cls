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
@isTest(seeAllData=false)
private class Batch_UpdateRIMemberHealthSnapFieldsTest {
/**
    Purpose     :   Test class for Batch_UpdateRIMemberHealthSnapshotFields.
                
    Create By   :   Abhinav Sharma
    
    Created Date:   2/24/2016
   
    Revision Log:   V1.0 - Created
                    V1.1 - Modified By - Abhinav Sharma - CR-20161031-10294 - 11/21/2016 - Process only updated records
		    V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code to by pass the auto population of following fields on Membership record.
		                                                                             Fields are as follows:-
										             "Average_QA_Grade__c", "Average_QA_Recommend__c", "Days_Since_Last_Teleconference_Date__c",
										             "Days_Since_Last_Recognized_ROI__c", "Next_Executive_Sponsor_Update__c", "Logins_Last_Month__c"
										             "Executive_Sponsor_Current_Through__c", "Users_Last_Month__c", "Next_Teleconference_Date__c",
										             "Last_Executive_Sponsor_Update__c".
		    
		   V1.3 - Modified By - Mahendra Swarnkar - CR-20211012-15511 increase test coverage	 
                    
    Coverage    :   V1.0 - Batch_UpdateRIMemberHealthSnapshotFields - 91%
					V1.1 - Batch_UpdateRIMemberHealthSnapshotFields - 93%

**/
    
    //V1.2 - Added By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017
    //test method
    static testMethod void unitTest1() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
        
        //Program
        Program__c swProgram1 = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram1;
        System.assertNotEquals(null,swProgram1.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Contract ABC
        Contract__c testContract = new Contract__c(
        Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
        Negotiated_Amount__c = 1,
        Type__c = 'NBB',
        Year__c = '2010',
        Join_Date__c = system.today().addDays(-5),
        Payer_Account__c = testAcct.Id,
        Main_Contact__c = testContact.Id,
        Invoice_Contact__c = testContact.Id,
        Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                            Project_Phase__c = '3 - Test',
                                            Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram1.Id;
    
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertEquals('Member - Integrated', testMembership.Membership_Status__c);
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
        
        //List of projects
        List<Project__c> projects = new List<Project__c>();
        
        //Create Project records
        Project__c project_1 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '1 - Test', Product__c = swProgram.Id);
        Project__c project_2 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '2 - Test', Product__c = swProgram.Id);
        projects.add(project_1);
        projects.add(project_2);
        insert projects;
        
        //List of project role
        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        
        //Create project role
        Project_Role__c pRole_1 = new Project_Role__c(Name = 'pRole', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = projects[0].Id, Contact__c = testContact.Id);
        Project_Role__c pRole_2 = new Project_Role__c(Name = 'pRole1', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = projects[1].Id, Contact__c = testContact.Id);
        Project_Role__c pRole_3 = new Project_Role__c(Name = 'pRole3', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = project.Id, Contact__c = testContact.Id);
		projectRoles.add(pRole_1);
		projectRoles.add(pRole_2);
        projectRoles.add(pRole_3);
		insert projectRoles;    
        
        //Diabling the triggers
        Util.byPassAllTriggers = false;
        
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Executive_Sponsor__c, Membership_Status__c FROM Membership__c];
		
		//Assert for the results
		System.assert(memberships != null);
		System.assertEquals(1, memberships.size());
        System.assertEquals('Member - Integrated', memberships[0].Membership_Status__c);
        //System.assertEquals(testContact.Id, memberships[0].Executive_Sponsor__c);
    }
    
    //Added By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017
    //Modified By - Mahendra Swarnkar - CR-20211012-15511 increase test coverage
    //test method
    static testMethod void unitTest2() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
        
        //Program
        Program__c swProgram1 = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram1;
        System.assertNotEquals(null,swProgram1.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Contract ABC
        Contract__c testContract = new Contract__c(
        Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
        Negotiated_Amount__c = 1,
        Type__c = 'NBB',
        Year__c = '2010',
        Join_Date__c = system.today().addDays(-5),
        Payer_Account__c = testAcct.Id,
        Main_Contact__c = testContact.Id,
        Invoice_Contact__c = testContact.Id,
        Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram1.Id;
        testMembership.Executive_Sponsor__c = testContact.Id;
    
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertEquals('Member - Integrated', testMembership.Membership_Status__c);
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
        
        testMembership.Membership_Status_Text__c = System.Label.ELIGIBLE_MEMBERSHIP_STATUS;
        update testMembership;
        
        //List of projects
        List<Project__c> projects = new List<Project__c>();
        
        //Create Project records
        Project__c project_1 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '1 - Test', Product__c = swProgram.Id);
        Project__c project_2 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '2 - Test', Product__c = swProgram.Id);
        projects.add(project_1);
        projects.add(project_2);
        insert projects;
        
        //Diabling the triggers
        Util.byPassAllTriggers = false;
        
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Executive_Sponsor__c, Membership_Status__c FROM Membership__c];
		
		//Assert for the results
		System.assert(memberships != null);
		System.assertEquals(1, memberships.size());
        System.assertEquals(System.Label.ELIGIBLE_MEMBERSHIP_STATUS, memberships[0].Membership_Status__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor__c);
    }
    
    //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code Starts from here
/**	
    //test method
    static testMethod void unitTest1() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Contract ABC
        Contract__c testContract = new Contract__c(
        Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
        Negotiated_Amount__c = 1,
        Type__c = 'NBB',
        Year__c = '2010',
        Join_Date__c = system.today().addDays(-5),
        Payer_Account__c = testAcct.Id,
        Main_Contact__c = testContact.Id,
        Invoice_Contact__c = testContact.Id,
        Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram.Id;
    
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertEquals('Member - Payer', testMembership.Membership_Status__c);
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
        
        //List of projects
        List<Project__c> projects = new List<Project__c>();
        
        //Create Project records
        Project__c project_1 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '1 - Test', Product__c = swProgram.Id);
        Project__c project_2 = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Primary_Paid_Membership__c = testMembership.Id, 
                                              Project_Phase__c = '2 - Test', Product__c = swProgram.Id);
        projects.add(project_1);
        projects.add(project_2);
        insert projects;
        
        //Teleconference utilizations
        List<Utilization_Data_Object__c> utilizationsToInsert = new List<Utilization_Data_Object__c>();
        
        //Create Teleconference utilization record
        Utilization_Data_Object__c otherUtilization1 = new Utilization_Data_Object__c();
        otherUtilization1.Membership__c = testMembership.Id;
        otherUtilization1.Event_Name__c = 'Test';
        otherUtilization1.ParticipationCount__c = 10;
        otherUtilization1.Contact__c = testContact.Id;
        otherUtilization1.Institution__c = testAcct.Id;
        otherUtilization1.Start_Date__c = system.today().addDays(-6);
        otherUtilization1.End_Date__c = system.today().addDays(-3);
        otherUtilization1.Utilization_Metric__c = 'Teleconferences';
        otherUtilization1.Program__c = 'TEST';
        utilizationsToInsert.add(otherUtilization1);
        
        Utilization_Data_Object__c otherUtilization2 = new Utilization_Data_Object__c();
        otherUtilization2.Membership__c = testMembership.Id;
        otherUtilization2.Event_Name__c = 'Test';
        otherUtilization2.Contact__c = testContact.Id;
        otherUtilization2.Institution__c = testAcct.Id;
        otherUtilization2.Start_Date__c = system.today().addDays(-9);
        otherUtilization2.End_Date__c = system.today().addDays(-6);
        otherUtilization2.Utilization_Metric__c = 'Teleconferences';
        otherUtilization2.Program__c = 'TEST';
        utilizationsToInsert.add(otherUtilization2);
        
        Utilization_Data_Object__c otherUtilization3 = new Utilization_Data_Object__c();
        otherUtilization3.Membership__c = testMembership.Id;
        otherUtilization3.ParticipationCount__c = 10;
        otherUtilization3.Event_Name__c = 'Test';
        otherUtilization3.Contact__c = testContact.Id;
        otherUtilization3.Institution__c = testAcct.Id;
        otherUtilization3.Start_Date__c = system.today();
        otherUtilization3.End_Date__c = system.today().addDays(6);
        otherUtilization3.Utilization_Metric__c = 'Teleconferences';
        otherUtilization3.Program__c = 'TEST';
        utilizationsToInsert.add(otherUtilization3);
        
        Utilization_Data_Object__c otherUtilization4 = new Utilization_Data_Object__c();
        otherUtilization4.Membership__c = testMembership.Id;
        otherUtilization4.Event_Name__c = 'Test';
        otherUtilization4.Contact__c = testContact.Id;
        otherUtilization4.Institution__c = testAcct.Id;
        otherUtilization4.Start_Date__c = system.today();
        otherUtilization4.End_Date__c = system.today().addDays(3);
        otherUtilization4.Utilization_Metric__c = 'Teleconferences';
        otherUtilization4.Program__c = 'TEST';
        utilizationsToInsert.add(otherUtilization4);
        insert utilizationsToInsert;
        
        //Member interactions list
        List<Call__c> memberinteractions = new List<Call__c>();
        
        //Creating member interaction records
        Call__c memberInteraction_1 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(-2), 
                                                  Current_Status__c = 'Completed',
                                                  Interaction_Type__c = 'Web Conference',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[0].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        Call__c memberInteraction_2 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(4), 
                                                  Current_Status__c = 'Requested',
                                                  Interaction_Type__c = 'Web Conference',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[1].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        Call__c memberInteraction_3 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(1), 
                                                  Current_Status__c = 'Scheduled',
                                                  Interaction_Type__c = 'Test',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[1].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        Call__c memberInteraction_4 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(-2), 
                                                  Current_Status__c = 'Completed',
                                                  Interaction_Type__c = 'Web Conference',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[0].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        Call__c memberInteraction_5 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(4), 
                                                  Current_Status__c = 'Requested',
                                                  Interaction_Type__c = 'Web Conference',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[1].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        Call__c memberInteraction_6 = new Call__c(Call_Brief_Notes__c = 'test description', 
                                                  Call_Date__c = Date.today().addDays(1), 
                                                  Current_Status__c = 'Scheduled',
                                                  Interaction_Type__c = 'Test',
                                                  Call_Type__c = 'Kickoff', Member__c = projects[1].Id,
                                                  Senior_Member_On_Call__c = testContact.Id,
                                                  Sponsor_Update__c = true);
        memberinteractions.add(memberInteraction_1);
        memberinteractions.add(memberInteraction_2);
        memberinteractions.add(memberInteraction_3);
        memberinteractions.add(memberInteraction_4);
        memberinteractions.add(memberInteraction_5);
        memberinteractions.add(memberInteraction_6);
        insert memberinteractions;
        
        //List of Opportunity and ROIs
        List<Opportunity_and_ROI__c> opportunityAndROIs = new List<Opportunity_and_ROI__c>();
        
        //Create opportunity and ROIs records
      	Opportunity_and_ROI__c oAR_1 = new Opportunity_and_ROI__c();
        oAR_1.ROI_Member_Sign_Off_Date__c = System.today().addDays(-16);
        oAR_1.Project__c = projects[0].Id;
        oAR_1.Value_Opportunity_Sign_Off_Contact__c = testContact.Id;
        oAR_1.ROI_Dollar_Amount__c = 500;
        oAR_1.Value_Opportunity_ROI_Type__c = Batch_UpdateRIMemberHealthFieldsConstant.OPPORTUNITY_IDENTIFIED_STATUS;
        
        Opportunity_and_ROI__c oAR_2 = new Opportunity_and_ROI__c();
        oAR_2.ROI_Member_Sign_Off_Date__c = System.today().addDays(-12);
        oAR_2.Project__c = projects[1].Id;
        oAR_2.Value_Opportunity_Sign_Off_Contact__c = testContact.Id;
        oAR_2.ROI_Dollar_Amount__c = 500;
        oAR_2.Value_Opportunity_ROI_Type__c = Batch_UpdateRIMemberHealthFieldsConstant.OPPORTUNITY_IDENTIFIED_STATUS;
        
        Opportunity_and_ROI__c oAR_3 = new Opportunity_and_ROI__c();
        oAR_3.ROI_Member_Sign_Off_Date__c = System.today().addDays(-8);
        oAR_3.Project__c = projects[1].Id;
        oAR_3.Value_Opportunity_Sign_Off_Contact__c = testContact.Id;
        oAR_3.ROI_Dollar_Amount__c = 500;
        oAR_3.Value_Opportunity_ROI_Type__c = Batch_UpdateRIMemberHealthFieldsConstant.OPPORTUNITY_IDENTIFIED_STATUS;
        
        Opportunity_and_ROI__c oAR_4 = new Opportunity_and_ROI__c();
        oAR_4.ROI_Member_Sign_Off_Date__c = System.today().addDays(-10);
        oAR_4.Project__c = projects[0].Id;
        oAR_4.Value_Opportunity_Sign_Off_Contact__c = testContact.Id;
        oAR_4.ROI_Dollar_Amount__c = 500;
        oAR_4.Value_Opportunity_ROI_Type__c = Batch_UpdateRIMemberHealthFieldsConstant.OPPORTUNITY_IDENTIFIED_STATUS;
        opportunityAndROIs.add(oAR_1);
        opportunityAndROIs.add(oAR_2);
        opportunityAndROIs.add(oAR_3);
        opportunityAndROIs.add(oAR_4);
        insert opportunityAndROIs;
        
        //List of project role
        List<Project_Role__c> projectRoles = new List<Project_Role__c>();
        
        //Create project role
        Project_Role__c pRole_1 = new Project_Role__c(Name = 'pRole', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = projects[0].Id, Contact__c = testContact.Id);
        Project_Role__c pRole_2 = new Project_Role__c(Name = 'pRole1', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = projects[1].Id, Contact__c = testContact.Id);
        Project_Role__c pRole_3 = new Project_Role__c(Name = 'pRole3', Project_Type__c = 'CCC', 
                                                    Role__c = Batch_UpdateRIMemberHealthFieldsConstant.EXECUTIVE_SPONSOR, 
                                                    Project__c = project.Id, Contact__c = testContact.Id);
		projectRoles.add(pRole_1);
		projectRoles.add(pRole_2);
        projectRoles.add(pRole_3);
		insert projectRoles;    
        
        //Querying Details for "PT QA Call" record type on Event Object
        List<RecordType> eventRdTypes = [SELECT ID FROM RecordType Where sObjectType = 'Event' AND IsActive = true 
                                   			AND Name =: DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL];
		//Assert for the results
        System.assert(eventRdTypes != null);
        
        //Record Type Setting list
        list<RecordType_Setting__c> listRTSettings = new list<RecordType_Setting__c>();

        //Record Type Setting instance
        RecordType_Setting__c rs = new RecordType_Setting__c(Name = 'Test1', 
                                                             Name__c = DisplayFieldsOnStdPageLayoutConstants.EVENT_RECORD_TYPE_PT_QA_CALL, 
                                                             SFID__c = eventRdTypes[0].Id, SObjectType__c = 'Event');
		listRTSettings.add(rs);
        insert listRTSettings;
        
        //Activities
        List<Event> events = new List<Event>();
        
        //Insert events associated with the membership record
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today().addDays(-5), EndDateTime = system.today().adddays(-5), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '9', Grade__c = 'A',
                             WhatId = testMembership.ID,
                             Cancelled_Did_Not_Occur__c = false));
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today().addDays(-50), EndDateTime = system.today().adddays(-50), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '10', Grade__c = 'A+',
                             WhatId = testMembership.ID,
                             Cancelled_Did_Not_Occur__c = false));
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today().addDays(-400), EndDateTime = system.today().adddays(-400), 
                             Would_Refer__c = '10', Would_Buy_Again__c = '10', Grade__c = 'A+',
                             WhatId = testMembership.ID,
                             Cancelled_Did_Not_Occur__c = false));
        events.add(new Event(RecordTypeId = eventRdTypes[0].Id, OwnerId = Userinfo.getUserId(), 
                             StartDateTime = system.today(), EndDateTime = system.today().adddays(5), 
                             Would_Refer__c = '9', Would_Buy_Again__c = '9', Grade__c = 'A',
                             WhatId = testMembership.ID,
                             Cancelled_Did_Not_Occur__c = false));
        insert events;
        
        //Today's Date
        Date todaysDate = System.today();
        
        //previous month num value
        Integer previousMonthNumValue = System.today().addMonths(-1).month();
        
        //Today's Date year
        String todaysDateYearString = String.valueOf(System.today().Year());
        
        //Last year string
        String lastYearString = String.valueOf(System.today().Year()-1);
        
        Map<Integer, String> mapofMonths = new Map<Integer, String>();
        mapofMonths.put(1, 'January');
        mapofMonths.put(2, 'February');
        mapofMonths.put(3, 'March');
        mapofMonths.put(4, 'April');
        mapofMonths.put(5, 'May');
        mapofMonths.put(6, 'June');
        mapofMonths.put(7, 'July');
        mapofMonths.put(8, 'August');
        mapofMonths.put(9, 'September');
        mapofMonths.put(10, 'October');
        mapofMonths.put(11, 'November');
        mapofMonths.put(12, 'December');
        
        //List of PTD Utilization
        List<Utilization__c> pTDUtilizations = new List<Utilization__c>();
        
        //Checking for value in map
        if(mapofMonths.containsKey(previousMonthNumValue) && mapofMonths.get(previousMonthNumValue) != null) {
            
            //Create PTD Utilization
            Utilization__c ptDUtil_1 = new Utilization__c(Total_Logins__c = 10, Distinct_Users__c = 5,
                                                           Project__c = projects[0].Id,
                                                           Month__c = mapofMonths.get(previousMonthNumValue),
                                                           Year__c = todaysDateYearString,
                                                           Date__c = System.today()); 
            
            Utilization__c ptDUtil_2 = new Utilization__c(Total_Logins__c = 25, Distinct_Users__c = 7,
                                                           Project__c = projects[0].Id,
                                                           Month__c = mapofMonths.get(previousMonthNumValue),
                                                           Year__c = todaysDateYearString,
                                                           Date__c = System.today()); 
            
            Utilization__c ptDUtil_3 = new Utilization__c(Total_Logins__c = 10, Distinct_Users__c = 5,
                                                           Project__c = projects[1].Id,
                                                           Month__c = mapofMonths.get(previousMonthNumValue),
                                                           Year__c = lastYearString,
                                                           Date__c = System.today()); 
            
            Utilization__c ptDUtil_4 = new Utilization__c(Total_Logins__c = 10, Distinct_Users__c = 5,
                                                           Project__c = projects[1].Id,
                                                           Month__c = mapofMonths.get(previousMonthNumValue),
                                                           Year__c = todaysDateYearString,
                                                           Date__c = System.today()); 
            
            Utilization__c ptDUtil_5 = new Utilization__c(Total_Logins__c = 15, Distinct_Users__c = 6,
                                                           Project__c = projects[1].Id,
                                                           Month__c = mapofMonths.get(previousMonthNumValue),
                                                           Year__c = todaysDateYearString,
                                                           Date__c = System.today()); 
            pTDUtilizations.add(ptDUtil_1);
            pTDUtilizations.add(ptDUtil_2);
            pTDUtilizations.add(ptDUtil_3);
            pTDUtilizations.add(ptDUtil_4);
            pTDUtilizations.add(ptDUtil_5);
            insert pTDUtilizations;
        }
        
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Days_Since_Last_Teleconference_Date__c, Next_Teleconference_Date__c,
                       Days_Since_Last_Recognized_ROI__c, Last_Executive_Sponsor_Update__c,
                       Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,
                       Executive_Sponsor__c, Executive_Sponsor_Current_Through__c,
                       Logins_Last_Month__c, Users_Last_Month__c, Membership_Status__c
                       FROM Membership__c];
		
		//Assert for the results
		System.assert(memberships != null);
		System.assertEquals(1, memberships.size());
        System.assertEquals('Member - Payer', memberships[0].Membership_Status__c);
        System.assertEquals(2, memberships[0].Days_Since_Last_Teleconference_Date__c);
        System.assertEquals(System.today().addDays(3), memberships[0].Next_Teleconference_Date__c);
        System.assertEquals(8, memberships[0].Days_Since_Last_Recognized_ROI__c);
        System.assertEquals(System.today().addDays(-2), memberships[0].Last_Executive_Sponsor_Update__c);
        System.assertEquals(System.today().addDays(1), memberships[0].Next_Executive_Sponsor_Update__c);
        System.assertEquals(4, memberships[0].Average_QA_Grade__c);
        System.assertEquals(9, memberships[0].Average_QA_Recommend__c);
        System.assertEquals(testContact.Id, memberships[0].Executive_Sponsor__c);
        System.assert(memberships[0].Executive_Sponsor_Current_Through__c != null);
        System.assertEquals(60, memberships[0].Logins_Last_Month__c);
        System.assertEquals(23, memberships[0].Users_Last_Month__c);
    }   
    
    //test method
    static testMethod void unitTest2() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Contract ABC
        Contract__c testContract = new Contract__c(
        Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
        Negotiated_Amount__c = 1,
        Type__c = 'NBB',
        Year__c = '2010',
        Join_Date__c = system.today().addDays(-5),
        Payer_Account__c = testAcct.Id,
        Main_Contact__c = testContact.Id,
        Invoice_Contact__c = testContact.Id,
        Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram.Id;
        testMembership.Days_Since_Last_Teleconference_Date__c = -6;
        testMembership.Next_Teleconference_Date__c = System.today().addDays(-6);
        testMembership.Days_Since_Last_Recognized_ROI__c = 8;
        testMembership.Last_Executive_Sponsor_Update__c = System.today().addDays(-2);
        testMembership.Next_Executive_Sponsor_Update__c = System.today().addDays(1);
        testMembership.Average_QA_Grade__c = 4;
        testMembership.Average_QA_Recommend__c = 9;
        testMembership.Executive_Sponsor__c = testContact.Id;
        testMembership.Executive_Sponsor_Current_Through__c = System.now();
        testMembership.Logins_Last_Month__c = 60;
        testMembership.Users_Last_Month__c = 23;
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertEquals('Member - Payer', testMembership.Membership_Status__c);
        
        //Updating membership in order to update it's status
        testMembership.Active_Contract_Idenfied__c = null;
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertNotEquals('Member - Payer', testMembership.Membership_Status__c);
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
    	
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Days_Since_Last_Teleconference_Date__c, Next_Teleconference_Date__c,
                       Days_Since_Last_Recognized_ROI__c, Last_Executive_Sponsor_Update__c,
                       Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,
                       Executive_Sponsor__c, Executive_Sponsor_Current_Through__c,
                       Logins_Last_Month__c, Users_Last_Month__c, Membership_Status__c
                       FROM Membership__c];
		
		//Assert for the results
		System.assert(memberships != null);
		System.assertEquals(1, memberships.size());
        System.assertNotEquals('Member - Payer', memberships[0].Membership_Status__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Teleconference_Date__c);
        System.assertEquals(null, memberships[0].Next_Teleconference_Date__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Recognized_ROI__c);
        System.assertEquals(null, memberships[0].Last_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Next_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Average_QA_Grade__c);
        System.assertEquals(null, memberships[0].Average_QA_Recommend__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor_Current_Through__c);
        System.assertEquals(null, memberships[0].Logins_Last_Month__c);
        System.assertEquals(null, memberships[0].Users_Last_Month__c);
    }    
    */
    //V1.2 - Modified By - Mahendra Swarnkar - CR-20170221-10705 - 4/27/2017 - Commented out the code Ends here
    
    //Added By - Abhinav Sharma - CR-20161031-10294 - 11/21/2016 - Process only updated records
    ////Modified by Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
    static testMethod void unitTest3() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = null;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram.Id;
        testMembership.Days_Since_Last_Teleconference_Date__c = null;
        //testMembership.Next_Teleconference_Date__c = System.today().addDays(-6);
        testMembership.Days_Since_Last_Recognized_ROI__c = null;
        //testMembership.Last_Executive_Sponsor_Update__c = null;
        testMembership.Next_Executive_Sponsor_Update__c = null;
        testMembership.Average_QA_Grade__c = null;
        testMembership.Average_QA_Recommend__c = null;
        testMembership.Executive_Sponsor__c = testContact.Id;
        //testMembership.Executive_Sponsor_Current_Through__c = null;
        testMembership.Logins_Last_Month__c = null;
        testMembership.Users_Last_Month__c = null;
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertNotEquals('Member - Payer', testMembership.Membership_Status__c);
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
    	
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Days_Since_Last_Teleconference_Date__c, /*Next_Teleconference_Date__c,*/
                       Days_Since_Last_Recognized_ROI__c, /*Last_Executive_Sponsor_Update__c,*/
                       Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,
                       Executive_Sponsor__c, /*Executive_Sponsor_Current_Through__c,*/
                       Logins_Last_Month__c, Users_Last_Month__c, Membership_Status__c
                       FROM Membership__c];
        
        //Assert for the results
        System.assert(memberships != null);
        System.assertEquals(1, memberships.size());
        System.assertNotEquals('Member - Payer', memberships[0].Membership_Status__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Teleconference_Date__c);
       // System.assertEquals(System.today().addDays(-6), memberships[0].Next_Teleconference_Date__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Recognized_ROI__c);
        //System.assertEquals(null, memberships[0].Last_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Next_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Average_QA_Grade__c);
        System.assertEquals(null, memberships[0].Average_QA_Recommend__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor__c);
       // System.assertEquals(null, memberships[0].Executive_Sponsor_Current_Through__c);
        System.assertEquals(null, memberships[0].Logins_Last_Month__c);
        System.assertEquals(null, memberships[0].Users_Last_Month__c);
    }    
    
    //Added By - Abhinav Sharma - CR-20161031-10294 - 11/21/2016 - Process only updated records
    static testMethod void unitTest4() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = null;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram.Id;
        testMembership.Days_Since_Last_Teleconference_Date__c = null;
        //testMembership.Next_Teleconference_Date__c = null;
        testMembership.Days_Since_Last_Recognized_ROI__c = null;
        //testMembership.Last_Executive_Sponsor_Update__c = null;
        testMembership.Next_Executive_Sponsor_Update__c = null;
        testMembership.Average_QA_Grade__c = null;
        testMembership.Average_QA_Recommend__c = null;
        testMembership.Executive_Sponsor__c = null;
        //testMembership.Executive_Sponsor_Current_Through__c = null;
        testMembership.Logins_Last_Month__c = null;
        testMembership.Users_Last_Month__c = null;
        
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c, Days_Since_Last_Teleconference_Date__c,
                          /*Next_Teleconference_Date__c,*/ Days_Since_Last_Recognized_ROI__c,
                          /*Last_Executive_Sponsor_Update__c,*/ Next_Executive_Sponsor_Update__c,
                          Average_QA_Grade__c, Average_QA_Recommend__c, Executive_Sponsor__c/*,
                          Executive_Sponsor_Current_Through__c*/, Logins_Last_Month__c, Users_Last_Month__c
                          FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertNotEquals('Member - Payer', testMembership.Membership_Status__c);
        System.assertEquals(null, testMembership.Days_Since_Last_Teleconference_Date__c);
        //System.assertEquals(null, testMembership.Next_Teleconference_Date__c);
        System.assertEquals(null, testMembership.Days_Since_Last_Recognized_ROI__c);
        //System.assertEquals(null, testMembership.Last_Executive_Sponsor_Update__c);
        System.assertEquals(null, testMembership.Next_Executive_Sponsor_Update__c);
        System.assertEquals(null, testMembership.Average_QA_Grade__c);
        System.assertEquals(null, testMembership.Average_QA_Recommend__c);
        System.assertEquals(null, testMembership.Executive_Sponsor__c);
        //System.assertEquals(null, testMembership.Executive_Sponsor_Current_Through__c);
        System.assertEquals(null, testMembership.Logins_Last_Month__c);
        System.assertEquals(null, testMembership.Users_Last_Month__c);
        
        //Number of script statements used so far (before batch execution)
        Integer noOfDMLStatementsBeforeBatchExec = Limits.getDmlStatements();
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
    	
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Querying for the results
        memberships = [SELECT Id, Days_Since_Last_Teleconference_Date__c, /*Next_Teleconference_Date__c,*/
                       Days_Since_Last_Recognized_ROI__c,/* Last_Executive_Sponsor_Update__c,*/
                       Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,
                       Executive_Sponsor__c, /*Executive_Sponsor_Current_Through__c,*/
                       Logins_Last_Month__c, Users_Last_Month__c, Membership_Status__c
                       FROM Membership__c];
		
		//Assert for the results
		System.assert(memberships != null);
		System.assertEquals(1, memberships.size());
        System.assertNotEquals('Member - Payer', memberships[0].Membership_Status__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Teleconference_Date__c);
        //System.assertEquals(null, memberships[0].Next_Teleconference_Date__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Recognized_ROI__c);
       // System.assertEquals(null, memberships[0].Last_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Next_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Average_QA_Grade__c);
        System.assertEquals(null, memberships[0].Average_QA_Recommend__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor__c);
        //System.assertEquals(null, memberships[0].Executive_Sponsor_Current_Through__c);
        System.assertEquals(null, memberships[0].Logins_Last_Month__c);
        System.assertEquals(null, memberships[0].Users_Last_Month__c);
        
        //Number of script statements used so far (before batch execution)
        Integer noOfDMLStatementsAfterBatchExec = Limits.getDmlStatements();
        
        //Asserting for the results
        System.assertEquals(noOfDMLStatementsAfterBatchExec, noOfDMLStatementsBeforeBatchExec);
    }    
    
    //Added By - Abhinav Sharma - CR-20161031-10294 - 11/21/2016 - Process only updated records
    ////Modified by Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
    static testMethod void unitTest5() {
    
        //Bypassing dupeblocker
        Util.IsTest(true);
            
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
    
        //Contact	
        Contact testContact = TestUtilities.CreateNewContact(true);
        testContact.Contact_Status__c = 'Active';
        update testContact;
    	
        //Program
        Program__c swProgram = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram;
        System.assertNotEquals(null,swProgram.id);
        
        //Program
        Program__c swProgram1 = new Program__c(
        Program_Acronym__c = 'TEST',
        Program_Formal_Name__c = 'Test Program Formal',
        Name = 'Test Program',
        Create_Memberships__c = 'No',
        Renewal_Unit_Count__c = 1,
        Business_Line__c = 'SW');         
        insert swProgram1;
        System.assertNotEquals(null,swProgram1.id);
    
        //Institution
        Account testAcct = TestUtilities.CreateNewAccount(false); 
        //testAcct.Active_SW_Memberships__c = '';
        insert testAcct;
        //System.assertNotEquals(null,testAcct.id);
    
        //Contract ABC
        Contract__c testContract = new Contract__c(
        Name='TestContract', Status__c = 'PAYER', Start__c = system.today().addDays(-1), End__c = system.today().addDays(2),
        Negotiated_Amount__c = 1,
        Type__c = 'NBB',
        Year__c = '2010',
        Join_Date__c = system.today().addDays(-5),
        Payer_Account__c = testAcct.Id,
        Main_Contact__c = testContact.Id,
        Invoice_Contact__c = testContact.Id,
        Program__c = swProgram.Id);
        insert testContract;
        System.assertNotEquals(null,testContract.id);
        
        //Primary Project
        Project__c project = new Project__c(Name = 'Test', Institution__c = testAcct.Id, 
                                              Project_Phase__c = '3 - Test',
                                           Product__c = swProgram.Id);
        insert project;
    
        //Membership
        Membership__c testMembership = TestUtilities.CreateNewMembership(testAcct.Id,swProgram.Id,true);
        testMembership.Active_Contract_Idenfied__c = testContract.Id;
        testMembership.Primary_Project__c = project.Id;
        testMembership.Program__c = swProgram1.Id;
    
        //Enabling triggers again
        Util.byPassAllTriggers = false;
    
        //update record
        update testMembership;
        
        //Querying for the membership details and asserting for the results
        testMembership = [SELECT ID, Membership_Status__c FROM Membership__c];
        
        //Assert for the results
        System.assert(testMembership != null);
        System.assertEquals('Member - Integrated', testMembership.Membership_Status__c);
        
        //Number of script statements used so far (before batch execution)
        Integer noOfDMLStatementsBeforeBatchExec = Limits.getDmlStatements();
        
        //Diabling the triggers
        Util.byPassAllTriggers = true;
        
        //Start test from here
        Test.startTest();
        
        //Execute the batch job
        Batch_UpdateRIMemberHealthSnapshotFields batch = new Batch_UpdateRIMemberHealthSnapshotFields();
        database.executeBatch(batch, 50);
        
        //Stop Test here
        Test.stopTest();
        
        //List of memberships
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Modified by Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
        //Querying for the results
        memberships = [SELECT Id, Days_Since_Last_Teleconference_Date__c, /*Next_Teleconference_Date__c,*/
                       Days_Since_Last_Recognized_ROI__c, /*Last_Executive_Sponsor_Update__c,*/
                       Next_Executive_Sponsor_Update__c, Average_QA_Grade__c, Average_QA_Recommend__c,
                       Executive_Sponsor__c, /*Executive_Sponsor_Current_Through__c,*/
                       Logins_Last_Month__c, Users_Last_Month__c, Membership_Status__c
                       FROM Membership__c];
        
        //Assert for the results
        System.assert(memberships != null);
        System.assertEquals(1, memberships.size());
        System.assertEquals('Member - Integrated', memberships[0].Membership_Status__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Teleconference_Date__c);
        //System.assertEquals(null, memberships[0].Next_Teleconference_Date__c);
        System.assertEquals(null, memberships[0].Days_Since_Last_Recognized_ROI__c);
        //Modified by Subhash Gharwal -04-29-2019 - Spring cleanup - CR-20190425-13035  
        //System.assertEquals(null, memberships[0].Last_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Next_Executive_Sponsor_Update__c);
        System.assertEquals(null, memberships[0].Average_QA_Grade__c);
        System.assertEquals(null, memberships[0].Average_QA_Recommend__c);
        System.assertEquals(null, memberships[0].Executive_Sponsor__c);
        //System.assertEquals(null, memberships[0].Executive_Sponsor_Current_Through__c);
        System.assertEquals(null, memberships[0].Logins_Last_Month__c);
        System.assertEquals(null, memberships[0].Users_Last_Month__c);
        
        //Number of script statements used so far (before batch execution)
        Integer noOfDMLStatementsAfterBatchExec = Limits.getDmlStatements();
        
        //Asserting for the results
        System.assertEquals(noOfDMLStatementsAfterBatchExec, noOfDMLStatementsBeforeBatchExec);
    }
}