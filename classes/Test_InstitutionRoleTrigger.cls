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
@isTest
private class Test_InstitutionRoleTrigger {

/*
    Purpose         :   Test class for Institution Role Trigger.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/08/2012
    
    Revision Log    :   V_1.0 Created
                        V_1.1 New method added  - CR-20111205-259
                        V_1.2 Bhavi - 11/05/2012 - CR-20120920-1514
                        V_1.3 Bhavi - 11/08/2012 - Added a new Method(PopulateContactData) - CR-20121019-1641
                        V_1.4 Prateek Pant - 11/03/2021 - CR-20210930-15473
    Coverage        :   
**/    

    
    
   @TestSetup
    static void testData(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //create the account and contact sample data
        Account account1 = new Account(Name = 'TestAccount1');
        insert account1;
        Account account2 = new Account(Name = 'TestAccount2');
        insert account2;
       
        //insert the contact record
        Contact contact1 = new Contact(LastName = 'TestContact1', AccountId = account1.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact1;
        Contact contact2 = new Contact(LastName = 'TestContact2', AccountId = account1.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact2;
        Contact contact3 = new Contact(LastName = 'TestContact3', AccountId = account2.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact3;
        
        //creating test AssignmentRoles
        Team_Role__c assignRole1= new Team_Role__c(Name= 'Role1' , Business_Owner__c = contact1.id, Entity__c = 'EAB',Institution_Role_External__c= true);
        insert assignRole1;
        Team_Role__c assignRole2= new Team_Role__c(Name= 'Role2' , Business_Owner__c = contact2.id, Entity__c = 'EAB',Institution_Role_External__c= true);
        insert assignRole2;
    }
    
    // Added by Seemu Saikia : 04/03/2019
    // Modified By - Prateek Pant - CR-20210930-15473 - Create testMethod
    static testMethod void testDuplicateInstitutionRole(){
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        // query account
        List<Account> accounts = [Select Id From Account];
        System.assertEquals(2, accounts.size());
       
        // query contact
        List<Contact> contacts = [Select Id From Contact];
        System.assertEquals(3, contacts.size());
        
        // query team roles
        List<Team_Role__c> teamRoles = [Select Id From Team_Role__c];
        System.assertEquals(2, teamRoles.size());
        
        //List of Roles 
        List<Institution_Roles__c> listIRoles = new List<Institution_Roles__c>();
        Institution_Roles__c  instRole1 = new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id,Contact__c = contacts[0].Id);
        Institution_Roles__c  instRole2 = new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id,Contact__c = contacts[1].Id);
        
        listIRoles.add(instRole1);
        listIRoles.add(instRole2);
        
        Util.BypassAllTriggers = false;
        Test.startTest();
        try{
            insert listIRoles; 
        }catch(Exception e){
            System.assert(e.getMessage().contains('The Role you selected already exists for this Institution. Please select another Role.'));
        }
          
        listIRoles = [Select Id From Institution_Roles__c];
        System.assertEquals(0, listIRoles.size());
        
        Util.BypassAllTriggers = true;
        listIRoles =  new List<Institution_Roles__c>();
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id,Contact__c = contacts[0].Id));
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[1].Id,Contact__c = contacts[1].Id));
        
        insert listIRoles;
        List<Institution_Roles__c> createdIR = [Select Id From Institution_Roles__c];
        System.assertEquals(2, createdIR.size());
        
        // Create duplicate Institution_Roles__c
        listIRoles =  new List<Institution_Roles__c>();
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id,Contact__c = contacts[0].Id));
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[1].Id,Contact__c = contacts[1].Id));
        Util.BypassAllTriggers = false;
        
        try{
            insert listIRoles;
        }catch(Exception e){
            System.assert(e.getMessage().Contains('The Role you selected already exists for this Institution. Please select another Role'));
        }
        
        Test.stopTest();    
	}
	
    //Added by Seemu Saikia : 04/03/2019
    //Modified By - Prateek Pant - CR-20210930-15473 - Create testMethod
    static testMethod void testUpdateContactBasedOnInstitutionRole(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        // query account
        List<Account> accounts = [Select Id From Account];
        System.assertEquals(2, accounts.size());
       
        // query contact
        List<Contact> contacts = [Select Id From Contact];
        System.assertEquals(3, contacts.size());
        contacts[0].Contact_Status__c = 'Active';
        contacts[0].Key_Contact__c = false;
        contacts[1].Contact_Status__c = 'Active';
        contacts[1].Key_Contact__c = false;
        update contacts;
        
        // query team roles
        List<Team_Role__c> teamRoles = [Select Id From Team_Role__c];
        System.assertEquals(2, teamRoles.size());
        
        //List of Roles 
        List<Institution_Roles__c> listIRoles = new List<Institution_Roles__c>();
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id, Contact__c = contacts[0].Id));
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[1].Id, Contact__c = contacts[1].Id));
        
        Test.startTest(); 
        Util.BypassAllTriggers = false;
        insert listIRoles; 

        contacts = [Select Id, Key_Contact__c From Contact Where Key_Contact__c = true];
        System.assertEquals(2, contacts.size());
        
        Test.stopTest();
    }
    
    //Modified By - Prateek Pant - CR-20210930-15473 - Create testMethod
    static testMethod void test_updateInstitutionRoleName(){
         
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        // query account
        List<Account> accounts = [Select Id From Account];
        System.assertEquals(2, accounts.size());
       
        // query contact
        List<Contact> contacts = [Select Id From Contact];
        System.assertEquals(3, contacts.size());
        contacts[0].Contact_Status__c = 'Active';
        contacts[0].Key_Contact__c = false;
        contacts[1].Contact_Status__c = 'Active';
        contacts[1].Key_Contact__c = false;
        update contacts;
        
        // query team roles
        List<Team_Role__c> teamRoles = [Select Id From Team_Role__c];
        System.assertEquals(2, teamRoles.size());
        
        //List of Roles 
        List<Institution_Roles__c> listIRoles = new List<Institution_Roles__c>();
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id, Contact__c = contacts[0].Id));
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[1].id, Institution__c = accounts[1].Id, Contact__c = contacts[1].Id));
        insert listIRoles; 
        
        listIRoles = [Select Id, Vacant_Role__c From Institution_Roles__c];
        listIRoles[0].Vacant_Role__c = true;
        listIRoles[1].Vacant_Role__c = true;
        
        Test.startTest();
        Util.BypassAllTriggers = false;
        update listIRoles;
        
        listIRoles = [Select Id, Vacant_Role__c From Institution_Roles__c Where Name like '%- Vacant%'];
        System.assertEquals(2, listIRoles.size());
        
        delete listIRoles;
        
        Util.BypassAllTriggers = true;
        listIRoles = new List<Institution_Roles__c>();
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[0].id, Institution__c = accounts[0].Id, Contact__c = contacts[0].Id, Vacant_Role__c = true));
        listIRoles.add(new Institution_Roles__c(Assignment_Role__c = teamRoles[1].id, Institution__c = accounts[1].Id, Contact__c = contacts[1].Id, Vacant_Role__c = true));
        insert listIRoles; 
        
        Util.BypassAllTriggers = false;
        InstitutionRoleTriggerHelper.BYPASS_TRIGGER_CASE_UPDATE_SUPPORT_PRODUCT = false;
        listIRoles[0].Vacant_Role__c = false;
        listIRoles[1].Vacant_Role__c = false;
        update listIRoles;
        
        listIRoles = [Select Id, Vacant_Role__c From Institution_Roles__c Where Name like '%- Vacant%'];
        System.assertEquals(0, listIRoles.size());
        Test.stopTest();
    }
}