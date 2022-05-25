//Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Removed the Reference of Activity Field from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018

trigger triggerRecordEventUpdate on Event (after update) {

    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;  

    try {
      
      if(EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
        return;
        
        if(SFListenerHelper.TriggerIsRunning) return;
    
        Map<ID, Event> oldEvents = Trigger.oldMap;
        List<Event_Queue__c> queues = new List<Event_Queue__c>();
        Set<ID> userIds = new Set<ID>();
        for(Event event : Trigger.new) {
            Boolean hasAction = false;
    
            Event_Queue__c q = new Event_Queue__c();
            q.Event_Id__c = event.Id;
            Event oldEvent = oldEvents.get(event.Id);
    
            if(event.Cancelled_Did_Not_Occur__c) {
                if(!oldEvent.Cancelled_Did_Not_Occur__c) {
                    hasAction = true;
                    q.Exchange_Email__c = oldEvent.OwnerId + '';
                    if(!userIds.Contains(oldEvent.OwnerId))
                        userIds.Add(oldEvent.OwnerId);
                    q.Exchange_Action__c = 'Delete';
                }
            }
            else if(!event.Exclude_From_Exchange_Synch__c) {
                hasAction = true;
                q.Exchange_Email__c = event.OwnerId + '';
                if(!userIds.Contains(event.OwnerId))
                    userIds.Add(event.OwnerId);
                q.Exchange_Action__c = 'Upsert';
            } else {
                q.Exchange_Action__c = null;
            } 
    
           /* if(!event.Gotomeeting__c && !oldEvent.Gotomeeting__c) {
                // Do nothing for gotomeeting
                q.Gotomeeting_Action__c = null;
            }
            else if(event.Gotomeeting__c && !oldEvent.Gotomeeting__c && event.Gotomeeting_Id__c == null) {
                // Create Gotomeeting
                hasAction = true;
                q.Gotomeeting_Action__c = 'Create';
            }
            else if(!event.Gotomeeting__c && oldEvent.Gotomeeting__c) {
                // To delete the gotomeeting if it is created already.
                if(oldEvent.Gotomeeting_Id__c != null) {
                    hasAction = true;
                    q.Gotomeeting_Action__c = 'Clear';
                    q.Gotomeeting_Organizer__c = oldEvent.Gotomeeting_Organizer_Id__c;
                    q.Gotomeeting_Url__c = oldEvent.Gotomeeting_Url__c;
                    q.Gotomeeting_Hash__c = oldEvent.Gotomeeting_Hash__c;
                }
            }
            else if(event.Gotomeeting__c && oldEvent.Gotomeeting__c) {
                if(event.Gotomeeting_Organizer_Id__c != oldEvent.Gotomeeting_Organizer_Id__c && event.Gotomeeting_Id__c == null) {
                    // Change organizer, we will delete old one and create a new one
                    if(oldEvent.Gotomeeting_Id__c != null) {
                        // Clear Gotomeeting from Event
                        hasAction = true;
                        q.Gotomeeting_Action__c = 'Recreate';
                        q.Gotomeeting_Organizer__c = oldEvent.Gotomeeting_Organizer_Id__c;
                        q.Gotomeeting_Url__c = oldEvent.Gotomeeting_Url__c;
                        q.Gotomeeting_Hash__c = oldEvent.Gotomeeting_Hash__c;
                    } else {
                        // Create Gotomeeting
                        hasAction = true;
                        q.Gotomeeting_Action__c = 'Create';
                    }
                    break;
                }
    
                String hash = G2MEventControllerExt.GetEventHash(event);
                if(oldEvent.Gotomeeting_hash__c != hash && event.Gotomeeting_Id__c != null) {
                    hasAction = true;
                    q.Gotomeeting_Action__c = 'Update';
                }
            }*/
    
            if(hasAction) queues.Add(q);
        }
    
        if(!queues.isEmpty()) {
            // Lookup Emails
            if(!userIds.isEmpty()) {
                Map<ID,User> users = new Map<ID,User>(
                    [SELECT email FROM User WHERE ID in :userIds]
                );
                for(Event_Queue__c q : queues) {
                    if(q.Exchange_Email__c != null && users.ContainsKey(q.Exchange_Email__c))
                        q.Exchange_Email__c = users.get(q.Exchange_Email__c).Email;
                }
            }
    
            insert queues;
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