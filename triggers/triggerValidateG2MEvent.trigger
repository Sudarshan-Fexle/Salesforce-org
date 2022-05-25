//Modified By - Abhinav Sharma - 07/07/2014 - CR-20140618-5849 - Catch DML errors in triggers to reduce exception emails to SFAdmin
//Modified By - Subhash Garhwal - 09/27/2017 - CR-20170926-11418 -  Added the Util.areTriggersOnThisObjectBypassed flag.
//Removed the Reference of Activity Field from the class - CR-20180604-12258 - Abhinav sharma - 06/28/2018
trigger triggerValidateG2MEvent on Event (before update, before insert) {   

    //return immediately if method returns true  
    if(Util.areTriggersOnThisObjectBypassed('Event')) return;  

    try {
       
        if(EventTriggerHelper.BYPASS_EVENT_TRIGGER_FOR_MERGE)
          return;
        
        // bypass flag
        if (Util.BypassAllTriggers) return;
        if(Trigger.isUpdate && SFListenerHelper.TriggerIsRunning) return;
        
        for(Event event : trigger.new) {
          /*  if(event.Gotomeeting__c) {
                if(event.StartDateTime < system.now()) {
                    event.StartDateTime.addError('Start time cannot be in the past for Gotomeeting event.');
                    break;            
                }
                
                if(event.RecurrenceActivityId != null) {
                    event.RecurrenceActivityId.addError('Gotomeeting sync is not supported for recurrencing events.');
                    break;                
                }
                
                ID organizerId = event.Gotomeeting_Organizer_Id__c == null? UserInfo.getUserId() : event.Gotomeeting_Organizer_Id__c;
                User organizer = [SELECT GotomeetingPassword__c FROM User WHERE ID =: organizerId];
                if(organizer.GotomeetingPassword__c == null || organizer.GotomeetingPassword__c == '') {
                    event.Gotomeeting_Organizer__c.addError('Organizer has not setup his Gotomeeting access yet.');
                    break;
                }
    
                if(Trigger.isUpdate && !Trigger.oldMap.get(event.Id).Gotomeeting__c) {
                    // To create a gotomeeting
                    event.Gotomeeting_Url__c = '(to be generated)';
                    event.Gotomeeting_Dialing__c = '(to be generated)';
                }
            }*/
            
            if(!event.Exclude_From_Exchange_Synch__c) {
                if(event.RecurrenceActivityId != null) {
                    event.RecurrenceActivityId.addError('Outlook sync is not supported for recurrencing events.');
                    break;
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