trigger Contact_Trigger on Contact (after insert, after update, after delete) {

    if(Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
            ContactTriggerHandler.updateStatusCountOnAccount(Trigger.new, Trigger.oldMap);
            //ContactTriggerHandler.createUserProfile(Trigger.new, Trigger.oldMap);
        }
    }
}