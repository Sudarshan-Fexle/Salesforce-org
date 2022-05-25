/** 
    *  Purpose         :  Helper class for Batch_CatalystRecipientBatchReceived
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    *
    *  Code Coverage   :  100%
    **/
@isTest(seeAllData = false)
public class TestBatch_CatalystRecipientBatchReceived 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        
        // Create Account
        Account acct = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Name = 'Test1', Account_Formal_Name__c = 'Sepire', r_School_Code__c = '1234');
        insert acct;
        
        //Create Program
        Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
        insert prog;
        
        //Insert Project record
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = acct.Id, Fiscal_Year__c = '2022');
        insert project;
        
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE, Vendor_Type__c = 'Digital', Mail_Quantity__c = 500, 
                                         Status__c = 'Draft', Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, 
                                         Project_Manager__c = UserInfo.getUserId(), Project__c = project.id,Change_Reason__c = 'Testing before update', 
                                         Mail_Date__c = system.today(), Mail_Vendor__c = acct.Id, Production_Manager__c = UserInfo.getUserId(),
                                         of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2020', Program__c = Prog.Id));
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE, Vendor_Type__c='Digital', Mail_Quantity__c = 500, Status__c = 'Draft', 
                                         Art_Director__c = UserInfo.getUserId(), Descriptive_Name__c = '### Test Record ###', Locked__c = true, 
                                         Project_Manager__c = UserInfo.getUserId(), Project__c = project.id,Change_Reason__c = 'Testing before update',
                                         Mail_Date__c = system.today(), Mail_Vendor__c = acct.Id, Production_Manager__c = UserInfo.getUserId(),
                                         of_Drops__c =2,of_Letter_Versions__c = 1,Fiscal_Year__c = '2020', Program__c = Prog.Id));
        insert jobTickets;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE, Drop__c = 1, Mail_Shop_Vendor__c =  acct.Id, 
                                                  Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, 
                                                  RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Internal_Data_Drop__c = 2, Art_File_Name__c = 'artFile1.zip'));
        pTrackings.add(new Production_Tracking__c(Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE, Drop__c = 2, Mail_Shop_Vendor__c =  acct.Id, 
                                                  Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, 
                                                  RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL,
                                                  Internal_Data_Drop__c = 3, Art_File_Name__c = 'artFile2.zip'));
        insert pTrackings;
        
        List<Recipient_Batch__c> recipientBatches = new List<Recipient_Batch__c>();
        recipientBatches.add(new Recipient_Batch__c(Production_Tracking__c = pTrackings[0].Id, Type__c = 'ArtProof',
                                                    Data_Posted_Quantity__c = 199, Data_Posted_Date_Time__c = System.now().addHours(-3)- 1));
        
        insert recipientBatches;
        
        Util.BypassAllTriggers = false;
    }
    
    @IsTest static void test_Batch_CatalystRecipientBatchReceived()
    {
        Test.startTest();
        Batch_CatalystRecipientBatchReceived batch = new Batch_CatalystRecipientBatchReceived(); 
        Database.executeBatch(batch,25);
        Test.stopTest();
    } 
}