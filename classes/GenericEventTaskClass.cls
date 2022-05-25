/**
 *  Purpose         :   Helper class for the generic Event/Task
 *
 *  Created By      :   Mahendra Swarnkar
 *
 *  Created Date    :   03/24/2020
 *
 *  Revision Logs   :   V_1.0 - Created
 * 			V_1.1 - Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676
 *
 */
public without sharing class GenericEventTaskClass {

    /**
     *  @description    :   Method to update the contact field Protocoled? (Sales) .The value should be true if there is any upcoming Sales event 
     * 						records tagged to the contact, and then remain true for 30 days after the date of that event.
     * 						The checkbox should be reverted to false if there is no longer an event or task matching the above criteria.
     * 
     *  @args           :   List<Event>, Map<Id, Event>
     * 
     *  @return         :   void
     *
     *  @Revision Log   :   V1.0 - Created - Mahendra Swarnkar - CR-20200122-13648. 
     **/
    public static void genericUpdateContactProtocoledField(Set<Id> setContacts){
        
        //Get Record Type
        Id EventSalesRecordType = Util.RecordTypeId('Event', 'Sales');
        
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        //Get Record Type
        //Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Task PT Marketing');
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - End Here
        
        Map<String, Set<String>> mapEventTypeWithEventPurpose = new Map<String, Set<String>>();
        mapEventTypeWithEventPurpose.put('In Person Visit', new Set<String> {'Initial', 'Follow Up', 'Relationship Visit'});
        mapEventTypeWithEventPurpose.put('Phone Appointment', new Set<String> {'Initial', 'Follow Up', 'Prewire'});
        mapEventTypeWithEventPurpose.put('Web Visit', new Set<String> {'Initial', 'Follow Up'});
        
        //List to update contact
        Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
        
        //Size check
        if(setContacts.size() > 0){
            
            //Map of events
            List<Event> listOfEvents = [SELECT Id, EndDateTime, Event_Type__c, Event_Purpose__c, 
                                        Cancelled_Did_Not_Occur__c, RecordTypeId, WhoId, Who.Type 
                                        From Event 
                                        Where WhoId IN :setContacts
                                        AND Who.Type = 'Contact' 
                                        AND EndDateTime != null 
                                        AND RecordTypeId =: EventSalesRecordType  
                                        AND Event_Type__c IN: mapEventTypeWithEventPurpose.keySet()
                                        AND Cancelled_Did_Not_Occur__c = false
                                        AND (EndDateTime = LAST_N_DAYS:30 OR EndDateTime >= Today)];
            //Map of events
            List<Task> listOfTasks = [SELECT Id, ActivityDate, Event_Type__c, Event_Purpose__c, 
                                      Cancelled_Did_Not_Occur__c, RecordTypeId, WhoId, Who.Type 
                                      From Task 
                                      Where WhoId IN :setContacts
                                      AND Who.Type = 'Contact' 
                                      AND ActivityDate != null 
                                      AND RecordTypeId =: taskPTMarketingRecordType  
                                      //AND Event_Type__c IN: mapEventTypeWithEventPurpose.keySet()
                                      //AND Cancelled_Did_Not_Occur__c = false
                                      AND (ActivityDate = LAST_N_DAYS:14 OR ActivityDate >= Today)];
            
            // Modified for CR-20200506-14021
            //Check for list of event size
            if(listOfEvents.size() > 0){
                
                //Map of contacts related to events
                Map<Id, List<EventWhoRelation>> mapOfContacts = new Map<Id, List<EventWhoRelation>>();
                
                //Loop over EventWhoRelation   
                for(EventWhoRelation evtWhoRel: [SELECT RelationId, EventId FROM EventWhoRelation WHERE EventId IN: listOfEvents ]){
                    
                    if(!mapOfContacts.containsKey(evtWhoRel.EventId))
                        mapOfContacts.put(evtWhoRel.EventId, new List<EventWhoRelation>());
                    
                    mapOfContacts.get(evtWhoRel.EventId).add(evtWhoRel);
                }
                
                if(listOfEvents.size() > 0  && mapOfContacts.values().size() > 0){
                    
                    //Loop over related events
                    for (Event evt : listOfEvents){  
                        
                        if(mapOfContacts.containsKey(evt.Id) && mapOfContacts.get(evt.Id) != null){
                            
                            //Loop over related contact
                            for(EventWhoRelation contRelation : mapOfContacts.get(evt.Id)){
                                
                                //Condition ActivityDate should be either less than 30 days from today
                                if(evt.RecordTypeId == EventSalesRecordType){
                                    
                                    DateTime daysString = evt.EndDateTime.addDays(30);
                                    Boolean isProtocoled = false;
                                    
                                    if(evt.EndDateTime >= System.today() || System.today() <= daysString){ 
                                        
                                        if(mapEventTypeWithEventPurpose.containsKey(evt.Event_Type__c)  && mapEventTypeWithEventPurpose.get(evt.Event_Type__c) != null 
                                           && mapEventTypeWithEventPurpose.get(evt.Event_Type__c).contains(evt.Event_Purpose__c)) {
                                               
                                               isProtocoled = true;
                                           }	
                                    }
                                    
                                    //Check if contact is protocoled previously, if yes do nothing. or if that is not exist in map create a new Instance.
                                    if(isProtocoled)
                                        mapContactsToUpdate.put(contRelation.RelationId, new Contact(Id =  contRelation.RelationId, Protocoled_Sales__c = isProtocoled));
                                    else {
                                        if(mapContactsToUpdate.containsKey(contRelation.RelationId) && mapContactsToUpdate.get(contRelation.RelationId) != null 
                                           && mapContactsToUpdate.get(contRelation.RelationId).Protocoled_Sales__c) {
                                               //Do Nothing - If a contact is protocoled by this process then do nothing.  
                                           }else{
                                               mapContactsToUpdate.put(contRelation.RelationId, new Contact(Id =  contRelation.RelationId, Protocoled_Sales__c = isProtocoled));    
                                           }       
                                    }
                                }
                            }
                        }
                    }
                }  
            }
            
	    // Modified for CR-20200506-14021
	    //If Event list size is zero and task slist size is greater than zero.
            else if(listOfTasks.size() > 0 ){
                //Map of contacts related to events
                Map<Id, List<TaskWhoRelation>> mapOfContacts = new Map<Id, List<TaskWhoRelation>>();
                
                //Loop over TasktWhoRelation   
                for(TaskWhoRelation taskWhoRel: [SELECT RelationId, TaskId FROM TaskWhoRelation WHERE TaskId IN: listOfTasks ]){
                    
                    if(!mapOfContacts.containsKey(taskWhoRel.TaskId))
                        mapOfContacts.put(taskWhoRel.TaskId, new List<TaskWhoRelation>());
                    
                    mapOfContacts.get(taskWhoRel.TaskId).add(taskWhoRel);
                }
                
                if(listOfTasks.size() > 0  && mapOfContacts.values().size() > 0){
                    
                    //Loop over related events
                    for (Task evt : listOfTasks){  
                        
                        if(mapOfContacts.containsKey(evt.Id) && mapOfContacts.get(evt.Id) != null){
                            
                            //Loop over related contact
                            for(TaskWhoRelation contRelation : mapOfContacts.get(evt.Id)){
                                
                                //Condition ActivityDate should be either less than 30 days from today
                                if(evt.RecordTypeId == taskPTMarketingRecordType){
                                    
                                    DateTime daysString = evt.ActivityDate.addDays(14);
                                    Boolean isProtocoled = false;
                                    
                                    if(evt.ActivityDate >= System.today() || System.today() <= daysString){ 
                                        
                                        //if(mapEventTypeWithEventPurpose.containsKey(evt.Event_Type__c)  && mapEventTypeWithEventPurpose.get(evt.Event_Type__c) != null 
                                           //&& mapEventTypeWithEventPurpose.get(evt.Event_Type__c).contains(evt.Event_Purpose__c)) {
                                               
                                               isProtocoled = true;
                                           //}	
                                    }
                                    
                                    //Check if contact is protocoled previously, if yes do nothing. or if that is not exist in map create a new Instance.
                                    if(isProtocoled)
                                        mapContactsToUpdate.put(contRelation.RelationId, new Contact(Id =  contRelation.RelationId, Protocoled_Sales__c = isProtocoled));
                                    else {
                                        if(mapContactsToUpdate.containsKey(contRelation.RelationId) && mapContactsToUpdate.get(contRelation.RelationId) != null 
                                           && mapContactsToUpdate.get(contRelation.RelationId).Protocoled_Sales__c) {
                                               //Do Nothing - If a contact is protocoled by this process then do nothing.  
                                           }
                                        else{
                                            mapContactsToUpdate.put(contRelation.RelationId, new Contact(Id =  contRelation.RelationId, Protocoled_Sales__c = isProtocoled));    
                                        }       
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
            //Size check
            if(mapContactsToUpdate.size() > 0){
                
                //by pass logic
                Util.byPassAllTriggers = true;
                
                //update
                update mapContactsToUpdate.values();
                
                //by pass logic
                Util.byPassAllTriggers = false;
            }
        }    
    }
}