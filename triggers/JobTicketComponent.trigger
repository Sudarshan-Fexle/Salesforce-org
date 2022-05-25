/**
 *  Purpose         :  This trigger is to control the automation on Job Ticket Component Object object.
 * 
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   10/14/2019
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20191011-13405
 *                     
**/
trigger JobTicketComponent on Job_Ticket_Component__c (after update) {
	
    //return immediately if method returns true	
    if(Util.byPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Job_Ticket_Component__c')) 
        return;
	
    try {
        //Check for the after update condition. 
        if(Trigger.isAfter && Trigger.isUpdate) {
        	
            JobTicketComponentTriggerHelper.updateJobTicketBasedOnJobTicketComponentChange(trigger.new, trigger.oldMap);
        }
        
    }catch(Exception e) {
        
    }
}