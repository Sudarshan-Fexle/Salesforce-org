/**
    *  Description     :   Sched_SubscriptionPeriodCreation
    * 
    *  Created By      :      
    * 
    *  Created Date    :   
    * 
    *  Revision Logs   :   V_1.0 - Created - CR-20160224-9640
    *			   V_1.1 - Modified by VH - 12/07/2018 - added scheduleProgramPackageCreation()
    *			   V_1.2 - Modified By - Subhash Garhwal - CR-20210922-15455
    *
    **/ 
global class Sched_SubscriptionPeriodCreation implements Schedulable {
    
    private List<SBQQ__Subscription__c> subscriptions;
    private Map<Id, SBQQ__Subscription__c> mapOldSubscriptions;
    
    //Map to hold map to hold Component Subscription
    private Map<String,SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomation;
    
    //Map to hold Program Subscription Id as key and value as key
    private Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKey;
    private Set<Id> setContractIds;
    
    public Sched_SubscriptionPeriodCreation (Map<String,SubscriptionPeriodAutomationWrapper> mapUniqueKeySubscriptionPeriodAutomations, Map<Id, Set<String>> mapProgramSubscriptionwithUniqueKeys, Set<Id> setContractIds) {
        this.mapUniqueKeySubscriptionPeriodAutomation = mapUniqueKeySubscriptionPeriodAutomations;
        this.mapProgramSubscriptionwithUniqueKey = mapProgramSubscriptionwithUniqueKeys;
        this.setContractIds = setContractIds;
    }
    
    global void execute(SchedulableContext ctx) {
        
        try {
            //Get all record types of Subscription_Period__c
            Map<String, Id> mapSubscriptionPeriodRecordTypes = Util.recordtypemap(CPQConstants.OBJECT_SUBSCRIPTION_PERIOD);
            
            //Get Record Type
            String eABRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_EAB);
            String hCRecordType = mapSubscriptionPeriodRecordTypes.get(CPQConstants.SBQQ_SUBSCRIPTION_PERIOD_RECORD_TYPE_DEVELOPERNAME_HC);
            
            //Map to hold Subscription Period
            Map<String,Subscription_Period__c> mapSubscriptionPeriodToBeInserted = new Map<String,Subscription_Period__c>();
            
            //Set to hold the Opportunty Id
            Set<Id> setOppIds = new Set<Id>();
            
            //Subhash Garhwal - CR-20180131-11927
            //Flag for Pending Subscription Period
            Boolean isPendingSubscriptionPeriods = false;
            
            //Set to hold the Program Subscription Ids
            Set<Id> setProgramSubscriptions = new Set<Id>();
            
            //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 
            //Map to hold the Subscription period Id with Boolean vale if product Associated with Enrollment Services product family
            Map<Id, Boolean> mapSubscriptionIdWithESProductFamily = new Map<Id, Boolean>();
            
            //Check for size
            if(mapProgramSubscriptionwithUniqueKey.Size() > 0 ) {
                
                //Map to hold the Contract + Product with Subscription Period unique identifier
                Map<String, String> mapPreviousSubIdentifierWithSubPeriodIdentifier = new Map<String, String>();
                
                //Set to hold the Renewed contract
                Set<Id> setPreviousRenewedContracts = new Set<Id>();
                
                //Set to hold the Product Id
                Set<Id> setProductIds = new Set<Id>();
                
                //Set to hold the Contract Id
                Set<Id> setContractIds = new Set<Id>();
                
                //Modified By - Subhash Garhwal - CR-20210922-15455
                //Loop through Program Subscription
                //)8/25/2017 - Subhash Garhwal - Issue--CR10808--QA--00005222 - Removed SBQQ__Product__r.Program_Family__c field from query
                //updated By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Added SBQQ__Product__r.Family , SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Family in the query
                for(SBQQ__Subscription__c subscription : [Select Id, SBQQ__Account__c,SBQQ__EndDate__c, SBQQ__SubscriptionEndDate__c, Source_Opportunity__c, Source_Opportunity__r.SBQQ__RenewedContract__c, SBQQ__SegmentIndex__c,
                                                          SBQQ__Product__c, SBQQ__Product__r.Family , SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Family, /*SBQQ__Product__r.Program_Family__c ,*/ 
                                                          SBQQ__Contract__c, Product_Code__c, SBQQ__Contract__r.AccountId, Segment_Label_Index__c,
                                                          SBQQ__Account__r.Name, Source_Opportunity__r.RecordType.DeveloperName, Previous_Program_Subscription__c, 
                                                          Early_Termination_Date__c, Opt_Out__c, Program_Products__c From SBQQ__Subscription__c //Added Early Termination Date & Opt Out Type by Colin McGloin - Issue--CR10808--QA--00004850
                                                          Where Id IN: mapProgramSubscriptionwithUniqueKey.keySet()]) 
                {	
                    //Check unique key in map
                    if(mapProgramSubscriptionwithUniqueKey.containsKey(subscription.Id)) {
                        
                        if(subscription.SBQQ__Contract__c != null){
                            setContractIds.add(subscription.SBQQ__Contract__c);
                        }
                        //Loop over the unique key
                        for(String uK : mapProgramSubscriptionwithUniqueKey.get(subscription.Id)) {
                            
                            String key = '-1' + String.valueOf(subscription.Id);
                            
                            //Check for Renewed Contract
                            if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.SBQQ__RenewedContract__c != null && uK.endsWithIgnoreCase(key)) {
                                
                                //Add Contract id
                                setPreviousRenewedContracts.add(subscription.Source_Opportunity__r.SBQQ__RenewedContract__c);
                                
                                //Add Product Id
                                setProductIds.add(subscription.SBQQ__Product__c);
                                
                                //Modified By Mahendra - CR-20210727-15318- 08/02/2021 - Modified the Key to include the Program Subscription id as well so that in case of mutiple instances it can mapp to correct SP
                                //Create a unique key for Previous Subscription Period 
                                String previousSubPeriodUK = subscription.Source_Opportunity__r.SBQQ__RenewedContract__c + '-' + subscription.Program_Products__c + subscription.Previous_Program_Subscription__c;
                                
                                //Add subscriptions period unique indentifier with previous Sub. Period identifier
                                mapPreviousSubIdentifierWithSubPeriodIdentifier.put(previousSubPeriodUK, uK);
                            }
                            
                            //Add Program Subscription details
                            mapUniqueKeySubscriptionPeriodAutomation.get(uK).programSubscription = subscription;
                            mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = hCRecordType;
                            
                            if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.RecordType.DeveloperName.contains('HC_'))
                                mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = hCRecordType;
                            
                            else if(subscription.Source_Opportunity__c != null && subscription.Source_Opportunity__r.RecordType.DeveloperName.contains('EAB_'))
                                mapUniqueKeySubscriptionPeriodAutomation.get(uK).RecordType = eABRecordType;
                        }
                    }
                    
                    //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Starts from here
                    //Check if subscription is associated with Enrollment Services products then populate the map 
                    if((subscription.SBQQ__Product__c != null && subscription.SBQQ__Product__r.Family == 'Enrollment Services') || (subscription.SBQQ__RequiredByProduct__c!= null && subscription.SBQQ__RequiredByProduct__r.Family == 'Enrollment Services'))
                        mapSubscriptionIdWithESProductFamily.put(subscription.Id, true);
                    else
                        mapSubscriptionIdWithESProductFamily.put(subscription.Id, false);
                    //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Ends here                                          
                }
                
                /*******************      This code is to get the Renewed Contract Start  ********************/
                
                //Map to hold the Renewal Subscriotion Period from Previous Contract with new Subscription Identifier
                Map<String, Id> mapRenewalSubPeriodWithubscriptionPeriodIdentifier = new Map<String, Id>();
                
                //RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING, Stage__c
                for(Subscription_Period__c subPeriod : [Select Id, Contract__c, Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c, Program_Subscription__r.Program_Products__c,
                                                        Program_Subscription__r.SBQQ__Contract__c, Program_Subscription__r.SBQQ__Contract__r.AccountId
                                                        From Subscription_Period__c
                                                        Where Contract__c IN : setPreviousRenewedContracts AND Program_Subscription__r.SBQQ__Product__c IN : setProductIds
                                                        AND Stage__c =: CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING ORDER BY Period_Start_Date__c DESC]) 
                {
                    //Modified By Mahendra - CR-20210727-15318- 08/02/2021 - Modified the Key to include the Program Subscription id as well so that in case of mutiple instances it can mapp to correct SP
                    //Create Unique Identifier
                    String renewalUK = subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__r.Program_Products__c + subPeriod.Program_Subscription__c ;
                    
                    //Check Product in map
                    if(mapPreviousSubIdentifierWithSubPeriodIdentifier.containsKey(renewalUK)) {
                        
                        //Get New Subscription Period Identifier
                        String newSubPeriodIdentifier = mapPreviousSubIdentifierWithSubPeriodIdentifier.get(renewalUK);
                        
                        //Check in map
                        if(!mapRenewalSubPeriodWithubscriptionPeriodIdentifier.containsKey(newSubPeriodIdentifier))
                            mapRenewalSubPeriodWithubscriptionPeriodIdentifier.put(newSubPeriodIdentifier, subPeriod.Id);           
                    } 
                }
                
                /*******************      This code is to get the Renewed Contract   End  ********************/
                
                //Map to hold the Contract + Product combination with list of related Subscription Periods
                Map<String, List<Subscription_Period__c>> mapSubscriptionPeriodsWithRelatedContract = new Map<String, List<Subscription_Period__c>>();
                
                //Loop through Subscription Period
                for(Subscription_Period__c subscriptionPeriod : [Select Id, Program_Subscription__c, Program_Subscription__r.SBQQ__Contract__c,
                                                                 Program_Subscription__r.SBQQ__Contract__r.AccountId,Program_Subscription__r.Program_Products__c,
                                                                 Contract__c, Segment_Index__c, Period_Start_Date__c, Stage__c,
                                                                 Product__c, Period_End_Date__c, Program_Subscription__r.SBQQ__Product__c
                                                                 From Subscription_Period__c Where Contract__c IN : setContractIds /*AND
																 Program_Subscription__c IN : mapProgramSubscriptionwithUniqueKey.KeySet() ORDER BY Period_End_Date__c ASC*/ FOR UPDATE ]) {
    
    //Create a unique key
    String uK = subscriptionPeriod.Contract__c + '-' + subscriptionPeriod.Program_Subscription__r.Program_Products__c;
    
    //Check the key in map
    if(!mapSubscriptionPeriodsWithRelatedContract.containsKey(uK))
        mapSubscriptionPeriodsWithRelatedContract.put(uK, new List<Subscription_Period__c>());
    
    //Add Subscription Period in map
    mapSubscriptionPeriodsWithRelatedContract.get(uK).add(subscriptionPeriod);
    
    //Unique Key
    /*String uKey = subscriptionPeriod.Contract__c + '-' + subscriptionPeriod.Program_Subscription__c + '-'
    + subscriptionPeriod.Segment_Index__c + '-' + subscriptionPeriod.Period_Start_Date__c ;
    
    //Check For Map contian Key
    if(!mapSubscriptionPeriodToBeInserted.containsKey(uKey)) 
    mapSubscriptionPeriodToBeInserted.put(uKey, subscriptionPeriod);*/
    
}
                //Set to hold the Id of already added Subscription Periods
                Set<Id> setExistingAddedSubPeriodIds = new Set<Id>();
                
                //Loop through key set of mapUniqueKeySubscriptionPeriodAutomation (Unique Identifier)
                for(String uniqueIdent : mapUniqueKeySubscriptionPeriodAutomation.keySet()) {
                    
                    //If Subscription Period not contian in map of mapSubscriptionPeriodToBeInserted
                    if(!mapSubscriptionPeriodToBeInserted.ContainsKey(uniqueIdent)) {
                        
                        if(mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).programSubscription.Id != null ) {
                            
                            //Hold Start Year
                            Integer Year = mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).periodStartDate.Year();
                            
                            //Variable to check the existing Subscription Period
                            Boolean isExistingSubPeriod = false;
                            
                            //Instance of SubscriptionPeriodAutomationWrapper
                            SubscriptionPeriodAutomationWrapper sPeriod = mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent);
                            
                            
                            //Instance of Subscription Period
                            Subscription_Period__c subPeriod = new Subscription_Period__c();
                            
                            //Create a unique Key
                            String existingSubPeriodUK = sPeriod.contract + '-' + sPeriod.programSubscription.Program_Products__c;
                            
                            //Check UK in map
                            if(mapSubscriptionPeriodsWithRelatedContract.containsKey(existingSubPeriodUK) && mapSubscriptionPeriodsWithRelatedContract.get(existingSubPeriodUK) != null) {
                                
                                //Loop over the Existing Subscription Periods
                                for(Subscription_Period__c sP : mapSubscriptionPeriodsWithRelatedContract.get(existingSubPeriodUK)) {
                                    //Check for Subscription End Date 
                                    if(sP.Period_End_Date__c >= sPeriod.periodEndDate && sP.Period_Start_Date__c < sPeriod.periodEndDate && !setExistingAddedSubPeriodIds.contains(sP.Id)) {
                                        
                                        //Add Sub Period Id in set
                                        setExistingAddedSubPeriodIds.add(sp.Id);
                                        
                                        //Add Id for record
                                        subPeriod.Id = sP.Id;
                                        if (sP.Segment_Index__c != null)
                                            subPeriod.Segment_Index__c = sP.Segment_Index__c;
                                        subPeriod.Amendment_Opportunity__c = sPeriod.programSubscription.Source_Opportunity__c;
                                        subPeriod.Program_Subscription__c = sPeriod.programSubscription.Id;
                                        subPeriod.Period_End_Date__c = sPeriod.periodEndDate;
                                        subPeriod.Institution__c = sPeriod.programSubscription.SBQQ__Contract__r.AccountId;
                                        subPeriod.Updated_By_Code__c = true;
                                        if(sP.Stage__c == CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING && (sPeriod.programSubscription.SBQQ__SubscriptionEndDate__c >= sP.Period_End_Date__c
                                                                                                                     || sPeriod.programSubscription.SBQQ__EndDate__c >= sP.Period_End_Date__c))
                                            subPeriod.Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL;
                                        
                                        //Add Stage Logic to account for Opt Outs
                                        //Scenario One - Early Termination Date - (Types: One Point in Time Opt Out With Penalty Fee, One Point in Time Opt Out Without Penalty Fee, Board Approval Opt Out)
                                        //If the Opt Out date occurs within or before the Subscription Period timespan then mark the Subscription Period as Pending
                                        if (sPeriod.programSubscription.Early_Termination_Date__c != null){
                                            if (sPeriod.periodStartDate >= sPeriod.programSubscription.Early_Termination_Date__c ||
                                                (sPeriod.periodEndDate >= sPeriod.programSubscription.Early_Termination_Date__c &&
                                                 sPeriod.periodStartDate <= sPeriod.programSubscription.Early_Termination_Date__c)){
                                                     subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                                 }
                                        }
                                        
                                        //Scenario Two - Opt Out after First Year (Types: Opt Out after First Year in Membership With Penalty Fee, Opt Out after First Year in Membership Without Penalty Fee,
                                        // Annual Opt Out on Anniversary with penalty fee, Annual Opt Out on Anniversary without penalty fee, Funds Appropriation Opt Out)
                                        Set <String> FirstYearOptOuts = new Set<String>();
                                        FirstYearOptOuts.addAll(System.label.ProgSub_OptOutAfterFirstYear.split(';'));
                                        if (sPeriod.ProgramSubscription.Opt_Out__c != null){
                                            if (FirstYearOptOuts.contains(sPeriod.ProgramSubscription.Opt_Out__c) && sPeriod.segmentIndex != 1){
                                                subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                            }
                                        }
                                        //Set flag
                                        isExistingSubPeriod = true;
                                        
                                        break;
                                    }
                                }   
                            }
                            
                            //Check for existing subscription
                            if(!isExistingSubPeriod) {
                                
                                //Set field values
                                subPeriod.Period_Start_Date__c = sPeriod.periodStartDate;
                                subPeriod.Period_End_Date__c = sPeriod.periodEndDate;
                                subPeriod.Contract__c = sPeriod.contract;
                                subPeriod.Program_Subscription__c = sPeriod.programSubscription.Id;
                                subPeriod.Source_Opportunity__c = sPeriod.programSubscription.Source_Opportunity__c;
                                if (sPeriod.segmentIndex != null)
                                    subPeriod.Segment_Index__c = sPeriod.segmentIndex;
                                subPeriod.Institution__c = sPeriod.programSubscription.SBQQ__Contract__r.AccountId;
                                subPeriod.Updated_By_Code__c = true;
                                
                                //Integer
                                Integer accountNameLength = 11;
                                
                                //Check for sPeriod.programSubscription.Product_Code__c
                                if(sPeriod.programSubscription.Product_Code__c != null)
                                    accountNameLength += sPeriod.programSubscription.Product_Code__c.length();
                                
                                Integer actualAccountNameLength = 79 - accountNameLength;
                                
                                subPeriod.Name = 'SP' + '--' + (sPeriod.programSubscription.SBQQ__Account__r.Name).left(actualAccountNameLength) +'--'+ 
                                    sPeriod.programSubscription.Product_Code__c + '-' + year;
                                subPeriod.RecordTypeId = sPeriod.recordType;
                                subPeriod.Stage__c = sPeriod.stage;
                                
                                //Added by Colin McGloin - 7/13/2017 - Issue--CR10808--QA--00004850
                                //Add Stage Logic to account for Opt Outs
                                //Scenario One - Early Termination Date - (Types: One Point in Time Opt Out With Penalty Fee, One Point in Time Opt Out Without Penalty Fee, Board Approval Opt Out)
                                //If the Opt Out date occurs within or before the Subscription Period timespan then mark the Subscription Period as Pending
                                if (sPeriod.programSubscription.Early_Termination_Date__c != null){
                                    if (sPeriod.periodStartDate >= sPeriod.programSubscription.Early_Termination_Date__c ||
                                        (sPeriod.periodEndDate >= sPeriod.programSubscription.Early_Termination_Date__c &&
                                         sPeriod.periodStartDate <= sPeriod.programSubscription.Early_Termination_Date__c)){
                                             subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                         }
                                }
                                
                                //Scenario Two - Opt Out after First Year (Types: Opt Out after First Year in Membership With Penalty Fee, Opt Out after First Year in Membership Without Penalty Fee,
                                // Annual Opt Out on Anniversary with penalty fee, Annual Opt Out on Anniversary without penalty fee, Funds Appropriation Opt Out)
                                Set <String> FirstYearOptOuts = new Set<String>();
                                FirstYearOptOuts.addAll(System.label.ProgSub_OptOutAfterFirstYear.split(';'));
                                if (sPeriod.ProgramSubscription.Opt_Out__c != null){
                                    if (FirstYearOptOuts.contains(sPeriod.ProgramSubscription.Opt_Out__c) && sPeriod.segmentIndex != 1){
                                        subPeriod.Stage__c = CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING;
                                    }
                                }
                                
                            }
                            
                            //Check for Renewal Subscription Period
                            if(sPeriod.segmentIndex == 1 &&  mapRenewalSubPeriodWithubscriptionPeriodIdentifier.containsKey(uniqueIdent)){
                                subPeriod.Id = mapRenewalSubPeriodWithubscriptionPeriodIdentifier.get(uniqueIdent);
                                
                                //Commented out by Victor Hanson - 11/14/2017 - Issue--CR11094--QA--00005364
                                //Added by Colin McGloin - 08/11/2017 - Issue--CR11094--QA--00005364
                                //Changed Decision Type Logic in SubscriptionPeriodTriggerHelper so need to update the Pending record Decision Type now while it is being upserted
                                //SubPeriod.Decision_Type__c = 'Fixed Term';
                            }
                            
                            //Subscription Period to be inserted
                            mapSubscriptionPeriodToBeInserted.put(uniqueIdent, subPeriod);
                            
                        }
                    }
                }
                
                for (Subscription_Period__c sp : mapSubscriptionPeriodToBeInserted.values()) {
                    
                    if (sp.RecordTypeId != CPQConstants.SUBSCRIPTION_PERIOD_RT_ID_EAB)
                        sp.RecordTypeId = CPQConstants.SUBSCRIPTION_PERIOD_RT_ID_EAB;
                }
                
                //Check for Size 
                if(mapSubscriptionPeriodToBeInserted.Size()>0)
                    upsert mapSubscriptionPeriodToBeInserted.values();
                
                //List to update the Component Subscriptions
                List<SBQQ__Subscription__c> componentSubscriptopnToBeUpdated = new List<SBQQ__Subscription__c>();
                
                //Update Parent of Component Subscription
                for(String uniqueIdent : mapUniqueKeySubscriptionPeriodAutomation.keySet()) {
                    
                    for(SBQQ__Subscription__c componentSubscription : mapUniqueKeySubscriptionPeriodAutomation.get(uniqueIdent).componentSubscription ) {
                        //Check Subscription Period and update same on Comp. Subscription
                        if(mapSubscriptionPeriodToBeInserted.containsKey(uniqueIdent) && mapSubscriptionPeriodToBeInserted.containsKey(uniqueIdent) != null)
                            componentSubscriptopnToBeUpdated.add(new SBQQ__Subscription__c(Id = componentSubscription.Id, Subscription_Period__c = mapSubscriptionPeriodToBeInserted.get(uniqueIdent).Id, Program_Subscription__c = mapSubscriptionPeriodToBeInserted.get(uniqueIdent).Program_Subscription__c));
                    }
                }
                
                //Check For Size
                if(componentSubscriptopnToBeUpdated.Size() > 0) {
                    
                    //Updated/Commented the trigger bypass flag- By Subhash Garhwal - 12/20/2018
                    //Util.byPassAllTriggers = true;
                    //Bypass BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS
                    SBQQ_SubscriptionTriggerHelper.BYPASS_FOR_SUBSCRIPTION_PERIOD_CREATION_PROCESS = true;
                    update componentSubscriptopnToBeUpdated;
                    
                    //Added the bypass trigger flag- By Subhash Garhwal - 12/20/2018
                    Util.byPassAllTriggers = true;
                    
                    //Call method - Mahendra Swarnkar - 05/10/2019 - CR-20181019-12685
                    //populate the previous period negotiated fields on the subscription period trigger helper. 
                    SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(mapSubscriptionPeriodToBeInserted.values(),null);
                    
                    //Call method
                    //Subhash Garhwal - 03/06/2018 - CR-20180301-12089
                    SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(componentSubscriptopnToBeUpdated, null);
                    
                    //update mapSubscriptionPeriodToBeInserted.values();
                    
                    //Subhash Garhwal - CR-20180131-11927 
                    List<SBQQ__Subscription__c> compSubs = [Select Id, RecordTypeId, Subscription_Period__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Quantity__c From SBQQ__Subscription__c Where Id IN : componentSubscriptopnToBeUpdated];
                    
                    //Call method to update Proposal value on Subscription Period
                    SBQQ_SubscriptionTriggerHelper.updateProposalvalue(compSubs, null);
                    SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(compSubs, null); //VH 3/13/18 - updated from updateProposalValueForFutureSubPeriod() to updatePendingSPNegotiatedAmountPeriod()
                    
                    Util.byPassAllTriggers = false;
                }
                
                //VH 3/13/18 - updated from updateProposalValueForFutureSubPeriod() to updatePendingSPNegotiatedAmountPeriod()
                //Check for Pending SP
                if(isPendingSubscriptionPeriods)
                    SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod([Select Id, RecordTypeId, Subscription_Period__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Quantity__c From SBQQ__Subscription__c Where Program_Subscription__c IN : setProgramSubscriptions], null);
                
                //V1.2 - Modified - 07/11/2017 - Saurabh Kumar - Q2C Phase (Issue--CR10807--QA--00004745) - Set Updated_By_Code__c = false for future check - Strat from here
                
                //Bypass the trigger
                Util.byPassAllTriggers = true;
                
                //Map to hold Subscription Period records which should be Updated_By_Code__c = false
                Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
                
                //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Starts from here
                //List to hold SPs associated with ES product family and hence program package will be created/updated for only these SPs
                List<Subscription_Period__c> listEligibleSubscriptionPeriodsForProgramCreation = new List<Subscription_Period__c>();
                
                //Processing on the Subscription Period records which are just updated/inserted
                for(Subscription_Period__c subsPeriod : mapSubscriptionPeriodToBeInserted.values()) {
                    
                    mapSubscriptionPeriods.put(subsPeriod.Id, new Subscription_Period__c(Id = subsPeriod.Id, Updated_By_Code__c = false));
                    
                    //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Starts from here
                    //Check if related program Subscription is associated with ES product family
                    if(mapSubscriptionIdWithESProductFamily.size() > 0 && mapSubscriptionIdWithESProductFamily.containsKey(subsPeriod.Program_Subscription__c) && mapSubscriptionIdWithESProductFamily.get(subsPeriod.Program_Subscription__c) != null && mapSubscriptionIdWithESProductFamily.get(subsPeriod.Program_Subscription__c)){
                        
                        //Populate list 
                        listEligibleSubscriptionPeriodsForProgramCreation.add(subsPeriod);	
                    }
                    //Added By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- Ends here
                }
                if(mapSubscriptionPeriods.size() > 0)
                    update mapSubscriptionPeriods.values();
                
                //Bypass the trigger
                Util.byPassAllTriggers = false;
                //V1.2 - Modified - 07/11/2017 - Saurabh Kumar - Q2C Phase (Issue--CR10807--QA--00004745) - Set Updated_By_Code__c = false for future check - Upto here
                
                if(listEligibleSubscriptionPeriodsForProgramCreation.size() > 0){
                    //Updated By Subash garhwal on - 01/21/2019 - CR-20181019-12685 -- replace the "mapSubscriptionPeriodToBeInserted.values()" with  "listEligibleSubscriptionPeriodsForProgramCreation"
                    //Added by VH - 12/07/2018 - CR-20181019-12685 - populates program package lookup on Subscription Period
                    Sched_ProgramPackageCreation.scheduleProgramPackageCreation(listEligibleSubscriptionPeriodsForProgramCreation);   
                }
                
                if(setContractIds.size() > 0){
                    Batch_UpdateSubscriptionPeriodFields.scheduleSPFieldUpdate(setContractIds);    
                }
                
            }
        } catch(Exception e){
            
            System.debug('#########Sched_SubscriptionPeriodCreation e' +e);
            
            //Check for UNABLE_TO_LOCK_ROW error
            if(e.getmessage().contains('UNABLE_TO_LOCK_ROW')) {
                
                DateTime sysTime = dateTime.now().addSeconds(10);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                System.debug('#######In schedule condition: ' );
                Sched_SubscriptionPeriodCreation job = new Sched_SubscriptionPeriodCreation(mapUniqueKeySubscriptionPeriodAutomation, mapProgramSubscriptionwithUniqueKey, setContractIds);
                System.schedule('SBQQ_SubscriptionTrigger' + sysTime.getTime(),chron_exp, job);
            }
        }
    }
}