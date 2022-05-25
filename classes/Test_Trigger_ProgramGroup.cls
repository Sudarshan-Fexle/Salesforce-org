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
private class Test_Trigger_ProgramGroup {   
/**
 *   Purpose         :   Test class for Trigger_ProgramGroup
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   06/26/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150618-9014
 * 		     :	 V_1.1 - Manual Merger By - Rajeev Jain - In Test Sandbox - 05/29/2016 - In order to conflict found with Release 50 CR-20160315-9697 Mods
 * 		     :	 V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of the program collection
 * 	             :   V_1.3 - Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record
 * 
 *   Coverage        :   V_1.0 - 100%
 **/
    
    //Test method to test validateProgramGroup methods functionality
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Short_Name__c = 'test1211', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 3', Effective_Start__c = System.today().addDays(-2), Effective_End__c = System.today(),
                                               Active__c = true));
        
        //Start testing from here
        Test.startTest();
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert
        insert programGroups;
        
        //Update Program Group Name
        programGroups[0].Name = 'Test PG 2';
        
        try {
            
            //Update
            update programGroups;
            
        } catch(Exception e) {
            
            //Assert
            System.assert(e.getMessage().contains(Label.DUPLICATE_PROGRAM_GROUP));      
        }
        
        //Stop Testing here
        Test.stopTest();
    }
    
    //Test method to test validateBeforeDelete methods functionality
    static testMethod void myUnitTest1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Short_Name__c = 'test1211', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Short_Name__c = '1332Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true, In_use_Plans_Direct__c = 2));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[1].Id,
                                                           Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Start testing from here
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //Delete Program Group (Collection)
        delete programGroups[1];
        
        //Query through program groups
        List<Program_Group__c> proGroups = [Select Id From Program_Group__c];
        
        //Assert for result
        System.assertEquals(1, proGroups.size());
        
        try {
            
            //Delete
            delete proGroups;
            
        } catch(Exception e) {
            
            //Assert for result
            System.assert(e.getMessage().contains(Label.PROGRAM_GROUP_IN_USE));     
        }
        
        //Stop Testing here
        Test.stopTest();
    }
        
    //Test method to test functionality of keyInformationChangedNotification method
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id,
                                      Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact.Id, Short_Name__c = 'test1211', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 2', Effective_Start__c = System.today().addDays(-5), Effective_End__c = System.today(),
                                               Business_Owner__c = contact.Id, Short_Name__c = 'test121121', Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'Test PG 3', Effective_Start__c = System.today().addDays(-2), Effective_End__c = System.today(),
                                               Business_Owner__c = contact.Id, Short_Name__c = 'test121112', Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Business_Owner__c = contact.Id, Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 2', Business_Owner__c = contact.Id, Short_Name__c = '1332Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Test Perspective 3', Business_Owner__c = contact.Id, Short_Name__c = '1222Test230', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 2', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 3', Program_Group__c = programGroups[2].Id, Perspective__c = perspectives[2].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        
        //Start testing from here
        Test.startTest();
        
        //Assert
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Update Program Group
        update programGroups;
        
        //Assert
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //Change in key field
        programGroups[0].Effective_Start__c = System.today().addDays(-1);
        programGroups[1].Name = 'Program Group';
        programGroups[2].Effective_End__c = System.today().addDays(10);
        
        //Update Program Groups
        update programGroups;
        
        //Subhash Garhwal - 23/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
        //Assert for result
        //System.assertEquals(1, Limits.getEmailInvocations());
        
        //Delete Program Groups
        delete programGroups;
        
        //Stop testing here
        Test.stopTest();
    }

    //Added by - Subhash Garhwal
    //Test method to test SummarizeRPPs methods functionality
    //V_1.2 - Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record (Modified Method)
    static TestMethod void testSummarizeRPPs() {
        
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
        Test.startTest();
        Util.BypassAllTriggers = false;
        
        programCollections[0].Short_Name__c = 'ShortName1';
        programCollections[1].Short_Name__c = 'ShortName2';    
        
        update programCollections;
        Test.stopTest();
        
        List<Team_Membership__c> teamMemberships = [SELECT Id, Program_Perspectives__c FROM Team_Membership__c];
        System.AssertEquals('ShortName1, ShortName2', teamMemberships[0].Program_Perspectives__c);
        
    }
    
    //V_1.1 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of the program collection
    //Test method to test  incentiveChangeLogmethods functionality
    /*static testMethod void testIncentiveChangeLog() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
    
    	//Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list
        programCollections.add(new Program_Group__c(Name = 'pC1', Short_Name__c = 'short name 1',Effective_Start__c = System.today().addDays(-3) , Effective_End__c = System.today().addDays(3)));
        programCollections.add(new Program_Group__c(Name = 'pC2', Short_Name__c = 'short name 2',Effective_Start__c = System.today().addDays(-3) , Effective_End__c = System.today().addDays(5) ));
        programCollections.add(new Program_Group__c(Name = 'pC3', Short_Name__c = 'short name 3',Effective_Start__c = System.today().addDays(-5) , Effective_End__c = System.today().addDays(5) ));
        programCollections.add(new Program_Group__c(Name = 'pC4', Short_Name__c = 'short name 4',Effective_Start__c = System.today().addDays(-3) , Effective_End__c = System.today().addDays(3)));
        programCollections.add(new Program_Group__c(Name = 'pC5', Short_Name__c = 'short name 5',Effective_Start__c = System.today().addDays(-3) , Effective_End__c = System.today().addDays(5) ));
        programCollections.add(new Program_Group__c(Name = 'pC6', Short_Name__c = 'short name 6',Effective_Start__c = System.today().addDays(-5) , Effective_End__c = System.today().addDays(5) ));
        
        //Test method start here
        Test.startTest();
        
        //Enale trigger here
        Util.BypassAllTriggers = false;
        
        //insert programCollections
        insert programCollections;
        
        //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> incentives = [Select Id, Name, Program_Collection__c From Incentive_Change_Log__c 
                                                    Where Program_Collection__c IN : programCollections];
        
        //Assert for result
        System.assertEquals(0, incentives.size());

        //Update Program Collection
        programCollections[0].Short_Name__c = 'update shortname';
        programCollections[1].Name = 'updatename';
        programCollections[2].Effective_End__c = System.today().addDays(9);
        
        //Update programCollections
        update programCollections;
        
        //Query Through Incentive Change Log
        incentives = [Select Id, Name, Program_Collection__c, End_Date__c From Incentive_Change_Log__c 
                      Where Program_Collection__c IN : programCollections];
        
        //Assert for result
        System.assertEquals(2, incentives.size());
        
        //Update Program Collection
        programCollections[3].Short_Name__c = 'update short change';
        programCollections[4].Effective_Start__c = System.today().addDays(-4);
        
        //Update Program Collection
        update programCollections;
        
        //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> incentivesRecords = [Select Id, Name,Start_Date__c, Program_Collection__c From Incentive_Change_Log__c Where Program_Collection__c IN : programCollections AND Id NOT IN : incentives];
        
        //Assert for result
        System.assertEquals(2, incentivesRecords.size());
        System.assertEquals(System.today().addDays(-4), incentivesRecords[1].Start_Date__c);
        
        //Update Program Collection
        programCollections[1].Short_Name__c = 'testing name';
        programCollections[5].Effective_Start__c = System.today().addDays(-4);
        programCollections[5].Effective_End__c = System.today().addDays(9);
        
        //Update Program Collection
        update programCollections;
        
        //Query Through Incentive Change Log
        List<Incentive_Change_Log__c> incentivesWithSNAndDate = [Select Id, Name, Program_Collection__c, Start_Date__c, End_Date__c From Incentive_Change_Log__c Where Program_Collection__c IN : programCollections AND Id NOT IN : incentives AND Id NOT IN : incentivesRecords];
        
        //Assert for result
        System.assertEquals(2, incentivesWithSNAndDate.size());
        System.assertEquals(programCollections[5].Effective_Start__c, incentivesWithSNAndDate[1].Start_Date__c);
        System.assertEquals(programCollections[5].Effective_End__c, incentivesWithSNAndDate[1].End_Date__c); 
        
        //Test method stop here
        Test.stopTest();
    }*/
}