/**
 *  Purpose	    :	This trigger is responsible for handling all the pre or post 
 *                      processing for any dml operation for Mailroom Inventory object
 *
 *  Create By	    :	Subhash Garhwal
 *
 *  Created Date    :	07/15/2021
 * 
 *  Revision Log    :	v1.0 - Created - CR-20210722-15306
 * 
 **/
trigger Trigger_MailroomInventory on Mailroom_Inventory__c(after update, before insert, before update) {

    // if bypass all triggers is set to true, return without processing
    if (Util.BypassAllTriggers || Util.areTriggersOnThisObjectBypassed('Mailroom_Inventory__c')) 
        return;

    try 
    {
        //Check for the request Type
        if(Trigger.isBefore)
        {
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate)
            {
            	MailroomInventoryTriggerHelper.populateOperatorFieldOnMailroomInventory(Trigger.New, Trigger.oldMap); 
            }
        }
        
        //Check for the request Type
        if(Trigger.isAfter) { 

            //Check for the event type
            if(Trigger.isUpdate) 
            {
                //Call helper class method to check when Mailroom Inventory status is changed
                MailroomInventoryTriggerHelper.sendNotificationToEmployee(Trigger.New, Trigger.oldMap);
            }
        }
    } 
    //Catching DML Exceptions
    catch(DMLException e) {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } 
    catch(Exception e) {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}