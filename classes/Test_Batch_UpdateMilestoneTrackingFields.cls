/**
 * Purpose          :   Test class for Batch_UpdateMilestoneTrackingFields
 * 
 * CreatedDate      :   7/31/2020
 * 
 * RevisionLog      :   V_1.0 - Created - Abhinav Sharma - CR-20200717-14331 - 07/31/2020
 * 
 * Code Coverage    :   
 *
**/
@IsTest(seeAllData=false)
public class Test_Batch_UpdateMilestoneTrackingFields {
    
     static testMethod void test_OnTrackMilestoneTracking()
    {
        Util.BypassAllTriggers = true;
        
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Vendor_Type__c = 'Offset';
        insert jobTicket;
        
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), status__c = 'Approved by Partner', Job_Ticket__c = jobTicket.Id);
        
        insert prodTracking;
        
        prodTracking.status__c = 'Proof';
        prodTracking.Status_Detail__c = 'Submitted';
        prodTracking.Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL;
        update prodTracking;

        prodTracking.Status_Detail__c = 'Approved';
        update prodTracking;
        
        Production_Tracking__History ptHistory = new Production_Tracking__History();
        ptHistory.ParentId = prodTracking.Id;
        ptHistory.Field = 'status__c';
        insert ptHistory;
        
        Production_Tracking__History ptHistory1 = new Production_Tracking__History();
        ptHistory1.ParentId = prodTracking.Id;
        ptHistory1.Field = 'Status_Detail__c';
        insert ptHistory1;
        
        List<Production_Tracking__History> ptrackingHistory = [SELECT Parent.Id, Parent.Recordtype.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name From Production_Tracking__History where (Field = 'status__c'or Field ='status_detail__c') ORDER BY CreatedDate ASC ];
                        
        Test.startTest();
        Batch_UpdateMilestoneTrackingFields batch = new Batch_UpdateMilestoneTrackingFields();
        database.batchablecontext bd ;
        batch.start(bd);
        batch.execute(bd, ptrackingHistory);
        batch.finish(bd);

        Test.stopTest();
    }
}