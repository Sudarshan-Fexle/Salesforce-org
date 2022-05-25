/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Event Registration record
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   02/22/2014
 * 
 *  Revision Logs   :   V1.1 - Modified By - Victor Hanson - 01/26/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.populateTopParent
            		V1.2 - Modified By - Bhavi Sharma - 02/23/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.manageMeetingFollowers
            		V1.3 - Modified By - Bhavi Sharma - 03/03/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.createDefaultTeamMembers
            		V1.4 - Modified By - Bhavi Sharma - 03/04/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.manageCloneRulesFromParent
            		V1.5 - Modified By - Bhavi Sharma - 03/04/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.deleteRulesForUseForParent
            		V1.6 - Modified By - Bhavi Sharma - 03/27/2015 - CR-20140520-5562 - added reference to AdvisoryEventTriggerHelper.deleteRulesForEstablishedIndependentRule
            		V1.7 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  to add bypass logic to trigger.
            		V1.8 - Modified By - Victor Hanson - 06/19/2019 - CR-20190611-13177 - added reference to checkEventSync & checkZoomMeetingId
            		V1.9 - Modified By - Rajeev jain - CR-20200424-13983 - 04/29/2020 - Added a new Method, updateCommunicationTemplate
	    		V2.0 - Modified By - Saurabh Kumar - CR-20200821-14453 - 09/29/2020 Added a new method syncRegistrationPartnerStatus
	    		V2.1 - Modified By - Saurabh Kumar - CR-20200821-14465 - 10/29/2020 Added a new method populateRegistrationOnCampaignMember
            		V2.2 - Modified By - Saurabh Kumar - CR-20201117-14698 - 11/20/2020 Added a new method populateTargetApexScriptOnMassActionConfiguration
			V2.3 - Modified By - Saurabh Kumar - CR-20210324-15021 -
 			V2.4 - Modofied By - Saurabh Kumar - CR-20210210-14902 - 02/17/2021 - Added a new method cloneRegistrationsFromParentEventToChildEvent()
			V2.5 - Modified By - Saurabh Kumar - CR-20210128-14855 - 03/18/2021
			V2.6 - Modified By - Chirag Soni - CR-20210606-15193 - 02/11/2022
 * 
 **/
trigger AdvisoryEvent on Advisory_Event__c(before insert, before update, before delete, after insert, after update){
	
    //return immediately if method returns true
    //Modified By - Saurabh Kumar - CR-20210324-15021 - 04/07/2021 Added Util.BypassAllTriggers Check
    if(Util.areTriggersOnThisObjectBypassed('Advisory_Event__c') || Util.BypassAllTriggers) return;
	
    try {
    	
        //VH added 1/26/15
        AdvisoryEventTriggerHelper.populateTopParent(trigger.new, trigger.oldMap, 'Advisory_Event__c', 'Parent_Event__c', 'Master_Event__c');
        
        //Added by Saurabh Kumar - CR-20200821-14453 - 09/29/2020
        if(Trigger.isBefore){
            
            //Delete event
            if(Trigger.isDelete){
                AdvisoryEventTriggerHelper.syncRegistrationPartnerStatus(Trigger.New, Trigger.oldMap);
            }
	    
           //Modified By - Saurabh Kumar - CR-20210128-14855 - 03/18/2021 - Added
            if(Trigger.isUpdate){
                AdvisoryEventTriggerHelper.validateCampaignTemplete(Trigger.New, Trigger.oldMap);
            }
            
        }
        
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Insert/Update
            if(Trigger.isInsert || Trigger.isUpdate) {
            	
            	//Call Helper class Method to manage the followers
            	AdvisoryEventTriggerHelper.manageMeetingFollowers(Trigger.New, Trigger.oldMap);
            	
            	//Call Helper class Method to manageRules
            	AdvisoryEventTriggerHelper.manageCloneRulesFromParent(Trigger.New, Trigger.oldMap);
                 
                //Victor Hanson - 06/19/2019 - CR-20190611-13177 - Call helper method to see if the EAB Event needs to sync with the Site
                SiteMeeting.checkEventSync(Trigger.new, Trigger.oldMap);
                
                //Victor Hanson - 03/26/2020 - CR-20190611-13177
                ZoomServices.checkZoomMeetingId(Trigger.new, Trigger.oldMap);
                
                //Saurabh Kumar - 11/20/2020 - CR-20201117-14698
                AdvisoryEventTriggerHelper.populateTargetApexScriptOnMassActionConfiguration(Trigger.new, Trigger.oldMap);
                
                //Added by Saurabh Kumar - CR-20210128-14855 - 03/18/2021
                AdvisoryEventTriggerHelper.processAcquiaAutomation(Trigger.new, Trigger.oldMap);
                
                //Added by Saurabh Kumar - CR-20210210-14902 - 02/17/2021
                AdvisoryEventTriggerHelper.cloneRegistrationsFromParentEventToChildEvent(Trigger.new, Trigger.oldMap);
                
                //Updated by Saurabh Kumar - CR-20210210-14902 - 04/06/2021 - Keeping this method in last.
                //Call the helper class method to delete the related rule's is Use Rapent's rules are defined
                AdvisoryEventTriggerHelper.deleteRulesForUseForParent(Trigger.New, Trigger.oldMap);
            }
            
            //Check for the event type
            if(Trigger.isInsert) {
                 
                 //Call the helper class method to create the registration records
                 AdvisoryEventTriggerHelper.createDefaultTeamMembers(Trigger.New);
            }
            
            //Insert/Update
            if(Trigger.isUpdate) {
                
                //Call the helper class method to delete all the rules when rule is changed from Parent to Estiblisehed Independent rule.
                AdvisoryEventTriggerHelper.deleteRulesForEstablishedIndependentRule(Trigger.New, Trigger.oldMap);
                
                //Added by Saurabh Kumar - CR-20200821-14453 - 09/29/2020
                AdvisoryEventTriggerHelper.syncRegistrationPartnerStatus(Trigger.New, Trigger.oldMap);
                
                //Added By - Saurabh Kumar - CR-20200821-14465 - 10/29/2020
                AdvisoryEventTriggerHelper.populateRegistrationOnCampaignMember(Trigger.New, Trigger.oldMap);
                
                //Added By - Chirag Soni - CR-20210606-15193 - 02/11/2022
                AdvisoryEventTriggerHelper.syncEventInfoWithAcquia(Trigger.New, Trigger.oldMap);
            }
        }
        
        //Before and Insert/update case.
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            AdvisoryEventTriggerHelper.updateCommunicationTemplate(Trigger.new, Trigger.Oldmap);
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
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}