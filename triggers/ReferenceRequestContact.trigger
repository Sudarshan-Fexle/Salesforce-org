/**
 *  Description     :  Trigger for the Reference Request Contact object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 *					:	V1.2 - Modified By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766
 *						V1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *						V1.4 - Modified By - Subhash Garhwal - 10/10/2017 - CR-20170928-11609 -  Added a new call
 **/
trigger ReferenceRequestContact on Reference_Request_Contact__c (before insert, before update, after Insert, after update) {
	
    ///Check for trigger
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    	ReferenceRequestContactHelper.validateEntity(Trigger.new, Trigger.oldMap);
    	
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Reference_Request_Contact__c')) return;

    //trigger bypass
    if (util.BypassAllTriggers) return;
	
    if (trigger.isBefore) {
        
        //populate the approver
        ReferenceRequestContactHelper.populateApprover(trigger.new);
    }
    //Added By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766 - Starts from here
    else if(trigger.isAfter) {
        
        //Check event Type
        if( Trigger.IsInsert || Trigger.IsUpdate){
        	
        	//Call method
        	//Added By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766
            //VH Commented out 04/29/2019 - Spring Cleanup
        	//ReferenceRequestContactHelper.populateMostRecentLastUseDateOnContact(Trigger.new, Trigger.oldmap);
        }
    }
    //Added By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766 - Ends here
}