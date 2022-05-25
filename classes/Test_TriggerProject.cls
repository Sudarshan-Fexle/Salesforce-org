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
private class Test_TriggerProject {
/**
    Purpose         :   Test class for Trigger_Project

    Create By       :   Bhavi Sharma

    Created Date    :   03/25/2013

    Revision Log    :   v1.0 - Created
                        v1.1 - Modified By - Bhavi Sharma - 04/26/2013 - test data added - CR-20130408-2822
                        V1.2 - Modified By - Bhavi Sharma - 06/28/2013 - Code modified - CR-20130617-3170
                        V1.3 - Modified By - Bhavi Sharma - 10/21/2013 - Code modified - CR-20130529-3091
                        V1.4 - Modified By - Bhavi Sharma - 12/23/2013 - Code modified - CR-20130813-3414
                        V1.5 - Modified By - Abhinav Sharma - 03/03/2014 - Code Modified - CR-20130829-3543
                        V1.6 - Modified By - Abhinav Sharma - 04/29/2014 - CR-20140403-4958 - Method Modified (test_populateFirstDeploymentSignedOff)
                        V1.7 - Modified By - Ajit Surana - 08/20/2014 - CR-20140507-5388 - Method modified (test_populateFirstDeploymentSignedOff)
                        V1.8 - Modified By - Ajit Surana - 09/08/2014 - CR-20140716-6256 - test_populateFirstDeploymentSignedOff method is modified
                        V1.9 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138 - New method test_populateDeploymentSignOffOldestOnProject added.
                        v2.0 - Modified By - Abhinav Sharma - 03/10/2015 - CR-20141222-8389 - Method modified - myUnitTest
                        v2.1 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
                        v2.2 - Modified By - Abhinav Sharma - 10/20/2015 - CR-20151016-9329
                        V2.3 - Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added a new Test Method "testPopulateCaseFieldsFromProject".
                        V2.4 - Modified By - Rajeev Jain - 09/10/2016 -  CR-20160420-9785 -
                        V2.5 - Modified By - Overall we wants to check code functionality of 'populateMarketDataPeriodFieldsOnProject' method in ProjectTriggerHelper
                        V2.6 - Modified By - Rajeev Jain - 10/19/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
            		V2.7 - Modified By - Rajeev Jain - 07/29/2016 - CR-20160728-10071 - Services Excellence - Removed references of CCC_Deployment Record Type
                        V2.8 - Modified By - Mahendra Swarnakar - CR-20161110-10358 - 12/10/2016 - Added new method (test_createDeliveryMilestoneTasksOnproject) 
                        V2.9 - Modified By - Abhinav Sharma - CR-20170113-10615 - Modified existing method i.e. "test_populateProjectFieldsFromChildren"
                        V3.0 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Added a new method "Test_sendMailToContactsTaggedASProjectRoles"
                        V3.1 - Modified By - Mahendra Swarnkar - CR-20170616-11008 - 07/11/2017 - Added a new method - testPopulateTVMFieldsOnProjectFromMembership
                        V3.2 - Modified By - Dipesh Gupta - CR-20170426-10878 - 08/30/2017- new Method Added to test the functionality of Project field population from parent Account and Memebrship. method - testProjectFieldPopulation
                        V3.3 - Modified By - Rajeev Jain - Fixed too many soql error - Added bypass trigger flag and reset start and stop test flag in testUpdateProjectByCurrentRenewalOpportunity method.
                        V3.4 - Modified By - Abhinav Sharma - 03/12/2018 - CR-20181025-12706 - new method added populateFieldsOnProjectFromAsset 
                        V3.5 - Modified By - Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'
                        V3.6 - Modified By - Dipesh Gupta - CR-20191204-13550 - 12/24/2019 - modified this method populateFieldsOnProjectFromAsset
                        V3.7 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
			V3.8 - Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Updated method populateFieldsOnProjectFromAsset to populateFieldsOnProjectFromCompTechSystem
 
**/
    static testMethod void myUnitTest() {

        //Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;


        //Create a Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id,
                                            Project_Phase__c = '1 - Test'/*, Implementation_Business_Analyst__c = UserInfo.getUserId()*/);

        //Start testing here
        Test.startTest();

        //Insert project record
        Util.BypassAllTriggers = false;
        insert project;

        //Asset for the results
        mem = [Select Primary_Project__c, BA_Assignment2__c from Membership__c where Id =: mem.Id];
        System.assertEquals(project.Id, mem.Primary_Project__c);
        //System.assertEquals(project.Implementation_Business_Analyst__c, mem.BA_Assignment2__c);

        //Create a new membership record
        Util.BypassAllTriggers = true;
        Membership__c mem2 = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem2;

        //Update Project object
        Util.BypassAllTriggers = false;
        project.Primary_Paid_Membership__c = mem2.Id;
        project.Project_Phase__c = '2 - Build';
        update project;

        //This should update the existing and new membership record
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>([Select Primary_Project__c, BA_Assignment2__c from Membership__c
                                                                                where Id =: mem.Id OR Id =: mem2.Id]);
        System.assertEquals(null, mapMemberships.get(mem.Id).Primary_Project__c);
        System.assertEquals(project.Id, mapMemberships.get(mem2.Id).Primary_Project__c);
        
        //Creata new Project with the Same Membership, This should throw exception
        Project__c project2 = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem2.Id);

        //try to insert the record
        try {

            //Insert the records
            Util.BypassAllTriggers = false;
            insert project2;

            //Code Modified - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
            //This should fail Test method
            System.assert(true);
            
        } catch(Exception e) {

            //Code Modified - Bhavi Sharma - 06/28/2013 - CR-20130617-3170
            //Test case is passed in exception occured
            System.assert(false);
        }

        //blank out the Primary_Paid_Membership__c field
        Util.BypassAllTriggers = false;
        project.Primary_Paid_Membership__c = null;
        update project;

        //Asset for the results
        mem2 = [Select Primary_Project__c from Membership__c where Id =: mem2.Id];
        System.assertEquals(null, mem2.Primary_Project__c);

        //Stop test here
        Test.stopTest();
    }

    //Bhavi Sharma - CR-20130408-2822
    static testMethod void testProjectData() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);

        //Test Name (Renewal), Membership__c, owner name
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Event'
                                                AND DeveloperName =: Constants.RECORD_TYPE_EVENT_DEVELOPER_NAME_BI_QA_CALL
                                                AND IsActive = true limit 1];

        //Asert or the record type
        System.assertEquals(1, recordTypes.size());

        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;

        //Create membership data
        Membership__c mem1 = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem1;

        //Create event data
        Event event = new Event( RecordTypeId = recordTypes[0].Id, Reason_for_Not_Grading_Higher__c = 'Data concerns',
                                    Subject = 'Call', StartDateTime = System.now().addDays(-456),
                                    EndDateTime = System.now().addDays(-450), WhatId = mem.Id, Cancelled_Did_Not_Occur__c = false,
                                    Would_Buy_Again__c = '2', Event_Type__c = 'Quality Assurance');

        //insert event
        insert event;
        
        //List to hold the project records
        List<Project__c> projects = new List<Project__c>();

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
        Project__c project1 = new Project__c(Name = 'Test1', Institution__c = acc.Id, Primary_Paid_Membership__c = mem1.Id);
        projects.add(project);
        projects.add(project1);
        
        //Start testing from here
        Test.startTest();
        
        //Enable triggers again
        Util.BypassAllTriggers = false;

        //Insert Project
        insert projects;
        
        //Assert for the results
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project = [Select Id, /*PT_QA_Call_Event_DT__c,*/ PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        //System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        //System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event.StartDateTime = System.now().addDays(-450);
        event.EndDateTime = System.now().addDays(-449);

        Event event1 = new Event( RecordTypeId = recordTypes[0].Id, Reason_for_Not_Grading_Higher__c = 'Data concerns',
                                    Subject = 'Call', StartDateTime = System.now().addDays(-445),
                                    EndDateTime = System.now().addDays(-440), WhatId = mem.Id, Cancelled_Did_Not_Occur__c = false,
                                    Would_Buy_Again__c = '2', Event_Type__c = 'Quality Assurance');

        //insert event
        Util.BypassAllTriggers = false;
        update event;
        insert event1;

        //Assert for the results
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        //System.assertEquals(event1.StartDateTime, project.PT_QA_Call_Event_DT__c);
        //System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);
        
        //Stop Test here
        Test.stopTest();

        //Update project
        //project.PT_QA_Call_Event_DT__c = null;
        //project.PT_QA_Call_Recommended_Score__c = null;
        Util.BypassAllTriggers = false;
        update project;

        //Assert for the results
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project = [Select Id,/* PT_QA_Call_Event_DT__c,*/ PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        //System.assertEquals(event1.StartDateTime, project.PT_QA_Call_Event_DT__c);
        //System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event1.WhatId = mem1.Id;
        Util.BypassAllTriggers = false;
        /*update event1;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //Assert for the results
        project1 = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[1].Id];
        System.assertEquals(event1.StartDateTime, project1.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event1.Would_Buy_Again__c), project1.PT_QA_Call_Recommended_Score__c);

        //update event
        event.Would_Buy_Again__c = '8';
        event.StartDateTime = System.now().addDays(-440);
        event.EndDateTime = System.now().addDays(-430);
        Util.BypassAllTriggers = false;
        update event;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(Integer.valueOf(event.Would_Buy_Again__c), project.PT_QA_Call_Recommended_Score__c);

        //update event
        event.Would_Buy_Again__c = 'N/A';
        Util.BypassAllTriggers = false;
        update event;

        //Assert for the results
        project = [Select Id, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c FROM Project__c WHERE Id =: projects[0].Id];
        System.assertEquals(event.StartDateTime, project.PT_QA_Call_Event_DT__c);
        System.assertEquals(null, project.PT_QA_Call_Recommended_Score__c); */
    }

    //Bhavi Sharma - CR-20130328-2773
    public static testMethod void testUpdateProjectByCurrentRenewalOpportunity() {

        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity'
                                                AND Name =: Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE
                                                AND IsActive = true limit 1];

        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
    
    //Bypass trigger
    Util.ByPassAllTriggers = true;
    
        //delete acc.Memberships__r;
        Account acc = new Account(Name = 'testacc', Account_Formal_Name__c = 'testacc');
        insert acc;
        
        // Test Class Fix Start Here 13Feb By: Dipesh Gupta
        //Creating Contact record 
        Contact cont = TestUtilities.CreateNewContact(True);
        // Test Class Fix End Here 13Feb By: Dipesh Gupta

        //Program__c prog = [select id from Program__c limit 1];
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;

        //Create membership data
        Membership__c mem = new Membership__c(Account_Name__c = acc.id, Program__c = prog.id);
        insert mem;
    
    //Bypass trigger
    Util.ByPassAllTriggers = false;
    
        //List of Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();

        //Opportunity record
        Opportunity opportunity1 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,Main_Contact__c = cont.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect', CloseDate = System.today(),Sales_Pursuit_Products__c = 'APS',
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),Special_Commitments__c = 'TestComitments');

        //Opportunity record
        Opportunity opportunity2 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,Main_Contact__c = cont.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect' ,CloseDate = System.today(),
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),Sales_Pursuit_Products__c = 'APS',
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(2)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity3 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,Main_Contact__c = cont.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),Sales_Pursuit_Products__c = 'APS',
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(-2)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity4 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,Main_Contact__c = cont.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),Sales_Pursuit_Products__c = 'APS',
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(-14)),Special_Commitments__c = 'TestComitments');
        //Opportunity record
        Opportunity opportunity5 = new Opportunity( Name = 'oop1Test', RecordtypeId = recordTypes[0].Id, AccountId = acc.Id,Main_Contact__c = cont.Id,
                                                    Program__c = prog.Id, StageName = 'Prospect',CloseDate = System.today(),Sales_Pursuit_Products__c = 'APS',
                                                    Membership__c = mem.Id,Pool_Year__c = String.valueOf(Date.today().year()),
                                                    Pool_Month__c = String.valueOf(Date.today().addMonths(8)),Special_Commitments__c = 'TestComitments');

        opportunities.add(opportunity1);
        opportunities.add(opportunity2);
        opportunities.add(opportunity3);
        opportunities.add(opportunity4);
        opportunities.add(opportunity5);

        //insert Opportunity List
        insert opportunities;

        //Create a Project record
        Project__c project = new Project__c(Name = 'Test', Institution__c = acc.Id, Primary_Paid_Membership__c = mem.Id);
    
    	//Test starts here
        Test.startTest();
    
        //insert Project
        insert project;

        //get record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        project = [SELECT Id, Current_Contract_Risk_Type__c/*,CPM_Special_Considerations__c */ FROM Project__c WHERE Id =: project.Id];

        opportunity1 = [SELECT Special_Commitments__c, Source_Contract_Type__c FROM Opportunity WHERE Id =: opportunities[0].Id];

        //assert statements
        System.assertEquals(project.Current_Contract_Risk_Type__c, opportunity1.Source_Contract_Type__c);
        //System.assertEquals(project.CPM_Special_Considerations__c, opportunity1.Special_Commitments__c);

        //Test stops here
        Test.stopTest();
    }

    //Added By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
    static testmethod void testPopulateCaseFieldsFromProject() {
        
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
        
	// Comment for CR-20200318-13864 
        //create Contract ABC test data
        List<Project__c> projects = new List<Project__c>();
        Project__c project_1 = new Project__c( Name = 'Test1', Dedicated_Advisor__c = users[1].Id/*, Membership_Advisor_Relationship_Manager__c = users[0].Id,
                                               Contract_Start_Date__c = System.today().addDays(-2),
                                               Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2)*/);
        
        Project__c project_2 = new Project__c( Name = 'Test2', Dedicated_Advisor__c = users[2].Id/*,Membership_Advisor_Relationship_Manager__c = users[2].Id,
                                               Contract_Start_Date__c = System.today().addDays(-2), 
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
        //Spring CleanUp
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                Description = 'Test', ContactId = c.Id, Deadline__c = System.today().addDays(1),
                                Project_Source_MS__c = projects[0].Id 
                            // , Contract__c = contracts[0].Id*/
                           ));
        
        //Create a sample case record to insert and test case trigger
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC1', Subject = 'Test', Description = 'Test2',
                                ContactId = c.Id, Deadline__c = System.today().addDays(1), 
                            // Contract__c = contracts[1].Id,
                                Project_Source_MS__c = projects[1].Id));
        
        //Create a sample case record to insert and test case trigger
        cases.add( new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC2', Subject = 'Test', Description = 'Test3',
                                ContactId = c.Id, Deadline__c = System.today().addDays(1)));
        
        //Start test from here
        Test.startTest();
        
        //Insert Cases
        Util.byPassAllTriggers = false;
        insert cases;
        
        //By pass all the triggers
        Util.byPassAllTriggers = true;
        
        //Query through Cases
        cases = [Select Id, Origin, 
                //Spring Clean Up - RM__c, 
                DA__c, Associate__c, 
                //Spring Clean Up - Cohort_ID__c, No_of_Participants__c, 
                // Half_Day_or_Full_Day__c,  Contract_Service_Start__c, Contract_Service_End__c,Service_Start__c, 
                Project_Year__c FROM Case Where Project_Source_MS__c != null ORDER BY Origin ASC];
        
        //Asserts on results
        System.assertEquals(2, cases.size());
        System.assertEquals('ABC', cases[0].Origin);
        //Spring Clean Up - System.assertEquals('Testing1', cases[0].RM__c);
        //System.assertEquals('Testing2', cases[0].DA__c);
        //System.assertEquals('Testing3', cases[0].Associate__c);
        //Spring Clean Up - System.assertEquals(1, cases[0].No_of_Participants__c);
        //System.assertEquals('Testing', cases[0].Cohort_ID__c);
        //System.assertEquals('1/2 Day', cases[0].Half_Day_or_Full_Day__c);
        //System.assertEquals(System.today().addDays(-2), cases[0].Contract_Service_Start__c);
        //System.assertEquals(System.today().addDays(2), cases[0].Contract_Service_End__c);
        //System.assertEquals(System.today().addDays(-1), cases[0].Service_Start__c);
        
        //update Case to change the Project source
        //Spring CleanUp
        //cases[0].Contract__c = contracts[1].Id;
        //cases[1].Contract__c = null;
        
        //Enable All the Triggers 
        Util.byPassAllTriggers = true;
        
        //Update the case
        update cases;
        // comment out - CR-20200318-13865
        //projects[0].Membership_Advisor_Relationship_Manager__c = users[1].Id;
        projects[0].Dedicated_Advisor__c = users[2].Id;
        //projects[0].Program_Associate__c = users[0].Id;
        //projects[0].No_of_Participants__c = 2;
        //projects[0].Cohort_ID_s__c = 'Test_Cohort';
        //projects[0].Full_Day__c = 1;
        //projects[0].X1_2_Day__c = null;
        //projects[0].Contract_Start_Date__c = System.today().addDays(-2);
        //projects[0].Internal_Strat_Session_NPI_Actual__c = System.today().addDays(2);
        //projects[0].Service_Date_Start__c = System.today().addDays(-1);
        
        //projects[1].Membership_Advisor_Relationship_Manager__c = users[2].Id;
        projects[1].Dedicated_Advisor__c = users[0].Id;
        //projects[1].Program_Associate__c = users[1].Id;
        //projects[1].No_of_Participants__c = 4;
        //projects[1].Cohort_ID_s__c = 'Test_Cohort_ABC';
        
        //By pass all the triggers
        Util.byPassAllTriggers = false;
        
        //Update the projects.
        update projects;
        
        //Query through Cases
        cases = [Select Id, Origin, 
                //Spring Clean Up - RM__c, 
                DA__c, Associate__c, 
                 //Spring Clean Up - Cohort_ID__c, No_of_Participants__c, 
                 //Half_Day_or_Full_Day__c, Contract_Service_Start__c, Contract_Service_End__c, Service_Start__c, 
                 Project_Year__c 
                 FROM Case Where Project_Source_MS__c != null ORDER BY Origin ASC ];
        
        //Asserts on results
        //System.assertEquals(2, cases.size());
        //Spring Clean Up - System.assertEquals('Testing2', cases[0].RM__c);
        //System.assertEquals('Testing3', cases[0].DA__c);
        //System.assertEquals('Testing1', cases[0].Associate__c);
        //System.assertEquals(2, cases[0].No_of_Participants__c);
        //System.assertEquals('Test_Cohort', cases[0].Cohort_ID__c);
        //System.assertEquals('Full Day', cases[0].Half_Day_or_Full_Day__c);
        
        //Spring Clean Up - System.assertEquals('Testing3', cases[1].RM__c);
        //System.assertEquals('Testing1', cases[1].DA__c);
        //System.assertEquals('Testing2', cases[1].Associate__c);
        //System.assertEquals(4, cases[1].No_of_Participants__c);
        //System.assertEquals('Test_Cohort_ABC', cases[1].Cohort_ID__c);
        
        //Stop test here
        Test.stopTest();
    }
    
    //Added By - Mahendra Swarnakar - CR-20161110-10358 - 12/10/2016
    static testMethod void test_createDeliveryMilestoneTasksOnproject() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //List of Custom Metadata Type
        List<Delievery_Milestones_Task__mdt> dmts = [SELECT Object_API_Name__c, Record_Type_API_Name__c,
                                                     IsActive__c, Milestone_Field_API_Name__c, Task_Subject__c,
                                                     Due_Date_After__c, DeveloperName, MasterLabel, ID
                                                     FROM Delievery_Milestones_Task__mdt];
        //Checking for the size value
        if(dmts != null && dmts.size() > 0) {
        
            //Getting Record Type Id Value for Project object
          ID sscProjRecordTypeId = [Select Id, Name FROM RecordType 
                                        WHERE SobjectType = 'Project__c' 
                                        AND RecordType.DeveloperName = 'SSC' AND IsActive = true].Id;
        System.assert(sscProjRecordTypeId != null);
        
            //Program Acronyms
            String progAcr = '';
            String progAcrSSC = '';
            
            //Checking for comman splitted string literal
            if(System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(',') != null
               &&
               System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(',').size() > 0
            ) {
                  progAcr = System.Label.PROJECT_APS_PROGRAM_ACRONYMS.split(',')[0];   
                  
            } else {
                  progAcr = System.Label.PROJECT_APS_PROGRAM_ACRONYMS;
            }
            
            //Checking for comman splitted string literal
            if(System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(',') != null
               &&
               System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(',').size() > 0
            ) {
                  progAcrSSC = System.Label.PROJECT_SSC_PROGRAM_ACRONYMS.split(',')[0];   
                  
            } else {
                  progAcrSSC = System.Label.PROJECT_SSC_PROGRAM_ACRONYMS;
            }
            
            //List to hold Account records
            List<Account> accList = new List<Account>();
            accList.add(new Account(Name = 'Test Account1'));
            insert accList;
            System.assert(accList.size() > 0);
            
            //Programs
            List<Program__c> programs = new List<Program__c>();
            Program__c progAPS = new Program__c(Name = 'testprog', Program_Acronym__c = progAcr, 
                                                Status__c = 'Active', Create_Memberships__c = 'No');
            Program__c progSSC = new Program__c(Name = 'testprog', Program_Acronym__c = progAcrSSC, 
                                                Status__c = 'Active', Create_Memberships__c = 'No');
            programs.add(progAPS);
            programs.add(progSSC);
            insert programs;
            System.assert(programs.size() > 0);
            
            // Test Class Fix Start Here 13Feb By: Dipesh Gupta
            //Creating Contact record 
            Contact cont = TestUtilities.CreateNewContact(True);
            // Test Class Fix End Here 13Feb By: Dipesh Gupta
            
            //Opportunity
            Opportunity opportunity = new Opportunity(Name = 'Test Opp', StageName = Constants.CONTRACT_RECEIVED,Main_Contact__c = cont.Id, 
                                                      Amount = 1, CloseDate = System.today(), AccountId = accList[0].ID,Sales_Pursuit_Products__c = 'APS');
            insert opportunity;
            
            //Contract
            Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = programs[0].Id, 
                                                   Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                                   Contract_Renewal_Opportunity__c = opportunity.Id);
            insert contract;
            
            //Update contract record
            contract.Start__c = Date.today() - 7;
            contract.End__c = Date.today() - 7;
            contract.Status__c = Constants.CLOSED;
            update contract;
            
            //List to hold Membership data
            List<Membership__c> membershipList = new List<Membership__c>();
            
            membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                                 Program__c = programs[0].Id, Active_Contract_Idenfied__c = contract.Id,
                                                 Earliest_Contract__c = contract.Id, Latest_Contract__c = contract.Id,
                                                 Membership_Status_Text__c = 'Member - Pure'));
            insert membershipList;
            
            //Project
            List<Project__c> projects = new List<Project__c>();
            Project__c project1 = new Project__c(Name = 'Test-Data', Primary_Paid_Membership__c = membershipList[0].Id,
                                                   RecordTypeId = sscProjRecordTypeId, Product__c = programs[0].ID);
            Project__c project2 = new Project__c(Name = 'Test-Data', RecordTypeId = sscProjRecordTypeId, 
                                                 Product__c = programs[1].ID, Primary_Paid_Membership__c = membershipList[0].Id);
            projects.add(project1);
            projects.add(project2);
            
            //Start test from here
            Test.startTest();
            
            //ENabling triggers
            Util.BypassAllTriggers = false;
            
            //Insert Projects
            insert projects;
            
            //Asserting for the results
            projects = [SELECT ID, Earliest_Contract_Start_Date__c FROM Project__c LIMIT 3];
            System.assertEquals(2, projects.size());
            //System.assertNotEquals(null, projects[0].Earliest_Contract_Start_Date__c);
            //System.assertNotEquals(null, projects[1].Earliest_Contract_Start_Date__c);
            
            //List of Tasks
            //List<Task> tasks = [SELECT ID FROM Task LIMIT 3];
            //System.assert(tasks.size() > 0);
            
            //Stop test here
            Test.stopTest();
        }
    }
     
    
     static testmethod void testProjectFieldPopulation() {
     
    Util.BypassAlltriggers = true;     
         
    //Fetching Record Type of Account 
    List<RecordType> rTypeAcc = [Select Id From RecordType Where Name='US Education' AND sobjectType = 'Account'];
       
    //Adding Institutions
    List<Account> accounts = new List<Account> ();
    accounts.add(new Account (Number_of_Hospitals_in_System__c = 120, Name = 'Test', RecordTypeId = rTypeAcc[0].Id));
    accounts.add(new Account (Number_of_Hospitals_in_System__c = 119, Name = 'Test1', RecordTypeId = rTypeAcc[0].Id));
    
    //Inserting Account 
    insert accounts;
    
    //now Creating Records Of Program
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Creating Record Of Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(1),
                                                    End__c = System.today().addDays(5));
        
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[1].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        contracts.add(contractABC_1);
        contracts.add(contractABC_2);
        
        insert contracts;
       
    //Creating Membership
    List<Membership__c> memberships = new List<Membership__c>();        
    
    memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[0].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[0].Id ));  
        memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[1].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[1].Id ));
        
        insert memberships;
        
        //Test start
        Test.startTest();
        
        //List of project Record type 
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        List<RecordType> rTProject = [Select Id From RecordType where Name = 'Tech' And sobjecttype = 'Project__c'];
     
        //Creating Projects 
        List<Project__c> projects = new list<Project__c> ();
        
        projects.add(new Project__c(Name = 'ProjectTest', Primary_Paid_Membership__c =  memberships[0].Id, Institution__c = accounts[0].Id, RecordTypeId = rTProject[0].Id));
        projects.add(new Project__c(Name = 'ProjectTest1', Primary_Paid_Membership__c =  memberships[1].Id, Institution__c = accounts[1].Id,  RecordTypeId = rTProject[0].Id));
        
        Util.BypassAlltriggers = false;
         
        insert projects;
        
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        List<Project__c> prjs = [Select Id, /*Number_of_Hospitals__c,*/ Annual_Contract_Value__c, Notes_Dedicated_Advisor__c From Project__c order by CreatedDate DESC];
        List<Membership__c> mems = [Select Id, Membership_Status__c, Active_Contract_Annual_Contract_Value__c From Membership__c order by CreatedDate DESC];
        
        system.assertEquals(prjs.size(), 2);
        system.assertEquals(mems.size(), 2);
       /* system.assertEquals(prjs[0].Number_of_Hospitals__c, accounts[0].Number_of_Hospitals_in_System__c);
        system.assertEquals(prjs[1].Number_of_Hospitals__c, accounts[1].Number_of_Hospitals_in_System__c);   
        system.assertEquals(prjs[0].Annual_Contract_Value__c, mems[0].Active_Contract_Annual_Contract_Value__c);
        system.assertEquals(prjs[1].Annual_Contract_Value__c, mems[1].Active_Contract_Annual_Contract_Value__c);*/
        
        /*
        //Updating the Notes advisor
        prjs[0].Notes_Dedicated_Advisor__c  = 'Changed the Advisor';
        update prjs[0];
        
        //Query on the Project
        List<Project__c> prjct = [Select Id, Notes_Dedicated_Advisor__c, Notes_Updated_Date__c From Project__c where Id =: prjs[0].Id];
        
        system.assertEquals('Changed the Advisor', prjct[0].Notes_Dedicated_Advisor__c);
        system.assertEquals(Date.Today(), prjct[0].Notes_Updated_Date__c);   
        */
        
        //Test stop
        Test.stopTest();
        
     }
    
    
    //Modified By Abhinav Sharma - 03/12/2018 - CR-20181025-12706 - Starts here
    //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the assert and data for the degree audit
    //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Updated test method Competitor Tech System object 
    static testmethod void populateFieldsOnProjectFromCompTechSystem() {
        
        Util.BypassAlltriggers = true;
        
         //Fetching Record Type of Account 
        List<RecordType> rTypeAcc = [Select Id From RecordType Where Name='US Education' AND sobjectType = 'Account'];
        
        //Adding Institutions
        List<Account> accounts = new List<Account> ();
        accounts.add(new Account (Number_of_Hospitals_in_System__c = 120, Name = 'Test', RecordTypeId = rTypeAcc[0].Id));
        accounts.add(new Account (Number_of_Hospitals_in_System__c = 119, Name = 'Test1', RecordTypeId = rTypeAcc[0].Id));
        insert accounts;
        
        //now Creating Records Of Program
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Creating Record Of Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(1),
                                                    End__c = System.today().addDays(5));
        
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[1].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        contracts.add(contractABC_1);
        contracts.add(contractABC_2);
        
        insert contracts;
       
        //Creating Membership
        List<Membership__c> memberships = new List<Membership__c>();        
    
        memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[0].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[0].Id ));  
        memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[1].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[1].Id ));
        
        insert memberships;
        
        Id RECORD_TYPE_EXTERNAL_SYSTEM = Schema.SObjectType.Competitor_and_Tech_System__c.getRecordTypeInfosByName().get('External System').getRecordTypeId();
        
        //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Create the asset data for degree audit
        //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Updated test method Competitor Tech System object 
        List<Competitor_and_Tech_System__c> compTechSysList = new List<Competitor_and_Tech_System__c>();
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t1', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t2', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t3', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t4', Tech_System__c ='CRM', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t1', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t2', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t3', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t4', Tech_System__c ='CRM', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='DegreeAudit1', Tech_System__c ='Degree Audit', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='DegreeAudit2', Tech_System__c ='Degree Audit', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        insert compTechSysList;
        
        
        //stop trigger bypass
        Util.BypassAlltriggers = false;
        
        Test.startTest();
        
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'
        //List of project Record type 
        List<RecordType> rTProject = [Select Id From RecordType where Name = 'Tech' And sobjecttype = 'Project__c'];
        
        //Creating Projects 
        List<Project__c> projects = new list<Project__c> ();
        
        projects.add(new Project__c(Name = 'ProjectTest', Primary_Paid_Membership__c =  memberships[0].Id, Institution__c = accounts[0].Id, RecordTypeId = rTProject[0].Id));
        projects.add(new Project__c(Name = 'ProjectTest1', Primary_Paid_Membership__c =  memberships[1].Id, Institution__c = accounts[1].Id,  RecordTypeId = rTProject[0].Id));
        projects.add(new Project__c(Name = 'ProjectTest2', Primary_Paid_Membership__c =  memberships[1].Id, Institution__c = accounts[1].Id,  RecordTypeId = rTProject[0].Id));
        
        insert projects;

        Project__c projectData =[Select Id ,Name, Current_SIS__c, Learning_Management_System__c, Enrollment_CRM__c,Degree_Audit__c From Project__c where Id =: projects[2].Id Limit 1];
        
        System.assertEquals('t3',projectData.Learning_Management_System__c );
        System.assertEquals('t1,t2',projectData.Current_SIS__c );
        //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the assert if not degree audit
        System.assertEquals('t4',projectData.Enrollment_CRM__c );
        //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the assert for degree audit
		System.assertEquals(true, projectData.Degree_Audit__c.contains('DegreeAudit1') );
		System.assertEquals(true, projectData.Degree_Audit__c.contains('DegreeAudit2') );
        
        test.stopTest();
    } 

    //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Add the assert and data for the degree audit (Update case)
    //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Updated test method Competitor Tech System object 
    static testmethod void populateFieldsOnProjectFromCompTechSystemV2() {
        
        Util.BypassAlltriggers = true;
        
         //Fetching Record Type of Account 
        List<RecordType> rTypeAcc = [Select Id From RecordType Where Name='US Education' AND sobjectType = 'Account'];
        
        //Adding Institutions
        List<Account> accounts = new List<Account> ();
        accounts.add(new Account (Number_of_Hospitals_in_System__c = 120, Name = 'Test', RecordTypeId = rTypeAcc[0].Id));
        accounts.add(new Account (Number_of_Hospitals_in_System__c = 119, Name = 'Test1', RecordTypeId = rTypeAcc[0].Id));
        insert accounts;
        
        //now Creating Records Of Program
        Program__c prog = new Program__c(Name = 'testprog', Program_Acronym__c = 'TEST', Status__c = 'Active', Create_Memberships__c = 'Yes');
        insert prog;
        
        //Creating Record Of Contract ABC
        List<Contract__c> contracts = new List<Contract__c>();
        
        Contract__c contractABC_1 = new Contract__c(Payer_Account__c = accounts[0].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(1),
                                                    End__c = System.today().addDays(5));
        
        Contract__c contractABC_2 = new Contract__c(Payer_Account__c = accounts[1].Id, Type__c = 'NBB', 
                                                    Program__c = prog.Id, Start__c = System.today().addDays(-5),
                                                    End__c = System.today().addDays(5));
        contracts.add(contractABC_1);
        contracts.add(contractABC_2);
        
        insert contracts;
       
        //Creating Membership
        List<Membership__c> memberships = new List<Membership__c>();        
    
        memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[0].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[0].Id ));  
        memberships.add(new Membership__c (Name = 'Test', Account_Name__c = accounts[1].Id, Program__c = prog.Id,  Active_Contract_Idenfied__c =  contracts[1].Id ));
        
        insert memberships;
        
        Id RECORD_TYPE_EXTERNAL_SYSTEM = Schema.SObjectType.Competitor_and_Tech_System__c.getRecordTypeInfosByName().get('External System').getRecordTypeId();
        
        //Modify by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Create the asset data for degree audit
        //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Updated test method Competitor Tech System object 
        List<Competitor_and_Tech_System__c> compTechSysList = new List<Competitor_and_Tech_System__c>();
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t1', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t2', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t3', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[0].Id ,Name='t4', Tech_System__c ='CRM', Category__c = 'Enrollment',
                                                             RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t1', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t2', Tech_System__c ='SIS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t3', Tech_System__c ='LMS', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='t4', Tech_System__c ='CRM', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='DegreeAudit1', Tech_System__c ='Degree Audit', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        compTechSysList.add(new Competitor_and_Tech_System__c(Institution__c=accounts[1].Id ,Name='DegreeAudit2', Tech_System__c ='Degree Audit', Category__c = 'Enrollment',
                                                              RecordTypeId = RECORD_TYPE_EXTERNAL_SYSTEM, Start_Date__c = System.Today() - 1, End_Date__c = System.today() + 2));
        insert compTechSysList;
                
        //Modified By Dipesh Gupta - CR-20190529-13156 - 09/04/2019 - Record type Label Modified From 'SSC' To 'Tech'
        //List of project Record type
        Id RECORD_TYPE_ID_SSC_PROJECT = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        //Creating Projects 
        List<Project__c> projects = new list<Project__c> ();
        
        projects.add(new Project__c(Name = 'ProjectTest', Primary_Paid_Membership__c =  memberships[0].Id, Institution__c = accounts[0].Id, RecordTypeId = RECORD_TYPE_ID_SSC_PROJECT));
        projects.add(new Project__c(Name = 'ProjectTest1', Primary_Paid_Membership__c =  memberships[1].Id, Institution__c = accounts[1].Id,  RecordTypeId = RECORD_TYPE_ID_SSC_PROJECT));
        projects.add(new Project__c(Name = 'ProjectTest2', Primary_Paid_Membership__c =  memberships[1].Id, Institution__c = accounts[1].Id,  RecordTypeId = RECORD_TYPE_ID_SSC_PROJECT));
        
        insert projects;

        //stop trigger bypass
        Util.BypassAlltriggers = false;
        
        Test.startTest();
        
        projects[0].Learning_Management_System__c=','; 
        projects[1].Current_SIS__c=',';
        projects[2].Current_SIS__c=',';
        projects[2].Learning_Management_System__c=',';
        projects[2].Enrollment_CRM__c=',';
        
        update projects;
        
        Project__c project2 =[Select Id ,Name, Current_SIS__c, Learning_Management_System__c, Enrollment_CRM__c,Degree_Audit__c From Project__c where Id =: projects[2].Id Limit 1];
        System.debug('project2 ###3 '+project2);
        System.assert(project2 != null);
        System.assertEquals('t3',project2.Learning_Management_System__c );
        System.assertEquals('t1,t2',project2.Current_SIS__c );
        System.assertEquals('t4',project2.Enrollment_CRM__c );
        
        test.stopTest();
    }
}