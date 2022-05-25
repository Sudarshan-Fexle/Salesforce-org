/*
    Purpose         :   This class is helper class for trigger on Membership object.
                
    Create By       :   Simplyforce Technology
    
    Created Date    :   10/30/2012
    
    Current Version :   v1.0
    
    Revision Log    :   V_1.0 Created
                        v1.1 - (Bhavi) - 05/02/2013 - CR-20130411-2856
                        v1.2 - (Bhavi) - 12/13/2013 - Added a new method(populateOpportunityCountOfSourcedWarmLead) - CR-20130417-2892
                        v1.3 - (Bhavi) - 02/22/2014 - Added a new method(updateLeadInfoOnContact) - CR-20140121-4302
                        v1.4 - (Abhinav Sharma) - 08/06/2014 - Modified an existing method(updateLeadInfoOnContact) - CR-20140610-5761
                        v1.5 - (Abhinav Sharma) - 11/24/2014 - CR-20141029-7923 - Added new method (populateInitialVisitDate)
                        v1.6 - (Victor Hanson) - 06/29/2015 - CR-20150129-8609 - Added new method (populateDefaultValues)
                        v1.7 - (Abhinav Sharma) - 10/20/2015 - CR-20150908-9227 - Added new method (populateReportingLeadChannel)
                        v1.8 - (Deepak Kumawat) - 11/17/2017 - Hypercare - Apollo - SF and FF Workstream [CR-20171116-11784] - Added the new method (updateEntityValueOnWarmLead)
                        V1.9 - Subhash Garhwwal - 11/21/2017 - Step--CR11784--0--00007484 - Modified updateEntityValueOnWarmLead method according to chatter
                        V1.10 - Subhash Garhwal - 11/30/2017 - CR-20171122-11812 - Modified updateEntityValueOnWarmLead Logic to Update Entity assignment logic
			V1.11 - Modified By - Dipesh Gupta - 03/20/2020 - CR-20191210-13556(Warm lead lookup field on Event)
			V1.12 - Modified by - Abhinav Sharma - 06/02/2020 - CR-20200103-13588 - Warm Leads: Change Ownership
*/
public without sharing class WarmLeadTriggerHelper {

    //This flag is to stop the recursive execution
    public static Boolean EXECUTE_TRIGGER_CREATE_MATCHING_WARM_LEADS_MTM = true;
    public static String DASH_VAR = '-';
    
    public static Map<String, Reporting_Lead_Channel_Setting__c> MAP_REPORTING_CHANNEL_SETTINGS {

        get {
            
            //Checking for null value
            if(MAP_REPORTING_CHANNEL_SETTINGS == null) {
                
                //Memory allocation
                MAP_REPORTING_CHANNEL_SETTINGS = new Map<String, Reporting_Lead_Channel_Setting__c>();
          
                //Get all values from custom setting
                List<Reporting_Lead_Channel_Setting__c> configs = Reporting_Lead_Channel_Setting__c.getAll().values();
          
                //Loop through all the custom setting records
                for(Reporting_Lead_Channel_Setting__c config : configs) {
      
                    //Check if Parameter Key is not null
                    if(String.IsBlank(config.Lead_Event__c) && String.isBlank(config.Lead_Origin__c))
                        continue;
                    
                    //Key String
                    String keyString = '';
                    keyString = config.Lead_Origin__c.trim().toLowerCase() + DASH_VAR + config.Lead_Event__c.trim().toLowerCase();
      
                    //populating map with key-value pair
                    MAP_REPORTING_CHANNEL_SETTINGS.put(keyString, config);
                }
            }
            return MAP_REPORTING_CHANNEL_SETTINGS;
        }
    }
    
    //Added By- Abhinav Sharma - 10/20/2015 - CR-20150908-9227
    /**
     *  @description    :   Method to populate "Reporting Lead Channel" field on Warm Lead records.
     *
     *  @param          :   List of new warm leads
     *
     *  @return         :   void
     *
    **/
    public static void populateReportingLeadChannel(List<Warm_Lead__c> warmLeads) {
        
        //Map of Reporting_Lead_Channel_Setting__c custom setting
        Map<String, Reporting_Lead_Channel_Setting__c> mapReportingLeadChannelSettings = MAP_REPORTING_CHANNEL_SETTINGS;
        
        //Loop through warm lead records
        for(Warm_Lead__c wL : warmLeads) {
            
            //Checking fields for null/blank value
            if(String.isNotBlank(wL.Lead_Origin__c) && String.isNotBlank(wL.Lead_Channel__c)) {
                
                //Key String
                String keyString = '';
                keyString = wL.Lead_Origin__c.trim().toLowerCase() + DASH_VAR + wL.Lead_Channel__c.trim().toLowerCase();
                
                //Checking for key in the map of custom setting
                if(mapReportingLeadChannelSettings != null 
                    && mapReportingLeadChannelSettings.containsKey(keyString)
                    && mapReportingLeadChannelSettings.get(keyString) != null) {
                    wL.Reporting_Lead_Channel__c = mapReportingLeadChannelSettings.get(keyString).Reporting_Lead_Channel_Value__c;       
                } else {
                    wL.Reporting_Lead_Channel__c = null;    
                }
            } else {
                wL.Reporting_Lead_Channel__c = null;
            }
        }
    }
    
     /*
    Purpose:    Set Warm Lead standard name as follows:
                [Lead Date] – [Truncate Institution Formal name to 55 characters] – [Primary Program Acronym]
    
    Create By:          
    
    Last Modified By:   Nathan Banas (SAP) - 1/25/2011
    
    Current Version:    v1.1
    
    Revision Log:       v1.0 - () Created code
                        v1.1 - (NB-2011-01-25) - Added header, code comments, and reviewed code coverage
                        
    */
    public static void setName(List<Warm_Lead__c> warmLeads, Map<Id, Warm_Lead__c> mapOldWarmLeads) {
        
        //maximum name length
        Integer maxAccNameLength = 55;
        Boolean checkAccountProgramNull = False;
        
        //get Warm Leads that will need a name calculated
        List<Warm_Lead__c> wls = new List<Warm_Lead__c>();
        
        set<Id> accids = new set<Id>();
        set<Id> progids = new set<id>();
        
        //Modified by - Abhinav Sharma - 6/18/2018 - CR-20180608-12274
        Map<id, Account> accid2accmap = new Map<id, Account>();
        Map<id, Program__c> progid2progmap = new Map<id, Program__c>();
        
        // Loop through Warm Leads that called this trigger and add their Account and Primary Program Ids to lists for querying
        for (Warm_Lead__c wl : warmLeads) {
            
            //Added check for change  by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start here
            if(mapOldWarmLeads == null || (wl.Account__c == null || wl.Primary_Program__c == null || wl.Account__c != mapOldWarmLeads.get(wl.Id).Account__c || wl.Primary_Program__c != mapOldWarmLeads.get(wl.Id).Primary_Program__c)){
                if(wl.Account__c != null || wl.Primary_Program__c != null )
                {
                    accids.add(wl.Account__c);
                    progids.add(wl.Primary_Program__c);  
                }
                else
                {
                   checkAccountProgramNull = True; 
                }
                
            }
            //Modified  by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Ends here
        }
        
        // Build a map to store Accounts related to the Warm Leads the called this trigger with the Account Id as the key
        if(accids != null && accids.size() > 0)
			accid2accmap = new Map<id, Account>([Select id, Name from Account where id in :accids]);
        
        // Build a map to store Programs related to the Primary Program on the Warm Leads the called this trigger with the Program Id as the key
        if(progids != null && progids.size() > 0 )
			progid2progmap = new Map<id, Program__c>([select id, Program_Acronym__c from Program__c where id in :progids]);
        
         //Added check for change  by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830 - Start here
       
            // Loop through Warm Leads that called this trigger and process Name and Owner updates
        for (Warm_Lead__c wl : warmLeads) {
            
            if(accid2accmap.size()>0 || progid2progmap.size()>0 || checkAccountProgramNull == True)
            {
                
                // Define the Suffix of the Warm Lead Name as either the Program Acronym of the
                // Primary Program or ' - ' if the Primary Program or Primary Program Acronym is blank
                String suffix = (progid2progmap.get(wl.Primary_Program__c) != null && progid2progmap.get(wl.Primary_Program__c).Program_Acronym__c != null) ?
                    ' - ' + progid2progmap.get(wl.Primary_Program__c).Program_Acronym__c :
                ' - ';
                
                // Define the First part of the Warm Lead Name as either the Account Name truncated to 55 characters or ' ' if the Account is blank
                String accname = accid2accmap.get(wl.Account__c) != null ?
                    (accid2accmap.get(wl.Account__c).Name).substring(0,Math.min(maxAccNameLength, accid2accmap.get(wl.Account__c).Name.length())) :
                ' ';
                
                // Set the Name of the Warm Lead
                wl.Name = accname + suffix;
                
                // If the Warm Lead has a Lead Date, set the Name equal to "<Lead Date> - <Warm Lead Name as defined above>""  
                if (wl.Lead_Date__c != null)
                    wl.Name = wl.Lead_Date__c.format() + ' - ' + wl.Name;
            }
            
            // Set Owner as Marketer // Nathan B 1/5/11 - Added to set Owner = Marketer
            /*if(!Util.IsBatch && wl.Marketer_Assignment__c != null) {
                
                if(wl.OwnerId != wl.Marketer_Assignment__c)
                    wl.OwnerId = wl.Marketer_Assignment__c;
            }*/
            
            //Modified by - Abhinav Sharma - 06/02/2020 - CR-20200103-13588 - Warm Leads: Change Ownership
            if(!Util.IsBatch && wl.Marketing_Associate_Assignment__c != null) {
                
                if(wl.OwnerId != wl.Marketing_Associate_Assignment__c)
                    wl.OwnerId = wl.Marketing_Associate_Assignment__c;
            }
        }
        
    }
    
    //CR-20120516-875 - This method is to create the matching Warm Lead MtM record
    //Method name changed - 4/24/2013 - Bhavi Sharma - CR-20130411-2856
    public static void UpdateStatusOfRelatedOpp(Map<Id, Warm_Lead__c> newWarmLeads, Map<Id, Warm_Lead__c> oldWarmLeads) {
        
        //Create a set to hold the Ids of institutions
        Set<Id> institutions = new Set<Id>();
        Set<Id> programs = new Set<Id>();
        
        //Create a set to maintain the uniqueness
        Set<String> setWithUniquenessCriteria = new Set<String>();
        Map<String, Id> mapWithUniquenessCriteria = new Map<String, Id>();
        
        //loop through the warm leads and get all the institution and programs associated with the warm leads
        for(Warm_Lead__c warmLead : newWarmLeads.values()) {
            
            //Check if Institution and Program is not null then add in set
            if(warmLead.Account__c != null && warmLead.Primary_Program__c != null) {
                
                if(oldWarmLeads == null 
                    || (oldWarmLeads.get(warmLead.Id).Account__c != warmLead.Account__c)
                    || (oldWarmLeads.get(warmLead.Id).Primary_Program__c != warmLead.Primary_Program__c)) {
                
                    //add data
                    institutions.add(warmLead.Account__c);
                    programs.add(warmLead.Primary_Program__c);
                    setWithUniquenessCriteria.add(warmLead.Account__c + '-' + warmLead.Primary_Program__c);
                    mapWithUniquenessCriteria.put(warmLead.Account__c + '-' + warmLead.Primary_Program__c, warmLead.Id);
                }   
            }
        }
        
        String marketing = '%Marketing%';

        List<Opportunity> opportunities = new List<Opportunity>();
        //Added the check Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
        if(institutions.size() > 0 && programs.size() > 0){
        	//Fetch all the relavent opportunities
        	opportunities = [Select Id, StageName, LastModifiedDate, Initial_Visit_Date__c, AccountId, Program__c 
        			From Opportunity where RecordType.Name LIKE: marketing 
                                AND AccountId != null AND AccountId IN: institutions 
                                AND Program__c != null AND Program__c IN: programs 
                                AND StageName != 'Closed Won' AND StageName != 'Closed Lost'];   
        }
        
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>(opportunities);

        //warmLeads to be updated
        List<Warm_Lead__c> warmLeads = new List<Warm_Lead__c>();
        
        //Create a Map to maintian the uniqueness
        Map<Id, Warm_Lead__c> mapWarmLead = new Map<Id, Warm_Lead__c>();
        
        //Group data
        AggregateResult[] aRs = [Select AVG(Total_PAs_WLMtM__c) totalPAs, AVG(Total_Visits_WLMtM__c) totalVisits, AVG(Total_Outreach_WLMtM__c) totalOC, Warm_Lead__c warmLead, 
                                    Opportunity__c opportunity from Warm_Lead_MtM__c where Warm_Lead__c IN: newWarmLeads.keySet() AND Opportunity__c != null GROUP BY Opportunity__c, Warm_Lead__c];
        
        Map<Id, Set<String>> mapStatuses = new Map<Id, Set<String>>();
        Map<Id, String> mapLastStatus = new Map<Id, String>();
        
        //Create query to get stage name of all the Opportunities related to WarmLead through MTM
        for(Warm_Lead_MtM__c wLMtM : [Select Warm_Lead__c, Opportunity__r.StageName from Warm_Lead_MtM__c where Warm_Lead__c IN: newWarmLeads.keySet() 
                                            AND Opportunity__c != null]) {
                
            if(!mapLastStatus.containsKey(wLMtM.Warm_Lead__c)) {
                
                //Put value in map
                mapLastStatus.put(wLMtM.Warm_Lead__c, wLMtM.Opportunity__r.StageName);
            }

            if(!mapStatuses.containsKey(wLMtM.Warm_Lead__c)) {
                
                //Put value in map
                mapStatuses.put(wLMtM.Warm_Lead__c, new Set<String>{ wLMtM.Opportunity__r.StageName });
            } else {
                
                //Put value in map
                mapStatuses.get(wLMtM.Warm_Lead__c).add( wLMtM.Opportunity__r.StageName);
            }
        }
        
        //Set the Appropriate status with each unique criteria
        for(Id warmLeadId : mapStatuses.keySet()) {
            
            //get all the statuses
            Set<String> statuses = mapStatuses.get(warmLeadId);
            
            //Variable to hold the status in priority order
            String status;

            //Check for the status and set in the order of priority
            if(statuses.contains('Closed Won'))
                status = 'Closed Won';
            else if(statuses.contains('Closed Lost'))
                status = 'Closed Lost';
            else if(statuses.contains('Active in FastTrack'))
                status = 'Active in FastTrack';
            else if(statuses.contains('Active in SlowTrack'))
                status = 'Active in SlowTrack';
            else if(statuses.contains('Initial Visit Scheduled'))
                status = 'Initial Visit Scheduled';
            else if(statuses.contains('Outreach'))
                status = 'Outreach';
            else if(statuses.contains('Prospect'))
                status = 'Prospect';
        
            //Set the status in mapLastStatus
            if(mapLastStatus.containsKey(warmLeadId) && status != null && status != '') {
                
                //Update the lead status
                mapLastStatus.put(warmLeadId, status);
            }
        }
                                    
        //loop through the the aggregate results
        for(AggregateResult aR : aRs) {
            
            //Warm Lead Id
            Id warmLeadId = Id.valueOf(String.valueOf(aR.get('warmLead')));
            Id oppId = Id.valueOf(String.valueOf(aR.get('opportunity')));

            //get the status
            String status;
            
            if(mapOpportunities.containsKey(oppId)) {
            
                //uniqueness criteria
                String uniquenessCriteria = mapOpportunities.get(oppId).AccountId + '-' + mapOpportunities.get(oppId).Program__c;
            }
            
            //Get Warm lead status
            if(mapLastStatus.containsKey(warmLeadId)) {
            
                //Status
                status = mapLastStatus.get(warmLeadId);             
            }
            
            //Set values in Warm lead record
            if(mapWarmLead.containsKey(warmLeadId)) {
                
                //Set variables
                if(aR.get('totalPAs') != null) {
                    if(mapWarmLead.get(warmLeadId).Total_PAs_Warm_Lead__c != null)
                        mapWarmLead.get(warmLeadId).Total_PAs_Warm_Lead__c += Integer.valueOf(aR.get('totalPAs'));
                    else
                        mapWarmLead.get(warmLeadId).Total_PAs_Warm_Lead__c = Integer.valueOf(aR.get('totalPAs'));
                }
                
                if(aR.get('totalVisits') != null) {
                    if(mapWarmLead.get(warmLeadId).Total_Visits_Warm_Lead__c != null)
                        mapWarmLead.get(warmLeadId).Total_Visits_Warm_Lead__c += Integer.valueOf(aR.get('totalVisits'));
                    else
                        mapWarmLead.get(warmLeadId).Total_Visits_Warm_Lead__c = Integer.valueOf(aR.get('totalVisits'));
                }
                
                if(aR.get('totalOC') != null) {
                    if(mapWarmLead.get(warmLeadId).Total_Outreach_Warm_Lead__c != null)
                        mapWarmLead.get(warmLeadId).Total_Outreach_Warm_Lead__c += Integer.valueOf(aR.get('totalOC'));
                    else
                        mapWarmLead.get(warmLeadId).Total_Outreach_Warm_Lead__c = Integer.valueOf(aR.get('totalOC'));
                }

                //Set the status
                if(status != null)
                    mapWarmLead.get(warmLeadId).Status_of_Related_Opportunity__c = status;
            } else {
                
                //Add new record to update
                mapWarmLead.put(warmLeadId, new Warm_Lead__c(Id = warmLeadId,  Total_PAs_Warm_Lead__c = Integer.valueOf(aR.get('totalPAs')),
                                                                                Total_Visits_Warm_Lead__c = Integer.valueOf(aR.get('totalVisits')),
                                                                                Total_Outreach_Warm_Lead__c = Integer.valueOf(aR.get('totalOC')),
                                                                                Status_of_Related_Opportunity__c = status));
            }
        }
        
        //Set the record back to list to update
        warmLeads = mapWarmLead.values();
        
        //Update the Warm Lead records as well 
        if(warmLeads.size() > 0) {
            
            //Set the execution flag to true
            WarmLeadTriggerHelper.EXECUTE_TRIGGER_CREATE_MATCHING_WARM_LEADS_MTM = false;
    
            //Update records
            update warmLeads;
        }
    }
    
    //Static variable to hold teh opportunity Ids related to Warm Lead. 
    //This is being used in updating the Warm lead Info on Opportunity once the Warm Lead is deleted
    public static Set<Id> beforeDeleteOppIds = new Set<Id>();
    
    /**
     *  @description    :   This method is used for Update related Warm Lead MtM's Opportunity field Count of Sourced Warm Leads on  
     *                      delete of Warm Leads.(Bhavi) - 12/09/2013 - CR-20130417-2892
     *
     *  @param          :   List<Warm_Lead__c>, Boolean
     *
     *  @return         :
     *
     **/
    public static void populateOpportunityCountOfSourcedWarmLead(List<Warm_Lead__c> oldWarmLeads, Boolean isBefore) {
        
        //Check if event type is before, then populate the opportunitis list
        if(isBefore) {
            
            //List to hold delete the WarmLeadMtMs
            for(Warm_Lead_MtM__c wLMtM : [SELECT Id, Opportunity__c FROM Warm_Lead_MtM__c WHERE Warm_Lead__c IN: oldWarmLeads AND Opportunity__c != null])
                beforeDeleteOppIds.add(wLMtM.Opportunity__c);
        } else {
            
            //Update opportunity info
            if(beforeDeleteOppIds.size() > 0)
                WarmLeadMtMTriggerHelper.updateWarmLeadInfoOnOpportunity(beforeDeleteOppIds);               
        }
    }
    
    /**
     *  @description    :   This method is used for Update related Warm Lead MtM's Opportunity field Count of Sourced Warm Leads on  
     *                      update of Lead date of Warm Leads.(Bhavi) - 12/09/2013 - CR-20130417-2892
     *
     *  @param          :   List of new warm leads
     *
     *  @return         :
     *
     **/
    public static void populateOpportunityCountOfSourcedWarmLead(List<Warm_Lead__c> warmLeads, Map<Id, Warm_Lead__c> mapOldWL) {
        
        //Set to hold the WL ids where lead date has been changed
        Set<Id> wLIds = new Set<Id>();
        
        //Loop through the WL and check if lead date has been changed on any record
        for(Warm_Lead__c wL : warmLeads) {
            
            //Check if lead date has been changed
            if(wl.Lead_Date__c != mapOldWL.get(wl.Id).Lead_Date__c)
                wLIds.add(wL.Id);
        }
        
        //Get the Opportunities and Update
        if(wLIds.size() > 0) {
            
            //Fetch related opportunities and update
            Set<Id> oppIds = new Set<Id>();
            
            //List to hold delete the WarmLeadMtMs
            for(Warm_Lead_MtM__c wLMtM : [SELECT Id, Opportunity__c FROM Warm_Lead_MtM__c WHERE Warm_Lead__c IN: warmLeads AND Opportunity__c != null])
                oppIds.add(wLMtM.Opportunity__c);
        
            //Update opportunity info
            if(oppIds.size() > 0)
                WarmLeadMtMTriggerHelper.updateWarmLeadInfoOnOpportunity(oppIds);
        }
    }
    
    //Modified By - Abhinav Sharma - 08/06/2014 - CR-20140610-5761
    /**
     *  @decription :   This method is to update the Lead Info on WL's related contact record
     *
     *  @args       :   List of new warm leads, Map of old warm leads
     *
     *  @return     :   void
     *
     **/
    public static void updateLeadInfoOnContact(List<Warm_Lead__c> newWarmLeads, Map<Id, Warm_Lead__c> mapOldWarmLeads) {
        
        //Set to hold Contact Ids
        Set<Id> setContactIds = new Set<Id>();
        
        //List to hold the current Context Warm Leads
        List<Warm_Lead__c> listWLs = newWarmLeads != null ? newWarmLeads : mapOldWarmLeads.values();

        //Loop through the records list and populate the setContactIds
        for(Warm_Lead__c wL : listWLs) {

            //If trigger is executing in case of update, Check old and new value before executing the login
            //Run always for insert and delete
            if((newWarmLeads != null && mapOldWarmLeads != null 
                        && (wL.Lead_Date__c != mapOldWarmLeads.get(wL.Id).Lead_Date__c 
                            || 
                            wL.Lead_Channel__c != mapOldWarmLeads.get(wL.Id).Lead_Channel__c
                            ||
                            wL.Contact__c != mapOldWarmLeads.get(wL.Id).Contact__c)
                        )
                    || (newWarmLeads != null && mapOldWarmLeads == null && wL.Lead_Date__c != null && wL.Lead_Channel__c != null)
                    || (newWarmLeads == null && mapOldWarmLeads != null && wL.Lead_Date__c != null && wL.Lead_Channel__c != null)
                ) {

                //This should be processed
                setContactIds.add(wL.Contact__c);
                
                //If Contact has been updated on WL, then update the Old Contact as well
                if(newWarmLeads != null && mapOldWarmLeads != null && mapOldWarmLeads.get(wL.Id).Contact__c != null)
                    setContactIds.add(mapOldWarmLeads.get(wL.Id).Contact__c);
            }
        }

        //Chech set size before executing the query
        if(setContactIds.size() == 0)
            return; 
            
        //Map to hold the lead events preceedings 
        Map<String, Integer> mapLeadEvents = Constants.MAP_WARM_LEAD_EVENTS;

        //Map to hold the contact Id as value and Warm Lead record as value
        Map<Id, Warm_Lead__c> mapContactIdWithWarmLead = new Map<Id, Warm_Lead__c>();
        
        //Loop through warm lead records
        for(Warm_Lead__c wLead : [SELECT Id, Lead_Date__c, Lead_Channel__c, Contact__c FROM Warm_Lead__c
                                    WHERE Contact__c != null AND Contact__c IN : setContactIds  
                                    AND Lead_Channel__c != null AND Lead_Channel__c IN : mapLeadEvents.keySet()
                                    AND Lead_Date__c != null AND Lead_Date__c = LAST_N_DAYS:45 
                                    ORDER BY Lead_Date__c DESC]) {
            
            //Checking if map contains the key and accordinngly populating the map
            if(!mapContactIdWithWarmLead.containsKey(wLead.Contact__c)) {
                mapContactIdWithWarmLead.put(wLead.Contact__c, wLead);
            } else {
                //Populating the map according to the pre-defined preceedings for the Lead Channel field values
                if(mapLeadEvents != null && mapLeadEvents.get(wLead.Lead_Channel__c) < mapLeadEvents.get(mapContactIdWithWarmLead.get(wLead.Contact__c).Lead_Channel__c)) {
                    mapContactIdWithWarmLead.put(wLead.Contact__c, wLead);
                }
            }
        }
        
        //Debugging for the value
        System.debug('@@@@@@ mapContactIdWithWarmLead ' + mapContactIdWithWarmLead);
        
        //Map to hold the "Contact" records to update
        Map<Id, Contact> mapContactsForUpdate = new Map<Id, Contact>();
        
        //Query Most recent records
        for(Contact contact : [SELECT Id, Most_Recent_Lead_Date__c, Most_Recent_Lead_Event__c, 
                                    (SELECT Id FROM Warm_Leads__r 
                                        WHERE Lead_Channel__c != null AND Lead_Channel__c IN : mapLeadEvents.keySet()
                                        AND Lead_Date__c != null AND Lead_Date__c = LAST_N_DAYS:45 LIMIT 1)
                                    From Contact WHERE Id IN : setContactIds]) {
                                        
            //Only Process the record if found and
            if(contact.Warm_Leads__r.size() > 0
                && mapContactIdWithWarmLead.get(contact.id) != null
                && (contact.Most_Recent_Lead_Date__c != mapContactIdWithWarmLead.get(contact.id).Lead_Date__c 
                    || contact.Most_Recent_Lead_Event__c != mapContactIdWithWarmLead.get(contact.id).Lead_Channel__c
            )) {
            
                //Add record in the map to be updated
                contact.Most_Recent_Lead_Date__c = mapContactIdWithWarmLead.get(contact.id).Lead_Date__c ;
                contact.Most_Recent_Lead_Event__c = mapContactIdWithWarmLead.get(contact.id).Lead_Channel__c;
                mapContactsForUpdate.put(contact.Id, contact);
                
            } else if(contact.Warm_Leads__r.size() == 0 && (contact.Most_Recent_Lead_Date__c != null || contact.Most_Recent_Lead_Event__c != null)) {
                
                //Update with Null
                //Add record in the map to be updated
                contact.Most_Recent_Lead_Date__c = null;
                contact.Most_Recent_Lead_Event__c = null;
                mapContactsForUpdate.put(contact.Id, contact);
            }
        }
        
        //Debugging for the value
        System.debug('@@@@@ mapContactsForUpdate ' + mapContactsForUpdate.values());
        
        //Only update the records if there any
        if(mapContactsForUpdate.values().size() > 0) {
            
            //Do not execute other triggers
            Util.BypassAllTriggers = true;
            update mapContactsForUpdate.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
    /**
     *  @description    :   Method to populate "Initial Visit Date" field on Warm Lead with the associated Warm Lead MtM records minimum "Opportunity Initial Visit" field value.
     *
     *  @args           :   List of Warm Lead
     *
     *  @return         :   void
     *
     **/
    public static void populateInitialVisitDate(List<Warm_Lead__c> newWarmLeads, Map<Id, Warm_Lead__c> mapOldWarmLead) {
      
        //Map of Warm Leads
        Map<Id, Warm_Lead__c> mapWarmLeads = new Map<Id, Warm_Lead__c>();
        
        //Loop through eligible warm lead records and populating map accordingly
        for(Warm_Lead__c wLead : newWarmLeads) {
            
            //Added change condition By Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
            if(mapOldWarmLead == null || wLead.Initial_Visit_Date__c != mapOldWarmLead.get(wLead.Id).Initial_Visit_Date__c){
            	mapWarmLeads.put(wLead.Id, new Warm_Lead__c(Id = wLead.Id, Initial_Visit_Date__c = null));
            }
        }
        
        //Check for size value
        if(mapWarmLeads.size() > 0) {
            
            //Loop through aggregate results for finding minimum "Opportunity Initial Visit" field value for the Warm Lead MTM records
            for(AggregateResult aResult : [SELECT MIN(Opportunity_Initial_Visit__c) minInitialVisit, Warm_Lead__c FROM Warm_Lead_MtM__c 
                                                WHERE Warm_Lead__c != null AND Warm_Lead__c IN: mapWarmLeads.keyset() GROUP BY Warm_Lead__c]) {
                
                //Getting warm lead id value
                Id warmLeadId = (Id)aResult.get('Warm_Lead__c'); 
                
                //Checking and setting minimum "Opportunity Initial Visit" field value for the associated warm lead records
                if(mapWarmLeads.containsKey(warmLeadId) && mapWarmLeads.get(warmLeadId) != null)
                    mapWarmLeads.get(warmLeadId).Initial_Visit_Date__c = (Date)aResult.get('minInitialVisit');
            }
        }
        
        //Loop through eligible warm lead records and populating map accordingly
        for(Warm_Lead__c wL : newWarmLeads) {
            
            //Checking & populating initial visit date accordingly
            if(mapWarmLeads.containsKey(wL.Id))     
                wL.Initial_Visit_Date__c = mapWarmLeads.get(wL.Id).Initial_Visit_Date__c;
        }
    }    
    
    /**
     * 
     * @description: if source interaction and outcome type are populated, 
     *               default fields based on the custom setting and related source interaction
     * 
     **/
    public static void populateDefaultValues(List<Warm_Lead__c> newWarmLeads) {
        //Commented by Mahendra Swarnkar - 06/18/2019 - CR-20190524-13150
        //set<Id> interactionIds = new set<Id>();
        //map<Id, Relationship_Interaction__c> interactionMap = new map<Id, Relationship_Interaction__c>();
        
        for (Warm_Lead__c lead : newWarmLeads) {
            if(lead.Source_Interaction__c != null) 
            {
                //interactionIds.add(lead.Source_Interaction__c);
            }
        }
        
        //if (interactionIds.size() > 0) 
            //interactionMap = new map<Id, Relationship_Interaction__c>([SELECT Id, Interaction_Type__c, Institution__c, Primary_Contact__c FROM Relationship_Interaction__c WHERE Id IN :interactionIds]);
        
        for (Warm_Lead__c lead : newWarmLeads) {
            if(lead.Source_Interaction__c != null && 
               lead.Outcome_Type__c != null && 
               lead.Outcome_Type__c.equalsIgnoreCase(Label.OutcomesProductLeadOAB)) 
            {
                //get the outcome warm lead default custom setting
                Outcome_WarmLead__c warmLeadDefaults = Outcome_WarmLead__c.getInstance(Label.OutcomesProductLeadOAB);
                
                if (warmLeadDefaults == null) throw new customException('No Outcome WarmLead custom setting record where name is \'' + Label.OutcomesProductLeadOAB + '\'');
                
                //default values from custom setting
                lead.RecordTypeId = warmLeadDefaults.RecordType__c;
                lead.Lead_Date__c = date.today();
                lead.Lead_Origin__c = warmLeadDefaults.Lead_Origin__c;
                lead.Qualification_Status__c = warmLeadDefaults.Qualification_Status__c;
                lead.Grade__c = warmLeadDefaults.Grade__c;
                lead.Marketing_Associate_Assignment__c = warmLeadDefaults.Marketing_Associate_Assignment__c;
                lead.Marketer_Assignment__c = warmLeadDefaults.Marketer_Assignment__c;
                lead.Status__c = warmLeadDefaults.Status__c;
                
                //Commented by Mahendra Swarnkar - 06/18/2019 - CR-20190524-13150
                //default values from source interaction
                //Relationship_Interaction__c interaction = interactionMap.get(lead.Source_Interaction__c);
                //lead.Lead_Channel__c = (string) interaction.get(warmLeadDefaults.Lead_Event__c);
                
                /*if (lead.Account__c == null)
                    lead.Account__c = (string) interaction.get(warmLeadDefaults.Account__c);
                if (lead.Contact__c == null)
                    lead.Contact__c = (string) interaction.get(warmLeadDefaults.Contact__c);*/
            }
        }
    }
    
    //Added By - Deepak Kumawat - 11/17/2017 - CR-20171116-11784
    /**
     *  @decription     :   This method is to update the Entity should as follows:-
     *                      related Institution, then based on Primary Program, then based on Contact.
     *
     *  @args           :   List of new warm leads, Map of old warm leads
     *
     *  @return         :   void
     *
     *  @Revision Log   :   V1.1 - Subhash Garhwwal - 11/21/2017 - Step--CR11784--0--00007484 - Modified updateEntityValueOnWarmLead method according to chatter
     *                      V1.2 - Subhash Garhwal - 11/30/2017 - CR-20171122-11812 - Modified updateEntityValueOnWarmLead Logic to Update Entity assignment logic 
     **/
    public static void updateEntityValueOnWarmLead(List<Warm_Lead__c> newWarmLeads, Map<Id, Warm_Lead__c> mapOldWarmLeads) {

        //set to hold id of Account
        Set<Id> setAccountIds =  new Set<Id>();
        Set<Id> setProgramIds = new Set<Id>();
        Set<Id> setConatctIds = new Set<Id>();
    
        //Loop over the Warm lead records
        for(Warm_Lead__c warmLead : newWarmLeads) {
                
            //Subhash Garhwal - 11/21/2017 - Step--CR11784--0--00007484
            //Added change check by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
            if(mapOldWarmLeads == null || (mapOldWarmLeads != null && 
               ((warmLead.Account__c != mapOldWarmLeads.get(warmLead.Id).Account__c)
               || (warmLead.Account__c != mapOldWarmLeads.get(warmLead.Id).Account__c)
               || (warmLead.Account__c != mapOldWarmLeads.get(warmLead.Id).Account__c))))
            {
            	//Check for account
                if(warmLead.Account__c != null)
                    setAccountIds.add(warmLead.Account__c);
                if(warmLead.Primary_Program__c != null)
                    setProgramIds.add(warmLead.Primary_Program__c);
                if(warmLead.Contact__c != null)
                    setConatctIds.add(warmLead.Contact__c); 
            }
        }
    
        //Check for Size
        if(setAccountIds.size() > 0 || setProgramIds.Size() > 0 || setConatctIds.Size() > 0) {
        
            Map<Id,Account> mapAccounts = new Map<Id,Account>();
            Map<Id,Program__c> mapPrograms = new Map<Id,Program__c>();
            Map<Id,Contact> mapContacts = new Map<Id,Contact>();
            
            //Map to hold Account
            If(setAccountIds != null && setAccountIds.size() > 0)
                mapAccounts = new Map<Id,Account>([Select Id, Entity__c From Account Where Id IN : setAccountIds AND Entity__c != null]);
            
            //Map to hold Program
            if(setProgramIds != null && setProgramIds.size() > 0)
                mapPrograms = new Map<Id,Program__c>([Select Id, Entity__c From Program__c Where Id IN : setProgramIds AND Entity__c != null]);
            
            //Map to hold Contact__c
            if(setConatctIds != null && setConatctIds.size() > 0)
                mapContacts = new Map<Id,Contact>([Select Id , Entity__c From Contact Where Id IN: setConatctIds AND Entity__c != null]);
            
            //loop through Warm Lead
            for(Warm_Lead__c warmLead : newWarmLeads) {
                
                //String to hold the Entity
                String wLEntity = '';
                
                //Check for Account
                if(warmLead.Account__c != null && mapAccounts.containsKey(warmLead.Account__c))
                    wLEntity = mapAccounts.get(warmLead.Account__c).Entity__c;
                
                //Check for Entity
                if(String.isBlank(wLEntity) || wLEntity == 'All') {
                    
                    //Check for Program
                    if(warmLead.Primary_Program__c != null && mapPrograms.containsKey(warmLead.Primary_Program__c))
                        wLEntity = mapPrograms.get(warmLead.Primary_Program__c).Entity__c;  
                    
                    //Check for Entity
                    if(String.isBlank(wLEntity) || wLEntity == 'All') {
                        
                        //Check for Contact
                        if(warmLead.Contact__c != null && mapContacts.containsKey(warmLead.Contact__c))
                            wLEntity = mapContacts.get(warmLead.Contact__c).Entity__c;  
                    }
                }
                
                //Check for entity
                if(wLEntity != null)
                    warmLead.Entity__c = wLEntity;  
            }
        }
    }
    
    /**
     *  @description    :  This Method is used to populate contact's Account 
     * 
     *  @args           :   List<Warm_Lead__c> newWarmLeads
     * 
     *  @return         :   void
     * 
     *  @revision log   :   V1.0 Created By - Dipesh Gupta - 03/20/2020 - CR-20191210-13556(Warm lead lookup field on Event)
     *                    
     **/
    
    public static void prepopulateAccountOnWarmLead(List<Warm_Lead__c> newWarmLeads)
    {
        Set<Id> setOfContactIds = new Set<Id>();
        Set<Id> setOfEventIds = new Set<Id>();
        Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
        Map<Id,Event> mapOfEvent = new Map<Id,Event>();
            
        for(Warm_Lead__c wL : newWarmLeads)
        {
            if(wL.Contact__c != null && wL.Account__c == null && wL.Event_Id__c != null)
            {
                setOfContactIds.add(wL.Contact__c);
                setOfEventIds.add(wL.Event_Id__c);
            }
        }
        
        if(setOfContactIds.size() > 0)
        {
            for(Contact con : [SELECT Id,AccountId FROM Contact WHERE Id IN : setOfContactIds AND AccountId != null])
            {
                if(!mapOfContact.containsKey(con.Id)){
                	mapOfContact.put(con.Id,con);    
                }
            }
        }
        if(setOfEventIds.size() > 0)
        {
            for(Event event : [SELECT Id,WhatId,WhoId,What.Type FROM Event WHERE Id IN : setOfEventIds]){
            	if(!mapOfEvent.containsKey(event.Id)){
                	mapOfEvent.put(event.Id,event);    
                }      
            }
        }  
        if(mapOfEvent.size() > 0)
        {
            for(Warm_Lead__c wL : newWarmLeads)
            {
                if(mapOfEvent.containsKey(wL.Event_Id__c))
                {
                    if(mapOfEvent.get(wL.Event_Id__c).What.Type == 'Account')
                    {
                        if(String.isNotBlank(mapOfEvent.get(wL.Event_Id__c).WhatId)){
                            wL.Account__c =  mapOfEvent.get(wL.Event_Id__c).WhatId;     
                        }     
                    }
                    else
                    {
                        if(mapOfContact.containsKey(wL.Contact__c))
                        {
                            if(String.isNotBlank(mapOfContact.get(wL.Contact__c).AccountId)){
                                wL.Account__c =  mapOfContact.get(wL.Contact__c).AccountId;     
                            }  
                        }    
                    }
                }
                else
                {
                    if(mapOfContact.containsKey(wL.Contact__c))
                    {
                        if(String.isNotBlank(mapOfContact.get(wL.Contact__c).AccountId)){
                            wL.Account__c =  mapOfContact.get(wL.Contact__c).AccountId;     
                        }  
                    }
                }
            }    
        }
    }
}