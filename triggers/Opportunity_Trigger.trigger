trigger Opportunity_Trigger on Opportunity (before insert, before update) {

    if (Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate){
            OpportunityTriggerHandler.updateStageTracking(Trigger.new, Trigger.oldMap);
        }
    }
}