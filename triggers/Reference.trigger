/**
 *  Description     :  Trigger for the Reference object
 *
 *  Revision Logs   :   v1.0 - 12/10/2015 - Created - Victor Hanson - Reference Tracking project (CR-20150826-9191)
 * 						V1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 * 						v1.2 - Modified By - MAhendra Swarnkar - Apollo Release - 10/09/2017 - CR-20170928-11607  - Added a new call for Entity field.
 * 
**/
trigger Reference on Reference__c (before insert, before update, after insert, after update) {
    
    //CHeck for trigger
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    	Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Reference__c', 'Entity__c', 'Institution__c', 'Entity__c', 'Institution__r', 'Account');
    	
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Reference__c')) return;

    //trigger bypass
    if (Util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        //populate the Reference default fields if they are blank (Reference Lead, Dedicated Advisor, NASA Principal/AP)
        ReferenceTriggerHelper.setReferenceDefaults(trigger.new);
    }
    else if (trigger.isAfter) {
        
        //populate the reference program status on the related Contacts/Accounts
        ReferenceTriggerHelper.updateReferenceStatusString(trigger.new, trigger.oldMap);
    }
}