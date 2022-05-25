//Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//Modified By - Abhinav Sharma - 03/15/2017 - CR-20170307-10743 - Invoked "RecordEventDeleteHelper" class "restrictProfilesFromDeletingTheEvents" method
//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
///to restrict users from deleting the event records for certain profiles users
//Removed the Reference of Activity Field from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018

trigger triggerRecordEventDelete on Event (before delete, after delete) {

    //return immediately if method returns true	
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;	

    try {
    
        // bypass flag
        if (Util.BypassAllTriggers) return;
        
        //Added By - Abhinav Sharma - 03/15/2017 - CR-20170307-10743
        if(Trigger.isBefore) {
        	
            //Checking for the request type
            if(Trigger.isDelete) {
                
            	//Calling helper class method
            	RecordEventDeleteHelper.restrictProfilesFromDeletingTheEvents(trigger.new, trigger.oldMap);
            }
        } 
        
		
		if(Trigger.isAfter) {
        	
            //Checking for the request type
            if(Trigger.isDelete) {
        	
                List<Event_Queue__c> queues = new List<Event_Queue__c>();
                Set<ID> userIds = new Set<ID>();
                
                
                for(Event event : Trigger.old) {
                
                    Boolean hasAction = false;
        
                    Event_Queue__c q = new Event_Queue__c();
                    q.Event_Id__c = event.Id;
            
                    if(!event.Exclude_From_Exchange_Synch__c && !event.Cancelled_Did_Not_Occur__c) {
                    
                        hasAction = true;
                        q.Exchange_Action__c = 'Delete';
                        q.Exchange_Email__c = event.OwnerId + '';
                        if(!userIds.Contains(event.OwnerId))
                            userIds.Add(event.OwnerId);
                    } else {
                        q.Exchange_Action__c = null;
                    }
                    
                   /* if(event.Gotomeeting_Id__c != null && event.Gotomeeting_Id__c != '') {
                        hasAction = true;
                        q.Gotomeeting_Action__c = 'Delete';
                        q.Gotomeeting_Id__c = event.Gotomeeting_Id__c;
                        //q.Gotomeeting_Hash__c = event.Gotomeeting_Hash__c;
                        q.Gotomeeting_Url__c = event.Gotomeeting_Url__c;
                        q.Gotomeeting_Organizer__c = event.Gotomeeting_Organizer_Id__c;
                    } else {
                        q.Gotomeeting_Action__c = null;
                    }*/
            
                    if(hasAction)
                        queues.Add(q);
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