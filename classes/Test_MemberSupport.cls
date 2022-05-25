/**
    Purpose         :   Test class for Trigger_MemberSupport
                
    Create By       :   Colin McGloin
    
    Created Date    :   8/28/2015
    
    Revision Log    :   V_1.0 - Created - 8/28/2015 - Code Refactoring
                        V_1.1 - Modified By - Abhinav Sharma - 11/28/2015 - CR-20150601-8977 - Added new method (test_CPRMDataLoadTicketUseCases) 
                        V_1.2 - Modified By - Mahendra Swarnakar - 02/15/2016 - CR-20151210-9456 
                        V_1.3 - Modified By - Abhinav Sharma - 04/01/2016 - CR-20160224-9632
                        V_1.4 - Modified By - Victor Hanson - 04/13/2016 - CR-20160413-9760
                        V_1.5 - Modified By - Abhinav Sharma - 05/30/2016 - CR-20150326-8810
                        V_1.6 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
                        V_1.7 - Modified By - Rajeev Jain - 09/10/2016 - CR-20160114-9520 - Added new test method test_MSAcknowledgeFields
                        V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.- 08/09/2016 - Services Excellence
                        V_1.9 - Modified By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - Testing for populateCurrentDataPeriodOnProject method
                        V_2.0 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures - coverage - 87%
                        V_2.1 - Modified By - Mahendra Swarnakar - CR-20161103-10340 - Release 55 - 12/16/2016 - Testing the CCM Data Load Fields values
			V_2.3 - Added By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017 - Added a new Method "Test_SendEmailCMADataLoadAndPRMDataLoadCompletion"
			V_2.4 - Modified by Colin McGloin - Spring Cleaning - Removed test methods which applied to deleted Record Types and Logic 
			V_2.5 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
**/ 
@isTest(seeAllData=false)
Private class Test_MemberSupport {

    // this test is to make sure that issues can be created for a product
    static testMethod void createIssueOnProduct() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;

        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        Id projectRTId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Support Request').getRecordTypeId();
        
        Project__c project = new project__c(RecordTypeId = projectRTId);
        insert project;
        system.assertNotEquals(null,project.id);
        
        //Member Support
        Site_issue__c issue1 = new site_issue__c();
        issue1.project__c = project.id;
        issue1.Data_Load_Type__c = Constants.CURRENT;
        issue1.site_issue_short_description__c = 'none';
        //issue1.site_issue_close_date__c = system.now();
        //issue1.site_issue_close_date__c = system.today();
        
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //issue1.status__c = '06 - Issue Resolved - Ticket Closed';
        //issue1.status__c = Constants.STATUS_SITE_ISSUE_CLOSED;
        issue1.Status__c = Constants.MEMBER_SUPPORT_STATUS_NEW;
        issue1.Site_Issue_Close_Date__c = null;
    
        issue1.support_category__c = 'Production Migration';
        issue1.data_load_period_begin__c = system.today()-1;
        issue1.data_load_period_end__c = system.today();
        issue1.application_version__c='2011.00';
        issue1.RecordTypeId = rcordType;
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //Insert site issue
        insert issue1;
        system.assertNotEquals(null,issue1.id);
        
        //Stop Test here
        Test.stopTest();
        
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //Modified by Rajeev, 08/09/2016 - Services Excellence - Setting null to Issue cloes date as validation is preventing record insert(VR_Update_Status_To_Closed)
        //Site Issue
        site_issue__c issue3 = new site_issue__c(RecordTypeId = rcordType, project__c = project.id, Data_Load_Type__c = 'Current', status__c = Constants.STATUS_SITE_ISSUE_CLOSED, site_issue_short_description__c = 'none', /*site_issue_close_date__c = system.now().date(),*/ support_category__c = 'none', data_load_period_begin__c = system.today()-1, data_load_period_end__c = system.today(), application_version__c='2011.01' );
        insert issue3;
        system.assertNotEquals(null,issue3.id);
    }
    
    //Code added by Bhavi Sharma - 04/29/2013 - CR-20130403-2801
    //Code added by Bhavi Sharma - 07/19/2013 - CR-20130718-3283
    static testMethod void updateProjectWithSiteIssue() {
    
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', Title = 'Test', Phone = '614-555-8855', Employee_ID__c = 'TestEmployee');
        insert contact;
                
        //Start Testing from here
        Test.StartTest();
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        //Get the three record types from Member Support
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Application_Version__c = '13.09',
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),
                                                        Data_Load_Period_End__c = System.today().addDays(-62));
          
        //insert Site Issue
        Util.BypassAllTriggers = false;
        insert sIssue;
        
        //test stops here
        Test.stopTest();
        
        project = [SELECT Id/*,Version_Bridge_New__c*/ FROM Project__c WHERE Id =: project.Id];
        sIssue = [SELECT Id,version_ms__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
        
        //Assert Results
        //System.assertEquals(sIssue.version_ms__c,project.Version_Bridge_New__c);
    }
    
    //Code added by Bhavi Sharma - 04/29/2013 - CR-20130403-2801
    //Code added by Bhavi Sharma - 07/19/2013 - CR-20130718-3283
    static testMethod void updateProjectWithSiteIssue2() {
        
        //Bypass triggers
        Util.BypassAllTriggers = true;
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', 
                                    Employee_ID__c = 'TestEmployee', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Get the three record types from Member Support
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        Id CPMDLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CPM Data Load').getRecordTypeId();
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - Get ARx_Data_Load record type Id 
        Id  msRecordType_ARx_Data_Load = Util.RecordTypeId(ProjectTriggerHelper.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_ARx_Data_Load);

        //List of Projects records to test
        List<Project__c> projectList = new List<Project__c>();
        projectList.add(new Project__c(Name = 'Test-Data'/*,version_bridge_new__c = 13.15*/));
        projectList.add(new Project__c(Name = 'Test-Data 1'));
    
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - New records are added
        projectList.add(new Project__c(Name = 'Test-Data 2'));
        projectList.add(new Project__c(Name = 'Test-Data 3'));

        //insert Project data
        Util.BypassAllTriggers = true;
        insert projectList;
        
        //Start Testing from here
        Test.startTest();
        
        //List of Member Support
        List<Site_Issue__c> listIssues = new List<Site_Issue__c>();
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.16',
                                                        RecordTypeId = CCADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10)
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.16',
                                                        RecordTypeId = CCADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),Files_Received__c = Date.today()
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test-Description', Application_Version__c = '13.15',
                                                        RecordTypeId = CMADLRT, Project__c = projectList[0].Id, Assigned_To_Contact__c = contact.Id, 
                                                        Expected_Resolution_Date__c = System.Today(), Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),Files_Received__c = Date.today()
                                                        ,Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Data_Load_Period_End__c = Date.today(), Data_Load_Period_Begin__c = Date.today()));
        
        listIssues.add(new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Application_Version__c = '13.09',
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CPMDLRT,
                                                        Project__c = projectList[1].Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Support_Category__c = Constants.CRIMSON_SUPPORT_REQUEST_SITE_ISSUE_SUPPORT_CATEGORY_PRODUCTION_MIGRATION, 
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54),Data_Load_Period_End__c = System.today().addDays(-62)));

        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190  
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test1', RecordTypeId = msRecordType_ARx_Data_Load, 
                                        Project__c = projectList[0].Id, Status__c = System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE,
                                        Assigned_To_Contact__c = contact.Id, 
                                        Site_Issue_Priority__c = 'Low',
                                        Files_Received__c = System.today()+1,
                                        Data_Load_Period_End__c = System.today()+2));
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test2', RecordTypeId = msRecordType_ARx_Data_Load, 
                                        Project__c = projectList[1].Id, Status__c = 'Waiting for files',
                                        Assigned_To_Contact__c = contact.Id, 
                                        Site_Issue_Priority__c = 'Low',
                                        Files_Received__c = System.today()-1,
                                        Data_Load_Period_End__c = System.today()));
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test3', RecordTypeId = msRecordType_ARx_Data_Load, 
                                        Project__c = projectList[2].Id, Status__c = System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE,
                                        Assigned_To_Contact__c = contact.Id, 
                                        Site_Issue_Priority__c = 'Low',
                                        Files_Received__c = System.today()+1));
        listIssues.add(new Site_Issue__c(Site_Issue_Short_Description__c = 'Test4', RecordTypeId = msRecordType_ARx_Data_Load, 
                                        Project__c = projectList[3].Id, Status__c = System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE,
                                        Assigned_To_Contact__c = contact.Id, 
                                        Site_Issue_Priority__c = 'Low',
                                        Files_Received__c = System.today()+1,
                                        Data_Load_Period_End__c = System.today()+2));
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190  Upto here
        
    
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        insert listIssues;
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - Current_Data_Period_New__c field is added to query
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //projectList = [SELECT Id/*,Version_Bridge_New__c*/, Current_Data_Period_New__c FROM Project__c where Id =: projectList[0].Id ];
        //System.assertEquals(listIssues[4].Data_Load_Period_End__c, projectList[0].Current_Data_Period_New__c);
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190
        //Update status 
        listIssues[5].Status__c = System.Label.MEMBER_SUPPORT_STATUS_MIGRATION_COMPLETE;
        listIssues[6].Data_Load_Period_End__c = System.today()+2;
        listIssues[7].Data_Load_Period_End__c = null;
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190  Upto here

        //test stops here
        Test.stopTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        update listIssues;
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190 - Current_Data_Period_New__c field is added to query
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //projectList = [SELECT Id/*,Version_Bridge_New__c*/, Current_Data_Period_New__c FROM Project__c Order By Name ASC LIMIT 4];
        //System.assert((projectList.size() == 0), (''+projectList[0].Current_Data_Period_New__c + ' @@' +projectList[1].Current_Data_Period_New__c + ' @@ ' + projectList[2].Current_Data_Period_New__c + ' @@ ' +projectList[3].Current_Data_Period_New__c) );
        
        //Assert Results
        //System.assertEquals(null,projectList[1].Version_Bridge_New__c);
        
        //V_1.9 - Added By - Mahendra Swarnkar - 11/04/2016 - CR-20160927-10190
        //System.assertEquals(listIssues[4].Data_Load_Period_End__c, projectList[0].Current_Data_Period_New__c);
        //System.assertEquals(listIssues[5].Data_Load_Period_End__c, projectList[1].Current_Data_Period_New__c);
        //System.assertEquals(listIssues[6].Data_Load_Period_End__c, projectList[2].Current_Data_Period_New__c);
        //System.assertEquals(listIssues[7].Data_Load_Period_End__c, projectList[3].Current_Data_Period_New__c);
        
        projectList = [SELECT Id/*,Version_Bridge_New__c*/ FROM Project__c WHERE Id =: projectList[0].Id LIMIT 1];
        
        listIssues = [SELECT Id,version_ms__c FROM Site_Issue__c WHERE Id =: listIssues[0].Id];
        
        //Assert Results
        //System.assertEquals(listIssues[0].version_ms__c,projectList[0].Version_Bridge_New__c);

    }
    
    //Code added by Abhinav Sharma - 03/11/2014 - CR-20140108-4243
    static testMethod void updateProjectWithSiteIssueForCMARecordTypes() {
        
        //Bypassing all the triggers at the time of test data creation
        Util.BypassAllTriggers = true;        
        Util.IsTest(true);
        
        //account record
        Account account = new Account(Name = 'test');
        insert account;
        
        // create a contact
        Contact contact = new Contact(FirstName = 'test', LastName = 'Contact', Email = Math.random()+'@test.com', 
        Employee_ID__c = 'TestEmployee', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        // get one record type name
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CMAIDSRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Initial Deployment Support').getRecordTypeId();
        
        //System Issue
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Application_Version__c = '13.00', Status__c = Constants.STATUS_X_DUPLICATE_CANCELLED,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMAIDSRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = contact.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(10),
                                                        Data_Load_Period_End__c = System.today().addDays(-62), Member_Facing_Resolution_Summary__c = 'Test');
        
        //Start Test from here
        Test.startTest();
        
        //Setting flag value, So, then trigger can execute
        Util.BypassAllTriggers = false;        
        
        try{
            
            //Insert site issue
            insert sIssue_1;
            
        }catch(Exception e){
            System.assert(false,e +'');
        }
        
        List<Site_Issue__c> sIssues = [Select ID, Version_MS__c FROM Site_Issue__c LIMIT 2];
        Decimal VersionMSComparison = sIssues[0].Version_MS__c;
        Integer sIssueSize = sIssues.Size();
        
        //List<Project__c> projects = [Select version_bridge_new__c FROM Project__c LIMIT 2];
        //Decimal VersionBridgeNewComparison = projects[0].version_bridge_new__c;
        //Integer projectsSize = projects.Size();
        
        //Stop Test Here
        Test.stopTest();
        
        //Updating Site Issue record
        sIssue_1.Status__c = 'Test';
        update sIssue_1;
        
        //projects = [Select version_bridge_new__c FROM Project__c LIMIT 2];
        //Decimal VersionBridgeNewComparison2 = projects[0].version_bridge_new__c;
        //Integer projectsSize2 = projects.Size();
        
        //Retreiving Member Support details after Member Support insertion and asserting for the results
        System.assertEquals(1, sIssueSize);
        System.assertEquals(13.00, VersionMSComparison);
        
        //Retreiving project details after associated Member Support insertion and asserting for the results
        //System.assertEquals(1, projectsSize);
        //System.assertEquals(null, VersionBridgeNewComparison);
              
        //Retreiving project details after Member Support update to status of 'Test' and asserting for the results
        //System.assertEquals(1, projectsSize2);
        //System.assertEquals(13.00, VersionBridgeNewComparison2);
    }
    
    static testMethod void testPopulateProgramType() {
        
        //By Passing all triggers so then test data can be created easily for testing purpose 
        util.BypassAllTriggers = true;
        
        //Create Contact
        Contact con = testUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //Create 2 new programs
        Program__c program_HCC = TestUtilities.CreateNewProgram(false);
        program_HCC.Program_Acronym__c = 'HCC';
        Program__c program_HCAB = TestUtilities.CreateNewProgram(false);
        program_HCAB.Program_Acronym__c = 'HCAB';
        list<Program__c> programList = new list<Program__c> { program_HCC, program_HCAB };
            insert programList;
        
        //Create a new Project__c
        Project__c project = new Project__c(Name = 'Test-Data', Product__c = program_HCC.Id);
        insert project;
        
        //Get record type
        Id TestRecordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Defect / Enhancement Request').getRecordTypeId();
        
        //create a member support record
        Site_Issue__c memSupport = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                     Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                     Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = TestRecordType,
                                                     Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                     Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                     Data_Load_Period_End__c = Date.Today().addDays(-62));
        
        //Enabling triggers back
        util.BypassAllTriggers = false;
        
        //Insert member support record
        insert memSupport;
        
        //Get member support record
        memSupport = [SELECT Id, Project_Program_Type__c FROM Site_Issue__c WHERE Id = :memSupport.Id];
        
        //Variable for later assertion
        String ProjProgramType1 = memSupport.Project_Program_Type__c;
        
        //Start Testing from here
        Test.StartTest();
        
        // update the member support record's program
        project.Product__c = program_HCAB.Id;
        
        //Enabling trigger back
        util.BypassAllTriggers = false;
        
        //Update project record
        update project;
        
        //Stop testing here
        Test.StopTest();   
        
        //Get member support record
        memSupport = [SELECT Id, Project_Program_Type__c FROM Site_Issue__c WHERE Id = :memSupport.Id];
        
        //verify that the member support program acronym was updated
        System.assertEquals(program_HCC.Program_Acronym__c, ProjProgramType1);
        
        //verify that the member support program acronym was updated
        System.assertEquals(program_HCAB.Program_Acronym__c, memSupport.Project_Program_Type__c);
    }   
    
    static testMethod void testCompassSupportAssignment() {
        
        //Bypassing triggers so them test data can be created easily for testing
        Util.IsTesting = true;
        Util.BypassAllTriggers = true;
        
        //User record
        User compassSupportUser = [SELECT Name, Id, Username FROM User WHERE IsActive = true LIMIT 1];
        
        // get one record type name
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Site_Issue__c' AND Name='CPM Support Issue' AND IsActive=true LIMIT 1];
        
        //Member Support Assignment
        /*Member_Support_Assignment__c memberAssignment = new Member_Support_Assignment__c();
        memberAssignment.Record_Type_Name__c = rt.Name;
        memberAssignment.Username__c = compassSupportUser.Username;*/
        
        //Create the support issue
        Site_Issue__c newIssue = new Site_Issue__c();
        newIssue.RecordTypeId = rt.Id;
        newIssue.Data_Load_Type__c = 'Production Issue';
        
        //Set flag false for not to by pass all triggers
        Util.BypassAllTriggers = false;   
        
        //Insert member Support
        insert newIssue;
        
        // get the new issue and test the owner
        List<Site_Issue__c> issues = [SELECT Name, Id, OwnerId FROM Site_Issue__c WHERE Id = :newIssue.Id];
        
        // make sure the owner of the newly created issue matches the owner that is specified in the custom setting
        //system.assertEquals(compassSupportUserId, issues[0].OwnerId);
        Util.BypassAllTriggers = true;
        
        //Test data added by Bhavi Sharma - 04/24/2013 - CR-20121219-1968
        
        //create new Project__c data
        Project__c project = new Project__c(Name = 'Test-Data');
        
        //insert Project data
        insert project;
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE Name='Defect / Enhancement Request' AND IsActive = true AND sObjectType = 'Site_Issue__c' limit 1];
        
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
        
        Contact con = testUtilities.CreateNewContact(true);
        con.Employee_ID__c = 'Test1';
        update con;
        
        System.debug('#### Contact' + con + '#### Id' + con.Id);
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = recordTypes[0].Id,
                                                 Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62));
        
        System.debug('Util.BypassAllTriggers 2:::::::::;'+ Util.BypassAllTriggers);
        
        //Set flag false for not to by pass all triggers
        Util.BypassAllTriggers = false;   
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Stop Testing from here
        Test.StopTest();
        
        //Get Project 
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        project = [SELECT Id/*, Delayed_Load__c*/ FROM Project__c WHERE Id =: project.Id];
        
        //assert statements
        //System.assertEquals(null, project.Delayed_Load__c);
    }
    
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the Too many Soql query error
    //Broke this method's logic in Three method testUpdateSiteIssueByProject, testUpdateSiteIssueByProject1, testUpdateSiteIssueByProject2
    //New test Method added of Utility class's UpdateSiteIssueByProject method  - Bhavi Sharma - 06/04/2013 - CR-20130328-2773
    static testmethod void testUpdateSiteIssueByProject() {
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create User
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        con.Employee_User_Record__c = user1.Id;
        insert con;
        
         //create new Project__c data
         //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project = new Project__c(Name = 'Test-Data',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id/*, 
                                            Crimson_Data_Analyst_Group_Lead__c = user1.Id,*//* Implementation_Pod__c = 'Test', Crimson_Data_Lag__c = 10, Load_Frequency__c = 'Test'*/);
                                                
        //insert Project data
        insert project;
        
        //Get the two record types Id of CMA/Data Load Migration Record Type
        Id CMADLRT = Util.RecordTypeId(Constants.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_CMA_DATA_LOAD);
                                                           
        //Create one Site Issue Record
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,
                                                        Project__c = project.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Site Issue record
        sIssue = [SELECT Production_Business_Analyst__c, Dedicated_Advisor__c, Assigned_To_Contact__c, Data_Load_Period_End__c, 
                    Project_Implementation_Pod_1__c, Crimson_Data_Lag_1__c, Load_Frequency__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
                    
        //update some fields of Site Issue
        sIssue.Data_Load_Period_End__c = Date.today();
        
         //Test stops here
        Test.stopTest();
        
        //update Site Issue
        update sIssue;
        
         //assert the fields mapped over from Member Support to Project correctly
         //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //System.assertEquals(project.Recurring_Business_Analyst__c, sIssue.Production_Business_Analyst__c);
        System.assertEquals(project.Dedicated_Advisor__c, sIssue.Dedicated_Advisor__c);
        //System.assertEquals(project.Implementation_Pod__c, sIssue.Project_Implementation_Pod_1__c);
        //System.assertEquals(project.Crimson_Data_Lag__c, sIssue.Crimson_Data_Lag_1__c);
        //System.assertEquals(project.Load_Frequency__c, sIssue.Load_Frequency__c);
        //System.assertEquals(con.Id, sIssue.Assigned_To_Contact__c);
    } 
    
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the Too many Soql query error
    static testmethod void testUpdateSiteIssueByProject1() {
        
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_ID__c = 'Test1';
        con1.Employee_User_Record__c = user1.Id;
        
        insert con1;
        
         //create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project2 = new Project__c(Name = 'Test-Data2',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id
                                            /* Crimson_Data_Analyst_Group_Lead__c = user1.Id, Current_Data_Period_New__c = Date.Today().addDays(-62)*//*,
                                             Latest_Data_Load__c = Date.today()*/);
        
        //insert Project data
        insert project2;
        
        //Get the two record types Id of CCA Data Load Record Type
        Id CCADLRT = Util.RecordTypeId(Constants.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD);
                                                           
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Create Variables for assertions at the end of the test method
        Date projectDatePeriodNew1;
        DateTime projectLatestDataLoad1;
        
        //Start Testing from here
        Test.StartTest();
        
        //Create List of Site
        Site_Issue__c sIssue2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project2.Id, Assigned_To_Contact__c = con1.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = Date.today(),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today());
        
        //insert Site Issue
        insert sIssue2;
        
        //Now update Site Issue and Populate it's close date
        sIssue2.Status__c = Constants.STATUS_MIGRATION_COMPLETE;
        
        //Popualte Application Version, this field must be field if Status = STATUS_MIGRATION_COMPLETE
        sIssue2.Application_Version__c = '2016.14';
        
        //Set diagnostic URL when Status is greate then or equals to 'Diagnostics Ready'
        sIssue2.Crimson_Diagnostic_URL__c = 'www.test.com';
        
        //Test stops here
        Test.stopTest();
        
        update sIssue2;
        
        //Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project2 = [SELECT /*Latest_Data_Load__c,*/ Current_Data_Period_New__c FROM Project__c WHERE Id =: project2.Id];
        
        //Pass to variables for testing at the end of the test
        //projectDatePeriodNew1 = project2.Current_Data_Period_New__c;
        //projectLatestDataLoad1 = project2.Latest_Data_Load__c;
        
         //Assert statements
        //System.assertEquals(sIssue2.Data_Load_Period_End__c, projectDatePeriodNew1);
        //System.assertEquals(sIssue2.Site_Issue_Close_Date__c, projectLatestDataLoad1);
    }
    
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the Too many Soql query error
    static testmethod void testUpdateSiteIssueByProject2() {
        
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_ID__c = 'Test1';
        con1.Employee_User_Record__c = user1.Id;
        
        insert con1;
        
         //create new Project__c data
         //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project2 = new Project__c(Name = 'Test-Data2',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id
                                            /* Crimson_Data_Analyst_Group_Lead__c = user1.Id,Current_Data_Period_New__c = Date.Today().addDays(-62)*//*,
                                             Latest_Data_Load__c = Date.today()*/);
        
        //insert Project data
        insert project2;
        
        //Get the two record types Id of CCA Data Load Record Type
        Id CCADLRT = Util.RecordTypeId(Constants.MEMBER_SUPPORT_API_NAME, 
                                                           Constants.RECORD_TYPE_SITE_ISSUE_CCA_DATA_LOAD);
                                                           
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Create Variables for assertions at the end of the test method
        Date projectDatePeriodNew1;
        DateTime projectLatestDataLoad1;
        
        //Create List of Site
        Site_Issue__c sIssue3 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CCADLRT,
                                                        Project__c = project2.Id, Assigned_To_Contact__c = con1.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = Date.today(),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62), Data_Load_Period_Begin__c = Date.today());
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue3;
        
        Test.StopTest();
        
        //Site Issue record
        sIssue3 = [SELECT Site_Issue_Close_Date__c, RecordTypeId, Data_Load_Period_End__c FROM Site_Issue__c WHERE Id =: sIssue3.Id];
        
        //Project record
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project2 = [SELECT /*Latest_Data_Load__c,*/ Current_Data_Period_New__c FROM Project__c WHERE Id =: project2.Id];
        
         //Assert statements
        //System.assertEquals(sIssue3.Data_Load_Period_End__c, project2.Current_Data_Period_New__c);
        //System.assertEquals(sIssue3.Site_Issue_Close_Date__c, project2.Latest_Data_Load__c);
            
    }
    
    //Method updated - Ajit Surana - -2/16/2015 - CR-20150106-8468 - Replaced CCC string with BIPC
    //New test Method added of Utility class's SendDataLoadAutoEmail method  - Bhavi Sharma - 07/24/2013 - CR-20120716-1142
    //Update - (SUNJ 12/19/13) - CR-20130815-3433
    static testmethod void testSendDataLoadAutoEmail() {
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create Users
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //create new Contact
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //create new Account
        Account account = TestUtilities.CreateNewAccount(false);
        Account.Name = 'TestBIPC Account ';
        Account.Account_Formal_Name__c = 'BIPC Account';
        Insert account;
        
        //create new Contact
        Contact contact = TestUtilities.CreateNewContact(false);
        Contact.AccountId = account.Id;
        Contact.Employee_ID__c = 'Test';
        
        //Insert contact here
        Insert contact;
        
        //create new Program record 
        Program__c program_BIPC = TestUtilities.CreateNewProgram(false);
        program_BIPC.Program_Acronym__c = 'BIPC';
        
        insert program_BIPC;
        
        //create new Project__c data
        Project__c project1 = TestUtilities.createProject(false);
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project1.Recurring_Business_Analyst__c = user1.Id;
        project1.Dedicated_Advisor__c = user1.Id;
        project1.Product__c = program_BIPC.Id;
        project1.Project_Manager__c = user1.Id;
        //project1.Crimson_Data_Analyst_Group_Lead__c = user1.Id;
        project1.Institution__c = account.Id;
        
        //insert Project data
        insert project1;
        
        project1 = [SELECT Name FROM Project__c WHERE Id =: project1.Id];
        System.debug('Name is ::::::' + project1.Name);
        
        //create new Project Role data
        Project_Role__c projectRole = new Project_Role__c(Project__c = project1.Id, Contact__c = contact.Id, CCC_Include_in_Data_Load_Automated_Email__c = true);
        
        //insert Project Role here
        insert projectRole;
        
        //create new Project__c data
        Project__c project2 = TestUtilities.createProject(false);
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //project1.Recurring_Business_Analyst__c = user1.Id;
        project1.Dedicated_Advisor__c = user1.Id;
        project1.Project_Manager__c = user1.Id;
        //project1.Crimson_Data_Analyst_Group_Lead__c = user1.Id;
        
        //insert Project data
        insert project2;
        
        Id CMADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        Id CCADLRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,

                            //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
                                                        //Status__c = Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED,
                            Status__c = Constants.STATUS_SITE_ISSUE_CLOSED,

                                                        Project__c = project1.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54), Site_Issue_Close_Date__c = System.now().addDays(8),
                                                        Data_Load_Period_End__c = Date.Today().addDays(-62),Application_Version__c='13.01',
                                                        Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                        Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(),
                                                        Member_Facing_Resolution_Summary__c='test', Data_Submission_Target_Date__c = Date.today(),
                                                        Diagnostics_Sent__c = Date.today(), Diagnostics_Sign_Off_Received__c = Date.today(),
                                                        Hours_Spent__c = 2);
                                                        
        
        //Create List of Site
        Site_Issue__c sIssue2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                        Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD,
                                                        Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = CMADLRT,
                                                        Status__c = Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE,
                                                        Project__c = project1.Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                        Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                        Data_Load_Period_End__c = Date.today().addDays(-62),Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),
                                                        Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                        Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(),Application_Version__c='13.01',
                                                        Member_Facing_Resolution_Summary__c='test');
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        insert sIssue2;
        
        //Start Testing from here
        Test.StartTest();
        
        //insert Site Issue
        insert sIssue1;
        
        //Stop Testing from here
        Test.stopTest();
        
        System.assertEquals(Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE, sIssue2.Status__c);
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //System.assertEquals(Constants.STATUS_SITE_ISSUE_10_CLOSED_MEMBER_NOTIFIED, sIssue1.Status__c);
        System.assertEquals(Constants.STATUS_SITE_ISSUE_CLOSED, sIssue1.Status__c);
    }
    
    //Method modified by Ajit Surana - 08/13/2014 - CR-20140417-5130
    //Created an admin user in this method and run the test method as this fixed admin user.
    //Code added By - Bhavi Sharma - 08/13/2013 - CR-20121219-1968
    //Test mehod added for CosecutivelyDelayedLoad updation on Member Support
    public static testMethod void testpopulateConsecutivelyDelyedOnSiteIssue() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select Id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Test User Create
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //List of projects
        List<Project__c> projects = new List<Project__c>();
        
        //create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id/*, Crimson_Data_Analyst_Group_Lead__c = user1.Id*/);
        Project__c project2 = new Project__c(Name = 'Test-Data2',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id/*, Crimson_Data_Analyst_Group_Lead__c = user1.Id*/);
        
        projects.add(project1);
        projects.add(project2);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Insert project
        insert projects;
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =:Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 1];
        
        //Asert or the record type
        System.assertEquals(1, recordTypes.size());
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                 RecordTypeId = recordTypes[0].Id, Project__c = projects[0].Id, 
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                                 Site_Issue_Close_Date__c = System.now().addMonths(-2), 
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),
                                                 Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
        
        //Run as test User of Specialist profile    
        System.runAs(user1) {
            
            //Enabling triggers back
            Util.BypassAllTriggers = false;
            
            //insert Site Issue
            insert sIssue;
            
            //Test starts here 
            Test.startTest();
            
            //Enabling triggers back
            Util.BypassAllTriggers = true;
            
            //query result 
            sIssue = [SELECT Consecutively_Delayed_Load__c, Total_Delay__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
            
            Boolean ConsDelay1 = sIssue.Consecutively_Delayed_Load__c;
            
            //Members Support record
            sIssue = new Site_Issue__c(Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                       RecordTypeId = recordTypes[0].Id, Project__c = projects[1].Id, Site_Issue_Created_Date__c = System.now().addDays(-54), 
                                       Site_Issue_Close_Date__c = System.now().addMonths(-1), Data_Load_Period_End__c = Date.Today().addDays(-62),
                                       Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today());
            
            //Enabling triggers back
            Util.BypassAllTriggers = false;
            
            //insert Site Issue
            insert sIssue;
            
            //query result 
            sIssue = [SELECT Consecutively_Delayed_Load__c, Total_Delay__c FROM Site_Issue__c WHERE Id =: sIssue.Id];
            
            Boolean ConsDelay2 = sIssue.Consecutively_Delayed_Load__c;
            
            //Test stops here
            Test.stopTest();
            
            //assert statements 1& 2
            System.assertEquals(false, ConsDelay1);
            System.assertEquals(false, ConsDelay2);
            
        }
    }       
    
    
  /*  static testmethod void testPopulateAssignedToUser() {
        
        //Bypassing all triggers
        util.BypassAllTriggers = true;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.FirstName = 'Salty';
        contact.LastName = 'Baxter';
        contact.Employee_ID__c = '13';
        insert contact;
        
        //create a community user associated with that contact Id
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserLicense.Name like '%High Volume Customer Portal' LIMIT 1];
        User communityUser = TestUtilities.CreateNewUser(portalProfile, false);
        communityUser.FirstName = 'Salty';
        communityUser.LastName = 'Baxter';
        communityUser.ContactId = contact.Id;
        insert communityUser;
        
        //create new project
        Project__c proj = TestUtilities.createProject(true);
        
        util.BypassAllTriggers = false;
        
        test.startTest();
        
        //create member support
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        util.BypassAllTriggers = true;

        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(proj.Id, false);
        memberSupport.Assigned_To_Contact__c = contact.Id;

        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //memberSupport.Status__c = '06 - Issue Resolved - Ticket Closed';
        memberSupport.Status__c = Constants.MEMBER_SUPPORT_STATUS_NEW;
        memberSupport.Site_Issue_Close_Date__c = null;
        insert memberSupport;
        
        //Stop test here
        Test.stopTest();
        
        //Grab the Project 
        proj = [SELECT Id, Crimson_Data_Analyst_Group_Lead__c FROM Project__c WHERE Id =:proj.Id];
        
        //Test to see if the value moved over from Member Support to Project successfully
        System.assertEquals(contact.Name, communityUser.Name);
    }*/
    
     //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
    /**
     * 
     * @description: test the populateAccountFormalName() method and verify the field gets populated correctly. (CR-9760)
     * 
     **/
    static testmethod void testPopulateAccountFormalName() {
        
        //Bypassing all triggers
        util.BypassAllTriggers = true;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(false);
        contact.FirstName = 'Salty';
        contact.LastName = 'Baxter';
        contact.Employee_ID__c = '13';  
        insert contact;
        
        //create a new institution
        Account acct = TestUtilities.CreateNewAccount(false);
        acct.Account_Formal_Name__c = 'Cleveland Clinic';
        insert acct;
        
        util.BypassAllTriggers = false;
        
        test.startTest();
        
        //create member support
        Site_Issue__c memberSupport = TestUtilities.createSiteIssue(null, false);
        memberSupport.Institution__c = acct.Id;
        memberSupport.recordTypeId = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('PIC Defect').getRecordTypeId();
        memberSupport.Status__c = 'New';
        memberSupport.Site_Issue_Close_Date__c = null;
        insert memberSupport;
        
        //Stop test here 
        Test.stopTest();
         
        //Grab the member support record 
        memberSupport = [SELECT Id, Institution_Formal_Name_Text__c FROM Site_Issue__c WHERE Id = :memberSupport.Id];
        
        //Test to see if the Institution Formal Name populated successfully
        System.assertEquals(acct.Account_Formal_Name__c, memberSupport.Institution_Formal_Name_Text__c);
    }
    
    //Code added By - Abhinav Sharma - 07/12/2014 - CR-20140422-5173
    static testMethod void testUpdateAssignedToContact() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Set to hold the record type names
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add('Compass_Connect_Ticket');
        setRecordTypeNames.add('Compass_Data_Analytics_Ticket');
        setRecordTypeNames.add('Compass_Implementation');
        setRecordTypeNames.add('Compass_Support_Issue');
        
        //get one record type name
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN : setRecordTypeNames 
                                                                      AND IsActive = true AND sObjectType = 'Site_Issue__c']); 
        
        //Asert or the record type
        System.assertEquals(4, mapRecordTypes.values().size());
        
        //RecordType
        Id rdType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Medical Director Service Request').getRecordTypeId();
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create a list of users 
        List<User> users = new List<User>();
        
        //Create User
        users.add(new User(Username = Math.random()+'@abc.com', LastName = 'Test User1', FirstName = 'Test1', Email = Math.random()+'@test.com',
                           Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = profiles[0].Id, 
                           timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true));
        users.add(new User(Username = Math.random()+'@abc.com', LastName = 'Test User2', FirstName = 'Test2', Email = Math.random()+'@test.com',
                           Alias = 'Test2', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = profiles[0].Id, 
                           timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '13131313', IsActive = true));
        
        //Insert users
        insert users;
        
        //create new Account
        Account account = new Account(Name = 'TestCCC Account ', Account_Formal_Name__c = 'CCC Account');
        
        //insert account here
        insert account;
        
        //Create a list of Contact records
        List<Contact> conList = new List<Contact>();
        
        //create new Contact
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 1', Employee_User_Record__c = users[0].Id, Title = 'Test', Phone = '614-555-8855');
        
        //create new Contact
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 2', Employee_User_Record__c = null, Title = 'Test', Phone = '614-555-8855');
        
        conList.add(con1);
        conList.add(con2);
        
        //Insert Contacts
        insert conList;
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data1', /*Recurring_Business_Analyst__c = users[0].Id,*/ 
                                             Dedicated_Advisor__c = users[0].Id/*, 
                                             Crimson_Data_Analyst_Group_Lead__c = users[0].Id*/);
        Project__c project2 = new Project__c(Name = 'Test-Data2', /*Recurring_Business_Analyst__c = users[0].Id,*/ 
                                             Dedicated_Advisor__c = users[0].Id);
        Project__c project3 = new Project__c(Name = 'Test-Data3', /*Recurring_Business_Analyst__c = users[0].Id, */
                                             Dedicated_Advisor__c = users[0].Id/*, 
                                             Crimson_Data_Analyst_Group_Lead__c = users[1].Id*/);
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        projects.add(project3);
        
        //insert Project data
        insert projects;
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(Support_Category__c = 'Bug Report', Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = mapRecordTypes.values()[0].Id, 
                                                  Project__c = projects[0].Id, Assigned_To_Contact__c = conList[0].Id,
                                                  Site_Issue_Short_Description__c = 'Test');
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(Support_Category__c = 'Bug Report', Site_Issue_Short_Description__c = 'Test',
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = mapRecordTypes.values()[1].Id, Project__c = projects[0].Id,  
                                                  Summary__c = 'xyz', Business_Impact__c = 'abc');
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(Support_Category__c = 'Bug Report', 
                                                  RecordTypeId = mapRecordTypes.values()[2].Id,
                                                  Project__c = projects[0].Id, Site_Issue_Short_Description__c = 'Test', 
                                                  Site_Issue_Priority__c = 'Normal', 
                                                  Products_to_be_Dropped_Added__c = 'Spend');
        
        //Insert Member Support Data
        Site_Issue__c sIssue4 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[0].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue5 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue6 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[1].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue7 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[1].Id, 
                                                  Assigned_To_Contact__c = null);
        
        //Insert Member Support Data
        Site_Issue__c sIssue8 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[2].Id, 
                                                  Assigned_To_Contact__c = null);
        
        //Insert Member Support Data
        Site_Issue__c sIssue9 = new Site_Issue__c(RecordTypeId = rdType, Project__c = projects[2].Id, 
                                                  Assigned_To_Contact__c = conList[0].Id);
        
        //Insert Member Support Data
        Site_Issue__c sIssue10 = new Site_Issue__c(RecordTypeId = rdType, Project__c = null, 
                                                   Assigned_To_Contact__c = conList[0].Id);
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        sitIssueList.add(sIssue4);
        sitIssueList.add(sIssue5);
        sitIssueList.add(sIssue6);
        sitIssueList.add(sIssue7);
        sitIssueList.add(sIssue8);
        sitIssueList.add(sIssue9);
        sitIssueList.add(sIssue10);
        
        //Start test from here
        Test.startTest();
        
        //Run as test User of System Administrator profile    
        System.runAs(users[0]) {
            
            try {
                
                //Enabling triggers back
                Util.BypassAllTriggers = false;
                
                //Insert list of Member Support records
                insert sitIssueList;
                
                //Enabling triggers again
                Util.byPassAllTriggers = true;
                
                //query result for "Compass_Connect_Ticket" Record Type
                sitIssueList = [SELECT Id, Assigned_To_Contact__c , Expected_File_Received_Date__c  FROM Site_Issue__c];   
                
            } catch(Exception e){
            }
            
        }    
        
        //Stop test here
        Test.stopTest();
        
        //assert statements
        System.assertEquals(conList[0].Id, sitIssueList[0].Assigned_To_Contact__c );
        System.assertEquals(null, sitIssueList[1].Assigned_To_Contact__c );
        System.assertEquals(null, sitIssueList[2].Assigned_To_Contact__c );
    }
    
    //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
    //Modified By - Abhinav Sharma - 05/30/2016 - CR-20150326-8810
    //Code added By - Ajit Surana - 10/17/2014 - CR-20140725-6664
    static testMethod void test_updateExpectedFileReceivedDate() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Bypass the entity population Logic  
    Util.bypassEntityPopulation = true;
        
        //RecordType
        Id msRType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //RecordType
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        Id projectRType = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Tech').getRecordTypeId();
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create Users
        User user1 = TestUtilities.CreatenewUser(profiles[0], false);
        user1.IsActive = true;
        User user2 = TestUtilities.CreatenewUser(profiles[0], false);
        insert user1;
        
        //Create new Account
        Account account = new Account(Name = 'TestCCC Account ', Account_Formal_Name__c = 'CCC Account');
        
        //Insert account here
        insert account;
        
        //Create new Contacts
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_User_Record__c = user1.Id;
        con1.Employee_ID__c = '13';
        con1.AccountId = account.Id;
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.AccountId = account.Id;
        con2.Employee_ID__c = '15';
        con2.Employee_User_Record__c = null;
        insert con1;
        insert con2;
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data1', /*Recurring_Business_Analyst__c = user1.Id,*/ 
                                             Dedicated_Advisor__c = user1.Id, RecordTypeId = projectRType/*,
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id*/);
        Project__c project2 = new Project__c(Name = 'Test-Data2', /*Recurring_Business_Analyst__c = user1.Id, */
                                             RecordTypeId  = projectRType, Dedicated_Advisor__c = user1.Id);
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        
        //Insert Project data
        insert projects;
        
        //Stop test here
        Test.startTest();
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(Support_Category__c = 'Bug Report', Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  RecordTypeId = msRType, Data_Load_Type__c = 'OPPE Deployment',
                                                  Data_Load_Period_End__c = System.Today(), Crimson_Diagnostic_URL__c = 'Test',
                                                  Project__c = projects[0].Id, Assigned_To_Contact__c = con1.Id,
                                                  Site_Issue_Short_Description__c = 'Test',
                                                  No_OPPE_Measures_Implemented__c = 2);
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(Support_Category__c = 'Bug Report', Site_Issue_Short_Description__c = 'Test',
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', 
                                                  Data_Load_Type__c = 'OPPE Deployment', Business_Impact__c = 'abc',
                                                  Data_Load_Period_End__c = System.Today(), Crimson_Diagnostic_URL__c = 'Test',
                                                  RecordTypeId = msRType, Project__c = projects[0].Id,
                                                  No_OPPE_Measures_Implemented__c = 2);
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(Support_Category__c = 'Bug Report', Data_Load_Period_End__c = System.Today(),
                                                  Data_Load_Type__c = 'OPPE Deployment', Project__c = projects[1].Id,
                                                  Site_Issue_Short_Description__c = 'Test', 
                                                  Site_Issue_Priority__c = 'Normal', Crimson_Diagnostic_URL__c = 'Test',
                                                  Products_to_be_Dropped_Added__c = 'Spend',
                                                  No_OPPE_Measures_Implemented__c = 2,
                                                  First_Comment_Date_Time__c = System.today(),
                                                  Site_Issue_Close_Date__c = System.today(),
                                                  Actual_Resolution_Date__c = System.today(),
                                                  Date_Time_Acknowledged__c = System.now());
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        
        //Variables for later test assertions
        Integer SiteIssueListSize1;
        Date SiteIssueListExpDate1;
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Insert list of Member Support records
        insert sitIssueList;
        
       /* //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Update Site_Issue__c records values
        sitIssueList[0].Crimson_Data_Lag_1__c = 2;
        sitIssueList[1].Crimson_Data_Lag_1__c = 3;
        sitIssueList[2].Crimson_Data_Lag_1__c = 4;
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Update the list
        update sitIssueList;
        
        //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Query to get desired results
        sitIssueList = [SELECT Id, Expected_File_Received_Date__c FROM Site_Issue__c];
        
        SiteIssueListSize1 = sitIssueList.size();
        SiteIssueListExpDate1 = sitIssueList[0].Expected_File_Received_Date__c;
        
        //Update Site_Issue__c records values
        sitIssueList[0].Application_Version__c = '14.01';
        sitIssueList[0].Status__c = '10 - Closed, Member Notified';
        sitIssueList[0].Site_Issue_Close_Date__c = System.Today();
        sitIssueList[0].Files_Received__c = System.Today();
        sitIssueList[0].Internal_Load_Complete__c = System.Today();
        sitIssueList[0].Smoke_Test_Complete__c = System.Today();
        sitIssueList[0].Testing_Complete__c = System.Today();
        sitIssueList[0].Ready_for_Final_QA__c = System.Today();
        sitIssueList[0].Moved_to_Production__c = System.Today();
        sitIssueList[0].Data_Submission_Target_Date__c = System.Today();
        sitIssueList[0].Diagnostics_Sent__c = System.Today();
        sitIssueList[0].Diagnostics_Sign_Off_Received__c = System.Today();
        sitIssueList[0].Hours_Spent__c = 5;
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
        
        //Query to hold Member support
        List<Site_Issue__c> issues = [Select Id, Elapsed_Open_to_Close_Hours__c, Elapsed_Open_to_Actual_Resolution_Hours__c,
                                     Elapsed_Open_to_Acknowledged_Hours__c, Elapsed_Open_to_First_Response_Hours__c,
                                     Date_Time_Acknowledged__c From Site_Issue__c Where Id =: sitIssueList[2].Id];
        
        //Assertion
        //System.assertNotEquals(null, issues[0].Elapsed_Open_to_Close_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertNotEquals(null, issues[0].Elapsed_Open_to_First_Response_Hours__c);
        //System.assertNotEquals(null, issues[0].Elapsed_Open_to_Close_Hours__c);

        //System.assertEquals(18, issues[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        //System.assertEquals(9, issues[0].Elapsed_Open_to_Acknowledged_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_First_Response_Hours__c);
        //System.assertEquals(18, issues[0].Elapsed_Open_to_Close_Hours__c);
        
        //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Upto here
        
        //Update the list
        update sitIssueList;  
        
        System.assertEquals(10, Limits.getQueries()); 
        
        //Stop test here
        Test.stopTest();
        
        //Enabling triggers again
        Util.byPassAllTriggers = true;
        
        //Query to get desired results
        projects = [SELECT Id, Elapsed_MS_Data_Load_Period_Data_Lag__c FROM Project__c WHERE ID IN : projects];
        
        //Assert statements
        System.assert(SiteIssueListSize1>0);
        //System.assertEquals(System.Today().addDays(2), SiteIssueListExpDate1);
        
        //Assert statements
        System.assertEquals(2, projects.size());
        //System.assertEquals(System.Today().addDays(2), projects[0].Elapsed_MS_Data_Load_Period_Data_Lag__c );   */ 
    }       
    
    //New test Method added - Ajit Surana - 01/20/2015 - CR-20150102-8430
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures
    static testmethod void testUpdate_PCP_Revenue_On_Project() {
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select id from Profile where Name = 'System Administrator' limit 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create User
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        Contact con1 = TestUtilities.CreateNewContact(false);
        con1.Employee_ID__c = 'Test1';
        con1.Employee_User_Record__c = user1.Id;
        
        Contact con2 = TestUtilities.CreateNewContact(false);
        con2.Employee_ID__c = 'Test2';
        con2.Employee_User_Record__c = user2.Id;
        
        //Create a list of Contacts 
        List<Contact> contacts = new List<Contact> { con1, con2 };
            insert contacts;
        
        //List to hold Project records
        List<Project__c> projects = new List<Project__c>();
        
        //create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data1',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id/*, 
                                             Crimson_Data_Analyst_Group_Lead__c = user1.Id, Implementation_Pod__c = 'Test', Crimson_Data_Lag__c = 10, Load_Frequency__c = 'Test'*/);
        
        //create new Project__c data
        Project__c project2 = new Project__c(Name = 'Test-Data2',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id
                                             /*Crimson_Data_Analyst_Group_Lead__c = user1.Id, Current_Data_Period_New__c = Date.Today().addDays(-62),
                                             Latest_Data_Load__c = Date.today()*/);
        
        projects.add(project1);
        projects.add(project2);
        
        //Insert list into database
        insert projects;
        
        //Set of Developer Name for Site Issue's RecordType
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CMA_DATA_LOAD_MIGRATION);
        setRecordTypeNames.add(Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_DATA_LOAD);
        
        // get one record type name
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN: setRecordTypeNames AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName Limit 2];
        
        //Asert or the record type
        System.assertEquals(2, recordTypes.size());
        
        Contact con = TestUtilities.CreateNewContact(false);
        con.Employee_ID__c = 'Test1';
        insert con;
        
        //Create List of Site
        Site_Issue__c sIssue = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                 Category__c = 'Test-Category', Data_Load_Type__c = Constants.HISTORICAL_RELOAD, Cause_for_Delay__c = 'CDA Issues',
                                                 Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = recordTypes[1].Id,
                                                 Project__c = projects[0].Id, Assigned_To_Contact__c = con.Id, CCC_Date_Observed__c = System.Today(),
                                                 Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                 Data_Load_Period_End__c = Date.Today().addDays(-62),Data_Load_Period_Begin__c = Date.today(),
                                                 //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
                                                //Status__c = '22 - Production Migration Complete', Percent_of_PCP_Revenue_Not_Captured__c = 10,
                                                Status__c = Constants.STATUS_MIGRATION_COMPLETE, Percent_of_PCP_Revenue_Not_Captured__c = 10,
                                                 Files_Received__c = Date.today(), Estimated_Prod_Team_Transition_Date__c = Date.today());
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Test starts here
        Test.startTest();
        
        //insert Site Issue
        insert sIssue;
        
        //Test stops here
        Test.stopTest();
        
        //Query data 
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //projects = [SELECT Id, Percent_of_PCP_Not_Captured__c FROM Project__c WHERE Id =: projects[0].Id];
        
        //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures
        //assert statements
        //System.assertEquals(sIssue.Percent_of_PCP_Revenue_Not_Captured__c, projects[0].Percent_of_PCP_Not_Captured__c);
        //System.assertEquals(null, projects[0].Percent_of_PCP_Not_Captured__c);
        //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures - upto here
    }
    
    static testMethod void test_BeforeEventsForMS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Create new Account
        Account account = new Account(Name = 'Test Account ', Account_Formal_Name__c = 'Test Account');
        insert account;
        
        //Create a list of Contact records
        List<Contact> conList = new List<Contact>();
        
        //create new Contact
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 1', Title = 'Test', Phone = '614-555-8855');
        
        //create new Contact
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com',
                                   AccountId = account.Id, Employee_ID__c = 'Test 2', Title = 'Test', Phone = '614-555-8855');
        
        conList.add(con1);
        conList.add(con2);
        
        //Insert Contacts
        insert conList;
        
        //RecordType
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        List<RecordType> projectRType = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName = 'SSC' 
                                         AND IsActive = true AND sObjectType = 'Project__c'];
        System.assert(projectRType != null);
        
        //List to hold the Project records
        List<Project__c> projects = new List<Project__c>();
        
        //Create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data1', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID/*,
                                             Recurring_Business_Analyst__c = Userinfo.getuserid()*/);
        
        Project__c project2 = new Project__c(Name = 'Test-Data2', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID/*,
                                             Recurring_Business_Analyst__c = Userinfo.getuserid()*/);
        
        Project__c project3 = new Project__c(Name = 'Test-Data3', Notes_Implementation__c = 'testing', RecordTypeId = projectRType[0].ID/*,
                                             Recurring_Business_Analyst__c = Userinfo.getuserid()*/);
        
        Project__c project4 = new Project__c(Name = 'Test-Data4', RecordTypeId = projectRType[0].ID, Project_Manager__c = Userinfo.getUserId());
        Project__c project5 = new Project__c(Name = 'Test-Data5', RecordTypeId = projectRType[0].ID, Project_Manager__c = Userinfo.getUserId());
        
        //populating list with records
        projects.add(project1);
        projects.add(project2);
        projects.add(project3);
        projects.add(project4);
        projects.add(project5);
        
        //insert Project data
        insert projects;
        
        //Set to hold the record type names
        Set<String> setRecordTypeNames = new Set<String>();
        setRecordTypeNames.add('CCA_Data_Load');
        setRecordTypeNames.add('CCA_Support_Request');
        setRecordTypeNames.add('CPRM_Data_Load');
        
        //get one record type name
        List<RecordType> listRecordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN : setRecordTypeNames 
                                                                 AND IsActive = true AND sObjectType = 'Site_Issue__c' ORDER BY DeveloperName ASC]); 
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[0].Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(2), 
                                                  Production_Migration_Approved__c = System.today().addDays(3),
                                                  Moved_to_Production__c = System.today().addDays(4), 
                                                  Final_QA_Complete__c = System.today().addDays(5),
                                                  Testing_Complete__c = System.today().addDays(6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue2 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[1].Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(-2), 
                                                  Production_Migration_Approved__c = System.today().addDays(-3),
                                                  Moved_to_Production__c = System.today().addDays(-4), 
                                                  Final_QA_Complete__c = System.today().addDays(-5),
                                                  Testing_Complete__c = System.today().addDays(-6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(-7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(-8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue3 = new Site_Issue__c(RecordTypeId = listRecordTypes[2].ID, Project__c = projects[2].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue4 = new Site_Issue__c(RecordTypeId = listRecordTypes[1].ID, Project__c = projects[3].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Insert Member Support Data
        Site_Issue__c sIssue5 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = projects[4].Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        //Add records to List
        sitIssueList.add(sIssue1);
        sitIssueList.add(sIssue2);
        sitIssueList.add(sIssue3);
        sitIssueList.add(sIssue4);
        sitIssueList.add(sIssue5);
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        
        //Insert Member Support records
        insert sitIssueList;
        
        //Test will stop here
        Test.stopTest();
        
        //Asert or the record type
        System.assertEquals(3, listRecordTypes.size());
        System.assertEquals('CCA_Data_Load', listRecordTypes[0].DeveloperName);
        System.assertEquals('CCA_Support_Request', listRecordTypes[1].DeveloperName);
        System.assertEquals('CPRM_Data_Load', listRecordTypes[2].DeveloperName);
        
        //Quering for the results
        sitIssueList = [SELECT ID, Notes_Recurring_Data__c, Production_Business_Analyst__c, Data_Analyst_Group_Lead__c, Crimson_Data_Analyst__c,
                        Technical_Project_Manager_new__c FROM Site_Issue__c ORDER BY Name ASC];
        System.assertEquals('testing', sitIssueList[0].Notes_Recurring_Data__c);
        //System.assertEquals(2, sitIssueList[0].Crimson_Data_Lag_1__c);
        //System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Production_Business_Analyst__c);  
        //System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Data_Analyst_Group_Lead__c);
        //System.assertEquals(Userinfo.getUserId(), sitIssueList[0].Crimson_Data_Analyst__c);
        System.assertEquals(null, sitIssueList[0].Technical_Project_Manager_new__c);
        System.assertEquals(null, sitIssueList[1].Technical_Project_Manager_new__c);
        System.assertEquals(null, sitIssueList[2].Technical_Project_Manager_new__c);
        //System.assertEquals(UserInfo.getName(), sitIssueList[3].Technical_Project_Manager_new__c);
        //System.assertEquals(UserInfo.getName(), sitIssueList[3].Technical_Project_Manager_new__c);
    }
    
    //Updated by Colin McGloin as part of the refactoring for increased code coverage
    static testMethod void test_CPRMDataLoadMS() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        //Create new Account
        Account account = new Account(Name = 'Test Account ', Account_Formal_Name__c = 'Test Account');
        insert account;
        
        //create new Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com',
                                  AccountId = account.Id, Employee_ID__c = 'Test 1', Title = 'Test', Phone = '614-555-8855');
        insert con;
        
        //RecordType
        //Modified By Dipesh Gupta - 09/26/2019 - CR-20190529-13156 - APS replaced by Tech (SSC) as per Taylor Chatter
        List<RecordType> projectRType = [SELECT ID, DeveloperName FROM RecordType WHERE DeveloperName = 'SSC' 
                                         AND IsActive = true AND sObjectType = 'Project__c'];
        System.assert(projectRType != null);
        
        //Create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data1', Notes_Implementation__c = 'The Great Ohioan', RecordTypeId = projectRType[0].ID/*,
                                            Recurring_Business_Analyst__c = Userinfo.getuserid()*/);
        insert project1;
        
        //get one record type name
        List<RecordType> listRecordTypes = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'CPRM_Data_Load' 
                                                                 AND IsActive = true AND sObjectType = 'Site_Issue__c']); 
        System.assert(listRecordTypes != null);      
        
        //List to hold the Member Support records
        List<Site_Issue__c> sitIssueList = new List<Site_Issue__c>();
        
        //Insert Member Support Data
        Site_Issue__c sIssue1 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = project1.Id,
                                                  Files_Received__c = System.today(),
                                                  Diagnostics_Sent__c = System.today().addDays(2), 
                                                  Production_Migration_Approved__c = System.today().addDays(3),
                                                  Moved_to_Production__c = System.today().addDays(4), 
                                                  Final_QA_Complete__c = System.today().addDays(5),
                                                  Testing_Complete__c = System.today().addDays(6), 
                                                  Files_Sent_to_Milliman__c = System.today().addDays(7),
                                                  DB_Received_from_Milliman__c = System.today().addDays(8),
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        Site_Issue__c sIssue2 = new Site_Issue__c(RecordTypeId = listRecordTypes[0].ID, Project__c = project1.Id,
                                                  Data_Load_Type__c = 'testing',
                                                  Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category',
                                                  Data_Load_Period_End__c = Date.Today().addDays(62),
                                                  Data_Load_Period_Begin__c = Date.today());
        
        sitIssueList.add(sIssue1);                                  
        sitIssueList.add(sIssue2);
        
        //Start testing here
        Test.startTest();
        
        //Enabling triggers back
        Util.BypassAllTriggers = false;
        insert sitIssueList;
        
        //Stop test here
        Test.stopTest();
        
        //Pull through the Project & Member Support for record comparison
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        project1 = [SELECT Name , Notes_Implementation__c /*,Recurring_Business_Analyst__c*/ FROM Project__c WHERE Id = :project1.Id];
        
        sIssue1 = [SELECT Id, Notes_Recurring_Data__c, Crimson_Data_Lag_1__c, Production_Business_Analyst__c, Data_Analyst_Group_Lead__c,
                          Crimson_Data_Analyst__c FROM Site_Issue__c WHERE Id = :sitIssueList[0].Id];
        
        //Assert the Project values came over to the Member Support record without issue
        System.assertEquals(sIssue1.Notes_Recurring_Data__c, project1.Notes_Implementation__c);
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
       // System.assertEquals(sIssue1.Production_Business_Analyst__c, project1.Recurring_Business_Analyst__c);
        //System.assertEquals(sIssue1.Data_Analyst_Group_Lead__c, project1.Data_Analyst__c);
    }
    
    //Added By - Ajit Surana - 03/02/2015 - CR-20150106-8468
    static testmethod void testvalidateContactFlagValues() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //String to hold error message
        String errormessage;
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Fetch profile from database
        List<Profile> profiles = [Select Id From Profile Where Name = 'System Administrator' LIMIT 1];
        
        //Assert for result
        System.assertEquals(1, profiles.size());
        
        //Create two users 
        User user1 = TestUtilities.CreatenewUser(profiles[0], true);
        User user2 = TestUtilities.CreatenewUser(profiles[0], true);
        
        //Create new Account
        Account account = new Account(Name = 'TestBIPC Account ', Account_Formal_Name__c = 'BIPC Account');
        
        //insert account here
        insert account;
        
        //Create a list of contact
        List<Contact> contacts = new List<Contact>();
        
        //Create new Contact
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com', AccountId = account.Id, Employee_ID__c = 'Test1',
                                 EmailBouncedReason = '', EmailBouncedDate = null, Title = 'Test', Phone = '614-555-8855'));
        
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com', AccountId = account.Id, Employee_ID__c = 'Test2',
                                 EmailBouncedReason = '', EmailBouncedDate = null, Title = 'Test', Phone = '614-555-8855'));
        
        //insert contacts
        insert contacts;
        
        //Create new Program record 
        Program__c program_BIPC = TestUtilities.CreateNewProgram(false);
        program_BIPC.Program_Acronym__c = 'BIPC';
        
        insert program_BIPC;
        
        //Create new Project__c data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project1 = new Project__c(Name = 'Test-Data-BIPC',/*Recurring_Business_Analyst__c = user1.Id,*/ Dedicated_Advisor__c = user1.Id, Product__c = program_BIPC.Id,
                                             Institution__c = account.Id);
        
        //insert Project data
        insert project1;
        
        //Create a list of Project Roles
        List<Project_Role__c> pRoles = new List<Project_Role__c>();
        
        //Create new Project Role data
        pRoles.add(new Project_Role__c(Project__c = project1.Id, Contact__c = contacts[0].Id, CCC_Include_in_Data_Load_Automated_Email__c = true));
        pRoles.add(new Project_Role__c(Project__c = project1.Id, Contact__c = contacts[1].Id, CCC_Include_in_Data_Load_Automated_Email__c = true));
        
        //insert Project Roles
        insert pRoles;
        
        // get one record type name
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CCA Data Load').getRecordTypeId();
        
        //Create List of Site
        Site_Issue__c sIssue1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', Site_Issue_Short_Description__c = 'Test-Description',
                                                  Category__c = 'Test-Category', Data_Load_Type__c = Constants.CURRENT, Project__c = project1.Id,
                                                  Crimson_Site_Issue_Description__c = 'Test Issue Description', RecordTypeId = rcordType,
                                                  Status__c = Constants.STATUS_SITE_ISSUE_22_SENT_EMAIL_UPDATE, Assigned_To_Contact__c = contacts[0].Id, 
                                                  CCC_Date_Observed__c = System.Today(), Site_Issue_Created_Date__c = System.now().addDays(-54),
                                                  Site_Issue_Close_Date__c = System.now().addDays(8), Hours_Spent__c = 2,
                                                  Data_Load_Period_End__c = Date.Today().addDays(-62),Application_Version__c='13.01',
                                                  Data_Load_Period_Begin__c = Date.today(), Files_Received__c = Date.today(),Internal_Load_Complete__c=Date.today(), Smoke_Test_Complete__c=Date.today(), Testing_Complete__c=Date.today(),
                                                  Ready_for_Final_QA__c=Date.today(), Moved_to_Production__c=Date.today(), Reason_for_Delay__c = 'Other',
                                                  Member_Facing_Resolution_Summary__c='test', Data_Submission_Target_Date__c = Date.today(),
                                                  Diagnostics_Sent__c = Date.today(), Diagnostics_Sign_Off_Received__c = Date.today());
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
    
        //Start Testing from here
        Test.StartTest();
    
        //Try-catch block to catch any error message if occured
        try{
    
            //Enabling trigger back
            Util.BypassAllTriggers = false;
    
            //insert Site Issue
            insert sIssue1;
    
        }catch(Exception e){
            errormessage = e.getMessage();       
        }
        
        //Stop Testing from here
        Test.stopTest();
        
        contacts = [SELECT Name, EmailBouncedReason From Contact];
        
        //Assert the email bounced reason is equal to null
        System.assertEquals(Contacts[0].EmailBouncedReason, null);
}
    
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures - Fixed too many Soql error
    //Added By - Ajit Surana - 05/07/2015 - CR-20140813-6993
    static testmethod void testvalidateAndPopulateQANotes() {
        
        Util.IsTest(true);
        Util.IsTesting = true;
        
        //Byapssing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Account
        Account account = new Account(Name = 'TestBIPC Account ', Account_Formal_Name__c = 'BIPC Account');
        insert account;
        
        //Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test1@test.com', 
                                      AccountId = account.Id, Employee_ID__c = 'Test1', Title = 'Test', Phone = '614-555-8855');
        insert contact;
        
        //Project
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;
        
        //List of eligible MS record types
        Id rcordType = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        
        //List to hold the member support records
        List<Site_Issue__c> siteIssues = new List<Site_Issue__c>();
        List<Site_Issue__C> memberSupports = new List<Site_Issue__c>();
        
        //Ste issue
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 1', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = project.Id, RecordTypeId = rcordType,
                                                   Assigned_To_Contact__c = contact.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-20),
                                                   Files_Received__c = Date.today(),
                                                   QA_Notes_and_Comments__c = 'Testing Notes');
        
        //Populating list with the records
        siteIssues.add(sIssue_1);
        
        //Creating variables to hold data for assertions later
        String MemSuppNotes0;
        Integer MemSuppListSize1;
        String MemSuppName1;
        String MemSuppNotes1;
        String MemSuppNotes2;
        Integer MemSuppListSize2;
        String MemSuppNotes3;
        String MemSuppNotes4;
                    
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        //Insert member supports
        insert siteIssues;
        
        //Querying results for the assertions
        memberSupports = [SELECT ID, QA_Notes_and_Comments__c FROM Site_Issue__c ORDER BY Category__c DESC];
        
        MemSuppNotes0 = memberSupports[0].QA_Notes_and_Comments__c;
        
        //Updating member supports to mark them as closed
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //memberSupports[0].Status__c = '22 - Production Migration Complete';
        memberSupports[0].Status__c = Constants.STATUS_MIGRATION_COMPLETE;

        memberSupports[0].Site_Issue_Close_Date__c = System.today().addDays(2);
        memberSupports[0].Data_Load_Period_Begin__c = System.today();
        memberSupports[0].Data_Load_Period_End__c = System.today().addDays(4);
        memberSupports[0].Percent_of_PCP_Revenue_Not_Captured__c = 10;
        memberSupports[0].Estimated_Prod_Team_Transition_Date__c = System.today();
        
        //Enabling trigger back
        Util.BypassAllTriggers = true;
        
        //Updating member supports
        update memberSupports;
        
        //Re-initailizing the list
        siteIssues = new List<Site_Issue__c>();
        
        Site_Issue__c sIssue_2 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 2', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                    Files_Received__c = Date.today());
        
        Site_Issue__c sIssue_3 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                    Site_Issue_Short_Description__c = 'Test-Description',
                                                    Category__c = 'Test-Category 3', Data_Load_Type__c = Constants.CURRENT, 
                                                    Project__c = project.Id, RecordTypeId = rcordType,
                                                    Assigned_To_Contact__c = contact.Id, 
                                                    Site_Issue_Created_Date__c = System.now().addDays(-20),
                                                    Files_Received__c = Date.today(),
                                                    QA_Notes_and_Comments__c = 'Testing');
        
        //Populating list with the records
        siteIssues.add(sIssue_2);
        siteIssues.add(sIssue_3);
        
        //Enabling trigger back
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();
        
        //V_1.8 - Modified By - Rajeev Jain - 10/20/2016 - Services Excellence - Manually merged code from ServicesEx to Test Sb.
        //Insert member supports
        insert siteIssues;
    
        //Enabling trigger back
        Util.BypassAllTriggers = true;        
        
        //Stop test
        Test.stopTest();
        
        //Querying results for the assertions
        memberSupports = [SELECT ID, Name, QA_Notes_and_Comments__c
                            FROM Site_Issue__c ORDER BY Category__c DESC];
        
        MemSuppListSize1 = memberSupports.size();
        MemSuppName1 = memberSupports[2].Name;
        MemSuppNotes1 = memberSupports[0].QA_Notes_and_Comments__c;
        MemSuppNotes2 = memberSupports[1].QA_Notes_and_Comments__c;
        MemSuppNotes3 = memberSupports[2].QA_Notes_and_Comments__c;                 
        
        System.assertEquals(MemSuppName1 + '<br><br>' + 'Testing Notes<br>Testing', MemSuppNotes1);
        System.assertEquals(MemSuppName1 + '<br><br>' + 'Testing Notes', MemSuppNotes2);
    }
    
    static testmethod void populateTier1Test(){
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Create a new user
        User User1 = TestUtilities.CreateNewUser(null,true);
        
        //Create a new Project
        Project__c TestProj = TestUtilities.createProject(true);
        
        //Grab the Member Support record type
        Id CCAMemSuppRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('Crimson Support Request').getRecordTypeId();
        
        //Create a new Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 4', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = TestProj.Id, RecordTypeId = CCAMemSuppRT,
                                                   Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                   Files_Received__c = Date.today(),
                                                   Tier_I_Support_Analyst__c = User1.Id);
        
        
        //Turn the triggers back on
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();
        
        //Update the Member Support Tier I Support Analyst
        insert sIssue_1;
        
        //Start Testing from here
        Test.StopTest();
        
        //Pull through the Member Support and User Data
        sIssue_1 = [SELECT Id, Tier_I_Support_Analyst__c FROM Site_Issue__c WHERE ID =:sIssue_1.Id];
        User1 = [SELECT Id, Name FROM User WHERE Id =:User1.Id];
        
        //The User listed as Tier I Support Analyst should be the name entered into the field on the 
        System.assertEquals(User1.Name, sIssue_1.Tier_I_Support_Analyst__c);
    }
    
    static testmethod void testPunctualityofLoads(){
        
        //Bypassing all triggers so then test data can be created for testing purpose
        Util.BypassAllTriggers = true;
        
        //Create a new user
        User User1 = TestUtilities.CreateNewUser(null,true);
        
        //Create a new Project
        Project__c TestProj = TestUtilities.createProject(true);
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //TestProj.Punctuality_of_Loads__c = Constants.PROJECT_PUNCTUALITY_OF_LOADS_TBD;
        
        Update TestProj;
        
        //Grab the Member Support record type
        Id CCADLMMemSuppRT = Schema.SObjectType.Site_Issue__c.getRecordTypeInfosByName().get('CMA Data Load/Migration').getRecordTypeId();
        
        //Create a new Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Site_Issue_Priority__c = 'High', 
                                                   Site_Issue_Short_Description__c = 'Test-Description',
                                                   Category__c = 'Test-Category 4', Data_Load_Type__c = Constants.CURRENT, 
                                                   Project__c = TestProj.Id, RecordTypeId = CCADLMMemSuppRT,
                                                   Site_Issue_Created_Date__c = System.now().addDays(-10),
                                                   Files_Received__c = Date.today(),
                                                   Next_Data_Upload_Expected_On2__c = Date.today().addDays(-54),
                                                   Tier_I_Support_Analyst__c = User1.Id);
        
        //Turn the triggers back on
        Util.BypassAllTriggers = false;
        
        //Start Testing from here
        Test.StartTest();

        insert sIssue_1;

        //Start Testing from here
        Test.StopTest();
        
        //Pull through the Project Data
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        //TestProj = [SELECT Id/*, Punctuality_of_Loads__c */FROM Project__c WHERE ID =:TestProj.Id];
        
        //The Punctuality of Loads field should now be updated and match the 'Typically Late' status
        //System.assertEquals(TestProj.Punctuality_of_Loads__c, Constants.PROJECT_PUNCTUALITY_OF_LOADS_TYPICALLY_LATE);
    }
    
    //V_1.6 - Modified By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
    //V_1.10 - Modified By - Rajeev Jain - 11/30/2016 - Fixing the test class failures
    //Added by - Abhinav Sharma - 11/28/2015 - CR-20150601-8977
    static testMethod void test_CPRMDataLoadTicketUseCases() {

        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
       
        //Project
        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
        Project__c project = new Project__c(Name = 'Test-Data'/*, Recurring_Business_Analyst__c = Userinfo.getUserId()*/);
        
        insert project;
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Query for the "Member Support" record types (CMA Data Load/Migration)
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE sObjectType = 'Site_Issue__c' 
                                        AND DeveloperName = 'CPRM_Data_Load' 
                                        AND isActive = true];
        //Asert or the record type
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //List to hold the member support records
        List<Site_Issue__c> memberSupports = new List<Site_Issue__c>();
        
        //Member Support
        Site_Issue__c sIssue_1 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 1', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.Today().addDays(3),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 1', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_2 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 2', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(6),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 2', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        
        Site_Issue__c sIssue_3 = new Site_Issue__c(Crimson_Site_Issue_Description__c = 'Test Issue Description 3', 
                                                   RecordTypeId = recordTypes[0].Id, Project__c = project.Id, 
                                                   Site_Issue_Created_Date__c = System.now().addDays(-3), 
                                                   Site_Issue_Close_Date__c = System.now().addDays(3), 
                                                   Data_Load_Period_End__c = System.today().addDays(5),
                                                   Data_Load_Period_Begin__c = System.today(), 
                                                   Files_Received__c = System.today(),
                                                   Status__c = 'Test 3', PRM_Application_Version__c = '2014.10', 
                                                   Percent_of_PCP_Revenue_Not_Captured__c = 23);
        memberSupports.add(sIssue_1);
        memberSupports.add(sIssue_2);
        memberSupports.add(sIssue_3);
        
        //Start Test
        Test.startTest();
        
        //Enabling trigger again
        Util.BypassAllTriggers = false;
        
        //insert Site Issue
        insert memberSupports;
        
        //Retrieving member support details
        memberSupports = [SELECT ID, Production_Business_Analyst__c, Status__c, Elapsed_Open_to_Actual_Resolution_Hours__c,
                          Elapsed_Open_to_Acknowledged_Hours__c, Elapsed_Open_to_First_Response_Hours__c, Elapsed_Open_to_Close_Hours__c
                          FROM Site_Issue__c ORDER BY Status__c ASC];
        
        //Asserting for the results
        System.assert(memberSupports != null);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[0].Crimson_Data_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[0].Production_Business_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[1].Crimson_Data_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[1].Production_Business_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[2].Crimson_Data_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[2].Production_Business_Analyst__c);
        
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_Actual_Resolution_Hours__c);
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_Acknowledged_Hours__c);
        System.assertEquals(null, memberSupports[0].Elapsed_Open_to_First_Response_Hours__c);
        System.assertEquals(null, memberSupports[1].Elapsed_Open_to_First_Response_Hours__c);
        System.assertEquals(null, memberSupports[2].Elapsed_Open_to_First_Response_Hours__c);
        //System.assertNotEquals(null, memberSupports[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[0].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[1].Elapsed_Open_to_Close_Hours__c);
        //System.assertEquals(27, memberSupports[2].Elapsed_Open_to_Close_Hours__c);
        //V_1.6 - Added By - Mahendra Swarnkar - 08/27/2016 - CR-20160114-9520 - Upto here
        
        //Update member support fields
        //memberSupports[0].Crimson_Data_Analyst__c = null;
        memberSupports[0].Production_Business_Analyst__c = null;
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Update the member support records
        update memberSupports[0];
        
        //Stop Test
        Test.stopTest();
        
        //Enabling all triggers
        Util.BypassAllTriggers = false;
        
        //Querying remaining member supports
        memberSupports = [SELECT ID, Production_Business_Analyst__c
                          FROM Site_Issue__c ORDER BY Status__c ASC];
        
       
        //Asserting for the results
        System.assert(memberSupports != null);
        //System.assertEquals(null, memberSupports[0].Crimson_Data_Analyst__c);
        System.assertEquals(null, memberSupports[0].Production_Business_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[1].Crimson_Data_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[1].Production_Business_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[2].Crimson_Data_Analyst__c);
        //System.assertEquals(Userinfo.getUserId(), memberSupports[2].Production_Business_Analyst__c);
    }
    
   
    //V1.12 - Added By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017
    //Commented out by Colin McGloin - Spring Cleaning - Relevant Record Types removed 
    /*static testMethod void Test_SendEmailCMADataLoadAndPRMDataLoadCompletion() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
    
        //Bypassing all trigger so then testing data can be created with ease
        Util.BypassAllTriggers = true;
        
        User u = TestUtilities.CreatenewUser(true);
        
        //Insert the Program records
        Program__c prog = new Program__c(Name = 'Test Prog', Program_Acronym__c = 'Test', 
                                           Status__c = 'Active', Create_Memberships__c = 'No');
        insert prog;
        
        //Getting Record Type Id Value for Project object
    ID cmaProjRecordTypeId = [Select Id, Name FROM RecordType 
                                    WHERE SobjectType = 'Project__c' 
                                    AND RecordType.DeveloperName = 'CMA' AND IsActive = true].Id;
        
        //Getting Record Type Id Value for Project object
    ID CMADataLoadMigrationMSRecordTypeId = [Select Id, Name FROM RecordType 
                                    WHERE SobjectType = 'Site_Issue__c' 
                                    AND RecordType.DeveloperName = 'CMA_Data_Load_Production' AND IsActive = true].Id;
        
        //Create a temporary date instanse
        Date d = Date.today();
        d = d.addDays(-40);
        
        //insert Account
        Account acc =  new Account(Name = 'Test Account');
        insert acc;
        
        //Insert Contact
        List <Contact> conlist = new List<Contact>();
        conlist.add(new Contact( FirstName = 'Test First', LastName = 'Test Last Portal Only', AccountId = acc.id, 
                                     Email = 'testuser1milliman@noreply.com', Is_Ignore_Phrase_Characters__c = true, Title = 'Test', Phone = '614-555-8855' ));
        
        conlist.add(new Contact( FirstName = 'Test First', LastName = 'TestLastName', AccountId = acc.id, 
                                     Email = 'testuser2@noreply.com', Is_Ignore_Phrase_Characters__c = true, Title = 'Test', Phone = '614-555-8855' ));
        insert conlist; 
        
        //Insert the Project records
        Project__c project1 = new Project__c(Name = 'Test-Data',  RecordTypeId = cmaProjRecordTypeId, 
                                               Recurring_Business_Analyst__c = u.Id, Product__c = prog.ID, 
                                               Percent_of_PCP_Not_Captured__c = 50, Current_Data_Period_New__c = d,
                                              Load_Frequency__c = 'Monthly', Crimson_Data_Lag__c = 4 
                                            );
        insert project1;
        
        
        //Insert Project Roles
        List<Project_Role__c> listProjRole = new List<Project_Role__c>(); 
        listProjRole.add(new Project_Role__c(Name = 'Test ROle Portal Only 1', Project__c = project1.Id, Contact__c = conlist[0].Id, 
                        Role__c = 'Benefits Lead', Project_Type__c = 'CMA', 
                                                Receive_CMA_Load_Completed_Email__c = true )); 
    listProjRole.add(new Project_Role__c(Name = 'Test ROle 3', Project__c = project1.Id, Contact__c = conlist[1].Id, 
                        Role__c = 'Benefits Lead', Project_Type__c = 'CMA', 
                                                Receive_CMA_Load_Completed_Email__c = true ));
        
        listProjRole.add(new Project_Role__c(Name = 'Test ROle Portal Only 2', Project__c = project1.Id, Contact__c = conlist[0].Id, 
                        Role__c = 'Benefits Lead', Project_Type__c = 'CMA', 
                                                Receive_PRM_Load_Completed_Email__c = true )); 
    listProjRole.add(new Project_Role__c(Name = 'Test ROle 4', Project__c = project1.Id, Contact__c = conlist[1].Id, 
                        Role__c = 'Benefits Lead', Project_Type__c = 'CMA', 
                                                Receive_PRM_Load_Completed_Email__c = true ));
        insert listProjRole;
        
        //Insert Member Support records
        Site_Issue__c ms1 = new Site_Issue__c( RecordTypeId = CMADataLoadMigrationMSRecordTypeId, Project__c = project1.Id , 
                                                Status__c = 'Migration complete' , Site_Issue_Short_Description__c = 'Test MS 1',
                                                Assigned_To_Contact__c = conlist[0].Id, Site_Issue_Created_Date__c = System.today(),
                                                Files_Received__c = System.today(), Site_Issue_Close_Date__c = System.today().addDays(2),
                                                Site_Issue_Priority__c = 'Normal', Production_Business_Analyst__c = u.Id, 
                                                Cause_for_Delay__c = 'Awaiting Member Response', Application_Version__c = '2017.11',
                                                Data_Load_Type__c = 'Current', Data_Load_Period_Begin__c =   System.today().addDays(-2),
                                                Data_Load_Period_End__c = System.today().addDays(1), Market_Data_Period_Begin__c = System.today(),
                                                Market_Data_Period_End__c = System.today().addMonths(1), Percent_of_PCP_Revenue_Not_Captured__c = 55,
                                                Estimated_Prod_Team_Transition_Date__c = System.today().addDays(5)
                                             ); 
     
        //Enable all the triggers 
        Util.BypassAllTriggers = False;
        
        //Test Starts from here
        Test.startTest();
        
        //Insert Member support record
        /*insert ms1; 
        
        //Query the MemberSupport records
        List<Site_Issue__c> memSupport = [Select Id, Status__c, Data_Load_Type__c From Site_Issue__c];
        
        //Asserts on results
        System.assertEquals(1,  memSupport.size());
        System.assertEquals('Migration complete',  memSupport[0].Status__c);
        System.assertEquals('Current',  memSupport[0].Data_Load_Type__c);
        
        //Update the MemberSupport
        ms1.Data_Load_Type__c = 'Off-Cycle/Migration';
        update ms1;
     
        //Test Stops here
        Test.stopTest();
        
        //Query the MemberSupport records
        memSupport = [Select Id, Data_Load_Type__c, Status__c From Site_Issue__c where Id =: ms1.Id];
        
        //Asserts on results
        System.assertEquals('Migration complete',  memSupport[0].Status__c);
        System.assertEquals('Off-Cycle/Migration',  memSupport[0].Data_Load_Type__c);
    }*/
    
}