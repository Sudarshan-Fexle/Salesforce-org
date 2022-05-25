/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for BillingScheduleHeader object
 *
 *  Create By       :   Neha Sharma
 *
 *  Created Date    :   07/12/2021
 *
 *  Revision Logs   :   V_1.0 - Created

 **/
trigger Trigger_BillingScheduleHeader on Billing_Schedule_Header__c(before insert, before update, after insert, after update) {
    
    //return immediately if method returns true 
    if(Util.BypassAllTriggers || Util.areTriggersOnThisObjectBypassed('Billing_Schedule_Header__c')) return;    

    try {
        //Check for the request Type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isUpdate) {
                
                //Added By - Neha Sharma - 07/08/2021 - CR-20210209-14889 - Update Invoice Bundle field on all associated BSL's 
                BillingScheduleHeaderHelper.updateInvoiceBundleOnBSL(Trigger.New, Trigger.oldMap);
                            
            }
        }       
        
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}