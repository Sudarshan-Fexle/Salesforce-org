/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_MembershipTrigger on Membership__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{   
    //return immediately if method returns true
    if(Util.areTriggersOnThisObjectBypassed('Membership__c')) return;
    
    //Bypassing Membership
    if(Util.ByPassDLRSMembershipTrigger && Util.ByPassAlltriggers)
        return;
    
    // Bypassing trigger to run unnecessary code execution.
    Util.ByPassAlltriggers = True;
    
    dlrs.RollupService.triggerHandler();
    
    Util.ByPassAlltriggers = false;
}