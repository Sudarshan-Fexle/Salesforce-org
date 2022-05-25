trigger Trigger_ProjectTask on pse__Project_Task__c (after insert, after update) {

    //return immediately if method returns true  
   if(Util.areTriggersOnThisObjectBypassed('pse__Project_Task__c')) return;

   try {

        //Calculating the Task Completion on Child Tasks
        ProjectTaskTriggerHelper.calculateTaskCompletion(Trigger.new, Trigger.oldMap);

        //Calculate the Completed Hours at Project based on Task Completion
        ProjectTaskTriggerHelper.calculateHoursCompleteToProjectRollup(Trigger.new, Trigger.oldMap);

   }    //Catching DML Exceptions
    catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }

}