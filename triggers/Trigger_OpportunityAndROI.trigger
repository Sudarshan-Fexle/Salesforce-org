/**
*   Purpose         :   This trigger is responsible for handling all the pre or post processing for
*                       any dml operation for Opportunity and ROI object 
*
*   Create By       :   Abhinav Sharma
*
*   Created Date    :   02/07/2019
*
*   Current Version :   v1.0
*
*   Revision Logs   :   Version-1 - Created by Abhinav Sharma. 
**/
trigger Trigger_OpportunityAndROI on Opportunity_and_ROI__c (after insert, after update) {
	
    //Bypassing the triggers.
    if(Util.ByPassAlltriggers)
        return;
    
    //Check for the Bypass Custom setting 
    if(Util.areTriggersOnThisObjectBypassed('Opportunity_and_ROI__c')) return;
    
    try {
    	
        //Check for the before and after checks. 
        if(trigger.isAfter) {
            
            //check for the insert and update. 
            if(trigger.isInsert || trigger.isUpdate) {
            	
                OpportunityAndRoiTriggerHelper.populateProjectFieldsFromOpportunityAndROI(trigger.new, trigger.oldMap);
            }
        }
        
    }catch(Exception e) {
      	
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());  
    }
}