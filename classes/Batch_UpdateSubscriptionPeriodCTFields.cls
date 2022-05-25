/**
*  Description     :   This batch class is used to update CT fields of Subscription Period 

*  Created By      :   Mahendra Swarnkar
*
*  Created Date    :   06/08/2020
*
*  Current Version :   v1.0
*       
*  Revision Log    :   V_1.0 Created - Mahendra Swarnkar - 06/08/2020 - CR-20200505-14017 - Enhance efficiency of SP CT fields
*					  
**/
global class Batch_UpdateSubscriptionPeriodCTFields implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'SELECT Id, Name, CT_Date_PA_Happens__c, CT_Date_Visit_Happens__c, CT_Previous_CT_Member__c,Previous_Subscription_Period__c, Previous_Subscription_Period__r.CT_Assignment__c, CT_Date_Passed__c FROM Subscription_Period__c'+
            		   ' WHERE Pool_Year__c >= \''+'2019\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Subscription_Period__c> subscriptionPeriodList) 
    {
        //List of Subscription Period to be updated 
        Map<Id, Subscription_Period__c> mapOfSubscriptionPeriodToBeUpdate = new Map<Id, Subscription_Period__c>(); 
        
        for(Subscription_Period__c sp : subscriptionPeriodList) {
            
            if(sp.Previous_Subscription_Period__c != null && sp.Previous_Subscription_Period__r.CT_Assignment__c != null)
            	mapOfSubscriptionPeriodToBeUpdate.put(sp.Id, new Subscription_Period__c (Id = sp.Id, CT_Previous_CT_Member__c = 'Yes'));
            else {
                if(String.isNotBlank(sp.CT_Previous_CT_Member__c) && sp.CT_Previous_CT_Member__c == 'Yes'){
                    mapOfSubscriptionPeriodToBeUpdate.put(sp.Id, new Subscription_Period__c (Id = sp.Id, CT_Previous_CT_Member__c = 'No'));
                }
            }
        }
        
        Map<Id, List<Event>>  mapOfSubscriptionPeriodIdWithEvent = new Map<Id, List<Event>>();
        
        for(Event evt : [SELECT Id, WhatId, StartDateTime, Event_Type__c, Event_Purpose__c 
                         FROM Event 
                         WHERE WhatId IN : subscriptionPeriodList 
                         AND RecordType.DeveloperName = 'Core_AM'
                         AND (
                             Event_Type__c =: 'Phone Appointment'
                             OR Event_Type__c =: 'In Person Visit'
                         )
                         AND Event_Purpose__c =: 'Chairman\''+'s Team'
                         AND Cancelled_Did_Not_Occur__c = false
                         ORDER BY StartDateTime  DESC])
        {
            
            if(!mapOfSubscriptionPeriodIdWithEvent.containsKey(evt.WhatId))
                mapOfSubscriptionPeriodIdWithEvent.put(evt.WhatId, new List<Event>());
            else
                mapOfSubscriptionPeriodIdWithEvent.get(evt.WhatId).add(evt); 
        }
        
        if(mapOfSubscriptionPeriodIdWithEvent.size() > 0)
        {
            for(Subscription_Period__c sP : subscriptionPeriodList)
            {
                if(sP.CT_Date_Passed__c != null) {
                    
                    Date cTDatePass = sP.CT_Date_Passed__c;
                    Date cTDatePassedStart = cTDatePass.addMonths(-1);
                    Date cTDatePassedEnd = cTDatePass.addMonths(12);
                    
                    if(mapOfSubscriptionPeriodIdWithEvent.containsKey(sP.Id))
                    {
                    	for(Event evt : mapOfSubscriptionPeriodIdWithEvent.get(sP.Id)) {
                        
                        if(evt.StartDateTime > cTDatePassedStart && evt.StartDateTime <= cTDatePassedEnd) {
                            
                            if(evt.Event_Type__c == 'Phone Appointment') {
                                if(! mapOfSubscriptionPeriodToBeUpdate.containsKey(evt.WhatId) )
                                	mapOfSubscriptionPeriodToBeUpdate.put(evt.WhatId, new Subscription_Period__c (Id = evt.WhatId, CT_Date_PA_Happens__c = Date.valueOf(evt.StartDateTime)));    
                            	else
                                    mapOfSubscriptionPeriodToBeUpdate.get(evt.WhatId).CT_Date_PA_Happens__c = Date.valueOf(evt.StartDateTime);
                            }
                            
                            if(evt.Event_Type__c == 'In Person Visit'){
                                if(! mapOfSubscriptionPeriodToBeUpdate.containsKey(evt.WhatId) )
                                	mapOfSubscriptionPeriodToBeUpdate.put(evt.WhatId, new Subscription_Period__c (Id = evt.WhatId, CT_Date_Visit_Happens__c = Date.valueOf(evt.StartDateTime)));    
                            	else
                                    mapOfSubscriptionPeriodToBeUpdate.get(evt.WhatId).CT_Date_Visit_Happens__c = Date.valueOf(evt.StartDateTime);
                            }
                        }
                    }
                    }
                }
            }
        }
        
        if(mapOfSubscriptionPeriodToBeUpdate.size() > 0 && mapOfSubscriptionPeriodToBeUpdate.values() != null && mapOfSubscriptionPeriodToBeUpdate.values().size() > 0)
        {
            Util.BypassAllTriggers = true;
            update mapOfSubscriptionPeriodToBeUpdate.values();
            Util.BypassAllTriggers = false;
        }
    }   
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}