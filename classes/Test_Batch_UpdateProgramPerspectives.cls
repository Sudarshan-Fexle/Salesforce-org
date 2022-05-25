/*
Purpose         :   Test class for Batch_UpdateProgramPerspectives

Create By       :   Abhinav Sharma

Created Date    :   08/26/2020

Current Version :   V1.0

Revision Log    :   V1.0 - Created - By Abhinav Sharma - CR-20200806-14405 - 08/26/2020 - Test the Batch_UpdateProgramPerspectives functionality

Coverage        :   
*/
@isTest(seeAllData=false)
private class Test_Batch_UpdateProgramPerspectives {
    
    @testSetup static void dataSetup() 
    {
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Create Accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2'));
        insert accounts;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[1].Id));
        insert contacts;
        
        //Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        programCollections.add(new Program_Group__c(Name = 'PC 1', Short_Name__c = 'short name 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2', Short_Name__c = 'short name 2'));
        programCollections.add(new Program_Group__c(Name = 'PC 3', Short_Name__c = 'short name 3'));
        insert programCollections;
        
        //Create Team Role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        staffRoles.add(new Team_Role__c(Name = 'Test8', Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test5', Active__c = true, Institution__c = true));
        insert staffRoles;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        perspectives.add(new Perspective__c(Name = 'perspective 1'));
        perspectives.add(new Perspective__c(Name = 'perspective 2'));
        insert perspectives;
        
        //Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 3' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[2].Id));
        insert programPerspectives;
        
         //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                            AND IsActive = true 
                                            AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Create staff Assignment 
        List<Team_Membership__c> staffAssignment = new List<Team_Membership__c>();               
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 1', Institution__c = accounts[0].Id , 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(+5),
                                                   RecordTypeId = tmRecordTypes[0].Id, Program_Perspectives__c = 'PP Test'));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 2', Institution__c = accounts[1].Id, 
                                                   Start_date__c = System.today().addDays(-3), 
                                                   End_date__c = System.today().addDays(+5),
                                                   RecordTypeId = tmRecordTypes[0].Id, Program_Perspectives__c = 'PP Test'));
        insert staffAssignment;
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspective = new List<Role_Program_Perspective__c>();
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[0].Id,
                                                                   Effective_Start__c = System.today().addDays(5)));
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[0].Id, Program_Perspective__c = programPerspectives[1].Id,
                                                                   Effective_Start__c = System.today().addDays(5)));
        roleProgramPerspective.add(new Role_Program_Perspective__c(Name = 'Test Rpp 3',Staff_Assignment__c = staffAssignment[1].Id, Program_Perspective__c = programPerspectives[2].Id,
                                                                   Effective_Start__c = System.today().addDays(5)));
        insert roleProgramPerspective;
        
        Util.BypassAllTriggers = false;
        
    }
    
    @isTest    
    static void test_Batch_UpdateProgramPerspectives() 
    {
        List<Team_Membership__c> listOfTeamMemberships = [SELECT Id FROM Team_Membership__c];
        List<Program_Group__c> listOfGroupMember = [SELECT Id, Short_Name__c FROM Program_Group__c];
        Test.startTest();
        Database.executeBatch(new Batch_UpdateProgramPerspectives(listOfTeamMemberships));
        Test.stopTest();
        
        List<Team_Membership__c> teamMemberships = [SELECT Id, Program_Perspectives__c FROM Team_Membership__c];
        System.AssertEquals(listOfGroupMember[2].Short_Name__c, teamMemberships[1].Program_Perspectives__c);
    }
    
    @isTest    
    static void test_NegCaseForBatch_UpdateProgramPerspectives() 
    {
        List<Team_Membership__c> listOfTeamMemberships = new List<Team_Membership__c>();
        Test.startTest();
        try{
            Database.executeBatch(new Batch_UpdateProgramPerspectives(listOfTeamMemberships));
        }
        catch(exception e){
        	Boolean expectedExceptionThrown =  e.getMessage().contains('No Team Membership records exists.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);    
        }
        Test.stopTest();
    }
}