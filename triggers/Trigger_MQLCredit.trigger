/** 
*  Purpose         :  This trigger is to control the automation on MQL Credit object.
* 
*  Created By      :  Nikita Kumari
*
*  Created Date    :  02/08/2022
*
*  Revision Logs   :  V_1.0 - Created - CR-20220119-15726
**/

trigger Trigger_MQLCredit on MQL_Credit__c (before insert, before update) {
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('MQL_Credit__c'))
        return;
    
    //check for before event
    if(Trigger.isBefore)
    {
        //check insert and update cases
        if(Trigger.isInsert || Trigger.isUpdate){
            //added by - Nikita Kumari - 02/08/2022 - CR-20220119-15726 
            MQLCreditTriggerHelper.checkEventRelatedOppRT(trigger.new, trigger.oldMap);
            MQLCreditTriggerHelper.populateFieldOnBefore(trigger.new, trigger.oldMap);
        }
    }
}