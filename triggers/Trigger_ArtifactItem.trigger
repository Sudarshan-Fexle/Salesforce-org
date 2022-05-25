/**
*  Purpose         :  This trigger is to control the automation on Artifact Item object.
*
*  Revision Logs   :   V_1.0 - 01/18/2021 - CR-20201012-14597 - Victor Hanson - Created
*                     
**/
trigger Trigger_ArtifactItem on Artifact_Item__c (before delete, before insert, before update, after delete, after insert, after undelete, after update) {
	
    //CR-20201012-14597 - Rollup Summary Helper for Artifact Items
    dlrs.RollupService.triggerHandler();
}