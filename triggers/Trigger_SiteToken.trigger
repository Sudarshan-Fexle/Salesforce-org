/**
 *  Description     :   Trigger is used to handle all the pre and post processing operation for Site Token
 *
 *  Created By      :   Dipesh Gupta
 *
 *  Created Date    :   05/17/2019
 *
 *  Revision Logs   :   V_1.0 - Created - Eab.com Rebuild
 * 						V_1.1 - Modified By - Nikita Kumari - 07/30/2021 - CR-20200520-14074 - Show Site Token on 1EAB Lead record and vice-versa
 *                      
 **/

trigger Trigger_SiteToken on Site_Token__c (after Insert, after delete, after update) {
    
    //Check for the bypass. 
    if(Util.BypassAllTriggers)
        return;
    
    if(Util.areTriggersOnThisObjectBypassed('Site_Token__c'))
        return;

    //Check for the after insert or delete. 
    if(Trigger.isAfter) {
		
		//Check for the Insert and delete case. 
        if(Trigger.isInsert || Trigger.isDelete) {  
            
            SiteTokenTriggerHelper.populateTokenUsedCountOnInstitution(Trigger.new, Trigger.oldMap);
        } 
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            //Added By - Nikita Kumari - 07/30/2021 - CR-20200520-14074 - Show Site Token on 1EAB Lead record and vice-versa
            SiteTokenTriggerHelper.populateTokenOn1EABLead(Trigger.new, Trigger.oldMap);
        }
        
        if(Trigger.isDelete || Trigger.isUpdate) {
            SiteTokenTriggerHelper.updateSiteProfileWhenTokenChatterPosted(Trigger.new, Trigger.oldMap);
        }
    }
}