/**
*   Purpose         :   This class is helper class for Trigger on WarmLeadMtM.
*
*   Create By       :   Bhavi Sharma
*
*   Created Date    :   06/13/2013
*
*   Current Version :   v1.0
*
*   Revision Logs   :   v1.0 - Created - CR-20121130-1808
*                       V_1.1 - Bhavi Sharma - 12/13/2013 - Added new method()
*                       V_1.2 - Abhinav Sharma - 11/24/2014 - Added new Method(populateInitialVisitDateOnWarmLead, getWarmLeadMtmsUpdates) - CR-20141029-7923
                        V_1.3 - Abhinav Sharma - 08/28/2015 - Added new method (populatePAsAndActivityFieldsOnWarmLead, populatePAsAndActivityFields, populateFieldsOnWarmLeadMTMItself)
                        V_1.4 - Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Triggers repetative execution
                        V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.
**/
public without sharing class WarmLeadMtMTriggerHelper {
    
    //Method for validate unique Warm_Lead_MtM__c records
    public static void ValidateWarmLeadMtMData(List<Warm_Lead_MtM__c> newListWarmLeadMtMs) {
        
        //properties initialization
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> warmLeadIds = new Set<Id>();
        
        //This set is to hold the Opportunity-Warm Lead id. This value will be used as uniqueness criteria.
        Set<String> setWarmLeadOpportunities = new Set<String>();
        
        //Loop through Trigger.new records
        for(Warm_Lead_MtM__c warmLeadMtM : newListWarmLeadMtMs) {
            
            //Check for WarmLeadMtM's opportunity is not null
            if(warmLeadMtM.Opportunity__c != null) {
                
                //add opportunity into set
                opportunityIds.add(warmLeadMtM.Opportunity__c);
            }   
            
            //Check for WarmLeadMtM's WarmLead is not null
            if(warmLeadMtM.Warm_Lead__c != null) {
                
                //add warmLead into set
                warmLeadIds.add(warmLeadMtM.Warm_Lead__c);
            }
            
            //Add in set if opp and warm lead, both are not null
            if(warmLeadMtM.Opportunity__c != null && warmLeadMtM.Warm_Lead__c != null)
                setWarmLeadOpportunities.add(warmLeadMtM.Opportunity__c + '-' + warmLeadMtM.Warm_Lead__c);
        }
        
        //Added condition by Mahendra Swarnkar - 04/04/2020 - CR-20200305-13830
        if(opportunityIds.size() > 0 && newListWarmLeadMtMs.size() > 0 && warmLeadIds.size() > 0){
            
            
            //Loop through warmLeadMtMs list
            for(Warm_Lead_MtM__c warmLeadMtM : [SELECT Id, Name, Warm_Lead__c, Opportunity__c FROM Warm_Lead_MtM__c 
                                                WHERE Warm_Lead__c IN: warmLeadIds AND Opportunity__c IN: opportunityIds AND Id NOT IN: newListWarmLeadMtMs]) 
            {
                
                //uniqueKey
                String uniqueKey = warmLeadMtM.Opportunity__c + '-' + warmLeadMtM.Warm_Lead__c;
                
                //If uniqueKey is already in the set, that means there is already a MtM record associated with the same Opp and Warm Lead
                if(setWarmLeadOpportunities.contains(uniqueKey)){
                    
                    //throw exception and redirect to Duplicate record
                    throw new CustomException(Label.ERROR_UNIQUE_WLMtM_SUB_TEXT + '&nbsp;<a href = "/' + warmLeadMtM.Id + '" target="_blank">' + warmLeadMtM.Name + '</a>');
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is to update the Warm lead counter information on opportunities
     * 
     *  @args           :   Set<Id> 
     * 
     *  @return         :   void    
     * 
     **/ 
    public static void updateWarmLeadInfoOnOpportunity(Set<Id> oppIds) {
        
        /*----V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.*/
        //Single query for affected Opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([Select Id, Warm_Lead__c, /*Count_of_Warm_Leads__c*/ Initial_Visit_Date__c,
            (Select Id, Warm_Lead__r.Lead_Date__c from Warm_Leads_MtM__r WHERE Warm_Lead__c != null) from Opportunity Where Id in :oppIds]);
       
        // Loop through related Opportunities
        for (Opportunity o : mapOpportunities.values()) {
            
             /*----V_1.5 Modified By - Rajiv Jain - 02/20/2020 - CR-20200110-13605 -  Remove zzzCount of Warm Leads (Count_of_Warm_Leads__c) field of opportunity.
            // Set Count of Warm Leads on Opp equal to the number of WLMtM this Opp has associated
            o.Count_of_Warm_Leads__c = o.Warm_Leads_MtM__r.size(); */
            
            // If the Opportunities has at least one WLMtM, set the Warm Lead checkbox to true, otherwise set it to false
            if (o.Warm_Leads_MtM__r.size() > 0) 
                o.Warm_Lead__c = true;
            else
                o.Warm_Lead__c = false;
                
            //Set default
            o.Count_of_Sourced_Warm_Leads__c = 0;
            
            if(o.Initial_Visit_Date__c == null)
                o.Count_of_Sourced_Warm_Leads__c = o.Warm_Leads_MtM__r.size();
            else {
                
                if(o.Warm_Leads_MtM__r.size() > 0) {
                    
                    //Loop through WarmLeadMtm
                    for(Warm_Lead_MtM__c warmLeadMtm : o.Warm_Leads_MtM__r){
                        
                        //Check if Opportunity's Initial Visit Date is greater its Child Warm Lead's Lead Date
                        if(warmLeadMtm.Warm_Lead__r.Lead_Date__c == null || warmLeadMtm.Warm_Lead__r.Lead_Date__c < o.Initial_Visit_Date__c){
                            
                            //Check for Count_of_Sourced_Warm_Leads__c field value is not null or blank
                            if(o.Count_of_Sourced_Warm_Leads__c != null)
                                o.Count_of_Sourced_Warm_Leads__c += 1;
                            else
                                o.Count_of_Sourced_Warm_Leads__c = 1;
                        }
                    }
                }
            }
        }
        
        //Modified By - Abhinav Sharma - 10/17/2015 - CR-20151008-9304 - Setting trigger bypass flag to true while performing DML
        //Check for the size and update the opportunities
        if(mapOpportunities.size() > 0) {
            Util.byPassAllTriggers = true;
            update mapOpportunities.values();
            Util.byPassAllTriggers = false;
        }
    }
    
    //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
    /**
     *  @description    :   Method to:-
     *                      Find the minimum Initial Visit Date from all the all the MtM records related to parent warm lead and stamp it on Warm Lead’s Initial Visit Date field.
     *                      If none of the MtM record has Initial Visit date populated, set Warm Lead’s Initial Visit Date to null.
     *                      If there is no MtM record on Warm Lead, set the value to null, set Warm Lead’s Initial Visit Date to null
     *
     *  @args           :   List of Warm Lead Mtm, Map of old Warm Lead Mtm
     *
     *  @return         :   void
     *
     **/
    public static void populateInitialVisitDateOnWarmLead(List<Warm_Lead_MtM__c> newWarmLeadMtMs, Map<Id, Warm_Lead_MtM__c> mapOldWarmLeadMtMs) {
        
        //Set to hold the Warm Lead records id value
        Set<Id> warmLeadIds = new Set<Id>();
        
        //Map of warm lead
        Map<Id, Warm_Lead__c> mapWarmLeadToBeUpdated = new Map<Id, Warm_Lead__c>();
        
        //Insert or update use cases
        if(newWarmLeadMtMs != null) {
        
            //Loop through warm lead MTM records
            for(Warm_Lead_MtM__c newWarmLeadMtm : newWarmLeadMtMs) {
                
                //Check for null & adding ProjectId into set
                if(newWarmLeadMtm.Warm_Lead__c != null) 
                    warmLeadIds.add(newWarmLeadMtm.Warm_Lead__c);
                
                //Checking for fields value changes
                if(mapOldWarmLeadMtMs != null 
                    && (newWarmLeadMtm.Warm_Lead__c != mapOldWarmLeadMtMs.get(newWarmLeadMtm.Id).Warm_Lead__c
                        || newWarmLeadMtm.Opportunity__c != mapOldWarmLeadMtMs.get(newWarmLeadMtm.Id).Opportunity__c
                        || newWarmLeadMtm.Opportunity_Initial_Visit__c != mapOldWarmLeadMtMs.get(newWarmLeadMtm.Id).Opportunity_Initial_Visit__c )
                    ) {
                    if(newWarmLeadMtm.Warm_Lead__c != null)
                        warmLeadIds.add(newWarmLeadMtm.Warm_Lead__c);
                    if(mapOldWarmLeadMtMs.get(newWarmLeadMtm.Id).Warm_Lead__c != null)
                        warmLeadIds.add(mapOldWarmLeadMtMs.get(newWarmLeadMtm.Id).Warm_Lead__c);
                }
            }
        //Delete use cases
        } else {
            
            //Loop through warm lead MTM records
            for(Warm_Lead_MtM__c newWLeadMtm : mapOldWarmLeadMtMs.values()) {
                
                //Checking for null value and adding to the set accordingly
                if(newWLeadMtm.Warm_Lead__c != null)
                    warmLeadIds.add(newWLeadMtm.Warm_Lead__c);
            }
        }
        
        //Checking set for size value
        if(warmLeadIds.size() > 0)
            mapWarmLeadToBeUpdated = WarmLeadMtMTriggerHelper.getWarmLeadMtmsUpdates(warmLeadIds);
        
        //Checking for size value and updating the records
        if(mapWarmLeadToBeUpdated.size() > 0) {
            
            Util.BypassAllTriggers = true;
            update mapWarmLeadToBeUpdated.values();
            Util.BypassAllTriggers = false;
        }
    }
    
    //Added By - Abhinav Sharma - 11/24/2014 - CR-20141029-7923
    /**
     *  @description    :   Method to used as generic bunch of logic to get the updates for Warm Lead MTM's
     *
     *  @args           :   Set<Id> setWarmLeadIds
     *
     *  @return         :   void
     *
    **/
    public static Map<Id, Warm_Lead__c> getWarmLeadMtmsUpdates(Set<Id> setWarmLeadIds) {
        
        //Map of Warm Leads
        Map<Id, Warm_Lead__c> mapWarmLeads = new Map<Id, Warm_Lead__c>();
        
        //Loop through eligible warm lead records and populating map accordingly
        for(Warm_Lead__c wLead : [SELECT Id FROM Warm_Lead__c WHERE Id IN : setWarmLeadIds]) {
            mapWarmLeads.put(wLead.Id, new Warm_Lead__c(Id = wLead.Id, Initial_Visit_Date__c = null));
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
        
        //Returning map
        return mapWarmLeads;
    }
    
    //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
    /**
     *  @description    :   Method to populate "Opportunity PA Date" and "Opportunity Activity Date" fields on "Warm Lead MTM" itself.
     *
     *  @args           :   List<Warm_Lead_MtM__c> newWarmLeadMtMs
     *
     *  @return         :   void
     *
    **/
    public static void populateFieldsOnWarmLeadMTMItself(List<Warm_Lead_MtM__c> newWarmLeadMtMs) {
        
        //Set to hold the opportunity IDs
        Set<Id> setOpportunities = new Set<Id>();
        
        //Loop through warm lead mtm records
        for(Warm_Lead_MtM__c wlm : newWarmLeadMtMs) {
            if(wlm.Opportunity__c != null)
                setOpportunities.add(wlm.Opportunity__c);
        }
        
        //Checking set for size value
        if(setOpportunities.size() > 0) {
            
            //Map of opportunities
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT ID, Initial_PA_Date__c, Initial_Activity_Date__c
                                                                                FROM Opportunity
                                                                                WHERE ID IN : setOpportunities]);
            
            //Loop through warm lead MTM records
            for(Warm_Lead_MtM__c wm : newWarmLeadMtMs) {
                
                //Checking if map contains the value. if Yes, then populating fields on Warm Lead MTm records accordingly
                if(mapOpportunities !=null && wm.Opportunity__c != null
                    && mapOpportunities.containsKey(wm.Opportunity__c)
                    && mapOpportunities.get(wm.Opportunity__c) != null) {
                    
                    //Populating fields with values on Warm lead MTM
                    wm.Opportunity_Initial_PA__c = mapOpportunities.get(wm.Opportunity__c).Initial_PA_Date__c;  
                    wm.Opportunity_Initial_Activity__c = mapOpportunities.get(wm.Opportunity__c).Initial_Activity_Date__c;     
                }
            }
        }
    }
    
    //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
    /**
     *  @description    :   Method to populate "Initial PA Date" and "Initial Activity Date" fields on "Warm Lead".
     *
     *  @args           :   List<Warm_Lead_MtM__c> newWarmLeadMtMs, Map<Id, Warm_Lead_MtM__c> mapOldWarmLeadMtMs
     *
     *  @return         :   void
     *
    **/
    public static void populatePAsAndActivityFieldsOnWarmLead(List<Warm_Lead_MtM__c> newWarmLeadMtMs, Map<Id, Warm_Lead_MtM__c> mapOldWarmLeadMtMs) {
        
        //Map of Warm Leads
        Map<Id, Warm_Lead__c> mapWarmLeads = new Map<Id, Warm_Lead__c>();
            
        //Loop through warm lead mtm records
        for(Warm_Lead_MtM__c wlm : newWarmLeadMtMs != null ? newWarmLeadMtMs : mapOldWarmLeadMtMs.values()) {
            
            //Insert use case
            if(mapOldWarmLeadMtMs == null && wlm.Warm_Lead__c != null)
                mapWarmLeads.put(wlm.Warm_Lead__c, new Warm_Lead__c(ID = wlm.Warm_Lead__c,
                                                                     Initial_PA_Date__c = null,
                                                                     Initial_Activity_Date__c = null));
            
            //Update use case
            if(mapOldWarmLeadMtMs != null 
               && (
                   wlm.Warm_Lead__c != mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c
                    || wlm.Opportunity_Initial_PA__c  != mapOldWarmLeadMtMs.get(wlm.Id).Opportunity_Initial_PA__c 
                    || wlm.Opportunity_Initial_Activity__c  != mapOldWarmLeadMtMs.get(wlm.Id).Opportunity_Initial_Activity__c
                    || wlm.Opportunity__c != mapOldWarmLeadMtMs.get(wlm.Id).Opportunity__c
                  )
            ) {
                
                //Checking for null value
                if(wlm.Warm_Lead__c != null)
                    mapWarmLeads.put(wlm.Warm_Lead__c, new Warm_Lead__c(ID = wlm.Warm_Lead__c,
                                                                        Initial_PA_Date__c = null,
                                                                        Initial_Activity_Date__c = null));
            
                
                //Checking for null value        
                if(mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c != null)
                    mapWarmLeads.put(mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c, new Warm_Lead__c(ID = mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c,
                                                                                                    Initial_PA_Date__c = null,
                                                                                                    Initial_Activity_Date__c = null));
            }
            
            //Delete Case
            if(newWarmLeadMtMs == null && mapOldWarmLeadMtMs != null && mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c != null)
                mapWarmLeads.put(mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c, new Warm_Lead__c(ID = mapOldWarmLeadMtMs.get(wlm.Id).Warm_Lead__c,
                                                                                                 Initial_PA_Date__c = null,
                                                                                                 Initial_Activity_Date__c = null));  
        }
            
        //Checking set for size value
        if(mapWarmLeads.values().size() > 0) {
            
            //Populating opportunity fields values
            mapWarmLeads = populatePAsAndActivityFields(mapWarmLeads);
            
            //Checking map for size value
            if(mapWarmLeads.values().size() > 0) {
                Util.BypassAllTriggers = true;
                update mapWarmLeads.values();
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    //Added By - Abhinav Sharma - 08/28/2015 - CR-20140613-5790
    public static Map<Id, Warm_Lead__c> populatePAsAndActivityFields(Map<Id, Warm_Lead__c> mapWLeads) {
        
        //Checking map for null and size value
        if(mapWLeads != null && mapWLeads.values().size() > 0) {
            
            //Querying Warm events and accordingly populating PA's fields on related opportunity
            for(Warm_Lead_MtM__c wl : [SELECT ID, Opportunity_Initial_PA__c, Warm_Lead__c  
                                        FROM Warm_Lead_MtM__c
                                        WHERE Warm_Lead__c != null AND Warm_Lead__c IN : mapWLeads.keySet()
                                        AND Opportunity_Initial_PA__c != null]) {
                
                //Checking if map contains the key in it                        
                if(mapWLeads.containsKey(wl.Warm_Lead__c) 
                    && mapWLeads.get(wl.Warm_Lead__c) != null) {
                            
                    //Minimum Activity Date of the activities on the opportunity
                    if(mapWLeads.get(wl.Warm_Lead__c).Initial_PA_Date__c == null) {
                        mapWLeads.get(wl.Warm_Lead__c).Initial_PA_Date__c = wl.Opportunity_Initial_PA__c;
                    } else {
                        
                        if(mapWLeads.get(wl.Warm_Lead__c).Initial_PA_Date__c > wl.Opportunity_Initial_PA__c) {
                            mapWLeads.get(wl.Warm_Lead__c).Initial_PA_Date__c = wl.Opportunity_Initial_PA__c;
                        }
                    } 
                }
            }
            
            //Querying Warm events and accordingly populating PA's fields on related opportunity
            for(Warm_Lead_MtM__c wlm : [SELECT ID, Opportunity_Initial_Activity__c, Warm_Lead__c  
                                        FROM Warm_Lead_MtM__c
                                        WHERE Warm_Lead__c != null AND Warm_Lead__c IN : mapWLeads.keySet()
                                        AND Opportunity_Initial_Activity__c != null]) {
                
                //Checking if map contains the key in it                        
                if(mapWLeads.containsKey(wlm.Warm_Lead__c) 
                    && mapWLeads.get(wlm.Warm_Lead__c) != null) {
                        
                    //Minimum Activity Date of the activities on the opportunity
                    if(mapWLeads.get(wlm.Warm_Lead__c).Initial_Activity_Date__c == null) {
                        mapWLeads.get(wlm.Warm_Lead__c).Initial_Activity_Date__c = wlm.Opportunity_Initial_Activity__c;
                    } else {
                        if(mapWLeads.get(wlm.Warm_Lead__c).Initial_Activity_Date__c > wlm.Opportunity_Initial_Activity__c) {
                            mapWLeads.get(wlm.Warm_Lead__c).Initial_Activity_Date__c = wlm.Opportunity_Initial_Activity__c;
                        }
                    }     
                }
            }
        }
        return mapWLeads;        
    }
}