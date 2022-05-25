/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Eligible Domain object 
                
    Create By       :   Deepak kumawat
    
    Created Date    :   10/07/2017
    
    Current Version :   V_1.0
    
    Revision Logs   :   V_1.0 - added by Deepak kumawat - 10/06/2017 - CR-20170928-11613 - Apollo Release -  Added a new call for Entity field.
                        
*/
trigger Trigger_EligibleDomain on Eligible_Domain__c (before insert,before update, after insert, after update) {
	
    try { 
    
        //Check for requests
        if(Trigger.isBefore) {
                
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Deepak Kumawat - 10/06/2017 - Apollo Release
                Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Eligible_Domain__c', 'Entity__c', 'Account__c', 'Entity__c', 'Account__r', 'Account');
            }
        }
        
        //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Eligible_Domain__c')) return;
    
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