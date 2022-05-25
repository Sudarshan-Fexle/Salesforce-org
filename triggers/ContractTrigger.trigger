/**
 *  Purpose         :   This trigger is to handle all the pre and post processing operations for Contract object
 *
 *  Create By       :   Subhash Garhwal
 *
 *  Created Date    :   07/01/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified By - Subhash Garhwal - 04/28/2017 - CR-20170403-10807 - Added a new method
 *                      V_1.2 - Modified By - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 - Added a new method
 *                      V_1.3 - Modified By - Subhash Garhwal - 05/15/2017 - CR-20170403-10807 - Added a new method
 *                      V_1.4 - Modified By - Saurabh Kumar - 05/18/2017 - CR-20170403-10807 - Added a new method
 *                      V_1.5 - Modified By - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - Added a new method
 *                      V_1.6 - Modified By - Saurabh Kumar - 05/25/2017 - CR-20170403-10807 - Calling new method "updateContractAndOppAfterContractTermination" to update Contract and Opportunity
 *                      V_1.7 - Modified By - Subhash Garhwal - 05/30/2017 - CR-20170403-10807  - Added a new call startRenewalForecast
 *                      V_1.8 - Modified By - Subhash Garhwal - 05/30/2017 - CR-20170403-10807  - Added a new call updateRenewalOpponSubAndSubPeriod
 *                      V_1.9 - Modified By - Saurabh Kumar - 05/31/2017 - CR-20170403-10807  - Added a new call "updateContractAmendmentType"
 *                      V_2.0 - Modified By - Abhinav Sharma - 06/02/2017 - DS114 - Added a new method calls "populateFieldsValueOnCases, beforeEventsLogicHandler"
 *                      V_2.1 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - A new method is added "updateActiveMembershipMainContact"
 *                      V_2.2 - Modified By - Subhash Garhwal - 06/30/2017  - A new method is added "populateContractTerm"
 *                      V_2.3 - Modified By - Subhash Garhwal - 09/18/2017  - A new method is added "setProposalAndLineBYPassFlag"
 *                      V_2.4 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
 *                      V_2.5 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_Contract_TRIGGER_FOR_MERGE)
 *                      V_2.6 - Modified By - Subhash Garhwal - 02/01/2017 - New Method call - updateContractABCRenewalOpportunity
 *                      V_2.7 - Modified By - Subhash Garhwal - 03/27/2017 - Bypass methods to avoid SOQL issue (ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL check)
 *                      V_2.8 - Modified By - Subhash Garhwal - 04/11/2018 - CR-20180411-12158 - Moved startRenewalForecast call from before to after
 *                      V_2.9 - Modified By - Subhash Garhwal - 06/29/2018 - CR-20180627-12306 - Added a new call opportunityContractedCheck
 *                      V_3.0 - Modified By - Subhash Garhwal - 08/13/2018 - CR-20180515-12225 - Added method 'populateFieldsOnContract' to populate Contract fields from Proposal 
 *                      V_3.1 - Modified By - Dipesh Gupta - 12/15/2019 - CR-20191029-13473 - Added method 'populateInvoiceContactOnCPQSub' to populate Invoice Contact field on CPQ Subscription
 * 			V_3.2 - Modified By - Dipesh Gupta - 02/25/2020 - CR-20200221-13792 - Added method 'createContractAndScheduledBatch' - Integrate Contracts with ES Campaigns
 *			V_3.3 - Modified By - Colin McGloin - 06/17/2020 - CR-20200615-14186 - Added updateInvoiceContact method
 *			V_3.4 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
 **/
trigger ContractTrigger on Contract (after insert, before insert, before update, before delete, after update) {
    
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Contract')) return;  
    
    try {
        
        //Bypass flag
        if(Util.BypassAllTriggers) return;
        
        //Check for trigger context
        if(Trigger.isBefore) {
            
            //Check for trigger event
            if(Trigger.isInsert) {
                
                //Subhash Garhwal - 06/29/2018 - CR-20180627-12306
                ContractTriggerHelper.opportunityContractedCheck(Trigger.new);
                
                //Subhash Garhwal - 08/13/2018 - CR-20180515-12225
                ContractTriggerHelper.populateFieldsOnContract(Trigger.new);        
                
                //Subhash Garhal - 09/18/2017 
                ContractTriggerHelper.setProposalAndLineBYPassFlag(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 6/8/2017
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.populateInitalValues(Trigger.new);

                //V_1.4 - Added by - Saurabh Kumar - 05/18/2017 - CR-20170403-10807
                //Call Helper class method to update Amendments field on Contract
                /*if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.updateAmendmentsFieldonContract(Trigger.new);*/
                    
                //Added by mahendra Swarnkar - 11/27/2019 -
                ContractTriggerHelper.populateBillingScheduleStatus(Trigger.new);
            }

            //Check for trigger event
            if(Trigger.isUpdate) {
                
                //Added By - Dipesh Gupta - 12/15/2019 - CR-20191029-13473
                ContractTriggerHelper.populateInvoiceContactOnCPQSub(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhal - 09/18/2017 
                ContractTriggerHelper.setProposalAndLineBYPassFlag(Trigger.new, Trigger.oldMap);

                //Call Helper Class Method to auto populate 'Replaced By Contract' on Contract
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.updateContractReplacedByOnContract(Trigger.new, Trigger.oldMap);

                //V_2.2 - Updated By - Subhash Garhwal - 06/30/2017 
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.populateContractTerm(Trigger.newMap);

                //Created - 06/17/2020 - Colin McGloin - CR-20200615-14186
                ContractTriggerHelper.updateInvoiceContact(Trigger.new, Trigger.oldMap);

            }
            
            //Check for trigger Event
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Call Helper class method to update our Renewal Opportunity on Subscription
                ContractTriggerHelper.renewalOpportunitySubscriptionHeader(Trigger.new, Trigger.oldMap);
                
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL) {
                  
                  //Subhash Garhwal - Added a new call  
                  //ContractTriggerHelper.validateContractType(Trigger.new, Trigger.oldMap);
                  
                  //Subhash Garhwal - 04/11/2018 - CR-20180411-12158 - Comment out the call
                  //Subhash Garhwal - Added a new call
                  //ContractTriggerHelper.startRenewalForecast(Trigger.new, Trigger.oldMap);  
                  
                  //Calling helper class method - Added by - Abhinav Sharma - 06/03/2017 - DS114
                  ContractTriggerHelper.beforeEventsLogicHandler(Trigger.new, Trigger.oldMap);
                  
                  //Call Helper class method
                  ContractTriggerHelper.syncNegotiatedBy(Trigger.new, Trigger.oldMap);

                  //Added by Colin McGloin - CR-20200824-14468
                  ContractTriggerHelper.populateBillingScheduleStatus(Trigger.new);
                  
                }
                  
                //V_1.9 - Saurabh Kumar - 05/31/2017 - CR-20170403-10807 - Added a new call.
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.updateContractAmendmentType(Trigger.new, Trigger.oldMap);
            }
            
            //Check for trigger event
            if(Trigger.isDelete) {
                 
                 //Mahendra Swarnkar - CR-20200610-14172 - 06/15/2020 -  Before delete validate Contratany Program Subscription is having the revenue records
                ContractTriggerHelper.validateContract(Trigger.new, Trigger.oldMap); 
                
                //Call Helper class method to delete related contract integrated accounts
                ContractTriggerHelper.syncContractIntegratedAccounts(Trigger.new, Trigger.oldMap);

            }
        }
        
        //Check for trigger context
        if(Trigger.isAfter) {
            
            //Check for trigger event
            if(Trigger.isInsert ) {
                
                //Added By - Dipesh Gupta - 02/25/2020 - CR-20200221-13792 - Calling helper class method
                ContractTriggerHelper.createContractAndScheduledBatch(Trigger.new);
                
                //Added By - Subhash Garhwal - 08/06/2018 - Issue--CR11980--QA--00008160 
                ContractTriggerHelper.createContentDocumentLink(Trigger.new);
                
                //Call Helper class method to create related contract integrated accounts
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.syncContractIntegratedAccounts(Trigger.new, Trigger.oldMap);

                //Subhash Garhwal - 05/11/2017 - CR-20170403-10807 - Call helper Method
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.linkSignedLOAToContract(Trigger.new);
                
                //Calling Trigger Helper Class Method
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.createContractIntegratedAccount(Trigger.New);
                
                //Calling Trigger Helper Class Method
                //Added by Subhash Garhwal
                if(!ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                    ContractTriggerHelper.validateInstitutionMSAStandardContract(Trigger.New);
               
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL) {
                    
                    //Calling helper class metho- Added by - Victor Hanson - 06/07/2017 - DS070
                    ContractTriggerHelper.populateFieldValuesOnOpportunity(Trigger.new, Trigger.oldMap);
                    
                
                    //Subhash Garhwal - 04/11/2018 - CR-20180411-12158 - Added call here to check the Renewal Forecast when contract is activated.
                    ContractTriggerHelper.startRenewalForecast(Trigger.new, Trigger.oldMap);    
                }
                    
                
                //V_1.6 - Updated by - Saurabh Kumar - 05/25/2017 - CR-20170403-10807 - Calling helper class method to update Contract Status and Opportunity Stage
                ContractTriggerHelper.updateContractAndOppAfterContractTermination(Trigger.new, Trigger.oldMap);
                
                //Subhash Garhwal - 05/30/2017
                ContractTriggerHelper.updateRenewalOpponSubAndSubPeriod(Trigger.new, Trigger.oldMap);
                
                //V_1.5 - Updated by - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - Calling method to make name format
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                  ContractTriggerHelper.generateNameFormat(Trigger.new, Trigger.oldMap);
             }
            
            //Checking for update event
            if(Trigger.isUpdate) {
                
                //Calling helper class method - Added by - Abhinav Sharma - 06/02/2017 - DS114
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                  ContractTriggerHelper.populateFieldsValueOnCases(Trigger.new, Trigger.oldMap);
                
                //Calling helper class method - Added by - Subhash Garhwal - 06/6/2017 - DS114
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                  ContractTriggerHelper.activeMemberships(Trigger.new, Trigger.oldMap);
                
                //V_2.1 - Updated By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Calling helper class method
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL)
                  ContractTriggerHelper.updateActiveMembershipMainContact(Trigger.new, Trigger.oldMap);
                
                //Call a new Method in the after update case
                ContractTriggerHelper.updateContractABCRenewalOpportunity(Trigger.new, Trigger.oldMap);
                
                
                if(!ContractTriggerHelper.BYPASS_Contract_TRIGGER_FOR_MERGE && !ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL && system.isFuture())
                    ContractTriggerHelper.validateInstitutionMSAStandardContract(Trigger.New);
                
                //Added By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
                ContractTriggerHelper.updateSubscriptionsInvoicingArrangement(Trigger.new, Trigger.oldMap);
             }
            
            if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete )
                ContractTriggerHelper.updateContactPrimaryContract(Trigger.new, Trigger.oldMap);
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