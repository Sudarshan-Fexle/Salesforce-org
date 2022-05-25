/**
    Purpose         :   This trigger to handle all the processing for Scope object.(CR-20151022-9346)
                
    Create By       :   Abhinav Sharma
    
    Created Date    :   11/26/2015
    
    Revision Logs   :   V_1.0 - Created
			V_1.1 - Modified By -Mahendra Swarnkar - CR-20151022-9346 -12/8/2015
			V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        
**/
trigger Scope on Scope__c (before insert, before update, before delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Scope__c')) return;	
		
    try {
    
        //If this flag value equals to true then just bypass it
        if (Util.BypassAllTriggers) 
            return;
        
        //Checking for the event type
    	if(trigger.isBefore) {
        	
            //Checking for the request type
            if(Trigger.isInsert || Trigger.isUpdate ) {
            	
                //Calling helper class method to check for the potentials duplcates on the basis of name field value
                ScopeHelper.scopeDuplicatePreventer(trigger.new, trigger.oldMap);
            }
            
            //Added by Mahendra swarnkar -12/08/2015 - CR-20151022-9346
            //Starts from here
            //Checking for the request type
            if(Trigger.isDelete) {
                
                //Calling helper class method to delete the related scopeMtM records, if parenr scope record got deleted
                ScopeHelper.deleteScopeMTMWithScope(trigger.oldMap);
            }
            //Ends here
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