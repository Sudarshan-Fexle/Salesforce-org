public class SFListenerHelper {
    public static boolean TriggerIsRunning = false;

    static SFListener.SFListenerSoap GetService()
    {
        SFListener.SFListenerSoap srv = new SFListener.SFListenerSoap();
        srv.timeout_x = 60000;
        srv.AuthHeader = new SFListener.AuthHeader();
        srv.AuthHeader.SystemName = 'SF';
        srv.AuthHeader.UserName = 'UserName';
        srv.AuthHeader.Password = 'Password';
        srv.AuthHeader.TimeStamp = DateTime.Now();

        return srv;
    }

    public static void upsertAppointments(List<Event_Queue__c> queues) {
    	try {
	        SFListener.ArrayOfEventUpdate apts = new SFListener.ArrayOfEventUpdate();
	        apts.EventUpdate = new List<SFListener.EventUpdate>();
	        Map<ID,Event_Queue__c> maps = new Map<ID,Event_Queue__c>();
	        for(Event_Queue__c q : queues) {
	            maps.put(q.Id, q);

	            SFListener.EventUpdate apt = new SFListener.EventUpdate();
	            apt.Id = q.Id;
	            apt.Email = q.Exchange_Email__c;
	            apt.SFEventId = q.Event_Id__c;
	            apts.EventUpdate.add(apt);
	        }

	        if(!apts.EventUpdate.isEmpty()) {
	            SFListener.SFListenerSoap service = GetService();
	            SFListener.ArrayOfEventUpdateResult results = service.UpsertAppointments(apts);
	            for(SFListener.EventUpdateResult result : results.EventUpdateResult){
	                Event_Queue__c q = maps.get(result.Id);
	                if(result.IsSuccessful) {
	                    q.Processed__c = true;
	                } else {
	                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;
	                    SFEventQueueProcessor.AppendLastActionResult(q, result.Error);
	                }
	            }
	        }
    	}
	    catch(Exception ex)
        {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[] {G2MEventControllerExt.ErrorEmail});
	        mail.setSubject('[ABC Salesforce]: SFListenerHelper.upsertAppointments');
	        mail.setHtmlBody('queues:' + queues + '\r\nError:\r\n' + ex);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public static void deleteAppointments(List<Event_Queue__c> queues) {
    	try {
	        SFListener.ArrayOfEventUpdate apts = new SFListener.ArrayOfEventUpdate();
	        apts.EventUpdate = new List<SFListener.EventUpdate>();
	        Map<ID,Event_Queue__c> maps = new Map<ID,Event_Queue__c>();
	        for(Event_Queue__c q : queues) {
	            maps.put(q.Id, q);

	            SFListener.EventUpdate apt = new SFListener.EventUpdate();
	            apt.Id = q.Id;
	            apt.Email = q.Exchange_Email__c;
	            apt.SFEventId = Q.Event_Id__c;
	            apts.EventUpdate.add(apt);
	        }

	        if(!apts.EventUpdate.isEmpty()) {
	            SFListener.SFListenerSoap service = GetService();
	            SFListener.ArrayOfEventUpdateResult results = service.DeleteAppointments(apts);
	            for(SFListener.EventUpdateResult result : results.EventUpdateResult){
	                Event_Queue__c q = maps.get(result.Id);
	                if(result.IsSuccessful) {
	                    q.Processed__c = true;
	                } else {
	                    q.Last_Action_Count__c = q.Last_Action_Count__c - 1;
	                    SFEventQueueProcessor.AppendLastActionResult(q, result.Error);
	                }
	            }
	        }
    	}
	    catch(Exception ex)
        {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[] {G2MEventControllerExt.ErrorEmail});
	        mail.setSubject('[ABC Salesforce]: SFListenerHelper.upsertAppointments');
	        mail.setHtmlBody('queues:' + queues + '\r\nError:\r\n' + ex);
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}