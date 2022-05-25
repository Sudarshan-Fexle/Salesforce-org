/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operation on Role Program Perspective
 * 
 *  Created By      :   Subhash Garhwal
 * 
 *  Created Date    :   06/30/2015
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20150618-9014
 *                      V_1.1 - Modified - Subhash Garhwal - CR-20150618-9014 - Add new call preventDuplicates
 *			V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *
 **/ 
trigger Trigger_RoleProgramPerspective on Role_Program_Perspective__c (after insert, after update, after delete, before insert, before update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Role_Program_Perspective__c')) return;

    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This metthod is used to prevent the duplicate RPPs on Staff Assignment.
                RoleProgramPerspectiveTriggerHelper.preventDuplicates(Trigger.new, Trigger.oldMap);
            }
        }
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Call helper class method
                //This method is used to populate Program Perspective fields value with all related Role Program Perspectives
                //Short Name field, if Role Program Perspectives Effective End date >= today and record is created or updated or deleted
                RoleProgramPerspectiveTriggerHelper.validateUpdate(Trigger.new, Trigger.oldMap);
            }
        }
        
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}