/**
 *  Purpose         :   Helper class for teh Trigger Event
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   01/19/2015
 *
 *  Revision Logs   :   V_1.0 - Created  (CR-20141119-8126)
 *                      V_1.1 - Modified By - Mahendra Swarnkar - 05/16/2015 - CR-20150401-8835 -Added new method (updateNextActivityDate)
 *                      V_1.2 - Modified By - Abhinav Sharma - 08/26/2015 - CR-20140613-5790 - Added new methods (populatePAsAndActivityFieldsOnOpportunity, populatePAsAndActivityFields)
 *                      V_1.3 - Modified By - Abhinav Sharma - 09/04/2015 - CR-20150817-9161 - Added new method (updateEventHistoryTrackingFields)
 *                      V_1.4 - Modified By - Abhinav Sharma - 11/24/2015 - CR-20150929-9281 - Modified existing method (updateEventHistoryTrackingFields)
 *                      v_1.5 - Modified By - Mahendra Swarnakar - 8/26/2016 - CR-20160606-9903 - Modified the Method populateMostRecentQACall.
 *                      V_1.6 - Modified By - Abhinav Sharma - 12/10/2016 - CR-20160111-9502 - Added new method (syncUpPSSrequestsFields)
 *                      V_1.7 - Modified By - Subhash Garhwal - - 02/17/2017 - CR-20170403-10807 -- primaryProposalRequiredForEvent(work order DS157)
 *                      V_1.9 - Modified By - Rajeev Jain - 07/05/2017(In order of migration tasks of - Releases after Q2CDev3 sandbox refresh date[04/07/2017] in Q2CDev3 sandbox from Test sandbox in order to sync with Q2c Beta Release and Revenue Management
 *                      V_1.7 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. 
 *                      V_1.8 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Added the methods (doIcsAttachment and  handleGoogleEvent). TO sent and outlook invite on the creation of Event record on the PSS request.
 *                      V_1.9 - Modified By - Rajeev Jain - 07/05/2017 - upto here
 *                      V_2.0 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue (BYPASS_EVENT_TRIGGER_FOR_MERGE)  
 *                      V_2.1 - Modified By - Abhinav Sharma - 03/28/2018 - CR-20170620-11016 - Added a New method - syncWithPssRequest
 *                      V_2.2 - Modified By - Subhash Garhwal - 04/25/2018 - CR-20180205-11952 - updated method 'primaryProposalRequiredForEvent' to add the logic to through error on event creation if there is no Proposal Line on Proposal under the opportunity
 *                      V_2.3 - Modified By - 06/26/2018 - Abhinav sharma - CR-20180625-12300 - Modified syncWithPssRequest To save the Query.
 *                      V_2.4 - Modified By - Abhinav Sharma - 5/24/2018 - CR-20180430-12193 - Updated method 'handleGoogleEvent'
 *                      V_2.5 - Modified By - Rajeev Jain - 07/19/2019 - L2 Release - July 2018 - Deployment.
 *                      V_2.6 - Modified By - Rajeev Jain - 08/23/2018 - CR-20180821-12512 - deployment 
 *                      V_2.7 - Modified By - Abhinav sharma - CR-20180830-12533 - used SME Request or wide email address to send SME invites. 
 *                      V_2.8 - Modified By - Rajeev Jain - Deployment - CR-20180830-12533.
 *                      V_2.9 - Modified By - Rajeev Jain - CR-20181008-12652 - 10/12/2018 - Update the Field population of 
                        								   Why is SME Required Field on the Event based on Reason Required.  Method - syncWithPssRequest      
 *                      V_3.0 - Modified By - Abhinav Sharma - CR-20181025-12708 - 10/30/2018 - syncWithPssRequest
 *                      V_3.1 - Modified By - Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863 - Added New Method - populateRelatedTypeField
 *                      V_3.2 - Modified By - Victor Hanson - 04/24/2019 - CR-20190204-12863 - added populateAllInstRoles
 *                      V_3.3 - Modified By - Victor Hanson - 08/07/2019 - CR-20190204-12863 - added populateNoContact & getNoContactRecords
 *                      V_3.4 - Modified By - Dipesh Gupta - CR-20190429-13049 - 08/12/2019 - populateFirstCreditedEventDateOnOpportunity
 *                      V_3.5 - Modified By - Dipesh Gupta - CR-20191010-13404 - 10/16/2019
 *                      V_3.6 - Modified By - Dipesh Gupta - 10/16/2019 - CR-20191014-13416 - added check to alter the logic for Graduate Education RT
 *                      V_3.7 - Modified By - Dipesh Gupta - 12/11/2019 - CR-20191104-13493 - Added new Event Purpose check to allow Relationship visit.
 *                      V_3.8 - Modified By - Dipesh Gupta - 01/22/2020 - CR-20200102-13583 - Added new Method 'populateProjectFields'
 *			V_3.9 - Modified By - Dipesh Gupta - 01/24/2020 - CR-20200110-13610
 *			V_4.0 - Modified By - Abhinav Sharma - CR-20200420-13963 - Add New Method (populateOpportunityFields)
 *         		V_4.1 - Modified By - Neha Sharma - CR-20210202-14862 - - 4/12/2021 - Add new method (populateCountOnOpportunityFields)
 *          		V_4.2 - Modified By - By Neha Sharma - 04/17/2021 - CR-20201110-14683 - modify the existing  Method populatePAsAndActivityFields
 *			V_4.3 - Modified By - Pankaj - 04/16/2021 - CR-20210407-15063 - added sendEmailNotification
 *			V_4.4 - Modified By - Neha Sharma - 04/16/2021 - CR-20201021-14627 - Add New Method createMembershipMtMRecords,deleteMembershipMtMRecords
 *			V_4.5 - Modified By - Nikita Kumari - 02/08/2022 - CR-20220119-15726 - Update related MQL Credits
**/
public without sharing class EventTriggerHelper {
  
    //Flag to contol the trigger execution 
    public static Boolean BYPASS_EVENT_TRIGGER_FOR_MERGE = false;
    
    //Control  the execution of trigger
    public static Boolean EXECUTE_TRIGGER = true;
    
    //V_1.9 - Merged By - Rajeev Jain - 07/05/2017
    //V_1.8 - Added By - Mahendra Swarnakar - 06/08/2017 - CR-20170302-10730
    //Boolean variable to bypass the second Execution.
    public static Boolean isAlreadyExecuted = False;
    //V_1.8 - Added By - Mahendra Swarnakar - 06/08/2017 - CR-20170302-10730 - Ends here
    //V_1.9 - Merged By - Rajeev Jain - 07/05/2017 - upto here
    
     /**
     * 
     *  @description    :   Method to populate history tracking type fields on Activity of Event Type = 'In Person Visit'
     *
    **/
    public static void populateContactLookup(List<Event> newEvents) {
        for (Event e : newEvents) {
            if (e.WhoId != null && string.valueOf(e.WhoId.getsobjecttype()) == 'Contact') {
                //Commented by Dipesh Gupta - 10/16/2019 - CR-20191010-13404
                //e.Contact__c = e.WhoId;
            }
            else {
                //e.Contact__c = null;
            }
        }
    }
    
    /**
    * 
    *  @description    :   Method to populate history tracking type fields on Activity of Event Type = 'In Person Visit'
    *
    **/
    public static void populateContactLookup(List<Task> newTasks) {
        for (Task t : newTasks) {
            if (t.WhoId != null && string.valueOf(t.WhoId.getsobjecttype()) == 'Contact') {
                //Commented by Dipesh Gupta - 10/16/2019 - CR-20191010-13404
                //t.Contact__c = t.WhoId;
            }
            else {
                //t.Contact__c = null;
            }
        }
    }
    
   /**
    * 
    *  @description    :   Whenever an event is created/updated and its relates to a contact (Event.WhoId) and its status is
    *                      inactive i.e Contact Status is equals one of the below statuses, then show the error message to user
    *                      "You can not create event for inactive contacts."
    * 
    *  @args           :   List of new events, Old evenets map
    *
    *  @return         :   void
    * 
    *  @Version        :   V1.0 - Dipesh Gupta - 01/24/2020 - CR-20200110-13610.
    *
    **/
    public static void validateContactStatus(List<Event> newEvents, Map<Id, Event> oldMapEvents)
    {        
        // Fill Set of ContactIdsRelatedToEvent for Insert and Update Case
        Set<Id> setWhoIdsReleateToEvent = new Set<Id>();
        
        for(Event evn: newEvents)
        {
            if(evn.WhoId != null && evn.WhoId.getSObjectType() == Schema.Contact.sObjectType)
            {
                if(oldMapEvents == null || oldMapEvents!= null )
                {
                    setWhoIdsReleateToEvent.add(evn.WhoId);
                }
            }
        }
        
        // List to hold contact Ids where Contact Status is not equals to active
        List<Contact> conList = new List<Contact>();
        
        if(setWhoIdsReleateToEvent.size() > 0)
        {
            conList = [Select Id, Contact_Status__c FROM Contact WHERE Id IN: setWhoIdsReleateToEvent AND Contact_Status__c != 'Active'];
        }
        if(conList.size() > 0)
        {
            for (Contact conData: conList)
            {
                 for(Event evnData: newEvents)
                 {
                     //event is created/updated and its relates to a contact and its status is not active
                     //then show the error message to user "You can not create event for inactive contacts."
                     if(conData.Id == evnData.WhoID)
                         evnData.addError('You can not create or update event for inactive contacts.');
                 }
            }
        }
    }
    
    //Added By - Abhinav Sharma - 09/04/2015 - CR-20150817-9161
    //Modified By - Abhinav Sharma - 11/24/2015 - CR-20150929-9281
    /**
     *  @description    :   Method to populate history tracking type fields on Activity of Event Type = 'In Person Visit'
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
    **/
    public static void updateEventHistoryTrackingFields(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Map of events
        Map<Id, Event> mapEventsOnStartDateTimeGotModified = new Map<Id, Event>();
        Map<Id, Event> mapEventsOnCancelledDidNotOccurGotModified = new Map<Id, Event>();
        Map<Id, Event> mapEventsWithEventTypeChange = new Map<Id, Event>();
        
        //Loop through event records
        for(Event ev : newEvents) {
            
            //Insert use case
            if(mapOldEvents == null) {

                if(ev.Cancelled_Did_Not_Occur__c != null && ev.Cancelled_Did_Not_Occur__c)
                    mapEventsOnCancelledDidNotOccurGotModified.put(ev.Id, ev);
            }
            
            //Update use case
            if(mapOldEvents != null) {

                //Populating map with appropriate values if Start Date got modified on event record
                if(ev.StartDateTime != mapOldEvents.get(ev.Id).StartDateTime)
                    mapEventsOnStartDateTimeGotModified.put(ev.Id, ev);
                
                //Populating map with appropriate values if Cancelled/Did Not Occur got modified on event record
                if(ev.Cancelled_Did_Not_Occur__c != mapOldEvents.get(ev.Id).Cancelled_Did_Not_Occur__c)
                    mapEventsOnCancelledDidNotOccurGotModified.put(ev.Id, ev);
                
                //Checking for the "Event Type" field change and populating map accordingly
                if(ev.Event_Type__c != mapOldEvents.get(ev.Id).Event_Type__c)
                    mapEventsWithEventTypeChange.put(ev.Id, ev);
            }
        }
        
        //Loop through event records
        for(Event eve : newEvents) {
            
            //Checking for event type
            if(eve.Event_Type__c != null && eve.Event_Type__c.toLowerCase().trim() == System.Label.Event_Type_IN_Person_Visit) {
            
                //Checking for values in map and accordingly populating the field's with value
                if(mapEventsOnStartDateTimeGotModified.containsKey(eve.Id)
                    && mapEventsOnStartDateTimeGotModified.get(eve.Id) != null) {
                    eve.Start_Date_Time_Last_Modified_Date__c = System.now();    
                
                    /*Spring clean up - if(eve.of_Times_Start_Date_Time_Updated__c == null)
                        eve.of_Times_Start_Date_Time_Updated__c = 1;
                    else
                        eve.of_Times_Start_Date_Time_Updated__c = eve.of_Times_Start_Date_Time_Updated__c + 1;
                    */
                }
                
                //Checking for values in map and accordingly populating the field's with value
                if(mapEventsOnCancelledDidNotOccurGotModified.containsKey(eve.Id)
                    && mapEventsOnCancelledDidNotOccurGotModified.get(eve.Id) != null) {
                    eve.Cancelled_Did_Not_Occur_Last_Modify_Date__c = System.now(); 
                }
                
                //Added by - Abhinav Sharma - CR-20150929-9281
                //Start from here
                //On an event record insert. if it having "Event Type" field 
                //value equals to "In Person Visit" then only "Initial Start Date/Time" field will populate 
                //to have "Start Date/Time" field value.
                if(mapOldEvents == null)
                    eve.Initial_Start_Date_Time__c = eve.StartDateTime;
                
                //Checking for the event type field change
                if(mapEventsWithEventTypeChange.containsKey(eve.Id)
                    && mapEventsWithEventTypeChange.get(eve.Id) != null)
                    eve.Initial_Start_Date_Time__c = eve.StartDateTime;
                
                //Upto Here
                
            } else {
                eve.Start_Date_Time_Last_Modified_Date__c = null;    
                //eve.of_Times_Start_Date_Time_Updated__c = null;
                eve.Cancelled_Did_Not_Occur_Last_Modify_Date__c = null;
            }        
        }
    }

    /**
     *  @description    :   Method to populate Next Activity Date field value on Opportunity record 
     *                      on the basis of associated events corresponding field value.
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *   
     *   @Version       :  V1.1 - Modified By Abhinav Sharma - CR-20180625-12300 - Saving query to avoid 101 Query Error. 
     *
     **/
    public static void updateNextActivityDate(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
    
        //Map of opportunity
        Map<Id, Opportunity> mapOpportunites = new Map<Id, Opportunity>();
        
        //Set to hold the eligible Record type.
        Set<String> setEligibleRecordTypeEvents = new Set<String>{'BI_Marketing', 'Core_Marketing'};
        
        //Map to hold the Record types of Event with the Id (Only BI_Marketing', 'Core_Marketing)
        Map<Id, String> mapEventRecordTypes = new Map<Id, String>();
        
        //Query to the Custom setting and check for the 2 Record types of Event Object- 'BI_Marketing', 'Core_Marketing'
        /*list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();
        
        for (Recordtype_Setting__c rts : rtslist) {
            if (rts.SObjectType__c == 'Event') {
               
                //Check for the 4 Record type of Event Only.
                if(setEligibleRecordTypeEvents.contains(rts.DeveloperName__c))
                  mapEventRecordTypes.put(rts.SFID__c, rts.DeveloperName__c);
            } 
        }*/
        mapEventRecordTypes.put(Util.sobjectRecordTypeId('Event').get('BI_Marketing'), 'BI_Marketing');
        mapEventRecordTypes.put(Util.sobjectRecordTypeId('Event').get('Core_Marketing'), 'Core_Marketing');
        
       /* Commented By Abhinav sharma - 06/26/2018 - CR-20180625-12300 - Save Query.
        * //Map of eligible event record types
        Map<Id, RecordType> mapEventRecordTypes =  new Map<Id, RecordType>([SELECT id , DeveloperName FROM RecordType 
                                                    WHERE DeveloperName IN ('BI_Marketing' , 'Core_Marketing')
                                                    AND IsActive = true 
                                                    AND SobjectType = 'Event']); */
        
        //Insert/update use cases
        if(newEvents != null) {
            
            //Loop through trigger.new event records
            for(Event e : newEvents) {
                
                //Insert use case
                if(mapOldEvents == null) {
                    
                    //Checking and validating for additional filters
                    if(e.WhatId != null 
                        && e.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                        && e.Cancelled_Did_Not_Occur__c == false
                        && e.RecordTypeId != null
                        && mapEventRecordTypes != null
                        && mapEventRecordTypes.get(e.RecordTypeId) != null)
                        mapOpportunites.put(e.WhatId, new Opportunity(Id = e.WhatId, Next_Activity_Date__c = null));       
                }    
                    
                //Update use case
                if(mapOldEvents != null) {
                    
                    //Checking for the field value change on event update
                    if(e.StartDateTime != mapOldEvents.get(e.Id).StartDateTime 
                       || e.WhatId != mapOldEvents.get(e.Id).WhatId
                       || e.Event_Type__c != mapOldEvents.get(e.Id).Event_Type__c
                       || e.RecordTypeId != mapOldEvents.get(e.Id).RecordTypeId
                       || e.Cancelled_Did_Not_Occur__c != mapOldEvents.get(e.Id).Cancelled_Did_Not_Occur__c) {
                       
                        //Checking and validating for additional filters
                        if(e.WhatId != null 
                            && e.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                            && e.RecordTypeId != null
                            && mapEventRecordTypes != null
                            && mapEventRecordTypes.get(e.RecordTypeId) != null )
                            mapOpportunites.put(e.WhatId, new Opportunity(Id = e.WhatId, Next_Activity_Date__c = null));          
                        
                        if(mapOldEvents.get(e.Id).WhatId != null 
                            && mapOldEvents.get(e.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                            && mapOldEvents.get(e.Id).RecordTypeId != null
                            && mapEventRecordTypes != null
                            && mapEventRecordTypes.get(mapOldEvents.get(e.Id).RecordTypeId) != null )
                            mapOpportunites.put(mapOldEvents.get(e.Id).WhatId, new Opportunity(Id = mapOldEvents.get(e.Id).WhatId, Next_Activity_Date__c = null)); 
                           
                    }
                }
            }
        }
        
        //Delete use case
        else {
            
            //Loop through trigger.old event records
            for(Event et : mapOldEvents.values()) {
                
                if(mapOldEvents.get(et.Id).WhatId != null 
                   && et.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                   && et.Cancelled_Did_Not_Occur__c == false
                   && et.RecordTypeId != null
                   && mapEventRecordTypes != null
                   && mapEventRecordTypes.get(et.RecordTypeId) != null)
                   mapOpportunites.put(mapOldEvents.get(et.Id).WhatId, new Opportunity(Id = mapOldEvents.get(et.Id).WhatId, Next_Activity_Date__c = null)); 
            }
        }
        
        //Checking set for size value
        if(mapOpportunites != null && mapOpportunites.size() > 0) {
            
            //Loop through opportunity records
            for(Opportunity opp : [SELECT ID, Next_Activity_Date__c,
                                    (SELECT ID, WhatId, StartDateTime FROM events 
                                     WHERE WhatId != null AND WhatId IN : mapOpportunites.keySet()
                                        AND RecordTypeID != null AND RecordTypeID IN : mapEventRecordTypes.keySet()
                                        AND Cancelled_Did_Not_Occur__c = false
                                        AND StartDateTime != null AND StartDateTime > TODAY
                                        ORDER BY StartDateTime ASC LIMIT 1)
                                  FROM Opportunity WHERE ID IN : mapOpportunites.keySet()]) {
                
                //Checking for associated events list size value
                if(opp.events != null && opp.events.size() > 0) {
                     if(mapOpportunites.containsKey(opp.Id) && mapOpportunites.get(opp.Id) != null 
                       && opp.events[0].StartDateTime != null)
                        mapOpportunites.get(opp.Id).Next_Activity_Date__c = Date.valueof(opp.events[0].StartDateTime);       
                }
            }
            
            //Updating opportunity records
            util.BypassAllTriggers = true;
            update mapOpportunites.values();
            util.BypassAllTriggers = false;
        }
    }
   
    /**
     *  @description    :   This method is to check if event is being created, updated or deleted, 
     *                      update the most recent membership data on Opporutnity
     *
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
     **/
    public static void populateMostRecentQACall(List<Event> newEvents, Map<Id, Event> mapOldEvents) {

        //Create a set of membership ids
        Set<Id> membershipIds = new Set<Id>();

        //Insert
        if(newEvents != null && mapOldEvents == null) {

            //Loop through the records
            for(Event event : newEvents) {

                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }
            }
        } else if(newEvents != null && mapOldEvents != null) {

            //Chekc if event was and is realted to membership or any of the event attribute has been changed
            //Loop through the records
            for(Event event : newEvents) {
                
                //Abhinav - 02/08/2019 - CR-20180828-12525 - Added check for Event purpose field 
                //Mahendra - 5/11/2016 - CR-20160219-9619 - Modified to add a check when Event Grades are changed
                //Mahendra - 8/26/2016 - CR-20160606-9903 - Modified to add a check when Event record type is changed
                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType &&
                        (event.WhatId != mapOldEvents.get(event.Id).WhatId
                            || event.Cancelled_Did_Not_Occur__c !=  mapOldEvents.get(event.Id).Cancelled_Did_Not_Occur__c
                            || event.StartDateTime !=  mapOldEvents.get(event.Id).StartDateTime
                            || event.Event_Type__c !=  mapOldEvents.get(event.Id).Event_Type__c
                            || event.Grade__c !=  mapOldEvents.get(event.Id).Grade__c
                            || event.RecordTypeId !=  mapOldEvents.get(event.Id).RecordTypeId
                            || event.Event_Purpose__c !=  mapOldEvents.get(event.Id).Event_Purpose__c)) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }

                //Chekc if Old was not null and related to membership
                if(mapOldEvents.get(event.Id).WhatId != null
                    && mapOldEvents.get(event.Id).WhatId.getSObjectType() == Schema.Membership__c.SobjectType
                    && event.WhatId != mapOldEvents.get(event.Id).WhatId) {

                    //Add in set to be processed
                    membershipIds.add(mapOldEvents.get(event.Id).WhatId);
                }
            }
        } else if(newEvents == null && mapOldEvents != null) {

            //Loop through the records
            for(Event event : mapOldEvents.values()) {

                //Check if event is related to membership
                if(event.WhatId != null && event.WhatId.getSObjectType() == Schema.Membership__c.SobjectType) {

                    //Add in set to be processed
                    membershipIds.add(event.WhatId);
                }
            }
        }

        //Check for the membership set size and call the method to reset the data
        if(membershipIds.size() > 0) {

            //Call the helper class method
            MembershipTriggerHelper.PopulateMostRecentQACall(membershipIds);
        }
    }
    
    //Added By - Abhinav Sharma- 08/26/2015 - CR-20140613-5790 - New Fields to track PAs
    /**
     *  @description    :   This method is to update the PA's and Activities fields on Opporutnity record,
     *                      if an event is being created, updated or deleted under it.
     *                      
     *  @args           :   List of new events, Old evenets map
     *
     *  @return         :   void
     *
     *  @revision Log  :  
     *
    **/
    public static void populatePAsAndActivityFieldsOnOpportunity(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Map of Opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
                
        //Loop through event records
        for(Event eve : newEvents != null ? newEvents : mapOldEvents.values()) {
            
            //Insert case
            if(mapOldEvents == null && eve.WhatId != null && eve.WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                mapOpportunities.put(eve.WhatId, new Opportunity(ID = eve.WhatId,
                                                                 Initial_PA_Date__c = null,
                                                                 Initial_Activity_Date__c = null,
                                                                 Current_YTD_Initial_Pas__c = null,
                                                                 Prev_YTD_Initial_Pas__c = null,
                                                                 Scheduled_Initial_Pas__c = null,
                                                                 Current_Year_Initial_Pas__c = null,
                                                                 Previous_Year_Initial_Pas__c = null,
                                                                 Current_YTD_Initial_Activities__c = null,
                                                                 Prev_YTD_Initial_Activities__c = null,
                                                                 Scheduled_Initial_Activities__c = null,
                                                                 Current_Year_Initial_Activities__c = null,
                                                                 Previous_Year_Initial_Activities__c = null,
                                                                 Total_Initial_Pas__c = null,
                                                                 Total_Initial_Activities__c = null));

            
            //Update case
            if(mapOldEvents != null 
               && (
                   eve.WhatId != mapOldEvents.get(eve.Id).WhatId
                    || eve.Event_Purpose__c != mapOldEvents.get(eve.Id).Event_Purpose__c
                    || eve.Event_Type__c != mapOldEvents.get(eve.Id).Event_Type__c
                    || eve.Cancelled_Did_Not_Occur__c != mapOldEvents.get(eve.Id).Cancelled_Did_Not_Occur__c
                    || eve.Count__c != mapOldEvents.get(eve.Id).Count__c
                    || eve.ActivityDate != mapOldEvents.get(eve.Id).ActivityDate
                  )
            ) {
                
                //Checking for null value
                if(eve.WhatId != null && eve.WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                    mapOpportunities.put(eve.WhatId, new Opportunity(ID = eve.WhatId,
                                                                     Initial_PA_Date__c = null,
                                                                     Initial_Activity_Date__c = null,
                                                                     Current_YTD_Initial_Pas__c = null,
                                                                     Prev_YTD_Initial_Pas__c = null,
                                                                     Scheduled_Initial_Pas__c = null,
                                                                     Current_Year_Initial_Pas__c = null,
                                                                     Previous_Year_Initial_Pas__c = null,
                                                                     Current_YTD_Initial_Activities__c = null,
                                                                     Prev_YTD_Initial_Activities__c = null,
                                                                     Scheduled_Initial_Activities__c = null,
                                                                     Current_Year_Initial_Activities__c = null,
                                                                     Previous_Year_Initial_Activities__c = null,
                                                                     Total_Initial_Pas__c = null,
                                                                     Total_Initial_Activities__c = null));

                
                //Checking for null value        
                if(mapOldEvents.get(eve.Id).WhatId != null && mapOldEvents.get(eve.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                    mapOpportunities.put(mapOldEvents.get(eve.Id).WhatId, new Opportunity(ID = mapOldEvents.get(eve.Id).WhatId,
                                                                                          Initial_PA_Date__c = null,
                                                                                          Initial_Activity_Date__c = null,
                                                                                          Current_YTD_Initial_Pas__c = null,
                                                                                          Prev_YTD_Initial_Pas__c = null,
                                                                                          Scheduled_Initial_Pas__c = null,
                                                                                          Current_Year_Initial_Pas__c = null,
                                                                                          Previous_Year_Initial_Pas__c = null,
                                                                                          Current_YTD_Initial_Activities__c = null,
                                                                                          Prev_YTD_Initial_Activities__c = null,
                                                                                          Scheduled_Initial_Activities__c = null,
                                                                                          Current_Year_Initial_Activities__c = null,
                                                                                          Previous_Year_Initial_Activities__c = null,
                                                                                          Total_Initial_Pas__c = null,
                                                                                          Total_Initial_Activities__c = null));

            }
            
            //Delete Case
            if(newEvents == null && mapOldEvents != null && mapOldEvents.get(eve.Id).WhatId != null && mapOldEvents.get(eve.Id).WhatId.getSObjectType() == Schema.Opportunity.SobjectType)
                mapOpportunities.put(mapOldEvents.get(eve.Id).WhatId, new Opportunity(ID = mapOldEvents.get(eve.Id).WhatId,
                                                                                        Initial_PA_Date__c = null,
                                                                                        Initial_Activity_Date__c = null,
                                                                                        Current_YTD_Initial_Pas__c = null,
                                                                                        Prev_YTD_Initial_Pas__c = null,
                                                                                        Scheduled_Initial_Pas__c = null,
                                                                                        Current_Year_Initial_Pas__c = null,
                                                                                        Previous_Year_Initial_Pas__c = null,
                                                                                        Current_YTD_Initial_Activities__c = null,
                                                                                        Prev_YTD_Initial_Activities__c = null,
                                                                                        Scheduled_Initial_Activities__c = null,
                                                                                        Current_Year_Initial_Activities__c = null,
                                                                                        Previous_Year_Initial_Activities__c = null,
                                                                                        Total_Initial_Pas__c = null,
                                                                                        Total_Initial_Activities__c = null));

        }

        //Checking set for size value
        if(mapOpportunities.values().size() > 0) {
            
            //Populating opportunity fields values
            mapOpportunities = populatePAsAndActivityFields(mapOpportunities);
            
            //Updating opportunity records
            if(mapOpportunities.values().size() > 0)
                update mapOpportunities.values();
        }
    }
    
    //Added By - Abhinav Sharma- 08/26/2015 - CR-20140613-5790 - New Fields to track PAs
    public static Map<Id, Opportunity> populatePAsAndActivityFields(Map<Id, Opportunity> mapOpps) {
        //Modified By - Neha Sharma - 04/17/2021 - CR-20201110-14683 
        Set<String> setOfEventType = new Set<String>{'Web Visit','Phone Appointment','In Person Visit'};

        //Checking map for null and size value
        if(mapOpps != null && mapOpps.values().size() > 0) {

            //Set to hold the event purpose values - eligible for PA types
            Set<String> setEventPurposeForPAs = new Set<String>();
            setEventPurposeForPAs.add('Initial');
            setEventPurposeForPAs.add('Intro PA');
            //Added by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
            setEventPurposeForPAs.add('Relationship Visit');
        
            //Modified By - Neha Sharma - 04/17/2021 - CR-20201110-14683
            //By Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
            for(Event ev : [SELECT ID, ActivityDate, WhatId, Event_Type__c,Event_Purpose__c FROM Event
                            WHERE WhatId != null AND WhatId IN : mapOpps.keySet()
                                        //AND Event_Type__c = Phone Appointment'
                                        AND Event_Purpose__c IN : setEventPurposeForPAs
                                        AND Cancelled_Did_Not_Occur__c = false
                                        AND Count__c = 1
                                        AND ActivityDate != null AND IsDeleted = false ALL ROWS])
            {
                //Commented by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                /*//Querying PA's events and accordingly populating PA's fields on related opportunity
                for(Event ev : [SELECT ID, ActivityDate, WhatId FROM Event
                                WHERE WhatId != null AND WhatId IN : mapOpps.keySet()
                                    AND Event_Type__c = 'Phone Appointment'
                                    AND Event_Purpose__c IN : setEventPurposeForPAs
                                    AND Cancelled_Did_Not_Occur__c = false
                                    AND Count__c = 1
                                    AND ActivityDate != null AND IsDeleted = false ALL ROWS]) {*/
                
                //New condition added Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                //For Event Type = 'Phone Appointment'
                if(ev.Event_Type__c == 'Phone Appointment'){
                    //Checking if map contains the key in it                        
                    if(mapOpps.containsKey(ev.WhatId) && mapOpps.get(ev.WhatId) != null) {
                        
                        //Initial_PA_Date__c
                        if(mapOpps.get(ev.WhatId).Initial_PA_Date__c == null) {
                            mapOpps.get(ev.WhatId).Initial_PA_Date__c = ev.ActivityDate;
                        } else {
                            if(mapOpps.get(ev.WhatId).Initial_PA_Date__c > ev.ActivityDate) {
                                mapOpps.get(ev.WhatId).Initial_PA_Date__c = ev.ActivityDate;
                            }
                        }        
                        
                        //Count all related PA’s with Activity Date is in current year and less or equal to today.
                        //Current_YTD_Initial_Pas__c
                        if(ev.ActivityDate.Year() == System.today().year()
                           && ev.ActivityDate <= System.today()) {
                               if(mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c == null)
                                   mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c = 1;
                               else
                                   mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c = mapOpps.get(ev.WhatId).Current_YTD_Initial_Pas__c + 1;
                           }
                        
                        //Previous Year same Date value as Today
                        Date previousYearTodaysDate = Date.newinstance((System.today().year()-1), System.today().month(), System.today().day());    
                        
                        //Count all related Initial PAs for which Activity Date is in previous year and less than today’s date minus one year.
                        //Prev_YTD_Initial_Pas__c
                        if(ev.ActivityDate.Year() == (System.today().year() - 1)
                           && ev.ActivityDate < previousYearTodaysDate) {
                               if(mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c == null)
                                   mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c = 1;
                               else
                                   mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c = mapOpps.get(ev.WhatId).Prev_YTD_Initial_Pas__c + 1;    
                           }
                        
                        //Count all related Initial PAs for which Activity Date is greater than today.   
                        //Scheduled_Initial_Pas__c 
                        if(ev.ActivityDate > System.today()) {
                            if(mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c == null)
                                mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c = 1;
                            else
                                mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c = mapOpps.get(ev.WhatId).Scheduled_Initial_Pas__c + 1;    
                        }  
                        
                        //Count all related Initial PAs for which Activity Date is in current year. 
                        //Current_Year_Initial_Pas__c  
                        if(ev.ActivityDate.Year() == System.today().year()) {
                            if(mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c == null)
                                mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c = 1;
                            else
                                mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c = mapOpps.get(ev.WhatId).Current_Year_Initial_Pas__c + 1;  
                        } 
                        
                        //Count all related Initial PAs for which Activity Date is in previous year.
                        //Previous_Year_Initial_Pas__c   
                        if(ev.ActivityDate.Year() == (System.today().year()-1)) {
                            if(mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c == null)
                                mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c = 1;
                            else
                                mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c = mapOpps.get(ev.WhatId).Previous_Year_Initial_Pas__c + 1; 
                        }
                        
                        //Total_Initial_Pas__c    
                        if(mapOpps.get(ev.WhatId).Total_Initial_Pas__c == null)
                            mapOpps.get(ev.WhatId).Total_Initial_Pas__c = 1;
                        else
                            mapOpps.get(ev.WhatId).Total_Initial_Pas__c = mapOpps.get(ev.WhatId).Total_Initial_Pas__c + 1;    
                    }    
                }
                
                
                //Modified By Dipesh Gupta - 12/11/2019 - CR-20191104-13493 - Added new Event Purpose check to allow RelationShip visit.
                //Querying Activity events and accordingly populating Activity type fields on related opportunity
                //Commented by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                /*for(Event e : [SELECT ID, ActivityDate, WhatId FROM Event
                                    WHERE WhatId != null AND WhatId IN : mapOpps.keySet()
                                    AND Event_Type__c != 'Additional Contact Meeting'
                                    AND (Event_Purpose__c IN : setEventPurposeForPAs OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT  )
                                    AND Cancelled_Did_Not_Occur__c = false
                                    AND Count__c = 1
                                    AND ActivityDate != null AND IsDeleted = false ALL ROWS]) {*/
                
                //New Condition added by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
                //For Event Type = 'Additional Contact Meeting'
                if(ev.Event_Type__c != 'Additional Contact Meeting'){
                    
                    //Checking if map contains the key in it                        
                    if(mapOpps.containsKey(ev.WhatId) && mapOpps.get(ev.WhatId) != null) {
                           
                           //Minimum Activity Date of the activities on the opportunity
                           //Initial_Activity_Date__c
                           if(mapOpps.get(ev.WhatId).Initial_Activity_Date__c == null) {
                               mapOpps.get(ev.WhatId).Initial_Activity_Date__c = ev.ActivityDate;
                           } else {
                               if(mapOpps.get(ev.WhatId).Initial_Activity_Date__c > ev.ActivityDate) {
                                   mapOpps.get(ev.WhatId).Initial_Activity_Date__c = ev.ActivityDate;
                               }
                           }      
                           
                           //Count all related activities’s with Activity Date is in current year and less or equal to today.
                           //Current_YTD_Initial_Activities__c
                           if(ev.ActivityDate.Year() == System.today().year()
                              && ev.ActivityDate <= System.today()) {
                                  if(mapOpps.get(ev.WhatId).Current_YTD_Initial_Activities__c == null)
                                      mapOpps.get(ev.WhatId).Current_YTD_Initial_Activities__c = 1;
                                  else
                                      mapOpps.get(ev.WhatId).Current_YTD_Initial_Activities__c = mapOpps.get(ev.WhatId).Current_YTD_Initial_Activities__c + 1;
                              }    
                           
                           //Previous Year same Date value as Today
                           Date previousYearTodaysDate = Date.newinstance((System.today().year()-1), System.today().month(), System.today().day());    
                           
                           //Count all related Initial activities for which Activity Date is in previous year and less than today’s date minus one year.
                           //Prev_YTD_Initial_Activities__c
                           if(ev.ActivityDate.Year() == (System.today().year() - 1)
                              && ev.ActivityDate < previousYearTodaysDate) {
                                  if(mapOpps.get(ev.WhatId).Prev_YTD_Initial_Activities__c == null)
                                      mapOpps.get(ev.WhatId).Prev_YTD_Initial_Activities__c = 1;
                                  else
                                      mapOpps.get(ev.WhatId).Prev_YTD_Initial_Activities__c = mapOpps.get(ev.WhatId).Prev_YTD_Initial_Activities__c + 1;    
                              }    
                           
                           //Count all related Initial PAs for which Activity Date is greater than today.
                           //Scheduled_Initial_Activities__c
                           //Modified By - Neha Sharma - 04/17/2021 - CR-20201110-14683
                           if(ev.ActivityDate > System.today() && ev.Event_Purpose__c =='Initial' &&  (ev.Event_Type__c == 'In Person Visit' || ev.Event_Type__c == 'Phone Appointment'|| ev.Event_Type__c == 'Web Visit')) {
                               if(mapOpps.get(ev.WhatId).Scheduled_Initial_Activities__c == null)
                                   mapOpps.get(ev.WhatId).Scheduled_Initial_Activities__c = 1;
                               else
                                   mapOpps.get(ev.WhatId).Scheduled_Initial_Activities__c = mapOpps.get(ev.WhatId).Scheduled_Initial_Activities__c + 1;    
                           }      
                           
                           //Count all related Initial PAs for which Activity Date is in current year.  
                           //Current_Year_Initial_Activities__c 
                           if(ev.ActivityDate.Year() == System.today().year()) {
                               if(mapOpps.get(ev.WhatId).Current_Year_Initial_Activities__c == null)
                                   mapOpps.get(ev.WhatId).Current_Year_Initial_Activities__c = 1;
                               else
                                   mapOpps.get(ev.WhatId).Current_Year_Initial_Activities__c = mapOpps.get(ev.WhatId).Current_Year_Initial_Activities__c + 1;  
                           } 
                           
                           //Count all related Initial PAs for which Activity Date is in previous year.
                           //Previous_Year_Initial_Activities__c   
                           if(ev.ActivityDate.Year() == (System.today().year()-1)) {
                               if(mapOpps.get(ev.WhatId).Previous_Year_Initial_Activities__c == null)
                                   mapOpps.get(ev.WhatId).Previous_Year_Initial_Activities__c = 1;
                               else
                                   mapOpps.get(ev.WhatId).Previous_Year_Initial_Activities__c = mapOpps.get(ev.WhatId).Previous_Year_Initial_Activities__c + 1; 
                           }  
                           

                       } 
                }
                
                //Commented By - Neha Sharma - 04/17/2021 - CR-20201110-14683 - Add logic to populate the Counts the Total_Initial_Activities__c via total number of initial PAs, web visits, and IPVs. Includes past and future activities.
                if(setOfEventType.contains(ev.Event_Type__c)){
                    
                    //Checking if map contains the key in it                        
                    if(mapOpps.containsKey(ev.WhatId) && mapOpps.get(ev.WhatId) != null) {
                        if(mapOpps.get(ev.WhatId).Total_Initial_Activities__c == null)
                        {
                            mapOpps.get(ev.WhatId).Total_Initial_Activities__c = 1;
                        }else
                        {
                            mapOpps.get(ev.WhatId).Total_Initial_Activities__c = mapOpps.get(ev.WhatId).Total_Initial_Activities__c + 1;
                        }
                    }
                }
            }    
        }
        return mapOpps;
    }
    
            
    
    
    //V_1.9 - Merged By - Rajeev Jain - 07/05/2017
    //V_1.7 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. - Starts From Here 
   /***
    //Added By - Abhinav Sharma - 12/09/2016 - CR-20160111-9502 - Will sync up fields on PSS Records from Event record
    public static void syncUpPSSrequestsFields(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
    
        //Map of opportunity
        Map<Id, Opportunity> mapOpportunites = new Map<Id, Opportunity>();
        
        //Map of eligible event record types
        Map<Id, RecordType> mapEventRecordTypes =  new Map<Id, RecordType>([SELECT id , DeveloperName FROM RecordType 
                                                    WHERE DeveloperName IN ('Core_Marketing' , 'Core_AM')
                                                    AND IsActive = true 
                                                    AND SobjectType = 'Event']);
        
        //Checking for null value
        if(newEvents != null) {
            
        //Loop through trigger.new event records
          for(Event e : newEvents) {
                    
                //Update use case
                if(mapOldEvents != null) {
                    
                    //Map to hold the event ID string literals as key and corresponding instance as value
                    Map<String, Event> mapOfEventsIds = new Map<String, Event>();
                    
                    //Checking for the field value change on event update
                    if(e.WhatId != null 
                        && e.WhatId.getSObjectType() == Schema.Opportunity.SobjectType
                        && e.RecordTypeId != null
                        && mapEventRecordTypes != null
                        && mapEventRecordTypes.get(e.RecordTypeId) != null
                        && 
                           (
                                e.StartDateTime != mapOldEvents.get(e.Id).StartDateTime 
                             || e.WhatId != mapOldEvents.get(e.Id).WhatId
                             || e.Event_Type__c != mapOldEvents.get(e.Id).Event_Type__c
                             || e.Subject != mapOldEvents.get(e.Id).Subject
                             || e.EndDateTime != mapOldEvents.get(e.Id).EndDateTime
                            )
          ){
                
                        //temp string
                        String eventIDStr = '';
                        
                        //Checking for the length and processing event ID string accordingly
                        if(String.valueOf(e.ID).length() == 18)
                            eventIDStr = String.valueOf(e.ID).substring(0, 15);
                        else
                            eventIDStr = String.valueOf(e.ID);
                        
                        //Populating collection with ID string literals
                        if(eventIDStr != '')
                            mapOfEventsIds.put(eventIDStr, e);
                    }
                    
                    //Checking collection for it's size
                    if(mapOfEventsIds.keySet().size() > 0) {
                        
                        //Map of PSS Requests
                        Map<Id, PSS_Request__c> mapPSSRequests = new Map<Id, PSS_Request__c>();
                        
                        //Loop through PSS Requests
                        for(PSS_Request__c pss : [SELECT ID, Subject__c, Event_Type__c, 
                                                    Opportunity__c, Start__c, End__c, Activity_ID__c
                                                   FROM PSS_Request__c
                                                   WHERE Activity_ID__c != null AND Activity_ID__c != ''
                                                    AND Activity_ID__c IN : mapOfEventsIds.keySet()
                                                 ]) 
                        {
                            
                            //Checking for key presence and for null value in the map
                            if(mapOfEventsIds.containsKey(pss.Activity_ID__c)
                              && mapOfEventsIds.get(pss.Activity_ID__c) != null
                            ) {
                                
                                //populating fields on "PSS Request" record instance from the event fields values
                                PSS_Request__c pssReq = new PSS_Request__c(ID = pss.ID);
                                pssReq.Start__c = mapOfEventsIds.get(pss.Activity_ID__c).StartDateTime;
                                pssReq.End__c = mapOfEventsIds.get(pss.Activity_ID__c).EndDateTime;
                                pssReq.Subject__c = mapOfEventsIds.get(pss.Activity_ID__c).Subject;
                                pssReq.Event_Type__c = mapOfEventsIds.get(pss.Activity_ID__c).Event_Type__c;
                                pssReq.Opportunity__c = mapOfEventsIds.get(pss.Activity_ID__c).WhatId;
                                mapPSSRequests.put(pssReq.Id, pssReq);
                            }                                                                            
                        }
                        
                        //Checking for the size value
                        if(mapPSSRequests.values().size() > 0) {
                            
                            //Update PSS Request records
                            update mapPSSRequests.values();
                        }
                    }
              }
          }
      }            
    }
    **/
    //V_1.7 - Modified By - Mahendra Swarnakar - 04/25/2017 - CR-20170302-10730 - Commentedout the method (syncUpPSSrequestsFields). Because as per the new "PSS process" it is no longer needed. - Ends Here 
    
    //V_1.8 - Modified By - Mahendra Swarnakar - 06/08/2017 - CR-20170302-10730 - Added the methods (doIcsAttachment and  handleGoogleEvent). TO sent and outlook invite on the creation of Event record on the PSS request.
    //V_1.9 - Modified By - Abhinav Sharma - 5/24/2018 - CR-20180430-12193 - Updated the Email subject
    /**
     *  @description    :   This method is used to handle the google event' operations. 
     *
     *  @args           :   List new Event, Map Old events  
     *
     *  @return         :   Void
     *
     **/
    public static void handleGoogleEvent( List<Event> newEvent, Map<Id, Event> mapOldEvents) {
       
        //Map to hold the event Id as a key and events DML Type as a value(i.e.Event Dml Type means event is created/updated/Cancelled). 
        Map<Id, String> mapEventIdWithEventDMLType = new Map<Id, String>();
        
        //MAp to hold the eligible event records 
        Map<Id, Event> mapEligibleEvent = new Map<Id, Event>();
        
        //Set to hlod the contact Ids on the "Name" field on Event
        Set<Id> setContactIds = new Set<Id> ();
        
        //Set to hold the pss request Ids
        Set<Id> setPSSids = new Set<Id>();
        
        //Loop over the event lists
        for(Event eve: newEvent ) {
            
            //Check for the PSS Request Type
            if(eve.SME_Request__c != null && String.isNotBlank(eve.SME_Request__c) ){
                
                //Insert/Update use case
                if(mapOldEvents == null 
                     || 
                     (
                        mapOldEvents != null
                        &&
                        (
              mapOldEvents.get(eve.Id).Cancelled_Did_Not_Occur__c !=  eve.Cancelled_Did_Not_Occur__c
                          ||
                            mapOldEvents.get(eve.Id).StartDateTime !=  eve.StartDateTime
                            ||
                            mapOldEvents.get(eve.Id).EndDateTime !=  eve.EndDateTime
                            ||
                            mapOldEvents.get(eve.Id).Subject !=  eve.Subject
                            ||
                            mapOldEvents.get(eve.Id).WhoId !=  eve.WhoId
                        )
          )
        ) {
                    
                    //Populate the mapEligibleEvent
                    mapEligibleEvent.put(eve.Id, eve);
                    
                    //Populate the Set setPSSids
                    setPSSids.add(eve.SME_Request__c);
                    
                    //Check If Name field on event is populated with contact 
                    if(eve.WhoId != null && eve.WhoId.getSObjectType() == Contact.sObjectType) {
                        setContactIds.add(eve.WhoId);
                    }
                    
                    if(mapOldEvents == null) {
                        
                        //Populate the map mapEventIdWithEventDMLType
                        mapEventIdWithEventDMLType.put(eve.Id, 'added');
                    }
                    
                    if(mapOldEvents != null)
                    {
                        //Check if event is going to marked as cancelled
                        if(eve.Cancelled_Did_Not_Occur__c == true)
                            
                            //Populate the map mapEventIdWithEventDMLType
                            mapEventIdWithEventDMLType.put(eve.Id, 'cancelled');
                        
                        else
                            //Populate the map mapEventIdWithEventDMLType
                            mapEventIdWithEventDMLType.put(eve.Id, 'updated');
                    }
                }
            }
        }
        
        //Check for the size
        if(mapEligibleEvent.size() > 0){
        
            Map<Id,Contact> mapContacts = new Map<Id,Contact>();
                
            if(setContactIds.size() > 0){
                for(Contact con : [Select Id,Name, AccountId, Account.Name From Contact where Id IN : setContactIds])
          mapContacts.put(con.Id, con);
            }
            
            //Map to Hold the pss request records
            Map<Id, PSS_Request__c> mapPSS = new Map<Id, PSS_Request__c>();
            
            //Check for the size
            if(setPSSids.size() > 0) {
                
                //Loop/Query over the PSS Request records 
            for(PSS_Request__c pss : [select Id, Name, Reason_Requested__c, PSS_Request_Notes__c,
                                            PSS_Resource__c, PSS_Resource__r.Name, PSS_Resource__r.Email,
                                            OwnerId, Owner.Email, Owner.Name,  
                                            Institution__c, Institution__r.Name, 
                                            Opportunity__c, Opportunity__r.Name,
                                            Membership__c, Membership__r.Name,
                                            Program__c, Program__r.Name
                                            From PSS_Request__c 
                                            where Id IN : setPSSids 
                                         ])
                    //Populate the mapPSS
                  mapPSS.put(pss.Id, pss);
            }
            
            //List of emails
            List<Messaging.SingleEmailMessage> listOfMail = new List<Messaging.SingleEmailMessage>();
            
            //Loop over the eligible events
            for(Event even : mapEligibleEvent.values()) {
                
                //List to hold the tooaddresses/Email address of the users for whom email to be sent 
                List<String> toAddresses = new List<String> ();
                
                //Check for the PSS request related to the Event
                if( even.SME_Request__c != null && mapPSS.get(even.SME_Request__c) != null) {
                    
                    //Check for the owner on the Event related PSS record and populate the too address list with its Email addresses
                    if(String.isNotBlank(mapPSS.get(even.SME_Request__c).Owner.Email)) 
                        toAddresses.add(mapPSS.get(even.SME_Request__c).Owner.Email);
                    
                    //Check for the PSS Resource on the Event related PSS record
                    if(mapPSS.get(even.SME_Request__c).PSS_Resource__c != null 
                         && String.isNotBlank(mapPSS.get(even.SME_Request__c).PSS_Resource__r.Email)
                      ) 
                        //Populate the tooaddresses list with the pss resource Email
                        toAddresses.add(mapPSS.get(even.SME_Request__c).PSS_Resource__r.Email);
                
                    //Create an Instance of Email
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                    //Set the TOO Addresses for the Email
                    mail.setToAddresses(toAddresses);
                    
                    //String emailSub = 'Meeting Invitation:' + even.Subject;
                    String emailSub = 'SME - ' + even.Type_of_PSS__c;
                    String memberContactName = '';
                    if(even.WhoId != null 
                         && even.WhoId.getSObjectType() == Contact.sObjectType 
                         && mapContacts.get(even.WhoId) != null
          ){
            memberContactName = mapContacts.get(even.WhoId).Name;
            if(mapContacts.get(even.WhoId).AccountId != null)
                //emailSub = emailSub + ' : ' + mapContacts.get(even.WhoId).Account.Name;
                emailSub = emailSub + ' - ' + mapContacts.get(even.WhoId).Account.Name + ' - ' + mapContacts.get(even.WhoId).Name;
                
              //Check that the Event has been cancelled - If Cancelled than Add the CANCELLED. - Added as per - CR-20180430-12193 - Abhinav Sharma
                if(mapEventIdWithEventDMLType.containsKey(even.Id)) {
                  //Check for the Cancelled 
                  if(mapEventIdWithEventDMLType.get(even.Id).equalsIgnoreCase('cancelled'))
                      emailSub = 'CANCELLED - ' +emailSub;    
                }
            }
            
                    //Set the Subject of the email
                    mail.setSubject(emailSub);
                    
                    String htmlString = 'Hello,<br/><br/>';
              htmlString += 'Following event has been '+mapEventIdWithEventDMLType.get(even.Id)+' in your calendar.<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Subject: &nbsp;</b> <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+even.Id+'" />'+even.Subject+'</a> <br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Start: &nbsp;</b> '+even.StartDateTime.format()+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;End: &nbsp;</b> '+even.EndDateTime.format()+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Related To: &nbsp;</b> <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+mapPSS.get(even.SME_Request__c).Id+'" />'+mapPSS.get(even.SME_Request__c).Name +'</a> <br/><br/>';
                    
                    htmlString += '<b>&nbsp;&nbsp;Requester: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).OwnerId != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Owner.name)? mapPSS.get(even.SME_Request__c).Owner.Name : '')+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;'+Label.SME +' Resource: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).PSS_Resource__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).PSS_Resource__r.name)? mapPSS.get(even.SME_Request__c).PSS_Resource__r.name : '')+'<br/><br/>';
                    
                    htmlString += '<b>&nbsp;&nbsp;Institution: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).Institution__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Institution__r.name)? mapPSS.get(even.SME_Request__c).Institution__r.name : '')+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Opportunity: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).Opportunity__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Opportunity__r.name)? mapPSS.get(even.SME_Request__c).Opportunity__r.name : '')+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Membership: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).Membership__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Membership__r.name)? mapPSS.get(even.SME_Request__c).Membership__r.name : '')+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Program: &nbsp;</b> '+(mapPSS.get(even.SME_Request__c).Program__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Program__r.name)? mapPSS.get(even.SME_Request__c).Program__r.name : '')+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Member Contact: &nbsp;</b> '+memberContactName+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;' + Label.SME +' Request notes: &nbsp;</b> '+mapPSS.get(even.SME_Request__c).PSS_Request_Notes__c+'<br/><br/>';
                    
                    htmlString += '<b>&nbsp;&nbsp;Event Type: &nbsp;</b> '+even.Event_Type__c+'<br/><br/>';
                    htmlString += '<b>&nbsp;&nbsp;Event Purpose: &nbsp;</b> '+even.Event_Purpose__c+'<br/><br/>';
                    htmlString += 'Thanks.<br/><br/>';
                    
                    /*Text body*/
                  String plainTextBody = 'Hello, ';
                      
                   plainTextBody += ' Subject: ' + even.Subject + ', ';
                   plainTextBody += ' URL: '    +URL.getSalesforceBaseUrl().toExternalForm()+'/'+even.Id+', ';
                   plainTextBody += 'Start: '  +even.StartDateTime.format()+', ';        
                   plainTextBody += 'End: '    +even.EndDateTime.format()+', ';
                   plainTextBody += 'Related To: '  +mapPSS.get(even.SME_Request__c).Name+', ';
                   plainTextBody += 'Requester: ' +(mapPSS.get(even.SME_Request__c).OwnerId != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Owner.name)? mapPSS.get(even.SME_Request__c).Owner.Name :  '')+', ';
                   plainTextBody +=  Label.SME+ ' Resource: ' +(mapPSS.get(even.SME_Request__c).PSS_Resource__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).PSS_Resource__r.name)? mapPSS.get(even.SME_Request__c).PSS_Resource__r.name : ', ');
                   plainTextBody += 'Institution: ' + (mapPSS.get(even.SME_Request__c).Institution__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Institution__r.name)? mapPSS.get(even.SME_Request__c).Institution__r.name : ', ');
                   plainTextBody += 'Opportunity: ' + (mapPSS.get(even.SME_Request__c).Opportunity__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Opportunity__r.name)? mapPSS.get(even.SME_Request__c).Opportunity__r.name : ', ');
                   plainTextBody += 'Membership: ' + (mapPSS.get(even.SME_Request__c).Membership__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Membership__r.name)? mapPSS.get(even.SME_Request__c).Membership__r.name : ', ');
                   plainTextBody += 'Membership: ' + (mapPSS.get(even.SME_Request__c).Membership__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Membership__r.name)? mapPSS.get(even.SME_Request__c).Membership__r.name : ', ');
                   plainTextBody += 'Program: ' + (mapPSS.get(even.SME_Request__c).Program__c != null && String.isNotBlank(mapPSS.get(even.SME_Request__c).Program__r.name)? mapPSS.get(even.SME_Request__c).Program__r.name : ', ');
                   plainTextBody += 'Member Contact: ' + memberContactName + ', ';
                   plainTextBody +=  Label.SME +' Request notes: ' + mapPSS.get(even.SME_Request__c).PSS_Request_Notes__c+ ', ';
                   plainTextBody += 'Event Type: ' + even.Event_Type__c + ', ';
                   plainTextBody += 'Event Purpose: ' + even.Event_Purpose__c + ' '; 
                   
                   //Set the Emails Body
                    mail.setHtmlBody(htmlString);
                    
                    //Added By Rajeev Jain - CR-20180830-12533 using Organisation wide address.
                    //Query to the Organisation wide Email address.
                    List<OrgWideEmailAddress> smeEmail  = [Select Id, DisplayName, Address From OrgWideEmailAddress where DisplayName = 'SME Request Support'];
                    
                    if(smeEmail != null)
                        //Setting the parameter so email can be send with this email Addresas
                        mail.setOrgWideEmailAddressId(smeEmail[0].Id);    
                    
                    //Create an instance for the email attachment 
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    
                    //Set the file Name
                    attach.filename = 'meeting.ics';
                    
                    //Set the content Type
                    attach.ContentType = 'text/calendar;';
                    attach.inline = true;
                    
                    //Method call to returm the blob type (i.e. the body for the attachment)
                    Blob b = doIcsAttachment(even, toAddresses, mapEventIdWithEventDMLType.get(even.Id), emailSub, plainTextBody, smeEmail[0].Address);
                    
                    //Set the body of the attachment/File 
                    attach.body = b;
                    
                    //Set the file Attachments
                    mail.setFileAttachments(new List<Messaging.EmailFileAttachment> {attach});
                    
                    //Add email to the list
                    listOfMail.add(mail);
                }
            }
            
            //Check for the Flag to execute the below code only once
            if(isAlreadyExecuted == False) {
                
                //Set the flag to by pass for the second execution
                isAlreadyExecuted = true;
                
                //Check for the size
                if(listOfMail.size() > 0 )
                    
                    //Sent the Emails
                    Messaging.sendEmail(listOfMail);
            }
        }
    }
    
    //V_1.8 - Added By - Mahendra Swarnakar - 06/08/2017 - CR-20170302-10730
    ////Updated by Abhinav sharma - CR-20180430-12193 - 06/20/2018 - to update the Subject on the ICS File.
    /**
     *  @description    :   This method is used to create Ics file Template 
     *
     *  @args           :   Event,  List<String>, String
     *
     *  @return         :   Blob
     *
     **/
    public static Blob doIcsAttachment(Event event, List<String> toEmails,String eventDMLType, String evSub, String evDescription, String Organiser_Email) {
        
        Timezone tz = UserInfo.getTimeZone();
        Integer secondsToAddStart= (tz.getOffset(event.StartDateTime))/1000;
        Integer secondsToAddEnd= (tz.getOffset(event.StartDateTime))/1000;
        
        DateTime startDate = event.StartDateTime.addSeconds(-secondsToAddStart);
        DateTime endDate = event.EndDateTime.addSeconds(-secondsToAddEnd);
        
    //Build date strings
    List<String> startDateFormatedSplit = (startDate.format('yyyyMMdd HHmmss')).split(' ');
        List<String> endDateFormatedSplit = (endDate.format('yyyyMMdd HHmmss')).split(' ');
        List<String> nowDateFormatedSplit = (Datetime.now().format('yyyyMMdd HHmmss')).split(' ');
        
        //Formating the Start Date
        String startDateString = startDateFormatedSplit[0]+'T'+startDateFormatedSplit[1]+'Z';
        
        //Fomatting the End date
        String endDateString = endDateFormatedSplit[0]+'T'+endDateFormatedSplit[1]+'Z';
        
        //Fomatting the Current date
        String nowString = nowDateFormatedSplit[0]+'T'+nowDateFormatedSplit[1]+'Z';
           
       /* //String to hold the Email Addresses
        String toEmailsAddresses = '';
        if(toEmails.size() > 0){
            for(String mail : toEmails)
                toEmailsAddresses = toEmailsAddresses + mail+ ';';
        }*/
        
        //Generate actual body
        String txtInvite = '';
        
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Google Inc//Google Calendar 70.9054//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'CALSCALE:GREGORIAN\n';
        
        //Check for the Event Dml Type and then accordingly update the Method of calendar event
        if(eventDMLType == 'cancelled')
            txtInvite +='METHOD:CANCELLED' +'\n'; 
        else
            txtInvite +='METHOD:REQUEST' +'\n';
        
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'VTIMEZONE:'+ UserInfo.getTimeZone().toString() +'\n';
        //Set the Timezone to EST time
        //txtInvite += 'VTIMEZONE:America/New_York\n';
        //txtInvite += 'VTIMEZONE:America/New_York\n';
        
        txtInvite += 'DTSTART:' + startDateString + '\n';
        txtInvite += 'DTEND:' + endDateString + '\n';
        txtInvite += 'DTSTAMP:' + startDateString + '\n';
        
        //Added by Rajeev Jain - CR-20180830-12533
        //Checking for the SME_Address Blank
        if(String.isBlank(Organiser_Email))
            Organiser_Email = UserInfo.getUserEmail();
        
        //Added this From CR-20180830-12533 - All mail send from a generic email. 
        //Mail should send from the generic SME Email - smerequests@eab.com
        txtInvite += 'ORGANIZER;CN=' + 'SME Request' + ':MAILTO:' + Organiser_Email + '\n';
    
        //txtInvite += 'ORGANIZER;CN=' + UserInfo.getName() + ':MAILTO:' + UserInfo.getUserEmail() + '\n';
        txtInvite += 'UID:' + String.valueOf(event.Id) + '\n';
      
        //Adding Current User's Email address.
        toEmails.add(UserInfo.getUserEmail());
        
        //Check the size list.
        if(toEmails != null && toEmails.size() > 0) {
          
            for(String emailid : toEmails) {
                txtInvite += 'ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=\n';
                  txtInvite += ' TRUE;X-NUM-GUESTS=0:mailto:' + emailid +'\n';    
            }
        }
        
        txtInvite += 'CREATED:' + nowString + '\n';
        txtInvite += 'DESCRIPTION:'+evDescription +'\n';
        txtInvite += 'LAST-MODIFIED:' + nowString + '\n';
        txtInvite += 'LOCATION: ' + event.Location + '\n';
        txtInvite += 'SEQUENCE:0\n';
        
        //Check for the Event Dml Type and then accordingly update the status of calendar event
        if(eventDMLType == 'cancelled')
            txtInvite +='STATUS:CANCELLED' +'\n'; 
        else
            txtInvite +='STATUS:CONFIRMED' +'\n';
        
        //Updated by Abhinav sharma - CR-20180430-12193 - to update the Subject on the ICS File.
        txtInvite += 'SUMMARY: ' + evSub +'\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR\n';
        return Blob.valueOf(txtInvite);
        
    }
    //V_1.8 - Modified By - Mahendra Swarnakar - 06/08/2017 - CR-20170302-10730 - Ends here.
    //V_1.9 - Merged By - Rajeev Jain - 07/05/2017 - upto here
    
    /**
     * 
     *  @description    :   This method is used to prevents an activity from being saved on the opportunity without the opportunity having an active primary proposal
     *
     *  @args           :   List<Event> events, Map<Id, Event> mapOldEvents 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 06/09/2017 - Subhash Garhwal - CR-20170403-10807 (Work Order DS157)
     *            V_1.01 - Modified By Subhash Garhwal - 04/25/2018 - CR-20180205-11952 - Added the logic to through error on event creation if there is no Proposal Line on Proposal under the opportunity
     * 
     **/   
   /*public static void primaryProposalRequiredForEvent(List<Event> events, Map<Id, Event> mapOldEvents ) {
       
       //bypass validation if this is a merge operation
       if (OpportunityMergeController.isOpportunityMerge) return;
       
        //Set to hold opportunity id
        Set<id> WhatIds = new Set<Id>();
      
        //Check for condition
        for(Event event : events) {
      
          //Check for particular condition
          if(event.WhatId != null && (mapOldEvents == null || event.WhatId != mapOldEvents.get(event.Id).WhatId) 
             && string.valueOf(event.WhatId).startsWith(CPQConstants.OPPORTUNITY_OBJECT_PREFIX)) 
          {
          
            //Add opportunity id to set
            WhatIds.add(event.WhatId);
          
          }
        }
  
        //Check for the size of opportunity id
        if(whatIds.Size()>0 ) {
        
          //Map to hold opportunity data
          Map<Id, Opportunity> mapOpportunity = new Map<Id,Opportunity>([Select Id, SBQQ__PrimaryQuote__r.SBQQ__Primary__c, recordTypeId,
                                                                         RecordType.DeveloperName, SBQQ__PrimaryQuote__c 
                                                                         From Opportunity Where Id IN: whatIds 
                                     AND RecordType.DeveloperName IN: CPQConstants.SET_OPP_INITIATING_RECORDTYPES
                                                                         AND  (SBQQ__PrimaryQuote__r.SBQQ__Primary__c = false 
                                                                         OR SBQQ__PrimaryQuote__r.SBQQ__LineItemCount__c = 0)
                                          ]);
          if(mapOpportunity.Size()>0) {
    
            for(event eV : events) {
        
              //Check WhatId contain in mapOldTasks
              if(mapOpportunity.containsKey(eV.WhatId))
                      eV.addError(Label.Activity_Cannot_Be_Saved);
            }
          }
       }
    }*/
    
     /**
     *  @description    :   This method pulls the related Pss request fields and Map with Event Pss Request Fiels 
     *
     *  @args           :   List<Event> events, Map<Id, Event> mapOldEvents 
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 03/28/2018 - CR-20170620-11016 - Created By Abhinav Sharma.
     *                  :   V_1.1 - Modified By - 06/26/2018 - Abhinav sharma - CR-20180625-12300 - Modified syncWithPssRequest To save the Query. 
     *                  :   V_1.2 - Modified By Rajeev Jain - CR-20181008-12652 - 10/12/2018 - Update the Field population of 
                            Why is SME Required Field on the Event based on Reason Required.  
                        :   V_1.3 - Added By Abhinav Sharma - CR-20181025-12708 - 10/30/2018 - Updated the logic to change the opp/Subscription period on event what Id. 
    **/   
    
    public static void syncWithPssRequest(List<Event> newEvents, Map<Id, Event> oldMapEvents) {
      
        //Set to hold the Pss request Ids 
        Set<Id> setPssRequestIds = new Set<Id>();
        
        //Set to hold the eligible Record types for Event 
        Set<String> setEligibleRecordTypeEvents = new Set<String>{'BI_AM','BI_Marketing','Core_AM','Core_Marketing'};
        
        //Set Of RecordType Id 
        Set<Id> setEventRecordIds = new Set<Id>();
        
        //Getting the Custom setting and check for the 4 Record types of Event Object- BI_AM', 'BI_Marketing', 'Core_AM', 'Core_Marketing'
        /*list<Recordtype_Setting__c> rtslist = Recordtype_Setting__c.getall().values();
        
        for (Recordtype_Setting__c rts : rtslist) {
            if (rts.SObjectType__c == 'Event') {
               
                //Check for the 4 Record type of Event Only.
                if(setEligibleRecordTypeEvents.contains(rts.DeveloperName__c))
                  setEventRecordIds.add(rts.SFID__c);
            } 
        }*/
        setEventRecordIds.add(Util.sobjectRecordTypeId('Event').get('BI_AM'));
        setEventRecordIds.add(Util.sobjectRecordTypeId('Event').get('BI_Marketing'));
        setEventRecordIds.add(Util.sobjectRecordTypeId('Event').get('Core_AM'));
        setEventRecordIds.add(Util.sobjectRecordTypeId('Event').get('Core_Marketing'));
        
        /* Commented By Abhinav sharma - CR-20180625-12300 - To save the Query. 
        //getting the Record Type of Event Object
        for(RecordType rT : [Select Id From RecordType Where DeveloperName IN ('BI_AM', 'BI_Marketing', 'Core_AM', 'Core_Marketing') AND sObjectType = 'Event'] )
          //Add the Record Type in the Set
            setEventRecordIds.add(rT.Id); */
        
        //Check the size of Set
        if(setEventRecordIds.size() > 0) {
            
            //Loop through the New Event List 
            for(Event evt : newEvents) {
               
                //Check the event is related to the PSS Request Object
                if(evt.WhatId != null && evt.whatId.getSObjectType() == PSS_Request__c.sObjectType && setEventRecordIds.contains(evt.RecordTypeId))
                    setPssRequestIds.add(evt.WhatId);      
            }
        }
        
        //Check for the size of set
        if(setPssRequestIds.size() > 0) {
          
            //Query on the Pss Request 
            Map<Id, PSS_Request__c> MapIdWithPssRequests = new Map<Id, PSS_Request__c> ([Select Id, PSS_Rank__c, Reason_Requested__c, PSS_Resource__c, PSS_Resource__r.FirstName, PSS_Resource__r.LastName,
                                                Approval_Status__c, Opportunity__c, Subscription_Period__c From PSS_Request__c Where Id IN: setPssRequestIds]);
            
            //Loop on the Pss Request 
            for(Event event : newEvents) {
              
                //Check for map contains the desired value, and Pss Request is approved
                if(event.WhatId != null && MapIdWithPssRequests.containsKey(event.WhatId) 
                  && MapIdWithPssRequests.get(event.WhatId) != null  && setEventRecordIds.contains(event.RecordTypeId)
                     && MapIdWithPssRequests.get(event.WhatId).Approval_Status__c == 'Approved') {
                    
                     //Mapping the Pss Request with the Event Object
                     event.PSS_Resource_Requested__c = true;
                     event.PSS_Resource_Confirmed__c = true; 
                    
                     //Modified By Rajeev Jain - CR-20181008-12652 - 10/12/2018 - Starts here
                     //Check of the Reason required field. 
                     if(String.isNotBlank(MapIdWithPssRequests.get(event.WhatId).Reason_Requested__c)  
                        && MapIdWithPssRequests.get(event.WhatId).Reason_Requested__c.length() >= 254)
                        
                        //Filling the Event Field, if the Reason required is more than equal to 254 Characters. 
                       event.Why_is_PSS_Requested__c = MapIdWithPssRequests.get(event.WhatId).Reason_Requested__c.subString(0, 253);    
                     else
                        //Filling the Event Field, if the Reason required is not more than 254 characters.
                        event.Why_is_PSS_Requested__c = MapIdWithPssRequests.get(event.WhatId).Reason_Requested__c;
                    
                     //Modified By Rajeev Jain - CR-20181008-12652 - 10/12/2018 - Ends here
 
          
                     //String to hold the First & Last Name.
                     String firstName = '';
                     String lastName = '';   
                        
                     //Set blank if the first or Last name is null
                     if(MapIdWithPssRequests.get(event.WhatId).PSS_Resource__r.LastName != null)
                       lastName = MapIdWithPssRequests.get(event.WhatId).PSS_Resource__r.LastName;
                     
                     //Set blank if the first or First name is null
                     if(MapIdWithPssRequests.get(event.WhatId).PSS_Resource__r.FirstName != null)
                       firstName = MapIdWithPssRequests.get(event.WhatId).PSS_Resource__r.FirstName;
                       
                     //Check the PSS Rank = 'Primary'
                     if(MapIdWithPssRequests.get(event.WhatId).PSS_Rank__c == 'Primary') {
                            
                        event.Preliminary_PSS_Resource__c = lastName + ', ' + firstName;
                     }
                     
                     //Commented by Dipesh Gupta - 10/16/2019 - CR-20191010-13404 
                     //Maping the PSS Field With Event Fields
                     //event.Confirmed_PSS_Resource__c = lastName + ', ' + firstName;
                        
                     //Check for the PSS Rank = 'Secondary'
                     if(MapIdWithPssRequests.get(event.WhatId).PSS_Rank__c == 'Secondary') {
                            
                         event.Secondary_PSS__c = lastName + ', ' + firstName;
                     }
                         
                      //Added By Abhinav Sharma - CR-20181025-12708 - 10/30/2018 - Updating th Event Related To Logic.- Starts here --
                     /*Updating the Related to of the Event.
                         If Opportunity is populated on the Sme Request then populate Opportunity id as a What Id on event
                         else if Subscription Period is populated on the sme request than populate Speriod on the Event What Id*/
                    
                     //Check if Opp is populated on the SME Request. 
                     if(String.isNotBlank(MapIdWithPssRequests.get(event.WhatId).Opportunity__c)){
                         event.SME_Request__c = MapIdWithPssRequests.get(event.WhatId).Id;
                         event.WhatId = MapIdWithPssRequests.get(event.WhatId).Opportunity__c; 
                         
                     }
                    //Checking for the Speriod. 
                    else if(String.isNotBlank(MapIdWithPssRequests.get(event.WhatId).Subscription_Period__c)) {
                        
                        event.SME_Request__c = MapIdWithPssRequests.get(event.WhatId).Id;
                        event.WhatId = MapIdWithPssRequests.get(event.WhatId).Subscription_Period__c;
                    }
                    //Added By Abhinav Sharma - CR-20181025-12708 - 10/30/2018 - Updating th Event Related To Logic.- Ends here --
                }
            }
        }
    }
    
     /**
     *  @description    :   Method to populate Related Type field on Event with object API name of record in WhatId
     *
     *  @args           :   List<Event>, Map<Id, Event>
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - By Mahendra Swarnkar - 02/14/2019 - CR-20190204-12863
     *
    **/
    public static void populateRelatedTypeField(List<Event> newEvents, Map<Id, Event> mapOldEvents) {
        
        //Loop over the new events
        for(Event event : newEvents) {
            
            //Check for conditions
            if(event.WhatId !=  null && (event.Related_Type__c ==  null || mapOldEvents == null || (mapOldEvents != null && event.WhatId != mapOldEvents.get(event.Id).WhatId))){
                
                //Populate the related Type on event
                event.Related_Type__c = event.WhatId.getsobjecttype().getDescribe().getLabel();
            }
        }
    }
    
    /**
     *  @description    :   Method to populate All Institution Roles field with Institution Roles of all Contact related to an Event.
     *                      This has to be a future method because multiple contacts on a single Event are added
     *                      as a separate DML statement after insert/update of the event itself.
     *
     *  @args           :   Set<Id> eventIds
     *
     *  @return         :   void
     * 
     *  @revision Log   :   V_1.0 - Created - Victor Hanson - 04/24/2019 - CR-20190204-12863
     *
    **/
    @future
    public static void populateAllInstRoles(Set<Id> eventIds) {
        
        //list of events to update
        List<Event> eventsToUpdate = new List<Event>();
        
        //get events
        Map<Id, Event> originalEventMap = new Map<Id, Event>([SELECT Id, All_Institution_Roles__c, WhoId FROM Event WHERE Id IN :eventIds]);
        List<Event> newEvents = originalEventMap.values().clone();
        
        Set<Id> allWhoIds = new Set<Id>();
        Set<Id> primaryWhoIds = new Set<Id>();
        Map<Id, Contact> contactsWithInstRoles;
        Map<Id, Set<Id>> mapEventIdToContactIds = new Map<Id, Set<Id>>();
        
        //get all whoIds
        for (Event e : newEvents) {
            if (e.WhoId != null) {
                Set<Id> cIds = new Set<Id>();
                cIds.add(e.WhoId);
                mapEventIdToContactIds.put(e.Id, cIds);
                
                allWhoIds.add(e.WhoId);
                primaryWhoIds.add(e.WhoId);
            }
        }
        
        for (EventWhoRelation evtRelationship : [SELECT Id, EventId, RelationId FROM EventWhoRelation WHERE Type = 'Contact'
                                                AND RelationId NOT IN :primaryWhoIds AND EventId IN :eventIds]) 
        {
            Set<Id> cIds = mapEventIdToContactIds.get(evtRelationship.EventId);
            if (cIds == null) cIds = new Set<Id>();
            cIds.add(evtRelationship.RelationId);
            mapEventIdToContactIds.put(evtRelationship.EventId, cIds);
            
            allWhoIds.addAll(cIds);
        }
        //get all contacts with institution roles
        contactsWithInstRoles = new Map<Id, Contact>([SELECT Id, 
                                                      (SELECT Id, Assignment_Role__r.Name FROM Institution_Roles__r WHERE Assignment_Role__c != null)
                                                      FROM Contact
                                                     WHERE Id IN :allWhoIds]);
        
        //loop through each event, populating All Institution Roles field
        for (Event e : newEvents) {
            
            //reset All Institution Roles field
            e.All_Institution_Roles__c = null;
            
            //set to hold list of roles
            List<String> roles = new List<String>();
            
            //get the EventWhoRelations so we can find each contact
            Set<Id> eventWhoIds = mapEventIdToContactIds.get(e.Id);
            if (eventWhoIds == null || eventWhoIds.size() == 0) continue;
            
            Contact primaryContact = contactsWithInstRoles.get(e.WhoId);
            if (primaryContact != null)
                roles = getRoles(primaryContact, roles);
            
            for (Id cId : mapEventIdToContactIds.get(e.Id)) {
                //we already added the primary roles first, so skip this
                if (cId != e.whoId && contactsWithInstRoles.containsKey(cId)) {
                    Contact c = contactsWithInstRoles.get(cId);
                    roles = getRoles(c, roles);
                }
            }
            
            if (roles.size() > 0) {
                //check if the roles have changed.  if so, add to update list
                if (String.join(roles, ';') != originalEventMap.get(e.Id).All_Institution_Roles__c) {
                    
                    e.All_Institution_Roles__c = String.join(roles, ';');
                    eventsToUpdate.add(e);
                }
            }
        }
        
        if (eventsToUpdate.size() > 0) {
            util.bypassAllTriggers = true;
            update eventsToUpdate;
            util.bypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :   returns a list of all institution roles for a contact
     *
     *  @args           :   Contact, List<String> roles
     *
     *  @return         :   List<String>
     * 
     *  @revision Log   :   V_1.0 - Created - Victor Hanson - 04/24/2019 - CR-20190204-12863
     *
    **/
    public static List<String> getRoles(Contact conWithInstRoles, List<String> roles) {
        if (conWithInstRoles.Institution_Roles__r != null && conWithInstRoles.Institution_Roles__r.size() > 0) {
            
            //add all roles to the set of roles
            for (Institution_Roles__c role : conWithInstRoles.Institution_Roles__r) {
                if (role.Assignment_Role__r.Name != null && !roles.contains(role.Assignment_Role__r.Name)) {
                    roles.add(role.Assignment_Role__r.Name);
                }
            }
        }
        return roles;
    }
    
    public static void populateNoContact(List<Event> events) {
        
        //List<Event> events = [SELECT Id, WhoId, WhatId FROM Event WHERE Id IN :eventIds];
        
        List<Event> eventsToUpdate = new List<Event>();
        
        //Map<sObjectName, Map<whatId, Set<Event>>>
        Map<String, Map<Id, Set<Event>>> sObjToAcctEventsMap = new Map<String, Map<Id, Set<Event>>>();
        
        //list of qualifying object api names
        Set<String> qualifyingObjNames = new Set<String> { 'Membership__c', 'Project__c', 'Subscription_Period__c' };
        
        //check each event to see if it's one of the qualifying objects
        for (Event e : events) {
            if (e.WhoId == null && e.WhatId != null) {
                
                //get sobject api name
                String sObjName = e.WhatId.getSObjectType().getDescribe().getName();
                
                //verify it's one of the qualified objects
                if (qualifyingObjNames.contains(sObjName)) {
                    
                    Map<Id, Set<Event>> mapWhatIdToEvents = sObjToAcctEventsMap.get(sObjName);
                    if (mapWhatIdToEvents == null) mapWhatIdToEvents = new Map<Id, Set<Event>>();
                    
                    Set<Event> evts = mapWhatIdToEvents.get(e.WhatId);
                    if (evts == null) evts = new Set<Event>();
                    
                    //add event to set
                    evts.add(e);
                    
                    //add to map
                    mapWhatIdToEvents.put(e.WhatId, evts);
                    
                    //add to sobjectName map
                    sObjToAcctEventsMap.put(sObjName, mapWhatIdToEvents);
                }
            }
        }
        
        if (sObjToAcctEventsMap.size() > 0) {
            
            Map<String, String> whatIdToAccountIdMap = new Map<String, String>();
            
            //get all of the institution ids
            //note: typically we don't do soql within a for-loop but this is an exception
            //      and will only happen if multiple events are inserted with WhatIds related to 2 or more of the qualifying objects (Membership/Project/Subscription)
            for (String sObjName : sObjToAcctEventsMap.keySet()) {
                
                //get map of whatIds to events
                Map<Id, Set<Event>> mapWhatIdToEvents = sObjToAcctEventsMap.get(sObjName);
                Set<Id> whatIds = mapWhatIdToEvents.keySet();
                
                //field name to use in dynamic query
                String fieldName = '';
                
                //set the field name based on the Institution lookup on each object
                if (sObjName == 'Membership__c') {
                    fieldName = 'Account_Name__c';
                }
                else if (sObjName == 'Project__c') {
                    fieldName = 'Institution__c';
                }
                else if (sObjName == 'Subscription_Period__c') {
                    fieldName = 'Institution__c';
                }
                
                //query the records dynamically
                List<SObject> records = database.query('SELECT Id, ' + fieldName + ' FROM ' + sObjName + ' WHERE Id IN :whatIds');
                
                //add each of the account ids to the map of <whatId, accountId>
                for (SObject so : records) {
                    whatIdToAccountIdMap.put( (String) so.get('Id'), (String) so.get(fieldName) );
                }
            }
            
            //get the accountIds and corresponding no-contact record
            //map<whatId, contactId>
            Map<String, Id> acctIdToContactIdMap = getNoContactRecords(whatIdToAccountIdMap);
            
            //assign the no-contact record to each of the events
            for (Event e : events) {
                
                if (e.WhatId != null && acctIdToContactIdMap.containsKey(e.WhatId)) {
                    
                    Event newEvent = e.Clone(true, true);
                    newEvent.WhoId=acctIdToContactIdMap.get(e.WhatId);
                    eventsToUpdate.add(newEvent);
                }
            }
            
            if (eventsToUpdate.size() > 0) {
                //serialize these events and pass to @future method to update (this is a workaround for a known SF issue)
                populateNoContact_future(JSON.serialize(eventsToUpdate));
            }
        }
    }
    
    /**
     * @description     :   Populates WhoId with a special contact record called 'no contact' on Membership, Project, and CPQ Subscriptions
     *
     *  @args           :   List<Event> events
     *
     *  @return         :   void
     * 
     * @revision Log    :   Created - Victor Hanson - 08/07/2019 - CR-20190204-12863
     **/
    @future
    public static void populateNoContact_future(String jsonString_eventList) {
        
        List<Event> eventsToUpdate = (List<Event>) JSON.deserialize(jsonString_eventList, List<Event>.class);
        if (eventsToUpdate.size() > 0) {
            Util.bypassAllTriggers = true;
            update eventsToUpdate;
            Util.bypassAllTriggers = false;
        }
    }
    
    /**
     * @description     :   Returns a map<whatId, contactId> so we can correctly populate the WhoId field on Events with no contact
     *
     *  @args           :   List<Event> events
     *
     *  @return         :   void
     * 
     * @revision Log    :   Created - Victor Hanson - 08/07/2019 - CR-20190204-12863
     **/
    public static Map<String, Id> getNoContactRecords(Map<String, String> whatIdToAccountIdMap) {
        
        //holds account to id contact map that will be returned
        Map<String, Id> whatIdToContactMap = new Map<String, Id>();
        
        //holds the map of <accountId, contactId>
        Map<Id, Id> acctIdToContactIdMap = new Map<Id, Id>();
        
        //get the list of account ids
        List<Id> acctIds = whatIdToAccountIdMap.values();
        
        //list of Contacts to insert
        List<Contact> contactsToInsert = new List<Contact>();
        
        //get all the accounts w/the no contact record
        List<Account> acctsWithContact = [SELECT Id, Entity__c, Primary_Address_Line_1__c, Primary_City__c, Primary_State_Province__c,
                                          Primary_Postal_Code__c, Primary_Country__c, RecordTypeId, ParentId,
                                          (SELECT Id FROM Contacts WHERE Contact_Status__c = :Constants.CONTACT_STATUS_INACTIVE_NO_CONTACT) 
                                          FROM Account WHERE Id IN :acctIds  ];
        
        //verify each acct has a No Contact record.  if not, add to the list of records to be created
        for (Account acct : acctsWithContact) {
            
            //if the 'no contact' record exists, add to the map
            if (acct.Contacts != null && acct.Contacts.size() > 0) {
                acctIdToContactIdMap.put(acct.Id, acct.Contacts[0].Id);
            }
            else { //if contact doesn't exist, add to creation list
                
                //Variable for Account Id 
                Id accId = acct.Id;
                
                //Modified By - Dipesh Gupta - 10/16/2019 - CR-20191014-13416 - added check to alter the logic for Graduate Education RT
                //Check for parent id and record type 
                if(acct.RecordTypeId == Constants.Account_Royall_Graduate_RT_ID && String.isNotBlank(acct.ParentId))
                    accId = acct.parentId;
                    
                contactsToInsert.add(new Contact(AccountId = accId,
                                                 Entity__c = acct.Entity__c,
                                                 RecordTypeId = Constants.CONTACT_RT_ID_EMPLOYEE,
                                                 Contact_Status__c = Constants.CONTACT_STATUS_INACTIVE_NO_CONTACT,
                                                 LastName='[No Contact]',
                                                 Primary_Address_Line_1__c = acct.Primary_Address_Line_1__c,
                                                 Primary_City__c = acct.Primary_City__c,
                                                 Primary_State_Province__c = acct.Primary_State_Province__c,
                                                 Primary_Postal_Code__c = acct.Primary_Postal_Code__c,
                                                 Primary_Country__c = acct.Primary_Country__c,
                                                 Description='Auto-generated so Events can be linked to a Institution when the Event does not contain a Contact')
                                    );
            }
        }
        
        //check for contacts to insert
        if (contactsToInsert.size() > 0) {
            
            //bypass triggers and insert the Contact
            Util.bypassAllTriggers = true;
            insert contactsToInsert;
            Util.bypassAllTriggers = false;
            
            //loop through each Contact, adding them to the map
            for (Contact c : contactsToInsert)
                acctIdToContactIdMap.put(c.AccountId, c.Id);
        }
        
        //connect each WhatId to the corresponding Contact
        for (String whatId : whatIdToAccountIdMap.keySet()) {
            //get the account id
            Id acctId = whatIdToAccountIdMap.get(whatId);
            
            //get the contact id
            Id contactId = acctIdToContactIdMap.get(acctId);
            
            //verify the contactId is populated, then add to map
            if (contactId != null)
                whatIdToContactMap.put(whatId, contactId);
        }
        
        return whatIdToContactMap;
    }
    
    /**
     *  @description    :   This method is used to populate 'First Credited Event Date' on Opportunity object
     *
     *  @args           :   List<Event> newEvents, Map<Id, Event> oldMapEvents
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 08/12/2019 - CR-20190429-13049 - Created By Dipesh Gupta.
     *                  
     **/  
    public static void populateFirstCreditedEventDateOnOpportunity(List<Event> newEvents, Map<Id, Event> oldMapEvents){
        
        List<Opportunity> opportunityToBeUpdated = new List<Opportunity>();
        
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the event lists
        for(Event eve : newEvents) {
            
            //Check for the Activity Date and for Opportunity Object
            if(eve.ActivityDate != null && eve.WhatId != null && eve.WhatId.getSObjectType() == Opportunity.sObjectType){
                
                //Insert/Update use case
                if(oldMapEvents == null ||
                   (oldMapEvents != null  && 
                    (oldMapEvents.get(eve.Id).ActivityDate !=  eve.ActivityDate || oldMapEvents.get(eve.Id).WhatId !=  eve.WhatId || oldMapEvents.get(eve.Id).Credit__c != eve.Credit__c))) 
                    setOppIds.add(eve.WhatId);
                
            }
        }
        
        //Check for the size of set. 
        if(setOppIds.size() > 0 ) {
            
            //Loop on the Event to retrive the first event where Credit is greater then zero
            for(Event  even : [Select WhatId, ActivityDate From Event WHERE WhatId IN : setOppIds AND Credit__c > 0 ORDER BY ActivityDate ASC LIMIT 1])
                opportunityToBeUpdated.add(new Opportunity(Id = even.WhatId , First_Credited_Event_Date__c = even.ActivityDate ));
            
            
            //Check for the list size. 
            if(opportunityToBeUpdated.size() > 0)
                update opportunityToBeUpdated;
        }
    }
    
    /**
     *  @description    :   This method is used to populate Project fields as mentioned below:-
     *                      1. Last Executive Update--> When Event Type is 'In Person Visit' or 'Phone Appointment' and 'Subject' 
                                                        contains 'Executive Update' then populate it with most recent Activity Date 
     *                      2. Last Internal Check-in-->When Event Purpose is 'Internal Discussion' then populate it with most recent
                                                        Activity Date
     *
     *  @args           :   List<Event>, Map<Id, Event>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 01/22/2020 - CR-20200102-13583 - Added new Method 'populateProjectFields'
     *                  :   V_1.1 - Modified By - Neha Sharma - 10/21/2020 - CR-20200602-14130 - Comment out the criteria of Event Type
                                                              ('In Person Visit','Phone Appointment) from query as well as condition
     *                  
    **/   
    public static void populateProjectFields(List<Event> newEvents, Map<Id, Event> oldMapEvents) {
        
        
        //Set to hold the Project Ids
        Set<Id> setProjectIds = new Set<Id>();
        
        //Map to hold the projects
        Map<Id, Project__c> mapProjects = new Map<Id, Project__c>();
        
        //Member Success Record Type Id 
        Id memberSuccessRTId = Util.RecordTypeId('Event', 'Member Success');
        
        //Check for the Related To Field on tasks.
        for(Event e : newEvents != null ? newEvents : oldMapEvents.values()) 
        {
            //Check for the Activity Date and for Project Object
            if(e.ActivityDate != null && e.WhatId != null && e.WhatId.getSObjectType() == Project__c.sObjectType ){
                
                //Check for insert Update case
                if(newEvents != null && (oldMapEvents == null || (oldMapEvents != null && 
                                            (oldMapEvents.get(e.Id).ActivityDate != e.ActivityDate
                                             || oldMapEvents.get(e.Id).Subject != e.Subject 
                                             || oldMapEvents.get(e.Id).Event_Type__c != e.Event_Type__c 
                                             || oldMapEvents.get(e.Id).Event_Purpose__c != e.Event_Purpose__c 
                                             || oldMapEvents.get(e.Id).WhatId != e.WhatId 
                                             || oldMapEvents.get(e.Id).RecordTypeId != e.RecordTypeId))))
                {
                    
                    setProjectIds.add(e.WhatId);
                    mapProjects.put(e.WhatId, new Project__c(Id = e.WhatId,Last_Executive_Update__c = null, Last_Internal_Check_In__c = null));
                    
                    if(oldMapEvents != null && oldMapEvents.get(e.Id).WhatId != e.WhatId 
                       && oldMapEvents.get(e.Id).WhatId.getSObjectType() == Project__c.sObjectType){
                           
                           setProjectIds.add(oldMapEvents.get(e.Id).WhatId);
                           mapProjects.put(oldMapEvents.get(e.Id).WhatId, new Project__c(Id = oldMapEvents.get(e.Id).WhatId, Last_Executive_Update__c = null, Last_Internal_Check_In__c = null));
                           
                       }
                   
                }
                
                //Check for delete case
                if(newEvents == null && oldMapEvents != null) {
                    setProjectIds.add(oldMapEvents.get(e.Id).WhatId);
                    mapProjects.put(oldMapEvents.get(e.Id).WhatId, new Project__c(Id = oldMapEvents.get(e.Id).WhatId, Last_Executive_Update__c = null, Last_Internal_Check_In__c = null));
                }
                
            }
        }
        
        if(setProjectIds.size() > 0) 
        {
            
            //Map to hold the Project id with Date. Last Executive
            Set<Id> setProjectIdForLastExecutiveUpdate = new Set<Id>();
            
            //Map to hold the Project id with Date. Last Interaction Check Ins
            Set<Id> setProjectIdForLastInteractionCheckIns = new Set<Id>();
            
            //Modified By - Neha Sharma - 10/21/2020 - CR-20200602-14130 - Comment out the criteria of Event Type('In Person Visit','Phone Appointment) from query as well as condition
            //Get all Member success Events related to Tech Projects
            for(Event e : [SELECT Id, Subject, WhatId, ActivityDate, Event_Type__c, Event_Purpose__c 
                           FROM Event 
                           WHERE WhatId IN : setProjectIds 
                           AND What.RecordType.DeveloperName = 'SSC'
                           AND RecordTypeId =: memberSuccessRTId 
                           ORDER BY ActivityDate DESC])
            {
                
                //If Event Type is In Person Visit or Phone Appointment and Subject contains 'Executive Update' then populate  Last_Executive_Update__c with most recent Activity Date 
                if(!setProjectIdForLastExecutiveUpdate.contains(e.WhatId) 
                   && String.isNotBlank(e.Subject) 
                   && e.Subject.containsIgnoreCase('Executive Update')  
                   /*&& (e.Event_Type__c == 'In Person Visit' || e.Event_Type__c == 'Phone Appointment')*/ 
                   && e.ActivityDate < System.today()) 
                {
                    setProjectIdForLastExecutiveUpdate.add(e.WhatId);
                    mapProjects.get(e.WhatId).Last_Executive_Update__c = e.ActivityDate;
                }   
                
                //If event purpose is Internal Discussion then populate Last_Internal_Check_In__c with most recent Activity Date 
                if(!setProjectIdForLastInteractionCheckIns.contains(e.WhatId) 
                   && e.Event_Purpose__c == 'Internal Discussion' 
                   && e.ActivityDate < System.today()
                ) 
                {
                    setProjectIdForLastInteractionCheckIns.add(e.WhatId);
                    mapProjects.get(e.WhatId).Last_Internal_Check_In__c = e.ActivityDate;
                }
            }
            
            //Empty check on Map
            if(mapProjects.size() > 0 && mapProjects.values() != null && mapProjects.values().size() > 0) 
            {
                Util.ByPassAllTriggers = true; 
                update mapProjects.values();
                util.ByPassAllTriggers = false;
            }
        }
    }
    
    /**
     *  @description    :   Method to update the contact field Protocoled? (Sales) .The value should be true if there is any upcoming Sales event 
     *                      records tagged to the contact, and then remain true for 30 days after the date of that event.
     *                      The checkbox should be reverted to false if there is no longer an event or task matching the above criteria.
     * 
     *  @args           :   List<Event>, Map<Id, Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Mahendra Swarnkar - CR-20200122-13648. 
     **/
    public static void updateContactProtocoledField(List<Event> newEvents, Map<Id, Event> oldMapEvents) {
        
        //Get Record Type
        Id EventSalesRecordType = Util.RecordTypeId('Event', 'Sales');
        
        //List to update contact
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Set of Event Ids
        Set<Id> setEventIds = new Set<Id>();
        
        for(Event evnt : newEvents){
           
            //check for insert and update case
            if(evnt.WhoId != null && evnt.WhoId.getSObjectType() == Contact.sObjectType && (evnt.RecordTypeId == EventSalesRecordType   ) 
               && evnt.EndDateTime != null /*&& evnt.Who.Type == 'Contact'*/ 
               && (oldMapEvents == null  
                || (evnt.EndDateTime != oldMapEvents.get(evnt.Id).EndDateTime 
                ||  evnt.WhoId != oldMapEvents.get(evnt.Id).WhoId
                ||  evnt.Event_Type__c != oldMapEvents.get(evnt.Id).Event_Type__c
                ||  evnt.Event_Purpose__c != oldMapEvents.get(evnt.Id).Event_Purpose__c
                ||  evnt.Cancelled_Did_Not_Occur__c != oldMapEvents.get(evnt.Id).Cancelled_Did_Not_Occur__c ))) {
                
               //mapContactsToUpdate.put(evnt.WhoId, new Contact(Id = evnt.WhoId, Protocoled_Sales__c = false));
                    setEventIds.add(evnt.Id);
                /*if(!System.isBatch()){
                    if(oldMapEvents != null && evnt.WhoId != oldMapEvents.get(evnt.Id).WhoId){
                        
                        //mapContactsToUpdate.put(oldMapEvents.get(evnt.Id).WhoId, new Contact(Id = oldMapEvents.get(evnt.Id).WhoId,  Protocoled_Sales__c = false));
                    }
                }*/
                
            }  
        }
        
        if(setEventIds.size() > 0){
            
            //Set of contact ids
            List<Id> contactIds = new List<Id>();
            
            //Loop over EventWhoRelation   
            for(EventWhoRelation evtWhoRel: [SELECT RelationId, EventId FROM EventWhoRelation WHERE EventId IN: setEventIds ]){
                contactIds.add(evtWhoRel.RelationId);
            }
            
            if(contactIds.size() > 0){
                fututeUpdateContactProtocoledField(contactIds);
            }
        }
    }
    
    @future
    public static void fututeUpdateContactProtocoledField(List<Id> listContactIds) {
        
        Set<Id> contactIds = new Set<Id>();
        contactIds.addAll(listContactIds);
        
        if(contactIds.size() > 0){
            GenericEventTaskClass.genericUpdateContactProtocoledField(contactIds);
        }
    }
    
    
    /**
     *  @description    :   This method is used to populate "CT: Date PA Happens" field on Subscription Periods
     *   
     *  @args           :   List<Event> newEvents, Map<Id, Event> oldMapEvents
     *
     *  @return         :   void
     *
     *  @Version        :   V_4.05 - Modified By - Mahendra Swarnkar - 06/04/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
    **/
    
    public static void populateCTFieldsOnSubsciptionPeriod(List<Event> newEvents, Map<Id, Event> oldMapEvents)
    {
        //Set to hold the Subscription Periods Ids
        Set<Id> setSubscriptionPeriodIds = new Set<Id>();
        
        //Map to hold the Id with Subscription Periods
        Map<Id, Subscription_Period__c> mapOfSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Check for the Related To Field
        for(Event event : newEvents != null ? newEvents : oldMapEvents.values()) 
        {
            //Check for the Start Date and for Subscription Periods Object
            if(event.StartDateTime != null && event.WhatId != null && event.WhatId.getSObjectType() == Subscription_Period__c.sObjectType && event.RecordTypeId == util.RecordTypeId('Event', 'Account Management'))
            {
                //Check for insert or update case
                if(newEvents != null && (oldMapEvents == null || (oldMapEvents != null && 
                                                                  (oldMapEvents.get(event.Id).StartDateTime != event.StartDateTime
                                                                   || oldMapEvents.get(event.Id).Event_Type__c != event.Event_Type__c 
                                                                   || oldMapEvents.get(event.Id).Event_Purpose__c != event.Event_Purpose__c 
                                                                   || (oldMapEvents.get(event.Id).WhatId != event.WhatId
                                                                      && oldMapEvents.get(event.Id).WhatId.getSObjectType() == Subscription_Period__c.sObjectType)
                                                                   || oldMapEvents.get(event.Id).RecordTypeId != event.RecordTypeId))))
                {
                    setSubscriptionPeriodIds.add(event.WhatId);
                    mapOfSubscriptionPeriods.put(event.WhatId, new Subscription_Period__c(Id = event.WhatId, CT_Date_PA_Happens__c = null, 
                                                                                          CT_Date_Visit_Happens__c = null));
                    if(oldMapEvents != null && oldMapEvents.get(event.Id).WhatId != event.WhatId){
                        
                        setSubscriptionPeriodIds.add(oldMapEvents.get(event.Id).WhatId);
                        mapOfSubscriptionPeriods.put(oldMapEvents.get(event.Id).WhatId, new Subscription_Period__c(Id = oldMapEvents.get(event.Id).WhatId, CT_Date_PA_Happens__c = null, 
                                                                                              CT_Date_Visit_Happens__c = null));
                    }
                }
                
                 //Check for delete case
                if(newEvents == null && oldMapEvents != null) 
                {
                    setSubscriptionPeriodIds.add(oldMapEvents.get(event.Id).WhatId);
                    mapOfSubscriptionPeriods.put(oldMapEvents.get(event.Id).WhatId, new Subscription_Period__c(Id = oldMapEvents.get(event.Id).WhatId, 
                                                                                                               CT_Date_PA_Happens__c = null, 
                                                                                                               CT_Date_Visit_Happens__c = null));
                }
            }
        }
        
        if(setSubscriptionPeriodIds.size() > 0)
        {
            Map<Id, Subscription_Period__c> subscriptionMap = new Map<Id,Subscription_Period__c>([SELECT Id, CT_Date_Passed__c FROM
                                                                                                  Subscription_Period__c
                                                                                                  WHERE Id IN : setSubscriptionPeriodIds
                                                                                                  AND CT_Date_Passed__c != null]);
            Date cTDatePassed;
            for(Event e : [SELECT Id, WhatId, StartDateTime, Event_Type__c, Event_Purpose__c 
                           FROM Event 
                           WHERE WhatId IN : setSubscriptionPeriodIds 
                           AND RecordType.DeveloperName = 'Core_AM'
                           AND (
                               Event_Type__c =: 'Phone Appointment'
                               OR Event_Type__c =: 'In Person Visit'
                           )
                           AND Event_Purpose__c =: 'Chairman\''+'s Team'
                           AND Cancelled_Did_Not_Occur__c = false
                           ORDER BY StartDateTime  DESC])
            {
                if(subscriptionMap.size() > 0 && subscriptionMap.containsKey(e.WhatId) && subscriptionMap.get(e.WhatId).CT_Date_Passed__c != null) {
                    Date cTDatePass = subscriptionMap.get(e.WhatId).CT_Date_Passed__c;
                    //if(cTDatePass == System.today()){
                    Date cTDatePassedStart = cTDatePass.addMonths(-1);
                    Date cTDatePassedEnd = cTDatePass.addMonths(12);
                    //}  
                
                    if(e.StartDateTime > cTDatePassedStart && e.StartDateTime <= cTDatePassedEnd) {
                    
                        if(e.Event_Type__c == 'Phone Appointment')
                            mapOfSubscriptionPeriods.get(e.WhatId).CT_Date_PA_Happens__c = Date.valueOf(e.StartDateTime);
                        
                        if(e.Event_Type__c == 'In Person Visit' )
                            mapOfSubscriptionPeriods.get(e.WhatId).CT_Date_Visit_Happens__c = Date.valueOf(e.StartDateTime);    
                    }
                }
            }
        }
        
        if(mapOfSubscriptionPeriods.size() > 0) {
            Util.BypassAllTriggers = true;
            update mapOfSubscriptionPeriods.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *  @description    :  Update the opportunity field on the basis of event
     * 
     *  @args           :   List<Event>, Map<Id, Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Abhinav Sharma - CR-20200420-13963. 
     **/
    public static void populateOpportunityFields(List<Event> newEvents, Map<Id, Event> oldMapEvents) {
        
        //Set to hold the Opportunity Ids
        Set<Id> setOpporunityIds = new Set<Id>();
        
        //Map to hold the opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        
        //Sales Record Type Id 
        Id salesRTId = Util.RecordTypeId('Event', 'Sales');
        
        //Check for the Related To Field on event.
        for(Event e : newEvents != null ? newEvents : oldMapEvents.values()) 
        {
            //Check for the Activity Date and for Project Object
            if(e.StartDateTime != null && e.WhatId != null && e.WhatId.getSObjectType() == Opportunity.sObjectType ){
                
                //Check for insert Update case
                if(newEvents != null && (oldMapEvents == null || (oldMapEvents != null && 
                                            (oldMapEvents.get(e.Id).StartDateTime != e.StartDateTime
                                             || oldMapEvents.get(e.Id).Event_Type__c != e.Event_Type__c 
                                             || oldMapEvents.get(e.Id).Event_Purpose__c != e.Event_Purpose__c 
                                             || oldMapEvents.get(e.Id).WhatId != e.WhatId 
                                             || oldMapEvents.get(e.Id).Cancelled_Did_Not_Occur__c != e.Cancelled_Did_Not_Occur__c 
                                             || oldMapEvents.get(e.Id).RecordTypeId != e.RecordTypeId))))
                {
                    
                    setOpporunityIds.add(e.WhatId);
                    mapOpportunities.put(e.WhatId, new Opportunity(Id = e.WhatId,Initial_Web_Visit_Date__c = null, Initial_Visit_Date_Ipv_Web__c = null,  Initial_Event_Type__c = ''));
                    
                    if(oldMapEvents != null && oldMapEvents.get(e.Id).WhatId != e.WhatId 
                       && oldMapEvents.get(e.Id).WhatId.getSObjectType() == Opportunity.sObjectType){
                           
                           setOpporunityIds.add(oldMapEvents.get(e.Id).WhatId);
                           mapOpportunities.put(oldMapEvents.get(e.Id).WhatId, new Opportunity(Id = oldMapEvents.get(e.Id).WhatId, Initial_Web_Visit_Date__c = null, Initial_Visit_Date_Ipv_Web__c = null,  Initial_Event_Type__c = ''));
                           
                       }
                }
                
                //Check for delete case
                if(newEvents == null && oldMapEvents != null) {
                    setOpporunityIds.add(oldMapEvents.get(e.Id).WhatId);
                    mapOpportunities.put(oldMapEvents.get(e.Id).WhatId, new Opportunity(Id = oldMapEvents.get(e.Id).WhatId, Initial_Web_Visit_Date__c = null, Initial_Visit_Date_Ipv_Web__c = null,  Initial_Event_Type__c = ''));
                }
                
            }
        }
        
        if(setOpporunityIds.size() > 0) {
            
            //set to hold the opportunity id with 
            Set<Id> setOppIdForIWVDate = new Set<Id>();
            
            //set to hold the opportunity id with 
            Set<Id> setOppIdForIvporWebDate = new Set<Id>();
            
            Set<Id> setOppIdForIET = new Set<Id>();
            
            //Get all sales Events related to opportunity
            for(Event e : [SELECT Id, Subject, WhatId, Cancelled_Did_Not_Occur__c,StartDateTime, Event_Type__c, Event_Purpose__c FROM Event 
                           WHERE WhatId IN : setOpporunityIds 
                           AND RecordTypeId =:  salesRTId
                           AND Event_Purpose__c = : 'Initial' 
                           AND Event_Type__c IN ('In Person Visit', 'Phone Appointment', 'Web Visit')
                           ORDER BY StartDateTime ASC])
            {
                
                //If Event Type is Web Visit and Event purpose is 'Initial' and Canceled/Did Not Occur = false then populate  Initial_Web_Visit_Date__c with most recent start Date 
                if(!setOppIdForIWVDate.contains(e.WhatId) && e.Event_Type__c == 'Web Visit' && e.Event_Purpose__c == 'Initial' && e.Cancelled_Did_Not_Occur__c == false) {
                       setOppIdForIWVDate.add(e.WhatId);
                       
                       mapOpportunities.get(e.WhatId).Initial_Web_Visit_Date__c = Date.valueOf(e.StartDateTime);

                   }   
                
                //If Event Type is 'Web Visit' or 'In Person Visit' and Event purpose is 'Initial' and Canceled/Did Not Occur = false then populate  Initial_Visit_Date_Ipv_Web__c with most recent start Date 
                if(!setOppIdForIvporWebDate.contains(e.WhatId) && 
                   (e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') && e.Event_Purpose__c == 'Initial' && e.Cancelled_Did_Not_Occur__c == false) {
                    
                    setOppIdForIvporWebDate.add(e.WhatId);
                    
                    mapOpportunities.get(e.WhatId).Initial_Visit_Date_Ipv_Web__c = Date.valueOf(e.StartDateTime);
                }
                
                
                //If Event Type is 'Web Visit' or 'In Person Visit' or 'Phone Appointment' and Event purpose is 'Initial' and Canceled/Did Not Occur = false then populate  Initial_Event_Type__c with most recent Event type  
                if(!setOppIdForIET.contains(e.WhatId) && 
                   (e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit' || e.Event_Type__c == 'Phone Appointment') && e.Event_Purpose__c == 'Initial' && e.Cancelled_Did_Not_Occur__c == false) {
                    
                    setOppIdForIET.add(e.WhatId);
                    
                    mapOpportunities.get(e.WhatId).Initial_Event_Type__c = e.Event_Type__c;
                }
            }
            
            //Empty check on Map
            if(mapOpportunities.size() > 0 && mapOpportunities.values() != null && mapOpportunities.values().size() > 0) {
             
                //Bypassing the triggers.
                Util.ByPassAllTriggers = true; 
                update mapOpportunities.values();
                util.ByPassAllTriggers = false;
            }
        }
    }
     
   /**
     *  @description    :  On insert/Update/Delete of event update the count on opportunity field on the basis of event
     * 
     *  @args           :   List<Event>, Map<Id, Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Neha Sharma - CR-20210202-14862. 
     **/
    public static void populateCountOnOpportunityFields(List<Event> newEvents, Map<Id, Event> oldMapEvents) {
        
        Set<String> setOfEventType = new Set<String>{'Web Visit','Phone Appointment','In Person Visit'};
        //Set to hold the Opportunity Ids
        Set<Id> setOpporunityIds = new Set<Id>();
        
        //Map to hold the opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        
        //Check for the Related To Field on event.
        for(Event e : newEvents != null ? newEvents : oldMapEvents.values()) 
        {
            //Check for the Activity Date and for Project Object
            if(e.StartDateTime != null && e.WhatId != null && e.WhatId.getSObjectType() == Opportunity.sObjectType ){
                
                //Check for insert Update case
                if(newEvents != null && (oldMapEvents == null || (oldMapEvents != null && 
                                            ( oldMapEvents.get(e.Id).Event_Type__c != e.Event_Type__c 
                                             || oldMapEvents.get(e.Id).WhatId != e.WhatId 
                                             || oldMapEvents.get(e.Id).endDate!= e.endDate
                                             || oldMapEvents.get(e.Id).EndDateTime != e.EndDateTime
                                             || oldMapEvents.get(e.Id).Cancelled_Did_Not_Occur__c != e.Cancelled_Did_Not_Occur__c))))
                {
                    
                    setOpporunityIds.add(e.WhatId);
                    mapOpportunities.put(e.WhatId, new Opportunity(Id = e.WhatId,Total_Completed_Activities__c = 0, Total_Upcoming_Activities__c = 0,  
                                                                   Total_In_Person_Activities__c = 0, Total_Web_Activities__c = 0,
                                                                   Total_Phone_Activities__c = 0, Total_Activities__c = 0));
                    
                    if(oldMapEvents != null && oldMapEvents.get(e.Id).WhatId != e.WhatId 
                       && oldMapEvents.get(e.Id).WhatId.getSObjectType() == Opportunity.sObjectType){
                           
                           setOpporunityIds.add(oldMapEvents.get(e.Id).WhatId);
                           mapOpportunities.put(oldMapEvents.get(e.Id).WhatId, new Opportunity(Id = oldMapEvents.get(e.Id).WhatId,Total_Completed_Activities__c = 0, Total_Upcoming_Activities__c = 0,  
                                                                                               Total_In_Person_Activities__c = 0, Total_Web_Activities__c = 0,
                                                                                               Total_Phone_Activities__c = 0, Total_Activities__c = 0));
                           
                       }
                }
                
                //Check for delete case
                if(newEvents == null && oldMapEvents != null) {
                    setOpporunityIds.add(oldMapEvents.get(e.Id).WhatId);
                    mapOpportunities.put(oldMapEvents.get(e.Id).WhatId, new Opportunity(Id = oldMapEvents.get(e.Id).WhatId,Total_Completed_Activities__c = 0, Total_Upcoming_Activities__c = 0,  
                                                                                                Total_In_Person_Activities__c = 0, Total_Web_Activities__c = 0,
                                                                                                Total_Phone_Activities__c = 0, Total_Activities__c = 0));
                }
                
            }
        }
        
        if(setOpporunityIds.size() > 0) {
          
            //Get all sales Events related to opportunity
            for(Event e : [SELECT Id, Subject, WhatId, Cancelled_Did_Not_Occur__c,EndDate, Event_Type__c, Event_Purpose__c
                           FROM Event 
                           WHERE WhatId IN : setOpporunityIds 
                           AND  Event_Type__c IN: setOfEventType
                           AND Cancelled_Did_Not_Occur__c = False
                           ORDER BY StartDateTime ASC])
            {

                if(setOfEventType.contains(e.Event_Type__c) )
                { 
                     mapOpportunities.get(e.WhatId).Total_Activities__c = mapOpportunities.get(e.WhatId).Total_Activities__c + 1;
                    
                    if(e.EndDate < system.today()) {
                        mapOpportunities.get(e.WhatId).Total_Completed_Activities__c = mapOpportunities.get(e.WhatId).Total_Completed_Activities__c + 1;
                    }
                    
                    if(e.EndDate > system.today()) {
                        mapOpportunities.get(e.WhatId).Total_Upcoming_Activities__c = mapOpportunities.get(e.WhatId).Total_Upcoming_Activities__c+1;
                    } 
                }
 
                if( e.Event_Type__c == 'In Person Visit') {
                    mapOpportunities.get(e.WhatId).Total_In_Person_Activities__c = mapOpportunities.get(e.WhatId).Total_In_Person_Activities__c + 1;
                }
                
                if( e.Event_Type__c == 'Web Visit') {
                    mapOpportunities.get(e.WhatId).Total_Web_Activities__c = mapOpportunities.get(e.WhatId).Total_Web_Activities__c + 1;
                }

                if( e.Event_Type__c == 'Phone Appointment') {
                    mapOpportunities.get(e.WhatId).Total_Phone_Activities__c = mapOpportunities.get(e.WhatId).Total_Phone_Activities__c + 1;
                }
  
            }
            
            //Empty check on Map
            if(mapOpportunities.size() > 0 && mapOpportunities.values() != null && mapOpportunities.values().size() > 0) {
             
                //Bypassing the triggers.
                Util.ByPassAllTriggers = true; 
                update mapOpportunities.values();
                util.ByPassAllTriggers = false;
            }
        }
    } 
    
     /**
     *  @description    :   Create the membershipMtm record on insert of SYNDICATED_RESEARCH event
     * 
     *  @args           :   Map<Id,Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - By neha Sharma - 04/16/2021 - CR-20201021-14627
     */
    public static void createMembershipMtMRecords(Map<Id, Event> newEvents,Map<Id,Event> oldEvents) {
        
        //Set to hold event Ids which should be processed
        Map<Id,Event> mapOfEvents = new Map<Id,Event>();
        
        //Map to hold Research Study Id by Event Id 
        Map<Id, Id> eventIdByResearchStudyId = new Map<Id, Id>();
        
        //Map to hold Contact Id by event Id
        Map<Id, Id> contactIdByEventId = new Map<Id, Id>();
         
        //Map to hold Contact  and institution details
        Map<Id, Id> contactAccountMap = new Map<Id, Id>();
        
        //Map to hold Rules by Research Study Ids
        Map<Id, List<Event_Rule__c>> rulesByResearchStudyIds = new Map<Id, List<Event_Rule__c>>();
        
        //Map to hold Memberships by Institution
        Map<String, List<Membership__c>> membershipsByInstitutionIds = new Map<String, List<Membership__c>>();
        
        //Map to hold Membership MtM records by Membership & rule Ids
        Map<String, Membership_MtM__c> membershipsMtMByMembershipAndRegistrationIds = new Map<String, Membership_MtM__c>();
        
        List<Event> eventToBeUpdated = new List<Event>();
        
        Set<String> setOfMemberKeyContactRole = new Set<String>{'Key Contact','MPOC','Team'};
        for(Event evnt : newEvents.values()){
            
            if(oldEvents != null && evnt.Status__c != oldEvents.get(evnt.Id).Status__c && evnt.WhatId != null && evnt.WhoId != null 
               && evnt.WhatId.getSObjectType() == Syndicated_Study__c.sObjectType 
               && evnt.Status__c == 'Completed')
            {
                mapOfEvents.put(evnt.Id,evnt);
            }
        }
        
        if(mapOfEvents.size() == 0)
            return;
        
        for(Event evnt : [Select Id, WhatId, WhoId 
                          From Event Where Id IN : mapOfEvents.keySet() 
                          AND WhoId != null AND WhatId != null
                          AND RecordtypeId =: constants.RECORD_TYPE_ID_SYNDICATED_RESEARCH]){
                                               
            eventIdByResearchStudyId.put(evnt.Id, evnt.WhatId);
            ContactIdByEventId.put(evnt.Id, evnt.WhoId);
        }
        
       
        //Block to get all related Rules and Programs
        if(eventIdByResearchStudyId.size() > 0){
            for(Event_Rule__c evtRule : [Select Id, Advisory_Event__c, Rule__r.Program__c,Research_Study__c From Event_Rule__c 
                                        Where Rule__r.Program__c != null 
                                        AND Research_study__c IN : eventIdByResearchStudyId.values()])
            {
                                   
                 if(!rulesByResearchStudyIds.containsKey(evtRule.Research_study__c)) 
                     rulesByResearchStudyIds.put(evtRule.Research_study__c, new List<Event_Rule__c>());
                 rulesByResearchStudyIds.get(evtRule.Research_study__c).add(evtRule);
            }
        }
                
         if(ContactIdByEventId.size() > 0){
             for(Contact con : [Select Id,AccountId from Contact 
                                where Id IN : ContactIdByEventId.values()])
             {
                 if(!contactAccountMap.containsKey(con.Id))
                     contactAccountMap.put(con.Id,con.accountId);
             }
         }
                 
        //Block to get all related Memberships and Programs
        if(contactAccountMap.size() > 0){
            for(Membership__c membership : [Select Id, (Select Id,Contact_Status__c,Contact__c from Membership_Key_Contacts__r where Role__c IN: setOfMemberKeyContactRole
                                                        AND Key_Contact_Status__c = 'Active' AND Contact__c IN: contactAccountMap.Keyset()), 
                                           Program__c, Active_Contract_Main_Contact__c,Membership_Status__c, Account_Name__c From Membership__c Where 
                                           Program__c != null AND Membership_Status__c LIKE 'Member%' and Account_Name__c IN : contactAccountMap.values()])
            {
                If(membership.Membership_Key_Contacts__r.size() > 0)
                {
                    if(!membershipsByInstitutionIds.containsKey(membership.Account_Name__c + '-'+ membership.Membership_Key_Contacts__r[0].Contact__c))
                        membershipsByInstitutionIds.put(membership.Account_Name__c + '-'+membership.Membership_Key_Contacts__r[0].Contact__c, new List<Membership__c>());
                    membershipsByInstitutionIds.get(membership.Account_Name__c + '-'+ membership.Membership_Key_Contacts__r[0].Contact__c).add(membership);
                }
            }
        }
        
        
        if(mapOfEvents.values().size() > 0){
        List<Event>  eventList = checkMembershipMTMExistForEvent(mapOfEvents.values());
            
             //Block to create Membership MtM records
             for(Event  evnt : eventList){
             	//boolean isEventOccur = false; 
             	Id accountId = contactAccountMap?.get(evnt.WhoId);
             	Id researchStudyId = evnt.WhatId != null ? evnt.WhatId  : null;
             	String memberkey = (accountId + '-'+ evnt.WhoId ).trim();
            
            	if(accountId != null && membershipsByInstitutionIds.containskey(memberkey) && researchStudyId != null && rulesByResearchStudyIds.containsKey(researchStudyId)){
                
                    for(Membership__c membership : membershipsByInstitutionIds.get(memberkey)){
                    	for(Event_Rule__c evtRule : rulesByResearchStudyIds.get(researchStudyId)){
                    	    if(membership.Program__c == evtRule.Rule__r.Program__c){
                            	membershipsMtMByMembershipAndRegistrationIds.put(membership.Id+''+researchStudyId, new Membership_MtM__c(Membership__c = membership.Id,Event_Id__c =  evnt.Id,
                                                                                                                                     	 Research_Study__c = evnt.whatId,Contact_Name__c = evnt.WhoId));
                            	break;
                            }
                        
                    	}
                    }
                
            	}
            }
        }
        
        if(membershipsMtMByMembershipAndRegistrationIds.size() > 0){
            Util.ByPassAllTriggers = true;
            insert membershipsMtMByMembershipAndRegistrationIds.values();
            Util.ByPassAllTriggers = false;
        }       
        
    }
    
     /**
     *  @description    :   This method to check membership record already exists on Research Study event 
     * 
     *  @args           :   Map<Id,Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - By neha Sharma - 04/16/2021 - CR-20201021-14627
     */
    public static List<Event> checkMembershipMTMExistForEvent(List<Event> newEvents){
        Set<Id> setOfResearchStudyIds = new Set<Id>();
        Set<Id> setOfContactIds = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        Set<String> eventPurpose = new Set<String>();
        List<Event> eventList = new List<Event>();
        Map<Id,List<membership_MTM__c>> mapOfMembershipMTM = new Map<Id,List<membership_MTM__c>>();
        Map<string,event> mapOfEvent = new map<string,Event>();
        if(newEvents.size() > 0){
            for(Event eve : newEvents){
                setOfResearchStudyIds.add(eve.WhatId);
                setOfContactIds.add(eve.WhoId);
                eventIds.add(eve.Id);
                eventPurpose.add(eve.Event_Purpose__c);
            }
            
            if(setOfContactIds.size() > 0 && setOfResearchStudyIds.size() > 0){
               for(Membership_MTM__c mtm : [Select Id,Contact_Name__c,Event_Id__c,membership__c,Research_Study__c from membership_MTM__c
                                            where Contact_Name__c IN: setOfContactIds AND Research_Study__c IN: setOfResearchStudyIds])
               {
                   if(!mapOfMembershipMTM.containsKey(mtm.Contact_Name__c)){
                       mapOfMembershipMTM.put(mtm.Contact_Name__c,new List<Membership_MTM__c>{});
                   }
                   mapOfMembershipMTM.get(mtm.Contact_Name__c).add(mtm);
               }
            }
            if(setOfResearchStudyIds.size() > 0){
                for(Event evnt : [Select Id, WhatId, WhoId ,StartDateTime,EndDateTime,
                                  Event_Purpose__c,Event_Type__c,ActivityDate
                                  From Event Where WhoId != null
                                  AND Event_Purpose__c IN : eventPurpose
                                  AND WhatId != null and WhatId IN: setOfResearchStudyIds 
                                  AND RecordtypeId =: constants.RECORD_TYPE_ID_SYNDICATED_RESEARCH 
                                  AND  WhoId IN : setOfContactIds ORDER BY Createddate ASC])
                {
                    String startdate = String.valueOf(evnt.StartDateTime);
                    String enddate = String.valueOf(evnt.EndDateTime);
                    String ActivityDate = String.valueOf(evnt.ActivityDate);
                    if(!mapOfEvent.containsKey(ActivityDate+'-'+startdate+'-'+enddate+'-'+evnt.WhoId+'-'+evnt.WhatId+'-'+evnt.Event_Purpose__c+'-'+evnt.Event_Type__c))
                    {
                        boolean mtmExists = false;
                        boolean createMTM =  false;
                        if(mapOfMembershipMTM.containsKey(evnt.whoId)){
                            for(Membership_MTM__c membershipMTM : mapOfMembershipMTM.get(evnt.whoId))
                            {
                               if(membershipMTM.event_Id__c == evnt.Id)
                               {
                                   mtmExists = true;
                               }
                            } 
                        }
                        if(eventIds.contains(evnt.Id) && mtmExists == false)
                        {
                           eventList.add(evnt); 
                           createMTM = true;
                        }
                       
                        if( mtmExists == true || createMTM == true)
                        {
                        	mapOfEvent.put(ActivityDate+'-'+startdate+'-'+enddate+'-'+evnt.WhoId+'-'+evnt.WhatId+'-'+evnt.Event_Purpose__c+'-'+evnt.Event_Type__c,evnt);
                        }
                     }
                }
            }
        }
        return eventList;
    }
    
     /**
     *  @description    :   delete the membershipMtm record on delete of SYNDICATED_RESEARCH event
     * 
     *  @args           :   List<Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - By neha Sharma - 04/16/2021 - CR-20201021-14627 
     **/
    public static void deleteMembershipMtMRecords(List<Event> newEvents , Map<Id,Event> oldMapEvents) {
       
        //Map to hold Contact Id by event Id
        Map<Id, Id> contactIdByEventId = new Map<Id, Id>();
        
        Map<Id,Id> researchStudyWithEventId = new Map<Id,Id>();
        
        List<Membership_MtM__c> listOfMembershipMtm = new List<Membership_MtM__c>();
        
        if(newEvents == null)
        {
            for(Event evnt : oldMapEvents.values()){
                
                if(evnt.WhatId != null && evnt.WhoId != null 
                   && evnt.RecordtypeId == constants.RECORD_TYPE_ID_SYNDICATED_RESEARCH)
                {
                    ContactIdByEventId.put(evnt.Id, evnt.WhoId);
                    researchStudyWithEventId.put(evnt.Id, evnt.WhatId);
                }
            }
            
            if(ContactIdByEventId.size() > 0)
            {
                for(Membership_MtM__c membershipMtm : [Select Id,Contact_Name__c From Membership_MtM__c where 
                                                       Contact_Name__c IN: ContactIdByEventId.values()
                                                       ANd Event_Id__c IN: researchStudyWithEventId.keyset()])
                {
                    listOfMembershipMtm.add(membershipMtm);
                }
            }
        }

        if(listOfMembershipMtm.size() > 0){
            Util.ByPassAllTriggers = true;
            delete listOfMembershipMtm;
            Util.ByPassAllTriggers = false;
        }
        
    }

    /**
     *  @description    :  Send email notification
     * 
     *  @args           :   List<Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - By Pankaj - 04/16/2021 - CR-20210407-15063
     **/
    public static void sendEmailNotification(List<Event> newEvents) {
        
        //Set to hold the contact Ids
        Set<Id> setOfContactIds = new Set<Id> ();
        Set<Id> setOfReviewCallIds = new Set<Id> ();
        
        //Map to hold the eligible event records
        Map<Id, Event> mapEligibleEvent = new Map<Id, Event>();
        Id EVENT_RT_CXQASurvey = Schema.SObjectType.Event.getRecordTypeInfosByName().get('CX QA Survey').getRecordTypeId();
        for(Event evt: newEvents){
            if(evt.recordTypeId != null && evt.RecordTypeId == EVENT_RT_CXQASurvey && evt.WhatId != null && evt.WhoId != null){
                
                //Populate the mapEligibleEvent
                mapEligibleEvent.put(evt.Id, evt);
                
                //Check If Name field on event is populated with contact 
                if(evt.WhoId != null && evt.WhoId.getSObjectType() == Contact.sObjectType) {
                    setOfContactIds.add(evt.WhoId);
                }
                
                //Check If Name field on event is populated with Review Call
                if(evt.WhatId != null && evt.WhatId.getSObjectType() == Review_Call__c.sObjectType) {
                    setOfReviewCallIds.add(evt.WhatId);
                }
            }
            
        }
        
        //Check for the size
        if(mapEligibleEvent.size() > 0){
            
            Map<Id,Review_Call__c> mapReviewCall = (setOfReviewCallIds.size() > 0) ? new Map<Id,Review_Call__c>([Select Id, Name, Company_Attended_By_Rep__c,Company_Attended_By_Rep__r.Name From Review_Call__c Where Id IN: setOfReviewCallIds]) : new Map<Id,Review_Call__c>();
            Map<Id,Contact> mapContacts = (setOfContactIds.size() > 0) ? new Map<Id,Contact>([Select Id, Name, AccountId, Account.Name From Contact where Id IN: setOfContactIds]) : new Map<Id,Contact>();
                       
            //List of emails
            List<Messaging.SingleEmailMessage> listOfMail = new List<Messaging.SingleEmailMessage>();
            //Loop over the eligible events
            for(Event even : mapEligibleEvent.values()) {
                
                String companyAttendedByRep = (mapReviewCall != null && mapReviewCall.containsKey(even.whatId) && String.isNotBlank(mapReviewCall.get(even.whatId)?.Company_Attended_By_Rep__r?.Name)) ? mapReviewCall.get(even.whatId).Company_Attended_By_Rep__r.Name : '';
                String reviewCallName = (mapReviewCall != null && mapReviewCall.containsKey(even.whatId) && String.isNotBlank(mapReviewCall.get(even.whatId)?.Name)) ? mapReviewCall.get(even.whatId).Name : '';
                String accountName = (mapContacts != null && mapContacts.containsKey(even.WhoId) && String.isNotBlank(mapContacts.get(even.WhoId)?.Account?.Name)) ? mapContacts.get(even.WhoId).Account.Name : '';
                String contactName = (mapContacts != null && mapContacts.containsKey(even.WhoId) && String.isNotBlank(mapContacts.get(even.WhoId)?.Name)) ? mapContacts.get(even.WhoId).Name : '';                
                
                //List to hold the tooaddresses/Email address of the users for whom email to be sent 
                List<String> toAddresses = new List<String> ();
                
				for(String str : System.Label.Cappex_Customer_Survey_Results_Notification.split(',')){
					toAddresses.add(str);
				}
                
                
                //Create an Instance of Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //Set the TOO Addresses for the Email
                mail.setToAddresses(toAddresses);
                
                //Set email subject
                //String emailSub = 'Customer Satisfaction Survey Response Created for' + contactName;
                
                mail.setSubject('Customer Satisfaction Survey Response Created for '+reviewCallName);
                
                //Set email body
                String mailBody = 'Hello,<br/><br/>';
                mailBody += '<p>A new customer satisfaction survey response was collected from ' + contactName;
                mailBody += ' of ' + reviewCallName;
                mailBody +='. Here are the details of the response:</p>';
                mailBody += '<p>Rapport with Client Rep: '
                    + (even.My_Rapport_with_My_Cappex_Rep__c != null ? even.My_Rapport_with_My_Cappex_Rep__c : 0 ) + '</p>';
                mailBody = mailBody + '<p>My Rep\'s Knowledge: ' 
                    + (even.My_Rep_s_Knowledge__c != null ? even.My_Rep_s_Knowledge__c : 0) + '</p>';
                mailBody = mailBody + '<p>Net Promoter Score: '
                    + (even.Net_Promoter_Score__c !=  null ? even.Net_Promoter_Score__c : 0) + '</p>';
                mailBody = mailBody + '<p>Comments/Feedback: '
                    + (String.isNotBlank(even.Description)? even.Description: '') + '</p>';
                mailBody = mailBody + '<p>Respondent\'s Name: ' + contactName;
                mailBody = mailBody + '<p>Company Attended By (Rep): ' + companyAttendedByRep;
                mailBody = mailBody + '<p>Institution Name: ' + accountName + '</p>';
                
                mailBody += '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+even.Id+'">'
                    +'To view the Customer Satisfaction Survey Response, please click here: '+'</a></html>';
                
                //Set the Emails Body
                mail.setHtmlBody(mailBody);
                
                //Add email to the list
                listOfMail.add(mail);
            }
            
            if(listOfMail.size() > 0){
                //Sent the Emails
                Messaging.sendEmail(listOfMail);
            }
        }
    }
    
    /**
     *  @description    :  Update related MQL Credits
     * 
     *  @args           :  List<Event>
     * 
     *  @return         :  void
     *
     *  @Revision Log   :  V1.0 - Created By - Nikita Kumari - 02/08/2022 - CR-20220119-15726 
     **/
    public static void updateRelatedMQLCredits(List<Event> newEvents , Map<Id,Event> oldMapEvents) {
        
        Map<String, Boolean> mapOfEventIdWithCancelled = new Map<String, Boolean>();
        
        for(Event evnt : newEvents)
        {
            //check update and insert case
            if(oldMapEvents != null && 
               (oldMapEvents.get(evnt.Id).Cancelled_Did_Not_Occur__c != evnt.Cancelled_Did_Not_Occur__c)
              )
            {
                mapOfEventIdWithCancelled.put(String.valueOf(evnt.Id), evnt.Cancelled_Did_Not_Occur__c);
                mapOfEventIdWithCancelled.put(String.valueOf(evnt.Id.to15()), evnt.Cancelled_Did_Not_Occur__c);
            }
        }
        
        //check set size
        if(mapOfEventIdWithCancelled.size() > 0 && mapOfEventIdWithCancelled.keySet().size() > 0)
        {  
            List<MQL_Credit__c> listOfMQLCreditToBeUpdate = new List<MQL_Credit__c>();
            for(MQL_Credit__c mqlCredit : [Select Id,Name, Event_ID__c, Credit_Approval__c From MQL_Credit__c 
                                           Where Event_ID__c != '' AND Event_ID__c != null
                                           AND Event_ID__c IN :mapOfEventIdWithCancelled.keySet()])
            {
                if(mapOfEventIdWithCancelled.containsKey(mqlCredit.Event_ID__c)){
                    
                    mqlCredit.Credit_Approval__c = mapOfEventIdWithCancelled.get(mqlCredit.Event_ID__c) ? 'Pending' : 'Approved';
                    listOfMQLCreditToBeUpdate.add(mqlCredit);
                }
            }
            
            if(listOfMQLCreditToBeUpdate.size() > 0)
            {
                //bypass the trigger to reduce recursion
                Util.BypassAllTriggers = true;
                Update listOfMQLCreditToBeUpdate;
                Util.BypassAllTriggers = false;
            }
        }
    }
}