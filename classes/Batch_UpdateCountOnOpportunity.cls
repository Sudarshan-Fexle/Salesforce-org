/**
     *  @description    :   Batch to Update the opportunity field on the basis of event
     * 
     *  @args           :   List<Event>, Map<Id, Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Neha Sharma - CR-20210202-14862 - 4/12/2021
     **/
global class Batch_UpdateCountOnOpportunity implements Database.Batchable<SObject>, Database.Stateful 
{
    public string Query = null;
        // Start(Database.BatchableContext) method from Database.Batchable class
	global Database.queryLocator start(Database.BatchableContext ctx)
	{
        Set<String> eligibleRT = new Set<String>{'EAB Initiating','Royall'};

        if(Query == null) {

            Query ='Select Id,CreatedDate,recordType.Name,Initial_Visit_Date_Ipv_Web__c from opportunity where (CreatedDate = LAST_N_YEARS:3 or CreatedDate = THIS_YEAR) and recordType.Name IN: eligibleRT ';
       
        }

        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext ctx, List<Opportunity> listOfopportunity)
	{
         if(listOfopportunity.size() > 0) {
             
             //Map to hold the opportunities
            Map<Id, Opportunity> mapExistingOpportunities = new Map<Id, Opportunity>();
             
            //Map to hold the opportunities
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
            DateTime BatchStartDateTime = System.now();
             
             for(Opportunity opp : listOfopportunity){
                 mapExistingOpportunities.put(opp.Id,opp);
             }
             
                //Get all sales Events related to opportunity
                for(Event e : [Select Id, Subject, WhatId, StartDateTime,ActivityDate,Cancelled_Did_Not_Occur__c,EndDate, Event_Type__c, Event_Purpose__c 
                               FROM Event WHERE Cancelled_Did_Not_Occur__c = False and whatId IN:listOfopportunity 
                               AND (Event_Type__c = 'In Person Visit' OR Event_Type__c = 'Phone Appointment' OR Event_Type__c = 'Web Visit' )])
                {
                    if(!mapOpportunities.containsKey(e.WhatId))
                    {
                        mapOpportunities.put(e.WhatId, new Opportunity(Id = e.WhatId,Total_Completed_Activities__c = 0, Total_Upcoming_Activities__c = 0,  
                                                                       Total_In_Person_Activities__c = 0, Num_Total_PAs__c = 0 ,Total_Web_Activities__c = 0,
                                                                       Total_Phone_Activities__c = 0, Total_Activities__c = 0,Total_Follow_Up_Visits__c=0,
                                                                       Scheduled_Visits__c = 0,Total_Initial_Activities__c = 0,Scheduled_Follow_Up_Visits__c=0,
                                                                       Num_Total_Visits__c = 0,Scheduled_Initial_Activities__c=0,Number_of_Follow_Up_Activities__c=0));
                    }
                    
                    if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'Phone Appointment' 
                       || e.Event_Type__c == 'In Person Visit') && e.EndDate < system.today()) {
                           
                           mapOpportunities.get(e.WhatId).Total_Completed_Activities__c = mapOpportunities.get(e.WhatId).Total_Completed_Activities__c+1;
                       }   
                    
                    if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'Phone Appointment' 
                       || e.Event_Type__c == 'In Person Visit') && e.EndDate > system.today()) {
                        mapOpportunities.get(e.WhatId).Total_Upcoming_Activities__c = mapOpportunities.get(e.WhatId).Total_Upcoming_Activities__c + 1;
                    }
                     
                    if( e.Event_Type__c == 'In Person Visit') {
                        mapOpportunities.get(e.WhatId).Total_In_Person_Activities__c = mapOpportunities.get(e.WhatId).Total_In_Person_Activities__c+ 1;
                    }
                    
                    if( e.Event_Type__c == 'Web Visit') {
                        mapOpportunities.get(e.WhatId).Total_Web_Activities__c = mapOpportunities.get(e.WhatId).Total_Web_Activities__c+1;
                    }
                    
                    if( e.Event_Type__c == 'Phone Appointment') {
                        mapOpportunities.get(e.WhatId).Total_Phone_Activities__c = mapOpportunities.get(e.WhatId).Total_Phone_Activities__c + 1;
                    }
                    
                     if(e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'Phone Appointment' 
                       || e.Event_Type__c == 'In Person Visit') {
                           mapOpportunities.get(e.WhatId).Total_Activities__c =  mapOpportunities.get(e.WhatId).Total_Activities__c+1;
                       } 
 
                  if(e.StartDateTime > BatchStartDateTime) {
                        
                        if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                            && (e.Event_Purpose__c == 'Follow Up' || e.Event_Purpose__c == 'Initial'))
                        {
                            mapOpportunities.get(e.WhatId).Scheduled_Visits__c =  mapOpportunities.get(e.WhatId).Scheduled_Visits__c+1;
                        }
                        if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                           && e.Event_Purpose__c == 'Follow Up')
                        {
                           mapOpportunities.get(e.WhatId).Scheduled_Follow_Up_Visits__c =  mapOpportunities.get(e.WhatId).Scheduled_Follow_Up_Visits__c+1; 
                        }
                        
                    }
                    if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') 
                       && e.Event_Purpose__c == 'Follow Up' )
                    {
                        mapOpportunities.get(e.WhatId).Total_Follow_Up_Visits__c =  mapOpportunities.get(e.WhatId).Total_Follow_Up_Visits__c+1;
                    }
                    
                     if(e.Event_Type__c == 'Phone Appointment' && e.Cancelled_Did_Not_Occur__c == false)
                    {
                        mapOpportunities.get(e.WhatId).Num_Total_PAs__c =  mapOpportunities.get(e.WhatId).Num_Total_PAs__c+1;
                    }
                    
                    
                     if((e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit') && e.Event_Purpose__c == 'Initial' )
                    {
                         mapOpportunities.get(e.WhatId).Num_Total_Visits__c =  mapOpportunities.get(e.WhatId).Num_Total_Visits__c+1; 
                    }
                    if(e.Event_Type__c == 'Web Visit' && e.Event_Purpose__c == 'Follow up')
                    {
                        mapOpportunities.get(e.WhatId).Num_Total_Visits__c =  mapOpportunities.get(e.WhatId).Num_Total_Visits__c+1; 
                    }
                    if(e.ActivityDate > System.today() && e.Event_Purpose__c =='Initial' &&  (e.Event_Type__c == 'In Person Visit' || e.Event_Type__c == 'Phone Appointment'|| e.Event_Type__c == 'Web Visit')) {
                       
                            mapOpportunities.get(e.WhatId).Scheduled_Initial_Activities__c = mapOpportunities.get(e.WhatId).Scheduled_Initial_Activities__c + 1;    
                    }
                    if ((mapExistingOpportunities.get(e.WhatId).Initial_Visit_Date_Ipv_Web__c < e.EndDate )&& (e.Event_Type__c == 'Web Visit' || e.Event_Type__c == 'In Person Visit')) {
                    
                        mapOpportunities.get(e.WhatId).Number_of_Follow_Up_Activities__c = mapOpportunities.get(e.WhatId).Number_of_Follow_Up_Activities__c+1;
                    }
                    if(e.Event_Purpose__c =='Initial' &&  (e.Event_Type__c == 'In Person Visit' || e.Event_Type__c == 'Phone Appointment'|| e.Event_Type__c == 'Web Visit')) {
                       
                            mapOpportunities.get(e.WhatId).Total_Initial_Activities__c = mapOpportunities.get(e.WhatId).Total_Initial_Activities__c + 1;    
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


	global void finish(Database.BatchableContext ctx)
	{
		
	}
}