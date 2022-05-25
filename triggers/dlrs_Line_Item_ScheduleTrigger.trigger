/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
 //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 //Modified By - Mahendra Swarnkar - 12/12/2017 - CR-20171204-11830 -  Added the Util.BypassAllTriggers flag.
 //Modified By - Subhash Garhwal - 09/28/2018 - CR-20180607-12270 - Added check for LineItemScheduleTriggerHelper.byPassLineItemScheduleTriggerHelper
trigger dlrs_Line_Item_ScheduleTrigger on Line_Item_Schedule__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('Line_Item_Schedule__c')) return;

    //Added by Colin McGloin - CR-20210202-14867
    if (Util.BypassAllTriggers) return;
    
    //By pass all other triggers
    Util.BypassAllTriggers = true;
    
    //To Stop dlrs unneccessory fire validating this variable form SBQQ_SubscriptionTriggerHelper 'reparentComponentSubscriptionsOnAmendment' method
    if(LineItemScheduleTriggerHelper.byPassLineItemScheduleTriggerHelper)
        return;
   
    dlrs.RollupService.triggerHandler();
    
    //Enable all the triggers
    Util.BypassAllTriggers = false;
}