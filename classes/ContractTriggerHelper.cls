/**
 *  Description     :  Helper class for ContractTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  07/01/2016 
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified By - Subhash Garhwal - 04/28/2017 - CR-20170403-10807 - Added a new method syncNegotiatedBy
 *                      V_1.2 - Modified By - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 - Added a new method linkSignedLOAToContract
 *                      V_1.3 - Modified By - Subhash Garhwal  - 05/15/2017 - CR-20170403-10807 - Added a new method updateContractReplacedByOnContract
 *                      V_1.4 - Modified By - Saurabh Kumar - 05/18/2017 - CR-20170403-10807 - Added a new method updateAmendmentsFieldonContract
 *                      V_1.5 - Modified By - Saurabh Kumar - 05/23/2017 - CR-20170403-10807 - Added a new method "generateNameFormat" to make the name field in standard format
 *                      V_1.6 - Modified By - Saurabh Kumar - 05/25/2017 - CR-20170403-10807 - Added a new method "updateContractAndOppAfterContractTermination"
 *                      V_1.7 - Modified By - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 - Added a new method "updateContractAndOppAfterContractTermination"
 *                      V_1.8 - Modified By - Subhash Garhwal - 05/30/2017 - CR-20170403-10807  - Added a new call startRenewalForecast
 *                      V_1.9 - Modified By - Saurabh Kumar - 05/31/2017 - CR-20170403-10807 - Added a new method "updateContractAmendmentType"
 *                      v_2.0 - Modified By - Abhinav Sharma - 06/02/2017 - DS114  - Added "populateFieldsValueOnCases, beforeEventsLogicHandler" method
 *                      V_2.1 - Modified By - Deepak Kumawat - 06/04/2017 - DS117 -  Method- syncNegotiatedBy Change- Negotiated_By__c on contract populated for every opportunity record type, previously it was populated only for Initialting record types.
 *                      V_2.2 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - A new method "updateActiveMembershipMainContact" is added
 *                      V_2.3 - Modified By - Saurabh Kumar - 06/13/2017 - updateAmendmentsFieldonContract method is updated
 *                      V_2.4 - Modified By - Subhash Garhwal - 6/19/2017 -"updateRenewalOpportunityOnSubscriptionPeriod" A new method
 *                      V_2.5 - Modified BY - Subhash Garhwal - 6/30/2017 -"populateContractTerm" A new method
 *                      V_2.6 - Modified By - Saurabh Kumar - 07/17/2017 - Issue--CR10808--QA--00005011 - Subscription_Period__c.Renewal_Opportunity__c is updated from lookup to formual
 *                      V_2.7 - Modified By - Subhash Garhwal - 07/25/2017 - Issue--CR10808--QA--00005099 - updated activeMemberships method
 *                      V_2.8 - Modified By - Colin McGloin - 08/14/2017 - Issue--CR11094--QA--00005443 - updated populateContractTerm method
 *                      V_2.9 - Modified By - Deepak Kumar - 08/23/2017 - Issue--CR11094--UAT--00005371 - updated populateInitalValues method
 *                      V_3.0 - Modified By - Subhash Garhwal - 08/31/2017 - Issue--CR11062--QA--00005610 - added truncate for CustomerSignedTitle field.
 *                      V_3.1 - Modified By - Subhash Garhwal - 09/18/2017 - Issue--CR11183--QA--00005816 - Added a static flag to check the Renewal Forcast
 *                      V_3.2 - Modified By - Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - 
 *                      V_3.3 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_Contract_TRIGGER_FOR_MERGE)
 *                 	V_3.4 - Modified By - Subhash Garhwal - 02/01/2018 - CR-20180126-11910 ADDED a new Method updateContractABCRenewalOpportunity   
 *                	V_3.5 - Modified By - Abhinav Sharma - 03/09/2018 -   CR-20180205-11984 updateActiveMembershipMainContact
 *                	V_3.6 - Modified By - Subhash Garhwal - 03/27/2018 - Make changes to avoid SOQL issue for Renewal Proposal process
 *                	V_3.7 - Modified By - Subhash Garhwal - 03/28/2018 - Issue--CR12039--QA--00007920 - Change Member Payer to Constants.MEMBER_PAYER
 *                	V_3.8 - Modified By - Subhash Garhwal - 06/08/2018 - CR-20180502-12199 - Removed Bypass logic on the check of the Renewal Forecast
 *                	V_3.9 - Modified By - Subhash Garhwal - 06/29/2018 - CR-20170918-11373 - Deploying this from dev1 to full1 sandbox.
 *                	V_4.0 - Modified By - Subhash Garhwal - 08/06/2018 - Issue--CR11980--QA--00008160 - created 'createContentDocumentLink' method to create the junction object 'ContentDocumentLink' records between Proposal and contract
 *                	V_4.1 - Modified By - Subhash Garhwal - 08/13/2018 - CR-20180515-12225 - Added method 'populateFieldsOnContract' to populate Contract fields from Proposal 
 *          		V_4.2 - Modified BY - Dipesh Gupta - CR-20190111-12831 - Method - updateContactPrimaryContract  
 *          		V_4.3 - Modified By - Subhash Garhwal - 05/22/2019 - Added method validateInstitutionMSAStandardContract
 *			V_4.4 - Modified By - Dipesh Gupta - 12/15/2019 - CR-20191029-13473 - Added method populateInvoiceContactOnCPQSub
 *       		V_4.5 - Modified By - Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added a Bypaas flag 'BYPASS_ON_INVOICE_CONTACT_CHANGE' 
 *       		V_4.6 - Modified By - Dipesh Gupta - 02/25/2020 - CR-20200221-13792 - Added method 'createContractAndScheduledBatch' - Integrate Contracts with ES Campaigns
 *			V_4.7 - Modified By - Colin McGloin - 05/20/2020 - CR-20200518-14066 - Added in mapping for three fields - Member Signed By, Member Signed Date, Member Signed Title to the populateFieldsOnContract method
 *			V_4.8 - Modified By - Colin McGloin - 06/17/2020 - CR-20200615-14186 - Added updateInvoiceContact method to update Invoice Contact on related Billing Schedule Headers when Invoice Contact is changed on Contract
 *			V_4.9 - Modified By - Mahendra Swarnkar - 06/15/2020 - CR-20200610-14172 - Before delete validate Contratany Program Subscription is having the revenue records
 *			V_5.0 - Modified By - Subhash Garhwal -   CR-20200619-14207 - Added check for "MSA Not Needed" "validateInstitutionMSAStandardContract" method
 *			V_5.1 - Modified By - Mahendra Swarnkar - CR-20201105-14668 - 11/25/2020 - to address the 101 issue
 *			V_5.2 - Modified By - Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
 *			V_5.3 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
 *			V_5.4 - Modified By - Subhash Garhwal -   CR-20210811-15348
			
 **/
public without sharing class ContractTriggerHelper {
    
    //Modified By : Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass subscription trigger's method when invoice contact updated 
    //Flag to control the trigger execution 
    public static Boolean BYPASS_ON_INVOICE_CONTACT_CHANGE = false;
    
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_Contract_TRIGGER_FOR_MERGE = false;
    
    //Static flag to control the execution of renewalOpportunitySubscriptionHeader
    public static Boolean BYPASS_RENEWAL_OPPORTUNITY_SUBSCRIPTION_HEADER = false;
    
    //Subhash Garhwal - 09/18/2017 - Added flag to bypass the Proposal and Proposal Line Triggers when Temp Proposal and Lines created
    public static Boolean BYPASS_PROPOSAL_AND_LINES_TRIGGER = false;
    
    //Subhash Garhwal - 09/18/2017 - Added flag to bypass the Contract methods for Renewal Proposal process
    public static Boolean BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL = false;
       
    //Subhash Garhawal - 05/29/2018 Added the list of AggregateResult to reduce unneccessry SOQL query
    public static List<AggregateResult> groupedResults;
    
     /**
      * 
      *  @description  :   Added method to set BYPASSFORCONTRACTED flag value to true if Opportunity is contracted
      *
      *  @args           :   List<Contract>
      *
      *  @return         :   void
      *
      *  @revision Log   :   V1.0 - Created - 06/29/2018 - Subhash Garhwal - CR-20180627-12306
      * 
      **/
    public static void opportunityContractedCheck(List<Contract> newContracts) {
        
        //Check for flag system.isFuture()
        if(!OpportunityTriggerHelper.BYPASSFORCONTRACTED)
        {
            //Check if COntract is inserted from future method
            if(System.isFuture())
                OpportunityTriggerHelper.BYPASSFORCONTRACTED = true;
            
        }  
    }
    
    /**
     * @description     :  Method to set the BYPASS_PROPOSAL_AND_LINES_TRIGGER variable value
     *
     *  @args           :   List<Contract>, Map<Id, Contract> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 09/18/2017 - Subhash Garhwal - Issue--CR11183--QA--00005816
     * 
     **/
    public static void setProposalAndLineBYPassFlag(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Loop over the Contract
        for(Contract cont : contracts)
        {
            
            //Check for Renewal forcast
            if(cont.SBQQ__RenewalForecast__c && !cont.SBQQ__RenewalQuoted__c && (mapOldContracts == null || cont.SBQQ__RenewalForecast__c != mapOldContracts.get(cont.Id).SBQQ__RenewalForecast__c))
                BYPASS_PROPOSAL_AND_LINES_TRIGGER = true;
            
            //Check for Renewal Proposal
            if(cont.SBQQ__RenewalQuoted__c && (mapOldContracts == null || !mapOldContracts.get(cont.Id).SBQQ__RenewalQuoted__c))
                BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL = true;  
        }
    }
    
    //map of Accounts for used for reference across multiple helper methods.  Store in one location so we don't waste SOQL queries
    public static map<Id, Account> mapAccounts {
        get {
            if (mapAccounts == null) mapAccounts = new map<Id, Account>();
            return mapAccounts;
        }
        set;
    }
    
    /**
     * 
     *  @description:       Method to populate the Opportunity fields below based on the related to Contract.
     *                      Opportunity.LOA Contract = Contract.ID
     *                      Opportunity.Start = Contract.StartDate
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/07/2017 - Victor Hanson - DS070
     *                      V_1.1 - Modified - 03/30/2018 - Subhash Garhwal - Added Record type check
     * 
     **/
    public static void populateFieldValuesOnOpportunity(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        Map<Id, Opportunity> mapOppsToUpdate = new Map<Id, Opportunity>();
        
        //Set to hold the Opp Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the Contract
        for(Contract cont : contracts)
        {
            
            //Check for Opportunity
            if(cont.SBQQ__Opportunity__c != null && (mapOldContracts == null || cont.SBQQ__Opportunity__c != mapOldContracts.get(cont.Id).SBQQ__Opportunity__c))
            {
                setOppIds.add(cont.SBQQ__Opportunity__c);
                
                //Check for old Opp
                if(mapOldContracts != null && mapOldContracts.get(cont.Id).SBQQ__Opportunity__c != null)
                    setOppIds.add(mapOldContracts.get(cont.Id).SBQQ__Opportunity__c);  
            }
            
        }
        
        //Check for set size
        if(setOppIds.size() > 0)
        {
            
            //Get the Opportunity Record Types
            Map<String, Id> oppRecordTypeMap = Util.recordtypemap('Opportunity');
            
            //Set to hold the continuing/Initiating record types
            Set<Id> setOppContinuingInitiatingRecordTypes = new Set<Id>();
            
            //Get Continuing record types
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Continuing From Opportunity.
            //setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_CONTINUING));
            setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_CONTINUING));
            //Commented by Mahendra Swarnkar - 03/16/2020 - CR-20200217-13756 - RT deleted : HC Initiating From Opportunity.
            //setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_HC_INITIATING));
            setOppContinuingInitiatingRecordTypes.add(oppRecordTypeMap.get(CPQConstants.OPP_RECORD_TYPE_NAME_EAB_INITIATING));
            
            //Map to hold the Opportunity
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([Select Id, RecordTypeId From Opportunity Where Id IN : setOppIds
                                                                              AND RecordTypeId IN : setOppContinuingInitiatingRecordTypes]);
            
            //get the list of opportunities related contracts
            set<Id> oppIds = new set<Id>();
            for (Contract cont : contracts) 
            {
                
                //get the old contract if this is an update
                Contract oldCont;
                if (mapOldContracts != null) 
                    oldCont = mapOldContracts.get(cont.Id);
                
                //if this is a new contract, or the contract.SBQQ__Opportunity__c is being updated
                if (oldCont == null || cont.SBQQ__Opportunity__c != oldCont.SBQQ__Opportunity__c)
                {
                    
                    OpportunityTriggerHelper.BYPASSFORCONTRACTED = true;
                    
                    //if the opportunity field is not null
                    if (cont.SBQQ__Opportunity__c != null && mapOpportunities.containsKey(cont.SBQQ__Opportunity__c))
                    {
                        
                        //populate Opportunity.LOA_Contract__c field with the contract ID
                        mapOppsToUpdate.put(
                            cont.SBQQ__Opportunity__c,
                            new Opportunity(Id=cont.SBQQ__Opportunity__c, LOA_Contract__c=cont.Id, Start__c=cont.StartDate,End__c=cont.EndDate)
                        );
                    }
                    
                    //if opportunity is being changed on a contract, remove the old opp's contract reference
                    if (oldCont != null && oldCont.SBQQ__Opportunity__c != null
                        && !mapOppsToUpdate.containsKey(oldCont.SBQQ__Opportunity__c) && mapOpportunities.containsKey(cont.SBQQ__Opportunity__c)) 
                    {
                        mapOppsToUpdate.put(oldCont.SBQQ__Opportunity__c,new Opportunity(Id=oldCont.SBQQ__Opportunity__c, LOA_Contract__c=null, Start__c=null));
                    } 
                }
            }
            
            //update the LOA_Contract__c field on opportunities
            if (mapOppsToUpdate.size() > 0) update mapOppsToUpdate.values();
        }
    }
    
    /**
     *  @description    :   This method is to hold the logic to populate and validate fields in before events.
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 06/03/2017 - Created
     *
     **/
    public static void beforeEventsLogicHandler(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Set to hold the account IDs
        Set<Id> setAccountsIDs = new Set<Id>();
        
        //Loop through contract records
        for(Contract cont : contracts)
        {
            if(cont.AccountId != null && !ContractTriggerHelper.mapAccounts.containsKey(cont.AccountId))
                setAccountsIDs.add(cont.AccountId);
        }
        
        //Checking set for its size
        if(setAccountsIDs.size() > 0)
        {
            ContractTriggerHelper.mapAccounts.putAll([SELECT ID, Name 
                                                      FROM Account
                                                      WHERE ID IN : setAccountsIDs
                                                     ]);
        }
        
        //Loop through contract records
        for(Contract con : contracts)
        {
            if(con.AccountId != null && ContractTriggerHelper.mapAccounts.containsKey(con.AccountId))
                con.Account_Name_Text__c = ContractTriggerHelper.mapAccounts.get(con.AccountId).Name;
            else
                con.Account_Name_Text__c = '';
        }
    }
    
    /**
     * 
     *  @description    :   Method to populate "Renewal_Date1__c" field on case records associated with memberships, due to formula reference limit.
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/22/2017 - Abhinav Sharma - DS114
     * 
     **/
    public static void populateFieldsValueOnCases(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Map of eligible contracts
        Map<Id, Contract> mapOfEligibleContracts = new Map<Id, Contract>();
        
        //Checking for update use case
        if(contracts != null && mapOldContracts != null)
        {
            //Loop through Subscription records
            for (Contract con : contracts)
            {
                
                //Checking for field value changes
                if(con.EndDate != mapOldContracts.get(con.Id).EndDate)
                    mapOfEligibleContracts.put(con.Id, con);
            }
            
            //Checking map for its size
            if(mapOfEligibleContracts.values().size() > 0)
            {
                //List of cases to be updated
                Map<Id, Case> mapOfCasesToBeUpdated = new Map<Id, Case>();
                
                //Loop through case records
                for(Case cs : [SELECT ID, Renewal_Date1__c, 
                               Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate
                               FROM Case
                               WHERE Membership__c != null
                               AND Membership__r.Latest_Subscription__c != null
                               AND Membership__r.Latest_Subscription__r.SBQQ__SubscriptionEndDate__c = null
                               AND Membership__r.Latest_Subscription__r.SBQQ__Contract__c != null
                               AND Membership__r.Latest_Subscription__r.SBQQ__Contract__c IN : mapOfEligibleContracts.keySet()])
                {
                    
                    //Checking for values difference and accordingly adding instances to the collection
                    if(cs.Renewal_Date1__c != cs.Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate)
                    {
                        cs.Renewal_Date1__c = cs.Membership__r.Latest_Subscription__r.SBQQ__Contract__r.EndDate;
                        mapOfCasesToBeUpdated.put(cs.Id, cs);   
                    }
                }
                
                //Checking map for its size
                if(mapOfCasesToBeUpdated.values().size() > 0) 
                {
                    
                    //Bypassing triggers
                    Util.byPassAllTriggers = true;
                    
                    //Update cases
                    update mapOfCasesToBeUpdated.values();
                    
                    //Enabling triggers
                    Util.byPassAllTriggers = false;
                }   
            }
        }
    }
    
    /**
     *  @description    :   This method is used to create Contract Integrated Account according if parent opportunity is contracted and integrated
     *                      account exists under it
     *
     *                      Details form WORK ORDER (Process): 
     *                      If Integrated Accounts exist on the parent Opportunity, create a Contract Integrated Account for each combination of Integrated Account and Contract record
     *                      Record Type = 'Standard Contract'
     *                      Integrated Account = <specific Integrated Account record>
     *                      LOA Contract = <specific standard Contract record>
     *                      Account = <Integrated Account.IntegratedAccount Id>
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 07/01/2016 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    public static void syncContractIntegratedAccounts(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Map to hold the Contract Ids with related Opportunity (Contract LOA type) Id
        Map<Id, Set<Id>> mapOppIdWithContractIds = new Map<Id, Set<Id>>();
        
        //Check for contract list size
        if(contracts != null && contracts.size() > 0)
        {
            /*
            //Query through the contract record
            //Subhash Garhwal - 02/05/2017 - Removed OPPORTUNITY_RECORD_TYPE_DEVELOPERNAME_CONTRACT_LOA varaible form Opp Record Type check and added SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES check
            for(Contract cont : [Select Id, SBQQ__Opportunity__c From Contract Where Id IN : contracts AND SBQQ__Opportunity__r.RecordType.DeveloperName IN: CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES
            AND SBQQ__Opportunity__r.SBQQ__Contracted__c = true]) {
            
            //Add Opportunity Id in map
            if(!mapOppIdWithContractIds.containsKey(cont.SBQQ__Opportunity__c))
            mapOppIdWithContractIds.put(cont.SBQQ__Opportunity__c, new Set<Id>());
            
            //Add Contract Id in set
            mapOppIdWithContractIds.get(cont.SBQQ__Opportunity__c).add(cont.Id);
            
            }
            
            //Check for map size
            if(mapOppIdWithContractIds.size() > 0) {
            
            //List ot insert Contract Integrated Accounts
            List<Contract_Integrated_Accounts__c> contractIntegratedAccounts = new List<Contract_Integrated_Accounts__c>();
            
            //Get Standard Contract Record Type
            List<RecordType> recordTypes = [Select Id From RecordType Where SobjectType = 'Contract_Integrated_Accounts__c' AND DeveloperName =: CPQConstants.CONTRACT_INT_ACC_RT_DN_STANDARD_CONTRACT LIMIT 1];
            
            //Query through the Integrated accounts
            for(Integrated_Account__c iA : [Select Id, Opportunity__c, Integrated_Account__c From Integrated_Account__c Where Opportunity__c IN : mapOppIdWithContractIds.keySet()]) {
            
            //Check Opprtunity Id in map
            if(mapOppIdWithContractIds.containsKey(iA.Opportunity__c)) {
            
            //Loop over the Contract Ids
            for(Id contId : mapOppIdWithContractIds.get(iA.Opportunity__c)) {
            
            //Instance of Contract_Integrated_Accounts__c
            Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
            
            //Set field values
            cIA.RecordTypeId = recordTypes.size() > 0 ? recordTypes[0].Id : cIA.RecordTypeId;
            cIA.LOA_Contract__c = contId;
            cIA.Integrated_Account__c = iA.Id;
            cIA.Account__c = iA.Integrated_Account__c;
            
            //Add record in lisr
            contractIntegratedAccounts.add(cIA);
            }
            }   
            }
            
            //Check for contractIntegratedAccounts size
            if(contractIntegratedAccounts.size() > 0) {
            Util.byPassAlltriggers = true;
            insert contractIntegratedAccounts;
            Util.byPassAlltriggers = false;
            }
            }
            */  
            
        } else if(mapOldContracts != null)
        {
            
            //Bypassing triggers
            Util.byPassAlltriggers = true;
            
            //Delete Contract Integrated accounts
            delete [Select Id From Contract_Integrated_Accounts__c Where LOA_Contract__c IN : mapOldContracts.keySet()];    
            
            //Enabling triggers
            Util.byPassAlltriggers = false;
        }
    }

    /**
     *  @description    :   This method is used to populate the Renewal Opportunity field on the header Subscription if the field is populated on the Contract
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 04/14/2017 - Created - Colin McGloin - CR-20170403-10807
     *
     **/
    public static void renewalOpportunitySubscriptionHeader(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //VH 8/17 to avoid SOQL limit
        if (BYPASS_RENEWAL_OPPORTUNITY_SUBSCRIPTION_HEADER) return;
        
        //VH 8/17/17 - update flag to true so we don't hit this method multiple times per invocation
        BYPASS_RENEWAL_OPPORTUNITY_SUBSCRIPTION_HEADER = true;
        
        //List of Contracts
        Map <Id, Id> mapContracts = new Map <Id, Id>();
        
        //List of Subscriptions to update
        List <SBQQ__Subscription__c> updateSubs = new List<SBQQ__Subscription__c>();
        
        //Loop over Contracts
        for(Contract con : contracts != null ? contracts : mapOldContracts.values())
        {
            //Insert Case
            if(mapOldContracts == null && con.SBQQ__RenewalOpportunity__c != null)
                mapContracts.put(con.Id, con.SBQQ__RenewalOpportunity__c);
            
            //Update case
            if(mapOldContracts != null && contracts != null &&
               (con.SBQQ__RenewalOpportunity__c != mapOldContracts.get(con.Id).SBQQ__RenewalOpportunity__c))
            {
                //Add our Contract to the list
                mapContracts.put(con.Id, con.SBQQ__RenewalOpportunity__c);
            }
            
            //Delete Case
            if(mapOldContracts != null && con.SBQQ__RenewalOpportunity__c == null)
                mapContracts.put(con.Id, null);
        }
        
        //Added check for size - to address the 101 issue - CR-20201105-14668 - Mahendra Swarnkar - 11/25/2020 
        if (mapContracts.keyset() != null && mapContracts.keyset().size() > 0) {
            
            //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Added additional fields in SOQL query for Renewal opps.
            //Query for our Subscription records
            List <SBQQ__Subscription__c> subscriptions = [SELECT Id, Name, SBQQ__Contract__c, SBQQ__Contract__r.Id, Renewal_Opportunity__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, SBQQ__Product__c, SBQQ__Product__r.SBQQ__Component__c, RecordType.Name,
                                                          SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__r.Name,
                                                          SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.OwnerId, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Owner.Name   
                                                          FROM SBQQ__Subscription__c
                                                          WHERE SBQQ__Contract__r.Id IN :mapContracts.keyset()
                                                          AND RecordType.Name = 'Program'
                                                          /*AND SBQQ__Product__r.SBQQ__Component__c != TRUE*/];
            
            //Loop through our Subscription records                                           
            for (SBQQ__Subscription__c sub : subscriptions)
            {
                
                //Let's grab our Renewal Opportunity value or blank value from the Contract that kick started the process
                if (sub.SBQQ__Contract__c != null && mapContracts.containsKey(sub.SBQQ__Contract__r.Id) && mapContracts.get(sub.SBQQ__Contract__r.Id) != null)
                {
                    
                    //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Added logic to update the Renewal Opp details on Subscriptions.
                    //Update 
                    sub.Renewal_Opportunity__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                    sub.Renewal_Opp_Stage__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName;
                    if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__c != null)
                        sub.Renewal_Opportunity_Main_Contact__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__r.Name;
                    
                    sub.Renewal_Opportunity_Owner_Name__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Owner.Name;
                    updateSubs.add(sub);
                }
            }
        }
        
        if (updateSubs.size() > 0)
        {
            //Update our Subscription values
            Util.byPassAlltriggers = true;
            update updateSubs;
            Util.byPassAlltriggers = false;
        }
    }
    
    /**
     *  @description    :   This method is used to populate the Negotiated By field on Contract with the name of the Marketer from the Closed Won Opp. And also used to update renewal opportunity field on related subscription period of Contract
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 04/28/2017 - Created - Subhash Garhwal - CR-20170403-10807  
     *                  :   V_1.1 - 06/04/2017 - Modified By - Deepak Kumawat - Negotiated_By__c of contract object is populated for every record type of opportunity.          
     *
     **/
    public static void syncNegotiatedBy (List<Contract> contracts, Map<Id, Contract> mapOldContracts) {

        //Set to hold the Opportunity Id
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the Contract
        for(Contract con : contracts)
        {
            //Check appropriate condition to execute logic
            if(con.SBQQ__Opportunity__c != null && (mapOldContracts == null || con.SBQQ__Opportunity__c != mapOldContracts.get(con.Id).SBQQ__Opportunity__c))
                setOppIds.add(con.SBQQ__Opportunity__c);    
        }
        
        //Check set size
        if(setOppIds.size() > 0)
        {
            //Map to hold the Opportunities
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([Select Id, Marketer__c, RecordType.DeveloperName, SBQQ__RenewedContract__r.Negotiated_Amount_Contract__c From Opportunity Where Id IN : setOppIds]);
            
            //Check for map size
            if(mapOpportunities.size() > 0)
            {  
                //Loop over the Contract
                for(Contract con : contracts)
                {
                    //Check opportunity Id in map
                    if(mapOpportunities.containsKey(con.SBQQ__Opportunity__c))
                    {
                        con.Negotiated_By__c =  mapOpportunities.get(con.SBQQ__Opportunity__c).Marketer__c;
                        
                        //Added by Deepak Kumawat- V_2.2 Previous_Contract_Negotiated_Amount__c of contract object is populated for opportunity's renewed contract Negotiated_Amount_Contract__c.    
                        con.Previous_Contract_Negotiated_Amount__c = mapOpportunities.get(con.SBQQ__Opportunity__c).SBQQ__RenewedContract__r.Negotiated_Amount_Contract__c;
                    }
                    
                    //Adding the logic of 'validateContractType' method to reduce the SOQL query
                    //Check for Opportunity
                    if(con.SBQQ__Opportunity__c != null && mapOpportunities.containsKey(con.SBQQ__Opportunity__c) && mapOpportunities.get(con.SBQQ__Opportunity__c) != null)
                    {
                        //Check source opportunity record type id
                        if(CPQConstants.SET_OPP_INITIATING_RECORDTYPES.contains(mapOpportunities.get(con.SBQQ__Opportunity__c).RecordType.DeveloperName))
                            con.Type__c = CPQConstants.TYPE_NBB; 
                        else if(CPQConstants.SET_OPP_CONTINUING_RECORDTYPES.contains(mapOpportunities.get(con.SBQQ__Opportunity__c).RecordType.DeveloperName))
                            con.Type__c = CPQConstants.Type_RENEWAL;
                    }
                }
            }
        }
    }
    /**
     *  @description    :   This method used to Link signed LOA to the Contract 
     *
     *  @args           :   List<Contract> newContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/11/2017 - CR-20170403-10807 
     *
     **/
    public static void linkSignedLOAToContract(List<Contract> newContracts) {
        
        //Set to hold opportunity Id
        Set<Id> setOfOpportunity = new Set<Id>();
        
        //List to hold Content Document Link
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        //Map to hold Opportunity Id with Contract Id
        Map<Id,Id> mapOfOpportunityIdWithLOAId = new Map<Id,Id>();
        
        //Loop through New Contract and Update Contract
        for(Contract contract : newContracts)
        {
            //Process if condition is true
            if(contract.SBQQ__Opportunity__c != null)
            {
                //Add id to set
                setOfOpportunity.add(contract.SBQQ__Opportunity__c);
            }
        }
        
        //Loop through Quotes
        for(SBQQ__Quote__c quote : [Select Id, LOA_PDF_Document_ID__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.StageName, SBQQ__Opportunity2__r.SBQQ__Contracted__c,
                                    SBQQ__DocumentStatus__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN: setOfOpportunity
                                    AND SBQQ__DocumentStatus__c =: CPQConstants.DOCUMENT_STATUS_SIGNED AND
                                    LOA_PDF_Document_ID__c != null AND 
                                    SBQQ__Opportunity2__r.StageName =:CPQConstants.OPPORTUNITY_STAGE_CLOSED_WON AND
                                    SBQQ__Opportunity2__r.SBQQ__Contracted__c = true ])
        {
            //Put values to Map 
            mapOfOpportunityIdWithLOAId.put(quote.SBQQ__Opportunity2__c,quote.LOA_PDF_Document_ID__c);
        }
        
        //Loop through New Contract and Update Contract
        for(Contract contract : newContracts)
        {
            //Check contain in Map
            if(mapOfOpportunityIdWithLOAId.containsKey(contract.SBQQ__Opportunity__c))
                
                //Add Content Document Link to List
                contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = mapOfOpportunityIdWithLOAId.get(contract.SBQQ__Opportunity__c),
                                                                 LinkedEntityId = contract.Id, ShareType = 'V', Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY));
            
        }
        
        //Check for size
        if(contentDocumentLinks.Size() > 0)
        {
            Util.byPassAlltriggers = true;
            insert contentDocumentLinks;
            Util.byPassAlltriggers = false;
        }
    }
    
    /**
     *  @description    :   This method used to update Contract_Replaced_By__c field to current login User
     *
     *  @args           :   List<Contract> ,Map<Id,Contract> mapOldContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/15/2017 - CR-20170403-10807 
     *
     **/
    public static void updateContractReplacedByOnContract(List<Contract> newContracts , Map<Id,Contract> mapOldContracts) {
        
        //Loop through Contract
        for(Contract contract : newContracts) {
            
            //Check for Condition
            if(contract.Status != null &&  contract.Status == CPQConstants.CONTRACT_STATUS_AMENDED_REPLACED && (contract.Status != mapOldContracts.get(contract.Id).Status))
                contract.Contract_Replaced_By__c = UserInfo.getUserId();            
        }       
    }
    /**
     *  @description    :   This method used to update Contract fields
     *
     *  @args           :   List<Contract> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 05/18/2017 - CR-20170403-10807 
     *
     **/
     //Logic of this method is moved to 'populateInitalValues' this method to reduce the soql query
    /*public static void updateAmendmentsFieldonContract(List<Contract> newContracts) {

        //Set to hold Opportunity Id
        Set<Id> setOpportunityIds = new Set<Id>();

        //Loop through New Contract
        for(Contract contract : newContracts) {

            //Check for opportunity Ids
            if(contract.SBQQ__Opportunity__c != null) 
                setOpportunityIds.add(contract.SBQQ__Opportunity__c);
        }

        //Check For Opportunity Size
        if(setOpportunityIds.Size() > 0) {

            //Query for Opportunity
            Map<Id,Opportunity> mapOfopportunities = new Map<Id,Opportunity>([Select Id, SBQQ__Contracted__c, StageName, RecordType.DeveloperName, RecordTypeId, Pricebook2Id, SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses__c,
                                                        SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses_Comments__c, Original_Opportunity_RecordTypeId__c From Opportunity  Where Id IN: setOpportunityIds
                                                        AND RecordType.DeveloperName IN : CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES]);

            //Loop through New Contract
            for(Contract contract : newContracts ) {

                //Check map contains key
                if(mapOfopportunities.containsKey(contract.SBQQ__Opportunity__c) && mapOfopportunities.get(contract.SBQQ__Opportunity__c) != null) {

                    //Populate opportunity Record Type Id
                    contract.SBQQ__AmendmentOpportunityRecordTypeId__c = mapOfopportunities.get(contract.SBQQ__Opportunity__c).Original_Opportunity_RecordTypeId__c;
                    
                    //Populate Renewal Behaviour
                    contract.SBQQ__AmendmentRenewalBehavior__c = CPQConstants.CONTRACT_AMENDMENT_RENEWAL_BEHAVIOR;
        
                    //Populate Opportunity Stage
                    //if(mapOfopportunities.get(contract.SBQQ__Opportunity__c).StageName == CPQConstants.CONTRACT_AMENDMENT_OPPORTUNITY_STAGE)
                        //contract.SBQQ__AmendmentOpportunityStage__c = CPQConstants.CONTRACT_AMENDMENT_OPPORTUNITY_STAGE;
                    
                    //V_2.3 - Modified By - Saurabh Kumar - 06/13/2017 - Condition is changed. No need to match Pricebook on Contract and Opportunity
                    //Check if Original Opportunity is having Price book then populate SBQQ__AmendmentPricebookId__c
                    if(mapOfopportunities.containsKey(contract.SBQQ__Opportunity__c) && mapOfopportunities.get(contract.SBQQ__Opportunity__c).Pricebook2Id != null )
                        contract.SBQQ__AmendmentPricebookId__c = mapOfopportunities.get(contract.SBQQ__Opportunity__c).Pricebook2Id;


                    //V_1.7 - Updated by - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 - Auto Populate Fields Non-Standard Clauses/Non-Standard Clauses Comments
                    if(mapOfopportunities.get(contract.SBQQ__Opportunity__c).SBQQ__Contracted__c) {
                        Contract.Non_Standard_Clauses__c = mapOfopportunities.get(contract.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses__c ;
                        Contract.Non_Standard_Clauses_Comments__c = mapOfopportunities.get(contract.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses_Comments__c;
                    }
                }
            }
        }
    }*/
    /**
     *  @description    :   The method is used to generate name format using a standard format. Format is as following
     *                      "Contract-"<Contract Number>_<First 30 characters of Institution name>_<End Date Month><End Date Year>_<Initiating or Continuing (based on Opportunity.Type)>
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 05/18/2017 - CR-20170403-10807 
     *
     **/
    public static void generateNameFormat(List<Contract> newContracts, Map<Id, Contract> mapOldContracts){
        
        //set to hold contract Id
        Set<Id> setContractId = new Set<Id>();
        
        //Processing on the new records
        for(Contract contract : newContracts)
        {
            //Checking whether record is inserting or updating
            if(mapOldContracts == null || contract.AccountId != mapOldContracts.get(contract.Id).AccountId || contract.EndDate != 
               mapOldContracts.get(contract.Id).EndDate || contract.SBQQ__Opportunity__c != mapOldContracts.get(contract.Id).SBQQ__Opportunity__c
               || contract.Type__c != mapOldContracts.get(contract.Id).Type__c)
            { 
                //Add Value to set
                setContractId.add(contract.Id);
            }
        }
        //Check for Account Id set
        if(setContractId.Size() >0 )
        {
            //List to hold contract
            List<Contract> contractTobeUpdated = new List<Contract>();

            //Loop through Contract
            for(Contract Con : [Select Id, ContractNumber, AccountId, Account.Name, EndDate, SBQQ__Opportunity__r.Type, Type__c From Contract Where Id IN : setContractId])
            {
                //Contract Prefix
                con.Name = CPQConstants.CONTRACT_PREFIX;

                //Check for Contract Name
                if(con.ContractNumber != null)
                    con.Name = con.Name  + con.ContractNumber;

                //Check Account Name length
                if(con.AccountId != null && con.Account.Name != null) 
                    con.Name = con.Name + '_' + con.Account.Name.left(30);

                //Check for End date
                if(con.EndDate != null)
                    con.Name = con.Name + '_' + String.valueOf(con.EndDate.Month()) +'_'+ String.valueOf(con.EndDate.year());
                
                //Check for opportunity 
                /* if(con.SBQQ__Opportunity__c != null) {
                //Check for Opportunity Recotrd type
                if(con.SBQQ__Opportunity__r.Type == CPQConstants.TYPE_NBB || con.SBQQ__Opportunity__r.Type == CPQConstants.Type_NEWBUSINESS)
                con.Name = con.Name + '_' + CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX;
                else
                con.Name = con.Name + '_' + CPQConstants.OPP_CONTINUING_RECORD_TYPE_SUFFIX;
                } */
                
                //Subhash Garhwal - 7/27/2017 - Issue--CR10808--QA--00004808
                if(con.SBQQ__Opportunity__c == null || con.SBQQ__Opportunity__r.Type == null)
                {
                    
                    if(con.Type__c == CPQConstants.TYPE_NBB || con.Type__c == CPQConstants.Type_NEWBUSINESS)
                        con.Name = con.Name + '_' + CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX;
                    else
                        con.Name = con.Name + '_' + CPQConstants.OPP_CONTINUING_RECORD_TYPE_SUFFIX;  
                }
                //Added By - Mahendra Swarnkar - 09/05/2019 - CR-20190903-13300 - Added else condition so that initiating/Continuing suffix can be added if contract related oportunity type is populated - Starts from here 
                else if(con.SBQQ__Opportunity__c != null && con.SBQQ__Opportunity__r.Type != null)
                {
                    
                    if(con.SBQQ__Opportunity__r.Type == CPQConstants.TYPE_NBB || con.SBQQ__Opportunity__r.Type == CPQConstants.Type_NEWBUSINESS)
                        con.Name = con.Name + '_' + CPQConstants.OPP_INITIATING_RECORD_TYPE_SUFFIX;
                    else
                        con.Name = con.Name + '_' + CPQConstants.OPP_CONTINUING_RECORD_TYPE_SUFFIX;   
                }
                //Added By - Mahendra Swarnkar - 09/05/2019 - CR-20190903-13300 - Added else condition so that initiating/Continuing suffix can be added if contract related oportunity type is populated - Ends here 
                //Added to list 
                contractTobeUpdated.add(con);
            }

            //Check if Size is greater than zero 
            if(contractTobeUpdated.Size()> 0 )
            {
                
                //By pass All trigger = true
                Util.byPassAlltriggers = true;
                
                //Update List
                update  contractTobeUpdated;
                
                //By pass All trigger = false
                Util.byPassAlltriggers = false;
            }
        }
    }
    
    /**
     *  @description    :   The method is used to update current Contract (Status = Terminated) and parent Opportunity 
                            (Stage = Closed) when "Amendment Type = Termination of Contract" on the all Contract
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 05/18/2017 - CR-20170403-10807 
     *
     **/
    public static void updateContractAndOppAfterContractTermination(List<Contract> newContracts, Map<Id, Contract> mapOldContracts){
        
        //Map to hold Parent Id (Renewal Opportunity Id) and current Contract Id
        Map<Id, Id> mapRenewalOppAndContractIds = new Map<Id, Id>();
        
        //Map to hold Contract records which should be update
        Map<Id, Contract> mapContacts = new Map<Id, Contract>();
        
        //Processing on the new records
        for(Contract contract : newContracts)
        {
            //Checking whether record is inserting or updating and bypass the blank update case
            if(contract.Amendment_Type__c != null && contract.Amendment_Type__c == CPQConstants.CONTRACT_AMENDMENT_TYPE_TERMINATION_OF_CONTRACT
               && contract.SBQQ__RenewalOpportunity__c != null && (mapOldContracts == null || contract.Amendment_Type__c != mapOldContracts.get(contract.Id).Amendment_Type__c ||
                                                                   contract.SBQQ__RenewalOpportunity__c != mapOldContracts.get(contract.Id).SBQQ__RenewalOpportunity__c))
            {
                mapRenewalOppAndContractIds.put(contract.SBQQ__RenewalOpportunity__c, contract.Id);
                mapContacts.put(contract.Id, contract);
            }
        }
        //Checking for map size
        if(mapRenewalOppAndContractIds.size() > 0)
        { 
            //Map to hold Renewal Opportunity and corresponding to Contract records
            Map<Id, List<Contract>> mapRenewalOppIdWithContract = new Map<Id, List<Contract>>();
            
            List<Contract> listContracts;
            
            //Query on the Contract
            for(Contract contract : [Select Id, SBQQ__RenewalOpportunity__c, Amendment_Type__c, Status From Contract Where SBQQ__RenewalOpportunity__c IN : mapRenewalOppAndContractIds.keySet()
                                     AND SBQQ__RenewalOpportunity__c != null])
            {
                //Check whether map contains the Contract
                if(mapRenewalOppIdWithContract.containsKey(contract.SBQQ__RenewalOpportunity__c))
                {
                    listContracts = mapRenewalOppIdWithContract.get(contract.SBQQ__RenewalOpportunity__c);
                    listContracts.add(contract);
                    mapRenewalOppIdWithContract.put(contract.SBQQ__RenewalOpportunity__c, listContracts);
                }
                else
                    mapRenewalOppIdWithContract.put(contract.SBQQ__RenewalOpportunity__c, new List<Contract>{contract});
            }
            //Checking map size and process on it
            if(mapRenewalOppIdWithContract.size() > 0)
            {
                
                Boolean isContractTermination = false;
                
                //Map to hold Opportunity record to update
                Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
                
                //Map to Contract which should be update
                Map<Id, Contract> mapContractsToUpdate = new Map<Id, Contract>();
                
                //Processing on the new records
                for(Contract contract : mapContacts.values())
                {
                    isContractTermination = true;
                    
                    if(mapRenewalOppIdWithContract.containsKey(contract.SBQQ__RenewalOpportunity__c))
                    {
                        for(Contract siblingContract : mapRenewalOppIdWithContract.get(contract.SBQQ__RenewalOpportunity__c))
                        {
                            if(contract.Id != siblingContract.Id)
                            {
                                if(siblingContract.Status == CPQConstants.CONTRACT_STATUS_TERMINATED)
                                    isContractTermination = true;
                                else
                                {
                                    isContractTermination = false;
                                    break;
                                }   
                            }
                        }
                    }
                    if(isContractTermination)
                    {
                        mapContractsToUpdate.put(contract.Id, new Contract(Id = contract.Id, Status = CPQConstants.CONTRACT_STATUS_TERMINATED));
                        mapOpportunities.put(contract.SBQQ__RenewalOpportunity__c, new Opportunity(Id = contract.SBQQ__RenewalOpportunity__c,
                                                                                        StageName = CPQConstants.OPPORTUNITY_STAGENAME_CLOSED));
                    }
                }
                
                //Checking for map size
                if(mapOpportunities.size() > 0)
                {
                    //Set flag to bypass all triggers
                    Util.BypassAllTriggers = true;
                    update mapOpportunities.values();
                    update mapContractsToUpdate.values();
                    
                    //Reset the flag
                    Util.BypassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     *  @description    :   When the Contract Status is set to the value 'Activated' for the first time (Activated Date is blank before this),
     *                      set the field Renewal Forecast (SBQQ__RenewalForecast__c) to TRUE.  This will start a CPQ process to create the renewal
     *                      opportunity.
     *
     *  @args           :   List<Contract> ,Map<Id,Contract> mapOldContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 
     *
     **/
    public static void startRenewalForecast(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        Set<Id> contractIds = new Set<Id>();
        
        //Loop over the Contracts
        for(Contract cont : contracts)
        {
            //Check for status and Activated Date
            if(cont.Status != null && cont.SBQQ__RenewalForecast__c != true 
               && CPQConstants.CONTRACT_ACTIVATE_STATUS.contains(cont.Status) 
               && (mapOldContracts == null || cont.Status != mapOldContracts.get(cont.Id).Status)
               && !system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled() )
            {
                contractIds.add(cont.Id);
            }
        }
        
        if (contractIds.size() > 0)
        {
            //System.enqueueJob(new RenewalForecastEnquueJob(contractIds));
            startRenewalForecast(contractIds);
        }
    }
    
    /**
     *  @description    :   Future method to set RenewalForecast = true on Contract.
     *                      Moved to a future method because we were hitting SOQL limits due to the creation of an Opp and all the SOQL
     *                      required for that process.
     *
     *  @args           :   List<Contract> ,Map<Id,Contract> mapOldContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 
     *                      V_1.1 - Modified - Subahsh Garhwal - 06/08/2018 - CR-20180502-12199 - Removed bypass logic
     *
     **/
    @future public static void startRenewalForecast(set<Id> contractIds) {
        
        List<Contract> contractsToUpate = new List<Contract>();
        for (Id i : contractIds) 
            contractsToUpate.add(new Contract(Id=i, SBQQ__RenewalForecast__c = true));
        
        if (contractsToUpate.size() > 0)
        {
            //Subhash Garhwal - CR-20180502-12199 - Commented
            //Bypass triggers
            //Util.byPassAllTriggers = true;
            
            update contractsToUpate; 
            
            Util.byPassAllTriggers = false;         
        }        
    }
    
    /**
     *  @description    :   Contract is updated with a Renewal Opportunity
     *                      1)  Update the related pending Subscription Period record to set the Renewal Opportunity field to link to the new Renewal Opportunity Id.
     *                      2)  Update the related Program Subscription records to set the Renewal Opportunity field to link to the new Renewal Opportunity Id."
     *
     *  @args           :   List<Contract> ,Map<Id,Contract> mapOldContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 
     *
     **/
    public static void updateRenewalOpponSubAndSubPeriod(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Map to hold the Contract Id with Renewal Opp Id
        Map<Id, Id> mapContractWithRenewalOpp = new Map<Id, Id>();
        
        //Loop over the contracts
        for(Contract cont : contracts)
        {
            //Check for renewal Opp
            if(cont.SBQQ__RenewalOpportunity__c != null && (mapOldContracts == null || cont.SBQQ__RenewalOpportunity__c != mapOldContracts.get(cont.Id).SBQQ__RenewalOpportunity__c))
                mapContractWithRenewalOpp.put(cont.Id, cont.SBQQ__RenewalOpportunity__c);   
        }
        
        //Check for map size
        if(mapContractWithRenewalOpp.size() > 0)
        {
            //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Added additional fields in SOQL query for Renewal opps.
            //SOQL on Subscription records
            List<SBQQ__Subscription__c> programSubscriptions = [Select Id, Renewal_Opportunity__c, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,
                                                                SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__c,
                                                                SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__r.Name,
                                                                SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.OwnerId, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Owner.Name
                                                                From SBQQ__Subscription__c Where SBQQ__Contract__c IN : mapContractWithRenewalOpp.keySet() AND
                                                                RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM];
            
            //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Comment the code as this is not needed
            //SOQL on Subscription records
            /*List<Subscription_Period__c> subscriptionPeriods = [Select Id, Renewal_Opportunity__c, Contract__c From Subscription_Period__c
	    Where Contract__c IN : mapContractWithRenewalOpp.keySet()]; */
            
            //Loop over the Subscriptions
            for(SBQQ__Subscription__c sub : programSubscriptions)
            {
                
                //Check contract Id in map
                if(mapContractWithRenewalOpp.containsKey(sub.SBQQ__Contract__c))
                {
                    
                    //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Added logic to update the Renewal Opp details on Subscriptions.
                    //Update 
                    sub.Renewal_Opportunity__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                    sub.Renewal_Opp_Stage__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName;
                    if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__c != null)
                        sub.Renewal_Opportunity_Main_Contact__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Main_Contact__r.Name;
                    
                    sub.Renewal_Opportunity_Owner_Name__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Owner.Name;
                }
                //sub.Renewal_Opportunity__c = mapContractWithRenewalOpp.get(subscription.SBQQ__Contract__c);
            }
            
            //Updated by - Saurabh Kumar - 07/17/2017 - Issue--CR10808--QA--00005011 - Code commented because Renewal_Opportunity__c type is updated from lookup to formula
            //Loop over the Subscriptions
            /*for(Subscription_Period__c subPeriod : subscriptionPeriods) {
            //Check contract Id in map
            if(mapContractWithRenewalOpp.containsKey(subPeriod.Contract__c))
            subPeriod.Renewal_Opportunity__c = mapContractWithRenewalOpp.get(subPeriod.Contract__c);
            }*/
            
            //Update program subscription
            if(programSubscriptions.size() > 0)
            {
                Util.byPassAlltriggers = true;
                update programSubscriptions;
                Util.byPassAlltriggers = false;
            }
            
            //Subhash Garhwal - 09/26/2017 - Issue--CR11394--QA--00005874 - Comment the code as this is not needed
            //Update Subscription Periods
            /*if(subscriptionPeriods.size() > 0) {
            Util.byPassAlltriggers = true;
            update subscriptionPeriods;
            Util.byPassAlltriggers = false;
            } */
        }
    }
    
    /**
     *  @description    :   The method is used to update Amendment Type = "Amend & Extend" if "Contract Term (months)" or "Contract End Date" is updated after clicking on the Amend button.
     *
     *  @args           :   List<Contract> ,Map<Id,Contract> mapOldContracts
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Saurabh Kumar - 05/31/2017 - CR-20170403-10807 
     *
     **/
    public static void updateContractAmendmentType(List<Contract> newContracts, Map<Id,Contract> mapOldContracts){
        
        //Processing on the new records
        for(Contract contract : newContracts){
            
            //Checking for update case only and byapss the blank update
            if(mapOldContracts != null && contract.Amendment_Type__c == CPQConstants.CONTRACT_AMENDMENT_TYPE_UPSELL && contract.Status != null && contract.Status == CPQConstants.CONTRACT_STATUS_ACTIVATED_AMENDED
               && (contract.ContractTerm != mapOldContracts.get(contract.Id).ContractTerm || contract.EndDate != mapOldContracts.get(contract.Id).EndDate))
            {
                contract.Amendment_Type__c = CPQConstants.CONTRACT_STATUS_AMEND_AND_EXTEND;
            }
        }
    }
    
    /**
     *  @description    :   This method is used to create CIA records
     *
     *  @args           :   List<Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 06/04/2017 - CR-20170403-10807 
     *
     **/
    public static void createContractIntegratedAccount(List<Contract> contracts) {
        
        //Set to hold the Opportunity Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the Contracts
        for(Contract cont : contracts)
        {
            //Check for SBQQ__Opportunity__c
            if(cont.SBQQ__Opportunity__c != null)
                setOppIds.add(cont.SBQQ__Opportunity__c);   
        }
        
        //Check for Opportunity
        if(setOppIds.size() > 0)
        {
            //Map to hold the Integrated Account
            Map<Id, List<Integrated_Account__c>> mapOppWithIntegratedAccounts = new Map<Id, List<Integrated_Account__c>>();
            
            //SOQL over the Integrated_Account__c
            for(Integrated_Account__c iA : [Select Id, Opportunity__c, Integrated_Account__c From Integrated_Account__c Where Opportunity__c IN : setOppIds])
            {
                //Check Opportunity Id in map
                if(!mapOppWithIntegratedAccounts.containsKey(iA.Opportunity__c))
                    mapOppWithIntegratedAccounts.put(iA.Opportunity__c, new List<Integrated_Account__c>());
                
                //Add Integrated Account in map
                mapOppWithIntegratedAccounts.get(iA.Opportunity__c).add(iA);
            }
            
            //Check for map size
            if(mapOppWithIntegratedAccounts.size() > 0)
            {
                //List to Insert CIA
                List<Contract_Integrated_Accounts__c> contractIntegratedAccountsToInsert = new List<Contract_Integrated_Accounts__c>();
                
                //Get Record Type
                List<RecordType> standardContractRecordType = [Select Id From RecordType Where SobjectType = 'Contract_Integrated_Accounts__c' AND DeveloperName = 'Standard_Contract' LIMIT 1];
                
                //Loop over the Contracts
                for(Contract cont : contracts)
                {
                    //Check for SBQQ__Opportunity__c
                    if(cont.SBQQ__Opportunity__c != null)
                    {
                        //Check Opportunity Id in map
                        if(mapOppWithIntegratedAccounts.containsKey(cont.SBQQ__Opportunity__c))
                        {
                            //Loop over the Integrated Account
                            for(Integrated_Account__c iA : mapOppWithIntegratedAccounts.get(cont.SBQQ__Opportunity__c))
                            {
                                //Instance of Contract_Integrated_Accounts__c
                                Contract_Integrated_Accounts__c cIA = new Contract_Integrated_Accounts__c();
                                
                                //Populate field values
                                cIA.Name = 'Will Auto populate';
                                cIA.Integrated_Account__c = iA.Id;
                                cIA.LOA_Contract__c = cont.Id;
                                cIA.Account__c = iA.Integrated_Account__c;
                                cIA.RecordTypeId = standardContractRecordType[0].Id;
                                
                                //Add Record in list
                                contractIntegratedAccountsToInsert.add(cIA);
                            }
                        }       
                    }
                }
                
                //Check for size
                if(contractIntegratedAccountsToInsert.size() > 0)
                {
                    //Util.byPassAlltriggers = true;
                    insert contractIntegratedAccountsToInsert;
                    //Util.byPassAlltriggers = false;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to update the related membership records
     *                      Rule: "Memberships are to be activated (ie: Membership Status = Member Payer, etc) from a Contract once the Contract
     *                      is set as Activated.  At that time, the Membership records for the Contract Integrated Accounts should also be activated.
     *                      Ref DS073, DS073.1, DS073.2 and related Automations.
     *
     *  @args           :   List<Contract>, Map<Id, Contract>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 06/04/2017 - CR-20170403-10807
     *                      V_1.1 - Modified By - Subhash Garhwal - 03/28/2018 - Issue--CR12039--QA--00007920 - Change Member Payer to Constants.MEMBER_PAYER 
     *
     **/
    public static void activeMemberships(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Set to hold the Contract Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the contract
        for(Contract cont : contracts)
        {
            //Check for Active status
            if(cont.StatusCode != null && cont.StatusCode == 'Activated' && cont.StatusCode != mapOldContracts.get(cont.Id).StatusCode)
                setContractIds.add(cont.Id);  
        }
        
        //Check for size
        if(setContractIds.size() > 0)
        {
            //Map to hold the Contract Id with related Program Ids
            Map<Id, Set<Id>> mapContractIdWithProgramIds = new Map<Id, Set<Id>>();
            
            //Map to hold the Contract Id with related Account Ids
            Map<Id, Set<Id>> mapContractIdWithAccIds = new Map<Id, Set<Id>>();
            
            //SOQL on Program Subscription
            for(SBQQ__Subscription__c sub : [Select Id, SBQQ__Contract__c, Program__c, SBQQ__Account__c From SBQQ__Subscription__c Where SBQQ__Contract__c IN : setContractIds AND RecordType.DeveloperName = 'Program' AND Program__c != null])
            {
                //Check Contract Id in map
                if(!mapContractIdWithProgramIds.containsKey(sub.SBQQ__Contract__c))
                    mapContractIdWithProgramIds.put(sub.SBQQ__Contract__c, new Set<Id>());
                
                //Add Program
                mapContractIdWithProgramIds.get(sub.SBQQ__Contract__c).add(sub.Program__c);
                
                //Subhash Garhwal - Issue--CR10808--QA--00005099
                //Add Account Id in map
                if(!mapContractIdWithAccIds.containsKey(sub.SBQQ__Contract__c))
                    mapContractIdWithAccIds.put(sub.SBQQ__Contract__c, new Set<Id>());
                
                //Add Account
                mapContractIdWithAccIds.get(sub.SBQQ__Contract__c).add(sub.SBQQ__Account__c);     
            }
            
            //SOQL on CIA
            for(Contract_Integrated_Accounts__c cIA : [Select Id, Account__c, LOA_Contract__c From Contract_Integrated_Accounts__c Where LOA_Contract__c IN : setContractIds AND RecordType.DeveloperName = 'Standard_Contract' AND Account__c != null])
            {
                
                //Check Contract Id in map
                if(!mapContractIdWithAccIds.containsKey(cIA.LOA_Contract__c))
                    mapContractIdWithAccIds.put(cIA.LOA_Contract__c, new Set<Id>());
                
                //Add Account
                mapContractIdWithAccIds.get(cIA.LOA_Contract__c).add(cIA.Account__c);  
            }
            
            //Set to hold the unique combination
            Set<String> setAccProgramUK = new Set<String>();
          
            //Set to hold the Program Ids
            Set<Id> setProIds = new Set<Id>();
          
            //Set to hold the Account Ids
            Set<Id> setAccountIds = new Set<Id>();
          
            //Loop over contract Ids
            for(Id contId : mapContractIdWithProgramIds.keySet())
            {
                //Get all the Program Id
                setProIds.addAll(mapContractIdWithProgramIds.get(contId));
            
                //Check Contract Id in map
                if(mapContractIdWithAccIds.containsKey(contId))
                {
                    //Get all the acocunt id
                    setAccountIds.addAll(mapContractIdWithAccIds.get(contId));
              
                    //Loop over the values
                    for(Id proId : mapContractIdWithProgramIds.get(contId))
                    {
                        //Loop over account ids
                        for(Id accId : mapContractIdWithAccIds.get(contId))
                            setAccProgramUK.add(proId + '-' + accId);  
                    }  
                }
            }
            
            //Check for set size
            if(setAccProgramUK.size() > 0)
            {
                //List to update Membership
                List<Membership__c> membershipsTOUpdate = new List<Membership__c>();
            
                //Get all the memerships
                for(Membership__c mem : [Select Id, Account_Name__c, Program__c, Membership_Status_Text__c From Membership__c Where Account_Name__c IN : setAccountIds
                                         AND Program__c In : setProIds])
                {
                    //UK
                    String uK = mem.Program__c + '-' + mem.Account_Name__c;
                  
                  //Change Member Payer to Constants.MEMBER_PAYER
                    //Check key in set
                    if(setAccProgramUK.contains(uK) && mem.Membership_Status_Text__c != Constants.MEMBER_PAYER)
                    {
                        //Update status
                        mem.Membership_Status_Text__c = Constants.MEMBER_PAYER;
                
                        //Add recod in list
                        membershipsTOUpdate.add(mem);
                    }               
                }
                
                //Check for size
                if(membershipsTOUpdate.size() > 0)
                {
                    Util.BypassAllTriggers = true;
                    update membershipsTOUpdate;
                    Util.BypassAllTriggers = false;
                }
            }
        }
    }
    
    /**
     *  @description    : This method is there to populate "Active Membership Main Contact" field on associated membership records via Subscription
     *                    with the "Main Contact" value from the parent contract record.
     * 
     *  @args           : List<Contract>, map<Id, Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Saurabh Kumar - 06/06/2017 -  CR-20170403-10807 (DS114)
                        : V1.1 - Modified By Abhinav Sharma - 03/09/2018 -   CR-20180205-11984 
     **/
    public static void updateActiveMembershipMainContact(List<Contract> newContracts, map<Id, Contract> mapOldContracts){
        
        //Map of Contracts records
        Map<Id, Contract> mapContracts = new Map<Id, Contract>();

        //Processing on the new records
        for(Contract con : newContracts)
        {
            //Checking for the field value change and accordingly populating map with values
            if(mapOldContracts != null && (mapOldContracts.get(con.Id).Main_Contact__c != con.Main_Contact__c))
                mapContracts.put(con.Id, new Contract(Id = con.Id, Main_Contact__c = con.Main_Contact__c));
        }
        
        //Checking for map size
        if(mapContracts.size() > 0)
        {
            //Map of memberships
            Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();
            
            //Loop through opportunity records and populating map accordingly
            for(Membership__c member : [SELECT ID, Active_Contract_Main_Contact__c, 
                                        Active_Subscription__c, Active_Subscription__r.SBQQ__Contract__c 
                                        FROM Membership__c
                                        WHERE Active_Subscription__c != null 
                                        AND Active_Subscription__r.SBQQ__Contract__c != null
                                        AND Active_Subscription__r.SBQQ__Contract__c IN : mapContracts.keySet()])
            {
                
                //Checking for the null value and populating fields value
                /*Logic to populate the Active_Contract_Main_Contact__c has been changed - CR-20180205-11984
                Previous logic - Sync the Active_Contract_Main_Contact__c Field of Membership with the updated value of parent Contract object's Main Contact Field.
                Current Logic - Only update membership If and only if Active_Contract_Main_Contact__c is blank
                */
                if(mapContracts.get(member.Active_Subscription__r.SBQQ__Contract__c) != null)
                {
                    //if(member.Active_Contract_Main_Contact__c != mapContracts.get(member.Active_Subscription__r.SBQQ__Contract__c).Main_Contact__c)
                    if(member.Active_Contract_Main_Contact__c == null )
                        mapMembership.put(member.Id, new Membership__c(Id = member.Id , Active_Contract_Main_Contact__c =  mapContracts.get(member.Active_Subscription__r.SBQQ__Contract__c).Main_Contact__c, Active_Membership_Main_Con_Updated_Date__c = date.today() ));    
                }                               
            }
            
            //Checking map for size value
            if(mapMembership.values().size() > 0)
            {
                Util.BypassAllTriggers = true;
                update mapMembership.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    /**
     *  @description    : In the new process, the Invoice Contact will be stored at both the Std Contract level and the Program Subscription level.
     *                    The Contact at the Std Contract level will be the main/default invoice contact, and will initially be copied to the Program
     *                    Subscription records.  The Invoice Contact on the Program Subscription record can then be changed to a different value and
     *                    maintained separately. And used to update the other contract fields
     * 
     *  @args           : List<Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - 06/06/2017 -  CR-20170403-10807
     *                    V1.1 - Modified By - Deepak Kumar - 07/14/2017 - Convert the existing process builder logic into apex code (Issue--CR10808--QA--00004991)
     *                    V1.2 - Modified By - Deepak Kumar - 08/23/2017 - Issue--CR11094--UAT--00005371
     *
     **/
    public static void populateInitalValues(List<Contract> contracts) {
        
        //Set to hold the opportunity Id
        Set<Id> setOpportunityIds = new Set<Id>();
        
        //V1.1 - Modified By - Deepak Kumar - 07/14/2017
        //Set to hold the account Id
        Set<Id> setAccountIds = new Set<Id>();
        
        //V1.2 - Modified By - Deepak Kumar - 07/23/2017
        //Set to hold the proposal Id
        Set<Id> setProposalIds = new Set<Id>();
        
        //Loop over the Contract
        for(Contract cont : contracts)
        {
            //Check for Opportunity
            if(cont.SBQQ__Opportunity__c != null)
                setOpportunityIds.add(cont.SBQQ__Opportunity__c);   
                
            //Check for the Account 
            if(cont.AccountId != null)
                setAccountIds.add(cont.AccountId);
                
            //Check for the Proposal 
            if(cont.SBQQ__Quote__c != null) 
               setProposalIds.add(cont.SBQQ__Quote__c);     
                
        }
        
        //Check for Opportunity
        if(setOpportunityIds.size() > 0)
        {
            
            //Map to hold the Opportunity
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([Select Id, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c, SBQQ__PrimaryQuote__r.Invoice_Contact__c, 
                                                                              SBQQ__Contracted__c, StageName, RecordType.DeveloperName, RecordTypeId, Pricebook2Id, SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses__c,
                                                                              SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses_Comments__c, Original_Opportunity_RecordTypeId__c
                                                                              From Opportunity Where Id In : setOpportunityIds AND SBQQ__PrimaryQuote__c != null]);
            
            //Loop over the Contrat
            for(Contract cont : contracts)
            {
                
                //Check for Opportunity
                if(cont.SBQQ__Opportunity__c != null && mapOpportunities.containsKey(cont.SBQQ__Opportunity__c))
                {
                    
                    //Set values
                    cont.Main_Contact__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
                    cont.Invoice_Contact__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.Invoice_Contact__c;
                }
                
                //Added the logic of 'updateAmendmentsFieldonContract' method to reduce the SOQL query
                //Check map contains key
                if(mapOpportunities.containsKey(cont.SBQQ__Opportunity__c) && mapOpportunities.get(cont.SBQQ__Opportunity__c) != null &&
                   CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES.contains(mapOpportunities.get(cont.SBQQ__Opportunity__c).RecordType.DeveloperName))
                {
                    
                    //Populate opportunity Record Type Id
                    cont.SBQQ__AmendmentOpportunityRecordTypeId__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).Original_Opportunity_RecordTypeId__c;
                    
                    //Populate Renewal Behaviour
                    cont.SBQQ__AmendmentRenewalBehavior__c = CPQConstants.CONTRACT_AMENDMENT_RENEWAL_BEHAVIOR;
        
                    //Populate Opportunity Stage
                    //if(mapOfopportunities.get(contract.SBQQ__Opportunity__c).StageName == CPQConstants.CONTRACT_AMENDMENT_OPPORTUNITY_STAGE)
                        //contract.SBQQ__AmendmentOpportunityStage__c = CPQConstants.CONTRACT_AMENDMENT_OPPORTUNITY_STAGE;
                    
                    //V_2.3 - Modified By - Saurabh Kumar - 06/13/2017 - Condition is changed. No need to match Pricebook on Contract and Opportunity
                    //Check if Original Opportunity is having Price book then populate SBQQ__AmendmentPricebookId__c
                    if(mapOpportunities.containsKey(cont.SBQQ__Opportunity__c) && mapOpportunities.get(cont.SBQQ__Opportunity__c).Pricebook2Id != null )
                        cont.SBQQ__AmendmentPricebookId__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).Pricebook2Id;
                                       
                    //V_1.7 - Updated by - Subhash Garhwal - 05/30/2017 - CR-20170403-10807 - Auto Populate Fields Non-Standard Clauses/Non-Standard Clauses Comments
                    if(mapOpportunities.get(cont.SBQQ__Opportunity__c).SBQQ__Contracted__c) {
                        cont.Non_Standard_Clauses__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses__c ;
                        cont.Non_Standard_Clauses_Comments__c = mapOpportunities.get(cont.SBQQ__Opportunity__c).SBQQ__PrimaryQuote__r.LOA_Non_Standard_Clauses_Comments__c;
                    }
                } 
            }
        }
        
        //V1.1 - Modified By - Deepak Kumar - 07/14/2017 - Start here 
        //Check for the Account 
        if(setAccountIds.size() > 0)
        {
            
            //Map to hold the Account
            Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Primary_Address_Line_1__c, Primary_Address_Line_2__c, Primary_Address_Line_3__c, Primary_City__c,
                                                                 Primary_Country__c, Primary_Postal_Code__c,Primary_State_Province__c FROM Account
                                                                 WHERE Id IN : setAccountIds]);
            
            //Loop over the Contrat records
            for(Contract cont : contracts)
            {
                
                //Check for Account
                if(cont.AccountId != null && mapAccounts.containsKey(cont.AccountId))
                {
                    
                    //Set values
                    cont.Primary_Address_Line_1__c = mapAccounts.get(cont.AccountId).Primary_Address_Line_1__c;
                    cont.Primary_Address_Line_2__c = mapAccounts.get(cont.AccountId).Primary_Address_Line_2__c;
                    cont.Primary_Address_Line_3__c = mapAccounts.get(cont.AccountId).Primary_Address_Line_3__c;
                    cont.Primary_City__c =  mapAccounts.get(cont.AccountId).Primary_City__c;
                    cont.Primary_Country__c = mapAccounts.get(cont.AccountId).Primary_Country__c;
                    cont.Primary_Postal_Code__c = mapAccounts.get(cont.AccountId).Primary_Postal_Code__c;
                    cont.Primary_State_Province__c = mapAccounts.get(cont.AccountId).Primary_State_Province__c;
                }
            }
        }
        //V1.1 - Modified By - Deepak Kumar - 07/14/2017 - stop here
        //V1.2 - Modified By - Deepak Kumar - 08/23/2017 - Start here 
        //Check for the setProposalIds set size 
        if(setProposalIds.size() > 0)
        { 
            
            //Map to hold the Proposal 
            Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>([SELECT Id, Invoice_Contact__c, SBQQ__PrimaryContact__c, SBQQ__PrimaryContact__r.Name,  PrimaryContactEmail__c, PrimaryContactTitle__c
                                                                                FROM SBQQ__Quote__c Where Id IN : setProposalIds AND Invoice_Contact__c = null AND SBQQ__PrimaryContact__c != null]);
            
            //Loop over the Contrat records
            for(Contract cont : contracts)
            {
                
                //Check for Account
                if(cont.SBQQ__Quote__c != null && mapProposals.containsKey(cont.SBQQ__Quote__c))
                {
                    
                    //Set values 
                    cont.Invoice_Contact__c = mapProposals.get(cont.SBQQ__Quote__c).SBQQ__PrimaryContact__c;
                    cont.CustomerSignedId =  mapProposals.get(cont.SBQQ__Quote__c).SBQQ__PrimaryContact__c;
                    
                    //Subhash Garhwal - 08/31/2017 - Issue--CR11062--QA--00005610 - added truncate for CustomerSignedTitle field.
                    if(String.isNotBlank(mapProposals.get(cont.SBQQ__Quote__c).PrimaryContactTitle__c))
                        cont.CustomerSignedTitle = mapProposals.get(cont.SBQQ__Quote__c).PrimaryContactTitle__c.left(40);
                    else
                        cont.CustomerSignedTitle = '';    
                }
            }            
        }
        //V1.1 - Modified By - Deepak Kumar - 08/23/2017 - stop here
        
    }
    /**
     *  @description    : In this method updated renewal opportunity field on related subscription period of Contract
     * 
     *  @args           : List<Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - 06/06/2017 -  CR-20170403-10807
     *			: V1.1 - Commented Out By Mahendra Swarnkar - CR-20200505-14016
     **/
    /*public static void updateRenewalOpportunityOnSubscriptionPeriod(List<Contract> contracts, map<Id, Contract> mapOldContracts ) {

        //Set to hold contract id 
        Set<Id> setContractIds = new Set<Id>();

        //Lit to hold Subscription period
        List<Subscription_Period__c> subscriptionPeriods =  new List<Subscription_Period__c>();

        //Loop through contract
        for(Contract contract : contracts) {

            //Check for condition
            if(contract.SBQQ__RenewalOpportunity__c != null 
                    &&(mapOldContracts == null || mapOldContracts.get(contract.Id).SBQQ__RenewalOpportunity__c != contract.SBQQ__RenewalOpportunity__c))
                setContractIds.add(contract.Id);
        }

        //Check the size of Contract
        if(setContractIds.Size() > 0 ) {

            //Loop through related Subscription period
            for(Subscription_Period__c subPeriod :[Select Id, contract__c, contract__r.SBQQ__RenewalOpportunity__c, contract__r.SBQQ__RenewalOpportunity__r.Close_Date__c,
                                                    contract__r.SBQQ__RenewalOpportunity__r.Projection_Liklihood__c, 
                                                    contract__r.SBQQ__RenewalOpportunity__r.Primary_Reason_Lost__c,
                                                    contract__r.SBQQ__RenewalOpportunity__r.Secondary_Reason_Lost__c,
                                                    contract__r.SBQQ__RenewalOpportunity__r.Anticipated_Float_Loss__c,
                                                    contract__r.SBQQ__RenewalOpportunity__r.Reason_for_Float__c,
                                                    Renewal_Opportunity__c, Projection_Likelihood__c, 
                                                    Primary_Reason_Lost__c, Anticipated_Float_Loss__c, Reason_for_Float__c
                                                    From Subscription_Period__c 
                                                    Where contract__c IN: setContractIds AND Renewal_Opportunity__c != null]) {
                                                        
                //Put value of renewal opportunity
                //Updated by Saurabh Kumar - 07/17/2017 - Issue--CR10808--QA--00005011 - Code commented because Renewal_Opportunity__c type is updated from lookup to formula 
                //subPeriod.Renewal_Opportunity__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__c;
                subPeriod.Projection_Likelihood__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Projection_Liklihood__c;
                subPeriod.Primary_Reason_Lost__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Primary_Reason_Lost__c; 
                subPeriod.Secondary_Reason_Lost__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Secondary_Reason_Lost__c;
                subPeriod.Anticipated_Float_Loss__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Anticipated_Float_Loss__c;
                subPeriod.Reason_for_Float__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Reason_for_Float__c;

                //Check for subscription Period close date
                if(subPeriod.Close_Date__c == null)
                    subPeriod.Close_Date__c = subPeriod.contract__r.SBQQ__RenewalOpportunity__r.Close_Date__c;

                //Record to list
                subscriptionPeriods.add(subPeriod);
            }

            //Check the size of list 
            if(subscriptionPeriods.Size() > 0) {

                //Bypassing triggers
                Util.byPassAllTriggers = true;

                //Update subscription period
                update subscriptionPeriods;

                //Enabling triggers
                Util.byPassAllTriggers = false;             
            }
        }
    } */  
    
    /**
     *  @description    : In this method updated renewal opportunity field on related subscription period of Contract
     * 
     *  @args           : List<Contract>, Map<Id, Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - 06/20/2017 -  Issue--CR10808--QA--00004686
     *
     **/    
     //Logic of the method is moved to 'syncNegotiatedBy' this method to reduce the SOQL query
    /*public static void validateContractType(List<Contract> contracts, Map<Id, Contract> mapOldContracts) {
        
        //Set to hold the Opportunity Id
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over to Contract
        for(Contract cont : contracts) {
            
            //Check for Opportunity
            if(cont.SBQQ__Opportunity__c != null && (mapOldContracts == null || cont.SBQQ__Opportunity__c != mapOldContracts.get(cont.Id).SBQQ__Opportunity__c))
                setOppIds.add(cont.SBQQ__Opportunity__c);   
        }
        
        //Check for set size
        if(setOppIds.size() > 0) {
            
            //Map to hold MemberShip
            Map<Id,Opportunity> mapOpportunities = new Map<Id, Opportunity >([Select Id, RecordType.DeveloperName From Opportunity Where Id IN: setOppIds]);
            
            //Loop over the Contracts
            for(Contract cont : contracts) {
            
                //Check for Opportunity
                if(cont.SBQQ__Opportunity__c != null && mapOpportunities.containsKey(cont.SBQQ__Opportunity__c) && mapOpportunities.get(cont.SBQQ__Opportunity__c) != null) {
                    
                    //Check source opportunity record type id
                    if(CPQConstants.SET_OPP_INITIATING_RECORDTYPES.contains(mapOpportunities.get(cont.SBQQ__Opportunity__c).RecordType.DeveloperName))
                        cont.Type__c = CPQConstants.TYPE_NBB; 
                    else if(CPQConstants.SET_OPP_CONTINUING_RECORDTYPES.contains(mapOpportunities.get(cont.SBQQ__Opportunity__c).RecordType.DeveloperName))
                        cont.Type__c = CPQConstants.Type_RENEWAL;
                }
            }
        }
    }*/
    
    /**
     *  @description    : In this method updated  Standard Contract Term (months) 
     * 
     *  @args           : List<Contract>, Map<Id, Contract>
     *  
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - Subhash Garhwal - 06/30/2017 - Issue--CR10807--QA--00004825
     *                    V1.1 - Modified - Victor Hanson - 07/19/2017 - Issue--CR10808--QA--00004805 - Asked to auto-update End date / Contract Term if Contract is Amended
     *                    V1.2 - Modified - Colin McGloin - 08/14/2017 - Issue--CR11094--QA--00005443 - Modified how the Contract Term is calculated if the End Date is the last day of Month
     *
     **/
    public static void populateContractTerm(map<Id, Contract> contracts) {
        
        //Null check
        if(groupedResults == null && contracts.Size() > 0)
            
            //get earliest start/end dates
            groupedResults = [SELECT MIN(SBQQ__StartDate__c) min, MAX(SBQQ__EndDate__c) max, SBQQ__Contract__c
                              FROM SBQQ__Subscription__c 
                              WHERE SBQQ__Contract__c IN :contracts.keySet()
                              AND Status__c != 'Dropped' AND Status__c != 'Void'
                              GROUP BY SBQQ__Contract__c];
        
        //Loop through Contracts
        for(AggregateResult ar : groupedResults)
        {
            
            //Check for condition
            if(contracts != null && contracts.containsKey((string)ar.get('SBQQ__Contract__c')))
            {
                
                //set the earliest Start date and latest End date based on the related active Subscriptions
                Contract contract = contracts.get((string)ar.get('SBQQ__Contract__c'));
                contract.StartDate = (Date)ar.get('min');
                contract.EndDate = (Date)ar.get('max');
                
                //Variable for holding the ContractTerm value
                Integer contactTermValue;
                
                //Added by Colin McGloin - Issue--CR11094--QA--00005443
                Integer lastDayOfMonth = Date.daysInMonth((contract.EndDate).Year(), (contract.EndDate).month());
                
                if ((contract.EndDate).Day() == lastDayOfMonth)
                {
                    
                    //If it's the last day of the month, add an extra month to capture the last month since it's short of a full month
                    contactTermValue = contract.StartDate.monthsBetween(contract.EndDate)+1;
                    
                } else
                {
                    
                    //Calculate our months normally
                    contactTermValue = contract.StartDate.monthsBetween(contract.EndDate);

                }
                
                //Check for value
                if(contactTermValue == null || contactTermValue <= 0)
                {
                    
                    //Populate the value
                    contract.contractTerm = 1;
                } else
                {
                    
                    //Populate the contractTerm value
                    contract.contractTerm = contactTermValue;
                }
            }
        }
    } 
    
    /**
     *  @description    : This Method is used to Populate the renewal opportunity on Contract ABC
     * 
     *  @args           : List<Contract>, Map<Id, Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created - 
     *                    
     **/
    public static void updateContractABCRenewalOpportunity(List<Contract> newContracts, Map<Id, Contract> mapoldContracts) {
    
        //Set to hold the Contract Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop through the new Contract List
        for(Contract newContract : newContracts)
        {
            //Check for condition
            if(newContract.SBQQ__RenewalOpportunity__c != mapoldContracts.get(newContract.Id).SBQQ__RenewalOpportunity__c)
                setContractIds.add(newContract.Id);    
        }
    
        //Check for contracts
        if(setContractIds.size() > 0)
        {
            //Map to update the Contract ABC
            Map<Id, Contract__c> mapContractsABC = new Map<Id, Contract__c>();
            
            //SOQL over the Program Subscription
            for(SBQQ__Subscription__c proSub : [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, Shadow_Contract_ABC__c From SBQQ__Subscription__c
                                                Where SBQQ__Contract__c IN : setContractIds AND Shadow_Contract_ABC__c != null
                                                AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM])
            {
                
                //Update Renewal Opportunity on Contract ABC
                mapContractsABC.put(proSub.Shadow_Contract_ABC__c, new Contract__c(Id = proSub.Shadow_Contract_ABC__c, Contract_Renewal_Opportunity__c = proSub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c));    
            }
            
            //Check for map size
            if(mapContractsABC.size() > 0)
            {
                
                //Bypass Trigger
                Util.BypassAllTriggers = true;
                
                //Update
                update mapContractsABC.values();
                 
                //Bypass Trigger
                Util.BypassAllTriggers = false;        
            }
        }
    }
    
    /**
     *  @description    : This Method is used to create the junction object 'ContentDocumentLink' records between Proposal and contract
     * 
     *  @args           : List<Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 Created By - Subhash Garhwal - 08/06/2018 - Issue--CR11980--QA--00008160 
     *                    
     **/
    public static void createContentDocumentLink(List<Contract> newContracts) {
        
        //Map to hold the Proposal Ids and their ContentDocument Ids
        Map<Id, Set<Id>> mapOfProposalIdsAndContentDocumentIds = new Map<Id, Set<Id>>();
        
        //Set to hold the primary Proposal Ids
        Set<Id> primaryProposalIds = new Set<Id>();
        
        //List to hold the ContentDocumentLink to be inserted
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        //Loop over the contract
        for(Contract con : newContracts)
        {
            
            //Check for proposal
            if(con.SBQQ__Quote__c != null)
                primaryProposalIds.add(con.SBQQ__Quote__c);
            
        }      
        //VH 9/25/18: fixed an issue where loading historical standard contracts threw an error when no proposal is related
        if (primaryProposalIds.size() > 0)
        {
            //Loop over the Primary Proposal
            for(ContentDocumentLink cDL : [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN : primaryProposalIds])
            {
                //Check for Proposal Ids
                if(!mapOfProposalIdsAndContentDocumentIds.containsKey(cDL.LinkedEntityId))
                {
                    //Put values into the map
                    mapOfProposalIdsAndContentDocumentIds.put(cDL.LinkedEntityId, new Set<Id>());  
                    mapOfProposalIdsAndContentDocumentIds.get(cDL.LinkedEntityId).add(cDL.ContentDocumentId);
                    
                } else 
                {
                    
                    //Put values into the map
                    mapOfProposalIdsAndContentDocumentIds.get(cDL.LinkedEntityId).add(cDL.ContentDocumentId);
                }  
            }
        }
        
        //Loop over the newContracts
        for(Contract Contract : newContracts)
        {
            
            //Check for Proposal
            if(mapOfProposalIdsAndContentDocumentIds.containsKey(Contract.SBQQ__Quote__c))
            {
                //Loop over the ContentDocument Ids
                for(Id ContentDocumentId : mapOfProposalIdsAndContentDocumentIds.get(Contract.SBQQ__Quote__c))
                {
                    //Add values into the list
                    contentDocumentLinks.add(new contentDocumentLink(ContentDocumentId = ContentDocumentId, LinkedEntityId = Contract.Id, ShareType ='V'));
                }
            }
        }
        
        //Size check
        if(contentDocumentLinks.size() > 0)
        {
            //Bypass Trigger
            Util.BypassAllTriggers = true;
            
            //upsert contentDocumentLinks
            upsert contentDocumentLinks;
            
            //Bypass Trigger
            Util.BypassAllTriggers = false;   
        }
    }
    
     /**
     *  @description    : This Method is used to populate Contract fields from Proposals
     * 
     *  @args           : List<Contract>
     * 
     *  @return         : void
     * 
     *  @revision log   : V1.0 - Created By - Subhash Garhwal - 08/13/2018 - CR-20180515-12225
     * 			  V1.1 - Modified By - Colin McGloin - 05/20/2020 - CR-20200518-14066 - Added in mapping for three fields - Member Signed By, Member Signed Date, Member Signed Title
     *                    
     **/
    public static void populateFieldsOnContract(List<Contract> newContracts) {
        
        //Map to hold the Proposal Ids and Contract Ids
        Set<Id> setOfProposalIds = new Set<Id>();
        
        //Loop over the new Contracts
        for(Contract con : newContracts)
        {
            //Check for Proposal 
            if(con.SBQQ__Quote__c != null)
            {
                //Add value into the set
                setOfProposalIds.add(con.SBQQ__Quote__c);
            }
        }
        
        //Query Over the Proposals
        Map<Id, SBQQ__Quote__c> mapOfProposals = new Map<Id, SBQQ__Quote__c>([Select Id, Invoice_Frequency__c, Invoice_Frequency_Override__c, Set_Invoice_Date__c, InitialPaymentAmount__c,
                                                                              Invoice_Contact__c, Invoice_Contact_Title__c, Invoice_Contact_Email__c, Signer_Contact__c, Signer_Contact_Title__c, SBQQ__Opportunity2__r.Contract_Signature_Date__c, SBQQ__PrimaryContact__c,
                                                                              PrimaryContactTitle__c,Legacy_YV_Autorenew__c,Autorenewal_Notification_Date__c From SBQQ__Quote__c
                                                                              Where Id IN : setOfProposalIds]);
        
        //Loop over new Contracts
        for(Contract con : newContracts)
        {
            //Check for Quote
            if(con.SBQQ__Quote__c != null && mapOfProposals.containsKey(con.SBQQ__Quote__c) && mapOfProposals.get(con.SBQQ__Quote__c) != null)
            {
                
                /*//Check for Invoice_Frequency_Override__c on Proposal
                if(mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Frequency_Override__c != null)
                con.Invoicing_Arrangement__c = mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Frequency_Override__c;
                
                //Check for Invoice_Frequency__c on Proposal  
                else */
                if(mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Frequency__c != null)
                    con.Invoicing_Arrangement__c = mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Frequency__c;
                
                //Check for Set_Invoice_Date__c on Proposal    
                if(mapOfProposals.get(con.SBQQ__Quote__c).Set_Invoice_Date__c != null)
                    con.First_Invoice_Date__c = mapOfProposals.get(con.SBQQ__Quote__c).Set_Invoice_Date__c;
                
                //Check for InitialPaymentAmount__c on Proposal  
                if(mapOfProposals.get(con.SBQQ__Quote__c).InitialPaymentAmount__c != null)
                    con.Initial_Payment_Amount__c = mapOfProposals.get(con.SBQQ__Quote__c).InitialPaymentAmount__c;
                
                //Check for Invoice_Contact__c on Proposal  
                if(mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Contact__c != null)
                    con.Invoice_Contact__c = mapOfProposals.get(con.SBQQ__Quote__c).Invoice_Contact__c;
                
                //Added By Subhash -04/02/2021 - CR-20210402-15054 - checking for Signer_Contact__c instead of "SBQQ__PrimaryContact__c" 
                //Check for Signer_Contact__c on Proposal  
                if(mapOfProposals.get(con.SBQQ__Quote__c).Signer_Contact__c != null)
                    con.CustomerSignedId = mapOfProposals.get(con.SBQQ__Quote__c).Signer_Contact__c;
                
                //Added By Subhash -04/02/2021 - CR-20210402-15054 - a) checking for Signer_Contact_Title__c instead of "PrimaryContactTitle__c" and then b) truncate the value of Signer_Contact_Title__c upto 40 character Limit to populate the CustomerSignedTitle field 
                //Check for Signer_Contact_Title__c on Proposal  
                if(String.isNotBlank(mapOfProposals.get(con.SBQQ__Quote__c).Signer_Contact_Title__c))
                    con.CustomerSignedTitle = mapOfProposals.get(con.SBQQ__Quote__c).Signer_Contact_Title__c.left(40);
                
                //Check for Contract_Signature_Date__c on related Opportunity  
                if(mapOfProposals.get(con.SBQQ__Quote__c).SBQQ__Opportunity2__r.Contract_Signature_Date__c != null)
                    con.CustomerSignedDate = mapOfProposals.get(con.SBQQ__Quote__c).SBQQ__Opportunity2__r.Contract_Signature_Date__c;
                
                //Check for Legacy_YV_Autorenew__c on Proposal  
                if(mapOfProposals.get(con.SBQQ__Quote__c).Legacy_YV_Autorenew__c != null)
                    con.Autorenew__c = mapOfProposals.get(con.SBQQ__Quote__c).Legacy_YV_Autorenew__c;
                
                //Check for Autorenewal_Notification_Date__c on Proposal  ,
                if(mapOfProposals.get(con.SBQQ__Quote__c).Autorenewal_Notification_Date__c != null)
                    con.Autorenewal_Notification_Date__c = mapOfProposals.get(con.SBQQ__Quote__c).Autorenewal_Notification_Date__c;
                
            }
        }
    }
    
    /**
     *  @description    :   This Method is used to update the contact.Contract Primary, if that contact is stamped on any Contract's Main Contact
     *
     *  @args           :   List of new Contract and Map<Id, Contract>
     *
     *  @return         :   void
     * 
     *  Version         :  V1.1 - Dipesh Gupta - CR-20190111-12831
     **/
    public Static void updateContactPrimaryContract(List<Contract> newContracts, Map<Id, Contract> oldMapContracts) {
      
        //Set to hold the Contact Id (Opportunity.Main_Contact__c)
        Set<Id> setContactIds = new Set<Id>();
           
        //loop on the Opportunity.
        for(Contract contract : newContracts != null ? newContracts : oldMapContracts.values())
        {
            //check for Insert, Update, delete case. 
            if(oldMapContracts == null || (oldMapContracts.get(contract.Id).Main_Contact__c != contract.Main_Contact__c 
                                           || newContracts == null))
            {
                
                //Fill the set with the Main contact Id.
                setContactIds.add(contract.Main_Contact__c);
                
                //Check for the Main Contact Change so we can make the relevent updates on the older Contact as well. 
                if(oldMapContracts != null && oldMapContracts.get(contract.Id).Main_Contact__c != contract.Main_Contact__c)
                    setContactIds.add(oldMapContracts.get(contract.Id).Main_Contact__c);
            }
        }
        
        //Checking for the size of set.
        if(setContactIds.size() > 0)
            //Calling method. 
            updateContact(setContactIds);
     }
    
      /**
     *  @description    :   This Method is used to update the contact.Contract Primary, if that contact is stamped on any Contract's Main Contact
     *
     *  @args           :  Set of Contact Id
     *
     *  @return         :   void
     * 
     *  Version         :  V1.1 - Dipesh Gupta - CR-20190111-12831
     **/
    public Static void updateContact(Set<Id> setContactIds)
    {
        //List to hold the Contract. 
        List<Contact> contactsToBeUpdated = new List<Contact>();
         
        //Check for the set size.
        if(setContactIds.size() > 0)
        {
            /*Query on the Contact and fetch the child Contract from here to check is there 
            a single contract that is active and contact is stamped on contract main Contact.*/
            for(Contact con : [Select Id, Contract_Primary__c, Contact_Status__c,
                               (Select Id From Contracts2__r where StatusCode = 'Activated') From Contact where Id IN: setContactIds])
            {
                
                //Boolean to change conditionally                   
                Boolean isContractPrimary = false;
                
                //Check for the size of contract List associaated with contract.
                if(con.Contracts2__r != null && con.Contracts2__r.size() > 0 && con.Contact_Status__c == 'Active')
                {
                    isContractPrimary = true;    
                }
                
                //Check if the values are mismatched. 
                if(isContractPrimary != con.Contract_Primary__c)
                    //Adding the values to the List.
                    contactsToBeUpdated.add(new Contact(Id = con.Id, Contract_Primary__c = isContractPrimary));
            }
        }
        
        //Check for the list size. 
        if(contactsToBeUpdated != null && contactsToBeUpdated.size() > 0)
        {
            //Bypassing Trigger
            Util.BypassAllTriggers = true;
            update contactsToBeUpdated;
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :  This Method is used to populate MSA fields on institution.
     * 
     *  @args           :   List<Contract>
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.0 Created By - Subhash Garhwal - 05/22/2018 
     * 			    V1.1 Modified by - Subhash Garhwal -   CR-20200619-14207 - Added check for "MSA Not Needed" , If �MSA Not Needed� is true, do not automatically update any MSA information.
     *                    
     **/
    public static void validateInstitutionMSAStandardContract(List<Contract> newContracts) {
      
        //Map to hold the Opportunity Id with Contract Id
        Map<Id,Id> mapProposalIdWithContractId = new Map<Id, Id>();
        
        //Set to hold the Contract Ids.
        Set<Id> setContractId = new Set<Id>();
        
        //Loop over the Proposals
        for(Contract cont : newContracts)
        {
            setContractId.add(cont.Id);
            
            //Check for conditions
            if(cont.SBQQ__Quote__c != null)
                mapProposalIdWithContractId.put(cont.SBQQ__Quote__c, cont.Id);
        }
        
        //Check for map size
        if(mapProposalIdWithContractId.size() > 0 )
        {
            
            //Map to account to update.
            Map<Id, Account> mapAccountsToBeUpdate = new Map<Id,Account>();
            
            Map<Id, Set<Id>> mapContractWithAmendedProposalIdSet = new Map<Id, Set<Id>>(); 
            
            Map<Id, SBQQ__Quote__c> mapProposalsToBeUpdate = new Map<Id, SBQQ__Quote__c>(); 

            //Subhash Garhwal -   CR-20210811-15348 - get lated ContentDocumentLink for MSA assignment
            List<ContentDocumentLink> latestContentDocument = [ SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType, ContentDocument.Title,ContentDocument.LastModifiedDate, ContentDocument.FileType 
                                                                FROM ContentDocumentLink 
                                                                WHERE LinkedEntityId IN : mapProposalIdWithContractId.keySet() 
                                                                Order By ContentDocument.LastModifiedDate DESC LIMIT 1 
                                                            ];
            Map<Id, ContentDocumentLink> proposalToContentDocumentMap = new Map<Id, ContentDocumentLink>();
            if( latestContentDocument != null && latestContentDocument.size() > 0 )
            {
                proposalToContentDocumentMap.put( latestContentDocument[0].LinkedEntityId, latestContentDocument[0] );
            }

            
            //SOQL over the Proposals
            for(SBQQ__Quote__c proposal : [SELECT Id, SBQQ__MasterContract__c, SBQQ__Type__c, Contract_Document_Creation_Date__c, LOA_PDF_Document_ID__c,LOA_PDF_Document_File_Name__c, SBQQ__Opportunity2__c, SBQQ__Account__c,MSA_Date__c,  
                                           SBQQ__Account__r.MSA_Standard_Contract__c,SBQQ__Account__r.MSA_Date__c, Member_Template__c,MSA_Not_Needed__c,
                                           (SELECT Id FROM CPQ_Contract_Exceptions__r LIMIT 1) 
                                           FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true AND SBQQ__Account__c != null AND Contracted__c = true 
                                           AND (ID IN : mapProposalIdWithContractId.keySet() OR (SBQQ__Type__c = 'Amendment' AND SBQQ__MasterContract__c != null AND SBQQ__MasterContract__c IN : setContractId)) Order BY CreatedDate DESC] )
            {
                //Subhash Garhwal -   CR-20200619-14207 - Added check for "MSA Not Needed"
                if(proposal.Member_Template__c == false && proposal.MSA_Not_Needed__c == false && (proposal.SBQQ__Account__r.MSA_Date__c == null || (proposal.CPQ_Contract_Exceptions__r != null && proposal.CPQ_Contract_Exceptions__r.size() > 0 )))
                {
                    
                    Account acc = new Account(Id = proposal.SBQQ__Account__c);
                    if( proposalToContentDocumentMap.size() > 0 && proposalToContentDocumentMap.containsKey(proposal.Id) )
                    {
                        //Subhash Garhwal -   CR-20210811-15348 - get lated ContentDocumentLink for MSA assignment
                        ContentDocumentLink contentDocumentData = proposalToContentDocumentMap.get( proposal.Id );
                        acc.MSA_Date__c =  Date.valueOf( contentDocumentData.ContentDocument.LastModifiedDate );
                        acc.MSA_Link_Id__c = contentDocumentData.ContentDocumentId;
                        acc.MSA_Link_File_Name__c = contentDocumentData.ContentDocument.Title;
                        acc.MSA_Proposal__c = proposal.Id;
                    }
                    /*
                    acc.MSA_Date__c = proposal.Contract_Document_Creation_Date__c;
                    acc.MSA_Link_Id__c = proposal.LOA_PDF_Document_ID__c;
                    acc.MSA_Link_File_Name__c = proposal.LOA_PDF_Document_File_Name__c;
                    acc.MSA_Proposal__c = proposal.Id;
                    */
                    
                    mapProposalsToBeUpdate.put(proposal.Id,new SBQQ__Quote__c(Id = proposal.Id, MSA_Date__c = proposal.Contract_Document_Creation_Date__c));
                    
                    //Check Amendment case
                    if(proposal.SBQQ__MasterContract__c != null && proposal.SBQQ__Type__c == 'Amendment')
                    {
                        
                        if(!mapContractWithAmendedProposalIdSet.containsKey(proposal.SBQQ__MasterContract__c))
                            mapContractWithAmendedProposalIdSet.put(proposal.SBQQ__MasterContract__c, new Set<ID>());
                        else
                            mapContractWithAmendedProposalIdSet.get(proposal.SBQQ__MasterContract__c).add(proposal.Id);
                        
                        acc.MSA_Standard_Contract__c = proposal.SBQQ__MasterContract__c;
                        
                        mapAccountsToBeUpdate.put(acc.Id, acc);
                        
                    } else
                    {
                        //Check if Contract is available for proposal
                        if(mapProposalIdWithContractId.containsKey(proposal.Id) 
                           && !mapContractWithAmendedProposalIdSet.containsKey(mapProposalIdWithContractId.get(proposal.Id)) )
                        {
                            
                            acc.MSA_Standard_Contract__c = mapProposalIdWithContractId.get(proposal.Id);
                            
                            //Populate the Map
                            mapAccountsToBeUpdate.put(acc.id, acc);
                        }
                    }
                }
            }
            
            //Disable all triggers
            Util.BypassAllTriggers = true;
                
            //check for size and Update Account.
            if(mapAccountsToBeUpdate.size() > 0 && mapAccountsToBeUpdate.values() != null && mapAccountsToBeUpdate.values().size() > 0)
                update mapAccountsToBeUpdate.values();
            
            //check for size and Update Account.
            if(mapProposalsToBeUpdate.size() > 0 && mapProposalsToBeUpdate.values() != null && mapProposalsToBeUpdate.values().size() > 0)
                update mapProposalsToBeUpdate.values();
            
            //Enable all triggers
            Util.BypassAllTriggers = false;
        }
    }
    /**
     *  @description    :  This Method is used to call A future job which will populate Invoice Contact fields On CPQ Subscription on update of Std. Contract.
     * 
     *  @args           :   List<Contract> newContracts, Map<Id, Contract> oldMapContracts
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.0 Created By - Dipesh Gupta - 12/15/2019 - CR-20191029-13473
     *                    
     **/
    public static void populateInvoiceContactOnCPQSub(List<Contract> newContracts, Map<Id, Contract> oldMapContracts) {
        
        //Check for Update case
        if(newContracts.size() > 0 && newContracts != null && oldMapContracts.size() > 0 && oldMapContracts != null)
        {
            Set<Id> contractIds = new Set<Id>();
            //Loop over the Proposals
            for(Contract cont : newContracts)
            {
                //Invoice Contract Update check 
                if(cont.Invoice_Contact__c != oldMapContracts.get(cont.Id).Invoice_Contact__c){
                    
                    //Adding Contracts Ids into set
                    contractIds.add(cont.Id);
                }
            }
            
            //Null check
            if(contractIds.size() > 0 && contractIds != null){
                
                //Calling method
                populateInvoiceContactOnCPQSubscriptions(contractIds);
            }
        }
    }
    /**
     *  @description    :  This Method is used to populate Invoice Contact fields On CPQ Subscription on update of Std. Contract.
     * 
     *  @args           :  Set<Id> contractIds
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.0 Created By - Dipesh Gupta - 12/15/2019 - CR-20191029-13473
     * 			    V1.1 Modified By - Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass Subscription trigger's method when invoice contact updated 
     *                    
     **/
    @future
    public static void populateInvoiceContactOnCPQSubscriptions(Set<Id> contractIds) {
        
        //Null check
        if(contractIds.size() > 0 && contractIds != null)
        {
            //Map to hold the Opportunity Id with Contract Id
            Map<Id,Contract> mapContractIdWithContract = new Map<Id, Contract>();
            
            //Loop over the Proposals
            for(Contract cont : [Select Id, Invoice_Contact__c FROM Contract WHERE Id IN: contractIds])
            {
                //Invoice Contract Update check 
                if(cont.Invoice_Contact__c != null)
                {
                    //Putting Contract with Id into a Map
                    mapContractIdWithContract.put(cont.Id,cont);
                }
            }
            
            //Check for map size
            if(mapContractIdWithContract.size() > 0 )
            {
                //List to update CPQ subscription
                List<SBQQ__Subscription__c> subscriptionToBeUpdate = new List<SBQQ__Subscription__c>();   
                
                //SOQL over the CPQ Subscription
                for(SBQQ__Subscription__c sub :  [SELECT Id, Invoice_Contact__c, SBQQ__Contract__c, Shadow_Contract_ABC__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN : mapContractIdWithContract.keySet()] )
                {
                    //Contains check 
                    if(mapContractIdWithContract.containsKey(sub.SBQQ__Contract__c)){
                        
                        SBQQ__Subscription__c subscription =  new SBQQ__Subscription__c();
                        
                        subscription.Id = sub.Id;
                        
                        //Updating Invoice Contact
                        subscription.Invoice_Contact__c = mapContractIdWithContract.get(sub.SBQQ__Contract__c).Invoice_Contact__c;
                        
                        //Adding Subscriptions 
                        subscriptionToBeUpdate.add(subscription);
                    }
                }
                
                //check for size
                if(subscriptionToBeUpdate.size() > 0)
                { 
                    
                    //Modified By : Dipesh Gupta - 01/27/2020 - CR-20200116-13629 - Added Bypass flag to bypass subscription trigger's method when invoice contact updated 
                    //Marking True the flag so it can bypass subscription trigger's those methods which are not in use   
                    ContractTriggerHelper.BYPASS_ON_INVOICE_CONTACT_CHANGE = true;
                    
                    //Update subscriptions
                    update subscriptionToBeUpdate;
                }
            }
        }
    }

    //Added by mahendra Swarnkar - 11/27/2019 -CR-20191030-13484
    //Modified by Colin McGloin - 08/25/2020 - CR-20200824-14468
    public static void populateBillingScheduleStatus(List<Contract> contracts) {
        
        //Set to hold the Contract status
        Set<String> setContractStatus = new Set<String>{'In Approval Process', 'Activated_Amended', 'Amended Replaced', 'Terminated', 'Expired', 'Void', 'Activated'};
            
            //Loop over the Contract
            for(Contract cont : contracts)
        {
            
            //Check to see if the field "Create_Billing_Schedule_Header__c" has been marked as true
            if (cont.Create_Billing_Schedule_Header__c == true)
            {
                
                //Check for status
                if(setContractStatus.contains(cont.Status) && (cont.Billing_Schedule_Automated_Status__c != 'Completed' || cont.Billing_Schedule_Automated_Status__c != 'Manual Creation Needed')){
                    
                    //Set our Billing Status to be picked up in the Scheduled Batch
                    cont.Billing_Schedule_Automated_Status__c = 'Awaiting Processing';
                    
                    //Set our Create Billing Schedule Header field back to False
                    cont.Create_Billing_Schedule_Header__c = false;
                    
                }
            }
        }
    }
    
    /**
     *  @description    :  This Method is used to when create new Record of Standard Contract and scheduled batch After 15 minutes.
     * 
     *  @args           :   List<Contract> newContracts, Map<Id, Contract> oldMapContracts
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.0 Created By - Dipesh Gupta - 02/27/2020 - CR-20200221-13792(Integrate Contracts with ES Campaigns)
     *                    
     **/
    public static void createContractAndScheduledBatch(List<Contract> newContracts)
    {
        Set<Id> setOfContractIds = new Set<Id>();
        
        for(Contract cont : newContracts)
        {
            if(String.isNotBlank(cont.Batch_Status__c) && cont.Batch_Status__c == System.Label.Ready_For_Batch)
            { 
                setOfContractIds.add(cont.Id);
            }
        }
        
        if(setOfContractIds.size() > 0)
        {
            Scheduler_BatchAutomatedProjAndRelated.scheduleAfterMinutes(Integer.valueOf(System.Label.Time_Duration_For_Contract_Job_Status_Check),setOfContractIds);
        }
    }
    
    
     /**
      * 
      *  @description	:   Added method to validate the Billing schedule Periods
      *
      *  @args		:   List<Contract>, Map<Id, Contract>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.1 - Created - 06/15/2020 - Mahendra Swarnkar - CR-20200610-14172 - Before delete validate Contratany Program Subscription is having the revenue records
      * 
    **/
    public static void validateContract(List<Contract> newContractList, Map<Id, Contract> mapOldContract) {
    	
       
        set<Id> setOfContractId = new set<Id>();
        Map<Id,ABC_Revenue__c> mapOfContractWithRevenue = new Map<Id,ABC_Revenue__c>();
        
        for(Contract con : newContractList != null ? newContractList : mapOldContract.values())
        {
            if(newContractList == null && mapOldContract !=  null){
                setOfContractId.add(con.Id);
            }    
        }
        
        if(setOfContractId.size() > 0)
        {
            for(ABC_Revenue__c revenue : [select Id,Contract__c From ABC_Revenue__c
                                          WHERE Contract__c =:setOfContractId ])
            {
                mapOfContractWithRevenue.put(revenue.Contract__c,revenue);
            }
        }
        
        for(Contract con : newContractList != null ? newContractList : mapOldContract.values())
        {
            if(mapOfContractWithRevenue.containsKey(con.Id))
            {
                
                con.addError('You can not delete a contract, as revenue records are exit on this contract.');
            }
        }
    }


     /**
      * 
      *  @description	:   Added method to update the Invoice Contact on any related Billing Schedule Headers when it is changed on Contract
      *
      *  @args		:   List<Contract>, Map<Id, Contract>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V1.1 - Created - 06/16/2020 - Colin McGloin - CR-20200615-14186 - When Invoice Contact is updated on Contract, then update the related Billing Schedule Headers Invoice Contact
      * 
      **/
    public static void updateInvoiceContact (List<Contract> newContractList, Map<Id, Contract> mapOldContract) {

        //Set for storing Contract Ids
        Map<Id, Id> mapContractToContact = new Map<Id, Id> ();

        //Create a List for updating the BSH records
        List <Billing_Schedule_Header__c> bshToUpdate = new List<Billing_Schedule_Header__c>();
        List <c2g__codaInvoice__c> siToUpdate = new List <c2g__codaInvoice__c>();
        
        for(Contract con : newContractList != null ? newContractList : mapOldContract.values())
        {
            //Check to see if Invoice Contact has changed
            if(mapOldContract != null){

                //Check to see if our Contact has changed
                if (con.Invoice_Contact__c != null && con.Invoice_Contact__c != mapOldContract.get(con.Id).Invoice_Contact__c){

                    //Add Id to Contract Set
                    mapContractToContact.put(con.Id, con.Invoice_Contact__c);

                }

            }

        }

        //Check to see if we have Contracts
        if (mapContractToContact.size() > 0)
        {
            
            //Query for our Billing Schedule Headers
            List<Billing_Schedule_Header__c> billSchedHeaders = [SELECT Id, Name, Standard_Contract__c, Invoice_Contact__c 
                                                                 FROM Billing_Schedule_Header__c
                                                                 WHERE Standard_Contract__c IN :mapContractToContact.keyset()];
            
            
            List <c2g__codaInvoice__c> salesInvoices = [SELECT Id, Name, BSP_Standard_Contract__c, Invoice_Contact__c
                                                        FROM c2g__codaInvoice__c
                                                        WHERE BSP_Standard_Contract__c IN :mapContractToContact.keyset()];
            
            //Loop through the Headers
            for (Billing_Schedule_Header__c bsh: billSchedHeaders){

                //Check our record to see if it needs to be updated
                if (bsh.Invoice_Contact__c != mapContractToContact.get(bsh.Standard_Contract__c))
                {
                    
                    //Update Invoice Contact on the BSH and add to List
                    bsh.Invoice_Contact__c = mapContractToContact.get(bsh.Standard_Contract__c);
                    bshToUpdate.add(bsh);

                }

            }

            //Check to see if there are any Sales Invoices to update as well
            if (salesInvoices.size() > 0)
            {
                
                //Loop through our Sales Invoices
                for (c2g__codaInvoice__c sI : salesInvoices)
                {
                    
                    //Check our record to see if it needs to be updated
                    if (sI.Invoice_Contact__c == null || sI.Invoice_Contact__c != mapContractToContact.get(sI.BSP_Standard_Contract__c))
                    {
                        
                        //Update Invoice Contact on the BSH and add to List
                        sI.Invoice_Contact__c = mapContractToContact.get(sI.BSP_Standard_Contract__c);
                        siToUpdate.add(sI);
                        
                    }
                    
                }
            }

        }

        //Check for records to update & update if there are records
        if (bshToUpdate.size() > 0)
        {
            update bshToUpdate;
        }

        //Check for Sales Invoices to Update
        if (siToUpdate.size() > 0)
        {
            update siToUpdate;
        }
        
    }
    
    /**
      * 
      *  @description	:   Added method to update the Invoicing Arrangement on any related Subscription(Component/Program) when it is changed on Contract
      *
      *  @args		:   List<Contract>, Map<Id, Contract>
      *
      *  @return	:   void
      *
      *  @revision Log	:   V_1.0 - Added By - Mahendra Swarnkar - 08/31/2021 - CR-20201120-14707 - CPQ: Invoicing Arrangement in CPQ inconsistent at times
      * 
    **/

    public static void updateSubscriptionsInvoicingArrangement (List<Contract> newContractList, Map<Id, Contract> mapOldContract) {
        
        //Set for storing Contract Ids
        Map<Id, String> mapContractToInvoicingArrangement = new Map<Id, String> ();
        
        for(Contract con : newContractList) {
            
            //Check to see if Invoice Contact has changed
            if(mapOldContract != null && con.Invoicing_Arrangement__c != mapOldContract.get(con.Id).Invoicing_Arrangement__c){
                
                //Set Contract Id along with Invoicing Arrangement
                mapContractToInvoicingArrangement.put(con.Id, con.Invoicing_Arrangement__c);
            }
            
        }
        
        //Check to see if we have Contracts
        if (mapContractToInvoicingArrangement.size() > 0 && mapContractToInvoicingArrangement.keySet().size() > 0){
            
            List<SBQQ__Subscription__c> subscriptionsToBeUpdated = new List<SBQQ__Subscription__c>();
            //Loop through the Subscriptions
            for (SBQQ__Subscription__c subscription: [ Select SBQQ__Contract__c, Invoicing_Arrangement__c
                                                      From SBQQ__Subscription__c 
                                                      Where SBQQ__Contract__c IN :mapContractToInvoicingArrangement.keySet()
                                                      AND (RecordTypeId = :Constants.RECORD_TYPE_ID_SUBSCRIPTION_COMPONENT OR RecordTypeId = :Constants.RECORD_TYPE_ID_SUBSCRIPTION_PROGRAM)])
            {
                
                //Check our record to see if it needs to be updated
                if (mapContractToInvoicingArrangement.containsKey(subscription.SBQQ__Contract__c) &&
                    subscription.Invoicing_Arrangement__c != mapContractToInvoicingArrangement.get(subscription.SBQQ__Contract__c))
                {
                    
                    //Update Invoice Arrangement on the Subscriptions and add to List
                    subscription.Invoicing_Arrangement__c = mapContractToInvoicingArrangement.get(subscription.SBQQ__Contract__c);
                    subscriptionsToBeUpdated.add(subscription);
                }
            }
            
            //Check for records to update & update if there are records
            if (subscriptionsToBeUpdated.size() > 0)
            {
                //Bypassing triggers
                Util.byPassAllTriggers = true;
                    
                //Update cases
                update subscriptionsToBeUpdated;
                
                //Enabling triggers
                Util.byPassAllTriggers = false;
            }
        }
    }
}