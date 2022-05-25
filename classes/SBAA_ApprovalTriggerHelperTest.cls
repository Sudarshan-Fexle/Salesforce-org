/*	Description		:	Test class for SBAA_ApprovalTriggerHelper
*
*	Revision Log	:	V1.1 - Created By - Victor Hanson - 08/07/2017 - Issue--CR10808--QA--00004965
*/
@isTest
private class SBAA_ApprovalTriggerHelperTest {
	
    /**
     * 
     * @description		: 	Verify the Pending Approver field is updated based on any open approvals on the related proposal
     * 
     **/
    static testMethod void testPendingApproverField() {
        
        //get 2 active users to use as the approvers
        list<User> users = [SELECT Id, Name, Profile.Name FROM User WHERE IsActive=true AND Profile.Name LIKE '%Administrator%' LIMIT 2];
        
        //create opportunity
        Util.BypassAllTriggers = true;
        Opportunity o = TestUtilities.CreateNewOpportunity(true);
        Util.BypassAllTriggers = false;
        
        //create a proposal
        SBQQ__Quote__c proposal = TestUtilities.createNewSbqqQuote(false);
        proposal.SBQQ__Opportunity2__c = o.Id;
        
        Util.BypassAllTriggers = true;
        insert proposal;
        Util.BypassAllTriggers = false;
        
        //create approvers
        sbaa__Approver__c approver1 = new sbaa__Approver__c(Name='Approver1', sbaa__User__c=users[0].Id);
        sbaa__Approver__c approver2 = new sbaa__Approver__c(Name='Approver2', sbaa__User__c=users[1].Id);
        
        //list to hold the approvers
        list<sbaa__Approver__c> approvers = new list<sbaa__Approver__c>();
        approvers.add(approver1);
        approvers.add(approver2);
        insert approvers;
        
        //create Approvals
        sbaa__Approval__c a1 = new sbaa__Approval__c(sbaa__Status__c='Requested',sbaa__ApprovalStep__c=1,sbaa__RecordField__c='Quote__c',sbaa__Approver__c=approvers[0].Id, Quote__c=proposal.Id);
        sbaa__Approval__c a2 = new sbaa__Approval__c(sbaa__Status__c='Requested',sbaa__ApprovalStep__c=1,sbaa__RecordField__c='Quote__c',sbaa__Approver__c=approvers[1].Id, Quote__c=proposal.Id);
        
        //add approvals to list
        list<sbaa__Approval__c> approvals = new list<sbaa__Approval__c>();
        approvals.add(a1);
        approvals.add(a2);
        insert approvals;
        
        a1.sbaa__Status__c = 'Approved';
        update a1;
        
        //get the approvals
        a1 = [SELECT Id, Pending_Approver__c FROM sbaa__Approval__c WHERE Id = :a1.Id];
        a2 = [SELECT Id, sbaa__Approver__r.Name FROM sbaa__Approval__c WHERE Id = :a2.Id];
        
        //verify that the pending approver name is populated on the approved record's "Pending Approver" field, because it is used in the email alert sent to the user that requested approval
        system.assertEquals(a2.sbaa__Approver__r.Name, a1.Pending_Approver__c);
        
        //approve the second record
        a2.sbaa__Status__c = 'Approved';
        update a2;
        
        //get the approval
        a2 = [SELECT Id, Pending_Approver__c FROM sbaa__Approval__c WHERE Id = :a2.Id];
        
        //verify that the pending approver name is null, because no additional appovals are pending
        system.assertEquals(null, a2.Pending_Approver__c);
    }
}