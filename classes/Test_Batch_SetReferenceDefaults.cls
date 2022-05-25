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
 *  Purpose         :   Test class for Batch_SetReferenceDefaults
 *
 *  Created By      :   Mahendra Swarnkar
 *  
 *  Created Date    :   9/5/2016 
 *
 *  Revision Log    :   V1.0 - Create By - Mahendra Swarnkar - CR-20160809-10096 
 * 						V1.1 - Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment 
 *
 *  Code Coverage   :	89%
 *
 **/
@isTest(SeeAllData = false)
private class Test_Batch_SetReferenceDefaults {
    
     public static final string CONTACT_EXTERNAL_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External').getRecordTypeId();
    
    //Method to test Batch functionality
    static testMethod void myUnitTest() {   
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email='testuser1@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User3', FirstName='Test3', Email='testuser3@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true));
        
        //Insert user records
        insert userList;
        
        //Assert for result
        System.assert(userList.size() > 0);

        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        account.Associate_Principal__c = userList[0].Id;
        account.Principal__c = userList[1].Id;
        
        //Insert
        insert account;
        
        //Create a Contact
        List<Contact> contact = new List<Contact>();
                
        contact.add(new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(), Reference_Program_Status__c = 'CCC', Title = 'Test', Phone = '614-555-8855'));
        contact.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test@test.com', AccountId = account.Id, Employee_User_Record__c = Userinfo.getUserId(), Reference_Program_Status__c = 'CCC', Title = 'Test', Phone = '614-555-8855'));
        
        //Insert
        insert contact;
        
        //Assert for result
        System.assert(contact.size() > 0);
        
        //List of Program
        List<Program__c> programs = new List<Program__c>();
        
        //Add new Programs in list
        programs.add(new Program__c(Name = 'Test Program 1', Status__c = 'Active'));
        programs.add(new Program__c(Name = 'Test Program 2', Status__c = 'Active'));
        
        //Insert
        insert programs;
        
        //Assert
        System.assert(programs.size() > 0);
        
        //List of Program Groups
        List<Program_Group__c> programGroups = new List<Program_Group__c>();
        
        //Add new Program Groups in list
        programGroups.add(new Program_Group__c(Name = 'PT', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact[0].Id, Short_Name__c = 'test1211',Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'PT', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact[0].Id, Short_Name__c = 'test1212',Active__c = true));
                                               
		programGroups.add(new Program_Group__c(Name = 'CCC', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact[0].Id, Short_Name__c = 'test1213',Active__c = true));
        
        programGroups.add(new Program_Group__c(Name = 'CCC', Effective_Start__c = System.today().addDays(-3), Effective_End__c = System.today(),
                                               Business_Owner__c = contact[0].Id, Short_Name__c = 'test1214',Active__c = true));
        
        //Insert
        insert programGroups;
        
        //Assert
        System.assert(programGroups.size() > 0);
        
        //List of Perspective
        List<Perspective__c> perspectives = new List<Perspective__c>();
        
        //Add new Perspective record in list
        perspectives.add(new Perspective__c(Name = 'Reference Tracking', Business_Owner__c = contact[0].Id, Short_Name__c = '1232Test230', Active__c = true));
        perspectives.add(new Perspective__c(Name = 'Reference Tracking', Business_Owner__c = contact[1].Id, Short_Name__c = '1232Test231', Active__c = true));
        
        //Insert
        insert perspectives;
        
        //Assert
        System.assert(perspectives.size() > 0);
        
        //List of Program Perspective
        List<Program_Perspective__c> programPerspectives = new List<Program_Perspective__c>();
        
        //Add new Program Perspective in list
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[0].Id, Perspective__c = perspectives[0].Id,
                                                           Business_Owner__c = contact[0].Id, Effective_Start__c = System.today(), 
                                                           Effective_End__c = System.today().addDays(4), In_use_Plans_Direct__c = 2, 
                                                           In_use_Plans_Indirect__c = 2, Active__c = true));
        
        programPerspectives.add(new Program_Perspective__c(Name = 'Test PP 1', Program_Group__c = programGroups[1].Id, Perspective__c = perspectives[1].Id,
                                                           Business_Owner__c = contact[0].Id, Effective_Start__c = System.today(), 
                                                           Effective_End__c = System.today().addDays(4), Active__c = true));
        
        //Insert
        insert programPerspectives;
        
        //Assert
        System.assert(programPerspectives.size() > 0);
        
        //Query on Program Relation Ship Record Types
        List<RecordType> cpcReocrdTypeList = [Select Id, DeveloperName From RecordType Where SobjectType = 'Program_Relationship__c' 
                                              AND IsActive = true AND DeveloperName IN ('Program', 'Program_Collection') 
                                              ORDER BY DeveloperName ASC];
        
        //Assert for result
        System.assert(cpcReocrdTypeList.size() > 0);
        
        //List of Program Relationship
        List<Program_Relationship__c> programRelationships = new List<Program_Relationship__c>();
        
        //Add new Program Relationship in list
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 1', Program_Perspective__c = programPerspectives[0].Id, 
                                                             Business_Owner__c = contact[0].Id, 
                                                             Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), 
                                                             RecordTypeId = cpcReocrdTypeList[1].Id, Program_Group__c = programGroups[2].Id));
        
        
        
        programRelationships.add(new Program_Relationship__c(Name = 'Test PR 2', Program_Perspective__c = programPerspectives[1].Id, 
                                                              Business_Owner__c = contact[0].Id, 
                                                             Effective_Start__c = System.today(), Effective_End__c = System.today().addDays(3), 
                                                             RecordTypeId = cpcReocrdTypeList[1].Id, Program_Group__c = programGroups[3].Id));
        
        //Insert
        insert programRelationships;
        
        //Assert for result
        System.assert(programRelationships.size() > 0);
                
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
		String APS_RTYPE = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
		
        // create a project
        Project__c proj = new Project__c(Name = 'test', Product__c = programs[0].Id, Institution__c = account.Id, 
                                         Dedicated_Advisor__c = userList[1].Id, RecordTypeId = APS_RTYPE);
        insert proj;
        
        //create the membership
        Membership__c mem = new Membership__c(Account_Name__c = contact[0].AccountId, Program__c = programs[0].Id, Primary_Project__c = proj.ID);
        insert mem;
        
        //create the References for the contact
        list<Reference__c> refs = new list<Reference__c>();
        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Gold Standard',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id, Reference_Module__c = 'CCC;CMA',
                                  Reference_Vetter__c = userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 1', Member_Type__c = 'NASA', NASA_Principal__c = userList[2].Id));
        
        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id, Reference_Module__c = 'CCC;CMA',
                                  Reference_Vetter__c = userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 2', Member_Type__c = 'NASA', NASA_Principal__c = userList[2].Id));

        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id, Reference_Module__c = 'CCC;CMA',Member_Type__c = 'NASA',
                                  Reference_Vetter__c =userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 3', NASA_Principal__c = userList[2].Id));
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Insert Reference records
        insert refs;
        
        //Assert for result
        System.assert(refs.size() > 0);
        
        //create the Reference Request
        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'Vetted',
                                                          Reference_Modules__c = 'CCC',
                                                           Requesting_Contact__c = contact[0].Id,
                                                           Requesting_Institution__c = contact[0].AccountId,
                                                           Source_Membership__c = mem.Id,
                                                           Date_Needed_By__c = System.today(),
                                                           Number_of_References_Needed__c = 1,
                                                           Reference_Type_Needed__c = 'Individual',
                                                           Submitted_By__c = userInfo.getUserId());
        insert req;
        
        //Asserting for the results
        List<Reference__c> references = [SELECT ID, Dedicated_Advisor__c, Reference_Status__c FROM Reference__c];
        System.assert(references != null);
        System.assertEquals(3, references.size());
        System.assertEquals(userList[0].Id, references[0].Dedicated_Advisor__c);
        System.assertEquals(userList[0].Id, references[1].Dedicated_Advisor__c);
        System.assertEquals(userList[0].Id, references[2].Dedicated_Advisor__c);
        
        
        //create the Reference Request Contact
        list<Reference_Request_Contact__c> rrcsList = new list<Reference_Request_Contact__c>();
        Reference_Request_Contact__c rrc1 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                           Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        Reference_Request_Contact__c rrc2 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                           Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        Reference_Request_Contact__c rrc3 = new Reference_Request_Contact__c(Reference_Contact__c = contact[0].Id,
                                                                            Reference_Request__c = req.Id,
                                                                            Reference_Modules__c = 'CCC',
                                                                            Approval_Status__c = 'Pending',
                                                                            Reference_Lead__c = userInfo.getUserId());
        rrcsList.add(rrc1);
        rrcsList.add(rrc2);
        rrcsList.add(rrc3);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Insert reference request contacts
        insert rrcsList;
        
        //Assert for result
        System.assert(rrcsList.size() > 0);
        
        //Asserting for the results
        List<Reference_Request_Contact__c> refReqContacts = [SELECT ID, Approver__c FROM Reference_Request_Contact__c];
        System.assert(refReqContacts != null);
        System.assertEquals(3, refReqContacts.size());
        System.assertEquals(null, refReqContacts[0].Approver__c);
        System.assertEquals(null, refReqContacts[1].Approver__c);
        System.assertEquals(null, refReqContacts[2].Approver__c);
        
        //Test method start here
        Test.startTest();
        
        //Batch Instance
        Batch_SetReferenceDefaults BC = new Batch_SetReferenceDefaults();

        //Execute batch
        Database.executeBatch(BC, 10);
          
        //Test methof stop here
        Test.stopTest();

		//Asserting for the results        
        references = [SELECT Id, Reference_Lead__c ,Dedicated_Advisor__c, 
                                                     Reference_Module__c,Attribute_A__c , 
        											 NASA_Principal__c/*, NASA_Associate_Principal__c*/
                                                     FROM Reference__c 
                                                     ORDER BY Attribute_A__c ASC];
                                                   
        //Assert for result
        System.assert(references != null);
        System.assertEquals(3, references.size());
        
        //Asserting for the results
        refReqContacts = [SELECT ID, Approver__c FROM Reference_Request_Contact__c];
        System.assert(refReqContacts != null);
        System.assertEquals(3, refReqContacts.size());
        
        System.assertEquals(userList[1].Id, references[0].Dedicated_Advisor__c);
        System.assertEquals(userList[1].Id, references[1].Dedicated_Advisor__c);
        System.assertEquals(userList[1].Id, references[2].Dedicated_Advisor__c);
        
        /*System.assertEquals(contact[0].Employee_User_Record__c, references[0].Reference_Lead__c);
        System.assertEquals(contact[0].Employee_User_Record__c, references[1].Reference_Lead__c);
        System.assertEquals(contact[0].Employee_User_Record__c, references[2].Reference_Lead__c);
        
        System.assertEquals(userList[1].Id, references[2].NASA_Principal__c);*/
        //System.assertEquals(userList[0].Id, references[2].NASA_Associate_Principal__c );
    }
}