/** 
  * Description     :   This trigger is to control the automation on Deployment Process Summary object.
  *
  * Created By      :   Rajeev Jain
  *
  * Created Date    :   07/27/2020
  *
  * Revision Log    :   V1.1 - Created.
**/
trigger Trigger_DeploymentProcessSummary on Deployment_Process_Summary__c (after Insert, after Update) 
{
    //Check for the trigger Bypass. 
    if(Util.ByPassAllTriggers || Util.areTriggersOnThisObjectBypassed('Deployment_Process_Summary__c'))
        return;
    
    //try
    {
        if(Trigger.isBefore)
        {
        }
        else if(Trigger.isAfter)
        {	
            if(Trigger.isInsert || Trigger.isUpdate) {
                DeploymentProcessSummaryTriggerHelper.checkProcessSummaryUpdates(Trigger.new, Trigger.oldMap);    
    			
                //Target Org back up for bacj sync records. 
                DeploymentProcessSummaryTriggerHelper.runTargetOrgBackupForBackSyncWhenValidationPassed(Trigger.new, Trigger.OldMap); 
           
            }
            
        }
        
    }
    /*catch(Exception e)
    {
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
	}*/
}