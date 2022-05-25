/**
 *	Purpose		:	This trigger is to handle all the pre and post processing operations for Community_user_Request__c
 *
 *	Created By	:	Ayush Gupta
 *
 *	Created Date	:	06/29/2021	
 *
 *	Rivision Log	:	V_1.1 - Created - CR-20210422-15098
 *
 **/
trigger Trigger_CreateCommunityUserOnApproval on Community_user_Request__c (before update) {
    
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Community_user_Request__c')) return;
    
    //Bypass flag
    if(Util.BypassAllTriggers) return;
    
    //Check for trigger context
    if(Trigger.isBefore) {
        
        //Check for trigger event
        if(Trigger.isUpdate) {
            CreateCommunityUserOnApprovalHelper.validateCommunityUserOnApproval(Trigger.new);
        }
    }
    
}