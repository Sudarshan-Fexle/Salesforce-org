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
private class Test_NBBTriggerHelper {
/**
 *  Purpose     :   Test class for NBBTriggerHelper.
 *               
 *  Create By   :   Bhavi
 *   
 *  Created Date:   11/16/2013
 *   
 *  Revision Log:   V1.1 - Created
 *                  v1.2 - (SUNJ) Update Proposal_Value__c with Amount
                    v1.3 - Added New Test Method(testCreateNBBRecords) - Ajit Surana - 03/1/2014 - CR-20140201-4430
                    v1.4 - Method (testCreateNBBRecords) modified by Ajit Surana - 07/08/2014 - CR-20131212-4143 - Removed reference for field "zzzProposal Value"
                    V1.5 - Modified By - Mahendra Swarnkar - 05/14/2015 - CR-20150416-8891 - Modify method (testPopulateSharingOnNBB)
                    V1.6 - Modify By - Subhash garhwal - 08/21/2015 - CR-20150820-9169 - Update Staff Assignments Start and End date to avoid overlapping.
                    V1.7 - Modified by Colin McGloin - 10/02/15 - CR-20150925-9270 - This CR Fix required a change to the Test Class to populate Staff_Member__c on Team Membership before inserting NBB records
                    V1.8 - Modified By Mahendra Swarnkar - 02/11/2015 - CR-20151028-9361
                    V1.9 - Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 
 *                  V2.0 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
 *  Coverage    :   97%
 **/
    
    //Test method for testing populateSharingOnNBB method of Trigger
    static testMethod void testPopulateSharingOnNBB(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER3', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER4', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test4', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER5', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test4', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        //insert users
        insert users;
        
        //List to hold Accounts record to be insert
        List<Account> accounts = new List<Account>();
        
        //List to hold Contact record to be inserted
        List<Contact> contacts = new List <Contact>();
        
        //Looping for creating differt test Accounts
        for(Integer i = 1; i <= 3; i++) {
            
            //populate list of Accounts    
            accounts.add(new Account(Name = 'Test Case Account '+ i));
        }
        
        //insert Accounts
        insert accounts;
        
        //Get the employee Record Type     
        Id EmpContRecordType = [SELECT Id, Name from RecordType WHERE Name = 'Employee' and SobjectType = 'Contact'].id;
        
        //Insert new Contact record
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact', Account = accounts[0], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[0].id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact', Account = accounts[1], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[1].id));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact', Account = accounts[2], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[2].id));
        contacts.add(new Contact(FirstName = 'Test4', LastName = 'Contact', Account = accounts[2], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[3].id));
        
        insert contacts;
        
        //Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 - remove Incentivized__c field deom Team role records
        //Updated by Mahendra Swarnkar -05/14/2015 - CR-20150416-8891
        //Starts from here
        
        //Insert Staff Roll 
        Team_Role__c staffRole = new Team_Role__c(Active__c =  true, Name = 'Test Staff Role', 
                                                  Institution__c = true);
        insert staffRole;
        Team_Role__c staffRole2 = new Team_Role__c(Active__c =  true, Name = 'Test Staff Role2',
                                                  Institution__c = true);
        insert staffRole2;
        
        //List to hold Staff Assignments to be insert 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Updated By - Subhash Garhwal - CR-20150820-9169 - Change Start Dates to avoid overlapping
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Populate staffAssignments
        staffAssignments.add(new Team_Membership__c(Name = 'testSA1', Institution__c = accounts[0].Id , 
                                                    Employee__c = users[1].Id, Staff_member__c = Contacts[1].id, 
                                                    Role__c = staffRole.Id, Start_date__c = system.today(),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'testSA2', Institution__c = accounts[1].Id , 
                                                    Employee__c = users[2].Id, Staff_member__c = Contacts[2].id, 
                                                    Role__c = staffRole.Id, Start_date__c = system.today().addDays(1),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'testSA3', Institution__c = accounts[0].Id , 
                                                    Employee__c = users[3].Id, Staff_member__c = Contacts[3].id, 
                                                    Role__c = staffRole2.Id, Start_date__c = system.today().addDays(2),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert Staff Assignment
        insert staffAssignments;
        
        //List to hold Configuration Manager custom setting records
        List<Configuration_Manager__c> configManagers = new List<Configuration_Manager__c>();
        configManagers.add(new Configuration_Manager__c(Name = 'test1', Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '% RM'));
        configManagers.add(new Configuration_Manager__c(Name = 'test2',  Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '%AE or EA%'));
        
        //Insert configuration Manager custom setting records 
        insert configManagers;
        
        //Ends here
        
        //List to hold Account Team Member to be insert 
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        
        //Loop through Accounts list for ATMs
        for(Account account : accounts) {
            
            accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = account.Id, TeamMemberRole = 'Research & Insights - RM'));
            accountTeamMembers.add(new AccountTeamMember(UserId = users[1].Id, AccountId = account.Id, TeamMemberRole = 'AE or EA'));
        }
        
        //insert Account Team Members
        insert accountTeamMembers;
        
        //List to hold Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Loop through Accounts list for Opportunity
        for(Account account : accounts) {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
          opportunities.add(new Opportunity(Name='Test Opp', Main_Contact__c = contacts[0].Id, StageName = '0-Exploring', Amount = 1, CloseDate = System.today().addDays(32), 
                                            AccountId = account.Id, Sales_Pursuit_Products__c = 'APS'));
        }
        
        //Insert Opportunities
        insert opportunities;
        
        //List to hold NBB test records
        List<NBB__c> nBBs = new List<NBB__c>();
        
        //Loop through Opportunity List
        for(Opportunity opportunity : opportunities) {
            
            nBBs.add(new NBB__c(Opportunity__c = opportunity.Id, OwnerId = Userinfo.getUserId(), Name = 'test', NBB_Type__c = 'Base Fee', 
                                    NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today()));
        }
        
        //Test starts here
        Test.startTest();
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //insert nBBs here
        insert nBBs;
        
        //Query result of NBB Share records
        List<NBB__Share> nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                                        WHERE ParentId IN: nBBs 
                                        AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(8, nBBShares.size());
        System.assertEquals(users[0].Id ,nBBShares[0].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[1].UserOrGroupId);
        System.assertEquals(users[3].Id ,nBBShares[2].UserOrGroupId);
        System.assertEquals(users[0].Id ,nBBShares[3].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[4].UserOrGroupId);
        System.assertEquals(users[2].Id ,nBBShares[5].UserOrGroupId);
        System.assertEquals(users[0].Id ,nBBShares[6].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[7].UserOrGroupId);
        
        //Disbaling triggers
        Util.BypassAllTriggers = true;
        
        //Update staffRole
        //Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576 
        //staffRole.Incentivized__c = false;
        update staffRole;
    
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Blank update NBBs
        update nBBs;
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                     WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(8, nBBShares.size());
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                       WHERE ParentId =: nBBs[2].Id AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(2, nBBShares.size());
        System.assertEquals(users[0].Id ,nBBShares[0].UserOrGroupId);
        
        //Disbling all the triggers
        Util.BypassAllTriggers = true;
        
        //Update staffAssignment stamped user
        staffAssignments[1].Employee__c = users[0].Id;
        update staffAssignments;
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Blank update NBBs
        update nBBs;
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                       WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(8, nBBShares.size());
        
        //Enables all the triggers
        Util.BypassAllTriggers = true;
        
        //Modified By - Mahendra Swarnakar - 10/21/2016 - CR-20160202-9576
        //Update staffRole
        //staffRole.Incentivized__c = true;
        update staffRole;
        
        //Update staffAssignment stamped user
        staffAssignments[1].Employee__c = users[2].Id;
        update staffAssignments;
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Blank update NBBs
        update nBBs;
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, ParentId, UserOrGroupId FROM NBB__Share 
                       WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(8, nBBShares.size());
        System.assertEquals(nBBs[1].Id ,nBBShares[4].ParentId);
        System.assertEquals(users[1].Id ,nBBShares[4].UserOrGroupId);
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId, ParentId FROM NBB__Share 
                       WHERE ParentId =: nBBs[1].Id AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(3, nBBShares.size());
        System.assertEquals(users[0].Id ,nBBShares[0].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[1].UserOrGroupId);
        System.assertEquals(users[2].Id ,nBBShares[2].UserOrGroupId);
        
        //Test stops here   
        Test.stopTest();
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //List of NBB Share reocrds to be insert
        List<NBB__Share> nBBSharesToInsert = new List<NBB__Share>();
        
        //Loop through NBBs list
        for(NBB__c nBB : nBBs) {
            
            //add into list to be insert
            nBBSharesToInsert.add(new NBB__Share(ParentId = nBB.Id, AccessLevel = 'Read', UserOrGroupId = users[0].Id,
                                            RowCause = Schema.NBB__Share.RowCause.Manual));
        }
        
        insert nBBSharesToInsert;
        
        //Disabling triggers
        Util.BypassAllTriggers = true;
        
        //Query results of ATMs
        accountTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'AE or EA'];
        
        //Loop through ATMs to update
        for(AccountTeamMember aTM : accountTeamMembers) {
            aTM.TeamMemberRole = 'Research & Insights - Marketer';
        }       
        
        //Update ATMs
        update accountTeamMembers;
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Blank update NBBs
        update nBBs;
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                       WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(6, nBBShares.size());
        system.assertEquals(users[0].Id , nBBShares[0].UserOrGroupId );
        system.assertEquals(users[1].Id , nBBShares[1].UserOrGroupId );
        system.assertEquals(users[3].Id , nBBShares[2].UserOrGroupId );
        system.assertEquals(users[0].Id , nBBShares[3].UserOrGroupId );
        system.assertEquals(users[2].Id , nBBShares[4].UserOrGroupId );
        system.assertEquals(users[0].Id , nBBShares[5].UserOrGroupId );
        
        //Disabling triggers
        Util.BypassAllTriggers = true;
        
        //Delete staff Assignments
        delete staffAssignments;
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Blank update NBBs
        update nBBs;
        
        //Query result of NBB Share records
        nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                       WHERE ParentId IN: nBBs AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(3, nBBShares.size());
        system.assertEquals(users[0].Id , nBBShares[1].UserOrGroupId);
    }
    
    //Method modified by Ajit Surana - 07/08/2014 - CR-20131212-4143 - Removed reference for field "zzzProposal Value"
    //Added By Ajit Surana - 03/1/2014 - CR-20140201-4430
    //Test method to create NBB records even if the Opp's related Institution has an inactive user 
    //listed as an Institution Team Member.
    static testMethod void testCreateNBBRecords() {
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Get profile list
        List<Profile> testProfile = [Select Id, Name from Profile 
                                     	where Name = 'Account Management'];
        
        //Assert for results
        System.assert(testProfile.size()>0);
                
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        
        //insert users
        insert users;
        
        //List to hold Configuration Manager custom setting records
        List<Configuration_Manager__c> configManagers = new List<Configuration_Manager__c>();
        configManagers.add(new Configuration_Manager__c(Name = 'test1', Parameter_Key__c = 'TeamMemberRoleForNBBSharing', 
                                                        Parameter_Value__c = '% RM'));
        configManagers.add(new Configuration_Manager__c(Name = 'test2',  Parameter_Key__c = 'TeamMemberRoleForNBBSharing', 
                                                        Parameter_Value__c = '%AE or EA%'));
        
        //Insert configuration Manager custom setting records 
        insert configManagers;
        
        //Insert Account
        Account testAccount = new Account(Name = 'Test-Account');
        insert testAccount;
        
        //List to hold Account Team Member to be insert 
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        
        accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = testAccount.Id, 
                                                     TeamMemberRole = 'Research & Insights - RM'));
        accountTeamMembers.add(new AccountTeamMember(UserId = users[1].Id, AccountId = testAccount.Id, 
                                                     TeamMemberRole = 'AE or EA'));
        
        //insert Account Team Members
        insert accountTeamMembers;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta
        
        //Getting Record Type Id Value for Opportunity
        ID oppRecordTypeId = [Select Id, Name FROM RecordType 
                              WHERE SobjectType = 'Opportunity' 
                              and Name = 'EAB Initiating'/*'RI AM Standard Opp'*/].Id;
        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Insert Opportunity
        Opportunity testOpportunity = new Opportunity(Name = 'Test', Main_Contact__c = cont.Id,RecordTypeId = oppRecordTypeId, AccountId = testAccount.Id,
                                                      StageName = 'Pending', CloseDate = System.today().addDays(32),
                                                      Amount = 100, Sales_Pursuit_Products__c = 'APS');
        insert testOpportunity;
        
        //Enable triggers again
        Util.BypassAllTriggers = false;
        
        //Insert NBB Record
        NBB__c testNBBRecord = new NBB__c(Name = 'test', Opportunity__c = testOpportunity.Id, OwnerId = Userinfo.getUserId(),
                                          Status__c = 'ATL', NBB__c = 10, Unit__c = 5, Binder_Date__c = system.today(),
                                          NA_Date__c = system.today());
        
        //Test starts here
        Test.startTest();
        
        //insert nBBs here
        insert testNBBRecord;
        
        //Query result of NBB Share records
        List<NBB__Share> nBBShares = [SELECT Id FROM NBB__Share WHERE ParentId =: testNBBRecord.Id 
                                      	AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(2, nBBShares.size());
        
        //Run as Current Login User
        System.runAs(new User(Id = UserInfo.getUserId())) {
        
            //Inactive one user
            users[0].IsActive = false;
            Util.BypassAllTriggers = true;
            update users;
        }
        
        //Update nBB record
        testNBBRecord.Unit__c = 10;
        Util.BypassAllTriggers = false;
        update testNBBRecord;
         
        //Query result of NBB Share records
        nBBShares = [SELECT Id FROM NBB__Share 
                     	WHERE ParentId =: testNBBRecord.Id 
                     	AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(1, nBBShares.size());
        
        //Test stops here   
        Test.stopTest();
    }   
    
    //Added By Mahendra Swarnkar - 02/11/2015 - CR-20151028-9361
    static testMethod void testPopulateSharingOnNBB_Using_Batch(){
        
        //Disables all the trigger
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        
        //Get System Admin profile list
        List<Profile> profile = [select Id, Name From Profile Where Name = 'System Administrator'];
        
        //Test User Create
        List<User> users = new List<User>();
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER1', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER2', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER3', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test3', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username= Math.random()+'@abc.com', LastName='TESTER4', FirstName='Test1', Email=Math.random()+'@test.com',
                            Alias='Test4', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=profile[0].Id, 
                            timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '12121212', IsActive = true));
        //insert users
        insert users;
        
        //List to hold Accounts record to be insert
        List<Account> accounts = new List<Account>();
        
        //List to hold Contact record to be inserted
        List<Contact> contacts = new List <Contact>();
        
        //Looping for creating differt test Accounts
        for(Integer i = 1; i <= 3; i++) {
            
            //populate list of Accounts    
            accounts.add(new Account(Name = 'Test Case Account '+ i));
        }
        
        //insert Accounts
        insert accounts;
        
        //Get the employee Record Type     
        Id EmpContRecordType = [SELECT Id, Name from RecordType WHERE Name = 'Employee' and SobjectType = 'Contact'].id;
        
        //Insert new Contact record
        contacts.add(new Contact(FirstName = 'Test1', LastName = 'Contact', Account = accounts[0], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[0].id));
        contacts.add(new Contact(FirstName = 'Test2', LastName = 'Contact', Account = accounts[1], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[1].id));
        contacts.add(new Contact(FirstName = 'Test3', LastName = 'Contact', Account = accounts[2], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[2].id));
        contacts.add(new Contact(FirstName = 'Test4', LastName = 'Contact', Account = accounts[2], RecordTypeId = EmpContRecordType, Employee_User_Record__c = users[3].id));
        
        insert contacts;
        
        //Modified By Mahendra Swarnkar - 02/11/2015 - CR-20151028-9361 - remove Incentivized__c field value
        //Insert Staff Roll 
        Team_Role__c staffRole = new Team_Role__c(Active__c =  true, Name = 'Test Staff Role',
                                                 Institution__c = true);
        insert staffRole;
        Team_Role__c staffRole2 = new Team_Role__c(Active__c =  true, Name = 'Test Staff Role2',
                                                  Institution__c = true);
        insert staffRole2;
        
        //List to hold Staff Assignments to be insert 
        List<Team_Membership__c> staffAssignments = new List<Team_Membership__c>();
        
        //Record Types
        List<RecordType> tmRecordTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Team_Membership__c' 
                                        	AND IsActive = true 
                       						AND DeveloperName = 'Assigned'];
        System.assert(tmRecordTypes != null);
        
        //Populate staffAssignments
        staffAssignments.add(new Team_Membership__c(Name = 'testSA1', Institution__c = accounts[0].Id , 
                                                    Employee__c = users[1].Id, Staff_member__c = Contacts[1].id, 
                                                    Role__c = staffRole.Id, Start_date__c = system.today(),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'testSA2', Institution__c = accounts[1].Id , 
                                                    Employee__c = users[2].Id, Staff_member__c = Contacts[2].id, 
                                                    Role__c = staffRole.Id, Start_date__c = system.today().addDays(1),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        staffAssignments.add(new Team_Membership__c(Name = 'testSA3', Institution__c = accounts[0].Id , 
                                                    Employee__c = users[3].Id, Staff_member__c = Contacts[3].id, 
                                                    Role__c = staffRole2.Id, Start_date__c = system.today().addDays(2),
                                                    RecordTypeId = tmRecordTypes[0].Id));
        
        //Insert Staff Assignment
        insert staffAssignments;
        
        //List to hold Configuration Manager custom setting records
        List<Configuration_Manager__c> configManagers = new List<Configuration_Manager__c>();
        configManagers.add(new Configuration_Manager__c(Name = 'test1', Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '% RM'));
        configManagers.add(new Configuration_Manager__c(Name = 'test2',  Parameter_Key__c = 'TeamMemberRoleForNBBSharing' , Parameter_Value__c = '%AE or EA%'));
        
        //Insert configuration Manager custom setting records 
        insert configManagers;
        
        //List to hold Account Team Member to be insert 
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        
        //Loop through Accounts list for ATMs
        for(Account account : accounts) {
            
            accountTeamMembers.add(new AccountTeamMember(UserId = users[0].Id, AccountId = account.Id, TeamMemberRole = 'Research & Insights - RM'));
            accountTeamMembers.add(new AccountTeamMember(UserId = users[1].Id, AccountId = account.Id, TeamMemberRole = 'AE or EA'));
        }
        
        //insert Account Team Members
        insert accountTeamMembers;
        
        //List to hold Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Loop through Accounts list for Opportunity
        for(Account account : accounts) {
            //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
            opportunities.add(new Opportunity(Name='Test Opp', Main_Contact__c = contacts[0].Id, StageName = '0-Exploring', Amount = 1, CloseDate = System.today().addDays(32), 
                                              AccountId = account.Id,Sales_Pursuit_Products__c = 'APS'));
        }
        
        //Insert Opportunities
        insert opportunities;
        
        //List to hold NBB test records
        List<NBB__c> nBBs = new List<NBB__c>();
        
        //Loop through Opportunity List
        for(Opportunity opportunity : opportunities) {
            
            nBBs.add(new NBB__c(Opportunity__c = opportunity.Id, OwnerId = Userinfo.getUserId(), Name = 'test', NBB_Type__c = 'Base Fee', 
                                    NBB__c = 10, Unit__c = 5, ATL_Date__c = system.today()));
        }
        
	    //insert nBBs here
        insert nBBs;

        //Test starts here
        Test.startTest();
        
        //Enables all the triggers
        Util.BypassAllTriggers = false;
        
        //Execute the batch
	    Database.executeBatch(new Batch_UpdateAccTeamMemberSharingOppNBB(), 50);
		
        //Test starts here
        Test.stopTest();
        
        //Query result of NBB Share records
        List<NBB__Share> nBBShares = [SELECT Id, UserOrGroupId FROM NBB__Share 
                                        WHERE ParentId IN: nBBs 
                                        AND RowCause =: Schema.NBB__Share.RowCause.Manual];
        
        //Assert statements
        System.assertEquals(8, nBBShares.size());
        System.assertEquals(users[0].Id ,nBBShares[0].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[1].UserOrGroupId);
        System.assertEquals(users[3].Id ,nBBShares[2].UserOrGroupId);
        System.assertEquals(users[0].Id ,nBBShares[3].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[4].UserOrGroupId);
        System.assertEquals(users[2].Id ,nBBShares[5].UserOrGroupId);
        System.assertEquals(users[0].Id ,nBBShares[6].UserOrGroupId);
        System.assertEquals(users[1].Id ,nBBShares[7].UserOrGroupId);
    }
}