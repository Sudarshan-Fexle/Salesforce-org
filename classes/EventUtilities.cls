//Bhavi - Added a new Method to send an email to distribution list AMQAFeedback@advisory.com and to
//          EA/AE on the account  if  QA Call with Negative Feedback was recently posted - CR-20120405-662
//Bhavi SFContractor - Modified - 05/18/2012 - CR-20120405-662 - Updated as per the Updated work order
//
//Bhavi Sharma - 04/27/2013 - New method added (UpdateProjectByMembershipEvent)- CR-20130408-2822
//Bhavi Sharma - 12/25/2013 - New methods added (UpdateMostRecentNBBVisitOnMembership)- CR-20130111-2120
//Bhavi Sharma - 02/04/2014 - New methods added (UpdateInteractionInformation)- CR-20140124-4353
//Ajit Surana - 07/03/2014 - CR-20140602-5661 - Method modified (sendNegativeFeedBackEmailAlert)
//Colin McGloin - 04/09/2018 - CR-20180327-12130 (Updated populateOppInfoToActivities method to update Program when associated with Subscription Period) 
//Dipesh Gupta - 03/27/2019 - CR-20190111-12831 Commented the method - UpdateInteractionInformation
//Victor Hanson - 10/04/2019 - CR-20190522-13123 - Added reference to syndicated research RT ID
//Modified By - Neha Sharma - CR-20210305-14968 - 12/3/2021 -  Comment the automatic population of program info on a given list of events 
public with sharing class EventUtilities {
    
    //VH added 10/04/2019 - CR-20190522-13123
    public static final Id syndicatedResearchRTID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Syndicated_Research').getRecordTypeId();
    
    // based on an event, return whether or not it meets the criteria of a prewire
    public static Boolean IsPrewire(Event evt) {
        if(evt.Event_Purpose__c == 'Prewire' && !evt.IsChild
            && (evt.Cancelled_Did_Not_Occur__c == false || evt.Cancelled_Did_Not_Occur__c == null)) {
            return true;
        }
        // if the above statement is not true, then it is not a valid prewire event and should not be counted as such
        return false;
    }
    
    //Modified By - Ajit Surana - 07/03/2014 - CR-20140602-5661
    //this method is to send email alert to distribution list AMQAFeedback@advisory.com and to EA/AE on the account (if there is one).
    //If value in  Negative Feedback or  QA Call - Negative Marketing Feedback fields =  "Product" or "Product & Marketing" (evaluated: when previously didn't meet the criteria) 
    public static void sendNegativeFeedBackEmailAlert(Map<Id, Event> mapNewEvents, Map<Id, Event> mapOldEvents, Boolean isInsert) {
        
        //Create list of events for those email will be sent
        Set<Id> eventIds = new Set<Id>();
        
        //Create a set of membership ids. This set will be usedd in fetch the related data from membership object
        Set<Id> membershipIds = new Set<Id>();
        
        //Create a set of Account ids. This set will be usedd in fetch the related data from Account object
        Set<Id> accIds = new Set<Id>();
        
        //Get the memebership keycode
        String membershipKeycode = Membership__c.sObjectType.getDescribe().getKeyPrefix();
        
        //Check if trigger is running for insert case
        if(isInsert == true) {
            
            //loop through the new records
            for(Event event : mapNewEvents.values()) {
                
                //Check for the event Negative Feedback Field value
                /*if((event.Negative_Feedback__c == Constants.NEGATIVE_FEEDBACK_MARKETING || event.Negative_Feedback__c == Constants.NEGATIVE_FEEDBACK_PRODUCT_AND_MARKETING)
                    && event.WhatId != null && (String.valueOf(event.WhatId).startsWith(membershipKeycode))) {
                    
                    eventIds.add(event.Id);
                    membershipIds.add(event.WhatId);
                }*/
            }  
        } else {
            
            //loop through the new records
            for(Event event : mapNewEvents.values()) {
                
                //Check for the event Negative Feedback Field value and add only in set if value is changed from the old value 
               /* if((event.Negative_Feedback__c == Constants.NEGATIVE_FEEDBACK_MARKETING || event.Negative_Feedback__c == Constants.NEGATIVE_FEEDBACK_PRODUCT_AND_MARKETING)
                    && event.Negative_Feedback__c != mapOldEvents.get(event.Id).Negative_Feedback__c && event.WhatId != null && (String.valueOf(event.WhatId).startsWith(membershipKeycode))) {
                    
                    eventIds.add(event.Id); 
                    membershipIds.add(event.WhatId);
                }*/
            }   
        }
        
        //fetch the data from database for selected events
        if(eventIds.size() > 0) {
            
            String emailBody = '';
            
            //fetch membership data from database and store records in a map 
            Map<Id, Membership__c> mapMembership = new Map<Id, Membership__c>([Select Id, Name, Account_Name__c, Account_Name__r.Name, Account_Name__r.EA_AE__r.Email 
                                                                                from Membership__c where ID IN: membershipIds]);
                                                                                
            //Loop through the membership records
            for(Membership__c membership : mapMembership.values()){
                
                //Check if Account field is not null
                if(membership.Account_Name__c != null)
                    
                    //Add Account Id to the set
                    accIds.add(membership.Account_Name__c);
            }
           
            //Set to hold Opportunity record types
            Set<String> setRTypes = new Set<String>();
            setRTypes.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_MAINTENANCE);
            setRTypes.add(Constants.RECORD_TYPE_OPPORTUNITY_PT_CONTRACT_RENEWAL);
            
            //Added By - Ajit Surana - 07/03/2014 - CR-20140602-5661
            //Fetch Opportunity data from database and store records in a map 
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
            
            //Loop through eligible opportunity record
            for(opportunity opp : [SELECT Id, Name, RecordType.Name, OwnerId, Owner.Email, Owner_Manager_Email__c, Membership__c FROM Opportunity
                                    WHERE Active_Renewal__c = TRUE AND RecordType.Name IN: setRTypes
                                     AND AccountId IN: accIds]) {
                
                //Check if Membership field is not null
                if(opp.Membership__c != null)
                    
                    //Add Membership Id to the Map
                    mapOpportunity.put(opp.Membership__c, opp);
                    
            }
            
            System.debug('@@@@@ mapOpportunity 1::::'+mapOpportunity);
            System.debug('@@@@@ mapMembership ' + mapMembership);
            
            for(Event event : [Select Id, WhatId from Event where ID IN: eventIds]){
                
                //check for the email limit
                if((Limits.getLimitEmailInvocations() - Limits.getEmailInvocations()) > 0) {
                    
                    //Send email to ditribution lsit and Accounts' EA
                    List<String> toAddresses = new List<String>();
                    
                    //Code Changes starts from here
                    //Added By - Ajit Surana - 07/03/2014 - CR-20140602-5661
                    //Set to hold unique ToAddresses email addresses
                    Set<String> setToAddress = new Set<String>();
                    
                    
                    
                    if(mapMembership != null) { 
                    
                        //Check if EA_AE__r is on account record
                        if(mapMembership.containsKey(event.WhatId) && mapMembership.get(event.WhatId).Account_Name__r.EA_AE__r.Email != null) {
                            setToAddress.add(mapMembership.get(event.WhatId).Account_Name__r.EA_AE__r.Email); 
                        } 
                    
                        
                        //Check if RM_RI__r is on account record
                       /* Spring clean up - if(mapMembership.containsKey(event.WhatId) && mapMembership.get(event.WhatId).Account_Name__r.RM_RI__r.Email != null) {
                            setToAddress.add(mapMembership.get(event.WhatId).Account_Name__r.RM_RI__r.Email);
                        }*/
                        
                        //Check if map contains any records to process
                        if(mapOpportunity.values().size() > 0) {
                        
                            //Check if Owner email is not null on opportunity record
                            if(mapMembership != null && mapOpportunity != null 
                                && mapMembership.get(event.WhatId) != null 
                                && mapOpportunity.get(event.WhatId) != null
                                && mapOpportunity.get(event.WhatId).Owner.Email != null) {
                                setToAddress.add(mapOpportunity.get(event.WhatId).Owner.Email);
                            }
                        
                            //Check if Owner Manager Email field is not null on opportunity record
                            if(mapMembership.get(event.WhatId) != null && mapOpportunity.get(event.WhatId) != null &&
                                   mapOpportunity.get(event.WhatId).Owner_Manager_Email__c != null) {
                                setToAddress.add(mapOpportunity.get(event.WhatId).Owner_Manager_Email__c);
                            }
                        }
                    }
                    
                    //Loop over the set values
                    for(String email : setToAddress){
                        
                        //Add each unique email to the List - 'toAddresses' 
                        toAddresses.add(email);
                    }
                    
                    //Checking and validating map for values
                    if(mapMembership.values().size()>0){
                
                        //Set email subject 
                        emailBody = 'A QA Call with Negative Feedback was recently posted to ' +  mapMembership.get(event.WhatId).Name + '. If this account has an EA/AE, Delivery Partner - Crimson, Executive Partner - Rev Cycle or RM - RI they have also received this notice.'
                                        + '<BR/><BR/>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + event.Id;
                    }
                    
                    //Code changes made by Ajit Surana are upto here
                    
                    EventUtilities.sendEmail(toAddresses, Constants.EMAIL_SUBJECT_DISTRIBUTION_LIST, emailBody);
                } else {
                    break;
                }
            }
        }
    }
    
    //This method is to send the email to appropriate users
    public static void sendEmail(String[] toAddresses, String subject, String body) {
        
        //Create an email and send to batch owner
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /*// when a new Task is added to an existing opp, copy the opp's initial visit date to the task's opp initial visit date field
    public static void populateOppInitialVisitDate(list<Task> listNewTasks) {
        
        // set of opportunity ids
        set<Id> oppIds = new set<Id>();
        
        // add all opp ids to the set
        for (Task tsk : listNewTasks) {
            
            if (tsk.WhatId != null) {
                
                // if the related object is opp, add to list
                if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Opportunity') oppIds.add(tsk.WhatId);
            }
        }
        
        if (oppIds.size() > 0) {
            
            // get all opportunities
            map<Id, Opportunity> opportunityMap = new map<Id, Opportunity>([SELECT Id, Initial_Visit_Date__c
                                                                            FROM Opportunity
                                                                            WHERE Id IN :oppIds
                                                                            AND Initial_Visit_Date__c != null]);
            
            for (Task tsk : listNewTasks) {
                
                // see if the opportunity is in our map
                if (opportunityMap.containsKey(tsk.WhatId)) {
                    
                    Opportunity opp = opportunityMap.get(tsk.WhatId);
                    
                    tsk.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
                }
                else {
                    
                    tsk.Opp_Initial_Visit_Date__c = null;
                }
            }
        }
    }*/
    
    // when a new event is added to an existing opp, copy the opp's initial visit date to the event's opp initial visit date field
    // Added by Colin McGloin - 04/09/18 - Added functionality to perform Program field update if Event/Task associated with Subscription Period
    public static void populateOppInfoToActivities(list<Event> events, list<Task> tasks) {
        
        // set of opportunity ids
        set<Id> oppIds = new set<Id>();
        //Set of Subscription Period IDs
        set<Id> spIds = new set<Id>();
        //Set of Project IDs
        set<Id> proIds = new set<Id>();
        //Set of Membership IDs
        set<Id> memIds = new set<Id>();
        //Set of Research Study IDs
        set<Id> ssIds = new set<Id>();
        
        // add all opp ids to the set
        if (events != null) {
            
            for (Event evt : events) {
                
                if (evt.WhatId != null) {
                    
                    // if the related object is opp, add to list
                    if (string.valueOf(evt.WhatId.getSObjectType()) == 'Opportunity') oppIds.add(evt.WhatId);
                    // if the related object is Subscription Period, add to Set
                    if (string.valueOf(evt.WhatId.getSObjectType()) == 'Subscription_Period__c') spIds.add(evt.WhatId);
                    // if the related object is Project, add to Set
                    if (string.valueOf(evt.WhatId.getSObjectType()) == 'Project__c') proIds.add(evt.WhatId);
                    // if the related object is Membership, add to Set
                    if (string.valueOf(evt.WhatId.getSObjectType()) == 'Membership__c') memIds.add(evt.WhatId);
                    // if the related object is Research Study, add to Set
                    if (string.valueOf(evt.WhatId.getSObjectType()) == 'Syndicated_Study__c') ssIds.add(evt.WhatId);
                    
                }
            }
        }
        
        if (tasks != null) {
            
            for (Task tsk : tasks) {
                
                if (tsk.WhatId != null) {
                    
                    // if the related object is opp, add to list
                    if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Opportunity') oppIds.add(tsk.WhatId);
                    // if the related object is Subscription Period, add to Set
                    if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Subscription_Period__c') spIds.add(tsk.WhatId);
                    // if the related object is Project, add to Set
                    if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Project__c') proIds.add(tsk.WhatId);
                    // if the related object is Membership, add to Set
                    if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Membership__c') memIds.add(tsk.WhatId);
                    // if the related object is Research Study, add to Set
                    if (string.valueOf(tsk.WhatId.getSObjectType()) == 'Syndicated_Study__c') ssIds.add(tsk.WhatId);
                    
                }
            }
        }
        if (oppIds.size() > 0) {
            
            // get all opportunities
            map<Id, Opportunity> oppMap = new map<Id, Opportunity>([SELECT Id, Initial_Visit_Date__c, Opportunity_Products__c, r_LOB__c, Program__c,
                                                                    Program__r.Program_Abbreviation__c, Program__r.Program_Acronym__c
                                                                    FROM Opportunity
                                                                    WHERE Id IN :oppIds]);
            
            if (events != null && events.size() > 0) {
                
                // popualte the program and abbreviation info on a given list of events (CR-20121127-1793)
                OpportunityTriggerUtilities.populateProgInfo_Events(oppMap, events);
                
                // update the opp initial visit date on these events
                updateEventInitVisit(events, oppMap);
            }
            
            if (tasks != null && tasks.size() > 0) {
                
                // popualte the program and abbreviation info on a given list of events (CR-20121127-1793)
                OpportunityTriggerUtilities.populateProgInfo_Tasks(oppMap, tasks);
                
                // update the opp initial visit date on these events
                updateTaskInitVisit(tasks, oppMap);
            }
            
        }
        
        //Subscription Period Logic from here on
        if (spIds.size() > 0) {
            
            //Get all Subscription Periods
            map<Id, Subscription_Period__c> spMap = new map<Id, Subscription_Period__c>([SELECT Id, Program_Subscription__c,
                                                                    Program_Subscription__r.Program__r.Program_Acronym__c
                                                                    FROM Subscription_Period__c
                                                                    WHERE Id IN :spIds]);
            
            if (events != null && events.size() > 0) {
                
                //Populate the Program and Program Abbreviation on a given list of Events
                SubscriptionPeriodTriggerHelper.populateProgramInfo_EventsSP(spMap, Events);
                               
            }
            
            if (tasks != null && tasks.size() > 0) {
                
                //Populate the Program and Program Abbreviation on a given list of Tasks
                SubscriptionPeriodTriggerHelper.populateProgramInfo_TasksSP (spMap, Tasks);
            }
            
        }
        
        //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Starts here
        //Project Logic from here on
        if (proIds.size() > 0) {
            
            //Get all Project
            map<Id, Project__c> proMap = new map<Id, Project__c>([SELECT Id, Product__r.Program_Acronym__c
                                                                    FROM Project__c
                                                                    WHERE Id IN :proIds]);
            
            if (events != null && events.size() > 0) {

                //Populate the Program on a given list of Events
                ProjectTriggerHelper.populateProgramInfo_Events(proMap, Events);
            }            
        }
        
        //Membership Logic from here on
        if (memIds.size() > 0) {
            
            //Get all Membership
            map<Id, Membership__c> memMap = new map<Id, Membership__c>([SELECT Id, Program__r.Program_Acronym__c
                                                                        FROM Membership__c
                                                                        WHERE Id IN :memIds]);
            
            if (events != null && events.size() > 0) {
                
                //Populate the Program on a given list of Events
                MembershipTriggerHelper.populateProgramInfo_Events(memMap, Events);
                               
            }            
        }
        
        //Modified By - Neha Sharma - CR-20210305-14968 - 12/3/2021 -  Comment out the automatic population of program info on a given list of events 
        //Research Study Logic from here on
       /* if (ssIds.size() > 0) {
            
            //Get all Research Study
            map<Id, Syndicated_Study__c> ssMap = new map<Id, Syndicated_Study__c>([SELECT Id, Primary_Program__r.Program_Acronym__c
                                                                                    FROM Syndicated_Study__c
                                                                                    WHERE Id IN :ssIds]);
            
            if (events != null && events.size() > 0) {
                //Populate the Program on a given list of Events
                SyndicatedStudyTriggerHelper.populateProgramInfo_Events(ssMap, Events);
                               
            }
        }*/
        //Added By Mahendra Swarnkar - 06/12/2019 - CR-CR-20190522-13122 - Ends here
    }
    
    public static void updateEventInitVisit(list<Event> events, map<Id, Opportunity> oppMap) {
        
        for (Event evt : events) {
            
            // see if the opportunity is in our map
            if (oppMap.containsKey(evt.WhatId)) {
                
                Opportunity opp = oppMap.get(evt.WhatId);
                
                evt.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
            }
            else {
                
                evt.Opp_Initial_Visit_Date__c = null;
            }
        }
    }
    
    public static void updateTaskInitVisit(list<Task> tasks, map<Id, Opportunity> oppMap) {
        
        for (Task tsk : tasks) {
            
            // see if the opportunity is in our map
            if (oppMap.containsKey(tsk.WhatId)) {
                
                Opportunity opp = oppMap.get(tsk.WhatId);
                
                tsk.Opp_Initial_Visit_Date__c = opp.Initial_Visit_Date__c;
            }
            else {
                
                tsk.Opp_Initial_Visit_Date__c = null;
            }
        }
    }
    
    //This method is to set Project data according to Event's membership information Bhavi Sharma - 04/27/2013 - CR-20130408-2822
    public static void UpdateProjectByMembershipEvent(List<Event> listNewEvents , Map<Id, Event> mapOldEvents){
        
        //Set of Memberships associated with Project
        Set<Id> setMembershipIds = new Set<Id>();
        
        //Loop through the Trigger.new
        for(Event event : listNewEvents){
            
            //Check WhatId is not null
            if(event.WhatId != null && (mapOldEvents == null || (mapOldEvents.containsKey(event.Id) && event.WhatId != mapOldEvents.get(event.Id).WhatId) 
                    || event.StartDateTime != mapOldEvents.get(event.Id).StartDateTime || event.Would_Buy_Again__c != mapOldEvents.get(event.Id).Would_Buy_Again__c)) {
                
                //Parent on event
                Id memberId = event.WhatId;
                
                //Object type of parent on event
                Schema.SObjectType objectType = memberId.getSobjectType();
                
                //Check for Membership__c
                if(objectType == Schema.Membership__c.SObjectType){
                    
                    //add id in setMembershipIds
                    setMembershipIds.add(memberId);
                }
            }
            
            if(mapOldEvents != null && mapOldEvents.get(event.Id).WhatId != event.WhatId && mapOldEvents.get(event.Id).WhatId != null){
                
                //Parent on event
                Id memberId = mapOldEvents.get(event.Id).WhatId;
                
                //Object type of parent on event
                Schema.SObjectType objectType = memberId.getSobjectType();
                
                //Check for Membership__c
                if(objectType == Schema.Membership__c.SObjectType){
                    
                    //add id in setMembershipIds  
                    setMembershipIds.add(memberId);
                }
            }
        }
        
        //Chekc if there is data to process
        if(setMembershipIds.size() > 0) {
            
            //Project which have membership
            //Commented By Abhinav Sharma - 17/06/2020 - CR-20200318-13865 - Project field deletions - references
            List<Project__c> projects = [SELECT Id/*, PT_QA_Call_Event_DT__c, PT_QA_Call_Recommended_Score__c*/ FROM Project__c 
                                        WHERE Primary_Paid_Membership__c != null 
                                            AND Primary_Paid_Membership__c IN: setMembershipIds];
            
            //Check for update
            if(projects.size() > 0)
                update projects;
        }
    }
    
    /**
     *  @description    :   This method is to update the Most_Recent_NBB_Visit__c on membership record related to event
     *
     *  @args           :   List of events
     *
     *  @return         :   void
     *
     **/
    public static void UpdateMostRecentNBBVisitOnMembership(List<Event> events, Map<Id, Event> mapOldEvents) {
        
        //Set to hold the opportunities ids which need to be queried
        Set<Id> oppIds = new Set<Id>();
        
        //Record Type Ids
        Set<String> recordTypes = new Set<String>();
        //recordTypes.add('PT Marketing');
        recordTypes.add('Sales');
        
        //Query record types from database
        Map<Id, RecordType> mapRecordTypes = new Map<Id, RecordType>([Select Id from RecordType where Name IN: recordTypes AND SObjectType = 'Event' AND IsActive = true]);
        
        //Insert scenario
        if(events != null || mapOldEvents == null) {
            for(Event event : events) {
                
                //check if what id is related to an opportunity
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Opportunity.getSObjectType()
                    && event.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT 
                    && mapRecordTypes.containsKey(event.RecordTypeId)
                    && event.Cancelled_Did_Not_Occur__c == false
                    && event.Count__c == 1) {
                    
                    //Add in Set
                    oppIds.add(event.WhatId);   
                }
            }
        }
        
        //Update Scenario
        if(events != null && mapOldEvents != null) {
            
            //Loop through the events and check if any of them is associated with Opportunity
            for(Event event : events) {
                
                //Old event instance
                Event oldEvent = mapOldEvents.get(event.Id);
                
                //check if what id is related to an opportunity
                if(event.WhatId != oldEvent.WhatId
                    || event.Event_Type__c != oldEvent.Event_Type__c
                    || event.RecordTypeId != oldEvent.RecordTypeId
                    || event.Cancelled_Did_Not_Occur__c != oldEvent.Cancelled_Did_Not_Occur__c
                    || event.Count__c != oldEvent.Count__c) {
                    
                    //check if what id is related to an opportunity
                    if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Opportunity.getSObjectType()
                        && event.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT 
                        && mapRecordTypes.containsKey(event.RecordTypeId)
                        && event.Cancelled_Did_Not_Occur__c == false
                        && event.Count__c == 1) {
                        
                        //Add in Set
                        oppIds.add(event.WhatId);   
                    }
                    
                    //Old opportunities
                    if(oldEvent.WhatId != null && oldEvent.WhatId.getSObjectType() == Schema.Opportunity.getSObjectType()
                        && oldEvent.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT 
                        && mapRecordTypes.containsKey(oldEvent.RecordTypeId)
                        && oldEvent.Cancelled_Did_Not_Occur__c == false
                        && oldEvent.Count__c == 1) {
                        
                        //Add in Set
                        oppIds.add(event.WhatId);   
                    }
                }
            }
        }
        
        //Delete scenario
        if(events == null && mapOldEvents != null) {
        
            //Loop throgh the records
            for(Event event : mapOldEvents.values()) {
                
                //check if what id is related to an opportunity
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Opportunity.getSObjectType()
                    && event.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT 
                    && mapRecordTypes.containsKey(event.RecordTypeId)
                    && event.Cancelled_Did_Not_Occur__c == false
                    && event.Count__c == 1) {
                    
                    //Add in Set
                    oppIds.add(event.WhatId);   
                }
            }
        }
        
        //call method to update membership data
        if(oppIds.size() > 0)
            EventUtilities.UpdateMostRecentNBBVisitOnMembership(oppIds);
    }
    
    /**
     *  @description    :   This method is to update the Most_Recent_NBB_Visit__c on membership record related to event
     *
     *  @args           :   Set of opportunities Ids
     *
     *  @return         :   void
     *
     **/
    public static void UpdateMostRecentNBBVisitOnMembership(Set<Id> opportunitiesIds) {
        
        //Check if opportunities to be queried
        if(opportunitiesIds.size() > 0) {
            
            //Set to hold the institution ids
            Set<Id> accountIds = new Set<Id>();
            
            //Set to hold the program Ids
            Set<Id> programIds = new Set<Id>();
            
            //Map to hold the unique combination of AccountId - Program Id as Key and Value as Maximum date
            Map<String, Date> mapAccountProgWithMaxNBBVisitDate = new Map<String, Date>();
            
            //Fetch all the opportunities which do not have Account and Program Null
            for(Opportunity opportunity : [Select AccountId, Program__c from Opportunity where Id IN: opportunitiesIds 
                                                                                                AND AccountId != null AND Program__c != null]) {
            
                //Populate collection
                accountIds.add(opportunity.AccountId);
                programIds.add(opportunity.Program__c);
                
                //Unique Key
                String uniqueKey = opportunity.AccountId + '-' + opportunity.Program__c;
                mapAccountProgWithMaxNBBVisitDate.put(uniqueKey, null); 
            }
            
            //Now fetch all the Opportunities again related to these accounts and Program
            Map<Id, String> mapAllOppsIdsWithUK = new Map<Id, String>();
            
            //Size check Modified by - Abhinav Sharma - 6/18/2018 - CR-20180608-12274
            if(accountIds.size() > 0 && programIds.size() > 0)
            
              //Get opportunities
              for(Opportunity opportunity : [Select Id, AccountId, Program__c from Opportunity where AccountId != null AND Program__c != null 
                                                                                                      AND AccountId IN: accountIds AND Program__c IN: programIds]) {
                  
                  //Unique Key
                  String uniqueKey = opportunity.AccountId + '-' + opportunity.Program__c;
                  
                  //Check if this unique key was in original map
                  if(mapAccountProgWithMaxNBBVisitDate.containsKey(uniqueKey)) {
                      
                      //Add in map
                      mapAllOppsIdsWithUK.put(opportunity.Id, uniqueKey);
                  }
              }
            
            //now fetch all the events related to allOppsIds and find the Max date among them
            if(mapAllOppsIdsWithUK.size() > 0) {
                
                //Record Type Ids
                Set<String> recordTypes = new Set<String>();
                //recordTypes.add('PT Marketing');
                recordTypes.add('Sales');
                
                //Query record types from database
                List<RecordType> lstRecordTypes = [Select Id from RecordType where Name IN: recordTypes AND SObjectType = 'Event' AND IsActive = true];
        
                //SOQL query to get the Maximum ActivityDate among the activities
                //Get data ordered by ActivityDate in DESC order, so the first one will be the maximum date 
                for(Event event : [Select WhatId, ActivityDate from Event where WhatId != null 
                                                                                AND Event_Type__c != null
                                                                                AND WhatId IN: mapAllOppsIdsWithUK.keySet() 
                                                                                AND Event_Type__c =: Constants.EVENT_TYPE_IN_PERSON_VISIT 
                                                                                AND RecordTypeId IN: lstRecordTypes
                                                                                AND Cancelled_Did_Not_Occur__c = false
                                                                                AND Count__c = 1 ORDER BY ActivityDate DESC ALL ROWS]) {
                    
                    //Get unique key from mapAllOppsIdsWithUK map
                    String uniqueKey = mapAllOppsIdsWithUK.get(event.WhatId);
                    
                    System.debug('uniqueKey, event.ActivityDate:::::' + event.ActivityDate);        
                    
                    //Check if Activity Date is not set yet in the mapAccountProgWithMaxNBBVisitDate
                    if(mapAccountProgWithMaxNBBVisitDate.containsKey(uniqueKey) && mapAccountProgWithMaxNBBVisitDate.get(uniqueKey) == null) {
                        
                        //Set Max data in map
                        mapAccountProgWithMaxNBBVisitDate.put(uniqueKey, event.ActivityDate);   
                    }
                }
                
                //Now get the Membership records associated with these Accounts and Programs and set the Most_Recent_NBB_Visit__c on these
                if(mapAccountProgWithMaxNBBVisitDate.size() > 0) {
                    
                    //List of memberships to be updated
                    List<Membership__c> memberships = new List<Membership__c>();
                    
                    if(accountIds.size() > 0 && programIds.size() > 0) {
                    
                      //Get all the related membership data
                      for(Membership__c membership : [Select Id, Account_Name__c, Program__c, Most_Recent_NBB_Visit__c from Membership__c where Account_Name__c != null 
                                                                                                                      AND Program__c != null
                                                                                                                      AND Account_Name__c IN: accountIds
                                                                                                                      AND Program__c IN: programIds]) {
                          
                          //Unique Key
                          String uniqueKey = membership.Account_Name__c + '-' + membership.Program__c;
                          
                          //get activity date from mapAccountProgWithMaxNBBVisitDate
                          if(mapAccountProgWithMaxNBBVisitDate.containsKey(uniqueKey)) {
                              
                              //Activity date
                              Date activityDate = mapAccountProgWithMaxNBBVisitDate.get(uniqueKey);
                              
                              //Check  if membership NBB Visit date != activityDate, only then update the record
                              if(membership.Most_Recent_NBB_Visit__c != activityDate) {
                                  
                                  //Update the date and add membership record in the list toi be updated
                                  membership.Most_Recent_NBB_Visit__c = activityDate;
                                  memberships.add(membership);
                              }
                          }
                      }
                    } 
                    
                    //Update memberships
                    if(memberships.size() > 0) {
                        
                        //Turn off all the trigger
                        Util.BypassAllTriggers = true;
                        
                        //update memberships
                        update memberships;
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is to update the Interaction infomration on Institution Role
     *
     *  @args           :   List of new events records, Map of old events 
     *
     *  @return         :   void
     *
     **/
   /* public static void UpdateInteractionInformation(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Create a set to hold teh contact Ids
        Set<Id> contactIds = new Set<Id>();
        
        //Check if Interaction information need to be updated
        //Insert Scenerio
        if(newEvents != null && mapOldEvents == null) {
            
            //Loop through the new events
            for(Event event : newEvents) {
                
                //Check for the Contact Id
                if(event.WhoId != null && (event.WhoId).getSobjectType() == Schema.Contact.SObjectType
                    && event.WhatId != null && (event.WhatId).getSobjectType() == Schema.Opportunity.SObjectType
                    && event.ActivityDate != null) {
                    
                    //Add new contact Id
                    contactIds.add(event.WhoId);
                }
            }
        } else if(newEvents != null && mapOldEvents != null) {
            //Update Scenerio   
            //Loop through the new events
            for(Event event : newEvents) {
                
                //Check for the Contact Id
                //if WhoId, WhatId or EventType changed
                if(event.WhoId != null && (event.WhoId).getSobjectType() == Schema.Contact.SObjectType
                    && event.WhatId != null && (event.WhatId).getSobjectType() == Schema.Opportunity.SObjectType
                    && (event.WhoId != mapOldEvents.get(event.Id).WhoId 
                        || event.WhatId != mapOldEvents.get(event.Id).WhatId 
                        || event.Event_Type__c != mapOldEvents.get(event.Id).Event_Type__c 
                        || event.RecordTypeId != mapOldEvents.get(event.Id).RecordTypeId
                        || event.ActivityDate != mapOldEvents.get(event.Id).ActivityDate
                        )
                ) {

                    //Add Old contact Id 
                    if(event.WhoId != mapOldEvents.get(event.Id).WhoId && mapOldEvents.get(event.Id).WhoId != null)
                        contactIds.add(mapOldEvents.get(event.Id).WhoId);
                    
                    //Add new contact Id
                    contactIds.add(event.WhoId);
                }
            }
        } else if(newEvents == null && mapOldEvents != null) {
            //Delete Scenerio
            //Loop through the new events
            for(Event event : mapOldEvents.values()) {
                
                //Check for the Contact Id
                if(event.WhoId != null && (event.WhoId).getSobjectType() == Schema.Contact.SObjectType
                    && event.WhatId != null && (event.WhatId).getSobjectType() == Schema.Account.SObjectType
                    && event.ActivityDate != null) {
                    
                    //Add new contact Id
                    contactIds.add(event.WhoId);    
                }
            }
        }
        
        //Chekc if Institution Roles need to be updated
        if(contactIds.size() > 0)
             InstitutionRoleTriggerHelper.UpdateInteractionInformationByContactIds(null, contactIds, true);
    }*/
}