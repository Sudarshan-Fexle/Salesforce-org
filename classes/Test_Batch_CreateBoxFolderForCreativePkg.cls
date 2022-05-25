/**
* Purpose          :   Test class for Batch_CreateBoxFolderForCreativePackage.
* 
* RevisionLog      :   V_1.0 - Created - 
**/
@IsTest(seeAllData=false)
public class Test_Batch_CreateBoxFolderForCreativePkg {
    
    //setup the test data
    @testSetup static void testSetupData() {
        
        Util.BypassAllTriggers = true;
       
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234');
        insert inst;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        //Create User
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
        //String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('SSC').getRecordTypeId();
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        Util.BypassAllTriggers = true;
        insert project;
        
        Util.BypassAllTriggers = false;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = escCampaigns[0].Id, Project__c = project.Id, Box_Folder_Id__c = 'testId',
                                         Project_ID__c = 'test',Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', 
                                         Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update'));
        insert jobTickets;
        
        Util.BypassAllTriggers = false;        
        
        //Get the Creative Package record 
        List<Creative_Package__c> listCreativePackage = new List<Creative_Package__c>();
        listCreativePackage.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id));
        
        Util.BypassAllTriggers = true;
        insert listCreativePackage;
        Util.BypassAllTriggers = false;
    }
    
    //test the Batch_CreateBoxFolderForCreativePackage batch
    @isTest
    static  void testBatch_CreateBoxFolderForCreativePackage() {
        
        //Get Job Ticket data
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
                
        //Set to hold Job Ticket ids
        Set<Id> setOfJTIds = new Set<Id>();
        
        //Loop over Job Tickets
        for(Job_Ticket__c jT: jobTickets)
            setOfJTIds.add(jT.Id);

        //Test Start here
        Test.startTest();
        
        //Execute batch
        Batch_CreateBoxFolderForCreativePackage createBoxFolderBatch = new Batch_CreateBoxFolderForCreativePackage(setOfJTIds);
       	Id createBoxFolderBatchId = Database.executeBatch(createBoxFolderBatch, 200);
        
        //Test stop here
        Test.stopTest();
    }
}