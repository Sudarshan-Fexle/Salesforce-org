/*
    Purpose         :   This trigger is responsible for handling all the pre or post processing for
                        any dml operation for Task object 
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   11/03/2011
    
    Current Version :   V1.0
    
    Revision Log    :   V1.0 - Created  
                        V1.1 - 11/20/2013 - VH - Added populateActivityDatecopy (cr-3662)
                        v1.2 - 12/17/2013 - VH - Added reference to 
                        V_1.3 - 03/07/2014 - Bhavi Sharma - CR-20140214-4512
                        V_1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
                        V_1.5 - Modified By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
                        V_1.6 - Modified By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766
                        V_1.7 - Modified By - Victor Hanson - 02/17/2017 - CR-20170217-10703 - Lookup Rollup Summary
                        V_1.8 - Modified By - Subhash Garhwal - - 02/17/2017 - CR-20170403-10807 - primaryProposalRequiredForTask(work order DS157)
            V_1.9 - Modified By - Dipesh Gupta - 09/12/2017 - CR-20170907-11182 - New Methid is created populateReleaseActualHours.
            V_1.10 - Modified By - Saurabh Kumar - 09/13/2017 - CR-20170907-11182 - New call is added rollupOnChangeRequest
            V_1.11 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
            //Merged by Dipesh Gupta for CR-20170926-11418 overlapping 
            V_1.12 - Modified By Abhinav Sharma - CR-20181008-12647
            V_1.13- Modified  By Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863 - New Method call - populateRelatedTypeField
            V_1.14 - Modified By Colin McGloin - 04/28/2019 - CR-20190419-13016 - Added new method call - saleloftTaskNotRelatedToProductLead
            V_1.15 - Modified By Dipesh Gupta - CR-20190514-13107 - 05/15/2019 - Commented method -  notifyTaskCretor.
			V_1.16 - Modified By Colin McGloin - CR-20190507-13095 - 05/15/2019 - Replaced method call to saleloftTaskNotRelatedToProductLead with saleloftTaskRelatedToContact method
            V_1.17 - Modified By -   Dipesh Gupta -12/30/2019 - CR-20191023-13455 -- added new method "updateSalesInvoice"

*/
trigger Trigger_Task on Task (before insert, before update, after insert, after update, after delete) {
    
   /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - start here*/    
    //V_1.11 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Task')) return;
     /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - ends here*/
    
    try{
        
        //CR-20170217-10703 - Rollup Summary Helper for Tasks related to Cases
        dlrs.RollupService.triggerHandler();
        
        // bypass if the bypass all trigger is true
        if (Util.BypassAllTriggers) return;
        
        //check for the trigger request type
        if (Trigger.isBefore) {
                   
            //check for the trigger event type
            if (trigger.isInsert || trigger.isUpdate) {
                
                // update the activity date copy field
                TaskTriggerHelper.populateActivityDateCopy(trigger.new);
                
                // update the program/abbreviation on new tasks
                EventUtilities.populateOppInfoToActivities(null, trigger.new);
                EventTriggerHelper.populateContactLookup(trigger.new);

                //V_1.8 - Modified By - Subhash Garhwal - - 02/17/2017 - CR-20170217-10703
                //TaskTriggerHelper.primaryProposalRequiredForTask(Trigger.new, Trigger.oldMap);
                //Added by Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863
                TaskTriggerHelper.populateRelatedTypeField(Trigger.new, Trigger.oldMap);

                //Added by Colin McGloin - 04/26/2019
                TaskTriggerHelper.saleloftTaskRelatedToContact(trigger.new);  
                
                
                
            }
            
            //Updating Task as per membership field is populated or not. 
            if(trigger.isInsert){
                
                //Calling helper class method 
                TaskTriggerHelper.updateTaskRTAsPerMembershipField(trigger.new);
            }
            
            if(trigger.isdelete)
                TaskTriggerHelper.populateFieldsOnConsolidatedInvoice(Trigger.new, Trigger.oldMap);
            
             //Check if the code is executed only on the test class. 
            If(Test.isRunningTest() && ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION) {
                ProgramTriggerHelper.CustomExceptiontoCoverCatch();            
            }
        }
        
        //check for the trigger request type
        if(Trigger.isAfter) {
            
            //Added By Bhavi Sharma - 03/07/2014 - CR-20140214-4512
            if(Trigger.isInsert) {
                TaskTriggerHelper.postMemberImpactStory(Trigger.New);
            }
                
            
            //Added By - Abhinav Sharma - 06/15/2015 - CR-20150416-8890
            //Calling helper class method
            //Start FROM here
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Added By Dipesh Gupta - CR-20191023-13455
                TaskTriggerHelper.updateSalesInvoice(Trigger.new, Trigger.oldmap);
                
                if(!TaskTriggerHelper.BYPASS_TASK_TRIGGER_FOR_MERGE) {
                    
                    TaskTriggerHelper.populateFieldsOnConsolidatedInvoice(Trigger.new, Trigger.oldMap);
                    
                    //V_1.9 - Added By Dipesh Gupta - 09/12/2017
                    TaskTriggerHelper.populateReleaseActualHours(Trigger.New, Trigger.oldmap);
                    
                    //V_1.10 - Added By - Saurabh Kumar - 09/13/2017 - CR-20170907-11182
                    TaskTriggerHelper.rollupOnChangeRequest(Trigger.New, Trigger.oldmap);  
                    
                    //Added By Abhinav Sharma - CR-20181008-12647
                    TaskTriggerHelper.updateProductLead(Trigger.new, Trigger.oldmap);
                    
                    if(Trigger.isInsert || Trigger.isUpdate){
                        //Added new method : By mahendra swarnkar - 03/24/2020 - CR-20200122-13648
                        TaskTriggerHelper.updateContactProtocoledField(Trigger.New, Trigger.oldMap);
                    }
                }
            }    
            //upto here
            
            //check for the trigger event type
            if(Trigger.isInsert || Trigger.isUpdate) { 
                
                //call the helper class
                //Commented the logic - CR-20190514-13107 - Dipesh Gupta
                //if(!TaskTriggerHelper.BYPASS_TASK_TRIGGER_FOR_MERGE)
                  //TaskTriggerHelper.notifyTaskCretor(Trigger.Old, Trigger.New);
                
                 //Added By Abhinav Sharma - SL Package - 12/11/2018.
                TaskTriggerHelper.createProductLeadsForTaskContact(trigger.New);
                
                // Added By - Dipesh Gupta - CR-20190703-13207
                TaskTriggerHelper.createMembershipForContactTaggedInProductLead(Trigger.New, Trigger.OldMap);
            }
            
            //Added By - Mahendra Swarnakar - 10/24/2016 - CR-20160414-9766
            //check for the trigger event type
            if(Trigger.isUpdate) { 
                
                //call the helper class
                TaskTriggerHelper.updateNameAndRRStatus(Trigger.New, Trigger.oldmap);
            }
        
            //Rajeev Jain - 03/03/2017 - Manually merged code from VHDev Sandbox - CR-20170217-10703 
            //check for the trigger event type
            if (trigger.isUpdate || trigger.isDelete) {
              
              if(!TaskTriggerHelper.BYPASS_TASK_TRIGGER_FOR_MERGE)
                  TaskTriggerHelper.updateFieldsOnDevActivity(Trigger.NewMap, Trigger.OldMap);
            }
        }
    //Catching DML Exceptions
   } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0) + e.getLineNumber());
        else
            Trigger.New[0].addError(e.getDmlMessage(0) + e.getLineNumber());

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getLineNumber());
        else
            Trigger.New[0].addError(e.getMessage() + e.getLineNumber());
    }
}