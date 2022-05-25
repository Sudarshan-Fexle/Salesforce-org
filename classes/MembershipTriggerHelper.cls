/*
    Purpose         :   This class is helper class for trigger on Membership object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   01/18/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        V_1.1 New method added  - CR-20111122-239
                        V_1.2 Bhavi - 06/15/2012 - Added new method(deleteKeyMemberContactsForNonMembership) - CR-20120518-905
                        V_1.3 Bhavi - 12/11/2012 - Added new Method(membershipPopulateAssignedMarketer) - CR-20120208-389
                        V_1.4 Bhavi - 11/07/2012 - Added a new Methos(PopulateContactData) - CR-20121019-1641
                        V_1.5 Bhavi - 02/01/2013 - Modified UpdateRelationshipGradeNotes method to execute only when required - CR-20130131-2377
                        V_1.6 Bhavi - 02/02/2013 - CR-20121212-1898
                        V_1.7 Bhavi - 03/28/2013 - Added a new Method(updateRelationshipManagerOnProject) - CR-20121207-1868
                        V_1.8 Victor - 04/23/2013 - Added a new Method(PopulateMostRecentQACall) - CR-20121031-1669
                        V_1.9 Victor - 10/15/2013 - Bypass Triggers in populateContactData - CR-20130416-2879
                        V_2.0 Abhinav Sharma - 02/12/2014 - Refactor the method (membershipPopulateAssignedMarketer) - CR-20130911-3628
                        V_2.1 Bhavi Sharma - 03/18/2014 - Refactor the method (membershipPopulateAssignedMarketer) - removed all Inline queries - CR-20130911-3628 
                        V_2.2 Abhinav Sharma - 04/18/2014 - CR-20140331-4909 - Updates to batch failure process
                        V_2.3 Abhinav Sharma - 09/08/2014 - CR-20140515-5538 - QA Data Lag
                        V_2.4 Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Update PopulateMostRecentQACall method
                        V_2.5 Ajit Surana - 03/28/2015 - CR-20150312-8758 - Added a new method (populateIndustryMemberOnAccount)
                        V_2.6 Abhinav Sharma - 04/30/2015 - CR-20121218-1964 - Membership name not correct on batch insert
                        V_2.7 Mahendra swarnkar - 07/15/2015 - CR-20150520-8962 - Updated process_membership method
                        V_2.8 - Abhinav Surana - 09/03/2015 - CR-20150205-8660 - Added new method (populateFieldsOnMembershipInBeforeEvent)
                        V_2.9 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution    
                        V_3.0 - Modified By - Victor Hanson - 02/16/2016 - CR-20160210-9596 - Fixed query row exception
                        V_3.1 - Modified By - Mahendra Swarnakar - 5/11/2016 - CR-20160219-9619 - Updated PopulateMostRecentQACall method to modify to sort the Membership events as per their grades
                        v_3.2 - Modified By - Mahendra Swarnakar - 8/25/2016 - CR-20160725-10063 - Modified StartDateTime Criteria, Use label to get value
                        v_3.3 - Modified By - Mahendra Swarnakar - 8/26/2016 - CR-20160606-9903 - Modified the Method PopulateMostRecentQACall.
                        v_3.4 - Modified By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
                        V_3.5 - Modified By - 1/23/2017 - Abhinav Sharma - CR-20170105-10596 - Modified existing method - updateMembershipStatusByContracts
                        V_3.6 - Modified By - Victor Hanson -03/20/2017 - CR-20170110-10605 - Bypass membership status update on Royall Memberships
                        V_3.7 - Modified By - Abhinav Sharma - DS114 - 06/02/2017 - updated "populateFieldsOnMembershipInBeforeEvent" method
                        V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - update "Active_Contract_Main_Contact__c", "membershipPopulateAssignedMarketer" and "updateMembershipStatusByContracts" method
                        V_3.9 - Merged By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
                        V_3.7 - Modified By - Mahendra Swarnakar -04/27/2017 - CR-20170327-10781 - Created a new Method "populateOpportunityAndProjectFieldsFromMembership" to populate the opportunity &Project fields from membership.
                        V_3.9 - Merged By - Rajeev Jain - 07/05/2017 - upto here
                        V_4.0 - Modified by Dipesh Gupta - 08/12/2017 - CR-20170426-10878 - Modified the new Method populateOpportunityAndProjectFieldsFromMembership to update the related projct  if membership updates.
                        V_4.1 - Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - membershipPopulateAssignedMarketer method
                        V_4.2 - Modified By Abhinav Sharma - CR-20180205-11984 - populateFieldsOnMembershipInBeforeEvent Update the Logic to populate the Active_Contract_Main_Contact__c, (This only populate in the Insert Case)
                        V_4.3 - Modified By - Subhash Garhwal - 06/20/2018  - CR-20180608-12273 - Updated the Subscription Stage check from Voider To Void.
                        V_4.4 - Modified By - Subhash Garhwal - 06/27/2018 - CR-20180607-12272 - Updated 'populateFieldsOnMembershipInBeforeEvent' method to update 'Join_Date_Most_Recent__c' on Membership
                        V_4.5 - Merged By Rajeev jain - 07/19/2018 - CR-20180607-12272 - Deployment 
                        V_4.6 - Merged by Rajeev Jain  - 10/03/2017 - Deployment CR-20180803-12480.
                        V_4.7 - Modified by - Colin McGloin - 09/04/2018 - CR-20180731-12476 - Commented out all references to Opportunity fields Value Advisor, Value Management Director, Value Management Lead, Practice Partner due to their removal as part of Opp Lookup Cleanup 
                        V_4.8 - Modified By Abhinav sharma - 08/27/2018 - CR-20180615-12286 - Added population of Active_ES_Membership/Paid_ES_Membership__c on Instittution. Method - process_membership 
                        V_4.9 - Merged BY Rajeev Jain - CR-20180615-12286 - 10/06/2018.
                        V_5.0 - Modified By - Subhash Garhwal - 09/26/2018 - CR-20180720-12456 - updated populateFieldsOnMembershipInBeforeEvent, populateContactData, populateIndustryMemberOnAccount, updateMembershipStatusBy to reduce the SOQL count.
                        V_5.1 - Modified By Abhinav sharma - CR-20180809-12494. updateMembershipFieldsForEnrollmentRecordType
                        V_5.2 - Modified By - Victor Hanson - 10/31/2018 - CR-20181031-12723 - updated updateMembershipStatusByContracts to fix a status bug
                        V_5.3 - Merged By Rajeev Jain - 11/01/2018 - CR-20181031-12723 method - updateMembershipStatusByContracts
                        V_5.4 - Modified By - Subhash Garhwal - 07/12/2018 - CR-20180504-12213 - Updated 'updateCurrentYearFees' method
                        V_5.5 - Modified By - Subhash Garhawal - 10/08/2018 - CR-20180504-12213 - Updated 'process_membership' method
                        V_5.6 - Modified By Abhinav sharma - 02/05/2018 - CR-20180828-12525 - Added method "PopulateMostRecentRIAMEvent" to Populate the evergreen Fields on Membership.
                        V_5.7 - Modified By - Subhash Garhawal - 12/26/2018 - CR-20181019-12685 - Added a new Method "populatePreviousCurrentNextYearProgramCost".
                        V_5.8 - Modified By - Victor Hanson - 02/14/2019 - CR-20181019-12685 - added bypassMembershipPopulateAssignedMarketer
                        V_5.9 - Modified By - Mahendra Swarnkar - 03/05/2019 - CR-20190215-12886 - updated the Method "updateCurrentYearFees".
                        V_6.0 - Modified By - Mahendra Swarnkar - 05/13/2019 - CR-20190308-12920 - updated "updateMembershipFieldsForEnrollmentRecordType".
                        V_6.1 - Modified By - Victor Hanson - 05/30/2019 - CR-20190520-13117 - Added method "checkForActiveMembership" to check for institutions with no active memberships
                        V_6.2 - Modified By - Dipesh Gupta - 07/03/2019 - CR-20190305-12910 - Added a new Method "populateOwnerByRSLOnProgramSubscription".
                        V_6.3 - Dipesh Gupta - 08/02/2019 - CR-20190801-13252
                        V_6.4 - Victor Hanson - 08/06/2019 - CR-20190805-13254 - updated query in populateOwnerByRSLOnProgramSubscription to filter out null
                        V_6.5 - Colin McGloin - 08/19/2019 - CR-20190730-13242 - Fixed how Research Memberships on Institution is populated post Spring Cleaning
                        V_6.6 - Modified By Dipesh Gupta - 08/28/2019 - CR-20190620-13190. modified updateMembershipStatusByContracts
                        V_6.7 - Modified By Victor Hanson - 11/05/2019 - CR-20191031-13488 - Updated updateCurrentYearFees to exclude global memberships from receiving annual/travel fees
                        V_6.8 - Modified By Dipesh Gupta - 11/11/2019 - CR-20190419-13012 - Added a new Method "populateMainContactSignerOnContact".
                        V_6.9 - Modified By Dipesh Gupta - 01/24/2020 - CR-20191204-13547 - Bypaased the logic for Active Subscription in "membershipPopulateAssignedMarketer" method 
                        V_7.0 - Modified By Mahendra Swarnkar - 02/25/2019 - CR-20200131-13680
                        V_7.1 - Added By - Mahendra Swarnkar - 08/17/2020 - CR-20181004-12632 - MS 4: Removing key contact status upon membership drop.
                        V_7.2 - Modified By -  Abhinav Sharma - 8/13/2020 -  CR-20180808-12492 - Delete Account Fields related changes
                        V_7.3 - Modified By Mahendra Swarnkar - 08/17/2020 - CR-20200427-13986 - Added new Method "populatePayerStatus" 
                        V_7.4 - Modified By Mahendra Swarnkar - 8/17/2020 - CR-20181004-12632 - Added new Method "UpdateMKConStatusChange"
                        V_7.5 - Modified By - Abhinav Sharma - CR-20200717-14329
                        V_7.6 - Modified By Victor Hanson - 10/27/2020 - CR-20201013-14598 - updated query to check for Program Costs OR Cappex Service Costs
                        V_7.7 - Modified By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - Commented out all values which update Membership Owner and added "UpdateOwnerOnMembership" method for insert generic owner
                        V_7.8 - Modified By - Neha Sharma - 11/10/2020 - CR-20201021-14625 - Add automation of cases for cappex.
                        V_7.9 - Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867
                        V_8.0 - Modified By - Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        V_8.1 - Modified By - Saurabh Kumar - 09/29/2020 - CR-20200821-14453 - syncRegistrationPartnerStatus method added
                        V_8.2 - Modified By - Mahendra Swarnkar - 12/1/2020 - CR-20200720-14338 
                        V_8.3 - Modified By - Neha Sharma - 11/03/2020 - CR-20200814-14435 - Remove the Commented out all values which update Membership Owner from populateOwnerByRSLOnProgramSubscription,MembershipPopulateAssignedMarketer method
                        V_8.4 - Modified By - Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Modified UpdateMKConStatusChange method.
			V_8.5 - Modified By - Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021                     
                        V_8.6 - Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - Annual_Fee calculated by taking the SUM of all applicable customer amounts.
			V_8.7 - Modified By - Mahendra Swarnkar - CR-20210316-15001 - 06/29/2021 - Added Check for Business Lines 'YV' and 'ES'
			V_8.8 - Modified By - Chirag Soni - CR-20210621-15227 - 07/26/2021 - modified method membershipPopulateAssignedMarketer - added new check IsTrigger_ContractIntegratedAcctRunning
			V_8.9 - Modified By - Mahendra Swarnkar - 11/19/2021 - CR-20211117-15586 - Modified method - membershipPopulateAssignedMarketer() - Added the Zendesk_Support__c field in the query
*/
public without sharing class MembershipTriggerHelper {
    
    //Flag is control the execution of UpdateRelationshipGradeNotes method
    public static Boolean EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES = true;
    public static Boolean bypassMembershipPopulateAssignedMarketer = false;
    
    //Modified By - Abhinav Sharma - DS114 - 06/02/2017
    //Added By - Abhinav Sharma - 09/03/2015 - CR-20150205-8660
    /**
     *  @description    :   Method to populate fields on membership itself from the respective parent corresponding field value.
     *
     *  @args           :   List of new Membership, Old Membership Map 
     *
     *  @return         :   void
     
     *  Version         :  V_1.1 - Created
     *          	:  V_1.2 - Modified By Abhinav Sharma - CR-20180205-11984 - Update the Logic to populate the Active_Contract_Main_Contact__c, (This only populate in the Insert Case)
     *             	:  V_1.3 - Modified By - Subhash Garhwal - 06/27/2018 - CR-20180607-12272 - Updated 'populateFieldsOnMembershipInBeforeEvent' method to update 'Join_Date_Most_Recent__c' on Membership
     *         		:  V_1.4 - Modified By - Subhash Garhwal - 09/26/2018 - CR-20180720-12456 - Added extra checks to reduce the SOQL count.
     * 			:  V_1.5 - Modified By - Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560 - populate the Join_Date_Most_Recent__c field on membership with start date  on Subscription(SBQQ__StartDate__c)/Contract(Start__c) instead of join_date__c. 
     * 			:  V_1.6 - Modified By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
    **/             
    public static void populateFieldsOnMembershipInBeforeEvent(List<Membership__c> newMemberships, Map<Id, Membership__c> mapOldMemberships) {
        
        //Set of Contracts
        Set<Id> setContracts = new Set<Id>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        //Set to hold Subscription Id
        Set<Id> setSubscriptions = new Set<Id>();
        
        //Set of users Ids
        Set<Id> setUsersIds = new Set<Id>();
        
        //Set of project IDs
        Set<Id> setProjectsIds = new Set<Id>();
        
        //Set of active renewal opportunities
        Set<Id> setActiveRenewalOpportunities = new Set<Id>();
        
        //Set to hold the Latest Subscription Ids
        Map<Id, Id> mapLatestSubIdAndMembershipIds = new Map<Id, Id>();
        
        //Set to hold the Latest Contract Ids
        Map<Id, Id> mapLatestContractIdAndMembershipIds = new Map<Id, Id>();
        
        //Map to hold the Membership Ids and its Latest Program Subscription
        Map<Id, SBQQ__Subscription__c> mapMembershipLatestSubs = new Map<Id, SBQQ__Subscription__c>();
        
        //Map to hold the Membership Ids and its Latest Contact ABC
        Map<Id, Contract__c> mapMembershipLatestContracts = new Map<Id, Contract__c>();
        
        //Loop through membership records
        for(Membership__c mem : newMemberships) {
            
            //Added By - Subhash Garhwal - CR-20180720-12456
            if((mem.Latest_Subscription__c != null || mem.Latest_Contract__c != null || mem.Active_Contract_Idenfied__c != null || mem.Active_Subscription__c != null || mem.BA_Assignment2__c != null
               || mem.DA_Assignment2__c != null || mem.Primary_Project__c != null || mem.Active_Renewal_Opportunity__c != null)
               && (mapOldMemberships == null || mem.Latest_Subscription__c != mapOldMemberships.get(mem.Id).Latest_Subscription__c
                   || mem.Latest_Contract__c != mapOldMemberships.get(mem.Id).Latest_Contract__c
                   || mem.Active_Contract_Idenfied__c != mapOldMemberships.get(mem.Id).Active_Contract_Idenfied__c
                   || mem.Active_Subscription__c != mapOldMemberships.get(mem.Id).Active_Subscription__c
                   || mem.BA_Assignment2__c != mapOldMemberships.get(mem.Id).BA_Assignment2__c
                   || mem.DA_Assignment2__c != mapOldMemberships.get(mem.Id).DA_Assignment2__c
                   || mem.Primary_Project__c != mapOldMemberships.get(mem.Id).Primary_Project__c
                   || mem.Active_Renewal_Opportunity__c != mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c)) {
              
            
              //Check for Latest Subscription 
              if(mem.Latest_Subscription__c != null && (mapOldMemberships == null ||  mem.Latest_Subscription__c != mapOldMemberships.get(mem.Id).Latest_Subscription__c))
                mapLatestSubIdAndMembershipIds.put(mem.Latest_Subscription__c, mem.Id);
              
              //Check for Latest Contract
              if(mem.Latest_Contract__c != null && (mapOldMemberships == null ||  mem.Latest_Contract__c != mapOldMemberships.get(mem.Id).Latest_Contract__c))
                mapLatestContractIdAndMembershipIds.put(mem.Latest_Contract__c, mem.Id);
              
              if(mem.Active_Contract_Idenfied__c != null)
                  setContracts.add(mem.Active_Contract_Idenfied__c);
              
              //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
              if(mem.Active_Subscription__c != null)
                setSubscriptions.add(mem.Active_Subscription__c);
              
              //Checking for the null value
              if(mem.BA_Assignment2__c != null)
                  setUsersIds.add(mem.BA_Assignment2__c);
              
              //Checking for the null value
              if(mem.DA_Assignment2__c != null)
                  setUsersIds.add(mem.DA_Assignment2__c);
              
              //Checking for the null value
              if(mem.Primary_Project__c != null)
                  setProjectsIds.add(mem.Primary_Project__c);
                  
              //Checking for the null value
              if(mem.Active_Renewal_Opportunity__c != null)
                setActiveRenewalOpportunities.add(mem.Active_Renewal_Opportunity__c);  
            }
        }
        
        //map of contrats
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        
        //Map to hold Subscription records
        Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        if(setSubscriptions.size() > 0){
          
          //Query on the subscription
          for(SBQQ__Subscription__c subscription : [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.Main_Contact__c, Join_Date__c,SBQQ__StartDate__c, 
                                  Membership__c, Membership__r.Latest_Subscription__c, Membership__r.Active_Subscription__c  
                                                        From SBQQ__Subscription__c 
                                                        Where Id IN : setSubscriptions OR Id IN : mapLatestSubIdAndMembershipIds.keySet()]) {
           
             //Check for Active Subscription
             if(setSubscriptions.contains(subscription.Id))
              mapSubscriptions.put(subscription.Id, subscription);
               
            //Check for Latest Subscription  
            if(mapLatestSubIdAndMembershipIds.containsKey(subscription.Id))
              mapMembershipLatestSubs.put(mapLatestSubIdAndMembershipIds.get(subscription.Id), subscription);
          }
        }//V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
        //Checking set for size value
        else if(setContracts.size() > 0) {
            
            //Map of contracts
            for(Contract__c c : [SELECT ID, Main_Contact__c, Join_Date__c, Start__c FROM Contract__c
                                    WHERE ID IN : setContracts OR ID IN : mapLatestContractIdAndMembershipIds.keySet()]) {
                               
                //Check for Active Contract ABC       
                if(setContracts.contains(c.Id))
                  mapContracts.put(c.Id, c); 
                
                //Check for Latest Contract ABC  
                if(mapLatestContractIdAndMembershipIds.containsKey(c.Id))  
                  mapMembershipLatestContracts.put(mapLatestContractIdAndMembershipIds.get(c.Id), C);     
            }
        }
        
        //map of users
        Map<Id, User> mapUsers = new Map<Id, User>();
        
        //Checking set for its size
        if(setUsersIds.size() > 0) {
            
            //Loop through user records
            for(User u : [SELECT ID, FirstName, LastName FROM User
                           WHERE ID IN : setUsersIds
                         ]
      )
              mapUsers.put(u.Id, u);      
        }
        
        //Map of projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Checking for the set size
        if(setProjectsIds.size() > 0) {
          
            //Loop through project records
            for(Project__c proj : [SELECT ID, Dedicator_Advisor_Pod_Lead__c 
                                   FROM Project__c
                               WHERE ID IN : setProjectsIds
                        ]
      )
              mapProjects.put(proj.Id, proj);  
        }
        
        //Map of opportunities
        Map<Id, Opportunity> mapOfActiveRenewalOpportunities = new Map<Id, Opportunity>();
        
        //Checking set for its size
        if(setActiveRenewalOpportunities.size() > 0) {
          mapOfActiveRenewalOpportunities = new Map<Id, Opportunity>([SELECT ID, Main_Contact__c, Main_Contact__r.FirstName, Main_Contact__r.LastName
                                        FROM Opportunity
                                        WHERE ID IN : setActiveRenewalOpportunities
                                        ]);  
        }
            
        //Loop through membership records
        for(Membership__c me : newMemberships) {
            
            //Modified By- Mahendra Swarnkar - 05/22/2020 - CR-20191211-13560 - Commented out the logic to populate the Join_Date_Most_Recent__c field on membership.
            //Modified By - Subhash Garhwal - 06/27/2018 - CR-20180607-12272
            //Check for Latest Program Subscription
            /*if(mapMembershipLatestSubs.containsKey(me.Id)) {
            
              //Replaced Join_Date__c with SBQQ__StartDate__c - By- Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560
              //Update Join_Date_Most_Recent__c on Memberships
              me.Join_Date_Most_Recent__c = mapMembershipLatestSubs.get(me.Id).SBQQ__StartDate__c;
           
            //Check for Latest Contract
            } else if(mapMembershipLatestContracts.containsKey(me.Id)) {
              
              //Replaced Join_Date__c with SBQQ__StartDate__c - By- Mahendra Swarnkar - 05/01/2020 - CR-20191211-13560
              //Update Join_Date_Most_Recent__c on Memberships
              me.Join_Date_Most_Recent__c = mapMembershipLatestContracts.get(me.Id).Start__c;  
            }
            */
            
            //CR-20180205-11984--Changes Start Here -----------------------------------------------
            
            //New Check to only run this in the Insert Case 
            If(trigger.isInsert) {
              
              //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Assign main contact via subscription if Active Subscription is not null otherwise via Activa Contract Identified
              //Checking for map size
              if(me.Active_Subscription__c != null){
                
                if(mapSubscriptions != null 
                      && mapSubscriptions.containsKey(me.Active_Subscription__c)
                      && mapSubscriptions.get(me.Active_Subscription__c) != null) {
                      me.Active_Contract_Main_Contact__c = mapSubscriptions.get(me.Active_Subscription__c).SBQQ__Contract__r.Main_Contact__c;       
                  }
              } 
              //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
              
             //Checking for field value and populating fields on membership accordingly 
             else if(me.Active_Contract_Idenfied__c != null) {
                    if(mapContracts != null 
                        && mapContracts.containsKey(me.Active_Contract_Idenfied__c)
                        && mapContracts.get(me.Active_Contract_Idenfied__c) != null) {
                        me.Active_Contract_Main_Contact__c = mapContracts.get(me.Active_Contract_Idenfied__c).Main_Contact__c;       
                    }
                } else {
                 
                  me.Active_Contract_Main_Contact__c = null;
             }   
            }else { 
              
              //Check for the Update case when Active Subscription and Active contract Value is changed.
              if(mapOldMemberships != null && (mapOldMemberships.get(me.Id).Active_Subscription__c != me.Active_Subscription__c 
                || mapOldMemberships.get(me.Id).Active_Contract_Idenfied__c != me.Active_Contract_Idenfied__c) && me.Active_Contract_Main_Contact__c == null){
                  
                //Check the Null Case and Fill it with the Subscription- Contract- main Contact Value
                if(me.Active_Subscription__c != null && mapSubscriptions.containsKey(me.Active_Subscription__c) && mapSubscriptions.get(me.Active_Subscription__c) != null)
                      me.Active_Contract_Main_Contact__c = mapSubscriptions.get(me.Active_Subscription__c).SBQQ__Contract__r.Main_Contact__c;
                
                //Check the Null Case and Fill it with the ContractABC- main Contact Value
                if(me.Active_Contract_Idenfied__c != null && mapContracts.containsKey(me.Active_Contract_Idenfied__c) && mapContracts.get(me.Active_Contract_Idenfied__c) != null)
                  me.Active_Contract_Main_Contact__c =  mapContracts.get(me.Active_Contract_Idenfied__c).Main_Contact__c; 
              }
            }
            
            //Check for field Active_Contract_Main_Contact__c is changed than Active_Membership_Main_Con_Updated_Date__c Update with Todays date
            if(mapOldMemberships != null && me.Active_Contract_Main_Contact__c  != mapOldMemberships.get(me.Id).Active_Contract_Main_Contact__c)
              me.Active_Membership_Main_Con_Updated_Date__c = Date.Today();
            
            //CR-20180205-11984--Changes Ends Here -----------------------------------------------
             
            //Populating "BA Text" field on membership instance
            if(me.BA_Assignment2__c != null && mapUsers.containsKey(me.BA_Assignment2__c)) {
                
                String bAText = '';
                
                //Checking for null value
                if(String.isNotBlank(mapUsers.get(me.BA_Assignment2__c).FirstName))
                    bAText += mapUsers.get(me.BA_Assignment2__c).FirstName  + ' ';
                
                bAText += mapUsers.get(me.BA_Assignment2__c).Lastname;
                
                me.BA_Text__c = bAText;
                
            } else  {
                me.BA_Text__c = null;
                
            }
            
            //Populating "DA_Assignment_Text__c" field on membership instance
            if(me.DA_Assignment2__c != null && mapUsers.containsKey(me.DA_Assignment2__c)) {
                
                String dAText = '';
                
                //Checking for null value
                if(String.isNotBlank(mapUsers.get(me.DA_Assignment2__c).FirstName))
                    dAText += mapUsers.get(me.DA_Assignment2__c).FirstName  + ' ';
                  
                dAText += mapUsers.get(me.DA_Assignment2__c).Lastname;
                me.DA_Assignment_Text__c = dAText;
            }
            else
                me.DA_Assignment_Text__c = null;
            
            //Populating "Dedicated_Advisor_Pod_Lead__c" field on membership instance
            if(me.Primary_Project__c != null && mapProjects.containsKey(me.Primary_Project__c))
                me.Dedicated_Advisor_Pod_Lead__c = mapProjects.get(me.Primary_Project__c).Dedicator_Advisor_Pod_Lead__c;
            else
                me.Dedicated_Advisor_Pod_Lead__c = null;
                
            //Checking for key existance in map and for the field value
            if(me.Active_Renewal_Opportunity__c != null && mapOfActiveRenewalOpportunities.containsKey(me.Active_Renewal_Opportunity__c)) {
              me.Active_Renewal_Opportunity_Main_Contact__c = mapOfActiveRenewalOpportunities.get(me.Active_Renewal_Opportunity__c).Main_Contact__c;
              
                //Checking for the reference
                if(mapOfActiveRenewalOpportunities.get(me.Active_Renewal_Opportunity__c).Main_Contact__c != null) {
                  
                    String mainContactName = '';
                
                    if(String.isNotBlank(mapOfActiveRenewalOpportunities.get(me.Active_Renewal_Opportunity__c).Main_Contact__r.FirstName))
                        mainContactName += mapOfActiveRenewalOpportunities.get(me.Active_Renewal_Opportunity__c).Main_Contact__r.FirstName + ' ';
                        
                    mainContactName += mapOfActiveRenewalOpportunities.get(me.Active_Renewal_Opportunity__c).Main_Contact__r.LastName;
                        
                    me.Active_Renewal_Opp_Main_Contact_Name__c = mainContactName;
                   
                } else {
                    me.Active_Renewal_Opp_Main_Contact_Name__c = '';
                }
              
            } else {
              me.Active_Renewal_Opportunity_Main_Contact__c = null;
              me.Active_Renewal_Opp_Main_Contact_Name__c = '';
            }    
        }
    }
    
    //Getter method which return the Map of account field api name as a value with businessline picklist value as a key
    public static Map<String,String> getmapAvailableOutReachAccountsFields() {
        
        Map<String,String> mapAvailableOutReachAccount = new Map<String,String>();
        mapAvailableOutReachAccount.put('TD', 'Academy_Programs_Available_for_Outreach__c');
        mapAvailableOutReachAccount.put('PT', 'BI_Programs_Available_for_Outreach__c');
        mapAvailableOutReachAccount.put('RI', 'Core_Programs_Available_for_Outreach__c');
        
        return mapAvailableOutReachAccount;
    }
    
    //Getter method which return the Map of list of account field api name as a value with businessline picklist value as a key
    public static Map<String,List<String>> getmapBusinessLineAccountsFields() {
        
  //Rajeev jain - 04/30/2019 - Overlapping Adjusted for Spring Cleanup, Removed few membership related fields
  
        Map<String,List<String>> mapBusinessLineAccount = new Map<String,List<String>>();
       mapBusinessLineAccount.put('PT', New List<String>{'Active_PT_Memberships__c', 'Paid_PT_Memberships__c', 'BI_Memberships__c' });
        mapBusinessLineAccount.put('RI', New List<String>{'Active_RI_Memberships__c', 'Active_RI_Memberships__c', 'Core_Memberships__c'});
        
        //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Academies_Memberships__c
        mapBusinessLineAccount.put('TD', New List<String>{'Active_TD_Memberships__c', 'Paid_TD_Memberships__c'/*, 'Academies_Memberships__c'*/});
        
        //Added by Abhinav Sharma - 08/27/2018 - CR-20180615-12286.
        mapBusinessLineAccount.put('RY', New List<String>{'Active_ES_Memberships__c','Paid_ES_Membership__c'});
        
        //Added by Mahendra Swarnkar - 06/15/2021 - CR-20210316-15001 - Starts from here
        mapBusinessLineAccount.put('YV', New List<String>{'Active_ES_Memberships__c','Paid_ES_Membership__c'});
        mapBusinessLineAccount.put('ES', New List<String>{'Active_ES_Memberships__c','Paid_ES_Membership__c'});
        //Added by Mahendra Swarnkar - 06/15/2021 - CR-20210316-15001 - Ends here
        
        return mapBusinessLineAccount;
    }
    
    //Commented as it is not performing any operation - Issue--CR14032--QA--00009867 - CR-20200508-14032
    /*    
    // this method is to populate the Relationship_Grade_Notes__c from the membership and put them on the associated Opportunity
    public static void UpdateRelationshipGradeNotes(List<Membership__c> memberships) {
        
        //Check if method need to be executed
        if(MembershipTriggerHelper.EXECUTE_UPDATE_RELATIONSHIP_GRADE_NOTES) {
        
            // get all membership Ids
            Set<Id> membershipIds = new Set<Id>();
            for (Membership__c membership : memberships) {
                membershipIds.add(membership.Id);
            }
            
            // list of Opportunities to update
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            
            //Checking for the set size value
            if(membershipIds.size() > 0) {
            
                //Loop through opportunity records
                for (Opportunity opp : [SELECT Name, Id, Membership__c, Relationship_Grade_Notes__c, Membership__r.Relationship_Grade_Notes__c
                                            FROM Opportunity 
                                            WHERE Membership__c != null AND Membership__c IN :membershipIds]) {
                    
                    //Checking for value change                            
                    if (opp.Relationship_Grade_Notes__c != opp.Membership__r.Relationship_Grade_Notes__c) {
                        opp.Relationship_Grade_Notes__c = opp.Membership__r.Relationship_Grade_Notes__c;
                        oppsToUpdate.add(opp);
                    }
                }
            }    
            
            //Checking list for size value
            if (oppsToUpdate.size() > 0) {
                
                // disable opportunity triggers
                Util.Isbatch = true;
                Util.byPassAllTriggers = true;
                update oppsToUpdate;
                Util.byPassAllTriggers = false;
                Util.Isbatch = false;
            }
        }
    }
    */
    //Modified By Abhinav sharma - 02/05/2018 - CR-20180828-12525 - Added Population of evergreen Fields. 
    //Modified By - Abhinav Sharma - 09/08/2014 - CR-20140515-5538
    //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Return void instead of List of membership
    // Take a list of memberships with their associated Events where Cancelled_Did_Not_Occur = false
    // and populates the Most_Recent_QA_Call_* fields with the appropriate info.
    public static void PopulateMostRecentQACall(Set<Id> memIds) {
        
        //Cheching size for null and size value
        if(memIds != null && memIds.size() > 0) {
            
            //Query Memberships associated to events
            //Bhavi - Where class criteria updated to fetch the Membership__c records having StartDateTime less than 60 days
            //Abhinav - Modified Where class criteria updated to fetch the Membersship__c record having StartDateTime less than 90 days
            //Mahendra - 5/11/2016 - CR-20160219-9619 - Modified to sort the Membership events as per their grades
            //Mahendra Swarnkar - 8/25/2016 - CR-20160725-10063 - Modified StartDateTime Criteria, Use label to get value
            //Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903 - Modified Event Type Criteria, to have Event_Type__c = 'RI QA Call' in the query string.
            //Dipesh Gupta - 08/02/2019 - CR-20190801-13252 - Modified Event Type Criteria, to have Event_Type__c = 'Phone Appointment' in the query string.
            //Modified by - Mahendra Swarnkar - 02/21/2020 - CR-20200131-13680  - Also query the (RecordType.DeveloperName) record type in query and add the record type in where caluse
            list<Membership__c> memList = [select id, Most_Recent_QA_Call_Date__c, Most_Recent_QA_Call_Grade__c, 
                                           Evergreen_Most_Recent_Call_Grade__c, Evergreen_Most_Recent_Call_Date__c, 
                                           Reason_for_No_QA_Call__c, Most_Recent_QA_Call_Recommend_Grade__c, 
                                           Most_Recent_QA_Call_Renew_Grade__c,RecordType.DeveloperName,
                                           (Select StartDateTime, Grade__c, Would_Refer__c, RecordType.DeveloperName, 
                                             Would_Buy_Again__c, EndDateTime, LastModifiedDate, Project_Sponsor_On_Call__c,
                                             Event_Purpose__c, Event_Type__c
                                            From Events  
                                            Where Cancelled_Did_Not_Occur__c = false 
                                             AND StartDateTime < :system.today().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)) 
                                             AND (Event_Type__c = 'PT QA Call' 
                                                 OR Event_Type__c = 'CM QA Call'
                                                 OR Event_Type__c = 'RI QA Call'
                                                 OR Event_Type__c = 'Phone Appointment'
                                                 OR recordType.DeveloperName = 'BI_QA_Call'
                                                ) 
                                            ORDER BY StartDateTime desc, Grade__c ASC
                                            LIMIT 5)
                                        from Membership__c
                                        where id in :memIds];
                                
            //loop through membership records
            for (Membership__c mem : memList) {
                //start blank
                mem.Most_Recent_QA_Call_Date__c = null;
                mem.Most_Recent_QA_Call_Grade__c = null;
        
                //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Set default values
                mem.Most_Recent_QA_Call_Recommend_Grade__c = null;
                mem.Most_Recent_QA_Call_Renew_Grade__c =null;
                        
                // CR-1669 - find the most recent Event that should count as the Most Recent QA Call
                Event mostRecentQAEvent;
            
                //Checking if size value is greater than 1
                if (mem.Events != null && mem.Events.size() > 0) {
                    
                    //Modified By - Mahendra - CR-20200131-13680 
                    /*Start */
                    if(mem.RecordType.DeveloperName == 'Enrollment') {
                        mostRecentQAEvent = PopulateMostRecentQACallForESMembership(mem.Events);    
                    } 
                    else {
                        /*End*/
                        // Event[0] is most recent, but we still need to see if other events occur on the same day
                        mostRecentQAEvent = mem.Events[0];
                        Date mostRecentQADate = mem.Events[0].StartDateTime.date();
                    
                        //Checking if size value is greater than 1
                        if (mem.Events.size() > 1) {
                        
                            // lists to hold events that need to be compared
                            List<Event> eventsOnSameDate = new List<Event>();
                            List<Event> eventsWithProjSponsor = new List<Event>();
                        
                            // add the most recent qa event to the appropriate list(s)
                            eventsOnSameDate.add(mostRecentQAEvent);
                        
                            if (mostRecentQAEvent.Project_Sponsor_On_Call__c == 'Yes')
                                eventsWithProjSponsor.add(mostRecentQAEvent);
                            
                            //Loop through events
                            for (Event evt : mem.Events) {
                                
                                // if the event occurs on the same date, add to the list to compare later
                                if (evt.Id != mostRecentQAEvent.Id && evt.StartDateTime.date() > mostRecentQADate) {
                                    
                                    // if the event has project sponsor = yes, then add to the project sponsor list
                                    if (evt.Project_Sponsor_On_Call__c == 'Yes')
                                        eventsWithProjSponsor.add(evt);
                                    
                                    EventsOnSameDate.add(evt);
                                    
                                }
                            }
                            
                            if (eventsWithProjSponsor.size() == 1) {
                                mostRecentQAEvent = eventsWithProjSponsor[0];
                            }
                            else if (eventsWithProjSponsor.size() > 1) {
                                
                                mostRecentQAEvent = eventsWithProjSponsor[0];
                            
                                // get the most recently modified event where Project sponsor = yes
                                for (Event evt : eventsWithProjSponsor) {
                                    if (evt.LastModifiedDate > mostRecentQAEvent.LastModifiedDate)
                                        mostRecentQAEvent = evt;
                                }
                            }
                        
                            // only find the event with the most recent last modified date if
                            // there are no events with project sponsor = 'yes'
                            if (eventsOnSameDate.size() > 1 
                                && eventsWithProjSponsor.size() == 0) {
                                
                                for (Event evt : eventsOnSameDate) {
                                    if (evt.LastModifiedDate > mostRecentQAEvent.LastModifiedDate)
                                        mostRecentQAEvent = evt;
                                }
                            }
                        }
                    }
                }
            
                /* Populate Most_Recent_QA_Call_Date and Most_Recent_QA_Call_Grade__c if there is such an event*/
                if (mostRecentQAEvent != null) {
                    mem.Most_Recent_QA_Call_Recommend_Grade__c = mostRecentQAEvent.Would_Refer__c;
                    mem.Most_Recent_QA_Call_Renew_Grade__c = mostRecentQAEvent.Would_Buy_Again__c;
                    mem.Most_Recent_QA_Call_Grade__c = mostRecentQAEvent.Grade__c;
                    
                    /*---Start ----- Modified By - Mahendra - CR-20200131-13680 */
                    if(mostRecentQAEvent.recordType.DeveloperName == 'BI_QA_Call') { 
                        mem.Most_Recent_QA_Call_Date__c = Date.newInstance(mostRecentQAEvent.EndDateTime.year(), mostRecentQAEvent.EndDateTime.month(), mostRecentQAEvent.EndDateTime.day()); 
                    } else {
                        mem.Most_Recent_QA_Call_Date__c = Date.newInstance(mostRecentQAEvent.StartDateTime.year(), mostRecentQAEvent.StartDateTime.month(), mostRecentQAEvent.StartDateTime.day());
                    }
                    /*------------End--------------*/
                    
        }
      }
            
            //Added By Abhinav sharma - 02/05/2018 - CR-20180828-12525 -- Starts from here
          //Map to hold the Membership records
          Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
          
          //Method call to populate the Evergreen fields on the Membership with most recent RI AM event
          mapMemberships = PopulateMostRecentRIAMEvent(memIds);
          
          //Loop over the Membership llist
          for(Membership__c memb : memList){
              
            //Check for conditions and then merge the Membership list and membership map
          if(mapMemberships.size() > 0 && mapMemberships.containsKey(memb.Id) && mapMemberships.get(memb.Id) != null ){
            
            memb.Evergreen_Most_Recent_Call_Date__c = mapMemberships.get(memb.Id).Evergreen_Most_Recent_Call_Date__c;
            memb.Evergreen_Most_Recent_Call_Grade__c = mapMemberships.get(memb.Id).Evergreen_Most_Recent_Call_Grade__c;
            mapMemberships.put(memb.Id, memb);
          }
          else{
            
            mapMemberships.put(memb.Id, memb);
          }
          }  
          //Added By Abhinav sharma - 02/05/2018 - CR-20180828-12525 -- Ends here
          
        
            //Bhavi Sharma - 01/19/2015 - CR-20141119-8126 - Update teh membership and return null
            if(mapMemberships.size() > 0 && mapMemberships.values() != null && mapMemberships.values().size() > 0) {
                Util.byPassAllTriggers = true;
                update mapMemberships.values();
                Util.byPassAllTriggers = false;     
            }
        }
    }        
    
    /**
     * 
     *  @description    :  This method return the most recent event of record type "Quality Assurance"
     * 
     *  @args           :   List<Event> newEvents
     *
     *  @return         :   List<Event>
     *
     *  @revision Log   :   V_1.0 - Created By Mahendra Swarnkar - 02/25/2019 - CR-20200131-13680
     * 
    **/
    public static Event PopulateMostRecentQACallForESMembership(List<Event> newEvents) {
        
        List<Event> events = new List<Event>();
        for(Event event : newEvents){
            if(event.recordType.DeveloperName == 'BI_QA_Call'){
                events.add(event);
            }
        } 
        
        if(events.size() > 0)
        	return events[0];
        else
            return null;
    }
    
    /**
     * 
     *  @description    :   This method is used to populate Evergreen fields ("Evergreen Most Recent Call Grade" and "Evergreen Most Recent Call Date") on Membership with most RI AM Events.
     *             			i.e When Event Type = In Person Visit or Phone Appointment, and Event Purpose = Evergreen Action
     *            			a) Evergreen Most Recent Call Grade - pull in the grade from the most recent RI AM Event when Event Purpose = Evergreen Action 
     *            			b) Evergreen Most Recent Call Date - pull in the event start date of the most recent associated RI AM Event when Event Purpose = Evergreen Action.  So therefore, if there are 2 events tagged to the Membership that have Event Purpose = Evergreen Action, pull in the most recent start date from today.
     *
     *  @args           :   Set<Id> MembershipIds
     *
     *  @return         :   Map<Id, Membership__c>
     *
     *  @revision Log   :   V_1.0 - Created By Abhinav sharma - 02/05/2018 - CR-20180828-12525
     * 
    **/
    public static Map<Id, Membership__c> PopulateMostRecentRIAMEvent(Set<Id> memIds) {
        
        //Map to hold the membership records 
    Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>(); 
        
        //Cheching size for null and size value
        if(memIds != null && memIds.size() > 0) {
            
            mapMemberships = new Map<Id, Membership__c>([select id, Evergreen_Most_Recent_Call_Grade__c, Evergreen_Most_Recent_Call_Date__c, 
                              (select StartDateTime, Grade__c, CreatedDate, Event_Purpose__c, Event_Type__c 
                                from Events  where Cancelled_Did_Not_Occur__c = false 
                                      //AND StartDateTime < :system.today().addDays(Integer.valueOf(System.Label.POPULATE_MOST_RECENT_QA_CALL_ADD_DAYS)) 
                                      AND StartDateTime < :system.today().addDays(1)
                                                   AND (Event_Type__c = 'In Person Visit' OR Event_Type__c = 'Phone Appointment')
                                      AND  Event_Purpose__c = 'Evergreen Action'
                                                   AND RecordType.DeveloperName = 'Core_AM'
                                      ORDER BY StartDateTime DESC, Grade__c ASC, CreatedDate DESC LIMIT 5)
                              from Membership__c where id in :memIds]);
                              
      //loop through membership records
            for (Membership__c mem : mapMemberships.values()) {
              
              //Set initial value
              mem.Evergreen_Most_Recent_Call_Date__c  = null;
                mem.Evergreen_Most_Recent_Call_Grade__c = null;
        
        //Event instance to hold most recent RI AM Event
                Event mostRecentRIAMEvent;
            
                //Checking if size value is greater than 1
                if (mem.Events != null && mem.Events.size() > 0) {
                    
                    // Event[0] is most recent, but we still need to see if other events occur on the same day
                    mostRecentRIAMEvent = mem.Events[0];
                    
                    //Checking if size value is greater than 1
                    if (mem.Events.size() > 1) {
                      
                        // lists to hold events that need to be compared
                        List<Event> eventsOnSameDate = new List<Event>();
                        
                        //Add the most recent RI AM event to the appropriate list(s)
                        eventsOnSameDate.add(mostRecentRIAMEvent);
                        
                        //Loop through events
                        for(Event evt : mem.Events) {
                            
                            // if the event occurs on the same date
                            if(evt.Id != mostRecentRIAMEvent.Id && evt.StartDateTime == mostRecentRIAMEvent.StartDateTime)
                EventsOnSameDate.add(evt);
                        }
                        
                        //Only find the event with the most recent last modified date
                        if(eventsOnSameDate.size() > 1 ) {
                            
                            for(Event evt : eventsOnSameDate) {
                                if (evt.CreatedDate > mostRecentRIAMEvent.CreatedDate)
                                    mostRecentRIAMEvent = evt;
                            }
                        }
                    }
                }
                
                //Check for the size
                if(mostRecentRIAMEvent != null) {
        
          //Populate some of the evergreen fields. 
          mem.Evergreen_Most_Recent_Call_Date__c = Date.newInstance(mostRecentRIAMEvent.StartDateTime.year(), mostRecentRIAMEvent.StartDateTime.month(), mostRecentRIAMEvent.StartDateTime.day());
          mem.Evergreen_Most_Recent_Call_Grade__c = mostRecentRIAMEvent.Grade__c;
        }
            }
    }
        
        //Return the map
        return mapMemberships;
  }
    
    
    //This method is to fetch the Associate value of the membership's record owner and 
    //populate Owner Associate with it
    //Modified By - Rajeev Jain - 10/04/2018 - CR-20180809-12494
    public static void populateOwnerAssociate(List<Membership__c> memberships, Map<Id, Membership__c> oldMapMembership) {
        
        //Create a set to hold the owner ids of membership records
        Set<Id> ownerIds = new Set<Id>();
        
        //loop through the membership records and pouplate the ownerIds with membership owners
        for(Membership__c membership : memberships) {
            
            //Check for Owner Id
            if(membership.OwnerId != null && (oldMapMembership == null || membership.OwnerId != oldMapMembership.get(membership.Id).OwnerId))
              ownerIds.add(membership.OwnerId);
        }
        
        //Check ownerIds and get owner related data
        if(ownerIds.size() > 0){
            
            //Map to hold the users data
            Map<Id, User> userMap = new Map<Id, User>([Select Id, Name, Associate__c from User where ID IN: ownerIds]);
            
            //Loop through the membership records and populate the Owner Associate data
            for(Membership__c membership : memberships) {
                
                //Check for Owner Name and Membership Owner Name - CR-20180809-12494
                if(userMap.containsKey(membership.OwnerId) && userMap.get(membership.OwnerId).Name != membership.Membership_Owner_Name__c) {
                    membership.Membership_Owner_Name__c = userMap.get(membership.OwnerId).Name;
                }
                
                //Check if map contains Membership owner and User has Associate populated on it
                if(userMap.containsKey(membership.OwnerId) && userMap.get(membership.OwnerId).Associate__c != membership.Owner_Associate__c) {
                    membership.Owner_Associate__c = userMap.get(membership.OwnerId).Associate__c;
                }
            }
        }
    }
    
    //Modified By - 1/23/2017 - Abhinav Sharma - CR-20170105-10596
    //Modified By - 09/20/2017 - Victor Hanson - Issue--CR11375--Other--00005836
    //Modified By - 09/20/2017 - Victor Hanson - Issue--CR11637--QA--00006855
    //Modified By - 06/20/2018 - Subhash Garhwal - CR-20180608-12273 - Updated the Subscription Stage check from Voider To Void.
    //This method is to update the Membership status text field on membership object whenever there is a change on Contract ABC record
    //Modified By - Subhash Garhwal - 09/28/2018 - CR-20180720-12456 - Added extra checks to reduce the SOQL count.
    //Modified By Dipesh Gupta - 08/28/2019 - CR-20190620-13190. updateMembershipStatusByContracts
    public static void updateMembershipStatusByContracts(List<Membership__c> listMembership) {
        
        //Create a set of Contract Ids related with membership records
        Set<Id> contracts = new Set<Id>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        //Set to hold Subscription Ids related to Membership
        Set<Id> setSubscriptionIds = new Set<Id>();
        
        //loop through the membership records and populate data in set
        for(Membership__c membership : listMembership) {
          
            //Add Active_Contract_Idenfied__c in set if not null
            if(membership.Active_Contract_Idenfied__c != null) {
                contracts.add(membership.Active_Contract_Idenfied__c);
            }
            //Add Earliest_Contract__c in set if not null
            if(membership.Earliest_Contract__c != null) {
                contracts.add(membership.Earliest_Contract__c);
            }
            //Add Latest_Contract__c in set if not null
            if(membership.Latest_Contract__c != null) {
                contracts.add(membership.Latest_Contract__c);
            }
            
            //Filling set with Subscription Ids
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
            if(membership.Earliest_Subscription__c != null)
              setSubscriptionIds.add(membership.Earliest_Subscription__c);
            if(membership.Active_Subscription__c != null)
              setSubscriptionIds.add(membership.Active_Subscription__c);
            if(membership.Latest_Subscription__c != null)
              setSubscriptionIds.add(membership.Latest_Subscription__c);
            
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
        }
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        //Map to hold Subscription records 
        Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        //Map of contracts
        Map<Id, Contract__c> mapContract = new Map<Id, Contract__c>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        //Checking for map size
        if(setSubscriptionIds.size() > 0){
          
          mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__StartDate__c, SBQQ__EndDate__c, Renewal_Opp_Stage__c, Status__c, SBQQ__Account__c, Program__c
                                      From  SBQQ__Subscription__c 
                                      Where Id IN : setSubscriptionIds]);
        }
        //Checking set for size value
        if(contracts.size() > 0) {
    
            //fetch related data from database from Contract ABC object
            mapContract = new Map<Id, Contract__c>([Select Id, Start__c, End__c, Status__c, Renewal_Opp_Status__c, Active_2__c,
                                                    Payer_Account__c 
                                                    from Contract__c
                                                    where ID IN: contracts]);
        }            
                                                                        
        //Temporary variable to hold the membership status
        String memberShipStatus;
        
        //Loop through the membership records and prepare the data set to be updated
        for(Membership__c membership : listMembership) {
            
            //VH added 3/20/17 - CR-20170110-10605
            //skip Royall memberships.  Royall memberships are populated based on Program Packages
            if (membership.Program_Business_Line__c == Label.Royall_Business_Line) continue;
            
            //reset membership status text
            memberShipStatus = '';
            
            //Check for map size
            if(mapSubscriptions.size() == 0 && mapContract.size() == 0)
                memberShipStatus = Constants.PROSPECT_PURE;
            
            //VH Modified 09/20/2017 - Issue--CR11375--Other--00005836
            //Determine which set of criteria should be applied when populating membership status
            boolean hasSubscriptions = (membership.Earliest_Subscription__c != null || membership.Active_Subscription__c != null || membership.Latest_Subscription__c != null);
            
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
            //Checking for map size. If Subscription records are exist then process on the Subsription otherwise process on the Contract
            if(hasSubscriptions && mapSubscriptions.size() > 0){
              
              //Check if Earliest_Subscription__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                if(
                    (
                        membership.Earliest_Subscription__c != null &&
                        mapSubscriptions.containsKey(membership.Earliest_Subscription__c) &&
                       (mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c == null
                     || mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c > Date.today())
                    )
                    || (
                        membership.Active_Subscription__c != null &&
                        mapSubscriptions.containsKey(membership.Active_Subscription__c) &&
                        mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__StartDate__c > Date.today()
                    )
                ) {
                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                }
                //If Active Subscription's SBQQ__EndDate__c is greater then today's date
                else if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                      && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c != null 
                      && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__EndDate__c >= Date.today()
                      && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__StartDate__c <= Date.today() //VH added 10/31/18 - CR-20181031-12723
                ) {
                    if(mapSubscriptions.get(membership.Active_Subscription__c).Status__c != null 
                         && mapSubscriptions.get(membership.Active_Subscription__c).Status__c == Constants.HONORARY) {
                          memberShipStatus = Constants.MEMBER_HONORARY;
                    } else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER){
                        memberShipStatus = Constants.MEMBER_PAYER;
                    }   
                    //Added By Dipesh Gupta - 08/28/2019 - CR-20190620-13190 -Starts here.
                    else if(membership.Payer_Status__c != null && membership.Payer_Status__c == Constants.PAYER_STATUS_INTEGRATED_GLOBAL) { //if program isn't related, it must be integrated global
                        memberShipStatus = Constants.MEMBER_PAYER_INTEGRATED_GLOBAL; //NOTE: MEMBER_PAYER_INTEGRATED_GLOBAL = 'Member - Integrated (Global)'
                    } 
                    // CR-20190620-13190 -Ends  here. 
                    else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED;
                    }
                }else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c != null 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != null 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c != ''
                          && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.PENDING)
                              || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))) 
                {
                    if (mapSubscriptions.get(membership.Latest_Subscription__c).Status__c  == Constants.HONORARY) {
                        memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                    } else if(mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c != null 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__Account__c == membership.Account_Name__c) 
                    {
                        memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                    } else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                    }
                        
                } else if(membership.Latest_Subscription__c != null && mapSubscriptions.containsKey(membership.Latest_Subscription__c) 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c < Date.today() 
                          && mapSubscriptions.get(membership.Latest_Subscription__c).SBQQ__EndDate__c > (Date.today() - 270)
                          && (mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.DROPPED
                              || mapSubscriptions.get(membership.Latest_Subscription__c).Renewal_Opp_Stage__c == Constants.VOIDER)) 
                {
                    memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                } else if(membership.Earliest_Subscription__c != null && mapSubscriptions.containsKey(membership.Earliest_Subscription__c) 
                          && mapSubscriptions.get(membership.Earliest_Subscription__c).SBQQ__StartDate__c >= date.newInstance(1960,01,01)) 
                {
                    
                    if(membership.Active_Subscription__c != null && mapSubscriptions.containsKey(membership.Active_Subscription__c) 
                       && mapSubscriptions.get(membership.Active_Subscription__c).SBQQ__StartDate__c > Date.today()) {
                           memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                       } else {
                           memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                       }   
                } else {
                    memberShipStatus = Constants.PROSPECT_PURE;
                }
            }
            
            //Modified By - Victor Hanson - 10/10/2017 - Issue--CR11637--QA--00006855
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
            if(mapContract.size() > 0 && 
               (!hasSubscriptions || 
                (memberShipStatus != null 
                 && mapContract.containsKey(membership.Active_Contract_Idenfied__c)
                 && mapContract.get(membership.Active_Contract_Idenfied__c).Active_2__c=='Active'
                 && !memberShipStatus.containsIgnoreCase('MEMBER') 
                 && membership.Active_Contract_Idenfied__c != null
                )
               )
            ) {
                  
                //Check if Earliest_Contract__r.Start__c is smaller then equals to today's date then set the Membership status as "Prospect - Pending Future Start Date"
                if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                   && (mapContract.get(membership.Earliest_Contract__c).Start__c == null 
                       || mapContract.get(membership.Earliest_Contract__c).Start__c > Date.today())) 
                {
                    memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                } 
                //If Active contract's end date is greater then today's date
                else if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                        && mapContract.get(membership.Active_Contract_Idenfied__c).End__c != null 
                        && mapContract.get(membership.Active_Contract_Idenfied__c).End__c >= Date.today()) 
                {
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
                              || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c.toLowerCase().contains(Constants.CONTRACT_RECEIVED))) 
                {
                    if (mapContract.get(membership.Latest_Contract__c).Status__c  == Constants.HONORARY) {
                        memberShipStatus = Constants.MEMBER_HONORARY_GRACE;
                    } else if(mapContract.get(membership.Latest_Contract__c).Payer_Account__c != null 
                              && mapContract.get(membership.Latest_Contract__c).Payer_Account__c == membership.Account_Name__c) 
                    {
                        memberShipStatus = Constants.MEMBER_PAYER_GRACE;
                    } else {
                        memberShipStatus = Constants.MEMBER_INTEGRATED_GRACE;
                    }
                } else if(membership.Latest_Contract__c != null && mapContract.containsKey(membership.Latest_Contract__c) 
                          && mapContract.get(membership.Latest_Contract__c).End__c < Date.today() 
                          && mapContract.get(membership.Latest_Contract__c).End__c > (Date.today() - 270)
                          && (mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.DROPPED
                              || mapContract.get(membership.Latest_Contract__c).Renewal_Opp_Status__c == Constants.VOIDER)) 
                {
                    memberShipStatus = Constants.PROSPECT_RECENT_DROP;
                } else if(membership.Earliest_Contract__c != null && mapContract.containsKey(membership.Earliest_Contract__c) 
                          && mapContract.get(membership.Earliest_Contract__c).Start__c >= date.newInstance(1960,01,01)) 
                {
                    if(membership.Active_Contract_Idenfied__c != null && mapContract.containsKey(membership.Active_Contract_Idenfied__c) 
                       && mapContract.get(membership.Active_Contract_Idenfied__c).Start__c > Date.today()) 
                    {
                        memberShipStatus = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                    } else {
                        memberShipStatus = Constants.PROSPECT_PAST_MEMBER;
                    }   
                } else {
                    memberShipStatus = Constants.PROSPECT_PURE;
                }  
            }
            
            //Checking for difference in between statuses
            if(memberShipStatus != null && memberShipStatus != '') {
                if (membership.Membership_Status_Text__c != memberShipStatus)
                    membership.Membership_Status_Change_Date__c = system.today();
                membership.Membership_Status_Text__c = memberShipStatus;
            }
        }
        
        //Update membership record in new list getting from OpportunityTriggerHelper
        if(OpportunityTriggerHelper.OPPORTUNITY_STATUS_FIELD_CHANGE_IS_THE_EVENT) {
            Util.byPassAllTriggers = true;
            update listMembership;
            Util.byPassAllTriggers = false;    
        }
    }
    
    //Modified By - Subhash Garhawal - 10/08/2018 - CR-20180504-12213 - Added 'Membership_Status__c' null check 
    //Updated by Abhinav sharma - 08/28/2018 - CR-20180615-12286 - Added condition for  Active ES Memberships Field on Institution. 
    //Modified by - Mahendra Swarnkar - 07/15/2015 - CR-20150520-8962
    //Modified by - Colin McGloin - 08/19/2019 - CR-20190730-13242 - Fixed how Research Memberships on Institution is populated post Spring Cleaning
    //Starts from here
    public static Account process_membership(Account a, List<Membership__c> memberships) {

        //Map to hold the different values. Will be helpful while further applying below written logic
        Map<String,String> mapAvailableOutReachAccountFields = MemberShipTriggerHelper.getmapAvailableOutReachAccountsFields();
        Map<String, List<String>> mapBusinessLineAccountFields = MemberShipTriggerHelper.getmapBusinessLineAccountsFields();
        
        // if the memberships list is null, return the account immediately without attempting to process
        if (memberships == null) return a;
    
        //Loop through Memberships on Account
        for (Membership__c mem : memberships) {
            
          	// check to see if the membership is active -- if so, add to the list of Active memberships VRH 3/5/12
            if (mem.Membership_Status__c != null 
                && !mem.Membership_Status__c.contains('Member - Payer')
                && mem.Program__c != null
                && mem.Program__r.Business_Line__c != null 
                && mapBusinessLineAccountFields != null
                && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null) {
          
                String paidValue;
          
          
                //Get value of the Account field   
                if(mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c) && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 2 && a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]) != null)
                    paidValue = String.valueOf(a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]));
    
                // make sure that the membership isn't already in the list
                if (paidValue != null) {
    
                    //Create set from existing data
                    Set<String> uniqueProgramAcronyms = new Set<String>();
    
                    //Split data by space and add in set 
                    uniqueProgramAcronyms.addAll(paidValue.split(Constants.SPACE));
    
                    //Check if the value is not null
                    if(uniqueProgramAcronyms.contains(mem.Program__r.Program_Acronym__c)) {
    
                        //Do the appropriate and expected replacements
                        paidValue = paidValue.replace(Constants.SPACE + mem.Program__r.Program_Acronym__c, '')
                                             .replace(mem.Program__r.Program_Acronym__c, '');
    
                        //Set value of the corresponding and applicable account field on record instance
                        a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue);
                    }
                }
            }
    
            // check to see if the membership is active -- if so, add to the list of Active memberships VRH 3/5/12
            if (mem.Membership_Status__c  != null
                && (mem.Membership_Status__c.contains('Member - Payer')
                    || mem.Membership_Status__c.contains('Member - Integrated')
                    || mem.Membership_Status__c.contains('Member - Honorary'))) {
    
                //Check for the business line
                if (mem.Program__c != null
                    && mem.Program__r.Business_Line__c != null
                    && mapBusinessLineAccountFields != null
                    && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null ) {
        			
                    //Get value from the Accout field as per the business line  
                    String activeValue;
                    String paidValue;
                    
                    if(mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c) && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 1 && a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[0]) != null)
                        activeValue = String.valueOf(a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[0]));
                        
                    if(mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c) && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 2 && a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]) != null)
                        paidValue = String.valueOf(a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1]));

                    // make sure that the membership isn't already in the list
                    if (activeValue != null && !activeValue.contains(mem.Program__r.Program_Acronym__c)) {
    
                        activeValue += Constants.SPACE + mem.Program__r.Program_Acronym__c + ' ';
                        a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[0], activeValue);
                    }
    
                    //Check for membership status
                    if(mem.Membership_Status__c != null
                        && mem.Membership_Status__c.contains('Member - Payer')) {
    
                        // make sure that the membership isn't already in the list
                        if (paidValue != null) {
    
                            //Check if the value is not null
                            if(!paidValue.contains(mem.Program__r.Program_Acronym__c)) {
                            
                                paidValue += Constants.SPACE + mem.Program__r.Program_Acronym__c;
                                
                                
                                if(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1] != 'Active_RI_Memberships__c'){
                                    a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue);
                                }
                            }  
                            
                        } else if(mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c) && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 2){
    
                            paidValue = Constants.SPACE + mem.Program__r.Program_Acronym__c;
                            if(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1] != 'Active_RI_Memberships__c'){
                                a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[1], paidValue );
                            }
                        }
                    }
                }
            }
    
            //Check for Program lookup on the membership
            if(mem.Program__c != null) {
    
                //Check for the Membership status and business line
                if (mem.Membership_Status__c != null
                    && mem.Membership_Status__c.startsWith('Member')
                    && mem.Program__r.Business_Line__c != null
                    && mapBusinessLineAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c) != null) {
    
                    //Added by Mahendra Swarnkar - 06/15/2021 - CR-20210316-15001 - Added Conditions for "ES" and "YV"   
                    // Get Sums of Renewal Unit Count and return to account
                    if (mem.Program__r.Business_Line__c == 'PT'
                        || mem.Program__r.Business_Line__c == 'RI'
                        || mem.Program__r.Business_Line__c == 'TD'
                        || mem.Program__r.Business_Line__c == 'CM'
                        || mem.Program__r.Business_Line__c == 'RY'
                        || mem.Program__r.Business_Line__c == 'ES'
                        || mem.Program__r.Business_Line__c == 'YV') {
    
                        //Checking map for size value    
                        if(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c).size() >= 3) {  
                            if(a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2]) != null) {
                                Decimal temp = (Decimal)a.get(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2]);
                                temp += mem.Renewal_Unit_Count__c != null ? mem.Renewal_Unit_Count__c : 0;
                                a.put(mapBusinessLineAccountFields.get(mem.Program__r.Business_Line__c)[2], temp);
                            }    
                        }        
                    }
                }
    
                // Get Program Acronyms of Programs Available for Outreach and return to account
                if(mem.Prospect_Status__c == 'Available for Outreach'
                    && mem.Renewal_Unit_Count__c == 1 
                    && mem.Program__r.Program_Acronym__c != null
                    && mem.Program__r.Business_Line__c != null
                    && mapAvailableOutReachAccountFields.containsKey(mem.Program__r.Business_Line__c)
                    && mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c) != null ) {
    
                    if(a.get(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c)) != null) {     
                        String temp = (String) a.get(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c));
                        temp += mem.Program__r.Program_Acronym__c + ' ';
                        a.put(mapAvailableOutReachAccountFields.get(mem.Program__r.Business_Line__c), temp);
                    }        
                }
            }
      
       //Subhash Garhawal - 10/08/2018 - CR-20180504-12213 - Added 'Membership_Status__c' null check 
       //VH added 9/10/2018 - CR-20180803-12480
            if (mem.Membership_Status__c != null
              && mem.Membership_Status__c.startsWith('Member')
                && mem.Program__r.Integration_Support__c != null 
                && mem.Program__r.Integration_Support__c.containsIgnoreCase(Constants.ZENDESK)
                && !a.Zendesk_Support__c) 
            {
                a.Zendesk_Support__c = true;
            }
        }
    
        return a;
    }
    //Ends here

    //Modified By - Neha Sharma - CR-20200930-14569 - 11/03/2020 - Commented out all values which update Membership Owner
    //CR-20120208-389 - Moved teh logic from Membership_PopulateAssignedMarketer trigger to new method
    //Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902
    //Modified By - Dipesh Gupta - 01/24/2020 - CR-20191204-13547 -- Bypassed the logic for Active subscription 
    //Modified By - Chirag Soni - 07/26/2021 - CR-20210621-15227 -- added new check IsTrigger_ContractIntegratedAcctRunning  
    //Modified By - Mahendra Swarnkar - 11/19/2021 - CR-20211117-15586 - Added the Zendesk_Support__c field in the query
    public static void membershipPopulateAssignedMarketer(List<Membership__c> newMemberShips, Boolean isBefore) {
        
        /*
        Purpose:    This Trigger populates the Assigned_Marketer__c field on the Membership object based on following logic
                    Program__r.New_Business_Marketer__c (text) is used to query AccountTeamMembers for the associated Account: 
                    Role = New_Business_Marketer__c
                    The resulting user is then set as Assigned_Marketer__c field
                    
                    Populates Membership Name based on the following criteria: <Account Name truncated to 55 characters> - <Program Acronym>
                    
                    Removes Earliest_Contract__c, Latest_Contract__c, and Active_Contract_Idenfied__c when Program or Account is null. 
                    
                    Populates Account fields 
                        RI Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'RI'
                        PT Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'PT'
                        TD Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'TD'
                        CM Memberships: sum of Renewal_Unit_Count__c on Memberships on Account where Membership__r.Program__r.Business_Line__c = 'CM'
                    
                    Updates OwnerID field based on the following criteria:
                    if (Membership_Status__c contains 'Prospect')
                        OwnerID = assigned marketer
                    else
                        OwnerID = owner of active contract renewal opportunity.
                    
        
        Create By:  Angela Williams (SAP Contractor)            
        
        Last Modified By:   Nathan Banas (SAP) - 1/24/2011
        
        Current Version:    v1.3
        
        Revision Log:       v1.0 - (AW) Created code
                            v1.1 - (JN-2010-12-15) Added requirements to update Account fields:
                                    RI Memberships
                                    PT Memberships
                                    TD Memberships
                                    CM Memberships
                            v1.2 - (NB-2011-01-19) Added requirements to update OwnerID field based on the following criteria:
                                    if (Membership_Status__c contains 'Prospect')
                                        OwnerID = assigned marketer
                                    else
                                        OwnerID = owner of active contract renewal opportunity.
                            v1.3 - (NB-2011-01-24) Added line to trigger to account for validation rule failures and bypass.  Code coverage reduced to 96%.
                            v1.4 - (Bhavi - 02/07/2012) Flag added not to execute the trigger if membership is updating as a result of user trigger
        Code Coverage as of 1/20/2011: 97%
        */  
        // Bypass this trigger if it is being called by another process
        if (system.isBatch() 
            || (system.isFuture() && Util.IsTrigger_ContractIntegratedAcctRunning) //- 07/26/2021 - CR-20210621-15227 - added new check IsTrigger_ContractIntegratedAcctRunning
            || Util.IsTrigger_ContractFieldUpdate 
            || Util.IsTrigger_Opportunity_ValidationAndFieldUpdates 
            || Util.IsTrigger_EventPrewire 
            || Util.IsTrigger_EventUpdateFields
            || Util.IsTrigger_ContractIntegratedAcctRunning
            || Util.IsMembershipOwnerAssociateTrigger
            || Util.BypassAllTriggers
            || Util.isShadowContractABC // CM - Added 07/27/2017 to bypass SOQL Query Limit Issues being experienced on AddContractsToInvoiceBillingSchedule
            || bypassMembershipPopulateAssignedMarketer
      ) {
                // if any of these conditions are true, return immediately without processing
                return;
        }
          
        //This map holds all the new membership records being loaded
        Map<Id,Membership__c> membershipMap = new Map<Id,Membership__c>();
    
        //This list will hold all the account ids for the new Memberships
        List<Id> accIdList = new List<Id>();
    
        // Map to store Program Acronyms w/ the Program Id as the key
        Map<Id, String> progMap = new Map<Id, String>();
        
        // List to store program Ids
        List<Id> progIds = new List<Id>();
        
        // List to store Active Contract Ids
        //Comment By Bhavi - 02/02/2013 - Instead of List, Used Set to prevent from the duplicate Ids and unnecessary execution
        //List<Id> activeContractIds = new List<Id>();
        Set<Id> activeContractIds = new Set<Id>();
        Set<Id> latestContractIds = new Set<Id>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        //Set to hold Active Subscription and Latest Contract
        Set<Id> activeSubscriptionIds = new Set<Id>();
        Set<Id> latestSubscriptionIds = new Set<Id>();
        
        // Map to store Programs w/ Membership Id as the key
        Map<Id, Program__c> memToProgMap = new Map<Id, Program__c>();
        
        for(Membership__c mem: newMemberShips) {
        
            // Build a map of of Memberships related to Membership Ids
            membershipMap.put(mem.Id, mem);
            
            // Build a List of Account Ids
            accIdList.add(mem.Account_Name__c);
            
            // First step in building a map of New Business Marketers relating to Program Ids
            progMap.put(mem.Program__c, null);
            
            if(mem.Program__c != null)
                progIds.add(mem.Program__c);
                
             // NB 1/19/11 - Added below section to allow for Ownership updates
            if(mem.Active_Contract_Idenfied__c != null) {
            
                //Add Id In Set
                activeContractIds.add(mem.Active_Contract_Idenfied__c);
            
            } else if(mem.Latest_Contract__c != null) {
                
                //Bhavi - 02/02/2013 - CR-20121212-1898
                
                //If Active Contract is null, use latest Contract to Populate Owner
                latestContractIds.add(mem.Latest_Contract__c);
            }
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
            /*// Commented by : Dipesh Gupta - 01/24/2020 - CR-20191204-13547 -- Start here 
            if(mem.Active_Subscription__c != null)
                activeSubscriptionIds.add(mem.Active_Subscription__c);
            
            // Commented by : Dipesh Gupta - 01/24/2020 - CR-20191204-13547 -- Start here */
            
            else if(mem.Latest_Subscription__c != null)
                latestSubscriptionIds.add(mem.Latest_Subscription__c);
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
        }
        
        // Map to store Accounts w/ the Account Id as the key 
        Map<Id,Account> accountMap = new Map<Id,Account>();
        
        //Map of contracts
        Map<Id, Contract__c> mapContracts = new Map<Id, Contract__c>();
        
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114)
        
        //Map to hold Subscription records
        Map<Id, SBQQ__Subscription__c> mapSubscriptions = new Map<Id, SBQQ__Subscription__c>();
        
        //Checking for subscription list size if not null then query on the Subscription otherwise query on the Contract ABC
        if(activeSubscriptionIds.size() > 0 || latestSubscriptionIds.size() > 0){
          
          //Commented by : Dipesh Gupta - 01/24/2020 - CR-20191204-13547 - Commented  "Id IN : activeSubscriptionIds OR" code block in the query
          //Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Add "Renewal_Opportunity__r.Owner.IsActive" to the soql query
          //Query on the Subscription
          mapSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__Account__c, Renewal_Opportunity__c, Renewal_Opportunity__r.OwnerId, Renewal_Opportunity__r.Owner.IsActive, SBQQ__Account__r.OwnerId 
                                      From SBQQ__Subscription__c
                                      Where (/*Id IN : activeSubscriptionIds OR */Id IN : latestSubscriptionIds) 
                                        AND Renewal_Opportunity__c != null]);
        }
        //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
        
        //Checking set for size value
        else if(latestContractIds.size() > 0 || activeContractIds.size() > 0) {
        
            // Query for all related Active Contracts meeting criteria necessary to perform the steps within this code
            
            //Commented By Bhavi - 02/02/2013 - instead of List, Used map to reduce the looping statement
            //List<Contract__c> activeContracts = [Select Id, Payer_Account__c, Contract_Renewal_Opportunity__c, Contract_Renewal_Opportunity__r.OwnerId, Payer_Account__r.OwnerId from Contract__c where Id in :activeContractIds]; // NB 1/19/11 - Added to allow for Ownership updates
            mapContracts = new Map<Id, Contract__c>([Select Id, Payer_Account__c, 
                                                        Contract_Renewal_Opportunity__c, Contract_Renewal_Opportunity__r.OwnerId, 
                                                        Payer_Account__r.OwnerId 
                                                        FROM Contract__c 
                                                        WHERE (Id in :activeContractIds OR Id IN: latestContractIds) 
                                                          AND Contract_Renewal_Opportunity__c != null]);
        }    
        
        //Build a map of Contract_Renewal_Opportunity__c Owner Ids relating to Membership Ids
        Map<Id, Id> membToActContrOwner = new Map<Id, Id>();
        
        //Loop through memberships calling this trigger
    for(Membership__c mem: newMemberShips) {
          
            //Commented by : Dipesh Gupta - 01/24/2020 - CR-20191204-13547 - Starts from here
            //Modified By - Subhash Garhwal - 01/30/2018 - CR-20180126-11902 - Check that the owner is active prior to adding the record to the membToActContrOwner map
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - If subscription records are extreacted then process with Subscription records otherwise contract records
		/*if(mem.Active_Subscription__c != null && mapSubscriptions.containsKey(mem.Active_Subscription__c)
              && mapSubscriptions.get(mem.Active_Subscription__c).Renewal_Opportunity__r.Owner.IsActive)
        membToActContrOwner.put(mem.Id, mapSubscriptions.get(mem.Active_Subscription__c).Renewal_Opportunity__r.OwnerId);
		else*/
		//Commented by : Dipesh Gupta - 01/24/2020 - CR-20191204-13547 - Ends here
        if(mem.Latest_Subscription__c != null && mapSubscriptions.containsKey(mem.Latest_Subscription__c)
          && mapSubscriptions.get(mem.Latest_Subscription__c).Renewal_Opportunity__r.Owner.IsActive)
              membToActContrOwner.put(mem.Id, mapSubscriptions.get(mem.Latest_Subscription__c).Renewal_Opportunity__r.OwnerId);
            
            //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
            
	    // If the Active Contract Identified field is not empty then process
            // If the Contract Id equals the Membership Active Contract Identified field value 
            //&& the Contract Renewal Opportunity field on Contracts isn't null, then process
            else if(mem.Active_Contract_Idenfied__c != null && mapContracts.containsKey(mem.Active_Contract_Idenfied__c)) {
            
                // Add the Contract's Contract Renewal Opportunity to a map with Membership Id as the key
                membToActContrOwner.put(mem.id, mapContracts.get(mem.Active_Contract_Idenfied__c).Contract_Renewal_Opportunity__r.OwnerId);
            
            } else if(mem.Latest_Contract__c != null && mapContracts.containsKey(mem.Latest_Contract__c)) {
                
                //Bhavi - 02/02/2013 - CR-20121212-1898
                
                // If the Active Contract Identified field is not empty then process
                // If the Contract Id equals the Membership Active Contract Identified field value 
                //&& the Contract Renewal Opportunity field on Contracts isn't null, then process
            
                // Add the Contract's Contract Renewal Opportunity to a map with Membership Id as the key
                membToActContrOwner.put(mem.id, mapContracts.get(mem.Latest_Contract__c).Contract_Renewal_Opportunity__r.OwnerId);
            }
             
        }
        
        //Checking list for size value
        if(accIdList.size() > 0) {
	    //Modified By Rajeev Jain - 04/30/2019 - CR-20190425-13032 - Spring Cleanup overlapping adjusted, removed few membership fields
            //Modified By Abhianv sharma - 08/29/2018 - CR-20180615-12286 - Added Paid_ES_Membership__c field this in the Query.
            //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
            // Build a map of Accounts relating to Account Ids
            //Modified by Bhavi Sharma - 03/18/2014 - Removed inline queries and used direct queries for assignment
            //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 - Academies_Memberships__c
            //Modified By - Mahendra Swarnkar - 11/19/2021 - CR-20211117-15586 - Added the Zendesk_Support__c field in the query
            for(Account acc: [select Id, Name, Core_Memberships__c, BI_Memberships__c, /*Academies_Memberships__c,*/
                                Paid_PT_Memberships__c,
                                Paid_TD_Memberships__c, Paid_ES_Membership__c, Zendesk_Support__c
                                from Account 
                                where Id IN: accIdList]) {
            
                accountMap.put(acc.Id, acc);
            }
        }    
        
        //Create a map of membership to hold teh memebership related to accounts
        Map<Id, List<Membership__c>> mapAccMemberships = new Map<Id, List<Membership__c>>();
        Map<Id, List<AccountTeamMember>> mapAccTeamMembers = new Map<Id, List<AccountTeamMember>>();
        
        boolean processAccMemberships = true;
        
        //Checking map for size value
        if(accountMap.keySet().size() > 0) {
            
            //Added Check for Business Lines 'YV' and 'ES' - CR-20210316-15001 - Mahendra Swarnkar - 06/29/2021
            //Added by Abhinav Sharma - 08/29/2018 - CR-20180615-12286 - Added RY in the Program__r.Business_line__c Where Clause. 
            //CR-20160210-9596 - get the total number of memberships related to the corresponding accounts.
            //if the count is greater than 10,000 then do not process account memberhips, because it
            //will cause us to go over the CPU limit.  Instead, these records will be updated by the nightly Batch_Account_OutreachProgs_v2 job
            integer numAccMemberships = [SELECT COUNT()
                                         FROM Membership__c where Program__r.Business_line__c in ( 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN', 'RY', 'YV', 'ES') 
                                         AND Account_Name__c IN: accountMap.keySet() LIMIT 10001];
            
            if (numAccMemberships > 10000) 
                processAccMemberships = false;
            
            //CR-20160210-9596 - mapAccMemberships is only used in the case where this is after trigger, so only populate it in that instance.
            if (!isBefore && processAccMemberships) {
                //Added Check for Business Lines 'YV' and 'ES' - CR-20210316-15001 - Mahendra Swarnkar - 06/29/2021
                //Fetch memberships related to account and popuplate map
                for(Membership__c m : [Select Id, Account_Name__c, Membership_Status_Text__c, Program__r.Business_Line__c, Program__r.Program_Acronym__c, 
                                       Prospect_Status__c, Membership_Status__c, Renewal_Unit_Count__c, Program__r.Integration_Support__c
                                       from Membership__c where Program__r.Business_line__c in ( 'RI', 'PT', 'TD', 'CM', 'SW', 'CLN', 'RY', 'YV', 'ES') 
                                       AND Account_Name__c IN: accountMap.keySet()]) {
                                           
                                           //Check if account has already been added in Map
                                           if(!mapAccMemberships.containsKey(m.Account_Name__c))
                                               mapAccMemberships.put(m.Account_Name__c, new List<Membership__c>());
                                           mapAccMemberships.get(m.Account_Name__c).add(m);
                 }
            }
        
            //Fetch team members and populate in map
            for(AccountTeamMember aTM : [Select AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId IN: accountMap.keySet()]) {
                
                //Check if account has already been added in Map
                if(!mapAccTeamMembers.containsKey(aTM.AccountId))
                    mapAccTeamMembers.put(aTM.AccountId, new List<AccountTeamMember>());
                mapAccTeamMembers.get(aTM.AccountId).add(aTM);
            }
        } 
        
        //List of programs
        List<Program__c> programs = new List<Program__c>();
        map<id, Program__c> progid2progmap = new Map<Id, Program__c>();
        
        //Checking set for size value
        if(progIds.size() > 0) {
        
            // Query for all related Programs
            programs = [select Id, New_Business_Marketer__c, Business_line__c, Program_Acronym__c from Program__c where Id in :progIds];
        
            // Build a Map of Programs w/ Program Id as their key
            progid2progmap = new map<id, Program__c>(programs);
        
            // Loop through related Programs and add them to a map
            for(Program__c prgm: programs) {
            
                // Second step in building a map of New Business Marketers relating to Program Ids
                progMap.put(prgm.Id, prgm.New_Business_Marketer__c);
            }
        }    
        
        // Process only if the Trigger is a before trigger
        if (Trigger.IsBefore) {
        
            //Modify By - Abhinav Sharma - 04/30/2015 - CR-20121218-1964
            //replace membershipMap.values () with newMemberShips (Trigger.new list)
            /* Set Membership name */ 
            for (Membership__c mem : newMemberShips) {
            
                //Set naming convention in case the name is edited
                if(progid2progmap.containsKey(mem.Program__c) && progid2progmap.get(mem.Program__c) != null) {
             
                    Program__c prog = progid2progmap.get(mem.Program__c);
                    String accname = accountMap.get(mem.Account_Name__c) != null ? accountMap.get(mem.Account_Name__c).Name : '';
                    Integer maxaccnamelength = 55;
                    String suffix = ' - ';
                
                    if ((prog != null) && (prog.Program_Acronym__c != null) && (prog.Program_Acronym__c != 'null'))
                        suffix += prog.Program_Acronym__c;
                        
                    accname = accname.substring(0,(Math.min(maxaccnamelength, accname.length())));
                    mem.Name = accname + suffix;
                }
            }                
            
            /* Set Assigned Marketer */
                
            // This map will hold the mapping for membership record along with the identified Assigned Marketer
            Map<Id, String> membershipUserIdMap = new Map<Id, String>();
            
            for(Id idVal: membershipMap.KeySet()) {
                
                Membership__c mem = membershipMap.get(idVal);
                    
                //find Assigned Marketer
                if(accountMap.get(mem.Account_Name__c) != null) {
                    
                    List<AccountTeamMember> members = new List<AccountTeamMember>();
                        
                    if(mapAccTeamMembers.containsKey(mem.Account_Name__c))
                        members = mapAccTeamMembers.get(mem.Account_Name__c);
                        
                    // Loop through Account Team Members
                    for(AccountTeamMember membr: members) {
                            
                        // If the Program's New Business Marketer matches the current Account Team Member,
                        // add it to a map of Key: Membership Id / Value: Account Team Member User Id
                        // DAF - changed 9/27/11 & 10/1/11      if(progMap.get(mem.Program__c) == membr.TeamMemberRole)
                        if (progMap.get(mem.Program__c) != null) {
                            if(membr.TeamMemberRole.contains(progMap.get(mem.Program__c)))
                                membershipUserIdMap.put(mem.Id, membr.UserId);
                        }
                    }
                }
            }
            
            // Loop through each membership
            for(Membership__c mem: newMemberShips) {
                
                //Added by Abhinav Sharma - CR-20200717-14329.
                //Bypass this process for the Enrollment Record type. 
                if(mem.RecordTypeId == Constants.Membership_Record_Type_Enrollment)
                    continue;
                // Process only if the trigger is a before trigger
                if(isBefore) {
                        
                    // Set assigned Marketer
                    mem.Assigned_Marketer__c =  membershipUserIdMap.get(mem.Id);
                        
                    // Nathan B 1/5/11 - Added to set Active, Earliest, Latest Contract to Null when Program OR Account is null
                    if(mem.Account_Name__c == null || mem.Program__c == null) {
                        mem.Earliest_Contract__c = null;
                        mem.Latest_Contract__c = null;
                        mem.Active_Contract_Idenfied__c = null;
                        
                       //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Following 3 fields are added.
                       mem.Earliest_Subscription__c = null;
                       mem.Latest_Subscription__c = null;
                       mem.Active_Subscription__c = null;
                       //V_3.8 - Modified By - Saurabh Kumar - 06/06/2017 - CR-20170403-10807 (DS114) - Upto here
                    }
                }
    
            }
        }
            
        // Process only if the trigger is an after trigger
        if (!isBefore) {
            
            // Build Program To Membership Map
            for(Membership__c mem: newMemberShips) {
                
                if(mem.Program__c != null) {
                    
                    for(Program__c p : programs) {
                        
                        if(mem.Program__c == p.Id) {
                            
                            memToProgMap.put(mem.Id, p);
                            
                            break;
                        }   
                    }
                }
            }
                
            /*
            Count the four different kinds of Memberships by Account
            Also provide the Program Acronyms for three different kinds of memberships            
            */
            
            //If statement for flag check - Added By - Mahendra Swarnakar - 09/15/2016 - CR-20160519-9865
            //Checking for flag which is responsible for handling the case when children are more than 10000 in count
            if(processAccMemberships) {
                
                // Loop through Accounts related to the Memberships that called this trigger
                //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
                for (Account a : accountMap.values()) {
                
                    // Zero out the 4 kinds of Membership Counts on this Account & the 3 kinds of Membership Program Acronyms
                    a.Core_Memberships__c = 0;
                    a.BI_Memberships__c = 0;
                    
                    //Commented by Abhinav Sharma- 08/11/2020 - CR-20180808-12492 
                    //a.Academies_Memberships__c = 0;
                    
                    a.Core_Programs_Available_for_Outreach__c = '';
                    a.Academy_Programs_Available_for_Outreach__c = '';
                    a.BI_Programs_Available_for_Outreach__c = '';
                    
                    // clear out active membership list
                    a.Active_RI_Memberships__c = '';
                    a.Active_PT_Memberships__c = '';
                    
                    a.Active_TD_Memberships__c = '';
                    
                    //Added by Abhinav sharma - Active_ES_Memberships __c for CR-20180615-12286
                    a.Active_ES_Memberships__c = '';
                      
                    // get a list of memberships from the institution to pass in to the process_Membership method
                    List<Membership__c> memberships = new List<Membership__c>();
                    if(mapAccMemberships.containsKey(a.Id))
                        memberships = mapAccMemberships.get(a.Id);
                    a = process_membership(a, memberships); 
                    
                    // Format the Programs Available for Outreach to remove blank spaces and ensure the max length is not exceeded then return the results to account
                    if (a.Academy_Programs_Available_for_Outreach__c != '')
                        a.Academy_Programs_Available_for_Outreach__c = 
                            a.Academy_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Academy_Programs_Available_for_Outreach__c.trim().length()));
                    if (a.BI_Programs_Available_for_Outreach__c != '')
                        a.BI_Programs_Available_for_Outreach__c = 
                            a.BI_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.BI_Programs_Available_for_Outreach__c.trim().length()));
                    if (a.Core_Programs_Available_for_Outreach__c != '')
                        a.Core_Programs_Available_for_Outreach__c = 
                            a.Core_Programs_Available_for_Outreach__c.trim().substring(0,Math.min(255, a.Core_Programs_Available_for_Outreach__c.trim().length()));
                }
            
                // Update accounts
                //Modified By Abhinav Sharma - 02/13/2014 - CR-20130911-3628 - Refactor the MembershipTriggerHelper.membershipPopulateAssignedMarketer method so it doesn't attempt to directly assign Accounts to the AccountList   
                if (accountMap.values().size() > 0) {
                  Util.byPassAllTriggers = true;
                  update accountMap.values();
                  Util.byPassAllTriggers = false;
                }
            }        
        }
    }
    
    //Modified By - Subhash Garhwal - 09/26/2018 - CR-20180720-12456 - Added extra checks to reduce the SOQL count.
    //This method is to populate data in key contact
    public static void populateContactData(List<Membership__c> memberShips, Map<Id, Membership__c> oldMapMemberships) {
        
        //Create a set to hold the appropriate membership records ids
        Set<Id> membershipIds = new Set<Id>();
        
        //Loop through the membership records and get all the records and add in set where Status starts with Membership
        for(Membership__c membership : memberShips) {
            
            //Added extra checks - Subhash Garhawal - CR-20180720-12456 
            //check for teh status value
            if(membership.Membership_Status__c != null && membership.Membership_Status__c.startsWith(Constants.MEMBER ) 
              && oldMapMemberships != null && membership.Membership_Status__c !=  oldMapMemberships.get(membership.Id).Membership_Status__c) {
                
                //Add membership Id in set
                membershipIds.add(membership.Id);
            }       
        }
        
        //Create a Map to hold the contact data and maintain the uniqueness
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        
        //Check id there are records to process
        if(membershipIds.size() > 0) {
            
            //get appropriate Membership Key Contacts from database
            for(Membership_Key_Contact__c mKC : [Select Id, Pubs__c, Meetings__c, Membership__c, Membership__r.Program_Acronym__c, 
                    Contact__c, Contact__r.Membership_Contact_Pubs__c, Contact__r.Membership_Contact_Meetings__c from Membership_Key_Contact__c 
                    where Membership__c != null AND Membership__r.Program_Acronym__c != null AND Membership__r.Program_Acronym__c != '' 
                    AND Membership__c IN: membershipIds AND Contact__c != null AND (Pubs__c = true OR Meetings__c = true)]) {
                
                //Contact cloneContact
                Contact cloneContact;
                
                //Check for the contact and update contact's data
                if(mapContact.containsKey(mKC.Contact__c)) {
                    
                    //Get the contact record from map
                    cloneContact = mapContact.get(mKC.Contact__c); 
                } else {
                    
                    //Create a contact clone
                    cloneContact = new Contact(Id = mKC.Contact__c, Membership_Contact_Pubs__c = mKC.Contact__r.Membership_Contact_Pubs__c, 
                                                Membership_Contact_Meetings__c = mKC.Contact__r.Membership_Contact_Meetings__c);
                }
                
                //Populate Membership_Contact_Pubs__c field data
                if(mKC.Pubs__c == true) {
                    if(cloneContact.Membership_Contact_Pubs__c != null && cloneContact.Membership_Contact_Pubs__c != '' 
                            && (!cloneContact.Membership_Contact_Pubs__c.contains(mKC.Membership__r.Program_Acronym__c))) {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Pubs__c += ', ' + mKC.Membership__r.Program_Acronym__c;
                    } else {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Pubs__c = mKC.Membership__r.Program_Acronym__c;
                    }
                }
                
                //Populate Membership_Contact_Meetings__c field data
                if(mKC.Meetings__c == true) {
                    if(cloneContact.Membership_Contact_Meetings__c != null && cloneContact.Membership_Contact_Meetings__c != '' 
                            && (!cloneContact.Membership_Contact_Meetings__c.contains(mKC.Membership__r.Program_Acronym__c))) {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Meetings__c += ', ' + mKC.Membership__r.Program_Acronym__c;
                    } else {
                            
                        //Set program acronym in cloneContact
                        cloneContact.Membership_Contact_Meetings__c = mKC.Membership__r.Program_Acronym__c;
                    }
                }
                    
                //Put the contact record in map
                mapContact.put(mKC.Contact__c, cloneContact);
            }
            
            //Check if there are records to update
            if(mapContact.size() > 0) {
                // we only want to populate 2 fields on the contact
                // so bypass all triggers when updating
                Util.BypassAllTriggers = true;
                update mapContact.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Added By - Ajit Surana - 03/28/2015 - CR-20150312-8758
    /**
     *  @description    :   Method is used to populate the Industry Member as true, if there is any child membership record with ÃƒÂ¯Ã‚Â¿Ã‚Â½Industry Member = trueÃƒÂ¯Ã‚Â¿Ã‚Â½.
     *
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *            	    V1.0 - Modified By - Subhash Garhwal - 09/26/2018 - CR-20180720-12456 - Commented out logic to reduce the SOQL count.
     *         		    V1.1 - Modified by Subhash Gharwal -29-04-2019 - Spring cleanup - CR-20190425-13035  
     **/
     public static void populateIndustryMemberOnAccount(List<Membership__c> newMemberships, Map<Id, Membership__c> mapOldMemberships) {
    
        /*//Set to hold Account Id of Membership record
        Set<Id> accIds = new Set<Id>();
        
        //Insert or update use cases
        if(newMemberships!= null) {
        
            //Loop through Trigger.new
            for(Membership__c newMembership : newMemberships) {
                
                //Commented By - Subhash Garhawal - CR-20180720-12456
                //Check for AccountId not null & adding AccountId into set
                //if(newMembership.Account_Name__c != null)    
                  //  accIds.add(newMembership.Account_Name__c);
                
                //Check if Account is update on Membership record
                if(mapOldMemberships != null && (newMembership.Program__c != mapOldMemberships.get(newMembership.Id).Program__c
                    || newMembership.Account_Name__c != mapOldMemberships.get(newMembership.Id).Account_Name__c)) {
                    
                    if(newMembership.Account_Name__c != null)
                        accIds.add(newMembership.Account_Name__c);
                        
                    if(mapOldMemberships.get(newMembership.Id).Account_Name__c != null)
                        accIds.add(mapOldMemberships.get(newMembership.Id).Account_Name__c);
                }
            }
        //Delete use cases
        } else {
            
            //Loop through Trigger.new
            for(Membership__c oldMembership : mapOldMemberships.values()) {
                
                //Check for null & adding ProjectId into set
                if(oldMembership.Account_Name__c != null)    
                    accIds.add(oldMembership.Account_Name__c);
            }
        }
        
        //Checking set for size value
        if(accIds.size() > 0){
            
            //Set to hold Account Ids
            Set<Id> tempSetIDs = new Set<Id>();
            
            //Making a clone
            tempSetIDs.addAll(accIds);
            
            //Map of Account
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
            //AggregateResult to get count of Membership for each Account
            for (AggregateResult ar: [Select Count(Id) MembershipCount, Account_Name__c accName From Membership__c 
                                        Where Account_Name__c != null AND Account_Name__c IN: accIds AND Industry_Member__c = true
                                        AND Active_Core_Membership__c = 1 GROUP BY Account_Name__c]){
                if(ar.get('accName') != null) { 
                    Account acct = new Account(Id=(Id)ar.get('accName'), Industry_Member__c = true);
                    mapAccounts.put((Id)ar.get('accName'), acct);
                    tempSetIDs.remove((Id)ar.get('accName'));
                }
            }
            
            //Checking set for the size value
            if(tempSetIDs.size()>0){
               
               //Loop through the ID values 
               for(Id aId: tempSetIDs){
                   Account acct = new Account(Id = aId, Industry_Member__c = false);
                   mapAccounts.put(aId, acct);
               }    
            }
            
            //Update the Account records 
            if(mapAccounts.values().size()>0){
                Util.byPassAllTriggers = true;
                update mapAccounts.values();
                Util.byPassAllTriggers = false;
            } 
        }*/
    }
    
    //Commented Relationship_Advisor__c - By Mahendra Swarnkar - spring clean up - 04/29/2019
    //V_3.10 - Modified by Dipesh Gupta - 08/12/2017 - CR-20170426-10878 
    //V_3.9 - Merged By - Rajeev Jain - 07/05/2017 
    //V_3.7 - Added By - Mahendra Swarnakar -04/27/2017 - CR-20170327-10781
    //Commented out Project Updates since all the relevant Project Record Types are being deleted - CM - Spring Cleaning
    /**
     *  @description    :   Method to populate the fields on opportunity & Project fields from membership.
     *
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
    **/
    public static void populateOpportunityAndProjectFieldsFromMembership(List<Membership__c> newMemberships, Map<Id, Membership__c> mapOldMemberships) {
        
        //Map to hold the opporttunity records going to update
        Map<Id, Opportunity> MapOppToBeUpdate = new Map<Id, Opportunity>();
        
        //Map to hold the Project records going to update
        Map<Id, Project__c> MapProjectToBeUpdate = new Map<Id, Project__c>();
        
        //V_3.10 - Modified by Dipesh Gupta - 08/12/2017 - CR-20170426-10878 
        //Set to hold the Membership Ids for non TVM fields  
	Set<Id> setMembershipIdForNonTVMFields  = new Set<Id>();
       
        //Set to hold the membership Ids for TVM fields
        Set<Id> setMembIds = new Set<Id>();
    
        //Loop over the newMemberships list
        for(Membership__c mem : newMemberships) {
           
            //insert use case
          //check for conditions and populate the set of membership ids
      if( 
        (
          mem.Active_Renewal_Opportunity__c != null 
          || mem.Primary_Project__c != null
        )
        &&
        mapOldMemberships == null
      ) {
            setMembIds.add(mem.Id);
      }
              
      //Update case
            if(mapOldMemberships != null){
                
                //Populating the set of Membership ids for TVM fields
                if( /*mem.Value_Management_Director__c != mapOldMemberships.get(mem.Id).Value_Management_Director__c
                    || mem.Value_Management_Lead__c != mapOldMemberships.get(mem.Id).Value_Management_Lead__c 
                    || mem.Value_Advisor__c != mapOldMemberships.get(mem.Id).Value_Advisor__c
                    || mem.Practice_Partner__c != mapOldMemberships.get(mem.Id).Practice_Partner__c
                    || mem.Relationship_Advisor__c != mapOldMemberships.get(mem.Id).Relationship_Advisor__c
                    || */ mem.Active_Renewal_Opportunity__c  != mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c
                    || mem.Primary_Project__c  != mapOldMemberships.get(mem.Id).Primary_Project__c
                    || mem.Membership_Status_Text__c  != mapOldMemberships.get(mem.Id).Membership_Status_Text__c
                    || mem.Active_Contract_Annual_Contract_Value__c  != mapOldMemberships.get(mem.Id).Active_Contract_Annual_Contract_Value__c
            ) {
                
                    setMembIds.add(mem.Id);
                        
                    //Populate the Project list on projetc change
                    if( mapOldMemberships.get(mem.Id).Primary_Project__c != null 
                       && mem.Primary_Project__c  != mapOldMemberships.get(mem.Id).Primary_Project__c )
                    {
                        //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
                        MapProjectToBeUpdate.put(mapOldMemberships.get(mem.Id).Primary_Project__c, new Project__c(Id = mapOldMemberships.get(mem.Id).Primary_Project__c/*,
                                                                                                                  Value_Management_Director__c = null, Value_Management_Lead__c = null,Value_Advisor__c = null*/));    
                    }
                    
                    //Populate the opportunity list on opportunity change
                    if( mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c != null
                       && mem.Active_Renewal_Opportunity__c  != mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c) 
                    {
                        MapOppToBeUpdate.put(mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c, new Opportunity(Id = mapOldMemberships.get(mem.Id).Active_Renewal_Opportunity__c));
                    }
        }
                
                //Populating the setMembershipIdForNonTVMFields of Membership ids for non TVM fields
                if( mem.Membership_Status_Text__c  != mapOldMemberships.get(mem.Id).Membership_Status_Text__c
                    || mem.Active_Contract_Annual_Contract_Value__c  != mapOldMemberships.get(mem.Id).Active_Contract_Annual_Contract_Value__c
                ){
                            setMembershipIdForNonTVMFields.add(mem.Id);
                }
            }
        } 
    
        //Check for the size
        if(setMembIds.size() > 0) 
        {
      //Set to hold the Opportunity record type's developer name
      Set<String> setEligibleOpportinityRecordTypeDeveloperName = new Set<String>{'BI_Contract_Renewal', 'BI_Contract_Maintenance'};
              
      //Set to hold the Project record type's developer name
      //Modified By - Abhinav Sharma - 06/17/2020 - CR-20200318-13867 - Project Page Layout and RT deletions
      //Set<String> setEligibleProjectRecordTypeDeveloperName = new Set<String>{'CCA','CCM','CMA','CPM','CMR','CostOps','HP_Consumer_Scheduling','iRound','RCS'};
                    
            //query on membership records
            for(Membership__c memb : [Select Id, /*Value_Management_Director__c, Value_Management_Lead__c, Value_Advisor__c,
                                        Practice_Partner__c, Relationship_Advisor__c,*/ Primary_Project__c, 
                                        Primary_Project__r.RecordTypeId, Primary_Project__r.RecordType.DeveloperName, 
                                        Active_Renewal_Opportunity__c, Active_Renewal_Opportunity__r.Pool_Date__c,
                                        Active_Renewal_Opportunity__r.Pool_Year__c, Active_Renewal_Opportunity__r.RecordTypeId, 
                                        Active_Renewal_Opportunity__r.recordType.DeveloperName,
                                /*(
                                            Select Id From projects__r 
                                            where Project_Phase__c !=: 'Contract Dropped' 
                                            AND RecordTypeId != null 
                                            AND RecordType.DeveloperName IN : setEligibleProjectRecordTypeDeveloperName
                                        ),*/ 
                              (
                                            Select Id From Opportunities__r 
                                            where 
                                            Pool_Year__c >=: String.valueOf(system.today().year())
                                            //Pool_Date__c >= TODAY 
                                            AND RecordTypeId != null 
                                            AND RecordType.DeveloperName IN : setEligibleOpportinityRecordTypeDeveloperName
                                        )
                                From Membership__c where Id IN : setMembIds
                              ]
      ){
        //Check for Additional conditions
                if(memb.Active_Renewal_Opportunity__c != null 
                   && memb.Active_Renewal_Opportunity__r.Pool_Year__c >= String.valueOf(system.today().year())
                   && memb.Active_Renewal_Opportunity__r.recordTypeId != null
                   && setEligibleOpportinityRecordTypeDeveloperName.contains(memb.Active_Renewal_Opportunity__r.recordType.DeveloperName)
                ) {
          //Populate the opportunity map to be updated
                MapOppToBeUpdate.put(memb.Active_Renewal_Opportunity__c, new Opportunity(Id = memb.Active_Renewal_Opportunity__c/*, Value_Management_Director__c = memb.Value_Management_Director__c,
                                                                                               Value_Management_Lead__c = memb.Value_Management_Lead__c, Value_Advisor__c = memb.Value_Advisor__c,
                                                                                               Relationship_Advisor__c = memb.Relationship_Advisor__c , Executive_Sales_Support__c = memb.Practice_Partner__c*/
                                                                                              ));
            }
                
                //Check for Additional conditions
                /*if(memb.Primary_Project__c != null 
                     && memb.Primary_Project__r.recordTypeId != null
                     && setEligibleProjectRecordTypeDeveloperName.contains(memb.Primary_Project__r.recordType.DeveloperName)
                ) {
                  //Populate the project map to be updated
                    MapProjectToBeUpdate.put(memb.Primary_Project__c, new Project__c(Id = memb.Primary_Project__c, Value_Management_Director__c = memb.Value_Management_Director__c,
                                                                                       Value_Management_Lead__c = memb.Value_Management_Lead__c, Value_Advisor__c = memb.Value_Advisor__c
                                                                                      ));
            }
                
                //Check for size
                if(memb.projects__r.size()>0) 
                {
                //Loop over the related projects
                    for(Project__c proj : memb.projects__r) 
                    {
                        
                      //Populate the project map to be updated
                        MapProjectToBeUpdate.put(proj.id, new Project__c(Id = proj.id, Value_Management_Director__c = memb.Value_Management_Director__c,
                                                                         Value_Management_Lead__c = memb.Value_Management_Lead__c, Value_Advisor__c = memb.Value_Advisor__c
                                                                        ));
                    }
            }*/
                
                //Check for size
                if(memb.Opportunities__r.size()>0){
                    
                  //Loop over the related opportunities
                    for(Opportunity oppo : memb.Opportunities__r) {
                        
                        //Populate the opportunity map to be updated
                        MapOppToBeUpdate.put(oppo.id, new Opportunity(Id = oppo.id /*Value_Management_Director__c = memb.Value_Management_Director__c,
                                                                      Value_Management_Lead__c = memb.Value_Management_Lead__c, Value_Advisor__c = memb.Value_Advisor__c,
                                                                      Relationship_Advisor__c = memb.Relationship_Advisor__c , Executive_Sales_Support__c = memb.Practice_Partner__c*/
                                                                     ));
                    }
                }
            }
            
            //Disable the triggers
            Util.BypassAllTriggers = true;
            
            //Check for size and update the opportunity records
            if(MapOppToBeUpdate.size() > 0 
               && MapOppToBeUpdate.values() != null 
               && MapOppToBeUpdate.values().size() > 0)
                
                update MapOppToBeUpdate.values();
            
            //Enable the triggers
            Util.BypassAllTriggers = false;
        }
        //V_3.9 - Merged By - Rajeev Jain - 07/05/2017 - upto here
        
        //V_3.10 - Modified by Dipesh Gupta - 08/12/2017 - CR-20170426-10878---- Start here
        //Check the size of Set
        /*if(setMembershipIdForNonTVMFields.size() > 0) {
          
            //map to hold the project with respact to membership id.
            map<Id, List<Project__c>> mapMembeshipIdWithProjectList = new Map<Id, List<Project__c>>();
            
            //Query on the Project which is related to the memebrrship
            for(Project__c proj : [Select Id, Annual_Contract_Value__c, Primary_Paid_Membership__c From Project__c Where Primary_Paid_Membership__c IN : setMembershipIdForNonTVMFields AND RecordType.DeveloperName IN ('EHBI','CCA', 'CMA', 'CPM', 'CostOps', 'HP_Consumer_Scheduling', 'iRound','RCS')]) {
                
                //Check for the map is containing the membership id previously , if not then put the id and initialise the list of Progam 
                
                if(!mapMembeshipIdWithProjectList.containsKey(proj.Primary_Paid_Membership__c))
                    mapMembeshipIdWithProjectList.put(proj.Primary_Paid_Membership__c, New List<Project__c>());
                
                //Addding the project to the map.
                mapMembeshipIdWithProjectList.get(proj.Primary_Paid_Membership__c).add(proj);
            }
            
            if(mapMembeshipIdWithProjectList.size() > 0) {
              
                //Loop though the new Membershiop records . 
                for(Membership__c mem : newMemberships) {
                    
                    //Check if map contains the membership id or Not
                    if(mapMembeshipIdWithProjectList.containsKey(mem.Id)
                        && mapMembeshipIdWithProjectList.get(mem.Id) != null
                         && mapMembeshipIdWithProjectList.get(mem.Id).size() > 0
          ) {
                        //Loop on the map values
                        for(Project__c pr : mapMembeshipIdWithProjectList.get(mem.Id)) {
                            
                            //Check the membership Fields , if they are not equal to project then update project fields accordngly.
                            if(pr.Annual_Contract_Value__c != mem.Active_Contract_Annual_Contract_Value__c) {
                                
                                //Populate Annual_Contract_Value value on the project field
                                if(pr.Annual_Contract_Value__c != mem.Active_Contract_Annual_Contract_Value__c) 
                                    pr.Annual_Contract_Value__c = mem.Active_Contract_Annual_Contract_Value__c;
                
                                //Populate list of Project records that will going to be updated
                                if(MapProjectToBeUpdate.size() > 0 
                                     && MapProjectToBeUpdate.containsKey(pr.Id)
                                    && MapProjectToBeUpdate.get(pr.Id) != null
                                ){
                                    MapProjectToBeUpdate.get(pr.Id).Annual_Contract_Value__c = pr.Annual_Contract_Value__c;
                                } 
                                else {
                                    MapProjectToBeUpdate.put(pr.Id, pr);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Bypass all triggers
        Util.BypassAllTriggers = true;
        
        //Check for size and populate the list of projects to be update
        if(MapProjectToBeUpdate.size() > 0 
           && MapProjectToBeUpdate.values() != null 
           && MapProjectToBeUpdate.values().size() > 0
        ){
              update MapProjectToBeUpdate.values();    
        }
        
        //Enable all triggers
        Util.BypassAllTriggers = false;*/
        //V_3.10 - Modified by Dipesh Gupta - 08/12/2017 - CR-20170426-10878---- Ends here
    }
    
    //Added By - Subhash Garhwal - 05/11/2018 - CR-20180504-12213
    /**
     *  @description    :   Method is used to populate the 'Current Period Annual Fee' and 'Current Year Travel Fee' fields on Membership .
     *
     *  @args           :   Map<Id, Membership__c> newMembershipMap, Map<Id, Membership__c> mapOldMemberships
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created By - Subhash Garhwal - 05/11/2018 - CR-20180504-12213
     *              	    V1.1 - Modified By - Subhash Garhwal - 07/12/2018 - CR-20180504-12213
     *              	    V1.2 - Modified By - Mahendra Swarnkar - 03/05/2019 - CR-20190215-12886
     *              	    V1.3 - Modified By - Victor Hanson - 11/05/2019 - CR-20191031-13488 - Exclude global memberships from receiving annual/travel fees
     *                      V1.4 - Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - Annual_Fee calculated by taking the SUM of all applicable customer amounts.
     **/
    public static void updateCurrentYearFees(Map<Id, Membership__c> newMembershipMap, Map<Id, Membership__c> mapOldMemberships) {
        
        //Addded By Mahendra Swarnkar - 03/05/2019 - CR-20190215-12886
        Map<Id, Membership__c> mapMembershipsToUpdate = new Map<Id, Membership__c>();  
        
        //Set of Membership Ids
        //Victor Hanson - 11/05/2019 - CR-20191031-13488 - updated to map<Id, Set<Id>>
        Map<Id, Set<Id>> MapOfProgramSubIdAndMembershipIds = new Map<Id, Set<Id>>();
        
        //Map to hold Membership where active Component Subscription is present
        Set<Id> setMembershipIds = new Set<Id>();
        
        //Variable to show Active Component Subscription is present or not 
        Boolean annualFeeExist = false;
        Boolean travelFeeExist = false;
        
        //Null and Size check
        if(newMembershipMap!= null && newMembershipMap.size() > 0 ) {
            
            //Loop over the Membership
            for(Membership__c mem : newMembershipMap.values()) {
                
                //Check of active Subscription
                if(mem.Active_Subscription__c != null && (mapOldMemberships == null || mem.Active_Subscription__c != mapOldMemberships.get(mem.Id).Active_Subscription__c 
                                                          || mem.Current_Year_Annual_Fee__c != mapOldMemberships.get(mem.Id).Current_Year_Annual_Fee__c
                                                          || mem.Current_Year_Travel_Fee__c != mapOldMemberships.get(mem.Id).Current_Year_Travel_Fee__c) && Util.ByPassDLRSMembershipTrigger) 
                {
                    Set<Id> memIds = MapOfProgramSubIdAndMembershipIds.get(mem.Active_Subscription__c);
                    if (memIds == null) memIds = new Set<Id>();
                    memIds.add(mem.Id);
                    
                    //Put value into the map
                    MapOfProgramSubIdAndMembershipIds.put(mem.Active_Subscription__c, memIds);
                    
                    //Put value into the map
                    setMembershipIds.add(mem.Id);
                    
                   // Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - Start from  here
                    mapMembershipsToUpdate.put(mem.Id, new Membership__c(Id = mem.Id, Current_Year_Annual_Fee__c = null, Current_Year_Travel_Fee__c = null,
                                                                         Current_Period_Start_Date__c = mem.Current_Period_Start_Date__c, Current_Period_End_Date__c = mem.Current_Period_End_Date__c,
                                                                         Membership_Status_Text__c = mem.Membership_Status_Text__c ));
                    // Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - End  here
                     
                    //Check if Active Subscription is updating null
                } else if(mem.Active_Subscription__c == null && (mapOldMemberships == null || (mapOldMemberships != null && mem.Active_Subscription__c != mapOldMemberships.get(mem.Id).Active_Subscription__c))){
                    
                    //Update the Membership field null
                    mapMembershipsToUpdate.put(mem.Id, new Membership__c(Id = mem.Id, Current_Year_Annual_Fee__c = null, Current_Year_Travel_Fee__c = null,
                                                                         Current_Period_Start_Date__c = null, Current_Period_End_Date__c = null,
                                                                         Membership_Status_Text__c = mem.Membership_Status_Text__c ));
                }
            }
        }
        
        //Null Check
        if(MapOfProgramSubIdAndMembershipIds.size() > 0) {
            //Query over the Component Subscription 
            List<SBQQ__Subscription__c> CompSubscriptions = [Select Id,  SBQQ__Product__c, SBQQ__Product__r.Name, Customer_Amount__c, SBQQ__SegmentStartDate__c, 
                                                             SBQQ__SegmentEndDate__c, Program_Subscription__c From SBQQ__Subscription__c 
                                                             Where Program_Subscription__c != null AND Program_Subscription__c IN : MapOfProgramSubIdAndMembershipIds.KeySet() 
                                                             AND SBQQ__SegmentStartDate__c != null AND SBQQ__SegmentEndDate__c != Null AND SBQQ__Product__c != Null 
                                                             AND RecordType.DeveloperName =: CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_COMPONENT 
                                                             ORDER BY SBQQ__SegmentStartDate__c ASC , Program_Subscription__c ASC];
														 
            //Size check
            if(CompSubscriptions.size() > 0) {
                
                //Loop over the Component Subscription
                for(SBQQ__Subscription__c subscription : CompSubscriptions)  {
                    
                    
                    //Check for active Component Subscription
                    if(subscription.SBQQ__SegmentStartDate__c <= Date.today() && subscription.SBQQ__SegmentEndDate__c >= Date.today()) {
                        
                        //Null check for new membership
                        if(MapOfProgramSubIdAndMembershipIds.get(subscription.Program_Subscription__c) != null) {
                            
                            for (Id memId : MapOfProgramSubIdAndMembershipIds.get(subscription.Program_Subscription__c)) {
                                
                                //Check if product type is Annual Fee 
                                if(subscription.SBQQ__Product__r.Name == CPQConstants.PRODUCT_CATEGORY_ANNUAL_FEE) {
                                    
                                    annualFeeExist = true;
                                    
                                    //Populate Current Period Annual Fee
                                    //11/05/2019 - Victor Hanson - CR-20191031-13488 - Added to exclude global memberships from receiving annual/travel fees
                                    if (mapMembershipsToUpdate.get(memId).Membership_Status_Text__c != Constants.MEMBER_PAYER_INTEGRATED_GLOBAL){
                                        //Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - Strat from  here
                                        //Annual_Fee calculated by taking the SUM of all applicable customer amounts.
                                        if (mapMembershipsToUpdate.get(memId).Current_Year_Annual_Fee__c == null) 
                                        {
                                            mapMembershipsToUpdate.get(memId).Current_Year_Annual_Fee__c = 0;
                                        }
                                        mapMembershipsToUpdate.get(memId).Current_Year_Annual_Fee__c += subscription.Customer_Amount__c;
                                        
                                    } 
                                    //Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - End here
                                   
                                    //Check product type is Travel Fee
                                } else if(subscription.SBQQ__Product__r.Name == CPQConstants.PRODUCT_CATEGORY_TRAVEL_FEE) {
                                    
                                    travelFeeExist = true;
                                    
                                    //Populate Current Period Travel Fee
                                    //11/05/2019 - Victor Hanson - CR-20191031-13488 - Added to exclude global memberships from receiving annual/travel fees
                                    if (mapMembershipsToUpdate.get(memId).Membership_Status_Text__c != Constants.MEMBER_PAYER_INTEGRATED_GLOBAL)
                                    {
                                        //Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - Strat from  here
                                        //Annual_Fee calculated by taking the SUM of all applicable customer amounts.
                                        if (mapMembershipsToUpdate.get(memId).Current_Year_Travel_Fee__c == null) 
                                        {
						mapMembershipsToUpdate.get(memId).Current_Year_Travel_Fee__c = 0;
                                        }
                                        mapMembershipsToUpdate.get(memId).Current_Year_Travel_Fee__c += subscription.Customer_Amount__c;
                                    }
                                    //Modified By - Neha Sharma - 5/21/21 - CR-20210113-14804 - End here   
                                }
                                
                                //Populate 'Current Period Start Date' and 'Current Period End Date' field on Memvership        
                                mapMembershipsToUpdate.get(memId).Current_Period_Start_Date__c = subscription.SBQQ__SegmentStartDate__c;
                                mapMembershipsToUpdate.get(memId).Current_Period_End_Date__c = subscription.SBQQ__SegmentEndDate__c;
                            }
                        }
                        //Check if annual fee or travel fee exist 
                        if(annualFeeExist || travelFeeExist) {
                            
                            for (Id memId : MapOfProgramSubIdAndMembershipIds.get(subscription.Program_Subscription__c)) {
                                
                                //make sure non-global memberships are taken out of setMembershipIds list so they don't get fees reset below
                                if (mapMembershipsToUpdate.get(memId).Membership_Status_Text__c != Constants.MEMBER_PAYER_INTEGRATED_GLOBAL) {
                                    //Remove the Membership where Active Component Subscription exist
                                    setMembershipIds.remove(memId);
                                    annualFeeExist = false;
                                    travelFeeExist = false;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Null and size check   
        if(setMembershipIds.size() > 0) {
            
            //Loop over the Membership Ids
            for(Id membershipId : setMembershipIds) {  
                
                //Update the Membership field null
                mapMembershipsToUpdate.get(membershipId).Current_Year_Annual_Fee__c = null;
                mapMembershipsToUpdate.get(membershipId).Current_Year_Travel_Fee__c = null;
                mapMembershipsToUpdate.get(membershipId).Current_Period_Start_Date__c = null;
                mapMembershipsToUpdate.get(membershipId).Current_Period_End_Date__c = null;
                
            }
        }
        
        //Null and size Check 
        //if(Trigger.isInsert == Null && Trigger.isUpdate == Null && newMembershipMap != Null && newMembershipMap.size() > 0) {
        if(mapMembershipsToUpdate.size() > 0 && mapMembershipsToUpdate.values().size() > 0) {
            
            //Enable all triggers
            Util.BypassAllTriggers = true;
            Util.ByPassDLRSMembershipTrigger = false;
            
            //Update memberships
            update mapMembershipsToUpdate.values();
            
            Util.ByPassDLRSMembershipTrigger = true;
            //Enable all triggers
            Util.BypassAllTriggers = false;
        }
    }
  
  /**
     *  @description    :   This method is used to update the Fields values on membership.
     *             	    Membership Status, Renewal Owner, Join Date-Earliest, Join Date-Most Recent, Last End Date
     *             	    This logic will only execute for the Enrollment Record type of Membership
     * 
     *  @args           :   List of new Membership, Map of old Membershi
     *
     *  @return         :   void
     * 
     *  @Version        :   v1.0 - Created By Abhinav sharma - CR-20180809-12494. 
     * 			    v1.1 - Modified By - Mahendra Swarnkar - 05/13/2019 - CR-20190308-12920
     * 			    v1.2 - Modified By - Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021
     * 
    **/
    public static void updateMembershipFieldsForEnrollmentRecordType (List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        //Checking for the Membership List
        if(newMemberships != null && newMemberships.size() > 0) {
          
            //for loop on membership object
            for(Membership__c mem : newMemberships) {
                  
                //Modified By - Mahendra Swarnkar - CR-20210422-15100 - 04/22/2021 - Added check for Next/Previous/Current_Year_Program_Package__c change
                //Updated By Mahendra Swarnkar - 05/13/2019 - CR-20190308-12920 - Added check for [Next_Year_Engagement_Status__c] field change
                //Checking for the new Insert case or specific update case
                if(mem.RecordTypeId == Constants.Membership_Record_Type_Enrollment && (oldMapMemberships == null || (oldMapMemberships != null 
                    && 
                    (
                    oldMapMemberships.get(mem.Id).Membership_Status_Text__c != mem.Membership_Status_Text__c 
                    ||
                    oldMapMemberships.get(mem.Id).Join_Date_Most_Recent__c != mem.Join_Date_Most_Recent__c
                    ||
                    oldMapMemberships.get(mem.Id).Active_Fiscal_Year__c != mem.Active_Fiscal_Year__c
                    ||
                    oldMapMemberships.get(mem.Id).Client_Since__c != mem.Client_Since__c
                    ||
                    oldMapMemberships.get(mem.Id).Current_Year_Engagement_Status__c != mem.Current_Year_Engagement_Status__c
                    ||
                    oldMapMemberships.get(mem.Id).Last_Secured_Fiscal_Year__c != mem.Last_Secured_Fiscal_Year__c
                    ||
                    oldMapMemberships.get(mem.Id).Previous_Year_Engagement_Status__c != mem.Previous_Year_Engagement_Status__c
                    ||
                    oldMapMemberships.get(mem.Id).Next_Year_Engagement_Status__c != mem.Next_Year_Engagement_Status__c
                    ||
                    oldMapMemberships.get(mem.Id).Next_Year_Program_Package__c != mem.Next_Year_Program_Package__c
                    ||
                    oldMapMemberships.get(mem.Id).Previous_Year_Program_Package__c != mem.Previous_Year_Program_Package__c
                    ||
                    oldMapMemberships.get(mem.Id).Current_Year_Program_Package__c != mem.Current_Year_Program_Package__c
                )))) {
                    
                    String activeFiscalYear = '0';
                    
                    //Set to hold the values 
                    Set<String> setCurrentYearValues = new Set<String>{'Committed','In Play','At Risk'};
                    
                    if(String.isNotBlank(mem.Active_Fiscal_Year__c))
                        activeFiscalYear = mem.Active_Fiscal_Year__c;    
				    
                    //Updated By Mahendra Swarnkar - 05/13/2019 - CR-20190308-12920 - Added check for [Next_Year_Engagement_Status__c == 'Secured']
                    //Check the condition to set the Membership status Text.
                    if(mem.Current_Year_Engagement_Status__c == 'Secured' || mem.Next_Year_Engagement_Status__c == 'Secured')
                        mem.Membership_Status_Text__c = Constants.MEMBER_PAYER;
                    
                    else if(setCurrentYearValues.contains(mem.Current_Year_Engagement_Status__c) && mem.Previous_Year_Engagement_Status__c == 'Secured')
                        mem.Membership_Status_Text__c = Constants.MEMBER_PAYER_GRACE;
                    
                    else if(String.isNotBlank(mem.Last_Secured_Fiscal_Year__c) && Integer.valueOf(mem.Last_Secured_Fiscal_Year__c) > Integer.valueOf(activeFiscalYear) )
                        mem.Membership_Status_Text__c = Constants.PROSPECT_PENDING_FUTURE_START_DATE;
                    
                    else if(String.isNotBlank(mem.Last_Secured_Fiscal_Year__c) && Integer.valueOf(mem.Last_Secured_Fiscal_Year__c)  == Integer.valueOf(activeFiscalYear) - 1)
                        mem.Membership_Status_Text__c = Constants.PROSPECT_RECENT_DROP;
                    
                    else if(String.isNotBlank(mem.Last_Secured_Fiscal_Year__c) && Integer.valueOf(mem.Last_Secured_Fiscal_Year__c) < Integer.valueOf(activeFiscalYear) - 1)
                        mem.Membership_Status_Text__c = Constants.PROSPECT_PAST_MEMBER;
                    
                    else
                        mem.Membership_Status_Text__c = Constants.PROSPECT_PURE;
                    
                    //Set the join Date Most recent on membership    
                    mem.Join_Date_Most_Recent__c = mem.Client_Since__c;
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to populate 'Previous Year - Program Cost (CPQ)[Previous_Year_Program_Cost_CPQ__c]', 'Current Year - Program Cost (CPQ)[Current_Year_Program_Cost_CPQ__c]', 'Next Year - Program Cost (CPQ)[Next_Year_Program_Cost_CPQ__c]', with the program cost from related SP's
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :  V1.0 - Added By Subhash Garhawal - 12/26/2018 - CR-20181019-12685.
    **/
    public static void populatePreviousCurrentNextYearProgramCost(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships) {
      
      //Set to hold the Program Package's Ids
      Set<Id> setProgramPackageIds = new Set<Id>();
      
      //Map to hold the eligible Membership records
      Map<Id, Membership__c> mapMemberships = new Map<Id, Membership__c>();
      
      //Loop over the membership records
      for(Membership__c memb : newMemberships){
        
        //Insert/update use case
        if(memb.recordTypeId == Constants.Membership_Record_Type_Enrollment && (oldMapMemberships == null ||(oldMapMemberships != null 
          && (memb.Previous_Year_Program_Package__c != oldMapMemberships.get(memb.Id).Previous_Year_Program_Package__c 
              || memb.Current_Year_Program_Package__c != oldMapMemberships.get(memb.Id).Current_Year_Program_Package__c
              || memb.Next_Year_Program_Package__c != oldMapMemberships.get(memb.Id).Next_Year_Program_Package__c)))){
        
        //Populate the Set of Program Package Ids
        if(memb.Previous_Year_Program_Package__c != null)
          setProgramPackageIds.add(memb.Previous_Year_Program_Package__c);
          
        //Populate the Set of Program Package Ids
        if(memb.Current_Year_Program_Package__c != null)
          setProgramPackageIds.add(memb.Current_Year_Program_Package__c);
        
        //Populate the Set of Program Package Ids
        if(memb.Next_Year_Program_Package__c != null)
          setProgramPackageIds.add(memb.Next_Year_Program_Package__c);
        
        //Update case
        if(oldMapMemberships != null){
          
          //Populate the Set of Program Package Ids
          if(oldMapMemberships.get(memb.Id).Previous_Year_Program_Package__c != null)
            setProgramPackageIds.add(memb.Previous_Year_Program_Package__c);
          
          //Populate the Set of Program Package Ids
          if(oldMapMemberships.get(memb.Id).Current_Year_Program_Package__c != null)
            setProgramPackageIds.add(memb.Current_Year_Program_Package__c);
            
          //Populate the Set of Program Package Ids
          if(oldMapMemberships.get(memb.Id).Next_Year_Program_Package__c != null)
            setProgramPackageIds.add(memb.Next_Year_Program_Package__c);
        }
        
        //Populate the Membership map with eligible Memberships
        mapMemberships.put(memb.Id, new Membership__c(Id = memb.Id, Previous_Year_Program_Package__c = memb.Previous_Year_Program_Package__c, Current_Year_Program_Package__c = memb.Current_Year_Program_Package__c, Next_Year_Program_Package__c = memb.Next_Year_Program_Package__c,
                                                              Previous_Year_Program_Cost_CPQ__c = 0, Current_Year_Program_Cost_CPQ__c = 0, Next_Year_Program_Cost_CPQ__c = 0));
        }
      }
      
      //Check for size
      if(setProgramPackageIds.size() > 0 && mapMemberships.size() > 0){
        
        ///Map to hold Program Package Id with the sum of Customer amount from related SPs/Component Subscriptions.
        Map<Id,Decimal> mapProgramIdWithTotalProgramCost = new Map<Id,Decimal>();
        
        //10/27/2020 - CR-20201013-14598 - Victor Hanson - updated query to check for Program Costs OR Cappex Service Costs
        //Query all the child SP's and its related component Subscriptions(where product Code = Program Cost)
        for(Subscription_Period__c sps : [Select Id, (Select Id, Customer_Amount__c From Subscriptions__r Where Product_Code__c IN :CPQConstants.COST_PRODUCT_CODES), 
                          Program_Package__c From Subscription_Period__c 
                          Where Program_Package__c != null AND Program_Package__c IN : setProgramPackageIds] ) {
          
          //Check for SP's component Subscriptions
          if(sps.Program_Package__c != null && sps.Subscriptions__r != null && sps.Subscriptions__r.size() > 0){
            
          //Hold the sum of program costs
            Decimal sumProgramCost = 0;
            
            //Loop over the related Component Subscriptions
            for(SBQQ__Subscription__c compSubs : sps.Subscriptions__r){
              
              //Check for customer amount
              if(compSubs.Customer_Amount__c != null)
                sumProgramCost = sumProgramCost + compSubs.Customer_Amount__c;
            }
       
            //Populate the Map with values
            if(mapProgramIdWithTotalProgramCost.containsKey(sps.Program_Package__c))
              mapProgramIdWithTotalProgramCost.put(sps.Program_Package__c, (mapProgramIdWithTotalProgramCost.get(sps.Program_Package__c)+ sumProgramCost));
            else
              mapProgramIdWithTotalProgramCost.put(sps.Program_Package__c,sumProgramCost);

          }
      }
        
      if(mapProgramIdWithTotalProgramCost.size() > 0){
        
        //List of memberships to be update
        List<Membership__c> listMembershipsToUpdate = new List<Membership__c>();
         
        //Loop over the membership records
          for(Id memId : mapMemberships.keySet()){
            
            //Get eligible Membership records
            if(mapMemberships.get(memId) != null){
              
              //Hold the Membership record
              Membership__c memb = mapMemberships.get(memId);
              
              //Populate the Previous Year Program Cost (CPQ)
            if(memb.Previous_Year_Program_Package__c != null && mapProgramIdWithTotalProgramCost.containsKey(memb.Previous_Year_Program_Package__c))
              memb.Previous_Year_Program_Cost_CPQ__c = mapProgramIdWithTotalProgramCost.get(memb.Previous_Year_Program_Package__c);
              
            //Populate the Current Year Program Cost (CPQ)
            if(memb.Current_Year_Program_Package__c != null && mapProgramIdWithTotalProgramCost.containsKey(memb.Current_Year_Program_Package__c))
              memb.Current_Year_Program_Cost_CPQ__c = mapProgramIdWithTotalProgramCost.get(memb.Current_Year_Program_Package__c);
            
            //Populate the Next Year Program Cost (CPQ)
            if(memb.Next_Year_Program_Package__c != null && mapProgramIdWithTotalProgramCost.containsKey(memb.Next_Year_Program_Package__c))
              memb.Next_Year_Program_Cost_CPQ__c = mapProgramIdWithTotalProgramCost.get(memb.Next_Year_Program_Package__c);
            
            //Populate the membership list to update
            listMembershipsToUpdate.add(memb);
            }
          }
          
          //Check for size
          if(listMembershipsToUpdate.size() > 0){
            
            //Disable all triggers
            Util.BypassAllTriggers = true;
            
            //Bypass dlrs trigger
            Util.ByPassDLRSMembershipTrigger = true;
                    
            //update memberships
            update listMembershipsToUpdate;
            
                    //Bypass dlrs trigger
            Util.ByPassDLRSMembershipTrigger = false; 
                    
          //Enable all triggers
              Util.BypassAllTriggers = false;
          }
      }
      }
    }
    
    //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Starts here
    //popualte the program info on a given list of events
    public static list<Event> populateProgramInfo_Events(map<Id, Membership__c> memMap, list<Event> events) {
        
        // get all events associated with these membership and update their program
        for (Event e : events) {
            
            //Checking for null and size value
            if (memMap != null && memMap.containsKey(e.WhatId) && memMap.get(e.WhatId) != null) {
                
                // get the asociated membership
                Membership__c mem = memMap.get(e.WhatId);
                
                if (mem.Program__c != null) {
                    
                    // update the program 
                    e.Program__c = mem.Program__r.Program_Acronym__c;
                }
                else {     
                    e.Program__c = null;
                }
            }
        }
        return events;
    }
    //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Ends here
    
    
    
    /**
     *  @description    :   When Membership Status is changed to an inactive value, check to see if the related Institution has any Memberships.
     *                      If no other active memberships are found:
     *                      1) execute a batch job to set Institution Tokens = 0 & Site Profile Tokens = 0 for all site profiles on the institution
     *                      2) expire any active 
     * 
     *  @args           :   List of new Membership, Map of old Membershi
     *
     *  @return         :   void
     *
     *  @Version        :  Created - 05/30/2019 - Victor Hanson - CR-20190520-13117
    **/
    public static void checkForActiveMembership (List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships) {
        
        //account ids to be checked for active memberships
        Set<Id> acctIds = new Set<Id>();
        
        //Set to hold the account Ids, which populates if the Membership status has been changes from any value. 
        Set<Id> setAccountIdIfMembershipStatusChanges = new Set<Id>();

        //membership ids that are no longer active, to exclude from our query
        Set<Id> memIds = new Set<Id>();

        //map of accounts with no active memberships
        Map<Id, Account> mapAcctsWithoutActiveMemberships = new Map<Id, Account>();
        
        //Checking for the Membership List
        if(newMemberships != null && newMemberships.size() > 0) {
          
            //for loop on membership object
            for(Membership__c mem : newMemberships) {
                 
                 //verify Membership Status has changed from an active status to an inactive status
                 if (oldMapMemberships != null
                    && oldMapMemberships.containsKey(mem.Id)
                    && oldMapMemberships.get(mem.Id).Membership_Status__c != null
                    && oldMapMemberships.get(mem.Id).Membership_Status__c.startsWith('Member') //was active membership
                    && !mem.Membership_Status__c.startsWith('Member') //no longer active membership
                    ) {
                        if (mem.Account_Name__c != null) {
                            acctIds.add(mem.Account_Name__c);
                            memIds.add(mem.Id);
                        }
                    }
                
                //Check for the membership status Change. 
                if(oldMapMemberships != null && oldMapMemberships.containsKey(mem.Id) 
                   && oldMapMemberships.get(mem.Id).Membership_Status_Text__c != mem.Membership_Status_Text__c) {
                    
                    //Filling up the set with the Account Id.
                    setAccountIdIfMembershipStatusChanges.add(mem.Account_Name__c);
                }
            }

            //if there is a membership being deactivated, check the institution(s) for other active memberships
            if (acctIds.size() > 0) {
                for (Account acct : [SELECT Id, Tokens__c, Tokens_Available__c, Tokens_Used__c, 
                                    (SELECT Id, Membership_Status__c FROM Memberships__r WHERE Id NOT IN :memIds AND Membership_Status__c LIKE 'Member%' LIMIT 1) 
                                     FROM Account WHERE Id IN :acctIds]) 
                {
                    if (acct.Memberships__r == null || acct.Memberships__r.size() == 0) {
                        //reset Tokens and Tokens Used fields to zero
                        acct.Tokens__c = 0;
                        acct.Tokens_Used__c = 0;
                        mapAcctsWithoutActiveMemberships.put(acct.Id, acct);
                    }
                }
            }
            
	    //Commented By Subhash Garhwal - 08/29/2019 - CR-20190828-13293
	    /*
            //Check for the Size of the Set. 
            if(setAccountIdIfMembershipStatusChanges.size() > 0) {
                
                //Commented the future job as getting the production validation Error/exception and called the method "updateWebProgramAccessOnInstitution" from "Sched_UpdateWebProgramAccessOnAccount" Queuable job class - by Mahendra Swarnkar - 08/21/2019 - CR-12685 Starts from here
                
                //Call Queuable job (calls the method "updateWebProgramAccessOnInstitution") from here, that is used to set the Web Program Access on the Institution based on the membership. 
        		Sched_UpdateWebProgramAccessOnAccount.scheduleUpdateWebProgramAccessOnAccount(setAccountIdIfMembershipStatusChanges, null);
                 
                //updateWebProgramAccessOnInstitution(setAccountIdIfMembershipStatusChanges);
                
                //Commented the future job as getting the production validation Error/exception and called the method "updateWebProgramAccessOnInstitution" from "Sched_UpdateWebProgramAccessOnAccount" Queuable job class - by Mahendra Swarnkar - 08/21/2019 - CR-12685 Ends here
            } */
        }

        //update the institution(s) that no longer have any active memberships
        if (mapAcctsWithoutActiveMemberships.size() > 0) {
            util.bypassAllTriggers = true;
            update mapAcctsWithoutActiveMemberships.values();
            util.bypassAllTriggers = false;
            
            //Commented By Subhash Garhwal - 08/29/2019 - CR-20190828-13293
	    //Added by Mahendra Swarnkar - 08/21/2019 - CR-12685 Starts from here
	    //Call Queuable job from here, that will start a batch job (Batch_TokenReset) to expire all existing Site Tokens and set Site Profile Token counts to 0. 
            //Sched_UpdateWebProgramAccessOnAccount.scheduleUpdateWebProgramAccessOnAccount(null, mapAcctsWithoutActiveMemberships.keySet());
        }
	
	//Added By Subhash Garhwal - 08/29/2019 - CR-20190828-13293
	//Call Queuable job (calls the method "updateWebProgramAccessOnInstitution") from here, 
        //a) that is used to set the Web Program Access on the Institution based on the membership. 
        //b) that will start a batch job (Batch_TokenReset) to expire all existing Site Tokens and set Site Profile Token counts to 0. 
        
        if(setAccountIdIfMembershipStatusChanges.size() > 0 || mapAcctsWithoutActiveMemberships.keySet().size() > 0) {
          
	  if(Limits.getQueueableJobs() == 0) {
                
                Sched_UpdateWebProgramAccessOnAccount sch1 = new Sched_UpdateWebProgramAccessOnAccount();
                
                if(setAccountIdIfMembershipStatusChanges.size() > 0)
                    sch1.setAccountIds = setAccountIdIfMembershipStatusChanges;
        
                if(mapAcctsWithoutActiveMemberships.keySet().size() > 0)
                    sch1.setAccountIdsOnInactiveMembership = mapAcctsWithoutActiveMemberships.keySet();
                
                System.enqueueJob(sch1);
                
            } else {
                
                Sched_UpdateWebProgramAccessQueqbleJob sch1 = new Sched_UpdateWebProgramAccessQueqbleJob();
                
                if(setAccountIdIfMembershipStatusChanges.size() > 0)
                    sch1.setAccountIds = setAccountIdIfMembershipStatusChanges;
        
                if(mapAcctsWithoutActiveMemberships.keySet().size() > 0)
                    sch1.setAccountIdsOnInactiveMembership = mapAcctsWithoutActiveMemberships.keySet();
                
                DateTime sysTime = DateTime.now().addSeconds(10);
                String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                System.schedule('Sched_UpdateWebProgramAccessOnAccount' + sysTime.getTime(),chron_exp, sch1);
            }
        }

        //Commented as per the production validation Error/exception and starts this batch from "Sched_UpdateWebProgramAccessOnAccount" Queuable job class - by Mahendra Swarnkar - 08/21/2019 - CR-12685 Starts from here
        /*
        //start a batch job to expire all existing Site Tokens and set Site Profile Token counts to 0
        Batch_TokenReset batchTokenReset = new Batch_TokenReset();
        batchTokenReset.acctIds = mapAcctsWithoutActiveMemberships.keySet();
        
        if (!test.isRunningTest()) {
            system.scheduleBatch(batchTokenReset, system.now() + 'batchTokenReset', 5);
        }
        else if (test.isRunningTest()) {
            database.executeBatch(batchTokenReset);
        }
        */
        //Commented as per the production validation Error/exception and starts this batch from "Sched_UpdateWebProgramAccessOnAccount" Queuable job class - by Mahendra Swarnkar - 08/21/2019 - CR-12685 Ends here
    }   
    
    /**
     *  @description    :   Method is used to update the Account - web program Access code based on the membership status change. 
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :  Created - 06/18/2019 - Dipesh Gupta - CR-20190510-13102
    **/
    //@future
    public static void updateWebProgramAccessOnInstitution(Set<Id> setAccIds) {
        
        //Map to hold the Account Id with the Set<Id> (Program ids)
        Map<Id, Set<Id>> mapAccountWithProgramIds = new Map<Id, Set<Id>>();
        
        //Map to hold the Program with the Web Program Access Ids. 
        Map<Id, Set<String>> mapProgramWithWebProgramAccessIds = new Map<Id, Set<String>>();
        
        //Map to hold the Account Ids and Account Instance. 
        Map<Id, Account> mapAccounts = new map<Id, Account>();
 
        //Set to hold the Id of Programs
        Set<Id> setProgramIds = new Set<Id>();

        //Check the size of the Set. 
        if(setAccIds != null && setAccIds.size() > 0) {
            
            //Query on Membership to get the Active Membership. 
            for(Membership__c paidMembership : [SELECT Id, Name, Program__c, Account_Name__c
                                                FROM Membership__c WHERE Member__c = TRUE
                                                AND Account_Name__c = : setAccIds] ) {
                
                //Adding values to the Map. 
                if(!mapAccountWithProgramIds.containsKey(paidMembership.Account_Name__c))   
                    mapAccountWithProgramIds.put(paidMembership.Account_Name__c, new Set<Id>());
                        
                //If already contains the account Id the get and update.
                mapAccountWithProgramIds.get(paidMembership.Account_Name__c).add(paidMembership.Program__c); 
                                                    
                //Filling the set with a programs. 
                setProgramIds.add(paidMembership.Program__c);
            }
            
            //Check the size of set. 
            if(setProgramIds.size() > 0 ) {
                
                //Query for our Programs and Web Program Access MTM records
                for(Program__c progs : [SELECT Id, Name, (SELECT Id, Adv_com_Program_ID__c FROM Web_Program_Access_MTM__r 
                                                          Where Adv_com_Program_ID__c != null)
                                                          FROM Program__c WHERE Id IN :setProgramIds]) {
                    //Adding values to the Map. 
                    if(!mapProgramWithWebProgramAccessIds.containsKey(progs.Id))    
                        mapProgramWithWebProgramAccessIds.put(progs.Id, new Set<String>());
                            
                    //Check the size of chile Related Web Program Access Records. 
                    if(progs.Web_Program_Access_MTM__r != null && progs.Web_Program_Access_MTM__r.size() > 0) {
                        
                        //Loop on the web program access 
                        for(Web_Program_Access_MTM__c webAccess : progs.Web_Program_Access_MTM__r)  {
                            
                            //If already contains the account Id the get and update.
                            mapProgramWithWebProgramAccessIds.get(progs.Id).add(String.valueOf(webAccess.Adv_com_Program_ID__c)); 
                        }  
                    }
                }
                
                //Check for the Map size.
                if(mapProgramWithWebProgramAccessIds != null && mapProgramWithWebProgramAccessIds.size() > 0 
                   && mapAccountWithProgramIds != null && mapAccountWithProgramIds.size() > 0) {
                    
                    //Loop on the Map of Accont. 
                    for(Id accId : mapAccountWithProgramIds.keyset()) {
                        
                        String webProgramAccessIds = '';
                        
                        //Check for the Map have some values. 
                        if(mapAccountWithProgramIds.get(accId).size() > 0) {
                            
                            //Loop on the set of Program Ids.
                            for(Id pgramId : mapAccountWithProgramIds.get(accId)) {
                                
                                if(mapProgramWithWebProgramAccessIds.containsKey(pgramId)) {
                                    for(String str : mapProgramWithWebProgramAccessIds.get(pgramId))
                                        webProgramAccessIds += str+',';
                                }
                            }
                            
                            webProgramAccessIds = webProgramAccessIds.removeEnd(',');
                            
                            //Adding the values in the Account Map. 
                            mapAccounts.put(accId, new Account(Id = accId, Web_Program_Access__c = webProgramAccessIds));
                        }
                    }
                       
                    //Check for the size of the Map. 
                    if(mapAccounts != null && mapAccounts.size() > 0) {
                        Util.ByPassAllTriggers = true;
                        update mapAccounts.values();
                        Util.ByPassAllTriggers = false;
                    }
                }
            }
        }
    }
  
    /**
     *  @description    :   This method is used to populate Main Contact Signer On Contact
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Added By Dipesh Gupta - 11/11/2019 - CR-20190419-13012.
     * 
    **/
    public static void populateMainContactSignerOnContact(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships) {
        //Set Of Memberships Id Where Active_Subscription__c is not null
        Set<Id> setMembershipIds = new Set<Id>();
        //List to hold the new Value Of contact
        //VH 12/06/2019 - converted this to a map due to duplicate id in list error when updating multiple memberships
        Map<Id, Contact> contactToBeUpdate = new  Map<Id, Contact>();
        //If Renewal_Opportunity_Main_Contact__c is not equels to null then on respective contact Main_Contact_Signer__c should be marked true. 
        for (Membership__c membership : newMemberships) {
            //Check for conditions
            if (membership.Renewal_Opportunity_Main_Contact__c != Null && (oldMapMemberships == null || 
               (oldMapMemberships.get(membership.Id).Renewal_Opportunity_Main_Contact__c != membership.Renewal_Opportunity_Main_Contact__c))) {
                   //Adding ids into set
                   setMembershipIds.add(membership.Id);
            }
        }
        //Check for size
        if(!setMembershipIds.isEmpty()){
            //Getting new or updated membership 
            for(Membership__c membership : [SELECT Id , Renewal_Opportunity_Main_Contact__c FROM Membership__c 
                                            WHERE Id IN: setMembershipIds 
                                            AND Renewal_Opportunity_Main_Contact__c != Null]) {
                    String temp = membership.Renewal_Opportunity_Main_Contact__c;
                    temp = temp.subStringAfter('/');
                    temp = temp.subStringBefore('"'); 
                if(String.isNotBlank(temp)){
                    //Instance Of contact to hold its new value
                    contactToBeUpdate.put(temp, new Contact(Id = temp, Main_Contact_Signer__c = True));
                }
            }
        }
        if(!contactToBeUpdate.isEmpty()){
            //Bypass all triggers
            Util.BypassAllTriggers = true;
            //Update the Membership
            update contactToBeUpdate.values();
            //Reset the flag to whatever it was originally
            Util.BypassAllTriggers = false;
        }
    }  
    /**
     *  @description    :   This method is used to populate Main Contact on Contact ABC
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Added By Dipesh Gupta - 12/19/2019 - CR-20191029-13473.
     * 
    **/
    public static void populateMainContactOnContractABC(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        //Map of Contract ABC to update Main Contact
        Map<Id, Contract__c> mapContractABCs = new Map<Id, Contract__c>(); 
        
        //Loop over new list of memberships
        for(Membership__c membership : newMemberships){
            
            //Check for condition 
            if((membership.Active_Contract_Main_Contact__c != oldMapMemberships.get(membership.Id).Active_Contract_Main_Contact__c) && membership.Active_Contract_Idenfied__c != NULL){
                
                //Putting values into Map
                mapContractABCs.put(membership.Active_Contract_Idenfied__c, new Contract__c(Id = membership.Active_Contract_Idenfied__c, Main_Contact__c = membership.Active_Contract_Main_Contact__c));
            }
        }
        
         //Check for Contract ABC
            if(mapContractABCs.size() > 0) {
            	
            	//Bypass all the trigger
            	util.bypassAllTriggers = true;
            	
            	update mapContractABCs.values();
            	
                //Resume triggers
                util.bypassAllTriggers = false;
            }
    } 
      /**
     *  @description    :   This method is used to populate Main point of Contact on Meeting Utilization. 
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Added By Dipesh Gupta - 06/02/2020 - CR-20200408-13916.
     * 
    **/
    public static void populateMainContactOnMeetingUtility(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        //Set of Membership
        Set<Id> setOfMembershipIds = new  Set<Id>();
        
        //Loop over new list of memberships
        for(Membership__c membership : newMemberships){
            
            //Check for condition 
            if(oldMapMemberships != null && membership.Active_Contract_Main_Contact__c != oldMapMemberships.get(membership.Id).Active_Contract_Main_Contact__c){
                
                //Putting id's into set
               setOfMembershipIds.add(membership.Id);
            }
        }
        
        
        if(setOfMembershipIds.size() > 0 && (!system.isBatch()) && !System.isFuture()) {
            
            //Bypass all the trigger
            upadteMainPointContact(setOfMembershipIds);
        }
        
    }

     /**
     *  @description    :   This method is used to populate Main point of Contact on Meeting Utilization. 
     * 
     *  @args           :   SetOfMembership Ids 
     *
     *  @return         :   void
     *
     *  @Version        :   V1.0 - Added By Dipesh Gupta - 06/02/2020 - CR-20200408-13916.
     * 
    **/    
    @future
    public static void upadteMainPointContact(Set<Id> setOfMembershipIds){
        
        List<Meeting_Utilization__c> meetingUtilToBeUpdate = new List<Meeting_Utilization__c>();
        if(setOfMembershipIds.size() > 0){
            for(Meeting_Utilization__c mu : [Select Id,Start_Date__c,Membership__c,
                                             Membership__r.Active_Contract_Main_Contact__c,
                                             Contact__c From Meeting_Utilization__c 
                                             Where Membership__c IN : setOfMembershipIds 
                                             AND Start_Date__c >= TODAY]){
                                                 
                if(mu.Contact__c != null && mu.Contact__c == mu.Membership__r.Active_Contract_Main_Contact__c){
                        
                    //Populate the main pointt of contact
                    mu.Main_Point_of_Contact__c = true;
                    
                    meetingUtilToBeUpdate.add( mu);
                }
            }
        }
        //Util.BypassTrigger.
        if(meetingUtilToBeUpdate.size() > 0){
            Util.BypassAllTriggers = true;
            update meetingUtilToBeUpdate;
            Util.BypassAllTriggers = false;
        }
    }
    
    
    /**
     *  @description    :   This method is used to populate Payer Status
     * 
     *  @args           :   List of new Membership, Map of old Membership
     *
     *  @return         :   void
     *
     *  @Version        :   v1.0 - Added By Mahendra Swarnkar - 08/17/2020 - CR-20200427-13986.
     * 
    **/
    public static void populatePayerStatus(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships) {
        
        //Set to hold the active subscription Ids
        Set<Id> setActiveSubscriptionIds = new Set<Id>();
        
        //Set to hold the Active Contract ABC's Ids
        Set<Id> setActiveContractABCIds = new Set<Id>();
        
        //Loop over the membership new list
        for(Membership__c memb : newMemberships) {
            
            //insert/update case
            if(memb.Account_Name__c != null && ( oldMapMemberships == null 
                                                || oldMapMemberships.get(memb.Id).Account_Name__c != memb.Account_Name__c
                                                || oldMapMemberships.get(memb.Id).Active_Subscription__c != memb.Active_Subscription__c
                                                || oldMapMemberships.get(memb.Id).Active_Contract_Idenfied__c != memb.Active_Contract_Idenfied__c
                                                || oldMapMemberships.get(memb.Id).Program__c != memb.Program__c)
            ) {
                
                //Populate the sets
                if(memb.Active_Subscription__c != null ) 
                    setActiveSubscriptionIds.add(memb.Active_Subscription__c);
                
                //Populate the sets
                if(memb.Active_Contract_Idenfied__c != null ) 
                    setActiveContractABCIds.add(memb.Active_Contract_Idenfied__c);
                
            }
        }
        
        //if(setActiveSubscriptionIds.size() > 0 || setActiveContractABCIds.size() > 0){
         
        //Map to hold the Active subscriptions
        Map<Id, SBQQ__Subscription__c> mapActiveSubscriptions;
        if(setActiveSubscriptionIds.size() > 0) {
            mapActiveSubscriptions = new Map<Id, SBQQ__Subscription__c>([Select Id, SBQQ__Account__c, Program__c, SBQQ__RequiredByProduct__c, 
                                                                          SBQQ__RequiredByProduct__r.Parent_Product__c, SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c, 
                                                                          SBQQ__Product__c, SBQQ__Product__r.Parent_Product__c, SBQQ__Product__r.Parent_Product__r.Program__c 
                                                                         From SBQQ__Subscription__c 
                                                                         Where ID IN : setActiveSubscriptionIds]);
        }
        
        //Map to hod the Active Contract ABCs
        Map<Id, Contract__c> mapActiveContractABCs;
        if(setActiveContractABCIds.size() > 0) {
            mapActiveContractABCs = new Map<Id, Contract__c>([Select Id, Payer_Account__c, Program__c From Contract__c Where ID IN : setActiveContractABCIds]);
        }
        
        //Loop over the Memberships
        for(Membership__c mem : newMemberships) {
            
            //insert/update case
            if(mem.Account_Name__c != null && ( oldMapMemberships == null 
                                                || oldMapMemberships.get(mem.Id).Account_Name__c != mem.Account_Name__c
                                                || oldMapMemberships.get(mem.Id).Active_Subscription__c != mem.Active_Subscription__c
                                                || oldMapMemberships.get(mem.Id).Active_Contract_Idenfied__c != mem.Active_Contract_Idenfied__c
                                                || oldMapMemberships.get(mem.Id).Program__c != mem.Program__c)
              ) {
                
                //Set default payer status
                String PAYER_STATUS = 'N/A';
                  
                //Check for acccount
                if(mem.Account_Name__c != null && mem.Program__c != null) {
                    
                    //Check for active Subscriptions
                    if(mem.Active_Subscription__c != null && mapActiveSubscriptions != null && mapActiveSubscriptions.size() > 0 
                        && mapActiveSubscriptions.containsKey(mem.Active_Subscription__c) && mapActiveSubscriptions.get(mem.Active_Subscription__c) != null) 
                    {
                        //Check for conditions to populate the payer status
                        if( mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c != null 
                           && mem.Account_Name__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c) 
                        {
                            
                            if((mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c)
                                /*|| (mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__c != null 
                                     && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__c != null 
                                     && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c != null 
                                     && mem.Program__c == mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c)
                                || (mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__c != null 
                                     && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__c != null 
                                     && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__r.Program__c != null 
                                     && mem.Program__c == mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__r.Program__c)*/
                            ) {
                                
                                PAYER_STATUS = Constants.PAYER; 
                            } else {
                                PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED_GLOBAL;
                            }
                            
                        } else {
                            if((mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c))
                                PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED;
                        }
                            /*if((mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c)
                                  || (mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__c != null 
                                       && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__c != null 
                                       && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c != null 
                                       && mem.Program__c == mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__RequiredByProduct__r.Parent_Product__r.Program__c)
                                  || (mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__c != null 
                                       && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__c != null 
                                       && mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__r.Program__c != null 
                                       && mem.Program__c == mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Product__r.Parent_Product__r.Program__c)
                               )
                        ) {
                            
                            PAYER_STATUS = 'Payer'; 
                        } else {
                        */
                            /*if(mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c != null 
                                && mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c != null
                                && mem.Account_Name__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).SBQQ__Account__c 
                                && mem.Program__c ==  mapActiveSubscriptions.get(mem.Active_Subscription__c).Program__c)
                                PAYER_STATUS = 'Payer';
                            else
                            */ 
                                
                            //PAYER_STATUS = 'Integrated';
                       // } 
                        //Check for tje Active Contract ABCs
                    } else if(mem.Active_Contract_Idenfied__c != null && mapActiveContractABCs != null && mapActiveContractABCs.size() > 0 
                           && mapActiveContractABCs.containsKey(mem.Active_Contract_Idenfied__c) && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c) != null) 
                    {
                        //Check for conditions to set the Payeer Status
                        if(mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Payer_Account__c != null 
                           && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Payer_Account__c == mem.Account_Name__c)
                        {
                            if(mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c != null 
                               && mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c == mem.Program__c)
                                
                                PAYER_STATUS = Constants.PAYER;
                            else
                                PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED_GLOBAL;    
                        } else {
                            if((mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c != null && mem.Program__c ==  mapActiveContractABCs.get(mem.Active_Contract_Idenfied__c).Program__c))
                                PAYER_STATUS = Constants.PAYER_STATUS_INTEGRATED;
                        }  
                    }
                }
                //Populate the Payer Status
                mem.Payer_Status__c = PAYER_STATUS;
            } 
        }
        //}
    }
    
     /**
    *  @description    :   	This method is used to update Membership Key Contact Status. 
    * 
    *  @args           :   	List of new Membership, Map of old Membership
    *
    *  @return         :   	void
    *
    *  @Version        :   	V1.0 - Added By Mahendra Swarnkar - 08/17/2020 - CR-20181004-12632 - MS 4: Removing key contact status upon membership drop.
    *				V1.1 - Modified - Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Modified method to have correct if condition
    * 
    **/   
    public static void UpdateMKConStatusChange(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        //Set of Membership
        Set<Id> setOfMembershipIds = new  Set<Id>();
        List<Membership_Key_Contact__c> listToBeUpdateMembershipKeyContact = new List<Membership_Key_Contact__c>();
        
        //Loop over new list of memberships
        for(Membership__c membership : newMemberships){
            
            //Subhash Garhwal - 04/27/2021 - CR-20210422-15095 - Changed condition 
            //From: String.isNotBlank(membership.Membership_Status_Text__c) && (oldMapMemberships != null || membership.Membership_Status_Text__c != oldMapMemberships.get(membership.Id).Membership_Status_Text__c
	    //To: String.isNotBlank(membership.Membership_Status_Text__c) && oldMapMemberships != null && membership.Membership_Status_Text__c != oldMapMemberships.get(membership.Id).Membership_Status_Text__c
            //Check for condition 
            if(String.isNotBlank(membership.Membership_Status_Text__c) /*&& membership.Membership_Status_Text__c.containsIgnoreCase('Prospect')*/ 
                && (oldMapMemberships != null && membership.Membership_Status_Text__c != oldMapMemberships.get(membership.Id).Membership_Status_Text__c )
            ) {
                //Putting id's into set
                setOfMembershipIds.add(membership.Id);
            }
        }
        
        //Check for size
        if(setOfMembershipIds.size() > 0) {
            
            //Get all the related MKC records
            for(Membership_Key_Contact__c mKC : [SELECT Id, Inactive_On_Membership_Drop__c, Key_Contact_Status__c, Membership__r.Membership_Status_Text__c
                                                 FROM Membership_Key_Contact__c 
                                                 WHERE Membership__c IN : setOfMembershipIds])
            {
                //MKC new instance
                Membership_Key_Contact__c MemberKeyContact = new Membership_Key_Contact__c(Id = mKC.Id);
                
                //Check for Membership Status
                if(mKC.Key_Contact_Status__c == 'Active' && String.isNotBlank(mKC.Membership__r.Membership_Status_Text__c) && mKC.Membership__r.Membership_Status_Text__c.containsIgnoreCase('Prospect')) {
                    
                    MemberKeyContact.Key_Contact_Status__c = 'Inactive';
                    
                    //Check if Membereship is dropped then update the Inactive_On_Membership_Drop__c to true
                    if(mKC.Membership__r.Membership_Status_Text__c == Constants.PROSPECT_RECENT_DROP)    
                        MemberKeyContact.Inactive_On_Membership_Drop__c = true;                         
                    
                    listToBeUpdateMembershipKeyContact.add(MemberKeyContact);
                    
                } else if( mKC.Inactive_On_Membership_Drop__c == true && String.isNotBlank(mKC.Membership__r.Membership_Status_Text__c) && mKC.Membership__r.Membership_Status_Text__c.containsIgnoreCase('Member')){
                    
                    MemberKeyContact.Inactive_On_Membership_Drop__c = false;
                    listToBeUpdateMembershipKeyContact.add(MemberKeyContact); 
                }
            }
        }
        
        //Check for size
        if(listToBeUpdateMembershipKeyContact.size() > 0)
        {
            //Disable all the triggers
            Util.BypassAllTriggers = true;
            
            //Update MKC records
            update listToBeUpdateMembershipKeyContact;
            
            //Enable all the triggers
            Util.BypassAllTriggers = false;
        }
    }

    /**
    *  @description    :   This method is used to insert generic owner on Membership. 
    * 
    *  @args           :   List of new Membership, Map of old Membership
    *
    *  @return         :   void
    *
    *  @Version        :   V1.0 - Created By - Neha Sharma - 11/03/2020 - CR-20200930-14569 - method for insert SF Admin owner on Membership
    * 
    **/   
    public static void UpdateOwnerOnMembership(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        if(newMemberships.size() > 0) {
            
            //get SF Admin user
            Id membershipOwnerId = [Select Id from User Where Name =: Label.Membership_Owner_Name]?.Id;
            for(Membership__c mem : newMemberships) {
                
                if(mem.OwnerId != membershipOwnerId && (oldMapMemberships == null || oldMapMemberships != null /*&&
                                                 /*(oldMapMemberships.get(mem.Id).OwnerId != mem.OwnerId || 
                                                  oldMapMemberships.get(mem.Id).Membership_Status_Text__c != mem.Membership_Status_Text__c )*/))
                {
                    if(String.isNotBlank(membershipOwnerId))
                    {
                        mem.OwnerId = membershipOwnerId;
                    }
                }   
            }
        }
    }
    
     /**
    *  @description    :   This method is used to create case for Membership. 
    * 
    *  @args           :   List of new Membership, Map of old Membership
    *
    *  @return         :   void
    *
    *  @Version        :   V1.0 - Created By - Neha Sharma - 11/10/2020 - CR-20201021-14625 - Add automation of cases for cappex.
    * 
    **/ 
     
    public static void createCappexRequestCases(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        if(newMemberships.size() > 0) {
            
            //Add cases for Cappex Request
            List<Case> cases = new List<Case>();
            Set<Id> membershipIds = new Set<Id>();

            Id cxcnProgramId = [Select Id From Program__c Where Program_Acronym__c =: Constants.PROGRAM_ACRONYM_CXCN And Status__c = 'Active']?.Id;
            
            for(Membership__c membership : newMemberships) {
                
                if( membership.Membership_Status__c == Constants.MEMBER_PAYER && membership.Program__c == cxcnProgramId 
                   && (oldMapMemberships == null || (oldMapMemberships != null && (oldMapMemberships.get(membership.Id).Membership_Status__c != membership.Membership_Status__c 
                                                                                   || oldMapMemberships.get(membership.Id).Program__c != membership.Program__c)
                                                    ) 
                      )
                  ) {
                      
                    membershipIds.add(membership.Id);
                  }
            }
            
            if(membershipIds.size() > 0)
            {
            	for(Membership__c membership : [Select Id, Account_Name__c, Account_AM__c, OwnerId, (Select Id from Cases__r) from Membership__c Where Id =: membershipIds]) {

                List<Case> relatedCases = membership.cases__r;

                if( relatedCases.size() == 0) {

                    Case cse = new Case();
                    cse.AccountId = membership.Account_Name__c;
                    cse.Reason = Constants.CASE_REASON_CONTRACT_CRITERIA_AUDIT;
                    cse.Membership__c = membership.Id;

                    if(membership.Account_AM__c != null)
                        cse.OwnerId = membership.Account_AM__c;
                    else
                        cse.OwnerId = membership.OwnerId;
                    
                    cse.Subject = Constants.CASE_REASON_CONTRACT_CRITERIA_AUDIT;
                    cse.Type = Constants.CASE_TYPE_CAPPEX_CLIENT_SUPPORT;
                    cse.Origin = Constants.CASE_ORIGIN_WORKFLOW;
                    cse.Status = Constants.CASE_STATUS_NEW;
                    cse.RecordTypeId = Constants.CASE_CAPPEX_REQUESTS_RT_ID;
                    cases.add(cse);
                }
            }
        }
            if(cases.size() > 0) {
                
                Util.BypassAllTriggers = true;
                Insert cases;
                Util.BypassAllTriggers = false;
            }
            
        }
    }
    
    /**
    *  @description    :   Populate Main Contact on related Sales Invoice Line Item.. 
    * 
    *  @args           :   List of new Membership, Map of old Membership
    *
    *  @return         :   void
    *
    *  @Version        :   V1.0 - Created By - Mahendra Swarnkar - 12/1/2020 - CR-20200720-14338 - Populate Main Contact on related Sales Invoice Line Item.
    * 				   :   V1.1 - Modified By - Neha Sharma - 05/02/2022 - CR-20210520-15169 - Added condition to populate active renewal opp main contact if Active Membership Main Contact is blank
    * 
    **/ 
    public static void updateMainContactOnSIL(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMapMemberships){
        
        //Set to hold the Membership Ids
        Set<Id> setMembershipIds = new Set<Id>();
            
        for(Membership__c membership : newMemberships) {
            
            //Modified By - Neha Sharma - 05/02/2022 - CR-20210520-15169 -- added condition for active renewal opp main contact
            //Check for Active_Contract_Main_Contact__c
            if((membership.Active_Contract_Main_Contact__c != null 
                && membership.Active_Contract_Main_Contact__c != oldMapMemberships.get(membership.Id).Active_Contract_Main_Contact__c) || 
                membership.Active_Renewal_Opportunity_Main_Contact__c != null)
            {
	    	setMembershipIds.add(membership.Id);
	    }
        }
        
        //Check for size
        if(setMembershipIds.size() > 0) {
            
            //List to hold the sales invoice line Items to be update
            List<c2g__codaInvoiceLineItem__c> salesInvoiceLinesToUpdate = new List<c2g__codaInvoiceLineItem__c>();
        
            //Modified By - Neha Sharma - 05/02/2022 - CR-20210520-15169 -- added field Membership__r.Active_Renewal_Opportunity_Main_Contact__c
            //Query over the sales invoice line Items
            for(c2g__codaInvoiceLineItem__c  invoiceLine : [Select Id, Main_Contact__c, Membership__r.Active_Contract_Main_Contact__c, Membership__r.Active_Renewal_Opportunity_Main_Contact__c
                                                             From c2g__codaInvoiceLineItem__c
                                                             Where Membership__c != null AND Membership__c IN :setMembershipIds])
            {
                if(invoiceLine.Membership__r.Active_Contract_Main_Contact__c != null 
                   && invoiceLine.Main_Contact__c != invoiceLine.Membership__r.Active_Contract_Main_Contact__c)
                {
                    invoiceLine.Main_Contact__c = invoiceLine.Membership__r.Active_Contract_Main_Contact__c;
                    salesInvoiceLinesToUpdate.add(invoiceLine);	    
                }
                //Modified By - Neha Sharma - 05/02/2022 - CR-20210520-15169 -- added condition for active renewal opp main contact
                else{
                    if(invoiceLine.Membership__r.Active_Renewal_Opportunity_Main_Contact__c != null 
                       && invoiceLine.Main_Contact__c != invoiceLine.Membership__r.Active_Renewal_Opportunity_Main_Contact__c)
                    {
                        invoiceLine.Main_Contact__c = invoiceLine.Membership__r.Active_Renewal_Opportunity_Main_Contact__c;
                        salesInvoiceLinesToUpdate.add(invoiceLine);
                    }
                }
            }
            
            //Check for size
        	if(salesInvoiceLinesToUpdate.size() > 0) {
                
                //Disable all the triggers
                Util.BypassAllTriggers = true;
                
                Update salesInvoiceLinesToUpdate;
                
                //Enable all the triggers
                Util.BypassAllTriggers = false;
            }
        }
    }

    /**
     * @description     : This method is used to sync Partner Status field on Registration in case of insert, delete & update
     * 
     * @args            : List<Membership__c> newMemberships, Map<Id, Membership__c> oldMemberships
     * 
     * @return          : void
     * 
     * @revision log    : V1.0 Created - Saurabh Kumar - CR-20200821-14453 - 09/29/2020
     * */
    public static void syncRegistrationPartnerStatus(List<Membership__c> newMemberships, Map<Id, Membership__c> oldMemberships){
        
        //Set to hold Institution Ids to get all Registrations
        Set<Id> institutionIds = new Set<Id>();
        
        //Set to hold Membership Ids which should be skipped
        Set<Id> membershipIdsToSkipped = new Set<Id>();
        
        //Map to hold registration which should be processed
        Map<Id, Registration__c> registrations = new Map<Id, Registration__c>();
        
        for(Membership__c membership : newMemberships != null ? newMemberships : oldMemberships.values()){
            
            if(oldMemberships == null && membership.Membership_Status__c != null && membership.Membership_Status__c.startsWith(Constants.KEYWORD_MEMBER)){
                institutionIds.add(membership.Account_Name__c);
            }else if(newMemberships == null && membership.Membership_Status__c != null && membership.Membership_Status__c.startsWith(Constants.KEYWORD_MEMBER)){
                institutionIds.add(membership.Account_Name__c);
                membershipIdsToSkipped.add(membership.Id);
            }else if(oldMemberships != null && (membership.Account_Name__c != oldMemberships.get(membership.Id).Account_Name__c
                     || membership.Program__c != oldMemberships.get(membership.Id).Program__c
                     ||(membership.Membership_Status__c != oldMemberships.get(membership.Id).Membership_Status__c &&
                       membership.Membership_Status__c.startsWith(Constants.KEYWORD_MEMBER) || 
                        (oldMemberships.get(membership.Id).Membership_Status__c != null && oldMemberships.get(membership.Id).Membership_Status__c.startsWith(Constants.KEYWORD_MEMBER)) ))){
                 institutionIds.add(membership.Account_Name__c);           
            }
        }
        
        if(institutionIds.size() == 0)
            return;
        
       /*registrations = new Map<Id, Registration__c>([Select Id, EAB_Event__c From Registration__c Where EAB_Event__c != null AND Contact__c != null AND
                                                    Contact__r.AccountId != null AND Contact__r.AccountId IN : institutionIds]);
       
       if(registrations.size() > 0)
        RegistrationHelper.updatePartnerStatus(registrations.keySet(), membershipIdsToSkipped); */
        //Modified By - Mahendra Swarnakar - 03/04/2021 - CR-20210301-14956 - Error when trying to edit any fields on Cappex Membership pages
                        
        registrations = new Map<Id, Registration__c>([Select Id, Name, Origin__c, Parent_Registration__c, Automated_Update__c, EAB_Event__c, EAB_Event__r.Status__c 
                                                      From Registration__c Where EAB_Event__c != null AND Contact__c != null 
                                                      AND Contact__r.AccountId != null AND Contact__r.AccountId IN : institutionIds 
                                                      AND (EAB_Event__r.Status__c =: Constants.EAB_EVENT_STATUS_OPEN_REGISTRATION 
                                                           OR EAB_Event__r.Status__c =:Constants.EAB_EVENT_STATUS_OPEN_WAITLIST_ONLY)
                                                     ]);
        
        Boolean isEABEventManager = FeatureManagement.checkPermission('EAB_Event');
         
        
        if( isEABEventManager && registrations.size() > 0)
            RegistrationHelper.updatePartnerStatus(registrations.keySet(), membershipIdsToSkipped);
        //Ends Here - CR-20210301-14956
         
    }
}