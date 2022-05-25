/**
 *  Purpose         :   This  trigger is to handle all the pre and post processing opreration
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   08/04/2014
 * 
 *  Revision Logs   :   V_1.0 - Created
 * 			V_1.1 - Modified By - Abhinav Sharma - CR-20150219-8692 - 05/03/2015
 * 			V_1.2 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
 *			V_1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                      V_1.4 - Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update apex class IntranetItemTriggerHelper
 * 
 **/
trigger Trigger_IntranetItem on Intranet_Item__c (before insert, before update, after insert, after update, before delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Intranet_Item__c')) return;	

    try {
        
        //Check if There any need to Bypass Trigger then it will be bypassed to Prevent to run Next time 
        if(!IntranetItemTriggerHelper.isByPassIntranetItemTrigger){
            
            //Checkfor the request Type
            if(Trigger.isBefore) {
	        
                //Insert
                if(Trigger.isInsert) {
                    
                    //getUpdatedMRSAndTRSIntranetItems  (Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update apex class IntranetItemTriggerHelper)
                    IntranetItemTriggerHelper.getUpdatedMRSAndTRSIntranetItems(Trigger.New, Trigger.OldMap);	
                    
                    //Call helper class method to validate  the data
                    IntranetItemTriggerHelper.validateData(Trigger.New);
    
                } else if(Trigger.isUpdate) {
                    
                    //getUpdatedMRSAndTRSIntranetItems (Modified By - Dipesh Gupta - 05/29/2020 - CR-20200514-14042 - Update apex class IntranetItemTriggerHelper)
                    IntranetItemTriggerHelper.getUpdatedMRSAndTRSIntranetItems(Trigger.New, Trigger.OldMap);
    
                    //Populate PermaLink on update
                    IntranetItemTriggerHelper.populatePermaLink(Trigger.New);
    
                    //Call helper class method to validate  the data
                    IntranetItemTriggerHelper.validateData(Trigger.New);
    
                } else if(Trigger.isDelete) {
                    
                    //Call helper class method to validate the records before deleting
                    IntranetItemTriggerHelper.validateBeforeDelete(Trigger.Old);    	
                }
            
                //Added By - Abhinav Sharma - CR-20150219-8692 - 05/03/2015
                //Start from here
                //Checking for the event type
                if(trigger.isInsert || trigger.isUpdate) {
                    
                    //Call helper class method to validate the records before deleting
                    IntranetItemTriggerHelper.validateAndFormatURL(Trigger.new);
                    
                    //V_1.2 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
                    //Call Method to Conver YouTube Video Url to Image Url and Store it on the field
                    IntranetItemTriggerHelper.getYouTubeVideoImageUrl(Trigger.new,Trigger.OldMap);
                }
                //Upto here
                
            } else {
                
                //Check for event type
                if(Trigger.isInsert ) {
                    
                    //Create Schedules
                    IntranetItemTriggerHelper.createSchedulesForAutomatedItems(Trigger.New);
    
                    //Force re-update in order to populate PermaLink on insert
                    IntranetItemTriggerHelper.forcePermaLinkUpdate(Trigger.New);
                    
                    //Call helper method to update the Items Topics
                    IntranetItemTriggerHelper.createTopics(Trigger.New, Trigger.oldMap);
                    
                    
                } else if(Trigger.isUpdate) {
                    
                    //Call helper method to update the Items Topics
                    IntranetItemTriggerHelper.createTopics(Trigger.New, Trigger.oldMap);
                }
                
                //V_1.2 - Modified By - Abhinav Sharma - CR-20140930-7520 - 07/16/2015
                //Check for Both Insert nad update
                if(Trigger.isInsert || Trigger.isUpdate) {
                    IntranetItemTriggerHelper.getVimeoVideoImageURL(Trigger.New, Trigger.oldMap);    
                }
	    	}
        }        
	} catch(DMLException e) {
        
    	//failed record
        String failureMessage = e.getDmlMessage(0);
       
        //Add Error Message on Page
        if(Trigger.isDelete)
        	Trigger.Old[0].addError(failureMessage);
        else
        	Trigger.New[0].addError(failureMessage);    
    } catch(Exception e) {
        
    	//Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}