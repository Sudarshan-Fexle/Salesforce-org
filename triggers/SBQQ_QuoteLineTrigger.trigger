/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__QuoteLine__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/22/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Subhash Garhwal - 08/10/2016 - CR-20160414-9762 - Added a new call "validateQuoteYearOneDiscount"
 *                      V_1.2 - Modified - Subhash Garhwal - 08/19/2016 - CR-20160414-9762 - Added a new call "updateStandardPricing"
 *                      V_1.3 - Modified - Subhash Garhwal - 06/15/2017  - CR-20170403-10807 Added a new call "updateThresholdValueOnOpportunity"
 *                      V_1.4 - Modified - Subhash Garhwal - 07/06/2017  - CR-20170403-10807 Added a new call "rollUpCreditAndProfitAdjustment"
 *                      V_1.5 - Modified - Subhash Garhwal - 07/08/2017  - Added a new call "validateAmendProposalLines"
 *                  	V_1.6 - Modified - Subhash Garhwal - 08/11/2017 - Added "blankOptOutAndEarlyTerminationDateOnMainProposalLine" call (Issue--CR11094--QA--00005437)
 *                  	V_1.7 - Modified - Subhash Garhwal - 08/18/2017 - Added "syncPHCustomerTotal" call (Issue--CR11141--QA--00005513)
 *                  	V_1.8 - Modified - Saurabh Kumar - 08/19/2017 - Issue--CR10808--QA--00005213 - Removed "validateOpportunityProducts" method because 
 *                                                                      Rollup_Products_to_Opportunity dlrs is working for the requirement.
 *                  	V_1.9 - Modified - Victor Hanson - 08/30/2017 - Issue--CR11094--UAT--00005444 - Added a new call "checkForRenewalSubscription"
 *                  	V_2.0 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                  	V_2.1 - Modified By - Subhash Garhwal - 03/27/2018 - Added checks to avoid SOQL issue
 *                  	V_2.2 - Modified By - Subhash Garhwal - 05/01/2018 - CR-20180425-12183 - Call method "checkForRenewalSubscription" before "validateAmendProposalLines"
 *                  	V_2.3 - Modifies By - Subhash Garhawal - 09/25/2018 - CR-20180607-12270 - Added 'updateProSubscriptionStatusForAmendment'
 *           		V_2.4 - Modified By - Victor Hanson - 01/10/2019 - CR-20181019-12685 - Added 'checkRenewalInitialPrice'
 *           		V_2.5 - Modified By - Subhash Garhwal - 01/11/2019 - CR-20181019-12685 - Added 'syncupProgramPackages'
 *           		V_2.6 - Modified By - Victor Hanson - 08/07/2019 - CR-20181019-12685 - Added 'populateQuoteLineFieldsForCPQ'
 *           		V_2.7 - Modified By - Victor Hanson - 09/12/2019 - CR-20190912-13336 - Added 'updateProrateMultiplier' to resolve an ES Proration bug
 * 			V_2.8 - Modified By - Victor Hanson - 12/13/2019 - CR-20191030-13484 - Added 'populateInvoicingArrangement'
 *			V_2.9 - Modified By - Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - Changed from before to after and added Trigger.oldMap
 *			V_3.0 - Modified By - Mahendra Swarnkar - 11/25/2020 - CR-20201105-14668
 *			V_3.1 - Modified By - Mahendra Swarnkar - 11/04/2020 - CR-20200611-14175 - 2-New product - Degree Rules Integration BHDR
 *			V_3.2 - Modified By - Subhash Garhwal - CR-20210504-15122 - 04/05/2021 - to execute twinFields method in insert use case only.
 *			V_3.3 - Modified By - Mahendra Swarnkar - CR-20210727-15318 - 07/28/2021
 *			V_3.4 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - invocation placement for the SBQQ_QuoteLineTriggerHelper.populateInvoicingArrangement method
 **/
trigger SBQQ_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, before delete,after insert, after update, after delete) {
    
    // Added Check to Bypass the trigger when creating the upsells - By Mahendra Swarnkar - 11/25/2020 - CR-20201105-14668
    //return immediately if method returns true  
    if(SubscriptionAdjustmentHelper.hasExecutedSubAdjustment || Util.areTriggersOnThisObjectBypassed('SBQQ__QuoteLine__c')) return;  

    try {
        
        //Added By Mahendra Swarnkar - on 01/07/2020 - added this check to by pass the trigger in case of renewal forcast  - CR-20200116-13628
        //Subhash Garhwal - 09/18/2017 - Bypass the trigger in case of the Renewal forcast
        if(ContractTriggerHelper.BYPASS_PROPOSAL_AND_LINES_TRIGGER) return;
        
        //Added By Mahendra Swarnkar - CR-20200116-13628 - Start from here
        if(Trigger.isBefore && Trigger.isInsert){
            
            SBQQ_QuoteLineTriggerHelper.validateRenewalProposal(Trigger.new);
        }
        //Added By Mahendra Swarnkar - CR-20200116-13628 - Ends here
        
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        	
            //Added check to by pass the insert case triggers when running from scheduler By Mahendra Swarnkar - CR-20200116-13628 
            if(!SBQQ_QuoteLineTriggerHelper.RENEWAL_PROPOSALLINE_FROM_SCHEDULER ){
            	
                
               //Modified By Subhash to execute twinFields method in insert use case only. - CR-20210504-15122 - 04/05/2021
                if(Trigger.isInsert){
                    //VH - 03/18/2019 - custom twin field functionality
                    SBQQ_SubscriptionTriggerHelper.twinFields(Trigger.new);    
                }
                SBQQ_QuoteLineTriggerHelper.populateStartDateOnImplementationFee(Trigger.new, Trigger.oldMap); 
                
                //VH added 4/23/2019 - auto-populates config attributes on amendment proposal lines
                SBQQ_QuoteLineTriggerHelper.populateESLinesOnAmendment(Trigger.new);
                
                //VH added 08/07/2019 - Auto-populates listPrice and specialPrice fields on QuoteLine
                SBQQ_QuoteLineTriggerHelper.populateQuoteLineFieldsForCPQ(Trigger.new);
                
                //VH test 09/12/2019 - CR-20190912-13336
                SBQQ_QuoteLineTriggerHelper.updateProrateMultiplier(Trigger.new);
                
                //Method Call - Mahendra Swarnkar - 10/03/2019 - CR-20190911-13329
                SBQQ_QuoteLineTriggerHelper.populatePreviousContractLastYearQuantity(Trigger.new);
                
                //Method Call - Mahendra Swarnkar - 10/01/2019 - CR-20190911-13329
                SBQQ_QuoteLineTriggerHelper.updateFieldsForMainProductLines(Trigger.new);
                
		// Modified By - Mahendra Swarnkar - 11/04/2020 - CR-20200611-14175
                SBQQ_QuoteLineTriggerHelper.validateBHDRonProposal(Trigger.New, Trigger.oldMap);
            }
        }
        
        //Commented By Mahendra Swarnkar - on 01/07/2020 - moved this check in upper side in the trigger - CR-20200116-13628
        //Subhash Garhwal - 09/18/2017 - Bypass the trigger in case of the Renewal forcast
        //if(ContractTriggerHelper.BYPASS_PROPOSAL_AND_LINES_TRIGGER) return;
        
        
        //NOTE: DO NOT ADD ANY OTHER CALL HERE.
        //Subhash Garhwal - Issue--CR11141--QA--00005513 - Added trigger logic before Util.BypassAllTriggers check b/c this method is only
        //Syncing the Place Holder Customer Total value with Customer Total field. This will not impact any other process.
        //Check for trigger logic
        //Added check to by pass the insert case triggers when running from scheduler By Mahendra Swarnkar - CR-20200116-13628
        ////Updated by Subhash Garhwal - 04/16/2020 - CR-20200409-13923 - Changed from before to after and added Trigger.oldMap -  Start here
        
        if(Util.BypassAllTriggers) return;
		
		if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) 
           && (!SBQQ_QuoteLineTriggerHelper.RENEWAL_PROPOSALLINE_FROM_SCHEDULER ))
            SBQQ_QuoteLineTriggerHelper.syncPHCustomerTotal(Trigger.new, Trigger.oldMap);
                  
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Added check to by pass the insert case triggers when running from scheduler By Mahendra Swarnkar - CR-20200116-13628
            if(!SBQQ_QuoteLineTriggerHelper.RENEWAL_PROPOSALLINE_FROM_SCHEDULER){
             	
                //Check for trigger event
                if(Trigger.isUpdate) {
                    
                    //Victor Hanson - 08/30/2017 - Issue--CR11094--UAT--00005444
                    //Subhash Garhwal - CR-20180425-12183 - Call method "checkForRenewalSubscription" before "validateAmendProposalLines"
                    SBQQ_QuoteLineTriggerHelper.checkForRenewalSubscription(Trigger.new);
                }
                
                //Check for event
                if(Trigger.isInsert || Trigger.isUpdate) {
                
                    //Subhash Garhwal - 08/11/2017 - Issue--CR11094--QA--00005437
                    SBQQ_QuoteLineTriggerHelper.blankOptOutAndEarlyTerminationDateOnMainProposalLine(Trigger.new, Trigger.isInsert);
                    
                    //Mahendra Swarnakar - 11/04/2020 - Call helper class method - CR-20200611-14175
                    SBQQ_QuoteLineTriggerHelper.validateBHDRonProposal(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 05/10/2017
                    //Call helper class method
                    //SBQQ_QuoteLineTriggerHelper.validateLargeDeals(Trigger.new, Trigger.oldMap);
                    //check for errors on QuoteLine, outside of the try/catch
                    //SBQQ_QuoteLineTriggerHelper.checkErrorsOnQuoteLine(Trigger.new, Trigger.oldMap);
                    
                    //Call helper class method
                    SBQQ_QuoteLineTriggerHelper.updateStandardPricing(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 05/11/2017
                    if(!SBQQ_QuoteLineTriggerHelper.BYPASS_SORT_ORDER_METHOD)
                        SBQQ_QuoteLineTriggerHelper.syncSortOrder(Trigger.new);
                    
                    //Victor Hanson - 07/03/2017
                    SBQQ_QuoteLineTriggerHelper.updateSegmentLabel(Trigger.new);
                    
                    //Victor Hanson - 07/03/2017
                    if(!SBQQ_QuoteLineTriggerHelper.BYPASS_UPDATEPREVIOUSSEGMENTPRICE)
                        SBQQ_QuoteLineTriggerHelper.updatePreviousSegmentPrice(Trigger.new);
                    
                    if(!SBQQ_QuoteLineTriggerHelper.BYPASS_POPULATEAMENDPROPOSALLINESLISTPRICE)
                        SBQQ_QuoteLineTriggerHelper.populateAmendProposalLinesListPrice(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
                    
                    SBQQ_QuoteLineTriggerHelper.updateQuantityOnAmendmentQuoteLines(Trigger.new);
                    
                    //Victor Hanson - 08/15/2017
                    SBQQ_QuoteLineTriggerHelper.checkRenewalsForRoundingBug(Trigger.new, Trigger.oldMap);
                    
                    //Victor Hanson - 01/04/2019
                    SBQQ_QuoteLineTriggerHelper.updateQuantity(Trigger.new);
                    
                    //Victor Hanson - 01/10/2019
                    //SBQQ_QuoteLineTriggerHelper.checkRenewalInitialPrice(Trigger.new, Trigger.oldMap);
                    
                    //Method Call - Mahendra Swarnkar - 05/13/2019 - CR-20190306-12914
                    SBQQ_QuoteLineTriggerHelper.populateSpecialPriceType(Trigger.new, Trigger.oldMap);
                }
                
                //Check for trigger event
                if(Trigger.isUpdate) {
                    
                    
                    //Victor Hanson - 08/30/2017 - Issue--CR11094--UAT--00005444
                    //Subhash Garhwal - CR-20180425-12183 - Call method "checkForRenewalSubscription" before "validateAmendProposalLines"
                    SBQQ_QuoteLineTriggerHelper.checkForRenewalSubscription(Trigger.new);
                }
            }
            
            //Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - invocation placement for the following method SBQQ_QuoteLineTriggerHelper.populateInvoicingArrangement
            if (Trigger.isInsert || Trigger.isUpdate) {
                
                //if(!SBQQ_QuoteLineTriggerHelper.BYPASS_populateInvoicingArrangement) 
                //VH 12/13/2019 - CR-20191030-13484
                SBQQ_QuoteLineTriggerHelper.populateInvoicingArrangement(Trigger.new, Trigger.oldMap);
            }
        }
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Added check to by pass the insert case triggers when running from scheduler By Mahendra Swarnkar - CR-20200116-13628
            if(!SBQQ_QuoteLineTriggerHelper.RENEWAL_PROPOSALLINE_FROM_SCHEDULER) {
                
                //Check for trigger event
                if(Trigger.isInsert) {
                    
                    SBQQ_QuoteLineTriggerHelper.updateThresholdValueOnOpportunity(Trigger.new);
                    
                    if(!SBQQ_QuoteLineTriggerHelper.BYPASS_AutomatedProductCreation_METHOD){
                        //Subhash Garhwal - 11/07/2019
                        SBQQ_QuoteLineTriggerHelper.validateAutomatedProductCreationProcess(Trigger.new);
                    }
                    //Added by Subhash Garhwal - CR-20200210-13716
                    SBQQ_QuoteLineTriggerHelper.populateCSVFieldsOnMainProposalLines(Trigger.new, Trigger.oldMap);
                    
                }
                    
                //Check for trigger event
                if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                    
                    //Turn off DupeBlocker since it is not needed here to save some SOQL queries
                    Util.disableDupeBlocker(true);
                    
                    //Subhash Garhwal 7/6/2017 - Added a new call
                    SBQQ_QuoteLineTriggerHelper.rollUpCreditAndProfitAdjustment(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 08/10/2016 - CR-20160414-9762
                    //Call Helper class method to validate quote 1st year discount
                    if(SBQQ_QuoteLineTriggerHelper.executeSyncProgramOpportunitiesLogic)
                        SBQQ_QuoteLineTriggerHelper.validateQuoteYearOneDiscount(Trigger.new, Trigger.oldMap);
                    
                    //Mahendra Swarnkar - 07/22/2019 - Call helper class method
                    SBQQ_QuoteLineTriggerHelper.validateGradeCriteriaCommittedTermLength(Trigger.new, Trigger.oldMap);
                     
                }
          
                //Check for trigger event
                if(Trigger.isInsert || Trigger.isUpdate) {
                    
                    //Added By Mahendra Swarnkar - CR-20210727-15318 - 07/28/2021
                    SBQQ_QuoteLineTriggerHelper.populateInstanceNameOnLines(Trigger.New, Trigger.oldMap);
                    
                    //Added by Mahendra Swarnkar - 10/16/2019 - CR-20190911-13329
                    //SBQQ_QuoteLineTriggerHelper.populatePrevContractLastYearTotalQuantityAndValue(Trigger.new);
                    
                    //Update the Top Parent Product
                    SBQQ_QuoteLineTriggerHelper.populateTopParentOnQuoteLines(Trigger.new);
                    
                    //Subhash Garhwal - 05/24/2019 - Call helper class method
                    SBQQ_QuoteLineTriggerHelper.ValidateESAMAndESOAMProducts(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 08/11/2017 - Call helper class method to update Opt Out
                    SBQQ_QuoteLineTriggerHelper.updateOptOutOnMainProposalLine(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhawal 09/25/2018 - CR-20180607-12270
                    //SBQQ_QuoteLineTriggerHelper.updateProSubscriptionStatusForAmendment(Trigger.new, Trigger.oldMap);
                    
                    //Subhash Garhwal - 01/11/2019 - CR-20181019-12685
                    SBQQ_QuoteLineTriggerHelper.syncupProgramPackages(Trigger.new, Trigger.oldMap);
                    
                    //Method Call - Mahendra Swarnkar - 10/01/2019 - 
                    //SBQQ_QuoteLineTriggerHelper.updateFieldsForMainProductLines(Trigger.new);
                }
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