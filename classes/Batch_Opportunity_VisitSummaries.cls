/*
    Purpose:    To populate Visit Summary fields on Opportunity based on the Opportunity's related Events that have an event type of one of
                the following: "In Person Visit", "Opportunity Visit - For Opportunity Goal", or "Prospect Meeting Attendee - Count as Visit".

    Create By:  Nathan Banas (SAP) - 1/17/2011

    Last Modified By:   Nathan Banas (SAP) - 1/20/2011

    Current Version:    v1.1

    Revision Log:       v1.0 - (NB) Created using requirements from Google Doc (UAT issue 112).
                        v1.1 - (NB) Modified code to include the following:
                                    - Removed of Event StartDateTime != null condition from loop and added to Query
                                    - Changed the way Previous YTD and Current YTD fields are calculated
                                    - Added comments to ensure code is easier to follow
                        v1.2 - (Bhavi) - 10/29/2012 - Added code to update the Outreach Count on opportunity level - CR-20120516-875
                        v1.3 - (Bhavi) - 12/19/2012 - CR-20120316-593
                        v1.4 - (Bhavi) - 11/20/2013 - CR-20130807-3382
                        v1.5 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.6 - Modify by - Abhinav Sharma - 04/19/2014 - CR-20140331-4909 - Updates to batch failure process
                        v1.7 - Modified by - Ajit Surana - 05/22/2014 - CR-20140320-4833
                        V1.8 - Modified By -(Abhinav Sharma) - Finish Deleting fields from Release 29 - 06/03/2014 - CR-20131120-4008 
                        V1.9 - Modified By - Abhinav Sharma - CR-20140613-5790 - 09/01/2015
                        V2.0 - Modified By - Victor Hanson - 09/22/2015 - CR-20150827-9195 - modified the SOQL Query & merged batch_OpportunityEvaluationCounts exec logic with this batch
                        V2.1 - Modified By - Subhash Garhwal - 07/13/2016 - CR-20160414-9762 - Added additional check for new Opportunity record types
                        V2.2 - Modified - 10/12/2016 - Subhash Garhwal -  - Q2C Hypercare of Hypercare
			V2.3 - Modified By - Mahendra Swarnakar - 08/02/2017 - As per the Regression testing failure -- Added code to byapass the opportunity triggers only 
                        V2.4- Modified By - Abhinav Sharma - CR-20180521-12234 - Removed the references of schedular Sched_UpdateDeploymentStatus
                        V2.5 - Removed the References of count1__c from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018
    			V2.6 - Modified By - Victor Hanson - CR-20180720-12460 - Added reference to Sched_CheckRestrictionExp job and slight modificationt to the finish() method		
			V2.7 - Modified by - Shalu Sharma - CR-20201110-14683 - modified the existing field logic
    Code Coverage as of 1/26/2011: 97%
*/
global class Batch_Opportunity_VisitSummaries implements Database.Batchable<SObject>, Database.Stateful {

    public string Query = null;

    String debuglog = '\n';
    Integer totalprocessed = 0;
    Integer totalSuccessfulUpdates = 0;
    
    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;
    
    //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    global Batch_Opportunity_VisitSummaries() {
        debugLogStr = '';
    }

    global Database.queryLocator start(Database.BatchableContext ctx) {

        AsyncApexJob a = [SELECT id, ApexClassId, JobItemsProcessed, TotalJobItems, NumberOfErrors,  CreatedBy.Email
            FROM AsyncApexJob
            WHERE id = :ctx.getJobId()];

        if(Query == null) {

            Query = Label.Query_Batch_Opportunity_VisitSummaries;
        }
        
        System.debug(LoggingLevel.Error, '@@@@Query' + Query); 
        return Database.getQueryLocator(Query);
        
    }

    global void execute(Database.BatchableContext ctx, list<Sobject> scope) {

        // Set bypass value to ensure triggers do not run
        Util.IsBatch = true;

        //VH - 9/22/2015 - CR-20150827-9195
        Set<Id> oIDs = new Set<Id>();
        Map<Id, Date> evalCountMap = new Map<Id, Date>();
        Map<Id, Integer> oCount = new Map<Id, Integer>();
        Map<Id, Date> oLatestActivity = new Map<Id, Date>();
        
        // create a map of opp ids and dates so that we don't count visits twice for the same day
        Map<Id, Set<Date>> oppDateMap = new Map<Id, Set<Date>>();
        
        //String variable to hold the error message string in case of any failure
        String logMessage = '';

        List<Opportunity> recordList = (List<Opportunity>)scope;

        System.debug(LoggingLevel.Error, '@@@@recordList' + recordList);
        DateTime BatchStartDateTime = System.now();

        // List to store Opportunity Ids to process
        List<Id> oppIds = new List<Id>();

        // Loop through Opportunities to process and build list of Ids
        for(Opportunity o : recordList) {

            oppIds.add(o.Id);
        }

        //Create a map to hold all the events against opportunity
        Map<Id, List<Event>> mapOpportunitiesWithEvents = new Map<Id, List<Event>>();

        //fetch releted events
        for(Event event : [Select Id, ActivityDate, StartDateTime, WhatId, Event_Type__c,  Count__c, Cancelled_Did_Not_Occur__c, Event_Purpose__c from Event
                                where (Event_Type__c = 'In Person Visit' OR Event_Type__c = 'Opportunity Visit - For Opportunity Goal'
                                        OR Event_Type__c = 'Prospect Meeting Attendee - Count as Visit' OR Event_Type__c = 'Phone Appointment')
                                    AND StartDateTime != null AND IsChild = false
                           	    //Removed RecordType.Name = 'PT Marketing'
                                    //AND (RecordType.Name = 'RI Marketing') - Modified By - Neha Sharma - CR-20201110-14683 
                                    AND Count__c = 1 AND WhatId != null AND WhatId IN: oppIds]) {

            //Check if opportunity is already in map, then add event in existing list, else add new
            if(mapOpportunitiesWithEvents.containsKey(event.WhatId)) {

                //Add event in list
                mapOpportunitiesWithEvents.get(event.WhatId).add(event);
            } else {

                //Add event in list
                mapOpportunitiesWithEvents.put(event.WhatId, new List<Event>{event});
            }
        }

        List<RecordType> rt = [select Id from RecordType where SobjectType = 'Event' and (Name = 'RI Marketing')];
        Set<Id> rtIds = new Set<Id>();
        for (Integer i = 0; i < rt.size(); i++) {
            rtIds.add(rt[i].Id);
        }
	// Modified By - Neha Sharma - CR-20201110-14683 
        AggregateResult[] r = [select ActivityDate, max(StartDateTime) StartDateTime, Event_Type__c, WhatId, Event_Purpose__c, Cancelled_Did_Not_Occur__c from Event
            where (Event_Type__c = 'In Person Visit' OR Event_Type__c = 'Opportunity Visit - For Opportunity Goal' OR Event_Type__c = 'Web Visit'
                                    OR Event_Type__c = 'Prospect Meeting Attendee - Count as Visit' OR Event_Type__c = 'Phone Appointment')
            AND StartDateTime != null AND WhatId in :oppIds /*AND (RecordType.Name = 'RI Marketing')*/
            AND IsChild = false AND IsDeleted = false AND Count__c = 1 group by WhatId, ActivityDate, Event_Type__c, Event_Purpose__c, Cancelled_Did_Not_Occur__c ALL ROWS];

        //(Bhavi) - 10/29/2012 - Added code to update the Outreach Count on opportunity level - CR-20120516-875

        AggregateResult[] tasksAggResults = [Select /*SUM(Outreach__c) totalORCount,*/ WhatId oppId from Task where
                                                WhatId in :oppIds AND IsDeleted = false group by WhatId ALL ROWS];


        List<Event> listEvents = new List<Event>();
        for (Integer i = 0; i < r.size(); i++) {
            String EventType = string.valueOf(r[i].get('Event_Type__c'));
            String oppId = String.valueOf(r[i].get('WhatId'));
            DateTime startDateTime = datetime.valueOf(r[i].get('StartDateTime'));
            Date startDate = startDateTime.date();

            //Modified by - Shalu Sharma - CR-20201110-14683 - start here
            /*if (EventType != 'Phone Appointment') {
                Set<Date> dtSet = oppDateMap.get(oppId);
                if (dtSet == null) {
                    dtSet = new Set<Date>();
                    dtSet.add(startDate);
                } else {
                    if (dtSet.contains(startDate))
                        continue;
                    dtSet.add(startDate);
                }

                oppDateMap.put(oppId, dtSet);
            }*/
            //Modified by - Shalu Sharma - CR-20201110-14683 - end here
            // if there is already an in person visit for this date, don't count it twice
            //if (dt != null) continue;
          
            listEvents.add(new Event(ActivityDate = date.valueOf(r[i].get('ActivityDate')), StartDateTime = datetime.valueOf(r[i].get('StartDateTime')),
                                        Event_Type__c = string.valueOf(r[i].get('Event_Type__c')), WhatId = String.valueOf(r[i].get('WhatId')), 
                                        Event_Purpose__c = String.valueOf(r[i].get('Event_Purpose__c')), Cancelled_Did_Not_Occur__c = Boolean.valueOf(r[i].get('Cancelled_Did_Not_Occur__c'))));
        }
        //  DAF 8-15-11 added above code

        Map<Id, List<Event>> oppToEventMap = new Map<Id, List<Event>>();

        for(Opportunity o : recordList) {

            for(Event e : listEvents) {

                if(e.whatId == o.Id) {

                    if(oppToEventMap.containsKey(o.Id))
                        oppToEventMap.get(o.Id).add(e);
                    else {

                        List<Event> tmpEventList = new List<Event>();
                        tmpEventList.add(e);
                        oppToEventMap.put(o.Id, tmpEventList);
                    }
                }
            }
        }

        
        map<Id, Opportunity> oppsToUpdate = new map<id, Opportunity>();
        
        //Added - Subhash Garhwal - 07/13/2016 - CR-20160414-9762
        //Opportunity Record Type map
        Map<String, Id> rtmap = Util.recordtypemap('Opportunity');

        for(Opportunity o : recordList) {

            // Increment counter of records processed
            totalprocessed++;
	    // Modified By - Neha Sharma - remove Unused variables - CR-20201110-14683 
            //Properties visits counter
            decimal tmpScheduledVisits = 0;
            decimal tmpTotalVisits = 0;

            //Properties follow up counter
            decimal tmpScheduledFollowUpVisits = 0;
            decimal tmpTotalFollowUpVisits = 0;

            //Added By Ajit Surana - 05/22/2014 - CR-20140320-4833
            decimal tmpTotalPAs = 0;

            //Commented By - Mahendra Swarnkar - 02/25/2021 - CR-20210122-14829 - Program – RI Marketing and Program – PT Marketing deleted from Opportunity
            //VH - 9/22/2015 - CR-20141210-8280
            //Subhash Garhwal - 07/13/2016 - CR-20160414-9762 - Added addition check for Program Record types
            //Modified by - Shalu Sharma - CR-20201110-14683 - start here
            if (o.RecordTypeId == constants.RECORD_TYPE_ID_OPPORTUNITY_RI_MARKETING
                 || o.RecordTypeId == constants.RECORD_TYPE_ID_OPPORTUNITY_PT_MARKETING
                 || o.RecordTypeId == CPQConstants.OPP_RT_ID_EAB_INITIATING
                 || o.RecordTypeId == constants.RECORD_TYPE_ID_OPPORTUNITY_ROYALL
                //Modified by - Shalu Sharma - CR-20201110-14683 - end here
                ) 
            {
                oIDs.add(o.Id);
                evalCountMap.put(o.Id, o.Initial_Visit_Date_Ipv_Web__c);
                oCount.put(o.Id, 0);
            }
            
            List<Event> Events = oppToEventMap.get(o.Id);
            

            if(Events != null) {
                
                // Loop through the related events on this opportunity to add to the total Visit Summaries
                for(Event e : Events) {
                    
                    //Modified by - Shalu Sharma - CR-20201110-14683 - start here
                    if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                       && e.Event_Purpose__c == 'Follow Up' 
                       && e.Cancelled_Did_Not_Occur__c == false)
                    {
                        tmpTotalFollowUpVisits = tmpTotalFollowUpVisits + 1;
                    }
                    
                    if(e.StartDateTime > BatchStartDateTime) {
                        
                        if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                            && (e.Event_Purpose__c == 'Follow Up' || e.Event_Purpose__c == 'Initial')
                            && e.Cancelled_Did_Not_Occur__c == false)
                        {
                            tmpScheduledVisits = tmpScheduledVisits + 1;
                        }
                        if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                           && e.Event_Purpose__c == 'Follow Up' 
                           && e.Cancelled_Did_Not_Occur__c == false)
                        {
                            tmpScheduledFollowUpVisits = tmpScheduledFollowUpVisits + 1;
                        }
                        
                    }
                    
                    
                     if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                       && e.Event_Purpose__c == 'Initial' 
                       && e.Cancelled_Did_Not_Occur__c == false)
                    {
                        tmpTotalVisits = tmpTotalVisits + 1;
                    }
                    if(e.Event_Type__c == 'Web Visit' && e.Event_Purpose__c == 'Follow up' && e.Cancelled_Did_Not_Occur__c == false)
                    {
                        tmpTotalVisits = tmpTotalVisits + 1;
                    }
                    if(e.Event_Type__c == 'Phone Appointment' && e.Cancelled_Did_Not_Occur__c == false)
                    {
                        tmpTotalPAs = tmpTotalPAs + 1;
                    }
                    
                }
                //Modified by - Shalu Sharma - CR-20201110-14683 - end here
                
            }
        
            //Modified by - Shalu Sharma - CR-20201110-14683 - remove the extrs varibale that are not used in the code
            // Determine if there are updates and add the Opportunity to a list to be updated if necessary
            if(  tmpScheduledVisits != o.Scheduled_Visits__c
                || tmpTotalVisits != o.Num_Total_Visits__c
                || tmpScheduledFollowUpVisits != o.Scheduled_Follow_Up_Visits__c
                || tmpTotalFollowUpVisits != o.Total_Follow_Up_Visits__c
                || tmpTotalPAs != o.Num_Total_PAs__c) {

                // visit summaries counter
                o.Scheduled_Visits__c = tmpScheduledVisits;
                o.Num_Total_Visits__c = tmpTotalVisits;

                //Follow up counter
                o.Scheduled_Follow_Up_Visits__c = tmpScheduledFollowUpVisits;
                o.Total_Follow_Up_Visits__c  = tmpTotalFollowUpVisits;

                //Added By Ajit Surana - 05/22/2014 - CR-20140320-4833
                //PAs counter
                o.Num_Total_PAs__c = tmpTotalPAs;
                
                // add opp
                oppsToUpdate.put(o.Id, o);
            }
        }
	/*
        //Loop through the tasks
        for(AggregateResult taskOutreachCount : tasksAggResults) {

            //Get the outreach count sum
            Id whatId = Id.valueOf(String.valueOf(taskOutreachCount.get('oppId')));

            //Check if opportunity is already added, then added Outreach count in existing oppotunity else add a new record to update
            if(oppsToUpdate.containsKey(whatId)) {

                //update outreach count on opportunity
                oppsToUpdate.get(whatId).Total_Outreach_Opp__c = Integer.valueOf(taskOutreachCount.get('totalORCount'));

            } else {

                //Add opportunity record in Map
                oppsToUpdate.put(whatId, new Opportunity(Id = whatId, Total_Outreach_Opp__c = Integer.valueOf(taskOutreachCount.get('totalORCount'))));
            }
        }*/
        
        //Added By - Abhinav Sharma - CR-20140613-5790 - 09/01/2015
        //Start from here
        //Map of opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        
        //Loop through opportunity ids and populating accordingly
        for(Id oId : oppIds) {
            mapOpportunities.put(oId, new Opportunity(ID = oId,
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
        
        //Populating opportunity fields values
        mapOpportunities = EventTriggerHelper.populatePAsAndActivityFields(mapOpportunities);
        
        //Loop through opportunities
        for(Opportunity opp : mapOpportunities.values()) {
            
            if(oppsToUpdate.containsKey(opp.Id)
                && oppsToUpdate.get(opp.Id) != null) {
                
                Opportunity oppt = oppsToUpdate.get(opp.Id);    
                oppt.Initial_PA_Date__c = mapOpportunities.get(opp.Id).Initial_PA_Date__c;
                oppt.Initial_Activity_Date__c = mapOpportunities.get(opp.Id).Initial_Activity_Date__c;
                oppt.Current_YTD_Initial_Pas__c = mapOpportunities.get(opp.Id).Current_YTD_Initial_Pas__c;
                oppt.Prev_YTD_Initial_Pas__c = mapOpportunities.get(opp.Id).Prev_YTD_Initial_Pas__c;
                oppt.Scheduled_Initial_Pas__c = mapOpportunities.get(opp.Id).Scheduled_Initial_Pas__c;
                oppt.Current_Year_Initial_Pas__c = mapOpportunities.get(opp.Id).Current_Year_Initial_Pas__c;
                oppt.Previous_Year_Initial_Pas__c = mapOpportunities.get(opp.Id).Previous_Year_Initial_Pas__c;
                oppt.Current_YTD_Initial_Activities__c = mapOpportunities.get(opp.Id).Current_YTD_Initial_Activities__c;
                oppt.Prev_YTD_Initial_Activities__c = mapOpportunities.get(opp.Id).Prev_YTD_Initial_Activities__c;
                oppt.Scheduled_Initial_Activities__c = mapOpportunities.get(opp.Id).Scheduled_Initial_Activities__c;
                oppt.Current_Year_Initial_Activities__c = mapOpportunities.get(opp.Id).Current_Year_Initial_Activities__c;    
                oppt.Previous_Year_Initial_Activities__c = mapOpportunities.get(opp.Id).Previous_Year_Initial_Activities__c;
                oppt.Total_Initial_Pas__c = mapOpportunities.get(opp.Id).Total_Initial_Pas__c;
                oppt.Total_Initial_Activities__c = mapOpportunities.get(opp.Id).Total_Initial_Activities__c;
                oppsToUpdate.put(opp.Id, oppt);  
            } else {
                oppsToUpdate.put(opp.Id, mapOpportunities.get(opp.Id));
            }
        }
        //Upto here
        
        
        //VH 9/22/2015: if the recordType.DeveloperName is BI_Marketing or Core_Marketing, process and add to the list of opps to update.
        //              This logic came directly from the execute() method in the Batch_OpportunityEvaluationCounts class.
        Date lDate;
        Date eDate;
        //Modify By - Neha Sharma - 04/17/2021 - CR-20201110-14683 - start here
        for (Event e : [select id, EndDateTime, WhatId, Event_Type__c, What.Type from Event where WhatId in :oIDs and Count__c = 1 and IsDeleted = false /*and EndDateTime < TODAY*/ ALL ROWS]) {
            eDate = date.newinstance(e.EndDateTime.year(), e.EndDateTime.month(), e.EndDateTime.day());

            if (evalCountMap.get(e.WhatId) < eDate && (e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit')) {
                oCount.put(e.WhatId,oCount.get(e.WhatId) + 1);
            }
            //Modify By - Neha Sharma - 04/17/2021 - CR-20201110-14683 - end here
            if (oLatestActivity.containsKey(e.WhatId)) {
                lDate = oLatestActivity.get(e.WhatId);
                if (lDate < eDate) {
                    oLatestActivity.put(e.WhatId, eDate);
                }
            } else {
                oLatestActivity.put(e.WhatId, eDate);
            }
        }
        
        for (Opportunity o : recordList) {
            if (evalCountMap.containsKey(o.Id)) {
                //VH
                if (oppsToUpdate.containsKey(o.Id)) o = oppsToUpdate.get(o.Id);
                
                o.Most_Recent_Activity__c = null;
                if (oLatestActivity.containsKey(o.Id)) {
                    o.Most_Recent_Activity__c = oLatestActivity.get(o.Id); 
                }
                system.debug('@@:' + o.Id + '-' + oCount.get(o.Id));
                o.Number_of_Follow_Up_Activities__c = oCount.get(o.Id);
                // add opp to the list of opps to update if it's not already in the list
                if (!oppsToUpdate.containsKey(o.Id))
                    oppsToUpdate.put(o.Id, o);
            }
        }
        // VH 9/22/2015: End of logic from Batch_OpportunityEvaluationCounts

        //Check if there are opportunities to be updated
        if(oppsToUpdate.size() > 0) {
        
            //V2.3 - Modified By - Mahendra Swarnakar - 08/02/2017 - As per the Regression testing failure -- Added code to byapass the opportunity triggers only  
            //By pass All Triggers
            Util.BypassAllTriggers = true;
            
            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((oppsToUpdate.values()),false));
            
            //Enable All Triggers
            Util.BypassAllTriggers = false;
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != ''){
                debugLogStr += logMessage;
                System.debug('@@@@1   '+  oppsToUpdate.values());
            }
        }
        
        //Added By Bhavi for Warm Lead Update

        //Map to hold the Warm Lead record Id as a key and warm lead as a value
        Map<Id, Warm_Lead__c> mapOfWarmLeadIdWithWarmLead = new Map<Id, Warm_Lead__c>();

        //Loop through list of Warm Leads MtM
        for(Warm_Lead_MtM__c warmLeadMtM : [SELECT ID, Opportunity__c, Warm_Lead__c FROM Warm_Lead_MtM__c WHERE Opportunity__c IN : oppIds AND Opportunity__c != null AND Warm_Lead__c != null]) {

            //Populate Map with Values
            mapOfWarmLeadIdWithWarmLead.put(warmLeadMtM.Warm_Lead__c, new Warm_Lead__c(Id = warmLeadMtM.Warm_Lead__c));
        }

        //Check for size
        if(mapOfWarmLeadIdWithWarmLead.values().size() > 0) {

            //Added By Abhinav Sharma - 04/19/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin 
            logMessage = Util.createLog(Database.update((mapOfWarmLeadIdWithWarmLead.values()),false));
            
            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '') 
                debugLogStr += logMessage; 
        
        }
    }

    global void finish(Database.BatchableContext ctx) {
        
        //Added By Abhinav Sharma - 04/19/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {
            
            //User Instance
            //Refactored By Doug Roberts - 08/31/2015 - Remove query for SF user email and change to custom label
            //List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];
            
            //Send log to admin
            //if(sfAdminUser.size() > 0)
            Util.sendBatchStatus(ctx.getJobId(), 'Batch_Opportunity_VisitSummaries', debugLogStr, Label.Salesforce_Admin_Email);
            
        }
        
        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            Datetime sysTime = DateTime.now();
            sysTime = sysTime.addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
          
            /* Abhinav Sharma - CR-20180521-12234 - Removed the references of schedular Sched_UpdateDeploymentStatus
            //Scheduler class
            Sched_UpdateDeploymentStatus controller = new Sched_UpdateDeploymentStatus();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_UpdateDeploymentStatus' + sysTime.getTime(),chron_exp,controller); */
            
            //VH Added 9/22/2015 - CR-20150827-9195
            //Scheduler class
            Sched_OAB_Lead_Passer batch_OAB = new Sched_OAB_Lead_Passer();
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_OAB_Lead_Passer' + System.now().getTime(),chron_exp,batch_OAB);
            system.schedule('Sched_CheckRestrictionExpiration' + System.now().getTime(), chron_exp, new Sched_CheckRestrictionExpiration());
        }
        
    }
}