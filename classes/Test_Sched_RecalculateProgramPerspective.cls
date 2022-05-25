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
private class Test_Sched_RecalculateProgramPerspective {
/**
 * 	Purpose			:	Test class for Sched_RecalculateProgramPerspective.
 * 
 * 	Created By		:	Padmesh Soni
 * 
 *	Created Date	:	07/06/2015 
 *
 * 	Revision Logs	:	V_1.0 - Created
 * 
**/
	//Test method of test class name myUnitTest that check some assert statement to gain coverage of test class.
	static testMethod void myUnitTest() {
		
		//Set to hold Staff Assignment Ids
		Set<Id> setSAIds = new Set<Id>();
		
		//Create account 
        List<Account> accounts = new List<Account>();
        
        //Add new records in list
        accounts.add(new Account(Name = 'Test Account1'));
        accounts.add(new Account(Name = 'Test Account2'));
        
        //Insert 
        insert accounts;

        //Create contact
        List<Contact> contacts = new List<Contact>();
        
        //Add new records in list
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855' ,Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855' ,Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
    
        //Insert contact
        insert contacts;
        
        //Create program Collection
        List<Program_Group__c> programCollections = new List<Program_Group__c>();
        
        //Add new records in list
        programCollections.add(new Program_Group__c(Name = 'PC 1', Short_Name__c = 'short name 1' ));
        programCollections.add(new Program_Group__c(Name = 'PC 2', Short_Name__c = 'short name 2'));
        
        //Insert program collection
        insert programCollections;
        
        //Create team role
        List<Team_Role__c> staffRoles = new List<Team_Role__c>();
        
        //Add new records in list
        staffRoles.add(new Team_Role__c(Name = 'Test 1',Active__c = true));
        staffRoles.add(new Team_Role__c(Name = 'Test 2',Active__c = true));
        
        //Insert
        insert staffRoles;
        
        //Create Perspective 
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new records in list
        perspectives.add(new Perspective__c(Name = 'perspective 1'));
        perspectives.add(new Perspective__c(Name = 'perspective 2'));
        
        //Insert
        insert perspectives;
        
        //Create program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new records in list
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 1' , Active__c = true,Perspective__c = perspectives[0].Id, Program_Group__c = programCollections[0].Id ));
        programPerspectives.add(new Program_Perspective__c(Name = 'PP 2' , Active__c = true,Perspective__c = perspectives[1].Id, Program_Group__c = programCollections[1].Id));
        
        //Insert Program Pespective
        insert programPerspectives;
        
        //Create staff Assignment 
        List<Team_Membership__c> staffAssignment = new List<Team_Membership__c>();
        
        //Add new records in list
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id , Start_date__c = System.today().addDays(-3), End_date__c = System.today().addDays(5)));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 2',Institution__c = accounts[1].Id , Start_date__c = System.today().addDays(-3), End_date__c = System.today().addDays(5)));
                
        //Insert
        insert staffAssignment;
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspectives = new List<Role_Program_Perspective__c>();
        
        //Add new records in list
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today().addDays(-2), Effective_End__c = System.today().addDays(-1)));
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[1].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today().addDays(-2),Effective_End__c = System.today().addDays(3)));
        
        //Insert
        insert roleProgramPerspectives;  
     	
   		//Test start from here
		Test.startTest();
		
		//Initialization of schedule class to call default constructure
		Sched_RecalculateProgramPerspective sched = new Sched_RecalculateProgramPerspective();
		
		//Set sch Value
		String sch =  '0 0 23 * * ?';
        
        //Calling of Scheduler
        System.schedule('Test check', sch, sched);
      
		//Test end here
       	Test.stopTest();
       
    }
}