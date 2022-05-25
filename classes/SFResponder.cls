//Removed the References of exclude_from_exchange_synch__c from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018
global with sharing class SFResponder {
    global class EventUpdate {
        webService String SFEventId;
        webService Boolean IsAllDayEvent;
        webService DateTime StartDateTime;
        webService DateTime EndDateTime;
    }

    global class EventDetail {
        webService Boolean IsValid;
        webService String ErrorMessage;

        webService DateTime StartDateTime;
        webService DateTime EndDateTime;
        webService Boolean IsAllDayEvent;
        webService String Subject;
        webService String Location;
        webService String Body;
        webService DateTime LastUpdatedTime;
    }

    webservice static EventDetail GetEventDetail(String eventId) {
        EventDetail event = new EventDetail();

        if(eventId == null || eventId == '') {
            event.IsValid = false;
            event.ErrorMessage = 'Error: eventId is blank.';
            return event;
        }

        try {
            Event sfEvent = [select Subject, StartDateTime, EndDateTime, IsAllDayEvent, Location, LastModifiedDate FROM Event WHERE Id = :eventId];
            event.IsValid = true;
            event.Subject = sfEvent.Subject;
            event.IsAllDayEvent = sfEvent.IsAllDayEvent;
            event.StartDateTime = sfEvent.StartDateTime;
            event.EndDateTime = sfEvent.EndDateTime;
            event.Location = sfEvent.Location;
            event.LastUpdatedTime = sfEvent.LastModifiedDate;

            PageReference ref = new PageReference('/apex/EventDetailsForOutlook?id=' + eventId);
            event.Body = ref.getContent().toString();
        }
        catch(Exception ex) {
            event.IsValid = false;
            event.ErrorMessage = '' + ex;
        }

        return event;
    }

    webservice static string UpdateEvent(EventUpdate eventUpdate) {
        if(eventUpdate.SFEventId == null || eventUpdate.SFEventId == '') return 'eventUpdate\'s SFEventId is blank.';

        try {
            Event event = [select StartDateTime, EndDateTime, IsAllDayEvent, 
                            Cancelled_Did_Not_Occur__c from Event where id = :eventUpdate.SFEventId];

            if(!event.Cancelled_Did_Not_Occur__c && 
                    (event.StartDateTime != eventUpdate.StartDateTime || event.EndDateTime!= eventUpdate.EndDateTime || event.IsAllDayEvent != eventUpdate.IsAllDayEvent)) {
                event.StartDateTime = eventUpdate.StartDateTime;
                event.EndDateTime = eventUpdate.EndDateTime;
                event.IsAllDayEvent = eventUpdate.IsAllDayEvent;

                update event;
            }
            return '';
        }
        catch(Exception ex) {
            return ex + '';
        }
    }

    webservice static void ProcessSyncQueue() {
        SFEventQueueProcessor.ProcessSyncQueue(null);
    }

    webservice static void ProcessGTMQueue() {
        SFEventQueueProcessor.ProcessGTMQueue(null);
    }
}