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
private class Test_UserTrigger {
    /*
    Purpose         :   Test class for Trigger_User
    
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/19/2012
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created
                        V1.1 - (SUNJ 12/19/13) - CR-20130118-2218
                        V1.2 - Modified By - Ajit Surana - Added new method (test_updateOwnerManagerEmailOnOpportunities) - 04/19/2014 - CR-20140403-4951
                        V1.3 - Modified By - Ajit Surana - Added new method (test_updateCTAssignmentManagerEmailOnOpportunities) - 04/29/2015 - CR-20140403-4951
                        V1.4 - Modified By - Abhinav Sharma - Added new method (test_doUpdateOnOpportunitiesOnUserUpdate) -  08/26/2015 - CR-20150820-9167
                        V1.5 - Modified By - Abhinav Sharma - 12/23/2015 - CR-20150706-9060 - Updated SF Admin opportunity record type reference 
                                             with some other record type reference. Since it is mark eligible for deletion cycle.
                        V1.6 - Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
                        V1.7 - Modified By - Colin McGloin - 08/08/2016 - CR-20160414-9762 - Added new method "validateSteelbrickApproverAdded"
                        V1.8 - Modified By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
                        V1.9 - Modified By - Saurabh Kumar - 06/26/2017 - Q2C Redesign - Beta Release
                        V2.0 - Modified By - Subhash garhwal - 01/31/2018 - CR-20180126-11902 - New Method deactivateStaffAssignmentForInactiveUsersTest
                        V2.1 - Modified By - Colin McGloin - 09/04/2018 - CR-20180731-12476 - Commented out reference to field Scope_MtM__c due to Opp Lookup Cleanup/Removal
                        V2.2 - Modified By - Dipesh Gupta - 02/05/2020 -  L1 Weekly Release - 3/4 Deployment Fix
                        V2.3 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
                        V2.4 - Modified By - Nikita Kumari - 09/28/2021 - CR-20210910-15426 - Updated the duplicate Program_Acronym__c
                        V2.5 - Modified By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes

    */
    
    //HttpRequest instance
    static Httprequest req = new Httprequest();
    
    //instance of Mock service class 
    //static CreditCardServiceMockClass mockController = new CreditCardServiceMockClass();
    
    //Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
   /**
    * @description: Test method to test out the functionality which will update "Owner Manager Email" on Opportunity records 
    *               when Manager has been updated on an User record(s).
    *               Test method to test out the functionality which will update CT Assignment's Manager Email on Opportunity records
    *               When Manager has been updated on User record(s).
    **/
    static testMethod void test_UseCases1() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
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
        
        //Test starts from here
        Test.startTest();
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Insert users
        insert userList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert Account record
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        System.assert(acc != null);
        
        //Insert Program record
        Program__c program = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                            Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
        insert program;
        System.assert(program != null);
        
        //Department Division Function
        Department_Division_Function__c dDF = new Department_Division_Function__c(Name = 'Test', Cost_Center__c = '1213');
        insert dDF;
        System.assert(dDF != null);
        
        //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Starts from here
        //Record types for "Intranet Item" object
        /*List<RecordType> rdTypes = [SELECT ID FROM RecordType 
                                    WHERE IsActive = true 
                                    AND SobjectType = 'Intranet_Item__c' 
                                    AND DeveloperName =: UserTriggerHelper.RTName_Office];
        //Asserting for the results
        System.assert(rdTypes != null);
        System.assert(rdTypes.size() > 0);
        
        //Intranet Item
        Intranet_Item__c iT = new Intranet_Item__c(Name = 'Test-0', Location_Code__c = '11232', RecordTypeId = rdTypes[0].ID, 
                                                   Active_Status__c = 'Active', Office_Short_Name__c = 'Test',
                                                   Item_Type__c = 'App Link', Item_Title__c = 'Office',
                                                   Category_Name__c = 'A',Color_Set_Name__c = 'ColorSet');
        insert iT;*/
        //Commented By - Nikita Kumari - 08/03/2022 - CR-20220217-15921 - Boardroom Sunsetting Changes - Ends from here
        
        //Getting Record Type Id Value for Opportunity
        List<RecordType> oppRecordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                           AND IsActive = true
                                           AND DeveloperName = 'EAB_Initiating'];
        System.assert(oppRecordTypes != null);
        System.assert(oppRecordTypes.size() > 0);
        
        Contact con = TestUtilities.CreateNewContact(True);
        
        //Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
        //Insert Opportunity record
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', RecordTypeId = oppRecordTypes[0].ID, 
                                                  StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 100, CloseDate = System.today().addDays(32), 
                                                  AccountId = acc.Id, OwnerId = userList[0].Id,Main_Contact__c = con.Id,
                                                  CT_Assignment__c = userList[0].Id, CT_Pass_Status__c = 'Assigned', 
                                                  CT_Reneg_Attempt__c = 'No', Sales_Pursuit_Products__c = 'APS');
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        List<Opportunity> oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                                     WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals(null, oppList[0].Owner_Manager_Email__c);
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[1].Id;
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Uodating user
        update userList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        Batch_OppUpdateCTAssManagerEmailData oppUpdateCTAsstManagerBatch = new Batch_OppUpdateCTAssManagerEmailData(new set<Id> { userList[0].Id, userList[1].Id, userList[2].Id });
        database.executeBatch(oppUpdateCTAsstManagerBatch, 1);
        
        Batch_OpportunityUpdateManagerEmail oppUpdateManagerBatch = new Batch_OpportunityUpdateManagerEmail(new set<Id> { userList[0].Id, userList[1].Id, userList[2].Id });
        database.executeBatch(oppUpdateManagerBatch, 1);
       
        //Test stops from here
        Test.stopTest();
        //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity WHERE Id=: opportunity.Id];
          
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size()> 0);
        System.assertEquals('testuser2@test.com', oppList[0].Owner_Manager_Email__c);
           
        //Update first user Manager lookup to second user
        userList[0].ManagerId = null;
        userList[0].Associate__c = UserInfo.getUserId();
        userList[0].Cost_Center__c = '1213';
        userList[0].ABC_Department__c = 'EAB';
        userList[0].Location_Code__c = '11232';
        
        //Enabling triggers
        Util.byPassAllTriggers=false;
        update userList;
  
        //Querying for the user details
        List<User> users = [SELECT ID, ABC_Department__c FROM User WHERE ID =: userList[0].ID];
        
        //Asserting for the results
        System.assert(users != null);
        System.assert(users.size() == 1);
        System.assertEquals(null, users[0].ABC_Department__c);
    }
    
    //Modified By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
    /**
    * @description: Test method to check deactivateCreditCardsForInactiveUsers methods based use cases and functionalities.
    **/
        //Commented by rajeev jain - functionality not in use
        /* static testMethod void deactivateCreditCardsForInactiveUsers() {
    
    //Bypass Dupeblocker
    Util.IsTest(true);
    
    //Bypassing Triggers so then test data can be created easily
    Util.byPassAllTriggers = true;
    
    //Flag for triggers: this is just a test, don't do crazy things.
    Util.isTesting = true;
    
    //Get profile list
    List<Profile> testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
    
    //Assert for results
    System.assert(testProfile != null);
    System.assert(testProfile.size()>0);
    
    //Test User Create
    List<User> userList = new List<User>();
    
    userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', 
    Email='testuser1@test.com', Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
    ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', localesidkey='en_US', 
    EmployeeNumber = '12121212', IsActive = true));
    
    //Run as user
    System.RunAs(new User(Id = UserInfo.getUserId())) {
    insert userList;
    }
    
    //insert Credit Card Settings record
    Credit_Card_Settings__c configCCDefaultSetting = TestUtilities.CreateCreditCardSettings();
    insert configCCDefaultSetting;
    
    //Set helper class variable
    CreditCardHelper.configDefaults = configCCDefaultSetting;
    CreditCardConstants.CONFIG_DEFAULT = configCCDefaultSetting;
    
    //Query result of Record Types
    List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND 
    SobjectType = 'Contact' 
    AND DeveloperName =: Constants.CONTACT_RECORD_TYPE_DEVELOPER_NAME_EMPLOYEE Limit 1];
    
    //assert statements
    System.assert(recordTypes != null);
    System.assertEquals(1, recordTypes.size());
    
    //List to hold Contact and insert contacts
    List<Contact> contacts = new List<Contact>();
    contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', RecordTypeId = recordTypes[0].Id, 
    Employee_Id__c = '1241', Legal_First_Name__c = 'Test1',
    Legal_Last_Name__c = 'Contact 1', Personal_Address_Line_1__c = 'Abc Street', 
    Personal_Address_Line_2__c = 'Test', Personal_Address_PostalCode__c = '32234', 
    Personal_Address_City__c = 'Dallas', Personal_Address_State__c = 'CA', 
    Employee_User_Record__c = userList[0].Id,Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855'));
    
    //Insert contact
    insert contacts;
    
    //Payment Account record
    List<Portfolio__c> payments = new List<Portfolio__c>();
    payments.add(new Portfolio__c(Status__c = Constants.ACTIVE, Card_Holder__c = contacts[0].Id, 
    Portfolio_Owner_Finance_Code__c = '678981'));
    insert payments;
    
    //Encrypt the card Number
    String encryptNumber1 = CreditCardService.Encrypt('5567356025410226');
    String encryptNumber2 = CreditCardService.Encrypt('5567356025410227');
    
    //Credit Card record   
    List<Credit_Card__c> cards = new List<Credit_Card__c>(); 
    cards.add(new Credit_Card__c(Card_Number__c = encryptNumber1, Status__c = CreditCardConstants.CC_STATUS_ACTIVE, 
    Payment_Account__c = payments[0].Id, 
    Card_Set_up_Status__c = CreditCardConstants.CC_SETUP_STATUS_SUCCESS, 
    Card_Requested_By__c = contacts[0].Id));
    insert cards;
    
    //Start Testing from here
    Test.startTest();
    
    //Initialize method number for deactivateCreditCard
    CreditCardServiceMockClass.methodNumber = 3;
    
    //Response of deactivateCreditCard request
    HttpService.response = mockController.respond(req);
    
    //Enable all the Triggers
    Util.BypassAllTriggers = false;
    
    //Deactivate the User record. This should trigger the OSR trigger and then Batch and user should be get deactivated
    //Run as user
    System.RunAs(new User(Id = UserInfo.getUserId())) {
    userList[0].IsActive = false;
    update userList;
    }
    
    //Stop testing here
    Test.stopTest();
    }
    */
    
    //Added By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
   /**
    * @description: Test method to check deactivateInactiveCommunityUsers methods based use cases and functionalities.
    **/
    static testmethod void testDeactivateInactiveCommunityUsers() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //User Instances
        User u1, u2, u3, sysAdmin;
        
        //add profile to the community profiles custom setting
        list<Profile> communityProfiles = [SELECT Id, Name FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
        
        //Asserting for the results
        System.assert(communityProfiles != null);
        System.assert(communityProfiles.size() > 0);
        
        //System Admin profile
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        System.assert(sysAdminProfile != null);
        
        //Community profile
        Community_Profiles__c cp  = new Community_Profiles__c(name='Community Profile 1',
                                                              Profile_Name__c = communityProfiles[0].Name);
        insert cp;
        
        
        //Asserting for the results
        System.assert(cp != null);
        
        User thisUser = [SELECT Id from User where Id = :UserInfo.getUserId()];
        
        //Run as current context user
        System.runAs (thisUser) {
            
            //create three contacts to associated with active users
            Contact c1 = TestUtilities.CreateNewContact(false);
            Contact c2 = TestUtilities.CreateNewContact(false);
            Contact c3 = TestUtilities.CreateNewContact(false);
            
            //List of contacts
            list<Contact> contacts = new list<Contact> { c1, c2, c3 };
                insert contacts;
            
            //create three active users with the community profile
            u1 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u2 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            u3 = TestUtilities.CreatenewUser(communityProfiles[0], false);
            sysAdmin = TestUtilities.CreatenewUser(sysAdminProfile, false);

            //Populating fields value on the user records            
            u1.FirstName = 'User1';
            u2.FirstName = 'User2';
            u3.FirstName = 'User3';
            u1.ContactId = c1.Id;
            u2.ContactId = c2.Id;
            u3.ContactId = c3.Id;
            u1.IsActive = true;
            u2.IsActive = true;
            u3.IsActive = true;
            
            //Inserting users
            list<User> users = new list<User> { u1, u2, u3, sysAdmin };
            /*insert users;
            
            //Create a project
            Project__c project = TestUtilities.CreateProject(true);
            List<RecordType> recordTypes = [Select Id from RecordType Where SobjectType = 'Case' AND IsActive = true
                                            AND DeveloperName ='SSC_Support'];
            //Create a case associated with the contact for u1 (ie: c1)
            Case aCase = new Case(Subject = 'testSubject',
                                  Status = '01-New',
                                  Tier_I_Support_Analyst__c = UserInfo.getUserId(),
                                  Priority = 'Low',
                                  Origin = 'Incoming Call',
                                  ContactId = c1.Id,
                                  Description = 'Test Description',
                                  RecordTypeId = recordTypes[0].Id, 
                                  Current_Results__c = 'test current results',
                                  Expected_Results__c = 'test expected results',
                                  Project_Source_MS__c = project.Id,
                                  Steps_to_Reproduce_MS__c = 'test steps to reproduce');
            insert aCase;
            
            //create a Project Role for c2
            Project_Role__c projectRole = new Project_Role__c(Project__c = project.Id, 
                                                              Contact__c = c2.Id, 
                                                              SIAM_Portal_Status__c = 'Active');
            insert projectRole;*/
        }
        /*
        //Executing as system admin user
        system.runAs(sysAdmin) {
        
        //Start test from here
        test.startTest();
        
        //Executing batch job
        Database.executeBatch(new Batch_DeactivateInactiveCommunityUsers());
        
        //Stop test here
        test.stopTest();
        }
        
        //get the users and see which ones are inactive
        list<User> users = [SELECT Id, ContactId, IsActive FROM User WHERE Id = :u1.Id OR Id = :u2.Id OR Id = :u3.Id];
        
        //Looping over users records and asserting for the results
        for (User u : users) {
        if (u.Id == u1.Id) system.assertEquals(true, u.IsActive);
        if (u.Id == u2.Id) system.assertEquals(true, u.IsActive);
        if (u.Id == u3.Id) system.assertEquals(false, u.IsActive);
        }*/
    }  
    
    //Added By - Abhinav Sharma - 06/14/2016 - CR-20150202-8649 - A Code Refactor CR
   /**
    * @description: Test method to check whether apex trigger is catching the exceptions properly or not.
    **/
    static testMethod void test_ExceptionBasedUseCases() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
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
        
        //Test starts from here
        Test.startTest();
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Insert users
        insert userList;
        
        //Disabling triggers
        Util.byPassAllTriggers = true;
        
        //Insert Account record
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        System.assert(acc != null);
        
        //Insert Program record
        List<Program__c> programs = new List<Program__c>();
        Program__c program = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                            Program_Acronym__c = 'ZZZ', Create_memberships__c = 'No', Business_line__c = 'PT');
        //Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426 - Program_Acronym__c = 'ZZZ' to 'ZZZ1'
        Program__c program1 = new Program__c(Name = 'Test Program', New_Business_Marketer__c = 'RI Marketer', 
                                             Program_Acronym__c = 'ZZZ1', Create_memberships__c = 'No', Business_line__c = 'PT');
        programs.add(program);
        programs.add(program1);
        insert programs;
        System.assert(programs != null);
        
        //Insert scope records
        List<Scope__c> scopes = new List<Scope__c>();
        scopes.add(new Scope__c(Name='test1', Active__c = true));
        insert scopes;
        
        //Insert Scope MtM records
        List<Scope_MtM__c> scopeMtMs = new List<Scope_MtM__c>();
        scopeMtMs.add(new Scope_MtM__c(Name = 'Test' , Program__c = programs[0].Id, Scope__c = scopes[0].Id ));
        insert scopeMtMs;
        
        //Getting Record Type Id Value for Opportunity
        List<RecordType> oppRecordTypes = [Select Id, Name FROM RecordType WHERE SobjectType = 'Opportunity' 
                                           AND IsActive = true
                                           AND DeveloperName = 'EAB_Initiating'];
        System.assert(oppRecordTypes != null);
        System.assert(oppRecordTypes.size() > 0);
        
        Contact con = TestUtilities.CreateNewContact(True);
        //Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
        //Insert Opportunity record
        Opportunity opportunity = new Opportunity(Name = 'Test Opp', RecordTypeId = oppRecordTypes[0].ID, 
                                                  StageName = CPQConstants.OPPORTUNITY_STAGE_EXPLORING, Amount = 100, CloseDate = System.today().addDays(32), 
                                                  AccountId = acc.Id, OwnerId = userList[0].Id,  Program__c = programs[0].Id,
                                                  CT_Assignment__c = userList[0].Id, CT_Pass_Status__c = 'Assigned',Main_Contact__c = con.Id, 
                                                  CT_Reneg_Attempt__c = 'No', Sales_Pursuit_Products__c = 'APS'/*, Scope_MtM__c = scopeMtMs[0].Id*/);
        
        insert opportunity;
        System.assert(opportunity != null);
        
        //Query to retrive "Owner Manager Email" field from Opportunity record
        List<Opportunity> oppList = [SELECT ID, Owner_Manager_Email__c, CT_Assignment_s_Manager__c FROM Opportunity 
                                     WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assertEquals(null, oppList[0].Owner_Manager_Email__c);
        System.assertEquals(null, oppList[0].CT_Assignment_s_Manager__c);
        
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[1].Id;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Uodating user
        update userList;
        
        Batch_OpportunityUpdateManagerEmail oppUpdateManagerBatch = new Batch_OpportunityUpdateManagerEmail(new set<Id> { userList[0].Id, userList[1].Id, userList[2].Id });
        database.executeBatch(oppUpdateManagerBatch, 1);
       
        Batch_OppUpdateCTAssManagerEmailData oppUpdateCTAsstManagerBatch = new Batch_OppUpdateCTAssManagerEmailData(new set<Id> { userList[0].Id, userList[1].Id, userList[2].Id });
        database.executeBatch(oppUpdateCTAsstManagerBatch, 1);
        
        //Test stops from here
        Test.stopTest();
         //Query to retrive "Owner Manager Email" field from Opportunity record
        oppList = [SELECT ID, Owner_Manager_Email__c FROM Opportunity WHERE Id=: opportunity.Id];
        
        //Assert for the result
        System.assert(oppList != null);
        System.assert(oppList.size()> 0);

        System.assertEquals('testuser2@test.com', oppList[0].Owner_Manager_Email__c);
        //Update first user Manager lookup to second user
        userList[0].ManagerId = userList[2].Id;
        update userList;
        
        //Enabling triggers
        Util.byPassAllTriggers = true;
        
        scopeMtMs[0].Program__c = programs[1].Id;
        update scopeMtMs;
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update first user Manager lookup back to first user
        userList[0].ManagerId = userList[1].Id;
        try {update userList;}
        catch(Exception ex) {}   
    }
    
    //Added by Colin McGloin - 08/08/2016 - CR-20160414-9762
    static testmethod void validateSteelbrickApproverAdded () {
        
        //Start Test
        Test.startTest();
        
        //Add a new User
        User test1 = new User();
        Profile aProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        test1.Alias = 'tUser';
        test1.Email = 'tUser@noreply.com';
        test1.EmailEncodingKey = 'UTF-8';
        test1.FirstName = 'The';
        test1.LastName = 'Batman';
        test1.ProfileId = aProfile.Id;
        test1.Username = 'tUser@noreply'+crypto.getRandomLong()+'.com';
        test1.TimeZoneSidKey = 'America/New_York';
        test1.LanguageLocaleKey = 'en_US';
        test1.LocaleSidKey = 'en_US';
        
        insert test1;
        
        //Stopping Test to test assertions on @future method
        Test.stopTest();
        
        //Query for the created Steelbrick record
        List<sbaa__Approver__c> approvers = [SELECT Id, Name, sbaa__User__c FROM sbaa__Approver__c 
                                             WHERE Name = 'The Batman'];
        
        //Check that an Approver record was found and the Approver resource matched the user entered
        if(approvers.size() > 0) {
            System.assertEquals(1, approvers.size());
            System.assertEquals(test1.Id, approvers[0].sbaa__User__c);
        }    
    }  
    
    //Added By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
    static testmethod void Test_updateRestrictionClearanceRequestRecords(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Query on Profile
        Profile prof = [select id from Profile Where Name = 'specialist' limit 1];
        
        //Create ist othold user records
        list<User> users = new list<User>();
        for (Integer i = 0; i < 2; i++) {
            String digit = String.valueOf(i);
            users.add(new User(
                alias = 'user' + digit, 
                email='standarduser@advisory.com', 
                emailencodingkey='UTF-8', 
                lastname='Testing ' + digit, 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = prof.id, 
                timezonesidkey='America/Los_Angeles', 
                username='testuser1971' + digit + '@advisory.com',
                IsActive = true
            ));
        }
        
        //Insert User records
        insert users;
        
        //List to hold Restrictions 
        List<Restrictions__c> rests = new List<Restrictions__c>();
        Date nextWeek = system.today().addDays(7);
        for (Integer i = 0; i < 4; i++) {
            rests.add(new Restrictions__c(
                Name = 'testrestriction',
                Expiration_Date__c = nextWeek,
                OwnerId = users[0].id));
        }
        
        //Insert Restrictions records
        insert rests;
        
        //Create Account record
        Account a = new Account(Name='Temp Name', Account_Formal_Name__c = '1', Primary_City__c = 'city', Primary_State_Province__c  = 'VA');
        insert a;
        
        //Create Contact record
        Contact con = new Contact(FirstName = 'Test 1', LastName = 'Contact test', AccountId = a.Id,Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855' );
        insert con;
        
        //Create Project record
        Program__c prog = new Program__c(Name = 'progname', Program_Acronym__c = 'TEST');
        insert prog;
        
        //Create Warm lead record
        Warm_Lead__c testwl = new Warm_Lead__c(Name = 'tempname', Lead_Date__c = system.today(), Account__c = a.id,  Primary_Program__c = prog.id,
                                               Grade__c = '1');
        //Insert WarmLead
        insert testwl;
        
        // Create a test RCR
        List<Restriction_Clearance_Request__c> RCRs = new List<Restriction_Clearance_Request__c>();
        
        //Add records in list
        Restriction_Clearance_Request__c rcr1 = new Restriction_Clearance_Request__c(Restriction__c = rests[0].id, Warm_Lead__c = testwl.Id,Restriction_Owner_2__c = users[1].Id,
                                                                                     DateLastMarketingOutreachtoContact__c = Date.Today(), Marketer__c = users[0].Id,
                                                                                     Program__c = prog.Id, Contact__c = con.Id, Type_of_Interaction_Requested__c = 'Other', 
                                                                                     Clearance_Request_Comments__c = 'Tersting 1');
        RCRs.add(rcr1);
        Restriction_Clearance_Request__c rcr2 = new Restriction_Clearance_Request__c(Restriction__c = rests[1].id, Restriction_Owner_2__c = users[0].Id,
                                                                                     DateLastMarketingOutreachtoContact__c = Date.Today(), Marketer__c = users[0].Id,
                                                                                     Program__c = prog.Id, Contact__c = con.Id, Type_of_Interaction_Requested__c = 'Other', 
                                                                                     Clearance_Request_Comments__c = 'Tersting 2');
        RCRs.add(rcr2);
        
        // Insert test RCR
        insert(RCRs);
        
        List<Restriction_Clearance_Request__c> rCR3 = [Select Id, Contact_Institution__c, Type_of_Interaction_Requested__c From Restriction_Clearance_Request__c Where Id =: rcr1.Id];
        
        //Start method here
        test.startTest();
        
        //Update user record value
        users[0].FirstName = 'TestingPOC1';
        users[0].LastName = 'Demo2';
        
        //By pass trigger
        Util.byPassAllTriggers = false;
        
        //Update user record
        update users[0];
        
        //Query over RCR record to get updated values
        List<Restriction_Clearance_Request__c> RCRs2 = [Select Id,name, Contact_Institution__c, Type_of_Interaction_Requested__c from Restriction_Clearance_Request__c Where Id =: rcr1.Id];
        
        //Asserr for result
        System.assertEquals(rCR3[0].Contact_Institution__c + '-' + prog.Program_Acronym__c + '-' + rCR3[0].Type_of_Interaction_Requested__c + '-' + users[0].FirstName + ' ' + users[0].LastName, RCRs2[0].Name);
        
        //test method stop here 
        test.stopTest();
    }
    
   /**  Description    :  The method is used to test updateMembershipRecordsFieldsValues
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  06/26/2017
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    static testMethod void testupdateMembershipRecordsFieldsValues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        List<Profile> profiles = [Select Id From Profile where Name = 'Specialist' LIMIT 1];
        
        //Inserting user records
        User user = TestUtilities.CreatenewUser(profiles[0], true);
        System.assertNotEquals(null, user.Id);
        
        //Start testing from here
        Test.startTest();
        
        //Execute the trigger
        Util.byPassAllTriggers = false;
        
        //List to hold membership records
        List<Membership__c> memberships = new List<Membership__c>();
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, false);
        membership.BA_Assignment2__c = user.Id;
        insert membership;
        
        //Updating user record
        user.FirstName = 'Test1';
        update user;
        
        membership = TestUtilities.CreateNewMembership(account.Id, program.Id, false);
        membership.DA_Assignment2__c = user.Id;
        insert membership;
        
        //Updating user record
        user.LastName = 'Test2';
        update user;
        
        //Stop testing here
        Test.stopTest();
    }
    
   /**  Description   :  The method is used to test updateProjectRecordsFieldsValues
    *
    *  Created  By   :  Saurabh Kumar
    *
    *  Created By    :  06/26/2017
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *			V1.1 Comment out by - Rajeev Jain CR-20200318-13865 - 09/09/2020
    *
    **/
    static testMethod void testUpdateProjectRecordsFieldsValues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        List<Profile> profiles = [Select id From Profile Where Name = 'Specialist' LIMIT 1];
        
        //Inserting user records
        User user = TestUtilities.CreatenewUser(profiles[0], true);
        System.assertNotEquals(null, user.Id);
        
        //List to hold project record
        List<Project__c> projects = new List<Project__c>();
        
        //Creating Project record
        Project__c project = TestUtilities.createProject(false);
	// Comment out for - CR-20200318-13865
	//project.Implementation_Business_Analyst__c = user.Id;
        projects.add(project);
        
        project = TestUtilities.createProject(false);
        // project.Implementation_Business_Analyst__c = user.Id;
        //project.Primary_Owner__c = 'Alias';
        projects.add(project);
        
        insert projects;
        
        //Start testing from here
        Test.startTest();
        
        //Execute the trigger
        Util.byPassAllTriggers = false;
        
        //Updating user record
        user.Alias = 'Alias';
        update user;
        
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //List<Project__c> updatedProjects = [Select Id/*, Primary_Owner__c*/ From Project__c /*Order By Primary_Owner__c*/];
        
        //Assertions
        //System.assert(updatedProjects != null);
        //System.assertEquals(null,updatedProjects[0].Primary_Owner__c);
        //System.assertEquals('Alias',updatedProjects[1].Primary_Owner__c);*/
        
        //Stop testing here
        Test.stopTest();
        
    }
    
   /**  Description    :  The method is used to test updateSubscriptionRecordsFieldsValues
    *
    *  Created  By    :  Saurabh Kumar
    *
    *  Created By    :  06/26/2017
    *
    *  Revision Log  :  V1.0_Created - Q2C Redesign - Beta Release
    *
    **/
    static testMethod void testUpdateSubscriptionRecordsFieldsValues(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Inserting user records
        //User user = TestUtilities.CreatenewUser(true);
        //System.assertNotEquals(null, user.Id);
        
        //Query on the profile
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.assert(profiles != null);
        
        User user = new User(Alias = 'tUser', Email = 'tUser@noreply.com', EmailEncodingKey = 'UTF-8', FirstName = 'The', LastName = 'Batman',ProfileId = profiles[0].Id, 
                             Username = 'tUser@noreply'+crypto.getRandomLong()+'.com', TimeZoneSidKey = 'America/New_York', LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US');
        
        insert user;
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);
        
        //Creating program record
        Program__c program = TestUtilities.CreateNewProgram(true);
        
        //Creating Membership records
        Membership__c membership = TestUtilities.CreateNewMembership(account.Id, program.Id, true);
        
        Opportunity opportunity = new Opportunity();
        
        //Change user context
        System.runAs(user){
            
            opportunity = TestUtilities.CreateNewOpportunity(true);
            System.assertNotEquals(null,opportunity.Id);
        }
        
        //Creating Congtract ABC record
        Contract__c contractABC = TestUtilities.CreateNewContract(false);
        contractABC.Contract_Renewal_Opportunity__c = opportunity.Id;
        insert contractABC;
        
        //Creating Subscription record
        SBQQ__Subscription__c subscription = TestUtilities.createNewSubscription(membership.Id, false);
        subscription.Renewal_Opportunity__c = opportunity.Id;
        insert subscription;
        
        //Start tesing from here
        Test.startTest();     
        
        //Execute trigger
        Util.byPassAllTriggers = false;
        
        //Updating user record
        user.FirstName = 'Testing';
        update user;
        
        //Stop testing here
        Test.stopTest();
    }
    
    /**  Description    :  The method is used to test deactivateStaffAssignmentForInactiveUsers
     *
     *  Created  By    :  Subhash Garhwal
     *
     *  Created By    :  01/30/2018
     *
     *  Revision Log  :  V1.0_Created -CR-20180126-11902
     *
    **/
    
    testMethod static void deactivateStaffAssignmentForInactiveUsersTest() {
        
        List<Profile> profiles = [Select Id From Profile Where Name =  'Specialist' LIMIT 1 ];
        
        //Creating the User
        User user = TestUtilities.CreatenewUser(profiles[0], true);
        System.assertNotEquals(null, user.Id);
        
        //Inserting the Account
        Account account = new Account(Name = 'Test11');
        insert account;
        
        //Create a Contact
        List<Contact> contacts = new List<Contact>();
        
        //Get the employee Record Type     
        Id EmpContRecordType = [SELECT Id, Name from RecordType WHERE Name = 'Employee' and SobjectType = 'Contact'].id;
        
        //List of contact
        contacts.add(new Contact(FirstName = 'TestContact1', LastName = 'Contact1',  RecordTypeId = EmpContRecordType,  Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855', AccountId = account.Id, Employee_User_Record__c = user.Id)); 
        
        Util.ByPassAllTriggers = true;  
        
        //Insert Contact
        insert contacts;
        
        Util.ByPassAllTriggers = false;
        
        //Start testing from here
        Test.startTest();
        
        //Inserting the Team Role
        Team_Role__c teamRole2 = new Team_Role__c(Name = 'UniqueName2', Institution__c = true, Active__c =  true);
        insert teamRole2;
        
        //Record Types
        List<RecordType> recordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        AND IsActive = true 
                                        AND DeveloperName = 'Assigned'];    
        
        //Team Membership
        Team_Membership__c teamMembership = new Team_Membership__c(Name = 'Test1', Employee__c = user.Id, Staff_member__c = contacts[0].id, 
                                                                   Institution__c = account.Id, Role__c = teamRole2.Id, 
                                                                   Start_date__c = Date.today()-5,
                                                                   RecordTypeId = recordTypes[0].Id);   
        insert teamMembership;
        
        
        //List to hold the Team Membership
        List<Team_Membership__c> staffAssignmentsToUpdate = [SELECT Id, End_Date__c, Staff_member__r.Employee_User_Record__c FROM Team_Membership__c];
        
        
        System.assertEquals(user.Id, staffAssignmentsToUpdate[0].Staff_member__r.Employee_User_Record__c);
        System.assertEquals(null, staffAssignmentsToUpdate[0].End_Date__c);
        
        //List to hold the users 
        List<User> users = [Select Id From User where Id =: UserInfo.getUserId() ];
        
        /*System.runAs(users[0]){

        //Deactivatting the User
        user.IsActive = false;
        update user;
        }
        
        //List to hold the Team Membership
        List<Team_Membership__c> staffAssignmentsToUpdate1 = [SELECT Id, End_Date__c, Staff_member__r.Employee_User_Record__c FROM Team_Membership__c];
        System.assertEquals(Date.Today() , staffAssignmentsToUpdate1[0].End_Date__c);
        */
        Test.stopTest();
    } 
    
    /**  Description      :  The method is used to test setContractTypeFree
	 *
	 *  Created  By   : Rajeev Jain
	 *
	 *  Created By    :  02/05/2019
	 *
	 *  Revision Log  :  V1.0_Created Rajeev Jain - CR-20190123-12845 - 02/05/2019 
	 * 		  :  V1.1 Modified By - Rajeev Jain - CR-20200714-14300
	 *
    **/
    
    testMethod static void testsetContractType() {
        
        // Set Contains All Profiles of Org
        Set<String> orgProfileNames = new Set<String>{'API Only','Boardroom - App Subscription User','Delivery - App Subscription','Force.com - App Subscription User','Royall - App Subscription User','Syndicated - General Research - App Subscription','ABC Dataloader','ABC DataReader - Restricted','Account Management','Analyst','Delivery Business Analyst - Restricted','Drift Sync - Restricted','Finance Ops','FinancialForce AR Operations','FinancialForce Controller - Restricted','FinancialForce Read Only - Restricted','FinancialForce Royall - Restricted','Gainsight API Only - Restricted','Integration - API Only Restricted','Leadership','Legal','Marketers','Marketing Associates','Marketing Manager','Marketing User','Marketo-Salesforce Sync','Member Response','Minimum Access - Salesforce','NPD - Restricted','Product Marketing Manager','Read Only','RoyallAPI - Restricted','Solution Manager','Specialist','Standard Contract Manager','Standard User','Strategic Marketing Ops','System Administrator','Delivery - Platform','Delivery Business Analyst - Platform','Standard Platform User'};
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile
                                     where Name IN: orgProfileNames ORDER BY Name ASC];
        
        //Assert for results
        System.assert(testProfile != null);
        System.assert(testProfile.size()>0);
        
        //Test User Create
        List<User> userList = new List<User>();
        
        //Adding user record instances into the list
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User101', FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121210', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User201', FirstName='Test2', Email='testuser2@test.com',
                              Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[1].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121211', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User301', FirstName='Test3', Email='testuser3@test.com',
                              Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[4].Id,
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232412', IsActive = true)); 
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User401', FirstName='Test4', Email='testuser4@test.com',
                              Alias='Test4', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[5].Id,
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232413', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User501', FirstName='Test5', Email='testuser5@test.com',
                              Alias='Test5', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[7].Id,
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121232414', IsActive = true));
        
        //Test starts from here
        Test.startTest();
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
        
        //Insert users
        insert userList;
        
        //Get user records
        List<User> updatedUsers = [Select Id, LastName, Profile.Name, Contract_Type__c from User Where Id IN: userList AND Profile.Name != Null Order By Name ASC Limit 5];
        System.assert(updatedUsers.size() == 5);
        
        System.assertEquals(updatedUsers[0].Contract_Type__c,System.Label.Contract_Type_Full);
        System.assertEquals(updatedUsers[1].Contract_Type__c,System.Label.Contract_Type_Restricted);
        System.assertEquals(updatedUsers[2].Contract_Type__c,System.Label.Contract_Type_App_Subscription);
        System.assertEquals(updatedUsers[3].Contract_Type__c,System.Label.Contract_Type_App_Subscription_Restricted);
        System.assertEquals(updatedUsers[4].Contract_Type__c,System.Label.Contract_Type_Platform);
		
        Test.stopTest();
        }
    
    /**  Description    :  The method is used to test updateOwnerManagerEmailOnOpportunities
	 *
	 *  Created  By    :  Dipesh Gupta
	 *
	 *  Created By    :  12/12/2019
	 *
	 *  Revision Log  : 
	 *
	**/
    
    testMethod static void updateOwnerManagerEmailOnOpportunitiesTest() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        User u1 = TestUtilities.CreatenewUser(false);
        u1.IsActive = true;
        insert u1;
        
        User u2 = TestUtilities.CreatenewUser(false);
        u2.IsActive = true;
        insert u2;
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.OwnerId = u1.Id;
        
        insert opp ;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        u1.ManagerId = u2.Id;
        if(u1 != null)
            update u1;
        Test.stopTest();
        User u = [SELECT ManagerId FROM User WHERE Id =: u1.Id LIMIT 1];
        System.assertEquals(u2.Id, u.ManagerId);
        
    }
    
    /**  Description    :  The method is used to test updateCTAssignmentManagerEmailOnOpportunities
	 *
	 *  Created  By    :  Dipesh Gupta
	 *
	 *  Created By    :  12/12/2019
	 *
	 *  Revision Log  : 
	 *
	**/
    
    testMethod static void updateCTAssignmentManagerEmailOnOpportunitiesTest() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        User u1 = TestUtilities.CreatenewUser(false);
        u1.IsActive = true;
        insert u1;
        
        User u2 = TestUtilities.CreatenewUser(false);
        u2.IsActive = true;
        insert u2;
        
        
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.OwnerId = u1.Id;
        insert opp ;
        
        //Bypassing Triggers
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        u1.ManagerId = u2.Id;
        if(u1 != null)
            update u1;
        Test.stopTest();
        User u = [SELECT ManagerId FROM User WHERE Id =: u1.Id LIMIT 1];
        System.assertEquals(u2.Id, u.ManagerId);
        
    }
    
    //Added by - Chirag soni - CR-20210910-15426 - 10/29/2021 - Code coverage increase.
    static testmethod void testUpdateAccountFieldVendorInvoiceOwner(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        List<User> managerUserIds = new List<User>();
        
        User manager1 = TestUtilities.CreatenewUser(false);
        manager1.IsActive = true;
        managerUserIds.add(manager1);
        
        User manager2 = TestUtilities.CreatenewUser(false);
        manager2.IsActive = true;
        managerUserIds.add(manager2);
        
        // Insert manager users 
        insert managerUserIds;
        
        List<User> activeUsers = new List<User>();
        
        User u1 = TestUtilities.CreatenewUser(false);
        u1.IsActive = true;
        u1.ManagerId = managerUserIds[0].Id;
        
        activeUsers.add(u1);
        
        User u2 = TestUtilities.CreatenewUser(false);
        u2.IsActive = true;
        u2.ManagerId = managerUserIds[1].Id;
        
        activeUsers.add(u2);
        
        insert activeUsers;
          
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(Name = 'Test Account 1', Vendor_Invoice_Owner__c = activeUsers[0].Id));
        accounts.add(new Account(Name = 'Test Account 2', Vendor_Invoice_Owner__c = activeUsers[1].Id));
        
        //Insert Accounts record
        insert accounts;
            
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        
        System.runAs(managerUserIds[0]){
            
            List<User> usersTobeUpdate = [SELECT Id, IsActive FROM User WHERE Id IN :activeUsers];
            
            usersTobeUpdate[0].IsActive = false;
            usersTobeUpdate[1].IsActive = false;
            
            update usersTobeUpdate;
        }
        
        Test.stopTest();
        
        accounts = [SELECT Id, Vendor_Invoice_Owner__c FROM Account WHERE Id IN :accounts];
        
        // Assert to check whether Vendor_Invoice_Owner__c  are update to manager user or not 
        System.assertEquals(managerUserIds[0].Id, accounts[0].Vendor_Invoice_Owner__c);
        System.assertEquals(managerUserIds[1].Id, accounts[1].Vendor_Invoice_Owner__c);
      
    }
    
    //Added By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
    static testMethod void test_populateUserSlackId_InsertCase() 
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
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
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
                
        //Insert users
        insert userList;
        
        //Test starts from here
        Test.startTest();
        
        String mockBody = '{"ok": true,"user": {"id": "W012A3CDE","team_id": "T012AB3C4","name": "Test",'+
            '"deleted": false,"color": "9f69e7","real_name": "Test User1","tz": "America/Los_Angeles",'+
            '"tz_label": "Pacific Daylight Time","tz_offset": -25200,"profile": {"avatar_hash": "ge3b51ca72de",'+
            '"status_text": "Print is dead","status_emoji": ":books:","real_name": "Test User1",'+
            '"display_name": "Test","real_name_normalized": "Test User1","display_name_normalized": "Test",'+
            '"email": "testuser1@test.com","image_24": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
            '"image_32": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","image_48": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
            '"image_72": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","image_192": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg",'+
            '"image_512": "https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg","team": "T012AB3C4"},'+
            '"is_admin": true,"is_owner": false,"is_primary_owner": false,"is_restricted": false,"is_ultra_restricted": false,'+
            '"is_bot": false,"updated": 1502138686,"is_app_user": false,"has_2fa": false}}';
        
        SlackResponseWrapper slackResposeWrap = (SlackResponseWrapper)JSON.deserialize(mockBody, SlackResponseWrapper.class);
        Boolean slackRspOk = slackResposeWrap.ok;
        SlackResponseWrapper.UserWrapper userDetl = slackResposeWrap.user;
        String id  = userDetl.Id;
        String team_id = userDetl.team_id;
        String name = userDetl.name;
        boolean deleted = userDetl.deleted;
        String color = userDetl.color;
        String real_name = userDetl.real_name;
        String tz = userDetl.tz;
        String tz_label = userDetl.tz_label;
        Integer tz_offset = userDetl.tz_offset;
        boolean is_admin = userDetl.is_admin;
        boolean is_owner = userDetl.is_owner;
        boolean is_primary_owner = userDetl.is_primary_owner;
        boolean is_restricted = userDetl.is_restricted;
        boolean is_ultra_restricted = userDetl.is_ultra_restricted;
        boolean is_bot = userDetl.is_bot;
        Integer updated = userDetl.updated;
        boolean is_app_user = userDetl.is_app_user;
        boolean has_2fa = userDetl.has_2fa;
        
        SlackResponseWrapper.UserProfileWrapper userProfWrap = userDetl.profile;
        String avatar_hash = userProfWrap.avatar_hash;
        String status_text = userProfWrap.status_text;
        String status_emoji = userProfWrap.status_emoji;
        String real_name1 = userProfWrap.real_name;
        String display_name = userProfWrap.display_name;
        String real_name_normalized = userProfWrap.real_name_normalized;
        String display_name_normalized = userProfWrap.display_name_normalized;
        String email = userProfWrap.email;
        String image_24 = userProfWrap.image_24;
        String image_32 = userProfWrap.image_32;
        String image_48 = userProfWrap.image_48;
        String image_72 = userProfWrap.image_72;
        String image_192 = userProfWrap.image_192;
        String image_512 = userProfWrap.image_512;
        String team = userProfWrap.team;
        
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGeneratorForSlackDetails());
        map<Id, String> mapOfUserIdWithEmail = new map<Id, String>();
        mapOfUserIdWithEmail.put(userList[0].Id, userList[0].Email);
        mapOfUserIdWithEmail.put(userList[1].Id, userList[1].Email);
        mapOfUserIdWithEmail.put(userList[2].Id, userList[2].Email);
        
        UserTriggerHelper.getSlackUserIdFromSlack(mapOfUserIdWithEmail);
        
        //Test starts from here
        Test.stopTest();
        
        userList = [Select Id, Slack_Id__c From User Where Id =: userList];
        System.assertEquals(true, String.isNotBlank(userList[0].Slack_Id__c));
        System.assertEquals('W012A3CDE', userList[0].Slack_Id__c);
        System.assertEquals('W012A3CDE', userList[1].Slack_Id__c);
        System.assertEquals('W012A3CDE', userList[2].Slack_Id__c);
                
     }
    
    
    //Added By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
    static testMethod void test_populateUserSlackId_UpdateCase() 
    {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
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
            
        //Insert users
        insert userList;
        
        //Enable triggers again
        Util.byPassAllTriggers = false;
            
        userList[0].Slack_Id__c = 'TestSlackId';
        userList[1].Slack_Id__c = 'TestSlackId';
        userList[2].Slack_Id__c = 'TestSlackId';
        
        //update users
        Update userList;
        
        //Test starts from here
        Test.startTest();
        
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGeneratorForSlackDetails());
        map<Id, String> mapOfUserIdWithEmail = new map<Id, String>();
        mapOfUserIdWithEmail.put(userList[0].Id, userList[0].Email);
        mapOfUserIdWithEmail.put(userList[1].Id, userList[1].Email);
        mapOfUserIdWithEmail.put(userList[2].Id, userList[2].Email);
        
        UserTriggerHelper.getSlackUserIdFromSlack(mapOfUserIdWithEmail);
        
        //Test starts from here
        Test.stopTest();
        
        userList = [Select Id,Slack_Id__c From User Where Id IN: userList];  
        System.assertEquals('W012A3CDE', userList[0].Slack_Id__c);
        System.assertEquals('W012A3CDE', userList[1].Slack_Id__c);
        System.assertEquals('W012A3CDE', userList[2].Slack_Id__c);
        
     }
}