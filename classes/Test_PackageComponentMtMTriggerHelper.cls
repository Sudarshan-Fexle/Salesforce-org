@IsTest(seeAllData=false)
public class Test_PackageComponentMtMTriggerHelper {

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
        
        //Insert Project record
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Project_ID__c = 'test2', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test2', Art_Director__c = user1.Id, Mail_Quantity__c = 101, Change_Reason__c = 'Testing before update2'));
        insert jobTickets;
        
        List<Job_Ticket_Component__c> jtComponents = new List<Job_Ticket_Component__c>();
        jtComponents.add(new Job_Ticket_Component__c(Component__c = 'Folder'));
        jtComponents.add(new Job_Ticket_Component__c(Component__c = 'Envelope'));
        insert jtComponents;
        
        Job_Ticket_MtM__c jobTktMTM = new Job_Ticket_MtM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jtComponents[0].Id, Laser__c = 'Simplex',
                                                            Component_Type__c = 'Folder', Paper_Typex__c = 'Lynx Opaque Smooth Text', Paper_Weightx__c = '70#',
                                                            Component_Code__c = 'testCode', Front_Colors_PMS__c = '2', Apply_Fugitive_Glue_to_Seal_Flap__c = false);
        insert jobTktMTM;
        
        Job_Ticket_MtM__c jobTktMTM1 = new Job_Ticket_MtM__c();
        jobTktMTM1.Job_Ticket__c = jobTickets[0].Id;
        jobTktMTM1.Component_Type__c = '';
        jobTktMTM1.Paper_Typex__c = '';
        jobTktMTM1.Paper_Weightx__c= '';
        jobTktMTM1.Component_Code__c='';
        //jobTktMTM1.Front_of_Colors__c='';
        jobTktMTM1.Front_Colors_PMS__c='';
        jobTktMTM1.Job_Ticket_Component__c = jtComponents[1].Id;
        //insert jobTktMTM1;
        
        //Insert the Creative Package records
        List<Creative_Package__c> creativePackages = new List<Creative_Package__c>();
        creativePackages.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id, Box_Folder_Link__c  = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8', Box_Folder_Id__c = 'testId2', Art_File_Name__c = 'ABC.zip'));
		insert creativePackages;
        
        Util.BypassAllTriggers = false;
        
    }
    
    //test the getJobTicket method
    static testMethod void testPopulateJobTicket() {
        
        //Get data
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c Where Drop_Type__c =: System.Label.DROP_TYPE_ON_DEMAND];
        system.assertEquals((jobTickets.size()) , 1);
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id FROM Job_Ticket_MtM__c ];
        system.assertEquals((jobTicketMtMs.size()) , 1);
        
        List<Creative_Package__c> creativePackages = [SELECT Id FROM Creative_Package__c];
        system.assertEquals((creativePackages.size()) , 1);
        
        Util.BypassAllTriggers = true;
        Mail_Copy__c mailCopy = new Mail_Copy__c(Creative_Package__c = creativePackages[0].Id );
        insert mailCopy;
        
        Mail_Package__c mailPackage = new Mail_Package__c(Creative_Package__c = creativePackages[0].Id, Mail_Copy__c = mailCopy.Id);
        insert mailPackage;
        
        //Test start here
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        
        Package_Component_MtM__c packageComponentMtM = new Package_Component_MtM__c(Mail_Package__c = mailPackage.Id, Job_Ticket_MtM__c = jobTicketMtMs[0].Id);
        insert packageComponentMtM;
        
        List<Package_Component_MtM__c> listPackageComponentMtM = [Select Id, Job_Ticket__c from Package_Component_MtM__c];
        
        system.assertEquals((listPackageComponentMtM.size()), 1);
        system.assertEquals(listPackageComponentMtM[0].Job_Ticket__c, jobTickets[0].Id);
        
        Test.stopTest();
    }
}