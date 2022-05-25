/** 
*  Purpose         :  This trigger is to control the automation on Inventory Transaction object.
* 
*  Created By      :   Victor Hanson
*
*  Created Date    :   04/22/2021
*
*  Revision Logs   :   V_1.0 - Created  - CR-20210420-15089
*		   :   V_1.1 - Modified By Abhinav Sharma - 05/12/2021 - CR-20210310-14983 - Added bypass trigger logic and try/catch block	
*		   :   V_1.2 - Modified By Abhinav Sharma - 06/17/2021 - CR-20210525-15180 - Add new "populateLocationOnInventory" method calling 
*		   :   V_1.3 - Modified By Shalu Sharma - 10/20/2021 - CR-20210924-15459 - Add new "checkAddNewInventoryRequest" method calling
**/
trigger Trigger_InventoryTransaction on Inventory_Transaction__c (before insert, after insert, after update, after delete) 
{
    //Added By Shalu Sharma - 10/29/2021 - CR-20210924-15459 - Added new method "rollupAvailableAmountOnInventory" calling
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
    {
        InventoryTransactionTriggerHelper.rollupAvailableAmountOnInventory(Trigger.new, Trigger.oldMap);
    }
    
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Inventory_Transaction__c'))
        return;
    
    try 
    {
        if (Trigger.isAfter) 
        {
            if(Trigger.isInsert)
            { 
                //Modified By Subhash Garhwal - 10/20/2021 - CR-20210924-15459 - Add new "checkAddNewInventoryRequest" method calling
                InventoryTransactionTriggerHelper.checkAddNewInventoryRequest(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isInsert || Trigger.isUpdate) {
                InventoryTransactionTriggerHelper.checkInventoryTransferRequest(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
            {
                InventoryTransactionTriggerHelper.populateLocationOnInventory(Trigger.new, Trigger.oldMap);
            }
        }
    } 
    catch(Exception e)
    {
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}