/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
 //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
trigger dlrs_Royall_ProgramTrigger on Royall_Program__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Royall_Program__c')) return;	
    
    dlrs.RollupService.triggerHandler();
}