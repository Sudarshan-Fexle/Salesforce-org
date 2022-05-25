trigger dlrs_pse_Project_TaskTrigger on pse__Project_Task__c (before delete, before insert, before update, after delete, after insert, after undelete, after update) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('pse__Project_Task__c')) return;

    dlrs.RollupService.triggerHandler();

}