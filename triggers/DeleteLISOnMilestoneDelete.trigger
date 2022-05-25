/*
  Purpose:
        When a billing milestone is deleted, this trigger deletes the Line Item Schedule that is associated
        with the billing milestone, unless the Line Item Schedulel is invoiced, in which case it throws an error.
        
  Initiative: IconATG FinancialForce PSA Implementation 
  Author:     William Rich
  Company:    IconATG
  Contact:    william.rich@iconatg.com
  Created:    8/15/2015
	      V.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/

trigger DeleteLISOnMilestoneDelete on pse__Milestone__c (before delete) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('pse__Milestone__c')) return;	

    Map<Id, Id> milestonesByLineItemSchedules = new Map<Id, Id>();
    for (pse__Milestone__c milestone : Trigger.old) {
        if (milestone.Line_Item_Schedule__c != null) {
            milestonesByLineItemSchedules.put(milestone.Line_Item_Schedule__c, milestone.Id);
        }
    }

    if (!milestonesByLineItemSchedules.isEmpty()) {
        List<Line_Item_Schedule__c> lises = [
            select
                Id,
                Invoiced__c,
                Bypass_Delete_Validation__c
            from Line_Item_Schedule__c
            where Id in :milestonesByLineItemSchedules.keySet()
        ];

        List<Line_Item_Schedule__c> toBeDeleted = new List<Line_Item_Schedule__c>();
        for (Line_Item_Schedule__c lis : lises) {
            if (lis.Invoiced__c) {
                String msg = 'The Line Item Schedule associated with this milestone has been invoiced. It cannot be deleted.';
                Trigger.oldMap.get(milestonesByLineItemSchedules.get(lis.Id)).addError(msg);
            }
            else {
                lis.Bypass_Delete_Validation__c = true;
                toBeDeleted.add(lis);
            }
        }

        if (!toBeDeleted.isEmpty()) { 
            update toBeDeleted;
            delete toBeDeleted;
        }
    }
}