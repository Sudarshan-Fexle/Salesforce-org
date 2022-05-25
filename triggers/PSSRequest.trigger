/**
    Purpose         :   This trigger to handle all the processing for PSS Request object.(CR-20160111-9502)
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   12/08/2016
    
    Revision Logs   :   V_1.0 - Created - CR-20160111-9502 
			V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.2 - Modified By - Deepak Kumawat - 10/06/2017 - CR-20170928-11564 - Apollo Release -  Added a new call for Entity field.
**/
trigger PSSRequest on PSS_Request__c (before insert, before update, after insert, after update) {
	
    try {
    	
    	//Check for trigger
    	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    		Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'PSS_Request__c', 'Entity__c', 'Program__c', 'Entity__c', 'Program__r', 'Program__c');
    	
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('PSS_Request__c')) return;
    	
    	//Bypassing trigger on the basis of boolean flag value
        if (Util.BypassAllTriggers) return;
        
        //Checking for the event
        if (trigger.isBefore) {
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                 
               //Calling Helper class method to do the validation and then populating fields on case records
                PSSRequestTriggerHelper.beforeEventsLogicHandler(Trigger.New, Trigger.oldMap);
                
                 if(Trigger.isUpdate){
                    PSSRequestTriggerHelper.validateApprovalForDenyReason(Trigger.NewMap, Trigger.oldMap);  
                }
            }
        }
        
        //Checking for event type
        if(Trigger.isAfter) {
        	
            
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Calling Helper class method to do the validation and then populating fields on case records
                //PSSRequestTriggerHelper.afterEventsLogicHandler(Trigger.New, Trigger.oldMap);
            	
				//Checking for the request type
                if(Trigger.isInsert){
                    PSSRequestTriggerHelper.startsApproval(Trigger.New);
                }
            }
        }        
    
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