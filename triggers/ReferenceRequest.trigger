/**
 *  Description     :  trigger for the Reference Request object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 *            			V1.1 - Modified By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766
 *            			V1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *            			V1.3 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_REFERENCE_TRIGGER_FOR_MERGE)
 *                  	V1.4 - Modified By - Victor Hanson - 04/29/2019 - CR-20190425-13033 remoed reference to updateReferenceUseThisQuaterField
 *                  	V1.5 - Modified By - Dipesh Gupta - 11/15/2019 - CR-20190919-13355 Commented 'setReferenceLead' method.
 **/
trigger ReferenceRequest on Reference_Request__c (before insert, before update, after update, after insert) {
    
    //Check Event type
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !OpportunityMergeController.isOpportunityMerge)
    Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Reference_Request__c', 'Entity__c', 'Requesting_Institution__c', 'Entity__c', 'Requesting_Institution__r', 'Account');
      
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Reference_Request__c')) return;  

    //trigger bypass
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        /*
         * Commented By - Dipesh Gupta - 11/15/2019 - CR-20190919-13355
         * 
        //set the reference lead based on the Reference Module(s) selected
        if(!ReferenceTriggerHelper.BYPASS_REFERENCE_TRIGGER_FOR_MERGE)
          ReferenceTriggerHelper.setReferenceLead(trigger.new);
		*/
    }
    else if(trigger.isAfter){
        
        //Added By - Mahendra Swarnkar - 10/22/2016 - CR-20160414-9766
        if(Trigger.IsUpdate || Trigger.IsInsert){
          
        }
    }   
}