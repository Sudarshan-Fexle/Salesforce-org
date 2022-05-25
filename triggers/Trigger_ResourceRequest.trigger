/** 
*  Purpose         :  This trigger is to control the automation on Resource Request object.
* 
*  Created By      :   Neha Sharma
*
*  Created Date    :   09/11/2021
*
*  Revision Logs   :   V_1.0 - Created - CR-20211103-15563
*/
trigger Trigger_ResourceRequest on pse__Resource_Request__c (before delete)
{
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('pse__Resource_Request__c'))
        return;
         
    if (Trigger.isBefore && Trigger.isdelete) 
    {  
        
        ResourceRequestTriggerHelper.validateResourceRequestStatus(trigger.oldMap);
        
    }
    
}