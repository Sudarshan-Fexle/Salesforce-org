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
private class Test_Trigger_ProgramPerspective {
    
    /**
    *   Purpose         :   Test class for Trigger_ProgramPerspective trigger
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   06/26/2015
    *
    *   Revision Log    :   V_1.0 - Created
    *			    V_1.1 - Added - Padmesh Soni - New method added myUnitTest2()
    *		            V_1.2 - Modified By - Rajeev Jain - In test sandbox - Conflict found with Release 50 CR-20160315-9697 Mods
    *			    V_1.3 - Modified By - Rajeev jain - CR-20151120-9402 - Removed the usage of myUnitTest2
    *			    V_1.4 - Modified By - Neha Sharma - CR-20211012-15511 increase code coverage
    **/
    
    //Test method for validateProgramPerspective
    static testMethod void myUnitTest() {
        
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
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
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
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true, In_use_Plans_Direct__c = 2, In_use_Plans_Indirect__c = 2));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(7), Active__c = true));
        
        //Start testing from here 
        Test.startTest();
        
        try {
            
            //Enabling triggers again
        	Util.BypassAllTriggers = false;
        
            //Insert
            insert programPerspectives;
            
        } catch(Exception e) {
            
            //Assert for result
            System.assert(e.getMessage().contains(Label.DUPLICATE_COMBINATION));        
        }
        
        //Change Program Group and Perspective
        programPerspectives[2].Effective_Start__c = System.today().addDays(5);
        
        //Insert
        insert programPerspectives;
        
        //Stop testing here
        Test.stopTest();
    }
    
    //Test method for validateBeforeDelete method
    static testMethod void myUnitTest1() {
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
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
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
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4),
                                                           In_use_Plans_Direct__c = 3, In_use_Plans_Indirect__c = 4, In_use_Staff_Direct__c = 5, Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Start testing from here 
        Test.startTest();
        
        //Delete Program Perspective
        delete programPerspectives[1];
        
        //Query through Program Perspective
        List<Program_Perspective__c> proPerspectives = [Select Id From Program_Perspective__c];
        
        //Assert for result
        System.assertEquals(2, proPerspectives.size());
        
        try {
            
            //delete Program Perspective
            delete proPerspectives;
        
        } catch(Exception e) {
            
            //Assert for result
            System.assert(e.getMessage().contains(Label.PROGRAM_PERSPECTIVE_IN_USE));
        }
    }
    
    //Added by - Subhash Garhwal
    //Test method to test updateRPPs methods functionality
    static testmethod void testUpdateRPPs() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add new recrods in list 
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert account
        insert accounts;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new recrods in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new recrods in list 
        staffRoles.add(new Team_Role__c(Name = 'Test 1', Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test 2', Active__c = true, Institution__c = true));
        insert staffRoles;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new recrods in list 
        perspectives.add(new Perspective__c(Name = 'Perspective 1'));
        perspectives.add(new Perspective__c(Name = 'Perspective 2'));
        
        //Insert
        insert perspectives;
        
        //Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list 
        programCollections.add(new Program_Group__c(Name = 'PC 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2'));
        
        //Insert
        insert programCollections;
        
        //Enabling triggers again
        Util.BypassAllTriggers = false;
        
        // Create program Perspective
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
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id ,
                                                    Staff_member__c = contacts[0].Id,Role__c = staffRoles[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id ,
                                                    Staff_member__c = contacts[1].Id,Role__c = staffRoles[1].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments;
        
        //Create role Program perspective 
        List<Role_Program_Perspective__c> rPPs = new List<Role_Program_Perspective__c>();
        
        //Add new recrods in list 
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp1',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[0].Id));
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp2',Staff_Assignment__c = staffAssignments[1].Id,Program_Perspective__c = programPerspectives[1].Id));
        
        // Test method start
        Test.startTest();
        
        //Insert role Program perspective
        insert rPPs;
        
        //Query through RPP
        List<Role_Program_Perspective__c> rPPsList = [Select Id, Name From Role_Program_Perspective__c];
        
        //Assert for result
        System.assertEquals('Test Contact 1-Test 1-PC 1-Perspective 1', rPPsList[0].Name);
        System.assertEquals('Test Contact 2-Test 2-PC 2-Perspective 2', rPPsList[1].Name);
        
        //Update 
        programCollections[0].Name = 'PG 1';
        
        //Update
        update programCollections;
        
        //CR-20211012-15511
        programPerspectives = [Select Id, Name From Program_Perspective__c];
        System.assertEquals(2, programPerspectives.size());
        programPerspectives[0].Name = 'ppp1';
        programPerspectives[1].Name = 'ppp2';
        update programPerspectives;
        
        //Test method Stop
        Test.stopTest();
    }
    
    //Added by - Subhash Garhwal
    //Test method to test SummarizeRPPs methods functionality
    static testmethod void testSummarizeRPPs() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        Util.BypassAllTriggers = true;
        
        //Create Account
        List<Account> accounts = new List<Account>();
        
        //Add new recrods in list 
        accounts.add(new Account(Name = 'Test Account1'));
        
        //Insert account
        insert accounts;
        
        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new recrods in list
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new recrods in list 
        staffRoles.add(new Team_Role__c(Name = 'Test 1', Active__c = true, Institution__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test 2', Active__c = true, Institution__c = true));
        insert staffRoles;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new recrods in list 
        perspectives.add(new Perspective__c(Name = 'Perspective 1'));
        perspectives.add(new Perspective__c(Name = 'Perspective 2'));
        
        //Insert
        insert perspectives;
        
        //Enabling trigger here
        Util.BypassAllTriggers = false;
        
        //Create Program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new recrods in list 
        programCollections.add(new Program_Group__c(Name = 'PC 1'));
        programCollections.add(new Program_Group__c(Name = 'PC 2'));
        
        //Insert
        insert programCollections;
        
        // Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new recrods in list 
        programPerspectives.add(new Program_Perspective__c(Name = 'pp1' , Active__c = true, Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'pp2' , Active__c = true, Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        
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
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id, 
                                                    Staff_member__c = contacts[0].Id,Role__c = staffRoles[0].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id, 
                                                    Staff_member__c = contacts[1].Id,Role__c = staffRoles[1].Id, 
                                                    Start_date__c = System.today().addDays(-3), 
                                                    End_date__c = System.today().addDays(+5),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert
        insert staffAssignments;
        
        //Create role Program perspective 
        List<Role_Program_Perspective__c> rPPs = new List<Role_Program_Perspective__c>();
        
        //Add new recrods in list 
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp1',Staff_Assignment__c = staffAssignments[0].Id,Program_Perspective__c = programPerspectives[0].Id));
        rPPs.add(new Role_Program_Perspective__c(Name = 'rpp2',Staff_Assignment__c = staffAssignments[1].Id,Program_Perspective__c = programPerspectives[1].Id));
        
        // Test method start
        Test.startTest();
        
        //Insert role Program perspective
        insert rPPs;
        
        //Query through RPP
        List<Role_Program_Perspective__c> rPPsList = [Select Id, Name From Role_Program_Perspective__c];
        
        //Assert for result
        System.assertEquals('Test Contact 1-Test 1-PC 1-Perspective 1', rPPsList[0].Name);
        System.assertEquals('Test Contact 2-Test 2-PC 2-Perspective 2', rPPsList[1].Name);
        
        //Test method Stop
        Test.stopTest();
    }    
    
	//-------------Code Added by Padmesh Soni  08/07/2015   CR-20150729-9114 ----------------
	//V_1.2 - Modified - Rajeev jain - CR-20151120-9402 - Removed the usage of myUnitTest2
	//Test method to check createIncentiveChangeLog method
	/*static testMethod void myUnitTest2() {
        
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
		
		//List of Program Collection
		List<Program_Group__c> programGroups = new List<Program_Group__c>();
		    
		//Add new Program Groups in list
		programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
												Business_Owner__c = contact.Id, Short_Name__c = 'test1211', Active__c = true));
		                                        
		//Insert
		insert programGroups;
		
		//Assert
		System.assert(programGroups.size() > 0);
		
		//List of Perspective
		List<Perspective__c> perspectives = new List<Perspective__c>();
		
		//Add new Perspective record in list
		perspectives.add(new Perspective__c(Name = 'Test Perspective 1', Business_Owner__c = contact.Id, Short_Name__c = '11244test1211', Active__c = true));
		
		//Insert
		insert perspectives;
		
		//Assert for result
		System.assert(perspectives.size() > 0);
        
        //Enabling trigger here
        Util.BypassAllTriggers = false;
		        
		//List of Program Perspective
		List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
		
		//Add new Program Perspective in list
		programPerspectives.add(new Program_Perspective__c(Name = 'Test CP 1', Program_Group__c = programGroups[0].Id,
														   Perspective__c = perspectives[0].Id, 
														   Business_Owner__c = contact.Id, 
														   Effective_Start__c = System.today(), 
														   Effective_End__c = System.today().addDays(20),
														   Active__c = true));
		
		//Insert
		insert programPerspectives;
		
		//Assert for results
		System.assert(programPerspectives.size() > 0);
		
		//Start testing from here 
		Test.startTest();
		
		//List of Incentive Change Log
		List<Incentive_Change_Log__c> iCG = [SELECT Id, Name, Collection_Perspective__c FROM Incentive_Change_Log__c 
                                             Where Collection_Perspective__c IN : programPerspectives];        
		
		//Assert for results
		System.assertEquals(0, iCG.size());
		
		//Update date field to create ICG record
		programPerspectives[0].Effective_Start__c = System.today().addDays(5);
		
		//Update programPerspectives
		update programPerspectives[0];
		
		//List of Incentive Change Log
		iCG = [SELECT Id, Name, Collection_Perspective__c FROM Incentive_Change_Log__c 
               Where Collection_Perspective__c IN : programPerspectives];        
		
		//Assert for results
		System.assertEquals(1, iCG.size());
		
		//Update program date fields
		programPerspectives[0].Effective_End__c = System.today().addDays(25);
		
		//By pass the triggers here
		Util.BypassAllTriggers = false;
		
		//Update programPerspectives
		update programPerspectives;
		
		//List of Incentive Change Log
		iCG = [SELECT Id, Name, Change_Type__c FROM Incentive_Change_Log__c 
               Where Collection_Perspective__c =: programPerspectives[0].Id];        
		
		//Assert for results
		System.assertEquals(2, iCG.size());
		
		//Update satus field
		programPerspectives[0].Active__c = false;
		
		//By pass the triggers here
		Util.BypassAllTriggers = false;
		
		//Update programPerspective
		update programPerspectives;
		
		//List of Incentive Change Log
		iCG = [SELECT Id, Name, Change_Type__c FROM Incentive_Change_Log__c Where Collection_Perspective__c =: programPerspectives[0].Id];        
		
		//Assert for result
		System.assertEquals(3, iCG.size());
		
		//Stop testing here
		Test.stopTest();
	}*/
}