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
@isTest(seeAlldata = false)
private class Test_OverrideCPCNewButtonController {
/**
 *  Purpose         :   Test class for OverrideCPCNewButtonController .
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   07/24/2015 
 *
 *  Revision Logs   :   V_1.0 - Created CR-20150618-9013
 *
 *  Coverage        :   100% 
 * 
**/
    
    //Test method of test class name testRedirect that check some assert statement to gain coverage of test class.
    static testMethod void testRedirect() {
    
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //Program instance
        Program__c programs = new Program__c(Name = 'TestProgram1', Status__c = 'Active');
        
        //Insert
        insert programs;
          
        //Program Groups instance
        Program_Group__c programGroups = new Program_Group__c(Name = 'TestPG1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                                              Business_Owner__c = contact.Id, Short_Name__c = 'test1211', Active__c = true);
        
        //Insert
        insert programGroups;
        
        //Perspective instance
        Perspective__c perspectives = new Perspective__c(Name = 'TestPerspective1', Business_Owner__c = contact.Id, Short_Name__c = '1232Test230', Active__c = true);
        
        //Insert
        insert perspectives;
        
        //Program Perspective instance
        Program_Perspective__c programPerspectives = new Program_Perspective__c(Name = 'TestPP1', Program_Group__c = programGroups.Id, Perspective__c = perspectives.Id,
                                                                                Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), 
                                                                                Active__c = true, In_use_Plans_Direct__c = 2, In_use_Plans_Indirect__c = 2);
     
        //Insert
        insert programPerspectives;
        
        //Query to fetch record type ID
        List<RecordType> recordID = [SELECT Id FROM RecordType WHERE sObjectType = 'Program_Relationship__c'];
        
        //Program Relationship Instance
        Program_Relationship__c programRelationships = new Program_Relationship__c(Name = 'TestPR', Program_Perspective__c = programPerspectives.Id, 
                                                                                   RecordTypeId = recordID[0].id);
        
        //Test start here 
        Test.startTest();
        
        //Standard controller instance passing collection perspective child  
        ApexPages.StandardController sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        OverrideCPCNewButtonController controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        Pagereference pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Program_Perspective__c'));
      
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c(Name = 'TestPR1', Program_Perspective__c = null ,Business_Owner__c = contact.Id, RecordTypeId = recordID[0].ID);
       
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller = new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Business_Owner__c'));
       
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c(Name = 'TestPR2', Effective_Start__c = System.today() , Program_Perspective__c = programPerspectives.Id,
                                                           RecordTypeId = recordID[0].ID);
       
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Effective_Start__c'));
      
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c(Name = 'TestPR3', Program_Group__c = programGroups.Id, RecordTypeId = recordID[0].ID);
       
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Program_Group__c'));
      
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c(Name = 'TestPR4', Program__c = programs.Id, RecordTypeId = recordID[0].ID);
        
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Program__c'));
        
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c(Name = 'TestPR2', Business_Owner__c = contact.Id, RecordTypeId = recordID[0].ID);
        
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef.getUrl().contains('Business_Owner__c'));
      
        //Program Relationship Instance
        programRelationships = new Program_Relationship__c();
        
        //Standard controller instance passing collection perspective child  
        sc = new ApexPages.standardController(programRelationships); 
        
        //Controller instance 
        controller= new OverrideCPCNewButtonController(sc);
        
        //Method calling
        pageRef = controller.redirect();
        
        //Assert for result
        System.assert(pageRef == null);
      
        //Test end here
        Test.stopTest();
    }
}