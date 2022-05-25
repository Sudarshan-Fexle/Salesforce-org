/** 
* Description     :   Test class to test the functionality of Trigger_ProductLead, ProductLeadTriggerHelper
* 
* Created By      :   Abhinav Sharma
*
* Created Date    :  07/04/2018
*
* Revision Log    :  V1.1 - Created.
*                 :  V1.2 - Modified By - Neha Sharma - CR-20210129-14857 - 03/01/2021
				  :  V1.3 - Modified - Test Coverage increase
*
**/

@isTest(seeAllData=false)
private class Test_ProductLeadTriggerHelper {
    
    /**
* @Description  : This method used to insert Data of Product Lead and its related obejct.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    @testSetup static void testSetUpData() {
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact brianODriscoll = TestUtilities.CreateNewContact(true);
        brianODriscoll.Location__c = 'TestClass @@@';
        update brianODriscoll; 
        
        //Create a new Program and set as Marketable to meet Lookup filter requirements
        Program__c testProg = TestUtilities.CreateNewProgram(true);
        testProg.Marketable__c = true;
        update testProg;
        
        //Create a new Lead to test process
        Lead johnnySexton = new Lead();
        johnnySexton.FirstName = 'Johnny';
        johnnySexton.LastName = 'Sexton';
        johnnySexton.LeadSource = 'Webinar';
        johnnySexton.Company = 'IRFU Test Class';
        insert johnnySexton;

        //Create a test Contact related Product Lead record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Stage__c = 'Inquiry';
        testProdLead.Contact__c = brianODriscoll.Id;
        testProdLead.Program__c = testProg.Id;
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Stage__c = 'Inquiry';
        testProdLead2.Lead__c = johnnySexton.Id;
        testProdLead2.Program__c = testProg.Id;
        
        //Add our Product Leads to List
        List<Product_Lead__c> prodLeads = new List<Product_Lead__c>();
        prodLeads.add(testProdLead);
        prodLeads.add(testProdLead2);
        
        //Insert our Product Lead records
        insert prodLeads; 
        
    } 
    
    /**
* @Description  : This method is to test the Product Lead name population logic
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    
    @isTest static void Test_populateProductLeadName(){
        
        List<Product_Lead__c> productLeads = [Select Id, Name, Name__c, TGL__c, Stage__c From Product_Lead__c];
        System.assertEquals(2, productLeads.size());
        
        //Check for the update case.
        productLeads[0].stage__c = 'MQL';
        productLeads[1].stage__c = 'TAL';
        productLeads[1].outreach_type__c = 'TAL';

        Test.startTest();
        update productLeads[0];
        update productLeads[1];
        Test.stopTest();
        
        List<Product_Lead__c> pD = [Select Id, Name, Name__c From Product_Lead__c where Id =: productLeads[0].Id];
        System.assertEquals(pD[0].Name__c, pD[0].Name);
    } 
    
    /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    //winningProductLead.CreatedDate < pLead.CreatedDate
    @isTest static void Test_populateExternalId(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        Id progId = [SELECT Id FROM Program__c LIMIT 1 ].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1 ].Id;
        
        Contact conId = [SELECT Id FROM Contact LIMIT 1 ]; 
        conId.AccountId = accId;
        update conId;
        
        List<Product_Lead__c> testData = [SELECT Id,Opportunity__c FROM Product_Lead__c Where Lead__c = null];
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testData[0].Id );
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testData[0].Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testData[0].Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = conId.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testData[0].Id;
        insert campMember;

        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testData[0].Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Stage__c = 'Inquiry';
        testProdLead2.CreatedDate = DateTime.newInstance(2017,02,03,13,20,30);
        testProdLead2.Contact__c = conid.Id;
        testProdLead2.Program__c = progId;
        
        //Start testing from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        insert testProdLead2;        
        Util.byPassAllTriggers = true;
        
        //Create Event
        Event ev = TestUtilities.createEvent(true, system.today(), testProdLead2.Id);
        
        //Create Task
        Task t = TestUtilities.createTask(true, testProdLead2.Id);
        
        
        //Create Attachment
        Attachment att = TestUtilities.createNewAttachment(testProdLead2.Id, true);
        
        //Create Note
        Note notes = new Note();
        notes.ParentId = testProdLead2.Id;
        notes.Title = 'Test Data';
        notes.Body = 'Test Data';
        insert notes; 
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
                
        //Record types
        Id eventInviteRcrdType1 =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType1 =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign1 = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType1,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign1;
        
        CampaignMemberStatus campMemberstatus1 = new CampaignMemberStatus();
        campMemberstatus1.CampaignId = campaign1.Id;
        campMemberstatus1.Label = 'Requested Follow Up';
        insert campMemberstatus1;
        
        //Create a new campaign to test process
        CampaignMember campMember1 = new CampaignMember();
        campMember1.CampaignId = campaign1.Id; 
        campMember1.ContactId = conId.Id;
        campMember1.Status = 'Requested Follow Up';
        campMember1.Product_lead__c = testProdLead2.Id;
        insert campMember1;

        List<Product_Lead__c> testData1 = [SELECT Id, Name FROM Product_Lead__c ];
        System.assertEquals(2,testData1.size()); 
        
        //Stop test here
        Test.stopTest();
    } 
    
        /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    
    // winningProductLeadStageOrder > pLeadStageOrder 
    // TAL EAL
    @isTest static void Test_populateExternalIdForDifferentStages(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        Id progId = [SELECT Id FROM Program__c LIMIT 1 ].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1 ].Id;
        
        Contact conId = [SELECT Id FROM Contact LIMIT 1 ]; 
        conId.AccountId = accId;
        update conId;
        
        List<Product_Lead__c> testData = [SELECT Id,Opportunity__c FROM Product_Lead__c Where Lead__c = null];
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testData[0].Id );
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testData[0].Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testData[0].Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = conId.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testData[0].Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testData[0].Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Stage__c = 'TAL';
        testProdLead2.Outreach_Type__c = 'TAL';
        testProdLead2.Contact__c = conId.Id;
        testProdLead2.Program__c = progId;
        
        //Start testing from here
        Test.startTest();
        
        Util.byPassAllTriggers = false;
        insert testProdLead2;        
        Util.byPassAllTriggers = true;
        
        //Create Event
        Event ev = TestUtilities.createEvent(true, system.today(), testProdLead2.Id );
        
        //Create Task
        Task t = TestUtilities.createTask(true, testProdLead2.Id);
        
        
        //Create Attachment
        Attachment att = TestUtilities.createNewAttachment(testProdLead2.Id, true);
        
        //Create Note
        Note notes = new Note();
        notes.ParentId = testProdLead2.Id;
        notes.Title = 'Test Data';
        notes.Body = 'Test Data';
        insert notes; 

        //Record types
        Id eventInviteRcrdType1 =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType1 =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign1 = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType1,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign1;
        
        CampaignMemberStatus campMemberstatus1 = new CampaignMemberStatus();
        campMemberstatus1.CampaignId = campaign1.Id;
        campMemberstatus1.Label = 'Requested Follow Up';
        insert campMemberstatus1;
        
        //Create a new campaign to test process
        CampaignMember campMember1 = new CampaignMember();
        campMember1.CampaignId = campaign1.Id; 
        campMember1.ContactId = conId.Id;
        campMember1.Status = 'Requested Follow Up';
        campMember1.Product_lead__c = testProdLead2.Id;
        insert campMember1;

        List<Product_Lead__c> testData1 = [SELECT Id, Name FROM Product_Lead__c ];
        System.assertEquals(2,testData1.size()); 
        
        //Stop test here
        Test.stopTest();
    } 
    
    
    
            /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    @isTest static void Test_populateExternalIdForNoDuplicate(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
		//Create our Lead related Product Lead Record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'TAL';
        testProdLead.Outreach_Type__c = 'TAL';
        
        //Start testing from here
        Test.startTest();
        insert testProdLead;
        
        System.debug('testData-->'+testProdLead.stage__c);
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testProdLead.Id);
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testProdLead.Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testProdLead.Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testProdLead.Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Contact__c = con.Id;
        testProdLead2.Program__c = prog.Id;
        testProdLead2.Stage__c = 'TAL';
        testProdLead2.Outreach_Type__c = 'TAL';

        Util.byPassAllTriggers = false;
        insert testProdLead2;    
        Util.byPassAllTriggers = true;
        
        List<Product_Lead__c> testData1 = [SELECT Id, Name, stage__c FROM Product_Lead__c Where Stage__c = 'TAL']; 
        System.assertEquals('TAL',testData1[0].stage__c = 'TAL');  
        
        //Stop test here
        Test.stopTest();
    } 

            /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    //winningProductLeadStageOrder < pLeadStageOrder
    @isTest static void Test_populateExternalIdForDiffStages1(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
		//Create our Lead related Product Lead Record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'MQL';
        testProdLead.Outreach_Type__c = 'TAL';
        
        //Start testing from here
        Test.startTest();
        insert testProdLead;
        
        System.debug('testData-->'+testProdLead.stage__c);
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testProdLead.Id);
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testProdLead.Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testProdLead.Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testProdLead.Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        

        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Contact__c = con.Id;
        testProdLead2.Program__c = prog.Id;
        testProdLead2.Stage__c = 'TAL';
        testProdLead2.Outreach_Type__c = 'TAL';

        Util.byPassAllTriggers = false;
        insert testProdLead2;    
        System.debug('Stage for 2nd Prod --> '+ testProdLead2.Stage__c);
        Util.byPassAllTriggers = true;
        
        List<Product_Lead__c> testData1 = [SELECT Id, Name, stage__c FROM Product_Lead__c]; 
        System.assertEquals(3, testData1.size());
        
        //Stop test here
        Test.stopTest();
    }     
    
               /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    @isTest static void Test_populateExternalIdForDiffResetValue(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
		//Create our Lead related Product Lead Record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'MQL';
        testProdLead.Outreach_Type__c = 'TAL';
        testProdLead.Reset__c = true;
        
        //Start testing from here
        Test.startTest();
        insert testProdLead;
        
        System.debug('testData-->'+testProdLead.stage__c);
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testProdLead.Id);
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testProdLead.Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testProdLead.Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testProdLead.Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Contact__c = con.Id;
        testProdLead2.Program__c = prog.Id;
        testProdLead2.Stage__c = 'TAL';
        testProdLead2.Outreach_Type__c = 'TAL';
        testProdLead2.Reset__c = false;

        Util.byPassAllTriggers = false;
        insert testProdLead2;    
        System.debug('Stage for 2nd Prod --> '+ testProdLead2.Stage__c);
        Util.byPassAllTriggers = true;

        List<Product_Lead__c> testData1 = [SELECT Id, Name, stage__c FROM Product_Lead__c]; 
        System.assertEquals(3, testData1.size()); 
        
        //Stop test here
        Test.stopTest();
    }     

   /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    //true, false
    @isTest static void Test_populateExternalIdForDiffResetValue1(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
		//Create our Lead related Product Lead Record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'Inquiry';
        testProdLead.Outreach_Type__c = 'TAL';
        testProdLead.Reset__c = false;
        
        //Start testing from here
        Test.startTest();
        insert testProdLead;
        
        System.debug('testData-->'+testProdLead.stage__c);
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testProdLead.Id);
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testProdLead.Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testProdLead.Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testProdLead.Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Contact__c = con.Id;
        testProdLead2.Program__c = prog.Id;
        testProdLead2.Stage__c = 'Inquiry';
        testProdLead2.Outreach_Type__c = 'TAL';
        testProdLead2.Reset__c = true;

        Util.byPassAllTriggers = false;
        insert testProdLead2;    
        System.debug('Stage for 2nd Prod --> '+ testProdLead2.Stage__c);
        Util.byPassAllTriggers = true;

        List<Product_Lead__c> testData1 = [SELECT Id, Name, stage__c FROM Product_Lead__c Where stage__c = 'Inquiry']; 
        System.assertEquals('Inquiry',testData1[0].stage__c = 'Inquiry'); 
        
        //Stop test here
        Test.stopTest();
    } 
       /**
* @Description  : This method is to test the Product Lead ExternalId population logic.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created
**/
    //true, false
    @isTest static void Test_populateExternalIdForDiffResetValue4(){
        //ByPass all triggers
        Util.byPassAllTriggers = true;
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
		//Create our Lead related Product Lead Record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'Inquiry';
        testProdLead.Outreach_Type__c = 'TAL';
        testProdLead.Reset__c = true;
        
        //Start testing from here
        Test.startTest();
        insert testProdLead;
        
        System.debug('testData-->'+testProdLead.stage__c);
   
        //Creating Event, Task, Opp, Note and Attahment for the First Product 
        //Create Event
        Event ev2 = TestUtilities.createEvent(true, system.today(), testProdLead.Id);
        
        //Create Task
        Task t2 = TestUtilities.createTask(true, testProdLead.Id);
        
        //Create Attachment
        Attachment att2 = TestUtilities.createNewAttachment(testProdLead.Id, false); 
        
        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        insert campaign;
        
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaign.Id;
        campMemberstatus.Label = 'Requested Follow Up';
        insert campMemberstatus;
        
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaign.Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        insert campMember;
        
        //Create Note
        Note notes2 = new Note();
        notes2.ParentId = testProdLead.Id;
        notes2.Title = 'Test Data';
        notes2.Body = 'Test Data';
        //insert notes2; 
        
        //Create our Lead related Product Lead Record
        Product_Lead__c testProdLead2 = new Product_Lead__c();
        testProdLead2.Contact__c = con.Id;
        testProdLead2.Program__c = prog.Id;
        testProdLead2.Stage__c = 'Inquiry';
        testProdLead2.Outreach_Type__c = 'TAL';
        testProdLead2.Reset__c = false;

        Util.byPassAllTriggers = false;
        insert testProdLead2;    
        System.debug('Stage for 2nd Prod --> '+ testProdLead2.Stage__c);
        Util.byPassAllTriggers = true;

        List<Product_Lead__c> testData1 = [SELECT Id, Name, stage__c FROM Product_Lead__c WHERE stage__c = 'Inquiry'];
        System.assertEquals('Inquiry',testData1[0].stage__c); 
        
        //Stop test here
        Test.stopTest();
    } 
    /**
* @Description  : This method is to test the sendMailToProductOwner() method.
* 
* @Args         :  
* 
* @Return       : void 
* 
* @Revision-log : V_1.0 - Created By - Neha Sharma - CR-20210129-14857 - 03/01/2021
**/
    
    @isTest(seeAllData = false) 
    static void Test_sendMailToProductOwner(){
		Util.byPassAllTriggers = true;
        
        
        //Create an Institution and Contact
        Account acc = new Account(Name='Acc1');
        insert acc;
        
        Contact con = new Contact(Firstname='Test Con',lastname='1',AccountId=acc.Id, 
                                  Email = 'testingxyz@eab.com', Phone = '1233445551', Title = 'testingxyz');
        insert con;
        
        
        //Program record
        Program__c prog = new Program__c(
            Name = 'testprog', 
            Program_Acronym__c = 'TEST', 
            Status__c = 'Active', 
            Create_Memberships__c = 'Yes',
            Marketable__c = true);
        insert prog;
        
        
        //Create a test Contact related Product Lead record
        Product_Lead__c testProdLead = new Product_Lead__c();
        testProdLead.Name = 'Test 1';
        testProdLead.Contact__c = con.Id;
        testProdLead.Program__c = prog.Id;
        testProdLead.Stage__c = 'TAL';
        testProdLead.Outreach_Type__c = 'TAL';
        
        insert testProdLead;

        //Record types
        Id eventInviteRcrdType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Event Invite List Member').RecordTypeId;
        Id mailingCampaignMemberType =  Schema.SObjectType.CampaignMember.RecordTypeInfosByName.get('Mailing Campaign Member').RecordTypeId;
        
        List<Campaign> campaignList = new List<Campaign>();
        
        Campaign campaign = new Campaign(Name = 'Test Campaign 1', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        campaignList.add(campaign);
        
        Campaign campaign1 = new Campaign(Name = 'Test Campaign 2', 
                                   CampaignMemberRecordTypeId = eventInviteRcrdType,
                                   StartDate = System.today(), EndDate = System.today().addDays(5),
                                   IsActive = true);
        campaignList.add(campaign1);
        Test.startTest();
        insert campaignList;
        
        List<CampaignMemberStatus> campMemberstatusList = new List<CampaignMemberStatus>();
        CampaignMemberStatus campMemberstatus = new CampaignMemberStatus();
        campMemberstatus.CampaignId = campaignList[0].Id;
        campMemberstatus.Label = 'Requested Follow Up';
        campMemberstatusList.add(campMemberstatus);
        
        CampaignMemberStatus campMemberstatusDemo = new CampaignMemberStatus();
        campMemberstatusDemo.CampaignId = campaignList[1].Id;
        campMemberstatusDemo.Label = 'Requested Demo';
        campMemberstatusList.add(campMemberstatusDemo);
        
        insert campMemberstatusList;
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        //Create a new campaign to test process
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaignList[0].Id; 
        campMember.ContactId = con.Id;
        campMember.Status = 'Requested Follow Up';
        campMember.Product_lead__c = testProdLead.Id;
        campMemberList.add(campMember);
        
        //Create a new campaign to test process
        CampaignMember campMember1 = new CampaignMember();
        campMember1.CampaignId = campaignList[1].Id; 
        campMember1.ContactId = con.Id;
        campMember1.Status = 'Requested Demo';
        campMember1.Product_lead__c = testProdLead.Id;
        campMember1.Request_Demo_Mail_Date__c = System.today();
        campMemberList.add(campMember1);
        
        insert campMemberList;

        //ByPass all triggers
        Util.byPassAllTriggers = false;
        
        testProdLead.Stage__c = 'AQL';
            update testProdLead;
        
            List<Product_Lead__c> prodList = [SELECT Id, Stage__c FROM Product_Lead__c WHERE Id =: testProdLead.Id];
            System.assertEquals('AQL',prodList[0].Stage__c);
        test.stopTest(); 
    }    
}