/**
 *  Purpose         :   Trigger written for ComponentChangesDetailTrigger
 *					:
 *  Create By       :   
 *					:
 *  Created Date    :   
 *					:
 *  Revision Logs   :   V_1.0 - Created
 *					:   V_1.1 - Modified By - Abhishek Mishra - 09/30/2021 - CR-20210909-15416 - Comment out method is commented to avoid extra processing because this method's ("handelDuplicates") DML is already commented
 **/
trigger ComponentChangesDetailTrigger on Component_Changes_Detail__c (after insert ,before insert) {
    try {
       
        //return immediately if method returns true 
        if(Util.areTriggersOnThisObjectBypassed('Component_Changes_Detail__c')) return;
        
        //return without processing if bypass all triggers is true
        if (Util.BypassAllTriggers) return;
        
        //Before trigger logic
        if(Trigger.isBefore) {
            
            If(Trigger.isInsert || Trigger.isUpdate) {
                
                ComponentChangesDetailTriggerHelper.populateUserName(Trigger.New, Trigger.oldMap);
            }
        }
        
        //After trigger logic
        if(Trigger.isAfter) {
            
            if(Trigger.isInsert) {
                
                //Added By mahendra to handel the duplicate records
                //Commented By - Abhishek Mishra - 09/30/2021 - CR-20210909-15416 - method is commented to avoid extra processing because this method's ("handelDuplicates") DML is already commented
                //ComponentChangesDetailTriggerHelper.handelDuplicates(Trigger.New); 
                
                ComponentChangesDetailTriggerHelper.checkISSystemComponent(Trigger.New);
            }
        }
    }
    catch(Exception e) {
        
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}