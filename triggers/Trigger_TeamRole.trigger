/**
 *  Purpose         :   This trigger is to handle all teh pre and post processing operation
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/31/2015
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified - Subhash Garhwal - 07/02/2015 - CR-20150618-9014 - New methods added - validateDelete, updateStaffAssignment
 *			V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.3 - Modified By - Saurabh Kumar - 09/22/2020 - CR-20200819-14449 - Added syncRelatedStaffAssignmentEABEventFields method.
 *
 **/ 
trigger Trigger_TeamRole on Team_Role__c (before insert, before update, before delete, after update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Team_Role__c')) return;

    try {
        
        //Check for the request type 
        if(Trigger.isBefore) {
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                TeamRoleTriggerHelper.validateTeamRoles(Trigger.New);
            }
            
            //Check for event type
            if(Trigger.isDelete) {
                
                //Added By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014
                //Call helper class method
                //This method is to check if Assignment Role (Staff Role) is used on any Staff Assignment than don't allow user to delete it.
                TeamRoleTriggerHelper.validateDelete(Trigger.old);
            }
        }
        
        //Check for trigger request type
        if(Trigger.isAfter) {
            
            //Check for event type
            if(Trigger.isUpdate) {
                
                //Added By - Subhash Garhwal - 07/02/2015 - CR-20150618-9014
                //Call helper class method
                //This method is used to rename all the the related Staff Assignments
                TeamRoleTriggerHelper.updateStaffAssignment(Trigger.new, Trigger.oldMap);
                
                //Added by - Saurabh Kumar - 09/22/2020 - CR-20200819-14449
                TeamRoleTriggerHelper.syncRelatedStaffAssignmentEABEventFields(Trigger.new, Trigger.oldMap);
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