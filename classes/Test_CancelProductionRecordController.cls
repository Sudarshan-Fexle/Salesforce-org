/**
*   Purpose         :   Test class for CancelProductionRecordController
*            
*   Create By       :   Nikita Kumari
* 
*   Created Date    :   09/09/2021
*
*   Revision Log    :   V_1.0 - Created By - Nikita Kumari - 09/07/2021 - CR-20210825-15380
*   
*   Coverage        :   V_1.0 - 
*          
**/
@isTest(seeAllData = false)
private class Test_CancelProductionRecordController 
{
     @testSetup static void testSetupData()
    {
        
        Util.BypassAllTriggers = true;
                
        //get name of one of the vendors specified in Vendor 
        List<Artifact_Transfer_Setting__mdt> ats = [SELECT Id, Mail_Shop_Vendor__c FROM Artifact_Transfer_Setting__mdt
                                                    WHERE Mail_Shop_Vendor__c != null AND Artifact_Type__c = 'Artwork' AND Proof_Generation__c = 'External' ORDER By MasterLabel ASC];
               
        // Create Account with the vendor name from ATS.Mail_Shop_Vendor__c
        Datetime historicalLinkerOverride = Datetime.newInstance(2011, 1, 1);
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', Historical_Linker__c = ats[0].Mail_Shop_Vendor__c, CreatedDate=historicalLinkerOverride,
                                   r_School_Code__c='abc12', r_CEEB_Code__c='abcd');
        insert inst;
        
        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser Test';
        insert user1;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id,Drop_Type__c = 'Pre Planned', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020'));
        
        insert jobTickets;

        // Insert Internal & External production_Tracking__c
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 1));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 2));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, Internal_Data_Drop__c = 3));
        insert pTrackings;
        
        Util.bypassAllTriggers = false;
    }
    
    //V_1.0 - Created By - Nikita Kumari - 09/07/2021 - CR-20210825-15380
    @IsTest static void test_getCancellationReasonPicklistValues() {
        
        //get picklist values
        LightningResponseEntity res = CancelProductionRecordController.getCancellationReasonPicklistValues();
        
        //asserts on result
        system.assertEquals(true, res.Body != null);
        system.assertEquals(true, res.isSuccess);
    }
    
    //V_1.0 - Created By - Nikita Kumari - 09/07/2021 - CR-20210825-15380
    @IsTest static void test_cancelProductionTracking() {
        
        
        List<Production_Tracking__c> pTrackings = [Select Id, Status__c, Cancellation_Reason__c From Production_Tracking__c Order By Status__c Asc];
        
        Test.startTest();
        //cancel specific PT record
        LightningResponseEntity res = CancelProductionRecordController.cancelProductionTracking(pTrackings[0].Id, Label.PT_Status_Cancelled, 'Duplicate');
        
        //asserts on result
        system.assertEquals(true, res.isSuccess);
        
        Production_Tracking__c pTrackingCancelled = [Select Id, Status__c, Cancellation_Reason__c From Production_Tracking__c Where Id =:pTrackings[0].Id Order By Status__c Desc];
        //asserts on result
        system.assertEquals(Label.PT_Status_Cancelled, pTrackingCancelled.Status__c);
        
        //get picklist values
        res = CancelProductionRecordController.cancelProductionTracking(pTrackings[2].Id, Label.PT_Status_Cancelled, 'Duplicate');
        //asserts on result
        system.assertEquals(true, res.message.contains('Only the user who has access to the "Non-Admin PT Records Approvers" permission can mark the PT record as cancelled and can update the cancel reason.'));
        
        Test.stopTest();
    }
}