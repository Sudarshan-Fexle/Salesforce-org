/**
 *  Description     :   Helper class for PSS Request object trigger
 * 
 *  Created By      :   Abhinav Sharma   
 * 
 *  Created Date    :   12/08/2016
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20160111-9502
 *                      v_1.1 - Modified by - Mahendra Swarnakar - CR-20161102-10332 - 12/20/2016 - Comment out "CRMfusionDBR101.DB_Globals.triggersDisabled" flag
 *						v_1.2 - Modified By - Abhinav Sharma - You're creating a duplicate record. We recommend you use an existing record instead.:
 *						v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Modified the "beforeEventsLogicHandler" and "afterEventsLogicHandler" method.
								Because as per the new "PSS Process", Event record should not be created anymore while requesting the PSS Resource. So bypassing the Events logic for new PSS process.
						v_1.4 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 06/08/2017 - 
										a) Commented out the "afterEventsLogicHandler" and "processRecordsAsynchronously" method. As they are no longer needed
										b) Added New Methods "validateApprovalForDenyReason" and "startsApproval" to invoke the Approval Process and then validate the approval process.
**/ 
public class PSSRequestTriggerHelper {
    
    //PSS Request object API Name
    public final static string PSS_REQUEST_OBJECT_API_NAME = 'PSS_Request__c';
    
    //PSS Request Object - "AM_EAB" Record Type
    public final static string AM_EAB_RECORD_TYPE_LABEL = 'AM - EAB';
    
    public final static Id RECORD_TYPE_SME_REQUEST_AM_EAB = Schema.SObjectType.PSS_Request__c.getRecordTypeInfosByName().get(AM_EAB_RECORD_TYPE_LABEL).getRecordTypeId();

    //Get all record types on PSS Request object
    public static Map<String, Id> mapOfPSSRequestRecordTypes = new map<String, Id> {
																AM_EAB_RECORD_TYPE_LABEL => RECORD_TYPE_SME_REQUEST_AM_EAB
    														   };

    //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Modified the "beforeEventsLogicHandler" and "afterEventsLogicHandler" method
    /**
     *  @description    :   Method to hold before events based logic with it, either to
     *                      perform a validation over PSS Request records
     *                      OR
     *                      populate fields on PSS Request record
     * 
     *  @args           :   List of PSS Requests, Map of PSS Requests
     * 
     *  @return         :   void
     * 
    **/ 
    public static void beforeEventsLogicHandler(List<PSS_Request__c> newPSSRequests, Map<Id,PSS_Request__c> oldMapPSSRequest) {
        
        /**Populate fields on PSS Request Records**/
        //Institution: Institution from Opportunity (auto populate both in insert & update case)
        //Membership: Membership from Opportunity (auto populate both in insert & update case)
        //Program: Program from Opportunity (auto populate both in insert & update case)
        //Start: Start from Event.Start (auto populate both in insert & update case)
        //End: End from Event.End (auto populate both in insert & update case)
        //PSS Resource (User) - User corresponding to the "PSS Resource" contact in the system. (auto populate both in insert & update case)
        //Note:- To get event record details, please utilize "Activity ID" field value.
        
        //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
        //Set to hold the event records IDs
        //Set<Id> setEventsIds = new Set<Id>();
        //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
        
        //Set to hold the opportunity IDs
        Set<Id> setOpportunityIds = new Set<Id>();
        
        //Set to hold the Contact IDs
        Set<Id> setContactIds = new Set<Id>();
        
        //Set to hold the Subscription period Ids 
     	Set<Id> setSubscriptionPeriodIds = new Set<Id>();
        
        //Set of eligible record types
        Set<Id> setOfEligibleRecordTypes = new Set<Id>();
        
        //Loop through record types
        for(String st : mapOfPSSRequestRecordTypes.keySet()) {
            if(st.equalsIgnoreCase(PSSRequestTriggerHelper.AM_EAB_RECORD_TYPE_LABEL)
                && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes != null
                && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.containsKey(st)
                && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.get(st) != null 
            )
                setOfEligibleRecordTypes.add(PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.get(st));   
        }
        
        //Loop through PSS Request records
        for(PSS_Request__c pssR : newPSSRequests) {
            //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
            /*
            if(
                
                (String.isNotBlank(pssR.Activity_ID__c))
                && (pssR.Activity_ID__c instanceof ID) 
                && (ID.valueOf(pssR.Activity_ID__c).getSobjectType() == Schema.Event.SObjectType)
                && (pssR.RecordTypeId != null)
                && (setOfEligibleRecordTypes.contains(pssR.RecordTypeId))
            ) {
			*/
           //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
                //Populating collection with the fields values
                //setEventsIds.add(ID.valueOf(pssR.Activity_ID__c));
            if( pssR.RecordTypeId != null && setOfEligibleRecordTypes.contains(pssR.RecordTypeId)) {
                
                //Checking for the null value
                if(pssR.Opportunity__c != null)
                    setOpportunityIds.add(pssR.Opportunity__c);
                
                //Checking for the null value
                if(pssR.Approver__c != null)
                    setContactIds.add(pssR.Approver__c);
                
                //Checking for the null value
                if(pssR.PSS_Resource__c != null)
                    setContactIds.add(pssR.PSS_Resource__c);
               	
                //Check for the Subscription period 
                if(pssR.Subscription_Period__c != null)
                    setSubscriptionPeriodIds.add(pssR.Subscription_Period__c);
             }
        }
        
        //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
		/*
        //Map of Events
        Map<Id, Event> mapEvents = new Map<Id, Event>();

        //Checking collection for its size
        if(setEventsIds.size() > 0) {
            mapEvents = new Map<Id, Event>([SELECT ID, EndDateTime, StartDateTime, Subject, Event_Type__c
                                            FROM Event 
                                            WHERE ID IN : setEventsIds]);     
        }    
        */
		//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
		
        //Map of Opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        Map<Id, Subscription_Period__c> mapSubscriptionPeriods = new Map<Id, Subscription_Period__c>();
        
        //Checking collection for its size
        if(setOpportunityIds.size() > 0) {
            mapOpportunities = new Map<Id, Opportunity>([SELECT ID, AccountId, Program__c, Membership__c
                                                         FROM Opportunity 
                                                         WHERE ID IN : setOpportunityIds]);     
        }
        
        //Check the size of set and qwuerying the rows from the Subscription period. 
        if(setSubscriptionPeriodIds != null && setSubscriptionPeriodIds.size() > 0) {
            mapSubscriptionPeriods = new Map<Id, Subscription_Period__c> ([Select Id, Institution__c, Membership_Lookup__c, 
                                                                           Program_Subscription__r.Program__c 
                                                                           From Subscription_Period__c Where Id IN: setSubscriptionPeriodIds]);
        }
        
        //Map with Contact ID as key and correspodning user instance as value
        Map<Id, User> mapContactsIdsWithUsers = new Map<Id, User>();
        
        //Checking collection for its size
        if(setContactIds.size() > 0) {
            
            //Set of Employee IDs
            Set<String> setOfEmployeeIds = new Set<String>();
            
            //Map of contacts with employee ID as key
            Map<String, Contact> mapContactsWithEmployeeIdAsKey = new Map<String, Contact>();
        
            //Loop through contact records
            for(Contact c : [Select Id, Employee_ID__c FROM Contact 
                                WHERE ID IN : setContactIds
                                AND Employee_Id__c != null 
                                AND Employee_Id__c != '']) {
                setOfEmployeeIds.add(c.Employee_Id__c);
                mapContactsWithEmployeeIdAsKey.put(c.Employee_Id__c, c);                    
            }
            
            //Checking set for size value
            if(setOfEmployeeIds.size() > 0) {
                
                //Loop through user records associated with contacts and populating collection with help of it
                for(User u : [SELECT ID, Employee_Id__c
                              FROM User
                              WHERE Employee_Id__c != null 
                              AND Employee_Id__c != '' 
                              AND Employee_Id__c =: setOfEmployeeIds]) {
                    
                    //Checking for the key presence and corresponding value for null value in map              
                    if(mapContactsWithEmployeeIdAsKey.containsKey(u.Employee_Id__c)
                        &&
                        mapContactsWithEmployeeIdAsKey.get(u.Employee_Id__c) != null
                    ) {
                        mapContactsIdsWithUsers.put(mapContactsWithEmployeeIdAsKey.get(u.Employee_Id__c).Id, u);
                    }           
                }
            }
        }
    
        //Loop through PSS Request records
        for(PSS_Request__c pssReq : newPSSRequests) {
            
			//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
            //Checking and validating for the eligibility
            /*
            if(
                (String.isNotBlank(pssReq.Activity_ID__c))
                && (pssReq.Activity_ID__c instanceof ID) 
                && (ID.valueOf(pssReq.Activity_ID__c).getSobjectType() == Schema.Event.SObjectType)
                && (pssReq.RecordTypeId != null)
                && (setOfEligibleRecordTypes.contains(pssReq.RecordTypeId))
            ) {
			*/
            
            //Checking and validating for the eligibility
            if( pssReq.RecordTypeId != null && setOfEligibleRecordTypes.contains(pssReq.RecordTypeId)) {
              
                /*
                //Checking for the events
                if(mapEvents.containsKey(ID.valueOf(pssReq.Activity_ID__c))
                    && mapEvents.get(ID.valueOf(pssReq.Activity_ID__c)) != null) {
                    
                    //Subject: Subject from Event.Subject
                    pssReq.Subject__c = mapEvents.get(pssReq.Activity_ID__c).Subject;
                    
                    //Event Type: EventType from Event.EndType
                    pssReq.Event_Type__c = mapEvents.get(pssReq.Activity_ID__c).Event_Type__c;
                    
                    //Start: Start from Event.Start
                    pssReq.Start__c = mapEvents.get(pssReq.Activity_ID__c).StartDateTime;
                    
                    //End: End from Event.End
                    pssReq.End__c = mapEvents.get(pssReq.Activity_ID__c).EndDateTime;                       
                    
                //Setting fields values to null - if no event is associated via "Activity ID" field.    
                } else {
                    pssReq.Subject__c = null;
                    pssReq.Event_Type__c = null;
                    pssReq.Start__c = null;
                    pssReq.End__c = null;
                }
              */
			//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
           
                //Checking and validating for the eligibility
                if(
                    pssReq.Opportunity__c != null
                    && mapOpportunities.containsKey(pssReq.Opportunity__c)
                    && mapOpportunities.get(pssReq.Opportunity__c) != null
                ) {
                
                    //Institution: Institution from Opportunity
                    pssReq.Institution__c = mapOpportunities.get(pssReq.Opportunity__c).AccountID;
                    
                    //Membership: Membership from Opportunity
                    pssReq.Membership__c = mapOpportunities.get(pssReq.Opportunity__c).Membership__c;
                    
                    //Program: Program from Opportunity
                    pssReq.Program__c = mapOpportunities.get(pssReq.Opportunity__c).Program__c;
                
                //Setting fields values to null - if no event is associated via "Activity ID" field.    
                } else if(pssReq.Subscription_Period__c != null
                         && mapSubscriptionPeriods.containsKey(pssReq.Subscription_Period__c)
                          && mapSubscriptionPeriods.get(pssReq.Subscription_Period__c) != null) {
                              
                     //Institution: Institution from Opportunity
                    pssReq.Institution__c = mapSubscriptionPeriods.get(pssReq.Subscription_Period__c).Institution__c;
                    
                    //Membership: Membership from Opportunity
                    pssReq.Membership__c = mapSubscriptionPeriods.get(pssReq.Subscription_Period__c).Membership_Lookup__c;
                    
                    //Program: Program from Opportunity
                    pssReq.Program__c = mapSubscriptionPeriods.get(pssReq.Subscription_Period__c).Program_Subscription__r.Program__c;         
                              
               }else{
                    pssReq.Institution__c = null;
                    pssReq.Membership__c = null;
                    pssReq.Program__c = null;
                }    
            
                //Checking and validating for the eligibility
                //Populating "Approver (User)" field with respect to "Approver" field value
                if(pssReq.Approver__c != null
                    && mapContactsIdsWithUsers.containsKey(pssReq.Approver__c)
                    && mapContactsIdsWithUsers.get(pssReq.Approver__c) != null
                ) {
                    pssReq.Approver_User__c = mapContactsIdsWithUsers.get(pssReq.Approver__c).Id;                       
                } else {
                    pssReq.Approver_User__c = null;    
                }
                
                //Checking and validating for the eligibility
                //Populating "PSS Resource (User)" field with respect to "PSS Resource" field value
                if(pssReq.PSS_Resource__c != null
                    && mapContactsIdsWithUsers.containsKey(pssReq.PSS_Resource__c)
                    && mapContactsIdsWithUsers.get(pssReq.PSS_Resource__c) != null
                ) {
                    pssReq.PSS_Resource_User__c = mapContactsIdsWithUsers.get(pssReq.PSS_Resource__c).Id;                       
                } else {
                    pssReq.PSS_Resource_User__c = null;
                }
            } else {
                
				//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
                /*
				pssReq.Subject__c = null;
                pssReq.Event_Type__c = null;
                pssReq.Start__c = null;
                pssReq.End__c = null;
                */
				//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
                
				pssReq.Institution__c = null;
                pssReq.Membership__c = null;
                pssReq.Program__c = null;
                pssReq.Approver_User__c = null;
                pssReq.PSS_Resource_User__c = null;
            }
        }        
    }        
    //v_1.4 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 06/08/2017 - Commented out the "afterEventsLogicHandler" and "processRecordsAsynchronously" method. As they are no longer needed - Starts from here
    /**
     *  @description    :   Method to hold after events based logic with it. Primarly will use for update fields values on related records.
     * 
     * 
     *  @args           :   List of PSS Requests, Map of PSS Requests
     * 
     *  @return         :   void
     * 
    **/ 
/**    public static void afterEventsLogicHandler(List<PSS_Request__c> newPSSRequests, Map<Id,PSS_Request__c> oldMapPSSRequest) {
            
        //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
        //Set of event IDs string
        //Set<String> setOfEvents = new Set<String>();
        //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
        
        //Map to hold the PSS Request records Ids for those email will fire
        Map<Id, PSS_Request__c> mapPSSRequestsForWhomEmailWillBeSentOut = new Map<Id, PSS_Request__c>();
        
        //Loop through PSS Records and checking for the eligibility
        for(PSS_Request__c pss : newPSSRequests) {
        	
			//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
		  	
            //Insert case
			if(oldMapPSSRequest == null 
				&& pss.Resource_Requested__c != null 
				&& pss.Resource_Requested__c == true 
			){
				mapPSSRequestsForWhomEmailWillBeSentOut.put(pss.Id, pss);
			}
            
			
            //Insert case
            if(oldMapPSSRequest == null 
               && String.isNotBlank(pss.Activity_ID__c)
            )
                setOfEvents.add(pss.Activity_ID__c);
            
            //Update Case
            if(oldMapPSSRequest != null) {
                
                //Checking for the fields value changes
                if(
                    (pss.Activity_ID__c != oldMapPSSRequest.get(pss.Id).Activity_ID__c
                        || pss.PSS_Rank__c != oldMapPSSRequest.get(pss.Id).PSS_Rank__c
                        || pss.PSS_Resource__c != oldMapPSSRequest.get(pss.Id).PSS_Resource__c
                        || pss.RecordTypeID != oldMapPSSRequest.get(pss.Id).RecordTypeID
                        || pss.Attended__c != oldMapPSSRequest.get(pss.Id).Attended__c
                        || pss.Approved__c != oldMapPSSRequest.get(pss.Id).Approved__c
                    )
                ) {
                    
                    //Checking for the field value
                    if(String.isNotBlank(pss.Activity_ID__c))
                        setOfEvents.add(pss.Activity_ID__c);
                    
                    //Checking for the field value
                    if(String.isNotBlank(oldMapPSSRequest.get(pss.ID).Activity_ID__c))
                        setOfEvents.add(oldMapPSSRequest.get(pss.ID).Activity_ID__c);        
                }
                
                //Checking for the fields value changes
                if(pss.Resource_Requested__c != oldMapPSSRequest.get(pss.Id).Resource_Requested__c && pss.Resource_Requested__c) {
                    mapPSSRequestsForWhomEmailWillBeSentOut.put(pss.Id, pss);        
                    if(String.isNotBlank(pss.Activity_ID__c))
                        setOfEvents.add(pss.Activity_ID__c);    
                }
            } 
			
            //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
            
		} 
        
		//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
		
        //Set to event owners emails
        Set<String> setAssignedToEmails = new Set<String>();
              
        //Checking collection for the size value           
        if(setOfEvents.size() > 0) {
            
            //Set of eligible record types
            Set<Id> setOfEligibleRecordTypes = new Set<Id>();
            
            //Loop through record types
            for(String st : mapOfPSSRequestRecordTypes.keySet()) {
                if(st.equalsIgnoreCase(PSSRequestTriggerHelper.AM_EAB_RECORD_TYPE_LABEL)
                    && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes != null
                    && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.containsKey(st)
                    && PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.get(st) != null 
                )
                    setOfEligibleRecordTypes.add(PSSRequestTriggerHelper.mapOfPSSRequestRecordTypes.get(st));   
            }
            
            //Map to PSS Requests
            Map<String, PSS_Request__c> mapOfPSSRequestsForConfirmedPSS = new Map<String, PSS_Request__c>();
            Map<String, PSS_Request__c> mapOfPSSRequestsForPreliminaryPSS = new Map<String, PSS_Request__c>();
            
            //Querying PSS Request records along with field values
            for(PSS_Request__c pssReq : [SELECT ID, PSS_Rank__c, PSS_Resource__c, 
                                         PSS_Resource__r.Name, Activity_ID__c, Attended__c
                                         FROM PSS_Request__c
                                         WHERE Activity_ID__c != null 
                                             AND Activity_ID__c != '' 
                                             AND Activity_ID__c IN : setOfEvents
                                             AND RecordTypeId != null
                                             AND RecordTypeId IN : setOfEligibleRecordTypes
                                             AND Opportunity__c != null
                                             AND PSS_Resource__c != null
                                         ORDER BY LastModifiedDate ASC]
            ) {
                
                //Checking if "PSS Rank" is primary
                if(pssReq.PSS_Rank__c != null
                    && pssReq.PSS_Rank__c != ''
                    && pssReq.PSS_Rank__c.equalsIgnoreCase(System.Label.PSS_RANK_PRIMARY))
                    mapOfPSSRequestsForPreliminaryPSS.put(pssReq.Activity_ID__c, pssReq);                    
                
                //Checking if "Attended" is true
                if(pssReq.Attended__c != null && pssReq.Attended__c)
                    mapOfPSSRequestsForConfirmedPSS.put(pssReq.Activity_ID__c, pssReq);   
            }
                
            //Logic #1
            //it will update "Event" record as per below mentioned use cases:-
            //Note:- In case of multiple record satisfying the criteria, consider the one which got modified most recently.
            //I) Update "Preliminary PSS Resource" field on event record with text value of "PSS Resource" field 
            //from PSS record(s) Where PSS Rank = "Primary".
            //II) Update "Confirmed PSS Resource" field on event record with text value of "PSS Resource" field from PSS record(s) 
            //where Attended = true
            
            //Map of event
            Map<Id, Event> mapOfEventsToBeUpdated = new Map<Id, Event>();
        
            //Loop through event records
            for(Event ev : [SELECT ID, Confirmed_PSS_Resource__c, Preliminary_PSS_Resource__c,
                            Owner.Email, OwnerId
                            FROM Event
                            WHERE ID IN : setOfEvents]) {
                                
                //Populating set with Owners email associated with events
                if(ev.ownerId != null && String.isnotBlank(ev.Owner.Email))
                    setAssignedToEmails.add(ev.Owner.Email);
                                
                //temp string
                String eventIDStr = '';
            
                //Checking for the length and processing event ID string accordingly
                if(String.valueOf(ev.ID).length() == 18)
                    eventIDStr = String.valueOf(ev.ID).substring(0, 15);
                else
                    eventIDStr = String.valueOf(ev.ID);
                                
                //Event Instance
                Event eve = new Event(Id = ev.Id);   
                                
                //Boolean to check whether update will be needed or not
                Boolean isUpdatedNeeded = false;                
                                
                //Checking for key existance in map
                if(mapOfPSSRequestsForPreliminaryPSS.containsKey(eventIDStr)
                    && mapOfPSSRequestsForPreliminaryPSS.get(eventIDStr) != null
                ) {
                    
                    //Checking for field value difference
                    if(mapOfPSSRequestsForPreliminaryPSS.get(eventIDStr).PSS_Resource__r.Name != ev.Preliminary_PSS_Resource__c) {
                        isUpdatedNeeded = true;
                        eve.Preliminary_PSS_Resource__c = mapOfPSSRequestsForPreliminaryPSS.get(eventIDStr).PSS_Resource__r.Name;
                    }
                }   
                                
                //Checking for key existance in map
                if(mapOfPSSRequestsForConfirmedPSS.containsKey(eventIDStr)
                    && mapOfPSSRequestsForConfirmedPSS.get(eventIDStr) != null
                ) {
                    //Checking for field value difference
                    if(mapOfPSSRequestsForConfirmedPSS.get(eventIDStr).PSS_Resource__r.Name != ev.Confirmed_PSS_Resource__c) {
                        isUpdatedNeeded = true;
                        eve.Confirmed_PSS_Resource__c = mapOfPSSRequestsForConfirmedPSS.get(eventIDStr).PSS_Resource__r.Name;
                    }
                }
                                
                //Checking for the boolean flag value and populating collection to have instance for further updates
                if(isUpdatedNeeded)
                    mapOfEventsToBeUpdated.put(eve.Id, eve);
            }
            
            //Checking for the size value and updating events
            if(mapOfEventsToBeUpdated.values().size() > 0) {
                
                //Bypassing all triggers
                Util.BypassAllTriggers = true;
                
                //Update events
                update mapOfEventsToBeUpdated.values();
                
                //Bypassing all triggers
                Util.BypassAllTriggers = false;
            }
        }
		
		//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
     
       //Checking for the size value
        if(mapPSSRequestsForWhomEmailWillBeSentOut.values().size() > 0) {
            
            //get the email template id
            List<EmailTemplate> emailTemplates = [SELECT Id 
                                                  FROM EmailTemplate 
                                                  WHERE 
                                                  DeveloperName =: System.Label.PSS_Template_Name 
                                                  AND IsActive = true];
            
            //IF email template is defined
            if(emailTemplates != null && emailTemplates.size() > 0) {
                
                //List of emails
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
                //Create list of toAddresses
                List<String> toAddresses = new List<String>();
                Set<String> setOfToAddresses = new Set<String>();
                
                //Populating "to addresses" in the list to have "Approver" emails
                for(PSS_Request__c p : [SELECT ID, Approver__c, Approver__r.Email 
                                            FROM PSS_Request__c 
                                            WHERE ID IN : mapPSSRequestsForWhomEmailWillBeSentOut.keySet()]) {
                    //Checking for the null value                            
                    if(p.Approver__c != null && String.isNotBlank(p.Approver__r.Email))
                        setOfToAddresses.add(p.Approver__r.Email);
                }  
              
				//v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Starts from here
			    
                //Checking for size value
                if(setAssignedToEmails.size() > 0) {
                    
                    //Loop through owners emails and adding them as To addresses
                    for(String assignToEmail : setAssignedToEmails) {
                        setOfToAddresses.add(assignToEmail);    
                    }
                }
			    
               //v_1.3 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 04/25/2017 - Ends here
                
                //Checking for the size value
                if(setOfToAddresses.size() > 0) {
                    
                    //To addresses
                    toAddresses.addAll(setOfToAddresses);
                    
                    System.debug('@@@@@@ toAddresses ' + toAddresses);
                
                    //Disabling triggers while creating the dummy contact record
                    Util.byPassAllTriggers = true;
                    
                    //Modified By - Abhinav Sharma - 02/02/2017
                    //To Fix - You're creating a duplicate record. We recommend you use an existing record instead.error
                    //Due to newly created contact matching rules (Found in during run all test through test class failures)
                    //Start from here
                    //Dummy Contact
                    Contact dummyContact = new Contact();
                    
                    String firstName = String.valueOf(Math.random());
                    
                    //Checking for the null and blank value
                    if(String.isNotBlank(firstName)) {
                        
                        //Checking for it's length
                        if(firstName.length() > 40)
                            firstName = firstName.substring(0, 38);
                    }
                    
                    //Populating fields on the dummy contact instances
                    dummyContact.FirstName = firstName;
                    dummyContact.LastName = toAddresses[0];
                    dummyContact.Email = 'somerandomemailaddress546556@test.com';
                    dummyContact.Description = 'dummy contact, please ignore';
                    dummyContact.Bypass_Domain_Validation__c = true;
                    dummyContact.Is_Ignore_Phrase_Characters__c = true;
                    insert dummyContact;
                    //Upto here
                    
                    //Populating collection with emails
                    for(PSS_Request__c ps : mapPSSRequestsForWhomEmailWillBeSentOut.values()) {
                        mails.add(EmailHandler.createEmail(toAddresses, ps.ID, dummyContact.Id, emailTemplates[0].Id, false));
                    }
                    
                    //Loop through emails and setting additional attributes
                    for(Messaging.SingleEmailMessage eml : mails) {
                        eml.setReplyTo(System.Label.PSS_REQUEST_TO_ADDRESS);
                        eml.setSenderDisplayName('PSS Requests');
                        eml.setSaveAsActivity(true);
                    }
                    
                    //Send Notification Email
                    if(mails.size() > 0)
                        //Messaging.sendEmail(mails);
                    
                    //delete dummy Contact
                    delete dummyContact;
                    
                    //Enabling trigger
                    Util.byPassAllTriggers = false;
                    
                    //Checking for size value and calling future method to perform asynchronous updates on PSS Records
                    if(mapPSSRequestsForWhomEmailWillBeSentOut.values().size() > 0)
                        PSSRequestTriggerHelper.processRecordsAsynchronously(mapPSSRequestsForWhomEmailWillBeSentOut.keySet());
                }
            }        
        }
    }
    
    @future(Callout=false)
    public static void processRecordsAsynchronously(Set<ID> recordIds) {
        
        //Map of PSS Request records to be updated
        Map<Id, PSS_Request__c> mapOfPSSRequestsToBeUpdated = new Map<Id, PSS_Request__c>();
        
        //Loop through PSS Records
        for(PSS_Request__c pss : [SELECT ID, Resource_Requested__c FROM PSS_Request__c
                                    WHERE ID IN : recordIds]) {
        System.debug('@@@@@@pss : Resource_Requested__c' + pss);
            //Checking for null and appropriate field value                            
            if(pss.Resource_Requested__c != null && pss.Resource_Requested__c) {
                PSS_Request__c ps = new PSS_Request__c(Id = pss.Id);
                ps.Resource_Requested__c = false;
                mapOfPSSRequestsToBeUpdated.put(ps.Id, ps);
            }
        }
        
        //Checking for the size value
        if(mapOfPSSRequestsToBeUpdated.values().size() > 0) {
            Util.byPassAllTriggers = true;
            update mapOfPSSRequestsToBeUpdated.values();
            Util.byPassAllTriggers = false;
        }
    }
   **/
//v_1.4 - Modified by - Mahendra Swarnakar - CR-20170302-10730 - 06/08/2017 - Commented out the "afterEventsLogicHandler" and "processRecordsAsynchronously" method. As they are no longer needed - Ends here

    //v_1.4 - Added by - Mahendra Swarnakar - CR-20170302-10730 - 06/08/2017 
	/**
     *  @description    :   This method is used to invoke the Approval Process. 
     *
     *  @args           :   List pss request
     *
     *  @return         :   
     *
     **/
    public static void startsApproval(List<PSS_Request__c> pssNew) {
        
        //Loop over the Pss records
        for(PSS_Request__c pss : pssNew){
         
            //Check for the condition
            if(pss.Resource_Requested__c == true){
             
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                
                //Specific approver
                req.setObjectId(pss.Id);
                req.setProcessDefinitionNameOrId('PSS_Request_Approval'); 
                req.setSkipEntryCriteria(true);
                req.setComments('Submitted for approval.');
                
                //Process the Approval process.
                Approval.ProcessResult result = Approval.process(req);
            }   
        }
    }
    
    //v_1.4 - Added by - Mahendra Swarnakar - CR-20170302-10730 - 06/08/2017 -
    /**
     *  @description    :   This method is used to  validate the approval process. 
     *
     *  @args           :   Map new pss request,  Map old pss request
     *
     *  @return         :   
     *
     **/
    public static void validateApprovalForDenyReason(map<Id, PSS_Request__c> newPSS,  map<Id, PSS_Request__c> oldPSS) {
        
        //Map to hold pss request
        map<Id, PSS_Request__c> mapPSS = new map<Id, PSS_Request__c>();
        
        // Build a list of rejected approval processes
        for ( PSS_Request__c pss : newPSS.values() )
        {
            //Check for Approver 
            if(pss.Approver_User__c != null){
             
                //Get the old pss instance from the old map
                PSS_Request__c oldps = oldPSS.get( pss.Id );
    
                //Check for approval status 
                if ( 
                	(
                    	pss.Approval_Status__c == 'Rejected' 
                    	|| pss.Approval_Status__c == 'Approved'
                	) 
                    && pss.Approval_Status__c != oldps.Approval_Status__c
				) {
                    //Populate the map pss
                    mapPSS.put(pss.Id, pss);
                }
            }
        }
    
        //cHECK FOR size
        if (mapPSS.size() > 0 )
        {
            //Map to hold the latest Approval
            map<Id, ProcessInstance> latestInstance = new map<Id, ProcessInstance>();
    
            //Query over the approval process with its steps
            for (ProcessInstance pi : [	SELECT TargetObjectId, Status, CreatedDate,
                                            (
                                            SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate
                                            FROM Steps
                                            WHERE StepStatus = 'Rejected' OR StepStatus = 'Approved'
                                            ORDER BY CreatedDate DESC
                                            )
                                            FROM ProcessInstance
                                            WHERE TargetObjectId In
                                            :mapPSS.keySet()
                                            ORDER BY CreatedDate DESC
                                        ])
            {
    			//Populate the map for latest Approval Instance
                if (!latestInstance.containsKey(pi.TargetObjectId))
                {
                    latestInstance.put(pi.TargetObjectId, pi);
                }
                else
                {
                    ProcessInstance maxInstance = latestInstance.get(pi.TargetObjectId);
                    if ( maxInstance.CreatedDate < pi.CreatedDate  )
                    {
                        latestInstance.put(pi.TargetObjectId, pi);
                    }
                }
            }
            
            //Check for map size
            if(latestInstance.size() > 0){
             
                // only process the latest processInstance for any PSS
                for ( ProcessInstance pi : latestInstance.values())
                {
                    //instance of Latest Process instance step 
                    ProcessInstanceStep latestPis = new ProcessInstanceStep();
                    
                    //Only process the latest step of any processInstance
                    for ( ProcessInstanceStep pis : pi.Steps)
                    {
                        //Check for lattest Instance
                        if ( latestPis.Id == null)
                        {
                            latestPis = pis;
                        }
                        else
                        {
                            //Compare the created date of processInstances to find the lattest ProcessInstance
                            if ( latestPis.CreatedDate < pis.CreatedDate)
                            {
                                latestPis = pis;
                            }
                        }
                    }
                        
                    //Check for the pss Request object
                    if(mapPSS.get(pi.TargetObjectId) != null) 
                    {
                        //Instance to hold the PSS Request record Related to the ProcessInstance
                    	PSS_Request__c pss = new PSS_Request__c (Id = pi.TargetObjectId);
                     	
						//Check for the approval is rejected or approved by the latest step status
                        if ( latestPis.StepStatus == 'Rejected' ) 
                        {
                            //validate the Comment/Pss Resourse
                            if(latestPis.Comments == null 
                                || latestPis.Comments.trim().length() == 0
                                || mapPSS.get(pi.TargetObjectId).PSS_Resource__c == null
                            ) {
                                //String to hold the error message
                                String errorMessage = '';
                                
                                //Check for pss resource on the PSS Request record 
                                if(mapPSS.get(pi.TargetObjectId).PSS_Resource__c == null)
                                    errorMessage =  errorMessage + System.label.PSS_Approved_Error;
                                
                                //Check for Comment field value on approval VF page
                                if(latestPis.Comments == null || latestPis.Comments.trim().length() == 0)
                                    errorMessage = errorMessage + System.label.PSS_Rejected_Error;
                                    
                                //bind the error message to the PSS request
                                mapPSS.get(pi.TargetObjectId).addError(errorMessage);      
                            }
                        }
                        else
                        {
                            //Check for the approval is rejected or approved by the latest step status and then check for the PSS Resource on the PSS request
                            if(latestPis.StepStatus == 'Approved')
                            {
                                //Check for the PSS Resource on related PSS Request 
                                if(mapPSS.get(pi.TargetObjectId).PSS_Resource__c == null)
                                {
                                 	//bind the Error message with the PSS request
                                    mapPSS.get(pi.TargetObjectId).addError(System.label.PSS_Approved_Error);   
                                }    
                            }
                        }
                    }
                }
            }    
        }
	}
}