/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Opportunity object
 *
 *  Create By       :   Bhavi Sharma
 *
 *  Created Date    :   01/31/2014
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Modified By - Abhinav Sharma - 07/02/2014 - CR-20140502-5327
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/26/2014 - CR-20140808-6940
 *                      V_1.3 - Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
 *                      V_1.4 - Modified By - Abhinav sharma - 09/17/2014 - CR-20140429-5272
 *                      V_1.5 - Modified By - Abhinav Sharma - 09/19/2014 - CR-20140429-5272
 *                      v_1.6 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
 *                      v_1.7 - Modified By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
 *                      V_1.8 - Modified By - Jeffery Sun - 09/30/2015 - CR-20130328-2770
 *                      v_1.9 - Modified By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
 *                      V_2.0 - Modified By - CJ Kelly - 6/20/2016 - Deactivated/reactivated to get around Data Load error pointing to this Trigger.
 *                      V_2.1 - Modified By - Subhash Garhwal - 06/23/2016 - CR-20160414-9762
 *                      V_2.2 - Modified By - Subhash Garhwal - 07/06/2016 - CR-20160414-9762
 *                      V_2.3 - Modified By - Subhash Garhwal - 07/14/2016 - CR-20160414-9762
 *                      V_2.4 - Modified By - Mahnedra Swarnkar - 10/11/2016 - CR-20160801-10076 
 *                      V_2.5 - Modified By - Mahendra Swarnakar - 1/23/2017 - CR-20170105-10596
 *                      V_2.6 - Modified By - Mahendra Swarnakar - 03/18/2017 - CR-20170216-10694 - A new method is added
 *                      V_2.7 - Modified By - Victor Hanson - 04/03/2017 - Added reference to updatePreviousOppType()
 *                      V_2.8 - Modified By - Subhash Garhwal - 04/06/2017 - CR-20170403-10807 - Added reference to updateOriginatingProgramOnAmendmentOpportunity
 *                      V_2.9 - Modified By - Subhash Garhwal - 04/06/2017 - CR-20170403-10807 - Added reference to autoPopulateFieldOnOpportuntiy
 *                      V_3.0 - Modified By - Subhash Garhwal - 04/06/2017 - CR-20170403-10807 - Added reference to preventInitiatingDuplicateOpportunities
 *                      V_3.1 - Modified By - Subhash Garhwal - 04/28/2017 - CR-20170403-10807 - Added reference to  updateOpportunityTopParentInstitution
 *                      V_3.2 - Modified By - Saurabh Kumar - 05/25/2017 - CR-20170403-10807 - A new method "updateStatusAndAmendmentTypeOnContract" is added to update Contract records
 *                      V_3.3 - Modified By - Abhinav Sharma - 06/04/2017 - DS114 
 *                      V_3.4 - Modified By - Deepak Kumawat - 06/05/2017 A new method 'populateOpportunityAmendment' is added to update Amendment field on opportunity.
 *                      V_3.5 - Modified By - Subhash Garhwal - 06/15/2017 Added reference to "updateThresholdValueOnOpportunity"
 *                      V_3.6 - Modified By - Subhash Garhwal - 06/28/2017 Added reference to "requiredAnAcitivityForActivityScheduledOppStage"
 *                      V_3.7 - Modified By - Subhash Garhwal - 06/30/2017 Added reference to "populateStartandEndDate"
 *                      V_3.8 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[                      04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
 *                      V_3.9 - Modified By - Mahendra Swarnakar - 05/04/2017 - CR-20170221-10707 - A new method is added
 *                      V_4.0 - Modified By - Rajeev Jain - 07/05/2017 - upto here
 *                      V_4.1 - Modified By - Subhash Garhwal - 07/13/2017 - "preventOpportunityStageNameToChange"
 *                      V_4.2 - Modified By - Rajeev Jain - 07/28/2017 - (Modified By - Mahendra Swarnakar - 07/05/2017 - CR-20170616-11008)
 *                      V_4.3 - Modified By -  Subhash Garhwal - 09/12/2017- Commented a method "requiredAnAcitivityForActivityScheduledOppStage" as per "Issue--CR11183--QA--00005732"
 *                      V_4.4 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                      V_4.5 - Modified By - Mahendra Swarnkar - 10/11/2017 - CR-20170929-11624 - Apollo Release
 *                      V_4.6 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASSOPPORTUNITYTRIGGERFORMERGE)
 *                      V_4.7 - Modified By - Subhash Garhwal - 06/29/2018 - CR-20180627-12306 - Add logic to bypass method for contracted SOQL issue
 *                      V_4.8 - Modified By - Rajeev jain - Deployment of Q2C CRs - CR-20180205-11986
 *                      V_4.9 - Modified By - Abhinav Sharma - CR-20180910-12583 - 09/13/2018
                        V_5.0 - Modified By - Rajeev Jain - 09/14/2018 - CR-20180910-12583 - Production.
 *                      V_5.1 - Modified By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Commented out the Method invocation "CalculateNextDecisionDate"
 *                      V_5.2 - Modified By - Mahendra Swarnkar - 04/11/2019 - CR-20181008-12649 - Added the flag "OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS"
 * 		        V_5.3 - Modified By - Colin McGloin - 05/08/2019 - CR-20190502-13078 - Added new method to run before VVSCustomHelper.runVVSLogic
 *                      V_5.4 - Modified By - Dipesh Gupta - 07/02/2019 - CR-20190226-12902 - Call in before update/Insert validateOppFieldOnCloseLost
 *		        V_5.5 - Modified By - Subhash Garhwal - 03/02/2020 - CR-20200210-13716 - Removed dataloader user bypass check
 *			V_5.6 - Modified By - Abhinav sharma - 07/13/2019 - CR-20200218-13783
 *			V_5.7 - Modified By - Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646
 *			V_5.8 - Modified By - Subhash Garhwal - on 10/24/2020 - CR-20200812-14427
 *			V_5.9 - Modified By - Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - Comment RT deleted : Contract LOA From Opportunity.
 *          		V_6.0 - Modified By - Mahendra Swarnakar -02/27/2020 - CR-20200217-13758			
 *                  	V_6.1 - Modified By - Neha Sharma - 9/04/2021 - CR-20210202-14862 - Added new method populateMaxProbabilityOppReached
 *			V_6.2 - Modified By - Mahendra Swarnkar - 08/19/2021 - CR-20210414-15080 - Institution on the proposal always matches the institution on the opportunity
*           V_6.3 - Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919
**/
trigger Trigger_Opportunity on Opportunity (before insert, before update, after insert, after update, after delete) {

    try {
    
        //Check for Trigger
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && !OpportunityMergeController.isOpportunityMerge)
            OpportunityTriggerHelper.populateEntityField(Trigger.new, Trigger.oldMap);
    
        // Added Check to Bypass the trigger if creating the upsells By Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
        //return immediately if method returns true  
        if(Util.areTriggersOnThisObjectBypassed('Opportunity') || SubscriptionAdjustmentHelper.ByPassOpportunityTriggerOnUpsells) return;  
      
        //Used for testing
        if(!Trigger.isDelete) {
            for(Opportunity opp: Trigger.new){
                //Throw Exception if requested
                if (Util.IsBreakMe) opp.addError('Requested Exception');
            }
        }
        
        
        //Bypass All Triggers
        if (Util.BypassAllTriggers) return;

        //Check for the request type
        if(Trigger.isBefore) {
      
            if(Trigger.isInsert || trigger.isUpdate)
                //Added by Rajeev Jain - ) - 09/11/2018 -CR-20180910-12583
                OpportunityTriggerHelper.updateInitialActivityDatePlanned(trigger.new);
		 
            	//Added by Colin McGloin - 05/08/2019 - CR-20190502-13078
            	VVSCustomHelper.runVVSLogic(trigger.new, trigger.oldMap);
                
                //Added By Dipesh Gupta - 07/02/2019 - CR-20190226-12902
                OpportunityTriggerHelper.validateOppFieldOnCloseLost(trigger.new, trigger.oldMap);
		
		//Added By Abhinav sharma - 07/13/2019 - CR-20200218-13783
                OpportunityTriggerHelper.validateContact(trigger.new, trigger.OldMap);
            
            	//Added By Abhinav Sharma - 07/10/2020 - CR-20200710-14288  - Taking logic from PB_Opportunity to the trigger. 
            	OpportunityTriggerHelper.updateProbabilityDate(Trigger.new, Trigger.oldMap);  
				
			 
	    //Code from Opportunity_ValidationAndFieldUpdates trigger
            if(Util.IsTrigger_EventPrewire
                || Util.IsTrigger_EventUpdateFields
                || Util.IsBatch
                || Util.IsTrigger_NBBOppFields)
                return;
			
	    //Subhash Garhwal - 03/02/2020 - CR-20200210-13716 - Removed dataloader user bypass check
            //Check users profile
            //Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;
	    //if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId)
            //  return;  // DAF - added 10/29/11 - removed ABC Dataloader from running code
            
            if(Trigger.isInsert || Trigger.isUpdate) {
                //Added By Neha Sharma - 04/09/2021 - CR-20210202-14862
                OpportunityTriggerHelper.populateMaxProbabilityOppReached(Trigger.new, Trigger.oldMap);
            }
            
            //Do not fire after Update event again
            if(Trigger.isUpdate) {
              
                 //Commented as per the Issue--CR12141--UAT--00008632 - By Subhash - 12/13/2018
                 //CR-20180402-12141  
                 //OpportunityTriggerHelper.validateOppStage(Trigger.new, Trigger.oldMap);
                 
                 //Added By Subhash Garhwal - 07/10/2018 - CR-20180205-11986
                 OpportunityTriggerHelper.setPreviosuRecordType(Trigger.new, Trigger.oldMap);
                 
                 //Added By Subhash Garhwal - 12/20/2018
                 OpportunityTriggerHelper.validateContractSignatureDateForESOpportunties(Trigger.new, Trigger.oldMap);
		 
                 //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - Start here
      		 //CR-20190821-13272
                 if(Util.BypassAllTriggers)
                    return;
    
                //disabled for bulk updatess
                if (Trigger.size == 1) {
                    SP_SalesPlanValidations.validateRequiredActions(Trigger.newMap, Trigger.oldMap);
                }
                //Modified by Mahendra Swarnakar -02/27/2020 - CR-20200217-13758 - End Here
            }
            //Modified By - Abhinav Sharma - Added Boolean flag for controlling the order of execution - CR-20140808-6940
            //Check for the event type
            if(Trigger.isInsert || (Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE)) {
                
                if(!OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS){
                
                    //Subhash Garhwal - 06/29/2018 - CR-20180627-12306
                    OpportunityTriggerHelper.opportunityContractedCheck(Trigger.new, Trigger.oldMap);

                    //V_3.10 - Merged By - Rajeev Jain - 07/28/2017 - (Added By MAhendra Swarnkar - 07/05/2017 - CR-20170616-11008) - Starts from here
                    //Call helper class method to populate TVM fields On opportunity record
                    OpportunityTriggerHelper.populateTVMFieldsOnOpportunityFromMembership(Trigger.new, Trigger.oldMap);
                    //V_3.10 - Merged By - Rajeev Jain - 07/28/2017 - (Added By MAhendra Swarnkar - 07/05/2017 - CR-20170616-11008) - Ends here

                    //Added By MAhendra Swarnkar - 05/04/2017 - CR-20170221-10707
                    //V_3.8 - Merged By - Rajeev Jain - 07/05/2017
                    //Call helper class method to populate Associate Principal On opportunity record
                    /*if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                        OpportunityTriggerHelper.populateAssociatePrincipalOnopportunity(Trigger.new);*/
                    //V_3.8 - Merged By - Rajeev Jain - 07/05/2017 - upto here
    
                    //Subhash Garhwal - 05/11/2017
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED)
                        OpportunityTriggerHelper.preventOppToMoveToContractReceivedSentToFinance(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 05/30/2017
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                        OpportunityTriggerHelper.updateRenewedContractAndPreviousContractOnContinuationOpp(Trigger.new, Trigger.oldMap);
                    
                    //Victor Hanson - 04/03/2017
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED)
                        OpportunityTriggerHelper.updatePreviousOppType(trigger.new, trigger.oldMap);
                    
                    //Subhash Garhwal - 04/06/2017 - CR-20170403-10807
                    //VH - 6/27/17 - Issue--CR10807--QA--00004570 - commenting out per updated requirements
                    //OpportunityTriggerHelper.updateOriginatingProgramOnAmendmentOpportunity(Trigger.new, Trigger.oldMap);
    
                    //Subhash Garhwal - 04/06/2017 - CR-20170403-10807
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED)
                        OpportunityTriggerHelper.autoPopulateFieldOnOpportuntiy(Trigger.New,Trigger.oldMap);
    
                    //Subhash Garhwal - 04/26/2017 - CR-20170403-10807 
                    OpportunityTriggerHelper.updateOpportunityTopParentInstitution(Trigger.New,Trigger.oldMap);

                    //Subhash Garhwal - 04/30/2017 
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED)
                        OpportunityTriggerHelper.populateStartandEndDate(Trigger.New,Trigger.oldMap);

                    //Subhash Garhwal - 06/23/2016 - CR-20160414-9762
                    //Call helper class method to validate program opportunities
                    //OpportunityTriggerHelper.PreventManualDuplicateProgramOpportunities(Trigger.new, Trigger.oldMap);
                    
                    //Added By Subhash Garhwal - on 10/24/2020 - CR-20200812-14427
		    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
		    	OpportunityTriggerHelper.populateOpportunityFieldsOnBeforeTrigger(Trigger.new,Trigger.oldMap);
                    
                }                

                //Only execute the trigger it is not executed yet
                if(Util.IsTrigger_Opportunity_ValidationAndFieldUpdates == false && Util.IsTrigger_WarmLeadMtm == false) {
                    
                    Util.IsTrigger_Opportunity_ValidationAndFieldUpdates = true; // NB20110114 - Added to prevent duplicate execution
                    
                    //Added by Ajit Surana - 03/13/2014 - CR-20140205-4458
                    //Call the helper class method to update opportunity records
                    if(Trigger.isUpdate && !OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED && !OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS)
                        OpportunityTriggerHelper.updateOpportunityNonSOXFields(Trigger.new, Trigger.oldMap);
                    
                    //Call helper class method to execute the code for Opportunity_ValidationAndFieldUpdates
                    OpportunityTriggerHelper.opportunityValidationAndFieldUpdated(Trigger.New, Trigger.newMap, Trigger.oldMap);
                }
                
                //Merged from Opportunity Related fields updates trigger
                if(Util.IsTrigger_Task_PopulateNoOfRevisitField == false && !OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS) {
                    
                    //Merged from Opportunitt Related fields updates
                    //Bhavi - 04/30/2013 - CR-20130408-2835
                    //Call helper class method to update the Opportunity Field Active_Renewal__c
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                        OpportunityTriggerHelper.populateFieldOnOpportunityWithMembership(Trigger.new, Trigger.oldMap);
                    
                    //Check for the event type
                    if(Trigger.isUpdate) {
                        
                        //Call the helper call method to update the "Initial Visit Date" on opportunity
                        if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                          OpportunityTriggerUtilities.updateInitialVisitDateByEventDate(Trigger.newMap);
                        
                         // Mahendra - CR-20200429-13999 - 04/30/2020
                        // assigns lost opportunity contacts to market warming campaign
                        /*if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                          OpportunityTriggerHelper.assignOpptyContactsToMarketWarmingCampaign(trigger.newMap,trigger.oldMap);*/
                        
                        if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                          OpportunityTriggerHelper.populateInitialVisitDate(Trigger.newMap);
                    }
                }
                
                //Added By - Abhinav Sharma - 09/19/2014 - CR-5272
                //Start from here
                //Calling helper class method
                if(Trigger.isInsert && !OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS) {
                    
                    //Deepak Kumawat
                    OpportunityTriggerHelper.populateOpportunityAmendment(trigger.new, trigger.oldMap);
                
                    //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    OpportunityTriggerHelper.applyValidationsOverOpportunityRecords(Trigger.new, Trigger.oldMap);
                    OpportunityTriggerHelper.doCalculationAndPopulateFieldsOnOpportunities(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 07/06/2016 - CR-20160414-9762
                    //Call helper class method to sync Renewal Opps
		    
                    //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                    //OpportunityTriggerHelper.syncRenewalOpp(Trigger.new);

                    //Subhash Garhwal -04/06/2017
                    //Call helper class method
                    //OpportunityTriggerHelper.preventInitiatingDuplicateOpportunities(Trigger.new);
                }
                
                //Calling helper class method in update case
                if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE && !OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS) {
                    
                    //Added By - Abhinav Sharma - 10/14/2015 - CR-20150831-9204
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                        OpportunityTriggerHelper.populateCTAssignmentManagerEmail(Trigger.new);
                    
                    //Added By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167
                    if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                        OpportunityTriggerHelper.applyValidationsOverOpportunityRecords(Trigger.new, Trigger.oldMap);
                    
                    OpportunityTriggerHelper.doCalculationAndPopulateFieldsOnOpportunities(Trigger.new, Trigger.oldMap);
                }
                //Upto here
                
                //Do not fire after Update event again
                if(Trigger.isUpdate){
                    OpportunityTriggerHelper.EXECUTE_TRIGGER_BEFORE_UPDATE = false;
                    OpportunityTriggerHelper.BYPASSFOROPPORTUNITYPRODUCTUPDATEFROMDLRS = false;
                }
                    
            }
            
        } else if(Trigger.isAfter) {

            //Modified By - Abhinav Sharma - Added Boolean flag for controlling the order of execution - CR-20140808-6940
            //Check for the event type
            if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE) {
                    
                // update opp initial visit date on related events when the opportunity initial visit date is updated cr-3662
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.populateInitialVisitOnActivities(trigger.new, trigger.oldMap);

                // update Program / Program Abbreviation on related events when the opportunity's program is updated cr-1793
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerUtilities.populateProgramInfoToActivities(trigger.new, trigger.oldMap);

                //Bhavi - 01/11/2014 - CR-20130417-2892
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.updateWarmLeadInfoOnOpportunity(Trigger.New, Trigger.oldMap);

                //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.populatePAsAndActivityFieldsOnWarmLeadMTMs(trigger.new, trigger.oldMap);
            }
            
            //Added - 06/01/2017
            if(Trigger.isUpdate) {
                
                //VH commented out 06/18/2019 due to the corresponding method being commented out
                //Subhash Garhwal - 6/5/2017
                //OpportunityTriggerHelper.updateRelationshipIntractionFields(Trigger.new, Trigger.oldMap);
                
                //Abhinav Sharma - 06/04/2017 - DS114
                //Added by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                    OpportunityTriggerHelper.updateSubscriptionsWithOpportunityFieldsValues(Trigger.New,Trigger.oldMap);
                
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.updateMembershipsWithOpportunityFieldsValues(Trigger.New,Trigger.oldMap);

                //Added By - Subhash Garhwal - 07/13/2017
                //OpportunityTriggerHelper.preventOpportunityStageNameToChange(Trigger.new,Trigger.oldMap);
                
                //Added by Abhinav Sharma
                OpportunityTriggerHelper.syncSMERequestWithOpportunity(Trigger.new, Trigger.OldMap);
                
                //Added By - Mahendra Swarnkar - 08/19/2021 - CR-20210414-15080 - Institution on the proposal always matches the institution on the opportunity
                OpportunityTriggerHelper.updateAccountOnProposal(Trigger.new, Trigger.OldMap);
            }

            //Skip trigger if this is cascading from a different update trigger
            // or if bypass all triggers is true, return without processing
            if (Util.IsTrigger_NBBOppFields
                || Util.IsTrigger_EventPrewire
                || Util.IsTrigger_EventUpdateFields
                || Util.IsBatch
                || Util.IsTrigger_Task_PopulateNoOfRevisitField) return;

            //Subhash Garhwal - 03/02/2020 - CR-20200210-13716 - Removed dataloader user bypass check
            //Check users profile
            //Id dataloaderProfileId = label.ABC_Dataloader_Profile_Id;

            //if(dataloaderProfileId != null && UserInfo.getProfileId() == dataloaderProfileId)
            //  return;  // DAF - added 10/29/11 - removed ABC Dataloader from running code

            //Insert and Update Event
            if (Trigger.isInsert || (Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE)) {
                
                //V_2.6 - Added By - Mahendra Swarnakar - 03/18/2017 - CR-20170216-10694 - Start from here
                //Checking for update event only
                if(Trigger.isUpdate)
                    OpportunityTriggerHelper.updateMainContactsOnCurrentAndFutureOpp(Trigger.new, Trigger.oldMap);
                
                //V_2.6 - Added By - Mahendra Swarnakar - 03/18/2017 - CR-20170216-10694 - Upto here
                
                //Added By - Abhinav Sharma - 05/20/2016 - CR-20160308-9682
                //Start from here  
                //Calling helper class method
                OpportunityTriggerHelper.syncOppMainContactAndPrimayOCR(Trigger.new, Trigger.oldMap);
                //Upto here
                    
                //Added By - Abhinav Sharma - 07/02/2014 - CR-20140502-5327
                //Start Here
                //Calling helper class method to update "Active Renewal Opportunity" field on membership records
                //OpportunityTriggerHelper.updateOpportunitiesWithDesiredFieldValues(Trigger.new, Trigger.oldMap);
                //Upto Here
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.updateActiveSubscriptionPeriodRenewalFieldValues(Trigger.new, Trigger.oldMap);

                //This method is to rollup the opportunity info on account level - CR-20130117-2187
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE && !OpportunityTriggerHelper.BYPASSFORCONTRACTED)
                  OpportunityTriggerHelper.rollupOppsDataOnAccount(Trigger.New);
        
        	//if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                
                //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469
                //OpportunityTriggerUtilities.CalculateNextDecisionDate(trigger.new);

                // check to see if there are any contract documents that need to be synched with the Opportunity
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerUtilities.UpdateContractDocs(trigger.new, trigger.oldMap);
        
        	if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.opportunitySignedContract(Trigger.New, Trigger.Old);

                //Bhavi - 11/07/2012 - CR-20121019-1641
                //Call helper class method to update the Pubs and Meeting data on Contact record
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.PopulateContactData(Trigger.newMap, Trigger.oldMap);
        
        	if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.updateSalesTeamRole(Trigger.newMap, Trigger.oldMap);

                //Colin McGloin - 08/01/2017 - Added to Insert or Update call
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.preventOpportunityStageNameToChange(Trigger.new,Trigger.oldMap);

            }

            //Update Event
            if(Trigger.isUpdate && OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE) {

                //Bhavi - 12/12/2012 - CR-20121106-1687
                //Call helper class method to set the agreement status to cancelled
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.validateAgreementsStatus(Trigger.newMap, Trigger.oldMap);
        
        	if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.membershipOwnerCheckfromOpps(Trigger.New);
                
                //Subhash Garhwal - 06/23/2016 - CR-20160414-9762
                //Call helper class method to validate program opportunities
                //if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                  //OpportunityTriggerHelper.validateProgramOpportunities(Trigger.new, Trigger.oldMap);
                
                //Comment out the method invocation - CR-20190104-12805.
                //Added by - Mahnedra Swarnkar - 10/11/2016 - CR-20160801-10076
                //if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE) 
                  //OpportunityTriggerHelper.sendOutTechnicalEvaluationToMarketingTeam(Trigger.new, Trigger.oldMap);
                
                //Added By - Abhinav Sharma - 1/23/2017 - CR-20170105-10596
                //Method to sync up "Membership Status" field value on associated membership records on update of status field on opportunity record
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.syncUpMembershipsWithLatestStatus(trigger.new, trigger.oldMap);
            }

            //Added By - Abhinav Sharma - 09-17-2014 - CR-20140429-5272
            //Check for event
            if(Trigger.isInsert) {
                
                //Subhash Garhwal - 07/06/2016 - CR-20160414-9762
                //Call helper class method to create IntegratedAccount for renewal Opps
                //Commented by Mahendra Swarnkar - 03/17/2020 - CR-20200217-13756 - RT deleted : Contract LOA From Opportunity.
                //OpportunityTriggerHelper.createIntegratedAccountForRenewalOpps(Trigger.new);
                
                //V_3.2 - Modified By - Saurabh Kumar - 05/25/2017 - CR-20170403-10807 - Calling helper class method to update Contract
                OpportunityTriggerHelper.updateStatusAndAmendmentTypeOnContract(Trigger.new);
            }

            //Added By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
            //Start from here
            
            //Subhash Garhwal - 06/23/2016 - CR-20160414-9762
            //Check for request type
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                //Call helper class method to Rollup Program Opps
                //OpportunityTriggerHelper.rollupProgramOpps(Trigger.new, Trigger.oldMap);
                
                OpportunityTriggerHelper.updateaOpportunityPrimaryOnContact(Trigger.new, Trigger.oldMap);
                
            }
            //Upto Here

            if(Trigger.isUpdate)
                OpportunityTriggerHelper.EXECUTE_TRIGGER_AFTER_UPDATE = false;

            //Added by Subhash Garhwal - 06/15/2017 
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //Added By Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646
                OpportunityTriggerHelper.CreateCaseUponLostOpportunityAndMarkRenewalCallAsScheduled(Trigger.new, Trigger.oldMap);
                
                //Added by Subhash Garhwal - 06/15/2017
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                  OpportunityTriggerHelper.updateThresholdValueOnOpportunity(Trigger.new, Trigger.oldMap);
                
                //Added By Subhash Garhwal - on 10/24/2020 - CR-20200812-14427
                if(!OpportunityTriggerHelper.BYPASSOPPORTUNITYTRIGGERFORMERGE)
                	OpportunityTriggerHelper.populateTriggerUpdate(Trigger.new, Trigger.oldMap);
                
                //Added by Subhash Garhwal - 12/27/2018 - CR-20181019-12685
                //OpportunityTriggerHelper.populateProgramPackageRollUpFields(Trigger.new, Trigger.oldMap);
                
            }
            
            //Added By Mahendra Swarnakar - 11/04/2020 - CR-20201029-14646

            //Modified by - Neha Sharma - 4/26/2022 - CR-20220216-15919 
            /*
            if(Trigger.isUpdate)
            {
               OpportunityTriggerHelper.CreateReviewCall(Trigger.new, Trigger.oldMap); 
            } */        

            //Added by Subhash Garhwal - 6/28/2017
            //Commented By - Subhash Garhwal - 09/12/2017-as per "Issue--CR11183--QA--00005732"
            //if(Trigger.isInsert || Trigger.isUpdate) 
            //OpportunityTriggerHelper.requiredAnAcitivityForActivityScheduledOppStage(Trigger.new, Trigger.oldMap);
        }
   } catch(DMLException e) {

        //Added By Bhavi - 01/30/2014 - CR-20131205-4084
        //failed record
        String failedRecordId = e.getDmlId(0);
        String failureMessage = e.getDmlMessage(0);

        //Check for the status code and error message
        if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION
            && failureMessage.containsIgnoreCase('You must specify a contract document type')) {

            //Query Agreement record
            if(failedRecordId != null) {

                //Fetch related agreement record
                List<echosign_dev1__SIGN_Agreement__c> agreements = [Select Id, Name from echosign_dev1__SIGN_Agreement__c where Id =: failedRecordId];

                if(agreements.size() > 0) {

                    //Custom error message
                    //String errorMessage = 'Related Contract Document Type field on the related agreement <a href="/' + failedRecordId + '" target="_blank">' + agreements[0].Name + '</a> must be populated prior to saving the opportunity as ' + Trigger.New[0].StageName;
                    String errorMessage = Label.CONTRACT_DOCUMENT_TYPE_REQUIRED_CUSTOM_ERROR_MESSAGE;
                    errorMessage = errorMessage.replace('{!agreementId}', failedRecordId).replace('{!agreementName}', agreements[0].Name).replace('{!opportunityStage}', Trigger.New[0].StageName);

                    //Add Error Message on Page
                    if(Trigger.isDelete)
                        Trigger.Old[0].addError(errorMessage);
                    else
                        Trigger.New[0].addError(errorMessage);
                } else {
                    //Add Error Message on Page
                    if(Trigger.isDelete)
                        Trigger.Old[0].addError(failureMessage);
                    else
                        Trigger.New[0].addError(failureMessage);
                }
            }
        } else {

            //Add Error Message on Page
            if(Trigger.isDelete)
                Trigger.Old[0].addError(failureMessage);
            else
                Trigger.New[0].addError(failureMessage);
        }
    } catch(Exception e) {

        //Add Error Message on Page   
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}