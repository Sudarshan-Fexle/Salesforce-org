/*
    Purpose:    This Trigger updates the prewire fields on Opportunity record based on the related events on Opportunity.
                It is derived by the following:  
                    How_many_Prewires_were_completed__c: the number of Events on Opportunity where Event_Purpose__c = “Prewire” and StartDateTime < system.today()
                    Prewire_Completed__c: If How_many_Prewires_were_completed__c > 0, this is TRUE. Otherwise FALSE
                
                The Membership field "Most Recent NBB Visit" logic is to look at membership institution and take max end date of events where record type
                contains 'marketing' and program acronym (on the event) = membership program acronym. 
                UPDATE - TO BE CLEAR THE EVENT TYPE SHOULD BE 'IN-PERSON VISIT' OR 'OPPORTUNITY VISIT - FOR OPPORTUNITY GOAL'.
                
                Care should be taken to include the current event record as well for Before Insert event as this wont be fetched as part of SOQL
                For checking if a particular event belongs to an Opportunity; we have to check the first 3 characters of Id.  Opportunities have a prefix of 006
    
    Create By:  Angela Williams (SAP Contractor)            
    
    Last Modified By:   Jeremy Nottingham (SAP) - 2/1/2011
    
    Current Version:    v1.4
    
    Revision Log:       v1.0 - (AW) Created code
                        v1.1 - (NB-2011-01-20) Added header, code comments, and reviewed code coverage
                        v1.2 - (JN 2/1/2011) Clarified header description
                        v1.3 - CM 12/20/2013 Edited as part of CR-1991 (remove ref to Old_Product_Field__c)
                        v1.4 - Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
			v1.5 - Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
*/
trigger Event_UpdatePrewireField on Event(before insert, before update, before delete) {
    
    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;
    
    try {
  
        // if the BypassAllTriggers is flagged -- return immediately without processing.
        if (Util.BypassAllTriggers) return;
        
        // Prevent other code pieces from running multiple times when this trigger is called
        Util.IsTrigger_EventPrewire = true;
        
        //This Map will hold all the opportunity ids for the new Event records
        Map<Id, Integer> oppEventCountMap = new Map<Id, Integer>();
        Map<Id, Integer> oppEventCountCompletedMap = new Map<Id, Integer>();
        
        
        list<Event> triggerevents = (Trigger.IsDelete) ? Trigger.old : Trigger.new;
        
        //Get list of IDs to avoid querying if this is an update
        set<Id> triggerids = new set<Id>();
        
        // Build set of Ids to be processed
        if (Trigger.IsUpdate) triggerids = Trigger.newmap.keyset();
        if (Trigger.IsDelete) triggerids = Trigger.oldmap.keyset();
        
        // Describe Opportunity and Account objects
        Schema.DescribeSObjectResult oppDescribe = Opportunity.sObjectType.getDescribe();
        Schema.DescribeSObjectResult accDescribe = Account.sObjectType.getDescribe();
        
        Integer count0 = 0;
        Integer count1 = 0;
        
        //keep track of recordtypes for Events
        map<String, Id> rtmap = Util.recordtypeMap('Event');
        Id coremarketingrtid = rtmap.get('Sales');
        Id bimarketingrtid = rtmap.get('Sales');
        
        Boolean DoMostRecentNBB = false;
        
        //Opps with NBB visits, used to get Accounts
        set<id> nbbvisitoppids = new set<id>();
        set<id> nbbvisitaccids = new set<id>();
        set<String> nbbProgramAcronyms = new set<String>();
        set<String> nbbEventTypes = new set<String>{ 'In Person Visit', 'Opportunity Visit - For Opportunity Goal' };
        
        for(Event evnt: triggerevents)
        {
            String idStr = String.valueOf(evnt.whatId);
            
            // If the WhatId of this Event is null, skip processing
            if (idSTr == null)
                continue;
            
            // Check if the whatId of Event is of an Opportunity.
            if(idStr.substring(0,3) == oppDescribe.getKeyPrefix())
            {
                // Count up/down Prewire-type Events from triggering list
                
                // Increment Prewire counter when the Event Event Purpose is not null
                // AND (the Event Purpose is equal to 'Prewire' AND the it is not Cancelled/Did Not Occur!
                if(evnt.Event_Purpose__c != null && (evnt.Event_Purpose__c.equalsIgnoreCase('Prewire')))
                {
                    count0 = oppEventCountMap.get(evnt.whatId);
                    count1 = oppEventCountCompletedMap.get(evnt.whatId);
                    
                    //reset count in map
                    if(count0 == null)
                        count0 = 0;
                    if (count1 == null)
                        count1 = 0;
                        
                    //only count non-deleting Events
                    if (!Trigger.IsDelete && !evnt.Cancelled_Did_Not_Occur__c) {
                        count0++;
                        if (evnt.StartDateTime < system.today())
                            count1++;
                    }
                    
                    //record running count for each opp in map
                    oppEventCountMap.put(evnt.whatId,count0);
                    oppEventCountCompletedMap.put(evnt.whatId, count1);
                }
            
                
               // Most recent nbb on membership - identify opps to help recalc Most Recent NBB Date
                if (((evnt.RecordtypeID == coremarketingrtid) || (evnt.RecordtypeID == bimarketingrtid)) && (nbbEventTypes.contains(evnt.Event_Type__c)))
                {
                    DoMostRecentNBB = true;
                    nbbvisitoppids.add(evnt.whatID);
                }
            }
            else if (idStr.substring(0,3) ==  accDescribe.getKeyPrefix()) // Check if the whatId of Event is of an Account.
            {
                
                // Most recent nbb on membership - identify Accounts and Program Acronyms to help recalc Most Recent NBB Date
                if (((evnt.RecordtypeID == coremarketingrtid) || (evnt.RecordtypeID == bimarketingrtid)) && (nbbEventTypes.contains(evnt.Event_Type__c)))
                {
                    DoMostRecentNBB = true;
                    nbbvisitaccids.add(evnt.whatID);
                    
                   /* if (evnt.Old_Product_Field__c != null)
                        nbbProgramAcronyms.add(evnt.Old_Product_Field__c); */
                }
            }
        }
        
        // Update Prewire counts and Prewire boolean from existing queried Events, excluding triggering records
        
        // Query for all Events that are in the Event Prewire Count whose Event Purpose is equal to 'Prewire'
        // the Event Id is not in the Events that spawned this trigger 
        //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start Here
        List<Event> allprewireEvents = new List<Event>();
        if(oppEventCountMap.size() > 0){
           allprewireEvents = [select Id, WhatId, Event_Purpose__c, Cancelled_Did_Not_Occur__c, StartDateTime from Event 
           			where WhatId IN :oppEventCountMap.keySet() 
                                and Event_Purpose__c = 'Prewire' 
                                and IsChild = false
                                //and StartDateTime < :system.today() // CR-474 now calculating all prewires scheduled or completed
                                and Id not in :triggerids and IsDeleted = false ALL ROWS]; 
        }
        //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - End Here
        
        // Loop through all Prewire Events and update Prewire Count in Opportunity map
        for (Event evnt : allprewireEvents)
        {
            count0 = oppEventCountMap.get(evnt.whatId);
            count1 = oppEventCountCompletedMap.get(evnt.whatId);
            
            // as long as this event is not cancelled/did not occur!
            if (!evnt.Cancelled_Did_Not_Occur__c)
                count0++;
            
            if (evnt.StartDateTime < system.today() && !evnt.Cancelled_Did_Not_Occur__c)
                count1++;
            
            oppEventCountMap.put(evnt.whatId,count0);
            oppEventCountCompletedMap.put(evnt.whatId, count1);
        }
    
        // Build a list to store the Opportunities needing updates
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        
        
        
        //Set the Prewire count in the opp field as per Map
        for(Id oppId: oppEventCountMap.keySet()) {
            system.debug('@@OppEventCountMapKeySet(): ' + oppEventCountMap.keySet() + ' @@ ' + oppEventCountCompletedMap.get(oppId));
            // Create a reference to the Opportunity and set the Prewire information
            Opportunity opp = new Opportunity(Id = oppId);
            
            opp.Prewire_Completed__c = false;
            
            // figure out if the opportunity has a completed prewire
            integer prewireCompletedCount = oppEventCountCompletedMap.get(oppId);
            if (prewireCompletedCount != null) {
                if (prewireCompletedCount > 0) {
                    opp.Prewire_Completed__c = true;
                    opp.Trigger_Update__c = true;
                }
            }
            
            
            // Set number of Prewires completed for this Opportunity
            opp.How_many_Prewires_were_completed__c = oppEventCountMap.get(oppId);
            
            // Add the Opportunity to the list of Opportunities needing updates
            oppListToUpdate.add(opp);
        }
        
        // Calculate Membership field Most_Recent_NBB_Visit__c only if this trigger was not called by a Batch AND the Event's Opportunity Type is Marketing
        // AND (the Event Type is 'In Person Visit' or 'Opportunity Visit - For Opportunity Goal') 
        if (!Util.IsBatch && DoMostRecentNBB)
        {
            map<String, Id> eventrtmap = Util.recordtypemap('Event');
            set<id> evtrtids = new set<id>();
            evtrtids.add(eventrtmap.get('Sales'));
            
            System.debug('nbbvisitoppids::::' +nbbvisitoppids);
            System.debug('triggerids::::' +triggerids);
            map<id, Opportunity> oppid2oppmapnbbvisits = new map<id, Opportunity>();
            //Added by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start Here
            if(nbbvisitoppids.size() > 0){
                // Query all Opportunities from Events and store them in a map 
                for( Opportunity opp : [select Id, Trigger_Update__c, AccountID, Membership__c, Program__c, Program__r.Program_Acronym__c,
                    					(select Id, EndDateTime from Events 
                        				 where RecordtypeID in :evtrtids 
                                            		 and Event_Type__c in :nbbEventTypes 
                                            		 and id not in :triggerids
                                            		 order by EndDateTime desc limit 1)
                			from Opportunity where id in :nbbvisitoppids])
                {
                    oppid2oppmapnbbvisits.put(opp.Id, opp);
                }
            }
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - End Here
            
            // List to store Opportunity Membership Ids
            set<id> nbbmemids = new set<id>();
            
            // List to store Opportunity Membership Ids needing updates
            set<id> updatedmemids = new set<id>();
            
            // Loop through Opportunities and add Memberships and Program Acronyms to lists for use later
            for (Opportunity o : oppid2oppmapnbbvisits.values())
            {
                nbbmemids.add(o.Membership__c);
                nbbProgramAcronyms.add(o.Program__r.Program_Acronym__c);
            }
            
            // Query all Memberships from either Opportunity connection or Account and Program in sets
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start Here
            map<id, Membership__c> memid2memmap = new map<id, Membership__c>();
            
            if(nbbmemids.size() > 0 || ( nbbProgramAcronyms.size() > 0 && nbbvisitaccids.size() > 0)){
            	for(Membership__c mem : [select Id, Most_Recent_NBB_Visit__c, Account_Name__c, Program__r.Program_Acronym__c from Membership__c 
                			where Program__c != null 
                			and (id in :nbbmemids 
                                        or (Program__r.Program_Acronym__c in :nbbProgramAcronyms and Account_Name__c in :nbbvisitaccids))])
                {
                    memid2memmap.put(mem.Id, mem);
                }   
            }  
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - End Here
            
            // Make sure we get all Accounts involved.
            for (Membership__c m : memid2memmap.values())
            {
                nbbvisitaccids.add(m.Account_Name__c);
            }
            
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start Here
            // Query all Accounts to retrieve their Event lists that may have been affected
            map<id, Account> accid2accmap = new map<id, Account>();
            if(nbbvisitaccids.size() > 0){
                for(Account acc : [select id, (select Id, EndDateTime /*, Old_Product_Field__c*/ from Events 
                				where RecordtypeID in :evtrtids 
                                            	and Event_Type__c in :nbbEventTypes 
                                            	//and Old_Product_Field__c in :nbbProgramAcronyms
                                            	and id not in :triggerids
                                            	order by EndDateTime desc limit 1)
                                        	from Account where id in :nbbvisitaccids])
                {
                    accid2accmap.put(acc.Id, acc);
                }
            }
            //Updated by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - End Here
            
            // Loop through Memberships
            for (Membership__c mem : memid2memmap.values())
            {
                Date mostrecentnbbdate = null;// = mem.Most_Recent_NBB_Visit__c;
                
                //Loop through Opportunities associated to the related Membership
                for (Opportunity o : oppid2oppmapnbbvisits.values())
                {
                    // If this Opportunity Membership is not equal to the related Membership, skip and move onto the next Opportunity
                    if (o.Membership__c != mem.id)
                        continue;
                    
                    system.debug('### Opportunity: ' + o.Id + ' / Number of Events: ' + o.Events.size());
                    //Loop through Events associated to the related Opportunity
                    for (Event e : o.Events)
                    {
                        system.debug('### Event: ' + e.Id + ' / Most recent NBB Date: ' + mostrecentnbbdate + ' / Event EndDateTime: ' + e.EndDateTime);
                        
                        // If Most Recent NBB Date is equal to null OR Most Recent NBB Date is less than the Event End Date,
                        // set Most Recent NBB Date equal to the Event End Date in GMT.
                        if (mostrecentnbbdate == null || mostrecentnbbdate < Date.newInstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day()))
                            mostrecentnbbdate = e.EndDateTime.dateGMT();
                    }
                }
                
                // Check Events on this Account that match the program acronym
                if (accid2accmap.containsKey(mem.Account_Name__c))
                {
                    system.debug('### Account: ' + accid2accmap.get(mem.Account_Name__c).Id + ' / Number of Events: ' + accid2accmap.get(mem.Account_Name__c).Events.size());
                    
                    // Loop through Events related to this Membership's Account
                    for (Event e : accid2accmap.get(mem.Account_Name__c).Events)
                    {
                        system.debug('### Event: ' + e.Id);
                        //system.debug('### Event Old Product: ' + e.Old_Product_Field__c + ' / Membership Program Acronym: ' + mem.Program__r.Program_Acronym__c);
                        system.debug('### Most Recent NBB Date: ' + mostrecentnbbdate + ' / Event End Date: ' + Date.newInstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day()));
                        
                        // If the Event Old Product is equal to the Membership Program Acronym AND (the most recent NBB Date is null
                        // OR the most recent NBB Date is less than the Event End Date), set the Most Recent NBB Date equal to the Event End Date in GMT.
                        if (/*e.Old_Product_Field__c == mem.Program__r.Program_Acronym__c && (mostrecentnbbdate == null ||*/ mostrecentnbbdate < Date.newInstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day()))
                            mostrecentnbbdate = e.EndDateTime.dateGMT();
                    }
                }
                
                // Process triggered records on insert or update to see if anything needs to change.
                if (!Trigger.IsDelete)
                {
                    // Loop through the Events that called this trigger
                    for (Event e : triggerevents)
                    {
                        if (((oppid2oppmapnbbvisits.containsKey(e.WhatID)) && (oppid2oppmapnbbvisits.get(e.WhatID).Membership__c == mem.id))
                           /* || ((accid2accmap.containsKey(e.WhatID)) && (e.Old_Product_Field__c.trim().equalsIgnoreCase(mem.Program__r.Program_Acronym__c.trim())))*/)
                        {
                            if ((mostrecentnbbdate == null) || (mostrecentnbbdate < e.EndDateTime))
                                mostrecentnbbdate = e.EndDateTime.dateGMT();
                        }
                        
                    }   
                }   
                
                // Build a list of Membership Ids needing updates to Most Recent NBB Visit (date)
                if (mostrecentnbbdate != mem.Most_Recent_NBB_Visit__c)
                {
                    mem.Most_Recent_NBB_Visit__c = mostrecentnbbdate;
                    updatedmemids.add(mem.id);
                } 
            }
            
            // Build list of Memberships that need new NBB Visit values
            list<Membership__c> memstoupdate = new list<Membership__c>();
            for (Id i : updatedmemids)
            {
                memstoupdate.add(memid2memmap.get(i));
            }
            
            system.debug('\n\n212memstoupdate ' + memstoupdate);
            
            // Update Memberships       
            if (memstoupdate.size() > 0)
                update memstoupdate;
        }
    
        // If there are Opportunities needing updates, update them
        if(oppListToUpdate.size()>0)
        {
            for(Opportunity o: oppListToUpdate)
            {
                o.Trigger_Update__c = true;
            }
            
            try
            {
                // Update Opportunities needing updates
                update oppListToUpdate;
            }
            catch (Exception e)
            {
                // Loop through Opportunities and display error encountered to user
                for (Opportunity o : oppListToUpdate)
                {
                    o.addError(e.getMessage());
                }
            }
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