/**
 *  Description     :   This trigger is to handle all the pre and post processing operation for Program__c record
 * 
 *  Created By      :   Ajit Surana
 * 
 *  Created Date    :   03/30/2015
 * 
 *  Revision Logs   :
 *					:   Modified By - Ajit Surana - 03/30/2015 - CR-20150312-8758 
 *					:   Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
 *					:   Modified By - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
 *					:   Modified By - Padmesh Soni - 08/04/2015 - CR-20150729-9114 - createIncentiveChangeLog method added.
 *					:   Modified By - Rajeev Jain - 04/19/2016 - CR-20151120-9402 - Removed createIncentiveChangeLog - ISSP Deployment E - As per the updated SDD of Change Management
 *					:                                                               This trigger is to handle DML operations and validations of the program object
 *					:   Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *					:   Modified By - Mahendra Swarnkar - CR-20170927-11494 - 10/09/2017 - Apollo Release
 *					:   Modified By - Abhinav Sharma - New Call from the Trigger  - insertNewMembershipIfProgramChange - 04/19/2018
 *					:   Modified By - Mahendra Swarnakar - 02/27/2020 - CR-20200217-13758
 *					:   Modified By - Nikita Kumari- 09/28/2021 - CR-20210910-15426 - validateProgramAcronyms method Added
 * 
 **/
trigger Trigger_Program on Program__c (after insert, after update, before delete, before insert, before update, after delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Program__c')) return;	

    try {
        
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //check if trigger is in after context
        if(Trigger.isAfter) {
            
            //check insert or update context
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //call the Helper class
                ProgramTriggerHelper.insertOrUpdateProductData(Trigger.isInsert, Trigger.New);
                
                //Check if the code is executed only on the test class. 
                If(Test.isRunningTest() && ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION) {
                	ProgramTriggerHelper.CustomExceptiontoCoverCatch();            
                }
           }
            
            //Added by - Ajit Surana - 03/30/2015 - CR-20150312-8758
            if(Trigger.isUpdate) {
            
                //Modified by Mahendra Swarnkar - 02/18/2020 - CR-20190904-13309 - Field: Eligible_For_Cloning__c is deleted from contact
                //Calling helper class method
                //ProgramTriggerHelper.updateInstitutionFromMembershipRelatedProgram(Trigger.new, Trigger.oldMap);
                
                //Calling helper class method
                //Added by - Subhash Garhwal - 07/07/2018 - CR-20180323-12122 
                ProgramTriggerHelper.updateSubscriptionFields(Trigger.new, Trigger.oldMap);
                
                //Added by - Subhash Garhwal - 06/25/2015 - CR-20150618-9014
                //Call the helper class method
                //This method is used to notify Progam Group and Perspective owner on program's key field changes
                ProgramTriggerHelper.keyInformationChangedNotification(Trigger.new, Trigger.oldMap);
                
                //Added by - Padmesh Soni - 08/04/2015 - CR-20150729-9114
                //Call the helper class method
                //This method is used to create IncentiveChangeLogs record when program key field changes
                //ProgramTriggerHelper.createIncentiveChangeLog(Trigger.new, Trigger.oldMap);
                
                //Added By Abhinav Sharma - 04/19/2018 - Investigate Missing Membership - Calling a method that will create the Membership under the institution.
                ProgramTriggerHelper.insertNewMembershipIfProgramChange(Trigger.New, Trigger.oldmap);
                
            }
        }
        
        //Added by - Ajit Surana - 03/30/2015 - CR-20150312-8758
        //Check for the request Type
        if(Trigger.isBefore) {
            //check insert context
            if(Trigger.isInsert){
                //Added by - Nikita Kumari - 09/28/2021 - CR-20210910-15426
            	//validate the duplicate Program Acronym
            	ProgramTriggerHelper.validateProgramAcronyms(trigger.new);
            }
            
            //Check for the event type
            if(Trigger.isDelete) {
            	//Modified by Mahendra Swarnkar - 02/18/2020 - CR-20190904-13309 - Field: Eligible_For_Cloning__c is deleted from contact
                //Calling helper class method
                //ProgramTriggerHelper.updateInstitutionFromMembershipRelatedProgramDeletion(Trigger.oldMap);
            } 
        }
        //===================================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here=========================
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Before delete
        set<id> progidstoupdate = new set<id>();
        set<id> progidstodelete = new set<id>();
        
        //If this is After Trigger, run the Make Memberships batch
        If (Trigger.IsInsert && Trigger.IsAfter)
        {
            //Make set of program ids with qualifications
            set<id> progids = new set<Id>();
            
            for (Program__c prog : Trigger.new)
            {
                if (prog.Create_memberships__c == 'Yes' && prog.Applicable_Segments__c != null)
                    progids.add(prog.id);
            }
            
            if (!Util.IsTesting) {
                
                //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                if(!System.isFuture() && !System.isBatch()) {
                    
                    //Run batch create on qualifying Programs
                    //Modified By Abhinav Sharma - 02/12/2014 - Added batch size 50 - CR-20130718-3280
                    Id batchprocessId = Database.executeBatch(new Batch_MakeMemberships(progids), 50);
                }
            }
        }
        
        //If Before Trigger, do field updates
        if (Trigger.IsBefore)
        {
            
            // schedule the batch to populate program abbreviation on all related events associated with opps that contain this programs
            ProgramTriggerHelper.scheduleProgramAbbreviationJob(trigger.new, trigger.oldMap);
            
            //We'll need a map of New Business Marketer roles by Program for Assigned Marketer later
            map<Id, String> progid2lookuprole = new map<Id, String>();
            
            // Loop through each Program that called this trigger
            for (Program__c prog : Trigger.new)
            {
                //New record or changed Program Acronym requires recalced name
                //Simplyforce Technology - Bhavi : Updated trigger to include the logic for executing the code on Program_Formal_Name__c field change
                prog.Name = prog.Program_Acronym__c + ' - ' + prog.Program_Formal_Name__c;
                
                //Changed New Business Marketer requires changing Membership field value
                if (Trigger.IsUpdate && Trigger.newmap.get(prog.id).New_Business_Marketer__c != Trigger.oldmap.get(prog.id).New_Business_Marketer__c)
                    progidstoupdate.add(prog.id);
                
            }//end for prog : Trigger.new
            
            //Update Assigned Marketers via batch (if necessary)
            if (progidstoupdate.size() > 0 && !Util.IsTesting) {
                
                //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
                if(!System.isFuture() && !System.isBatch())
                    Id batchprocessid = Database.executeBatch(new Batch_UpdateMemberships(progidstoupdate, 'update'));
            }
    
        }//end if isbefore
        
        if(Trigger.isDelete && Trigger.isAfter)
        {
        System.debug('---------------- Step1');
            for (Program__c prog : Trigger.old)
            {
                //Deleting record requires deleting Memberships
                if (Trigger.IsDelete)
                    progidstodelete.add(prog.id);   
            }
            
            //Delete Memberships via batch (if necessary)
            if (progidstodelete.size() > 0 && !Util.IsTesting)
             //   Id batchprocessid = Database.executeBatch(new Batch_UpdateMemberships(progidstodelete, 'delete'));
             
             //SFDC Testing
            // Id batchprocessid = Database.executeBatch(new SFDC_Batch_UpdateMemberships(progidstodelete, 'delete'));
            
            System.debug('test');
        }
        //==================================Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here============================

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