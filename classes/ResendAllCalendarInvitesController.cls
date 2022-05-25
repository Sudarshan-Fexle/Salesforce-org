/*
*	Purpose         :   Controller class for Resend All Calendar Invites lightning component and it is used for following purpose :
*                           1. Query eligible registrations
*			    2. Send calendar invites to queried registrations 
*
*	Revision Log    :   V_1.0 Created - Chirag Soni - 02/17/2022 - CR-20211214-15627
*/

public without sharing class ResendAllCalendarInvitesController {
    
    //variable to add calendar invite names 
    public static Set<String> calendarInvites = new Set<String>{'In-Person Event', 'Reception','Dinner'};
        
   /** 
    *   Description     :   This method is used to fetch all or filter based registration records.
    *
    *   @argument       :   String
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
    **/
    @AuraEnabled
    public static LightningResponseEntity fetchEligibleRegistrationRecords(String eventRecordId)
    {  
        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
        if(String.isNotBlank(eventRecordId))
        {
            
            try{
                //get advisory event record information
                Advisory_Event__c eabEvent = getEventInfo(eventRecordId);
                
                String whereClause = ' EAB_Event__c = \''+eventRecordId+'\'';
                
                // elevated meals 
                if(eabEvent.RecordTypeId == Constants.RECORD_TYPE_ID_EAB_EVENT_ELEVATED_MEAL){
                    whereClause = whereClause+' AND (RSVP__c = \'Yes\' OR RSVP__c = \'Maybe\')';
                }
                // virtual events 
                else if(eabEvent.Event_Format__c == 'Virtual'){
                    whereClause = whereClause+' AND (Status__c = \'Registered\' AND Zoom_Participant_URL__c != null)';
                }
                // other in-person events 
                else if (eabEvent.Event_Format__c == 'In-Person'){
                    whereClause = whereClause+' AND Status__c = \'Registered\'';
                }
                
                // Query registration records 
                List<Registration__c> eligibleRegistrations = Database.query('SELECT Id FROM Registration__c WHERE'+whereClause+' AND RecordTypeId != \''+Constants.REGISTRATION_RECORD_TYPE_ID_INTERNAL_ATTENDEE+'\'');
                
                //check size
                if(eligibleRegistrations != null && eligibleRegistrations.size() > 0)
                {
                    res.setBody(eligibleRegistrations);
                    res.setSuccess(true);
                }
                else
                {
                    //Throw error in case of no Program records
                    res.setMessage('No Eligible Registrations Found on this EAB Event');
                    res.setSuccess(true);
                }
                return res;
            }catch(Exception ex){
                //Throw error 
                res.setError(ex.getMessage());
                return res;
            }
        }
        else{
            //Throw error in case of Insufficient Access To RecordId
            res.setError(Label.Insufficient_Access_To_RecordId); 
            
            return res;
        }
    }
    
   /** 
    *   Description     :   This method is used to send calendar invite to all eligible registrations 
    *
    *   @argument       :   String,List<Registration__c>
    *   
    *   return type     :   LightningResponseEntity
    * 
    *   Revision Logs   :   V_1.0 - Created
   **/
    @AuraEnabled
    public static LightningResponseEntity sendCalenderInvites(String eventRecordId, List<Registration__c> eligibleRegistrations)
    {
        //To hold data and message to display on screen
        LightningResponseEntity res = new LightningResponseEntity();
        
        if(eligibleRegistrations == null || eligibleRegistrations.size() == 0){
            res.setError('No eligible registrations found');
            return res;
        }
        
        //check record id 
        if(String.isNotBlank(eventRecordId))
        {
            try{
                //get advisory event record information
                Advisory_Event__c eabEvent = getEventInfo(eventRecordId);
                
                if(eabEvent != null){
                    //hold validation error message
                    String validationMessage = '';
                    //check if calendar invite template is blank
                    if(String.isBlank(eabEvent.Communication_Template__c)){
                        
                        //Throw error calendar invite template is blank 
                        validationMessage = 'Calendar Invite Template is blank on Event';
                    }
                    //check if event format and calendar invite is different 
                    else if(eabEvent.Event_Format__c == 'Virtual' && eabEvent.Communication_Template__r.Name != 'Virtual Event'){
                        validationMessage = 'Event format is Virtual and calendar invite template is '+eabEvent.Communication_Template__r.Name+'.';
                    }
                    //check if event format and calendar invite is different 
                    else if(eabEvent.Event_Format__c == 'In-Person' && eabEvent.Communication_Template__r.Name == 'Virtual Event'){
                        validationMessage = 'Event format is In-Person and calendar invite template is '+eabEvent.Communication_Template__r.Name+'.';
                    }
                    // ends date must be in future 
                    else if (eabEvent.Ends__c < DateTime.now()){
                        validationMessage = 'Event Ends Time is in past';
                    }
                    // check zoom information 
                    else if (eabEvent.Event_Format__c == 'Virtual' && eabEvent.Communication_Template__r.Name == 'Virtual Event' && String.isBlank(eabEvent.Zoom_Meeting_ID__c)) {
                        validationMessage = 'Zoom information is not available on event';
                    }
                    // check primary venue 
                    else if (eabEvent.Event_Format__c == 'In-Person' && calendarInvites.contains(eabEvent.Communication_Template__r.Name))
                    {
                        String venueName = '';
                        for(Venue__c venue : [Select Id,Name From Venue__c Where Primary__c = True AND Advisory_Event__c = :eabEvent.Id]){
                            if(venue != null){
                                venueName += venue.Name;
                            }
                        }
                        
                        if(String.isblank(venueName)){
                            validationMessage = 'A primary venue must be associated with the EAB Event';
                            //A primary venue must be associated with the EAB Event
                        }
                    }
                    
                    //Check if all validation passes or not. 
                    if(String.isNotBlank(validationMessage)) {
                        res.setError(validationMessage);
                    }
                    // hit call out to send calendar invite 
                    else{
                        Set<Id> registrationIds = new Set<Id>();
                        
                        for(Registration__c reg : eligibleRegistrations)
                        {
                            registrationIds.add(reg.id);
                        }
                        
                        // call out to communication template
                        HttpResponse response = Schedule_CommunicationTemplateService.callWebServiceToSendCommunicationtTemplate(registrationIds, Constants.HTTP_REQUEST_POST_TYPE, false);
                        
                        if(response.getStatusCode() == 202 || response.getStatusCode() == 200){
                            res.setSuccess(true);
                            res.setMessage('Request sent Successfully.');
                        }else{
                            res.setError(String.valueOf(response.getStatusCode()));
                        }
                     }
                } 
                return res;
            }catch(Exception ex){
                //Throw error 
                res.setError(ex.getMessage());
                return res;
            }
        } else{
            //Throw error in case of Insufficient Access To RecordId
            res.setError(Label.Insufficient_Access_To_RecordId); 
            
            return res;
        }
    }
    
   /** 
    *   Description     :   This method is used to fetch EAB Event record based on recordId.
    *
    *   @argument       :   String
    *   
    *   return type     :   Advisory_Event__c
    * 
    *   Revision Logs   :   V_1.0 - Created
    **/
    public static Advisory_Event__c getEventInfo(String recordId)
    {
        return [SELECT Id, Communication_Template__c,Event_Format__c , RecordTypeId, Communication_Template__r.Name , Zoom_Meeting_ID__c, Ends__c FROM Advisory_Event__c WHERE Id = :recordId];
    }
}