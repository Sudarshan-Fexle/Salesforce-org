/**
 *  Description     :   This trigger to handle all the pre and post processing operation for Program Perspective
 *
 *  Created By      :   Subhash Garhwal
 *
 *  Created Date    :   06/25/2015
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20150618-9014
 *                  :   V_1.0 - Added - Padmesh Soni - CR-20150729-9114 - 08/04/2015 - New Method Addded IncentiveChangeLogs
 *                  :   V_1.1 - Code Added - Padmesh Soni - CR-20150729-9114 - 08/12/2015 - New renameCP method added
 *                  :   V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016 - Removed the usage of IncentiveChangeLogs method
 *			V_1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *
 **/
trigger Trigger_ProgramPerspective on Program_Perspective__c (before delete, before insert, before update, after update, after delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Program_Perspective__c')) return;

    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                //This method is used to check Perspective name. The Name value must be unique across all Perspective
                ProgramPerspectiveTriggerHelper.validateProgramPerspective(Trigger.new, Trigger.oldMap);
    
                //Code Added - Padmesh Soni - 08/12/2015 - CR-20150729-9114 - New method renameCP called .
                //Call helper class method
                //This method is to rename Collection Perspective
                ProgramPerspectiveTriggerHelper.renameCP(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //Method to check related Program Perspective's In Use values on record delation, If "In Use" values > 0, then throw error.
                ProgramPerspectiveTriggerHelper.validateBeforeDelete(Trigger.old);
                
                //Call helper class method
                ProgramPerspectiveTriggerHelper.SummarizeRPPs(Trigger.old);
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Call helper class method
                ProgramPerspectiveTriggerHelper.updateRPPs(Trigger.new, Trigger.oldMap);
                
                //Added by - Padmesh Soni - 08/04/2015 - CR-20150729-9114
                //V_1.2 - Modified - Rajeev Jain - CR-20151120-9402 - 04/19/2016
                //Call the helper class method
                //This method is used to create IncentiveChangeLogs record when collection perspective key field changes
                //ProgramPerspectiveTriggerHelper.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                ProgramPerspectiveTriggerHelper.SummarizeRPPs();
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