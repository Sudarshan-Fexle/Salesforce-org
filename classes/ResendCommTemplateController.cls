/**
 *  Purpose         :   Test Class for ResendCommTemplateController
 *  Created By      :   Victor Hanson
 *  Created Date    :   07/21/2020
 *  Revision Logs   :   V_1.0 - 07/21/2020 - CR-20200708-14279 - Victor Hanson - removed reference to Long_Date__c field, updated callWebServiceToSendCommunicationtTemplate reference
 * 			V_1.1 - 08/04/2020 - CR-20200804-14400 - Victor Hanson - updated reference to callWebServiceToSendCommunicationtTemplate
 * 			V_1.2 - 10/08/2020 - CR-20200819-14447 - Saurabh Kumar - Removed meeting reference in resendTemplatedCallout method
 * 			V_1.3 - 10/13/2021 - CR-20210628-15254 - Chirag soni - Removed old zoom related conditions and added new condition as per event format.
 *			V_1.4 - 10/18/2021 - CR-20210628-15254 - Chirag Soni  - Added a validation message when eab event don't have the event format = "In-Person" and not have a primary venue
 *			V_1.5 - 12/08/2021 - CR-20210614-15212 - Chirag Soni - QA/UAT Issue #124 - Updated condition for elevated meal registration
 *			V_1.6 - 12/03/2021 - CR-20211022-15545 - Chirag Soni - 'Hybrid' Picklist value is deactivated on Event Format
 *      	        V_1.7 - 01/13/2022 - CR-20220112-15701 - Chirag Soni - Modified method - resendTemplatedCallout () commented condition for Event is not compatible to send the Template.             
 **/
public without sharing class ResendCommTemplateController {
    
    @AuraEnabled
    public static LightningResponseEntity resendTemplatedCallout(String Pagejson){
        LightningResponseEntity reponseHandler = new LightningResponseEntity();
        
        if(String.isNotBlank(Pagejson)) {
            
            //Parse it to get the Parameters. 
            Map<String, Object> mapParameters = (Map<String, Object>) JSON.deserializeUntyped(Pagejson);
            String recordId = String.valueOf(mapParameters.get('record'));
            
            //Added by - Chirag Soni - CR-20210628-15254 - 10/18/2021 - check for In person communication template - From Here
            Set<Id> setOfEABEvent = new Set<Id>();
            //string to hold EAB Event primary venue
            String venueName = '';
            //loop over the registration record Id
            for (Registration__c reg : [Select Id, EAB_Event__c, EAB_Event__r.Event_Format__c From Registration__c Where Id =: recordId]){
                if(reg != null && reg.EAB_Event__c != null && reg.EAB_Event__r.Event_Format__c == Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT)
                    setOfEABEvent.add(reg.EAB_Event__c);
            }
            
            for(Venue__c venue : [Select Id,Name From Venue__c Where Primary__c = True AND Advisory_Event__c IN: setOfEABEvent]){
                if(venue != null){
                    venueName += venue.Name;
                }
            }
            //Added by - Chirag Soni - 10/18/2021 - check for In person communication template - Till Here
            
            if(String.isNotBlank(recordId)) {
                
                String validationMessage = '';
                
                //Validating that this record is eligible for resending callouts or not.SELECT 
                for(Registration__c reg : [Select Id, Status__c, RecordTypeId, EAB_Event__r.Elevated_Meal_Type__c,
                                           Zoom_Participant_URL__c,RSVP__c,
                                           EAB_Event__c, 
                                           EAB_Event__r.Communication_Template__r.Name,
                                           EAB_Event__r.Event_Type__c,
                                           EAB_Event__r.Public_Name__c, 
                                           EAB_Event__r.Event_Format__c,
                                           EAB_Event__r.Zoom_DialIn_Number__c,
                                           EAB_Event__r.Zoom_Meeting_ID__c,
                                           EAB_Event__r.Event_Website__c,
                                           EAB_Event__r.Begins__c, 
                                           EAB_Event__r.Ends__c,
                                           Contact__c, Contact__r.Company_Email__c, Contact__r.Name,
                                           Contact__r.Email
                                           From Registration__c 
                                           Where Id =: recordId]) {
                                               
	               if(String.isBlank(reg.EAB_Event__c)){
	                   validationMessage = 'EAB Event is not added to the Registration.';    
	               }//12/08/2021 - CR-20210614-15212 - Chirag Soni - QA/UAT Issue #124 - Updated condition for elevated meal registration
                   	else if(reg.Status__c != RegistrationHelper.STATUS_REGISTERED && reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL){
	                   validationMessage = 'Registration status should be registered before sending the Template.';
	               }else if(reg.RecordTypeId == Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && (String.isBlank(reg.RSVP__c) || reg.RSVP__c == 'No')){
	                   validationMessage = 'Registration RSVP should be Yes or Maybe before sending the Template.';
	               }else if(String.isBlank(reg.EAB_Event__r.Communication_Template__r.Name)) {
	                   validationMessage = 'No Communication Template added to the Eab Event.';
                   }//12/08/2021 - CR-20210614-15212 - Chirag Soni - QA/UAT Issue #124 - Updated condition for elevated meal registration
                                               
                   //01/13/2022 - CR-20220112-15701 - Chirag Soni - commented below condition                          
                   /*  else if(reg.RecordTypeId != Constants.REGISTRATION_RECORD_TYPE_ELEVATED_MEAL && String.isBlank(reg.EAB_Event__r.Event_Type__c)) {
	                   validationMessage = 'Event is not compatible to send the Template.';
	               }*/
                                               
                  else if(String.isBlank(reg.EAB_Event__r.Public_Name__c)) {
	                   validationMessage = 'Public Name should have value on Eab Event.';
	               }else if(reg.EAB_Event__r.Begins__c == null) {
	                   validationMessage = 'EAB Event Start Time is should have value.';
	               }else if(reg.EAB_Event__r.Ends__c == null) {
	                   validationMessage = 'Meeting End Time is should have value.';
	               }
	               //08/04/2020 - CR-20200804-14400 - Victor Hanson - don't attempt to send reminder if end dateTime is in the past
	               else if(reg.EAB_Event__r.Ends__c < DateTime.now()) {
	                   validationMessage = 'EAB Event End Time is in the past.';
	               }else if(String.isBlank(reg.Contact__c)){
	                   validationMessage = 'Registration should have contact populated.';
	               }else if(String.isBlank(reg.Contact__r.Email)){
	                   validationMessage = 'Contact should have Email.';
	               }
                                       
                                               
	               //Added By - Chirag Soni - 10/13/2021 - CR-20210628-15254 - new validation condition as per event format.
		       //Updated By -  Chirag Soni  -  12/03/2021 - CR-20211022-15545 - 'Hybrid' Picklist value is deactivated on Event Format 
                       else if(reg.EAB_Event__r.Event_Format__c!= null && (reg.EAB_Event__r.Event_Format__c == 'Virtual' /*|| reg.EAB_Event__r.Event_Format__c == 'Hybrid'*/))
	               {
	                   if(String.isblank(reg.Zoom_Participant_URL__c)){
	                       validationMessage = 'Zoom Participant URL should not be blank before sending the Template.';
	                   }else if(String.isBlank(reg.EAB_Event__r.Zoom_DialIn_Number__c)){
	                       validationMessage = 'Zoom Dial In should have value on Eab Event';
	                   }else if(String.isBlank(reg.EAB_Event__r.Zoom_Meeting_ID__c)){
	                       validationMessage = 'Zoom Meeting Id should have value on Eab Event';
	                   }
	               }
	               //Added by - Chirag Soni - 10/18/2021 - throw an error message when there is no primary venue in case of In person event - From Here                           
	               else if(String.isblank(venueName) && reg.EAB_Event__r.Event_Format__c == Constants.EAB_EVENT_IN_PERSON_EVENT_FORMAT)
	                   validationMessage = 'A primary venue must be associated with the EAB Event if Event Format = In-Person';            
	               //Added by - Chirag Soni - 10/18/2021 - throw an error message when there is no primary venue in case of In person event - Ends Here 
                                               
	               //Check if all passes or not. 
	               if(String.isNotBlank(validationMessage)) {
	                   reponseHandler.setError(validationMessage);
	               }else{
	                   boolean isVoid = (reg.Status__c == RegistrationHelper.STATUS_VOID || reg.Status__c == RegistrationHelper.STATUS_CANCELLED);
                                                   
	                   //08/04/2020 - CR-20200804-14400 - Victor Hanson - added false param
	                   //07/27/2021 - Chirag Soni - CR-20210709-15278 - commented this methods call from Registration helper class and added scheduler in place of it 
	                   //HttpResponse response = RegistrationHelper.callWebServiceToSendCommunicationtTemplate(new Set<Id> {recordId}, Constants.HTTP_REQUEST_POST_TYPE, false);
                                                   
	                   HttpResponse response = Schedule_CommunicationTemplateService.callWebServiceToSendCommunicationtTemplate(new Set<Id> {recordId}, Constants.HTTP_REQUEST_POST_TYPE, false);
                                                   
	                   if(response.getStatusCode() == 202 || response.getStatusCode() == 200){
	                       reponseHandler.setSuccess(true);
	                       reponseHandler.setMessage('Request sent Successfully.');
	                   }else{
	                       reponseHandler.setError(String.valueOf(response.getStatusCode()));
	                   }
	               }
	           }
            }
        }
        
        //Valiate the Data first. 
        return reponseHandler;
    }
}