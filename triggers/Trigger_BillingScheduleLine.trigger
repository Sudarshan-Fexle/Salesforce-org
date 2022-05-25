/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Billing schedule line record
 * 
 *  Created By      :   Mahendra Swarnkar
 * 
 *  Created Date    :   01/09/2020
 * 
 *  Revision Logs   :   V1.0 - Created
 * 		    :   V1.1 - 04/23/2020 - CR-20200423-13977 - Victor Hanson - Added updatePeriodType method
 *		    :   V1.2 - 04/09/2021 - CR-20210408-15069 - Commented by Mahendra Swarnkar  
 * 
 **/
trigger Trigger_BillingScheduleLine on Billing_Schedule_Line__c (after insert, after update, before insert,before update,before delete) {
    
	//return immediately if method returns true  
	if(Util.areTriggersOnThisObjectBypassed('Billing_Schedule_Line__c')) return;
  
	//if a trigger bypass is active, return immediately without processing
	if (Util.BypassAllTriggers)  return;
	
	//Check for the request Type
    if(Trigger.IsAfter) {
        
        if (Trigger.isInsert) {
            //04/23/2020 - CR-20200423-13977 - Victor Hanson
            BillingScheduleLineTriggerHelper.updatePeriodType(Trigger.new);
            
        }
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            BillingScheduleLineTriggerHelper.populateFieldsOnBillingSchedulePeriod(Trigger.new, Trigger.OldMap);
            
            //04/24/2020 - CR-20200423-13977 - Mahendra Swarnkar
            //BillingScheduleLineTriggerHelper.updatBillingSchedulePeriodStartAndEndDate(Trigger.new, Trigger.OldMap);
            
            //Commented by Mahendra Swarnkar - CR-20210408-15069 - 04/09/2021
            //Added By - Mahendra Swarnkar - CR-20200715-14321 - 09/07/2020 
            //BillingScheduleLineTriggerHelper.populateTypeOnBSP(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.IsBefore) {
        
        if (Trigger.isInsert) {
            //04/23/2020 - CR-20200422-13970 - Mahendra Swarnkar
            BillingScheduleLineTriggerHelper.updatePOField(Trigger.new);
        }
        
        //06/15/2020 - CR-20200605-14143 - Mahendra Swarnkar
        if(Trigger.isDelete){
            BillingScheduleLineTriggerHelper.validateBSLs(trigger.new, trigger.oldMap);
        }
    }
    

}