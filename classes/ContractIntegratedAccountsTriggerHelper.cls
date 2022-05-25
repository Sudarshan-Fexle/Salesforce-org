/**
 *  Description     :   This class is helper class for triggers on Contract Integrated Accounts
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   03/22/2013
 * 
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process - method modified (populateContractsOnMembership)
 *                      V_1.2 - 06/07/2017 - Q2C Phase 2
 *			V_1.3 - Modified By - Saurabh Kumar - 07/26/2017 - Issue--CR10808--QA--00005099 - Added a new method "populateSubscriptionFieldsOnMembership"
 *			V_1.4 - Modified By - Victor Hanson - 10/18/2017 - Issue--CR11695--QA--00007013 - Modified populateContractsOnMembership to work with standard contracts / CPQ Subscriptions
 *			V_1.5 - Modified By - Subhash Garhwal - 06/27/2018 - CR-20180502-12199 - updated method 'populateContractsOnMembership', comment out the logic to populate 'Join_Date_Most_Recent__c' on membership
 *                      V_1.6 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out all values which update Membership Owner
 *			V_1.7 - Modified By - Neha Sharma - 11/03/2020 - CR-20200814-14435 - Remove the Commented out membershipOwnerCheckfromMemberships method which update Membership Owner 
 *          		V_1.8 - Modified By - Chirag Soni - 07/26/2021 - CR-20210621-15227 - Commented the logic in createMemberships method and moved it to new future method createMembershipsFuture, 
 * 											     Commented the SBQQ__Subscription__c query and mehtod call populateSubscriptionFieldsOnMembership and moved it to new future method populateSubscriptionFieldsOnMembershipFuture.
 *			V_1.9 - Modified By - Mahendra Swarnkar - 08/31/2021 - CR-20210825-15378
 *			V_2.0 - Modified By - Mahendra Swarnkar - 01-09-2021 - CR-20210831-15398 - Add fix for error "Future method cannot be called from a future or batch method"
**/ 
public without sharing class ContractIntegratedAccountsTriggerHelper {
   
    public static Map<Id, List<SBQQ__Subscription__c>> accId2SubscriptionListMap {
        get {
            if (accId2SubscriptionListMap == null) accId2SubscriptionListMap = new Map<Id, List<SBQQ__Subscription__c>>();
            return accId2SubscriptionListMap;
        }
        set;
    }
    public static Map<Id, Membership__c> MembershipstoCheckMap { get; set; }
    
    //Method to populate accId2SubscriptionListMap and MembershipstoCheckMap
    //Used for populating Active/Earliest/Lastest Subscription on Membership using Standard Contracts / CPQ Subscriptions
    public static void populateAccIdMapAndMembershipMap(List<Contract_Integrated_Accounts__c> newCIAs) {
        
        //Check for the records size
        if(newCIAs != null && newCIAs.size() > 0) {
            
            /** Find the Memberships for these Contracts that need updated **/
            // Set to store Account Ids
            Set<Id> accIds = new Set<Id>();
            
            // Set to store Program Ids
            Set<Id> progIds = new Set<Id>();
            
            Set<Id> memOwnerNeeded = new Set<Id>(); // DAF - added 12-15-11
            
            // Map of a List Contracts associated to their Account Id as a key
            ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap = new Map<Id, List<SBQQ__Subscription__c>>();
            
            //set of standard contracts
            set<Id> stdContractIds = new set<Id>();
            for (Contract_Integrated_Accounts__c cia : newCIAs) {
                if (cia.LOA_Contract__c != null) 
                    stdContractIds.add(cia.LOA_Contract__c);
            }
            
            if (stdContractIds.size() == 0) return;
            
            //get all standard Contracts
            map<Id, Contract> stdContractMap = new map<Id, Contract>([SELECT Id, AccountId, StartDate, EndDate, Status,
                                                                      (SELECT Id, Account__c FROM Contract_Integrated_Accounts__r),
                                                                      (SELECT Id, Join_Date__c, Program__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Active_Subscription__c FROM SBQQ__Subscriptions__r 
                                                                       WHERE (Status__c = 'Committed' OR Status__c = 'Honorary' OR Status__c = 'ATL' OR Status__c = 'Dropped') AND RecordType.Name = 'Program')
                                                                      FROM Contract
                                                                      WHERE Id IN :stdContractIds
                                                                      AND ActivatedDate != null AND Status!='Void']);
            
            //split out the Contracts according to which Account they're associated with
            for (Contract c : stdContractMap.values()) {
                
                // Add the Contract's Payer Account Id to a list of Account Ids
                accIds.add(c.AccountId);
                
                // Add the Contract's Program Id to a list of Program Ids
                for (SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r)
                    progIds.add(s.Program__c);
                
                // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                // otherwise add a new key for the Account and a list containing the Contract
                if (ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.containsKey(c.AccountId))
                    ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.get(c.AccountId).addAll(c.SBQQ__Subscriptions__r);
                else
                    ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.put(c.AccountId, new List<SBQQ__Subscription__c> ( c.SBQQ__Subscriptions__r ) );
                
                //Associate this Contract with Accounts according to Contract Integrated Accounts also (1 Contract may be in multiple lists, if there are CIAs)
                for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {// Loop through Contract Integrated Accounts for this Contract
                    
                    // Add the Contract Integrated Account Account Id to a list of Account Ids
                    accIds.add(cia.Account__c);
                    
                    // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                    // otherwise add a new key for the Account and a list containing the Contract
                    if (ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.containsKey(cia.Account__c))
                        ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.get(cia.Account__c).addAll(c.SBQQ__Subscriptions__r);
                    else
                        ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.put(cia.Account__c, new list<SBQQ__Subscription__c> ( c.SBQQ__Subscriptions__r ) );
                }
            }
            
            //Get full list of all Memberships that might possibly match our list
            Map<Id, Membership__c> allMems = new Map<Id, Membership__c>([select id, Program__c, Account_Name__c 
                                                                         from Membership__c where Program__c in :progIds and Account_Name__c in :accIds]);
            
            //Narrow list down to only Memberships that actually match directly with one of our Subscriptions, narrow down by Account first
            ContractIntegratedAccountsTriggerHelper.MembershipstoCheckMap = new Map<Id, Membership__c>();
            
            // Loop through all Memberships associated to the Accounts from these Contracts
            for (Membership__c m : allMems.values()) {
                
                // If the Account Id To Contract map contains a record for this Membership's Account then process
                // (there should be no reason for this condition, but it's better to have it than not)
                if (ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.containsKey(m.Account_Name__c)) {
                    
                    for (SBQQ__Subscription__c s : ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.get(m.Account_Name__c)) {
                        
                        // If the Subscription's Program equals the Membership's Program then store the Membership in a map w/ it's Id as a key 
                        if (s.Program__c == m.Program__c) {
                            ContractIntegratedAccountsTriggerHelper.MembershipstoCheckMap.put(m.id, m);
                            memOwnerNeeded.add(m.id);   //DAF - added 12-15-11
                        }
                    }
                }
            }
        }
    }
    
    //Method to update the memberships with contracts
    //Modified by - Victor Hanson - 10/18/2017 - Issue--CR11695--QA--00007013 - Modified populateContractsOnMembership to work with standard contracts / CPQ Subscriptions
    //Modified By - Subhash Garhwal - 06/27/2018 - CR-20180502-12199 - Comment out the logic to populate 'Join_Date_Most_Recent__c' on membership
    public static string populateContractsOnMembership(List<Contract__c> contracts, List<Contract_Integrated_Accounts__c> newCIAs) {
    
        //String to hold the log Message
        String logMessage = '';
        
        //Check for the records size
        if((contracts != null && contracts.size() > 0) || (newCIAs != null && newCIAs.size() > 0)) {
            
            /** Find the Memberships for these Contracts that need updated **/
            // Set to store Account Ids
            Set<Id> accIds = new Set<Id>();
            
            // Set to store Program Ids
            Set<Id> progIds = new Set<Id>();
            
            Set<Id> memOwnerNeeded = new Set<Id>(); // DAF - added 12-15-11
            
            // Map of a List Contracts associated to their Account Id as a key
            Map<Id, List<Contract__c>> accId2ConListMap = new Map<Id, List<Contract__c>>();
            
            //get full list of changed Contracts and Contract Integrated Accounts to use for checking on Memberships
            List<Contract__c> allCons = [Select Id, Payer_Account__c, Program__c, Start__c, End__c, Active__c,
                (Select Account__c from Contract_Integrated_Accounts__r)
                from Contract__c where Id in :contracts and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')];
            
            //split out the Contracts according to which Account they're associated with
            for (Contract__c c : allCons) {
            
                // Add the Contract's Payer Account Id to a list of Account Ids
                accIds.add(c.Payer_Account__c);
                
                // Add the Contract's Program Id to a list of Program Ids
                progids.add(c.Program__c);
                
                // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                // otherwise add a new key for the Account and a list containing the Contract
                if (accId2ConListMap.containsKey(c.Payer_Account__c))
                    accId2ConListMap.get(c.Payer_Account__c).add(c);
                else
                    accId2ConListMap.put(c.Payer_Account__c, new List<Contract__c> { c });
                
                //Associate this Contract with Accounts according to Contract Integrated Accounts also (1 Contract may be in multiple lists, if there are CIAs)
                for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {// Loop through Contract Integrated Accounts for this Contract
                
                    // Add the Contract Integrated Account Account Id to a list of Account Ids
                    accIds.add(cia.Account__c);
                    
                    // If the Map of Contracts to Account Ids already contains a key for the Account, add the Contract to the list for the existing key,
                    // otherwise add a new key for the Account and a list containing the Contract
                    if (accId2ConListMap.containsKey(cia.Account__c))
                        accId2ConListMap.get(cia.Account__c).add(c);
                    else
                        accId2ConListMap.put(cia.Account__c, new list<Contract__c> { c });
                }
            }
            
            //Get full list of all Memberships that might possibly match our list
            Map<Id, Membership__c> allMems = new Map<Id, Membership__c>([select id, Program__c, Account_Name__c 
                from Membership__c where Program__c in :progIds and Account_Name__c in :accIds]);
            
            //Narrow list down to only Memberships that actually match directly with one of our Contracts, narrow down by Account first
            Map<Id, Membership__c> MembershipstoCheckMap = new Map<Id, Membership__c>();
            
            // Loop through all Memberships associated to the Accounts from these Contracts
            for (Membership__c m : allMems.values()) {
            
                // If the Account Id To Contract map contains a record for this Membership's Account then process
                // (there should be no reason for this condition, but it's better to have it than not)
                if (accId2ConListMap.containsKey(m.Account_Name__c)) {
                
                    for (Contract__c c : accId2ConListMap.get(m.Account_Name__c)) {
                    
                        // If the Contract's Program equals the Membership's Program then store the Membership in a map w/ it's Id as a key 
                        if (c.Program__c == m.Program__c) {
                            MembershipstoCheckMap.put(m.id, m);
                            memOwnerNeeded.add(m.id);   //DAF - added 12-15-11
                        }
                    }
                }
            }
            
            /* Go through the Memberships identified above (MembershipstoCheck) to see what needs to be done.  */
            
            //get set of Contract Ids on the basis of matching Contract Integrated Accounts 
            List<Contract_Integrated_Accounts__c> ciaList = [select Id, Account__c, Contract__c, Contract__r.Program__c 
                from Contract_Integrated_Accounts__c where (Account__c in :accIds) and (Contract__r.Program__c in :progIds)
                and (Contract__r.Status__c = 'ATL' or Contract__r.Status__c = 'Honorary' or Contract__r.Status__c = 'Dropped')];
            
            // Set to store Contract Ids from the related Contract Integrated Accounts 
            Set<Id> ciaContractIds = new Set<Id>();
            
            // Loop through Contract Integrated Accounts and build a list of associated Contract Ids based on memberships
            for(Contract_Integrated_Accounts__c cia : ciaList) {
            
                // Loop through Memberships associated to the related Accounts
                for (Membership__c m : MembershipstoCheckMap.values()) {
                
                    // If the Contract Integrated Account Contract Program and Membership Program are equal
                    // AND the Contract Integrated Account Account and the Membership Account are equal, 
                    // then add the Contract Id to a list
                    if ((cia.Contract__r.Program__c == m.Program__c) && (cia.Account__c == m.Account_Name__c))
                        ciaContractIds.add(cia.Contract__c);
                }
            }
            
            // Build a list of Cotracts from the Contract Ids found from above
            List<Contract__c> listContracts = [select Id, Active__c, Join_Date__c, Start__c, End__c, Program__c, Payer_Account__c,
                (select Id, Account__c from Contract_Integrated_Accounts__r where Account__c in :accIds)
                from Contract__c 
                where ((id in :ciaContractIds) or (Payer_Account__c in :accids and Program__c in :progids))
                and (Status__c = 'ATL' or Status__c = 'Honorary' or Status__c = 'Dropped')]; // Nathan B 1/5/11 - Added Status condition
            
            // Map of Contracts w/ their Id as the key
            Map<Id, Contract__c> conId2ConMap = new Map<Id, Contract__c>(listContracts);
            
            // Map of Contracts w/ their Account Id as the key
            Map<Id, List<Contract__c>> accId2ContractListMap = new Map<Id, List<Contract__c>>();
            
            // Map a list of Contract Ids w/ their associated Account Id as the key
            Map<Id, set<Id>> accId2ContractIdSetMap = new Map<Id, Set<Id>>(); //acc id to Contract IDs, to make sure we don't add the same Contract twice
            
            // Loop through contracts (and Contract Integrated Accounts) for identified Memberships and put in sets by account number
            for (Contract__c c : listContracts) {
            
                if (accId2ContractIdSetMap.get(c.Payer_Account__c) == null) 
                    accId2ContractIdSetMap.put(c.Payer_Account__c, new set<id>{c.Id});
                else
                    accId2ContractIdSetMap.get(c.Payer_Account__c).add(c.Id);
                    
                // Loop through entire list of Contract Integrated Accounts on this Contract as possible connections. 1/11/11 jn
                for (Contract_Integrated_Accounts__c cia : c.Contract_Integrated_Accounts__r) {
                
                    if (accId2ContractIdSetMap.get(cia.Account__c) == null) 
                        accId2ContractIdSetMap.put(cia.Account__c, new set<id>{c.id});
                    else
                        accId2ContractIdSetMap.get(cia.Account__c).add(c.id);
                }
            } //end for contracts
            
            //convert id sets into a map of contract lists w/ account ID as the key
            for (Id i : accId2ContractIdSetMap.keySet())
            {
                accId2ContractListMap.put(i,new list<Contract__c>());
                
                for (Id cid : accId2ContractIdSetMap.get(i))
                {
                    accId2ContractListMap.get(i).add(conId2ConMap.get(cid));
                }
            }
            
            //populate the accountIdMap and MembershipMaps for Standard Contract with CPQ Subscriptions
            populateAccIdMapAndMembershipMap(newCIAs);
            
            //add all memberships found via populateAccIdMapAndMembershipMap() method
            if (ContractIntegratedAccountsTriggerHelper.MembershipsToCheckMap != null)
                MembershipsToCheckMap.putAll(ContractIntegratedAccountsTriggerHelper.MembershipsToCheckMap);
            
            // Loop through all Memberships that need to be checked
            for (Membership__c m : MembershipstoCheckMap.values()) {
            
                // Set the Earliest, Latest, and Active Contract field values to null
                m.Earliest_Contract__c = null;
                m.Latest_Contract__c = null;
                m.Active_Contract_Idenfied__c = null;
                /*m.Join_Date_Most_Recent__c = null;*/
                
                // Variables to temporarily store Earliest, Latest, Latest Active, and Earliest Future Contracts
                Contract__c earliestContract;
                Contract__c latestContract;
                Contract__c latestActiveContract;
                Contract__c earliestFutureContract;
                Date mostRecentJoinDate = null;
                
                //set the earliest, latest, and active Subscription field values to null
                m.Earliest_Subscription__c = null;
                m.Latest_Subscription__c = null;
                m.Active_Subscription__c = null;
                
                // Variables to temporarily store Earliest, Latest, Latest Active, and Earliest Future Contracts
                SBQQ__Subscription__c earliestSubscription;
                SBQQ__Subscription__c latestSubscription;
                SBQQ__Subscription__c latestActiveSubscription;
                SBQQ__Subscription__c earliestFutureSubscription;
                
                
                // If this membership has a Program and an Account then process
                if(m.Program__c != null && m.Account_Name__c != null) {
                
                    // If the Membership's Account has Contracts associated, then process
                    if (accId2ContractListMap.get(m.Account_Name__c) != null) {
                    
                        // Loop through list of contracts for membership Institution(Account)
                        for (Contract__c acon : accId2ContractListMap.get(m.Account_Name__c)) {
                        
                            // Skip processing if the Contract's Program and the Membership's Program do not match
                            if (acon.Program__c != m.Program__c)
                                continue; 
                            
                            //earliest contract
                            if (acon.Start__c != null && (earliestContract == null  || acon.Start__c < earliestContract.Start__c)) 
                                earliestContract = acon;
                            
                            //latest contract
                            if (acon.End__c != null && (latestContract == null || acon.End__c > latestContract.End__c)) 
                                latestContract = acon;
                            
                            //active contract idenfied
                            if (acon.Start__c != null && acon.End__c != null && acon.Start__c <= system.today() && acon.End__c >= system.today()
                                && (latestActiveContract == null || acon.End__c > latestActiveContract.End__c)) {
                            
                                latestActiveContract = acon;
                            }
                            
                            //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
                            if (acon.Start__c != null && acon.End__c != null && acon.Start__c > system.today()
                                && (earliestFutureContract == null || acon.Start__c < earliestFutureContract.Start__c))
                            {
                                earliestFutureContract = acon;
                            }
                            
                            //Bhavi Sharma - 04/26/2013 - Set oldest date as mostRecentJoinDate
                            /*if(acon.Active__c == true && acon.Join_Date__c != null && (mostRecentJoinDate == null || acon.Join_Date__c < mostRecentJoinDate )) {
                                
                                //Set join date as most recent
                                mostRecentJoinDate = acon.Join_Date__c;
                            }*/ 
                        }
                        
                        if (latestActiveContract == null)
                            latestActiveContract = earliestFutureContract;
                    }
                    
                    //put calculated values, if they were found, into the appropriate fields
                    if (earliestContract != null)
                        m.Earliest_Contract__c = earliestContract.id;
                        
                    if (latestContract != null)
                        m.Latest_Contract__c = latestContract.id;
                        
                    if (latestActiveContract != null)
                        m.Active_Contract_Idenfied__c = latestActiveContract.id;
                        
                     //Modified By - Subhash Garhwal - 06/27/2018 - CR-20180502-12199 Comment out the logic to populate 'Join_Date_Most_Recent__c' on membership
                    /*if(mostRecentJoinDate != null)
                        m.Join_Date_Most_Recent__c = mostRecentJoinDate;*/
                    
                }
                
                /*** Subscription START ***/
                // If the Membership's Account has Contracts associated, then process
                if (ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.get(m.Account_Name__c) != null) {
                    
                    // Loop through list of contracts for membership Institution(Account)
                    for (SBQQ__Subscription__c aSub : ContractIntegratedAccountsTriggerHelper.accId2SubscriptionListMap.get(m.Account_Name__c)) {
                        
                        // Skip processing if the Contract's Program and the Membership's Program do not match
                        if (aSub.Program__c != m.Program__c)
                            continue; 
                        
                        //earliest contract
                        if (aSub.SBQQ__StartDate__c != null && (earliestSubscription == null  || aSub.SBQQ__StartDate__c < earliestSubscription.SBQQ__StartDate__c)) 
                            earliestSubscription = aSub;
                        
                        //latest contract
                        if (aSub.SBQQ__EndDate__c != null && (latestSubscription == null || aSub.SBQQ__EndDate__c > latestSubscription.SBQQ__EndDate__c)) 
                            latestSubscription = aSub;
                        
                        //active contract idenfied
                        if (aSub.SBQQ__StartDate__c != null && aSub.SBQQ__EndDate__c != null && aSub.SBQQ__StartDate__c <= system.today() && aSub.SBQQ__EndDate__c >= system.today()
                            && (latestActiveSubscription == null || aSub.SBQQ__EndDate__c > latestActiveSubscription.SBQQ__EndDate__c)) {
                                
                                latestActiveSubscription = aSub;
                            }
                        
                        //earliest Future Contract (to use for Active Contract Idenfied if there is none found within its dates)
                        if (aSub.SBQQ__StartDate__c != null && aSub.SBQQ__EndDate__c != null && aSub.SBQQ__StartDate__c > system.today()
                            && (earliestFutureSubscription == null || aSub.SBQQ__StartDate__c < earliestFutureSubscription.SBQQ__StartDate__c))
                        {
                            earliestFutureSubscription = aSub;
                        }
                        
                        //Bhavi Sharma - 04/26/2013 - Set oldest date as mostRecentJoinDate
                        //Modified By - Subhash Garhwal - 06/27/2018 - CR-20180502-12199 Comment out the logic to populate 'Join_Date_Most_Recent__c' on membership
                        /*if(aSub.Active_Subscription__c == true && aSub.Join_Date__c != null && (mostRecentJoinDate == null || aSub.Join_Date__c < mostRecentJoinDate )) {
                            
                            //Set join date as most recent
                            mostRecentJoinDate = aSub.Join_Date__c;
                        }*/ 
                    }
                    
                    if (latestActiveSubscription == null)
                        latestActiveSubscription = earliestFutureSubscription;
                    
                    //put calculated values, if they were found, into the appropriate fields
                    if (earliestSubscription != null)
                        m.Earliest_Subscription__c = earliestSubscription.id;
                    
                    if (latestSubscription != null)
                        m.Latest_Subscription__c = latestSubscription.id;
                    
                    if (latestActiveSubscription != null)
                        m.Active_Subscription__c = latestActiveSubscription.id;
                    
                    /*if(mostRecentJoinDate != null)
                        m.Join_Date_Most_Recent__c = mostRecentJoinDate;*/
                }
                /*** Subscription END ***/
                
            }
            
            //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process 
            // If there are Memberships needing update, then update and record errors to the debuglog variable
            if (MembershipstoCheckMap.values().size() > 0) {
                
                //Modified By - Abhinav Sharma - 04/19/2014 - CR-20140331-4909
                if(System.isBatch()) {
                    logMessage = Util.createLog(Database.update((MembershipstoCheckMap.values()),false));
                } else {
                    update MembershipstoCheckMap.values();
                }
            }
        }
        
        //Returning log message string
        return logMessage;      
    }
    
    
    
    /**
     *      Description     :   Method to get Contract Integrated Account records and 
     *                          create the missing Membership record with 
     *                              i)  program = CIA related contract's programs and 
     *                              ii) account = CIA related Account  
     *  
     *      Return Type     :   Void
     *
     *      Arguments       :   List<Contract_Integrated_Accounts__c>
     *  
     **/   
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
    public static void createMembershipForCIARecords(List<Contract_Integrated_Accounts__c> newCIAs, Map<Id, Contract_Integrated_Accounts__c> mapOldCIAs) {
        
        //List to hold CIA records 
        List<Contract_Integrated_Accounts__c> listOfCIARecords = new List<Contract_Integrated_Accounts__c>();
        
        //Set to hold CIA Ids 
        Set<Id> setCIAIds = new Set<Id>();
        
        //Loop over new records 
        for(Contract_Integrated_Accounts__c cia : newCIAs){
            
            if(
                cia.Account__c != null 
                && cia.Contract__c != null
                &&
                (
                    mapOldCIAs == null 
                    || 
                    (
                        mapOldCIAs != null 
                         && 
                         (
                             cia.Account__c != mapOldCIAs.get(cia.id).Account__c 
                             || cia.Contract__c!= mapOldCIAs.get(cia.id).Contract__c
                         )
                    )
                )
            ){
                setCIAIds.add(cia.Id);
            }
        }
        
        //Check for the size
        if(setCIAIds.size() > 0)
        {
            //Loop over new CIA records to get parent record fields value
            for(Contract_Integrated_Accounts__c cia : [SELECT ID , Account__c, Contract__c, Contract__r.Program__c 
                                                       FROM Contract_Integrated_Accounts__c 
                                                       WHERE Id IN: setCIAIds]) {
                
                //Add CID record ID in the set 
                listOfCIARecords.add(cia);
            }
            
            //Check for size
            // then Call the method and pass argument for future proccess
            if(listOfCIARecords.size() > 0)
                createMembershipForCIA(Constants.OBJECT_CONTRACT_ABC_API_NAME, listOfCIARecords);           
        }
    }
    
    /**
     *      Description     :   Method to get All Membership records where 
     *                          Membership.Account = CIA.Account And
     *                          Membership.Program = CIA.Contract.Program
     *  
     *      Return Type     :   List<Membership__c>
     *
     *      Arguments       :   Set Account ids = setAcc , Set Program Ids = setProgram
     *  
     **/
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679    
    public static List<Membership__c> MembershipRecords(Set<Id> setAccIds, Set<Id> setProgramIds) {
        
        //List to hold Membership records 
        List<Membership__c> listOfMembership = new List<Membership__c>();
        
        //Check for size
        if(setAccIds !=null && setProgramIds != null) 
        {
            //Query over Membership records
            for(Membership__c ms : [Select Id, Account_Name__c, Program__c From Membership__c 
                                    Where Account_Name__c != null AND Account_Name__c IN : setAccIds AND
                                    Program__c != null AND Program__c IN : setProgramIds ]
            ) {
                //Plopulate membership list 
                listOfMembership.add(ms);                          
            }    
        }
        
        //Return
        return listOfMembership;
    }
    
    /**
     *      Description     :   Method to have logic When a Contract Integrated Account is created or 
     *                          modified and the Contract field is populated/updated, 
     *                          check that a Membership exists on the "Account" referenced on the Contract Integrated Account.
     *                          The Membership should be for the Program that the related Contract's Opportunity is related to.
     *                          If the Membership doesn't exist on the institution, create a new Membership for that 
     *                          Institution / Program.
     *  
     *      Return Type     :   Void   
     *
     *      Arguments       :   String ,List<Contract_Integrated_Accounts__c>   
     *  
     **/ 
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
    public static void createMembershipForCIA(String objAPIName , List<Contract_Integrated_Accounts__c> newCIAs){
          
        //Check for Object Name
        if(objAPIName == Constants.OBJECT_CONTRACT_ABC_API_NAME){
            
            //Define properties to hold values
            //Set to hold Account Id 
            Set<Id> setAccIds = new Set<Id>();
            
            //Set to hold Program Ids
            Set<Id> setProgramIds = new Set<Id>();
            
            //Mep to hold Contract Id as key and Contract.Program Id as a value.
            map<Id, Id> mapContractIdWithProgramId = new map<Id, Id>();
               
            //Loove over Contract Integrated Account
            for(Contract_Integrated_Accounts__c cia : newCIAs){
                
                //Check for Account field and add value in the set
                if(cia.Account__c != null)
                    setAccIds.add(cia.Account__c);
                
                //Check for Conract field and add value in the set
                if(cia.Contract__c != null && cia.Contract__r.Program__c != null){
                    setProgramIds.add(cia.Contract__r.Program__c); 
                    mapContractIdWithProgramId.put(cia.Contract__c , cia.Contract__r.Program__c);  
                }
            }
            
            //To hold the set of unique Key [Account.Id-Program.Id]
            Set<String> setAccountIdProgramIdAsKey = new Set<String>();
            
            //Check for set size and call the method to to get all membership records
            if(setAccIds.size() > 0 && setProgramIds.size() > 0)
            {    
                //Loop over membership records
                for(Membership__c ms2 : MembershipRecords(setAccIds ,setProgramIds )) 
                {
                    //Check for Membership account and Program/ And add 
                    //populate the set for unique keys "setAccountIdProgramIdAsKey"
                    if(ms2.Account_Name__c != null && ms2.Program__c != null )
                        setAccountIdProgramIdAsKey.add(ms2.Account_Name__c + ' - ' + ms2.Program__c);
                }
            }            
            
            //List to hold the Membership Records to be inserted.
            List<Membership__c> listOfMembershipToBeInsert = new List<Membership__c>();
            
            //Loop over new records
            for(Contract_Integrated_Accounts__c cia : newCIAs)
            {
                //String to hold tepm unique key of Program/ Account value
                String tempString = cia.Account__c + ' - ' + cia.Contract__r.Program__c;
                
                //Check set contain unique value in set or not
                if(!setAccountIdProgramIdAsKey.contains(tempString)) 
                {
                    //create new membership records 
                    listOfMembershipToBeInsert.add(new Membership__c(Program__c = mapContractIdWithProgramId.get(cia.Contract__c), Account_Name__c = cia.Account__c));   
                    
                    //populate set "setAccountIdProgramIdAsKey"
                    setAccountIdProgramIdAsKey.add(tempString);   
                }              
            }
            
            //Check for size
            if(listOfMembershipToBeInsert.size() > 0) 
                
                //In order to auto populate the other membership fields, DO Not BY Pass The Triggeres 
                //Insert Membership records
                insert listOfMembershipToBeInsert; 
        }
    }
    
    /**
     *  @description    :   Method for CIA naming convention 
     *
     *  @args           :   List<Contract_Integrated_Accounts__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 06/04/2017 - CR-20170403-10807 
     *
     *
     **/
    public static void cIANamingConvention(List<Contract_Integrated_Accounts__c> contIntAccounts) {
        
        //Set to hold the Account Ids
        Set<Id> setAccountIds = new Set<Id>();
        
        //Set to hold the Contract Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the CIA
        for(Contract_Integrated_Accounts__c cIA : contIntAccounts) {
            
            //Check for Account and Contract
            if(cIA.LOA_Contract__c != null) {
                
                if(cIA.Account__c != null)
                    setAccountIds.add(cIA.Account__c);
                
                //Check for LOA_Contract__c
                setContractIds.add(cIA.LOA_Contract__c);        
            }
        }
        
        //Check for size
        if(setContractIds.size() > 0) {
            
            //Query through the account
            Map<Id, Account> mapAccounts = new Map<Id, Account>([Select Id, Name From Account Where Id IN : setAccountIds]);
            
            //Query throough the Contract
            Map<Id, Contract> mapContracts =  new Map<Id, Contract>([Select Id, Name From Contract Where Id IN : setContractIds]);
            
            //Loop over the CIA
            for(Contract_Integrated_Accounts__c cIA : contIntAccounts) {
                
                //Check for Account and Contract
                if(cIA.LOA_Contract__c != null) {
                    
                    //name variable
                    String cIAName = '';
                    
                    //Check for Account
                    if(mapAccounts.containsKey(cIA.Account__c))
                        cIAName = mapAccounts.get(cIA.Account__c).Name.left(55);
                    
                    //Add Contract name
                    cIAName += mapContracts.get(cIA.LOA_Contract__c).Name;
                    
                    //Check for max
                    cIAName = cIAName.left(80);
                    
                    //Update name
                    cIA.Name = cIAName;             
                }
            }
        }
    }
    
    /**
     *  @description    :   Method to create Membership for Std. Contract 
     *
     *  @args           :   List<Contract_Integrated_Accounts__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - 06/07/2017 - CR-20170403-10807 
     *			:   V_1.1 - Modified - Chirag Soni - 07/26/2021 - CR-20210621-15227 - Commented the logic and moved it to new future method createMembershipsFuture.
     **/
    public static void createMemberships(List<Contract_Integrated_Accounts__c> contractIntegratedAccounts) {
        /*
        //Set to hold the Account Ids
        Set<Id> setAccountIds = new Set<Id>();
        
        //Set to hold the Program Ids
        Set<Id> setProgramIds = new Set<Id>();
        
        //Map to hold the Contracts with AccountIds
        Map<Id, Set<Id>> mapContractIdWithAccountIds = new Map<Id, Set<Id>>();
        
        //Map to hold the Contracts with Program Ids
        Map<Id, Set<Id>> mapContractIdWithProgramIds = new Map<Id, Set<Id>>();
        
        //Loop over the CIA
        for(Contract_Integrated_Accounts__c cIA : contractIntegratedAccounts) {
            
            //Check for account
            if(cIA.Account__c != null && cIA.LOA_Contract__c != null) {
                
                //Add Account Id
                setAccountIds.add(cIA.Account__c);
                
                //Check Contract Id in map
                if(!mapContractIdWithAccountIds.containsKey(cIA.LOA_Contract__c))
                    mapContractIdWithAccountIds.put(cIA.LOA_Contract__c, new Set<Id>());
                
                //Add Account
                mapContractIdWithAccountIds.get(cIA.LOA_Contract__c).add(cIA.Account__c);
            }
        }
        
        //Check for map size
        if(mapContractIdWithAccountIds.size() > 0) {
            
            //Loop over the Program Subscriptions
            for(SBQQ__Subscription__c pS : [Select Id, Program__c, SBQQ__Product__r.Program__c, SBQQ__Contract__c From SBQQ__Subscription__c Where SBQQ__Contract__c IN : mapContractIdWithAccountIds.keySet()
                                                   AND RecordType.DeveloperName = 'Program' AND SBQQ__Product__r.Program__c != null]) {
                                                    
                //Add Program Id in set
                setProgramIds.add(pS.SBQQ__Product__r.Program__c);
                
                //Check for Contract Id in map
                if(!mapContractIdWithProgramIds.containsKey(pS.SBQQ__Contract__c))
                    mapContractIdWithProgramIds.put(pS.SBQQ__Contract__c, new Set<Id>());
                
                //Add Progrma Id in map
                mapContractIdWithProgramIds.get(pS.SBQQ__Contract__c).add(pS.SBQQ__Product__r.Program__c);                                              
            }
            
            //Check for size
            if(mapContractIdWithProgramIds.size() > 0) {
                
                //Map to hold the Std. Contract
                Map<Id, Contract> mapContracts = new Map<Id, Contract>([Select Id From Contract Where StatusCode = 'Activated' AND Id IN : mapContractIdWithAccountIds.keySet()]);
                
                //Map to hold the memberships
                Map<String, Id> mapMemberships = new Map<String, Id>();
                
                //SOQL on membership
                for(Membership__c mem : [Select Id, Account_Name__c, Program__c From Membership__c Where Account_Name__c IN : setAccountIds AND Program__c IN : setProgramIds])
                    mapMemberships.put(mem.Account_Name__c + '-' + mem.Program__c, mem.Id);
                
                //List to upsert Membership__c
                Map<String, Membership__c> mapMembershipsToInsert = new Map<String,Membership__c>();
                
                //Loop over the Contract
                for(Id contId : mapContractIdWithAccountIds.keySet()) {
                    
                    //Check Contract id in map
                    if(mapContractIdWithProgramIds.containsKey(contId)) {
                        
                        //Loop over the Accounts
                        for(Id accId : mapContractIdWithAccountIds.get(contId)) {
                            
                            //Loop over the Program
                            for(Id proId : mapContractIdWithProgramIds.get(contId)) {
                                
                                //Create UK
                                String uK = accId + '-' + proId;
                                
                                //Instance of membership
                                Membership__c mem = new Membership__c();
                                
                                //Check for Id
                                if(mapMemberships.containsKey(uK) && mapMemberships.get(uK) != null)
                                    mem = new Membership__c(Id = mapMemberships.get(uK));
                                
                                //Populate field values
                                mem.Account_Name__c = accId;
                                mem.Program__c = proId;
                                mem.Membership_Status_Text__c = 'Membership Integrated';    
                                
                                        
                                //Add record in list
                                if(!mapMembershipsToInsert.containsKey(uK))
                                    mapMembershipsToInsert.put(uK,mem);
                            }
                        }
                    }   
                }
                
                //Check for size
                if(mapMembershipsToInsert.size() > 0) {
                	
                	//Issue--CR10808--QA--00004671
                	Util.IsTrigger_ContractIntegratedAcctRunning = false;
                	
                	upsert mapMembershipsToInsert.values();     
                	
                	Util.IsTrigger_ContractIntegratedAcctRunning = true;
                }
            }
        }*/
       
        // Modified - Chirag Soni - 07/26/2021 - CR-20210621-15227 - new logic to send set of Ids in future method. -- starts
        Set<Id> setCIAIds = new Set<Id>();
        
        //Loop over the CIA
        for(Contract_Integrated_Accounts__c cIA : contractIntegratedAccounts) {
            
            //Check for account
            if(cIA.Account__c != null && cIA.LOA_Contract__c != null) {
                
                setCIAIds.add(cIA.Id);
            }
        }
        if(setCIAIds.size() > 0) {
            //CR-20210831-15398 - By Subhash - call sched_populateSubFieldsOnMembership  and comment createMembershipsFuture method calling
            //createMembershipsFuture(setCIAIds);
            sched_populateSubFieldsOnMembership.schedule_populateSubFieldsOnMembership(null, setCIAIds, true );
        }
        // Modified - Chirag Soni - 07/26/2021 - CR-20210621-15227 - new logic to send set of Ids in future method. -- ends
    }
    
     /**
     *  @description    :   Future method to create Membership for Std. Contract 
     *
     *  @args           :   Set<Id>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Chirag Soni - 07/26/2021 - CR-20210621-15227
     *                      V_1.1 - Updated - Mahendra Swarnkar - CR-20210831-15398 remove/comment @future anotation.
     *		
     **/
    
    //@future
    public static void createMembershipsFuture(Set<Id> setCIAIds) {
        
        if(setCIAIds != null && setCIAIds.size()>0){
            
            //Set to hold the Account Ids
            Set<Id> setAccountIds = new Set<Id>();
            
            //Set to hold the Program Ids
            Set<Id> setProgramIds = new Set<Id>();
            
            //Map to hold the Contracts with AccountIds
            Map<Id, Set<Id>> mapContractIdWithAccountIds = new Map<Id, Set<Id>>();
            
            //Map to hold the Contracts with Program Ids
            Map<Id, Set<Id>> mapContractIdWithProgramIds = new Map<Id, Set<Id>>();
            
            //Loop over the CIA
            for(Contract_Integrated_Accounts__c cIA : [SELECT Id, Account__c, LOA_Contract__c 
                                                       From Contract_Integrated_Accounts__c Where ID IN : setCIAIds]) 
            {
                
                //Check for account
                if(cIA.Account__c != null && cIA.LOA_Contract__c != null) {
                    
                    //Add Account Id
                    setAccountIds.add(cIA.Account__c);
                    
                    //Check Contract Id in map
                    if(!mapContractIdWithAccountIds.containsKey(cIA.LOA_Contract__c))
                        mapContractIdWithAccountIds.put(cIA.LOA_Contract__c, new Set<Id>());
                    
                    //Add Account
                    mapContractIdWithAccountIds.get(cIA.LOA_Contract__c).add(cIA.Account__c);
                }
            }
            
            //Check for map size
            if(mapContractIdWithAccountIds.size() > 0) {
                
                //Loop over the Program Subscriptions
                for(SBQQ__Subscription__c pS : [Select Id, Program__c, SBQQ__Product__r.Program__c, SBQQ__Contract__c From SBQQ__Subscription__c Where SBQQ__Contract__c IN : mapContractIdWithAccountIds.keySet()
                                                AND RecordType.DeveloperName = 'Program' AND SBQQ__Product__r.Program__c != null]) 
                {
                    //Add Program Id in set
                    setProgramIds.add(pS.SBQQ__Product__r.Program__c);
                    
                    //Check for Contract Id in map
                    if(!mapContractIdWithProgramIds.containsKey(pS.SBQQ__Contract__c))
                        mapContractIdWithProgramIds.put(pS.SBQQ__Contract__c, new Set<Id>());
                    
                    //Add Progrma Id in map
                    mapContractIdWithProgramIds.get(pS.SBQQ__Contract__c).add(pS.SBQQ__Product__r.Program__c);                                              
                }
                
                //Check for size
                if(mapContractIdWithProgramIds.size() > 0) {
                    
                    //Map to hold the Std. Contract
                    Map<Id, Contract> mapContracts = new Map<Id, Contract>([Select Id From Contract Where StatusCode = 'Activated' AND Id IN : mapContractIdWithAccountIds.keySet()]);
                    
                    //Map to hold the memberships
                    Map<String, Id> mapMemberships = new Map<String, Id>();
                    
                    //SOQL on membership
                    for(Membership__c mem : [Select Id, Account_Name__c, Program__c From Membership__c Where Account_Name__c IN : setAccountIds AND Program__c IN : setProgramIds])
                        mapMemberships.put(mem.Account_Name__c + '-' + mem.Program__c, mem.Id);
                    
                    //List to upsert Membership__c
                    Map<String, Membership__c> mapMembershipsToInsert = new Map<String,Membership__c>();
                    
                    //Loop over the Contract
                    for(Id contId : mapContractIdWithAccountIds.keySet()) {
                        
                        //Check Contract id in map
                        if(mapContractIdWithProgramIds.containsKey(contId)) {
                            
                            //Loop over the Accounts
                            for(Id accId : mapContractIdWithAccountIds.get(contId)) {
                                
                                //Loop over the Program
                                for(Id proId : mapContractIdWithProgramIds.get(contId)) {
                                    
                                    //Create UK
                                    String uK = accId + '-' + proId;
                                    
                                    //Instance of membership
                                    Membership__c mem = new Membership__c();
                                    
                                    //Check for Id
                                    if(mapMemberships.containsKey(uK) && mapMemberships.get(uK) != null)
                                        mem = new Membership__c(Id = mapMemberships.get(uK));
                                    
                                    //Populate field values
                                    mem.Account_Name__c = accId;
                                    mem.Program__c = proId;
                                    mem.Membership_Status_Text__c = 'Membership Integrated';    
                                    
                                    
                                    //Add record in list
                                    if(!mapMembershipsToInsert.containsKey(uK))
                                        mapMembershipsToInsert.put(uK,mem);
                                }
                            }
                        }   
                    }
                    
                    //Check for size
                    if(mapMembershipsToInsert.size() > 0) {
                        
                        //Issue--CR10808--QA--00004671
                        Util.IsTrigger_ContractIntegratedAcctRunning = false;
                        
                        upsert mapMembershipsToInsert.values();     
                        
                        Util.IsTrigger_ContractIntegratedAcctRunning = true;
                    }
                }
            }
        }
    }
    
    /*	Description		:	The method is used to populate Subscription fields on the Membership records
    *
    *	@args			:	List<Contract_Integrated_Accounts__c>, Map<Id, Contract_Integrated_Accounts__c>
    *
    *	@return			:	Void
    *
    *	Revision Log	 	:	V1.0 created - Subhash Garhwal - Issue--CR10808--QA--00005099 - 07/26/2017
    *					V1.1 Modified - Subhash Garhawal - 10/08/2018 - CR-20180720-1245
    * 					V1.2 Modified - Chirag Soni - 07/26/2021 - CR-20210621-15227 - Commented the SBQQ__Subscription__c query and mehtod call populateSubscriptionFieldsOnMembership and moved it to new future method populateSubscriptionFieldsOnMembershipFuture
    **/
    public static void populateSubscriptionFieldsOnMembership(List<Contract_Integrated_Accounts__c> newIntegrateds, Map<Id, Contract_Integrated_Accounts__c> mapOldIntegrateds){
    	
    	//Define variables
    	
    	//Insert and Update case variables
    	
    	//Set to hold the Std. Contract Ids
    	Set<Id> setStdContractIds = new Set<Id>();
    	
    	//Set to hold the Acocunt Ids
    	Set<Id> setAccountIds = new Set<Id>();
    	
    	//Delete case variables
    	
    	//Set to hold the Contract Ids
		Set<Id> setDeleteStdContractIds = new Set<Id>();
		
    	//Map to hold the Accounts with Std. Contract
    	Map<Id, List<Id>> mapAccountsWithStdContracts = new Map<Id, List<Id>>();
    	
    	//Loop over the CIA
    	for(Contract_Integrated_Accounts__c cIA : newIntegrateds != null ? newIntegrateds : mapOldIntegrateds.values()) {
    		
    		//Check for Insert case
    		if(mapOldIntegrateds == null && cIA.Account__c != null && cIA.LOA_Contract__c != null) {
    			
    			//Add values in collections
    			setStdContractIds.add(cIA.LOA_Contract__c);
    			setAccountIds.add(cIA.Account__c);
    		}
    		
    		//Update case
    		if(newIntegrateds != null && mapOldIntegrateds != null && (cIA.Account__c != mapOldIntegrateds.get(cIA.Id).Account__c
    			|| cIA.LOA_Contract__c != mapOldIntegrateds.get(cIA.Id).LOA_Contract__c)) {
    			
    			//Add values in collections
    			if(cIA.LOA_Contract__c != null)
    				setStdContractIds.add(cIA.LOA_Contract__c);
    			
    			if(cIA.Account__c != null)
    				setAccountIds.add(cIA.Account__c);
    			
    			//Check for old values
    			if(mapOldIntegrateds.get(cIA.Id).LOA_Contract__c != null) {
    				
    				//Check Std Contract in map
    				if(!mapAccountsWithStdContracts.containsKey(mapOldIntegrateds.get(cIA.Id).LOA_Contract__c))
    					mapAccountsWithStdContracts.put(mapOldIntegrateds.get(cIA.Id).LOA_Contract__c, new List<Id>());
    				
    				//Add Account Id
    				if(mapOldIntegrateds.get(cIA.Id).Account__c != null)
    					mapAccountsWithStdContracts.get(mapOldIntegrateds.get(cIA.Id).LOA_Contract__c).add(mapOldIntegrateds.get(cIA.Id).Account__c);		
    			}
    		}
    		
    		//Delete case
    		if(newIntegrateds == null && cIA.Account__c != null && cIA.LOA_Contract__c != null) {
    			
    			//Check Std Contract in map
				if(!mapAccountsWithStdContracts.containsKey(cIA.LOA_Contract__c))
					mapAccountsWithStdContracts.put(cIA.LOA_Contract__c, new List<Id>());
				
				//Add Account Id
				mapAccountsWithStdContracts.get(cIA.LOA_Contract__c).add(cIA.Account__c);
    			
    		}		
    	}
    	
    	//Check for size
    	if(mapAccountsWithStdContracts.size() > 0) {
    		
    		//Set to hold the Programs
    		Set<Id> setProgramIds = new Set<Id>();
    		
    		//Set to hold the Account Ids
    		Set<Id> setDeleteCIAAccIds = new Set<Id>();
    		
    		//Set to hold the Unique combination of Account and Program
    		Set<String> setAccAndProgramUK = new Set<String>();
    		
    		//Set to hold the Subscription Id
    		Set<Id> setProgramSubIds = new Set<Id>();
    		
    		//SOQL query over the Program Subscriptions
    		for(SBQQ__Subscription__c pS : [Select Id, Program__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Status__c From SBQQ__Subscription__c
    											   Where SBQQ__Contract__c IN : mapAccountsWithStdContracts.keySet() AND RecordType.DeveloperName = 'Program'
    											   AND Program__c != null]) {
    			
    			//Check Std Contract in map
    			if(mapAccountsWithStdContracts.containsKey(pS.SBQQ__Contract__c) && mapAccountsWithStdContracts.get(pS.SBQQ__Contract__c) != null) {
    				
    				//Add Program Id in set
    				setProgramIds.add(pS.Program__c);
    				
    				//Add PS id in set
    				setProgramSubIds.add(pS.Id);
    				
    				//Loop over the Account Ids
    				for(Id accId : mapAccountsWithStdContracts.get(pS.SBQQ__Contract__c)) {
    					
    					//Add Account Id in set
    					setDeleteCIAAccIds.add(pS.SBQQ__Account__c);
    					
    					//Add UK in set
    					setAccAndProgramUK.add(pS.SBQQ__Account__c + '-' + pS.Program__c);
    				
    				}
    			}									   	
    		}
    		
    		//Check for UK
    		if(setAccAndProgramUK.size() > 0) {
    			
    			//List to update the Membership
    			List<Membership__c> membershipsToUpdate = new List<Membership__c>();
    			
    			//SOQL over the membership
    			for(Membership__c mem : [Select Id, Active_Subscription__c, Earliest_Subscription__c, Latest_Subscription__c, Account_Name__c,
    											Program__c From Membership__c Where (Active_Subscription__c IN : setProgramSubIds
    											OR Earliest_Subscription__c IN : setProgramSubIds OR Latest_Subscription__c IN : setProgramSubIds)
    											AND Account_Name__c IN : setDeleteCIAAccIds AND Program__c IN : setProgramIds]) {
    				
    				//Check uK in set
    				if(setAccAndProgramUK.contains(mem.Account_Name__c + '-' + mem.Program__c)) {
    					
    					//Check for Active_Subscription__c subscription
    					if(setProgramSubIds.contains(mem.Active_Subscription__c))
    						mem.Active_Subscription__c = null;
    					
    					//Check for Earliest_Subscription__c subscription
    					if(setProgramSubIds.contains(mem.Earliest_Subscription__c))
    						mem.Earliest_Subscription__c = null;
    					
    					//Check for Latest_Subscription__c subscription
    					if(setProgramSubIds.contains(mem.Latest_Subscription__c))
    						mem.Latest_Subscription__c = null;
    					
    					//Add record in list
    					membershipsToUpdate.add(mem);	
    				}	
				}
				
				//Check for size
				if(membershipsToUpdate.size() > 0) {
					
					//Update
					update membershipsToUpdate;
					
					//Get all the CIA records for updated Accounts
					for(Contract_Integrated_Accounts__c cIA : [Select Id, Account__c, LOA_Contract__c From Contract_Integrated_Accounts__c
																	  Where Account__c IN : setDeleteCIAAccIds AND LOA_Contract__c != null])
						setStdContractIds.add(cIA.LOA_Contract__c);
					
					//Add renaming Ids in list
					setDeleteStdContractIds.addAll(mapAccountsWithStdContracts.keySet());	
				}
					
    		}
    	}
    	
    	//Check for new CIA case
    	if(setDeleteStdContractIds.size() > 0 || (setStdContractIds.size() > 0 && setAccountIds.size() > 0)) {
    		
    		//Set to hold the all the Std. Contract Ids
    		Set<Id> setAllStdContractIds = new Set<Id>();
    		
    		//Check for Account and Contract Ids
    		if(setStdContractIds.size() > 0 && setAccountIds.size() > 0)
				setAllStdContractIds.addAll(setStdContractIds);
    		
    		//Check for delete case Std. Contract
    		if(setDeleteStdContractIds.size() > 0)
    			setAllStdContractIds.addAll(setDeleteStdContractIds);
    		
    		//07/26/2021 - Modified by - Chirag Soni - CR-20210621-15227 - commented this part and pass the std contracts ids to new future method populateSubscriptionFieldsOnMembershipFuture -- starts here
            	//SOQL query over the Program Subscription
    		/*List<SBQQ__Subscription__c> proSubscriptions = [Select Id, Program__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Status__c, Parent_Program__c,SBQQ__Product__c From SBQQ__Subscription__c
				    											   Where SBQQ__Contract__c IN : setAllStdContractIds AND RecordType.DeveloperName = 'Program'
				    											   AND Program__c != null];
			
			//Modified - Subhash Garhawal - 10/08/2018 - CR-20180720-1245 
			//Call Subscription class method
			if(proSubscriptions.size() > 0)
			   SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(proSubscriptions, null);*/
            
            //CR-20210621-15227 - call the future method and pass the set of  std contracts ids to it.
            //CR-20210831-15398 - By Subhash - call sched_populateSubFieldsOnMembership and comment populateSubscriptionFieldsOnMembershipFuture method calling
            if(setAllStdContractIds.size() > 0){
                //populateSubscriptionFieldsOnMembershipFuture(setAllStdContractIds);
                sched_populateSubFieldsOnMembership.schedule_populateSubFieldsOnMembership(setAllStdContractIds, null, false);
            }
            
    	    //07/26/2021 - Modified by - Chirag Soni - CR-20210621-15227 - commented this part and pass the std contracts ids to new future method populateSubscriptionFieldsOnMembershipFuture -- ends here
    	}
    }
    
    
    /*	Description		:	The method is used to populate Subscription fields on the Membership records
    *
    *	@args			:	Set<Id> setAllStdContractIds
    *
    *	@return			:	Void
    *
    *	Revision Log		:	V1.0 created - Chirag Soni - 07/26/2021 - CR-20210621-15227 
    *				:       V1.1 Modified By - Mahendra Swarnkar - 01/09/2021 - CR-20210831-15398 remove/comment @future anotation.
    **/
    
    //@future
    public static void populateSubscriptionFieldsOnMembershipFuture(Set<Id> setAllStdContractIds){
        
        if(setAllStdContractIds != null && setAllStdContractIds.size() > 0){
            
            //SOQL query over the Program Subscription
            List<SBQQ__Subscription__c> proSubscriptions = [Select Id, Program__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Status__c, Parent_Program__c,SBQQ__Product__c 
                                                            From SBQQ__Subscription__c Where SBQQ__Contract__c IN : setAllStdContractIds AND RecordType.DeveloperName = 'Program'
                                                            AND Program__c != null];
            
            //Call Subscription class method
            if(proSubscriptions.size() > 0)
                SBQQ_SubscriptionTriggerHelper.populateSubscriptionFieldsOnMembership(proSubscriptions, null);
            
        }
    }
    
}