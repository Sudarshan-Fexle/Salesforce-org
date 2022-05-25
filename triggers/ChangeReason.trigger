/**
 *	Purpose		:	This trigger is responsible for handling all the pre or post processing for any dml operation for Change Reason object
 *
 * Create By	:	Mahendra Swarnkar
 *
 * Created Date	:	10/06/2017
 * 
 * Current Version:	v1.0
 * 
 * Revision Log	:	v1.0 - Created - Apollo Release - CR-20170927-11486 -  Added a new call for Entity field.
 * 
 * 
**/
trigger ChangeReason on Change_Reason__c (before insert, before update) {

    try {
        
        //Check Event type
        if(Trigger.isBefore) {
            
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Mahendra Swarnkar - 10/06/2017 - Apollo Release
				Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Change_Reason__c','Entity__c','ABC_Revenue__c', 'Entity__c', 'Change_Reasons__r', 'ABC_Revenue__c');
            }
        }
        
        //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Change_Reason__c')) return;
    
        //Bypassing trigger according to the flag value
        if (Util.BypassAllTriggers) 
            return;
    	
        
    } catch(DMLException e) {

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