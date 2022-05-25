/*
    Purpose         :   This class is helper class for trigger on User object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   V_1.15
    
    Revision Log    :   V_1.1 Created
                    :   V_1.2 - Modified By - Ajit Surana - 04/19/2014 - CR-20140403-4951
                    :   V_1.3 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                    :   V_1.4 - Modified By - Bhavi Sharma - 01/23/2015 - CR-20141209-8273 - Deactivate Credit card records if the user in marked as deactivated
                    :   V_1.5 - Modified By - Ajit Surana - 04/29/2015 - CR-20150112-8537
                    :   V_1.6 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    :   V_1.7 - Modified By - Rajeev Jain - 08/19/2016 - Manual merged in FFDC1 from Test SB - As found Q2C Overlapping as part of deployment task.
                    :   V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release - Manual merge of Royall User Trigger with Corporate Instance               
                    :                                                  - Migrated from Shift_User_Trigger on User object, from Royall Instance
		    :	V_1.8 - Modified By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
		    :	V_1.9 - Modified By - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797
		    :   V_2.0 - Modified By - Abhinav Sharma - DS114 - 06/02/2017 - Added "updateMembershipRecordsFieldsValues" method
		    :	V_2.1 - Modified By - Victor Hanson - 07/25/2017 - Issue--CR10810--QA--00005143 - Added "checkApproverOwner" method
		    :	V_2.2 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
		    :	V_2.3 - Modified By - Mahendra Swarnkar - CR-20170928-11552 - 10/09/2017 - Apollo Release
		    :	V_2.4 - Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Added a new call deactivateStaffAssignmentForInactiveUsers
		    :	V_2.5 - Modified By - Colin McGloin - 02/02/2018 - CR-20180125-11899 - Added a new call to syncUserWorkspaceFieldsFromContact method
		    :   V_2.6 - Modified By - Subhash Garhwal - 02/05/2017 - CR-20180126-11912 - CaLL a new Method populateCTManagerEmailOnSubPeriod
		    :	V_2.7 - Modified By - Victor Hanson - 04/09/2018 - CR-20170918-11373 - Removed reference to doUpdateOnOpportunitiesOnUserUpdate()
		    :	V_2.8 - modified By - Rajeev Jain - CR-20190123-12845 - 02/05/2018 CaLL a new Method setContractTypeFree()
		    :   V_2.9 - Modified By - Mahendra Swarnkar - 03/30/2020 - CR-20200316-13858
		    :   V_3.0 - Modified By - Ayush Gupta - CR-20210422-15098
		    :	V_3.1 - Modified By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
*/

trigger Trigger_User on User (before insert, before update, after insert, after update) {
        
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('User')) return;

    try{
        
        // if bypass all triggers is true, return without processing
        if (util.BypassAllTriggers) return;
        //Check for the request type
        if(Trigger.isAfter) {
            
            if(Trigger.isInsert) {
                
                //Added as part of the Steelbrick Approval Process - Added by Colin McGloin
                UserTriggerHelper.checkForOrCreateApproverRecord(Trigger.New);
                
                //Modified By - Ayush Gupta - CR-20210422-15098
                UserTriggerHelper.setCommunityUserName(Trigger.New);
            }
            
            //Check for the event type
            if(Trigger.isUpdate) {
                
                //Bhavi Sharma - 01/23/2015 - CR-20141209-8273 - Deactivate Credit card records if the user in marked as deactivated
                //UserTriggerHelper.deactivateCreditCardsForInactiveUsers(Trigger.New, Trigger.oldMap);
                
                //Call Helper class method to update the Owner Associate
                UserTriggerHelper.updateMembershipRecords(Trigger.oldMap, Trigger.newMap);
                
                //Added by Ajit Surana - 04/19/2014 - CR-20140403-4951
                UserTriggerHelper.updateOwnerManagerEmailOnOpportunities(Trigger.new, Trigger.oldMap);
                
                //Added by Ajit Surana - 04/29/2015 - CR-20150112-8537
                UserTriggerHelper.updateCTAssignmentManagerEmailOnOpportunities(Trigger.new, Trigger.oldMap);
                
                //"V_1.7 - Manual merged in FFDC1 from Test SB - by - Rajeev Jain - 08/19/2016 - As found Q2C Overlapping as part of deployment task."
                //V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release
                // V_1.8 Updated By - Mahendra swarnakar - 11/8/2015 - CR-20160729-10074
                if (!system.isFuture() && !system.isScheduled() && !system.isBatch() && Shift_ChangeDelete_Callout.calloutSettings.Enable_User_Trigger__c) {
                    Shift_ChangeDelete_Callout.processRecords((List<SObject>)trigger.new, 'update', 'User');
                }
                //V_1.7 - Modified By - Rajeev Jain - 06/27/2016 - Royall SFDC Migration Release - upto here
                
                //Added by - Mahendra Swarnakar - 10/10/2016 - CR-20160426-9797 
                UserTriggerHelper.updateRestrictionClearanceRequestRecords(Trigger.new, Trigger.oldMap);
                
                //Modified By - Abhinav Sharma - DS114 - 06/02/2017
                UserTriggerHelper.updateMembershipRecordsFieldsValues(Trigger.new, Trigger.oldMap);
                UserTriggerHelper.updateProjectRecordsFieldsValues(Trigger.new, Trigger.oldMap);
                UserTriggerHelper.updateSubscriptionRecordsFieldsValues(Trigger.new, Trigger.oldMap);
                
                //Added by - Victor Hanson - 07/25/2017 - Issue--CR10810--QA--00005143
                UserTriggerHelper.checkApproverOwner(Trigger.newMap);
                
                //Added BY - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Added a new call deactivateStaffAssignmentForInactiveUsers
                UserTriggerHelper.deactivateStaffAssignmentForInactiveUsers(Trigger.new, Trigger.oldMap);
            }
            
            if(trigger.isInsert || trigger.isUpdate) {
                
                //Added BY - Subhash Garhwal - 02/05/2018 -CR-20180126-11912
                UserTriggerHelper.populateCTManagerEmailOnSubPeriod(trigger.new, trigger.oldmap);
                
                //Added by Mahendra Swarnkar - 03/30/2020 - CR-20200316-13858
                UserTriggerHelper.updateAccountFieldVendorInvoiceOwner(trigger.new, trigger.oldMap);
                
                //Added By - Nikita Kumari - CR-20220128-15759 - Slack API - Use the users.lookupByEmail method to populate User.Slack_Id__c
                UserTriggerHelper.populateUserSlackId(trigger.new, trigger.oldMap);
            }
        }
        
        //Before
        else if(Trigger.isBefore) {
            
            //Event Type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper call method to update data related to Cost Center
                UserTriggerHelper.updateCostCenterRelatedData(Trigger.New, Trigger.oldMap);
                
                //Update the Office Info for the User (for Workday integration)
                UserTriggerHelper.populateUserInfoOffice(trigger.new, trigger.oldMap);
                
                //Call helper call method to check if we need to sync Workspace Data
                UserTriggerHelper.syncUserWorkspaceFieldsFromContact(trigger.new, trigger.oldMap);
                
                //Added by Rajeev Jain - CR-20190123-12845 - 02/05/2018 
                //now
                //UserTriggerHelper.setContractTypeFree(trigger.new, trigger.oldMap);
                //Added this Seemu 03/14/2019
                UserTriggerHelper.setContractType(trigger.new, trigger.oldMap);
                 
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