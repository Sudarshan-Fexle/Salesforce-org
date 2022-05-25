/**
*  Purpose         :  This trigger is to control the automation on Artifact object.
*
*  Revision Logs   :   V_1.0 - 04/09/2020 - CR-20200227-13815 - Victor Hanson - Created
*		       V_1.1 - 06/01/2020 - CR-20200601-14128 - Victor Hanson - added populateArtifactTransferFields
*		       V_1.2 - 08/17/2020 - CR-20200803-14397 - Victor Hanson - added checkStatus
*		       V_1.3 - 02/02/2021 - CR-20201012-14597 - Victor Hanson - moved to isAfter
*                     
**/
trigger Trigger_ArtifactTransfer on Artifact_Transfer__c (before insert, after insert, before update, after update) {
    
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Artifact_Transfer__c'))
        return;
    
    if (Trigger.isBefore) {
        
        //06/01/2020 - CR-20200601-14128 - Victor Hanson - populates fields on artifact transfer
        ArtifactTransferHelper.populateArtifactTransferFields(Trigger.new);
        
        if (Trigger.isUpdate) {
            
            //08/17/2020 - CR-20200803-14397 - Victor Hanson - added
            ArtifactTransferHelper.checkStatus(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        
        //02/02/2021 - CR-20201012-14597 - Victor Hanson - moved to isAfter
        ArtifactTransferHelper.updateJobTicket(Trigger.new, Trigger.oldMap);
        
        ArtifactTransferHelper.updatesOnArtifactStatusChange(Trigger.new, Trigger.oldMap);
        
        if (Trigger.isUpdate) {
            
            ArtifactTransferHelper.updatePushToTransferNow(Trigger.new, Trigger.oldMap);
            ArtifactTransferHelper.updateArtifactOnartifactTxStatusUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}