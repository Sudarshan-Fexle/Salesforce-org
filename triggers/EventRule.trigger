/**
 *  Purpose     	:   This trigger is to handle all the pre and post dml operation for Event Rule object
 *
 *  Created By  	:   Chirag Soni
 *
 *  Created Date    	:   06/02/2021
 *
 *  Revision Logs   	:  V1.0 Created: Chirag Soni - 06/23/2021 - CR-20210504-15118 - added createMembershipMtMRecords method()
 *            
 **/ 

trigger EventRule on Event_Rule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers) return;
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            
            //V1.0 - Added by - Chirag Soni - 06/23/2021 - CR-20210504-15118
            EventRuleTriggerHelper.createMembershipMtMRecords(Trigger.new);
        }
    }
}