// - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
// - 04/30/2013 - Victor - Code modified as per the CR-20130221-2554
// - 02/12/2014 - Abhinav Sharma (UpdateNextDecisionDate) method updated for CR-20130822-3489 - it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
// - 04/16/2014 - Abhinav Sharma - CR-20140321-4841 - (Added IsDeleted = false to the WHERE clause in the getTasksWithUpdatedProgInfo and getEventsWithUpdatedProgInfo methods)
// - 08/06/2014 - Ajit Surana - CR-20140717-6282 - (MembershipsWithOpps) method updated - Removed the Record Type criteria from Opportunity inline query.
// - 09/15/2014 - Abhinav Sharma - CR-20140429-5272 - Modified to removed the existing Bundle_Parent__c references & commenting of it
//- 04/03/2015 - Abhinav Surana - CR-20150220-8700 - Query modified at line# 167 - Added idDeleted = false and ALL ROWS to it
//Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
// Modified By - Victor Hanson - 08/16/2017 - Issue--CR11106--QA--00005464 - updated CalculateNextDecisionDate to work with Q2C architecture
//Modified By - Subhash Garhawal - 08/20/2018 - CR-20180726-12469 - updated calcNextDecisionDateFromCPQOpps to remove the check for Opportunity
// Modified By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Commented the following Methds :- CalculateNextDecisionDate(),calcNextDecisionDateFromCPQOpps(), calcNextDecisionDateFromCPQOpps(Set<Id> setCPQOppIds)" 
//Modified By - Dipesh Gupta -09/25/2019 - CR-20190429-13049 - Added Check for Visit Location as per taylor chatter
//Modified By - Dipesh Gupta -10/04/2019 - CR-20190429-13049 - Added Check for Event_Purpose__c as per carter chatter
public without sharing class OpportunityTriggerUtilities {
    
    //Static flag to control the execution of calcNextDecisionDateFromCPQOpps
    public static boolean BYPASS_CALC_NEXT_DECISION_DATE_FROM_CPQ_OPPS = false;
    
    public static void UpdateContractDocs(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        
        // return immediately if this is a mass insert/update -- should not need to connect docs in these scenarios
        if (triggerNew.size() > 1) return;
        
        Set<Id> contractIds = new Set<Id>();
        
        for (Opportunity newOpp : triggerNew) {
            Opportunity oldOpp = new Opportunity();
            if (triggerOldMap!= null) {
                oldOpp = triggerOldMap.get(newOpp.Id);
            }
            
            if (oldOpp != null) {
                if (newOpp.Signed_Opportunity_Contract__c != null && oldOpp.Signed_Opportunity_Contract__c != newOpp.Signed_Opportunity_Contract__c) {
                    contractIds.add(newOpp.Signed_Opportunity_Contract__c);
                }
            }
            else {
                if (newOpp.Signed_Opportunity_Contract__c != null) {
                    contractIds.add(newOpp.Signed_Opportunity_Contract__c);
                }
            }
        }
        
        if (contractIds.size() > 0) {
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch())
                GlobalUtilities.ConnectDocsToContract(contractIds);
            
            //Bhavi Sharma - 04/26/2013 - CR-20130227-2597 - Added condition to make the callout only if not current context is not batch or future
            if(!System.isFuture() && !System.isBatch())
                GlobalUtilities.ConnectDocsToOpp(contractIds);
        }
    }
    
    //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Starts from here
    /**
     * 
     * @description: get a list of the associated memberships and update the next decision date on those memberships
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Modified - 08/16/2017 - Victor Hanson - Issue--CR11106--QA--00005464
     * 
     **/
    /*public static void CalculateNextDecisionDate(List<Opportunity> triggerNew) {
        Set<Id> memIds = new Set<Id>();
        Set<Id> setCPQOppIds = new Set<Id>();
        for (Opportunity o : triggerNew) {
            
            //if membership is populated, add the membership id to the list of ids
            /*if (o.Membership__c != null) {
                
                memIds.add(o.Membership__c);
            }
            else if (o.SBQQ__PrimaryQuote__c != null && (CPQConstants.OPP_INITIATING_RT_ID_SET.contains(o.RecordTypeId) || CPQConstants.OPP_CONTINUING_RT_ID_SET.contains(o.RecordTypeId))) {
                
                //if this is one of the new opportunity recordTypes, add the opp to our CPQ list
                setCPQOppIds.add(o.Id);
            //}
        }
        
        List<Membership__c> memberships = MembershipsWithOpps(memIds, triggerNew);
        
        //update the Next Decision Date on memberships for the new CPQ architecture (ie: multiple products on a single opp)
        if (setCPQOppIds.size() > 0)
            calcNextDecisionDateFromCPQOpps(setCPQOppIds);
        
        
        // now run the logic to calculate the next decision date
        /*if (memberships.size() > 0)
        	UpdateNextDecisionDate(memberships);
    }
    */
    
    
    /**
     * 
     * @description: returns a list of memberships related to the Programs on the CPQ Opp's primary proposal
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   List<Membership__c>
     *
     *  @revision Log   :   V1.0 - Created - 08/16/2017 - Victor Hanson - Issue--CR11106--QA--00005464
     * 
     **/
    /*public static void calcNextDecisionDateFromCPQOpps(Set<Id> setCPQOppIds) {
        
        //bypass method if it already executed
        if (BYPASS_CALC_NEXT_DECISION_DATE_FROM_CPQ_OPPS) return;
        
        //get the unique list of Account-Program for each quoteLine
        Set<String> ukAccountProgramOnQuoteLine = new Set<String>();
        Set<Id> programIds = new set<Id>();
        Set<Id> accountIds = new set<Id>();
        for (SBQQ__QuoteLine__c qL : [SELECT Id, SBQQ__Product__r.Program__c, SBQQ__Quote__r.SBQQ__Account__c 
                                      FROM SBQQ__QuoteLine__c
                                      WHERE Component__c = false 
                                      AND SBQQ__Quote__r.SBQQ__Opportunity2__c IN :setCPQOppIds
                                      AND SBQQ__Product__r.Program__c != null
                                      AND SBQQ__Quote__r.SBQQ__Account__c != null])
        {
            
            ukAccountProgramOnQuoteLine.add(qL.SBQQ__Quote__r.SBQQ__Account__c + '-' + qL.SBQQ__Product__r.Program__c);
            accountIds.add(qL.SBQQ__Quote__r.SBQQ__Account__c);
            programIds.add(qL.SBQQ__Product__r.Program__c);
        }
        
        //calculate the next decision date
        calcNextDecisionDateFromCPQOpps(ukAccountProgramOnQuoteLine, accountIds, programIds);
    }*/
    
    /**
     * 
     * @description: returns a list of memberships related to the Programs on the CPQ Opp's primary proposal
     *
     *  @args           :   List<Opportunity>
     *
     *  @return         :   string
     *
     *  @revision Log   :   V1.0 - Created - 08/16/2017 - Victor Hanson - Issue--CR11106--QA--00005464
     *					:   V1.1 - Modified - 09/20/2018 - Subhash Garhawal - CR-20180726-12469	
     * 
     **/
    /*public static String calcNextDecisionDateFromCPQOpps(Set<String> ukAccountProgramOnQuoteLine, Set<Id> accountIds, Set<Id> programIds) {
        
        //bypass method if it already executed
        if (BYPASS_CALC_NEXT_DECISION_DATE_FROM_CPQ_OPPS) return null;
        
        //set the bypass to true, so we only execute this method once per invokation
        BYPASS_CALC_NEXT_DECISION_DATE_FROM_CPQ_OPPS = true;
        
        //set of all membership IDs so we can query for the subscription periods related to them
        Set<Id> membershipIds = new Set<Id>();
        
        //get the list of account-program -> Membership for the each institution, where the Account/Program combo is in ukAccountProgramOnQuoteLine
        Map<String, Membership__c> ukAcctProgramToMembership = new Map<String, Membership__c>();
        for (Membership__c m : [SELECT Id, Account_Name__c, Program__c, Next_Decision_Date__c
                                FROM Membership__c 
                                WHERE Account_Name__c IN :accountIds 
                                  AND Program__c IN :programIds]) 
        {
            
            if (ukAccountProgramOnQuoteLine.contains(m.Account_Name__c + '-' + m.Program__c)) {
                
                ukAcctProgramToMembership.put(m.Account_Name__c + '-' + m.Program__c, m);
                
                //add the membership id to our set
                membershipIds.add(m.Id);
            }
        }
        system.debug('@@membershipIds:' + membershipIds);
        
        //get a map of MembershipId -> Subscription Period, sorted by Period Start Date ASC
        Map<Id, list<Subscription_Period__c>> mapMembershipIdToListSP = new Map<Id, list<Subscription_Period__c>>();
        for (Subscription_Period__c sp : [SELECT Id, Program_Subscription__r.Membership__c, Period_Start_Date__c, Opt_Out_Early_Termination_Date__c, Decision_Type__c
                                          FROM Subscription_Period__c 
                                          WHERE Program_Subscription__r.Membership__c IN :membershipIds
                                          AND Stage__c = 'Pending'
                                          AND Period_Start_Date__c >= TODAY
                                         ORDER BY Period_Start_Date__c, Opt_Out_Early_Termination_Date__c DESC]) 
        {
            
            List<Subscription_Period__c> tempListSP = new List<Subscription_Period__c>();
            
            //if the list of subscription periods already exists, get the list so we can add to it
            if (mapMembershipIdToListSP.containsKey(sp.Program_Subscription__r.Membership__c))
                tempListSP = mapMembershipIdToListSP.get(sp.Program_Subscription__r.Membership__c);
            
            //add the subscription period to our list
            tempListSP.add(sp);
            
            //add the membership -> list<subscription period> to the map
            mapMembershipIdToListSP.put(sp.Program_Subscription__r.Membership__c, tempListSP);
        }
        system.debug('@@mapMembershipIdToListSP:' + mapMembershipIdToListSP);
        
        //get the map of account-program -> list<Opportunity>
        //Commented out as per the requirements on CR-20180726-12469
        /*Map<String, list<Opportunity>> ukAcctProgramToOpportunityList = new Map<String, list<Opportunity>>();
        for (SBQQ__QuoteLine__c qL : [SELECT Id, SBQQ__Product__r.Program__c, SBQQ__Quote__r.SBQQ__Account__c,
                                      SBQQ__Quote__r.SBQQ__Opportunity2__r.Opt_Out_Date__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Start__c, SBQQ__Quote__r.SBQQ__Opportunity2__c
                                      FROM SBQQ__QuoteLine__c
                                      WHERE Component__c = false
                                      AND SBQQ__Product__r.Program__c IN :programIds
                                      AND SBQQ__Quote__r.SBQQ__Account__c IN :accountIds
                                      AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Start__c >= TODAY
                                      AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName LIKE '%Pending%'
                                      ORDER BY SBQQ__Quote__r.SBQQ__Opportunity2__r.Start__c ASC])
        {
            list<Opportunity> opps = new list<Opportunity>();
            String uk = qL.SBQQ__Quote__r.SBQQ__Account__c + '-' + qL.SBQQ__Product__r.Program__c;
            
            if (ukAcctProgramToOpportunityList.containsKey(uk)) opps = ukAcctProgramToOpportunityList.get(uk);
            
            opps.add(
                new Opportunity(Id=qL.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                Start__c=qL.SBQQ__Quote__r.SBQQ__Opportunity2__r.Start__c,
                                Opt_Out_Date__c=qL.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opt_Out_Date__c)
            );
            
            ukAcctProgramToOpportunityList.put(uk, opps);
        }*/
        /*system.debug('@@ukAcctProgramToMembership:' + ukAcctProgramToMembership);
        
        for (String key : ukAcctProgramToMembership.keySet()) {
            
            //get the membership
            Membership__c m = ukAcctProgramToMembership.get(key);
            
            if (m.Next_Decision_Date__c < date.today())
                m.Next_Decision_Date__c = null;
            
            //check if there is a corresponding opportunity for this Accont-Program
            /*if (ukAcctProgramToOpportunityList.containsKey(key)) {
                
                //get the opportunity
                Opportunity earliestPendingOpp = ukAcctProgramToOpportunityList.get(key)[0];
                
                if (earliestPendingOpp.Opt_Out_Date__c != null) {
                    m.Next_Decision_Date__c = earliestPendingOpp.Opt_Out_Date__c;
                }
                else {
                    if (earliestPendingOpp.Start__c != null)
                        m.Next_Decision_Date__c = earliestPendingOpp.Start__c.addDays(-1);
                }
            }*/
            
            //check if there is a pending Subscription Period with a closer date in the future
          /*  if (mapMembershipIdToListSP.containsKey(m.Id)) {
                
                //get the first subscription period from the list.  It was already sorted via SOQL, so the first record is the earliest
                Subscription_Period__c earliestPendingSubscriptionPeriod = mapMembershipIdToListSP.get(m.Id)[0];
                system.debug('@@mapMembershipIdToListSP.get(m.Id)[0]:' + mapMembershipIdToListSP.get(m.Id)[0]);
                //if the next decision date is null or subscription period start date is earlier than the current decision date
                if (m.Next_Decision_Date__c == null || earliestPendingSubscriptionPeriod.Period_Start_Date__c < m.Next_Decision_Date__c) {
                    
                    if (earliestPendingSubscriptionPeriod.Opt_Out_Early_Termination_Date__c != null 
                    	&& earliestPendingSubscriptionPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT)
                        m.Next_Decision_Date__c = earliestPendingSubscriptionPeriod.Opt_Out_Early_Termination_Date__c;
                    
                    //Added extra checks as per the requirements on CR-20180726-12469
                    else if(earliestPendingSubscriptionPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_NEED_NEW_LOA 
                    		|| (earliestPendingSubscriptionPeriod.Opt_Out_Early_Termination_Date__c == null
                    		&& earliestPendingSubscriptionPeriod.Decision_Type__c == CPQConstants.SUBSCRIPTION_PERIOD_DECISION_TYPE_OPT_OUT))
                        m.Next_Decision_Date__c = earliestPendingSubscriptionPeriod.Period_Start_Date__c;
                    
                    else
                     	m.Next_Decision_Date__c = null;
                }
            }
        }
        
        String logMessage = '';
        
        //if there are memberships in the map to update
        if (ukAcctProgramToMembership.size() > 0) {
            
            //bypass triggers and update the memberships
            util.BypassAllTriggers = true;
            
            if(System.isBatch()) {
                
                logMessage = Util.createLog(Database.update((ukAcctProgramToMembership.values()),false));
            } else {
                update ukAcctProgramToMembership.values();
            }
            
            Util.BypassAllTriggers = false;
        }
        
        return logMessage;
    }
    */
    //Commented By - Subhash Garhwal - 12/03/2018 - CR-20180726-12469 - Ends here
    
    public static Set<Id> PTRenewalOppIds() {
        // get the PT Renewal opportunity record types
        Set<Id> RenewalRecordTypeIds = new Set<Id>();
        String ptContractMaintenance = Util.RecordTypeId('Opportunity', 'PT Contract Maintenance');
        String ptContractRenewal = Util.RecordTypeId('Opportunity', 'PT Contract Renewal');
        // add these ids to the list of renewal record types ids
        RenewalRecordTypeIds.add(ptContractMaintenance);
        RenewalRecordTypeIds.add(ptContractRenewal);
        return RenewalRecordTypeIds;
    }
    
    //Modified by - Ajit Surana - 08/06/2014 - CR-20140717-6282
    //Remove the Record Type criteria from Opportunity inline query
    //Modified by - Victor Hanson - 08/16/2017 - Issue--CR11106--QA--00005464 - PTRenewalOppIds was commented out because it wasn't used.
    public static List<Membership__c> MembershipsWithOpps(Set<Id> memIds, List<Opportunity> opps) {
        //Set<Id> PTRenewalOppIds = PTRenewalOppIds();
        // get all memberships with the associated Opportunities
        List<Membership__c> memberships = [SELECT Id, Next_Decision_Date__c, 
                                        (SELECT Id, Start__c, Opt_Out_Date__c FROM Opportunities__r 
                                        WHERE StageName LIKE '%Pending%' AND Start__c >= :system.today() ORDER BY Start__c ASC) FROM Membership__c 
                                        WHERE Id IN :memIds];
        return memberships;
    }
    
    public static string UpdateNextDecisionDate(List<Membership__c> memberships) {
        
        // loop through all memberships and figure out the next decision date
        for (Membership__c m : memberships) {
            // clear out the next decision date for any memberships that are in the list
            m.Next_Decision_Date__c = null;
            
            // if there is an opportunity present, take the first value as the next decision date
            // (the proper sorting and filtering took place in the query)
            if (m.Opportunities__r.size() > 0) {
                // the earliest pending renewal opportunity
                Opportunity earliestPendingRenewalOpp = m.Opportunities__r[0];
                
                if (earliestPendingRenewalOpp.Opt_Out_Date__c != null) {
                    m.Next_Decision_Date__c = earliestPendingRenewalOpp.Opt_Out_Date__c;
                }
                else {
                    if (earliestPendingRenewalOpp.Start__c != null)
                        m.Next_Decision_Date__c = earliestPendingRenewalOpp.Start__c.addDays(-1);
                }
            }
        }
        
        Util.BypassAllTriggers = true;
        Util.IsBatch = true;
        
        // update all of our memberships
        //Modified By Abhinav Sharma - 02/12/2014 - Modify Batch_MembershipNextActivityDate to it uses System.Update() with AllOrNone = false so one failure won't cause the entire batch to fail.
        //Also, if there are failures in the database.saveResults[], they should be recorded and emailed to SFAdmin. - CR-20130718-3280
        //Database.update will be called only if current context is batch, else existing functionality willwork
        
        String logMessage = '';
        
        if(System.isBatch()) {
            
            logMessage = Util.createLog(Database.update((memberships),false));
        } else {
            update memberships;
        }
        
        Util.BypassAllTriggers = false;
        Util.IsBatch = false;
        return logMessage;
        
    }
    
    //CR-20111205-259
    //Static variable to hold the opportuny records to be updated
    public static Map<Id, Opportunity> opportunities;
    
    //Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
    // This method is to update the Initial Visit Date on opportunity object with the most recent active event
    //if no active event is there flag will be false
    public static void updateInitialVisitDateByEventDate(Map<Id, Opportunity> mapOpportunities){
        
        /*//Create a set to hold the Bundle Opportunity records
        Set<Id> bundleOpportunityIds = new Set<Id>();
        
        //Map to hold the Bundle opportunity data
        Map<Id, Opportunity> mapBundledOpportunity = new Map<Id, Opportunity>();*/
        
        //Check if code is running from Opportunity before context
        /*if(Trigger.isBefore && Trigger.New.size() > 0 && Trigger.New[0] instanceOf Opportunity) {
            
            //Commented By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
            //Loop through the new records
            for(Opportunity opp : mapOpportunities.values()) {
                
                if(opp.Bundle_Parent__c != null)
                    bundleOpportunityIds.add(opp.Bundle_Parent__c);
            }
            
            //Populate data in map
            //mapBundledOpportunity = new Map<Id, Opportunity>([Select Id, Initial_Visit_Date__c from Opportunity where ID IN: bundleOpportunityIds]);
        }*/
        
        //Map to hold the Opportunity ID as key and corresponding event record as value
        Map<Id, Event> mapOppIdWithEvent = new Map<Id, Event>();
        
        //Modified By - Ajit Surana - 04/03/2015 - CR-20150220-8700 - Query modified - Added idDeleted = false and ALL ROWS to it
        //Loop through event records
        for(Event evt : [Select Id, StartDateTime, WhatId from Event WHERE WhatId != null AND WhatId IN : mapOpportunities.keySet()
                            AND isDeleted=false 
                            AND Cancelled_Did_Not_Occur__c = false  
                            AND (Event_Type__c =: Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL 
                                 OR (Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT AND 
                                     (Event_Purpose__c =: Constants.EVENT_PURPOSE_INITIAL  /*OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT*/))
                                 OR Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT) 
                            ORDER BY StartDateTime ASC ALL ROWS]) {
            if(!mapOppIdWithEvent.containsKey(evt.WhatId))
                mapOppIdWithEvent.put(evt.WhatId, evt);                         
        }
        
        //Checking map for size value
        if(mapOpportunities.keySet().size() > 0) {
            
            //Modified By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
            //if(OpportunityTriggerHelper.DO_NOT_EXECUTE == false) {
            //fecth all the events associated with the opportunities
            //and loop through the records to get the lastest active event
            for(Opportunity opp : [Select Id, Initial_Visit_Date__c 
                                        FROM Opportunity where Id IN : mapOpportunities.keySet()]) {
                
                //Commented By - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
                // - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
                //Populate Initial_Visit_Date__c field iwith the Bundle_Parent__c's Initial_Visit_Date__c date .
                /*if(mapOpportunities.get(opp.Id).Bundle_Parent__c != null) {
                    if(opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Initial_Visit_Date__c != null) {
                    
                        //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = opp.Bundle_Parent__r.Initial_Visit_Date__c;
                    } else if(mapBundledOpportunity.containsKey(mapOpportunities.get(opp.Id).Bundle_Parent__c)){
                        
                        //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = mapBundledOpportunity.get(mapOpportunities.get(opp.Id).Bundle_Parent__c).Initial_Visit_Date__c;
                    }
                } else if(Trigger.New != null && Trigger.New.size() > 0 && Trigger.New[0] instanceOf Event && opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Initial_Visit_Date__c != null) {
                    
                    //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                    mapOpportunities.get(opp.Id).Initial_Visit_Date__c = opp.Bundle_Parent__r.Initial_Visit_Date__c;
                }*/ 
                                            
                //Check if there is any active event is assciated 
                if(mapOppIdWithEvent.containsKey(opp.Id) && mapOppIdWithEvent.get(opp.Id) != null 
                   && mapOppIdWithEvent.get(opp.Id).StartDateTime != null) {
                       
                    //As discuseed with VH:If an event with a start date > the opportunity’s Initial Vistit Date, 
                    //that should not overwrite the earlier initial visit date on the Opportunity. However, 
                    //if a new event is created for a qualifying initial visit and the StartDateTime is LESS 
                    //than the current Initial Visit Date on the Opportunity, that should overwrite the 
                    //Opportunity’s Initial Visit date with the earliest visit date.

                    if(mapOpportunities.get(opp.Id).Initial_Visit_Date__c == null 
                        || mapOpportunities.get(opp.Id).Initial_Visit_Date__c > Date.valueOf(mapOppIdWithEvent.get(opp.Id).StartDateTime)) {
                        
                        //Not Cancelled latest event: So copy this date to opportunity's Initial Visit Date
                        mapOpportunities.get(opp.Id).Initial_Visit_Date__c = Date.valueOf(mapOppIdWithEvent.get(opp.Id).StartDateTime);
                    }
                } else {
                    
                    //No events associted with this opportunity record or all events have been cancelled so mark Initial Visit Date as null
                    mapOpportunities.get(opp.Id).Initial_Visit_Date__c = null;
                }
            }
        }    
    }
    
    // update the program and program abbreviation field on all tasks/events associated with an opportunity
    public static void populateProgramInfoToActivities(list<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        
        // create a map of opportunities
        map<Id, Opportunity> mapOppsWithUpdatedPrograms = new map<Id, Opportunity>();
        
        // see if the opportunity's program changed
        for (Opportunity opp : newOpps) {
            
            // get the old opp if applicable
            Opportunity oldOpp;
            if (oldOppMap != null) 
                oldOpp = oldOppMap.get(opp.Id);
            
            if (oldOpp == null || opp.Program__c != oldOpp.Program__c) {
                
                mapOppsWithUpdatedPrograms.put(opp.Id, opp);
            }
        }

		//Checking map for size value        
        if (mapOppsWithUpdatedPrograms.size() > 0) {
            
            // get the opportunity map with program info
            mapOppsWithUpdatedPrograms = new map<Id, Opportunity>([SELECT Id, Program__c, Program__r.Program_Acronym__c, Program__r.Program_Abbreviation__c
                                          FROM Opportunity WHERE Id IN :mapOppsWithUpdatedPrograms.keySet()]);
            
            // for all opportunities that have updated program, we need to update their associated events/tasks
            list<Task> tasksToUpdate = getTasksWithUpdatedProgInfo(mapOppsWithUpdatedPrograms);
            list<Event> eventToUpdate = getEventsWithUpdatedProgInfo(mapOppsWithUpdatedPrograms);
            
            // bypass all triggers prior to update
            util.BypassAllTriggers = true;
            
            // update the tasks/events
            if (tasksToUpdate.size() > 0) update tasksToUpdate;
            if (eventToUpdate.size() > 0) update eventToUpdate;
            
            // turn off the trigger bypass
            util.BypassAllTriggers = false;
        }
    }
    
    //Modified By - Abhinav Sharma - 04/16/2014 - CR-20140321-4841 - Unable to change Opportunity Program if related Event is deleted 
    //Added IsDeleted = false to the WHERE clause
    public static list<Task> getTasksWithUpdatedProgInfo(map<Id, Opportunity> oppMap) {
        
    	// setup the list of tasks to return
        list<Task> tasksToReturn = new List<Task>();
    	
        //Checking for null value and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        
            // setup the list of tasks to return
            tasksToReturn = [SELECT Id, WhatId, Program__c, Program_Abbreviation__c FROM Task 
                             	WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS];
        
            //Checking for size value
            if (tasksToReturn.size() > 0) {
                
                // populate the program / abbreviation on all tasks
                tasksToReturn = populateProgInfo_Tasks(oppMap, tasksToReturn);
            }
        }    
        return tasksToReturn;
    }
    
    //Modified By - Abhinav Sharma - 04/16/2014 - CR-20140321-4841 - Unable to change Opportunity Program if related Event is deleted 
    //Added IsDeleted = false to the WHERE clause
    public static list<Event> getEventsWithUpdatedProgInfo(map<Id, Opportunity> oppMap) {
        
        // setup the list of tasks to return
        list<Event> eventsToReturn = new List<Event>();
        
        //Checking for null value and size value
        if(oppMap != null && oppMap.keySet().size() > 0) {
        	eventsToReturn = [SELECT Id, WhatId, Program__c, Program_Abbreviation__c FROM Event 
        						WHERE IsDeleted = false AND WhatId IN :oppMap.keySet() ALL ROWS];
        
            //Checking for size value
        	if (eventsToReturn.size() > 0) {
            
                // populate the program / abbreviation on all events
                eventsToReturn = populateProgInfo_Events(oppMap, eventsToReturn);
        	}
        }
        return eventsToReturn;
    }
    
    // popualte the program and abbreviation info on a given list of events
    public static list<Event> populateProgInfo_Events(map<Id, Opportunity> oppMap, list<Event> events) {
        
        // get all tasks associated with these opps and update their program / program abbreviation
        for (Event e : events) {
            
            //Checking for null and size value
            if (oppMap != null && oppMap.containsKey(e.WhatId) && oppMap.get(e.WhatId) != null) {
                
                // get the asociated opp
                Opportunity opp = oppMap.get(e.WhatId);
                
                // update the program / abbreviation
                if (String.isNotBlank(opp.Opportunity_Products__c)) {
                    e.Program__c = opp.Opportunity_Products__c;
                    e.Program_Abbreviation__c = null;
                }else if (opp.r_LOB__c != Null ) {
                    e.Program__c = opp.r_LOB__c;
                    e.Program_Abbreviation__c = null;
                } else if (opp.Program__c != null) {
                    e.Program__c = opp.Program__r.Program_Acronym__c;
                    e.Program_Abbreviation__c = opp.Program__r.Program_Abbreviation__c;
                }
                else {
                    
                    e.Program__c = null;
                    e.Program_Abbreviation__c = null;
                }
            }
        }
        
        return events;
    }
    
    // popualte the program and abbreviation info on a given list of events   
    public static list<Task> populateProgInfo_Tasks(map<Id, Opportunity> oppMap, list<Task> tasks) {
        
        // get all tasks associated with these opps and update their program / program abbreviation
        for (Task t : tasks) {
            
            //Checking for null value and size value
            if (oppMap != null && oppMap.containsKey(t.WhatId) && oppMap.get(t.WhatId) != null) {
                
                // get the asociated opp
                Opportunity opp = oppMap.get(t.WhatId);
                
                if (opp.Program__c != null) {
                    
                    // update the program / abbreviation
                    t.Program__c = opp.Program__r.Program_Acronym__c;
                    t.Program_Abbreviation__c = opp.Program__r.Program_Abbreviation__c;
                }
                else {
                    
                    t.Program__c = null;
                    t.Program_Abbreviation__c = null;
                }
            }
        }
        
        return tasks;
    }  
}