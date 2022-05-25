/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for SBQQ__Quote__c object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   06/23/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
 *                      V_1.1 - Modified - Colin McGloin - 
 *                      V_1.2 - Mofified - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 - Added new Method autoPopulateEndDateOnQuotes
 *                      V_1.3 - Modified by - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - "updateContractLOAStage" method is commented because no longer use of the Pipeline logic
 *                      V_1.4 - Modified by - Subhash Garhwal - 06/06/2017 - CR-20170403-10807 - "autoPopulateFieldsOnProposal"
 *                      V_1.5 - Modified by - Subhash Garhwal - 06/16/2017 - CR-20170403-10807 - "rollUpAnnualizedOpportunityValueonOpportunity"
 *                      V_1.6 - Modified by - Subhash Garhwal - 07/03/2017 - Issue--CR10810--QA--00004844  "updateOpportunityStatus"
 *                      V_1.7 - Modified by - Victor Hanson - 09/18/2017 - Issue--CR11183--QA--00005822 - Removed "validateOpportunityProducts" method because 
                                                                        Rollup_Products_to_Opportunity dlrs is working for the requirement.
                        V_1.8 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
                        //Merged by Dipesh Gupta for CR-20170926-11418 overlapping
                        V_1.9 - Added bypass flags to avoid SOQL issue during opportunity merge (BYPASSPROPOSALTRIGGERFORMERGE)
                        V_1.10 - Modified By - Subhash Garhwal - 01/31/2018 - CR-20180126-11917 - New Method call - markFirstProposalAsPrimary
                        V_1.11 - Modified By Subhsh Garhwal - CR-20180126-11911 - 02/02/2018 - New Method is Called populateIntegratedAccounts
                        V_1.12 - Modified by - Subhash Garhwal - 02/08/2018 - CR-20180126-11904 - Added a new call updateFirstYearFeesForRenewalOpp
                        V_2.1 -  Modified by - Subhash Garhwal - 03/27/2018 - Added checks to avoid SOQL issue for Renewal Proposal (ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL check)
                        V_2.2 - Modified BY - Subhash Garhwal - CR-20180205-11952 - 03/19/2018 - New Method Called - preventPrimaryCheckUpdate  
                        V_2.3 - Modified By - Victor Hanson - CR-20180205-11956 - 05/24/2018 - New Method Called - recalculatePriceRules
                        V_2.4 - Modified By - Subhash Garhwal - CR-20180205-12018 - 07/16/2018 - Added a new call - updateLOANonStandardClauses
                        V_2.5 - Modified By - Victor Hanson - 12/11/2018 - added reference to Sched_calculatorPDFSync
			V_2.6 - Modified By - Subhash Garhwal - CR-20210521-15175
**/
trigger SBQQ_QuoteTrigger on SBQQ__Quote__c (before insert, before update, after insert, after update, before delete, after delete) {
    
     /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - start here*/
    	
    //Added by Mahendra Swarnkar - 05/19/2020 - CR-20200508-14032
    if(SubscriptionAdjustmentHelper.hasExecutedSubAdjustment){
        SubscriptionAdjustmentHelper.ByPassOpportunityTriggerOnUpsells = true;
    }
      // Added Check to Bypass the trigger if creating the upsells By Mahendra Swarnkar - 05/11/2020 - CR-20200508-14032
      //Bypass flag 
      //return immediately if method returns true  
      if(SubscriptionAdjustmentHelper.hasExecutedSubAdjustment || Util.areTriggersOnThisObjectBypassed('SBQQ__Quote__c') ) return;  
        
      /*Merged by Dipesh Gupta for CR-20170926-11418 overlapping - ends  here*/
    
    try {
        
        //Check for the Trigger is Insert or Update  
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
             
            //Subhash Garhwal - 02/05/2020 - CR-20200204-13688
            SBQQ_QuoteTriggerHelper.populateStatusOnProposal(Trigger.new, Trigger.oldMap);
            
            //Subhash Garhwal - 03/030/2020 - 
            SBQQ_QuoteTriggerHelper.validateStatusOnProposal(Trigger.new, Trigger.oldMap);
        }
        
        //Bypass flag 
        //Subhash Garhwal - 09/18/2017 - Bypass the trigger in case of the Renewal forcast
        if(Util.BypassAllTriggers || ContractTriggerHelper.BYPASS_PROPOSAL_AND_LINES_TRIGGER) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Subhash Garhwal - 05/15/2019
                //Call helper class method
                //SBQQ_QuoteTriggerHelper.validateLargeDeals(Trigger.new);
                
                //Subhash Garhwal - 05/15/2019
                //check for errors on QuoteLine, outside of the try/catch
                //SBQQ_QuoteTriggerHelper.checkErrorsOnQuote(Trigger.new);
                
		//Modified By - Subhash Garhwal - CR-20210521-15175
                SBQQ_QuoteTriggerHelper.populateIActiveSTRCO(Trigger.new, Trigger.OldMap);
                
            }
            if(Trigger.isInsert) { 
                
                //Added By Subhash Garhwal - 06/06/2017 - Populate Subscription term and Proposal version
                SBQQ_QuoteTriggerHelper.autoPopulateFieldsOnProposal(Trigger.new);
                
                //Populate Proposal Version field
                SBQQ_QuoteTriggerHelper.updateProposalVersion(Trigger.new, Trigger.OldMap);

                //Added By Subhsah Garhwal -05/11/2017 -Populate proposal end date
                SBQQ_QuoteTriggerHelper.autoPopulateEndDateOnQuotes(Trigger.new);
                
                //Added By Subhash Garhwal - 01/31/2018.
                SBQQ_QuoteTriggerHelper.markFirstProposalAsPrimary(Trigger.new);
                
                //Added By Subhash Garhwal - 08/26/2019.
                SBQQ_QuoteTriggerHelper.populateStandardPriceBookOnProposal(Trigger.new);
                
                //Added By Subhash Garhwal - 03/05/2020 - CR-20200210-13716.
                SBQQ_QuoteTriggerHelper.populateAmendedProposalFieldsFromOriginalProposal(Trigger.new);
            }

            if(Trigger.isUpdate) {

                //Populate Proposal Version field
                SBQQ_QuoteTriggerHelper.updateProposalVersion(Trigger.new, Trigger.OldMap);
                
                SBQQ_QuoteTriggerHelper.populateGradingCriteriaForContractedProposal(Trigger.new, Trigger.OldMap);

                //Call Helper Class method 
                //Added by Subhash Garhwal
                SBQQ_QuoteTriggerHelper.autoPopulateFieldOnQuotes(Trigger.new, Trigger.OldMap);

                //Added By Subhsah Garhwal -05/11/2017 -Populate proposal end date
                //SBQQ_QuoteTriggerHelper.autoPopulateEndDateOnQuotes(Trigger.new);
                
                //helper class method - 06/09/2017
                SBQQ_QuoteTriggerHelper.checkDocumentStatus(Trigger.new, Trigger.OldMap);
                
                //Added by Victor Hanson - 07/13/2017
                SpringCMHelper.attachComparedLOA(Trigger.new, Trigger.oldMap);
                
                //Added by Victor Hanson - 05/24/2018
                SBQQ_QuoteTriggerHelper.recalculatePriceRules(Trigger.new, Trigger.OldMap);
                
                //Call helper class method to populate Contract_Document_Creation_Date on proposal.
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                    SBQQ_QuoteTriggerHelper.populateContractDocumentCreationDate(Trigger.new,Trigger.OldMap);
                
                //VH 12/13/2019
                SBQQ_QuoteTriggerHelper.populateInvoicingArrangement(Trigger.newMap, Trigger.oldMap);
                
            }
            
            //Check for the Trigger is Insert or Update  
            if(Trigger.isInsert || Trigger.isUpdate) {
                //Added By Subhsh Garhwal - CR-20180126-11911 - 02/02/2018 
                //Calling a method On the Before Insert and update case
                SBQQ_QuoteTriggerHelper.populateIntegratedAccounts(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 07/16/2018 - CR-20180205-12018
                SBQQ_QuoteTriggerHelper.updateLOANonStandardClauses(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 02/05/2020 - CR-20200204-13688
                //SBQQ_QuoteTriggerHelper.populateStatusOnProposal(Trigger.new, Trigger.oldMap);
            }
            //Check for trigger event
            if(Trigger.isDelete) {
                
                //Call helper class method
                //VH 4/12/17: Commented out because we no longer use program opportunities
                //SBQQ_QuoteTriggerHelper.populateSetProgramOpportunitiesId(Trigger.old); 

                //Prevent Proposals from being deleted by users who do not have the Custom Permission "CPQ Proposal - Delete Permission"
                SBQQ_QuoteTriggerHelper.preventProposalDeletion(Trigger.oldMap);
            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            //Check for trigger event
            if(Trigger.isInsert || Trigger.isUpdate) {
                SBQQ_QuoteTriggerHelper.populateProgramPackageFields(Trigger.new, Trigger.oldMap);
				
                //Subhash Garhwal - 02/05/2020 - CR-20200204-13688
                SBQQ_QuoteTriggerHelper.populateAmendmentTypeOnContract(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isInsert) {
                
                //V_1.3 - Modified by - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - "updateContractLOAStage" method is commented because no longer use of the Pipeline logic
                //Call helper class method to update contract LOA stage to piepline
                //if(SBQQ_QuoteTriggerHelper.executeUpdateContractLOAStageLogic)
                    //SBQQ_QuoteTriggerHelper.updateContractLOAStage(Trigger.new);

                //Roll up first year fees to the Opportunity
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                  SBQQ_QuoteTriggerHelper.rollUpFirstYearFees(Trigger.new, Trigger.oldMap);
                
                //Added By MAhendra Swarnkar - CR-20190911-13329 - 09/25/2019.
                SBQQ_QuoteTriggerHelper.populateMSADetailsFromInstitution(Trigger.new);

            }
            
            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Call Helper class method to sync Quote Lines with Program Opportunities
                //VH 4/12/17: Commented out because we no longer use program opportunities
                //SBQQ_QuoteTriggerHelper.syncProgramOpportunities(Trigger.new, Trigger.oldMap);

                //Roll up first year fees to the Opportunity
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.rollUpFirstYearFees(Trigger.new, Trigger.oldMap);

                //Call Helper Class
                //Added by Subhash Garhwal
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.createContentDocument(Trigger.new, Trigger.oldMap);
                
                //VH Added 6/15/17 - CR-10808
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.sendSignedLOAToOwner(Trigger.new, Trigger.oldMap);

                //V_1.6 - Modified by - Subhash Garhwal - 07/03/2017
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.updateOpportunityStatus(Trigger.new, Trigger.oldMap); 
                
                //Modified BY - Subhash Garhwal - CR-20180205-11952 - 03/19/2018 - New Method Called - preventPrimaryCheckUpdate 
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.preventPrimaryCheckUpdate(Trigger.new, Trigger.oldMap);
                
                //To update the Account MSA-Date field.
                //Added by Subhash Garhwal
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.populateAccountMSADate(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {  
                
                //Call helper class method
                //VH 4/12/17: Commented out because we no longer use program opportunities
                //SBQQ_QuoteTriggerHelper.validateProgramOpportunities(); 

                //Roll up first year fees to the Opportunity
                SBQQ_QuoteTriggerHelper.rollUpFirstYearFees(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 02/08/2018 - CR-20180126-11904 - Added a new call updateFirstYearFeesForRenewalOpp
                SBQQ_QuoteTriggerHelper.updateFirstYearFeesForRenewalOpp(Trigger.old);
            }

            //Check for Trigger event
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
                
                /* V1.2  Modified By - Rajeev Jain - 18/02/2020 - CR-20200110-13605 -  Remove zzzFirst Year Credit(Annualized_Contract_Value__c) field on opportunity object
                We have comment this method as this method is used to calucualte total of Annualized_Contract_Value__c on Opportunity from primary proposal Annualized_Contract_Value__c 
                and Annualized_Contract_Value__c  field is deleted from opportunity.
                //Call Helper class
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                  SBQQ_QuoteTriggerHelper.rollUpAnnualizedContractValueonOpportunity(Trigger.new, Trigger.oldMap);
                  */
                
                //Call Helper class method
                //Subhash Garhwal - 08/01/2017
                //Victor Hanson - 09/18/2017 - Commented out per Issue--CR11183--QA--00005822
                //SBQQ_QuoteTriggerHelper.validateOpportunityProducts(Trigger.new, Trigger.oldMap);
            }
                

            //Check for Trigger event
            if(Trigger.isInsert || Trigger.isUpdate ) {
              
                if(!SBQQ_QuoteTriggerHelper.BYPASSPROPOSALTRIGGERFORMERGE)
                    SBQQ_QuoteTriggerHelper.updateOpportunityPrimaryProposal(Trigger.new,Trigger.oldMap);
              
                //VH added 12/11/2018
                Sched_CalculatorPDFSync.checkForSync(Trigger.new, Trigger.oldMap);
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