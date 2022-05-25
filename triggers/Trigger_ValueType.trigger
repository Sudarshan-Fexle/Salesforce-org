/**
 *  Description     :   Trigger is used to handle all the post processing operation for value Type
 *
 *  Created By      :   Subhash Garhwal 
 *
 *  Created Date    :   09/10/2015
 *
 *  Revision Logs   :   V_1.0 - Created - CR-20150825-9182
 *			V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *						
 **/
trigger Trigger_ValueType on Value_Type__c (after update) {
	
	//return immediately if method returns true	
        if(Util.areTriggersOnThisObjectBypassed('Value_Type__c')) return;

	try {
    	
    	//Bypass flag
        if (Util.BypassAllTriggers) return; 
        	    
	    //Check for trigger context
	    if(Trigger.isAfter) {
	        
	        //Check for trigger events
	        if(Trigger.isUpdate) {
	            
	            //Call helper class method
	            //This method is used to to rename when use as value field is modified
	            ValueTypeTriggerHelper.reNameStaffHistory(Trigger.new, Trigger.oldMap);                
	        }
	    }
	//Catching DML Exception
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