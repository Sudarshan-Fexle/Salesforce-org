/**
 *  Purpose         :   This Class is used to test the class - UpdateContactInstitutionRoleController
 *
 *  Create By       :   Dipesh Gupta
 *
 *  Created Date    :   04/24/2019
 *
 *  Revision Logs   :   V_1.0 - Created.
 *                      
 **/
@istest(seeAllData=false)
public class Test_UpdateContactInstitutionRoleContro {

    @istest static void unitTestMethod() {
        
        
         //List of Roles 
        List<Institution_Roles__c> listIRoles = new List<Institution_Roles__c>(); 
        
        //create the account and contact sample data
        Account account1 = new Account(Name = 'TestAccount1');
        insert account1;
        
        //insert the contact record
        Contact contact1 = new Contact(LastName = 'TestContact1', AccountId = account1.Id, Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert contact1;
        
        //creating test AssignmentRoles
        Team_Role__c assignRole1= new Team_Role__c(Name= 'Role1' , Business_Owner__c = contact1.id, Entity__c = 'EAB',Institution_Role_External__c= true);
        insert assignRole1;
        
        //creating test AssignmentRoles
        Team_Role__c assignRole2 = new Team_Role__c(Name= 'Role2' , Business_Owner__c = contact1.id, Entity__c = 'EAB',Institution_Role_External__c= true);
        insert assignRole2;
        
        //create a garbeage institute role
        Institution_Roles__c  instRole1 = new Institution_Roles__c(Assignment_Role__c = assignRole1.id, Institution__c = account1.Id);
        Institution_Roles__c  instRole2 = new Institution_Roles__c(Assignment_Role__c = assignRole2.id, Institution__c = account1.Id);
		listIRoles.add(instRole1);
        listIRoles.add(instRole2);
        
        insert listIRoles;
        
        Test.StartTest();
        	
        //Initialize the controller. 
        ApexPages.currentPage().getParameters().put('id',contact1.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contact1);
        
        UpdateContactInstitutionRoleController controller = new UpdateContactInstitutionRoleController(sc);
        controller.institutionRoleWrapper[0].isChecked = true;
        controller.doSave();
        
        //Assert.
        List<Institution_Roles__c> institutionRole = [Select Id, Contact__c From Institution_Roles__c Where Contact__c != null];
        System.assert(institutionRole.size() == 1);
		System.assertEquals(institutionRole[0].Contact__c, contact1.Id);
        
        //2nd Round of testing where no Institution role is selected.
        controller.institutionRoleWrapper[0].isChecked = false;
        
        try {
        	controller.doSave();    
        }catch(Exception e) {
            System.assert(e.getMessage().contains('Please select at least one institution role.'));
        }
        
        Test.StopTest();
    }
}