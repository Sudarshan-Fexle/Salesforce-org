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
private class Test_Trigger_RoleProgramPerspective {
/**
 *   Purpose         :   Test class for Trigger_RoleProgramPerspective
 *            
 *   Create By       :   Subhash Garhwal
 *
 *   Created Date    :   07/6/2015
 *
 *   Revision Log    :   V_1.0 - Created - CR-20150618-9014
 *                       V_1.1 - Added -  Padmesh Soni - 08/05/2015 - New method added - preventDuplicates()
 * 			 V_1.2 - Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record
 * 			 V_1.3 - Modified - Mahendra Swarnkar - CR-20201123-14708 - 09/01/2021 - Population of the Current Program Responsibilities field on Staff Assignment
 * 
 *                      
 **/
    
    //Test method to test validateUpdate methods functionality
    //Modified - Abhinav Sharma - CR-20200806-14405 - Error In Update Program Collection record
    static testMethod void testvalidateUpdate(){

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
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact1', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact2', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855',Employee_User_Record__c = Userinfo.getUserId(), AccountId = accounts[0].Id));
    
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
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3)));
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[1].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today().addDays(-2),Effective_End__c = System.today().addDays(3)));
        
        
        //Test method start here 
        Test.startTest();
        
        //Insert
        insert roleProgramPerspectives;          
		
        try{
            roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',
                                                                        Program_Perspective__c = programPerspectives[0].Id,
                                                                        Effective_Start__c = System.today().addDays(-2),
                                                                        Effective_End__c = System.today().addDays(3)));
            
            Insert roleProgramPerspectives[2];
        }
        catch(DMLException ex){
            System.assert(ex.getMessage().contains('REQUIRED_FIELD_MISSING'));
        }
        
        
        //Test method stop here 
        Test.stopTest();  
        //Modified By - Mahendra Swarnkar - CR-20201123-14708 - 09/01/2021 - Population of the Current Program Responsibilities field on Staff Assignment
        //List<Team_Membership__c> teamMemberships = [Select Id, Name, Program_Perspectives__c From Team_Membership__c ORDER BY CreatedDate];
        //Assert for result
        //System.assertEquals(programCollections[0].Short_Name__c, teamMemberships[0].Program_Perspectives__c);
    
    }
    
    
    //~~~~~~~~ Code added - Padmesh Soni (08/05/2015) - ~~~~~~~~
    //Test method for preventDuplicates method
    static testMethod void myUnitTest2() {
    
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
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 1',Institution__c = accounts[0].Id , Start_date__c = System.today().addDays(-3), End_date__c = System.today().addDays(100)));
        staffAssignment.add(new Team_Membership__c(Name = 'Test As 2',Institution__c = accounts[1].Id , Start_date__c = System.today().addDays(-3), End_date__c = System.today().addDays(100)));
                
        //Insert
        insert staffAssignment;
        
        //Create Role Program Perspective
        List<Role_Program_Perspective__c> roleProgramPerspectives = new List<Role_Program_Perspective__c>();
        
        //Add new records in list
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 1',Staff_Assignment__c = staffAssignment[0].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(10)));
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 2',Staff_Assignment__c = staffAssignment[0].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today().addDays(8),Effective_End__c = System.today().addDays(20)));
        roleProgramPerspectives.add(new Role_Program_Perspective__c(Name = 'Test Rpp 3',Staff_Assignment__c = staffAssignment[0].Id, 
                                    Program_Perspective__c = programPerspectives[0].Id,Effective_Start__c = System.today().addDays(30),Effective_End__c = System.today().addDays(40)));
        
        //Test method start here 
        Test.startTest();
        
        //Try to update record with effective start date
        try {    
            
            //Insert
            insert roleProgramPerspectives;  
            
            //Assert for Result
            System.assert(false);
        
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_RPP));
         
        }
        
        //Change effective date to avoid overlaping   
        roleProgramPerspectives[1].Effective_Start__c = System.today().addDays(12);
               
        //Insert role program perspective;  
        insert roleProgramPerspectives;
        
        //Query through role program perspective
        List<Role_Program_Perspective__c> rPPs = [Select Id From Role_Program_Perspective__c];
        
        //Assert for result
        System.assertEquals(3, rPPs.size());
        
        //Try to update record with effective start date   
        try {    
            
            //Update role program perspective Dates 
            roleProgramPerspectives[2].Effective_Start__c = System.today().addDays(35);
            
            //Update
            update roleProgramPerspectives;
            
            //Assert Check
            System.assertEquals(System.today().addDays(35), roleProgramPerspectives[2].Effective_Start__c);
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_RPP));
         
        }
        
        //Try to update record with effective start date   
        try {    
            
            //Update start Dates for role program perspective
            roleProgramPerspectives[1].Effective_Start__c = System.today().addDays(15);
            
            //Update
            update roleProgramPerspectives;
    
            //Assert Check
            System.assertEquals(System.today().addDays(15), roleProgramPerspectives[1].Effective_Start__c);
            
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_RPP));
         
        }
        
        //Try to update record with effective end date   
        try {    
            
            //Update role program perspective Dates 
            roleProgramPerspectives[2].Effective_End__c = System.today().addDays(85);
            
            //Update 
            update roleProgramPerspectives[2];
            
            //Assert Check
            System.assertEquals(System.today().addDays(85), roleProgramPerspectives[2].Effective_End__c);
        
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_RPP));
         
        }   
    
        //Try to update record with effective end date   
        try {    
            
            //Update role program perspective Dates 
            roleProgramPerspectives[2].Effective_Start__c = System.today().addDays(19);
            
            //Update 
            update roleProgramPerspectives[2];
            
            //Assert Check
            System.assertEquals(System.today().addDays(19), roleProgramPerspectives[2].Effective_Start__c);
        
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_RPP));
         
        }
        //Test Stop here 
        Test.stopTest();
    
    }
}