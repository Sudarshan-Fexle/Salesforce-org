/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
 //Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 //Modified By - Mahendra Swarnkar - 04/11/2019 - CR-20181008-12649
trigger dlrs_OpportunityLineItemTrigger on OpportunityLineItem
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    
	//return immediately if method returns true 
    //if(Util.areTriggersOnThisObjectBypassed('CaseComment')) return;
    if(Util.areTriggersOnThisObjectBypassed('OpportunityLineItem')) return;
    
    system.debug('@@@@@@@ ' + Util.BypassAllTriggers);
	
    //Added By Mahendra Swarnkar - 04/11/2019 - CR-20181008-12649 - Set the flag to update the opportunity name on the change of opportunity product field on the related opportunity - Starts from here
    OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = true;
    OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS = true;
    //Added By Mahendra Swarnkar - 04/11/2019 - Set the flag to update the opportunity name on the change of opportunity product field on the related opportunity - Ends here
    
    dlrs.RollupService.triggerHandler();
}