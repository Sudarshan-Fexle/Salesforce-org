/** 
    *  Purpose         :  This trigger is to handle all the pre and post processing operations for Recipient_Batch__c object
    * 
    *  Created By      :  Shalu Sharma
    *
    *  Created Date    :  09/16/2021
    *
    *  Revision Logs   :  V_1.0 - Created - CR-20210824-15374
    *
    **/
trigger RecipientBatch_Trigger on Recipient_Batch__c(before insert, before update,after insert, after update)
{
    //return immediately if method returns true
    if(Util.areTriggersOnThisObjectBypassed('Recipient_Batch__c')) return;
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate ) {
                RecipientBatchTriggerHelper.sendEmailForRecipientBatchReceived(trigger.new, trigger.oldMap);
            }
        }
        
        //Catching DML Exception
    } catch(DMLException e) {
        //Commented  -  not using Delete event 
        /*
        //Add Error Message on Page
        if(Trigger.isDelete)
        Trigger.Old[0].addError(e.getDmlMessage(0));
        else
        Trigger.New[0].addError(e.getDmlMessage(0));
        */
        //Catching all Exceptions
    } 
}