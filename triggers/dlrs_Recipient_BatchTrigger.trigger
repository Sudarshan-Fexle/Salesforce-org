/** 
*  Purpose         :  Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
* 
*  Created By      :   Mahendra Swarnakar
*
*  Created Date    :   
*
*  Revision Logs   :   V_1.0 - Created  - CR-20210323-15016

**/
trigger dlrs_Recipient_BatchTrigger on Recipient_Batch__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler();
}