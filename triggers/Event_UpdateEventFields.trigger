trigger Event_UpdateEventFields on Event(before insert, before update, after insert, after update, after delete) 
{
    /*
Purpose:    This Trigger updates the following fields:

Event
Populate Subject: [Year, 4digits]/[Month, 2digits]/[Day, 2digits)] - [Account Name] - [Function] - [Type] . 
If the Event is Related To an Opportunity, use the Account on the Opportunity. Otherwise use the Account directly associated.
If the Event is related to a Membership, use Program Acronym from the Membership in place of Function
Populate Program: If isnull(Old_Product_Field__c), get Program__c from associated Opportunity, else Old_Product_Field__c
Populate Membership__c: Text value of Membership__c on associated Opportunity. This will be a SFDC ID stored in a text field.
Populate Visit__c: [end date] & " - " & [account formal name]

Opportunity
Next PA Date: Upcoming Phone Appointment start date
Populate # Revisits based on Type = 'In Person' and Purpose = 'Follow Up'

For checking if a particular event belongs to an Opportunity; we have to check the first 3 characters of Id.  Opportunities have a prefix of 006


Create By:  Angela Williams (SAP Contractor)            

Last Modified By:   Jeremy Nottingham (SAP) 2/15/2011

Current Version:    v2.7

Revision Log:       v1.0 - (AW) Created code
v1.1 - (NB-2011-01-20) Added header, code comments, and reviewed code coverage
v1.2 - Modified to allow for updates to existing Events and account for changes to Next PA Date or Initial Visit Date fields
v1.3 - (NB-2011-01-27) Added requirement Populate # of Revisits
v1.4 - (JN 2/15/2011) Added handling of null StartDateTime
- Reorganized header for clarity
v1.5 - (JN 3/1/2011) Modified method of calculating Initial Visit Date from Datetime (StartDateTime)
v1.6 -  09/28/2011 - Simplyforce(Bhavi) - Code modified as per the CR-20110912-30
v1.7 -  01/15/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20111207-263  
v1.8 -  02/12/2012 - DAF - eliminated Initial Visit Date from updating in Bundled Opps
v1.9 - (Bhavi 04/11/2012) - CR-20111205-259        
v2.0 - (11/05/2012 - Bhavi - CR-20120920-1514)
v2.1 - (05/01/2013 - Bhavi - CR-20130408-2822)  
v2.2 - 11/20/2013  - VH - CR-20130919-3662
v2.3 - 12/17/2013  - VH - CR-20121127-1793
v2.4 - 12/19/2013  - CM - CR-20121226-1991
v2.5 - 12/25/2013 - Bhavi - CR-20130111-2120
v2.6 - 02/04/2014 - Bhavi - CR-20140124-4353
v2.7 - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
v2.8 - Ajit Surana - 04/03/2015 - CR-20150220-8700 - Query modified - Added idDeleted = false and ALL ROWS to it
v2.9 - Victor Hanson - 05/20/2015 - CR-20150511-8947 - bypass autopopulation of subject if the event comes from LP (ie: External ID is populated)
v2.10 - Mahendra Swarnakar - 02/04/2016 - CR-20151221-9474
v2.11 - Colin McGloin - 08/14/2017 - Issue--CR11094--QA--00005435 (Q2C - Freeing up lookup fields on Opportunity)
v2.12 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
V2.13 - Modified By - Subhash Garhwal - 11/07/2017 - Issue--CR11744--QA--00007311 - Added bypass logic to avoid SOQL limit issue
V2.14 - Modified By - Abhinav sharma  - 06/28/2018 - CR-20180604-12258 - Removed the Field visit__c From the Event Object. 
V2.15  - Dipesh Gupta -CR-20190111-12831- 03/27/2019 - Commented out the method - UpdateInteractionInformation
V2.16 -  Modified By Dipesh Gupta - Issue--CR13122--QA--00009008 (CR-20190522-13122).
V2.17 -  Modified By - Dipesh Gupta -09/25/2019 CR-20190429-13049 - Added Check for Visit Location as per taylor chatter
V2.18 -  Modified By - Dipesh Gupta -10/04/2019 CR-20190429-13049 - Added Check for Event_Purpose__c as per carter chatter
*/
    
    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;  
    
    
    try {
        
        if (Util.BypassAllTriggers) return;
        
        if (trigger.isBefore) {
            
            // when a new event is added to an existing opp, populate the opp's initial visit date on the event (CR-20130919-3662)
            EventUtilities.populateOppInfoToActivities(trigger.new, null);
        }
        
        if (trigger.isAfter) {
            
            //comment the reference of class - LP_ServiceUtils -- CR-20200520-14075
            if(!EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
                //LP_ServiceUtils.checkTargetReleaseDate(trigger.new, trigger.oldMap);
            
            if (trigger.isDelete) {
                
                //do not allow deletion of records synched with LP unless it is the site guest user
                //LP_ServiceUtils.validateDelete(trigger.old);
            }
        }
        
        //CR-20111205-259 
        //Create a list of opportunities to be updated  
        Map<Id, Opportunity> opportunitiesToBeUpdated = new Map<Id, Opportunity>();
        
        //check for the request type
        if(Trigger.isBefore || (Trigger.isAfter && Trigger.isDelete)) {
            
            // if this is being updated because the contact's title was updated, let that trigger handle the work, don't do it again
            if (!Util.BypassAllTriggers && !trigger.isDelete && !EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
                ContactTriggerUtilities.PopulateContactTitleFromEvent(trigger.new);
            
            // Prevent other code pieces from running multiple times when this trigger is called
            Util.IsTrigger_EventUpdateFields = true;
            
            List<Id> accIdList = new List<Id>();
            List<Id> oppIdList = new List<Id>();
            List<Id> memIdList = new List<Id>();
            List<Opportunity> oppsNeedingUpdate = new List<Opportunity>();
            set<id> triggeringeventids = new set<id>();
            if (Trigger.IsUpdate) triggeringeventids = Trigger.newmap.keyset();
            
            
            set<Id> updatedoppids = new set<Id>();
            
            // Get Describe Information for Opportunity and Account objects 
            Schema.DescribeSObjectResult oppDescribe = Opportunity.sObjectType.getDescribe();
            Schema.DescribeSObjectResult accDescribe = Account.sObjectType.getDescribe();
            Schema.DescribeSObjectResult memDescribe = Membership__c.sObjectType.getDescribe();
            
            //Simplyforce - Create variables to hold the contact and lead id
            Set<Id> cntIds = new Set<Id>();
            Set<Id> leadIds = new Set<Id>();
            Schema.DescribeSObjectResult cntDescribe = Contact.sObjectType.getDescribe();
            Schema.DescribeSObjectResult leadDescribe = Lead.sObjectType.getDescribe();
            
            // Loop thru events and build List of Opportunity and Account IDs
            for(Event evnt : trigger.isDelete ? trigger.old : trigger.new)
            {
                //Modified CR:-CR-20190522-13122
                //if (evnt.RecordTypeId == LP_ServiceUtils.EVENT_ETECH_RT_ID) continue;
                String idStr = String.valueOf(evnt.whatId);
                
                // If WhatId of current Event == null, then skip this event
                if (idStr == null)
                    continue;
                
                // Check if the whatId of Task is of an Opportunity.
                if (idStr.substring(0,3) ==  oppDescribe.getKeyPrefix())
                {
                    oppIdList.add(evnt.whatId);
                    opportunitiesToBeUpdated.put(evnt.whatId, new Opportunity(Id = evnt.whatId));
                } 
                
                // Check if the whatId of Task is of an Account.
                else if(idStr.substring(0,3) ==  accDescribe.getKeyPrefix())
                {
                    accIdList.add(evnt.whatId);
                }
                
                // Check if the whatId of Task is of an Membership.
                else if(idStr.substring(0,3) ==  memDescribe.getKeyPrefix())
                {
                    memIdList.add(evnt.whatId);
                }
                
            }
            
            //Copy opportunitiesToBeUpdated list to OpportunityTriggerUtilities opportunities
            OpportunityTriggerUtilities.opportunities = opportunitiesToBeUpdated;
            
            
            // Loop thru events and build List of Opportunity and Account IDs
            for(Event evnt : trigger.isDelete ? trigger.old : trigger.new) {
                //if (evnt.RecordTypeId == LP_ServiceUtils.EVENT_ETECH_RT_ID) continue;
                String whoIdStr = String.valueOf(evnt.whoId);
                
                // If WhatId of current Event == null, then skip this event
                if (whoIdStr == null)
                    continue;
                
                //Simplyforce - check who id is of lead
                if(whoIdStr.substring(0,3) ==  leadDescribe.getKeyPrefix()) {
                    leadIds.add(evnt.WhoId);
                }
                
                //Simplyforce - check who id is of contact
                else if(whoIdStr.substring(0,3) ==  cntDescribe.getKeyPrefix()) {
                    cntIds.add(evnt.WhoId);
                }
            }
            
            //Create contact and lead map
            Map<Id, Contact> mapContact = new Map<Id, Contact>([Select Id, Name, LastName from Contact where Id in: cntIds]);
            Map<Id, Lead> mapLead = new Map<Id, Lead>([Select Id, Name from Lead where Id in: leadIds]);
            
            //Modified By - Ajit Surana - 04/03/2015 - CR-20150220-8700 - Query modified - Added idDeleted = false and ALL ROWS to it
            // Query to return all Opportunities related to the events within this trigger and retrive all of their related events
            // that meet the criteria of (Event_Type__c = 'Phone Appointment' and StartDateTime >= :system.today()) or Event_Type__c = 'In Person Visit'
            // or Event_Type__c = 'Opportunity Visit - For Opportunity Goal' or Event_Type__c = 'Prospect Meeting Attendee - Count as Visit'
            // Simplyforce : Added Name field in Opportunity select clase
            
            //Modified by Colin McGloin - Issue--CR11094--QA--00005435
            //Removed query filter of 'AND Bundle_Parent__c = null' since we are deleting that lookup field
            List<Opportunity> oppList = new list<Opportunity>();
            if (oppIdList.size() > 0) {
                oppList = [select Id, Name, Trigger_Update__c, of_Revisits__c, Account.Name, Account.Account_Formal_Name__c, 
                           Initial_Visit_Date__c, Next_PA_Date__c, Program__r.Program_Abbreviation__c,
                           Account.Type, Function__c, Program__c, Program__r.Program_Acronym__c, Membership__c
                           FROM Opportunity 
                           WHERE Id IN :oppIdList];
            }
            
            Map<Id, Opportunity> allOppMap = new Map<Id, Opportunity>([SELECT Id, Name, Trigger_Update__c, of_Revisits__c, Account.Name, 
                                                                       Account.Account_Formal_Name__c, Initial_Visit_Date__c, Next_PA_Date__c, 
                                                                       Account.Type, Function__c, Program__c, Program__r.Program_Acronym__c, Membership__c
                                                                       FROM Opportunity 
                                                                       WHERE Id IN :oppIdList]);
            
            //Map to hold the Opportunity ID as key and list of events as value
            Map<Id, List<Event>> mapOpportunityIdWithEvents = new Map<Id, List<Event>>();
            
            //Loop over events
            for(Event evt : [SELECT Event_Type__c, ActivityDate, Visit_Location__c, StartDateTime, Event_Purpose__c, WhatId from Event
                             WHERE isDeleted = false AND Id not in :triggeringeventids
                             AND WhatId != null AND WhatId IN : allOppMap.keySet()
                             AND ((Event_Type__c = 'Phone Appointment' and StartDateTime >= :system.today())
                                  or Event_Type__c = 'In Person Visit'
                                  or Event_Type__c = 'Opportunity Visit - For Opportunity Goal'
                                  or Event_Type__c = 'Prospect Meeting Attendee - Count as Visit')
                             order by StartDateTime ASC ALL ROWS]) {
                                 if(mapOpportunityIdWithEvents.containsKey(evt.WhatId))
                                     mapOpportunityIdWithEvents.get(evt.WhatId).add(evt);
                                 else
                                     mapOpportunityIdWithEvents.put(evt.WhatId, new List<Event>{evt}); 
                             }
            System.debug('@@@@@ mapOpportunityIdWithEvents ' + mapOpportunityIdWithEvents);
            
            // populate the event subject regardless of whether or not the Opp is a child (ie: bundled parent is populated)
            if (!Trigger.isDelete) {
			
				String MEMBER_TRANSITION_RECORDTYPEID  =  Schema.SObjectType.Event.getRecordTypeInfosByName().get('Member Transition').getRecordTypeId();
                String MEMBER_SUCCESS_RECORDTYPEID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Member Success').getRecordTypeId();
				
				Map<Id, String> mapUserIdWithName = New Map<Id, String>();
				//Loop on the Event Object to check if the event is Member transition type then we need the owner information. 
				for(Event e : trigger.new) {
					
					//Check if the record type id is Member transition.
					if(e.RecordTypeId == MEMBER_TRANSITION_RECORDTYPEID && String.isNotBlank(e.OwnerId))
						mapUserIdWithName.put(e.OwnerId, '');
					
				}
				
                //Check for the Map size. 
                if(mapUserIdWithName.size() > 0) { 
                	//For loop on the User to get the Information regarding the User populated om the event's owner. 
                    for(User u : [Select Id, Name From User where Id IN: mapUserIdWithName.keySet()]) 
                        //Filling map with the User Id and Name of the user. 
                        mapUserIdWithName.put(u.Id, u.Name);
                }
				
				for (Event evnt : trigger.new) {
                    //if (evnt.RecordTypeId == LP_ServiceUtils.EVENT_ETECH_RT_ID) continue;
                    
                    //STARTS HERE - Modified By Dipesh Gupta - 07/29/2019 - Issue--CR13122--QA--00009008 (CR-20190522-13122) 
                    //Bypass All the naming convention for the Member Success Record type 
                    if(evnt.RecordTypeId == MEMBER_SUCCESS_RECORDTYPEID)
                        continue;
                    //Issue--CR13122--QA--00009008 (CR-20190522-13122)  - ENDS HERE.
                    
                    String contactName;
                    if(evnt.whoId != null) {
                        
                        //get the who refernce
                        String whoIdStr = String.valueOf(evnt.whoId);
                        if ((whoIdStr.substring(0,3) ==  cntDescribe.getKeyPrefix()) && (mapContact.get(evnt.whoId) != null)) {
                            
                            contactName = mapContact.get(evnt.whoId).Name;
                            
                        } else if ((whoIdStr.substring(0,3) ==  leadDescribe.getKeyPrefix()) && (mapLead.get(evnt.whoId) != null)) {
                            contactName = mapLead.get(evnt.whoId).Name;
                        }
                    }
                    
                    //check if contact name is null then add No Contact
                    if(contactName == null || contactName == '')
                        contactName = 'No Contact';
                    
                    //variable to hold the event type value
                    String eventPurpose;
                    if(evnt.Event_Purpose__c == null || evnt.Event_Purpose__c == '')
                        eventPurpose = '';
                    else
                        eventPurpose = evnt.Event_Purpose__c;
                    
                    //Populate the event subject
                    if(evnt.WhatId != null && evnt.RecordTypeId != EventUtilities.syndicatedResearchRTID) {
                        evnt.Subject = evnt.Event_Type__c 
                            + '-' + eventPurpose
                            + '-' + contactName;
                        //Simplyforce - Event subject population
                        String suffix;
                        //populate event subject from Event :[Event_Type__c] - [Event_Purpose__c] - [ContactName] - [OpportunityName]
                        if (allOppMap.get(evnt.whatId) != null) {
                            suffix = allOppMap.get(evnt.whatId).Name;
                        }
                        
                        if(suffix != null && suffix != '') {//Populate the event subject
                            evnt.Subject += '-' + suffix;
                        } 
                    }
                    
                    //MEMBER TRANSITION RECORD TYPE - NAMING CONVENTION
                    //Check for the Member Transition Record type. 
                    if(evnt.RecordTypeId == MEMBER_TRANSITION_RECORDTYPEID) {      
                        
                        String priorAssignment = String.isNotBlank(evnt.Prior_Assignment__c) ? evnt.Prior_Assignment__c : '';
                        
                        evnt.Subject = 'Member Transition-'+eventPurpose+'-'+ priorAssignment +'>'+ mapUserIdWithName.get(evnt.OwnerId);
                    }
                }
            }    
            
            // Query to return all accounts related to the events within this trigger.
            List<Account> accList = new list<Account>();
            if (accIdList.size() > 0) {
                accList = [select Id, Name, Account_Formal_Name__c, Type  from Account where Id IN:accIdList];
            }
            
            // Query to return all accounts related to the events within this trigger.
            map<id, Membership__c> memid2memmap = new map<id, Membership__c>();
            if (memIdList.size() > 0) {
                memid2memmap = new map<id, Membership__c>([select Id, Name, Account_Name__c, Account_Name__r.Name, Program__c, Program__r.Program_Acronym__c  
                                                           from Membership__c where Id IN :memIdList]);
            }
            
            // This Map will hold all the opportunity for the new Event records
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(oppList);
            
            // This Map will hold all the Account Id for the new Event records
            Map<Id, Account> accMap = new Map<Id, Account>(accList);
            
            System.debug('### oppMap : ' + oppMap + 'AccMap###');
            
            // Make sure all the Opps are up to date with existing events
            for (Opportunity o : oppList)
            {
                o.Next_PA_Date__c = null;
                o.Initial_Visit_Date__c = null;
                o.of_Revisits__c = 0;
                
                if(mapOpportunityIdWithEvents.containsKey(o.Id) && mapOpportunityIdWithEvents.get(o.Id) != null) {
                    
                    // Loop through all events within this opportunity (except the ones that just got changed)
                    for (Event e : mapOpportunityIdWithEvents.get(o.Id))
                    {
                        // Next PA Date Processing
                        if (e.Event_Type__c.trim() == 'Phone Appointment'.trim()) 
                        {
                            
                            // Process only if this Event has an Event Type of 'Phone Appointment'
                            Date checkDate;
                            
                            //if (e.StartDateTime != null) checkDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), e.StartDateTime.day());
                            if (e.StartDateTime != null) checkDate = e.StartDateTime.dateGMT();
                            
                            //If this event is eligible by date
                            if (checkDate >= system.today()) {
                                if (o.Next_PA_Date__c == null)
                                {
                                    // If Opportunity Next PA Date is null and Event Start Date is greater than Today,
                                    // set the Next PA Date equal to the Event Start Date
                                    o.Next_PA_Date__c = checkDate;
                                    o.Trigger_Update__c = true;
                                    updatedoppids.add(o.id);
                                }
                                else if ((o.Next_PA_Date__c != null) && (checkDate < o.Next_PA_Date__c))
                                {
                                    // If the Event Start Date is less than the Opportunity Next PA Date and the Event Start Date
                                    // is greater or equal to today, set the Next PA Date equal to the Event Start Date
                                    o.Next_PA_Date__c = checkDate;
                                    o.Trigger_Update__c = true;
                                    updatedoppids.add(o.id);
                                }
                            }
                        }
                        
                        else // Initial Visit Date Processing
                        {
                            // Process Events with Event Types other than 'Phone Appointment'
                            Date checkDate;
                            //if (e.StartDateTime != null) checkDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), e.StartDateTime.day());
                            if (e.StartDateTime != null) checkDate = e.StartDateTime.dateGMT(); //modified 3/1/2011 jkn
                            system.debug('\n\n170 checkDate ' + checkDate + ' startdatetime ' + e.StartDateTime);                    
                            
                            if (((o.Initial_Visit_Date__c == null) || (checkDate < o.Initial_Visit_Date__c))&&
                                e.Event_Purpose__c != Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT){
                                // If Opportunity Visit Date equals null OR Event Start Date is less than the Opportunity Initial Visit Date, set the Initial Visit Date
                                o.Initial_Visit_Date__c = checkDate;
                                o.Trigger_Update__c = true;
                                updatedoppids.add(o.id);
                            }
                            
                            if(e.Event_Type__c != null && e.Event_Purpose__c != null)
                            {
                                if (e.Event_Type__c.trim() == 'In Person Visit'.trim() && e.Event_Purpose__c.trim() == 'Follow Up'.trim())
                                    o.of_Revisits__c ++;
                            }
                        }
                        
                    }
                }
                
                if(!trigger.isDelete)
                {
                    // changed from FOR(Event e : trigger.new) to for (Event e : o.Events) 4/2/2012
                    // Loop through Events that spawned this trigger
                    for (Event e : trigger.new)
                    {
                        if (e.WhatId != null) {
                            if (e.WhatId != o.Id)   continue;
                        }
                        // Next PA Date Processing
                        if (e.Event_Type__c != null && e.Event_Type__c.trim() == 'Phone Appointment'.trim()) 
                        {
                            
                            // Process only if this Event has an Event Type of 'Phone Appointment'
                            
                            Date checkDate;
                            //if (e.StartDateTime != null) checkDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), e.StartDateTime.day());
                            if (e.StartDateTime != null) checkDate = e.StartDateTime.dateGMT();
                            
                            if (checkDate >= system.today()) {
                                if (o.Next_PA_Date__c == null && checkDate >= system.today())
                                {
                                    // If Opportunity Next PA Date is null and Event Start Date is greater than Today,
                                    // set the Next PA Date equal to the Event Start Date
                                    o.Next_PA_Date__c = checkDate;
                                    o.Trigger_Update__c = true;
                                    updatedoppids.add(o.id);
                                }
                                else if (o.Next_PA_Date__c != null && checkDate < o.Next_PA_Date__c && checkDate >= system.today())
                                {
                                    // If the Event Start Date is less than the Opportunity Next PA Date and the Event Start Date
                                    // is greater or equal to today, set the Next PA Date equal to the Event Start Date
                                    o.Next_PA_Date__c = checkDate;
                                    o.Trigger_Update__c = true;
                                    updatedoppids.add(o.id);
                                }
                            }
                        }
                        //11/05/2012 - Bhavi - CR-20120920-1514
                        else if (e.Event_Type__c != null &&
                                 ((e.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT 
                                   && (e.Event_Purpose__c == Constants.EVENT_PURPOSE_INITIAL || e.Event_Purpose__c == Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT)) ||
                                  e.Event_Type__c == Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL ||
                                  e.Event_Type__c == Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT)) // Initial Visit Date Processing
                        {
                            // Process Events with Event Types other than 'Phone Appointment'
                            Date checkDate;
                            //if (e.StartDateTime != null) checkDate = Date.newInstance(e.StartDateTime.year(), e.StartDateTime.month(), e.StartDateTime.day());
                            if (e.StartDateTime != null) checkDate = e.StartDateTime.dateGMT(); //modified 3/1/2011 jkn
                            system.debug('\n\n229 checkDate ' + checkDate + ' startdatetime ' + e.StartDateTime);                    
                            if (((o.Initial_Visit_Date__c == null) || (checkDate < o.Initial_Visit_Date__c))&&
                                e.Event_Purpose__c != Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT){
                                // If Opportunity Visit Date equals null OR Event Start Date is less than the Opportunity Initial Visit Date, set the Initial Visit Date
                                o.Initial_Visit_Date__c = checkDate;
                                o.Trigger_Update__c = true;
                                updatedoppids.add(o.id);
                            }
                            
                            if(e.Event_Type__c != null && e.Event_Purpose__c != null)
                            {
                                if (e.Event_Type__c.trim() == 'In Person Visit'.trim() && e.Event_Purpose__c.trim() == 'Follow Up'.trim())
                                    o.of_Revisits__c ++;
                            }
                        }
                    }
                }
                else
                {
                    boolean oppNotInUpdateList = true;
                    for(id oul : updatedoppids)
                    {
                        if(oul == o.Id)
                            oppNotInUpdateList = false;
                    }
                    
                    if(oppNotInUpdateList)
                    {
                        o.Next_PA_Date__c = null;
                        o.Initial_Visit_Date__c = null;
                        o.Trigger_Update__c = true;
                        updatedoppids.add(o.id);
                    }           
                }
            }
            
            
            if(!Trigger.isDelete)
            {
                //check if this event will change Next PA Date or Initial Visit Date
                for(Event evnt: Trigger.new)
                {
                    //if (evnt.RecordTypeId == LP_ServiceUtils.EVENT_ETECH_RT_ID) continue;
                    //Simplyforce - Event subject population
                    String MEMBER_TRANSITION_RECORDTYPEID  =  Schema.SObjectType.Event.getRecordTypeInfosByName().get('Member Transition').getRecordTypeId();
                    String MEMBER_SUCCESS_RECORDTYPEID = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Member Success').getRecordTypeId();
                        
                    //Check if the record type is Member Transition and  Member success then by pass the below logic. 
                    if(evnt.RecordTypeId == MEMBER_SUCCESS_RECORDTYPEID || evnt.RecordTypeId == MEMBER_TRANSITION_RECORDTYPEID)
                        continue;
                    
                    // Get the whatId of Event 
                    String idStr = String.valueOf(evnt.whatId);
                    
                    // If there is no Event WhatId, skip this record
                    if (idStr == null) continue;
                    
                    // If the WhatId of the Event is an Opportunity, then set Function, Program, Membership, Subject, and Visit
                    if ((idStr.substring(0,3) ==  oppDescribe.getKeyPrefix()) && (oppMap.get(evnt.whatId) != null))
                    {
                        
                        //Set the Event Membership
                        if ((evnt.Membership__c == null) && (oppMap.get(evnt.whatId).Membership__c != null))
                        {
                            // Set the Event Membership equal to the Opportunity Membership when
                            // the Event Membership is null AND the Opportunity Membership is not null
                            evnt.Membership__c = oppMap.get(evnt.whatId).Membership__c;
                        }
                        
                        //Added By - Mahendra Swarnakar - 02/04/2016 - CR-20151221-9474
                        //Start From Here
                        //Set the Event Visit when the Event End Date is not null AND the Opportunity Account Formal Name is not null
                        if ((evnt.EndDateTime != null) && evnt.whatId != null && oppMap.get(evnt.whatId).Account != null
                            && (oppMap.get(evnt.whatId).Account.Account_Formal_Name__c != null)) {
                                
                                //Temp variable
                                String visitTempString = '';
                                
                                // Set the Event Visit equal to <Event End Date> - <Opportunity Account Formal Name>
                                visitTempString = (String.valueOf(evnt.EndDateTime.month()).length() == 1 ? '0' + String.valueOf(evnt.EndDateTime.month()) : String.valueOf(evnt.EndDateTime.month())) +  
                                    '/' + (String.valueOf(evnt.EndDateTime.day()).length() == 1 ? '0' + String.valueOf(evnt.EndDateTime.day()) : String.valueOf(evnt.EndDateTime.day())) + 
                                    '/' + evnt.EndDateTime.year() + ' - ' + oppMap.get(evnt.whatId).Account.Account_Formal_Name__c;
                                
                                //Removing un-necessary spaces
                                visitTempString = visitTempString.trim();
                                
                                //Populating visit field with value 
                                if(visitTempString.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) {
                                    visitTempString = visitTempString.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH));
                                    evnt.Visit__c = visitTempString;
                                } else {
                                    evnt.Visit__c = visitTempString;
                                }
                            }
                        //Upto here
                    } 
                    else if ((idStr.substring(0,3) ==  accDescribe.getKeyPrefix()) && (accMap.get(evnt.whatId) != null)) // Check if the whatId of Task is of an Account.
                    {
                        
                        //Simplyforce - Event subject population
                        String suffix;
                        
                        if ((idStr.substring(0,3) ==  accDescribe.getKeyPrefix()) && (accMap.get(evnt.whatId) != null)) {
                            suffix = accMap.get(evnt.whatId).Name;
                        }
                        
                        //vh updated 10/04/2019 - CR-20190522-13123 - do not auto-populate subject on syndicated research RT
                        if(suffix != null && suffix != '' && evnt.RecordTypeId != EventUtilities.syndicatedResearchRTID) {//Populate the event subject
                            evnt.Subject = evnt.Subject
                                + '-' + suffix;
                        }
                        
                        //Set the Event Subject only when the Start Date is not null (Salesforce internally validates, so Event Start Date will never be null)
                        if(evnt.StartDateTime != null)
                        {
                            Date dt = Date.newInstance(evnt.StartDateTime.year(), evnt.StartDateTime.month(), evnt.StartDateTime.day());
                            
                            /**Commented by Simplyforce - CR-20110912-30 **/
                            // Set the Event Subject equal to the <Event Start Date> - <Related Account Name limited to 55 characters> - <Event Function> - <Event Type>
                            //evnt.Subject = dt.format() + ' - '+ accMap.get(evnt.whatId).Name.substring(0,Math.min(accMap.get(evnt.whatId).Name.length(), 55)) +  ' - ' + evnt.Function__c + ' - '+ evnt.Event_Type__c ;
                        }
                        
                        //Added By - Mahendra Swarnakar - 02/04/2016 - CR-20151221-9474
                        //Start From Here
                        //Set the Event Visit when the Event End Date is not null AND the Account Formal Name is not null
                        if ((evnt.EndDateTime != null) && evnt.whatId != null && (accMap.get(evnt.whatId).Account_Formal_Name__c != null)) {
                            
                            //Temp variable
                            String visitString = '';
                            
                            // Set the Event Visit equal to <Event End Date> - <Account Formal Name>
                            visitString = (String.valueOf(evnt.EndDateTime.month()).length() == 1 ? '0' + String.valueOf(evnt.EndDateTime.month()) : String.valueOf(evnt.EndDateTime.month())) +  
                                '/' + (String.valueOf(evnt.EndDateTime.day()).length() == 1 ? '0' + String.valueOf(evnt.EndDateTime.day()) : String.valueOf(evnt.EndDateTime.day())) + 
                                '/' + evnt.EndDateTime.year() + ' - ' + accMap.get(evnt.whatId).Account_Formal_Name__c;
                            
                            //Removing un-necessary spaces
                            visitString = visitString.trim();
                            
                            //Populating visit field with value 
                            if(visitString.length() > Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH)) {
                                visitString = visitString.substring(0, Integer.valueOf(Label.EVENT_VISIT_MAX_ALLOWED_LENGTH));
                                evnt.Visit__c = visitString;
                            } else {
                                evnt.Visit__c = visitString;
                            }
                        }
                        //upto here
                    }
                    /*  Membership Subject  [Year, 4digits]/[Month, 2digits]/[Day, 2digits)] - [Account Name] - [Function] - [Type] .  */
                    else if ((idStr.substring(0,3) ==  memDescribe.getKeyPrefix()) && (memid2memmap.get(evnt.whatId) != null))
                    {
                        system.debug('\n\n348 ');
                        Date dt = Date.newInstance(evnt.StartDateTime.year(), evnt.StartDateTime.month(), evnt.StartDateTime.day());
                        Membership__c mem = memid2memmap.get(evnt.whatId);
                        String progacronym = '';
                        if (mem.Program__c != null) progacronym = mem.Program__r.Program_Acronym__c;
                        /**Commented by Simplyforce - CR-20110912-30 **/
                        //evnt.Subject = dt.format() + ' - '+ mem.Account_Name__r.Name + ' - ' + progacronym + ' - '+ evnt.Event_Type__c ;
                        
                        String contactName;
                        if(evnt.whoId != null) {
                            
                            //get the who refernce
                            String whoIdStr = String.valueOf(evnt.whoId);
                            if ((whoIdStr.substring(0,3) ==  cntDescribe.getKeyPrefix()) && (mapContact.get(evnt.whoId) != null)) {
                                contactName = mapContact.get(evnt.whoId).Name;
                            } else if ((whoIdStr.substring(0,3) ==  leadDescribe.getKeyPrefix()) && (mapLead.get(evnt.whoId) != null)) {
                                contactName = mapLead.get(evnt.whoId).Name;
                            }
                        }
                        //check if contact name is null then add No Contact
                        if(contactName == null || contactName == '')
                            contactName = 'No Contact';
                        
                        //vh updated 10/04/2019 - CR-20190522-13123 - do not auto-populate subject on syndicated research RT
                        /**Added by Simplyforce - CR-20111207-263 */
                        if (evnt.RecordTypeId != EventUtilities.syndicatedResearchRTID)
                            evnt.Subject = evnt.Event_Type__c + '-' + mem.Account_Name__r.Name + '-' + progacronym + '-' + contactName;
                        
                        //evnt.Program__c = progacronym;  //DAF - added 12-6-11            
                    }
                    
                }
            }
            
            // Determine if any opps need updating and update them
            if(updatedoppids.size() > 0)
            {
                list<Opportunity> oppstoupdate = new list<Opportunity>();
                
                // Build a list of Opportunities from the UpdatedOppIds Map to update
                for (Id i : updatedoppids)
                {
                    oppstoupdate.add(oppmap.get(i));
                }
                
                for(Opportunity o: oppstoupdate)
                {
                    o.Trigger_Update__c = true;
                }
                
                // Update Opportunities needing updates
                if(oppstoupdate.size() > 0)
                    update oppstoupdate;
                
                // DAF - added 8-6-11 (modified 9-2-11) to update Warm Lead Initial Visit Dates
                Set<Id> wlIDs = new Set<Id>();  // to keep multiple same warm leads on the same opp from going in the update list
                List<Warm_Lead__c> WarmLeadsToUpdate = new List<Warm_Lead__c>();
                for (Warm_Lead_MtM__c wlm : [select Opportunity__c, Warm_Lead__c from Warm_Lead_MtM__c where Opportunity__c in :updatedoppids]) {
                    if (!wlIDs.contains(wlm.Warm_Lead__c) && (wlm.Warm_Lead__c != null)) {
                        WarmLeadsToUpdate.add(new Warm_Lead__c(Id = wlm.Warm_Lead__c, Initial_Visit_Date__c = oppmap.get(wlm.Opportunity__c).Initial_Visit_Date__c));
                        wlIDs.add(wlm.Warm_Lead__c);
                    }
                }       
                
                // Update warm leads needing updates
                if(WarmLeadsToUpdate.size() > 0)
                    update WarmLeadsToUpdate;
            }
            
            if(Trigger.isDelete) {
                
                //Update the list of opportunities
                if(OpportunityTriggerUtilities.opportunities.size() > 0) {
                    
                    //call the helper class method to update the Initial data
                    OpportunityTriggerUtilities.updateInitialVisitDateByEventDate(OpportunityTriggerUtilities.opportunities);
                    
                    //Update Opportunities
                    update OpportunityTriggerUtilities.opportunities.values();
                }
                
                //Update Most_Recent_NBB_Visit__c NBB field on membership records
                EventUtilities.UpdateMostRecentNBBVisitOnMembership(Trigger.New, Trigger.oldMap);
            }
            
        } else if(Trigger.isAfter) {
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Update the list of opportunities
                if(OpportunityTriggerUtilities.opportunities.size() > 0) {
                    
                    //call the helper class method to update the Initial data
                    OpportunityTriggerUtilities.updateInitialVisitDateByEventDate(OpportunityTriggerUtilities.opportunities);
                    
                    //try to Update Opportunities
                    try {
                        update OpportunityTriggerUtilities.opportunities.values();
                    }
                    catch(Exception ex) {
                        if (ex.getMessage().contains('Only Finance Ops Users can set the stage field to')) {
                            for(Event evnt : trigger.new) {
                                evnt.addError('Only Finance Ops Users can add/update events associated with this Opportunity because it is in the stage Closed Won, Void, Dropped, Honorary, ATL, or Sent to Finance - Opp Rejected.<br/>'+
                                              ' Please contact <a href="mailto:salesforcehelp@advisory.com?Subject=Error when adding/updating event">salesforcehelp@advisory.com</a> with any questions.');
                            }
                        }
                        else if (ex.getMessage().contains('must have at least one Initial in-person visit')) {
                            for(Event evnt : trigger.new) {
                                evnt.addError('Update failed: Opportunity must have at least one Initial in-person visit associated to save on an Opportunity in the Stage ' +
                                              '"Initial Visit Scheduled".  To cancel the event, first move the Opportunity back to Outreach.');
                            }
                        }
                        else {
                            for(Event evnt : trigger.new) {
                                evnt.addError(ex.getMessage());
                            }
                        }
                    }
                }
                
                //Call the Utility class methid to send the notification to Distribution list
                EventUtilities.sendNegativeFeedBackEmailAlert(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
                
                //Call the EventTriggerHelper method to update project - CR-20130408-2822
                EventUtilities.UpdateProjectByMembershipEvent(Trigger.new, Trigger.oldMap);
            }
            
            //Update Most_Recent_NBB_Visit__c NBB field on membership records - CR-20130111-2120
            EventUtilities.UpdateMostRecentNBBVisitOnMembership(Trigger.New, Trigger.oldMap);
            
            //Update Institution Roles
            //EventUtilities.UpdateInteractionInformation(Trigger.New, Trigger.oldMap);
        }
        //Catching DML Exceptions
    } catch(DMLException e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));
        
        //Catching all Exceptions
    } catch(Exception e) {
        
        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage());
        else
            Trigger.New[0].addError(e.getMessage());
    }
}