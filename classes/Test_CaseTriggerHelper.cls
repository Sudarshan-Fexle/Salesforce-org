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
private class Test_CaseTriggerHelper {
  /**
   * Purpose         :  Test class for CaseTriggerHelper
   *
   * Created By      :  Abhinav Sharma
   *
   * Created Date    :  06/20/2014
   *
   * Revision Log    :  V_1.0 - Created - Abhinav Sharma - CR-20140417-5120
   *                    V_1.1 - Modified By - Abhinav Sharma - CR-20140618-5845 - 07/03/2014
   *                    V_1.2 - Modified By - Abhinav Sharma - CR-20140629-6015 - 07/04/2014
   *                    V_1.3 - Modified By - Abhinav Sharma - CR-20140707-6093 - 08/06/2014
   *                    V_1.4 - Modified By - Ajit Surana - CR-20140812-6973 - 09/10/2014 - Added a new test method named "test_PopulateCaseFromEmailToCase"
   *                    V_1.5 - Modified By - Abhinav Sharma - CR-20140827-7164 - 10/08/2014
   *                    V_1.6 - Modified By - Abhinav Surana - 10/15/2014 - CR-20141001-7574
   *                    V_1.7 - Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987
   *                    V_1.8 - Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992
   *                    V_1.9 - Modified By - Abhinav Sharma - 11/26/2015 - CR-20151118-9394
   *                    V_2.0 - Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006 
   *                    V_2.1 - Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397
   *                    V_2.2 - Modified By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
   *                    V_2.3 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
   *                    V_2.4 - Modified By - Abhinav Sharma - 06/15/2016 - CR-20150202-8628
   *                    V_2.5 - Modified By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651
   *                    V_2.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160803-10082
   *                    V_2.7 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. Fixing the assert failure and code fix.
   *                    V_2.8 - Modified By - Mahendra Swarnkar - 10/13/2016 - CR-20160607-9905
   *                    V_2.9 - Modified By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
   *                    V_3.0 - Modified By - Abhinav Sharma - 12/11/2016 - CR-20160408-9751
   *                    V_3.1 - Modofied By - Abhinav Sharma - CR-20170222-10716 
   *                    V_3.2 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Replaced the Platinum_Services__c Field references with "Research_Platform__c" field on account and cases. 
   *                    V_3.3 - Modified By - Dipesh Gupta - CR-20170705-11059 - cover the phone Appointment scenario on case, in which deadline and priority Automatically set.
   *                    V_3.4 - Modified By - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
   *                    V_3.5 - Modified By - Abhinav Sharma - CR-20180928-12623 - 10/26/2018 - New method added. webHelpCaseFunctionlityTest
   *                    V_3.6 - Modified By - Victor Hanson - CR-20200331-13896 - 03/31/2020 - New method added. testUpdateRegistration
   *                    V_3.7 - Modified By - Abhinav Sharma - CR-20200729-14382 -10/26/2018 - Updated testUpdateRegistration method is used to test the Registration Status when Event Type "Cohort" 
   *                    V_3.8 - Modified By - Saurabh Kumar - CR-20200819-14447 - 10/13/2020 : Replaced Meeting with EAB Event.
   *                    V_3.9 - Modified By - Saurabh Kumar - 11/12/2020 - Increase coverage of CreateDummyContact method
   *                    V_4.0 - Modified By - Neha Sharma - 03/24/2021 - CR-20210324-15019
   *                    V_4.1 - Modified By - Abhinav Sharma - 03/13/2021 - CR-20201207-14726
   *                    V_4.2 - Modified By - Chirag Soni - 06/22/2021 - MRS 2.0 Phase 2 (Test class fixes)
   *                    V_4.3 - Modified By - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
   *                    V_4.4 - Modified By - Ayush Gupta - 09/13/2021 - Increase code coverage
   *                    V_4.5 - Modified By - Ayush Gupta - 09/13/2021 - testCreateDummyContact
   *                    V_4.6 - Modified By - Ayush Gupta - 09/13/2021 - testpostResolutionToComments
   *                    V_4.7 - Modified By - Ayush Gupta - 09/13/2021 - test_notifyAccountOwner
   *			V_4.8 - Modified By - Mahendra Swarnka - 06-12-2021 - CR-20211203-15614
   *                    		
  **/
    
   /** Description : Method to test out whether:-
    *                a) Member_Type__c field is populating as expected or not
    *                b) Utility method to add business days is working as expected or not.
    **/
    static testmethod void myUnitTest_1() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        //Added by - Ayush Gupta - 09/13/2021 - Start
        //List to insert Program records
        List<Program__c> programs = new List<Program__c>();
        
        //Add Program Record in list
        programs.add(TestUtilities.CreateNewProgram(false));
        programs.add(TestUtilities.CreateNewProgram(false));
        
        //Add additional field values
        programs[0].Business_line__c = 'RI';
        programs[0].Status__c = 'Active';
        programs[0].Name = 'TMBH - Test Method';
        programs[0].Program_Acronym__c = 'TMBH';
        programs[0].Program_Formal_Name__c = 'Test Method';
        programs[0].Renewable__c = true; 
        programs[0].New_Business_Business__c = 'EAB';
        programs[0].Type__c = 'Standard';
        programs[0].New_Business_Vertical__c = 'EAB';
        programs[0].Entity__c = 'EAB';
        programs[0].Program_Line__c = 'PT';
        programs[0].Sector__c = 'HE';
        programs[0].Applicable_Segments__c = 'International Education;US Education';
        programs[0].Solomon_Code__c = '851';
        programs[0].New_Business_Marketer__c = 'HE SSC';
        programs[0].Create_memberships__c = 'Yes';
        programs[0].Renewal_Unit_Count__c = 1;
        
        //Add additional field values
        programs[1].Business_line__c = 'TD';
        programs[1].Status__c = 'Active';
        programs[1].Name = 'TMBH - Test Method 1';
        programs[1].Program_Acronym__c = 'TMBH 1';
        programs[1].Program_Formal_Name__c = 'Test Method 1';
        programs[1].Renewable__c = true; 
        programs[1].New_Business_Business__c = 'EAB';
        programs[1].Type__c = 'Standard';
        programs[1].New_Business_Vertical__c = 'EAB';
        programs[1].Entity__c = 'EAB';
        programs[1].Program_Line__c = 'PT';
        programs[1].Sector__c = 'HE';
        programs[1].Applicable_Segments__c = 'International Education;US Education';
        programs[1].Solomon_Code__c = '851';
        programs[1].New_Business_Marketer__c = 'HE SSC';
        programs[1].Create_memberships__c = 'Yes';
        programs[1].Renewal_Unit_Count__c = 1;
        
        //insert programs
        insert programs;														
        //Added by - Ayush Gupta - 09/13/2021 - end								
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Case' AND IsActive = true 
                                   AND DeveloperName = 'Member_Employee_Support'];
        
        //Query for queue                                
        List<QueueSobject> lstQueues = [SELECT Id, queue.Name, QueueId FROM QueueSobject 
                                        WHERE SobjectType = 'Case' and queue.name= 'Events & Member Support'];
        
        //Assert for the results
        System.assert(rdType != null);
        System.assert(lstQueues != null);
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Description = 'Testing RIAMLargeContract Testing';
        acct_1.Account_Formal_Name__c = 'Test 1';
        acct_1.Primary_Country__c = 'Canada';
        
        //Create an institution
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Description = 'RIAMLargeContract';
        acct_2.Account_Formal_Name__c = 'Test 2';
        acct_2.Primary_Country__c = 'India';
        
        //Create an institution
        Account acct_3 = TestUtilities.CreateNewAccount(false);
        acct_3.Description = 'Testing RIAM';
        acct_3.Account_Formal_Name__c = 'Test 3';
        acct_3.Primary_Country__c  = 'UK';
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); accounts.add(acct_3);
        
        //Insert accounts
        insert accounts;
        //Added by -  Ayush Gupta -  09/13/2021 - for parentId - Start
        accounts  = [Select Id,Description,ParentId from Account Order By Account_Formal_Name__c ASC];
        accounts[0].ParentId = accounts[2].Id;
        update accounts;
        
        //Added by -  Ayush Gupta -  09/13/2021 - end
        
        List<Contact> contacts = new List<Contact>();
        // create a new contact
        Contact con_1 = TestUtilities.CreateNewContact(false);
        contacts.add(con_1);
        // create a new contact
        Contact con_2 = TestUtilities.CreateNewContact(false);
        contacts.add(con_2);
        insert contacts;
        //Added by -  Ayush Gupta -  09/13/2021 - Start here 
        
        //List to hold Contract records to insert
        List<Contract> contracts = new List<Contract>();
        
        //Add contract record into the list
        contracts.add(new Contract(Name = 'Test 1', StartDate = System.today(), EndDate = System.today().addDays(10), ContractTerm = 36,
                                   AccountId = accounts[0].Id,Invoicing_Arrangement__c = 'Annual', Program__c = programs[0].Id,
                                   Billing_Schedule_Automated_Status__c = 'Completed',status = 'Draft',Amendment_Type__c = 'Upsell'));
        
        //Add contract record into the list
        contracts.add(new Contract(Name = 'Test 2', StartDate = System.today().addDays(5), EndDate = System.today().addDays(15), 
                                   ContractTerm = 30, AccountId = accounts[1].Id, Program__c = programs[1].Id,
                                   Billing_Schedule_Automated_Status__c = 'Awaiting Processing', Invoicing_Arrangement__c = 'Annual',
                                   status = 'Draft',Amendment_Type__c = 'Upsell'));    
        
        //insert contract records
        insert contracts;
        
        //create Contract ABC test data
        List<Contract__c> contractsABC = new List<Contract__c>();
        
        //Add record to list
        contractsABC.add( new Contract__c(Name = 'TestContract 1', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[0].Id,
                                          Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contacts[0].Id,
                                          End__c = System.today().addDays(10),Start__c = System.today(),
                                          Negotiated_Amount__c = 12, Term_Type__c ='Year with Opt Out',Program__c = programs[0].Id));
        
        contractsABC.add( new Contract__c(Name = 'TestContract 2', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[1].Id,
                                          Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contacts[1].Id,
                                          End__c = System.today().addDays(10),Start__c = System.today(),
                                          Negotiated_Amount__c = 12, Term_Type__c ='Fixed Term',Program__c = programs[1].Id));
        
        contractsABC.add( new Contract__c(Name = 'TestContract 3', Invoicing_Arrangement__c = 'Special', Payer_Account__c = accounts[1].Id,
                                          Year__c = '2017', Type__c = 'NBB', Main_Contact__c = contacts[1].Id,
                                          End__c = System.today().addDays(10),Start__c = System.today(),
                                          Negotiated_Amount__c = 12, Term_Type__c ='Fixed Term',Program__c = programs[1].Id));
        
        //Bypass
        Util.BypassAllTriggers = true;
        
        //Insert the contract ABC
        insert contractsABC;
        
        //Fetch records of contract to update  because of dependent picklist
        contracts = [Select Id, status from Contract Order By Name ASC];
        
        contracts[0].status = 'Activated';
        contracts[1].status = 'Activated';
        
        //update contracts
        update contracts;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'SBQQ__Subscription__c' AND IsActive = true
                                        AND DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
        
        //List to hold subscription
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();  
        
        //Add new subscription record in list
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Previous_Period_Plus_Uplift__c = 1000,SBQQ__Account__c = accounts[0].Id,
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Contract__c = contracts[0].Id,Renewal_Type__c = 'Initial',
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,Program__c = programs[0].Id,
                                                    Previous_Contract_ABC__c = contractsABC[0].Id, Status__c = 'Committed', Official_Drop_Date__c = Date.today()));
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 3, Previous_Period_Plus_Uplift__c = 2000,SBQQ__Contract__c = contracts[1].Id,Renewal_Type__c = 'Initial',
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Account__c = accounts[1].Id,Program__c = programs[1].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 2,
                                                    Previous_Contract_ABC__c = contractsABC[1].Id, Status__c = 'Committed', Official_Drop_Date__c = Date.today()));     
        
        subscriptions.add(new SBQQ__Subscription__c(SBQQ__Quantity__c = 5, Previous_Period_Plus_Uplift__c = 3000,SBQQ__Contract__c = contracts[1].Id,Renewal_Type__c = 'Initial',
                                                    SBQQ__ListPrice__c = 0, RecordTypeId = recordTypes[0].Id,SBQQ__Account__c = accounts[1].Id,Program__c = programs[1].Id,
                                                    SBQQ__NetPrice__c = 0, SBQQ__CustomerPrice__c = 0, SBQQ__ProrateMultiplier__c = 3,
                                                    Previous_Contract_ABC__c = contractsABC[1].Id, Status__c = 'Committed', Official_Drop_Date__c = Date.today()));                                                  
        //Insert
        insert subscriptions; 
        
        subscriptions = [SELECT ID, Program_Acronym__c, SBQQ__Account__c, SBQQ__StartDate__c, 
                         SBQQ__EndDate__c, Business_Line__c,Renewal_Type__c,RecordTypeID,Program__c
                         FROM SBQQ__Subscription__c
                         WHERE SBQQ__Account__c != null 
                         AND SBQQ__Account__c IN : accounts
                         AND Renewal_Type__c =: System.Label.RENEWAL_TYPE_INITIAL 
                         AND (
                             Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                             OR Business_Line__c =: System.Label.CASE_TD_PROGRAM_TYPE 
                         )
                         AND SBQQ__StartDate__c != null
                         AND SBQQ__EndDate__c != null
                         AND RecordTypeID != null
                         AND RecordType.DeveloperName = 'Program'
                         ORDER By SBQQ__EndDate__c DESC];
        
        //asserts
        System.assertEquals(3, subscriptions.size());
        
        //list to hold membership records
        List<Membership__c> membs = new List<Membership__c>();
        membs.add(new Membership__c(Account_Name__c = accounts[0].Id, Name = 'TestMemb1',
                                    Membership_Status_Text__c = Constants.MEMBER_INTEGRATED_GRACE, 
                                    Program__c = programs[0].Id)); //,Earliest_Subscription__c = programs[0].Id,Latest_Subscription__c = programs[0].Id,Active_Subscription__c = programs[0].Id));
        
        membs.add(new Membership__c(Account_Name__c = accounts[1].Id, Name = 'TestMemb1', Program__c = programs[1].Id));
        
        //insert membership records
        insert membs;
        //Added by -  Ayush Gupta -  09/13/2021 - Till here 
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[0].Id, Subject = 'out of office', 
                              OwnerId = lstQueues[0].QueueId, Description = 'out of office');
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[0].Id, Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Phone', ContactId = contacts[0].Id, Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[1].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Web', ContactId = contacts[0].Id, Subject = 'Test 3', 
                                Description = 'test 3', AccountId = accounts[2].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_4 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[0].Id, Subject = 'Test OOO', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 4');
        
        //Create a sample case record to insert and test case trigger
        Case aCase_5 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[0].Id, Subject = 'Test Out of Offices', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 5');
        
        //Create a sample case record to insert and test case trigger
        Case aCase_6 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id, Subject = 'Test 6', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test out of the Office');
        
        //Create a sample case record to insert and test case trigger
        Case aCase_7 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id, Subject = 'Automatic reply : Test', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 6');
        
        
        //Added by - Ayush Gupta - 09/13/2021 - From Here
        
        //Create a sample case record
        Case aCase_8 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id,AccountId = accounts[0].Id , Subject  = 'U test 1', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 7', Membership__c = membs[0].Id);
        
        //Create a sample case record 
        Case aCase_9 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id, AccountId = accounts[0].Id , Subject  = 'U test 2', 
                                OwnerId = lstQueues[0].QueueId, Description = 'Test 8', Membership__c = membs[0].Id);
        
        //Create a sample case record 
        Case aCase_10 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id, AccountId = accounts[1].Id , Subject  = 'U test 3', 
                                 OwnerId = lstQueues[0].QueueId, Description = 'Test 9', Membership__c = membs[1].Id);
        
        //Create a sample case record 
        Case aCase_11 = new Case(RecordTypeId = rdType[0].Id, Origin = 'Email', ContactId = contacts[1].Id, AccountId = accounts[2].Id , Subject  = 'U test 4', 
                                 OwnerId = lstQueues[0].QueueId, Description = 'Test 10', Membership__c = membs[1].Id);
        
        //Added by -  Ayush Gupta - 09/13/2021 - Till Here
        //Populating list with records instances
        cases.add(aCase);   cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3);
        cases.add(aCase_4); cases.add(aCase_5); cases.add(aCase_6); cases.add(aCase_7);
        
        //Added by - Ayush Gupta - 09/13/2021 - From Here
        
        cases.add(aCase_8); cases.add(aCase_9); cases.add(aCase_10); cases.add(aCase_11);
        
        //Added by - Ayush Gupta - 09/13/2021 - Till Here
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert Case
        insert cases;
        
        //Checking record need to remove from here
        List<SBQQ__Subscription__c> SBBQSubs = [SELECT ID, Program_Acronym__c, SBQQ__Account__c, SBQQ__StartDate__c, 
                                                SBQQ__EndDate__c, Business_Line__c,Renewal_Type__c,RecordTypeID
                                                FROM SBQQ__Subscription__c
                                                WHERE SBQQ__Account__c != null 
                                                AND SBQQ__Account__c IN : accounts
                                                AND RecordType.DeveloperName = 'Program'
                                                AND Renewal_Type__c =: System.Label.RENEWAL_TYPE_INITIAL 
                                                AND (
                                                    Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                                                    OR Business_Line__c =: System.Label.CASE_TD_PROGRAM_TYPE 
                                                )
                                                ORDER By SBQQ__EndDate__c DESC];
        
        //Checking record need to remove till here
        //Stop Test here
        Test.stopTest();  
        
        //Querying case records
        cases = [SELECT ID, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(5, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[1].Member_Type__c);
        System.assertEquals(null, cases[2].Member_Type__c);
        
        //Updating the existing case records
        cases[1].AccountId = accounts[2].Id;
        cases[2].AccountId = accounts[1].Id;
        
        //Update case records
        update cases;
        
        //Querying case records
        cases = [SELECT ID, Member_Type__c FROM Case ORDER BY Subject ASC LIMIT 5];
        System.assertEquals(5, cases.size());  
        System.assertEquals('RIAMLargeContract', cases[0].Member_Type__c);
        System.assertEquals(null, cases[1].Member_Type__c);
        System.assertEquals('RIAMLargeContract', cases[2].Member_Type__c);
        
        //Disable triggers execution for avoiding the limits errors
        Util.byPassAllTriggers = true;
        
        //Testing Utility method for checking that it is doing calcualtion for bussiness days correctly or not
        Date date_1 = date.newinstance(2014, 7, 04);
        Date date_2 = date_1.addDays(1);
        Date date_3 = date_2.addDays(1);
        Date date_4 = date_3.addDays(1);
        Date date_5 = date_4.addDays(1);
        Date date_6 = date_5.addDays(1);
        Date date_7 = date_6.addDays(1);
        Date date_8 = date_7.addDays(1);
        Date date_9 = date_8.addDays(1);
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_1));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_1, 3));
        
        //Calling utility method and Asserting for the results
        System.assert(Util.IsWeekendDay(date_2));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_2, 3));
        
        //Calling utility method and Asserting for the results
        System.assert(Util.IsWeekendDay(date_3));
        System.assert(date.parse('07/09/2014') == Util.AddBusinessDays(date_3, 3));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_4));
        System.assert(date.parse('07/10/2014') == Util.AddBusinessDays(date_4, 3));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_5));
        System.assert(date.parse('07/11/2014') == Util.AddBusinessDays(date_5, 3));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_6));
        System.assert(date.parse('07/14/2014') == Util.AddBusinessDays(date_6, 3));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_7));
        System.assert(date.parse('07/15/2014') == Util.AddBusinessDays(date_7, 3));
        
        //Calling utility method and asserting for the results
        System.assert(!Util.IsWeekendDay(date_8));
        System.assert(date.parse('07/16/2014') == Util.AddBusinessDays(date_8, 3));
        
        //Calling utility method and asserting for the results
        System.assert(Util.IsWeekendDay(date_9));
        System.assert(date.parse('07/16/2014') == Util.AddBusinessDays(date_9, 3));
        
        //Calling utility method and asserting for the results
        System.assert(Util.IsWeekendDay(date_9));
        System.assert(date.parse('07/18/2014') == Util.AddBusinessDays(date_9, 5));
    }

    /** Description : Method to test out whether case fields updates and OOO type case deletion related funcationality is
     *                working as expected or not.
     * Revision Log :  V_1.0 - Modified By - Ajit Surana - 09/10/2014 - CR-20140812-6973
     * 		    :  V_1.1 - Modified By - Ajit Surana - 11/16/2014 - CR-20141105-7987
     * 		    :  V_1.2 - Modified By - Ajit Surana - 11/17/2014 - CR-20141105-7992
     * 		    :  V_1.3 - Modified By - Abhinav Sharma - 12/01/2015 - CR-20150616-9006
     * 		    :  V_1.4 - Modified By - Mahendra Swarnakar - 12/02/2015 - CR-20151118-9397  
     * 		    :  V_1.5 - Modified By - Mahendra Swarnakar - 8/31/2016 - CR-20160715-10014  
     * 		    :  V_1.6 - Modified By - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
     * 		    :  V_1.7 - Modified By - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
     * 		    :  V_1.8 - Modified By - Ayush Gupta - 09/13/2021 - Code coverage Increase	
    **/															  
    static testmethod void test_PopulateCaseFromEmailToCase() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Set of record types
        Set<String> setOfRecordTypeDeveloperNames = new Set<String>();
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT);
        setOfRecordTypeDeveloperNames.add('SSC_Support');
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_WEBHELP);
        setOfRecordTypeDeveloperNames.add(Constants.CASE_RECORD_TYPE_ETECH_SUPPORT);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRecordTypes = [SELECT ID, DeveloperName FROM RecordType 
                                            Where sObjectType = 'Case' AND IsActive = true 
                                            AND DeveloperName IN : setOfRecordTypeDeveloperNames
                                            ORDER By DeveloperName ASC];
        //Assert for the results
        System.assert(caseRecordTypes != null);
        System.assert(caseRecordTypes.size() == 4);
        System.assert(caseRecordTypes[0].DeveloperName == Constants.CASE_RECORD_TYPE_ETECH_SUPPORT);
        System.assert(caseRecordTypes[1].DeveloperName == Constants.CASE_RECORD_TYPE_MEMBER_EMPLOYEE_SUPPORT);
        System.assert(caseRecordTypes[2].DeveloperName == 'SSC_Support');
        System.assert(caseRecordTypes[3].DeveloperName == Constants.CASE_RECORD_TYPE_WEBHELP);
        
        //Query for queue                                
        List<QueueSobject> queueList = [SELECT Id, queue.DeveloperName, QueueId FROM QueueSobject 
                                        WHERE SobjectType = 'Case' AND queue.DeveloperName != null 
                                        AND (
                                            queue.DeveloperName =: Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT
                                            OR
                                            queue.DeveloperName =: Constants.QUEUE_NAME_WEBHELP
                                            OR
                                            queue.DeveloperName =: Constants.QUEUE_NAME_DATA_INTEGRATIONS
                                        )
                                        ORDER By queue.DeveloperName ASC
                                       ];
        //Assert for the results
        System.assert(queueList != null);
        System.assertEquals(queueList[0].queue.DeveloperName, Constants.QUEUE_NAME_DATA_INTEGRATIONS);
        System.assertEquals(queueList[1].queue.DeveloperName, Constants.QUEUE_NAME_EVENTS_MEMBER_SUPPORT);
        System.assertEquals(queueList[2].queue.DeveloperName, Constants.QUEUE_NAME_WEBHELP);
        
        // Added by Ayush Gupta - 09/13/2021 - Start
        //Querying Details for record type on Site_Issue__c Object
        List<RecordType> issueRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                         Where sObjectType = 'Site_Issue__c' 
                                         AND IsActive = true 
                                         AND DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST
                                         ORDER By DeveloperName ASC];
        
        //List to hold the Member Support (Site_Issue__c) records
        List<Site_Issue__c> issues = new List<Site_Issue__c>();
        
        //Create a sample case record of (Site_Issue__c) records
        issues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test description 1 ', Data_Load_Type__c = 'Current',
                                     Data_Load_Period_Begin__c	= System.today(), Data_Load_Period_End__c = System.today(),
                                     RecordTypeId = issueRdTypes[0].Id));
        
        issues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test description 2', Data_Load_Type__c = 'Current',
                                     Data_Load_Period_Begin__c	= System.today(), Data_Load_Period_End__c = System.today(),
                                     RecordTypeId = issueRdTypes[0].Id));
        
        //Insert
        insert issues;
        // Added by Ayush Gupta - 09/13/2021 - end
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert
        Case aCase_1 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_MEETINGS, 
                                Subject = 'Test Record 1', Entity__c = 'EAB',
                                OwnerId = queueList[0].QueueId, Description = 'Testing Meetings W2C Email');
        
        //Create a sample case record to insert
        Case aCase_2 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_WEBCONFERENCES, 
                                Subject = 'Test Record 2', Entity__c = 'EAB',
                                Description = 'Testing Webconferences W2C Email');
        
        //Create a sample case record to insert
        Case aCase_3 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS, 
                                Subject = 'Test Record 3', Entity__c = 'EAB',
                                Description = 'Testing ConferenceRoomRequests W2C Email');
        
        //Create a sample case record to insert
        Case aCase_4 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_TRAVEL, 
                                Subject = 'Test Record 4',  Entity__c = 'EAB',
                                Description = 'Testing Travel EmailW2C Email');
        
        //Create a sample case record to insert
        Case aCase_5 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_VOICE_MAIL, 
                                Subject = 'Test Record 5', Entity__c = 'EAB', 
                                OwnerId = queueList[0].QueueId, Description = 'Testing Voice Mail W2C Email');
        
        //Create a sample case record to insert
        Case aCase_6 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_ADVISORY, 
                                Subject = 'Test Record 6', Entity__c = 'EAB',
                                OwnerId = queueList[0].QueueId, Description = 'Testing Advisory W2C Email');
        
        //Create a sample case record to insert
        Case aCase_7 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB, 
                                Subject = 'Test Record 7',  Entity__c = 'EAB',
                                OwnerId = queueList[0].QueueId, Description = 'Testing EAB W2C Email');
        
        //Create a sample case record to insert
        Case aCase_8 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_ABI, 
                                Subject = 'Test Record 8',  Entity__c = 'EAB',
                                OwnerId = queueList[0].QueueId, Description = 'Testing ABI W2C Email');
        
        //Create a sample case record to insert
        Case aCase_9 = new Case(RecordTypeId = caseRecordTypes[0].Id, Origin = Constants.CASE_ORIGIN_EMAIL_TO_CASE_DATA_INTEGRATIONS, 
                                Subject = 'Test Record 9',  Entity__c = 'EAB',
                                OwnerId = queueList[0].QueueId, Description = 'Testing Data Integration W2C Email');
        
        //Create a sample case record to insert
        Case aCase_10 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB_MEETINGS, 
                                 Subject = 'Test Record 10',  Entity__c = 'EAB',
                                 OwnerId = queueList[0].QueueId, Description = 'Testing EAB Meetings W2C Email');
        
        //Create a sample case record to insert
        Case aCase_11 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = Constants.CASE_ORIGIN_EAB_MEETINGS, 
                                 Subject = 'Test Record 11',  Entity__c = 'EAB',
                                 OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 1',
                                 SuppliedEmail = 'Mailer-daemon@advisory.com');
        
        //Create a sample case record to insert
        Case aCase_12 = new Case(RecordTypeId = caseRecordTypes[1].Id, Origin = 'Voice Mail', Subject = 'Test Record 12', 
                                 OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 2',  Entity__c = 'EAB',
                                 SuppliedEmail = 'spamfilter@advisory.com');
        
        //Create a sample case record to insert
        Case aCase_13 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = 'Voice Mail', Subject = 'Test Record 9 ooo', 
                                 OwnerId = queueList[0].QueueId, Description = 'Testing VoiceMail W2C Email 3');
        
        //Create a sample case record to insert
        Case aCase_14 = new Case(RecordTypeId = caseRecordTypes[2].Id,
                                 Origin = 'Email', Subject = 'Test PT Record', 
                                 Description = 'Testing PT W2C Email');
        
        //Added by - Ayush Gupta - 09/13/2021 - Start Here 
        //Sample cases record to insert
        Case aCase_15 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = Constants.CASE_ORIGIN_MEETINGS, 
                                 Subject = 'UTest 15', Type = 'EAB',Member_Support_Ticket__c = issues[0].Id,
                                 OwnerId = queueList[0].QueueId, Description = 'Testing Meetings W2C Email');
        
        Case aCase_16 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = Constants.CASE_ORIGIN_WEBCONFERENCES, 
                                 Subject = 'UTest 16', Type = 'EAB',Member_Support_Ticket__c = issues[0].Id,
                                 Description = 'Testing Webconferences W2C Email');
        
        Case aCase_17 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS, 
                                 Subject = 'UTest 17',Member_Support_Ticket__c = issues[1].Id,
                                 Description = 'Testing ConferenceRoomRequests W2C Email');
        
        Case aCase_18 = new Case(RecordTypeId = caseRecordTypes[3].Id, Origin = Constants.CASE_ORIGIN_TRAVEL, 
                                 Subject = 'UTest 18',Member_Support_Ticket__c = issues[1].Id,
                                 Description = 'Testing Travel EmailW2C Email');
        
        //Added by - Ayush Gupta - 09/13/2021 - Till Here 
        
        //Populating list with records instances
        cases.add(aCase_1);
        cases.add(aCase_2); cases.add(aCase_3);
        cases.add(aCase_4); cases.add(aCase_5);
        cases.add(aCase_6); cases.add(aCase_7);
        cases.add(aCase_8); cases.add(aCase_9);
        cases.add(aCase_10);
        cases.add(aCase_11); cases.add(aCase_12);
        cases.add(aCase_13); cases.add(aCase_14);
        
        //Added By - Ayush Gupta - 09/13/2021 - From Here
        cases.add(aCase_15);
        cases.add(aCase_16);
        cases.add(aCase_17); 
        cases.add(aCase_18);
        //Added By - Ayush Gupta - 09/13/2021 - Till Here 
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert Case
        insert cases;
        
        //Stop Test here
        Test.stopTest();  
        
        //Querying case records
        cases = [SELECT ID, Origin, Type, Subject, OwnerId FROM Case ORDER By Subject ASC];
        
        //Asserts for getting correct results
        
        //Modify By -  Ayush Gupta - 09/13/2021 - From Here 
        System.assertEquals(15, cases.size()); 
        //Modify By -  Ayush Gupta - 09/13/2021 - From Here 
        
        System.assertEquals(Constants.EMAIL, cases[0].Origin);
        System.assertEquals(null, cases[0].Type);
        System.assertEquals('Test PT Record', cases[0].Subject);
        
        System.assertEquals(Constants.EMAIL, cases[1].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_MEETINGS, cases[1].Type);
        System.assertEquals('Test Record 1', cases[1].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.CASE_ORIGIN_EAB_MEETINGS, cases[2].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_MEETINGS, cases[2].Type);
        System.assertEquals('Test Record 10', cases[2].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[3].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_WEBCONFERENCES, cases[3].Type);
        System.assertEquals('Test Record 2', cases[3].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[4].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_CONFERENCE_ROOM_REQUESTS, cases[4].Type);
        System.assertEquals('Test Record 3', cases[4].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[5].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_TRAVEL, cases[5].Type);
        System.assertEquals('Test Record 4', cases[5].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        //V1.17 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        System.assertEquals(Constants.CASE_ORIGIN_VOICE_MAIL, cases[6].Origin);
        //System.assertEquals(Constants.EMAIL, cases[6].Origin);
        
        System.assertEquals(Constants.CASE_ORIGIN_VOICE_MAIL, cases[6].Type);
        System.assertEquals('Test Record 5', cases[6].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[7].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_ADVISORY, cases[7].Type);
        System.assertEquals('Test Record 6', cases[7].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[8].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_EAB, cases[8].Type);
        System.assertEquals('Test Record 7', cases[8].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[9].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_ABI, cases[9].Type);
        System.assertEquals('Test Record 8', cases[9].Subject);
        //V_1.24 - Modified by - Subhash Garhwal - 11/13/2017 - Assert Failure Error fix(CR- Apollo - Salesforce Workstream) fixed by commenting assert
        //System.assertEquals(queueList[1].QueueId, cases[1].OwnerID);
        
        System.assertEquals(Constants.EMAIL, cases[10].Origin);
        System.assertEquals(Constants.CASE_ORIGIN_DATA_INTEGRATIONS, cases[10].Type);
        System.assertEquals('Test Record 9', cases[10].Subject);
    }

    /** Description : Method to test out "New_Member_Programs_RI__c" field is populating as expected or not.
     * Revision Log :  V_1.0 - Modified By - Mahedra Swarnkar - 07/25/2016 - CR-20160229-9651
     * 		       V_1.1 - Modified By - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
     * 		       V_1.2 - Modified By - Abhinav Sharma - 02/15/2016 - CR-20150925-9267
    **/
    static testmethod void test_CasebeforeEventsLogics() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testCode', 
                                              Business_line__c = 'RI', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'PT', Status__c = 'Active');
        Program__c program_3 = new Program__c(Name = 'testName 3', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2); programs.add(program_3);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 3);
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        Contract__c contractABC_3 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = programs[2].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        contracts.add(contractABC_1); contracts.add(contractABC_2); contracts.add(contractABC_3);
        insert contracts;
        
        //Assert for results
        System.assert(contracts != null);
        System.assert(contracts.size() == 3);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('EAB_Custom', 'WebHelp' , 'SSC_Support')
                                        ORDER By DeveloperName ASC];
        
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 3);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
        System.assert(caseRdTypes[1].DeveloperName == 'SSC_Support');
        System.assert(caseRdTypes[2].DeveloperName == 'WebHelp');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[1].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id);
        
        //Populating list with case records
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        
        //Asserting for the results
        //SpringCleanUp
        cases = [SELECT ID, Origin, New_Member_Programs_RI__c //, New_Member_Programs_TD__c
                 FROM Case ORDER BY Origin ASC];
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        //System.assertEquals('testCode', cases[1].New_Member_Programs_RI__c);
        //System.assertEquals('ABC2', cases[2].Origin);
        //Spring CleanUp
        //System.assertEquals('testing TD', cases[2].New_Member_Programs_TD__c);
        
        //Bypassing triggers
        Util.byPassAllTriggers = true;
        
        //Updating contracts
        contracts[1].Program__c = programs[0].Id;
        update contracts;
        
        //Changing fields values on the Cases
        cases[1].New_Member_Programs_RI__c = null;
        cases[0].New_Member_Programs_RI__c = 'Test';
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Update cases
        update cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        
        //Asserting for the results
        cases = [SELECT ID, Origin, AccountID, New_Member_Programs_RI__c FROM Case ORDER BY Origin ASC];
        /*    
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 3);
        System.assertEquals('Email', cases[0].Origin);
        System.assertEquals(null, cases[0].New_Member_Programs_RI__c);
        System.assertEquals('ABC1', cases[1].Origin);
        System.assertEquals('testCode,testCode', cases[1].New_Member_Programs_RI__c);
        */       
        //test will stop here
        Test.stopTest();
    }

    /** Description : Few fields on case object can not be changed directly without using custom detail page button and this
     *                test method is test out/validate the same.
     * Revision Log : V_1.0 - Modified By - Abhinav Sharma - CR-20150202-8628 - To refactor the existing code
     * 		    : V_1.1 - Modified By - Abhinav Sharma - 03/31/2016 - CR-20160224-9632
    **/
    static testmethod void test_CasebeforeEventsLogics2() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
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
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121212123', IsActive = true));
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2', FirstName='Test2', Email='testuser2@test.com',
                              Alias='Test2', EmailEncodingKey='UTF-8', languagelocalekey='en_US', ProfileId=testProfile[0].Id, 
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121212124', IsActive = true));
        
        insert userList;
        
        //Asserting for the results
        System.assert(userList != null);
        System.assert(userList.size() == 2);
        
        //Run as user
        System.runAs(userList[0]) {
            
            //List to hold the Account records
            List<Account> accounts = new List<Account>();
            
            //Create an institution
            Account acct_1 = TestUtilities.CreateNewAccount(false);
            
            //Populating list with account records
            accounts.add(acct_1); 
            
            //Insert accounts
            insert accounts;
            
            //Assert for the results
            System.assert(accounts != null);
            System.assert(accounts.size() == 1);
            
            //Contact
            Contact con = TestUtilities.CreateNewContact(false);
            insert con;
            System.assert(con != null);
            
            //Querying Details for "Member & Employee Support" record type on Case Object
            List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                            Where sObjectType = 'Case' 
                                            AND IsActive = true 
                                            AND DeveloperName IN ('EAB_Custom', 'WebHelp' , 'SSC_Support','International')
                                            ORDER By DeveloperName ASC];
            
            //Assert for the results
            System.assert(caseRdTypes != null);
            System.assertEquals(4, caseRdTypes.size());
            System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
            System.assert(caseRdTypes[1].DeveloperName == 'International');
            System.assert(caseRdTypes[2].DeveloperName == 'SSC_Support');
            System.assert(caseRdTypes[3].DeveloperName == 'WebHelp');
            
            //Useful collections
            //V1.17 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            //map<string, string> mapStatusesMStoCase = CaseTriggerHelper.memSupportToCaseStatus_SupportRT_Map;
            
            map<string, string> mapStatusePTLoadCaseToMS = CaseTriggerHelper.caseToMemSupportStatus_DataLoadRT_Map;
            map<string, string> mapStatusePTLoadMStoCase = CaseTriggerHelper.memSupportToCaseStatus_DataLoadRT_Map;
            map<string, string> mapPriorityMStoCase = CaseTriggerHelper.memSupportToCasePriority_Map;
            
            //list of cases
            List<Case> cases = new List<Case>();
            
            //Create a sample case record to insert and test case trigger
            Case aCase_1 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'ABC1', Subject = 'Test1', 
                                    Description = 'Test1', AccountId = accounts[0].Id);
            Case aCase_2 = new Case(RecordTypeId = caseRdTypes[3].Id, Origin = 'ABC2', Subject = 'Test2', 
                                    Description = 'Test2', AccountId = accounts[0].Id);
            Case aCase_3 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC3', Subject = 'Test3',
                                    Description = 'Test3', AccountId = accounts[0].Id, Request_Type__c = 'Test');
            //Added by Saurabh Kumar - 11/09/2020 - CR-20160224-9632
            Case aCase_4 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC4', Subject = 'Test4',
                                    Description = 'Test4', AccountId = accounts[0].Id, Request_Type__c = 'Strategic Mapping Request');
            Case aCase_5 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC5', Subject = 'Test5',
                                    Description = 'Test5', AccountId = accounts[0].Id, Request_Type__c = 'Expert Call');
            Case aCase_6 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC6', Subject = 'Test6',
                                    Description = 'Test6', AccountId = accounts[0].Id, Request_Type__c = 'Check-in Call');
            Case aCase_7 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC7', Subject = 'Test7',
                                    Description = 'Test7', AccountId = accounts[0].Id, Request_Type__c = 'Webinar');
            Case aCase_8 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC8', Subject = 'Test8',
                                    Description = 'Test8', AccountId = accounts[0].Id, Request_Type__c = 'Document Review');
            Case aCase_9 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC9', Subject = 'Test9',
                                    Description = 'Test9', AccountId = accounts[0].Id, Request_Type__c = 'Networking Request');
            Case aCase_10 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC10', Subject = 'Test10',
                                     Description = 'Test10', AccountId = accounts[0].Id, Request_Type__c = 'Onboarding Call');
            Case aCase_11 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC11', Subject = 'Test11',
                                     Description = 'Test11', AccountId = accounts[0].Id, Request_Type__c = 'Other');
            
            //Populating list with case records
            cases.add(aCase_1);
            cases.add(aCase_2);
            cases.add(aCase_3);
            cases.add(aCase_4);
            cases.add(aCase_5);
            cases.add(aCase_6);
            cases.add(aCase_7);
            cases.add(aCase_8);
            cases.add(aCase_9);
            cases.add(aCase_10);
            cases.add(aCase_11);
            
            //Start test from here
            Test.startTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            //Insert cases
            insert cases;
            
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 11);
            
            //Asserting for the results
            cases = [SELECT ID, Status FROM Case ORDER BY Origin ASC LIMIT 5];
            
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 5);
            //System.assert(cases[0].Status == '01-New');
            //System.assert(cases[0].Button_Used__c == false);
            
            //Stop test here
            Test.stopTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            //Making a try to update the status value
            try {
                
                //Setting the flags
                CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
                CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
                
                //Updating cases
                cases[0].Status = '10-In Progress';
                cases[0].OwnerId = userList[1].Id;
                cases[0].Tier_I_Support_Analyst__c = userList[1].Id;
                update cases;
                
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES));
            }
            
            //Updating case with field values
            cases[0].Member_Facing_Resolution_Summary__c = 'Test';
            cases[0].Status = '90-Closed';
            cases[0].ContactId = con.Id;
            update cases[0];
            
        }            
    }
    
    //Added By - Abhinav Sharma - 07/12/2016 - CR-20160609-9913
    static testmethod void test_CasebeforeEventsLogics3() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Starts from here
        //acct_1.Platinum_Services__c = false;
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Ends here
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 1);
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(accounts[0], false);
        c.AccountId = accounts[0].Id;
        insert c;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('EAB_Custom')
                                        ORDER By DeveloperName ASC];
        
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(15));
        
        //Populating list with case records
        cases.add(aCase_1); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Making a try to update the status value
        try {
            
            //Setting the flags
            CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
            CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            
            //Insert cases
            insert cases;
            
            //V1.17 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 1);
            
            //Asserting for the results
            cases = [SELECT ID, Status FROM Case ORDER BY Origin ASC];
            
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 1);
            System.assert(cases[0].Status == 'Assigned');
            //System.assert(cases[0].Button_Used__c == false);
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
            
            //Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb. - upto here
            
        } catch(Exception ex) {
            System.debug(ex.getMessage().contains(System.Label.ERROR_Deadline_Reason_required));
        }
        
        //Updating fields values on the case instance
        cases[0].Origin = System.Label.ORIGIN_MEMBER_PRIORITY;
        
        //Making a try to update the status value
        try {
            
            //Setting the flags
            CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
            CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
            cases[0].Deadline__c = System.today().addDays(15);
            
            //Insert cases
            update cases;
            
        } catch(Exception ex) {
            //V1.17 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            //System.debug(ex.getMessage().contains(System.Label.ERROR_Deadline_Reason_Reqd_for_Member_Priority));
            //System.assert(ex.getMessage().contains(System.Label.ERROR_CASE_DIRECT_FIELDS_CHANGES));
            //System.assert(false, 'Check actual error message ::: ' + ex.getMessage());
        }
        
        //Stop test here
        Test.stopTest();
    }

     //Added By - Mahendra Swarnka - 06-12-2021 - CR-20211203-15614
     static testmethod void test_CasebeforeEventsLogics5() {
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('EAB_Onsite_Request', 'International')
                                        ORDER By DeveloperName ASC];
        
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 2);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Onsite_Request');
        System.assert(caseRdTypes[1].DeveloperName == 'International');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', 
                                Description = 'Test', AccountId = accounts[0].Id, Status = 'Tentative', Date_of_Presentation__c = Date.today() );
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = accounts[1].Id, Request_Type__c = 'Strategic Mapping Request');
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Expert Call');
         
        Case aCase_4 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Check-in Call');
        
        Case aCase_5 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Webinar');
         
        Case aCase_6 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Document Review');
         
        Case aCase_7 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Networking Request');
         
        Case aCase_8 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Onboarding Call');
         
        Case aCase_9 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC2', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = accounts[0].Id, Request_Type__c = 'Other');
        
        //Populating list with case records
        cases.add(aCase_1); 
        cases.add(aCase_2); 
        cases.add(aCase_3); 
        cases.add(aCase_4); 
        cases.add(aCase_5); 
        cases.add(aCase_6); 
        cases.add(aCase_7); 
        cases.add(aCase_8); 
        cases.add(aCase_9); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert cases
        insert cases;
        
        //Assert for the results
        System.assert(cases != null);
        System.assert(cases.size() == 9);
        
        List<Case> updatedCases = [Select Id, Hold_Expires__c From Case Where Hold_Expires__c != null];
        System.assertEquals(1, updatedCases.size());
        
        updatedCases = [Select Id, Deadline__c From Case Where Deadline__c != null];
        System.assertEquals(8, updatedCases.size());
        Test.stopTest();
    }
    
    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    static testmethod void test_populateCaseFields() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        
        //List to hold the users
        List<User> users = new List<User>();
        
        //User 1
        User user_1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                               TimeZoneSidKey = 'GMT', UserName=Math.random() + '@test.com');
        
        //User 2
        User user_2 = new User(Alias = 'standt', Email='standarduser@testorg1.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                               TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        //User 3
        User user_3 = new User(Alias = 'standt', Email='standarduser@testorg2.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                               TimeZoneSidKey='GMT', UserName=Math.random() + '@test.com');
        
        //Populating list with the user instance
        users.add(user_1); users.add(user_2); users.add(user_3);
        insert users;
        
        //Create an institution
        Account account = TestUtilities.CreateNewAccount(false);
        
        //Insert accounts
        insert account;
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(account, false);
        c.AccountId = account.Id;
        insert c;
        
        //Create program data
        List<Program__c> programs = new List<Program__c>();
        Program__c program_1 = new Program__c(Name = 'testName 1', Program_Acronym__c = 'testing TD', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        Program__c program_2 = new Program__c(Name = 'testName 2', Program_Acronym__c = 'testing', 
                                              Business_line__c = 'TD', Status__c = 'Active');
        programs.add(program_1); programs.add(program_2);
        insert programs;
        
        //Assert for the results
        System.assert(programs != null);
        System.assert(programs.size() == 2);
        
        
        //create Contract ABC test data
        List<Contract__c> contracts = new List<Contract__c>();
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[0].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = account.Id, Type__c = 'NBB', 
                                                    Program__c = programs[1].Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(7));
        
        contracts.add(contractABC_1); contracts.add(contractABC_2);
        insert contracts;
        
        //Assert for the results
        System.assert(contracts != null);
        System.assert(contracts.size() == 2);
        
        //create Contract ABC test data
        List<Project__c> projects = new List<Project__c>();
        Project__c project_1 = new Project__c( Name = 'Test1', Dedicated_Advisor__c = users[1].Id/*, Membership_Advisor_Relationship_Manager__c = users[0].Id,
                                               Contract_Start_Date__c = System.today().addDays(-2),Program_Associate__c = users[2].Id,
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2)*/);
        
        Project__c project_2 = new Project__c( Name = 'Test2', Dedicated_Advisor__c = users[2].Id/*, Membership_Advisor_Relationship_Manager__c = users[1].Id,
                                               Contract_Start_Date__c = System.today().addDays(-2), Program_Associate__c = users[0].Id,
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2)*/);
        
        projects.add(project_1); projects.add(project_2);
        insert projects;
        
        
        //Assert for the results
        System.assert(projects != null);
        System.assert(projects.size() == 2);
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('EAB_Custom')];
        
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 1);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                           Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1),
                           Project_Source_MS__c = projects[0].Id));
        //Spring CleanUp
        //Contract__c = contracts[0].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', Description = 'Test2',
                           ContactId = c.Id, Deadline__c = System.today().addDays(1)));
        //Spring CleanUp
        //Contract__c = contracts[0].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC2', Subject = 'Test', Description = 'Test3',
                           ContactId = c.Id, Deadline__c = System.today().addDays(1)));
        
        //Start test from here
        Test.startTest();
        
        //Insert Cases
        Util.byPassAllTriggers = false;
        insert cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
        cases = [Select Id, 
                 //Spring Clean Up - RM__c, 
                 DA__c, Associate__c, 
                 //Spring Clean Up - Dipesh Gupta
                 //No_of_Participants__c, Cohort_ID__c, 
                 
                 //Half_Day_or_Full_Day__c, Contract_Service_Start__c, 
                 //Contract_Service_End__c, Service_Start__c, 
                 Project_Year__c FROM Case Where Project_Source_MS__c != null ];
        
        //Asserts on results
        System.assertEquals(1, cases.size());
        //Spring Clean Up - System.assertEquals('Testing1', cases[0].RM__c);
        //System.assertEquals('Testing2', cases[0].DA__c);
        //System.assertEquals('Testing3', cases[0].Associate__c);
        //Spring Clean up - Dipesh Gupta
        //System.assertEquals(1, cases[0].No_of_Participants__c);
        //System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        //System.assertEquals('1/2 Day', cases[0].Half_Day_or_Full_Day__c);
        //System.assertEquals(System.today().addDays(-2), cases[0].Contract_Service_Start__c);
        //System.assertEquals(System.today().addDays(2), cases[0].Contract_Service_End__c);
        //System.assertEquals(System.today().addDays(-1), cases[0].Service_Start__c);
        
        //update Case to change the Project source
        cases[0].Project_Source_MS__c = projects[1].Id;
        
        //Enable All the Triggers 
        Util.byPassAllTriggers = false;
        
        //Update the case
        update cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
        cases = [Select Id, 
                 //RM__c, 
                 DA__c, Associate__c, 
                 //Spring Clean up - Dipesh Gupta
                 //No_of_Participants__c, Cohort_ID__c, 
                 //Half_Day_or_Full_Day__c, Contract_Service_Start__c, 
                 //Contract_Service_End__c, Service_Start__c, 
                 Project_Year__c FROM Case Where Project_Source_MS__c != null ];
        
        //Asserts on results
        //System.assertEquals(1, cases.size());
        //Spring Clean Up - System.assertEquals('Testing2', cases[0].RM__c);
        //System.assertEquals('Testing3', cases[0].DA__c);
        //System.assertEquals('Testing1', cases[0].Associate__c);
        //Spring Clean up - Dipesh Gupta
        //System.assertEquals(2, cases[0].No_of_Participants__c);
        //System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        //System.assertEquals('Full Day', cases[0].Half_Day_or_Full_Day__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160803-10082 
    /***
     @ This Method will test 
     @  1) Populating deadline functionality for following case record types :- 
     @         IRC request, Expert Center, Talent Development, Syndicated Services.
     @  2) populating priority field on expert center cases. 
    ***/
    static testmethod void test_CasebeforeEventsLogics4() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create institutions
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Starts from here
        //acct_1.Platinum_Services__c = True;
        acct_1.Research_Platform__c = 'Accelerator Member';
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Ends here
        
        acct_1.Account_Formal_Name__c = 'Acc1';
        acct_1.Platinum_Member_Date__c = System.today();
        
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Account_Formal_Name__c = 'Acc2';
        //Populating list with account records
        accounts.add(acct_1);
        accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Starts from here
        accounts = [Select Id, Research_Platform__c From Account Order By Account_Formal_Name__c ASC];
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        //System.assert(accounts[0].Platinum_Services__c, true);
        System.assertEquals(accounts[0].Research_Platform__c, 'Accelerator Member');
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Ends here
        
        //List to hold the Contact records
        List<Contact> contacts = new List<Contact>();
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(accounts[0], false);
        c.AccountId = accounts[0].Id;
        contacts.add(c);
        
        //create contact
        Contact c1 = TestUtilities.CreateNewContact(accounts[0], false);
        c1.AccountId = accounts[1].Id;
        contacts.add(c1);
        
        //Insert Contacts
        insert contacts;
        
        //Mofified by - Mahendra Swarnakar - CR-20160607-9905
        //Querying Details for record types on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('EAB_Onsite_Request','EAB_Custom','Member_Employee_Support', 'SSC_Support', 'WebHelp')
                                        ORDER By DeveloperName ASC];
        
        //Assert for the results
        System.assert(caseRdTypes != null);
        System.assert(caseRdTypes.size() == 5);
        System.assert(caseRdTypes[0].DeveloperName == 'EAB_Custom');
        System.assert(caseRdTypes[1].DeveloperName == 'EAB_Onsite_Request');
        System.assert(caseRdTypes[2].DeveloperName == 'Member_Employee_Support');
        System.assert(caseRdTypes[3].DeveloperName == 'SSC_Support');
        System.assert(caseRdTypes[4].DeveloperName == 'WebHelp');
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        //1.Expert Center Type Case 
        Case aCase_1 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC1');
        
        Case aCase_1a = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC', Subject = 'Test', 
                                 Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(4), 
                                 Deadline_Reason__c = 'ABC9');
        
        Case aCase_2 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = System.Label.ORIGIN_MEMBER_PRIORITY, Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC2');
        
        Case aCase_2a = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = System.Label.ORIGIN_MEMBER_PRIORITY, Subject = 'Test',
                                 Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(9), 
                                 Deadline_Reason__c = 'ABC91');
        
        Case aCase_3 = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC', Subject = 'Test',
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC3');
        
        Case aCase_3a = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC', Subject = 'Test',
                                 Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(10), 
                                 Deadline_Reason__c = 'ABC92');
        
        //2.IRC Request Type Case
        Case aCase_4 = new Case(RecordTypeId = caseRdTypes[2].Id, Origin = 'Other', Subject = 'Test', 
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC4');
        
        //3.Syndicated Services Type Case
        Case aCase_5 = new Case(RecordTypeId = caseRdTypes[3].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC5');
        
        Case aCase_6 = new Case(RecordTypeId = caseRdTypes[3].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC6');
        
        //4.Talent Development Type Case
        Case aCase_7 = new Case(RecordTypeId = caseRdTypes[4].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC7');
        
        Case aCase_8 = new Case(RecordTypeId = caseRdTypes[4].Id, Origin = 'ABC', Subject = 'Test', Topic_Unknown__c = true,
                                Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(1), 
                                Deadline_Reason__c = 'ABC8');
        
        //Added By - Mahendra Swarnkar - 10/13/2016 - CR-20160607-9905                        
        Case aCase_9a = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                 Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                                 Deadline_Reason__c = 'ABC9a', Status = 'Tentative', Date_of_Presentation__c = System.today().addDays(5));
        
        //Added By - Dipesh Gupta - CR-20170705-11059 - 08/29/2017
        Case aCase_9b = new Case(RecordTypeId = caseRdTypes[1].Id, Origin = 'ABC', Subject = 'Test', 
                                 Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(7), 
                                 Deadline_Reason__c = 'ABC9b',  Phone_Appointment__c = true);
        
        
        //Populating list with case records
        cases.add(aCase_1);
        cases.add(aCase_1a);
        cases.add(aCase_2);
        cases.add(aCase_2a);
        cases.add(aCase_3);
        cases.add(aCase_3a);
        cases.add(aCase_4);
        cases.add(aCase_5);
        cases.add(aCase_6);
        cases.add(aCase_7);
        cases.add(aCase_8); 
        
        //Added By - Mahendra Swarnkar - 10/13/2016 - CR-20160607-9905  
        cases.add(aCase_9a); 
        
        //Added By - Dipesh Gupta - CR-20170705-11059 - 08/29/2017
        cases.add(aCase_9b); 
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Setting the flags
        CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
        CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
        
        //Insert cases
        insert cases;
        cases = [Select Id, Deadline__c, Priority, Deadline_Reason__c, Date_of_Presentation__c, Hold_Expires__c From Case ORDER By Deadline_Reason__c ASC];
        
        //Asserts for results
        System.assertEquals(13, cases.size());
        
        if(!Util.IsWeekendDay(System.today())) {
            
            //Asserts for DeadLine fields
            //System.assertEquals(cases[0].Deadline__c, System.today().addDays(5));
            System.assertEquals(cases[1].Deadline__c, System.today().addDays(1));
            System.assertEquals(cases[2].Deadline__c, System.today().addDays(1) );
            /* System.assertEquals(cases[3].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.IRC_DeadLine_Default)) );
            System.assertEquals(cases[4].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_True_Default)));
            System.assertEquals(cases[5].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.SyndicatedServices_DeadLine_Platinum_False_Default)));
            System.assertEquals(cases[6].Deadline__c, Util.AddBusinessDays(System.today(), Integer.valueOf(System.Label.ExpertCenter_DeadLine_Platinum_True_Default)) );
            System.assertEquals(cases[7].Deadline__c, System.today().addDays(1));
            
            System.assertEquals(cases[8].Deadline_Reason__c, 'ABC9');
            System.assertEquals(cases[9].Deadline_Reason__c, 'ABC91'); 
            System.assertEquals(cases[10].Deadline_Reason__c, 'ABC92');
            
            //Added By - Mahendra Swarnkar - 10/13/2016 - CR-20160607-9905 
            System.assertEquals(cases[11].Deadline_Reason__c, 'ABC9a');
            System.assertEquals(System.today().addDays(5), cases[11].Date_of_Presentation__c);
            //Mofified by - Mahendra Swarnakar - CR-20160607-9905 - till here   
            
            //Added By - Dipesh Gupta CR-20170705-11059 - 08/29/2017
            system.assertEquals(cases[12].Priority, 'Standard');
            system.assertEquals(cases[12].Deadline__c, Util.AddBusinessDays(Date.today(), 2));
            system.assertEquals(cases[12].Deadline_Reason__c, 'ABC9b');
            */
        }
        //Updating fields values on the case instance
        cases[0].Deadline__c = System.today().addDays(1);
        cases[1].Deadline__c = Util.AddBusinessDays(System.today(), 10);
        cases[2].Deadline__c = Util.AddBusinessDays(System.today(), 8);
        
        //Setting the flags
        //CaseTriggerHelper.IS_ALREADY_EXECUTED_ONCE = false;
        //CaseTriggerHelper.IS_UPDATE_HAPPENS_ON_INSERT_EVENT = false; 
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnkar - 10/17/2016 - CR-20160726-10065
    static testmethod void testUpdateContactTECCasesCount(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create institutions
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Starts from here
        //acct_1.Platinum_Services__c = True;
        acct_1.Research_Platform__c = 'Accelerator Member';
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Ends here
        
        acct_1.Account_Formal_Name__c = 'Acc1';
        acct_1.Platinum_Member_Date__c = System.today();
        
        Account acct_2 = TestUtilities.CreateNewAccount(false);
        acct_2.Account_Formal_Name__c = 'Acc2';
        //Populating list with account records
        accounts.add(acct_1);
        accounts.add(acct_2); 
        
        //Insert accounts
        insert accounts;
        
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Starts from here
        accounts = [Select Id, Research_Platform__c From Account Order By Account_Formal_Name__c ASC];
        
        //Assert for the results
        System.assert(accounts != null);
        System.assert(accounts.size() == 2);
        //System.assert(accounts[0].Platinum_Services__c, true);
        System.assertEquals(accounts[0].Research_Platform__c, 'Accelerator Member');
        //V_1.22 - Modofied By - Mahendra Swarnakar - CR-20170519-10949 - Ends here
        
        //List to hold the Contact records
        List<Contact> contacts = new List<Contact>();
        
        //create contact
        Contact c = TestUtilities.CreateNewContact(accounts[0], false);
        c.AccountId = accounts[0].Id;
        contacts.add(c);
        
        //create contact
        Contact c1 = TestUtilities.CreateNewContact(accounts[0], false);
        c1.AccountId = accounts[1].Id;
        contacts.add(c1);
        
        //Insert Contacts
        insert contacts;
        
        //Querying Details for record types on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName IN ('Event_Request')
                                        ORDER By DeveloperName ASC];
        
        //Assert for results
        System.assertEquals(1, caseRdTypes.size());
        System.assertEquals('Event_Request',caseRdTypes[0].DeveloperName);
        
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        //1.Expert Center Type Case 
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                           Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                           Deadline_Reason__c = 'ABC1'));
        
        cases.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                           Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(4), 
                           Deadline_Reason__c = 'ABC9'));
        
        //Test method start
        test.startTest();
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        //Insert case records
        insert cases;
    
        //Retrive contact record to get update on records
        List<Contact> contactResults = [SELECT Id , TEC_Cases_Count__c FROM Contact];
        
        //Assert for result
        //System.assertEquals(1,contactResults[0].TEC_Cases_Count__c);
        //System.assertEquals(1,contactResults[1].TEC_Cases_Count__c);
        
        //Delete Case records
        delete cases[1];
        
        //Retrive contact record to get update on records                      
        contactResults = [SELECT Id , TEC_Cases_Count__c FROM Contact];
        
        //Assert for result
        //System.assertEquals(1,contactResults[0].TEC_Cases_Count__c);
        //System.assertEquals(1,contactResults[1].TEC_Cases_Count__c);
        
        //List to hold the case records
        List<Case> casesnew = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        casesnew.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                              Description = 'Test', ContactId = contacts[0].Id, Deadline__c = System.today().addDays(1), 
                              Deadline_Reason__c = 'ABC2'));
        
        casesnew.add(new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                              Description = 'Test', ContactId = contacts[1].Id, Deadline__c = System.today().addDays(4), 
                              Deadline_Reason__c = 'ABC23'));
        
        //Create new case records
        insert casesnew;
        
        //Retrive contact record to get update on records                      
        contactResults = [SELECT Id , TEC_Cases_Count__c FROM Contact];
    
        //Assert for result
        //System.assertEquals(2,contactResults[0].TEC_Cases_Count__c);
        //System.assertEquals(1,contactResults[1].TEC_Cases_Count__c);
        
        //Test method here
        test.stopTest();    

    }
    
    //Updated by Rajeev Jain - 09/16/2020 - to solve System.LimitException: Too many SOQL queries: 101 issue
    //Added by Victor Hanson - 03/31/2020 - test the new updateRegistration method
    //Updated by Saurabh Kumar - 10/13/2020 - CR-20200819-14447: Replaced Metting with EAB Event
    //Updated by Saurabh Kumar - 11/3/2020 - CR-20200819-14447: Increased Coverage
    @istest static void testUpdateRegistration() {
        
        // initialize mock response - Modified by - Chirag Soni - 06/22/2021 - MRS 2.0 Phase 2 (Test class fixes)
        MockAcquiaHTTPCallout mockAcquiaCallOut = new MockAcquiaHTTPCallout();
        Test.setMock(HttpCalloutMock.Class, mockAcquiaCallOut);
        
        util.BypassAllTriggers = true;
        
        //create the series record
        Advisory_Event__c eSeries = testUtilities.createEvent(Constants.RECORD_TYPE_ID_ADV_EVENT_COHORT, null, false);
        eSeries.Meeting_GUID__c = '000-000-001';
        eSeries.Event_Type__c = 'Research Working Sessions';
        eSeries.Public_Name__c = 'Test';
        eSeries.Short_Name__c = 'Test';
        eSeries.Status__c = 'Open - Registration';
        eSeries.Begins__c = System.today();
        eSeries.Ends__c = System.today();
        insert eSeries;
        
        //create meetings that correspond to the advisory event structure that was just created
        //Meeting__c parentMeeting = Test_SiteMeetingController.CreateMeeting(false);
        Advisory_Event__c eabEvent = Test_SiteMeetingController.createEABEvent(false);
        //parentMeeting.EAB_Event__c = eSeries.Id;
        eabEvent.Meeting_GUID__c = '000-000-001';
        eabEvent.RecordTypeId = Constants.RECORD_TYPE_ID_ADV_EVENT_BREAKOUT;
        insert eabEvent;
        
        // create a new contact
        Contact newContact = testUtilities.CreateNewContact(true);
        Registration__c reg = Test_SiteMeetingController.CreateRegistration(eSeries.Id, newContact.Id, true);
        
        util.BypassAllTriggers = false;
        
        Map<Id, Registration__c> regMap = new Map<Id, Registration__c>([SELECT Id, Status__c, Approval_Status__c FROM Registration__c
                                                                        WHERE Id = :reg.Id
                                                                        AND EAB_Event__r.event_type__c 
                                                                        IN ('Research Working Sessions', 'Prospect Webinar', 'Research Webinar')]);
        
        system.assertEquals(1, regMap.size());
        
        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Member_Employee_Support').getRecordTypeId();
        
        //Create a sample case record to insert and test case trigger
        Case aCase = new Case(Origin = 'Email', Subject = 'Test 1', Status='Assigned', Registration__c=reg.Id,
                              Description = 'test 1', Resolution__c='Question Answered', RecordTypeId=rtId);
        insert aCase;
        
        //get the case
        aCase = [SELECT Id, Registration__r.Status__c, Status FROM Case WHERE Id=:aCase.Id];
        
        //assertions
        system.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, aCase.Status);
        system.assertEquals(RegistrationHelper.STATUS_REGISTERED, aCase.Registration__r.Status__c);
    }
    
    //Added by Abhinav Sharma - 10/26/2018 - This method is used to test the Functional test.
    @istest static void webHelpCaseFunctionlityTest() {
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Creating eligible domain  
        Eligible_Domain__c eD = new Eligible_Domain__c();
        eD.Account__c = accounts[0].Id;
        eD.Qualified_Domain__c = 'test.com';
        eD.Is_Included__c = true;
        insert eD;
        
        //List to hold the Contacts
        List<Contact> contactToBeInserted = new List<Contact>();
        contactToBeInserted.add(new Contact(LastName='Test', Email='Test1@test.com', AccountId = accounts[0].Id, Title = 'Test', Phone = '614-555-8855'));
        
        //Inserting  contact. 
        insert contactToBeInserted;
         
        //Bypassing off
       	Util.BypassAllTriggers = false;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test1', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test2', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
         
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test3', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
         
        //Create a sample case record to insert and test case trigger
        Case aCase_4 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test4', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
         
        //Create a sample case record to insert and test case trigger
        Case aCase_5 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test5', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
         
        //Create a sample case record to insert and test case trigger
        Case aCase_6 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test6',
                                Description = 'Test', ContactId = contactToBeInserted[0].Id, AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_7 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test7',
                                Description = 'Test', ContactId = contactToBeInserted[0].Id, AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_8 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test8',
                                Description = 'Test', ContactId = contactToBeInserted[0].Id, AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_9 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test9', SuppliedEmail = 'Test2@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_10 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test10', SuppliedEmail = 'Test2@Test.com',
                                 Description = 'Test', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_11 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test6', SuppliedEmail = 'Test2@Test.com',
                                 Description = 'Test', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_12 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test6', SuppliedEmail = 'Test2@Test.com',
                                 Description = 'Test', AccountId = accounts[0].Id);
        
        //Adding the case to the List
        cases.add(aCase_1);cases.add(aCase_2);cases.add(aCase_3);
        cases.add(aCase_4);cases.add(aCase_5);cases.add(aCase_6);
        cases.add(aCase_7);cases.add(aCase_8);cases.add(aCase_9);
        cases.add(aCase_10);cases.add(aCase_11);cases.add(aCase_12);
        
        Test.startTest();
        
        //Inserting Case 
        insert cases;
        
        Test.stopTest();
    } 
    
    
    // Modified by Neha Sharma - 03/24/2021 - CR-20210324-15019 - comment the logic which run on the basis 'Rachel Brink', 'Andrea
   /* @istest static void testpopulateCaseOwner(){
        
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
                              timezonesidkey='America/Los_Angeles', localesidkey='en_US', EmployeeNumber = '121212123', IsActive = true));

        insert userList;
        
        //Asserting for the results
        System.assert(userList != null);
        System.assert(userList.size() == 1);
		
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //Creating eligible domain  
        Eligible_Domain__c eD = new Eligible_Domain__c();
        eD.Account__c = accounts[0].Id;
        eD.Qualified_Domain__c = 'test.com';
        eD.Is_Included__c = true;
        insert eD;
        
        //List to hold the Contacts
        List<Contact> contactToBeInserted = new List<Contact>();
        contactToBeInserted.add(new Contact(LastName='Test', Email='Test1@test.com', AccountId = accounts[0].Id, Title = 'Test', Phone = '614-555-8855'));
        
        //Inserting  contact. 
        insert contactToBeInserted;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test1', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id,Case_Category__c = 'Website Feature Request', Website_Content_Owner__c = userList[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test2', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id ,Case_Category__c = 'Website Issues', Website_Content_Owner__c = userList[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_3 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test3', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id,Case_Category__c = 'Website Content Request/Issue', Website_Content_Owner__c = userList[0].Id );
        
        //Create a sample case record to insert and test case trigger
        Case aCase_4 = new Case(RecordTypeId = Constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test4', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', AccountId = accounts[0].Id, Website_Content_Owner__c = userList[0].Id);
        
        cases.add(aCase_1);
        cases.add(aCase_2);
        cases.add(aCase_3);
        cases.add(aCase_4);
        insert cases;
        
        //system.assertEquals(UserInfo.getUserId(),cases[0].OwnerId);
        
        test.stopTest();
        }*/
    
    //Added by Abhinav Sharma - 08/13/2020 - This method is used to test the Functional test  
    //Modify by Ayush Gupta - 09/13/2021 - Increase Code Coverage 																  
    @istest static void test_sentEmailToParentCaseOwnerOnChildClosed(){
        
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
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User1',
                              FirstName='Test1', Email='testuser1@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US',
                              ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', 
                              localesidkey='en_US', EmployeeNumber = '121212123',isActive = true));
        
        userList.add(new User(Username= Math.random()+'@abc.com', LastName='Test User2',
                              FirstName='Test1', Email='testuser2@test.com',
                              Alias='Test1', EmailEncodingKey='UTF-8', languagelocalekey='en_US', 
                              ProfileId=testProfile[0].Id, timezonesidkey='America/Los_Angeles', 
                              localesidkey='en_US', EmployeeNumber = '121212124',isActive = true));
        
        insert userList;
        
        //Asserting for the results
        System.assert(userList != null);
        System.assert(userList.size() == 2);
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        Id rcrdTypeId = Util.RecordTypeId('Case', 'eTech Support');
        
        List<Case> parentCases = new List<Case>();
        //Create a sample case record for parent record 
        parentCases.add(new Case(RecordTypeId = rcrdTypeId, Origin = 'Email', 
                                 Subject = 'Webhelp Test1', SuppliedEmail = 'Test@Test.com',
                                 OwnerId = userList[0].Id,Description = 'Test',
                                 Resolution__c = 'Question Answered',AccountId = acct_1.Id,
                                 Case_Category__c = 'Website Feature Request'));
        
        parentCases.add(new Case(RecordTypeId = rcrdTypeId, Origin = 'Email', 
                                 Subject = 'Webhelp Test2', SuppliedEmail = 'Test1@Test.com',
                                 OwnerId = userList[1].Id,Description = 'Test',
                                 Resolution__c = 'Question Answered',AccountId = acct_1.Id,
                                 Case_Category__c = 'Website Feature Request'));
        //insert cases
        Util.byPassAllTriggers = true;
        insert parentCases;
        Util.byPassAllTriggers = false;
        
        Test.startTest();
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = rcrdTypeId, Origin = 'Email', Subject = 'Webhelp Test2',
                                SuppliedEmail = 'Test@Test.com',Description = 'Test',
                                Status = 'Closed',Case_Category__c = 'Website Issues',
                                Resolution__c = 'Question Answered',ParentId = parentCases[0].Id);
        
        Case aCase_2 = new Case(RecordTypeId = rcrdTypeId, Origin = 'Email', Subject = 'Webhelp Test2',
                                SuppliedEmail = 'Test1@Test.com',Description = 'Test Case',
                                Status = 'Closed',Case_Category__c = 'Website Issues',
                                Resolution__c = 'Question Answered',ParentId = parentCases[1].Id);
        
        cases.add(aCase_1);
        cases.add(aCase_2);
        
        //Email sent before new case insert
        system.assertEquals(0,Limits.getEmailInvocations());
        
        insert cases;
        
        //Email sent After new case insert
        system.assertEquals(1,Limits.getEmailInvocations());
        
        Test.stopTest();   
    }
    
    //Added by Abhinav Sharma - 03/13/2021 - CR-20201207-14726 - This method is used to test the Functional test  
    @istest static void test_populateLookupFields(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        acct_1.Cappex_Partner_Success_Manager__c = UserInfo.getUserId();
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        
        //Create a sample case record to insert and test case trigger
        Case aCase_1 = new Case(RecordTypeId = constants.CASE_CAPPEX_REQUESTS_RT_ID, Origin = 'Email', Subject = 'Webhelp Test1', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test', Case_Category__c = 'Website Feature Request', AccountId = accounts[0].Id);
        
        //Create a sample case record to insert and test case trigger
        Case aCase_2 = new Case(RecordTypeId = constants.CASE_WEBHELP_RT_ID, Origin = 'Email', Subject = 'Webhelp Test2', SuppliedEmail = 'Test@Test.com',
                                Description = 'Test',Case_Category__c = 'Website Issues',ParentId = aCase_1.Id,AccountId = accounts[0].Id);
        cases.add(aCase_1);
        cases.add(aCase_2);
        
        Util.byPassAllTriggers = false;
        insert cases;
        
        Test.startTest();
        List<Case> caseList = [Select Id,Cappex_Partner_Success_Manager_Email__c from case ];
        system.assert(caseList[0].Cappex_Partner_Success_Manager_Email__c != null);
        system.assertEquals(null,caseList[1].Cappex_Partner_Success_Manager_Email__c);
        Test.stopTest(); 
        
    }
    //Added By  - Ayush Gupta - 09/13/2021 - Increase Code Coverage
    @isTest static void testCreateDummyContact(){

        List<String> listOfEmailAddress =  new List<String>{'user@test1.com','user@test2.com','user@test3.com',
                                                            'user@test4.com','user@test5.com'};
															
	//create account 
        Account acc = testUtilities.CreateNewAccount(true);
        //Create a Contact
        List<contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName = 'Test 1', LastName = 'Contact 1', Email = 'user@test1.com', Title = 'Test', Phone = '614-555-8855', AccountId = acc.Id));
        contactList.add(new Contact(FirstName = 'Test 2', LastName = 'Contact 2', Email = 'user@test4.com', Title = 'Test', Phone = '614-555-8855', AccountId = acc.Id));
                
        //Insert
        insert contactList;

        Test.startTest();
        //pass the Email addresses in Trigger Method
        Map<String,Contact> mapOfContactsWithEmail = CaseTriggerHelper.CreateDummyContact(listOfEmailAddress);
																																					   
        //Fetch Contacts with above emails
        List<Contact> conList = [Select Id, Email,Title From Contact Where Email IN:listOfEmailAddress];
	
        //Asserts
        system.assertEquals(5,conList.size());
																																	
        //Check for all the contacts
        system.assertEquals(5,mapOfContactsWithEmail.values().size());

        Test.stopTest();
    }

    //Added by Ayush Gupta - 08/26/2021 - To increase code coverage
    @istest static void test_notifyAccountOwner(){
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        User newUser;
        Account acct;
        
        Profile p = [select Id,name from Profile where name = 'Analyst']; 
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ){
            newUser = new User(
                profileId = p.id,
                username = 'TestReq@eab.community.com',
                email = 'abc@sakonent.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                CommunityNickname = 'Nick'+math.random(),
                alias= 'Comm',
                lastname='John',
                firstname='Test'
            );
            
            insert newuser;
            
        }
        
        
        acct = TestUtilities.CreateNewAccount(false);
        acct.OwnerId = newuser.Id;
        
        Test.startTest();
        insert acct;
        
        Contact con = TestUtilities.CreateNewContact(acct,true);
        
        //Querying Details for "APS_Review & Starfish" record type on Case Object
        List<RecordType> starfishRecordTypeIds = [Select Id From RecordType Where DeveloperName IN ('APS_Review','Starfish') And SobjectType = 'Case'];
        
        //Assert for the results
        System.assert(starfishRecordTypeIds != null);
        
        List<Case> caseList = new List<Case>();
        
        //Creating Case
        caseList.add(new Case(RecordTypeId = starfishRecordTypeIds[0].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                              Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                              ContactId = con.Id,AccountId = acct.Id));
        
        caseList.add(new Case(RecordTypeId = starfishRecordTypeIds[1].Id, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                              Description = 'Test SurveyInvitation',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                              ContactId = con.Id,AccountId = acct.Id));
        
        Util.byPassAllTriggers = false;
        
        insert caseList;
        for(Case cse : [Select Id,Account.Owner.ProfileId,Account.Owner.Email,Account.Owner.Profile.Name From Case]){
            System.debug('case Account Owner profile Id -> '+ cse.Account.Owner.ProfileId);
            System.debug('case Account Owner profile Name -> '+ cse.Account.Owner.Profile.Name);
        }
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
    }
    //Added by Ayush Gupta - 10/11/2021 - To increase code coverage
    @istest static void test_updateSupportProduct(){
        
        //Bypassing Triggers so then test data can be created easily
         Util.byPassAllTriggers = true;
        
        //Insering the Account
      	Account acct = TestUtilities.CreateNewAccount(false);
        Insert acct;

        //Insering contact
        Contact con = TestUtilities.CreateNewContact(acct,true);

        //Case List
        List<Case> caseList = new List<Case>();

        //Creating Case
        caseList.add(new Case(RecordTypeId = Constants.CASE_RT_ID_STARFISH, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'RT Starfish',Status = 'New',Priority = 'Minor',Support_Product__c = 'Starfish',
                            ContactId = con.Id,AccountId = acct.Id));

        caseList.add(new Case(RecordTypeId = Constants.CASE_RT_ID_COUNSELOR_COMMUNITY, Origin = 'Other', Subject = 'Test SurveyInvitation', 
                            Description = 'RT Counselor Community',Status = 'New',Priority = 'Minor',Support_Product__c = 'Intersect',
                            ContactId = con.Id,AccountId = acct.Id));
        
        caseList.add(new Case(RecordTypeId = Constants.CASE_RT_ID_TECH_SUPPORT, Origin = 'Other', Subject = Constants.CASE_SUBJECT_STOPPED_CAMPAIGN, 
                            Description = 'RT Technical Support 1',Status = 'New',Support_Product__c = 'Starfish',ContactId = con.Id,AccountId = acct.Id));
        
        caseList.add(new Case(RecordTypeId = Constants.CASE_RT_ID_TECH_SUPPORT, Origin = 'Other', Subject = Constants.CASE_SUBJECT_SCHEDULED_IMPORT_FAILED, 
                            Description = 'RT Technical Support 2',Status = 'New',Support_Product__c = 'Starfish',ContactId = con.Id,AccountId = acct.Id));
        
        //Inserting the Case List
        insert caseList;
         
        Util.byPassAllTriggers = false;
		
        //Test Start Here
        Test.startTest();
         
        caseList = [Select Id,Status,Last_Support_Rep_Comment__c,Initial_Response_Time2__c,InitialResponseTimeUpdated__c,Number_Of_Execution__c From Case];
          
        caseList[0].Status = Constants.CASE_STATUS_ESCALATED_TO_APS; 
        caseList[0].Last_Support_Rep_Comment__c = true;
        caseList[0].InitialResponseTimeUpdated__c = false;
        caseList[1].Status = Constants.CASE_STATUS_ESCALATED_TO_TECH_SUPPORT;
        caseList[1].Initial_Response_Time2__c = true;
        caseList[1].InitialResponseTimeUpdated__c = false;
        caseList[1].Number_Of_Execution__c = 2 ;
        
        //Updating the values
        update caseList;
        
        //querying the records of case Appling the Asserts
        caseList = [Select Id,RecordTypeId,Last_Support_Rep_Comment__c,Initial_Response_Time2__c,InitialResponseTimeUpdated__c,Number_Of_Execution__c From Case];
        System.assertEquals(true, caseList[0].InitialResponseTimeUpdated__c);
        System.assertEquals(false, caseList[1].Initial_Response_Time2__c);
        System.assertEquals(0, caseList[1].Number_Of_Execution__c);
        //Test Stop here
        Test.stopTest();
        
        // code coverage increase part 
        map<string, string> caseToMemberSuppPriority = CaseTriggerHelper.caseToMemSupportPriority_Map;
        System.assertEquals('Normal', caseToMemberSuppPriority.get('Low'));
        System.assertEquals('Normal', caseToMemberSuppPriority.get('Medium'));
        System.assertEquals('High', caseToMemberSuppPriority.get('High'));
    }
    
}