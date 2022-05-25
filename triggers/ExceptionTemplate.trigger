/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Exception Template object
    
    Revision Logs   :   V_1.0 - 03/20/2019 - Created - Victor Hanson
*/
trigger ExceptionTemplate on Exception_Template__c (before insert, before update, after insert, after update) {
	
    if (Trigger.isBefore) {
        
        //increments the master exception template version number field
        ExceptionTemplateHelper.incrementTemplateVersion(trigger.new, trigger.oldMap);
    }
    else if (Trigger.isAfter) {
        
        //creates a new template exception version if needed
        ExceptionTemplateHelper.createExceptionVersion(trigger.new, trigger.oldMap);
        
        if(Trigger.isUpdate) {
            
            //Added By - Mahendra Swarnkar - 06/10/2019 - CR-20181019-12685
            //Update the CPQ Contract Exceptions on the update of Master Exception Template
            ExceptionTemplateHelper.updateContractExceptions(trigger.new, trigger.oldMap);
            
            //Update the versions to archived
            ExceptionTemplateHelper.updateVersionTemplateToArchived(trigger.new, trigger.oldMap);
        }
    }
}