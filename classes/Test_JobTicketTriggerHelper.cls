/**
 *  Purpose         :   Test class for JobTicketTriggerHelper
 *  
 *  CreatedDate     :   21/10/2019
 *  
 *  RevisionLog     :   V_1.0 - Created - Dipesh Gupta
 *		    :   V_1.1 - Modified By Dipesh Gupta - 4/22/2020  --- CR-20200415-13951
 *		    :   V_1.2 - Modified By Victor Hanson - 05/15/2020 - CR-20200514-14041 - Updated tests to reference testSetupData and added logic to testCheckUpdateJobTicketName
 *		    :   V_1.3 - Modified By Dipesh Gupta - 06/12/2020 - CR-20200612-14177 - JobTicket Name sections
 *		    :   V_1.4 - Modified By Victor Hanson - 06/30/2020 - CR-20200609-14157 - verify ceeb is not included in name when null
 *		    :   V_1.5 - Modified By Abhinav Sharma - 07/10/2020 - CR-20200709-14285 - Update box folder name 
 *		    :   V_1.6 - Modified By Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
 *		    :   V_1.7 - Modified By Abhinav Sharma - 05/12/2021 - CR-20210510-15129 -  
 *		    :   V_1.8 - Modified By Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
 *		    :   V_1.9 - Modified By Shalu Sharma - 05/21/2021 - CR-20200713-14292 - Add reuired field i.e Insertion Order, Job Code and Project fields when JT set to Approved by Partner
 *		    :   V_2.0 - Modified By Neha Sharma - 04/30/2021 - CR-20210323-15016 - populate drop type
 *		    :   V_2.1 - Modified By Neha Sharma - 06/17/2021 - CR-20210330-15044 - Remove the Laser field
 *		    :   V_2.2 - Modified By Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
 *		    :   V_2.3 - Modified By Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
 *		    :   V_2.4 - Modified By Abhishek Mishra - 09/28/2021 - CR-20200527-14111 - Removed the refrence of  Component Type inactive value 'Letter'
 *		    :   V_2.5 - Modified By Nikita Kumari - CR-20210916-15441 - 10/01/2021 - Added condition in test method test_CreateFulfillmentRecordsForDropUpdate for postage class for PT records 
 *		    :   V_2.6 - Modified By Subhash Garhwal - 10/13/2021 -CR-20211012-15513 - Added new test method testChangeReasonRequiredForLockedRecord() for ChangeReasonRequiredForLockedRecord() method. 
 *		    :   V_2.7 - Modified By Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new menthod "test_populatePTPrintQuantityContractedOnInventory"
 *		    :   V_2.8 - Modified By Shalu Sharma - 19/01/2021 - CR-20220105-15694 - Update method "test_populatePTPrintQuantityContractedOnInventory"
**/
@IsTest
private class Test_JobTicketTriggerHelper
{
    @testSetup static void testSetupData()
    {
        util.bypassAllTriggers = true;
        //Create Program
        Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
        insert prog;
        
        // Create Account
        Account acct = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',
                                   r_School_Code__c = 'BR', r_CEEB_Code__c = '1232', Fiscal_Year__c='2021',
                                   RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR);
        insert acct;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        Id userId = UserInfo.getUserId();
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = acct.Id, Fiscal_Year__c = '2019');
        insert project;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        //VH 06/11/2020 - added mail vendor to job ticket
        //insert job tickets
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Vendor_Type__c='Offset', Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = UserInfo.getUserId(), 
                                         Project__c = project.id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(), Mail_Vendor__c = acct.Id,
                                         Production_Manager__c = UserInfo.getUserId(),of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2020', Program__c = Prog.Id));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Vendor_Type__c='Offset', Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = UserInfo.getUserId(), 
                                         Project__c = project.id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(), Mail_Vendor__c = acct.Id,
                                         Production_Manager__c = UserInfo.getUserId(),of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2020', Program__c = Prog.Id));
        util.bypassAllTriggers = false;
        insert jobTickets;
        
        
    }
    
    @IsTest static void testJobTicketTriggerHelper()
    {
        Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
        
        //get the existing project
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        Test.startTest();
        Id userId = UserInfo.getUserId();
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Status__c, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        system.assertEquals(true , jobTickets.size() > 0);
        system.assertEquals('Draft', jobTickets[0].Status__c);
        
        // Update Status from Draft to Ready for Production
        jobTickets[0].Status__c = 'In Progress';
        jobTickets[0].Change_Reason__c = 'Testing After Update';
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        jobTickets[0].Insertion_Order__c = 'ADM - Letter driver';
        jobTickets[0].Job_Code__c = '123456';
        jobTickets[0].Project__c = proj.Id;
        update jobTickets[0];
        system.assertEquals('In Progress', jobTickets[0].Status__c);
        system.assertEquals(userId, jobTickets[0].Project_Manager__c);
        
        // Creating Set To store Job_Ticket__c Id
        Set<Id> jobTicketIds = new Set<Id>();       
        for(Job_Ticket__c jT : jobTickets)
        {
            jobTicketIds.add(jT.Id);
        }
        
        //Calling a Batch job that will create the respective fulfillment records. 
        system.assertEquals(true , jobTicketIds.size() > 0);
        Batch_CreateFulfillmentTracking batch = new Batch_CreateFulfillmentTracking(jobTicketIds); 
        Database.executeBatch(batch,25);
        
        Test.stopTest();
        
        jobTickets[1].Mail_Quantity__c = 100;
        try{
            update jobTickets;
        }
        catch(DMLException ex){
            system.assertEquals('If editing a Locked Record then you must enter a new Change Reason',ex.getDmlMessage(0));
        }
        
        List<Job_Ticket_Estimate_Component__c> jobTicketEstimateComponents = [SELECT Id FROM Job_Ticket_Estimate_Component__c];
        system.assertEquals(0, jobTicketEstimateComponents.size());
        
        List<Job_Ticket_Estimates__c> jobTicketEstimates = [SELECT Id FROM Job_Ticket_Estimates__c];
        system.assertEquals(0, jobTicketEstimates.size());
    }
    
    @IsTest static void testCheckUpdateJobTicketName() {
        
        util.bypassAllTriggers = true;
        
        //Create Program
        Program__c prog = TestUtilities.createNewProgram(null, 'ESAM', 'No', 'Enrollment Services', false);
        insert prog;
        
        //get the existing project
        Project__c proj = [SELECT Id, Institution__c FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Job_Ticket_Name_Number__c, Name, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        system.assertEquals(2, jobTickets.size());
        boolean hasName1 = false;
        boolean hasName2 = false;
        for (Job_Ticket__c jt : jobTickets) {
            if (jt.Job_Ticket_Name_Number__c == 1) {
                //verify the name does not end with '-1' (ie: we expect something like BR-1232-2021-ESNN)
                system.assertEquals(false, jt.Name.endsWith('-1'));
                hasName1 = true;
            }
            else if (jt.Job_Ticket_Name_Number__c == 2) {
                //verify the name ends with '-2' (ie: BR-1232-2021-ESNN-2)
                system.assertEquals(true, jt.Name.endsWith('-2'));
                hasName2 = true;
            }
        }
        system.assertEquals(true, hasName1);
        system.assertEquals(true, hasName2);
        
        //VH 06/30/2020 - CR-20200609-14157 - verify ceeb is not included in name when null
        //remove the CEEB code from the institution and update the job ticket to verify the name is updated accordingly
        Account a = new Account(Id=proj.Institution__c,
                                r_CEEB_Code__c = null);
        update a;
        update jobTickets;
        jobTickets = [SELECT Id, Name, School_Code__c, Project__r.Fiscal_Year__c, CEEB_Code__c,
                      Program__r.Program_Acronym__c, Project__r.Institution__r.r_CEEB_Code__c
                      FROM Job_Ticket__c 
                      WHERE Id IN :jobTickets AND Job_Ticket_Name_Number__c = 1 LIMIT 1];
        //String jtNameWithoutCEEB = jobTickets[0].School_Code__c + '-' + jobTickets[0].Project__r.Fiscal_Year__c +  '-' + jobTickets[0].Program__r.Program_Acronym__c;
        system.assertEquals(null, jobTickets[0].Project__r.Institution__r.r_CEEB_Code__c);
        system.assertEquals(null, jobTickets[0].CEEB_Code__c);
        JobTicketTriggerHelper.checkUpdateJobTicketName(jobTickets, null);
        jobTickets = [SELECT Id, Name, School_Code__c, Project__r.Fiscal_Year__c, CEEB_Code__c,
                      Program__r.Program_Acronym__c, Project__r.Institution__r.r_CEEB_Code__c
                      FROM Job_Ticket__c 
                      WHERE Id IN :jobTickets AND Job_Ticket_Name_Number__c = 1 LIMIT 1];
        system.assertEquals(false, jobTickets[0].Name.contains('null'));
    }
    
    @isTest
    static void testPopulateFiscalYearWithSubsPeriodYear(){
        
        
        util.bypassAllTriggers = true;
        
        //Create Program
        Program__c prog = TestUtilities.createNewProgram(null, 'ESAM', 'No', 'Enrollment Services', false);
        insert prog;
        
        //get the existing project
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //cpq subscription
        SBQQ__Subscription__c cpq = new SBQQ__Subscription__c();
        cpq.SBQQ__Quantity__c = 10;
        
        insert cpq;
        
        //Subscription period
        Subscription_Period__c sub = new Subscription_Period__c();
        sub.Name = 'Test';
        sub.Program_Subscription__c = cpq.Id;
        sub.Year__c = '2019';
        
        Subscription_Period__c sub1 = new Subscription_Period__c();
        sub1.Name = 'Test';
        sub1.Program_Subscription__c = cpq.Id;
        sub1.Year__c = '2020';
        
        insert sub;
        insert sub1;
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        //get job tickets
        jobTickets = [SELECT Id, Name, Job_Ticket_Name_Number__c FROM Job_Ticket__c WHERE Id IN :jobTickets];
        system.assertEquals(2, jobTickets.size());
        
        List<Job_Ticket__c> jobs = [SELECT Id, Fiscal_Year__c FROM Job_Ticket__c];
        jobs[0].Fiscal_Year__c = null;
        jobs[0].Subscription_Period__c = sub.Id;
        
        util.bypassAllTriggers = false;
        update jobs;
        
        jobTickets = [SELECT Id, Name, Job_Ticket_Name_Number__c, Subscription_Period__c,Fiscal_Year__c  FROM Job_Ticket__c WHERE Id IN :jobTickets];
        jobs[0].Fiscal_Year__c = '2020';
        jobs[0].Subscription_Period__c = sub1.Id;
        
        //Commented By - Abhinav Sharma - CR-20210510-15129 - 05/12/2021
        util.bypassAllTriggers = false;
        //JobTicketTriggerHelper.Bypass_DublicateJobTicket = true;
        update jobs;
        //JobTicketTriggerHelper.Bypass_DublicateJobTicket = false;
        
    }
    
    @isTest
    static void testValidateJobTicketMTM(){
        
        util.bypassAllTriggers = true;
        
        Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
        
        //get the existing project
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //cpq subscription
        SBQQ__Subscription__c cpq = new SBQQ__Subscription__c();
        cpq.SBQQ__Quantity__c = 10;
        
        insert cpq;
        
        //Subscription period
        Subscription_Period__c sub = new Subscription_Period__c();
        sub.Name = 'Test';
        sub.Program_Subscription__c = cpq.Id;
        
        Subscription_Period__c sub1 = new Subscription_Period__c();
        sub1.Name = 'Test';
        sub1.Program_Subscription__c = cpq.Id;
        
        insert sub;
        insert sub1;
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        //get job tickets
        jobTickets = [SELECT Id, Name, Job_Ticket_Name_Number__c FROM Job_Ticket__c WHERE Id IN :jobTickets];
        system.assertEquals(2, jobTickets.size());
        
        List<Job_Ticket__c> jobs = [SELECT Id, Fiscal_Year__c FROM Job_Ticket__c];
        jobs[0].Status__c = 'Approved by Partner';
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        jobs[0].Insertion_Order__c = 'ADM - Letter driver';
        jobs[0].Job_Code__c = '123456';
        jobs[0].Project__c = proj.Id;
        
        util.bypassAllTriggers = false;
        update jobs;
        
        List<Job_Ticket_Component__c> jtComponents = new List<Job_Ticket_Component__c>();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jtComponents.add(new Job_Ticket_Component__c(Component__c = Constants.COMPONENT_TYPE_BRE));
        jtComponents.add(new Job_Ticket_Component__c(Component__c = 'Envelope'));
        insert jtComponents;
        //Modified By - Abhishek Mishra - 09/28/2021 - CR-20200527-14111 -  Component_Type__c = 'Letter' ->  Component_Type__c = 'Form-Control'
        Job_Ticket_MtM__c jobTktMTM = new Job_Ticket_MtM__c(Job_Ticket__c = jobs[0].Id, Job_Ticket_Component__c=jtComponents[0].Id, Component_Type__c = 'Form',Paper_Typex__c = '',Paper_Weightx__c= '',Component_Code__c='',Front_Colors_PMS__c='');
        Job_Ticket_MtM__c jobTktMTM1 = new Job_Ticket_MtM__c();
        jobTktMTM1.Job_Ticket__c = jobs[1].Id;
        jobTktMTM1.Component_Type__c = '';
        jobTktMTM1.Paper_Typex__c = '';
        jobTktMTM1.Paper_Weightx__c= '';
        jobTktMTM1.Component_Code__c='';
        //jobTktMTM1.Front_of_Colors__c='';
        jobTktMTM1.Front_Colors_PMS__c='';
        jobTktMTM1.Job_Ticket_Component__c = jtComponents[1].Id;
        util.bypassAllTriggers = false;
        insert jobTktMTM;
        insert jobTktMTM1;
        
    }
    
    @isTest
    static void testPopulateProjectManagerOnProductionTracking(){
        
        util.bypassAllTriggers = true;
        
        //Create Program
        Program__c prog = TestUtilities.createNewProgram(null, 'ESAM', 'No', 'Enrollment Services', false);
        insert prog;
        
        //get the existing project
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //user
        User u = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'].Id,
                          LastName = 'last',
                          Email = 'puser000@amamama.com',
                          Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                          CompanyName = 'TEST',
                          Title = 'title',
                          Alias = 'alias',
                          TimeZoneSidKey = 'America/Los_Angeles',
                          EmailEncodingKey = 'UTF-8',
                          LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US'                         
                         );
        insert u;
        
        //create duplicate job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        //get job tickets
        jobTickets = [SELECT Id, Name, Job_Ticket_Name_Number__c FROM Job_Ticket__c WHERE Id IN :jobTickets];
        system.assertEquals(2, jobTickets.size());
        
        List<Job_Ticket__c> jobs = [SELECT Id, Fiscal_Year__c FROM Job_Ticket__c];
        jobs[0].Project_Manager__c = u.Id;
        
        util.bypassAllTriggers = false;
        update jobs;
        
        //Production Tracking
        Production_Tracking__c pros = new Production_Tracking__c(Job_Ticket__c = jobs[0].Id );
        util.bypassAllTriggers = false;
        insert pros;
    }
    
    @isTest
    static void testCreateBoxFoldersForJobTicket(){
        
        JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = true;
        JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = false;
        
        util.bypassAllTriggers = true;
        
        Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
        
        //get the existing project
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //get job tickets
        List<Job_Ticket__c> jobs = [SELECT Id, BOX_Folder_Link__c, Box_Folder_Id__c, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        system.assertEquals(2, jobs.size());
        
        //Modified By Abhinav Sharma - 09/22/2021 - CR-20210913-15431 - Box folders not getting created and/or linked in some JTs
        /*jobs[0].Status__c = Label.Job_Ticket_BoxFolderCreation_Status;
        jobs[1].Status__c = Label.Job_Ticket_BoxFolderCreation_Status;
        
        jobs = [SELECT Id, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        util.bypassAllTriggers = false;
        update jobs;*/
        
    }
    
    //Modified by Dipesh Gupta - 06/12/2020 - CR-20200612-14177 - JobTicket Name sections
    @isTest
    static void testCheckJobTicketTemplateName()
    {
        Id JobTicketTemplateRTId = Util.RecordTypeId('Job_Ticket__c', 'Job Ticket Template');
        //Modified By - Neha Sharma - 06/17/2021 - CR-20210330-15044 - Removed the Laser field from Job Ticket 
        Job_Ticket__c jobTicket = new Job_Ticket__c(Name = 'Test12', Template_Name__c = 'Test Template', Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,
                                                    RecordTypeId = JobTicketTemplateRTId, Status__c = 'Active'/*, Laser__c ='Simplex'*/);
        insert jobTicket;
        System.assert(jobTicket.Name != null);
        List<Job_Ticket__c> listOfJobTicket = [SELECT Id, Name FROM Job_Ticket__c WHERE RecordType.Name = 'Job Ticket Template'];
        
    }
    
    //Modified by Abhinav Sharma - 07/10/2020 - CR-20200709-14285 - Update box folder name 
    @isTest
    static void test_UpdateBoxFoldersJT(){
        
        // Create Account
        Account acct2 = new Account(Vendor_Type__c = 'Vendor', Name = 'Test2',Account_Formal_Name__c = 'Sepire2',
                                    r_School_Code__c = 'BR2', r_CEEB_Code__c = '8549', Fiscal_Year__c='2022',
                                    RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR);
        insert acct2;
        
        util.bypassAllTriggers = true;
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = accountId, Fiscal_Year__c = '2019');
        insert project;
        
        //get job tickets
        List<Job_Ticket__c> jobs = [SELECT Id, Project__c, Program__c, Change_Reason__c   
                                    FROM Job_Ticket__c];
        system.assert(jobs.size() != null);
        
        jobs[0].Project__c = project.Id;
        jobs[0].Change_Reason__c = 'Update Project';
        jobs[0].Box_Folder_Id__c = 'testId';
        jobs[0].Mail_Vendor__c = acct2.Id;
        
        util.bypassAllTriggers = false;
        update jobs;
        
    }
    //Added By - Abhinav Sharma - 01/05/2021 - CR-20201105-14666 - Add automation when Drop # is updated on JT
    //Modified By - Nikita Kumari - CR-20210916-15441 - 10/01/2021 - Added condition for postage class for PT records 
    @IsTest static void test_CreateFulfillmentRecordsForDropUpdate()
    {
        Test.startTest();
        Id userId = UserInfo.getUserId(); 
        
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Status__c, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c];
        
        system.assertEquals(true , jobTickets.size() > 0);
        system.assertEquals('Draft', jobTickets[0].Status__c);
        
        // Update Status from Draft to Approved By Partner and update Drop
        jobTickets[0].Status__c = 'Approved By Partner';
        jobTickets[0].of_Drops__c = 3;
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        jobTickets[0].Insertion_Order__c = 'ADM - Letter driver';
        jobTickets[0].Job_Code__c = '123456';
        jobTickets[0].Project__c = proj.Id;
        
        //populate postage class field on JT after PT records created 
        jobTickets[0].Postage_Class__c = 'Non-Profit (200 Piece Minimum)';
        update jobTickets[0];
        
        Set<Id> jobTicketIds = new Set<Id>();       
        for(Job_Ticket__c jT : jobTickets)
        {
            jobTicketIds.add(jT.Id);
        }
        
        //Calling a Batch job that will create the respective fulfillment records. 
        system.assertEquals(true , jobTicketIds.size() > 0);
        Batch_CreateFulfillmentTracking batch = new Batch_CreateFulfillmentTracking(jobTicketIds); 
        Database.executeBatch(batch,25);
        
        Test.stopTest();
        
        List<Production_Tracking__c> productionTracking = [SELECT Id, Drop__c, Postage_Class__c, Previous_Production_Tracking__c FROM Production_Tracking__c];
        System.assertEquals(true , productionTracking.size() > 0);
        
        
        //Assert to check populated postage class value on PT's 
        System.assertEquals(jobTickets[0].Postage_Class__c, productionTracking[0].Postage_Class__c);
        System.assertEquals(jobTickets[0].Postage_Class__c, productionTracking[1].Postage_Class__c);
        
        //update postage class to null in pt records 
        productionTracking[0].Postage_Class__c = null;
        
        util.bypassAllTriggers = true;
        update productionTracking[0];
        util.bypassAllTriggers = false;
        
        //now update postage class field value and check  PT record whose postage class is null 
        jobTickets[0].Postage_Class__c = 'Presort 1st Class (500 piece minimum)';
        jobTickets[0].Change_Reason__c = 'Updating record to check null postage class field of associated pt records';

        update jobTickets[0];
        
        // query pt records
        productionTracking = [SELECT Id, Postage_Class__c FROM Production_Tracking__c WHERE Job_Ticket__c = :jobTickets[0].Id];
        
        //Assert to check populated postage class value on PT's both should be different 
        System.assertEquals('Presort 1st Class (500 piece minimum)', productionTracking[0].Postage_Class__c);
        System.assertEquals('Non-Profit (200 Piece Minimum)', productionTracking[1].Postage_Class__c);
    }
    
    @IsTest 
    static void test_createPrintPTRecordsOnDropOnDemand() {
        
        
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Status__c, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, 
                                          Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, 
                                          of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c LIMIT 1];
        
        jobTickets[0].Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND;
        jobTickets[0].of_Drops__c = 3;
        
        //Added By Shalu Sharma - 05/21/2021 - CR-20200713-14292
        jobTickets[0].Insertion_Order__c = 'ADM - Letter driver';
        jobTickets[0].Job_Code__c = '123456';
        jobTickets[0].Project__c = proj.Id;
        
        update jobTickets;
        
        Map<Id,Job_Ticket__c> mapOfJobTicket = new Map<Id,Job_Ticket__c>();
        for(Job_Ticket__c jT: jobTickets)
            mapOfJobTicket.put(jT.Id, jT);
        
        system.assertEquals(true , jobTickets.size() > 0);
        system.assertEquals('Draft', jobTickets[0].Status__c); 
        
        Test.startTest();
        
        util.bypassAllTriggers = false;
        // Update Status from Draft to Approved By Partner and update Drop
        jobTickets[0].Status__c = System.Label.Print_Production_Tracking_Creation_Status ;
        update jobTickets[0];
        
        Test.stopTest();
    } 
    
    //Modified By Shalu Sharma - 09/24/2021 - CR-20210922-15453 - For on demand job tickets, generate auto-number for project ID
    @isTest
    static void testPopulateProjIdWithAutoNumberOnJT(){
        
        //get Program
        Program__c prog = [SELECT Id FROM Program__c LIMIT 1];
        
        //get project
        Project__c proj = [SELECT Id, Institution__c FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Vendor_Type__c='Offset', Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = UserInfo.getUserId(), 
                                         Project__c = proj.id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(), Mail_Vendor__c = proj.Institution__c, Project_ID__c = '12345',
                                         Production_Manager__c = UserInfo.getUserId(),of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2021', Program__c = prog.Id));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'On Demand',Vendor_Type__c='Offset', Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = UserInfo.getUserId(), 
                                         Project__c = proj.id,Change_Reason__c = 'Testing before update', Mail_Date__c = system.today(), Mail_Vendor__c = proj.Institution__c, Project_ID__c = '12345',
                                         Production_Manager__c = UserInfo.getUserId(),of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2022', Program__c = prog.Id));
        util.bypassAllTriggers = false;
        
        test.startTest();
        insert jobTickets;
        
        //get job tickets
        jobTickets = [SELECT Id, Project_ID__c, Project_Id_Auto_Number__c, Drop_Type__c FROM Job_Ticket__c Where Id IN: jobTickets Order By Drop_Type__c Desc];
        
        //asserts on JT
        System.assertEquals(jobTickets[0].Project_Id_Auto_Number__c, jobTickets[0].Project_ID__c);
        System.assertEquals('12345', jobTickets[1].Project_ID__c);
        
        //Update Drop Type
        jobTickets[1].Drop_Type__c = 'On Demand';
        Update jobTickets[1];
        
        //get job tickets
        jobTickets = [SELECT Id, Project_ID__c, Project_Id_Auto_Number__c, Drop_Type__c FROM Job_Ticket__c Where Id IN: jobTickets Order By Drop_Type__c Desc];
        
        //asserts on JT
        System.assertEquals(jobTickets[0].Project_Id_Auto_Number__c, jobTickets[0].Project_ID__c);
        System.assertEquals(jobTickets[1].Project_Id_Auto_Number__c, jobTickets[1].Project_ID__c);
        
        test.stopTest();
    }
    
    //Added By Subhash Garhwal - 10/13/2021 -CR-20211012-15513 - test method for ChangeReasonRequiredForLockedRecord() method
    @isTest
    static void testChangeReasonRequiredForLockedRecord()
    {
        // Bypass all triggers
        util.bypassAllTriggers = true;
        
        // get profile Id 
        Id specialistProfileId = [SELECT Id FROM Profile WHERE Name = 'Specialist'].Id;
        
        //Test User Create
        User testUser = new User(Username = Math.random()+'@abc.com', LastName = 'Test User1', FirstName = 'Test1', Email = Math.random()+'@test.com',
                                 Alias = 'Test1', EmailEncodingKey='UTF-8', languagelocalekey = 'en_US', ProfileId = specialistProfileId, 
                                 timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US', EmployeeNumber = '12121212', IsActive = true);
        
        //insert users
        insert testUser;
        
        Project__c proj = [SELECT Id FROM Project__c WHERE Institution__r.r_School_Code__c != null LIMIT 1];
        
        //get job tickets
        List<Job_Ticket__c> jobTickets = [SELECT Id, Status__c, Descriptive_Name__c, School__c, Art_Director__c, Mail_Quantity__c, 
                                          Vendor_Type__c, Mail_Date__c, Project_Manager__c, Production_Manager__c, of_Drops__c, 
                                          of_Letter_Versions__c, Fiscal_Year__c FROM Job_Ticket__c LIMIT 1];
        
        jobTickets[0].Status__c = 'Approved by Partner';
        jobTickets[0].Insertion_Order__c = 'ADM - Letter driver';
        jobTickets[0].Job_Code__c = '123456';
        jobTickets[0].Project__c = proj.Id;
        
        update jobTickets[0]; // update job ticket status to approved by partner to lock the record.
        util.bypassAllTriggers = false;
        
        Test.startTest();
        
        System.runAs(testUser){
            // Use case 1 - If user don't have custom permission and not assigned as project manager on JT record.
            try{
                jobTickets[0].of_Letter_Versions__c = 2; // update any of the field from Unlock_Job_Tickets field set in locked record 
                update jobTickets[0];
                
            }catch(Exception ex){
                //Assert to check actual error message 
                System.assertEquals(true, ex.getMessage().contains('You do not have permission to edit a Locked Record'), ex.getMessage()); 
            }
        }
        
        // update project manager on JT record  
        util.bypassAllTriggers = true;
        jobTickets[0].Project_Manager__c = testUser.Id;
        update jobTickets[0];    
        util.bypassAllTriggers = false;
        
        System.runAs(testUser){
            
            System.assertEquals(testUser.Id, UserInfo.getUserId());
            
            // Use case 2 - If user don't have custom permission and assigned as project manager on JT record. In this user can only be able to update # of drop field but updating multiple fields.
            try{
                jobTickets[0].of_Drops__c = 1;
                jobTickets[0].of_Letter_Versions__c = 3; // update any of the field from Unlock_Job_Tickets field set in locked record 
                update jobTickets[0];
                
            }catch(Exception ex){
                //Assert to check actual error message 
                System.assertEquals(true, ex.getMessage().contains(Label.JT_LockedFieldEditAccessIssueMsg), ex.getMessage()); 
            }
            
            
            Job_Ticket__c jT = [SELECT Id, of_Drops__c FROM Job_Ticket__c WHERE Id = :jobTickets[0].Id];
            
            // Use case 3 - If user don't have custom permission and assigned as project manager on JT record. In this user can only be able to update # of drop field and updating only # of drop field
            try{
                jT.of_Drops__c = 1;
                update jT;
                
            }catch(Exception ex){
                //Assert to check actual error message 
                System.assertEquals(true, ex.getMessage().contains('If editing a Locked Record then you must enter a new Change Reason'), ex.getMessage()); 
            }
        }
        
        Test.stopTest();
    }
    //Modified By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added new method "test_populatePTPrintQuantityContractedOnInventory"
    //Modified By Shalu Sharma - 19/01/2021 - CR-20220105-15694 - Update method "test_populatePTPrintQuantityContractedOnInventory"
    static testMethod void test_populatePTPrintQuantityContractedOnInventory()
    {
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc12', r_CEEB_Code__c='AE');
        insert inst;
        
        //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                   Name = 'Test Account 2', r_School_Code__c='abc11', r_CEEB_Code__c='AB');
        insert inst1;
        
        Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
        insert prog;
        
        List<Membership__c> memberships = new List<Membership__c>();
        memberships.add(new Membership__c(Name = 'Test Membership 1', Account_Name__c = inst.Id,
                                          Program__c = prog.Id, Account_AM__c = UserInfo.getUserId()));
        insert memberships;
		        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        proj.Primary_Paid_Membership__c = memberships[0].Id;
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Name = 'GW-5242-2021-ESNN-2', Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned'
                                         ));
        insert jobTickets;
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        jobTctComponet.Component__c = 'BRE';
        insert jobTctComponet;
        
        Job_Ticket_Component__c jobTctComponetEnv = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        jobTctComponetEnv.Component__c = 'Envelope';
        insert jobTctComponetEnv;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        Job_Ticket_MtM__c jobTickectMTMEnv = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMEnv.Job_Ticket_Component__c = jobTctComponetEnv.Id;
        jobTickectMTMEnv.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMEnv.Component_Code__c = 'AE0013';
        insert jobTickectMTMEnv;
        
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Mail_Shop').getRecordTypeId();

        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art1.zip'));
        insert pTrackings;
        
        List<Inventory__c> inventorys = new List<Inventory__c>();
        inventorys.add(new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                        Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id));
        insert inventorys;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                               Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Status__c = 'Requested', Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998',
                                                               Quantity_Printed__c = 6000));
        insert inventoryTransactions;
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        List<Job_Ticket__c> listOfJobTickets = [SELECT Id, Mail_Quantity__c FROM Job_Ticket__c];
        listOfJobTickets[0].Mail_Quantity__c = 80000;
        update listOfJobTickets; 
        
        Test.stopTest();
    }
}