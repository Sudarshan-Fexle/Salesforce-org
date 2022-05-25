/**
* Purpose          :   Test class for CreativePackageTriggerhelper
* 
* RevisionLog      :   V_1.0 - Created - 
**/
@IsTest
public class Test_CreativePackageTriggerhelper {
    
    //setup the test data
    @testSetup static void testSetupData() {
        
        Util.BypassAllTriggers = true;
        
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234');
        insert inst;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        Util.BypassAllTriggers = true;
        insert user1;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> escCampaigns = new List<ES_Campaign__c>();
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = user1.id));
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = user1.id));
        insert escCampaigns;
        
        Util.BypassAllTriggers = true;
        //Insert Project record
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id, Fiscal_Year__c = String.valueOf(System.today().Year()));
        Util.BypassAllTriggers = true;
        insert project;
        
        Util.BypassAllTriggers = false;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        
        //Formula fields are :- School__c
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,ES_Campaign__c = escCampaigns[0].Id, Project__c = project.Id, Project_ID__c = 'test', Status__c = 'Draft', Production_Manager__c = user1.Id, Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update', Vendor_Type__c = 'Digital', Mail_Date__c = System.today().addDays(5), of_Drops__c = 1, of_Letter_Versions__c = 1, Fiscal_Year__c = String.valueOf(System.today().Year()), Insertion_Order__c = 'ADM - Letter driver', Job_Code__c = 'ABC'));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Project_ID__c = 'test2', Status__c = 'Draft', Production_Manager__c = user1.Id, Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test2', Art_Director__c = user1.Id, Mail_Quantity__c = 101, Change_Reason__c = 'Testing before update2', Vendor_Type__c = 'Digital', Mail_Date__c = System.today().addDays(5), of_Drops__c = 1, of_Letter_Versions__c = 1, Fiscal_Year__c = String.valueOf(System.today().Year()), Insertion_Order__c = 'ADM - Letter driver', Job_Code__c = 'ABC'));
        insert jobTickets;
        
        Util.BypassAllTriggers = false;        
    }
    
    //test the getJobTicket method
    @isTest
    static void testCreateBoxFolderForCreativePackage() {
                
        //Get data
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c Where Drop_Type__c =: System.Label.DROP_TYPE_ON_DEMAND];
        jobTickets[0].Creative_Package_Box_Folder_Id__c = '12343';
        jobTickets[0].Creative_Package_BOX_Folder_Link__c = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8';
        Util.ByPassAllTriggers = true;
        update jobTickets;
        
        //Insert the Creative Package records
        List<Creative_Package__c> listCreativePackage = new List<Creative_Package__c>();
        listCreativePackage.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id));
        listCreativePackage.add(new Creative_Package__c(Job_Ticket__c = jobTickets[1].Id));

        //Test start here
        Test.startTest();
        
        Util.ByPassAllTriggers = false; 
        insert listCreativePackage;
        
        listCreativePackage = [Select ID, Box_Folder_Link__c, Box_Folder_Id__c  from Creative_Package__c where Job_Ticket__c =: jobTickets[0].Id ];
        system.assertEquals(listCreativePackage[0].Box_Folder_Id__c, jobTickets[0].Creative_Package_Box_Folder_Id__c);
        system.assertEquals(listCreativePackage[0].Box_Folder_Link__c, jobTickets[0].Creative_Package_BOX_Folder_Link__c);
        
        //Update Creative Package record
        listCreativePackage = [Select ID, Job_Ticket__c, Box_Folder_Link__c, Box_Folder_Id__c  from Creative_Package__c where Job_Ticket__c =: jobTickets[1].Id ];
        listCreativePackage[0].Job_Ticket__c = jobTickets[0].Id;
        update listCreativePackage;
        
        List<Creative_Package__c> listCreativePackage1 = [Select ID, Box_Folder_Link__c, Box_Folder_Id__c  from Creative_Package__c where Id =: listCreativePackage[0].Id ]; 
        system.assertEquals(listCreativePackage1[0].Box_Folder_Id__c, jobTickets[0].Creative_Package_Box_Folder_Id__c);
        system.assertEquals(listCreativePackage1[0].Box_Folder_Link__c, jobTickets[0].Creative_Package_BOX_Folder_Link__c);
        
        //Test Stop here
        Test.stopTest();
    }
    
    //Added by Mahendra Swarnkar - CR-20210630-15262  
	//test the getJobTicket method
    @isTest
    static void testupdatePTonArtFileChange_InsertNewPT() {
        
        //Get data
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c Where Drop_Type__c =: System.Label.DROP_TYPE_ON_DEMAND];
        system.assertEquals((jobTickets.size()) , 2);
        Test.setCreatedDate(jobTickets[0].Id, DateTime.newInstance(2021, 05, 20));
        jobTickets[0].Creative_Package_Box_Folder_Id__c = '12343';
        jobTickets[0].Creative_Package_BOX_Folder_Link__c = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8';
        jobTickets[0].Status__c = 'Approved by Partner';
        Util.ByPassAllTriggers = true;
        update jobTickets;
        
        List<Account> accounts = [SELECT Id FROM Account];
        system.assertEquals((accounts.size()) , 1);
        
        //Insert the Creative Package records
        Creative_Package__c creativePackage = new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id, Box_Folder_Link__c  = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8', Box_Folder_Id__c = '12343', Art_File_Name__c = 'ABC.zip');
		insert creativePackage;
        
        //Test start here
        Test.startTest();
        
        Util.ByPassAllTriggers = false;
        
        creativePackage.Art_File_Name__c = 'ABC1.zip';
        Update creativePackage;
        
        Test.stopTest();
        
        List<Production_Tracking__c> pTrackings = [Select ID, Art_File_Name__c,Status__c, Status_Detail__c from Production_Tracking__c];
        
        system.assertEquals((pTrackings.size()), 1);
        system.assertEquals(pTrackings[0].Art_File_Name__c, 'ABC1.zip');
        system.assertEquals(pTrackings[0].Status__c, Constants.PRODUCTION_TRACKING_STATUS_PROOF);
        system.assertEquals(pTrackings[0].Status_Detail__c, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED);
    }
    
    //Added by Mahendra Swarnkar - CR-20210630-15262 - 
    @isTest
    static void testupdatePTonArtFileChange_UpdateExistingPTs() {
        
        //Get data
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c Where Drop_Type__c =: System.Label.DROP_TYPE_ON_DEMAND];
        system.assertEquals((jobTickets.size()) , 2);
        
        Test.setCreatedDate(jobTickets[0].Id, DateTime.newInstance(2021, 05, 20));
        jobTickets[0].Creative_Package_Box_Folder_Id__c = '12343';
        jobTickets[0].Creative_Package_BOX_Folder_Link__c = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8';
        jobTickets[0].Status__c = 'Approved by Partner';
        Util.ByPassAllTriggers = true;
        update jobTickets;
        
        List<Account> accounts = [SELECT Id FROM Account];
        system.assertEquals((accounts.size()) , 1);
        
        //Insert the Creative Package records
        Creative_Package__c creativePackage = new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id, Box_Folder_Link__c  = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8', Box_Folder_Id__c = '12343', Art_File_Name__c = 'ABC.zip');
		insert creativePackage;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Creative_Package__c = creativePackage.ID, Drop__c = 1, Mail_Shop_Vendor__c =  accounts[0].Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 1, Art_File_Name__c = 'artFile1.zip'));
        pTrackings.add(new Production_Tracking__c(Creative_Package__c = creativePackage.ID, Drop__c = 2, Mail_Shop_Vendor__c =  accounts[0].Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 2, Art_File_Name__c = 'artFile2.zip'));
        pTrackings.add(new Production_Tracking__c(Creative_Package__c = creativePackage.ID, Drop__c = 3, Mail_Shop_Vendor__c =  accounts[0].Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 3, Art_File_Name__c = 'artFile3.zip'));
       
        Util.ByPassAllTriggers = true;
        insert pTrackings;
        
        pTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT;
        
        pTrackings[1].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        pTrackings[1].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        
        pTrackings[2].Proof_Approval_Status__c = 'Approved';
        pTrackings[2].Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        pTrackings[2].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL;
        
        Util.ByPassAllTriggers = true;
        update pTrackings;
        
        //Test start here
        Test.startTest();
        
        Util.ByPassAllTriggers = false;
        
        creativePackage.Art_File_Name__c = 'ABC1.zip';
        Update creativePackage;
        
        Test.stopTest();
        
        List<Production_Tracking__c> pTrackingsAsserts = [Select ID, Art_File_Name__c,Status__c, Status_Detail__c from Production_Tracking__c Where ID IN : pTrackings ORDER BY Drop__c ASC];
        
        system.assertEquals((pTrackingsAsserts.size()), 3);
        system.assertEquals(pTrackingsAsserts[0].Art_File_Name__c, 'ABC1.zip');
        system.assertEquals(pTrackingsAsserts[0].Status__c, Constants.PRODUCTION_TRACKING_STATUS_PROOF);
        system.assertEquals(pTrackingsAsserts[0].Status_Detail__c, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED);
        
        system.assertEquals(pTrackingsAsserts[1].Art_File_Name__c, 'ABC1.zip');
        system.assertEquals(pTrackingsAsserts[1].Status__c, Constants.PRODUCTION_TRACKING_STATUS_PROOF);
        system.assertEquals(pTrackingsAsserts[1].Status_Detail__c, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED);
        
        system.assertEquals(pTrackingsAsserts[2].Art_File_Name__c, 'ABC1.zip');
        system.assertEquals(pTrackingsAsserts[2].Status__c, Constants.PRODUCTION_TRACKING_STATUS_PROOF);
        system.assertEquals(pTrackingsAsserts[2].Status_Detail__c, Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED);
    }
}