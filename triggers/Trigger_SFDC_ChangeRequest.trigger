/*
    Purpose:    This trigger is responsible for handling all the pre or post processing for
                any dml operation for SFDC Chnage Request object  - CR-20120424-757
                
                Processes:
                Roll up Data from SFDC Change Request to SFDC Release   
                
                
    Create By:  Simplyforce Technology
    
    Created Date:   05/28/2012
    
    Current Version:    v1.0
    
    Revision Log:       V_1.1 Created
                        V_1.2 - Ajit Surana - 04/18/2014 - CR-20140303-4690
                        V_1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
			V_1.4 - Modified By - Mahendra Swarnkar - 1/30/2017 - CR-20160408-9753 - Added a new Method "validateCRFields"
			V_1.5 - Modified By - Victor Hanson - 03/14/2017 - CR-20170217-10703 - Added references to util.BypassAllTriggers.
			                      Did not bypass for all methods, because checkIfRollupUpdateNeeded still needs to execute
			V_1.6 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
			V_1.7 - Added By Abhinav Sharma - CR-20170420-10865 - relateCaseWithCR
			V_1.8 - Modified By - Mahendra Swarnakar -02/27/2020 - CR-20200217-13758
			V_1.9 - Modified By - Neha Sharma - 8/3/2014 - CR-20201208-14728 - Notify user when CR gets cancelled
*/
trigger Trigger_SFDC_ChangeRequest on SFDC_Change_Request__c (after insert, after update, after delete, after undelete, before insert, before update) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('SFDC_Change_Request__c')) return;

    try {
        //Check for the request type
        if(Trigger.isAfter) {
            
            //Added by Ajit Surana - 04/18/2014 - CR-20140303-4690
            //Check for the event type
            if(!util.bypassAllTriggers && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
                
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.rollUpStorySizeDataOnSFDCRelease(Trigger.New, Trigger.oldMap);
                
                //Added by Neha Sharma - 8/3/2014 - CR-20201208-14728
                if(Trigger.isUpdate) {
                    
                    //Call helper class method here to notify User on Cancel of CR 
                    SFDCChangeRequestTriggerHelper.notifyUserOnCRCancelled(Trigger.New, Trigger.oldMap);
                }
            }
            
            //Added by  Abhinav Sharma - CR-20170420-10865
            if(Trigger.isInsert) {
                
                SFDCChangeRequestTriggerHelper.relateCaseWithCR(Trigger.New);
            }
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUnDelete) {
                
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.checkIfRollupUpdateNeeded(Trigger.New);
                
            } else if (Trigger.isDelete) {
            
                //Call helper class method here to roll up data on SFDC Release
                SFDCChangeRequestTriggerHelper.checkIfRollupUpdateNeeded(Trigger.Old);
            }
        }
        
        //V_1.4 Modified By - Mahendra Swarnkar - 1/30/2017 - CR-20160408-9753
        else
        {
            if(Trigger.isBefore)
            {
                //Check for the event type
                if(!util.bypassAllTriggers && (Trigger.isInsert || Trigger.isUpdate))
                {
                    //V_1.4 Modified By - Mahendra Swarnkar - 1/30/2017 - CR-20160408-9753 - Invoke the Method to populate User fields on the CR.
                    SFDCChangeRequestTriggerHelper.validateCRFields(Trigger.New);
                }
            }
        }
        //V_1.4 Modified By - Mahendra Swarnkar - 1/30/2017 - CR-20160408-9753 - Ends here 
        //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here
	if(util.BypassAllTriggers) return;
	// get the list of change requests
        list<SFDC_Change_Request__c> changeRequests = (Trigger.IsDelete)? Trigger.old : Trigger.new;
        
        //Check for trigger context
        if(Trigger.isBefore) 
        {
            if(Trigger.isUpdate) 
            {	
                //CR-20191018-13439
                ChangeRequestUtilities.validateAndUpdateCRStatusAndStage(Trigger.new, Trigger.oldMap); 
                //Added by Neha Sharma - 8/3/2014 - CR-20201208-14728
                SFDCChangeRequestTriggerHelper.validationOnCRStatusChange(Trigger.new, Trigger.oldMap);   
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) 
        {
            //Check for trigger event
            if((Trigger.isInsert || Trigger.isUpdate) && ChangeRequestUtilities.byPassTrigger == false ) 
            {
                //Added be Dipesh Gupta - 10/03/2019 - CR-20190906-13320 
                /*Start --- Revert the changes -- By Dipesh Gupta - 03/13/2020 - CR-20190906-13320
                ChangeRequestUtilities.autoLaunchApprovals(Trigger.new, Trigger.oldMap);
                --------End ------By Dipesh Gupta - 03/13/2020 - CR-20190906-13320-----------*/
            }
            
            if(Trigger.isUpdate && ChangeRequestUtilities.byPassTrigger == false){
                //Added be Dipesh Gupta - 12/31/2019 - CR-20190906-13320
                /*Start --- Revert the changes -- By Dipesh Gupta - 03/13/2020 - CR-20190906-13320
                ChangeRequestUtilities.RequireRejectionComment(Trigger.new, Trigger.oldMap);
                --------End ------By Dipesh Gupta - 03/13/2020 - CR-20190906-13320-----------*/
            }
            
            // update the current status of the IS System if applicable
            /* V1.1 Modified By - Rajiv Jain - 19/02/2020 - CR-20200130-13677 - Remove zzzCurrent Status(Current_Status__c) field of IS_System__c object.
            	ChangeRequestUtilities.UpdateCurrentStatus(changeRequests);
            */
            ChangeRequestUtilities.validateAndUpdateReleaseStatus(Trigger.new, Trigger.oldMap);
        }
        //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here


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