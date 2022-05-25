/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_SFDC_Change_RequestTrigger on SFDC_Change_Request__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
   if(test.isRunningTest() &&  Util.ByPassDLRSForTest == true)
       return;
       
   dlrs.RollupService.triggerHandler();
   
}