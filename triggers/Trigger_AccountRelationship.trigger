/*
    Purpose         :   Trigger on AccountRelationship__c object 
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   02/02/2015
    
    Current Version :   V_1.0
    
    Revision Logs   :   V_1.0 - Created - CR-20150116-8581
			V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/

trigger Trigger_AccountRelationship on AccountRelationship__c (before insert) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('AccountRelationship__c')) return;	

    try {
    
        //if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return; 

        //Checking for event type
        if(trigger.isBefore) {
        
            //Checking for the request type
            if(trigger.isInsert) {
            
                //Calling Helper class method
                AccountRelationshipTriggerHelper.validateRelationshipForThirdParty(trigger.new);
            }
        }
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