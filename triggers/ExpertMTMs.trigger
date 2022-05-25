/**
 *	Purpose		:	This trigger is responsible for handling all the pre or post processing for any dml operation for Change Reason object
 *
 * Create By	:	Mahendra Swarnkar
 *
 * Created Date	:	10/06/2017
 * 
 * Current Version:	v1.0
 * 
 * Revision Log	:	v1.0 - Created - Apollo Release - CR-20170928-11557 -  Added a new call for Entity field.
 * 
 * 
**/
trigger ExpertMTMs on Expert_MTM__c (before insert, before update) {
    
    try {
        
        //Check Event type
        if(Trigger.isBefore) {
            
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Mahendra Swarnkar - 10/06/2017 - Apollo Release - CR-20170928-11557
				Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Expert_MTM__c', 'Entity__c','Expert__c', 'Entity__c', 'Expert__r', 'Contact');
            }
        }
        
        //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Expert_MTM__c')) return;
    
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