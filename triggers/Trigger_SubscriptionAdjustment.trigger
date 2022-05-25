trigger Trigger_SubscriptionAdjustment on Subscription_Adjustment__c (before insert, before update) {
    
    //return immediately if triggers are bypassed 
    if(Util.BypassAllTriggers || Util.areTriggersOnThisObjectBypassed('Subscription_Adjustment__c')) return;
    
    if (Trigger.isBefore) {
        
        if (trigger.isInsert) {
            
            //sets some default field values (ie: Original Quantity)
            new SubscriptionAdjustmentHelper(Trigger.new, null).cloneComponentSubscriptions();
        }
        
        if (Trigger.isUpdate) {
            
            new SubscriptionAdjustmentHelper(Trigger.new, Trigger.oldMap).cloneComponentSubscriptions();
        }
    }
}