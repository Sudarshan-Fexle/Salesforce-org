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
Private class Test_CloneWithProgramsController {
/**
 *   Purpose         :   Test class for CloneWithProgramsController
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   07/3/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150618-9014
 * 
 *   Coverage        :   V_1.0 - 100%
 **/
    
    //Test method
    static testMethod void myUnitTest() {
        
        //Bypassing all triggers
        Util.byPassAllTriggers = true;
        Util.IsTest(true);
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add new recrods in list 
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert account
        insert accounts;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new recrods in list 
        staffRoles.add(new Team_Role__c(Name = 'Test 1',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test 2',Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test 3',Active__c = true, Institution__c = true));
        insert staffRoles;
        
        //Create staff Assignment 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(recordTypes != null);
        
        //Add new records in list
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1', Institution__c = accounts[0].Id, 
                                                    Role__c = staffRoles[0].Id, Start_date__c = System.today().addDays(-3), 
                                                    RecordTypeId = recordTypes[0].Id, End_date__c = System.today().addDays(+5)));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 2', Institution__c = accounts[0].Id, 
                                                    Role__c = staffRoles[1].Id,Start_date__c = System.today().addDays(-4), 
                                                    RecordTypeId = recordTypes[0].Id, End_date__c = System.today().addDays(+5)));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 3', Institution__c = accounts[0].Id,
                                                    Role__c = staffRoles[2].Id,Start_date__c = System.today().addDays(-5), 
                                                    RecordTypeId = recordTypes[0].Id, End_date__c = System.today().addDays(+5)));
        
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
        List<Role_Program_Perspective__c> roleProgramPerspective = new List<Role_Program_Perspective__c>();
        
        //Add new records in list
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[0].Id, 
                                    Effective_Start__c = System.today().addDays(3), Effective_End__c = System.today().addDays(+3)));
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[1].Id, 
                                    Effective_Start__c = System.today(),Effective_End__c = System.today().addDays(+3)));
                                                
        //Insert 
        insert roleProgramPerspective;
   
        //Test method start here
        Test.startTest();

        //Put Parameters from URL
        Apexpages.currentPage().getParameters().Put('sourceId',staffAssignments[0].Id);
        Apexpages.currentPage().getParameters().Put('newid',staffAssignments[1].Id);
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Create instant
        CloneWithProgramsController cloneController = new CloneWithProgramsController();
        
        //List through role Program perspective
        List<Role_Program_Perspective__c> rPPList = [Select Id,Name From Role_Program_Perspective__c Where Staff_Assignment__c =: staffAssignments[1].Id ];
        
        //Assert for result
        System.assertEquals(0, rPPList.size());
        
        //List through role Program perspective
        rPPList = [Select Id,Name From Role_Program_Perspective__c Where Staff_Assignment__c =: staffAssignments[0].Id ]; 
        
        //Assert for result
        System.assertEquals(2, rPPList.size());
        
        //Call init Method
        cloneController.inIt();        
        
        //List through role Program perspective
        rPPList = [Select Id,Name From Role_Program_Perspective__c Where Staff_Assignment__c =: staffAssignments[0].Id ]; 
        
        //Assert for result
        System.assertEquals(2, rPPList.size());
        
        //List through role Program perspective
        rPPList = [Select Id,Name From Role_Program_Perspective__c Where Staff_Assignment__c =: staffAssignments[1].Id ];
        
        //Assert for result
        System.assertEquals(2, rPPList.size());
       
        //Test Method stop here 
        Test.stopTest();
    }
}