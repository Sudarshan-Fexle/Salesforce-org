/**
    Purpose         :   Trigger for Campaign Member object.

    Created By      :   Victor Hanson

    Created Date    :   06/24/2014

    Current Version :   V_1.0
    
    Revision Log    :   V_1.0 - Created
                        V_1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  to add bypass logic to trigger.
			V_1.2 - Created - Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
			V_1.3 - Modified by - Saurabh Kumar - 10/28/2020 - CR-20200821-14465 - A new method added populateRegistration();
            		V_1.4 - Modified by - Saurabh Kumar - 03/25/2021 - CR-20201116-14696 - A new method added createAndPopulateRegistration();
            		V_1.5 - Modified by - Saurabh Kumar - 03/30/2021 - CR-20201116-14696 - A new method added postChatterOnStatusMismatch();
 **/
trigger CampaignMember on CampaignMember (before insert, before update, after insert, after update) {
    
    //return immediately if method returns true
    if(Util.areTriggersOnThisObjectBypassed('CampaignMember')) return;

    //return immediately if bypass flag is active
    if (util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        //if the campaign member is marked undeliverable, update the # undeliverable mailings on the contact
        CampaignMemberTriggerHelper.updateUndeliverableMailings(trigger.new, trigger.oldMap);
        
        if (trigger.isInsert) {
            
            CampaignMemberTriggerHelper.PopulateCampaignMemberLookups(trigger.new);
            
            //Modified by - Saurabh Kumar - 10/28/2020 - CR-20200821-14465
            CampaignMemberTriggerHelper.populateRegistration(Trigger.new);
        }
        
    } else {
        
        //Check if this is the after case
        if(Trigger.isAfter) {
         
            //Check for the trigger for the update Case
        	if(Trigger.isUpdate || Trigger.isInsert) {
                
                //Mahendra updated on 28/05/2019
                CampaignMemberTriggerHelper.mergeCampaignMember(Trigger.New, Trigger.OldMap);
        	}
            
            //Modified By - Dipesh Gupta -05/07/2020 - CR-20200429-14006 (Automated email notification to PDR for hot lead)
            if(Trigger.isInsert || Trigger.isUpdate)
                CampaignMemberTriggerHelper.sendMailToProductOwner(Trigger.New, Trigger.OldMap);
            
            if(Trigger.isUpdate)
            {
                 //Modified by - Saurabh Kumar - CR-20201116-14696 - 03/30/2021
                CampaignMemberTriggerHelper.postChatterOnStatusMismatch(Trigger.new, Trigger.oldMap);
            }
            if (trigger.isInsert || Trigger.isUpdate){
                if(CampaignMemberTriggerHelper.isCreateAndPopulateRegistrationExecute){
                    //Modified by - Saurabh Kumar - 03/25/2021 - CR-20201116-14696
                    CampaignMemberTriggerHelper.createAndPopulateRegistration(Trigger.new, Trigger.OldMap);
                }
            }
        }
    }
    
}