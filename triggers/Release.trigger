//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Modified By - Dipesh Gupta - 12/27/2019 - CR-20191216-13564 - added 'ReleaseTriggerHelper.updatingReleaseFields()'
//Modified By - Dipesh Gupta - 1/30/2020  - added 'ReleaseTriggerHelper.deleteCompChangeDetail()'
trigger Release on SFDC_Release__c (before insert, before update, after delete, after insert, after update ) {
    
    try 
    {
    	//return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('SFDC_Release__c')) return;
    
    	//return without processing if bypass all triggers is true
    	if (Util.BypassAllTriggers) return;
    
    	if (trigger.isBefore) {
        
        	//Modified By - Dipesh Gupta - 12/27/2019 - CR-20191216-13564 - updatingReleaseFields -- Starts here. 
        	if (trigger.isInsert || trigger.isUpdate) {
            
            	//If Deployment Date changes the related fields should also change. 
            	ReleaseTriggerHelper.updatingTargetFields(trigger.new, trigger.oldMap);
        	}
        	//Modified By - Dipesh Gupta - 12/27/2019 - CR-20191216-13564 - updatingReleaseFields -- Ends here.
        
            if (trigger.isUpdate) {
                
                //If the release status changes to cancelled, remove events from the deployment calendar.
                //LP_ServiceUtils.checkEventOwner(trigger.new, trigger.oldMap);
                ReleaseTriggerHelper.deleteCompChangeDetail(trigger.new, trigger.oldMap);
            }
            System.debug('@@@@@@@ In Beffore end ');
    	}
    
    	if (trigger.isAfter) {
    		System.debug('@@@@@@@ In after ');
    		if (trigger.isInsert || trigger.isUpdate)
            	{ System.debug('@@@@@@@ In after 1');
                	ReleaseTriggerHelper.manageOrgComparisionRecords(Trigger.new, Trigger.oldMap);
                	
            	}
	    
        	if (trigger.isDelete) {
            //Comment the reference - CR-20200520-14075
			//do not allow deletion of records synched with LP unless it is the site guest user
			//LP_ServiceUtils.validateDelete(trigger.old);
        	}
    	}
    }
    catch(Exception e) 
    {
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}