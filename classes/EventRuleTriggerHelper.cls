/**
 *	Desription      :   Helper class for the Event Rule Trigger
 *
 *	Revision Logs   :   V1.0 - 06/23/2021 - Created - CR-20210504-15118 - Chirag Soni - added new method createMembershipMtMRecords().
 **/

public without sharing class EventRuleTriggerHelper {
    
   /**
    *  @description    : Method is used to create Membership MtM records in case on Registration insertion AND Event rule insertion on EAB Event.
    *                    Logic 2 - Whenever Event Rule is created under EAB Event, get all EAB Event's related registration records and check Membership MtM record is there for registration record if no  
    *			 Create a Membership MtM record for each of the Contact Institution's active Membership where the Program matches a corresponding Event Rule Program. 
    *			 Membership MtM.Registration = registration.Id
    *			 Membership MtM.Membership = membership.Id
    *
    *  @arg            : List<Event_Rule__c> newEventRules
    * 
    *  @return         : Void
    * 
    *  @revision       : V1.0 Created: Chirag Soni 06/23/2021 - CR-20210504-15118
    * */
    
    public static void createMembershipMtMRecords(List<Event_Rule__c> newEventRules){
        
        //Set to hold EAB Event ids
        Set<Id> eventIds = new Set<Id>();
        
        //Set to hold registration ids
        Set<Id> registrationIds = new Set<Id>();
        
        for(Event_Rule__c evtRule : newEventRules){
            
            //check for null eab event and rule 
            if(evtRule.Advisory_Event__c != null && evtRule.Rule__c != null){
                
                // add event id in set
                eventIds.add(evtRule.Advisory_Event__c); 
            }
        }
        
        if(eventIds.size()>0)
        {
            //get all EAB Event's related registration records and check Membership MtM record is there for registration record if yes leave it, If no, hold the registration Ids in a set.
            for(Registration__c registration : [SELECT Id, (SELECT Id FROM Membership_MtMs__r) FROM Registration__c WHERE EAB_Event__c IN :eventIds])
            {
                //check if membership mtm record not exist
                //Commented By - Chirag Soni - 08/03/2021 - commented the code to check for the Multiple Program Rules in the RegistrationHelper Class
                //if(registration.Membership_MtMs__r.size() == 0)
                registrationIds.add(registration.Id);
            }
            //check size of registration ids
            if(registrationIds.size()>0){
                // pass the registration ids to createMembershipMtMRecordsLogic method
                RegistrationHelper.createMembershipMtMRecordsLogic(registrationIds);
            }
        }
    }
}