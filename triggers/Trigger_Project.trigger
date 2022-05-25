/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Project object 
                
    Create By       :   Bhavi Sharma
    
    Created Date    :   01/18/2012
    
    Current Version :   V_1.7
    
    Revision Logs   :   V_1.0 - Created
                        V_1.1 - Modified By - Bhavi Sharma - 04/26/2013 - CR-20130408-2822
                        V_1.2 - Modified By - Bhavi Sharma - 05/31/2013 - CR-20130328-2773
                        V_1.5 - Modified By - Bhavi Sharma - 12/23/2013 - CR-20130813-3414
                        V_1.6 - Modified By - Abhinav Sharma - 03/03/2014 - CR-20130829-3543
                        V_1.7 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.8 - Modified By - Abhinav Sharma - 10/17/2014 - CR-20140826-7138
                        V_1.9 - Modified By - Abhinav Sharma- 06/13/2015 - CR-20150601-8976
                        V_2.0 - Modified By - Abhinav Sharma - 07/29/2015 - CR-20150709-9070
                        V_2.1 - Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651
                        V_2.2 - Modified By - Mahendra Swarnkar - CR-20160420-9785 - 09/01/2016
                        V_2.3 - Modified By - Mahendra Swarnakar - CR-20161110-10358 - 12/10/2016
                        V_2.4 - Modified By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017
                        V_2.5 - Modified By - Abhinav Sharma - 06/02/2017 - DS114
                        V_2.6 - Modified By - Rajeev jain -7/28/2017 -Release 60 Deployment -(Modified By - Mahendra Swarnakar - 07/05/2017 - CR-20170616-11008)
                        V_2.7 - Modified By - Dipesh Gupta - 08/12/2017 -  CR-20170426-10878  - New Argument pass Trigger.Oldmap validateAndPopulateProjectFields Method.
                        V_2.8 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        V_2.9 - Modified By - Deepak Kumawat - 10/06/2017 - Apollo Release -  Added a new call for Entity field.
                        V_3.0 - Modified By - Abhinav Sharma - 09/20/2018 - CR-20180917-12599 - Created a new Method - createShadowProjectOnProjectCreation
                        V_3.1 - Modified By - Dipesh Gupta - 03/05/2020 - CR-20191223-13575 populateFieldsOndeployment
                        V_3.2 - Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Changed the method name from populateFieldsOnProjectFromAsset To populateFieldsOnProjectFromCompTechSystem
*/
trigger Trigger_Project on Project__c (before insert,before update, after insert, after update) {
    
	try{
    
        //Check for trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        	Util.validateEntityValue(Trigger.new, Trigger.oldMap, 'Project__c', 'Entity__c', 'Product__c', 'Entity__c', 'Product__r', 'Program__c');
        	
        //return immediately if method returns true	
    	if(Util.areTriggersOnThisObjectBypassed('Project__c')) return;
    
        // if bypass all triggers is set to true, return without processing
        if (Util.BypassAllTriggers) return; 
        
        //check for the request type {
        if(Trigger.isAfter) {
        
            //Check for event type
            if(Trigger.isInsert) {
                
                //Added By Mahedra Swarnkar - 12/10/2016 - CR-20161110-10358 - Create tasks for project
                ProjectTriggerHelper.createDeliveryMilestoneTasksOnproject(Trigger.New);
                
                //Added by Abhinav Sharma - 09/20/2018 - CR-20180917-12599
                ProjectTriggerHelper.createShadowProjectOnProjectCreation(Trigger.New);
            }
            
            //Check for teh event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                ProjectTriggerHelper.updateMembershipData(Trigger.New, Trigger.oldMap);
                
                //Added By Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - to populate case fields from Project
                //Call helper class method
                ProjectTriggerHelper.populateCaseFieldsFromProject(Trigger.New, Trigger.oldMap);
                
                //V_1.14 - Added By - Mahendra Swarnakar - CR-20160420-9786 - 3/16/2017
                //ProjectTriggerHelper.sendMailToContactsTaggedASProjectRoles(Trigger.New, Trigger.oldMap);
            }
            
            //Check for the update event
            if(Trigger.isUpdate) {
                
                
                //Added by VH - 12/26/13 - CR-3856
                MemberSupportTriggerUtilities.populateMemberSupportProgramType(trigger.new, trigger.oldMap);
                
                //Calling helper class method - Added By - Abhinav Sharma - 06/02/2017 - DS114
                ProjectTriggerHelper.updateMembershipsFromProject(Trigger.new, Trigger.oldMap);
                
                //Added by Abhinav Sharma - 09/20/2018 - CR-20180917-12599
                ProjectTriggerHelper.syncProjectWithPSAProject(trigger.New, trigger.oldMap);
            }
	    
            //Check for the Update and Delete case. 
            if(Trigger.isUpdate || Trigger.isDelete)
                ProjectTriggerHelper.populateFieldsOndeployment(Trigger.new, Trigger.OldMap);
        } 
        else if(Trigger.isBefore) {
            
            //Code added by Bhavi Sharma - 04/26/2013 - CR-20130408-2822
            //Check for event type 
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call helper class method
                ProjectTriggerHelper.UpdateProjectByMembershipEvent(Trigger.new, Trigger.oldMap);
                
                //Added by Bhavi Sharma - 05/31/2013 - CR-20130328-2773
                ProjectTriggerHelper.updateProjectByCurrentRenewalOpportunity(Trigger.New);
                
                //Added By - Abhinav Sharma- 06/13/2015 - CR-20150601-8976
                //Modified by DIpesh Gupta - CR-20170426-10878 - Pass Trigger.oldMap 
                ProjectTriggerHelper.validateAndPopulateProjectFields(Trigger.new,Trigger.oldMap );  

		//Merged By - Rajeev jain -7/28/2017 -Release 60 Deployment -( Added By MAhendra Swarnkar - 07/05/2017 - CR-20170616-11008) - Starts from here  
                //Call helper class method to populate TVM fields On Project record
                //ProjectTriggerHelper.populateTVMFieldsOnProjectFromMembership(Trigger.new, Trigger.oldMap);
                //Merged By - Rajeev jain -7/28/2017 -Release 60 Deployment -( Added By MAhendra Swarnkar - 07/05/2017 - CR-20170616-11008) - Ends here
                
                //Modified By - Mahendra Swarnkar - CR-20211118-15596 - 11/24/2021 - Changed the method name from populateFieldsOnProjectFromAsset To populateFieldsOnProjectFromCompTechSystem
             	//ProjectTriggerHelper.populateFieldsOnProjectFromAsset(Trigger.New, Trigger.oldMap);
             	ProjectTriggerHelper.populateFieldsOnProjectFromCompTechSystem(Trigger.New, Trigger.oldMap);
                
            }
            
            //Check for event type
            if(Trigger.isUpdate) {
                
                //Added by Abhinav Sharma - 03/03/2014 - CR-20130829-3543
                ProjectTriggerHelper.populateFirstDeploymentSignedOff(Trigger.new);
                
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