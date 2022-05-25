/**
 * Purpose          :   Test class for MileStoneTrackingController
 * 
 * CreatedDate      :   7/31/2020
 * 
 * RevisionLog      :   V_1.0 - Created - Abhinav Sharma - CR-20200717-14331 - 07/31/2020
 * 
 * Code Coverage    :   
 *
**/
@IsTest(seeAllData=false)
private class Test_MilestoneTrackingController {
 
    //setup the test data
    @testSetup static void testSetupData() {
        
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
    	
        Job_Ticket__c jobTicketVendorTypeOffset = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicketVendorTypeOffset.Vendor_Type__c = 'Offset';
        insert jobTicketVendorTypeOffset;
        
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), status__c = 'Proof',
                                                                         Status_Detail__c = 'Submitted', Job_Ticket__c = jobTicketVendorTypeOffset.Id,
                                                                         Art_Due_to_Vendor_Date__c = system.today());
        insert prodTracking;

        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Active_Production_Tracking__c = prodTracking.Id;
        insert jobTicket;
        
    }
    
     static testMethod void test_OnTrackMilestoneTracking()
    {
        List<Job_Ticket__c> jobtickets = [SELECT Id,
                                          Active_Production_Tracking__r.Status_Detail__c,
                                          Active_Production_Tracking__r.status__c,
                                          Active_Production_Tracking__r.Planned_Mail_Date__c,
                                          Active_Production_Tracking__r.Art_Due_to_Vendor_Date__c,
                                          Active_Production_Tracking__r.Live_Proof_Approval_Due_Date__c,
                                          Active_Production_Tracking__r.Data_Due_to_Vendor_Date__c,
                                          Active_Production_Tracking__r.Proof_Approval_Date__c,
                                          Active_Production_Tracking__c
                                          FROM job_Ticket__c WHERE
                                          Active_Production_Tracking__c != null
                                          AND Active_Production_Tracking__r.Planned_Mail_Date__c != null
                                          AND Vendor_Type__c != 'Offset'];
        
        Test.startTest();
        MilestoneTrackingController.fetchproductionTrackingInfo(jobtickets[0].Id);
        system.assertEquals(jobtickets[0].Active_Production_Tracking__r.Art_Due_to_Vendor_Date__c,system.today());

        Test.stopTest();
    }
    
        //Created by - Abhinav Sharma - 10/12/2020 - CR-20200915-14512 - Added for skip the "Art/Proof approval" status on milestone tracking
    static testMethod void test_MilestoneTrackingForLiveProof()
    {
        //get the job ticket
        List<Job_Ticket__c> jobtickets = [SELECT Id,
                                          Active_Production_Tracking__c,
                                          Active_Production_Tracking__r.Status_Detail__c,
                                          Active_Production_Tracking__r.status__c,
                                          Active_Production_Tracking__r.Planned_Mail_Date__c,
                                          Active_Production_Tracking__r.Art_Due_to_Vendor_Date__c,
                                          Active_Production_Tracking__r.Live_Proof_Approval_Due_Date__c,
                                          Active_Production_Tracking__r.Data_Due_to_Vendor_Date__c,
                                          Active_Production_Tracking__r.Proof_Approval_Date__c,
                                          Active_Production_Tracking__r.New_Art__c,
                                          Active_Production_Tracking__r.Previous_Production_Tracking__c,
                                          Active_Production_Tracking__r.Previous_Production_Tracking__r.Mail_Shop_Vendor__c,
                                          Active_Production_Tracking__r.Mail_Shop_Vendor__c
                                          FROM job_Ticket__c WHERE
                                          Active_Production_Tracking__c != null
                                          AND Active_Production_Tracking__r.Planned_Mail_Date__c != null
                                          AND Vendor_Type__c != 'Offset'];
        
        Production_Tracking__c prodTracking = [Select Id, Mail_Shop_Vendor__c From Production_Tracking__c limit 1];
        
        //insert a new Production Tracking under the same Job Ticket record 
        Production_Tracking__c prodTracking1 = new Production_Tracking__c(Previous_Production_Tracking__c = prodTracking.Id, Mail_Shop_Vendor__c = prodTracking.Mail_Shop_Vendor__c,
                                                                          Job_Ticket__c = jobtickets[0].Id,
                                                                          Planned_Mail_Date__c = system.today().addDays(6), Live_Proof_Approval_Due_Date__c = System.today(), 
                                                                          New_Art__c = false, Art_File_Name__c = 'Test.zip', Internal_Data_Drop__c = 1);
        
        Insert prodTracking1;
        
        //Updated the Active Production Tracking on Job Ticket
        jobtickets[0].Active_Production_Tracking__c = prodTracking1.Id;
        Update jobtickets[0];
        
        Test.startTest();
        
        List<MilestoneTrackingController.MilestoneWithStatusWrapper> milestoneWithStatusWrapper = MilestoneTrackingController.fetchproductionTrackingInfo(jobtickets[0].Id);
        //Check status is on track
        system.assertEquals(Label.Milestone_Tracking_Status_On_Track, milestoneWithStatusWrapper[0].status);
        
        prodTracking1.Planned_Mail_Date__c = system.today().addDays(-10);
        prodTracking1.Live_Proof_Approval_Due_Date__c = null;
        Update prodTracking1;
        
        List<MilestoneTrackingController.MilestoneWithStatusWrapper> milestoneWithStatusWrapper1 = MilestoneTrackingController.fetchproductionTrackingInfo(jobtickets[0].Id);
        //Check status is on track
        system.assertEquals(Label.Milestone_Tracking_Status_At_Risk, milestoneWithStatusWrapper1[0].status);

        Test.stopTest();
    }
}