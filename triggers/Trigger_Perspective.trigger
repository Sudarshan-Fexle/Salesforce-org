/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Perspective
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014
 *                      V_1.1 - Added - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - incentiveChangeLog method added.
 *                      V_1.2 - Modified - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Commented out the incentiveChangeLog
 *			V_1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *
 **/
trigger Trigger_Perspective on Perspective__c (before delete, before insert,before update,after update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Perspective__c')) return;	

    try {
         
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to check Perspective name. The Name value must be unique across all Perspective
                PerspectiveTriggerHelper.validatePerspective(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw error.
                PerspectiveTriggerHelper.validateBeforeDelete(Trigger.old);
            }
        }
        //V_1.2 - Modified - Rajeev Jain - 04/19/2016 - CR-20151120-9402 -
        //Check for trigger
        /*if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Code Added - Subhash Garhwal - 08/04/2015 - CR-20150729-9114 - incentiveChangeLog method called.
                //Call helper class method 
                //This method is to incentiveChangeLog 
                PerspectiveTriggerHelper.incentiveChangeLog(Trigger.new, Trigger.oldMap);
            }
        }*/
        //V_1.2 - Modified - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - upto here
    
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