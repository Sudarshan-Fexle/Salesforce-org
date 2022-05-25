/**
*   Description     :   Logic for the Advanced Approval object
*                
*   Created by      :   Victor Hanson
*
*   Created Date    :   08/04/2017
*
*   Revision Log    :   V1.0 - Created - Issue--CR10808--QA--00004965
*			V1.1 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/
trigger SBAA_Approval on sbaa__Approval__c (before update) {
	
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('sbaa__Approval__c')) return;	
	
    if (trigger.isBefore) {
        
        
        if (trigger.isUpdate) {
            
            //VH 08/04/2017 - Populates fields on Approval to support approval emails
            SBAA_ApprovalTriggerHelper.setApprovalFields(Trigger.newMap, Trigger.oldMap);
        }
    }
}