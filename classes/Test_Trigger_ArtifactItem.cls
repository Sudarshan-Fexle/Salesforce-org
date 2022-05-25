/*
* Purpose          :   Test class for Trigger_ArtifactItem
* 
* CreatedDate      :   03/05/2021
* 
* RevisionLog      :   V_1.0 - Created - Shalu Sharma - PrintMIS: XMPie API Updates release coverage increase
*		       V_1.1 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
* Code Coverage    :   100%
**/
@IsTest
public class Test_Trigger_ArtifactItem {
    
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR,Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234', 
                                   Historical_Linker__c = 'N00141269');
        insert inst;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> escCampaigns = new List<ES_Campaign__c>();
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = user1.id));
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = user1.id));
        insert escCampaigns;
        
        Id programId = TestUtilities.CreateNewProgram(true).Id;
       
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = escCampaigns[0].Id, Project__c = project.Id, Project_ID__c = 'test', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update'));
        insert jobTickets;
        
        //Create Production Trackings
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Drop__c = 1,Art_File_Name__c = 'test',Status__c = 'Planned', Job_Ticket__c = jobTickets[0].Id,Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id));
        insert productionTrackings;
        
        //Creating artifact record
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Type__c = 'Ready To Print',Status__c ='Success',Production_Tracking__c = productionTrackings[0].Id,Job_Ticket__c = jobTickets[0].Id,
                                        Source_Directory_Path_Override__c ='/PrintMIS/<Production_Tracking__r.Job_Ticket__r.Fiscal_Year__c>/<Production_Tracking__r.Job_Ticket__r.Name>/'
                                        ));
        Insert artifactList;
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_AtifactItem()
    {
        Test.startTest();
        
        List<Artifact__c> artifacts = [SELECT Id FROM Artifact__c];
        
        List<Artifact_Item__c> artifactItemList = new List<Artifact_Item__c>();
        artifactItemList.add(new Artifact_Item__c(Name = 'Test ArtifactItem', Artifact__c = artifacts[0].Id, Item_Type__c = 'Ready to Print PDF',
                                                 Database_Count__c = 16000, XMPie_Count__c = 16000, Banner_Sheet_Count__c = 16, File_Name__c = 'Test.pdf'));
        Insert artifactItemList;
        
        Test.stopTest();
    }
}