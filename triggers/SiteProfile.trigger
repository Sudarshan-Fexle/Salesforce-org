//Modified By - Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016
//Modified By - Mahendra Swarnkar  CR-20151216-9463 - 12/09/2016
//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Modified By - Victor Hanson - 04/29/2019 - CR-20190425-13033 removed reference to trackLoginHistory() method
trigger SiteProfile on Site_Profile__c (before insert, before update, after insert, after update, after delete) {
    
    if(Util.BypassAllTriggers) return;
    
    //Added By - Deepak Kumawat - 10/10/2017 - CR-20170927-11503 - Apollo Release
    if (Trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) {
        
        //Call the helper class method 
        SiteProfileTriggerHelper.populateEntityFieldOnAssociatedSiteUser(trigger.new, trigger.oldMap);
    }
        
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Site_Profile__c')) return;
	
    if (trigger.isBefore && trigger.isInsert) {
        //populate the Site Profile Created By field
        SiteProfileTriggerHelper.updateSiteProfileCreatedBy(trigger.new);
    }/*
    if (trigger.isAfter && trigger.isInsert) {
        SiteProfileTriggerHelper.autoGenerateSubscriptionsOnAutoSubscribeAll(trigger.new);
    }*/
    
    //return immediately if one of the bypass flags are true
    if (Util.BypassAllTriggers || SiteProfileTriggerHelper.bypassSiteProfileTrigger) return;
    
    /** before **/
    if (trigger.isBefore) {
        
        //check for other site profiles with the same Username + Type
        SiteProfileTriggerHelper.siteProfileDupeCheck(trigger.new);
        
        //synchronize some contact info with the site profile
        SiteProfileTriggerHelper.synchronizeContactWithSiteProfile(trigger.new, trigger.oldMap);
        
        //if the username was changed, synchronize that username across the Contact and all related site profiles
        SiteProfileTriggerHelper.synchronizeSiteProfileWithContact(trigger.new, trigger.oldMap);
        
        //validate the site profiles have an eligible domain
        SiteProfileTriggerHelper.validateEligibleDomain(trigger.new, trigger.oldMap);
        
        if (trigger.isInsert) {
            
            //create the siteUser if necessary, and validate that this profile should be created (ie: Domain validation).
            SiteProfileTriggerHelper.createSiteProfile(trigger.new);
            
            //Added By - Mahendra Swarnkar - CR-20160926-10189 - 12/8/2016
            //SiteProfileTriggerHelper.autoGenerateSubscriptionsOnAutoSubscribeAll(trigger.new);
        }
        
        if (trigger.isUpdate) {
            //VH 04/29/2019 - Commented out because this is no longer needed
            //SiteUserHelper.trackLoginHistory(trigger.new, trigger.old);
        }
        
        //Added by Mahendra Swarnkar  CR-20151216-9463 - 12/09/2016
        if(trigger.isInsert || trigger.isUpdate) {
        	SiteProfileTriggerHelper.siteProfileDuplicatePreventer(trigger.new, trigger.oldMap);
        }
    }
    
    /** after **/
    if (trigger.isAfter) {
        
        SiteProfileTriggerHelper.updateSiteProfileCount(trigger.new, trigger.oldMap);
        
        if(trigger.isInsert) {
            
            SiteProfileTriggerHelper.sendVerificationEmail(trigger.newMap.keySet());
        }
    }
}