/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__Subscription__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/30/2016 
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - 08/01/2016 - Subhash Garhwal - CR-20160414-9762 - Call helper class method "validateProgramOpportunities"
 *                      V_1.2 - Modified - 05/10/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method "populateSubscriptionFieldsBasedOnMembership"
 *                      V_1.3 - Modified - 05/11/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method "updateRenewalSubscriptionOnContract"
 *                      V_1.4 - Modified - 05/17/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method "populateProgramSubscription"
 *                      V_1.5 - Modified - 05/17/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method "populateJoiningDateOfPreviousSubscription"
 *                      V_1.6 - Modified - 05/19/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method "calculateACVAndProfit"
 *                      V_1.7 - Modified - 05/24/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method  "populateRecordTypeOnSubscription"
 *                      V_1.8 - Modified - 05/24/2017 - Saurabh Kumar - CR-20170403-10807 - Calling helper class method "populateProductCode" to populate product code on the parent contract object
 *                      V_1.9 - Modified - 05/24/2017 - Subhash Garhwal  - CR-20170403-10807 - Calling helper class method  "createSubscriptionPeriodforUniqueComponent"
 *                      V_2.0 - Modified - 05/30/2017 - Subhash Garhwal  - CR-20170403-10807 - Calling helper class method  "automationSubscription" 
 *                      V_2.1 - Modified - 05/30/2017 - Subhash Garhwal  - CR-20170403-10807 - Calling helper class method  "rollUpTotalPaidSubscription" 
 *                      V_2.2 - Modified - 06/01/2017 - Saurabh Kumar - CR-20170403-10807 - New helper class method is added. "populateDefaultFieldValue"
 *                      V_2.3 - Modified - 06/02/2017 - Abhinav Sharma - DS114  - Added "populateFieldsValueOnCases" method
 *                      V_2.4 - Modified - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 (DS104.1) - A new method added "rollupNegotiatedAmountPeriodOnSubscriptionPeriod" method 
 *                      V_2.5 - Modified - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 (DS114) - A new calling method is added "updateMembershipStatusBySubscription".
 *                      V_2.6 - Modified - 06/05/2017 - Subhash Garhwal - CR-20170403-10807  - A new calling method is added "populateTypeOnContract"
 *                      V_2.7 - Modified - 06/06/2017 - Subhash Garhwal - CR-20170403-10807  - A new calling method is added "rollUpNegotiationAmountSubscription"
 *                      V_2.8 - Modofied - 06/08/2017 - Saurabh Kumar - CR-20170403-10807 (DS073.2) A new calling method is added "updateOpportunityFields"
 *                      V_2.9 - Modified - 06/08/2017 - Deepak Kumawat - new method called "validateIBSIdForProgramSubscription"
 *                      V_3.0 - Modified - 06/08/2017 - Subhash Garhwal - CR-20170403-10807 - new method called "populateRenewalFieldOnSubscription"
 *                      V_3.1 - Modified - 06/09/2017 - Deepak Kumawat - new menthd called "populateInvoiceContactFieldsOnSubscription"
 *                      V_3.2 - Modified - 06/23/2017 - Victor Hanson - popualte the previous component subscription
 *                      V_3.3 - Modified - 07/10/2017 - Subhash Garhwal - Added a new call "populateOptOutDetails"
 *                      V_3.4 - Modified - 07/21/2017 - Saurabh Kumar - Added a new call "syncPreviousPeriodNegotiatedOnSubPeriod"
 *                      V_3.5 - Modified - 07/21/2017 - Colin McGloin - Added a new call to "syncProgSubToShadowContractABC"
 *                      V_3.6 - Modified - 07/26/2017 - Saurabh Kumar - Added a new call to "populateSubscriptionFieldsOnMembership"
 *                      V_3.7 - Modified - 08/10/2017 - Colin McGloin - Commented out rollUpNegotiationAmountSubscription method (Issue--CR11094--UAT--00005346)
 *                      V_3.8 - Modified - 08/11/2017 - Subhash Garhwal - updateTravelandAnnualFeesonComponentSubscription method (Issue--CR11094--UAT--00005349)
 *                      V_3.9 - Modified - 08/28/2017 - Colin McGloin - Added bypass logic to createSubscriptionPeriodforUniqueComponent method (Issue--CR11156--QA--00005594)
 *                      V_4.0 - Modified - 09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609 - Added a new call updatePendingSPNegotiatedAmountPeriod.
 *                      V_4.1 - Modified - 09/20/2017 - Victor Hanson - Issue--CR11375--QA--00005830 - Added reference to new method "setProposalAndLineByPassFlag"
 *                      V_4.2 - Modified - 09/27/2017 - Subhash Garhwal  - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                      V_4.3 - Merged by Dipesh Gupta for CR-20170926-11418 overlapping 
 *                      V_4.4 - Modified - 11/07/2017 - Subhash Garhwal - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
 *                      V_4.5 - Modified - 11/28/2017 - Colin McGloin - CR-20171128-11817 - Added additional bypass logic to avoid SOQL limit issue
 *                      V_4.6 - Modified - 12/06/2017 - Mahendra Swarnkar - CR-20171204-11830 - Added additional bypass logic to avoid SOQL limit issue
 *                      V_4.7 - Modified - 02/01/2018 - Subhash Garhwal - CR-20180126-11910 Call a new Method updateContractABCRenewalOpportunity
 *                      V_4.8 - Modified - 02/08/2018 - Subhash Garhwal - CR-20180131-11927 Call new Methods updateProposalvalue, updateProposalValueForFutureSubPeriod
 *                      V_4.9 - Modified - 03/19/2018 - Subhash Garhwal - CR-20180314-12107 - Added check to avoid SOQL issue
 *                      V_5.0 - Modified - 03/27/2018 - Subhash Garhwal -  Added check to avoid SOQL issue
 *                      V_5.1 - Modified - 04/10/2018 - Subhash Garhwal -  New Method added - checkComponentSubscription
 *                      V_5.2 - Modified - 07/12/2018 - Subhash Garhwal -  CR-20180504-12213 - Added a new method 'updateCurrentYearFeesOnMembership'
 *                      V_5.3 - Modified - 07/23/2018 - Subhash Garhwal -  CR-20180607-12272 - Added 'updateJoinDateMostRecentOnMembership' method to update 'Join Date-Most Recent' field on Membership.
 *                      V_5.4 - Merged - 07/26/2018 - Rajeev Jain - updateCurrentYearFeesOnMembership Removed 
 *                      V_5.5 - Modified - 07/27/2018 - Victor Hanson - CR-20180607-12270 - Added reparentComponentSubscriptionsOnAmendment method
 *                      V_5.6 - Modifies - 09/25/2018 - Subhash Garhawal - CR-20180607-12270 - added 'updateStatusForAmendment'
 *                      V_5.7 - Modified - 10/08/2018 - Subhash Garhawal - CR-20180720-12456 - Added parameter in populateSubscriptionFieldsOnMembership method also add some additional checks
 *                      V_5.8 - Modified - 12/03/2018 - Subhash Garhwal - CR-20180726-12469  - A new calling method is added "calculateNextDecisionDate"
 *                      V_5.9 - Modified - 01/11/2019 - Subhash Garhwal - CR-20181019-12685 - Add a new call "syncProgramPackages"
 *                      V_6.0 - Modified - 01/23/2019 - Subhash Garhwal - CR-20181019-12685 - Added a new call "syncTotalContractQuantity"
 *                      V_6.1 - Modified - 01/31/2019 - Victor Hanson - CR-20181019-12685 - Added a new call "populateAmendmentPriceOverride"
 *                      V_6.2 - Modified - 02/21/2019 - Victor Hanson - CR-20181019-12685 - Added subscriptionFutureUpdateCount to bypass trigger after x executions within a future method (ie: ContractQuotesDeferred)
 *                      V_6.3 - Modified - 02/22/2019 - Subhash garhwal - CR-20181019-12685 - a. Added rollupDetailsonProgramSubscriptionFromComponentSubscription call.
 *                                                                                            b. Added populateStdContractFields call.
 *                                                                                            c. Added rollupCompSubToSubPeriod call.
 *                      V_6.4 - Modified - 03/05/2019 - Colin McGloin - CR-20180918-12607 - Added a call on update to goUpdateListPriceOnRevenueRecords method
 *                      V_6.5 - Modified - 04/05/2019 - Victor Hanson - CR-20181019-12685 - added custom twin field method
 *                      V_6.6 - Modified - Colin McGloin - CR-20190724-13232 - Commented out updateLISWithProgramSubscriptionIBS method 
 *                      V_6.7 - Modified - 09/13/2019 - Colin McGloin - CR-20190829-13298 - Changed event logic so SBQQ_SubscriptionTriggerHelper.populateGAAPFieldsOnAmendment is only called upon insert of the Amended record
 * 			V_6.8 - Modified - 01/27/2020 - Dipesh Gupta - CR-20200116-13629 - Added Bypass flag to bypass some methods when invoice contact updated. 
 *			V_6.9 - Modified - 05/22/2020 - Mahendra Swarnkar - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership
 *			V_7.0 - Modified - 08/18/2020 - Subhsh Garhwal  CR-20200701-14248
 *         		V_7.1 - Modified - 11/03/2020 - Neha Sharma  - CR-20200930-14569 - Commented out method calling which is used for only Membership Owner update 
 *              	V_7.2 - Modified - 10/03/2021 - Neha Sharma  - CR-20200814-14435 - Remove the Commented out populateOwnerOnMembership method calling which is used for only Membership Owner update 
**/

trigger SBQQ_SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update, after insert, after update, after delete,before delete) {
    
    	/*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - start here*/
        //return immediately if method returns true
	if(Util.areTriggersOnThisObjectBypassed('SBQQ__Subscription__c')) return;
	/*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - ends here*/
  
   try {
        
        if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && (!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE || !AddContractsToInvoiceBillingSchedule.bypassProcess)) {
            SBQQ_SubscriptionTriggerHelper.updateSubscriptionPeriodFields(trigger.new, trigger.oldMap);
        }

        //CR-20190829-13298 - Finance needs Contract ABC to be synced when certain Subscription Processes are run
        if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && (SBQQ_SubscriptionTriggerHelper.SYNC_SHADOW_ABC_WITH_SUBSCRIPTION)) {
            
            //Modified By : Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass this method when invoice contact updated 
            if(!ContractTriggerHelper.BYPASS_ON_INVOICE_CONTACT_CHANGE)
                SBQQ_SubscriptionTriggerHelper.syncProgSubToShadowContractABC(Trigger.New, Trigger.oldMap);
        }
       
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert) {
                //Subash Garhwal - 03/26/2018 - CR-20180313-12103 - Set flag value here so this can be utilized for all the methods if needed and can avoid creating duplicate flags
                //Set Insert flag value to true - 
                SBQQ_SubscriptionTriggerHelper.IS_INSERT_CASE = true;
                
                //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                //Added bypass logic for Adding Program Subscription to IBS process
                if (!AddContractsToInvoiceBillingSchedule.bypassProcess){
                    //V_1.7 - Modified - 05/24/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method populateRecordTypeOnSubscription
                    SBQQ_SubscriptionTriggerHelper.populateRecordTypeOnSubscription(Trigger.new);
                    
                    //Call helper class method to populate Program Code field
                    //SBQQ_SubscriptionTriggerHelper.populateProgramCode(Trigger.New, Trigger.oldMap);
                    
                    //Commented - 07/04/2019 - Mahendra Swarnkar - CR-20181019-12685 - "population of 'GAAP_Negotiated_Amount__c'" is migrated in the method "rollupDetailsonProgramSubscriptionFromComponentSubscription"  
                    //SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsBasedOnMembership(Trigger.New, Trigger.oldMap);
                }
            }
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //VH 09/20/2017 - Issue--CR11375--QA--00005830
                SBQQ_SubscriptionTriggerHelper.setProposalAndLineByPassFlag(Trigger.new, Trigger.oldMap);
                
                //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                //Added bypass logic for Adding Program Subscription to IBS process
                if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                
                    SBQQ_SubscriptionTriggerHelper.populateQuantity(Trigger.New);
                
                    //Subhash Garhwal - 06/04/2017 - Call helper class method to populate Program
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                      SBQQ_SubscriptionTriggerHelper.populateProgram(Trigger.new, Trigger.oldMap);
                    
                    //Call helper class method to populate various fields on Subscription
                    SBQQ_SubscriptionTriggerHelper.populateSubscriptionFields(Trigger.new, Trigger.oldMap);
                
                    //V_1.10 - Modified - 05/30/2017 - Subhash Garhwal  - CR-20170403-10807 - Calling helper class method  "automationSubscription"
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE) 
                      SBQQ_SubscriptionTriggerHelper.validatePreviousSubscriptionNegotiated(Trigger.new, Trigger.oldMap);

                    //V_1.10 - Modified - 05/30/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807 - Added a new method automationSubscription
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                      SBQQ_SubscriptionTriggerHelper.automationSubscription(Trigger.new, Trigger.oldMap);

                    //V_1.5 - Modified - 05/17/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method to populate the joining date of Previous subscription
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                      SBQQ_SubscriptionTriggerHelper.populateJoiningDateOfPreviousSubscription(Trigger.new, Trigger.oldMap);

                    //V_1.20 - Modified - 06/08/2017 - Subhash Garhwal - CR-20170403-10807 - Call helper class method to populate renewal field 
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                        SBQQ_SubscriptionTriggerHelper.populateRenewalFieldOnSubscription(Trigger.new, Trigger.oldMap);

                    //V_1.21 - Modified - 06/09/2017 - Deepak kumar - CR-20170403-10807 - Call helper class method to populate invoice contact field 
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                      SBQQ_SubscriptionTriggerHelper.populateInvoiceContactFieldsOnSubscription(Trigger.new, Trigger.oldMap);

                    //V_1.22 - Modified - 06/23/2017 - Victor Hanson - popualte the previous component subscription
                    //Modified - 3/06/2018 - Subhash Garhwal - CR-20180301-12089
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE )
                      SBQQ_SubscriptionTriggerHelper.populatePrevComponentSubscription(Trigger.new, Trigger.oldMap);

                    //V_1.25 - Modified - 07/21/2017 - Colin McGloin - Sync Program Subscription field values on Shadow Contract ABC
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE ){
                        
                        //Modified By : Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass this method when invoice contact updated 
                        if(!ContractTriggerHelper.BYPASS_ON_INVOICE_CONTACT_CHANGE)
                            SBQQ_SubscriptionTriggerHelper.syncProgSubToShadowContractABC(Trigger.New, Trigger.oldMap);
                    }
                    
                    //Added by - Subhash Garwaal - 09/27/2019
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE )
                    SBQQ_SubscriptionTriggerHelper.populateListPriceOnComponentSubscription(Trigger.New, Trigger.oldMap);
		    
                //Added by - Subhash Garwaal -  06/30/2020 - CR-20200701-14248/CR-20210218-14931
                    if((Trigger.isInsert || (Trigger.isUpdate && SBQQ_SubscriptionTriggerHelper.IS_INSERT_CASE)) && !SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE )
                    SBQQ_SubscriptionTriggerHelper.populateStartEndDateOnESYOComponentSubscription(Trigger.New, Trigger.oldMap);
                }   
                
               //Added by - Mahendra Swarnakar - 06/26/2020 Issue--CR14162--QA--00009945 (CR-20200609-14162)
                SBQQ_SubscriptionTriggerHelper.populateIvoiceArrangementProgSubscription(Trigger.New, Trigger.oldMap);

            }
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                //Added bypass logic for Adding Program Subscription to IBS process
                if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                
                    //Call helper class method to populate Program Code field
                    //SBQQ_SubscriptionTriggerHelper.populateProgramCode(Trigger.New, Trigger.oldMap);
                    
                    //Commented - 07/04/2019 - Mahendra Swarnkar - CR-20181019-12685 - "population of 'GAAP_Negotiated_Amount__c'" is migrated in the method "rollupDetailsonProgramSubscriptionFromComponentSubscription"  
                    //if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE )
		    //SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsBasedOnMembership(Trigger.New, Trigger.oldMap);
                }
                
                //V_5.09 - Modified - 01/31/2019 - Victor Hanson CR-20181019-12685 - populates Amendment_Price_Override__c
                SBQQ_SubscriptionTriggerHelper.populateAmendmentPriceOverride(Trigger.new);
                
                //V_6.01 - Added - 03/05/2019 - Colin McGloin - CR-20180918-12607 - Goes off and re-calculates ABC Revenue records as needed
                SBQQ_SubscriptionTriggerHelper.goUpdateListPriceOnRevenueRecords(Trigger.New, Trigger.oldMap);
                
                
                //V_6.02 - Added - 04/05/2019 - custom twin field functionality
                SBQQ_SubscriptionTriggerHelper.twinFields(Trigger.new);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                 
              
                //Mahendra Swarnkar - CR-20200610-14172 - 06/15/2020 -  Before delete validate Program Subscription is having the revenue records
                SBQQ_SubscriptionTriggerHelper.validateSubscription(Trigger.new, Trigger.oldMap); 

            }
            
        }
        //Check for trigger context
        if(Trigger.isAfter) {
            //check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate ) {
                SBQQ_SubscriptionTriggerHelper.populateOptOutDetailsOnChildProgramSubscriptions(Trigger.New, Trigger.oldMap);
                
                // Added by Neha Sharma CR-20200910-14498 - 10/19/2020 
                SBQQ_SubscriptionTriggerHelper.UpdateYouVisitFromCPQSubscription(Trigger.New, Trigger.oldMap);
            }
            
            //03/08/2019 - Subhash Garhwal - Call a new method to check if trigger is running from future job
            if(System.isFuture()) {
                SBQQ_SubscriptionTriggerHelper.validateCPQProcessAndByPassTrigger(Trigger.new, Trigger.isInsert);
            }
            
            
            //Check if trigger needs to bypass
            if(!SBQQ_SubscriptionTriggerHelper.IS_RUNNING_FROM_CPQ_CONTRACTED_JOB) {
                
                //Check for trigger event
                if(Trigger.isInsert) {
                    
                    //Deepak kumar - call the helper class method - Deepak Kumar - 06/07/2017 
                    SBQQ_SubscriptionTriggerHelper.createMembershipWithCIA(Trigger.New);  
                    
                    //Added by Subhash Garhawal 09/25/2018
                    SBQQ_SubscriptionTriggerHelper.updateStatusForAmendment(Trigger.New);  
                    
                }
            
                //check for trigger event
                if(Trigger.isInsert || Trigger.isUpdate ) {
                    
                    //Modified by Colin McGloin - 11/28/2017 - Added Bypass Logic 
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL){
                        SBQQ_SubscriptionTriggerHelper.populateProgramSubscription(Trigger.new, Trigger.oldMap);
                        
                        //Subhash Garhwal - 6/6/2017 - Call helper class method
                        SBQQ_SubscriptionTriggerHelper.updateMembershiponProgramSubscription(Trigger.New, Trigger.oldMap);                    
                    }
                        
                    // Added by Subhsh Garhwal 08/18/2020 - CR-20200701-14248/CR-20210218-14931
                    SBQQ_SubscriptionTriggerHelper.populateStartEndDateOnESFOProgramSubscription(Trigger.New, Trigger.oldMap);   
                    
                    if (Util.areTriggersOnThisObjectBypassed ('SBQQ__Subscription__c') == false){
                        
                        //Added-05/24/2017 Subhash Garhwal  - CR-20170403-10807
                        //Modified by Colin McGloin - 11/28/2017 - Added Bypass Logic 
                        if (!AddContractsToInvoiceBillingSchedule.bypassProcess && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL
                            && !SBQQ_SubscriptionTriggerHelper.BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS){
                                
                                //Commented out the methods as per the requirement on CR-20180720-12454
                                SBQQ_SubscriptionTriggerHelper.createSubscriptionPeriodforUniqueComponent(Trigger.New, Trigger.oldMap);
                                
                            }
                    }
                    //Modified By - Subhash GArhawal - 10/11/2018 
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL ) {
                        
                        //Added-06/09/2017 Subhash Garhwal  - CR-20170403-10807
                        //Modified By : Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass this method when invoice contact updated 
                        if(!ContractTriggerHelper.BYPASS_ON_INVOICE_CONTACT_CHANGE)
                            SBQQ_SubscriptionTriggerHelper.populateRenewalPriceFieldOnCompSubscription(Trigger.New, Trigger.oldMap);
                        
                        //Subhash Garhwal - 06/04/2017 - Call helper class method
                        SBQQ_SubscriptionTriggerHelper.validateFinalPeriodNegotiatedOnProgramSubscription(Trigger.New, Trigger.oldMap);
                        
                        //Subhash Garhwal - 6/6/2017 - Call helper class method
                        SBQQ_SubscriptionTriggerHelper.updateFinalPeriodUpliftonProgramSubscription(Trigger.New, Trigger.oldMap);
                        
                        //Subhash Garhwal - 6/6/2017 - call helper method
                        SBQQ_SubscriptionTriggerHelper.populateTypeOnContract(Trigger.New, Trigger.oldMap);
                        
                    }
                    //Modified By - Subhash GArhawal - 10/11/2018
                    //if(!Util.BYPASS_SUBSCRIPTION_TRIGGER && !Util.BYPASS_CONTRACT_TRIGGER)
                    
                    //Subhash Garhwal - 6/9/2017 - Call helper method
                    SBQQ_SubscriptionTriggerHelper.validateContractABC(Trigger.New, Trigger.oldMap);
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                        
                        //Modified - Subhash Garhawal - 10/08/2018 - CR-20180720-1245
                        //Saurabh Kumar - 07/26/2017 - Calling helper method
                        if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL) {
                            
                            SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(Trigger.new, Trigger.oldMap);
                        }
                        
                        //09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609 - Added a new call updatePendingSPNegotiatedAmountPeriod.
                        if(!SBQQ_SubscriptionTriggerHelper.BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                            SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(Trigger.new, Trigger.oldMap);
                        
                    }
                    
                    //Added By Subhash Garhawal - 04/10/2018
                    SBQQ_SubscriptionTriggerHelper.checkComponentSubscription(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 01/11/2019 - CR-20181019-12685
                    SBQQ_SubscriptionTriggerHelper.syncProgramPackages(Trigger.new, Trigger.oldMap);
                }
                
                //Checking for the update use case
                if(Trigger.isUpdate) {
                    
                    //Calling helper class method - Added by - Subhash Garhwal - Subhash Garhwal - 12/03/2018 - CR-20180726-12469
                    SBQQ_SubscriptionTriggerHelper.calculateNextDecisionDate(Trigger.New, Trigger.oldMap);
                    
                    //Calling helper class method - Added by - Subhash Garhwal - 07/12/2018 - CR-20180504-12213
                    SBQQ_SubscriptionTriggerHelper.updateCurrentYearFeesOnMembership(Trigger.New, Trigger.oldMap);
                    
                    //Commented By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
                    //Calling helper class method - Added by - Subhash Garhwal - 07/23/2018 - CR-20180607-12272
                    //SBQQ_SubscriptionTriggerHelper.updateJoinDateMostRecentOnMembership(Trigger.NewMap, Trigger.oldMap);
                    
                    //Added - 10/20/2018 - Subhash Garhwal - Issue--CR12270--UAT--00008464
                    SBQQ_SubscriptionTriggerHelper.updateContractABC(Trigger.new, Trigger.oldMap);
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL) {
                        
                        //Calling helper class method - Added by - Abhinav Sharma - 06/02/2017 - DS114
                        SBQQ_SubscriptionTriggerHelper.populateFieldsValueOnCases(Trigger.New, Trigger.oldMap);
                        
                        //Subhash Garhwal - call helper class method
                        SBQQ_SubscriptionTriggerHelper.validateSubscriptionPeriods(Trigger.New, Trigger.oldMap);
                        
                    }
                    
                    //Updated By Mahendra Swarnkar - 03/05/2018 - CR-20180301-12089 - Added check (!SBQQ_SubscriptionTriggerHelper.BYPASS_MULTIPLE_EXECUTION_OF_updateLISWithProgramSubscriptionIBS)
                    //Deepak kumar - call the helper class method - Deepak Kumar - 06/07/2017
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE && !SBQQ_SubscriptionTriggerHelper.BYPASS_MULTIPLE_EXECUTION_OF_updateLISWithProgramSubscriptionIBS
                       && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                        SBQQ_SubscriptionTriggerHelper.updateLISWithProgramSubscriptionIBS(Trigger.New);
                    //Updated By Mahendra Swarnkar - 03/05/2018 -CR-20180301-12089 - Ends
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                        
                        //V_1.15 - Modified - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 (DS114)
                        if(!SBQQ_SubscriptionTriggerHelper.isSubscriptionTriggerExecuted && !SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE)
                            SBQQ_SubscriptionTriggerHelper.updateMembershipStatusBySubscription(Trigger.New, Trigger.oldMap);
                        
                        //V_1.18 - Modofied - 06/08/2017 - Saurabh Kumar - CR-20170403-10807 (DS073.2)
                        SBQQ_SubscriptionTriggerHelper.updateOpportunityFields(Trigger.New, Trigger.oldMap);
                        
                        SBQQ_SubscriptionTriggerHelper.populateFieldsOnCaseFromSubscription(Trigger.New, Trigger.oldMap);
                        
                    }
                    
                    //Added By Deepak Kumawat - on 06/08/2017 to restrict Blank IBS if LIS is associated with Subscription.
                    SBQQ_SubscriptionTriggerHelper.validateIBSIdForProgramSubscription(Trigger.New, Trigger.oldMap);
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                        
                        //Added by - Saurabh Kumar - 07/21/2017
                        SBQQ_SubscriptionTriggerHelper.syncPreviousPeriodNegotiatedOnSubPeriod(Trigger.New, Trigger.oldMap);
                        
                    }
                    
                    //Calling a new Method on after update call 
                    SBQQ_SubscriptionTriggerHelper.updateContractABCRenewalOpportunity(Trigger.New, Trigger.oldMap);
                    
                    //Calling a new Method on After update to update the Subscription period Owner Manager Email Field 
                    SBQQ_SubscriptionTriggerHelper.populateOwnerManagerEmailToSubPeriod(Trigger.New, Trigger.oldMap);
                    
                }
                
                //V_1.15 - Modified - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 (DS114)
                //Set the flag
                SBQQ_SubscriptionTriggerHelper.isSubscriptionTriggerExecuted = true;
                
                //check for trigger event
                if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL) {
                        
                        SBQQ_SubscriptionTriggerHelper.calculateACVAndProfit(Trigger.New, Trigger.oldMap);
                        
                        SBQQ_SubscriptionTriggerHelper.populateProductCode(Trigger.New, Trigger.oldMap);
                        
                        //V_1.11 - Modified - 05/30/2017 - Subhash Garhwal  - CR-20170403-10807 
                        SBQQ_SubscriptionTriggerHelper.rollUpTotalPaidSubscription(Trigger.New, Trigger.oldMap);
                        
                    }
                    
                    //V_1.14 - Modified - 06/05/2017 - Saurabh Kumar - CR-20170403-10807 (DS104.1)
                    SBQQ_SubscriptionTriggerHelper.rollupNegotiatedAmountPeriodOnSubscriptionPeriod(Trigger.new, Trigger.oldMap);
                    
                    //V_4.5 - Modified BY - Mahendra Swarnkar - 12/06/2017 - CR-20171204-11830
                    //Added bypass logic for Adding Program Subscription to IBS process
                    if (!AddContractsToInvoiceBillingSchedule.bypassProcess) {
                        
                        //V_1.28 - Modified - 08/11/2017 - Subhash Garhwal - Issue--CR11094--UAT--00005349
                        if(!SBQQ_SubscriptionTriggerHelper.BYPASS_SUBSCRIPTION_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                            SBQQ_SubscriptionTriggerHelper.updateTravelandAnnualFeesonComponentSubscription(Trigger.New,Trigger.oldMap);
                        
                    }
                    
                    //Added by Subahsh Garhwal - 02/08/2018 - CR-20180131-11927
                    //Added check to avoid SOQL issue - CR-20180314-12107
                    if(!SBQQ_SubscriptionTriggerHelper.BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                        SBQQ_SubscriptionTriggerHelper.updateProposalvalue(Trigger.New,Trigger.oldMap);
                    
                    //Subhash Garhwal - 01/23/2019 - CR-20181019-12685 - Added a new call
                    SBQQ_SubscriptionTriggerHelper.syncTotalContractQuantity(Trigger.New,Trigger.oldMap);
                    
                    //Subhash Garhwal - 01/30/2019 - CR-20181019-12685 - Added a new Call
                    SBQQ_SubscriptionTriggerHelper.populatePreviousCurrentNextYearProgramCost(Trigger.New,Trigger.oldMap);
                    
                    //Subhash Garhwal - 02/22/2019 - CR-20181019-12685 - Added a new Call
                    SBQQ_SubscriptionTriggerHelper.rollupDetailsonProgramSubscriptionFromComponentSubscription(Trigger.new,Trigger.oldMap);
                    
                    //Subhash Garhwal - 02/12/2019 - CR-20181019-12685 - Added a new Call
                    SBQQ_SubscriptionTriggerHelper.rollupDetailsOnUltimateProgramSubscriptionFromDirectProgramSubs(Trigger.new,Trigger.oldMap);
                    
                    //Subhash Garhwal - 02/22/2019 - CR-20181019-12685 - Added a new Call
                    SBQQ_SubscriptionTriggerHelper.populateStdContractFields(Trigger.new,Trigger.oldMap);
                  
                    //Subhash Garhwal - 02/22/2019 - CR-20181019-12685 - Added a new Call
                    SBQQ_SubscriptionTriggerHelper.rollupCompSubToSubPeriod(Trigger.new,Trigger.oldMap);
                    
                    //check for trigger event
                    if(Trigger.isInsert)
                        
                        //Mahendra Swarnkar - 07/19/2019 - CR-20181019-12685 - Added a new Call
                        //Colin McGloin - 09/13/2019 - CR-20190829-13298 - Changed event logic so this is only called upon insert of the Amended record
                        SBQQ_SubscriptionTriggerHelper.populateGAAPFieldsOnAmendment(Trigger.new,Trigger.oldMap);
                    
                    
                }
                
                System.debug('LIMIT QUERIES---'+LIMITS.getQueries());
            }
        }
    //Catching DML Exception
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