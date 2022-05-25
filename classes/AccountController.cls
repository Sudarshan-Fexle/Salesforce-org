/**
 *  Desription      :   Standard Controller for Account Detail Page 
 * 
 *  Created By      :   Bhavi Sharma
 * 
 *  Created Date    :   02/16/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *                      V1.2 - 12/06/2013 - VH - CR-4088
 *                      V1.3 - 12/20/2013 - VH - CR-3556
 *                      V1.4 - 03/18/2014 - Abhinav Sharma - CR-20140201-4431
 *                      V1.5 - 05/21/2014 - Abhinav Sharma - CR-20140410-5043
 *                      V1.6 - 06/07/2017 - Abhinav Sharma - DS073.2
 *                      V1.7 - 07/07/2017 - Subhash Garhwal - Issue--CR10810--QA--00004827
 *                      V1.8 - 07/10/2018 - Subhash Garhwal - CR-20180126-11905
 *                      V1.9   Modified By - Rajeev Jain - 02/18/2020 - CR-20190929-13381 -  Remove zzzRole(Role__c) field on Institution_Roles__c object
 *                                                       - 02/18/2020 - CR-20190929-13381 -  Remove zzzType of Contact(Type_of_Contact__c) field Institution_Roles__c object
 *			V2.0 - Modified By -  Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : US_Provider_System, US_Provider_Strategic, US_Provider
 **/ 
public with sharing class AccountController {
    
    //Account record
    public Account account { get; set; }
    
    //Updated By Abhinav Sharma - CR-20140201-4431 - 03/18/2014 - Account VF page performance enhancements
    private integer RECORD_LIMIT = 10; //sets the page size or number of rows
    private integer RECORD_15_LIMIT = 15;
    
    public boolean renderTabPanels { get; set; }
  
    //Properties to hold object name and OFFSET values for the related list [Helpful in pagination]  
    //Added By Abhavin Sharma - CR-20140201-4431 - 03/18/2014 - Account VF page performance enhancements
    public String object_Name {get; set;}
    Map<String, Integer> mapObjectWithOffset;
    
    //Properties helpful in rendering of links at VF page
    public Boolean displayShowMoreForCurrentRenewalOpportunity {get; set;}
    public Integer totalCurrentRenewalCount {get; set;}
    
    public Boolean displayShowMoreForNBBOpportunity {get; set;}
    public Integer totalNBBOpportunityCount {get; set;}
    
    public Boolean displayShowMoreForMemberships {get; set;}
    public Integer totalMembershipsCount {get; set;}
    
    public Boolean displayShowMoreForContractABCs {get; set;}
    public Integer totalContractABCsCount {get; set;}
    
    public Boolean displayShowMoreForAccountRoles {get; set;}
    public Integer totalAccountRolesCount {get; set;}
    
    public Boolean displayShowMoreForActiveRestrictions {get; set;}
    public Integer totalActiveRestrictionsCount {get; set;}
    
    public Boolean displayShowMoreForOpenNBBChildOpportunity {get; set;}
    public Integer totalOpenNBBChildOpportunitiesCount {get; set;}
    
    public Boolean displayShowMoreForCurrentChildRenewalOpp {get; set;}
    public Integer totalCurrentChildRenewalOppCount {get; set;}
    
    public Boolean displayShowMoreForActiveChildContracts {get; set;}
    public Integer totalActiveChildContractsCount {get; set;}
    
    public Boolean displayShowMoreForActiveChildSubscriptions {get; set;}
    public Integer totalActiveChildSubscriptionsCount {get; set;}
    
    public Boolean displayShowMoreForSubscriptions {get; set;}
    public Integer totalSubscriptionsCount {get; set;}
    
    private final static string ACCT_VF_PAGE_NAME = 'Account_US_Provider_Strategic';
    
    // controls number of items to display on each related list that uses pagination
    public Integer NumChildActivitiesToDisplay { get; set; }
    
    //Set to hold the object names
    Set<String> objectNamesSet = new Set<String>();
    
    //Set default
    public boolean activateRelatedLists {get; set;}
    
    public AccountController(ApexPages.StandardController controller) {
        
        //Initialize account record 
        account = (Account)controller.getRecord();
        
        // perform additional queries and setup variables in preparation for redirect
        if (ApexPages.currentPage().getURL().toLowerCase().contains( ACCT_VF_PAGE_NAME.toLowerCase() )) {
        
            // get the account with custom subqueries so we can set limits on the number of records returned (CR-4088)
            account = [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                       (SELECT Id, Name, Contact__c, ABC_Owner__c, Last_Interaction__c, Next_Interaction__c, Assignment_Comment__c, Contact_ABCO_Relationship__c 
                         FROM Account_Roles__r LIMIT :RECORD_LIMIT),
                       (SELECT Id, Name, Program__r.Name, Membership_Status__c, Renewal_Opp_Owner__c, End_Date_On_Last_Contract__c 
                         FROM Memberships__r WHERE Membership_Status__c LIKE 'Member%' ORDER BY Renewal_Opp_Owner__c ASC LIMIT :RECORD_LIMIT),
                       (SELECT Id, Negotiated_Amount__c, Active__c, Name, Start__c, End__c, Status__c, Annual_Contract_Value__c 
                         FROM Contracts__r WHERE Active__c = true ORDER BY End__c ASC LIMIT :RECORD_LIMIT)
                       FROM Account WHERE Id = :account.Id];
            
            // set the initial number of related list items to display
            NumChildActivitiesToDisplay = RECORD_15_LIMIT;
            
            //Setting default values  
            //Added By Abhinav Sharma - CR-20140201-4431 - 03/18/2014 - Account VF page performance enhancements  
            mapObjectWithOffset = new Map<String, Integer>();
            mapObjectWithOffset.put('Opportunity', 0);
            mapObjectWithOffset.put('Membership', 0);
            mapObjectWithOffset.put('ContractABC', 0);
            mapObjectWithOffset.put('CurrentRenewalOpportunity', 0);
            mapObjectWithOffset.put('AccountRole', 0);
            mapObjectWithOffset.put('ActiveRestriction', 0);
            mapObjectWithOffset.put('OpenNBBChildOpportunity', 0);
            mapObjectWithOffset.put('CurrentChildRenewalOpportunities', 0);
            mapObjectWithOffset.put('ActiveChildContracts', 0);
            mapObjectWithOffset.put('ActiveChildSubscriptions', 0);
            mapObjectWithOffset.put('Subscription', 0);
            totalNBBOpportunityCount = 0;
            totalMembershipsCount = 0;
            totalContractABCsCount = 0;
            totalCurrentRenewalCount = 0;
            totalAccountRolesCount = 0;
            totalActiveRestrictionsCount = 0;
            totalOpenNBBChildOpportunitiesCount = 0;
            totalCurrentChildRenewalOppCount = 0;
            totalActiveChildContractsCount = 0;
            totalActiveChildSubscriptionsCount = 0;
            totalSubscriptionsCount = 0;
            
            //Added By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
            objectNamesSet.add('OpenNBBChildOpportunity');
            objectNamesSet.add('CurrentChildRenewalOpportunities');
            objectNamesSet.add('ActiveChildContracts');
            objectNamesSet.add('ActiveChildSubscriptions');
            
            activateRelatedLists = false;
    
        }
    }
    
    // incrementally increase the number of records to display and refresh the list
    public void showMoreChildActivities() {
        NumChildActivitiesToDisplay += RECORD_15_LIMIT;
        childActivities = null;
    }
     
    //Set to hold the Open NBB Opportunity Ids
    Set<Id> setOpenNBBIds = new Set<Id>();
    
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    //Get all the NBB Opportunities
    public List<Opportunity> openNBBOpportunities {
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('Opportunity');
            
            //Setting flag values
            displayShowMoreForNBBOpportunity = true;
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //NBB Opportunities record total count
            totalNBBOpportunityCount = [Select count() FROM Opportunity 
                                        WHERE AccountId =: account.Id 
                                        AND (Type2__c = 'NBB' OR Type2__c = 'Initiating') 
                                        AND IsClosed = false
                                        AND RecordType.DeveloperName != 'Merged_Migrated'];
            
            //Checking list for null value
            if(openNBBOpportunities == null)
                openNBBOpportunities = new List<Opportunity>();
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //Querying Open NBB type Opportunities and populating list of records accordingly
            for(Opportunity openNBBOpp : [SELECT Id, Name, Marketer__c, Marketing_Associate__c, StageName, Next_Steps_Text__c,
                                            CloseDate, Next_PA_Date__c, Amount, Opportunity_Products__c, Main_Contact__c
                                            FROM Opportunity 
                                            WHERE AccountId =: account.Id 
                                            AND (Type2__c = 'NBB' OR Type2__c = 'Initiating')  
                                            AND IsClosed = false 
                                            AND RecordType.DeveloperName != 'Merged_Migrated'
                                            ORDER BY RecordType.DeveloperName ASC, StageName DESC LIMIT :RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setOpenNBBIds.contains(openNBBOpp.Id)) {
                    openNBBOpportunities.add(openNBBOpp); 
                    setOpenNBBIds.add(openNBBOpp.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(openNBBOpportunities.size() == 0)
                displayShowMoreForNBBOpportunity = false;
            
            if(totalNBBOpportunityCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalNBBOpportunityCount)
                    displayShowMoreForNBBOpportunity = false;
            }
                
            return openNBBOpportunities;
        }
        set;
    }
    
    //Set to hold the Open NBB Child Opportunity Ids
    Set<Id> setOpenNBBChildOpportunityIds = new Set<Id>();
     
    //Modified By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    //Get all the NBB Opportunities at child institutions
    public List<Opportunity> openNBBChildOpportunities {
    
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('OpenNBBChildOpportunity');
            
            //Setting flag values
            displayShowMoreForOpenNBBChildOpportunity = true;
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //Open NBB Child Opportunities record total count
            totalOpenNBBChildOpportunitiesCount = [Select count() FROM Opportunity WHERE AccountId  IN :childInstitutionIds AND (Type2__c = 'NBB' OR Type2__c = 'Initiating') AND IsClosed = false
                                                        AND RecordType.DeveloperName != 'Merged_Migrated'];
            
            //Checking list for null value
            if(openNBBChildOpportunities == null)
                openNBBChildOpportunities = new List<Opportunity>();
                
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //Querying child open NBB opportunities records associated to the account
            for(Opportunity openNBBChildOpp : [SELECT Id, Name, Marketer__c, Marketing_Associate__c, StageName, Next_Steps_Text__c,
                                                    CloseDate, Next_PA_Date__c, Amount
                                                    FROM Opportunity 
                                                    WHERE AccountId  IN :childInstitutionIds
                                                    AND (Type2__c = 'NBB' OR Type2__c = 'Initiating')
                                                    AND IsClosed = false 
                                                    AND RecordType.DeveloperName != 'Merged_Migrated' 
                                                    ORDER BY RecordType.DeveloperName ASC, StageName DESC LIMIT :RECORD_15_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setOpenNBBChildOpportunityIds.contains(openNBBChildOpp.Id)) {
                    openNBBChildOpportunities.add(openNBBChildOpp); 
                    setOpenNBBChildOpportunityIds.add(openNBBChildOpp.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(openNBBChildOpportunities.size() == 0)
                displayShowMoreForOpenNBBChildOpportunity = false;
            
            if(totalOpenNBBChildOpportunitiesCount > 0) {
                if((RECORD_15_LIMIT + offsetValue) >= totalOpenNBBChildOpportunitiesCount)
                    displayShowMoreForOpenNBBChildOpportunity = false;
            }
                
            return openNBBChildOpportunities;
        }
        set;
    }
    
    //Set to hold the Current Renewal Opportunity Ids
    Set<Id> setCurrentRenewalOpportunityIds = new Set<Id>();
    
    //Get all the Current Renewal Opportunities
    public List<Opportunity> currentRenewalOpportunities {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('CurrentRenewalOpportunity');
            
            //Setting flag values
            displayShowMoreForCurrentRenewalOpportunity = true;
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //NBB Opportunities record total count
            totalCurrentRenewalCount = [Select count() FROM Opportunity WHERE AccountId =: account.Id AND (Type2__c = 'Renewal' OR Type2__c = 'Continuing')
                                            AND (
                                                Pool_Date__c = THIS_YEAR 
                                                OR (Pool_Date__c >= TODAY AND Pool_Date__c <= NEXT_N_QUARTERS:2)
                                                OR (
                                                    IsClosed = false
                                                    AND Pool_Date__c <= NEXT_N_QUARTERS:4
                                                    AND Pool_Date__c >= TODAY
                                                )
                                                OR CloseDate >= TODAY
                                            )
                                            AND RecordType.DeveloperName != 'Merged_Migrated' 
                                        ];
            
            //Checking list for null value
            if(currentRenewalOpportunities == null)
                currentRenewalOpportunities = new List<Opportunity>();
            
            //Querying Current renewal opportunity records associated to the account
            for(Opportunity currentRenewalOpp : [Select Id, Name, OwnerId, Main_Contact__c, Pool_Date__c, Amount, Marketer__c,
                                                StageName, Next_PA_Date__c, Next_Steps_Text__c, Marketing_Associate__c, CloseDate, Probability, Opportunity_Products__c 
                                                FROM Opportunity where AccountId =: account.Id AND (Type2__c = 'Renewal' OR Type2__c = 'Continuing')
                                                                        AND (
                                                                            Pool_Date__c = THIS_YEAR 
                                                                            OR (Pool_Date__c >= TODAY AND Pool_Date__c <= NEXT_N_QUARTERS:2)
                                                                            OR (
                                                                                IsClosed = false
                                                                                AND Pool_Date__c <= NEXT_N_QUARTERS:4
                                                                                AND Pool_Date__c >= TODAY
                                                                            )
                                                                            OR CloseDate >= TODAY
                                                                        ) ORDER BY Pool_Date__c ASC LIMIT :RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setCurrentRenewalOpportunityIds.contains(currentRenewalOpp.Id)) {
                    currentRenewalOpportunities.add(currentRenewalOpp); 
                    setCurrentRenewalOpportunityIds.add(currentRenewalOpp.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(currentRenewalOpportunities.size() == 0)
                displayShowMoreForCurrentRenewalOpportunity = false;
            
            if(totalCurrentRenewalCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalCurrentRenewalCount)
                    displayShowMoreForCurrentRenewalOpportunity = false;
            }
                
            return currentRenewalOpportunities;
        }
        set;
    }
    
    //Set to hold the children Renewal opportunity record Ids
    Set<Id> setChildRenewalOppIds = new Set<Id>();
    
    //Modified By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    //Get all the Current Child Renewal Opportunities
    public List<Opportunity> currentChildRenewalOpportunities {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('CurrentChildRenewalOpportunities');
            
            //Setting flag values
            displayShowMoreForCurrentChildRenewalOpp = true;
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //Child Renewal Opportunities record total count
            totalCurrentChildRenewalOppCount = [Select count() FROM Opportunity WHERE AccountId IN: childInstitutionIds AND (Type2__c = 'Renewal' OR Type2__c = 'Continuing')
                                                    AND (
                                                        Pool_Date__c = THIS_YEAR 
                                                        OR (Pool_Date__c >= TODAY AND Pool_Date__c <= NEXT_N_QUARTERS:2)
                                                        OR (
                                                            IsClosed = false
                                                            AND Pool_Date__c <= NEXT_N_QUARTERS:4
                                                            AND Pool_Date__c >= TODAY
                                                        )
                                                    )
                                                    AND RecordType.DeveloperName != 'Merged_Migrated' 
                                                ];
            
            //Checking list for null value
            if(currentChildRenewalOpportunities == null)
                currentChildRenewalOpportunities = new List<Opportunity>();
            
            //Modified By- Subhash Garhwal - 07/10/2018 Added RecordType.DeveloperName != 'Merged_Migrated' check on SOQL query
            //Querying child renewal opportunities associated to the account
            for(Opportunity childRenewalOpp : [Select Id, Name, OwnerId, Main_Contact__c, Pool_Date__c, Amount, Marketer__c,
                                                        StageName, Next_PA_Date__c, Next_Steps_Text__c, Marketing_Associate__c, CloseDate, Probability 
                                                        FROM Opportunity where AccountId IN: childInstitutionIds AND (Type2__c = 'Renewal' OR Type2__c = 'Continuing') 
                                                                        AND (
                                                                            Pool_Date__c = THIS_YEAR 
                                                                            OR (Pool_Date__c >= TODAY AND Pool_Date__c <= NEXT_N_QUARTERS:2)
                                                                            OR (
                                                                                IsClosed = false
                                                                                AND Pool_Date__c <= NEXT_N_QUARTERS:4
                                                                                AND Pool_Date__c >= TODAY
                                                                            )
                                                                        )
                                                                        AND RecordType.DeveloperName != 'Merged_Migrated' 
                                                                        ORDER BY  RecordType.DeveloperName ASC, Pool_Date__c ASC LIMIT :RECORD_15_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setChildRenewalOppIds.contains(childRenewalOpp.Id)) {
                    currentChildRenewalOpportunities.add(childRenewalOpp); 
                    setChildRenewalOppIds.add(childRenewalOpp.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(currentChildRenewalOpportunities.size() == 0)
                displayShowMoreForCurrentChildRenewalOpp = false;
            
            
            if(totalCurrentChildRenewalOppCount > 0) {
                if((RECORD_15_LIMIT + offsetValue) >= totalCurrentChildRenewalOppCount)
                    displayShowMoreForCurrentChildRenewalOpp = false;
            }
                
            return currentChildRenewalOpportunities;
        }
        set;
    }
    
    //Set to hold the active children contract records Ids
    Set<Id> setActiveChildContractsIds = new Set<Id>();
    
    //Set to hold the active children subscription records Ids
    Set<Id> setActiveChildSubscriptionsIds = new Set<Id>();
    
    //Modified By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    // active contracts at child hospitals
    public list<Contract__c> activeChildContracts {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('ActiveChildContracts');
            
            //Setting flag values
            displayShowMoreForActiveChildContracts = true;
            
            //Child Renewal Opportunities record total count
            totalActiveChildContractsCount = [Select count() FROM Contract__c WHERE Payer_Account__c IN :childInstitutionIds AND Active__c = true];
            
            //Checking list for null value
            if(activeChildContracts == null)
                activeChildContracts = new List<Contract__c>();
            
            //Querying child contract records asscociated to the account
            for(Contract__c childContract : [SELECT Id, Negotiated_Amount__c, Active__c, Name, Start__c, End__c, 
                                                  Status__c, Annual_Contract_Value__c FROM Contract__c 
                                                  WHERE Payer_Account__c IN :childInstitutionIds AND Active__c = true
                                                  ORDER BY End__c DESC LIMIT :RECORD_15_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setActiveChildContractsIds.contains(childContract.Id)) {
                    activeChildContracts.add(childContract); 
                    setActiveChildContractsIds.add(childContract.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(activeChildContracts.size() == 0)
                displayShowMoreForActiveChildContracts = false;
            
            
            if(totalActiveChildContractsCount > 0) {
                if((RECORD_15_LIMIT + offsetValue) >= totalActiveChildContractsCount)
                    displayShowMoreForActiveChildContracts = false;
            }
                
            return activeChildContracts;
        }
        set;
    }
    
    // active subscriptions at child hospitals
    public list<SBQQ__Subscription__c> activeChildSubscriptions {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('ActiveChildSubscriptions');
            
            //Setting flag values
            displayShowMoreForActiveChildSubscriptions = true;
            
            //Child Renewal Opportunities record total count
            totalActiveChildSubscriptionsCount = [Select count() 
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Account__c IN :childInstitutionIds 
                                                        AND Active_Subscription__c = true
                                                        AND RecordType.DeveloperName = 'Program'];
            
            //Checking list for null value
            if(activeChildSubscriptions == null)
                activeChildSubscriptions = new List<SBQQ__Subscription__c>();
            
            //Querying child subscriptions records asscociated to the account
            for(SBQQ__Subscription__c childSubscription : [SELECT Id, Secured_Amount_Negotiated__c, Active_Subscription__c, Name, 
                                                            SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                                            Status__c, Annualized_Amount__c 
                                                            FROM SBQQ__Subscription__c 
                                                            WHERE SBQQ__Account__c IN :childInstitutionIds 
                                                            AND Active_Subscription__c = true
                                                            AND RecordType.DeveloperName = 'Program'
                                                            ORDER BY SBQQ__EndDate__c DESC 
                                                            LIMIT :RECORD_15_LIMIT OFFSET : offsetValue]) {
                                                            
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setActiveChildSubscriptionsIds.contains(childSubscription.Id)) {
                    activeChildSubscriptions.add(childSubscription); 
                    setActiveChildSubscriptionsIds.add(childSubscription.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(activeChildSubscriptions.size() == 0)
                displayShowMoreForActiveChildSubscriptions = false;
            
            
            if(totalActiveChildSubscriptionsCount > 0) {
                if((RECORD_15_LIMIT + offsetValue) >= totalActiveChildSubscriptionsCount)
                    displayShowMoreForActiveChildSubscriptions = false;
            }
                
            return activeChildSubscriptions;
        }
        set;
    }
    
    //Set to hold the active restriction records Id
    Set<Id> setActiveRestrictionsIds = new Set<Id>();
    
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    //Get all the Active Restriction
    public List<Restricted_MtM__c> activeRestrictions {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('ActiveRestriction');
                
            //Setting flag values
            displayShowMoreForActiveRestrictions = true;
                
            //Restriction Records total count
            totalActiveRestrictionsCount = [Select count() FROM Restricted_MtM__c WHERE Account__c =: account.Id AND Restriction_Status__c = 'Active'];
            
            //Checking list for null value
            if(activeRestrictions == null)
                activeRestrictions = new List<Restricted_MtM__c>();
                
            //Loop through eligible account role records and populatin
            for(Restricted_MtM__c restriction : [Select Restriction__c, Restriction_Subject__c, Restriction_Status__c, 
                                                    Restriction_Expiration_Date__c, Restriction_Owner__c from Restricted_MtM__c 
                                                    where Account__c =: account.Id AND Restriction_Status__c = 'Active' 
                                                    ORDER BY Restriction_Expiration_Date__c DESC LIMIT :RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setActiveRestrictionsIds.contains(restriction.Id)) {
                    activeRestrictions.add(restriction); 
                    setActiveRestrictionsIds.add(restriction.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(activeRestrictions.size() == 0)
                displayShowMoreForActiveRestrictions = false;
            
            if(totalActiveRestrictionsCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalActiveRestrictionsCount)
                    displayShowMoreForActiveRestrictions = false;
            }
                
            return activeRestrictions;
        }
        set;
    }
    
    //Commmented by Mahendra Swarnkar - 03/04/2020 - CR-20200217-13756 : US_Provider_System, US_Provider_Strategic, US_Provider
    // set of record type names that should be redirected to the custom VF page
    private set<string> recordTypesToRedirect {
      
      get {
            
            if (recordTypesToRedirect == null) {
                  
                  recordTypesToRedirect = new set<string> { /*'US_Provider_System', 'US_Provider', 'US_Provider_Strategic'*/ };
            }
            
            return recordTypesToRedirect;
      }
      set;
    }
    
    // create a map of <ProfileId, list<RecordTypeAPIName>> 
    // so we can determine which profiles/record types need to see the standard layout.
    private map<string, list<string>> accountStandardLayoutMap {
        
        get {
            
            if (accountStandardLayoutMap == null) {
                
                accountStandardLayoutMap = new map<string, list<string>>();
                
                //get the custom setting data for the current profile and create the map
                list<Account_Standard_Layouts__c> acctStandardLayouts = Account_Standard_Layouts__c.getall().values();
                for (Account_Standard_Layouts__c acctLayout : acctStandardLayouts) {
                    
                    if (accountStandardLayoutMap.containsKey(acctLayout.Profile_ID__c)) {
                        
                        // get the existing list of record types
                        list<string> recordTypeList = accountStandardLayoutMap.get(acctLayout.Profile_ID__c);
                        recordTypeList.add(acctLayout.Record_Type_API_Name__c);
                        accountStandardLayoutMap.put(acctLayout.Profile_ID__c, recordTypeList);
                    }
                    else {
                        
                        accountStandardLayoutMap.put(acctLayout.Profile_ID__c, new list<string> { acctLayout.Record_Type_API_Name__c });
                    }
                }
            }
            
            return accountStandardLayoutMap;
        }
        set;
    }
    
    private boolean showStandardLayout {
        
        get {
            
            if (showStandardLayout == null) {
                
                showStandardLayout = false;
                
                if (accountStandardLayoutMap.containsKey(UserInfo.getProfileId())) {
                    
                    for (string recordTypeAPIName : accountStandardLayoutMap.get(UserInfo.getProfileId())) {
                        
                        if (account.RecordType.DeveloperName.equalsIgnoreCase(recordTypeAPIName)) {
                            
                            showStandardLayout = true;
                            break;
                        }
                    }
                }
            }
            
            return showStandardLayout;
        }
        set;
    }
    
    //This method is to redicted the user on the appropriate page
    public PageReference redirectTo() {
        
        //Create a new Pagereference instance
        PageReference pageRef;
        
        //Check, wheather the redirect page is defined for user is defined for the same record type
        if (recordTypesToRedirect.contains(account.RecordType.DeveloperName) && !showStandardLayout) {
            
            pageRef = new PageReference('/apex/' + ACCT_VF_PAGE_NAME);
            pageRef.getParameters().put('id', account.Id);
            pageRef.setRedirect(true);
            
            //Redirect user on appropriate page
            return pageRef;
        }
        
        //else redirect user on standard page
        pageRef = new PageReference('/' + account.Id);
        pageRef.getParameters().put('nooverride', '1');
        
        return pageRef;
    }

    
    // get a set of all child institution ids
    private set<Id> childInstitutionIds {
        
        get {
            
            if (childInstitutionIds == null) {
                
                // query for all institutions with this account as the parent
                map<Id, Account> childAccounts = new map<Id, Account>([SELECT Id FROM Account 
                                                                        WHERE ParentId = :account.Id
                                                                        AND ParentId != null LIMIT :RECORD_LIMIT]);
                
                childInstitutionIds = childAccounts.keySet();
            }
            return childInstitutionIds;
        }
        
        set;
    }
    
    // get the total number of child activities -- this lets us know if we need to display the 'show more' link on the page
    public integer numChildActivities {
        get {
            
            if (numChildActivities == null || numChildActivities == 0) {
                
                numChildActivities = [SELECT Count() FROM Event WHERE AccountId IN :childInstitutionIds LIMIT 500];
                numChildActivities += [SELECT Count() FROM Task WHERE AccountId IN :childInstitutionIds LIMIT 500];
            }
            
            return numChildActivities;
            
        }
        set;
    }
    
    //Modified by Abhinav Sharma - CR-20140410-5043 - 05/21/2014
    // list of all open events and tasks for the child institutions associated with this parent
    public List<MembershipViewController.EventOrTask> childActivities {
        get {
            
            if (childActivities == null) {
                
                childActivities = new List<MembershipViewController.EventOrTask>();
                
                // also add any events associated with the Membership or Related Opps
                List<Event> openEvents = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name, 
                                          Event_Type__c, Owner.Name, What.Type, Status_F__c, recordType.Name
                                          FROM Event 
                                          WHERE AccountId IN :childInstitutionIds
                                          ORDER BY ActivityDate DESC LIMIT :NumChildActivitiesToDisplay];
                                          
                // add all of these events to our wrapper list
                for (Event evt : openEvents) {
                    childActivities.add(new MembershipViewController.EventOrTask(evt));
                }
                
                //Checking for the remaining count value going to be helpful in making decision about Task Query
                if((NumChildActivitiesToDisplay - openEvents.size()) > 0) {
                
                    Integer remainingCount = NumChildActivitiesToDisplay - openEvents.size(); 
                    
                    // check for open tasks as well
                    List<Task> openTasks = [SELECT Id, Subject, ActivityDate, WhoId, WhatId, OwnerId, What.Name, Who.Name,  
                                        Event_Type__c, Owner.Name, What.Type, Status_F__c, recordType.Name
                                        FROM Task 
                                        WHERE AccountId IN :childInstitutionIds
                                        ORDER BY ActivityDate DESC LIMIT :remainingCount];
                                        
                    // add all of these tasks to our wrapper list
                    for (Task tsk : openTasks) {
                        childActivities.add(new MembershipViewController.EventOrTask(tsk));
                    }
                }
                
                // sort the list of events/tasks
                childActivities.sort();
            }
            
            return childActivities;
        }
        set;
    }
    
    //Set to hold the Account Role records Ids
    Set<Id> setAccRolesIds = new Set<Id>();
            
    //Updated By Abhinav Sharma  - 03/19/2014 - CR-20140201-4431
    public list<Institution_Roles__c> accountRoles {
            
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('AccountRole');
            
            //Setting flag values
            displayShowMoreForAccountRoles = true;
            
            //Institution Records total count
            totalAccountRolesCount = [Select count() FROM Institution_Roles__c WHERE Institution__c =: account.Id];
            
            //Checking list for null value
            if(accountRoles == null)
                accountRoles = new List<Institution_Roles__c>();
                
            //Loop through eligible account role records and populatin
            for(Institution_Roles__c accRole : [Select Id, Name, Contact__c, ABC_Owner__c, 
                                                Last_Interaction__c, Next_Interaction__c, Assignment_Comment__c, 
                                                Contact_ABCO_Relationship__c FROM Institution_Roles__c 
                                                WHERE Institution__c =: account.Id              
                                                LIMIT :RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setAccRolesIds.contains(accRole.Id)) {
                    accountRoles.add(accRole); 
                    setAccRolesIds.add(accRole.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(accountRoles.size() == 0)
                displayShowMoreForAccountRoles = false;
            
            if(totalAccountRolesCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalAccountRolesCount)
                    displayShowMoreForAccountRoles = false;
            }
                
            return accountRoles;
        }
        set;
    }
    
    //Set to hold the membership records Id
    Set<Id> setMembershipIds = new Set<Id>();
    
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    public list<Membership__c> memberships {
        
        get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('Membership');
            
            //Setting flag values
            displayShowMoreForMemberships = true;
            
            //Memberships record total count
            totalMembershipsCount = [SELECT count() FROM Membership__c WHERE Account_Name__c =: account.Id AND Membership_Status__c LIKE 'Member%'];
                                    
            //Checking list for null value
            if(memberships == null)
                memberships = new List<Membership__c>();
            
            //Loop through eligible account role records and populatin
            for(Membership__c member : [SELECT Id, Name, Program__r.Name, Membership_Status__c, Renewal_Opp_Owner__c, End_Date_On_Last_Contract__c 
                                    FROM Membership__c WHERE Account_Name__c =: account.Id AND Membership_Status__c LIKE 'Member%' 
                                    ORDER BY Renewal_Opp_Owner__c ASC LIMIT : RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setMembershipIds.contains(member.Id)) {
                    memberships.add(member); 
                    setMembershipIds.add(member.Id);
                }                                  
            }
            
            //Setting flag values on the basis of results
            if(memberships.size() == 0)
                displayShowMoreForMemberships = false;
            
            if(totalMembershipsCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalMembershipsCount)
                    displayShowMoreForMemberships = false;
            }
                
            return memberships;
        }
        set;
    }
    
    //Set to hold the Contract ABC records Id
    Set<Id> setContractABCs = new Set<Id>();
    
    //Updated By Abhinav Sharma  - 03/18/2014 - CR-20140201-4431
    public list<Contract__c> contractABCs {
        
       get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('ContractABC');
                    
            //Setting flag values
            displayShowMoreForContractABCs = true;
            
            //Active Contract record total count
            totalContractABCsCount = [SELECT count() FROM Contract__c WHERE Payer_Account__c =: account.Id AND Active__c = true];
                                    
            //Checking list for null value
            if(contractABCs == null)
                contractABCs = new List<Contract__c>();
                
            //Loop through eligible account role records and populatin
            for(Contract__c contract : [SELECT Id, Negotiated_Amount__c, Active__c, Name, Start__c, End__c, Status__c, Annual_Contract_Value__c 
                                            FROM Contract__c WHERE Payer_Account__c =: account.Id AND Active__c = true 
                                            ORDER BY End__c ASC LIMIT : RECORD_LIMIT OFFSET : offsetValue]) {
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setContractABCs.contains(contract.Id)) {
                    contractABCs.add(contract); 
                    setContractABCs.add(contract.Id);
                }                                  
            }
               
            //Setting flag values on the basis of results
            if(contractABCs.size() == 0)
                displayShowMoreForContractABCs = false;
            
            if(totalContractABCsCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalContractABCsCount)
                    displayShowMoreForContractABCs = false;
            }
                
            return contractABCs;
        }
        set;
    }
    
    //Set to hold the Subscription records Id
    Set<Id> setSubscriptions = new Set<Id>();
    
    //Subscriptions
    public list<SBQQ__Subscription__c> subscriptions {
        
       get {
            
            //Getting Offset value from the map
            Integer offsetValue = mapObjectWithOffset.get('Subscription');
                    
            //Setting flag values
            displayShowMoreForSubscriptions = true;
            
            //Subscription record total count
            totalSubscriptionsCount = [SELECT count() FROM SBQQ__Subscription__c 
                                            WHERE SBQQ__Account__c =: account.Id 
                                                AND Active_Subscription__c = true
                                                AND RecordType.DeveloperName = 'Program'];
                                    
            //Checking list for null value
            if(subscriptions == null)
                subscriptions = new List<SBQQ__Subscription__c>();
              
            //Loop through subscription records
            for(SBQQ__Subscription__c sub : [SELECT Id, Secured_Amount_Negotiated__c, Active_Subscription__c, Name, 
                                                    SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                                    Status__c, Annualized_Amount__c 
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Account__c =: account.Id 
                                                        AND Active_Subscription__c = true
                                                        AND RecordType.DeveloperName = 'Program'
                                                        ORDER BY SBQQ__EndDate__c ASC 
                                                        LIMIT : RECORD_LIMIT OFFSET : offsetValue]) {
                                                            
                //Adding record into the list if and only if that was not added in prior to the same list
                if(!setSubscriptions.contains(sub.Id)) {
                    subscriptions.add(sub); 
                    setSubscriptions.add(sub.Id);
                }                                  
            }
               
            //Setting flag values on the basis of results
            if(subscriptions.size() == 0)
                displayShowMoreForSubscriptions = false;
            
            if(totalSubscriptionsCount > 0) {
                if((RECORD_LIMIT + offsetValue) >= totalSubscriptionsCount)
                    displayShowMoreForSubscriptions = false;
            }
                
            return subscriptions;
        }
        set;
    }
    
    //Modified By - Abhinav Sharma - CR-20140410-5043 - 05/21/2014
    //Added By Abhinav Sharma - 03/18/2014 - CR-20140201-4431
    /**
     *  @description    :   Method to retrieve out some additional records when user clicks on "Show More" button.
     *
     *  @args           :    
     *
     *  @return         :   void
     *
    **/
    public void showMoreRecords() {
        Integer incrementedOffset = 0;
        if(mapObjectWithOffset.get(object_Name) != null) { 
            //Checking for the Object Name string
            if(objectNamesSet.contains(object_Name)) {
                incrementedOffset = mapObjectWithOffset.get(object_Name) + RECORD_15_LIMIT; 
                mapObjectWithOffset.put(object_Name, incrementedOffset);
            } else {
            
                incrementedOffset = mapObjectWithOffset.get(object_Name) + RECORD_LIMIT; 
                mapObjectWithOffset.put(object_Name, incrementedOffset);
            }
        }
    }
}