/**
*  Description     :   This trigger is to handle all the pre and post processing operation for Billing schedule period record
* 
*  Created By      :   Mahendra Swarnkar
* 
*  Created Date    :   05/25/2020
* 
*  Revision Logs   :   V1.0 - Created
*		       V1.1 - Modified By - Mahendra Swarnkar - 30/11/2020 - CR-20201109-14681 - Billing - BSP Validation Rules for Installment
 *		       V1.2 - Modified By - Mahendra Swarnkar - 02/01/2021 - CR-20201229-14765 - BSP Clone Enhancement
* 
**/
trigger Trigger_BillingSchedulePeriod on Billing_Schedule_Period__c (before delete,after update,before insert,before update, after insert) {
    try {
        //return immediately if method returns true  
        if(Util.areTriggersOnThisObjectBypassed('Billing_Schedule_Period__c')) return;
        
        //if a trigger bypass is active, return immediately without processing
        if (Util.BypassAllTriggers)  return;
        
        if(Trigger.isBefore && Trigger.isDelete){
            BillingSchedulePeriodTriggerHelper.validateBSPs(trigger.new, trigger.oldMap);
        }
        
        //Created - 06/22/2020 - Mahendra Swarnkar - CR-20200619-14209
        if(Trigger.isBefore ){
            if(Trigger.isInsert || Trigger.isUpdate){
                //Added - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
                if(Trigger.isInsert){
                    BillingSchedulePeriodTriggerHelper.updateBSPonClone(trigger.new);
                }
                
                BillingSchedulePeriodTriggerHelper.populatePOonBSP(trigger.new, trigger.oldMap);
		
		//Modified By - Mahendra Swarnkar - 30/11/2020 - CR-20201109-14681 - Billing - BSP Validation Rules for Installment
                BillingSchedulePeriodTriggerHelper.validateUniqueInstallment(trigger.new, trigger.oldMap);
            }
        }
        //Added - 02/01/2021 - Mahendra Swarnkar - CR-20201109-14679
        if(Trigger.isAfter ){
            
            if(Trigger.isInsert){
                BillingSchedulePeriodTriggerHelper.cloneBSLonBSPclone(trigger.new);
            }
        }
        //Catching DML Exceptions
    } catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}