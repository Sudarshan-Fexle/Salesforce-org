/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Subscription_Period__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   05/24/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal -CR-20170403-10807
 *            		V_1.1 - Modified by - Saurabh Kumar - 08/11/2017 - Issue--CR11094--UAT--00005392 - A new call is added "populateSubscriptionPeriodFields"
 *            		V_1.2 - Modified - Subhash Garhwal - 09/02/2017 - Issue--CR11062--QA--00005609 - 1. Commented out updateNegotiatedAmountPeriod call
 *                                                                                             2. Added a new call updatePendingSPNegotiatedAmountPeriod
 *            		V_1.3 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *            		V_1.4 - Modified By - Subhash Garhwal - 02/09/2018 - CR-20180207-12036 - call a new Method - populateNegotiatedAmountFutureSubPeriod
 *	      		V_1.5 - Modified By - Subhash Garhwal - 02/28/2018 -CR-20180228-12087 - Call a method - syncPreviousPeriodNegotiated
 *	      		V_1.6 - Modified By - Subhash Garhwal - 03/19/2018 -CR-20180314-12107 - Add check to avoid SOQL Issue
 *	      		V_1.7 - Modified By - Subhash Garhwal - 03/29/2018 - Issue--CR12039--QA--00007920 - Call a method populateMembershiplookup
 *	      		V_1.8 - Modified By - Subhash Garhwal - 05/24/2018 - CR-20180502-12199 - Call a method populateRenewalOwnerOnSubAndOwnerOnMembership
 *	     		V_1.9 - Modified By - Subhash Garhwal - 08/08/2018 - CR-20180417-12162 - added 'populateCloseDateOnSP' method to populate 'Close_Date__c' field on 'Subscription Period' when stage is updating from 'Opt out' to 'ATL'
 *            		V_2.0 - Modified By - Abhinav Sharma - 10/17/2018 - new method Called - syncSMERequestWithSPeriod  
 * 	      		V_2.1 - Modified By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - update method calculateNextDecisionDate calling to pass old map as well
 * 	      		V_2.2 - Modified By - Subhash Garhwal - 12/27/2018 - CR-20181019-12685 - invoked the method populateEngagementStatusOnProgramPackage on after update event
 * 	      		V_2.3 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
 *			V_2.4 - Modified By - Mahendra Swarnkar - CR-20200715-14321 - 09/07/2020
 *			V_2.5 - Modified By - Mahendra Swarnkar - CR-20210408-15069 - 04/09/2021
 * 			V_2.6 - Modified By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
 **/
trigger Trigger_SubscriptionPeriod on Subscription_Period__c (before insert, before update, after insert, after update, after delete) {
    
   //return immediately if method returns true  
   if(Util.areTriggersOnThisObjectBypassed('Subscription_Period__c')) return;  

   try {

        //Call Helper class method
        //Note: Do not add any method call here. 
        if(Trigger.isBefore && (Trigger.isInsert && !Util.BypassAllTriggers) || (Trigger.isUpdate && CPQConstants.SUBSCRIPTION_PERIOD_TRIGGER_INSERT_CASE))
            SubscriptionPeriodTriggerHelper.populateSubscriptionPeriodFields(Trigger.new, Trigger.oldMap);
                
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {

            //Check for trigger event
            if(Trigger.isInsert) {
                
                //Subhash Garhwal - 09/02/2017 - Issue--CR11062--QA--00005609 - Comment out the call
                //SubscriptionPeriodTriggerHelper.updateNegotiatedAmountPeriod(Trigger.new);
            }
           
            //Check for trigger update event
            if(Trigger.isUpdate)
            
                //Subhash Garhwal - 08/08/2018 - CR-20180417-12162
                SubscriptionPeriodTriggerHelper.populateCloseDateOnSP(Trigger.new, Trigger.oldMap);
            
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                SubscriptionPeriodTriggerHelper.updateFutureSubscriptionPeriod(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 06/01/2017 - Call helper class method
                SubscriptionPeriodTriggerHelper.populateRenewalYearHalfOnSubPeriod(Trigger.new, Trigger.oldMap);

                //V_1.6 - Subhash Garhwal - 03/29/2018 - Call a helper method
                SubscriptionPeriodTriggerHelper.populateMembershipLookup(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 06/5/2020 - Call a helper method
                SubscriptionPeriodTriggerHelper.populateAutorenewAndDate(Trigger.new, Trigger.oldMap);
                
                //V_1.21 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
                SubscriptionPeriodTriggerHelper.populateCTFieldsOnSubsciptionPeriod(Trigger.new, Trigger.oldMap, Trigger.isBefore);

            }

        }
        //Checking for trigger contex
        if(Trigger.isAfter){
            
            //Check for event
            if(Trigger.isInsert) {
                
                //Subhash Garhwal - 6/29/2017 - Call helper class method
                //Modified by Subhash Garhwal - 09/03/2019 - Code is shifted to insert and update case as we have reparenting in Renewal case. 
                //SubscriptionPeriodTriggerHelper.updateDecisionType(Trigger.new);
                
                //Call helper class method
                SubscriptionPeriodTriggerHelper.populateNegotiatedAmountPeriodForRenewalSubPeriod(Trigger.new);
            }
            
            //Check for event
            if(Trigger.isUpdate) {
                //Subhash Garhwal - 02/09/2018 - Add a new Call
                SubscriptionPeriodTriggerHelper.populateNegotiatedAmountFutureSubPeriod(trigger.new, trigger.oldMap);

                //V_1.4 - Modified By - Subhash Garhwal - 02/28/2018 -CR-20180228-12087 - Call a method - syncPreviousPeriodNegotiated
                SubscriptionPeriodTriggerHelper.syncPreviousPeriodNegotiated(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - -05/24/2018 - Add a new Call - CR-20180502-12199
                SubscriptionPeriodTriggerHelper.populateRenewalOwnerOnSubAndOwnerOnMembership(Trigger.newMap, trigger.oldMap);
                
                //Added by Abhinav sharma - CR-20181016-12674
                SubscriptionPeriodTriggerHelper.syncSMERequestWithSPeriod(Trigger.new, trigger.oldmap);
                
                //Added By - Subhash Garhawal - CR-20181019-12685 - 12/27/2018
                //Method call to update the engagement status on Program Package
                SubscriptionPeriodTriggerHelper.populateEngagementStatusOnProgramPackage(Trigger.new, trigger.oldmap);
                
                //V_1.21 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
                SubscriptionPeriodTriggerHelper.populateCTFieldsOnSubsciptionPeriod(Trigger.new, Trigger.oldMap, Trigger.isBefore);
                
                //Commented by Mahendra Swarnkar - CR-20210408-15069 - 04/09/2021
                //Added By - Mahendra Swarnkar - CR-20200715-14321 - 09/07/2020 
                //SubscriptionPeriodTriggerHelper.populateTypeOnBSP(Trigger.new, Trigger.oldMap);
                
                //Added By - Shalu Sharma - 06/17/2021 - CR-20200924-14551 - Create Project/JT when Sub Period Stage changes
                SubscriptionPeriodTriggerHelper.callBatchAutomatedProjectAndRelated(Trigger.new, Trigger.oldMap);
            }
            //Checking for triggger event
            if(Trigger.isInsert || Trigger.isUpdate){
                
                //call helper class method
                SubscriptionPeriodTriggerHelper.validateCompSubscriptions(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 06/01/2017 - Call helper class method
                if(!SubscriptionPeriodTriggerHelper.BYPASSPOPULATEPREVIOUSYEARSUBSCRIPTIONPERIOD)
                    SubscriptionPeriodTriggerHelper.populatePreviousYearSubscriptionPeriod(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 06/04/2017 - Call helper class method
                SubscriptionPeriodTriggerHelper.populateNextYearRenewal(Trigger.new, Trigger.oldMap);
                
                //Calling helper class method to populate Previous Subscription Period/Previous Contract ABC on the Subscription Period and Previous Subscription/Previous Contract on the Program Subscription
                //SubscriptionPeriodTriggerHelper.populatePreviousSubscriptionOrPreviousContractABC(Trigger.new, Trigger.oldMap);

                //Subhash Garhwal - 6/6/2017
                SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(Trigger.new, Trigger.oldMap);

                //Subhash Garhwal - 09/03/2019
                SubscriptionPeriodTriggerHelper.updateDecisionType(Trigger.new, Trigger.oldMap);
                
                //Modified to pass old map - 12/03/2018 - Subhash Garhwal - CR-20180726-12469
                //Victor Hanson - 8/17/2017 - Issue--CR11106--QA--00005464
                SubscriptionPeriodTriggerHelper.calculateNextDecisionDate(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 9/2/2017 - Added a new call
                SubscriptionPeriodTriggerHelper.updatePendingSPNegotiatedAmountPeriod(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - -2/06/2018 - Add a new Call
                SubscriptionPeriodTriggerHelper.populateCTManagerEmail(trigger.new, trigger.oldMap);
                
                //Subhash Garhwal - 12/27/2018 - CR-20181019-12685 - Added a new Call
                SubscriptionPeriodTriggerHelper.populateProgramPackageRollUpFields(Trigger.new, Trigger.oldMap);
            }
            
            //Check for triggger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
                
                //Subhash Garhwal - 01/30/2019 - CR-20181019-12685 - Added a new Call
                SubscriptionPeriodTriggerHelper.populatePreviousCurrentNextYearProgramCost(trigger.new, trigger.oldMap); 
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