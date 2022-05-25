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
private class Test_EditClarification {
/**
 *  Purpose         :   Test class for EditClarificationController.
 * 
 *  Created By      :   Padmesh Soni
 * 
 *  Created Date    :   07/06/2015 
 *
 *  Revision Logs   :   V_1.0 - Created
 * 
**/
    //Test method of test class name myUnitTest that check some assert statement to gain coverage of test class.
    static testMethod void myUnitTest() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Account List
        List<Account> account = new List<Account>();
        
        //Add values in list of account
        account.add(new Account(Name = 'Test1'));
        account.add(new Account(Name = 'Test2'));
        account.add(new Account(Name = 'Test3'));
        
        //Insert list of accounts
        insert account;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add contacts in List
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'test@test.com', 
                                Employee_User_Record__c = UserInfo.getUserId(), AccountId = account[0].Id, Active_PSS__c = true, Title = 'Test', Phone = '614-555-8855'));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'test1@test.com', 
                                Employee_User_Record__c = UserInfo.getUserId(), AccountId = account[0].Id, Active_PSS__c = true, Title = 'Test', Phone = '614-555-8855'));
    
        //Insert contact list
        insert contacts;
          
        //Create team roles
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add values in list
        staffRoles.add(new Team_Role__c(Name = 'Testing1',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Testing2',Active__c = true, Institution__c = true));
        
        //Insert
        insert staffRoles;
        
        //Object initilization of Team membership in list
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(recordTypes != null);
        
        //Add values in list of Team membership
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5), 
                                                    Institution__c =  account[0].Id, Employee__c = UserInfo.getUserId(), 
                                                    Role__c = staffRoles[0].Id, Staff_member__c = contacts[0].Id, 
                                                    RecordTypeId = recordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 2', Start_date__c = System.today().addDays(4), 
                                                    End_date__c = System.today().addDays(5), 
                                                    Institution__c =  account[1].Id, Employee__c = UserInfo.getUserId(), 
                                                    Role__c = staffRoles[1].Id, 
                                                    Staff_member__c = contacts[0].Id, RecordTypeId = recordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 3', Start_date__c = System.today().addDays(-5), 
                                                    End_date__c = System.today().addDays(+5), 
                                                    Institution__c =  account[2].Id, Employee__c = UserInfo.getUserId(), 
                                                    Role__c = staffRoles[1].Id, RecordTypeId = recordTypes[0].Id,
                                                    Staff_member__c = contacts[1].Id));
        
        //Insert
        insert staffAssignments;
        
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
        
        //Insert Program Pespective
        insert programPerspectives;
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspectives = new List<Role_Program_Perspective__c>(); 
        
        //Add new records in list
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignments[0].Id, Program_Perspective__c = programPerspectives[0].Id, 
                                    Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3)));
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignments[0].Id, Program_Perspective__c = programPerspectives[1].Id, 
                                    Effective_Start__c = System.today().addDays(-2),Effective_End__c = System.today().addDays(3)));
        
        //Insert
        insert roleProgramPerspectives;
        
        // Apex page standard controller object initializaation
        ApexPages.StandardController sc = new ApexPages.standardController(staffAssignments[0]);
    
        //Test start from here
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //Instance of controller name EditClarificationController
        EditClarificationController controller = new EditClarificationController(sc);
        
        //Set value of option that is equal to new
        controller.sldOption = 'New';
        
        //Call Controller method
        controller.redirectUser();
        
        //Assert for result
        System.assertEquals(false, controller.isEdit);
        
        //Call controller method
        PageReference redirectPage = controller.doNew();
        
        //Assert for result
        System.assert(redirectPage.getUrl().contains('/apex/RedirectWithVariables?redirect=Object--Team_Membership__c'));
        
        //Set value of option that is equal to Edit
        controller.sldOption = 'Cancel';
        
        //Call controller method
        controller.redirectUser();
        
        //Call controller method
        controller.doNew();
        
        //Set value of option that is equal to Edit
        controller.sldOption = 'Edit';
        
        //Call controller method
        controller.redirectUser();
        
        //Assert for result
        System.assertEquals(true, controller.isEdit);
        
        //Call controller method
        controller.doNew();
        
        //Assert for result
        System.assertEquals(true, controller.isEdit);
        
        //Get option value in list
        List<SelectOption> selectOption = controller.options;
        
        //Update Staff Assignment
        staffAssignments[0].Start_date__c = System.today();
        staffAssignments[0].End_date__c = System.today().addDays(4);
        
        system.debug('redirectPage @@@@@' + redirectPage);
        
        //Call Controller method
        controller.doSave();
        
        //Query through Staff Assignment
        List<Team_Membership__c> teamMemberships = [Select Id, Start_date__c, End_date__c From Team_Membership__c Where Id =: staffAssignments[0].Id];
        
        
        System.assertEquals(1, teamMemberships.size());
        
        //Assert for result
        System.assertEquals(System.today(), teamMemberships[0].Start_date__c);
        System.assertEquals(System.today().addDays(4), teamMemberships[0].End_date__c);
        
        //Pass Parameters in URL
        Apexpages.currentPage().getParameters().put('sourceId', staffAssignments[0].Id +'-' + 'false');
        Apexpages.currentPage().getParameters().put('newId', staffAssignments[1].Id);
        
        //Instance of controller for UpdateSourceStaffAssignmentController
        UpdateSourceStaffAssignmentController controllerUpdate = new UpdateSourceStaffAssignmentController();
        
        //Redirect method of UpdateSourceStaffAssignmentController called
        controllerUpdate.redirect();
        
        //Query through Staff Assignment
        teamMemberships = [Select Id, Start_date__c, End_date__c From Team_Membership__c Where Id =: staffAssignments[0].Id];
        
        //Assert for result
        System.assertEquals(System.today().addDays(3), teamMemberships[0].End_date__c);
        
        //
        //Pass Parameters in URL
        Apexpages.currentPage().getParameters().put('sourceId', staffAssignments[0].Id +'-' + 'true');
        Apexpages.currentPage().getParameters().put('newId', staffAssignments[1].Id);
        
        //Instance of controller for UpdateSourceStaffAssignmentController
        UpdateSourceStaffAssignmentController controllerUpdate1 = new UpdateSourceStaffAssignmentController();
        
        //Redirect method of UpdateSourceStaffAssignmentController called
        controllerUpdate1.redirect();
        
        //Query through Role Program Perspetive
        List<Role_Program_Perspective__c> rPPList = [select Id,Effective_Start__c, Effective_End__c From Role_Program_Perspective__c Where Staff_Assignment__c =: staffAssignments[1].Id];
        
        //Assert for result
        System.assertEquals(2, rPPList.size());

  
        //Test end here
        Test.stopTest();
    }
}