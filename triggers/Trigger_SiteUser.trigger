/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Site User object 
                
    Create By       :   Deepak kumawat
    
    Created Date    :   10/10/2017
    
    Current Version :   V_1.0
    
    Revision Logs   :   V_1.0 - added by Deepak kumawat - 10/09/2017 - CR-20170927-11503 - Apollo Release 
                        
*/
trigger Trigger_SiteUser on Site_User__c (after update) {
    
    try { 
    	
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return;
        
    	//Check for requests
        if(Trigger.isAfter) {
                
            //Check for event
            if(Trigger.isUpdate) {
                
                //Deepak Kumawat - 10/10/2017 - Apollo Release
                SiteUserHelper.populateEntityField(Trigger.new, Trigger.oldMap);
            }
        }
        	
	    //return immediately if method returns true	
	    if(Util.areTriggersOnThisObjectBypassed('Site_User__c')) return;
    
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return;
        
    //Catching DML Exceptions
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