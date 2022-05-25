/** 
*  Purpose         :  This trigger is to control the automation on Creative Package object.
* 
*  Created By      :  Neha Sharma
*
*  Created Date    :  05/05/2021
*
*  Revision Logs   :  V_1.0 - Created  - CR-20210323-15016
*		   :  V_1.1 - Modified By Mahendra Swarnkar - CR-20210630-15262                
**/
trigger Trigger_CreativePackage on Creative_Package__c (before insert, before update, after Insert, after update)
{
    //Check for the trigger Bypass. 
	if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Job_Ticket__c'))
    	return;
        
	if(Trigger.isBefore) {
        
        if(Trigger.isInsert || Trigger.isUpdate){
         	
            CreativePackageTriggerhelper.beforeTriggerLogic(trigger.new, trigger.oldMap);
            CreativePackageTriggerhelper.createBoxFolderForCreativePackage(trigger.new, trigger.oldMap);
        }
    } 
    
    if(Trigger.isAfter) {
        
	//Modified by Mahendra Swarnkar - CR-20210630-15262
        if( Trigger.isUpdate && !CreativePackageTriggerhelper.updatePTonArtFileChangeFutureExecution){
            CreativePackageTriggerhelper.updatePTonArtFileChange(trigger.newMap, trigger.oldMap);
        }
    }
    
}