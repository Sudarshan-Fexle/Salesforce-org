/**
 *	Purpose		:	Test code for the ReferenceTriggerHelper class
 * 
 * 	Created By	:	Victor Hanson
 * 
 * 	Created Date	:	1/13/2016
 * 
 *      Revision Logs	:	V_1.0 - Created
 *				V_1.1 - Modified By - Mahendra Sawrnkar - 9/6/2016 - CR-20160809-10096
 *				V_1.2 - Modified By - Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment 
 *				V_1.3 - Modified By - Subhash - 10/12/2021 - CR-20211012-15511
 *
 * Code Covrage		:	93%
 *
 **/ 
@isTest(SeeAllData = false)
public class Test_ReferenceTriggerHelper {
	
    //setup test data
    @testSetup static void setup() {
        /**
         * @description:1) Setup 3 users with related contacts
         * 				2) Create Program Collections/Collection Perspectives/Collection Perspective Children
         * 				3) Create an Ambassador reference for a contact
         **/
        Test_ReferenceRequestController.setupTestData();
    }
    
    /**
     * 
     * @description: insert the Reference record and verify the Reference Lead is set according to the Businss Owner of the corresponding Program Collection record
     * 
     **/
    static testMethod void testSetReferenceLead() {
		//create some test users
        list<User> users = new list<User>();
        User dedicatedAdvisor = TestUtilities.CreatenewUser(false);
        users.add(dedicatedAdvisor);
        User nasaPrincipal = TestUtilities.CreatenewUser(false);
        users.add(nasaPrincipal);
        User nasaAP = TestUtilities.CreatenewUser(false);
        users.add(nasaAP);
        util.BypassAllTriggers = true;
        insert users;
        //create a new account
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Principal__c = nasaPrincipal.Id;
        acct.Associate_Principal__c = nasaAP.Id;
        util.BypassAllTriggers = true;
        insert acct;
        //create an external contact that will be used as a reference
        Contact c = TestUtilities.CreateNewContact(acct, false);
        //create an external contact that will be used as a reference
        //Contact c = TestUtilities.CreateNewContact(false);
        c.RecordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        c.lastName = 'Ambassador';
        util.BypassAllTriggers = true;
        insert c;
        //create the program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        //create the membership
        Membership__c mem = TestUtilities.CreateNewMembership(c.AccountId, prog.Id, true);
        util.BypassAllTriggers = false;
		
		Test.startTest();
       
    }
    
    /**
     * 
     * @description: insert the Reference record as Vetted-Ambassador and verify the Contact's Program Status is updated to reflect the programs that it is vetted for (ie: Performance Technology: CCC; CMA)
     * 
     **/
    static testMethod void testSetReferenceStatus() {
		//create some test users
        list<User> users = new list<User>();
        User dedicatedAdvisor = TestUtilities.CreatenewUser(false);
        users.add(dedicatedAdvisor);
        User nasaPrincipal = TestUtilities.CreatenewUser(false);
        users.add(nasaPrincipal);
        User nasaAP = TestUtilities.CreatenewUser(false);
        users.add(nasaAP);
        util.BypassAllTriggers = true;
        insert users;
        //create a new account
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Principal__c = nasaPrincipal.Id;
        acct.Associate_Principal__c = nasaAP.Id;
        util.BypassAllTriggers = true;
        insert acct;
        //create an external contact that will be used as a reference
        Contact c = TestUtilities.CreateNewContact(acct, false);
        //create an external contact that will be used as a reference
        //Contact c = TestUtilities.CreateNewContact(false);
        c.RecordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        c.lastName = 'Ambassador';
        util.BypassAllTriggers = true;
        insert c;
        //create the program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        //create the membership
        Membership__c mem = TestUtilities.CreateNewMembership(c.AccountId, prog.Id, true);
        util.BypassAllTriggers = false;
        //create the References for the contact
        list<Reference__c> refs = new list<Reference__c>();
		Test.startTest();
		
		/* 
        refs.add(new Reference__c(Contact_Name__c = c.Id,
                                  Institution__c = c.AccountId,
                                  Reference_Status__c = 'Vetted',
                                  Reference_Level__c = 'Gold Standard',
                                  Dedicated_Advisor__c = userInfo.getUserId(),
                                  Membership__c = mem.Id,
                                  Reference_Module__c = 'CCC',
                                  Reference_Vetter__c = userInfo.getUserId(),
								  Member_Type__c = 'NASA', 
								  NASA_Principal__c = UserInfo.getUserId(), 
                                  Projected_Vetting_Date__c = Date.today()));
        refs.add(new Reference__c(Contact_Name__c = c.Id,
                                  Institution__c = c.AccountId,
                                  Reference_Status__c = 'Vetted',
                                  Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userInfo.getUserId(),
                                  Membership__c = mem.Id,
                                  Reference_Module__c = 'CMA',
								  Member_Type__c = 'NASA', 
								  NASA_Principal__c = UserInfo.getUserId(), 
                                  Reference_Vetter__c = userInfo.getUserId(),
                                  Projected_Vetting_Date__c = Date.today()));
        insert refs;
		Test.stopTest();
		
        //get the contact and account program status fields
        c = [SELECT Id, Reference_Program_Status__c, Account.Reference_Program_Status__c FROM Contact WHERE id = :c.Id];
        system.assert(c.Reference_Program_Status__c.contains('CCC'));
        system.assert(c.Reference_Program_Status__c.contains('CMA'));
        system.assert(c.Account.Reference_Program_Status__c.contains('CCC'));
        system.assert(c.Account.Reference_Program_Status__c.contains('CMA')); */
    }
    
    /**
     * 
     * @description: insert the Reference record and verify the Dedicated Advisor ans NASA Principal/AP fields are populated
     * 
     **/
    static testMethod void testSetReferenceDefaults() {
        //create some test users
        list<User> users = new list<User>();
        User dedicatedAdvisor = TestUtilities.CreatenewUser(false);
        users.add(dedicatedAdvisor);
        User nasaPrincipal = TestUtilities.CreatenewUser(false);
        users.add(nasaPrincipal);
        User nasaAP = TestUtilities.CreatenewUser(false);
        users.add(nasaAP);
        util.BypassAllTriggers = true;
        insert users;
        //create a new account
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Principal__c = nasaPrincipal.Id;
        acct.Associate_Principal__c = nasaAP.Id;
        util.BypassAllTriggers = true;
        insert acct;
        //create an external contact that will be used as a reference
        Contact c = TestUtilities.CreateNewContact(acct, false);
        c.RecordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        c.lastName = 'Ambassador';
        util.BypassAllTriggers = true;
        insert c;
        //create the program
        Program__c prog = TestUtilities.CreateNewProgram(true);
        //create a Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Dedicated_Advisor__c = dedicatedAdvisor.Id;
        util.BypassAllTriggers = true;
        insert proj;
        //create the membership
        Membership__c mem = TestUtilities.CreateNewMembership(c.AccountId, prog.Id, false);
        mem.Primary_Project__c = proj.Id;
        util.BypassAllTriggers = true;
        insert mem;
        util.BypassAllTriggers = false;
        //create the Reference for the contact
        //Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment 
        Reference__c ref = new Reference__c(Contact_Name__c = c.Id,
                                            Institution__c = acct.Id,
                                            Reference_Status__c = 'Pending Approval',
                                            Reference_Level__c = 'Pipeline',
                                            Member_Type__c = 'NASA',
                                            Dedicated_Advisor__c = null, //intentionally left blank so we can test the auto-population code
                                            NASA_Principal__c = null, //intentionally left blank so we can test the auto-population code
                                            /*NASA_Associate_Principal__c = null,*/ //intentionally left blank so we can test the auto-population code
                                            Membership__c = mem.Id,
                                           Reference_Module__c = 'CCC',
                                            Projected_Vetting_Date__c = Date.today());
        //insert ref;
        
        //get the reference
        //ref = [SELECT Id, Dedicated_Advisor__c, NASA_Principal__c/*, NASA_Associate_Principal__c*/ FROM Reference__c WHERE Id = :ref.Id];
        //system.assertEquals(dedicatedAdvisor.Id, ref.Dedicated_Advisor__c);
        //system.assertEquals(nasaPrincipal.Id, ref.NASA_Principal__c);
        //system.assertEquals(nasaAP.Id, ref.NASA_Associate_Principal__c);
    }
    
    //Added by - Mahendra Sawrnkar - 9/6/2016 - CR-20160809-10096
    static testMethod void testUnit1() {
    	
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
        //Test method start here
        Test.startTest();
        
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
       
        // create a project
        Project__c proj = new Project__c(Name = 'test', Product__c = programs[0].Id, Institution__c = account.Id, Dedicated_Advisor__c = userList[1].Id);
        insert proj;
        
        //create the membership
        Membership__c mem = new Membership__c(Account_Name__c = contact[0].AccountId, Program__c = programs[0].Id, Primary_Project__c = proj.ID);
        insert mem;
        
        //Add recordtype in test class - CR-20211012-15511 - Subhash
        Id referenceRecordTypeId = Schema.SObjectType.Reference__c.getRecordTypeInfosByName().get('PT').getRecordTypeId();
        
        //create the References for the contact
        list<Reference__c> refs = new list<Reference__c>();
        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Gold Standard',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id, Reference_Module__c = 'CCC;CMA',
                                  Reference_Vetter__c = userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 1', Member_Type__c = 'NASA', 
											NASA_Principal__c = UserInfo.getUserId(), RecordTypeId = referenceRecordTypeId));
        
        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id, Reference_Module__c = 'CCC;CMA',
                                  Reference_Vetter__c = userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 2', Member_Type__c = 'NASA', 
											NASA_Principal__c = UserInfo.getUserId(), RecordTypeId = referenceRecordTypeId));

        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id,Reference_Module__c = 'CCC;CMA',Member_Type__c = 'NASA',
                                  Reference_Vetter__c =userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 3',  NASA_Principal__c = userList[2].Id, 
                                  RecordTypeId = referenceRecordTypeId));
        refs.add(new Reference__c(Contact_Name__c = contact[0].Id, Institution__c = contact[0].AccountId, Reference_Status__c = 'Vetted', Reference_Level__c = 'Ambassador',
                                  Dedicated_Advisor__c = userList[0].Id, Membership__c = mem.Id,Reference_Module__c = 'CCC;CMA',Member_Type__c = 'NASA',
                                  Reference_Vetter__c =userList[1].Id, Projected_Vetting_Date__c = Date.today(), Attribute_A__c = 'Test 4',  NASA_Principal__c = userList[2].Id,
                                  RecordTypeId = referenceRecordTypeId));
        
        
        //Assert for result
        System.assert(refs.size() > 0);
        
        
		
	//Enable trigger flag
	Util.byPassAllTriggers = false;
		
	//Insert Reference records
        insert refs;
        
        ReferenceTriggerHelper.setReferenceLead(refs);
        
        //Retrive Refrence record to get updated records
        //Modified By Dipesh Gupta - 10/07/2019 - CR-20190919-13355 - Commented NASA_Associate_Principal__c as per requirment 
        List<Reference__c> refrenceRetriveRecords = [SELECT Id, Reference_Lead__c ,Dedicated_Advisor__c,Reference_Module__c, Attribute_A__c , 
        											NASA_Principal__c/*, NASA_Associate_Principal__c*/
                                                    FROM Reference__c 
                                                    ORDER BY Attribute_A__c ASC];
                                             
        //Assert for result
        //System.AssertEquals(4, refrenceRetriveRecords.size() );
        //System.assertEquals(refrenceRetriveRecords[3].NASA_Principal__c, userList[1].Id );
        //System.assertEquals(refrenceRetriveRecords[3].NASA_Associate_Principal__c, userList[0].Id );
        
        //Test methof stop here
        Test.stopTest();
         
    }
    
    
    /**
     * Create By -  Subhash
     * @description: cover setReferenceLead function of ReferenceTriggerHelper
     * CR - CR-20211012-15511
    **/
    static testMethod void setReferenceLeadReferenceRequestTest(){
        util.BypassAllTriggers = true;
        Contact reqContact = TestUtilities.CreateNewContact(false);
        reqContact.lastName = 'reqContact';
        reqContact.recordTypeId = Test_ReferenceRequestController.CONTACT_EXTERNAL_RT_ID;
        insert reqContact;

        //Insert new Program
        Program__c testProgram = testUtilities.createNewProgram(true);
        
        //create the membership related to the institution
        util.BypassAllTriggers = true;
        Membership__c mem = new Membership__c(Account_Name__c = reqContact.AccountId, Program__c = testProgram.Id);
        insert mem;
        util.BypassAllTriggers = false;
        
        List<Reference_Request__c> rRequestList = new List<Reference_Request__c>();
        Id referenceRRecordTypeId = Schema.SObjectType.Reference_Request__c.getRecordTypeInfosByName().get('PT').getRecordTypeId();
        Reference_Request__c req = new Reference_Request__c(Request_Status__c = 'New',
                                                            Reference_Modules__c = 'CCC',
                                                            Requesting_Contact__c = reqContact.Id,
                                                            Requesting_Institution__c = reqContact.AccountId,
                                                            Source_Membership__c = mem.Id,
                                                            Date_Needed_By__c = Date.today(),
                                                            Number_of_References_Needed__c = 1,
                                                            Reference_Type_Needed__c = 'Individual',
                                                            Submitted_By__c = userInfo.getUserId(),
                                                            RecordTypeId = referenceRRecordTypeId
                                                           );
        rRequestList.add(req);
        insert rRequestList;
        Test.startTest();
        ReferenceTriggerHelper.setReferenceLead(rRequestList);
        Test.stopTest();
    }
}