/**
* Desription      :   Validate Travel details and Send Emails 
*
* Create By       :   Chirag Soni
* 
* Create Date     :   10/25/2021
*
* Revision Logs   :   V1.0 - Created - 10/25/2021 - CR-20210511-15133
**/ 
public without sharing class SendMemberAndGoTravelEmailController {

    /**
    * Desription      : Method to validate the conditions on the Registrations travel records 
    *
    * Create By       : Chirag Soni
    * 
    * Create Date     : 10/25/2021
    *
    * Revision Logs   : V1.0 - Created - 10/25/2021
    **/ 
    
    @AuraEnabled
    public static LightningResponseEntity SendMemberAndGoTravelEmailCallout(String Pagejson){

        LightningResponseEntity reponseHandler = new LightningResponseEntity();

        //Parse it to get the Parameters. 
        Map<String, Object> mapParameters = (Map<String, Object>) JSON.deserializeUntyped(Pagejson);
        String recordId = String.valueOf(mapParameters.get('record'));
        Set<Id> setOfEABEventIds = new Set<Id>();
        Boolean isHoltelRoomBlock = false;
        Boolean isVenuePresent = false;
        String validationMessage = '';
        Registration__c reg;
        String EABLogo;
        
        if(String.isNotBlank(Pagejson)) {
            if(String.isNotBlank(recordId)) {

                reg = [Select Id,Name, Status__c, What_Travel_is_being_offered__c, Valid_Through_Date__c,Travel_Email_Status__c,
                        EAB_Event__c, EAB_Event__r.Begins__c, EAB_Event__r.Ends__c,
                        First_Name__c,Contact__r.Asst_Email__c,Contact__r.Email,
                        Contact__c, Contact__r.Company_Email__c, Contact_Email__c, Contact__r.Phone,Contact__r.Name, Contact__r.Account.Account_Formal_Name__c,
                        Contact_Institution__c, Contact__r.Account.Primary_City__c, Contact__r.Account.Primary_State_Province__c,
                        Assistant__c, Assistant_Email__c, Contact__r.AssistantPhone, Contact__r.Account.Primary_Postal_Code__c,
                        EAB_Event__r.Public_Name__c,EAB_Event__r.Location__c,EAB_Event__r.Event_Manager__c,
                        EAB_Event__r.Begins_Long_Date__c,EAB_Event__r.Ends_Long_Date__c,
                        Must_Arrive_at_Meeting_Location_By__c,Must_Depart_No_Earlier_Than__c, EAB_Event__r.Event_Manager__r.Name,
                        Department_Authorization__c,Department_Authorization__r.Name, Department_Authorization__r.Email,
                        Requester_Name__c, Requester_Name__r.Email, Requester_Name__r.Name,Maximum_Hotel_Nights__c, 
                        Travel_Compensation_Approval_Status__c, Travel_Assistance_Request__c
                        From Registration__c Where Id =: recordId];
                
                //Fetch document for Image URL
                Document[] doc = [SELECT Id,LastModifiedDate FROM Document WHERE DeveloperName =: Label.Send_Partner_And_Go_Travel_Email_Footer_EAB_Logo];
                if(doc.isEmpty()) {
                    EABLogo ='';
                } else {
                    EABLogo =  Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+doc[0].Id+'&oid='+UserInfo.getOrganizationId()+'&lastMod='+doc[0].LastModifiedDate.getTime();
                }   
                
                //Validating that this record is eligible
                
                if(reg.EAB_Event__c != null){
                    setOfEABEventIds.add(reg.EAB_Event__c);
                }
                    
                if(reg.Travel_Assistance_Request__c == false){
                    validationMessage = 'Travel Assistance is not requested.';
                }
                else if(reg.Travel_Compensation_Approval_Status__c != Constants.KEYWORD_APPROVED){
                    validationMessage = 'Travel compensation request not approved';
                }
            }
        }
        //Check if all passes or not. 
        if(String.isNotBlank(validationMessage)) {
            reponseHandler.setError(validationMessage);
        }
        else{
            
            //single email message
            Messaging.SingleEmailMessage[] mails =   new List<Messaging.SingleEmailMessage>();

            List<Venue__c> venues = [Select Id, Name,Venue_Address__c, Accommodations__c, Advisory_Event__c From Venue__c Where Advisory_Event__c =: reg.EAB_Event__c And Primary__c = true];
			
            //Send Internal Travel Email when hotel room is blocked or not blocked
            if(reg != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if(venues.size()>0)
                	mail.setHtmlBody(TravelCompEmailTemplateWrapper.getInternalTravelEmailBody(reg, venues[0], EABLogo));
                else{
                    Venue__c venue = new Venue__c();
                    mail.setHtmlBody(TravelCompEmailTemplateWrapper.getInternalTravelEmailBody(reg, venue, EABLogo));
                }
                String[] ccAddresses = new String[] {reg.Requester_Name__r.Email};
                    
                    if(String.isNotBlank(reg.Requester_Name__r.Email)){
                      mail.setccAddresses(ccAddresses);
                    }
                
                String toAddress = Label.Internal_Travel_Email_To_Address;
                //address that will be used when a recipient replies to the email
                mail.setReplyTo(reg.Department_Authorization__r.Email);
                mail.setToAddresses(new String[] {toAddress});
                mail.setSubject(Label.Travel_Email_Subject + ' | ' + reg.EAB_Event__r.Public_Name__c);
                mails.add(mail);
            }
            
            //Send Partner facing email 
            if(reg != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setHtmlBody(TravelCompEmailTemplateWrapper.getPartnerFacingEmailBody(reg, EABLogo));
                String[] ccAddresses = new String[] {reg.Assistant_Email__c};
                    if(String.isNotBlank(reg.Assistant_Email__c)){
                        mail.setccAddresses(ccAddresses);
                    }
                mail.setBccAddresses(new String[]{Label.Partner_Facing_Email_BCC_Address});
                String toAddress = reg.Contact_Email__c;

                //address that will be used when a recipient replies to the email
                mail.setReplyTo(reg.Requester_Name__r.Email);
                mail.setToAddresses(new String[] {toAddress});
                mail.setSubject(Label.Travel_Email_Subject + ' | ' + reg.EAB_Event__r.Public_Name__c);
                mails.add(mail);
            }
            
            try {
                if(mails.size()>0){
                    Messaging.sendEmail(mails);
                    reponseHandler.setSuccess(true);
                    reponseHandler.setMessage('Request sent Successfully.');
                    
                    //Update Registration
                    reg.Travel_Email_Status__c = 'Travel Email Sent '+System.now().format('MM/dd/yyyy HH:mm:ss');
                    Util.ByPassAllTriggers = true;
                    update reg;
                    Util.ByPassAllTriggers = false;
                }
        	}
            catch(Exception e) {
                reponseHandler.setError(e.getMessage());
                
                //Update registration
                reg.Travel_Email_Status__c = 'Travel Email Not Sent '+e.getMessage();                
                Util.ByPassAllTriggers = true;
                update reg;
                Util.ByPassAllTriggers = false;
            }
        }
        
        //Valiate the Data first. 
        return reponseHandler;
    }
}