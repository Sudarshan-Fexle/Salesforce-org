trigger Trigger_Review_Call on Review_Call__c (Before insert, Before update,After insert, After Update) {
    
    if(Trigger.isAfter) {
        
        //Check for request type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Created By Neha Sharma - 11/06/2020 - CR-20201029-14646
            ReviewCallTriggerHelper.CreateActionPlan(Trigger.new, Trigger.oldMap);
        }
    }

}