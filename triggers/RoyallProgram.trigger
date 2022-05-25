/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Program (Royall) record
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   01/04/2017
 * 
 *  Revision Logs   :   V1.0 - Created - CR-20161128-10501 
 *			V1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        V1.2 - Modified By - Dipesh Gupta - 05/25/2020 - CR-20200522-14088 - Added a new method updateCampaignCodeOnRoyall.
                        V1.3 - Modified By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
                        V1.4 - Modified By - Mahendra Swarnkar - 01/04/2021 - CR-20201204-14725 - Added a new method "populateProgramCostOnMembership"
			V1.5 - Modified By - Colin McGloin - 09/14/2021 - CR-20210824-15375
 * 
 **/
trigger RoyallProgram on Royall_Program__c (After insert, after update, after delete, before Insert, before update ) {


    //This part should be run anytime royall program updates. (Calling it before the BYpass All trigger)
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ) {
        RoyallProgramTriggerHelper.updateCampaignCodeOnRoyall(Trigger.new);
    }
    
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Royall_Program__c')) return;	

    // if a trigger bypass is active, return immediately without processing
    if (Util.BypassAllTriggers)  {
        return;
    }
    
    //Check for the request Type
    if(Trigger.isAfter) {
        
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete ) {
        		
            //Added By - Mahendra - CR-20161128-10501 - 01/04/2017
            //Invoke the Method to populate the Rollupsummary fields on Program package records.
            RoyallProgramTriggerHelper.populateRollUpSummaryFields(Trigger.new, Trigger.oldMap);
            //Added By - Abhinav Sharma - 11/03/2020 - CR-20201026-14638 - Add Cappex fields
            RoyallProgramTriggerHelper.populateFieldOnMembershipPeriod(Trigger.new, Trigger.oldMap);
            
            
            //Added By - Mahendra Swarnkar - 01/04/2021 - CR-20201204-14725 - Update logic behind CX Current Contract Value
            RoyallProgramTriggerHelper.populateProgramCostOnMembership(Trigger.new, Trigger.oldMap);

            //Added by Colin McGloin - 09/14/2021 - CR-20210824-15375
            RoyallProgramTriggerHelper.createCompetitorSelectionRecords(Trigger.new, Trigger.oldMap);
        }
    }
}