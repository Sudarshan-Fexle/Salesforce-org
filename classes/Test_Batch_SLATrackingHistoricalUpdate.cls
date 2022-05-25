/**
 * Purpose          :   Test class for Batch_SLATrackingHistoricalDataUpdate 
 * 
 * CreatedDate      :   7/31/2020
 * 
 * RevisionLog      :   V_1.0 - Created - Abhinav Sharma - CR-20200717-14438 - 07/31/2020
                    :   V_1.1 Modify By - Abhinav Sharma - CR-20201002-14573 - 10/2/2020
 * 
 * Code Coverage    :   
 *
**/
@IsTest(seeAllData=false)
public class Test_Batch_SLATrackingHistoricalUpdate {
    
     static testMethod void test_OnTrackMilestoneTracking()
    {
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Vendor_Type__c = 'Offset';
        insert jobTicket;
        
        List<Production_Tracking__c> prodTrackingList = new List<Production_Tracking__c>();
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), status__c = 'Approved by Partner', Job_Ticket__c = jobTicket.Id);
        prodTrackingList.add(prodTracking);
        insert prodTrackingList;
        
        prodTrackingList[0].status__c = 'Proof';
        prodTrackingList[0].Status_Detail__c = 'Submitted';
        // Modified By - Rajeev Jain - CR-20201012-14597 - 03/05/2021
        prodTrackingList[0].Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL;
        update prodTrackingList[0];
        
        prodTrackingList[0].status__c = 'Proof';
        prodTrackingList[0].Status_Detail__c = 'File Received';
        update prodTrackingList[0];

        Production_Tracking__History ptHistory = new Production_Tracking__History();
        ptHistory.ParentId = prodTrackingList[0].Id;
        ptHistory.Field = 'status__c';
        insert ptHistory;
        
        Production_Tracking__History ptHistory1 = new Production_Tracking__History();
        ptHistory1.ParentId = prodTrackingList[0].Id;
        ptHistory1.Field = 'Status_Detail__c';
        insert ptHistory1;
        
        List<Production_Tracking__History> ptrackingHistory = [SELECT Parent.Id, Parent.Recordtype.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name 
                                                               From Production_Tracking__History 
                                                               where (Field = 'status__c'or Field ='status_detail__c') and Parent.Id =: prodTrackingList[0].Id
                                                               ORDER BY CreatedDate ASC ];
                        
        system.assertEquals(2,ptrackingHistory.size());
        Test.startTest();
	//V_1.1 Modify By - Abhinav Sharma - CR-20201002-14573 - 10/2/2020
        Set<Id> setofIds = new Set<Id>();
        setofIds.add(prodTrackingList[0].Id);
        String query = 'SELECT Parent.Id, Parent.Recordtype.Name, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name From Production_Tracking__History where Parent.Recordtype.developerName = \''+ 'Mail_Shop' +'\'and (Field =\''+ 'status__c' +'\' or Field =\''+ 'status_detail__c' +'\')';
        Batch_SLATrackingHistoricalDataUpdate batch = new Batch_SLATrackingHistoricalDataUpdate(query,setofIds);
        database.batchablecontext bd ;
        batch.start(bd);
        batch.execute(bd, ptrackingHistory);
        batch.finish(bd);
        
        List<Production_Tracking__c> productionTrackings = [Select Id,Proof_File_Received_DateTime__c From Production_Tracking__c];
         
        system.assertEquals( true,productionTrackings[0].Proof_File_Received_DateTime__c != null);
        
        Test.stopTest();
    }
}