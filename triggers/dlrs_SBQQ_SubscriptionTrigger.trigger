/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
 //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 //Modified By - Victor Hanson - 03/05/2018 - CR-20180301-12089 - Added bypassAllTriggers to prevent SOQL Limit issue due to duplicate record updates
 //Modified By - Colin McGloin - 04/05/2018 - CR-20180123-11898 - Removed bypassAllTriggers flag
 //Modified By - Subhash Garhwal - 10/08/2018 - CR-20180720-1245 - Added ByPassAllTriggers check
trigger dlrs_SBQQ_SubscriptionTrigger on SBQQ__Subscription__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    
    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('SBQQ__Subscription__c')) return;
    
    //Modified By - Subhash Garhwal - 10/08/2018 - CR-20180720-12456
    if(Util.ByPassAllTriggers) return;   
    
    //bypass other triggers, to prevent unnecessary updates
    util.BypassAllTriggers = true;
    
    dlrs.RollupService.triggerHandler();
    
    //Modified By - Subhash Garhwal - 10/10/2018 - CR-20180720-12456
    Util.BYPASS_CONTRACT_TRIGGER = true;
    Util.BYPASS_SUBSCRIPTION_TRIGGER = true;
    
    //allow trigger updates, now that the rollup had completed
    util.BypassAllTriggers = false;
}