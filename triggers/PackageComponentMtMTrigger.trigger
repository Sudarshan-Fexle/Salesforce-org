/** 
*  Purpose         :  
* 
*  Created By      :   Mahendra Swarnakar
*
*  Created Date    :   
*
*  Revision Logs   :   V_1.0 - Created  - CR-20210323-15016

**/
trigger PackageComponentMtMTrigger on Package_Component_MtM__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Package Component MtM'))
        return;
    try
    {
        
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                
                PackageComponentMtMTriggerHelper.populateJobTicket(Trigger.new);
            }
          }
    }
    catch(Exception e)
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getLineNumber());
        else
            Trigger.New[0].addError(e.getMessage() + e.getLineNumber());
    }
}