/**
 *	Purpose		:	This trigger is to handle all the pre and post processing operation for Rule trigger
 *
 *	Created By	:	Bhavi Sharma
 *
 *	Created Date	:	02/10/2015
 *
 *	Revision Logs	:	V_1.0 - Created
 *				V_1.1 - Modified By - Bhavi Sharma - 03/05/15 - added method: validateRuleBeforeInsert
 *				V_1.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *				V_1.3 - Modified By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453 - Added a method syncRegistrationPartnerStatus
 *				V_1.4 - Modified By - Saurabh Kumar - 01/28/20202 - UAT Issues (MRS2.0) - Added a method populateProgramNamesOnEABEvent
 *              		V_1.5 - Modified By - Victor Hanson - 03/10/2021 - updated to skip if bypassAllTriggers = true
 *			        V_1.6 - Modified By - Saurabh Kumar - 03/04/2021 - CR-20210302-14960 - Added a method createEventRules
 * 				V_1.7 - Modified By - Saurabh Kumar - 03/24/2021 - CR-20201222-14763 - Added a flag to bypass cloning of Event Rule in case of Add Program Rule via LWC(Custom Button on EAB Event)
 * 
 **/ 
trigger Trigger_Rule on Rule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    //03/10/2021 - CR-20210308-14971 - Victor Hanson - added util.bypassAllTriggers
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Rule__c')) return;

    try {
        
        //Check if trigger is enabled
        if(!RuleTriggerHelper.EXECUTE_RULE_TRIGGER)
            return;
        
        //Chekc for the request type
        if(Trigger.isBefore) {
            
            //Check for the Event Typoe
            if(Trigger.isInsert) {
                
                //Call helper class method for validate rule before inserting
                RuleTriggerHelper.validateRuleBeforeInsert(Trigger.New);
            }
            
            //Check for the Event Typoe
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method to validate the uniqueness of rule
                RuleTriggerHelper.validateRulesUniqueness(Trigger.New, Trigger.oldMap);
                
                //Call helper class method to check the Unique primary flag
                RuleTriggerHelper.validatePrimaryRule(Trigger.New);
            }
	    
            //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
            if(Trigger.isDelete){
                RuleTriggerHelper.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
            }
	    
        } else if(Trigger.isAfter) {
            
            //Insert
            if(Trigger.IsInsert) {
                
                //Create Events rules
		//Modified By - Saurabh Kumar - 03/24/2021 - CR-20201222-14763 - Added a flag to bypass cloning of Event Rule in case of Add Program Rule via LWC(Custom Button on EAB Event)
                if(RuleTriggerHelper.EXECUTE_RULE_TRIGGER_METHOD)
                	RuleTriggerHelper.manageCloneRulesFromParent(Trigger.New);
                
                //Added By - Saurabh Kumar - 03/04/2021 - CR-20210302-14960
                RuleTriggerHelper.createEventRules(Trigger.New);
            }
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Check if the Primary Program on Meeting
                RuleTriggerHelper.updateMeeting(Trigger.New, Trigger.oldMap);
                
                    //Added By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453
                    RuleTriggerHelper.syncRegistrationPartnerStatus(Trigger.new, Trigger.oldMap);
            }
            
            //Check for the Event Type
            if(Trigger.isDelete) {
                
                //Check if the Primary Program on Meeting
                RuleTriggerHelper.updateMeeting(Trigger.New, Trigger.oldMap);
            }
            
            //Added by Saurabh Kumar - 01/28/20202 - UAT Issues (MRS2.0)
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete){
                
                RuleTriggerHelper.populateProgramNamesOnEABEvent(Trigger.new, Trigger.oldMap);
            }
        }
	} catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}