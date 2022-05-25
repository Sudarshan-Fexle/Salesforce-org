public class SFEventQueueProcessor {
    static integer BatchCount_GTM = 1;
    static integer BatchCount_Sync = 200;
    
    public static void AppendLastActionResult(Event_Queue__c q, String result) {
        if(q.Last_Action_Result__c == null)
            q.Last_Action_Result__c = result;
        else
            q.Last_Action_Result__c = result + '\n' + q.Last_Action_Result__c;
    }
    
    public static void ProcessGTMQueue(List<Event_Queue__c> scope) {
        if(scope == null || scope.isEmpty()) {
            scope = [SELECT Id, Event_Id__c, Exchange_Action__c, Gotomeeting_Action__c, Gotomeeting_Hash__c, Gotomeeting_Id__c,
                Gotomeeting_Organizer__c, Gotomeeting_Url__c, Last_Action_Result__c, Last_Action_Count__c
                FROM Event_Queue__c
                WHERE Last_Action_Count__c > 0 AND Processed__c = false
                Limit :BatchCount_GTM];
            if(scope.isEmpty()) return;
        }
         
        List<Event_Queue__c> g2mCreates = new List<Event_Queue__c>();
        List<Event_Queue__c> g2mUpdates = new List<Event_Queue__c>();
        List<Event_Queue__c> g2mDeletes = new List<Event_Queue__c>();
        List<Event_Queue__c> g2mRecreates = new List<Event_Queue__c>();
        List<Event_Queue__c> g2mClears = new List<Event_Queue__c>();
        for(Event_Queue__c q : scope) {
            if(q.Gotomeeting_Action__c == 'Create') {
                g2mCreates.Add(q);
            } else if(q.Gotomeeting_Action__c == 'Update') {
                g2mUpdates.Add(q);
            } else if(q.Gotomeeting_Action__c == 'Delete') {
                g2mDeletes.Add(q);
            } else if(q.Gotomeeting_Action__c == 'Recreate') {
                g2mRecreates.Add(q);
            } else if(q.Gotomeeting_Action__c == 'Clear') {
                g2mClears.Add(q);
            }
        }

        if(!g2mCreates.isEmpty()) {
            CreateGotomeetings(g2mCreates);
        }
        if(!g2mUpdates.isEmpty()) {
            UpdateGotomeetings(g2mUpdates);
        }
        if(!g2mClears.isEmpty()) {
            ClearGotomeetings(g2mClears, false);
        }
        if(!g2mDeletes.isEmpty()) {
            DeleteGotomeetings(g2mDeletes);
        }
        if(!g2mRecreates.isEmpty()) {
            ClearGotomeetings(g2mRecreates, true);
        }
    }
        
    public static void ProcessSyncQueue(List<Event_Queue__c> scope) {
        if(scope == null || scope.isEmpty()) {
            scope = [SELECT Id, Event_Id__c, Exchange_Action__c, Exchange_Email__c, Last_Action_Result__c, Last_Action_Count__c
                FROM Event_Queue__c
                WHERE Last_Action_Count__c > 0 AND Processed__c = false AND Gotomeeting_Action__c = null
                Limit :BatchCount_Sync];
            if(scope.isEmpty()) return;
        }
        
        Set<string> lookupUpdateKeys = new Set<string>();
        Set<string> lookupDeleteKeys = new Set<string>();
        List<Event_Queue__c> ewsUpserts = new List<Event_Queue__c>();
        List<Event_Queue__c> ewsDeletes = new List<Event_Queue__c>();
        for(Event_Queue__c q : scope) {
            String key = q.Event_Id__c + '|' + q.Exchange_Email__c;
            if(q.Exchange_Action__c == 'Upsert') {
                if(!lookupUpdateKeys.Contains(key)) {
                    lookupUpdateKeys.Add(key);
                    ewsUpserts.Add(q);
                } else {
                    q.Processed__c = true;
                    q.Last_Action_Result__c = 'Duplication: Skip';
                }
            } else if(q.Exchange_Action__c == 'Delete') {
                if(!lookupDeleteKeys.Contains(key)) {
                    lookupDeleteKeys.Add(key);
                    ewsDeletes.Add(q);
                } else {
                    q.Processed__c = true;
                    q.Last_Action_Result__c = 'Duplication: Skip';
                }
            }
        }
        
        if(!ewsUpserts.isEmpty()) {
            SFListenerHelper.upsertAppointments(ewsUpserts);
        }
        if(!ewsDeletes.isEmpty()) {
            SFListenerHelper.deleteAppointments(ewsDeletes);
        }
        
        update scope;
    }
    
    static void CreateGotomeetings(List<Event_Queue__c> queues){        
        // QueryEvents
        Set<Id> eventIds = new Set<Id>();
        for(Event_Queue__c q : queues) {
            if(!eventIds.contains(q.Event_Id__c))
                eventIds.add(q.Event_Id__c);
        }
        Map<ID, Event> events = new Map<ID, Event>(
            [SELECT StartDateTime, EndDateTime, Subject
               //Gotomeeting_Meeting_Name__c, Gotomeeting_Organizer_Id__c 
                FROM Event WHERE id IN :eventIds]
        );    
    
        // Query Organizers
        Set<ID> userIds = new Set<Id>();
        for(Event event : events.values()) {
            //if(event.Gotomeeting_Organizer_Id__c != '')
              //  userIds.Add(event.Gotomeeting_Organizer_Id__c);
        }
        Map<ID,User> organizers = new Map<ID,User>(
            [SELECT ID, email, GotomeetingPassword__c FROM User WHERE Id in :userIds]
        );
        
        List<Event> failures = new List<Event>();
        List<Event> updates = new List<Event>();
        for(Event_Queue__c q : queues) {
            if(!events.ContainsKey(q.Event_Id__c)) {
                AppendLastActionResult(q, 'Error - Not found.');
                q.Last_Action_Count__c = 0;
                continue;
            }
            
            Event event = events.get(q.Event_Id__c);
           /* if(!event.Gotomeeting__c) {
                AppendLastActionResult(q, 'Error - Not a Gotomeeting Event.');
                q.Last_Action_Count__c = 0;
                continue;            
            }*/
            /*if(event.Gotomeeting_Organizer_Id__c == '' || !organizers.ContainsKey(event.Gotomeeting_Organizer_Id__c)){
                AppendLastActionResult(q, 'Error - Invalid Event Organizer Id: ' + event.Gotomeeting_Organizer_Id__c);
                q.Last_Action_Count__c = 0;
                continue;
            }*/
            
            /*User organizer = organizers.get(event.Gotomeeting_Organizer_Id__c);
            try {
                G2MClient client = new G2MClient(organizer.Email, organizer.GotomeetingPassword__c);
                if(client.logon()) {
                    client.createMeeting(event);
                    client.logoff();
                    updates.Add(event);
                    q.Gotomeeting_Action__c = null;
                    AppendLastActionResult(q, 'OK - Create Gotomeeting');
                    if(q.Exchange_Action__c == null)
                        q.Processed__c = true;
                } else {
                    AppendLastActionResult(q, 'Error - Failed to create Gotomeeting: invalid password');
                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;                 
                    failures.Add(event);
                }
            }
            catch(G2MClient.G2MClientException ex) {
                AppendLastActionResult(q, 'Error - Failed to create Gotomeeting: ' + ex);
                q.Last_Action_Count__c = q.Last_Action_Count__c - 1;            
                G2MClient.SendEventExceptionEmail(event, ex, organizer.Email, 'Failed to create Gotomeeting');
            }*/
        }
        
        if(!updates.isEmpty()){
            Util.IsTrigger_EventUpdateFields = true;
            Util.IsTrigger_EventPrewire = true;
            SFListenerHelper.TriggerIsRunning = true;
            update updates;
        }
        
        if(!failures.isEmpty()) {
            for(Event event : failures) {         
                //G2MClient.SendEmail(event.Id, event.Gotomeeting_Organizer_Id__c, 'Invalid_Gotomeeting_Login_ManageEvent');
            }
        }
        
        update queues;
    }

    static void UpdateGotomeetings(List<Event_Queue__c> queues){
        // QueryEvents
        Set<Id> eventIds = new Set<Id>();
        for(Event_Queue__c q : queues) {
            if(!eventIds.contains(q.Event_Id__c))
                eventIds.add(q.Event_Id__c);
        }
        Map<ID, Event> events = new Map<ID, Event>(
            [SELECT StartDateTime, EndDateTime, Subject
                //Gotomeeting_Meeting_Name__c, 
               //Gotomeeting_Organizer_Id__c
                FROM Event WHERE id IN :eventIds]
        );    
    
        // Query Organizers
        Set<ID> userIds = new Set<Id>();
        for(Event event : events.values()) {
            //userIds.Add(event.Gotomeeting_Organizer_Id__c);
        }
        Map<ID,User> organizers = new Map<ID,User>(
            [SELECT ID, email, GotomeetingPassword__c FROM User WHERE Id in :userIds]
        );
        
        List<Event> failures = new List<Event>();
        List<Event> updates = new List<Event>();
        for(Event_Queue__c q : queues) {
            if(!events.ContainsKey(q.Event_Id__c)) {
                AppendLastActionResult(q, 'Error - Not found.');
                q.Last_Action_Count__c = 0;
                continue;
            }
            
            Event event = events.get(q.Event_Id__c);
           /* if(!event.Gotomeeting__c) {
                AppendLastActionResult(q, 'Error - Not a Gotomeeting Event.');
                q.Last_Action_Count__c = 0;
                continue;            
            }
            if(!event.Gotomeeting__c) {
                AppendLastActionResult(q, 'Error - Missing Gotomeeting Id.');
                q.Last_Action_Count__c = 0;
                continue;            
            }*/      
            /*if(event.Gotomeeting_Organizer_Id__c == '' || !organizers.ContainsKey(event.Gotomeeting_Organizer_Id__c)){
                AppendLastActionResult(q, 'Error - Invalid Event Organizer Id: ' + event.Gotomeeting_Organizer_Id__c);
                q.Last_Action_Count__c = 0;
                continue;
            }
            
            User organizer = organizers.get(event.Gotomeeting_Organizer_Id__c);
            try {
                G2MClient client = new G2MClient(organizer.Email, organizer.GotomeetingPassword__c);
                if(client.logon()) {
                    client.updateMeeting(event);
                    client.logoff();
                    updates.Add(event);
                    q.Gotomeeting_Action__c = null;
                    AppendLastActionResult(q, 'OK - Update Gotomeeting');
                    if(q.Exchange_Action__c == null)
                        q.Processed__c = true;
                } else {
                    AppendLastActionResult(q, 'Failed to update Gotomeeting: invalid password');
                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;                 
                    failures.Add(event);
                }
            }
            catch(G2MClient.G2MClientException ex) {
                AppendLastActionResult(q, 'Error - Failed to update Gotomeeting: ' + ex);
                q.Last_Action_Count__c = q.Last_Action_Count__c - 1;            
                G2MClient.SendEventExceptionEmail(event, ex, organizer.Email, 'Failed to update Gotomeeting');
            }*/
        }
        
        if(!updates.isEmpty()){
            Util.IsTrigger_EventUpdateFields = true;
            Util.IsTrigger_EventPrewire = true;
            SFListenerHelper.TriggerIsRunning = true;
            update updates;
        }
        
        if(!failures.isEmpty()) {
            for(Event event : failures) {          
               // G2MClient.SendEmail(event.Id, event.Gotomeeting_Organizer_Id__c, 'Invalid_Gotomeeting_Login_ManageEvent');
            }
        }
        
        update queues;
    }
    
    static void ClearGotomeetings(List<Event_Queue__c> queues, Boolean recreate){
        // QueryEvents
        Set<Id> eventIds = new Set<Id>();
        Set<ID> userIds = new Set<Id>();
        for(Event_Queue__c q : queues) {
            userIds.Add(q.Gotomeeting_Organizer__c);
            if(!eventIds.contains(q.Event_Id__c))
                eventIds.add(q.Event_Id__c);
        }
        Map<ID, Event> events = new Map<ID, Event>(
            [SELECT   Id, Subject
                FROM Event WHERE id IN :eventIds]
        );    
    
        // Query Organizer
        Map<ID,User> organizers = new Map<ID,User>(
            [SELECT ID, email, GotomeetingPassword__c FROM User WHERE Id in :userIds]
        );
        
        List<Event> failures = new List<Event>();
        List<Event> updates = new List<Event>();
        Map<ID,ID> lookups = new Map<ID,ID>();
        for(Event_Queue__c q : queues) {
            if(!events.ContainsKey(q.Event_Id__c)) {
                AppendLastActionResult(q, 'Error - Not found.');
                q.Last_Action_Count__c = 0;
                continue;
            }
            
            Event event = events.get(q.Event_Id__c);
            /*if(event.Gotomeeting_Id__c == null || event.Gotomeeting_Id__c == '') {
                AppendLastActionResult(q, 'Error - Missing Gotomeeting Id.');
                q.Last_Action_Count__c = 0;
                continue;            
            } */          
            
            lookups.put(event.Id, q.Gotomeeting_Organizer__c);
            User organizer = organizers.get(q.Gotomeeting_Organizer__c);
            if(organizer != null) {
                try {
                    G2MClient client = new G2MClient(organizer.Email, organizer.GotomeetingPassword__c);
                    if(client.logon()) {
                        client.deleteMeeting(event);
                        client.logoff();
                        updates.Add(event);
                        
                        // Now, we need make it for recreate
                        if(recreate) {
                            q.Gotomeeting_Action__c = 'Create';
                        }
                        else {
                            q.Gotomeeting_Action__c = null;
                        }
                        AppendLastActionResult(q, 'OK - Clear Gotomeeting');
                        if(q.Exchange_Action__c == null)
                            q.Processed__c = true;
                    } else {
                        AppendLastActionResult(q, 'Failed to clear Gotomeeting: invalid password');
                        q.Last_Action_Count__c = q.Last_Action_Count__c - 1;                 
                        failures.Add(event);
                    }
                }
                catch(G2MClient.G2MClientException ex) {
                    AppendLastActionResult(q, 'Error - Failed to clear Gotomeeting: ' + ex);
                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;            
                    G2MClient.SendEventExceptionEmail(event, ex, organizer.Email, 'Failed to clear Gotomeeting');
                }
            }
        }
        
        if(!updates.isEmpty()){
            Util.IsTrigger_EventUpdateFields = true;
            Util.IsTrigger_EventPrewire = true;
            SFListenerHelper.TriggerIsRunning = true;
            update updates;
        }
        
        if(!failures.isEmpty()) {
            for(Event event : failures) {          
                G2MClient.SendEmail(event.Id, lookups.get(event.Id), 'Invalid_Gotomeeting_Login_ManageEvent');
            }
        }
        
        update queues;
    }
    
    static void DeleteGotomeetings(List<Event_Queue__c> queues){
        // Query Organizer
        Set<ID> userIds = new Set<Id>();
        for(Event_Queue__c q : queues) {
            userIds.Add(q.Gotomeeting_Organizer__c);
        }
        Map<ID,User> organizers = new Map<ID,User>(
            [SELECT ID, email, GotomeetingPassword__c FROM User WHERE Id in :userIds]
        );
        
        List<Event_Queue__c> failures = new List<Event_Queue__c>();
        for(Event_Queue__c q : queues) {
            if(q.Gotomeeting_Id__c == null || q.Gotomeeting_Id__c == '') {
                AppendLastActionResult(q, 'Error - No Gotomeeting Id.');
                q.Last_Action_Count__c = 0;
                continue;
            }
            if(q.Gotomeeting_Organizer__c == null || q.Gotomeeting_Organizer__c == '') {
                AppendLastActionResult(q, 'Error - No Organizer.');
                q.Last_Action_Count__c = 0;
                continue;
            }
            
            User organizer = organizers.get(q.Gotomeeting_Organizer__c);
            try {
                G2MClient client = new G2MClient(organizer.Email, organizer.GotomeetingPassword__c);
                if(client.logon()) {
                    client.deleteMeeting(q.Gotomeeting_Id__c);
                    client.logoff();
                    q.Gotomeeting_Action__c = null;
                    AppendLastActionResult(q, 'OK - Delete Gotomeeting');
                    if(q.Exchange_Action__c == null)
                        q.Processed__c = true;
                } else {
                    AppendLastActionResult(q, 'Failed to delete Gotomeeting: invalid password');
                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;                 
                    failures.Add(q);
                }
            }
            catch(G2MClient.G2MClientException ex) {
                AppendLastActionResult(q, 'Error - Failed to delete Gotomeeting: ' + ex);
                q.Last_Action_Count__c = q.Last_Action_Count__c - 1;            
                G2MClient.SendDeleteG2MExceptionEmail(q.Event_Id__c, ex, organizer.Email);
            }
        }
        
        if(!failures.isEmpty()) {
            for(Event_Queue__c q : failures) {          
                G2MClient.SendEmail(q.Id, q.Gotomeeting_Organizer__c, 'Invalid_Gotomeeting_Login_DeleteEvent');
            }
        }
        
        update queues;
    }
}