/*
*    Purpose         :   This trigger is responsible for handling all the pre or post processing for
*                        any dml operation for Competitor_and_Tech_System__c object 
*                
*    Create By       :   Mahendra Swarnkar 
*    
*    Created Date    :   11/24/2021
*    
*    Revision Logs   :   V_1.0 - Created - CR-20211118-15596
*/

trigger Trigger_CompetitorandTechSystem on Competitor_and_Tech_System__c (after insert, after update, after delete) {
    
    //Check if Bypass Logic is true then bypass
    if(Util.areTriggersOnThisObjectBypassed('Competitor_and_Tech_System__c')) return;
    
    //If bypass all triggers is set to true, return without processing
    if (Util.BypassAllTriggers) return;
    
    //trigger is after check.
    if(Trigger.isAfter) {
        
        //check for the insert and update.
        if(trigger.isInsert || trigger.isUpdate || trigger.isDelete) {
            //Calling method.
            CompetitorandTechSystemTriggerHelper.updateProjectFields(trigger.new, trigger.oldMap);
        }
    }
    
}