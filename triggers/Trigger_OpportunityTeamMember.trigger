/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for OpportunityTeamMember object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   11/8/2017
 *
 *  Revision Logs   :   V_1.0 - Created
 **/
trigger Trigger_OpportunityTeamMember on OpportunityTeamMember (before insert) {

    try {
    
        //Bypass All Triggers
        if (Util.BypassAllTriggers) return;

        //Check for request type
        if(Trigger.isBefore) {
    
            //Check for event type
            if(Trigger.isInsert) {
        
                //Call helper method
                OpportunityTeamMeamberTriggerHelper.preventNewOpportunityTeamMember(Trigger.new);
            }
        }
    }
    catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isInsert)
            Trigger.New[0].addError(e.getMessage());
        else
            Trigger.Old[0].addError(e.getMessage());
    }
}