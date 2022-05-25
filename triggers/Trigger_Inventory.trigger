/** 
*  Purpose         :  	This trigger is to control the automation on Inventory object.
* 
*  Created By      :   	Abhinav Sharma
*
*  Created Date    :   	10/20/2021
*
*  Revision Logs   :   	V_1.0 - Created  - CR-20210924-15459 - 10/20/2021
*		   :    V_1.1 - Modified By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added calling of new method "sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
**/
trigger Trigger_Inventory on Inventory__c (after update, after insert, before update, before insert) 
{
    //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added calling of new method "sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
    if(JobTicketTriggerHelper.sendEmailOnMailQuantityChange && (Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Inventory__c')))
    {
        if(Trigger.isAfter && Trigger.isUpdate) 
        {
            InventoryTriggerHelper.sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted(trigger.new, trigger.oldMap); 
        }
    }
    
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Inventory__c'))
        return;
    
    if(Trigger.isAfter) 
    {
        if(Trigger.isUpdate) 
        {
            InventoryTriggerHelper.updateInsufficientInventoryOnRelatedMailShopPTs(trigger.new, trigger.oldMap);
        }
        
        //Added By - Shalu Sharma - 22/12/2021 - CR-20211213-15624 - Added calling of new method "sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted"
        if(Trigger.isUpdate || Trigger.isInsert) 
        {
            InventoryTriggerHelper.sendEmailWhenQtyInInventoryIsLessThanPrintQtyContracted(trigger.new, trigger.oldMap); 
        }
    }
}