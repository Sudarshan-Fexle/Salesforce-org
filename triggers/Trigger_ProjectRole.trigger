/**
    Desription      :   Auto-subscribe project role contacts for PT programs
  
    Created By      :   Victor Hanson
  
    Created Date    :   11/15/2013
  
    Revision Logs   :   v1 - Created (CR-3785)
                        v1.1 - VH - 09/04/2014 - EAB/SF Integration
                        v1.2 - Abhinav Sharma - 03-03-2015 - CR-20141222-8389
            		v1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 **/ 
trigger Trigger_ProjectRole on Project_Role__c (before insert, before update, after insert, after update, after delete) {

    //return immediately if method returns true 
    if(Util.areTriggersOnThisObjectBypassed('Project_Role__c')) return;

    if (Util.BypassAllTriggers) return;
    
    if (trigger.isBefore) {
        
        // Auto-subscribe project role contacts for PT programs  (CR-3785)
        SiteUserHelper.CreateAutoSubscriptions_ProjectRoles(trigger.new, trigger.oldMap);
        
        //Checking for the event type
        if(trigger.isInsert || trigger.isUpdate) {
             //Added By - Dipesh Gupta - 05-27-2020 - CR-20200519-14068
            ProjectRoleTriggerHelper.updateProjectRoleName(trigger.new, trigger.oldMap);
        }
    }
    
    //Checking for request type
    if(trigger.isAfter) {
    
        //Checking for the event type
        if(trigger.isInsert || trigger.isUpdate) {
            
            //Querying for the current logged in user details
            List<User> currentlyLoggedInUser = [SELECT ID, Name, ProfileId, Profile.Name FROM User WHERE ID =: Userinfo.getUserId()];
            
            //Checking list for null and size value
            if(currentlyLoggedInUser != null && currentlyLoggedInUser.size() > 0) {
                
                //Calling the method of ProjectRoleTriggerHelper class
                //Refactored By Doug Roberts - 08/31/2015 - Changed hard-coded 'Salesforce Administrator' and 'ABC Dataloader' to Custom Labels
                if(currentlyLoggedInUser[0].Name != Label.Salesforce_Admin_Name && currentlyLoggedInUser[0].ProfileId != null && currentlyLoggedInUser[0].Profile.Name != Label.Profile_Name_ABC_Dataloader) {
                    ProjectRoleTriggerHelper.validateExistanceOfPrimaryRoles(trigger.new, trigger.oldMap);
                }
            }
        }
        
        //Checking for the event type
        if(trigger.isInsert || trigger.isUpdate || trigger.isDelete) {
            
            //Added By - Abhinav Sharma - 03-03-2015 - CR-20141222-8389
            ProjectRoleTriggerHelper.validateProjectKeyRole(trigger.new, trigger.oldMap);
        }
    }
}