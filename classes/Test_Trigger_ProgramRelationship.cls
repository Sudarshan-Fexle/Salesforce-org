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
private class Test_Trigger_ProgramRelationship {

    /**
    *   Purpose         :   Test class for Trigger_ProgramRelationship trigger
    *            
    *   Create By       :   Subhash Garhwal
    *
    *   Created Date    :   06/26/2015
    *
    *   Revision Log    :   V_1.0 - Created
    *                       V_1.1 - Modified - Padmesh Soni - 07/13/2015 - New method added - testAssociateCollectionContentsOnCPC()
    *                       V_1.2 - Modified - Padmesh Soni - 08/01/2015 - New method added - validateCPCs()
    *                       V_1.3 - Modified - Padmesh Soni - 08/14/2015 - New method added - myUnitTest3() - CR-20150729-9114
    *                       V_1.4 - Modified - Rajeev Jain - 05/04/2016 - Modified Asserts regarding testing of incentive cahnge 
    *
    *   Coverage        :   V_1.0 - 100%
    *                       V_1.1 - 100%
    *                       V_1.2 - 95%
    *                       V_1.3 - 95%
    *
    **/
    
    //Setup test data from class
    @testSetup static void setupTestDataForClass() {
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert
        insert account;
        
        //Create a Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId());
        
        //Insert
        insert contact;
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 3', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'Test PG 1', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact.Id, Short_Name__c = 'test1211',Active__c = true));
        
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
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), In_use_Plans_Direct__c = 2, In_use_Plans_Indirect__c = 2, Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[2].Id, Perspective__c = perspectives[2].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
                                                           
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Query on Program Relation Ship Record Types
        List<RecordType> cpcReocrdTypeList = [Select Id, DeveloperName From RecordType Where SobjectType = 'Program_Relationship__c' AND IsActive = true 
                                                     AND DeveloperName IN ('Program', 'Program_Collection') ORDER BY DeveloperName ASC];
        
        //List of Program Relationship
        List<Program_Relationship__c> programRelationships = new List<Program_Relationship__c>();
        
        //Add new Program Relationship in list
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 1', Program_Perspective__c = programPerspectives[0].Id, Program__c = programs[0].Id, Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 2', Program_Perspective__c = programPerspectives[0].Id, Program__c = programs[1].Id, Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 3', Program_Perspective__c = programPerspectives[1].Id, Program__c = programs[1].Id, Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 4', Program_Perspective__c = programPerspectives[2].Id, Program__c = programs[0].Id, Business_Owner__c = contact.Id, Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), RecordTypeId = cpcReocrdTypeList[1].Id));
        
        //Insert
        insert programRelationships;
        
    }
    
    //Test method for validateBeforeDelete method
    static testMethod void myUnitTest() {
        
        //List of Program Relationship
        List<Program_Relationship__c> programRelationships = [Select Id From Program_Relationship__c ORDER BY Total_In_Use__c ASC];
        
        //Test start here 
        Test.startTest();
        
        //Delete Program Relationship
        delete programRelationships[0];
        
        //Query through program relationship
        List<Program_Relationship__c> proRelationships = [Select Id From Program_Relationship__c];
        
        //Assert for result
        System.assertEquals(3, proRelationships.size());
        
        try {
            
            //delete program relationship
            delete proRelationships;
            
            //Assert for result
            System.assert(false);
        
        } catch(Exception e) {
            
            //Assert for result
            System.assert(e.getMessage().contains(Label.PROGRAM_RELATIONSHIP_IN_USE));
        }
        
        // Test Stop here 
        Test.stopTest();
    }
    
    //Test method for validateBeforeDelete method
    static testMethod void myUnitTest1() {
        
        //List of Program Relationship
        List<Program_Relationship__c> programRelationships = [Select Id From Program_Relationship__c ORDER BY Total_In_Use__c ASC];
        
        //Test start here 
        Test.startTest();
        
        //Assert for result
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //update Program Relationship
        update programRelationships;
        
        //Assert for result
        System.assertEquals(0, Limits.getEmailInvocations());
        
        //Update Program Relationship
        programRelationships[0].Effective_End__c = System.today().addDays(5);
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
        
        //Update
        update programRelationships;
        
        //Subhash Garhwal - 23/7/2015 - CR-20150618-9013 - Code Commented as per Program Management Issues submitted by Taylor
        //Assert for result
        //System.assertEquals(1, Limits.getEmailInvocations());
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
        
        //Delete
        delete programRelationships[0];
        
        //Assert for result
        //System.assertEquals(1, Limits.getEmailInvocations());
        
        // Test Stop here 
        Test.stopTest();
    }
    
    //              ~~~~~~~~ Code added - Padmesh Soni (07/13/2015) - ~~~~~~~~
   //Test Method for associateCollectionContentsOnCPC method
    static testMethod void testAssociateCollectionContentsOnCPC() {
        
        //New list of cpc
        List<Program_Relationship__c> programRelationshipsFetch = new List<Program_Relationship__c>();
        
        //List of Program Perspective fetch via query from test setup CP LIST
        List<Program_Perspective__c> programPerspectivesFetch = [Select Id, Name From Program_Perspective__c];
        
        //List of Program fetch via query from test setup
        List<Program__c> programs = [Select Id, Name From Program__c];
        
        //List of Program Groups fetch via query from test setup
        List<Program_Group__c> programGroups = [Select Id, Name From Program_Group__c];
       
        //List of contact fetch via query from test setup
        List<Contact> contactFetch = [Select Id, Name From Contact];
        
        //List of Perspective
        List<Perspective__c> perspectives = [Select Id, Name From Perspective__c];
        
        //List of Record Type
        List<RecordType> recordTypes = [Select Id, DeveloperName From RecordType Where SObjectType = 'Program_Relationship__c' 
                                               AND DeveloperName IN ('Program', 'Program_Collection') ORDER BY DeveloperName ASC];
         
        //Add reocrds of CPC
        programRelationshipsFetch.add(new Program_Relationship__c(Name = 'Test PR 5', Program_Perspective__c = programPerspectivesFetch[1].Id, 
                                                                    Program_Group__c = programGroups[0].Id, RecordTypeId = recordTypes[1].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3)));
        programRelationshipsFetch.add(new Program_Relationship__c(Name = 'Test PR 6', Program_Perspective__c = programPerspectivesFetch[1].Id, 
                                                                    Program_Group__c = programGroups[1].Id, RecordTypeId = recordTypes[1].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today().addDays(4), Effective_End__c = System.today().addDays(6)));
        
        //Test start here 
        Test.startTest();
        
        //Bypass All Trigger set to false
        Util.ByPassAllTriggers = false;
        
        //Insert programRelationshipsFetch cpc 
        insert programRelationshipsFetch;
        
        //Assert for Result
        System.assertEquals(2, programRelationshipsFetch.size());
        
        //List of Collection Contents
        List<CollectionContents__c> collectionContents = [SELECT Id,Name FROM CollectionContents__c Where Collection_Perspective_Child__c =: programRelationshipsFetch[1].Id];        
        
        //assert statements
        System.assertEquals(3, collectionContents.size());
        
        //Bypass All Trigger set to false
        Util.ByPassAllTriggers = false;
        
        //Update Collection Perspective child
        programRelationshipsFetch[0].Program_Perspective__c = programPerspectivesFetch[0].Id;
        programRelationshipsFetch[1].Program_Perspective__c = programPerspectivesFetch[0].Id;
        
        //Update
        update programRelationshipsFetch;
        
        //List of Collection Contents
        collectionContents = [SELECT Id FROM CollectionContents__c WHERE Collection_Perspective_Child__c IN : programRelationshipsFetch];        
        
        //Assert statementss
        System.assertEquals(2, collectionContents.size());
        
        //Update Collection Perspective child
        programRelationshipsFetch[0].Program_Group__c = programGroups[2].Id;
        programRelationshipsFetch[1].Program_Group__c = programGroups[2].Id;
        
        //List of CPC
        List<Program_Relationship__c> pRList1 = [Select Id From Program_Relationship__c];
        
        //Assert for Result 
        System.assertEquals(6, pRList1.size());
        
        //Update
        update programRelationshipsFetch;
        
        //List of Collection Contents
        collectionContents = [SELECT Id FROM CollectionContents__c WHERE Collection_Perspective_Child__c =: programRelationshipsFetch];        
        
        //Assert statementss
        System.assertEquals(0, collectionContents.size());
        
        //Test Stop here 
        Test.stopTest();
    }
    
    
    //~~k~~~~~~ Code added - Padmesh Soni (08/01/2015) - ~~~~~~~~
    //Test method for validateCPCs method
    static testMethod void myUnitTest2() {
    
        //List of Program Relationship
        List<Program_Relationship__c> programRelationshipsFetch = [Select Id From Program_Relationship__c ORDER BY Total_In_Use__c ASC];
        
        //New list of cpc
        List<Program_Relationship__c> programRelationships = new List<Program_Relationship__c>();
        
        //New list of cpc
        List<Program_Relationship__c> programRelationshipsCheck = new List<Program_Relationship__c>();
        
        //List of Program Perspective fetch via query from test setup CP LIST
        List<Program_Perspective__c> programPerspectivesFetch = [Select Id, Name From Program_Perspective__c];
        
        //List of Program fetch via query from test setup
        List<Program__c> programs = [Select Id, Name From Program__c];
        
          //List of Program Groups fetch via query from test setup
        List<Program_Group__c> programGroups = [Select Id, Name From Program_Group__c];
       
        //List of contact fetch via query from test setup
        List<Contact> contactFetch = [Select Id, Name From Contact];
        
        //List of Perspective
        List<Perspective__c> perspectives = [Select Id, Name From Perspective__c];
        
        //List of Record Type
        List<RecordType> recordTypes = [select Id, DeveloperName From RecordType Where SObjectType = 'Program_Relationship__c'
                                                   AND DeveloperName IN ('Program', 'Program_Collection') ORDER BY DeveloperName ASC];
        
        //Add reocrds of CPC
        programRelationships.add(new Program_Relationship__c(Name = 'TestPR5', Program_Perspective__c = programPerspectivesFetch[0].Id, 
                                                                    Program__c = programs[0].Id, RecordTypeId = recordTypes[0].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today().addDays(30), Effective_End__c = System.today().addDays(40)));
        
        programRelationships.add(new Program_Relationship__c(Name = 'TestPR6', Program_Perspective__c = programPerspectivesFetch[0].Id, 
                                                                    Program__c = programs[0].Id, RecordTypeId = recordTypes[0].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today().addDays(28), Effective_End__c = System.today().addDays(60)));
        
        programRelationships.add(new Program_Relationship__c(Name = 'TestPR7', Program_Perspective__c = programPerspectivesFetch[0].Id, 
                                                                    Program_Group__c = programGroups[0].Id, RecordTypeId = recordTypes[1].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today().addDays(70), Effective_End__c = System.today().addDays(80)));
        
        programRelationships.add(new Program_Relationship__c(Name = 'TestPR8', Program_Perspective__c = programPerspectivesFetch[0].Id, 
                                                                    Program_Group__c = programGroups[0].Id, RecordTypeId = recordTypes[1].Id, Business_Owner__c = contactFetch[0].Id, 
                                                                    Effective_Start__c = System.today().addDays(90), Effective_End__c = System.today().addDays(100)));
        
        //Test start here 
        Test.startTest();
        
        //Try to update record with effective start date   
        try {    
            
            //Insert ProgramRelationShip
            insert programRelationships;
            
            //Assert for Result
            System.assert(false);
        
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_CPC));
         
        }
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
           
        //Change effective date to avoid overlaping   
        programRelationships[1].Effective_Start__c = System.today().addDays(45);
               
        //Insert programRelationships;  
        insert programRelationships;
        
        //Query through Collection Perspective Child
        List<Program_Relationship__c> cPCs = [Select Id From Program_Relationship__c];
        
        //Assert for result
        System.assertEquals(8, cPCs.size());
        
        //Try to update record with effective start date   
        try {    
            
            //By pass the triggers here
            Util.BypassAllTriggers = false;
        
            //Change effective date to avoid overlaping   
            programRelationships[1].Effective_Start__c = System.today().addDays(28);
            
            //Update
            update programRelationships[1];
            
            //Assert for Result
            System.assert(false);
        
        }
        
        //Catch block to handle exception
        catch(Exception ex) {
        
            //Assert for Result
            System.assert(ex.getMessage().contains(Label.ERROR_UNIQUENESS_CPC));
        }
        
            
        //Update Program Relation Ship Dates 
        programRelationships[2].Effective_Start__c = System.today().addDays(75);
        
        //Update
        update programRelationships;
        
        //Assert Check
        System.assertEquals(System.today().addDays(75), programRelationships[2].Effective_Start__c);
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
        
        //Update Program Relation Ship Dates 
        programRelationships[1].Effective_Start__c = System.today().addDays(46);
        
        //Update
        update programRelationships;
        
        //Assert Check
        System.assertEquals(System.today().addDays(46), programRelationships[1].Effective_Start__c);
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
        
        //Update Program Relation Ship Dates 
        programRelationships[2].Effective_End__c = System.today().addDays(85);
        
        //Update 
        update programRelationships[2];
        
        //Assert Check
        System.assertEquals(System.today().addDays(85), programRelationships[2].Effective_End__c);
        
        //By pass the triggers here
        Util.BypassAllTriggers = false;
        
        //Update Program Relation Ship Dates 
        programRelationships[2].Effective_Start__c = System.today().addDays(40);
            
        //Update 
        update programRelationships[2];
        
        //Assert Check
        System.assertEquals(System.today().addDays(40), programRelationships[2].Effective_Start__c);
        
        //Test Stop here 
        Test.stopTest();
    
    }
}