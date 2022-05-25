/**
 *  Purpose         :  This trigger is to control the automation on 1EAB Lead object.
 * 
 *  Created By      :   Neha Sharma
 *
 *  Created Date    :   2/5/2021
 *
 *  Revision Logs   :   V_1.0 - Created  - CR-20201204-14721
 *                      V_1.1 - Modified By - Nikita Kumari - CR-20210316-15000 - Add 1EAB Leads to Contact Roles
 *                     
**/
trigger EABLeadTrigger on X1EAB_Lead__c (before delete, before insert, before update, after insert, after update, after delete) {
    
//return immediately if method returns true 
    if(Util.byPassAllTriggers || Util.areTriggersOnThisObjectBypassed('X1EAB_Lead__c')) 
        return;
    
    try {
    
        //Check for the after update condition - Nikita Kumari - CR-20210316-15000
        if(Trigger.isAfter && Trigger.isUpdate){
            //call helper to update Opportunity Contact Role for 1EAB Lead's Contact/Opportunity
            EABLeadTriggerHelper.updateEABContactOnOppContactRole(trigger.new,trigger.oldmap);
        }
     
        //Check for the after insert/update condition. 
        if(Trigger.isAfter && (Trigger.isInsert ||  Trigger.isUpdate)){
            EABLeadTriggerHelper.createLeadPasser(trigger.new,trigger.oldmap);
            EABLeadTriggerHelper.createProductLead(trigger.new,trigger.oldmap);
            
        }
        
    }catch(Exception e) {
        
    }
}