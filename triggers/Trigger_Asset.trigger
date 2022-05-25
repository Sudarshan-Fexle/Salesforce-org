/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Asset object 
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   12/19/2018
    
    Revision Logs   :   V_1.0 - Created - CR-20181025-12706
    		    : 	V_1.1 - Modified by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Delete use case
		    :   V_1.2 - Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented method updateProjectFields
*/
trigger Trigger_Asset on Asset (after insert, after update, after delete) {
    /*	
    //Check if Bypass Logic is true then bypass
    if(Util.areTriggersOnThisObjectBypassed('Asset')) return;
    
    //If bypass all triggers is set to true, return without processing
    if (Util.BypassAllTriggers) return; 
    
    try{
        
        //trigger is after check.
        if(Trigger.isAfter) {
            
            //check for the insert and update.
            //Modified by - Neha Sharma - CR-20200615-14188 - 04/08/2021 - Delete use case
            if(trigger.isInsert || trigger.isUpdate || trigger.isDelete) {
                //Calling method.
           	//Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Commented method updateProjectFields
    	    	//AssetTriggerHelper.updateProjectFields(trigger.new, trigger.oldMap);
            }
		}
	}catch(DMLException e) {

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
    }*/
}