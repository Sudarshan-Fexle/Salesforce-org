/**
 * Purpose          :   Test class for Batch_UpdateMilestoneTrackingStatusOnPT
 * 
 * CreatedDate      :   7/31/2020
 * 
 * RevisionLog      :   V_1.0 - Created - Abhinav Sharma - CR-20200717-14331 - 07/31/2020
 * 
 * Code Coverage    :   
 *
**/
@IsTest(seeAllData=false)
private class Test_Batch_UpdateMilestoneTrackingStatus {
 
    //setup the test data
    @testSetup static void testSetupData() {
        Util.BypassAllTriggers = true;
        
        Job_Ticket__c jobTicketVendorTypeOffset = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicketVendorTypeOffset.Vendor_Type__c = 'Offset';
        insert jobTicketVendorTypeOffset;
        
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), status__c = 'Proof',
                                              Status_Detail__c = 'Submitted', Job_Ticket__c = jobTicketVendorTypeOffset.Id);
        insert prodTracking;
        
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
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
        Batch_UpdateMilestoneTrackingStatusOnPT batch = new Batch_UpdateMilestoneTrackingStatusOnPT();
        database.executeBatch(batch);

        Test.stopTest();
    }
}