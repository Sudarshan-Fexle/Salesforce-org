//Class Updated - Simplyforce - Bhavi- 2011-11-29 - CR-20111102-209
//Class Updated - Ajit Surana- 04/03/2015 - CR-20150220-8700 - Query modified at line# 89 - Added isDeleted = false and ALL ROWS to it
//Modified By Mahendra Swarnkar - 02/25/2019 - CR-20200131-13680
global class Batch_ActivityCount implements Database.Batchable<sObject>, Database.Stateful
{
    /*
    Purpose:    Called by Sched_DailyEventCounts

                Update fields on associated Membership:
                - Most Recent QA Call Date (Events)
                    Event.Event_Type__c = "QA Call", max (date) <= today

                - Most Recent QA Call Grade (Events)
                    Event.Event_Type__c = "QA Call", max (date) <= today


                Update fields on Opportunity:
                - Next PA Date (Events)
                    Event_Type__c = "Phone Appointment"  MIN(ActivityDate) >= TODAY

                - How many prewires were completed (Events)
                    Count of Events on Opportunity where Event Type = Prewire and StartDateTime < TODAY

                - Prewire_Completed__c
                    if (Count of Events on Opportunity where Event Type = Prewire and StartDateTime < TODAY) > 0, this field is TRUE. Else, FALSE

    Create By:          Pierre (SAP Contractor)

    Last Modified By:   Nathan Banas (SAP) - 2-25-2011

    Current Version:    v1.3

    Revision Log:       v1.0 - (PE) Created code
                        v1.1 - (NB-2011-01-26) Added header, code comments, and checked code coverage
                        v1.2 - (JN 2/1/2011) Added Opportunity Prewire Completed field
                             - Modified Prewire calculation to use Event_Purpose__c instead of Event_Type__c
                        v1.3 - (NB-2011-02-25) Revised query filter criteria to properly format date (system.today().addDays(1)) into a recognized W3C standard date/time
                        v1.4 - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
                        v1.5 - 07/10/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120612-998
                        v1.5 - 12/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20121113-1719
                        v1.6 - 03/23/2013 - Simplyforce(Bhavi) - Code modified as per the CR-20130204-2413
                        v1.7 - 04/24/2013 - Victor - Code modified as per the CR-20121031-1669
                        v1.8 - Modify by - Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
                        v1.9 - Modify by - Abhinav Sharma - 04/18/2014 - CR-20140331-4909 - Updates to batch failure process
                        v1.10 - Modify by - Abhinav Sharma - 09/15/2014 - CR-20140429-5272 - Removed the existing Bundle_Parent__c references
                        v1.11 - Modify By - Ajit Surana- 04/03/2015 - CR-20150220-8700 - Query modified at line# 89 - Added isDeleted = false and ALL ROWS to it
                        v1.12 - Modified By - Mahendra Swarnkar - 05/20/2015 - CR-20150401-8835 - populate Next Activity Date field on Opportunity
                        v1.13 - Modified By - Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903 - Modified Event Type Criteria, to have Event_Type__c = 'RI QA Call' in the query string.
                        v1.14 - Modified By - Victor Hanson - 07/23/2018 - CR-20180720-12460 - cleanup scheduled jobs in the finish() method
			v1.15 - Modified by - Dipesh Gupta - 08/02/2019 - CR-20190801-13252
*/

    // Variable to store the query string used by the Query Locator
    public String queryStr = null;
    public Integer totalprocessed = 0;
    public string debuglog = '';

    //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
    //Variable is set to true when the batch job is executed from the Scheduled job.
    global Boolean ExecuteNextJob = false;

    //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
    //String variable to hold the entire log message string value
    global String debugLogStr;
    
    //Modified By Rajeev Jain - CR-20180830-12532 - 11/03/2019 - Commented the checks of Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT. 
    // Primary Constructor
    public Batch_ActivityCount()
    {
        debugLogStr = '';

        if(queryStr == null) {

            //Date Format
            //2003-11-20T00:00:00Z
            //2003-11-20T11:11:11Z
            //1994-11-05T08:15:30-05:00

            date filterD = system.today().addDays(-3);

            string year = filterD.year().format().replace(',', '');
            string month = filterD.month() > 9 ? filterD.month().format() : '0' + filterD.month().format();
            string day = filterD.day() > 9 ? filterD.day().format() : '0' + filterD.day().format();
            string suffix = 'T00:00:00-05:00';

            string filterDstr = year + '-' + month + '-' + day + suffix;

            system.debug('#####' + filterDstr);

            /*Date startdate = system.today().addDays(-3);
            String startdatestring = String.valueof(startdate.year()) + '-'
                + ((startdate.month() < 10) ? '0':'') + String.valueof(startdate.month()) + '-'
                + ((startdate.day() < 10)   ? '0':'') + String.valueof(startdate.day());
            String startdatetimestring = startdatestring + 'T00:00:00Z';*/
        
            //Mahendra Swarnkar - 8/26/2016 - CR-20160606-9903 - Modified Event Type Criteria, to have Event_Type__c = 'RI QA Call' in the query string.
            // Modified by - Dipesh Gupta - 08/02/2019 - CR-20190801-13252 - Removed 'or' from the end of the line no. 115
            // Modified by - Mahendra - 02/21/2020  - CR-20200131-13680 - added  or RecordType.DeveloperName = \'BI_QA_Call\' in line 100 and line 99 also query the record type
            queryStr = 'SELECT Id, Event_Type__c,Visit_Location__c, Event_Purpose__c, ActivityDate, StartDateTime, Cancelled_Did_Not_Occur__c, EndDateTime, Grade__c, WhatId, What.Type, What.RecordType.DeveloperName, RecordType.DeveloperName from Event where isDeleted=false AND ' + 
                '(What.Type = \'Opportunity\' or What.Type = \'Membership__c\') and ' +  
                '(Event_Purpose__c = \'Prewire\'  or RecordType.DeveloperName = \'BI_QA_Call\' or ' + 
                '(Event_Type__c = \'' + Constants.EVENT_TYPE_IN_PERSON_VISIT + '\' AND (Event_Purpose__c = \'' + Constants.EVENT_PURPOSE_INITIAL +
                
                //Commented By Rajeev Jain - CR-20180830-12532 - 11/03/2019 - Start Here -
                //OR Event_Purpose__c = \'' + Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT 
                  
                //Commented By Rajeev Jain - CR-20180830-12532 - 11/03/2019 - End Here -
                //
                 + '\' )) or ' +
                ' Event_Type__c = \'' + Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL + '\' or ' +
                ' Event_Type__c = \'' + Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT + '\' or ' +
                ' Event_Type__c = \'Quality Assurance\'  or ' +
                ' Event_Type__c = \'Phone Appointment\' or ' +
                ' Event_Type__c = \'Internal Meetings\' or ' +
                ' Event_Type__c = \'Reference Call\' or ' +
                ' Event_Type__c = \'HSPI Meeting\' or ' +
                ' Event_Type__c = \'Web Visit\' or ' +
                ' Event_Type__c = \'In Person Visit\' or ' +
                ' Event_Type__c = \'Additional Contact Meeting\'' +
                ') ' +
                ' and (StartDateTime > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                    //' OR ActivityDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                    ' OR LastModifiedDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring
                    ' OR CreatedDate > ' + filterDstr + //startdatetimestring + // NB-2011-02-25-Added filterDstr and removed startdatetimestring 
                    ') ' + 
                'order by WhatId ALL ROWS';
                system.debug('\n\n56 querystr\n' + queryStr);
        }
    }

    // Start(Database.BatchableContext) method from the Database.Batchable class
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('******** Batch Process for Event Started ******* ');

        System.debug('Executing Query: '+queryStr);

        return Database.getQueryLocator(queryStr);
    }
    
    //Modified By Rajeev jain - 11/03/2018 - Remove the     Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT From the Query. 
    // Execute(Database.BatchableContext, List<sObject>) method from the Database.Batchable class
    global void execute(Database.BatchableContext BC, List<sObject> srcObjects0)
    {
        //String variable to hold the error message string in case of any failure
        String logMessage = '';

        // Flag the static variable in the Util class to show that a batch is running and therefore bypass triggers
        Util.IsBatch = true;

        // Describe the Opporunity object
        Schema.DescribeSObjectResult oppDescribe = Opportunity.sObjectType.getDescribe();

        // Translate the query from the QueryLocator method into a list of Events
        List<Event> srcObjects = (List<Event>)srcObjects0;
        System.debug('List of Events: '+srcObjects);

        Date maxDate, minDate;
        Map<Id, Event> oppEventMap = new Map<Id, Event>();

        set<id> oppids = new set<id>();
        set<id> memids = new set<id>();

        // Loop through all events being processed
        for (Event e : srcObjects)
        {
            // Check if the whatId of Task is of an Opportunity and add the Opp Id to a list
            if (e.What.Type == 'Opportunity') {
                oppids.add(e.whatId);
            } else if (e.What.Type == 'Membership__c') {

                // Modified by - Dipesh Gupta - 08/02/2019 - CR-20190801-13252
                // Added logic to check event type of 'Phone Appontment'
                //Modified by - Mahendra - CR-20200131-13680 - added the check for RecordType.DeveloperName i.e. BI_QA_Call and Enrollment
                if (e.Event_Type__c.contains('QA Call') || e.Event_Type__c.contains('Phone Appointment') || (String.valueOf(e.RecordType.DeveloperName) == 'BI_QA_Call' && String.valueOf(e.What.RecordType.DeveloperName) == 'Enrollment'))
                    memids.add(e.WhatId);
            }
        }

        //Checking for the size value
        if(oppids.size() > 0) {

            //Modified by - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
            // Query all opportunities associated to these events
            List<Opportunity> oppList = [select id, Next_Activity_Date__c, Next_PA_Date__c, Last_PA_Date__c, Initial_Visit_Date__c, Last_Visit_Date__c,
                How_many_prewires_were_completed__c, Prewire_Completed__c
                from Opportunity where id in :oppids];

            System.debug('List of Opportunities: '+oppList);

            //Map to hold the Opportunity ID as key and list of events as value
            Map<Id, List<Event>> mapOpportunityIdWithEvents = new Map<Id, List<Event>>();

            //Loop over events
            for(Event evt : [SELECT Id, Event_Type__c, Visit_Location__c, Cancelled_Did_Not_Occur__c, Event_Purpose__c, IsChild,
                             ActivityDate, StartDateTime, EndDateTime, Grade__c, WhatId from Event
                             WHERE (Event_Type__c = 'Prewire' or
                             (Event_Type__c = 'In Person Visit' and
                                (Event_Purpose__c =: Constants.EVENT_PURPOSE_INITIAL 
                                 
                                 //Commented By Rajeev jain - 11/03/2018 - Start here 
                                 //OR Event_Purpose__c =: Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT
                                 //Commented By Rajeev jain - 11/03/2018 - End here 
                                )
                             ) or
                             Event_Type__c =: Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL or
                             Event_Type__c =: Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT or
                             Event_Type__c = 'Phone Appointment')
                             AND Cancelled_Did_Not_Occur__c != true
                             AND isDeleted = false
                             AND WhatId != null AND WhatId IN : oppids ALL ROWS]) {

                            if(mapOpportunityIdWithEvents.containsKey(evt.WhatId))
                                mapOpportunityIdWithEvents.get(evt.WhatId).add(evt);
                            else
                                mapOpportunityIdWithEvents.put(evt.WhatId, new List<Event>{evt});
            }
            System.debug('@@@@@ mapOppIdWithEvents ' + mapOpportunityIdWithEvents);
            //Map of eligible event record types
            Map<Id, RecordType> mapEventRecordTypes =  new Map<Id, RecordType>([SELECT id , DeveloperName FROM RecordType
                                                        WHERE DeveloperName IN ('BI_Marketing' , 'Core_Marketing')
                                                        AND IsActive = true
                                                        AND SobjectType = 'Event']);

            //Map to hold the Opportunity ID as key and list of events as value
            Map<Id, List<Event>> mapOppIdWithEvents = new Map<Id, List<Event>>();

            //Loop over events
            for(Event event : [SELECT ID, WhatId, Visit_Location__c, StartDateTime FROM Event
                                WHERE WhatId != null AND WhatId IN : oppids
                                AND RecordTypeID != null AND RecordTypeID IN : mapEventRecordTypes.keySet()
                                AND Cancelled_Did_Not_Occur__c = false
                                AND isDeleted = false
                                AND StartDateTime != null AND StartDateTime > TODAY
                                ORDER BY StartDateTime ASC] ) {

                if(mapOppIdWithEvents.containsKey(event.WhatId))
                    mapOppIdWithEvents.get(event.WhatId).add(event);
                else
                    mapOppIdWithEvents.put(event.WhatId, new List<Event>{event});
            }

            // Loop through all opportunities
            for(Opportunity opp : oppList)
            {
                // Reset Opportunity field values
                opp.How_many_prewires_were_completed__c = 0;
                opp.Next_PA_Date__c = null;
                opp.Last_PA_Date__c = null;
                opp.Initial_Visit_Date__c = null;
                opp.Last_Visit_Date__c = null;
                opp.Next_Activity_Date__c = null;
                Integer numPrewires = 0;
                 
                //Checking and retrieving events associated with the opportunity record
                if(mapOppIdWithEvents != null && mapOppIdWithEvents.containsKey(opp.Id)
                   && mapOppIdWithEvents.get(opp.Id) != null && mapOppIdWithEvents.get(opp.Id).size() > 0
                   && mapOppIdWithEvents.get(opp.Id)[0].StartDateTime != null) {
                    opp.Next_Activity_Date__c = Date.valueOf(mapOppIdWithEvents.get(opp.Id)[0].StartDateTime);
                } 
                
                //Checking and retrieving events associated with the opportunity record
                if(mapOpportunityIdWithEvents != null && mapOpportunityIdWithEvents.containsKey(opp.Id)
                   && mapOpportunityIdWithEvents.get(opp.Id) != null) {

                    // Loop through all events associated w/ this Opportunity
                    for(Event evt : mapOpportunityIdWithEvents.get(opp.Id))
                    {
                        System.debug('Event ' + evt.Id + ' associated to Opportunity ' + opp.Id);

                        /* Populate Next_PA_Date */
                        if(evt.Event_Type__c == 'Phone Appointment') {

                            System.debug('### Populate Opp Next_PA_Date for Opp: ' + opp.Id);

                            // Variable to store the Start Date/Time translated into Date format
                            Date checkDateStart = Date.newInstance(evt.StartDateTime.year(), evt.StartDateTime.month(), evt.StartDateTime.day());

                            // If the Start Date is >= today then process
                            if(checkDateStart >= System.today()) {

                                // If the Opp Next PA Date (Phone Appointment) is not blank, then determine if the Opp Next PA Date
                                // is >= the Event Start Date and if so set the Opp Next PA Date to the Event Start Date
                                //If event start date is in past, then keep Next_PA_Date__c = null
                                if(opp.Next_PA_Date__c != null)
                                {
                                    if(opp.Next_PA_Date__c >= checkDateStart)
                                        opp.Next_PA_Date__c = checkDateStart;
                                }
                                else // If the Opp Next PA Date is not currently populated, set it to the Event Start Date
                                    opp.Next_PA_Date__c = checkDateStart;
                            } else if (opp.Next_PA_Date__c < system.today())
                                opp.Next_PA_Date__c = null;


                            System.debug('### Populate Opp Last_PA_Date for Opp: ' + checkDateStart);

                            //12/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20121113-1719
                            // If the Start Date is < today then process
                            if(checkDateStart < System.today()) {

                                // If the Opp Last PA Date (Phone Appointment) is not blank, then determine if the Opp Last PA Date
                                // is < the Event Start Date and if so set the Opp Last PA Date to the Event Start Date
                                //If event start date is in future, then keep Last_PA_Date__c = null
                                if(opp.Last_PA_Date__c != null) {

                                    if(opp.Last_PA_Date__c < checkDateStart)
                                        opp.Last_PA_Date__c = checkDateStart;
                                }
                                else // If the Opp Next PA Date is not currently populated, set it to the Event Start Date
                                    opp.Last_PA_Date__c = checkDateStart;
                            } else if (opp.Last_PA_Date__c >= system.today())
                                opp.Last_PA_Date__c = null;

                            //12/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20121113-1719
                        }

                        /* Populate Initial_Visit_Date */
                        if ((evt.Event_Type__c == Constants.EVENT_TYPE_IN_PERSON_VISIT &&
                                    (evt.Event_Purpose__c == Constants.EVENT_PURPOSE_INITIAL
                                           //Modified By Rajeev Jain -Stats here - CR-20180830-12532
                                       // || evt.Event_Purpose__c == Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT
                                       //Modified By Rajeev Jain -Ends  here - CR-20180830-12532
                                     ))
                            || evt.Event_Type__c == Constants.EVENT_TYPE_OPPORTUNITY_VISIT_FOR_OPPORTUNITY_GOAL
                            || evt.Event_Type__c == Constants.EVENT_TYPE_PROSPECT_MEETING_ATTENDEE_COUNT_AS_VISIT) {

                            System.debug('### Populate Opp Initial_Visit_Date for Opp: ' + opp.Id);

                            // Variable to store the End Date/Time translated into Date format
                            Date checkDateEnd = Date.newInstance(evt.EndDateTime.year(), evt.EndDateTime.month(), evt.EndDateTime.day());

                            //Commented by - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
                            /*// - 06/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20120417-730
                            //Populate Initial_Visit_Date__c field iwith the Bundle_Parent__c's Initial_Visit_Date__c date .
                            if(opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Initial_Visit_Date__c != null) {

                                //Set Initial Visit Date with Bundle Parent Opportunity Initial Visit Date
                                opp.Initial_Visit_Date__c = opp.Bundle_Parent__r.Initial_Visit_Date__c;
                            }*/

                            // If the Opp Initial Visit Date is not blank then determine if the Event End Date is <= the Opp Initial Visit Date,
                                // if so then set the Opp Initial Visit Date equal to the Event End Date
                                if(evt.Event_Purpose__c != Constants.EVENT_PURPOSE_RELATIONSHIP_VISIT){
                                       if (opp.Initial_Visit_Date__c != null)
                                       {
                                           if(checkDateEnd <= opp.Initial_Visit_Date__c)
                                               opp.Initial_Visit_Date__c = checkDateEnd;
                                       }
                                       else // If the Opp Initial Visit Date is blank, then set the Opp Initial Visit Date equal to the Event End Date
                                           opp.Initial_Visit_Date__c = checkDateEnd;
                                   }
                            //Commented by - Abhinav Sharma - 09/15/2014 - CR-20140429-5272
                            //12/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20121113-1719
                            //Populate Last_Visit_Date__c field with the Bundle_Parent__c's Last_Visit_Date__c date .
                            /*if(opp.Bundle_Parent__c != null && opp.Bundle_Parent__r.Last_Visit_Date__c != null) {

                                //Set Last Visit Date with Bundle Parent Opportunity Last Visit Date
                                opp.Last_Visit_Date__c = opp.Bundle_Parent__r.Last_Visit_Date__c;
                            }*/

                            // If the Opp Last Visit Date is not blank then determine if the Event End Date is > the Opp Last Visit Date,
                            // if so then set the Opp Last Visit Date equal to the Event End Date
                            if (checkDateEnd < System.today()) {

                                //Check if Last Visit date is not null for this opportunity record
                                if(opp.Last_Visit_Date__c != null) {

                                    //If event has latest date then opportunity, then set it to Opportunity
                                    if(checkDateEnd > opp.Last_Visit_Date__c)
                                        opp.Last_Visit_Date__c = checkDateEnd;
                                } else
                                    opp.Last_Visit_Date__c = checkDateEnd;
                            }
                            // If the Opp Last Visit Date is blank, then set the Opp Last Visit Date equal to the Event End Date
                            else if (opp.Last_Visit_Date__c >= system.today())
                                opp.Last_Visit_Date__c = null;
                            //12/12/2012 - Simplyforce(Bhavi) - Code modified as per the CR-20121113-1719

                        }

                        /* Add to Prewire Count for this Opportunity */
                        if(EventUtilities.IsPrewire(evt)) // added EventUtilities isprewire reference
                        {
                            System.debug('### Add to Prewire Count for Opp: ' + opp.Id);
                            numPrewires++;

                            // figure out if at least one prewire has occurred
                            if (evt.StartDateTime < system.today() && !opp.Prewire_Completed__c)
                                opp.Prewire_Completed__c = true;
                        }
                    }

                    // Populate # Prewires and Prewire Completed
                    opp.How_many_prewires_were_completed__c = numPrewires;
                }

                
            }

            // Update Opportunities
            if(oppList.size() > 0) {
                System.debug(' Updated :::::::::::::::::::' + oppList);
                //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
                //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin
                logMessage = Util.createLog(Database.update((oppList),false));

                //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
                if(logMessage != '')
                    debugLogStr += logMessage;

                System.debug('Updated :::::::::::::::::::' + oppList);
            }
        }

        // CR-20121031-1669 - Populate the most recent QA Call fields
       /* list<Membership__c> memList = MembershipTriggerHelper.PopulateMostRecentQACall(memIds);

        //Update Memberships
        if (memList.size() > 0)
        {
            totalprocessed += memList.size();

            //Added By Abhinav Sharma - 04/18/2014 - CR-20140331-4909
            //Making a try to update the list of records and recording error messages will be wmailed to the SFAdmin
            logMessage = Util.createLog(Database.update((memList),false));

            //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
            if(logMessage != '')
                debugLogStr += logMessage;
        }*/

        try {

            //Added by Ajit Surana - 02/02/201 - CR-20141119-8126
            MembershipTriggerHelper.PopulateMostRecentQACall(memIds);
        } catch(Exception ex) {
            logMessage += ex.getMessage();
        }

        //Checking errors log messages string for blank value and append it to final error message string only and only if it have proper value with it
        if(logMessage != '')
            debugLogStr += logMessage;

        Util.IsBatch = false;

    }

    // Finish(Database.BatchableContext) method from the Database.Batchable class
    global void finish(Database.BatchableContext BC)
    {
        System.debug('### ******** Batch Process for Event Completed ******* ');
        System.debug('@@@@ debugLogStr ' + debugLogStr);

        //Added By Abhinav Sharma - 04/18/2014 - Emailing recorded errors details to SFAdmin. - CR-20140331-4909
        //Checking logMessage  string for blank value but if it does not have blank value with it then emailed it to SFAdmin.
        if(debugLogStr != '') {

            //User Instance
            List<User> sfAdminUser = [Select Email FROM User WHERE Name = 'Salesforce Administrator' AND IsActive = true AND Profile.Name = 'System Administrator' AND Email!= null LIMIT 1];

            //Send log to admin
            if(sfAdminUser.size() > 0)
                Util.sendBatchStatus(BC.getJobId(), 'Batch_ActivityCount', debugLogStr, sfAdminUser[0].Email);
        }

        //Added By Abhinav Sharma - 02/19/2014 - CR-20120208-412 - scheduled batch job automation
        //Schedules the next job if the "ExecuteNextJob" variable = true
        if(ExecuteNextJob) {

            //Build the system time of now + 20 Seconds to schedule the batch apex.
            /* VH 9/22/2015 - CR-20150827-9195
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(20);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
            //Scheduler class
            Sched_OppVisitSummaries controller = new Sched_OppVisitSummaries();
            
            //Schedule the next job, and give it the system time so name is unique
            System.schedule('Sched_OppVisitSummaries' + sysTime.getTime(),chron_exp,controller);
            */
        }
        
        // find all scheduled jobs with no Next Fire date and un-schedule them
        for (CronTrigger job : [SELECT Id, NextFireTime FROM CronTrigger WHERE NextFireTime = null LIMIT : Limits.getLimitDMLStatements()]) {
            try {
                system.abortJob(job.Id);
            } catch(Exception ex) {
                continue;
            }  
        }

    }
}