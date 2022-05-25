/**
 *  Description     :  Helper class for Trigger_SubscriptionPeriodTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal
 *
 *  Created Date    :  05/24/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20170403-10807
 *                      V_1.1 - Modified By - Saurabh Kumar - 08/11/2017 - Issue--CR11094--UAT--00005392 - Added a new method "populateSubscriptionPeriodFields"
 *                      V_1.2 - Modified By - Saurabh Kumar - 08/16/2017 - Issue--CR11094--UAT--00005487 - populateNextYearRenewal method is commented out because it can be edited after first 1st time population.
 *                      V_1.3 - Modified By - Victor Hanson - 08/17/2017 - Issue--CR11106--QA--00005464 - added method: calculateNextDecisionDate
 *                      V_1.4 - Modified By - Subhash Garhwal - 08/25/2017-Issue--CR11141--QA--00005572 - populateSubscriptionPeriodFields
 *                      V_1.5 - Modified By - Subhash Garhwal - 09/02/2017 -  - Issue--CR11062--QA--00005609 - 1.Commented out the updateNegotiatedAmountPeriod method 
 *                                                                                                          2. Added a new method updatePendingSPNegotiatedAmountPeriod 
 *                      V_1.6 - Modified By - 02/05/2018 - Subhash Garhwal - CR-20180126-11912 A new Method called populateCTManagerEmail
 *                      V_1.7 - Modified By - 02/09/2018 - Subahsh Garhwal - CR-20180207-12036 A new Method called populateNegotiatedAmountFutureSubPeriod
 *                      V_1.8 - Modified By - 02/13/2018 - Subahsh Garhwal - CR-20180126-11922 - Updated "populatePreviousPeriodNegotiated" method.
 *                      V_1.9 - Modified By - 02/21/2018 - Subhash Garhwal - CR-20180214-12041 - Updated "populateRenewalYearHalfOnSubPeriod"
 *                      V_2.0 - Modified By - 02/28/2018 - Subhash Garhwal - CR-20180228-12087 - A new Method - syncPreviousPeriodNegotiated
 *                      V_2.1 - Modified By - 03/19/2018 - Subhash Garhwal - CR-20180314-12107 - Added check for SOQL issue
 *                      V_2.2 - Modified By - 03/9/2018 - Subhash Garhwal -Issue--CR12039--QA--00007920 A new Method Called populateMembershiplookup
 *                      V_2.3 - Modified By - Subhash Garhwal - 04/3/2017 - CR-20180403-12144 - populatePreviousYearSubscriptionPeriod method
 *                      V_2.4 - Modified By - 04/09/2018 - Colin McGloin - CR-20180327-12130 - Added two new methods - populateProgramInfo_EventsSP and populateProgramInfo_TasksSP
 *                      V_2.5 - Modified By - Subhash Garhwal - 05/24/2018 - CR-20180502-12199 - Added a new method - populateRenewalOwnerOnSubAndOwnerOnMembership to populate 'Renewal Owner' field on 'Subscription' and higher date 'Suscription Period' from active 'Suscription Period' record 
 *                      V_2.6 - Modifiel By - Subhash Garhwal - 07/12/2018 - Issue--CR12199--QA--00008128   - Updated populateRenewalOwnerOnSubAndOwnerOnMembership method
 *                      V_2.7 - Modified By - Subhash Garhwal - 08/02/2018 - CR-20180205-11957 - updated 'populatePreviousPeriodNegotiated' method to update 'Previous_Period_Negotiated__c' and 'Previous_Period_Negotiated_Components__c' from the 'Renewal_Negotiated__c' field of Previous SP
 *                      V_2.8 - Modified By - Subhash Garhwal - 08/08/2018 - CR-20180417-12162 - added 'populateCloseDateOnSP' method to populate 'Close_Date__c' field on 'Subscription Period' when stage is updating from 'Opt out' to 'ATL' 
 *                      V_2.9 - Modified By - Rajeev Jain - 04//11/2018 - CR-20180327-12130 - Deploying this CR from the Dev 1 To Full Sandbox.
 *                      V_3.0 - Modified By - Subhash Garhwal - 09/26/2018 - CR-20180925-12620- updated 'populateCloseDateOnSP' method to check for current user profile Id
 *                      V_3.1 - Modified By - Abhinav Sharma - CR-20181016-12674 - New Method syncSMERequestWithSPeriod 
 *                      V_3.2 - Modified By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Updated the Method calculateNextDecisionDate() to have new logic 
 *                      V_3.3 - Modified By - Subhash Garhawal - 12/27/2018 - CR-20181019-12685 - Added New Methods "populateEngagementStatusOnProgramPackage" and "populateEngagementStatus"
 *                      V_3.4 - Modified By - Subhash Garhawal - 01/30/2018 - CR-20181019-12685 - Added New Methods "populatePreviousCurrentNextYearProgramCost"
 *                      V_3.5 - Modified By - Mahendra Swarnkar - 07/02/2019 - CR-20190219-12888 - Updated the Method updateDecisionType
 *                      V_3.6 - Modified By - Subhash Garhawal - 06/04/2020 - CR-20200608-14151
 *                      V_3.7 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
 *                      V_3.8 - Modified By - Subhash Garhawal - 06/24/2020  commneted this method "populateAutorenewAndDate" as per CR-20200623-14217
 *                      V_3.9 - Modified By - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Update the " populateRenewalYearHalfOnSubPeriod" to populate YouVisit Package on Subscription Periods
 *                      V_4.0 - Modified By - Victor Hanson - 10/27/2020 - CR-20201013-14598 - modified query with reference to the cost product codes
 *                      V_4.1 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out all values which update Membership Owner
 *                      V_4.2 - Modified By - Neha Sharma - 11/03/2020 - CR-20200814-14435 - Remove the Commented out all values which update Membership Owner from populateOwnerOnMembership
 *          		V_4.3 - Modified By - Mahendra Swarnkar - 09/07/2020 - CR-20200715-14321
 *          		V_4.4 - Modified By - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
 *			V_4.5 - Modified By - Shalu Sharma - CR-20200924-14551 - 06/17/2021 
 *			V_4.6 - Modified By - Subhash Garhwal - 10/11/2021 - CR-20210928-15467 - Commented the code
**/
public without sharing class SubscriptionPeriodTriggerHelper {  
  
  //03/19/2018 - Subhash Garhwal - CR-20180314-12107 - Added check for SOQL issue
  //Flag to bypass the populatePreviousYearSubscriptionPeriod after one time execution
  public static Boolean BYPASSPOPULATEPREVIOUSYEARSUBSCRIPTIONPERIOD = false;
  
    
    /**
     * 
     *  @description    :   The method is used to populate stage = void on the all future Subscription Periods when the current 
                            Subscription Period stage = 'Dropped'. 
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Saurabh Kumar - 05/24/2017 - CR-20170403-10807
     * 
     **/
     public static void updateFutureSubscriptionPeriod(List<Subscription_Period__c> newSubscriptionPeriods, Map<Id, Subscription_Period__c> oldMapSubscriptionPeriods){
        
        //Map to hold current subscription period Id and Program Subscription Id
        Map<Id, Id> mapSubscriptionPeriodIdAndProgramSubscriptionId = new Map<Id, Id>();
        
        //Map to hold program subscription Id and current subscription period records
        Map<Id, Subscription_Period__c> mapProgramSubscriptionIdAndSubscriptionPeriod = new Map<Id, Subscription_Period__c>();
        
        //Processing on the new records
        for(Subscription_Period__c subscriptionPeriod : newSubscriptionPeriods){
            
            //Checking whether record is inserting or updating and bypass the blank update
            if(subscriptionPeriod.Program_Subscription__c != null && subscriptionPeriod.Period_Start_Date__c != null && subscriptionPeriod.Stage__c != null &&
                subscriptionPeriod.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED
                && (oldMapSubscriptionPeriods == null || (subscriptionPeriod.Program_Subscription__c != oldMapSubscriptionPeriods.get(subscriptionPeriod.Id).Program_Subscription__c
                    || subscriptionPeriod.Period_Start_Date__c != oldMapSubscriptionPeriods.get(subscriptionPeriod.Id).Period_Start_Date__c || 
                    subscriptionPeriod.Stage__c != oldMapSubscriptionPeriods.get(subscriptionPeriod.Id).Stage__c))){
                
                    mapSubscriptionPeriodIdAndProgramSubscriptionId.put(subscriptionPeriod.Id, subscriptionPeriod.Program_Subscription__c);
                    mapProgramSubscriptionIdAndSubscriptionPeriod.put(subscriptionPeriod.Program_Subscription__c, subscriptionPeriod);
            }
        }
        
        //Checking for map size
        if(mapSubscriptionPeriodIdAndProgramSubscriptionId.size() > 0){
            
            //Query on the Subscription Period
            List<Subscription_Period__c> subscriptionPeriods = [Select Id, Program_Subscription__c, Period_Start_Date__c, Stage__c From Subscription_Period__c
                                                                Where Program_Subscription__c IN : mapSubscriptionPeriodIdAndProgramSubscriptionId.values() AND
                                                                ID NOT IN : mapSubscriptionPeriodIdAndProgramSubscriptionId.keySet() AND Program_Subscription__c != null
                                                                AND (Period_Start_Date__c != null OR Stage__c =: CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING)];
                                                                
            //Checking for list size 
            if(subscriptionPeriods.size() > 0){
                
                //Map to hold Subscription Period records to be update
                Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
                
                //Processing on the list
                for(Subscription_Period__c subscriptionPeriod : subscriptionPeriods){
                    
                    //Checking whether subscription period is in future or pending subscription
                    if(subscriptionPeriod.Period_Start_Date__c > mapProgramSubscriptionIdAndSubscriptionPeriod.get(subscriptionPeriod.Program_Subscription__c).Period_Start_Date__c
                    || subscriptionPeriod.Stage__c ==  CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING)
                        mapSubscriptionPeriods.put(subscriptionPeriod.Id, new Subscription_Period__c(Id = subscriptionPeriod.Id, Stage__c = CPQConstants.SUBSCRIPTION_PERIOD_STAGE_VOID));  
                }
                //Checking for map size
                if(mapSubscriptionPeriods.size() > 0){
                    
                    //Bypass all triggers
                    Util.BypassAllTriggers = true;
                    
                    update mapSubscriptionPeriods.values();
                    
                    //Reset the flag
                    Util.BypassAllTriggers = false;
                }
            }
        }
     }
    /**
     * 
     *  @description    :   1 - The method is used to populate Previous Subscription Period if any Subscription Period found with following criteias.
                            Same Institutuion + Program Subscription.Product + Period and end date is the nearest prior to current Subscription
                            start date.
                            2 - If above criteria did not matched then populate Previous Contract ABC if any Contract ABC found with following criterias.
                            Same Institution + Program and Period end date is the nearest prior to current Subscription start date.
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Saurabh Kumar - 05/24/2017 - CR-20170403-10807
     * 
     **/
   /* public static void populatePreviousSubscriptionOrPreviousContractABC(List<Subscription_Period__c> newSubscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptions){
        
        //Map to hold new Subscription Period records
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Set to hold Program Subscription Ids
        Set<Id> setProgramSubscriptionIds = new Set<Id>();
        
        //Variable to hold most recent Subscription Period start date
        Date mostRecentPeriodStartDate = Date.valueOf('0001-01-01');
        
        //Processing on the new records
        for(Subscription_Period__c subscription : newSubscriptionPeriods){
            
            //Checking whether record is inserting or updating and bypass the blank update in the case of update
            if(subscription.Institution__c != null && subscription.Program_Subscription__c != null && subscription.Period_Start_Date__c != null 
                && (mapOldSubscriptions == null || subscription.Institution__c != mapOldSubscriptions.get(subscription.Id).Institution__c 
                    || subscription.Program_Subscription__c != mapOldSubscriptions.get(subscription.Id).Program_Subscription__c || subscription.Period_Start_Date__c != mapOldSubscriptions.get(subscription.Id).Period_Start_Date__c 
                    || subscription.Period__c != mapOldSubscriptions.get(subscription.Id).Period__c || subscription.Program__c != mapOldSubscriptions.get(subscription.Id).Program__c)){
                        
                mapSubscriptionPeriods.put(subscription.Id, subscription);
                setProgramSubscriptionIds.add(subscription.Program_Subscription__c);
                
                if(subscription.Period_Start_Date__c >= mostRecentPeriodStartDate)
                    mostRecentPeriodStartDate = subscription.Period_Start_Date__c;
            }
        }
        
        //Checking for map size
        if(mapSubscriptionPeriods.size() > 0){
            
            //Map to hold all Subscription Period recods (excluding new records). Key = Institutuion + Program Subscription.Product + Period. Value = List<Subscription Period>
            Map<String, List<Subscription_Period__c>> mapForPreviousProgramSubscriptionAndSubscriptionPeriod = new Map<String, List<Subscription_Period__c>>();
            
            //Map to hold new Subscription Period records. Key = Institutuion + Program Subscription.Product + Period. Value = List<Subscription Period>
            Map<String, List<Subscription_Period__c>> mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod = new Map<String, List<Subscription_Period__c>>();
            
            //Map to hold new Subscription Period records which Previous Subscription Period is not populated
            Map<Id, Subscription_Period__c> mapSubscriptionPeriodForPreviousContractAbc = new Map<Id, Subscription_Period__c>();
            
            //Query on the Subscription Periods
            for(Subscription_Period__c subscriptionPeriod : [Select Id, Program_Subscription__r.SBQQ__Account__c, Program_Subscription__c, Program_Subscription__r.SBQQ__Product__c, Period_Start_Date__c, Period_End_Date__c, 
                                                            Period__c, Program_Subscription__r.Program__c From Subscription_Period__c Where Program_Subscription__r.SBQQ__Account__c != null AND Program_Subscription__c != null AND Period_Start_Date__c != null
                                                            AND Program_Subscription__c IN : setProgramSubscriptionIds AND Period_Start_Date__c <= : mostRecentPeriodStartDate]){
                
                //Checking whether new record or old
                if(mapSubscriptionPeriods.containsKey(subscriptionPeriod.Id) ){
                
                    String uk = subscriptionPeriod.Program_Subscription__r.SBQQ__Account__c+'||'+subscriptionPeriod.Program_Subscription__r.SBQQ__Product__c+'||'+subscriptionPeriod.Period__c;
                
                    //Checking whether key is already exist
                    if(mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.containsKey(uk)){
                        
                        List<Subscription_Period__c> subscriptions = mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.get(uk);
                        subscriptions.add(subscriptionPeriod);
                        mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.put(uk, subscriptions);
                    }
                    else
                        mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.put(uk, new List<Subscription_Period__c>{subscriptionPeriod});
                }
                else{
                        String uk = subscriptionPeriod.Program_Subscription__r.SBQQ__Account__c+'||'+subscriptionPeriod.Program_Subscription__r.SBQQ__Product__c+'||'+subscriptionPeriod.Period__c;
                    
                        //Checking whether key is already exist
                        if(mapForPreviousProgramSubscriptionAndSubscriptionPeriod.containsKey(uk)){
                            
                            List<Subscription_Period__c> subscriptions = mapForPreviousProgramSubscriptionAndSubscriptionPeriod.get(uk);
                            subscriptions.add(subscriptionPeriod);
                            mapForPreviousProgramSubscriptionAndSubscriptionPeriod.put(uk, subscriptions);
                        }
                        else
                            mapForPreviousProgramSubscriptionAndSubscriptionPeriod.put(uk, new List<Subscription_Period__c>{subscriptionPeriod});
                }
            }
            
            //Map to hold Subscription Period records which should be update
            Map<Id, Subscription_Period__c> mapSubscriptionPeriodsTobeUpdate = new Map<Id, Subscription_Period__c>();
                
            //Processing on the maps which hold new records (Previous Subscription Period) only. We'll get all old records using new records' key
            if(mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.size() > 0){
                
                //Temprary Subscription Period instance
                Subscription_Period__c subscriptionPeriodTemp;
                
                //Processing on the new records key
                for(String uk : mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.keySet()){
                    
                    //Processing on the new records value (Populate Previous Subscription Period)
                    for(Subscription_Period__c newsubscriptionPeriod : mapForPreviousProgramSubscriptionAndNewSubscriptionPeriod.get(uk)){
                        
                        if(uk.contains('||null') || uk.contains('null||'))
                            mapSubscriptionPeriodForPreviousContractAbc.put(newsubscriptionPeriod.Id, newsubscriptionPeriod);
                        else{
                            
                            subscriptionPeriodTemp = new Subscription_Period__c(Period_End_Date__c =  Date.valueOf('0001-01-01'));
                            Boolean isPreviousSubscriptionPeriodFound = false;
                            
                            //Checking whether map contains the key
                            if(mapForPreviousProgramSubscriptionAndSubscriptionPeriod.containsKey(uk)){
                                
                                //Processing on the old records value
                                for(Subscription_Period__c oldsubscriptionPeriod : mapForPreviousProgramSubscriptionAndSubscriptionPeriod.get(uk)){
                                    
                                    //Checking for the date
                                    if(newsubscriptionPeriod.Period_Start_Date__c > oldsubscriptionPeriod.Period_End_Date__c && oldsubscriptionPeriod.Period_End_Date__c > subscriptionPeriodTemp.Period_End_Date__c ){
                                        
                                        subscriptionPeriodTemp = oldsubscriptionPeriod;
                                        isPreviousSubscriptionPeriodFound = true;
                                    }
                                }
                                if(isPreviousSubscriptionPeriodFound)
                                    mapSubscriptionPeriodsTobeUpdate.put(newsubscriptionPeriod.Id, new Subscription_Period__c(Id = newsubscriptionPeriod.Id, Previous_Subscription_Period__c = subscriptionPeriodTemp.Id)); 
                                 
                                else
                                    mapSubscriptionPeriodForPreviousContractAbc.put(newsubscriptionPeriod.Id, newsubscriptionPeriod);
                            }   
                        }
                    }
                }
            }
            
            //Checking if Previous Subscription Period is not found then process on the Contract ABC
            if(mapSubscriptionPeriodForPreviousContractAbc.size() > 0){
                

                //Map to hold new Subscription Periopd records. Key = Institution + Program. Value = List<Contract ABC>
                Map<String, List<Contract__c>> mapForPreviousContractABCAndNewSubscriptionPeriod = new Map<String, List<Contract__c>>();
                
                //Processing on the Contract ABC
                for(Contract__c contract : [Select Id, Payer_Account__c, Program__c, End__c From Contract__c Where Payer_Account__c != null AND Program__c != null AND End__c != null AND 
                                            End__c <: mostRecentPeriodStartDate]){
                    
                    String uk = contract.Payer_Account__c+'||'+contract.Program__c;
                    
                    //Checking whether map is already contains the key
                    if(mapForPreviousContractABCAndNewSubscriptionPeriod.containsKey(uk)){
                        
                        List<Contract__c> contracts = mapForPreviousContractABCAndNewSubscriptionPeriod.get(uk);
                        contracts.add(contract);
                        mapForPreviousContractABCAndNewSubscriptionPeriod.put(uk, contracts);
                    }
                    else
                        mapForPreviousContractABCAndNewSubscriptionPeriod.put(uk, new List<Contract__c>{contract});
                }
                //Checking for map size
                if(mapForPreviousContractABCAndNewSubscriptionPeriod.size() > 0){
                    
                    //Processing on the Subscription Period records
                    for(Subscription_Period__c subscriptionPeriod : mapSubscriptionPeriodForPreviousContractAbc.values()){
                        
                        if(subscriptionPeriod.Program_Subscription__r.SBQQ__Account__c == null || subscriptionPeriod.Program_Subscription__r.Program__c == null)
                            continue;
                            
                        Contract__c comtractTemp = new Contract__c(End__c =  Date.valueOf('0001-01-01'));
                        Boolean isPreviousContractFound = false;
                        
                        String uk = subscriptionPeriod.Program_Subscription__r.SBQQ__Account__c+'||'+subscriptionPeriod.Program_Subscription__r.Program__c;
                        
                        if(mapForPreviousContractABCAndNewSubscriptionPeriod.containsKey(uk)){
                            
                            for(Contract__c contract : mapForPreviousContractABCAndNewSubscriptionPeriod.get(uk)){
                                
                                if(subscriptionPeriod.Period_Start_Date__c > contract.End__c && contract.End__c > comtractTemp.End__c){
                                    
                                    isPreviousContractFound = true;
                                    comtractTemp = contract;
                                }
                            }
                            if(isPreviousContractFound)
                                mapSubscriptionPeriodsTobeUpdate.put(subscriptionPeriod.Id, new Subscription_Period__c(Id = subscriptionPeriod.Id, Previous_Contract_ABC__c = comtractTemp.Id));    
                              
                        }
                    }
                }
            }
            //Checking for map size
            if(mapSubscriptionPeriodsTobeUpdate.size() > 0){
                
                //Bypass all triggers
                Util.bypassAllTriggers = true;
                
                update mapSubscriptionPeriodsTobeUpdate.values();
                
                //Reset the flag
                Util.bypassAllTriggers = false;
            }
       }
    } */
    
    /**
     * 
     *  @description    :   This method is used to populate the previous year subscription period.
     *                      Rule: DS104.1
     *                      If this is not the first Period of the contract, link to the previous period's Subscription Period record.
     *                      If this is the first Period, and this is a Continuing Opp, check the parent Subscription record's Previous Subscription
     *                      field and get the last Period linked to the Previous Subscription
     *
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Subhash Garhwal - 06/01/2017 - CR-20170403-10807
     *            V_1.1 - Modified - Subhash Garhwal - 07/27/2017 - Issue--CR10808--QA--00005096
     *            V_1.2 - Modified - Subhash Garhwal - 04/3/2017 - CR-20180403-12144 - Removed bypass check
     * 
     **/   
    public static void populatePreviousYearSubscriptionPeriod(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
        
        //Map to hold the toal Subscription Periods under the Program Subsription
        Map<String, Subscription_Period__c> mapSubscriptionPeriods = new Map<String, Subscription_Period__c>();
        
        //Set to hold the Program Subscription Id
        Set<Id> setProgramSubscriptionIds = new Set<Id>();
        
        //Set to hold the Contract Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the Subscription Periods
        for(Subscription_Period__c sP : subscriptionPeriods) {
            
            //Check appropriate condition to fire the trigger logic
            if(sP.Program_Subscription__c != null && sP.Contract__c != null && (mapOldSubscriptionPeriods == null
                || sP.Segment_Index__c != mapOldSubscriptionPeriods.get(sP.Id).Segment_Index__c)) {
            
                //Create unique key
                String uniqueKey = sP.Contract__c + '-' + sP.Program_Subscription__c;
                
                //Check for segment Index
                if(sP.Segment_Index__c != null)
                    uniqueKey += '-' + sP.Segment_Index__c;
                
                //Add Program Subscription Id in set
                setProgramSubscriptionIds.add(sP.Program_Subscription__c);
                
                //Add Contract Id in set
                setContractIds.add(sP.Contract__c);
                
                //Add Subscription Period in map
                mapSubscriptionPeriods.put(uniqueKey, sP);
            }
        }
        
        //Check for size
        if(mapSubscriptionPeriods.size() > 0) {
          
            //Map to hold the Previous subscription with related Program Subscriptions
            Map<Id, List<Id>> mapPreviousSubWithProSubs = new Map<Id, List<Id>>();
            
            //Map to hold the Previous subscription's lastest Subscription Period with Program Subscription
            Map<Id, Id> mapPreSubPeriodWithProSubsription = new Map<Id, Id>();
            
            //Query through Program Subscription
            for(SBQQ__Subscription__c pS : [Select Id, Previous_Program_Subscription__c From SBQQ__Subscription__c Where Id IN : setProgramSubscriptionIds AND Previous_Program_Subscription__c != null]) {
                
                //Check for Previous Subscription
                if(!mapPreviousSubWithProSubs.containsKey(pS.Previous_Program_Subscription__c))
                    mapPreviousSubWithProSubs.put(pS.Previous_Program_Subscription__c, new List<Id>());
                
                //Add Program Subscription
                mapPreviousSubWithProSubs.get(pS.Previous_Program_Subscription__c).add(pS.Id);
            }
            
            //Check for map
            if(mapPreviousSubWithProSubs.size() > 0) {
                
                //Query on Program Subscription with Lastest Subscription Period
                List<SBQQ__Subscription__c> previousSubscriptions = [Select Id, (Select Id From Program_Subscriptions__r Where Period_End_Date__c != null
                                                                        ORDER BY Period_End_Date__c DESC LIMIT 1) From SBQQ__Subscription__c Where Id IN : mapPreviousSubWithProSubs.keySet()];
                
                //Loop over the Previsous subscriptions
                for(SBQQ__Subscription__c preSub : previousSubscriptions) {
                    
                    //Check for Subscription Period
                    if(preSub.Program_Subscriptions__r != null && preSub.Program_Subscriptions__r.size() > 0 && mapPreviousSubWithProSubs.containsKey(preSub.Id)) {
                        
                        //Loop over the Program Subscriptions
                        for(Id proSubId : mapPreviousSubWithProSubs.get(preSub.Id))
                            mapPreSubPeriodWithProSubsription.put(proSubId, preSub.Program_Subscriptions__r[0].Id); 
                    }
                }
            }
            
            //Map to hold the Program Subscription with Max Segment Index
            Map<Id, Decimal> mapProSubscriptionWithMaxIndex = new Map<Id, Decimal>();
            
            //SOQL on Subscription Period to get all the subscriptions
            for(Subscription_Period__c sP : [Select Id, Contract__c, Program_Subscription__c, Segment_Index__c, Period_End_Date__c From Subscription_Period__c
                                  Where Contract__c IN : SetContractIds AND Program_Subscription__c IN : setProgramSubscriptionIds
                                      AND Period_End_Date__c != null ORDER BY Segment_Index__c DESC NULLS LAST]) {
        
        //Create unique key
                String uniqueKey = sP.Contract__c + '-' + sP.Program_Subscription__c;
                
                if(sP.Segment_Index__c != null)
                 uniqueKey = uniqueKey + '-' + sP.Segment_Index__c;
                
                //Add Subscription Period in map
                mapSubscriptionPeriods.put(uniqueKey, sP);
                
                //Check Program Subscription in map
                if(!mapProSubscriptionWithMaxIndex.containsKey(sP.Program_Subscription__c) && sP.Segment_Index__c != null)
                  mapProSubscriptionWithMaxIndex.put(sP.Program_Subscription__c, sP.Segment_Index__c);  
      }
      
            //List to update Previous Subscription Period record 
            List<Subscription_Period__c> subscriptionPeriodsToUpdate = new List<Subscription_Period__c>();
            
            //Loop over the Subscriptions Period map
            for(String uk : mapSubscriptionPeriods.keySet()) {
                
                //Get the Subscription Period
                Subscription_Period__c subPeriod = mapSubscriptionPeriods.get(uK);
                
                //Check for Segment index
                if(subPeriod.Segment_Index__c == 1 && mapPreSubPeriodWithProSubsription.containsKey(subPeriod.Program_Subscription__c))
                    subscriptionPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Previous_Subscription_Period__c = mapPreSubPeriodWithProSubsription.get(subPeriod.Program_Subscription__c)));
                else if(subPeriod.Segment_Index__c != null && subPeriod.Segment_Index__c != 1) {
                    
                    //Create unique Key to get the Previous Year Subscription Period
                    String preYearUK = subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__c + '-' + (subPeriod.Segment_Index__c - 1);
                    
                    //Check uniquekey in map
                    if(mapSubscriptionPeriods.containsKey(preYearUK))
                        subscriptionPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Previous_Subscription_Period__c = mapSubscriptionPeriods.get(preYearUK).Id));
                
                } else if(subPeriod.Segment_Index__c == null && mapProSubscriptionWithMaxIndex.containsKey(subPeriod.Program_Subscription__c)) {
                  
                  //Create unique Key to get the Previous Year Subscription Period
                    String preYearUK = subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__c + '-' + mapProSubscriptionWithMaxIndex.get(subPeriod.Program_Subscription__c);
                    
                    //Check uniquekey in map
                    if(mapSubscriptionPeriods.containsKey(preYearUK))
                        subscriptionPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Previous_Subscription_Period__c = mapSubscriptionPeriods.get(preYearUK).Id));
                  
                }   
            }
            
            //Check for list size
            if(subscriptionPeriodsToUpdate.size() > 0) {
                
                //Bypass triggers
                Util.BypassAllTriggers = true;
                
                //Subhash Garhwal - 04/03/2018 - CR-20180403-12144 - comment the flag. 
                //BYPASSPOPULATEPREVIOUSYEARSUBSCRIPTIONPERIOD = true;
                
                //Update
                update subscriptionPeriodsToUpdate;
                
                //Enable triggers
                Util.BypassAllTriggers = false;
                
                
                //Added by - Saurabh Kumar - 07/21/2017 - Issue--CR10808--QA--00004854 - Calling method to adjust negotiated amount on latest Subscription records
                SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(subscriptionPeriodsToUpdate, null);
                
            }
        }       
    }
    
    /**
     * 
     *  @description    :   This method is used to populate the Negotiated_Amount_Period__c values on future renewal Subscription
     *                      Rule: DS104.1
     *                      For the future Pending Subscription period record, populate the field with the Negotiated Amount (Period) value from
     *                      the previous Subscription Period plus the value of the uplift amount, which is calculated from the previous Subscription
     *                      Period as Negotiated Amount (Period) * SBQQ__SegmentUplift__c (as a percentage).
     *
     *
     *  @args           :   List<Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Subhash Garhwal - 06/04/2017 - CR-20170403-10807
     * 
     **/
    public static void populateNegotiatedAmountPeriodForRenewalSubPeriod(List<Subscription_Period__c> subscriptionPeriods) {
        
        //Set to hold the Program Subscription Id
       /* Set<Id> setProgramsubscriptions = new Set<Id>();
        
        //Loop over Subscription Periods
        for(Subscription_Period__c subPeriod : subscriptionPeriods) {
            
            //Check for Renewal Subscription
            if(subPeriod.Program_Subscription__c != null && subPeriod.Stage__c == CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING && subPeriod.Period_Start_Date__c != null) {
                
                //Add Program Subscription in set
                setProgramsubscriptions.add(subPeriod.Program_Subscription__c);
            }
        }
        
        //Map to hold the latest Subscription Period with Program Subscription
        Map<Id, Subscription_Period__c> mapLatestSubPeriodWIthProSubscription = new Map<Id, Subscription_Period__c>();
        
        //Check for set size
        if(setProgramsubscriptions.size() > 0) {
            
            //SOQL on Subscription Periods
            for(Subscription_Period__c sP : [Select Id, Negotiated_Amount_Period__c, Program_Subscription__c, Program_Subscription__r.SBQQ__SegmentUplift__c,
                                                    Program_Subscription__r.SBQQ__StartDate__c, Program_Subscription__r.SBQQ__EndDate__c From Subscription_Period__c
                                                    Where Program_Subscription__c IN : setProgramsubscriptions AND Stage__c !=: CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING 
                                                    ORDER BY Period_End_Date__c DESC]) {
                
                //Check Program Subscription Id in map
                if(!mapLatestSubPeriodWIthProSubscription.containsKey(sP.Program_Subscription__c))
                    mapLatestSubPeriodWithProSubscription.put(sP.Program_Subscription__c, sP);      
            }
            
            //Check for latest subscriotion map
            if(mapLatestSubPeriodWIthProSubscription.size() > 0) {
                
                //List to update Renewal Subscription Periods
                List<Subscription_Period__c> subPeriodsToUpdate = new List<Subscription_Period__c>();
                
                //Loop over Subscription Periods
                for(Subscription_Period__c subPeriod : subscriptionPeriods) {
                    
                    //Check for Renewal Subscription
                    if(subPeriod.Program_Subscription__c != null && subPeriod.Stage__c == CPQConstants.RENEWAL_SUBSCRIPTION_PERIOD_STAGE_PENDING && subPeriod.Period_Start_Date__c != null) {
                        
                        //Check Program Subscription in map
                        if(mapLatestSubPeriodWithProSubscription.containsKey(subPeriod.Program_Subscription__c)) {
                            
                            //Get the latest Subscription Period
                            Subscription_Period__c latestSubPeriod = mapLatestSubPeriodWithProSubscription.get(subPeriod.Program_Subscription__c);
                            
                            //Check for Renewal Sub. Period 
                            if(subPeriod.Period_Start_Date__c >= latestSubPeriod.Program_Subscription__r.SBQQ__EndDate__c) {
                                
                                //Check for Amount fields
                                if(latestSubPeriod.Negotiated_Amount_Period__c != null && latestSubPeriod.Program_Subscription__r.SBQQ__SegmentUplift__c != null) {
                                    
                                    //Get Negotiated Amount Period
                                    Decimal negotiatedAmountPeriod = latestSubPeriod.Negotiated_Amount_Period__c + ((latestSubPeriod.Negotiated_Amount_Period__c * latestSubPeriod.Program_Subscription__r.SBQQ__SegmentUplift__c)/100).setScale(2);
                                    
                                    //Add Record in list to update
                                    if(negotiatedAmountPeriod != subPeriod.Negotiated_Amount_Period__c)
                                      subPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Negotiated_Amount_Period__c = negotiatedAmountPeriod));
                                }
                            }
                        }
                    }
                } 
                
                //Check for size
                if(subPeriodsToUpdate.size() > 0)
                  update subPeriodsToUpdate;  
            }
        } */
    }
    
    /**
     * 
     *  @description    :   This method is used to populate the Renewal Negotiated
     *                      Rule: DS104.1
     *                      Populate with Negotiated Amount (Period) of the next Period.  If this is Period 1, populate the field with the amount from Period 2.
   *            For the future Pending Subscription period record, set this field to 0, since no renewal has been negotiated.
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Subhash Garhwal - 06/04/2017 - CR-20170403-10807
     *          :  V_1.1 - Modified by Saurabh Kumar - 08/16/2017 - Issue--CR11094--UAT--00005487 - Code is commented out because it can be edited after first 1st time population.
     * 
     **/   
    public static void populateNextYearRenewal(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
        /*
        //Map to hold the toal Subscription Periods under the Program Subsription
        Map<String, Subscription_Period__c> mapSubscriptionPeriods = new Map<String, Subscription_Period__c>();
        
        //Set to hold the Program Subscription Id
        Set<Id> setProgramSubscriptionIds = new Set<Id>();
        
        //Loop over the Subscription Periods
        for(Subscription_Period__c sP : subscriptionPeriods) {
            
            //Check appropriate condition to fire the trigger logic
            if(sP.Program_Subscription__c != null && sP.Contract__c != null && (mapOldSubscriptionPeriods == null
                || sP.Segment_Index__c != mapOldSubscriptionPeriods.get(sP.Id).Segment_Index__c || sP.Negotiated_Amount_Period__c != mapOldSubscriptionPeriods.get(sP.Id).Negotiated_Amount_Period__c)) {
            
                //Create unique key
                String uniqueKey = sP.Contract__c + '-' + sP.Program_Subscription__c;
                
                //Check for segment Index
                if(sP.Segment_Index__c != null)
                    uniqueKey += '-' + sP.Segment_Index__c;
                
                //Add Subscription Period in map
                mapSubscriptionPeriods.put(uniqueKey, sP);
            }
        }
        
        //Check for size
        if(mapSubscriptionPeriods.size() > 0) {
            
            //List to update Next year renewal 
            List<Subscription_Period__c> subscriptionPeriodsToUpdate = new List<Subscription_Period__c>();
            
            //Loop over the Subscriptions Period map
            for(String uk : mapSubscriptionPeriods.keySet()) {
                
                //Get the Subscription Period
                Subscription_Period__c subPeriod = mapSubscriptionPeriods.get(uK);
                
                //Check for segment Index
                if(subPeriod.Segment_Index__c != null) {
                    
                    //Create unique Key to get the next Year Subscription Period
                    String nextYearUK = subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__c + '-' + (subPeriod.Segment_Index__c + 1);
                    
                    //Check value in map
                    if(mapSubscriptionPeriods.containsKey(nextYearUK)) 
                      subscriptionPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Renewal_Negotiated__c = mapSubscriptionPeriods.get(nextYearUK).Negotiated_Amount_Period__c));
                    else if(mapSubscriptionPeriods.containsKey(subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__c))  
                      subscriptionPeriodsToUpdate.add(new Subscription_Period__c(Id = subPeriod.Id, Renewal_Negotiated__c = mapSubscriptionPeriods.get(subPeriod.Contract__c + '-' + subPeriod.Program_Subscription__c).Negotiated_Amount_Period__c));
                }   
            }
            
            //Check for list size
            if(subscriptionPeriodsToUpdate.size() > 0) {
                
                //Bypass triggers
                Util.BypassAllTriggers = true;
                
                //Update
                update subscriptionPeriodsToUpdate;
                
                //Enable triggers
                Util.BypassAllTriggers = false;
            }
        } */      
    }
    
    /**
     * 
     *  @description    :   This method is used to populate the Previous Period Negotiated
     *                      Rule: A067
     *            Execution Critieria:
     *            The Subscription Period record is created and/or the Previous Subscription Period lookup field is populated or a Contract ABC based
     *            opportunity is being converted to the new Subscription model
     *            
     *                      Rule:
     *            If linking to the Previous Subscription Period, copy the Negotiated Amount from that record to the Previous Year
     *            Negotiated on this record.  
   *            If converting from the Contract ABC model, copy the value from the most recent closed Opportunity to the earliest
   *            Subscription Period year record.  During a data conversion, the previous Contract ABC record will be linked to the
   *            parent Program Subscription record (see this diagram - https://advisory.my.salesforce.com/069C0000002bMQXIA2).
   *            To get the most recent closed Opportunity, go up to the parent Program Subscription, and use the Previous Contract ABC
   *            link.  Then get the most recent closed Opp related to that Contract ABC.
   *            
   *            NOTE - this is a one-time population.  Once it is populated the first time, the value can be updated as needed
   *            separaetely from the actual source values.
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created by Subhash Garhwal - 06/06/2017 - CR-20170403-10807
     *                      V_1.1 - Modified by Subhash Garhwal - 08/02/2018 - CR-20180205-11957 - update 'Previous_Period_Negotiated__c' and 'Previous_Period_Negotiated_Components__c' from the Negotiated_Amount_Period__c' and 'Renewal_Negotiated__c' fields of Previous SP
     * 
     **/
  public static void populatePreviousPeriodNegotiated(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {

      
    //Set to hold the Previous Subscription Period Ids
    Set<Id> setPreviousSubPeriods = new Set<Id>();
    
    //Set to hold the Program Subscription Ids
    Set<Id> setProgramSubscriptions = new Set<Id>();
    
    //Set to hold the Subscription Period Ids
    Set<Id> setSubPeriodIds = new Set<Id>();
    
    //Map to hold the Subscription Periods where Renewal_Negotiated__c or Negotiated_Amount_Period__c is changing
    Map<Id, Subscription_Period__c> mapOfSPsNegotiatedAmountChanged = new Map<Id, Subscription_Period__c>();
    
    //Loop over the subscription period
    for(Subscription_Period__c sP : subscriptionPeriods) {
            
      //Modified by - Subhash Garhwal - replace 'Negotiated_Amount_Period__c' with 'Renewal_Negotiated__c' as per the requirement on CR-20180205-11957
      //Check for appropriate condition to fire the trigger logic
      if(mapOldSubscriptionPeriods == null || sP.Previous_Subscription_Period__c != mapOldSubscriptionPeriods.get(sP.Id).Previous_Subscription_Period__c
        || sP.Program_Subscription__c != mapOldSubscriptionPeriods.get(sP.Id).Program_Subscription__c
        || sP.Negotiated_Amount_Period__c != mapOldSubscriptionPeriods.get(sP.Id).Negotiated_Amount_Period__c
        || sP.Renewal_Negotiated__c != mapOldSubscriptionPeriods.get(sP.Id).Renewal_Negotiated__c) {
          
        //Check where Renewal_Negotiated__c or Negotiated_Amount_Period__c is changing
        if(mapOldSubscriptionPeriods != null && mapOldSubscriptionPeriods.get(sP.Id) != null 
            && (sP.Negotiated_Amount_Period__c != mapOldSubscriptionPeriods.get(sP.Id).Negotiated_Amount_Period__c
            || sP.Renewal_Negotiated__c != mapOldSubscriptionPeriods.get(sP.Id).Renewal_Negotiated__c)) {
            
            //Put values into the map
            mapOfSPsNegotiatedAmountChanged.put(sP.Id, sP);
        
        } else {
            
            //Check for Previous Subscription Period
            if(sP.Previous_Subscription_Period__c != null)
              setPreviousSubPeriods.add(sP.Previous_Subscription_Period__c);
            else if(sP.Program_Subscription__c != null)
              setProgramSubscriptions.add(sP.Program_Subscription__c);
        }
        //Add Id in set
        setSubPeriodIds.add(sP.Id);  
      }
    } 
    
      
    //Check for size
    if(setPreviousSubPeriods.size() > 0 || setProgramSubscriptions.size() > 0 || (mapOfSPsNegotiatedAmountChanged != null && mapOfSPsNegotiatedAmountChanged.size() > 0)) {
      
      //Subhash Garhwal - 02/13/2018 - CR-20180126-11922 - Added inline query
      //Map to hold all tje previous Subscription Periods
      Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
      
      //Subhash Garhwal - 06/28/2018 - CR-20180627-12306 - Added Size check 
      if(setPreviousSubPeriods.size() > 0 || (mapOfSPsNegotiatedAmountChanged != null && mapOfSPsNegotiatedAmountChanged.size() > 0))
        
        //Query over the previous Subscription Periods
        for(Subscription_Period__c sP: [Select Id, Renewal_Negotiated__c, Negotiated_Amount_Period__c, (Select Id, Customer_Amount__c From Subscriptions__r Where Customer_Amount__c != null AND Customer_Amount__c > 0 AND Product_Code__c = 'ImplementationFee') From Subscription_Period__c
        				Where Id IN : setPreviousSubPeriods OR Id IN : mapOfSPsNegotiatedAmountChanged.keySet()]) {
            
            //Check for Id 
            if(mapOfSPsNegotiatedAmountChanged.containsKey(sP.Id)) {
                
                //Put value  into the map
                mapOfSPsNegotiatedAmountChanged.put(sP.Id, sP);
            } else {
                
                //Put value  into the map
                mapSubscriptionPeriods.put(sP.Id, sP);
            }
        }
        
      
      //Map to hold the Contract ABC with Program Subscriptions
      Map<Id, Set<Id>> mapContractABCWithProgramSubs = new map<Id, Set<Id>>();
      
      //Map to hold the Program Subscription with Latest close Opportunity amount
      Map<Id, Decimal> mapProSubWithLatestOppAmount = new Map<Id, Decimal>();
      
      if(setProgramSubscriptions.size() > 0)
      
          //SOQL over the Program Subscriptions
          for(SBQQ__Subscription__c pS : [Select Id, Previous_Contract_ABC__c From SBQQ__Subscription__c Where Id IN : setProgramSubscriptions AND Previous_Contract_ABC__c != null]) {
            
            //Check Contract ABC Id in map
            if(!mapContractABCWithProgramSubs.containsKey(pS.Previous_Contract_ABC__c))
              mapContractABCWithProgramSubs.put(pS.Previous_Contract_ABC__c, new Set<Id>());
            
            //Add Program Subscription in map
            mapContractABCWithProgramSubs.get(pS.Previous_Contract_ABC__c).add(pS.Id);  
          }
      
      //Check for Contract ABC
      if(mapContractABCWithProgramSubs.size() > 0) {
        
        //SOQL on the Opportunity to get the latest opportunities for Contrat ABC
        for(Opportunity opp : [Select Id, Amount, Signed_Opportunity_Contract__c From Opportunity Where Signed_Opportunity_Contract__c IN : mapContractABCWithProgramSubs.keySet()
                          AND ISWON = true AND ISCLOSED = true ORDER BY CloseDate DESC]) {
                            
          //Check Contract ABC in map
          if(mapContractABCWithProgramSubs.get(opp.Signed_Opportunity_Contract__c) != null) {
            
            //Loop over the Program Subscription ids
            for(Id pSId : mapContractABCWithProgramSubs.get(opp.Signed_Opportunity_Contract__c)){
              
              //Add Amount in map
              mapProSubWithLatestOppAmount.put(pSId, opp.Amount);
            }
          }                    
        }
      } 
      
      //List to update Subscription Period
      List<Subscription_Period__c> subPeriodsToUpdate = new List<Subscription_Period__c>();
      
      //Null and size check
      if(setSubPeriodIds.size() > 0 || (mapOfSPsNegotiatedAmountChanged != null && mapOfSPsNegotiatedAmountChanged.size() > 0)) {
      
          //SOQL on the Subscription Period to update the Previous Period Negotiated
          for(Subscription_Period__c sP : [Select Id, Previous_Period_Negotiated__c, Previous_Period_Negotiated_Components__c, Previous_Subscription_Period__c,Program_Subscription__c 
                                            From Subscription_Period__c Where Id IN : setSubPeriodIds
                                            OR Previous_Subscription_Period__c IN : mapOfSPsNegotiatedAmountChanged.KeySet()]) {
                                                
            //Check for Previous_Subscription_Period__c
            if((sP.Previous_Subscription_Period__c != null && mapSubscriptionPeriods.containsKey(sP.Previous_Subscription_Period__c)
              && (mapSubscriptionPeriods.get(sP.Previous_Subscription_Period__c).Renewal_Negotiated__c != null 
                || mapSubscriptionPeriods.get(sP.Previous_Subscription_Period__c).Negotiated_Amount_Period__c != null)
              && (sP.Previous_Period_Negotiated__c != mapSubscriptionPeriods.get(sP.Previous_Subscription_Period__c).Renewal_Negotiated__c
                || sP.Previous_Period_Negotiated_Components__c != mapSubscriptionPeriods.get(sP.Previous_Subscription_Period__c).Negotiated_Amount_Period__c))
              || mapOfSPsNegotiatedAmountChanged.containsKey(sP.Previous_Subscription_Period__c)) {
                
                  
              //Previous SP
              Subscription_Period__c pSP = new Subscription_Period__c();
              
              //Check for SP where Negotiated Amount (Components) or Renewal Negotiated is changing
              if(mapOfSPsNegotiatedAmountChanged.containsKey(sP.Previous_Subscription_Period__c)) {
                
                //Get Previous Subscription Period
                pSP = mapOfSPsNegotiatedAmountChanged.get(sP.Previous_Subscription_Period__c);
              } else {
              
                  //Subhash Garhwal - 02/13/2018 - CR-20180126-11922
                  //Start
                  //Get Previous Subscription Period
                  pSP = mapSubscriptionPeriods.get(sP.Previous_Subscription_Period__c);
              }
              
              //Subhash Garhwal - 11/12/2018 - Issue--CR12270--QA--00008526 - check for  Renewal_Negotiated__c & Negotiated_Amount_Period__c
              if(pSP.Renewal_Negotiated__c != null && pSP.Negotiated_Amount_Period__c != null) {
              
                  //Modified by - Subhash Garhwal - replace 'Negotiated_Amount_Period__c' with 'Renewal_Negotiated__c' as per the requirement on CR-20180205-11957
                  //Variable to hold the Previous_Period_Negotiated__c
                  Decimal previousPeriodNegotiated = pSP.Renewal_Negotiated__c;
                  Decimal previousPeriodNegotiatedComponent = pSP.Negotiated_Amount_Period__c;
                  
                  //Check for Implementation Fee Prdocut
                  if(pSP.Subscriptions__r != null && pSP.Subscriptions__r.size() > 0) {
            
                    //Loop over the Implementation Fee products
                    for(SBQQ__Subscription__c compSub : pSP.Subscriptions__r) {
                      
                      previousPeriodNegotiated -= compSub.Customer_Amount__c;
                      previousPeriodNegotiatedComponent -= compSub.Customer_Amount__c;
                    }
                  }
                  
                  if(previousPeriodNegotiated != null)
                      //Update amount and add Sub Period to list
                      sP.Previous_Period_Negotiated__c = previousPeriodNegotiated;
                  
                  if(previousPeriodNegotiatedComponent != null)
                    sP.Previous_Period_Negotiated_Components__c = previousPeriodNegotiatedComponent;
              }
                 
              //End - CR-20180126-11922
              
              //Add reord in list
              subPeriodsToUpdate.add(sP);
            
            } else if(sP.Previous_Subscription_Period__c == null && sP.Program_Subscription__c != null && mapProSubWithLatestOppAmount.containsKey(sP.Program_Subscription__c)
                  && sP.Previous_Period_Negotiated__c != mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c)) {
                    
              //Update amount and add Sub Period to list
              sP.Previous_Period_Negotiated__c = mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c);
              sP.Previous_Period_Negotiated_Components__c = mapProSubWithLatestOppAmount.get(sP.Program_Subscription__c);
              
              //Add reord in list
              subPeriodsToUpdate.add(sP);
            }
          }
      }
        
      //Check for list size
      if(subPeriodsToUpdate.size() > 0) {
        
        //Bypass all triggers
                Util.BypassAllTriggers = true;
                
                update subPeriodsToUpdate;
                
                //Reset the flag
                Util.BypassAllTriggers = false;
        
      }
    }
  }
  
  /**
     * 
     *  @description    :   This method is used to update Negotiated_Amount_Period__c on Pending Sub Period
     *
     *  @args           :   List<Subscription_Period__c> 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/06/2017 - Subhash Garhwal - CR-20170403-10807 (DS114)
     *            V_1.1 - Modified - 09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609 - Commented out the method
     * 
     **/
  /*public static void updateNegotiatedAmountPeriod(List<Subscription_Period__c> subscriptionPeriods) {
    
    //Set to hold the Program Subscription Id
    Set<Id> setProSubIds = new Set<Id>();
    
    //Loop over the Sub Period
    for(Subscription_Period__c sP : subscriptionPeriods) {
      
      //Check values
      if(sP.Program_Subscription__c != null && sP.Segment_Index__c == null && sP.Stage__c == 'Pending')
        setProSubIds.add(sP.Program_Subscription__c);  
    }
    
    //Check for set
    if(setProSubIds.size() > 0) {
      
      //SOQL over Program Subscription
      Map<Id, SBQQ__Subscription__c> mapProSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, Previous_Period_Plus_Uplift__c From SBQQ__Subscription__c Where Id IN : setProSubIds]);
      
      //Loop over the Sub Period
      for(Subscription_Period__c sP : subscriptionPeriods) {
        
        //Check values
        if(sP.Program_Subscription__c != null && sP.Segment_Index__c == null && sP.Stage__c == 'Pending' && mapProSubscriptions.containsKey(sP.Program_Subscription__c))
          sP.Previous_Period_Negotiated__c = mapProSubscriptions.get(sP.Program_Subscription__c).Previous_Period_Plus_Uplift__c;
      }
    }
  } */
  
  /**
  * 
  *  @description    :  Method to populate "Renewal_Year_Half__c" and YouVisit Package field on Subscription Period 
  *
  *  @args           :  List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
  *
  *  @return         :  void
  *
  *  @revision Log   :  V_1.0 - Created  By - Subhash Garhwal- 06/06/2017
  *            		V_1.1 - Modified By - 02/21/2018 - Subhash Garhwal - CR-20180214-12041 - Updated "populateRenewalYearHalfOnSubPeriod"
  * 			V_1.2 - Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
  * 
    **/
	public static void populateRenewalYearHalfOnSubPeriod(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldsubscriptionPeriods) {
    
    	//Modified by - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Create a Map of Subscription Period to be updated
    	//Map<Id, Subscription_Period__c> mapSubscriptionPeriodWithIds = new Map<Id, Subscription_Period__c>();
    	Map<Id, List<Subscription_Period__c>> mapProgSubIdWithSubscriptionPeriods = new Map<Id, List<Subscription_Period__c>>();

        //Loop through subscription Period 
        for(Subscription_Period__c sP : subscriptionPeriods) {
            
            //Commented as per CR-20180214-12041 
            //Check for condition
            if(sP.Renewal_Quarter__c != null /*&& (mapOldsubscriptionPeriods == null || sP.Renewal_Quarter__c != mapOldsubscriptionPeriods.get(sP.Id).Renewal_Quarter__c )*/) {
                
                //Process if condition is true
                if(sP.Renewal_Quarter__c == 'Q1' || sP.Renewal_Quarter__c == 'Q2') 
                    sP.Renewal_Year_Half__c = 'H1';
                
                //Process if condition is true
                else if(sP.Renewal_Quarter__c == 'Q3' || sP.Renewal_Quarter__c == 'Q4') 
                    sP.Renewal_Year_Half__c = 'H2';
                
                //If above condition not meets then 
                else 
                    sP.Renewal_Year_Half__c = '';
            }
            //Process if above conditon is not true as per CR-20180214-12041 
            else
                sP.Renewal_Year_Half__c = '';  
            
            //Modified by - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Check which Subscription Period to be updated 
            // Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
            if(sP.Program_Subscription__c != null 
               && (mapOldsubscriptionPeriods == null 
                   || (mapOldsubscriptionPeriods != null 
                       && (/*sP.YouVisit_Package_Type__c != mapOldsubscriptionPeriods.get(sP.Id).YouVisit_Package_Type__c
							||*/ sP.Program_Subscription__c != mapOldsubscriptionPeriods.get(sP.Id).Program_Subscription__c )
                      )
                  )
			) {
                sP.YouVisit_Package_Type__c = '';
                
                if(!mapProgSubIdWithSubscriptionPeriods.containsKey(sP.Program_Subscription__c))
                    mapProgSubIdWithSubscriptionPeriods.put(sP.Program_Subscription__c, new List<Subscription_Period__c>());
                
                mapProgSubIdWithSubscriptionPeriods.get(sP.Program_Subscription__c).add(sP);
            }
        }
	
    //Modified by - Neha Sharma - CR-20200910-14498 - 10/19/2020 - Update YouVisit Package value with CPQ Subscription's You Visit package value
    if(!mapProgSubIdWithSubscriptionPeriods.isEmpty() && mapProgSubIdWithSubscriptionPeriods.keySet().size() > 0) {
	
       // Modified by - Neha Sharma - CR-20210105-14771 - 05/21/2021 - Update Virtual Tour Package Type Lookup
      // Query on related Subscriptions and update YouVisit Package value on Subscription Period

        
        for(SBQQ__Subscription__c sub : [Select Id, You_Visit_Package_Type_m__c From SBQQ__Subscription__c 
                                         Where Id IN: mapProgSubIdWithSubscriptionPeriods.Keyset() 
                                         AND RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_PROGRAM])
        {
            if(mapProgSubIdWithSubscriptionPeriods.containsKey(sub.Id)) {
                for(Subscription_Period__c sp : mapProgSubIdWithSubscriptionPeriods.get(sub.Id)){
                    sp.YouVisit_Package_Type__c = sub.You_Visit_Package_Type_m__c;
                }
            }
        }
    }
  }
   
  
  /**
  * 
  *  @description    :  Method to update the Decision Type field according to parent Program Subscription
  *            1. If the Opt Out Type is Funds Appropriation Opt Out or any of the Annual Opt Out options, then the first Subscription
  *              Period (Period 1) Decision Type is 'Fixed Term', and the future ones are 'Opt Out'.  
  *            2. If the Opt Out Type is set to Board Approval or any of the Rolling options, the Decision Type is 'Opt Out'
  *              across all periods.
  *            3. If the Opt Out Type is one of the One Point in Time or Opt Out after First Year selections, the Subscription Period
  *               record that contains the date of the Opt Out Early Termination Date would be set to 'Opt Out' and all other periods
  *               would be set to 'Fixed Term'.  
  *
  *  @args             :   List<Subscription_Period__c>
  *
  *  @return           :   void
  *
  *  @revision Log     :   V_1.0 - Created  By - Subhash Garhwal- 06/29/2017 - Issue--CR10808--QA--00004803
  *                        V_1.1 - Modified By - Subhash Garhwal- 08/16/2017 - Issue--CR11094--QA--00005364
  * 		           V_1.2 - Modified By - Mahendra Swarnkar - 07/02/2019 - CR-20190219-12888
  * 
    **/
  public static void updateDecisionType(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldsubscriptionPeriods) {
    
    //Set to hold the Program Subscription Ids
    Set<Id> setProgramSubscriptionIds = new Set<Id>();
    
    //Set to hold the new Subscription Period record Ids
    Set<Id> setNewSubPeriodIds = new Set<Id>();
    
    //Loop over the Subscription Periods
    for(Subscription_Period__c sP : subscriptionPeriods) {
      
      //Add Id in set
      setNewSubPeriodIds.add(sP.Id);
      
      //Check for Program Subscription
      if(sP.Program_Subscription__c != null && (mapOldsubscriptionPeriods == null || ( sP.Program_Subscription__c != mapOldsubscriptionPeriods.get(sP.Id).Program_Subscription__c)))
        setProgramSubscriptionIds.add(sP.Program_Subscription__c);
    }
    
    //Check for Program Subscriptions
    if(setProgramSubscriptionIds.size() > 0) {
      
      //Map to hold the Subscription Periods with Program Subscription Id
      Map<Id, List<Subscription_Period__c>> mapSubscriptionPeriodsWithProSub = new Map<Id, List<Subscription_Period__c>>();
      
      //Map to hold the Program Subscription Id with first Subscription Period
      Map<Id, Subscription_Period__c> mapProgramSubscriptionWithFirstSubPeriod = new Map<Id, Subscription_Period__c>();
      
      //SOQL over the Subscription Periods
      for(Subscription_Period__c sP : [Select Id, Program_Subscription__c, Period_Start_Date__c,Period_End_Date__c, Decision_Type__c,Stage__c,
                          Program_Subscription__r.Opt_Out__c, Program_Subscription__r.Early_Termination_Date__c, Program_Subscription__r.SBQQ__EndDate__c From Subscription_Period__c
                            Where Program_Subscription__c IN : setProgramSubscriptionIds ORDER BY Period_Start_Date__c ASC]) {
                                  
        //Check for new records
        if(setNewSubPeriodIds.contains(sP.Id)) {
          
          
          //Add Program Subscription in map
          if(!mapSubscriptionPeriodsWithProSub.containsKey(sP.Program_Subscription__c))
            mapSubscriptionPeriodsWithProSub.put(sP.Program_Subscription__c, new List<Subscription_Period__c>());
          
          //Add Subscription Period in map
          mapSubscriptionPeriodsWithProSub.get(sP.Program_Subscription__c).add(sP);  
        
        } else if(!mapProgramSubscriptionWithFirstSubPeriod.containsKey(sP.Program_Subscription__c) && !mapSubscriptionPeriodsWithProSub.containsKey(sP.Program_Subscription__c))
          mapProgramSubscriptionWithFirstSubPeriod.put(sP.Program_Subscription__c,sP);  
      }
      
      //Check for Subscription Period map
      if(mapSubscriptionPeriodsWithProSub.size() > 0) {
        
        //List to update the Subscription Period
        List<Subscription_Period__c> subscriptionperiodsToUpdate = new List<Subscription_Period__c>();
        
        //Loop over the Program Subscriptions
        for(Id proSubId : mapSubscriptionPeriodsWithProSub.keySet()) {
          
          //Variable to hold the first Sub Period check
          Boolean isFirstSubPeriod = true;
          
          //Check Program Subscription Id in map
          if(mapProgramSubscriptionWithFirstSubPeriod.containsKey(proSubId))
            isFirstSubPeriod = false;
            
          //Loop over the Subscription Periods
          for(Subscription_Period__c sP : mapSubscriptionPeriodsWithProSub.get(proSubId)) {
            
            //Check for Subscription Period Stage
            //Subhash Garhwal - 7/10/2017 - Issue--CR10808--QA--00004849
            ////Mahendra Swarnkar - 08/09/2019 - Issue - 302, CR-20181019-12685
            if(sP.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING && (sP.Period_Start_Date__c == null || sP.Period_Start_Date__c > sP.Program_Subscription__r.SBQQ__EndDate__c)) {
              
              //Set Descision Type to new 
              sP.Decision_Type__c = 'Need New LOA';
              
            } else if(String.isBlank(sP.Program_Subscription__r.Opt_Out__c)) {
              
              //Set Descision Type to Fixed Term
              sP.Decision_Type__c = 'Fixed Term'; 
              
            
            } else if(String.isNotBlank(sP.Program_Subscription__r.Opt_Out__c)) {
              
              //Check for Opt Out value (1st case)
              if(CPQConstants.CPQ_SUBSCRIPTION_FUND_AND_ANNUAL_OPT_OUT_TYPES.contains(sP.Program_Subscription__r.Opt_Out__c)) {
                
                //Check for first Sub Period
                if(isFirstSubPeriod)
                  sP.Decision_Type__c = 'Fixed Term';
                else
                  sP.Decision_Type__c = 'Opt Out';
              
              //Check for Opt Out value (2nd case)
              } if(CPQConstants.CPQ_SUBSCRIPTION_BOARD_AND_ROLLING_OPT_OUT_TYPES.contains(sP.Program_Subscription__r.Opt_Out__c)) {
                
                //Set Decision Type
                sP.Decision_Type__c = 'Opt Out';
              
              //Check for Opt Out value (3rd case)
              } if(CPQConstants.CPQ_SUBSCRIPTION_ONE_POINT_AND_AFTER_FIRST_YEAR_OPT_OUT_TYPES.contains(sP.Program_Subscription__r.Opt_Out__c)) {
                
                //Check for Start and End Date
                if(sP.Program_Subscription__r.Early_Termination_Date__c != null && sP.Period_Start_Date__c != null && sP.Period_End_Date__c != null
                  && sP.Program_Subscription__r.Early_Termination_Date__c >= sP.Period_Start_Date__c
                  && sP.Program_Subscription__r.Early_Termination_Date__c <= sP.Period_End_Date__c)
                  sP.Decision_Type__c = 'Opt Out';
                else
                  sP.Decision_Type__c = 'Fixed Term';
				  
              } 
                
		/**Added by Mahendra Swarnkar - CR-20190219-12888 - 07/02/2019 - Starts from here**/
                //Check if opt out type is 'Annual Opt-In' or 'Point in time Opt-In' then populate the decission type with "Opt In"
                if(CPQConstants.CPQ_SUBSCRIPTION_OPT_IN_TYPES.contains(sP.Program_Subscription__r.Opt_Out__c)){
                    sP.Decision_Type__c = CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_IN;
                }
                /**Added by Mahendra Swarnkar - CR-20190219-12888 - 07/02/2019 - Ends here**/
            }
            
            //Add Subscription Period record in list
            subscriptionperiodsToUpdate.add(sP);
            
            isFirstSubPeriod = false;
          }
        }
        //Check for Subscription Period list size
        if(subscriptionperiodsToUpdate.size() > 0) {
          
          //By pass triggers
           Util.byPassAllTriggers = true;
           update subscriptionperiodsToUpdate;
           Util.byPassAllTriggers = false;
        }
      }
    }
  }
  
  /**
   * 
   *  @description    :  Method to update the Stage (Period) field on all the child Component Subscription on Stage change
   *
   *  @args             :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
   *
   *  @return           :   void
   *
   *  @revision Log     :   V_1.0 - Created  By - Subhash Garhwal- 07/21/2017 - Issue--CR10810--QA--00005089
   * 
     **/
  public static void validateCompSubscriptions(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
    
    //Set to hold the Subscription Period Ids
    Set<Id> setSubPeriodIds = new Set<Id>();
    
    //Map to update the Program Subscriptions
    Map<Id, SBQQ__Subscription__c> mapProgramSubscriptions = new Map<Id, SBQQ__Subscription__c>();
    
    //Loop over the Subscription Periods
    for(Subscription_Period__c sP : subscriptionPeriods) {
        
        //Add condition to update the Stage (Program) on Program Subscription
        /*if(sP.Stage__c != null && sP.Program_Subscription__c != null && (mapOldSubscriptionPeriods == null
            || sP.Program_Subscription__c != mapOldSubscriptionPeriods.get(sP.Id).Program_Subscription__c
                                                                       || sP.Stage__c != mapOldSubscriptionPeriods.get(sP.Id).Stage__c) && !mapProgramSubscriptions.containsKey(sP.Program_Subscription__c)){
            
            mapProgramSubscriptions.put(sP.Program_Subscription__c, new SBQQ__Subscription__c(Id = sP.Program_Subscription__c, Stage_Period__c = sP.Stage__c)); 
        }*/
        
        
        //Add condition to update the Stage (Program) on Program Subscription
        if(sP.Stage__c != null && sP.Program_Subscription__c != null && mapOldSubscriptionPeriods != null && (sP.Program_Subscription__c != mapOldSubscriptionPeriods.get(sP.Id).Program_Subscription__c
                                                                       || sP.Stage__c != mapOldSubscriptionPeriods.get(sP.Id).Stage__c) && !mapProgramSubscriptions.containsKey(sP.Program_Subscription__c)){
            
            mapProgramSubscriptions.put(sP.Program_Subscription__c, new SBQQ__Subscription__c(Id = sP.Program_Subscription__c, Stage_Period__c = sP.Stage__c)); 
        }
        
      //Check for Stage field
      if(mapOldSubscriptionPeriods != null && sP.Stage__c != mapOldSubscriptionPeriods.get(sP.Id).Stage__c)
        setSubPeriodIds.add(sP.Id);  
    }
      
    //Check for size
    if(mapProgramSubscriptions.size() > 0) {
      
      //By pass triggers
      Util.byPassAllTriggers = true;
            
            //Update records
      update mapProgramSubscriptions.values();
      
      Util.byPassAllTriggers = false;
    }
    
    //Check for set size
    if(setSubPeriodIds.size() > 0) {
      
      //List to update the Comp. Subscriptions
      List<SBQQ__Subscription__c> compSubscriptions = new List<SBQQ__Subscription__c>();
      
      //SOQL over the Comp. Subscriptions
      for(SBQQ__Subscription__c cSub : [Select Id, Subscription_Period__c, Subscription_Period__r.Stage__c, Stage_Period__c From SBQQ__Subscription__c
                             Where Subscription_Period__c IN : setSubPeriodIds]) {
                               
        //Check for Stage
        if(cSub.Subscription_Period__c != null && cSub.Stage_Period__c != cSub.Subscription_Period__r.Stage__c) {
          
          //Update Stage
          cSub.Stage_Period__c = cSub.Subscription_Period__r.Stage__c;
          
          //Add record in list to update
          compSubscriptions.add(cSub);
        }           
      }
      
      //Check for list size
      if(compSubscriptions.size() > 0) {
        
        //By pass triggers
        Util.byPassAllTriggers = true;
                
                //Update records
        update compSubscriptions;
        
        Util.byPassAllTriggers = false;
      }
    }
  }
  
  /**
   * 
   *  @description    :  Method to populate subscription period fields.
   *              1 - Check for insert case and set the flag which will indicate that executing transaction is first transaction even in update case. 
                   Reason why we considering first transaction only, we need to populate Renewal_Negotiated__c field with "Negotiated Amount (Period)" but 
                   "Negotiated Amount (Period)" do not populate while creating the record. It get's populated via rollup and workflow. So after update we can get the first value.
   *              2 - Check for the insert/update case with appropritate field value. In update case flag must be checked.
   *              3 - Fill the map with Subscription Period records and update.
   *              4 - After update flag should be reset, because if field is populated in insert case itself no need to update in update case.                
   *
   *  @args             :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
   *
   *  @return           :   void
   *
   *  @revision Log     :   V_1.0 - Created  By - Saurabh Kumar - 08/11/2017 - Issue--CR11094--UAT--00005392
   *                        V_1.1 - Modified By -  - Subhash Garhwal - 08/25/2017 -Issue--CR11141--QA--00005572
   *                        V_1.2 - Modified By - Subhash Garhwal - 08/02/2018 - CR-20180205-11957 - prevent to replace value of Renewal_Negotiated__c for renewal contract 1st year SP
   * 
     **/
  public static void populateSubscriptionPeriodFields(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> oldSubscriptionPeriods){

    //Set to hold the program subscription Id
    Set<Id> setProgramSubscriptionIds = new Set<Id>(); 

    //Checking for insert case and set the flag
    if(Trigger.isInsert)
      CPQConstants.SUBSCRIPTION_PERIOD_TRIGGER_INSERT_CASE = true;

    //Processing on the new record
    for(Subscription_Period__c sp : subscriptionPeriods){
            
      //Check for Condition
      if(sp.Negotiated_Amount_Period__c != null && sp.Negotiated_Amount_Period__c != sP.Renewal_Negotiated__c && (oldSubscriptionPeriods == null
        || (sp.Negotiated_Amount_Period__c != oldSubscriptionPeriods.get(sp.Id).Negotiated_Amount_Period__c && CPQConstants.SUBSCRIPTION_PERIOD_TRIGGER_INSERT_CASE)))
        setProgramSubscriptionIds.add(sp.Program_Subscription__c);
    }
    
    //Check for Program Subscription size
    if(setProgramSubscriptionIds.size() > 0) {
      
      //SOQL over the Program Subscription
      Map<Id, SBQQ__Subscription__c> mapProgramSubscription = new Map<Id,SBQQ__Subscription__c> ([Select Id, SBQQ__EndDate__c From SBQQ__Subscription__c Where Id IN: setProgramSubscriptionIds AND SBQQ__EndDate__c != null]);
  
      //Perocessing on the new records
      for(Subscription_Period__c sp : subscriptionPeriods){
  
        //Checking for insert and update case with appropriate fields values and flag
        if(sp.Negotiated_Amount_Period__c != null && sp.Negotiated_Amount_Period__c != sP.Renewal_Negotiated__c &&
          (oldSubscriptionPeriods == null || (sp.Negotiated_Amount_Period__c != oldSubscriptionPeriods.get(sp.Id).Negotiated_Amount_Period__c &&
                CPQConstants.SUBSCRIPTION_PERIOD_TRIGGER_INSERT_CASE))){ 
                    
          if((mapProgramSubscription.containsKey(sp.Program_Subscription__c) 
                && sp.Period_Start_Date__c != null 
                && sp.Status__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING  
                && mapProgramSubscription.get(sp.Program_Subscription__c).SBQQ__EndDate__c.daysBetween(sp.Period_Start_Date__c) == 1)
            || (oldSubscriptionPeriods != null && oldSubscriptionPeriods.get(sp.Id) != null 
                && sp.Source_Opportunity__c != null && oldSubscriptionPeriods.get(sp.Id).Source_Opportunity__c != null
                && sp.Stage__c != null && oldSubscriptionPeriods.get(sp.Id).Stage__c != null
                && sp.Contract__c != null && oldSubscriptionPeriods.get(sp.Id).Contract__c != null
                && sp.Source_Opportunity__c != oldSubscriptionPeriods.get(sp.Id).Source_Opportunity__c
                && sp.Stage__c != oldSubscriptionPeriods.get(sp.Id).Stage__c 
                && sp.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL
                && oldSubscriptionPeriods.get(sp.Id).Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING
                && sp.Contract__c != oldSubscriptionPeriods.get(sp.Id).Contract__c)
            || (oldSubscriptionPeriods != null && oldSubscriptionPeriods.get(sp.Id) != null 
                && sp.Negotiated_Amount_Period__c != null && oldSubscriptionPeriods.get(sp.Id).Negotiated_Amount_Period__c != null
                && sP.Segment_Index__c != null
                && sp.Negotiated_Amount_Period__c != oldSubscriptionPeriods.get(sp.Id).Negotiated_Amount_Period__c
                && sP.Segment_Index__c == 1))
            continue;
          
          //Set Renewal Negotiated amount
          sP.Renewal_Negotiated__c = sp.Negotiated_Amount_Period__c;
        }
      }
    }
  }
    
    /**
   *  @Description  :  The method is used to Negotiated amount (Period) on the Pending Subscription Period with the Uplift logic.
   *
   *  @args      :  List<SBQQ__Subscription__c>, Map<Id,SBQQ__Subscription__c>
   *
   *  @return      :  Void
   *
   *  @Revision Log  :  V1.0 - 09/02/2017 - Subhash Garhwal - Issue--CR11062--QA--00005609
   *
   **/
  public static void updatePendingSPNegotiatedAmountPeriod(List<Subscription_Period__c> subPeriods, Map<Id,Subscription_Period__c> mapOldSubPeriods) {
    
    //Set to hold the Program Subscription Ids
    Set<Id> setProgramSubscriptionIds = new Set<Id>();
    
    //Loop over the Subscription Periods
    for(Subscription_Period__c sP : subPeriods) {
      
      //Check for field values
      if(sP.Program_Subscription__c != null && sP.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING &&
        (mapOldSubPeriods == null || sP.Stage__c != mapOldSubPeriods.get(sP.Id).Stage__c || sP.Program_Subscription__c != mapOldSubPeriods.get(sP.Id).Program_Subscription__c)) {
        
        //Add Program Subscription Id in set
        setProgramSubscriptionIds.add(sP.Program_Subscription__c);
      }
    }
    
    //Check for set size
    if(setProgramSubscriptionIds.size() > 0) {
      
      //SOQL over the component subscription
      List<SBQQ__Subscription__c> componentSubscriptions = [Select Id, RecordTypeId, Subscription_Period__c, Program_Subscription__c, SBQQ__CustomerPrice__c, SBQQ__Quantity__c From SBQQ__Subscription__c Where Program_Subscription__c IN : setProgramSubscriptionIds
                                     AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT];
      
      //Check for size
      if(componentSubscriptions.size() > 0)
        SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(componentSubscriptions, null);
    }
  }
  
  
   /**
   *  @Description  :  The method is used to populate the  CT Manager Email Field of Subscription Period 
   *
   *  @args      :  List<Subscription_Period__c>, Map<Id,Subscription_Period__c>
   *
   *  @return      :  Void
   *
   *  @Revision Log  :  V1.0 - 02/05/2018 - Subhash Garhwal - CR-20180126-11912 
   *
   **/
   public static void populateCTManagerEmail(List<Subscription_Period__c> subscriptionPeriods, Map<Id,Subscription_Period__c> mapOldSubPeriod) {
     
     //Map to hold the Email of manager with respact to User id 
        Map<Id, String> mapuserWithManagerEmail = new map<Id, String> ();
        
        //List to hold the Subscription Period 
        List<Subscription_Period__c> subscriptionPeriodToBeUpdate = new List<Subscription_Period__c> ();
        
        //Set to hold the Sub Period Ids
        Set<Id> setSubPeriods = new Set<Id>();
        
        //loop on the Period List
         for(Subscription_Period__c sPeriod : subscriptionPeriods) {
           
             if(mapOldSubPeriod == null || mapOldSubPeriod.get(sPeriod.Id).CT_Assignment__c != sPeriod.CT_Assignment__c)
               setSubPeriods.add(sPeriod.Id);
         }
        
        //List to hole the Subscription Period 
        List<Subscription_Period__c> newSubscriptionPeriod = new List<Subscription_Period__c>();
            
        //Check the Size of Set
    if(setSubPeriods.size()> 0 ) {
          
          //Query on the Sub Period 
       for(Subscription_Period__c sP:  [Select Id, CT_Assignment__c, CT_Assignment__r.Manager.Email, CT_Assignment_s_Manager_Email__c,  
                                                Program_Subscription__r.OwnerId,  Owner_Manager_Email__c From Subscription_Period__c
                              Where Id IN: setSubPeriods] ) {
         
           mapuserWithManagerEmail.put(sP.Program_Subscription__r.OwnerId, '');
                newSubscriptionPeriod.add(sP);
         }
            
        //Query on USER 
        for(User u : [Select Id, Manager.Email From User Where Id IN : mapuserWithManagerEmail.keySet()])
            mapuserWithManagerEmail.put(u.Id, u.Manager.Email);
            
            //Check the Size of list
            if(newSubscriptionPeriod.size() > 0) {
                //Loop on the list of Speriod 
                for(Subscription_Period__c sPeriod : newSubscriptionPeriod) {
                    
                    //Check if the Owner email and CT Manager are Different than the Email Address 
                    if(sPeriod.CT_Assignment_s_Manager_Email__c != sPeriod.CT_Assignment__r.Manager.Email 
                        || sPeriod.Owner_Manager_Email__c != mapuserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId))   {
                        
                        //Fill the Right Email Address on both of the speriod.
                        sPeriod.CT_Assignment_s_Manager_Email__c = sPeriod.CT_Assignment__r.Manager.Email ;
                        sPeriod.Owner_Manager_Email__c = mapuserWithManagerEmail.get(sPeriod.Program_Subscription__r.OwnerId);
                        
                        subscriptionPeriodToBeUpdate.add(new Subscription_Period__c(Id = sPeriod.Id, 
                                                                                    CT_Assignment_s_Manager_Email__c = sPeriod.CT_Assignment_s_Manager_Email__c,
                                                                                    Owner_Manager_Email__c = sPeriod.Owner_Manager_Email__c ));
                    }
                }  
          }
            
          //Bypass all Triggers
          Util.ByPassAllTriggers = true;
          
          //Check the Size of List
          if(subscriptionPeriodToBeUpdate.size() > 0)
            update subscriptionPeriodToBeUpdate;
            
          //Bypass all Triggers
          Util.ByPassAllTriggers = false;
    }
     }
     
      /**
   *  @Description  :  The method is used to populate the Negotiated Amount on the Subscripotion period 
   *
   *  @args      :  List<Subscription_Period__c>, Map<Id,Subscription_Period__c>
   *
   *  @return      :  Void
   *
   *  @Revision Log  :  V1.0 - 02/05/2018 - Subhash Garhwal - CR-20180207-12036
   *
   **/
     public static void populateNegotiatedAmountFutureSubPeriod(List<Subscription_Period__c> subscriptionPeriods, Map<Id,Subscription_Period__c> mapoldSubscriptionPeriod) {
       
       //Set to hold the Ids of Susbcription ids 
       Set<Id> setSubscriptionPeriod = new Set<Id>();
       
       //set to hold the Ids of Subscription period 
       for(Subscription_Period__c sPeriod : subscriptionPeriods) {
         
         //check for the subscription period End date or start date changes - Check for the only Update case
         if(subscriptionPeriods != null && mapoldSubscriptionPeriod != null 
           && (mapoldSubscriptionPeriod.get(sPeriod.Id).Period_Start_Date__c != sPeriod.Period_Start_Date__c 
               || mapoldSubscriptionPeriod.get(sPeriod.Id).Period_End_Date__c != sPeriod.Period_End_Date__c )) {
                 
           
           //Fill the Set of the with the Subscription Petriod 
           setSubscriptionPeriod.add(sPeriod.Id);        
           }
       }
       
       //Check for the Set size
       if(setSubscriptionPeriod.size() > 0) { 
         
         //Fetch all the component Subscription from the Susbcription period
         List<SBQQ__Subscription__c> subscriptions = [Select Id, SBQQ__CustomerPrice__c, SBQQ__Quantity__c, Subscription_Period__c, Program_Subscription__c, RecordTypeId, SBQQ__SegmentIndex__c,
                               SBQQ__SegmentUplift__c From SBQQ__Subscription__c Where Subscription_Period__c IN: setSubscriptionPeriod 
                               AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT ];
         
         //Check for the list of subscription 
         if(subscriptions.size() > 0) {  
                             
                //Call subscription trigger helper Method   
                SBQQ_SubscriptionTriggerHelper.updatePendingSPNegotiatedAmountPeriod(subscriptions, null);
                //VH 3/13/18 - commented out the line below.  Merged updateProposalValueForFutureSubPeriod() with updatePendingSPNegotiatedAmountPeriod()
           //SBQQ_SubscriptionTriggerHelper.updateProposalValueForFutureSubPeriod(subscriptions, null); 
         }
       }
     }
     
   /**
  *  @Description  :  The method is used to syn Previous_Period_Negotiated__c on chnage of Negotiated_Amount_Period__c
  *
  *  @args      :  List<Subscription_Period__c>, Map<Id,Subscription_Period__c>
  *
  *  @return      :  Void
  *
  *  @Revision Log  :  V1.0 - 02/28/2018 - Subhash Garhwal - CR-20180228-12087
  *
  **/
  public static void syncPreviousPeriodNegotiated(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods){
        
        //Set to hold SubscriptionPeriod Id
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
        
        //Processing on new records
        for(Subscription_Period__c subscriptionPeriod : subscriptionPeriods){
          
            //Checking for update case only 
            if(mapOldSubscriptionPeriods != null && subscriptionPeriod.Negotiated_Amount_Period__c != mapOldSubscriptionPeriods.get(subscriptionPeriod.Id).Negotiated_Amount_Period__c)
                setSubscriptionPeriodIds.add(subscriptionPeriod.Id);
        }
        
        //Checking for set size
        if(setSubscriptionPeriodIds != null && setSubscriptionPeriodIds.size() > 0){
            
            //Query on the Subscription Period record
            List<Subscription_Period__c> subperiods = [Select Id, Name, Previous_Subscription_Period__c, Program_Subscription__c,
                                                               Negotiated_Amount_Period__c, Previous_Period_Negotiated__c From Subscription_Period__c
                                                               Where Previous_Subscription_Period__c IN : setSubscriptionPeriodIds];
            
            //Checking for list size and calling the method to sync Previous_Period_Negotiated__c on the Subscription Period
            if(subperiods != null && subperiods.size() > 0)
                SubscriptionPeriodTriggerHelper.populatePreviousPeriodNegotiated(subperiods, null);
        }    
  }
  /**
   *  @description    :   Method used to populate Membership lookup value from program subscription membership field
   *
   *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
   *
   *  @return         :   void
   *
   *  @revision Log   :   V1.0 - Created - 03/29/2019 - Subhash Garhwal -Issue--CR12039--QA--00007920
   *
  **/
  public static void populateMembershipLookup(List<Subscription_Period__c> newSubsriptionPeriods, Map<Id,Subscription_Period__c> oldMapSubscriptionPeriod) {
  
    //Set to hold subscription Id
    Set<Id> setProgramSubscriptions = new Set<Id>();
    
    //Loop over newSubsriptionPeriods
    for(Subscription_Period__c subPeriod : newSubsriptionPeriods){
  
      //Check for insert or update case
      if(subPeriod.Program_Subscription__c != null && (oldMapSubscriptionPeriod == null || 
                              subPeriod.Program_Subscription__c != oldMapSubscriptionPeriod.get(subPeriod.Id).Program_Subscription__c)){
  
        //Add Id to set
        setProgramSubscriptions.add(subPeriod.Program_Subscription__c);
      }
    }
    //Process if condtion is true
    if(setProgramSubscriptions.size()>0) {
    
      //Map top hold Progrma subscription details
      Map<Id,SBQQ__Subscription__c>  mapSubscriptionDetail = new Map<Id,SBQQ__Subscription__c>([Select Id, Membership__c From SBQQ__Subscription__c Where Id IN : setProgramSubscriptions AND Membership__c != null]);
    
      //Process if Map size is greater than zero
      if(mapSubscriptionDetail.size()>0){
      
        //Loop over newSubsriptionPeriods
        for(Subscription_Period__c subPeriod : newSubsriptionPeriods){
  
          //Check if map contains subscription contains key
          if(mapSubscriptionDetail.containskey(subPeriod.Program_Subscription__c)){
            subPeriod.Membership_Lookup__c = mapSubscriptionDetail.get(subPeriod.Program_Subscription__c).Membership__c;
          }
        }
      }
    }
  }
   /**
    *   @Description    :   The method is used to populate Program fields on Event based on the related Subscription Period
    *
    *   @args           :   Map<Id, Subscription_Period__c>, List<Event>
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   V1.0 - 04/09/2018 - Colin McGloin - CR-20180327-12130
    *
    **/
    
    // Populate the program and abbreviation info on a given list of events
    public static list<Event> populateProgramInfo_EventsSP(map<Id, Subscription_Period__c> subPeriodMap, list<Event> events) {
        
        // get all Events associated with these opps and update their program / program abbreviation
        for (Event e : events) {
            
            //Checking for null and size value
            if (subPeriodMap != null && subPeriodMap.containsKey(e.WhatId) && subPeriodMap.get(e.WhatId) != null) {
                
                // get the associated Subscription Period
                Subscription_Period__c sP = subPeriodMap.get(e.WhatId);
                
                if (sP.Program_Subscription__r.Program__r.Program_Acronym__c != null) {
                    
                    // update the program
                    e.Program__c = sP.Program_Subscription__r.Program__r.Program_Acronym__c;
                }
                else {
                    
                    e.Program__c = null;
                }
            }
        }
        
        return events;
    }
    
    /**
    *   @Description    :   The method is used to populate Program fields on Task based on the related Subscription Period
    *
    *   @args           :   Map<Id, Subscription_Period__c>, List<Task>
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   V1.0 - 04/09/2018 - Colin McGloin - CR-20180327-12130
    *
    **/
    
    // Populate the program and abbreviation info on a given list of events
    public static list<Task> populateProgramInfo_TasksSP(map<Id, Subscription_Period__c> subPeriodMap, list<Task> tasks) {
        
        // get all Tasks associated with these opps and update their program / program abbreviation
        for (Task t : tasks) {
            
            //Checking for null and size value
            if (subPeriodMap != null && subPeriodMap.containsKey(t.WhatId) && subPeriodMap.get(t.WhatId) != null) {
                
                // get the asociated Subscription Period
                Subscription_Period__c sP = subPeriodMap.get(t.WhatId);
                
                if (sP.Program_Subscription__r.Program__r.Program_Acronym__c != null) {
                    
                    // update the program
                    t.Program__c = sP.Program_Subscription__r.Program__r.Program_Acronym__c;
                }
                else {
                    
                    t.Program__c = null;
                }
            }
        }
        
        return tasks;
    }
    
    /**
    *   @Description    :   The method is used to populate 'Renewal Owner' field on 'Subscription' and higher date 'Suscription Period' from active 'Suscription Period' record. Also update the owner on Membership of Program Subscription
    *
    *   @args           :   Map<Id, Subscription_Period__c> newSubscriptionPeriodMap, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   V1.0 - 05/24/2018 - Subhash Garhwal - CR-20180502-12199
    *                       V1.1 - Modifiel by Subhash Garhwal 07/12/2018 - Issue--CR12199--QA--00008128
    *
    **/
    public static void populateRenewalOwnerOnSubAndOwnerOnMembership(Map<Id, Subscription_Period__c> newSubscriptionPeriodMap, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap) {
        
        //List to hold the Subscription records to be update.
        List<SBQQ__Subscription__c> subscriptionsToBeUpdated = new List<SBQQ__Subscription__c>();
                
        //List to hold the Subscription Period records to be update
        List<Subscription_Period__c> subscriptionPeriodsToBeUpdate = new List<Subscription_Period__c>();
                
        //Map to hold the Subscription Id and its child Subscription Periods
        Map<Id, Subscription_Period__c> mapOfSubscriptionIdAndSp = new Map<Id, Subscription_Period__c>();
        
        //Modified by Subhash Garhwal - 10/11/2021 - CR-20210928-15467 - Commented the code
        //List to hold the Institution to be updated 
        //List<Account> institutionsToBeUpdated = new List<Account>();
        
        //List to hold the Renewal Opportunity to be updated
        List<Opportunity> renewalOppsToBeUpdated = new List<Opportunity>();
        
        //Set to hold the Program Subscription
        Set<Id> setProgramSubscriptionIds = new Set<Id>();
        
        //Set to hold the subscription period ids
        Set<Id> setOfSPeriodIds = new Set<Id>();
            
        //List to hold the membership to be updated 
        List<Membership__c> membershipsToBeUpdated = new List<Membership__c>();
                
        //Loop over the newSubscription .
        for(Subscription_Period__c subPeriod : newSubscriptionPeriodMap.values() ) {
            
            //Check for Renewal_Owner__c, Research_Strategic_Leader__c updating or inserting in new s periods. 
            if(subPeriod.Id != null && ((!oldSubscriptionPeriodMap.containsKey(subPeriod.Id))
                    ||((newSubscriptionPeriodMap.get(subPeriod.Id).Research_Strategic_Leader__c != null || newSubscriptionPeriodMap.get(subPeriod.Id).Renewal_Owner__c != null)
                    && newSubscriptionPeriodMap.get(subPeriod.Id).Program_Subscription__c != null 
                    && newSubscriptionPeriodMap.get(subPeriod.Id).Period_End_Date__c != null && newSubscriptionPeriodMap.get(subPeriod.Id).Period_End_Date__c >= Date.today() 
                    && (newSubscriptionPeriodMap.get(subPeriod.Id).Renewal_Owner__c != oldSubscriptionPeriodMap.get(subPeriod.Id).Renewal_Owner__c 
                    || newSubscriptionPeriodMap.get(subPeriod.Id).Research_Strategic_Leader__c != oldSubscriptionPeriodMap.get(subPeriod.Id).Research_Strategic_Leader__c)))) {
                
                    //Add Subscription Ids into the set
                    setProgramSubscriptionIds.add(subPeriod.Program_Subscription__c);
                    
                    //Add Subscription Period Ids into the set
                    setOfSPeriodIds.add(subPeriod.Id);
            }
        }
        
        //Size check
        if(setProgramSubscriptionIds.size() > 0) {
        
            //Query over the Subscription Periods 
            for(Subscription_Period__c sP : [Select Id, Program_Subscription__c, Source_Opportunity__c, Program_Subscription__r.Membership__c, Period_Start_Date__c,
                                                Period_End_Date__c, Renewal_Owner__c, Research_Strategic_Leader__c, Institution__c, Program_Subscription__r.Renewal_Opportunity__c  
                                                From Subscription_Period__c Where Program_Subscription__c != Null
                                                AND Program_Subscription__c IN : setProgramSubscriptionIds AND Period_End_Date__c != null AND Period_End_Date__c >= TODAY
                                                ORDER BY Period_Start_Date__c, Program_Subscription__c ASC]) {
                
                //Check for new Subscription Period where 'Renewal Owner' or 'Research Strategic Leader' is updating
                if(setOfSPeriodIds.contains(sP.Id)) { 
                    
                    //Contains check into the map                       
                    if(!mapOfSubscriptionIdAndSp.containsKey(sP.Program_Subscription__c)) {
                
                        //Put values into the map
                        mapOfSubscriptionIdAndSp.put(sP.Program_Subscription__c, sP);
                        
                        //Check for higher date Subscription Periods
                    } else if(mapOfSubscriptionIdAndSp.get(sP.Program_Subscription__c).Period_Start_Date__c < sP.Period_Start_Date__c) {
                
                        //Put value into the map
                        mapOfSubscriptionIdAndSp.put(sP.Program_Subscription__c, sP);
                    }
                    
                  //Check for higher date s periods 
                } else if(mapOfSubscriptionIdAndSp.containsKey(sP.Program_Subscription__c) && mapOfSubscriptionIdAndSp.get(sP.Program_Subscription__c) != null) {
                    
                    //Adding s period values into the list to be update
                    subscriptionPeriodsToBeUpdate.add(new Subscription_Period__c(Id = sP.Id, Renewal_Owner__c = mapOfSubscriptionIdAndSp.get(sP.Program_Subscription__c).Renewal_Owner__c,
                                                                                    Research_Strategic_Leader__c = mapOfSubscriptionIdAndSp.get(sP.Program_Subscription__c).Research_Strategic_Leader__c));
                }
            }
        }
        
        //Null check
        if(mapOfSubscriptionIdAndSp.size() > 0) {
        
            //Loop over the Subscription Periods
            for(Id sub : mapOfSubscriptionIdAndSp.keySet()) {
                
                //Addind values into the list to be updated.
                subscriptionsToBeUpdated.add(new SBQQ__Subscription__c(Id = sub, Renewal_Owner__c = mapOfSubscriptionIdAndSp.get(sub).Renewal_Owner__c, 
                                                                        Research_Strategic_Leader__c = mapOfSubscriptionIdAndSp.get(sub).Research_Strategic_Leader__c));
                
                 
                
                
                //Modified by Subhash Garhwal - 10/11/2021 - CR-20210928-15467 - Commented the code
                //Modifiel by Subhash Garhwal 07/12/2018 - Issue--CR12199--QA--00008128
                //Inctitution null check
                /*if(mapOfSubscriptionIdAndSp.get(sub).Research_Strategic_Leader__c != null && mapOfSubscriptionIdAndSp.get(sub).Institution__c != null)
                
                    //Add value into the list 
                    institutionsToBeUpdated.add(new Account(Id = mapOfSubscriptionIdAndSp.get(sub).Institution__c, Research_Strategic_Leader__c = mapOfSubscriptionIdAndSp.get(sub).Research_Strategic_Leader__c));
                */    
                //Modifiel by Subhash Garhwal 07/12/2018 - Issue--CR12199--QA--00008128
                //Inctitution null check
                if(mapOfSubscriptionIdAndSp.get(sub).Research_Strategic_Leader__c != null && mapOfSubscriptionIdAndSp.get(sub).Program_Subscription__r.Renewal_Opportunity__c != null)
                
                    //Add value into the list 
                    renewalOppsToBeUpdated.add(new Opportunity(Id = mapOfSubscriptionIdAndSp.get(sub).Program_Subscription__r.Renewal_Opportunity__c, Research_Strategic_Leader__c = mapOfSubscriptionIdAndSp.get(sub).Research_Strategic_Leader__c));
            }
        }
        
        //Bypass all Triggers
        Util.ByPassAllTriggers = true;
                
        //Size check
        if(subscriptionsToBeUpdated.size() > 0) 
        
            //Update mapOfSubscriptionToBeUpdated
            update subscriptionsToBeUpdated;
            
        //Size Check
        if(subscriptionPeriodsToBeUpdate.size() > 0)
        
            //Update Subscription Periods
            update subscriptionPeriodsToBeUpdate; 
            
        
        //Modified by Subhash Garhwal - 10/11/2021 - CR-20210928-15467 - Commented the code
        //Size Check
        /*if(institutionsToBeUpdated.size() > 0)
        
            //Update Institution
            update institutionsToBeUpdated; 
        */    
        //Size Check
        if(renewalOppsToBeUpdated.size() > 0)
        
            //Update Opportunity
            update renewalOppsToBeUpdated; 
        
        //Bypass all Triggers
        Util.ByPassAllTriggers = false;
    }
    
    /**
    *   @Description    :   The method is used to populate 'Close_Date__c' field on 'Subscription Period' when stage is updating from 'Opt out' to 'ATL' 
    *
    *   @args           :   List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   V1.0 Created  By - Subhash Garhwal - 08/08/2018 - CR-20180417-12162 - CR-20180827-12522
    *
    **/
    public static void populateCloseDateOnSP(List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap) {
    
        //Loop over the Subscription Periods 
        for(Subscription_Period__c sP : newSubscriptions) {
            
            //Check for Stage update
            if(oldSubscriptionPeriodMap != null && oldSubscriptionPeriodMap.get(sp.Id) != null 
                && (oldSubscriptionPeriodMap.get(sP.Id).Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING
                    && oldSubscriptionPeriodMap.get(sP.Id).Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT)
                && (sP.Stage__c != oldSubscriptionPeriodMap.get(sP.Id).Stage__c 
                    && sP.Decision_Type__c == oldSubscriptionPeriodMap.get(sP.Id).Decision_Type__c)
                && (sP.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL 
                    || sP.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_DROPPED)) {
                    
                //Update Close Date by Today  
                sP.Close_Date__c = Date.today();    
            }
            
            //Check for Profile Id and Stage change - CR-20180827-12522
            //Update check for current user profile Id - CR-20180925-12620
            if(userinfo.getProfileId() == Label.PROFILE_ID_ACCOUNT_MANAGEMENT 
                && oldSubscriptionPeriodMap.get(sP.Id).Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_STAGE_ATL
                && sP.Stage__c != oldSubscriptionPeriodMap.get(sP.Id).Stage__c 
                && sP.Stage__c == CPQConstants.SUBSCRIPTION_PERIOD_SENT_TO_FINANCE_REQUEST_DROP) {
                
                //Throw error message
                sP.addError('Account Management Profile can not change stage from ATL to Sent To Finance - Request Drop');
                
            } 
        }
    }
    
    /*public static void sentCSVForSP() {
        
        String CSVString = 'Subscription Period Id' + ',' + 'Subscription Period Name'+ ',' +  'Start date'+ ',' + 'End Date'+ ',' +'Decision type' + ','
                            + 'Stage'+ ',' + 'Current Primary Reason Lost'+ ',' + 'Current Primary Reason Lost (Additional Info)'+','+ 'Expected Primary Reason Lost'
                            + ',' + 'Expected Primary Reason Lost (Additional Info)' + ',' +'Current Secondary Reason Lost'+ ',' + 'Current Secondary Reason Lost (Additional Info)'
                            + ','+ 'Expected Secondary Reason Lost'+ ',' + 'Expected Secondary Reason Lost (Additional Info),'+ '\n';
                            
        String CSVString2 = 'Opportunity Id' + ',' + 'Opportunity Name'+ ',' +  'Start date'+ ',' + 'End Date'+  ','
                            + 'Stage'+ ','+ 'Record Type' + ',' + 'Current Primary Reason Lost'+ ',' + 'Current Primary Reason Lost (Additional Info)'+','+ 'Expected Primary Reason Lost'
                            + ',' + 'Expected Primary Reason Lost (Additional Info)' + ',' +'Current Secondary Reason Lost'+ 
                            + ','+ 'Expected Secondary Reason Lost'+ '\n';

        Set<String> setOfPrimaryResonLost = new Set<String>{'Competitor - system mandate', 'Competitor - tool in place', 'Competitor - won evaluation', 'Plan to build in-house tool', 
            'Use existing in-house tool', 'Lost to Competitor Eval', 'Already Have Competitor in Place', 'Price', 'Budget Timing', 'Financial Hardships/Limited Resources','Budget Issues',
            'Off Budget Cycle','Other','Other ABC Joins/Products','Stalled - no vendor selected','Organizational Priorities','Executive Turnover','Contact Turnover', 
            'Executive Engagement Issues','Engagement','Lack of Executive Support','Not an Executive Priority','Data Issues','Implementation Delay','Technical Functionality',
            'Marketing Expectations Not Met','ROI','Utilization','Value Concerns','Lack of Team Utilization','Value'};
        
        Set<String> setOfSecondaryResonLost = new Set<String>{'Competitor - system mandate', 'Competitor - tool in place', 'Competitor - won evaluation', 'Plan to build in-house tool', 
            'Use existing in-house tool', 'Price', 'Budget Timing', 'Financial Hardships/Limited Resources','Other','Other ABC Joins/Products','Stalled - no vendor selected','Organizational Priorities','Contact Turnover', 
            'Engagement','Lack of Executive Support','Data Issues','Implementation Delay','Technical Functionality',
            'Marketing Expectations Not Met','ROI','Utilization','End of contract - Didn\'t Renew','POC Member - Didn\'t Opt-In'};
            
        for(Opportunity opp : [Select Id, Name, Start__c, End__c, StageName, Additional_Info_Primary_Reason_Lost__c, Primary_Reason_Lost__c, Secondary_Reason_Lost__c, RecordType.Name From Opportunity
                                Where Start__c >= 2016-01-01 AND StageName = 'Dropped' AND (Primary_Reason_Lost__c != null OR Secondary_Reason_Lost__c != null) 
                                AND (Primary_Reason_Lost__c IN : setOfPrimaryResonLost OR Secondary_Reason_Lost__c IN :setOfSecondaryResonLost)
                                AND RecordType.DeveloperName != 'EAB_Initiating']){
            
            if(opp.Primary_Reason_Lost__c != null && setOfPrimaryResonLost.contains(opp.Primary_Reason_Lost__c)) {
            
                CSVString2 += opp.Id + ',' + opp.Name.remove(',') + ',' + opp.Start__c + ',' + opp.End__c + ','+ opp.StageName+ ',' + opp.RecordType.Name + ',';
                
                if(opp.Primary_Reason_Lost__c == 'Competitor - system mandate')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Competitor' + ',,';
        
                else if(opp.Primary_Reason_Lost__c == 'Competitor - tool in place')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Competitor' + ',,';
        
                else if(opp.Primary_Reason_Lost__c == 'Competitor - won evaluation')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Competitor' + ',' + 'External' + ',';
                    
                else if(opp.Primary_Reason_Lost__c == 'Price')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Value' + ',' + 'Attachment To Research'+ ',';
        
                else if(opp.Primary_Reason_Lost__c == 'Budget Timing')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Budget' + ',,';
        
                else if(opp.Primary_Reason_Lost__c == 'Financial Hardships/Limited Resources')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+ 'Budget' + ','+ 'Severe Budget Constraints (Value Not Questioned)' + ',';
        
                else if(opp.Primary_Reason_Lost__c == 'Budget Issues')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' +   'Budget' + ',,';
                    
                else if(opp.Primary_Reason_Lost__c == 'Other')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c+ ',' + 'Other' + ',,';
        
                else if(opp.Primary_Reason_Lost__c == 'Other ABC Joins/Products')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c+ ',' + 'Value' + ','+ 'Attachment To Research' + ',';
        
                else if(opp.Primary_Reason_Lost__c == 'Stalled - no vendor selected')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+ 'Value'+ ',' + 'Attachment To Research' + ',';
                    
                else if(opp.Primary_Reason_Lost__c == 'Organizational Priorities')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+ 'Value' + ','+ 'Lack Of Exec Engagement/Champion' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Executive Turnover')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+  'Contact Turnover'+ ',' + 'Executive/Leadership Turnover'+ ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Contact Turnover')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Contact Turnover' + ',' + 'Executive/Leadership Turnover'+ ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Executive Engagement Issues')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+ 'Value'+ ',' + 'Lack Of Exec Engagement/Champion' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Data Issues')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Product Issues' + ',' + 'Data Trust/Data Validity Concerns' + ',' ;
                
                else if(opp.Primary_Reason_Lost__c == 'Implementation Delay')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Product Issues' + ',' + 'Implementation Delay/Failure To Launch' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Technical Functionality')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+  'Product Issues'+ ',' + 'Feature/Product Roadmap Expectations Not Met' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Marketing Expectations Not Met')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c+ ',' + 'Value' + ',' + 'Marketing Expectations Not Met' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'ROI')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Value' + ',' + 'Lack Of Documented/Hard ROI/Impact' + ',' ;
                
                else if(opp.Primary_Reason_Lost__c == 'Utilization')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ','+ 'Value' + ',' + 'Team Utilization' +',' ;
                
                else if(opp.Primary_Reason_Lost__c == 'Value Concerns')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Value' + ',' + 'Attachment To Research' + ',';
                
                else if(opp.Primary_Reason_Lost__c == 'Lack of Team Utilization')
                    CSVString2 += opp.Primary_Reason_Lost__c + ',' + opp.Additional_Info_Primary_Reason_Lost__c + ',' + 'Value' + ',' + 'Team Utilization' +',' ;
            }
            if(opp.Secondary_Reason_Lost__c != null && setOfSecondaryResonLost.contains(opp.Secondary_Reason_Lost__c)) {
                
                if(opp.Primary_Reason_Lost__c == null || (opp.Primary_Reason_Lost__c != null && !setOfPrimaryResonLost.contains(opp.Primary_Reason_Lost__c))) {
                    
                    CSVString2 += opp.Id + ',' + opp.Name.remove(',')+',' + opp.Start__c + ',' + opp.End__c + ','+ opp.StageName + ','+ opp.RecordType.Name + ',,,,,' ;
                }
                if(opp.Secondary_Reason_Lost__c == 'Competitor - system mandate')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Competitor' + ',\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Competitor - tool in place')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Competitor' + ',\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Competitor - won evaluation')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Competitor' +  ',\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Plan to build in-house tool')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Competitor'+ ',' +'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Use existing in-house tool')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+ 'Competitor' + ',' +'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Price')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Value' + ','  + '\n' ;
    
                else if(opp.Secondary_Reason_Lost__c == 'Budget Timing')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Budget' + ',' +'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Financial Hardships/Limited Resources')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+ 'Budget' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Other')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Other' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Other ABC Joins/Products')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Value' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Stalled - no vendor selected')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+ 'Value'+ ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Organizational Priorities')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+ 'Value' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Contact Turnover')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Contact Turnover' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Engagement')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' +  'Value' + ','+'\n'; 
    
                else if(opp.Secondary_Reason_Lost__c == 'Lack of Executive Support')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Contact Turnover'  + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Data Issues')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Product Issues' + ','+'\n' ;
    
                else if(opp.Secondary_Reason_Lost__c == 'Implementation Delay')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Product Issues' + ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Technical Functionality')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+  'Product Issues'+  ','+'\n';
    
                else if(opp.Secondary_Reason_Lost__c == 'Marketing Expectations Not Met')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Value' + ','+'\n';
     
                else if(opp.Secondary_Reason_Lost__c == 'ROI')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Value' +  ','+'\n' ;
    
                else if(opp.Secondary_Reason_Lost__c == 'Utilization')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ','+ 'Value' + ','+'\n' ;
    
                else if(opp.Secondary_Reason_Lost__c == 'POC Member - Didn\'t Opt-In')
                    CSVString2 += opp.Secondary_Reason_Lost__c + ',' + 'Value' + ','+'\n';
        
            } else if(opp.Primary_Reason_Lost__c != null && (opp.Secondary_Reason_Lost__c == null || (opp.Secondary_Reason_Lost__c != null && !setOfSecondaryResonLost.contains(opp.Secondary_Reason_Lost__c)))) {
                
                CSVString2 += ',,'+'\n';
            }
        }
        
        for(Subscription_Period__c sub : [Select Id , Name, Primary_Reason_Lost__c, Primary_Reason_Lost_Additional_Info__c, Secondary_Reason_Lost__c, Secondary_Reason_Lost_Additional_Info__c,
                                            Period_Start_Date__c, Period_End_Date__c, Decision_Type__c, Stage__c From 
                                            Subscription_Period__c Where Period_Start_Date__c >= 2016-01-01 AND (Stage__c = 'Dropped' OR Stage__c = 'Sent to Finance - Request Drop')
                                            AND (Primary_Reason_Lost__c != null OR Secondary_Reason_Lost__c != null) AND (Primary_Reason_Lost__c IN : setOfPrimaryResonLost OR Secondary_Reason_Lost__c IN :setOfSecondaryResonLost)
                                            //AND (Source_Opportunity__r.RecordType.DeveloperName = 'EAB_Continuing' OR Source_Opportunity__r.RecordType.DeveloperName = 'EAB_Initiating')
                                            ]) {
        
            if(sub.Primary_Reason_Lost__c != null && setOfPrimaryResonLost.contains(sub.Primary_Reason_Lost__c)) {
                
                CSVString += sub.Id + ',' + sub.Name.remove(',') + ',' + sub.Period_Start_Date__c + ',' + sub.Period_End_Date__c + ','+ sub.Decision_Type__c + ','+ sub.Stage__c+ ',' ;
                if(sub.Primary_Reason_Lost__c == 'Competitor - system mandate')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Competitor - tool in place')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Competitor - won evaluation')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',' + 'External' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Plan to build in-house tool')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor'+ ',' + 'Building Their Own' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Use existing in-house tool')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Competitor' + ',' + 'Building Their Own' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Lost to Competitor Eval')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',' + 'External' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Already Have Competitor in Place')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',' + 'External' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Price')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Attachment To Research'+ ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Budget Timing')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Budget' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Financial Hardships/Limited Resources')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Budget' + ','+ 'Severe Budget Constraints (Value Not Questioned)' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Budget Issues')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' +   'Budget' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Off Budget Cycle')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Budget' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Other')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c+ ',' + 'Other' + ',,';
        
                else if(sub.Primary_Reason_Lost__c == 'Other ABC Joins/Products')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c+ ',' + 'Value' + ','+ 'Attachment To Research' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Stalled - no vendor selected')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Value'+ ',' + 'Attachment To Research' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Organizational Priorities')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Value' + ','+ 'Lack Of Exec Engagement/Champion' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Executive Turnover')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+  'Contact Turnover'+ ',' + 'Executive/Leadership Turnover'+ ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Contact Turnover')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Contact Turnover' + ',' + 'Executive/Leadership Turnover'+ ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Executive Engagement Issues')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Value'+ ',' + 'Lack Of Exec Engagement/Champion' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Engagement')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' +  'Value' + ',' + 'Team Utilization' + ','; 
        
                else if(sub.Primary_Reason_Lost__c == 'Lack of Executive Support')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Lack Of Exec Engagement/Champion' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Not an Executive Priority')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Lack Of Exec Engagement/Champion' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Data Issues')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Product Issues' + ',' + 'Data Trust/Data Validity Concerns' + ',' ;
        
                else if(sub.Primary_Reason_Lost__c == 'Implementation Delay')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Product Issues' + ',' + 'Implementation Delay/Failure To Launch' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Technical Functionality')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+  'Product Issues'+ ',' + 'Feature/Product Roadmap Expectations Not Met' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Marketing Expectations Not Met')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c+ ',' + 'Value' + ',' + 'Marketing Expectations Not Met' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'ROI')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Lack Of Documented/Hard ROI/Impact' + ',' ;
        
                else if(sub.Primary_Reason_Lost__c == 'Utilization')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ','+ 'Value' + ',' + 'Team Utilization' +',' ;
        
                else if(sub.Primary_Reason_Lost__c == 'Value Concerns')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Attachment To Research' + ',';
        
                else if(sub.Primary_Reason_Lost__c == 'Lack of Team Utilization')
                    CSVString += sub.Primary_Reason_Lost__c + ',' + sub.Primary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Team Utilization' +',' ;
            }
        
            if(sub.Secondary_Reason_Lost__c != null && setOfSecondaryResonLost.contains(sub.Secondary_Reason_Lost__c)) {
                
                if(sub.Primary_Reason_Lost__c == null || (sub.Primary_Reason_Lost__c != null && !setOfPrimaryResonLost.contains(sub.Primary_Reason_Lost__c))) {
                    
                    CSVString += sub.Id + ',' + sub.Name.remove(',')+',' + sub.Period_Start_Date__c + ',' + sub.Period_End_Date__c + ','+ sub.Decision_Type__c + ','+ sub.Stage__c+ ',,,,,' ;
                }
                
                
                if(sub.Secondary_Reason_Lost__c == 'Competitor - system mandate')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',,\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Competitor - tool in place')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' + ',' + 'External' + ','+ '\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Competitor - won evaluation')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Competitor' +',,\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Plan to build in-house tool')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Competitor'+ ',' + 'Building Their Own' + ',' +'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Use existing in-house tool')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Competitor' + ',' + 'Building Their Own' + ',' +'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Price')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Attachment To Research'+ ','+'\n' ;
    
                else if(sub.Secondary_Reason_Lost__c == 'Budget Timing')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Budget' + ',,' +'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Financial Hardships/Limited Resources')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Budget' + ','+ 'Severe Budget Constraints (Value Not Questioned)' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Other')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c+ ',' + 'Other' + ',,'+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Other ABC Joins/Products')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c+ ',' + 'Value' + ','+ 'Attachment To Research' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Stalled - no vendor selected')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Value'+ ',' + 'Attachment To Research' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'End of contract - Didn\'t Renew')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Value'+ ',' + 'Attachment To Research' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Organizational Priorities')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Value' + ','+ 'Lack Of Exec Engagement/Champion' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Contact Turnover')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Contact Turnover' + ',' + 'Executive/Leadership Turnover'+ ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Engagement')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' +  'Value' + ',' + 'Team Utilization' + ','+'\n'; 
    
                else if(sub.Secondary_Reason_Lost__c == 'Lack of Executive Support')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Contact Turnover' + ',' + 'Executive/Leadership Turnover' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Data Issues')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Product Issues' + ',' + 'Data Trust/Data Validity Concerns' + ','+'\n' ;
    
                else if(sub.Secondary_Reason_Lost__c == 'Implementation Delay')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Product Issues' + ',' + 'Implementation Delay/Failure To Launch' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Technical Functionality')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+  'Product Issues'+ ',' + 'Feature/Product Roadmap Expectations Not Met' + ','+'\n';
    
                else if(sub.Secondary_Reason_Lost__c == 'Marketing Expectations Not Met')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c+ ',' + 'Value' + ',' + 'Marketing Expectations Not Met' + ','+'\n';
     
                else if(sub.Secondary_Reason_Lost__c == 'ROI')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Lack Of Documented/Hard ROI/Impact' + ','+'\n' ;
    
                else if(sub.Secondary_Reason_Lost__c == 'Utilization')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ','+ 'Value' + ',' + 'Team Utilization' +','+'\n' ;
    
                else if(sub.Secondary_Reason_Lost__c == 'POC Member - Didn\'t Opt-In')
                    CSVString += sub.Secondary_Reason_Lost__c + ',' + sub.Secondary_Reason_Lost_Additional_Info__c + ',' + 'Value' + ',' + 'Attachment To Research' + ','+'\n';
        
            } else if(sub.Primary_Reason_Lost__c != null && (sub.Secondary_Reason_Lost__c == null || (sub.Secondary_Reason_Lost__c != null && !setOfSecondaryResonLost.contains(sub.Secondary_Reason_Lost__c)))) {
                
                CSVString += ',,,,'+'\n';
            }
        } 
        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Messaging.EmailFileAttachment csvAttc2 = new Messaging.EmailFileAttachment();
                blob csvBlob = Blob.valueOf(CSVString);
                blob csvBlob2 = Blob.valueOf(CSVString2);
                string csvname= 'Subscription Periods To Be Updated.csv';
                string csvname2= 'Opportunities To Be Updated.csv';
                csvAttc.setFileName(csvname);
                csvAttc2.setFileName(csvname2);
                csvAttc.setBody(csvBlob);
                csvAttc2.setBody(csvBlob2);
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                String[] toAddresses = new list<string> {'subhash.garhwal@briskminds.com', 'rajeev.jain@briskminds.com', 'asharma@eab.com'};
                String subject ='Subscription Periods and Opportunities To Be Updated';
                email.setSubject(subject);
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('Hi Subhash, Please find the comparison list attached. Thanks! ');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc, csvAttc2});
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
    }*/
    
    /**
    *   @Description    :   This method is to sync PSS Request with the Speriod.
    *
    *   @args           :   List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   Created By Abhinav Sharma - CR-20181016-12674 
    **/
    public static void syncSMERequestWithSPeriod(List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> oldSubscriptionPeriodMap) {
        
        //set to hold the subcription period ids
        set<Id> setSubPeriodsIds = new set<Id>();
        
        //check the size of the list
        if(newSubscriptions != null && newSubscriptions.size() > 0) {
            
            //loop on the new subscription period list
            for(Subscription_Period__c sP : newSubscriptions) {
                
                //check for the changes in the Fields 
                if(oldSubscriptionPeriodMap != null 
                && (oldSubscriptionPeriodMap.get(sP.Id).Institution__c != sP.Institution__c ||
                oldSubscriptionPeriodMap.get(sP.Id).Membership_Lookup__c != sP.Membership_Lookup__c )) {
                
                    //Filling the set with the subscription period 
                    setSubPeriodsIds.add(sP.Id);
                }
            }
            
            //List to hold the sme request that is going to update
            List<Pss_Request__c> smeRequestsToBeUpdated = new List<Pss_Request__c>();
            
            //Checking for the set size
            if(setSubPeriodsIds != null && setSubPeriodsIds.size() > 0) {
                
                //Query on the SPeriod records
                for(Subscription_Period__c sP : [Select Id, Institution__c, Membership_Lookup__c, Program_Subscription__r.Program__c,
                                                 (Select Id, Institution__c, Membership__c, Program__c From PSS_Requests__r) 
                                                 From Subscription_Period__c Where Id IN: setSubPeriodsIds]) {
                                                     
                    //check for list size
                    if(sP.PSS_Requests__r != null && sP.PSS_Requests__r.size() > 0) {
                        
                        //Loop on the subscription period's chile list
                        for(Pss_Request__c smeReq : sP.PSS_Requests__r) {
                            
                            //Filing the list with the updated values.
                            smeRequestsToBeUpdated.add(new Pss_Request__c(Id = smeReq.Id, Institution__c = sP.Institution__c, 
                                                                         Membership__c = sP.Membership_Lookup__c, 
                                                                         Program__c = sP.Program_Subscription__r.Program__c));
                            
                        }
                    }
                }
                
                //Check for the size of list.
                if(smeRequestsToBeUpdated != null && smeRequestsToBeUpdated.size() > 0) {
                    //Util Bypass triggers
                    Util.ByPassAllTriggers = true;
                    update smeRequestsToBeUpdated;
                    Util.ByPassAllTriggers = false;
                }
                
            }
        }       
    }
    
   /**
    *   @Description    :   This method is to Calcuate the Next Decission Date on the Membership.
    *
    *   @args           :   List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriod
    *
    *   @return         :   Void
    *
    *   @Revision Log   :   V1.1 - Created - 08/16/2017 - Victor Hanson - Issue--CR11106--QA--00005464
                            V1.2 - Modified - 12/03/2018 - Subhash Garhwal - CR-20180726-12469
    **/
    public static void calculateNextDecisionDate(List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriod) {
        
        //Commented on - 12/03/2018 - Subhash Garhwal - CR-20180726-12469 - Starts from here
        /*
        Set<Id> setCPQOppIds = new Set<Id>();
        
        
        for (Subscription_Period__c sp : subscriptionPeriods) {
            
            //if source opportunity is populated, add to the list of ids
            if (sp.Source_Opportunity__c != null)
                setCPQOppIds.add(sp.Source_Opportunity__c);
        }
        
        //update the Next Decision Date on memberships for the new CPQ architecture (ie: multiple products on a single opp)
        if (setCPQOppIds.size() > 0)
            OpportunityTriggerUtilities.calcNextDecisionDateFromCPQOpps(setCPQOppIds);
        */
        //Commented on - 12/03/2018 - Subhash Garhwal - CR-20180726-12469 - Ends here
        
        // Added on - 12/03/2018 - Subhash Garhwal - CR-20180726-12469 - Starts from here
        //Map to hold the Memberships
        Map<Id, Membership__c> mapMembrships = new Map<Id, Membership__c>();
            
        //Set to hold the program Subscription Ids
        set<Id> setProgramSubscriptions = new set<Id>();
        
        //iterate over the subscription periods
        for(Subscription_Period__c sp : newSubscriptions){
            
            //Insert/update case, check conditions
            if(sp.Membership_Lookup__c != null 
                && (mapOldSubscriptionPeriod == null || (mapOldSubscriptionPeriod != null 
                                                            && (sp.Membership_Lookup__c != mapOldSubscriptionPeriod.get(sp.id).Membership_Lookup__c
                                                                || sp.Decision_Type__c != mapOldSubscriptionPeriod.get(sp.id).Decision_Type__c
                                                                || sp.Stage__c != mapOldSubscriptionPeriod.get(sp.id).Stage__c
                                                                || sp.Period_Start_Date__c != mapOldSubscriptionPeriod.get(sp.id).Period_Start_Date__c)))){
                
                //Populate the set
                mapMembrships.put(sp.Membership_Lookup__c , new Membership__c(Id = sp.Membership_Lookup__c, Next_Decision_Date__c = null ));
                
                if(mapOldSubscriptionPeriod != null && mapOldSubscriptionPeriod.get(sp.id).Membership_Lookup__c != null)
                    //Populate the set
                    mapMembrships.put(mapOldSubscriptionPeriod.get(sp.id).Membership_Lookup__c, new Membership__c(Id = mapOldSubscriptionPeriod.get(sp.id).Membership_Lookup__c, Next_Decision_Date__c = null ));
            }
        }
        
        //Check for size
        if(mapMembrships.size() > 0){
            
            //Call the method
            mapMembrships = calculateNextDecisionDate(mapMembrships);
            
            //Check for size
            if(mapMembrships != null && mapMembrships.values().size() > 0){
                
                //disable all triggers to execute
                Util.BypassAllTriggers = true;
                
                // Update Memberships
                update mapMembrships.values();
                
                //Enable all trigger 
                Util.BypassAllTriggers = false;
            }
        }
        //Added on - 12/03/2018 - Subhash Garhwal - CR-20180726-12469 - ends here
    }
    
     /**
    *   @Description    :   This method is to Calcuate the Next Decission Date on the Membership.
    *
    *   @args           :   Map<Id, Membership__c> mapMembrships
    *
    *   @return         :   Map<Id, Membership__c>
    *
    *   @Revision Log   :   V1.1 - Created - 12/03/2018 - Subhash Garhwal - CR-20180726-12469
    *
    **/
    public static Map<Id, Membership__c> calculateNextDecisionDate(Map<Id, Membership__c> mapMembrships) {
        
        //Check for size
        if(mapMembrships != null && mapMembrships.size() > 0){
            
            Map<Id, List<Subscription_Period__c>> mapMembershipIdToListSP = new Map<Id, List<Subscription_Period__c>> ();
            
            //Query over the SPs
            for(Subscription_Period__c sp : [Select Id, Membership_Lookup__c, Membership_Lookup__r.Next_Decision_Date__c, 
                                                Decision_Type__c, Opt_Out_Early_Termination_Date__c, Stage__c, Period_Start_Date__c 
                                                From Subscription_Period__c 
                                                where Membership_Lookup__c IN : mapMembrships.keySet()
                                                AND Membership_Lookup__c != null
                                                AND Stage__c = 'Pending'
                                                AND (Decision_Type__c =: CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT 
                                                     OR Decision_Type__c =: CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_NEED_NEW_LOA) 
                                                AND Period_Start_Date__c >= TODAY
                                                AND (Opt_Out_Early_Termination_Date__c = null OR Opt_Out_Early_Termination_Date__c >= TODAY)
                                                ORDER BY Decision_Type__c ASC, Opt_Out_Early_Termination_Date__c ASC NULLS LAST, Period_Start_Date__c ASC]){
                
                //Check membership in map
                if(!mapMembershipIdToListSP.containsKey(sP.Membership_Lookup__c))
                    mapMembershipIdToListSP.put(sP.Membership_Lookup__c, new List<Subscription_Period__c>());
                
                //Add SP in map
                mapMembershipIdToListSP.get(sP.Membership_Lookup__c).add(sP);
            }
            
            //Check for SPs
            if(mapMembershipIdToListSP.size() > 0) {
                
                
                //Loop over the Mebership Ids
                for(Id memId : mapMembershipIdToListSP.keyset()){
                    
                    //Check if map contains Mebership
                    if(mapMembrships.containsKey(memId)) {
                        
                        //Loop over the SPs
                        for(Subscription_Period__c sP : mapMembershipIdToListSP.get(memId)) {
                            
                            //Check for decision type
                            if(sP.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT) {
                                
                                //Check for Opt_Out_Early_Termination_Date__c
                                if(sP.Opt_Out_Early_Termination_Date__c != null)
                                    mapMembrships.get(memId).Next_Decision_Date__c = sP.Opt_Out_Early_Termination_Date__c;
                                else
                                    mapMembrships.get(memId).Next_Decision_Date__c = sP.Period_Start_Date__c;
                                    
                                break;      
                            } else if(sP.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_NEED_NEW_LOA) {
                                mapMembrships.get(memId).Next_Decision_Date__c = sP.Period_Start_Date__c;
                                break;
                            }   
                        }   
                    }
                } 
            }
        }
        return mapMembrships;       
    }
    
    /**
    *  @description    :   This method is used to populate the Engagement Status on program Package 
    *
    *  @args           :   
    *
    *  @return         :   void
    * 
    * Version          :  V1.1 - Created By - Subhash Garhawal - 12/27/2018 - CR-20181019-12685
    *
    **/
    public static void populateEngagementStatusOnProgramPackage(List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriod) {
        
        //Map to hold the Program Packages
        Map<Id, Program_Package__c> mapProgramPackages = new Map<Id, Program_Package__c>();
        
        //Loop over the new subscriptions
        for(Subscription_Period__c sPs : newSubscriptions){
            
            //update case
            if(mapOldSubscriptionPeriod != null 
                && (sPs.Stage__c != mapOldSubscriptionPeriod.get(sPs.Id).Stage__c 
                    || sPs.Period_Start_Date__c != mapOldSubscriptionPeriod.get(sPs.Id).Period_Start_Date__c 
                    || sPs.Program_Package__c != mapOldSubscriptionPeriod.get(sPs.Id).Program_Package__c )){
                    
                //Populate the program package map
                if(sps.Program_Package__c != null )
                    mapProgramPackages.put(sps.Program_Package__c, new Program_Package__c(Id = sps.Program_Package__c));
                
                //Populate the program package map
                if(mapOldSubscriptionPeriod.get(sPs.Id).Program_Package__c != null 
                    && sPs.Program_Package__c != mapOldSubscriptionPeriod.get(sPs.Id).Program_Package__c )
                    mapProgramPackages.put(mapOldSubscriptionPeriod.get(sPs.Id).Program_Package__c, new Program_Package__c(Id = mapOldSubscriptionPeriod.get(sPs.Id).Program_Package__c));  
            }   
        }
        
        //Check fpr size
        if(mapProgramPackages.size() > 0){
            
            //Method call to update the engagement status on Program Package
            populateEngagementStatus(mapProgramPackages.values(), true);
        }
    }
    
    /**
      * @description    :   This method is used to populate the Engagement Status on program Package 
      *
      * @args           :   List<Program_Package__c>, Boolean
      *
      * @return         :   void
      * 
      * @version        :   V1.1 - Created By - Subhash Garhawal - 12/27/2018 - CR-20181019-12685
      *
      **/
    public static void populateEngagementStatus(List<Program_Package__c> newProgramPackage, Boolean bypassValidation) {
        
        //Check for size
        if(newProgramPackage != null && newProgramPackage.size() > 0){
            
            //List to hold the program package to update
            List<Program_Package__c> listProgramPackageToUpdate = new List<Program_Package__c>();
            
            //Map to hold the Program package Id with list of Subscription periods
            Map<Id, List<Subscription_Period__c>> mapProgramPackageIdWithListSubscriptionPeriods = new Map<Id, List<Subscription_Period__c>>();
            
            //Query on subscription periods
            for(Subscription_Period__c sp : [Select Id, Stage__c, Period_Start_Date__c, Program_Package__c, Program_Package__r.Client_Status_New__c From Subscription_Period__c where Program_Package__c != null AND Program_Package__c IN : newProgramPackage]){
                
                //Populate the the mapProgramPackageIdWithListSubscriptionPeriods
                if(mapProgramPackageIdWithListSubscriptionPeriods.containsKey(sp.Program_Package__c)){
                    
                    mapProgramPackageIdWithListSubscriptionPeriods.get(sp.Program_Package__c).add(sp);
                }
                else{
                    mapProgramPackageIdWithListSubscriptionPeriods.put(sp.Program_Package__c, new List<Subscription_Period__c> {sp});
                }
            }
            
            //Check for size
            if(mapProgramPackageIdWithListSubscriptionPeriods.size() > 0){
                 
                //Loop over the program packages Ids
                for(Id pPackageId : mapProgramPackageIdWithListSubscriptionPeriods.keySet()){
                    
                    //Check for size
                    if(mapProgramPackageIdWithListSubscriptionPeriods.get(pPackageId).size() > 0){
                        
                        //Hold the engagement status for the Program package
                        String engagementStatus = mapProgramPackageIdWithListSubscriptionPeriods.get(pPackageId)[0].Program_Package__r.Client_Status_New__c;
                        
                        //Program Package Instance
                        Program_Package__c pPackage = new Program_Package__c(Id = pPackageId, Client_Status_New__c = engagementStatus, By_Pass_Validations__c = bypassValidation); 
                        
                        //Loop over the SPs
                        for(Subscription_Period__c sP : mapProgramPackageIdWithListSubscriptionPeriods.get(pPackageId)){
                        
                            //Check if ATL SP
                            if(sP.Stage__c != null && sP.Stage__c == 'ATL'){
                                
                                //Update engagement status to secured
                                engagementStatus = 'Secured';
                                break;
                            
                            } else{
                                
                                //Update engagement status to In Play 
                                engagementStatus = 'In Play';
                            }
                        }
                        
                        //Check for condition
                        if( engagementStatus != pPackage.Client_Status_New__c)
                            pPackage.Client_Status_New__c = engagementStatus;
                            
                            //Populate the list to update the program package to update
                            listProgramPackageToUpdate.add(pPackage);
                    }
                }   
            }
            
            //Check for size
            if(listProgramPackageToUpdate.size() > 0){
                
                //Bypass all triggers
                Util.BypassAllTriggers = false;
                
                //Update the Program package
                update listProgramPackageToUpdate;
                
                //Check for bypass Validation
                if(bypassValidation) {
                    
                    //Loop over the Membership Period
                    for(Program_Package__c pP : listProgramPackageToUpdate)
                        pP.By_Pass_Validations__c = false;
                    
                    Util.BypassAllTriggers = true;
                    
                    //Update the Program package
                    update listProgramPackageToUpdate;
                }
                
                //Enable all triggers
                Util.BypassAllTriggers = false;
            }   
        }
    }
    
    /**
     *  @description    :   This method is used to populate the Rollup fields on program Package 
     *
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     * 
     * Version          :  V1.1 - Created By - Subhash Garhawal - 12/27/2018 - CR-20181019-12685
     *
    **/
    public static void populateProgramPackageRollUpFields(List<Subscription_Period__c> newSubscriptions, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriod) {
        
        //Map to hold the Program Packages
        Map<Id, Program_Package__c> mapProgramPackages = new Map<Id, Program_Package__c>();
        
        //Set to hold the Subscription Period Ods
        Set<Id> setRenewedSubPeriodIds = new Set<Id>();
        
        //Loop over the new SPs
        for(Subscription_Period__c sP : newSubscriptions){
            
            //Check appropriate condition to fire trigger
            if(mapOldSubscriptionPeriod == null || (mapOldSubscriptionPeriod != null && sP.Program_Package__c != mapOldSubscriptionPeriod.get(sP.Id).Program_Package__c)){
                
                //Check Program Package and add details in map
                if(sP.Program_Package__c != null)
                    mapProgramPackages.put(sP.Program_Package__c, new Program_Package__c(Id = sP.Program_Package__c, Total_Contracted_Program_Annual_Cost__c = 0,
                                                                                         Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0));
                
                //Check for old program package and add old one in map if there is any change
                if(mapOldSubscriptionPeriod != null && mapOldSubscriptionPeriod.get(sP.Id).Program_Package__c != null && sP.Program_Package__c != mapOldSubscriptionPeriod.get(sP.Id).Program_Package__c)
                    mapProgramPackages.put(mapOldSubscriptionPeriod.get(sP.Id).Program_Package__c,
                                            new Program_Package__c(Id = mapOldSubscriptionPeriod.get(sP.Id).Program_Package__c, Total_Contracted_Program_Annual_Cost__c = 0,
                                                                  Total_Contracted_Postage_Cost_CPQ__c = 0, Total_Contracted_Media_Cost_CPQ__c = 0));
                
                //Check Renewal Opportunity
                if(sP.Renewal_Opportunity__c != null && sP.Program_Package__c != null)
                    setRenewedSubPeriodIds.add(sP.Program_Package__c);  
            }
        }
        
        //Check for size
        if(mapProgramPackages.size() > 0) {
            
            //Set to hold the program package Ids
            Set<Id> setProgramPackageIds = new Set<Id>();
            
            //Loop Over the SPs
            for(Subscription_Period__c subs : [Select Id, Program_Package__c, Program_Package__r.Contract_Sent__c, Program_Subscription__r.SBQQ__QuoteLine__c, Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c From Subscription_Period__c where Program_Package__c != null AND Program_Subscription__r.SBQQ__QuoteLine__c != null AND Program_Package__c IN : mapProgramPackages.values() ORDER By CreatedDate DESC, Program_Package__c ]){
                
                //Check for condition
                if(!setProgramPackageIds.contains(subs.Program_Package__c) && mapProgramPackages.containsKey(subs.Program_Package__c) && mapProgramPackages.get(subs.Program_Package__c) != null  && subs.Program_Subscription__r.SBQQ__QuoteLine__c != null && subs.Program_Package__c != null && subs.Program_Package__r.Contract_Sent__c != subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c){
                    
                    //Populate the map
                    mapProgramPackages.get(subs.Program_Package__c).Contract_Sent__c = subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c;
                    
                    //Populate the set
                    setProgramPackageIds.add(subs.Program_Package__c);
                }
            }
            
            //method call to update the Rollup fields
            ProgramPackageRoyallTriggerHelper.populateRollUpFields(mapProgramPackages);
        }
        
        //Check for Renewed Sub Periods and call Program Package class method
        if(setRenewedSubPeriodIds.size() > 0) {
            
            //
            ProgramPackageRoyallTriggerHelper.syncRenewalDetailsOnProgramPackage(setRenewedSubPeriodIds);
            
            //Call validateTotalContractedContactQty method to update ContractedContactQty field
            ProgramPackageRoyallTriggerHelper.validateTotalContractedContactQty(setRenewedSubPeriodIds, CPQConstants.ORIGIN_PROPOSAL_LINE);
        }
    }
    
    /**
     *  @description    :   This method is used to populate 'Previous Year - Program Cost (CPQ)[Previous_Year_Program_Cost_CPQ__c]', 'Current Year - Program Cost (CPQ)[Current_Year_Program_Cost_CPQ__c]', 'Next Year - Program Cost (CPQ)[Next_Year_Program_Cost_CPQ__c]', with the program cost from related SP's
     * 
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @Version        :  V1.0 - Created By - Subhash Garhawal - 01/30/2018 - CR-20181019-12685
    **/
    public static void populatePreviousCurrentNextYearProgramCost(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
        
        //Map to hold the Memberships
        Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
        
        
        //Loop over the Subscription Periods
        for(Subscription_Period__c sP : subscriptionPeriods != null ? subscriptionPeriods : mapOldSubscriptionPeriods.values()) {
            
            //Check appropriate condition to execute trigger
            
            
            //Insert Case/Delete case
            if((mapOldSubscriptionPeriods == null || subscriptionPeriods == null ) && sP.Membership_Lookup__c != null)
                mapMemberships.put(sP.Membership_Lookup__c, new Membership__c(Id = sP.Membership_Lookup__c, Previous_Year_Program_Cost_CPQ__c = 0, Current_Year_Program_Cost_CPQ__c = 0, Next_Year_Program_Cost_CPQ__c = 0));
                
            //Check for update case
            if(subscriptionPeriods != null && mapOldSubscriptionPeriods != null && sP.Membership_Lookup__c != mapOldSubscriptionPeriods.get(sP.Id).Membership_Lookup__c) {
                
                //Check for new Membership
                if(sP.Membership_Lookup__c != null)
                    mapMemberships.put(sP.Membership_Lookup__c, new Membership__c(Id = sP.Membership_Lookup__c, Previous_Year_Program_Cost_CPQ__c = 0, Current_Year_Program_Cost_CPQ__c = 0, Next_Year_Program_Cost_CPQ__c = 0));
                
                //CHeck for hold membership
                if(mapOldSubscriptionPeriods.get(sP.Id).Membership_Lookup__c != null)
                    mapMemberships.put(mapOldSubscriptionPeriods.get(sP.Id).Membership_Lookup__c, new Membership__c(Id = mapOldSubscriptionPeriods.get(sP.Id).Membership_Lookup__c, Previous_Year_Program_Cost_CPQ__c = 0, Current_Year_Program_Cost_CPQ__c = 0, Next_Year_Program_Cost_CPQ__c = 0));
            }
        }
        
        //Check memberships
        if(mapMemberships.size() > 0) {
            
            //10/27/2020 - CR-20201013-14598 - Victor Hanson - modified query with reference to the cost product codes
            //SOQL over the Component Subscriptions
            for(SBQQ__Subscription__c compSub : [Select Id, Customer_Amount__c, Subscription_Period__r.Membership_Lookup__c, Subscription_Period__r.Period_Start_Date__c,
            					 Subscription_Period__r.Period_End_Date__c From SBQQ__Subscription__c
                                                 Where RecordTypeId =: CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT AND Product_Code__c IN :CPQConstants.CPQ_ES_PRODUCT_CODES
                                                 AND Subscription_Period__r.Membership_Lookup__c IN : mapMemberships.keySet() AND Customer_Amount__c > 0]) {
                
                //Check for SP Start and End Date and Add values on Membership
                if(compSub.Subscription_Period__r.Period_End_Date__c != null && compSub.Subscription_Period__r.Period_End_Date__c < Date.today() && compSub.Subscription_Period__r.Period_End_Date__c > Date.today().addYears(-1))
                    mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Previous_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
                else if(compSub.Subscription_Period__r.Period_Start_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c > Date.today() && compSub.Subscription_Period__r.Period_Start_Date__c < Date.today().addYears(1))
                    mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Next_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
                    else if (compSub.Subscription_Period__r.Period_End_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c != null && compSub.Subscription_Period__r.Period_Start_Date__c <= Date.today() && compSub.Subscription_Period__r.Period_End_Date__c >= Date.today())
                    mapMemberships.get(compSub.Subscription_Period__r.Membership_Lookup__c).Current_Year_Program_Cost_CPQ__c += compSub.Customer_Amount__c;
            }
            
            //Check for size
            if(mapMemberships.size() > 0) {
                
                //Bypass all triggers
                Util.BypassAllTriggers = true;
                
                //Update Memberships
                update mapMemberships.values();
                
                //Enable all triggers
                Util.BypassAllTriggers = false;
            }
        }   
    }
    
    /**
     *  @description    :   This method is used to populate "Autorenew__c", "Autorenewal_Notification_Date__c"
     * 
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @Version        :  V1.0 - Created By - Subhash Garhawal - 06/05/2020
     * 			:  V1.1 - Modfied By - Subhash Garhawal - 06/17/2020
     * 			:  V1.2 - Modfied By - Subhash Garhawal - 06/24/2020  commneted method as per CR-20200623-14217
    **/
    public static void populateAutorenewAndDate(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods)
    {
        /*
        //Set to hold the Contract Id
        Set<Id> setContractIds = new Set<Id>();
        
        //Processing on the new record
        for(Subscription_Period__c sp : subscriptionPeriods)
        {
            
            //Check for Condition
            if(sp.Contract__c != null )
                setContractIds.add(sp.Contract__c);
        }
	
	// Modify By Subhash Garhawal - 06/17/2020 - CR-20200608-14151
        if(setContractIds.size() > 0){
            
            //Query Over the Contract
            Map<Id,Contract> mapOfContract = new Map<Id, Contract>([Select id,Autorenew__c,Autorenewal_Notification_Date__c From Contract Where Id IN : setContractIds]);
            
            for(Subscription_Period__c sp : subscriptionPeriods)
            {
                //Check for Autorenew__c on Contract
                if(mapOfContract.get(sp.Contract__c).Autorenew__c != null)
                    sp.Autorenew__c = mapOfContract.get(sp.Contract__c).Autorenew__c;
                
                //Check for Autorenewal_Notification_Date__c on Contract
                if(mapOfContract.get(sp.Contract__c).Autorenewal_Notification_Date__c != null)
                    sp.Autorenewal_Notification_Date__c = mapOfContract.get(sp.Contract__c).Autorenewal_Notification_Date__c;
                
            }
        } */
        /* // start commented for this CR-20200608-14151
         if(setContractIds.size() > 0)
        {
            //Query Over the Contract
            Map<Id,Contract> mapOfContract = new Map<Id, Contract>([Select id,SBQQ__Quote__r.Legacy_YV_Autorenew__c,
                                                                    SBQQ__Quote__r.Autorenewal_Notification_Date__c
                                                                    From Contract where Id IN : setContractIds]);
            
            //Loop over new Subscription Period
            for(Subscription_Period__c sp : subscriptionPeriods)
            {
                //Check for Legacy_YV_Autorenew__c on Proposal
                if(mapOfContract.get(sp.Contract__c).SBQQ__Quote__r.Legacy_YV_Autorenew__c != null)
                    sp.Autorenew__c = mapOfContract.get(sp.Contract__c).SBQQ__Quote__r.Legacy_YV_Autorenew__c;
                
                //Check for Autorenewal_Notification_Date__c on Proposal
                if(mapOfContract.get(sp.Contract__c).SBQQ__Quote__r.Autorenewal_Notification_Date__c != null)
                    sp.Autorenewal_Notification_Date__c = mapOfContract.get(sp.Contract__c).SBQQ__Quote__r.Autorenewal_Notification_Date__c; 
            }

            
        } */ // end comments commented for this CR-20200608-14151

		

                                                               
    }
    
    //Method to Perform Data Update for the CR-20181220-12797
    /*public static void dataUpdateStepCodeToGenerateCSVFile() {
        
        String CSVString = 'Subscription Period Id' + ',' + 'Subscription Period Name'+ ',' +'Created Date'+ ',' +'Created By'+ ','+'Previous Period Negotiated (Components)'+ ','+'Previous Period Negotiated'+ ','+'Renewal Negotiated'+ ','+'Renewal Year Half'+ ','+ 'Negotiated Amount (Components)-- Current value'+ ',' + 'Negotiated Amount (Components)-- Expected new value,'+ '\n';
        
        //Map to hold the Subscription Periods
        Map<Id, Subscription_Period__c> mapsubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Map to hold the Subscription Periods
        Map<Id, Subscription_Period__c> mapsubscriptionPeriodsWithCurrentValue = new Map<Id, Subscription_Period__c>();
        
        //Map to hold the Subscription Periods
        Map<Id, String> mapUserIdWithName = new Map<Id,String>();
        
        
        //Query over the component subscriptions
        for(SBQQ__Subscription__c compSubs : [Select Id, Subscription_Period__c,Subscription_Period__r.Name, Subscription_Period__r.CreatedDate, Subscription_Period__r.CreatedById, Subscription_Period__r.CreatedBy.Name, Subscription_Period__r.Previous_Period_Negotiated__c, Subscription_Period__r.Previous_Period_Negotiated_Components__c,
        				      Subscription_Period__r.Negotiated_Amount_Period__c, Subscription_Period__r.Renewal_Negotiated__c, Subscription_Period__r.Renewal_Year_Half__c, Customer_Amount__c From SBQQ__Subscription__c 
                                              Where RecordTypeId = : CPQConstants.SUBSCRIPTION_RT_ID_COMPONENT AND Subscription_Period__c != null AND Subscription_Period__r.Negotiated_Amount_Period__c = null AND Customer_Amount__c != null AND (Subscription_Period__r.Stage__c != 'Pending' OR (Subscription_Period__r.Stage__c = 'Pending' AND Subscription_Period__r.Decision_Type__c != 'Need New LOA'))] ){
            
            //Check for conditions 
            if(compSubs.Subscription_Period__c != null && compSubs.Subscription_Period__r.Negotiated_Amount_Period__c == null && compSubs.Customer_Amount__c != null){
                
                //Check for size and then accordingly populate the SPs Map
                if(mapsubscriptionPeriodsWithCurrentValue.size() > 0 && mapsubscriptionPeriodsWithCurrentValue.containsKey(compSubs.Subscription_Period__c) && mapsubscriptionPeriodsWithCurrentValue.get(compSubs.Subscription_Period__c) != null){
                    
                    //Populate the map with value
                    mapsubscriptionPeriodsWithCurrentValue.get(compSubs.Subscription_Period__c).Negotiated_Amount_Period__c = compSubs.Subscription_Period__r.Negotiated_Amount_Period__c;
                }else{
                    
                    //Populate the map with value
                    mapsubscriptionPeriodsWithCurrentValue.put(compSubs.Subscription_Period__c, new Subscription_Period__c(Id = compSubs.Subscription_Period__c, Name = compSubs.Subscription_Period__r.Name,  
                                                                                                                                        CreatedDate = compSubs.Subscription_Period__r.CreatedDate, CreatedByID = compSubs.Subscription_Period__r.CreatedById, 
                                                                                                                                        Previous_Period_Negotiated__c = compSubs.Subscription_Period__r.Previous_Period_Negotiated__c, Previous_Period_Negotiated_Components__c = compSubs.Subscription_Period__r.Previous_Period_Negotiated_Components__c,
                                                                                                                           Negotiated_Amount_Period__c = compSubs.Subscription_Period__r.Negotiated_Amount_Period__c ));
                    mapUserIdWithName.put(compSubs.Subscription_Period__r.CreatedById, compSubs.Subscription_Period__r.CreatedBy.Name);
                }
                
                //Check for size and then accordingly populate the SPs Map
                if(mapsubscriptionPeriods.size() > 0 && mapsubscriptionPeriods.containsKey(compSubs.Subscription_Period__c) && mapsubscriptionPeriods.get(compSubs.Subscription_Period__c) != null){
                    
                    //Hold the negotiated amount
                    Decimal negotiatedAmountSum = mapsubscriptionPeriods.get(compSubs.Subscription_Period__c).Negotiated_Amount_Period__c;
                    negotiatedAmountSum = negotiatedAmountSum + compSubs.Customer_Amount__c ;
                    
                    //Populate the map with value
                    mapsubscriptionPeriods.get(compSubs.Subscription_Period__c).Negotiated_Amount_Period__c = negotiatedAmountSum;
                }else{
                    
                    //Populate the map with value
                    mapsubscriptionPeriods.put(compSubs.Subscription_Period__c, new Subscription_Period__c(Id = compSubs.Subscription_Period__c, Negotiated_Amount_Period__c = compSubs.Customer_Amount__c ));
                }
            }
        }
        
        //Check for size
        if(mapsubscriptionPeriods.size() > 0 && mapsubscriptionPeriods.values() != null && mapsubscriptionPeriods.values().size() > 0){
        
            //lOOP OVER THE SP's Keyset
            for(Id spId : mapsubscriptionPeriods.keySet()){
                
                //Check for conditions and add the new Row in the csv file
                if(mapsubscriptionPeriodsWithCurrentValue.size() > 0 && mapsubscriptionPeriodsWithCurrentValue.containsKey(spId) && mapsubscriptionPeriodsWithCurrentValue.get(spId) != null){
                    
                    //Get SP
                    Subscription_Period__c sp = mapsubscriptionPeriodsWithCurrentValue.get(spId);
                    
                    //add field values in the CSV file
                    CSVString +=  sp.Id +','+ sp.Name + ',' +sp.CreatedDate+ ',' +mapUserIdWithName.get(sp.CreatedById)+ ','+sp.Previous_Period_Negotiated_Components__c+ ','+sp.Previous_Period_Negotiated__c+ ','+ sp.Renewal_Negotiated__c+','+ sp.Renewal_Year_Half__c+','+ sp.Negotiated_Amount_Period__c +',';
                    
                    
                    //check for codition
                    if(mapsubscriptionPeriods.get(spId) != null){
                        
                        //add field values in the CSV file
                        CSVString += mapsubscriptionPeriods.get(spId).Negotiated_Amount_Period__c +','+'\n';
                    }
                    else
                        CSVString += ','+'\n';
                }
            }
            
            //Update sps
            //update mapsubscriptionPeriods.values();
        }
        
        //Send the CSV file to users via email
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            
        //Convert the CSV file(which is in string format) into the blob
        blob csvBlob = Blob.valueOf(CSVString);
        
        //Name of the CSV file
        string csvname= 'Subscription Periods To Be Updated.csv';
        csvAttc.setFileName(csvname);
        
        //set the body
        csvAttc.setBody(csvBlob);
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        //String to hold the email addresses
        String[] toAddresses = new list<string> {'subhash.garhwal@briskminds.com', 'mahendra.swarnkar@briskminds.com'};
        
        String sentemail = Label.Data_Update_File_Sent_Email;
        if(String.isNotBlank(sentemail)){
            toAddresses.add(sentemail);
        }
        email.setToAddresses( toAddresses );
        
        //subject for the email
        String subject ='Subscription Periods To Be Updated';
        email.setSubject(subject);
        
        //Set email body content
        email.setPlainTextBody('Hi Subhash, Please find the comparison list attached for Subscription Periods that are going to update. Thanks! ');
        
        //Attach the blob file as an attachment with the email
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        
        //Sent the email to users
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }*/
    
    /**
     *  @description    :   This method is used to populate CT: Previous CT Member field on Subscription Periods
     *   
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V_4.05 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
    **/
    public static void populateCTFieldsOnSubsciptionPeriod(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods, Boolean Isbefore)
    {
        //Set to hold Prevoius Subscription Period Ids
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
            
        for(Subscription_Period__c sP : subscriptionPeriods) {
            
            //Insert/Update case
            if(Isbefore && sP.Previous_Subscription_Period__c != null && (mapOldSubscriptionPeriods == null || sP.Previous_Subscription_Period__c != mapOldSubscriptionPeriods.get(sP.Id).Previous_Subscription_Period__c ))
                setSubscriptionPeriodIds.add(sP.Previous_Subscription_Period__c);  
            
            if(!Isbefore && mapOldSubscriptionPeriods != null && sP.CT_Assignment__c != mapOldSubscriptionPeriods.get(sP.Id).CT_Assignment__c )
                setSubscriptionPeriodIds.add(sP.Id);  
        }
        
        if(setSubscriptionPeriodIds.size() > 0 ) {
            
            Map<Id, List<Subscription_Period__c>> mapPreviousSPIdWithListSPs = new Map<Id, List<Subscription_Period__c>>();
            
            //Map to hold Id with Subscription Period
            Set<Id> setCTAssignmentSPIds = new Set<Id>();
            
            for(Subscription_Period__c subperiod : [SELECT Id, CT_Assignment__c, CT_Previous_CT_Member__c, Previous_Subscription_Period__c FROM Subscription_Period__c WHERE Id IN : setSubscriptionPeriodIds OR Previous_Subscription_Period__c IN : setSubscriptionPeriodIds]){
                
                if(subperiod.Previous_Subscription_Period__c != null) {
                    if(!mapPreviousSPIdWithListSPs.containsKey(subperiod.Previous_Subscription_Period__c))
                        mapPreviousSPIdWithListSPs.put(subperiod.Previous_Subscription_Period__c, new List<Subscription_Period__c>());
                    mapPreviousSPIdWithListSPs.get(subperiod.Previous_Subscription_Period__c).add(subperiod);
                }
                
                if(subperiod.CT_Assignment__c != null) 
                    setCTAssignmentSPIds.add(subperiod.Id);
            }
            
            Map<Id,Subscription_Period__c> mapSpsToUpdate = new Map<Id,Subscription_Period__c>();
            
            for(Subscription_Period__c sP : subscriptionPeriods) {
                if(Isbefore){
                	
                    if(sP.Previous_Subscription_Period__c != null && setCTAssignmentSPIds.contains(sP.Previous_Subscription_Period__c))
                        sP.CT_Previous_CT_Member__c = 'Yes' ;	    
                    else
                        sP.CT_Previous_CT_Member__c = 'No' ;
                
                } else {
                    
                 	if(mapOldSubscriptionPeriods != null && sP.CT_Assignment__c != mapOldSubscriptionPeriods.get(sP.Id).CT_Assignment__c
                       	&& mapPreviousSPIdWithListSPs.containsKey(sP.Id) && mapPreviousSPIdWithListSPs.get(sP.Id) != null 
                       	&& mapPreviousSPIdWithListSPs.get(sP.Id).size() > 0) 
                    {   
                        for(Subscription_Period__c subPeriod :mapPreviousSPIdWithListSPs.get(sP.Id)) {
                            
                            mapSpsToUpdate.put(subPeriod.Id, new Subscription_Period__c(Id = subPeriod.Id, CT_Previous_CT_Member__c = subPeriod.CT_Previous_CT_Member__c = 'No') );
                            if(sP.CT_Assignment__c != null)
                                mapSpsToUpdate.get(subPeriod.Id).CT_Previous_CT_Member__c = 'Yes';
                        }
                    }   
                }
            }
            
            if(mapSpsToUpdate.size() > 0 && mapSpsToUpdate.values() != null && mapSpsToUpdate.values().size() > 0){
                util.BypassAllTriggers = true;
                update mapSpsToUpdate.values();
                util.BypassAllTriggers = false;
            }
        }
    }
	
    /**
     *  @description    :   This method is used to populate the Type field on the Billing schedule Periods.
     *   
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.1 - Created - 09/07/2020 - Mahendra Swarnkar - CR-20200715-14321
    **/
    public static void populateTypeOnBSP(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
        
        //Set to hold Prevoius Subscription Period Ids
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
            
        for(Subscription_Period__c sP : subscriptionPeriods) {
            
            //Update case
            if(mapOldSubscriptionPeriods != null && (sP.Stage__c != mapOldSubscriptionPeriods.get(sP.Id).Stage__c
                                                     || sP.Renewal_Health__c != mapOldSubscriptionPeriods.get(sP.Id).Renewal_Health__c
                                                     || sP.Decision_Type__c != mapOldSubscriptionPeriods.get(sP.Id).Decision_Type__c))
	    	setSubscriptionPeriodIds.add(sP.Id);  
        }
        
        if(setSubscriptionPeriodIds.size() > 0){
            
            //Get all the Component Subscriptions Associated with SP
            Set<Id> setbillingPeriodLines  = new Set<Id>();
            for(Billing_Schedule_Line__c billingLines : [Select Id, Billing_Schedule_Period__c, Billing_Schedule_Period__r.Invoice_Sent__c From Billing_Schedule_Line__c Where Related_Subscription_Component__c != null AND Related_Subscription_Component__r.Subscription_Period__c != null AND Related_Subscription_Component__r.Subscription_Period__c IN : setSubscriptionPeriodIds]){
                
                if(billingLines.Billing_Schedule_Period__c != null && billingLines.Billing_Schedule_Period__r.Invoice_Sent__c == false){
                    setbillingPeriodLines.add(billingLines.Billing_Schedule_Period__c);
                }
            }
            if(setbillingPeriodLines.size() > 0) {
                
                BillingScheduleLineTriggerHelper.updateTypeOnBSP(setbillingPeriodLines);
                
            }
        }
    } 
    
    /**
     *  @description    :   This method is used to call Batch_AutomatedProjectAndRelated for creating Project/Dployment and Job ticket records.
     *   
     *  @args           :   List<Subscription_Period__c>, Map<Id, Subscription_Period__c>
     *
     *  @return         :   void
     *
     *  @Version        :   V1.1 - Created - 06/17/2021 - Shalu Sharma - CR-20200924-14551
    **/
    
    public static void callBatchAutomatedProjectAndRelated(List<Subscription_Period__c> subscriptionPeriods, Map<Id, Subscription_Period__c> mapOldSubscriptionPeriods) {
        
        //to hold contract ids
        Set<Id> setOfContractIds = new Set<Id>();
        
        for(Subscription_Period__c sp : subscriptionPeriods){
            
            //check Stage is changes from Pending to ATL
            if( mapOldSubscriptionPeriods != null && sp.Contract__c != null && mapOldSubscriptionPeriods.get(sp.Id).Stage__c != sp.Stage__c
               && sp.Stage__c == Constants.SUBSCRIPTION_PERIOD_STATUS_ATL && mapOldSubscriptionPeriods.get(sp.Id).Stage__c == Constants.SUBSCRIPTION_PERIOD_STATUS_PENDING){
               
                setOfContractIds.add(sp.Contract__c);
            }
            
        }
        
        //check set size
        if(setOfContractIds.size() > 0){
            
            //query string for batch
            String query = 'SELECT Id, Batch_Status__c FROM Contract WHERE Id IN : contractIds';
            
            //execute batch to create Project/Dployment and Job ticket records
            Database.executeBatch(new Batch_AutomatedProjectAndRelated(setOfContractIds, query));
        }
    }
}