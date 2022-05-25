/**
*  Purpose         :  This trigger is to control the automation on Artifact object.
*
*  Revision Logs   :   V_1.0 - 04/09/2020 - CR-20200227-13815 - Victor Hanson - Created
*                     
**/
trigger Trigger_Artifact on Artifact__c (before insert, after insert,before Update,after update) {
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Artifact__c'))
        return;
    
    try {
        
        if (Trigger.isInsert && Trigger.isAfter) {
            ArtifactTriggerHelper.createArtifactTransfers(Trigger.new);
            
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            ArtifactTriggerHelper.updateArtifactTransferAndProductionTracking(Trigger.new, Trigger.OldMap);
        }
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