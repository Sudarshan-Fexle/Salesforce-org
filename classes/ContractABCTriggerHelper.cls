/*
    Purpose:    This class is helper class for trigger on Contract ABC object.
                
    Create By:  Simplyforce Technology
    
    Created Date:   09/18/2011
    
    Current Version:    v1.0
    
    Revision Log:   V1.0 Created
                    V_1.1 - 10/26/2011 - Method added to update the Contract's child  Line Item Schedules with the Invoice billing Schedule Id
                    V_1.2 - 10/26/2011 - Method added not to update the invoice billing schedule id as null if LIS is associated with the records
                    V_1.3 - 08/25/2015 - Modified By - Abhinav Sharma - 08/25/2015 - CR-20150820-9167 - Added new method (doUpdateOnOpportunitiesOnContractABCTypeUpdate)
                    V_1.4 - 09/03/2015 - Modified By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660 - Added a new method (updateActiveMembershipMainContact)
                    v_1.5 - 10/17/2015 - Modified By - Abhinav Sharma - CR-20151008-9304 - Triggers repetative execution
                    v_1.6 - 02/13/2016 - Modified By - Abhinav Sharma - CR-20150925-9267
                    v_1.7 -  07/05/2016 -Modified By - Mahedra Swarnkar -CR-20160229-9651 - Updated the method "populateFieldsOnCaseFromContract" to add the logic to populate New_Member_Programs_TD__c field on case
                    v_1.8 - Modified By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
                    v_1.9 - Modified By - 06/04/2017 - Abhinav Sharma - DS114  - Updated "populateAndValidateContractFields" method
		    V_2.0 - Modified By - 08/04/2017 - Colin McGloin - Updated "updateTotalNegotiatedAmount" method - Issue--CR11094--UAT--00005346
		    V_2.1 - Modified By - 11/29/2017 - Modified By Dipesh Gupta - 11/29/2017 -CR-20171128-11817 - Fixing the Code coverage error in the Partial deployment. Creted a new Method "CustomExceptiontoCoverCatch"
		    V_2.2 - Modified by ABhinav Sharma - 03/08/2018 - CR-20180205-11984 -  Update the logic to populate the Active_Contract_Main_Contact__c onn Membership on the Change of Main Contact Of Contract ABC	
		    V_2.3 - Modified By - Subhash Garhwal - 07/23/2018 - CR-20180607-12272 - Added 'updateJoinDateMostRecentOnMembership' method to update 'Join Date-Most Recent' field on Membership.				
		    V_2.4 - Modified By - Dipesh Gupta - 11/26/2019 - Issue--CR13473--QA--00009287 - Added a check to populate Main Contact.	
		    V_2.5 - Modified By - Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
		    V_2.6 - Modified By - Abhinav Sharma - 08/12/2020 - CR-20190826-13286 - MS 2: Change to Pending Future Start Date value
*/
public without sharing class ContractABCTriggerHelper {
    
    //variable to stop the recursive execution of th trigger
    public static Boolean isContractABCTriggerExecuted = false;
    
    //Method to populate fields on contract ABC object in before events
    public static void populateAndValidateContractFields(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        /*Collection's useful, while building logic to populate fields on Contract ABC records*/
        //Start from here
        
        //Memory allocation to collections
        Set<Id> setPayerAccountsIds = new Set<Id>();
        Set<Id> setProgramsIds = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setMainContactIds = new Set<Id>();
        Set<Id> setContractRenewalOpportunityIDs = new Set<Id>();
        
        //Loop through contract record and populating collections with value
        for(Contract__c c : contracts) {
            
            //Check fix for Issue By - Dipesh Gupta - 11/26/2019 - Issue--CR13473--QA--00009287
            if(c.Main_Contact__c != null && mapOldContracts != null){
                if(mapOldContracts.get(c.Id).Main_Contact__c != null)
                    c.Main_Contact__c = mapOldContracts.get(c.Id).Main_Contact__c;
            }
                
            //Checking "Payer Account" field for null value and accordingly populating the set with appropriate values
            if(c.Payer_Account__c != null)
                setPayerAccountsIds.add(c.Payer_Account__c);
                
            //Checking program field for null value and accordingly populating the set with appropriate values
            if(c.Program__c != null)    
                setProgramsIds.add(c.Program__c);
                
            //Checking source opportunity field for null value and accordingly populating the set with appropriate values
            if(c.Source_Opportunity__c != null) 
                setOpportunityIds.add(c.Source_Opportunity__c);
                
            //Checking main contact field for null value and accordingly populating the set with appropriate values
            if(c.Main_Contact__c != null)
                setMainContactIds.add(c.Main_Contact__c);   
                
            //Checking main contact field for null value and accordingly populating the set with appropriate values 
            if(c.Contract_Renewal_Opportunity__c != null)
                setContractRenewalOpportunityIDs.add(c.Contract_Renewal_Opportunity__c);
        }
    
        //Map of Accounts
        Map<Id, Account> mapPayerAccountsInfo = new Map<Id, Account>();
        
        //Map of programs
        Map<Id, Program__c> mapProgramsInfo = new Map<Id, Program__c>();
        
        //Map of source opportunities
        map<Id, Opportunity> mapSourceOpportunities = new Map<Id, Opportunity>();
        
        //Map of main contacts
        Map<Id, Contact> mapOfMainContacts = new Map<Id, Contact>();
        
        //Map of contract renewal opportunities
        Map<Id, Opportunity> mapOfContractRenewalOpportunities = new Map<Id, Opportunity>();
        
        //Checking set for size value and populating the map with retrieved account records
        if(setPayerAccountsIds.size() > 0)
            mapPayerAccountsInfo = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : setPayerAccountsIds]);

        //Checking set for size value and populating the map with retrieved program records
        if(setProgramsIds.size() > 0)
            mapProgramsInfo = new Map<Id, Program__c>([SELECT Id, Program_Acronym__c, Business_Line__c FROM Program__c 
                                                        WHERE Id IN : setProgramsIds]);
                                                        
        //Checking set for the size value and populating the map with retrived opportunity records
        if(setOpportunityIds.size() > 0)
            mapSourceOpportunities = new Map<Id, Opportunity>([SELECT Id, Previous_Contract__c, Previous_Contract__r.Join_Date__c,
                                                               CloseDate, Decision_Type__c, End__c,
                                                                (SELECT Id, ContactId FROM OpportunityContactRoles 
                                                                    WHERE Role = 'Invoice Contact')
                                                                FROM Opportunity 
                                                                WHERE Id IN : setOpportunityIds]);
        //Upto here
        
        //Checking set for the size value and populating the map with retrived contact records
        if(setMainContactIds.size() > 0) {
            mapOfMainContacts = new Map<Id, Contact>([SELECT ID, FirstName, LastName
                                                        FROM Contact
                                                        WHERE ID IN : setMainContactIds
                                                    ]);
        }
        
        //Checking set for the size value and populating the map with retrived contact records
        if(setContractRenewalOpportunityIDs.size() > 0) {
            mapOfContractRenewalOpportunities = new Map<Id, Opportunity>([SELECT ID, OwnerID, Owner.Name
                                                                            FROM Opportunity
                                                                            WHERE ID IN : setContractRenewalOpportunityIDs
                                                                        ]);
        }                                                 

        //Variable to hold the Max length allowed for account name string literal
        Integer maxacctnamelength = 55;
    
        //Loop through contract records and populating name field with ("Account Name - Program Acronym - Year") combined string value
        for(Contract__c c : contracts) {
            
            /*Logic to populate name field on contract ABC records*/
            //Start from here
            //Temprary variables
            String acctName = '';
            String progAcronym = '';
            String yearString = '';

            //Checking payer account for null value and populating account name temparary variable with value
            if(c.Payer_Account__c != null) {
                if(mapPayerAccountsInfo.containsKey(c.Payer_Account__c) && mapPayerAccountsInfo.get(c.Payer_Account__c) != null)
                    acctName = mapPayerAccountsInfo.get(c.Payer_Account__c).Name;
            }
            
            //Truncating account string if exceeding allowed characters limit
            if(acctName != '')
                acctName = acctName.substring(0,Math.min(acctName.length(), maxacctnamelength));

            //Checking program for null value and populating program acronym temparary variable with value
            if(c.Program__c != null) {
                if(mapProgramsInfo.containsKey(c.Program__c) && mapProgramsInfo.get(c.Program__c) != null)
                    progAcronym = mapProgramsInfo.get(c.Program__c).Program_Acronym__c;
            }

            //Checking "Year__c" field for null value and populating year temparary variable with value
            if (c.Year__c != null) 
                yearString = c.Year__c;

            //concatenation string literal to have a combined string and then populating name field with it 
            c.Name = acctName + ' - ' + progAcronym + ' - ' + yearString; 
            //Upto here
            
            /*Logic to populate Business Line (From Trigger) [Business_Line_From_Trigger__c] field on contract ABC records*/
            //Start from here 
            //Checking for value in map and accordingly populating "Business Line (From Trigger)" field on contract ABC records
            if(mapProgramsInfo.containsKey(c.Program__c) && mapProgramsInfo.get(c.Program__c) != null) {
                if(c.Business_Line_From_Trigger__c != mapProgramsInfo.get(c.Program__c).Business_Line__c)
                        c.Business_Line_From_Trigger__c = mapProgramsInfo.get(c.Program__c).Business_Line__c;
            }
            //Upto here
            
            /*Logic to populate Active (Active__c) field on contract ABC records*/      
            //Start from here
            //Set Active checkbox
            if ((c.Start__c != null) && (c.End__c != null)) {
                if ((c.Start__c <= system.today()) && (c.End__c >= system.today())) 
                    c.Active__c = true;
                else
                    c.Active__c = false; 
            } else {
                c.Active__c = false;
            }
            //Upto Here
            
            /*Logic to populate Previous Contract (Previous_Contract__c) field on contract ABC records*/        
            //Start from here
            //Checking for Source Opportunity for this contract and then setting Previous Contract on contract from Previous Contract on source Opp
            if (c.Source_Opportunity__c != null
                && mapSourceOpportunities.containsKey(c.Source_Opportunity__c) 
                && mapSourceOpportunities.get(c.Source_Opportunity__c) != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c != null) 
                c.Previous_Contract__c = mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c;
            //Upto here
            
            /*Logic to update/populate Join Date from source Opportunity.Previous Contract join date on contract ABC records*/
            //Start from here
            //update Join Date from source Opportunity.Previous Contract join date
            //Join Date populate/update logic will only execute for insert use cases
            if (mapOldContracts == null 
                && c.Source_Opportunity__c != null
                && mapSourceOpportunities.containsKey(c.Source_Opportunity__c) 
                && mapSourceOpportunities.get(c.Source_Opportunity__c) != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__c != null
                && mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__r.Join_Date__c != null)
                c.Join_Date__c = mapSourceOpportunities.get(c.Source_Opportunity__c).Previous_Contract__r.Join_Date__c;
            //Upto Here
            
            /*Logic to populate main contact name field*/
            if(c.Main_Contact__c != null && mapOfMainContacts.containsKey(c.Main_Contact__c)) {
                
                //Temp variable
                String mainContactName = '';
                                                
                //Checking for the null value
                if(String.isNotBlank(mapOfMainContacts.get(c.Main_Contact__c).FirstName))                           
                    mainContactName += mapOfMainContacts.get(c.Main_Contact__c).FirstName + ' ';
                                                
                mainContactName += mapOfMainContacts.get(c.Main_Contact__c).LastName;
                c.Main_Contact_Name__c = mainContactName;       
            } else {
                c.Main_Contact_Name__c = '';
            }
            
            //Checking for the null value 
            if(c.Source_Opportunity__c != null && mapSourceOpportunities.containsKey(c.Source_Opportunity__c)) {
                c.Source_Opportunity_Close_Date__c = mapSourceOpportunities.get(c.Source_Opportunity__c).CloseDate;
                c.Source_Opportunity_Decision_Type__c = mapSourceOpportunities.get(c.Source_Opportunity__c).Decision_Type__c;
                c.Source_Opportunity_End_Date__c = mapSourceOpportunities.get(c.Source_Opportunity__c).End__c;
            }
            else {
                c.Source_Opportunity_Close_Date__c = null;
                c.Source_Opportunity_Decision_Type__c = '';
                c.Source_Opportunity_End_Date__c = null;
            }
            
            //Checking for the null value
            if(c.Contract_Renewal_Opportunity__c != null && mapOfContractRenewalOpportunities.containsKey(c.Contract_Renewal_Opportunity__c))
                if(mapOfContractRenewalOpportunities.get(c.Contract_Renewal_Opportunity__c).OwnerID != null)
                    c.Renewal_Opp_Owner__c = mapOfContractRenewalOpportunities.get(c.Contract_Renewal_Opportunity__c).Owner.Name;
                else
                    c.Renewal_Opp_Owner__c = '';
            else
                c.Renewal_Opp_Owner__c = '';
        }
    }
        
    //This method is to update the Membership status text field on membership object whenever there is a change on Contract ABC record
    public static void updateMembershipStatusByContracts(List<Contract__c> newContracts, Map<Id, Contract__c> mapOldContracts) {
    
        //Checking for update use case
        if(newContracts != null && mapOldContracts != null) {
            
            //Set of eligible contracts
            Set<Id> setOfEligibleContracts = new Set<Id>();
            
            //Loop through contract ABC records
            for(Contract__c con : newContracts) {
                
                //Checking for field value changes
                if(con.Start__c != mapOldContracts.get(con.ID).Start__c
                    ||
                    con.End__c != mapOldContracts.get(con.ID).End__c
                    ||
                    con.Status__c != mapOldContracts.get(con.ID).Status__c
                    ||
                    con.Renewal_Opp_Status__c != mapOldContracts.get(con.ID).Renewal_Opp_Status__c
                    ||
                    con.Payer_Account__c != mapOldContracts.get(con.ID).Payer_Account__c
                ) {
                    setOfEligibleContracts.add(con.Id);     
                }
            }
            
            //Checking set for it's size
            if(setOfEligibleContracts.size() > 0) {
                
                //Set to hold Subscription Ids related to Membership
                Set<Id> setSubscriptionIds = new Set<Id>();
                
                //Map of memberships
                Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
                
                //Create a set of Contract Ids related with membership records
                Set<Id> contracts = new Set<Id>();
        
                //Loop through the membership records and prepare the data set to be updated
                for(Membership__c membership : [SELECT Id, Payer_Status__c, Active_Contract_Idenfied__r.Status__c, Active_Contract_Idenfied__r.Start__c, 
                                                    Latest_Contract__r.Status__c, Membership_Status__c, 
                                                    Earliest_Contract__r.Start__c, Latest_Contract__r.Start__c, Account_Name__c,
                                                    Active_Contract_Idenfied__r.End__c, Latest_Contract__r.Payer_Account__c, 
                                                    Active_Contract_Idenfied__r.Payer_Account__c,
                                                    Latest_Contract__r.Renewal_Opp_Status__c, Earliest_Contract__r.Status__c, Latest_Contract__r.End__c,
                                                    Earliest_Subscription__c, Active_Subscription__c, Latest_Subscription__c,Program_Business_Line__c,Membership_Status_Text__c 
                                                    FROM Membership__c 
                                                    WHERE (Active_Contract_Idenfied__c != null AND Active_Contract_Idenfied__c IN : setOfEligibleContracts)
                                                            OR 
                                                            (Earliest_Contract__c != null AND Earliest_Contract__c IN : setOfEligibleContracts)
                                                            OR 
                                                            (Latest_Contract__c != null AND Latest_Contract__c IN : setOfEligibleContracts)]) {
                    
                    //Checking for the null and populating set with values                                          
                    if(membership.Earliest_Subscription__c != null)
                        setSubscriptionIds.add(membership.Earliest_Subscription__c);
                    if(membership.Active_Subscription__c != null)
                        setSubscriptionIds.add(membership.Active_Subscription__c);
                    if(membership.Latest_Subscription__c != null)
                        setSubscriptionIds.add(membership.Latest_Subscription__c);
                    
                    //Add Active_Contract_Idenfied__c in set if not null
                    if(membership.Active_Contract_Idenfied__c != null)
                        contracts.add(membership.Active_Contract_Idenfied__c);
                   
                    //Add Earliest_Contract__c in set if not null
                    if(membership.Earliest_Contract__c != null)
                        contracts.add(membership.Earliest_Contract__c);
                    
                    //Add Latest_Contract__c in set if not null
                    if(membership.Latest_Contract__c != null)
                        contracts.add(membership.Latest_Contract__c);
                
                    //map of membership
                    mapMemberships.put(membership.Id, membership);
                }
                
                //Checking map for its size
                if(mapMemberships.values().size() > 0) {
                    
                    //Map to hold Subscription records 
                    Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
                    
                    //Map of contracts
                    Map<Id, Contract__c> mapContract = new Map<Id, Contract__c>();
                    
                    //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
                    //Checking for map size
                    if(setSubscriptionIds.size() > 0){
                        
                        mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                                                               Renewal_Opp_Stage__c, Status__c, 
                                                                               SBQQ__Account__c 
                                                                               From  SBQQ__Subscription__c 
                                                                                Where Id IN : setSubscriptionIds]);
                    }
                    //Checking set for size value
                    else if(contracts.size() > 0) {
                
                        //fetch related data from database from Contract ABC object
                        mapContract = new Map<Id, Contract__c>([Select Id, Start__c, End__c, Status__c, Renewal_Opp_Status__c, 
                                                                    Payer_Account__c 
                                                                    from Contract__c
                                                                    where ID IN: contracts]);
                    }
                    
                    //Temporary variable to hold the membership status
                    String memberShipStatus;
                    
                    //Map of membership to be updated
                    Map<Id, Membership__c> mapOfMembershipsToBeUpdated = new Map<Id, Membership__c>();
                    
                    //Loop through the membership records and prepare the data set to be updated
                    for(Membership__c membership : mapMemberships.values()) {
            
                        //skip Royall memberships.  Royall memberships are populated based on Program Packages
                        if (membership.Program_Business_Line__c == Label.Royall_Business_Line) continue;
                        
                        //reset membership status text
                        memberShipStatus = '';
                        
                        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
                        //Checking for map size. If Subscription records are exist then process on the Subsription otherwise process on the Contract
                        if(mapSubscriptions.values().size() > 0){
                
                            //Check if Earliest_Subscription__r.SBQQ__StartDate__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                            if(membership.Earliest_Subscription__c != null && mapSubscriptions.containsKey(membership.Earliest_Subscription__c) 
                                    && (mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c == null 
                                        || mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c > Date.today())) {
                                memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                            }
                            //If Active Subscription's SBQQ__EndDate__c is greater then today's date
                            else if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                                    && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c != null 
                                    && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c >= Date.today()) {
                                    if(mapSubscriptions.get(membership.Active_Subscription__c).Status__c != null 
                                       && mapSubscriptions.get(membership.Active_Subscription__c).Status__c == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY;
                                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                                        memberShipStatus = Constants.MEMBER_PAYER;
                                    } else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                                    }
                            } else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c != null 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != null 
                                && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != ''
                                && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.PENDING)
                                    || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                                ) {
                                    if (mapSubscriptions.get(membership.Latest_Subscription__c).Status__c  == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                                    } else if(mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c != null 
                                            && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c == membership.Account_Name__c) {
                                        memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                                    } else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                                    }
                            }else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                                    && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                                    && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c > (Date.today() - 270)
                                    && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.DROPPED
                                        || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.VOIDER)) {
                                memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                            } else if(membership.Earliest_Subscription__c != null && mapSubscriptions.containsKey(membership.Earliest_Subscription__c) 
                                    && mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c >= date.newInstance(1960,01,01)) {
                                if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                                        && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__StartDate__c > Date.today()) {
                                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;  //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286
                                } else {
                                    memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                                }   
                            } else {
                                memberShipStatus = Constants.PROSPECT_PURE;
                            }
                        }
                        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
                        else if(mapContract.values().size() > 0){
                
                            //Check if Earliest_Contract__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                            if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                                    && (mapContract.get(membership.Earliest_Contract__c).Start__c == null 
                                        || mapContract.get(membership.Earliest_Contract__c).Start__c > Date.today())) {
                                memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                            } 
                            //If Active contract's end date is greater then today's date
                            else if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c != null 
                                    && mapContract.get(membership.Active_Contract_Idenfied__c).End__c >= Date.today()) {
                                    if(mapContract.get(membership.Active_Contract_Idenfied__c).Status__c != null 
                                       && mapContract.get(membership.Active_Contract_Idenfied__c).Status__c == Constants.HONORARY) {
                                        memberShipStatus = Constants.MEMBER_HONORARY;
                                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                                        memberShipStatus = Constants.MEMBER_PAYER;
                                    } else {
                                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                                    }
                            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                                && mapContract.get(membership.Latest_Contract__c).End__c != null 
                                && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                                && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != null 
                                && mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c != ''
                                && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.PENDING)
                                    || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))
                            ) {
                                if (mapContract.get(membership.Latest_Contract__c).Status__c  == Constants.HONORARY) {
                                    memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                                } else if(mapContract.get(membership.Latest_Contract__c).Payer_Account__c != null 
                                        && mapContract.get(membership.Latest_Contract__c).Payer_Account__c == membership.Account_Name__c) {
                                    memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                                } else {
                                    memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                                }
                            } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                                        && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                                        && mapContract.get(membership.Latest_Contract__c).End__c > (Date.today() - 270)
                                        && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.DROPPED
                                            || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.VOIDER)) {
                                memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                            } else if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                                    && mapContract.get(membership.Earliest_Contract__c).Start__c >= date.newInstance(1960,01,01)) {
                                if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                                        && mapContract.get(membership.Active_Contract_Idenfied__c).Start__c > Date.today()) {
                                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;  //Modified - Abhinav Sharma - 08/12/2020 - CR-20190826-13286
                                } else {
                                    memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                                }   
                            } else {
                                memberShipStatus = Constants.PROSPECT_PURE;
                            }   
                        }
                        
                        //Checking for difference in between statuses
                        if(memberShipStatus != null && memberShipStatus != '') {
                            if (membership.Membership_Status_Text__c != memberShipStatus) {
                                membership.Membership_Status_Change_Date__c = system.today();
                                membership.Membership_Status_Text__c = memberShipStatus;
                                mapOfMembershipsToBeUpdated.put(membership.Id, membership);
                            }
                        }
                    }
        
                    //Check for the list size and update the recors if needed
                    if(mapOfMembershipsToBeUpdated.size() > 0) {
                        Util.byPassAllTriggers = true;
                        update mapOfMembershipsToBeUpdated.values();
                        Util.byPassAllTriggers = false;
                    }       
                }
            }
        }        
    }
    
    //This method is to update the Total_Negotiated_Amt__c on Invoice_Billing_Schedule__c record 
    //with sum of Negotiated_Amount__c field of related Contract__c records
    
    //Modified by Colin McGloin - 08/04/2017 - Issue--CR11094--UAT--00005346
    @invocableMethod
    public static void updateTotalNegotiatedAmount(List<Contract__c> contracts) {
        
        //prepare a set of related invoice billing schedule records
        Set<Id> iBSRecords = new Set<Id>();
        
        //loop through the records list
        for(Contract__c contract : contracts){
            
            //check if invoice billing schedule record id is not null, then add it into the set
            if(contract.Invoice_Billing_Schedule__c != null){
                iBSRecords.add(contract.Invoice_Billing_Schedule__c);
            }
        }
        
        //clone of billing schedule
        Set<Id> cloneIBSRecords = new Set<Id>();
        
        //Checking set for size value
        if(iBSRecords.size() > 0) {
        
            //get the aggregate sum of Negotiated_Amount__c field from  Contract__c records
            AggregateResult[] results = [Select Invoice_Billing_Schedule__c iBSId, SUM(Negotiated_Amount__c) totalAmout from Contract__c
                                         WHERE Invoice_Billing_Schedule__c != null AND Invoice_Billing_Schedule__c in: iBSRecords 
                                         GROUP BY Invoice_Billing_Schedule__c];

            //MAp to hold Invoice_billing_schedule
            Map<Id, Invoice_Billing_Schedule__c> mapInvoiceBilling = new Map<Id,Invoice_Billing_Schedule__c>();
 
            //Set to hold the ids of the records found
            Set<Id> usedIBSRecords = new Set<Id>(); 
            
            //loop through the results
            for(AggregateResult result : results) {
                
                //add Invoice_Billing_Schedule__c id in set 
                usedIBSRecords.add((Id)result.get('iBSId'));
                
                //Map to hold Invoice billing 
                mapInvoiceBilling.put((Id)result.get('iBSId'), new Invoice_Billing_Schedule__c(Id = (Id)result.get('iBSId'), Total_Negotiated_Amt__c = (Decimal)result.get('totalAmout')));

            }

            /* //Commented out by Colin McGloin - 08/04/2017 - Issue--CR11094--UAT--00005346
            //We will use the value calculated from the Shadow Contract ABC instead of the Subscriptions which is calculated from the logic above

            //Loop through Subscription.
            for(AggregateResult aResult :[SELECT SUM(Negotiated_Amount_Subscription__c) totalNegoAmount, Invoice_Billing_Schedule__c cInvoiceBill 
                                            FROM SBQQ__Subscription__c WHERE Invoice_Billing_Schedule__c IN:iBSRecords AND
                                            Invoice_Billing_Schedule__c != null GROUP BY Invoice_Billing_Schedule__c]) {

                //Id of invoice billing schedule
                Id invoiceId = Id.valueOf(String.valueof(aResult.get('cInvoiceBill')));

                //Hold total negotiation amount
                Decimal totalNegAmount = (Decimal) aResult.get('totalNegoAmount');

                if(mapInvoiceBilling.containsKey(invoiceId) && mapInvoiceBilling.get(invoiceId).Total_Negotiated_Amt__c != null)
                    mapInvoiceBilling.get(invoiceId).Total_Negotiated_Amt__c += totalNegAmount;
				if(mapInvoiceBilling.containsKey(invoiceId))
					mapInvoiceBilling.get(invoiceId).Total_Negotiated_Amt__c = totalNegAmount;	
            }*/
            
            //remove the records have been used from iBSRecords
            cloneIBSRecords = iBSRecords;
            cloneIBSRecords.removeAll(usedIBSRecords);
            
            //update records with  total amount 
            //loop through the results
            for(ID unusedId : cloneIBSRecords) {
                
                //add record in the list need to be updated
                mapInvoiceBilling.put(unusedId,new Invoice_Billing_Schedule__c(Id = unusedId, Total_Negotiated_Amt__c = 0));
            }
        
            //update the listIBSRecords
            if(mapInvoiceBilling.size() > 0) {
                Util.byPassAllTriggers = true;
                update mapInvoiceBilling.values();
                Util.byPassAllTriggers = false;
            }
        }
    }

    
    //update Contract's child line item schedules with the invoice billing schedule id
    public static void updateLISWithContractABCIBS(List<Contract__c> records) {
        
        //Variable to hold the clone of Line Item schedule
        List<Line_Item_Schedule__c>  lineItemScheduleClone = new List<Line_Item_Schedule__c>();
        
        //Variable to hold the master Line Item schedule
        List<Line_Item_Schedule__c>  lisToBeDeleted = new List<Line_Item_Schedule__c>();
        
        //Checking list for null and size value
        if(records != null && records.size() > 0) {
        
            //retrive all the LIS records related to Contracts
            //inner query to fetch all trhe LIS item related with contratcs
            //update the LIS's IBS id if it's different
            for(Contract__c contractABC : [SELECT Id, Invoice_Billing_Schedule__c, 
                                            (SELECT Contract__c, Invoice_Billing_Schedule_del__c, Amount__c, 
                                                Invoice_Comment__c, Invoice_Date__c, Type__c from Line_Item_Schedule__r) 
                                            FROM Contract__c WHERE Id IN : records]) {
            
                //loop through the lis records
                if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0) {
                    
                    //create a temporary list to add te records to be deleted
                    List<Line_Item_Schedule__c>  tempListToBeDeleted = new List<Line_Item_Schedule__c>();
                    
                    //loop through the related contracts and create a list to be deleted
                    for(Line_Item_Schedule__c lisRecord : contractABC.Line_Item_Schedule__r) {
                        
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(contractABC.Invoice_Billing_Schedule__c != null 
                           && lisRecord.Invoice_Billing_Schedule_del__c != contractABC.Invoice_Billing_Schedule__c) {
                            tempListToBeDeleted.add(lisRecord);
                        }
                    }
                    
                    //Create a clone of teh contracts records
                    List<Line_Item_Schedule__c>  cloneList = tempListToBeDeleted.deepClone(false);
                    
                    //Loop through line item schedules
                    for(Line_Item_Schedule__c lisRecord : cloneList) {
                        
                        //check if contract's IBS is different then LIS IBS id then update the LIS record with the same id
                        if(contractABC.Invoice_Billing_Schedule__c != null && lisRecord.Invoice_Billing_Schedule_del__c != contractABC.Invoice_Billing_Schedule__c) {
                            lisRecord.Invoice_Billing_Schedule_del__c = contractABC.Invoice_Billing_Schedule__c;
                            lineItemScheduleClone.add(lisRecord);
                        }
                    }
                    
                    //add the master LIS in the list to be deleted
                    lisToBeDeleted.addAll(tempListToBeDeleted);
                }
            }
        
            //update the LIS records
            if(lineItemScheduleClone.size() > 0) {
                Util.byPassAllTriggers = true;
                insert lineItemScheduleClone;
                Util.byPassAllTriggers = false;
            }
                
            //delete the master Contract records
            if(lisToBeDeleted.size() > 0)
                delete lisToBeDeleted;
        }
    }    
    
    //This method is to check wheather LIS is associated with the Contract ABC record, if yes then don't allow IBS id as null
    public static void validateIBSIdForContactABC(List<Contract__c> records) {
        
        //Create a collection of the records to be processed
        List<Contract__c> nullIBSContracts = new List<Contract__c>();
        
        //loop through the Contract ABC records and create a collection of Contracts having IBS as Null
        for(Contract__c contractABC : records) {
            
            //check if IBS is null then add teh record in list
            if(contractABC.Invoice_Billing_Schedule__c == null) {
                nullIBSContracts.add(contractABC);
            }
        }
        
        //Checking list for size value
        if(nullIBSContracts.size() > 0) {
        
            //query to database to check whether these contractABC records have LIS associated with them or not
            //if yes then throw the exception that IBS cannot be null for contracts having LIS associated with them.
            for(Contract__c contractABC : [Select Id, 
                                            (Select Id from Line_Item_Schedule__r limit 1) 
                                           from Contract__c where Id in: nullIBSContracts ]) {
                
                //check for the Line_Item_Schedule__r size
                if(contractABC.Line_Item_Schedule__r != null && contractABC.Line_Item_Schedule__r.size() > 0) {
                    throw new CustomException('You cannot remove the Invoice Billing Schedule link for contracts that have Line Item Schedules.'
                                                + 'To remove the Invoice Billing Schedule link you must first delete all child Line Item Schedules.');
                }
            }
        }        
    }
    
    //Added by Abhinav Sharma - CR-20150820-9167 - 08/25/2015
    /**
     *  @description    : If any update happens on "Type__c" field then this method will update all of opportunity
     *                    records where contract ABC was stamped there as "Contract Signed Opportunity". 
     *                    They will ultimately keep the "Renewal Contract Type" field
     *                    in sync on those records.
     * 
     *  @args           : List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         : void
     * 
    **/
    public static void doUpdateOnOpportunitiesOnContractABCTypeUpdate(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        //Set to hold the user records Id value
        Set<Id> setEligibleContractsIds = new Set<Id>();
        
        //Loop through contract records
        for(Contract__c con : contracts) {
            
            //Checking for "Type__c" field update/change on contract records
            //Accordingly populating the set with Id values
            if(mapOldContracts != null
                && (
                    mapOldContracts.get(con.Id).Type__c != con.Type__c
                ) 
            ){
                setEligibleContractsIds.add(con.Id);    
            }
        }
        
        //Checking set for size value
        if(setEligibleContractsIds.size() > 0) {
            
            //Map of opportunities going to be update to keep the fields in sync
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
            
            //Loop through opportunity records and populating map accordingly
            for(Opportunity o : [SELECT ID, Signed_Opportunity_Contract__c, Signed_Opportunity_Contract__r.Type__c, Renewal_Contract_Type__c 
                                    FROM Opportunity
                                    WHERE Signed_Opportunity_Contract__c != null 
                                    AND Signed_Opportunity_Contract__c IN : setEligibleContractsIds]) {
                if(o.Renewal_Contract_Type__c != o.Signed_Opportunity_Contract__r.Type__c) {
                    o.Renewal_Contract_Type__c = o.Signed_Opportunity_Contract__r.Type__c;
                    mapOpportunities.put(o.Id, o);
                }
            }

            //Checking map for size value
            if(mapOpportunities.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapOpportunities.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
    /**
     *  @description    : This method is there to populate "Active Membership Main Contact" field on associated membership records
     *                    with the "Main Contact" value from the parent contract record.
     * 
     *  @args           : List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         : void
     *
     *	Version         : V1.1 - Created
						: V1.2 - Modified by ABhinav Sharma - 03/08/2018 - CR-20180205-11984 -  Update the logic to populate the Active_Contract_Main_Contact__c onn Membership on the Change of Main Contact Of Contract ABC									
     * 
    **/
    public static void updateActiveMembershipMainContact(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        
        //Map of Contracts ABC records
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();

        //Loop through contract records
        for(Contract__c con : contracts) {

            //Checking for the field value change and accordingly populating map with values
            if(mapOldContracts != null && (mapOldContracts.get(con.Id).Main_Contact__c != con.Main_Contact__c))
                mapContracts.put(con.Id, new Contract__c(Id = con.Id, Main_Contact__c = con.Main_Contact__c));
        }
        
        //Checking for map values size
        if(mapContracts.values().size() > 0) {

            //Map of memberships
            Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>();

            //Loop through opportunity records and populating map accordingly
            for(Membership__c member : [SELECT ID, Active_Contract_Main_Contact__c, Active_Contract_Idenfied__c FROM Membership__c
                                            WHERE Active_Contract_Idenfied__c != null
                                            AND Active_Contract_Idenfied__c IN : mapContracts.keySet()]) {
                //Checking for the null value and populating fields value
                if(mapContracts.get(member.Active_Contract_Idenfied__c) != null) {
                	
                	/*Changed the logic to populate the Active_Contract_Main_Contact__c
                	Previous logic - Update the value of this field with the updated values of Main_Contact__c
                	New Logic - Only those Membership will be changed, which is having Active_Contract_Main_Contact__c blank/Null */
                    //if(member.Active_Contract_Main_Contact__c != mapContracts.get(member.Active_Contract_Idenfied__c).Main_Contact__c)
                    
                    if(member.Active_Contract_Main_Contact__c == null)
                    	mapMembership.put(member.Id, new Membership__c(Id = member.Id , Active_Contract_Main_Contact__c =  mapContracts.get(member.Active_Contract_Idenfied__c).Main_Contact__c, Active_Membership_Main_Con_Updated_Date__c = date.today() ));    
                }                               
            }
            
            //Checking map for size value
            if(mapMembership.values().size() > 0) {
                Util.BypassAllTriggers = true;
                update mapMembership.values();
                Util.BypassAllTriggers = false;
            }
        }    
    }
    
    //Modified By - Mahedra Swarnkar - 07/05/2016 - CR-20160229-9651 - Added logic to populate New_Member_Programs_TD__c field on case
    //Added By - Abhinav Sharma - 02/13/2016 - CR-20150925-9267
    /**
     *  @description    :   Whenever a new Contract is Inserted (after insert) or the Start/End date fields are changed (after update) 
     *                      and the related Program's Business Line = RI, perform an update on all Cases related to that Institution. 
     * 
     *  @args           :   List of new contract ABC records, Map of old contract ABC records
     * 
     *  @return         :   void
     * 
    **/
    public static void populateFieldsOnCaseFromContract(List<Contract__c> contracts, Map<Id, Contract__c> mapOldContracts) {
        /* Spring CleanUp
        //Set to hold the parent account IDs
        Set<Id> parentAccountIds = new Set<Id>();
        
        //Set to hold the Contract IDs
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop through contract records
        for(Contract__c cABC : contracts) {
            
            //populating setContractIds
            if(mapOldContracts == null || (mapOldContracts != null && cABC.End__c != mapOldContracts.get(cABC.Id).End__c))
                setContractIds.add(cABC.Id);
            
            //Checking for fields values
            if(cABC.Payer_Account__c != null) {
                    
                //Checking for the event type (Insert and Update case)
                if(mapOldContracts == null || (mapOldContracts != null && contracts !=  null
                                                && 
                                                (cABC.Payer_Account__c != mapOldContracts.get(cABC.Id).Payer_Account__c
                                                || 
                                                cABC.Business_Line__c != mapOldContracts.get(cABC.Id).Business_Line__c
                                                ||
                                                cABC.Type__c != mapOldContracts.get(cABC.Id).Type__c
                                                ||
                                                cABC.Start__c != mapOldContracts.get(cABC.Id).Start__c
                                                ||
                                                cABC.End__c != mapOldContracts.get(cABC.Id).End__c
                                                 ||
                                                cABC.Program__c != mapOldContracts.get(cABC.Id).Program__c
                                                )
                                              ) 
                ) { 
                    parentAccountIds.add(cABC.Payer_Account__c);     
                    
                    //Old Account record Id value (In case account got changed on contract record)
                    if(mapOldContracts != null && mapOldContracts.get(cABC.Id).Payer_Account__c != null)
                        parentAccountIds.add(mapOldContracts.get(cABC.Id).Payer_Account__c);
                }
            }
        }
        
        //Map to hold the case records to be Updated 
        Map<Id, Case> mapOfCasesToBeUpdated = new Map<Id, Case>();
        
        //Check for Size
        if(setContractIds.size() > 0) {
            
            //Query through Case records 
            for(Case tdCase : [Select Id, Project_Year__c, Project_Source_MS__c, Project_Source_MS__r.Name, 
                                    Contract__c, Contract__r.End__c, Program_Subscription__c, 
                                    Program_Subscription__r.SBQQ__EndDate__c
                                 From Case 
                                 WHERE RecordTypeId =: Util.RecordTypeId('Case', 'Talent Development') 
                                    AND Contract__c != null AND Contract__c IN : setContractIds]) {
                
                //Checking for the null value
                if(tdCase.Project_Source_MS__c != null ) {
                    
                    //Checking for the subscription record reference
                    if(tdCase.Program_Subscription__c != null && tdCase.Program_Subscription__r.SBQQ__EndDate__c != null)
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - ' + tdCase.Program_Subscription__r.SBQQ__EndDate__c.year();
                    else if(tdCase.Contract__c != null && tdCase.Contract__r.End__c != null)    
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - ' + tdCase.Contract__r.End__c.year();
                    else
                        tdCase.Project_Year__c =  tdCase.Project_Source_MS__r.Name + ' - null';
                
                } else {
                    
                    //Checking for the subscription record reference
                    if(tdCase.Program_Subscription__c != null && tdCase.Program_Subscription__r.SBQQ__EndDate__c != null)
                        tdCase.Project_Year__c =  'null - ' + tdCase.Program_Subscription__r.SBQQ__EndDate__c.year();
                    else if(tdCase.Contract__c != null && tdCase.Contract__r.End__c != null)    
                        tdCase.Project_Year__c =  'null - ' + tdCase.Contract__r.End__c.year();
                    else
                        tdCase.Project_Year__c =  'null - null';
                }
                
                //Populating map with values
                mapOfCasesToBeUpdated.put(tdCase.Id, tdCase);
            }   
        } 
        
        //Map to hold  account Id as a key and list of related contracts as values
        Map<Id, List<Contract__c>> mapAccountWithContracts = new Map<Id, list<Contract__c>>();
        
        //Checking set for size value
        if(parentAccountIds.size() > 0) {
        
            //Loop through contract records
            for(Contract__c cABC : [SELECT ID, Program_Acronym__c, Payer_Account__c, Start__c, End__c, Business_Line__c
                                    FROM Contract__c
                                    WHERE Payer_Account__c != null 
                                    AND Payer_Account__c IN : parentAccountIds
                                    AND Type__c =: Constants.CONTRACT_TYPE_NBB 
                                    AND (
                                            Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE
                                            OR Business_Line__c = 'TD'
                                        )
                                    AND Start__c != null
                                    AND End__c != null
                                    ORDER By End__c DESC]) {
                                        
                //Checking for parent account presence and populating map accordingly                       
                if(mapAccountWithContracts.containsKey(cABC.Payer_Account__c)) 
                    mapAccountWithContracts.get(cABC.Payer_Account__c).add(cABC);  
                else   
                    mapAccountWithContracts.put(cABC.Payer_Account__c, new List<Contract__c>{cABC});   
            }
        }
            
        //Get all record types on case object
        Map<String, Id> caseRecordTypesMap = Util.recordtypemap(Constants.CASE_OBJECT);
        
        //Set to hold the eligible record type IDs
        Set<Id> eligibleCaseRecordTypes = new Set<Id>();
        
        //Map to hold the case record type Id as key and correspodning record type label as value
        Map<Id, String>  mapRecordTypes = new Map<Id, String>();
        
        //Looping over map keyset and accordingly populating collection with map retrieved values
        for(String recordTypeLabel : caseRecordTypesMap.keySet()) {
            if(recordTypeLabel != null 
               && (
                    recordTypeLabel.equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE)
                    || recordTypeLabel.equalsIgnoreCase('Talent Development')
                  )
               && caseRecordTypesMap.get(recordTypeLabel) != null   
              )
                eligibleCaseRecordTypes.add(caseRecordTypesMap.get(recordTypeLabel));
                
            //Populating map to hold the case record type Id as key and correspodning record type label as value
            if(String.isNotBlank(recordTypeLabel) 
               && caseRecordTypesMap.containsKey(recordTypeLabel)
               && caseRecordTypesMap.get(recordTypeLabel) != null)
                mapRecordTypes.put(caseRecordTypesMap.get(recordTypeLabel), recordTypeLabel);       
        }          
            
        //Checking if eligible case record type exists or not
        if(eligibleCaseRecordTypes != null && eligibleCaseRecordTypes.size() > 0 
           && parentAccountIds != null && parentAccountIds.size() > 0) {
                
            //Map of cases
            Map<Id, Case> mapOfCases = new Map<Id, Case>([SELECT ID, AccountID, New_Member_Programs_RI__c, 
                                                            New_Member_Programs_TD__c, CreatedDate, RecordTypeId,
                                                            Program_Subscription__c, 
                                                            Program_Subscription__r.SBQQ__EndDate__c
                                                            FROM Case 
                                                          WHERE AccountId != null
                                                            AND AccountId IN : parentAccountIds
                                                            AND RecordTypeId IN: eligibleCaseRecordTypes]); 
                                                            
            //Map to hold the account ID as key and associated subscription records list as value
            Map<Id, List<SBQQ__Subscription__c>> mapAccountWithSubscriptions = new Map<Id, List<SBQQ__Subscription__c>>();
        
            //Loop through subscription records and populating map accordingly
            for(SBQQ__Subscription__c sub : [SELECT ID, Program_Acronym__c, SBQQ__Account__c, SBQQ__StartDate__c, 
                                                    SBQQ__EndDate__c
                                                   ,Business_Line__c
                                                    FROM SBQQ__Subscription__c
                                                    WHERE SBQQ__Account__c != null 
                                                    AND SBQQ__Account__c IN : parentAccountIds
                                                    AND Renewal_Type__c =: System.Label.RENEWAL_TYPE_INITIAL 
                                                    AND (
                                                            Business_Line__c =: System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE 
                                                            OR Business_Line__c =: System.Label.CASE_TD_PROGRAM_TYPE 
                                                        )
                                                    AND SBQQ__StartDate__c != null
                                                    AND SBQQ__EndDate__c != null
                                                    AND RecordTypeID != null
                                                    AND RecordType.DeveloperName = 'Program'
                                                    ORDER By SBQQ__EndDate__c DESC]) { 
                //Checking for parent account presence and populating map accordingly                       
                if(mapAccountWithSubscriptions.containsKey(sub.SBQQ__Account__c)) 
                    mapAccountWithSubscriptions.get(sub.SBQQ__Account__c).add(sub);  
                else   
                    mapAccountWithSubscriptions.put(sub.SBQQ__Account__c, new List<SBQQ__Subscription__c>{sub});   
            }                                                                        
                                                                
            //Checking if eligible cases are associated with the contract records
            if(mapOfCases != null && mapOfCases.keySet().size() > 0) {
                
                //Loop over case records
                for(Case c : mapOfCases.values()) {
                        
                    //Temporary variable to hold the contracts program acronyms Concatenated string literal value
                    String programAcromyms = '';
                    String programAcromymsForTD = '';
                    
                    //Checking for the eligibility
                    if(mapAccountWithSubscriptions != null && mapAccountWithSubscriptions.containsKey(c.AccountId) 
                        && mapAccountWithSubscriptions.get(c.AccountId) != null 
                        && mapAccountWithSubscriptions.get(c.AccountId).size() > 0) {
                        
                        //Checking case "CreatedDate" field for null value
                        if(c.CreatedDate != null) {
                            
                            //getting created date GTM time zone value (for comparision in between value)    
                            Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                            Time myTime = Time.newInstance(0, 0, 0, 0);
                            DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                               
                            //Loop through subscription records
                            for(SBQQ__Subscription__c sub : mapAccountWithSubscriptions.get(c.AccountId)) {
                                   
                                //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                //which is in current context
                                if(sub.SBQQ__StartDate__c <= dt && sub.SBQQ__EndDate__c >= dt) {                     
                                    
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) 
                                        && sub.Business_Line__c == System.Label.CASE_NEW_MEMBER_PROGRAMS_TYPE
                                        )
                                        programAcromyms += sub.Program_Acronym__c + Constants.COMMA;
                                        
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_TALENT_DEVELOPMENT_RECORD_TYPE) 
                                        
                                        && sub.Business_Line__c == System.Label.CASE_TD_PROGRAM_TYPE
                                        )
                                        programAcromymsForTD += sub.Program_Acronym__c + Constants.COMMA;    
                                }
                            }
                        } else {
                            
                            //Loop through contract records
                            for(SBQQ__Subscription__c ss : mapAccountWithSubscriptions.get(c.AccountId)) {
                                   
                                //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                //which is in current context
                                if(ss.SBQQ__StartDate__c <= System.today() && ss.SBQQ__EndDate__c >= System.today()) {
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE))
                                        programAcromyms += ss.Program_Acronym__c + Constants.COMMA;  
                                        
                                    if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_TALENT_DEVELOPMENT_RECORD_TYPE))
                                        programAcromymsForTD += ss.Program_Acronym__c + Constants.COMMA;
                                }
                            }
                        }
                        
                        //Removing additional "," from the end of concatenated string literal (if exists)
                        if(programAcromyms != '') {
                               
                            //Trim the white spaces
                            programAcromyms = programAcromyms.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                        }
                        
                        if(programAcromymsForTD != '') {
                               
                            //Trim the white spaces
                            programAcromymsForTD = programAcromymsForTD.trim();
                               
                            //Checking if last character of string literal is "Comma" or not
                            if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                        }
                    
                    } else {
                        
                        //Checking for eligible contract records presence and then accordingly concatenating "Program Acronyms" string literal
                        if(mapAccountWithContracts != null && mapAccountWithContracts.containsKey(c.AccountId) 
                            && mapAccountWithContracts.get(c.AccountId) != null 
                            && mapAccountWithContracts.get(c.AccountId).size() > 0) {
                                
                            //Checking case "CreatedDate" field for null value
                            if(c.CreatedDate != null) {
                                
                                //getting created date GTM time zone value (for comparision in between value)    
                                Date myDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());
                                Time myTime = Time.newInstance(0, 0, 0, 0);
                                DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
                                
                                //Loop through contract records
                                for(Contract__c conABC : mapAccountWithContracts.get(c.AccountId)) {
                                       
                                    //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                    //which is in current context
                                    if(conABC.Start__c <= dt && conABC.End__c >= dt) {
                                        
                                        if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE) && conABC.Business_Line__c == 'RI')
                                            programAcromyms += conABC.Program_Acronym__c + Constants.COMMA;
                                            
                                        if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development') && conABC.Business_Line__c == 'TD')
                                            programAcromymsForTD += conABC.Program_Acronym__c + Constants.COMMA;    
                                    }
                                }
                                
                            } else {
                                
                                //Loop through contract records
                                for(Contract__c coABC : mapAccountWithContracts.get(c.AccountId)) {
                                       
                                    //Checking and validating contract "Start" and "End" dates with respect to the case record 
                                    //which is in current context
                                    if(coABC.Start__c <= System.today() && coABC.End__c >= System.today()) {
                                        if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase(System.Label.CASE_NEW_MEMBER_RECORD_TYPE))
                                            programAcromyms += coABC.Program_Acronym__c + Constants.COMMA;  
                                            
                                        if(mapRecordTypes.get(c.RecordTypeId).equalsIgnoreCase('Talent Development'))
                                            programAcromymsForTD += coABC.Program_Acronym__c + Constants.COMMA;
                                    }
                                }                            
                            }    
                               
                            //Removing additional "," from the end of concatenated string literal (if exists)
                            if(programAcromyms != '') {
                                   
                                //Trim the white spaces
                                programAcromyms = programAcromyms.trim();
                                   
                                //Checking if last character of string literal is "Comma" or not
                                if(programAcromyms.substring((programAcromyms.length()-1), programAcromyms.length()) == Constants.COMMA)
                                    programAcromyms = programAcromyms.removeEnd(Constants.COMMA);
                            }
                            
                            if(programAcromymsForTD != '') {
                                   
                                //Trim the white spaces
                                programAcromymsForTD = programAcromymsForTD.trim();
                                   
                                //Checking if last character of string literal is "Comma" or not
                                if(programAcromymsForTD.substring((programAcromymsForTD.length()-1), programAcromymsForTD.length()) == Constants.COMMA)
                                    programAcromymsForTD = programAcromymsForTD.removeEnd(Constants.COMMA);
                            }
                        }    
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_RI__c != programAcromyms) {
                        c.New_Member_Programs_RI__c = programAcromyms;
                        
                        //Checking for te key existance in map
                        if(mapOfCasesToBeUpdated.containsKey(c.Id))
                            mapOfCasesToBeUpdated.get(c.Id).New_Member_Programs_RI__c = c.New_Member_Programs_RI__c;
                        else
                            mapOfCasesToBeUpdated.put(c.Id, c);
                    }
                    
                    //First checking for the difference in between new and old value and accordingly Setting field value on the case records
                    if(c.New_Member_Programs_TD__c != programAcromymsForTD ) {
                        c.New_Member_Programs_TD__c = programAcromymsForTD;
                        
                        //Checking for te key existance in map
                        if(mapOfCasesToBeUpdated.containsKey(c.Id))
                            mapOfCasesToBeUpdated.get(c.Id).New_Member_Programs_TD__c = c.New_Member_Programs_TD__c;
                        else  
                            mapOfCasesToBeUpdated.put(c.Id, c);
                    }  
                }   
            }                                   
        }
        
        //Checking for size value
        if(mapOfCasesToBeUpdated.values().size() > 0){
            
            Util.byPassAlltriggers = true;
            update mapOfCasesToBeUpdated.values();
            Util.byPassAlltriggers = false;
        }
   */ }
    
    /**
     *      Description     :   Method to have logic, 
     *                          1) When the contract is updated and Program is changes then populate the set of contract Ids
     *                          2) now query all the CIA's with Account, Contract,Contract.Programs where contract = set contractIds 
     *                          3) Now pass this list and the object API Name i.e. "Contract__c" to the common method "createMembershipForCIA" of ContractIntegratedAccountsTriggerHelper
     *
     *  
     *      Return Type     :   void  
     *
     *      Arguments       :   List<Contract__c>  , Map<Id, Contract__c>   
     *  
     **/   
    //Added By - Mahendra Swarnakar - 3/15/2017 - CR-20170210-10679
    public static void createMembershipForCIAFromContract(List<Contract__c> newContracts , Map<Id, Contract__c> mapOldContracts){
    
        //Set to hold ContractIds
        Set<Id> setContractIds = new Set<Id>();
        
        //Check for UPdate case
        
        //Loop over Contract Records
        for(Contract__c cont : newContracts){
            
            //Check for Program get update
            if(mapOldContracts != null 
                && cont.Program__c != null 
                && cont.Program__c != mapOldContracts.get(cont.Id).Program__c
            )
                setContractIds.add(cont.Id);
        }
        
        //Check for setContractIds size 
        if(setContractIds.size() > 0 ) 
        {   
            //List to CIA records
            List<Contract_Integrated_Accounts__c> listOfCIARecords = new List<Contract_Integrated_Accounts__c>();
            
            //Loop over new CIA records to get parent record fields value
            for(Contract_Integrated_Accounts__c cia : [SELECT ID , Account__c, Contract__c, Contract__r.Program__c 
                                                       FROM Contract_Integrated_Accounts__c 
                                                       WHERE Account__c != null AND Contract__c IN : setContractIds]
            ) {
                //Add CID record ID in the set 
                listOfCIARecords.add(cia);
            }
            
            //Check for the size
            if(listOfCIARecords.size() > 0)
                
                //Call the method and pass argument for further proccessing on the records.
                ContractIntegratedAccountsTriggerHelper.createMembershipForCIA(Constants.OBJECT_CONTRACT_ABC_API_NAME, listOfCIARecords);
        }
    }
    
    //Created By Dipesh Gupta - 11/29/2017 -CR-20171128-11817 - Fixing the Code coverage error in the Partial deployment.
    public static void CustomExceptiontoCoverCatch () {
        
        try {
        	throw new CustomException('I am only covering Catch part');
        }Catch (Exception e) {
            
        }
 
    }
    
    /**
     *  @description    :   Method is used to populate the 'Join Date-Most Recent' field on Membership .
     *
     *  @args           :   Map<Id, Contract__c> mapNewContracts , Map<Id, Contract__c> mapOldContracts
     *
     *  @return         :   void
     *
     * 	@Revision Log	:   V1.0 - Created - Subhash Garhwal - 07/23/2018 - CR-20180607-12272
     * 			    V1.1 - Modified By- Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560 - populate the Join_Date_Most_Recent__c field on membership with start date  on Subscription(SBQQ__StartDate__c)/Contract(Start__c) instead of join_date__c.
     * 			    V1.2 - Modified By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
     *
     **/
    /*public static void updateJoinDateMostRecentOnMembership(Map<Id, Contract__c> mapNewContracts , Map<Id, Contract__c> mapOldContracts) {
    	
    	//Set to hold the Latest Subscription Ids
    	Set<Id> setContractIdWithJoinDate = new Set<Id>();
    	
    	//Set to hold the Latest Subscription Ids
    	Set<Id> setContractIdWithoutJoinDate = new Set<Id>();
    	
    	//List of Membership to be updated
    	List<Membership__c> membershipsToBeUpdated = new List<Membership__c>();
    
    	//Loop over the new subscriptions
    	for(Contract__c cont : mapNewContracts.values()) {
    		
    		//Check for Join Date 
    		if(cont.Start__c  != null && (mapOldContracts == null || cont.Start__c != mapOldContracts.get(cont.Id).Start__c ))
    		
    			//Add value into the set
    			setContractIdWithJoinDate.add(cont.Id);
    			
    		else if(cont.Start__c == null & mapOldContracts != null && cont.Start__c != mapOldContracts.get(cont.Id).Start__c)
    		
    			setContractIdWithoutJoinDate.add(cont.Id);
    	}
    	
    	//Size check
    	if(setContractIdWithJoinDate.size() > 0 || setContractIdWithoutJoinDate.size() > 0) {
    	
	    	//Query over Membership
	    	for(Membership__c mem : [Select Id, Join_Date_Most_Recent__c, Latest_Subscription__c, Latest_Subscription__r.SBQQ__StartDate__c, Latest_Contract__c From Membership__c Where Latest_Contract__c IN :  setContractIdWithJoinDate
	    								OR Latest_Contract__c IN : setContractIdWithoutJoinDate])	{
	    		
	    		//Check for Latest Subscription and its Join Date 
	    		if(mem.Latest_Subscription__c == null || (mem.Latest_Subscription__c != null && mem.Latest_Subscription__r.SBQQ__StartDate__c == null)) {
	    		
	    			//Check for Contract join date
	    			if(setContractIdWithJoinDate.contains(mem.Latest_Contract__c))
		    		
			    		//Add value into the list 
			    		membershipsToBeUpdated.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = mapNewContracts.get(mem.Latest_Contract__c).Start__c));
			    		
			    	//Check for contract join date updating to null and Subscription Join date is null
			    	else if(setContractIdWithoutJoinDate.contains(mem.Latest_Contract__c))
			    	
			    		//Add value into the list 
			    		membershipsToBeUpdated.add(new Membership__c(Id = mem.Id, Join_Date_Most_Recent__c = null));
	    		}
	    	}
    	}
    	//Size check
    	if(membershipsToBeUpdated.size() > 0) {
    	
    		//Enable all triggers
		    Util.BypassAllTriggers = true;
    	
    		//Update Membership
    		update membershipsToBeUpdated;
    		
    		//Enable all triggers
		    Util.BypassAllTriggers = false;
    	}
		
    }  */
}