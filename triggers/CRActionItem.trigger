/*
    Purpose         :   This Trigger to handel the post and pre actions for "CR Action Item"
                
    Create By       :   The Advisory Board Company
    
    Created Date    :   
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created - 
						V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017
						V_1.2 Modified By - Saurabh Kumar - 09/08/2017 - CR-20170907-11182 - New calling method is added
						V_1.3 Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                       //Merged by Dipesh Gupta for CR-20170926-11418 overlapping
*/
trigger CRActionItem on CR_Action_Item__c (before insert, after insert, after update, before delete, after delete) {
    
    /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - start here*/
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('CR_Action_Item__c')) return;
    
    /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - ends here */
    
    try {
        //Check for the request type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017 - Starts from here
            if(Trigger.isBefore)
                //Call helper class method here to restrict a user to clone an issue if related CR status is deployed.
            	CRActionItemTriggerHelper.beforeEventLogic(Trigger.new, Trigger.oldMap, Trigger.isDelete);
            //V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017 - Ends here
            
            //Call helper class method here to roll up data to parent SFDC Modification
            SFDCModificationHelper.recalculateManualStepsTime (Trigger.New);
            
            //Call helper class method here to roll up data on SFDC Release
            SFDCChangeRequestTriggerHelper.rollUpDataOnSFDCRelease(CRActionItemTriggerHelper.getParentReleaseIds(Trigger.new,'ISMod'));
            
        }
        
        else if (Trigger.isDelete) {
            
            if(Trigger.isBefore){
                
                //V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017 - Starts from here
                //Call method to restrict the user for deleting the Issue CRA when the Releted CR status is deployed.
                CRActionItemTriggerHelper.beforeEventLogic(Trigger.new, Trigger.oldMap, Trigger.isDelete);
                //V_1.1 Modified By - Mahendra Swarnkar - 07/04/2017 - Ends here
                
                //Call method to get the Release Ids that will need to have recalculations
            	set<Id> setReleaseIds = CRActionItemTriggerHelper.getParentReleaseIds(Trigger.old,'ISMod');
                
                //Call method to run the recalculation.  This runs in @Future once the records are deleted.
                CRActionItemTriggerHelper.recalculateManualStepsOnReleases(setReleaseIds);
                
            }
            
            if(Trigger.isAfter){
            
            	//Call helper class method here to roll up data to parent SFDC Modification
            	SFDCModificationHelper.recalculateManualStepsTime (Trigger.Old);
            	
            }
        }
        if(Trigger.isAfter){
            
            //V_1.2 Modified By - Saurabh Kumar - 09/08/2017 - CR-20170907-11182 - New calling method is added
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
                    CRActionItemTriggerHelper.rollupFieldsOnROllup(Trigger.new, Trigger.oldMap);
            
            //V_1.0 Modified By - Dipesh Gupta - 11/14/2019 - CR-20191018-13439
            if(Trigger.isUpdate)
            {
                CRActionItemTriggerHelper.validateAndUpdateCRStatus(Trigger.new, Trigger.oldMap);
            }
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