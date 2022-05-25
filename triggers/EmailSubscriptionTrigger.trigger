/*
*    Purpose:    This trigger is responsible for handling all the pre or post processing for
*                any dml operation for Email Subscription object
*    Created By   :  Dipesh Gupta
*
*    Created Date:   09/09/2019
*
*    Current Version:    v1.0
*
*    Revision Log:       v1.0 - Created - Dipesh Gupta - CR-20190107-12810
*/
trigger EmailSubscriptionTrigger on Email_Subscription__c (Before Insert, Before Update, After Insert, After Update) {
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Email_Subscription__c')) return;  
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //To Populate Email Subscription Field
                EmailSubscriptionTriggerHelper.populateEmailSubcriptionFields(Trigger.New, Trigger.OldMap);
                
                //To Verify Email Subscription Duplicacy 
                EmailSubscriptionTriggerHelper.verifyEmailDuplicacy(Trigger.New, Trigger.OldMap);
            }
        }
    }
    catch(DMLException e) {
    }
}