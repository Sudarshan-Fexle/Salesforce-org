/**
 *  Purpose         :   This trigger is to handle all teh pre and post processing operation
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/31/2015
 * 
 *  Revision Logs   :   V_1.0 - Created  
 *                      V_1.1 - Modified By - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
 *                      V_1.2 - Modified By - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224
 *                  	V_1.3 - Manual Merged By - Rajeev Jain - In Test Sandbox - 05/29/2016 - Conflict found with Release 50 CR-20150908-9224
 *                  	V_1.4 - Modified By - Rajeev Jain - 04/20/2016 - CR-20151120-9402 - Added IncentiveChangeLog Method
 *                  	V_1.5 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                 	V_1.6 - Modified By - Abhinav Sharma - 6/5/2018 - CR-20171211-11842 - Added populateStaffAssignmentRecordName method
 *                  	V_1.7 - Modified By - Dipesh Gupta - 01/03/2020 - Added a new method checkClonedStaffAssignmentAndUpdateSourceAndCloneRPP
 *                 	V_1.8 - Modified By - Saurabh Kumar - 09/22/2020 - CR-20200819-14449 - Added a new method populateEABEventFields
 *                   	V_1.9 - Modified By - Saurabh Kumar - 10/15/2020 - CR-20200821-14455 - Added a new method associateRecentRegistrationWithStaffAssignment

**/
trigger Trigger_TeamMembership on Team_Membership__c (before insert, before update, before delete, after Insert, after update, after delete) {
    
    //Added by Saurabh Kumar - 10/15/2020 - CR-20200821-14455
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
        TeamMembershipTriggerHelper.associateRecentRegistrationWithStaffAssignment(Trigger.new, Trigger.oldMap);
    }

    //return immediately if method returns true  
    if(Util.byPassFromCustomComponent || Util.areTriggersOnThisObjectBypassed('Team_Membership__c')) return;  

    try {
        //Check for the request type 
        if(Trigger.isBefore) {
            
            //Check for the Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                TeamMembershipTriggerHelper.validateTeamMemberships(Trigger.New);
                
                //Added by Rajeev Jain - CR-20170812-11145 - Update the Active Institution field
                TeamMembershipTriggerHelper.updateActiveInstitution(trigger.new);
            }
            
        }
        
        //Check for trigger request type
        if(Trigger.isAfter) {
            
            //V_1.3 - Added By - Rajeev Jain - 04/20/2016 - CR-20151120-9402
            if(Trigger.isInsert || Trigger.isUpdate){
                TeamMembershipTriggerHelper.populateStaffAssignmentRecordName(Trigger.new, Trigger.oldMap);
            	
            if(!TeamMembershipTriggerHelper.isByPassIncentiveChangeLogMethod) 
            		TeamMembershipTriggerHelper.incentiveChangeLog(Trigger.new, Trigger.oldMap);
            }
            
            if(Trigger.isInsert)
            	TeamMembershipTriggerHelper.checkClonedStaffAssignmentAndUpdateSourceAndCloneRPP(Trigger.new);
                
            //Check for trigger event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added by - Mahendra swarnkar - 03/16/2016 - CR-20150908-9224
                //Call helper class method
                //This method is used to update the Institutions to relicate the solution data on the related institution record
                if(!TeamMembershipTriggerHelper.isMethodExecutedOnce && !TeamMembershipTriggerHelper.BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE)
                    TeamMembershipTriggerHelper.updateInstitutionToReplicateSolutionData(Trigger.new, Trigger.oldMap);
                
                if(Trigger.isUpdate) {
                    //Added by - Subhash Garhwal - 06/30/2015 - CR-20150618-9014
                    //Call helper class method
                    //This method is used to validate all the related RPPs Effective dates according to Staff Assignments Effective dates
                    if(!TeamMembershipTriggerHelper.BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE)
                      TeamMembershipTriggerHelper.validateUpdate(Trigger.new, Trigger.oldMap);
                    
                    //Added by - Subhash Garhwal - 07/02/2015 - CR-20150618-9014
                    //Call helper class method
                    //This method is used to update all the related RPPs name, if SA name is changed.
                    if(!TeamMembershipTriggerHelper.BYPASS_TEAMMEMBERSHIP_TRIGGER_FOR_MERGE)
                      TeamMembershipTriggerHelper.updateRPPs(Trigger.new, Trigger.oldMap);
                }
            }
            //Added by Saurabh Kumar - 09/22/2020 - CR-20200819-14449
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)
                TeamMembershipTriggerHelper.populateEABEventFields(Trigger.new, Trigger.oldMap); 
        }
    //Catching DML Exceptions
    } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    }catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}