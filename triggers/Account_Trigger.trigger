trigger Account_Trigger on Account (before insert, before update, after insert, after update) {

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            AccountTriggerHandler.updateAccountNumber(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.makeInActiveReasonFieldRequired(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
        //     AccountTriggerHandler.createContactUnderAccount(Trigger.newMap, Trigger.oldMap);
            AccountTriggerHandler.createContactUnderAccount(Trigger.new, Trigger.oldMap);
            
}