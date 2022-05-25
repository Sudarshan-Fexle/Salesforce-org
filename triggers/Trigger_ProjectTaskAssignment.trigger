/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for ProjectTaskAssignment (pse__Project_Task_Assignment__c) record
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   11/04/2020
 * 
 *  Revision Logs   :   V1.0 - Created - CR-20201020-14618
 * 
 **/
trigger Trigger_ProjectTaskAssignment on pse__Project_Task_Assignment__c (after insert, after update ) {
	
    //return immediately if method returns true  
	if(Util.areTriggersOnThisObjectBypassed('pse__Project_Task_Assignment__c')) return;
  
	//if a trigger bypass is active, return immediately without processing
	if (Util.BypassAllTriggers)  return;
    
    if(Trigger.IsAfter) {
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            //Added by - Mahendra Swarnkar - 11/04/2020 - CR-20201020-14618
            ProjectTaskAssignmentTriggerHelper.createAssignmentForResourceProject(Trigger.new, Trigger.oldMap);
        }
    }
    
}