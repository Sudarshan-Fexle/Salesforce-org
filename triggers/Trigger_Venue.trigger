/**
 *	Purpose			:	This trigger is to handle all the pre and post processing operation for Venue trigger
 *
 *	Created By		:	Bhavi Sharma
 *
 *	Created Date	:	02/14/2015
 *
 *	Revision Logs	:	V_1.0 - Created
 *				V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *
 **/ 
trigger Trigger_Venue on Venue__c (before insert, before update, after insert , after update, after delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Venue__c')) return;

    try {
        
        //Check if trigger is enabled
        if(!VenueTriggerHelper.EXECUTE_VENUE_TRIGGER)
            return;
        
        //Chekc for the request type
        if(Trigger.isBefore) {
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method to check the Unique primary flag
                VenueTriggerHelper.validatePrimaryVenue(Trigger.New);
            }
        } 
        else If(Trigger.isAfter) {
            
                //Check for the Event Type
                if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                    
                    //Call helper class method to Populate the staff rate on Team member
                    VenueTriggerHelper.updateStaffRateOnTeamMembers(Trigger.New, Trigger.oldMap);
                }
        	}        
	} catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}