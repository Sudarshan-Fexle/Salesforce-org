/**
 * Desription      :   	Trigger for the IS System App object
 * 
 * Revision Logs   :   	v1.0 - Victor Hanson - 11/05/2015 - Created
 *			v1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 **/
trigger ISSystemApp on IS_System__c (before insert, before update) {
    
   //return immediately if method returns true	
   if(Util.areTriggersOnThisObjectBypassed('IS_System__c')) return;

    //bypass triggers if necessary
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        if (trigger.isUpdate) {
            
            //
            ISSystemAppHelper.inactiveCheck(trigger.newMap, trigger.oldMap);
        }
    }
	
}