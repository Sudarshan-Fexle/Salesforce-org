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

/**
    Purpose         :   Test class for Batch_UpdateDegreeAuditOnProject class

    Create By       :   Mahendra Swarnkar 

    Created Date    :   11/24/2021

    Revision Log    :   v1.0 - Created - CR-20211118-15596
**/
@isTest
public class Test_Batch_UpdateDegreeAuditOnProject {
    
    @testSetup static void testSetup(){
        
        Util.byPassAllTriggers = true;
        
        //Creating account records.
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
        //Creating Project. 
        ID SSC_RTYPE_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        ID APS_RTYPE_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        //List to hold the Projects.
        List<Project__c> listProject = new List<Project__c>();
        
        //Create a Project record
        Project__c project1 = new Project__c(Name = 'Test-1', Institution__c = account.Id,
                                             Project_Phase__c = '1 - Test', RecordTypeId = APS_RTYPE_PROJECT);
        
        //Create a Project record
        Project__c project2 = new Project__c(Name = 'Test-2', Institution__c = account.Id,
                                             Project_Phase__c = '2 - Test', RecordTypeId = SSC_RTYPE_PROJECT);
        listProject.add(project1);
        listProject.add(project2);
        insert listProject;
        
        List<Competitor_and_Tech_System__c> compTechSysList = new List<Competitor_and_Tech_System__c>();
        
        //Creating Asset records.
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=account.Id, Name='CompTechSystem 1', Tech_System__c ='LMS', Category__c = 'Enrollment', Start_Date__c = System.today() -1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=account.Id, Name='CompTechSystem 2', Tech_System__c ='SIS',Category__c = 'Enrollment', Start_Date__c = System.today() -1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=account.Id, Name='CompTechSystem 3', Tech_System__c ='LMS;SIS', Category__c = 'Enrollment', Start_Date__c = System.today() -1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=account.Id, Name='CompTechSystem 4', Tech_System__c = 'CRM', Category__c = 'Enrollment', Start_Date__c = System.today() -1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=account.Id, Name='CompTechSystem 5', Tech_System__c ='LMS;SIS;CRM', Category__c = 'Enrollment', Start_Date__c = System.today() -1, End_Date__c = System.today() + 2));
        
        insert compTechSysList;
        
        Util.byPassAllTriggers = False;
        
    }
    
    @isTest
    static void testBatch_UpdateDegreeAuditOnProject(){
        
        test.startTest();
        
        Batch_updateDegreeAuditOnProject batchUpdateDegreeAuditOnProject  = new Batch_updateDegreeAuditOnProject();
        Database.executeBatch(batchUpdateDegreeAuditOnProject);
        
        test.stopTest();
        List<Project__c> projects = [Select Id, Current_SIS__c, Learning_Management_System__c, Enrollment_CRM__c
                                     From Project__c order by Name];
        System.assert(projects != null);
        System.assertEquals('CompTechSystem 2,CompTechSystem 5,CompTechSystem 3', projects[0].Current_SIS__c);
        System.assertEquals('CompTechSystem 5,CompTechSystem 4', projects[0].Enrollment_CRM__c);
        
    }
}