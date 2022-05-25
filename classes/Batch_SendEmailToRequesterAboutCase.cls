/**
 *  Desription      :   This class is Used to Send the Email alert to the Requester of case to know them about the case Status.
 * 
 *  Created By      :   Abhinav Sharma
 * 
 *  Created Date    :   01/24/2018
 * 
 *  Revision Logs   :   V1.1 - Created
 * 						V1.2 - Issue--CR10865--QA--00007852 - 03/14/2018 - Abhinav Sharma - Change the Status from new to submitted
 *	                :   V1.3 - CR-20190107-12808 - 01/07/2019 - Modified By Abhinav Sharma - Change the day difference from 2 to 3 in the 
								condition of in progress email send if case in in progress for 24 hrs. 
 **
**/
global class Batch_SendEmailToRequesterAboutCase implements Database.Batchable<sObject>, Database.Stateful {
    
    //Map to hold the Email template with its Name 
    public static Map<String, EmailTemplate> mapNameWithEmailTemplate = new Map<String, EmailTemplate>();
    public static Map<String, EmailTemplate> mapIdWithEmailTemplate = new Map<String, EmailTemplate>();
    Public static Map<Id, String> mapEmailMessageIdWithText = new Map<Id, String>();
    Public Static List<Case> CaseToBeUpdatedAsClose = New List<Case>();
    
    //Constructor
    global Batch_SendEmailToRequesterAboutCase() {
        
        //Initialising the List of case 
        CaseToBeUpdatedAsClose = new List<Case>();
        mapNameWithEmailTemplate = new Map<String, EmailTemplate>();
        mapIdWithEmailTemplate = new Map<String, EmailTemplate>();
     }
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, Status, Status_Changed_Date__c, CreatedDate, StatusAge__c, RecordType.Name, Contact.Email, Stakeholder__r.Email, OwnerId, Owner.Email, Support_Manager__c, Support_Manager__r.Email
                                         From Case where StatusAge__c != null 
                                         AND RecordType.Name = 'eTech Support' 
                                         AND ContactId != null
                                        ]);
     }
    
    //Expt Method
    global void execute(Database.BatchableContext BC, List<Case> scope)  {
        
        //List to hold the single emails
    	List<Messaging.SingleEmailMessage> reminderEmailToRequesterOrCaseOwner = new List<Messaging.SingleEmailMessage>();
    
        //List to hold the Email templates.
        List<EmailTemplate> listEmailTemplate = [Select Id, Subject, Body, DeveloperName
                                                 From EmailTemplate where DeveloperName IN ('X1_Day_to_case_cancellation', 
                                                                                            'X2_Days_in_In_Progress_status',    
                                                                                            'X2_Days_in_New_status', 
                                                                                            'X3_Days_To_Case_Cancellation',
                                                                                            'X3_days_to_case_closure_for_non_verification', 
                                                                                            'Case_cancelled_for_non_response', 
                                                                                            'Case_closed_10_days_post_fix')];
        //Check for the List Size
        if(listEmailTemplate != null && listEmailTemplate.size() > 0) {
           
            //For loop on the Email template
            for(EmailTemplate emailTemplate : listEmailTemplate) {
                
                //Map to hold the email template with the emailTemplate
                mapNameWithEmailTemplate.put(emailTemplate.DeveloperName, emailTemplate);
                mapIdWithEmailTemplate.put(emailTemplate.Id, emailTemplate);
           }
        } 
        
        //Set to hold the Ids of cases
        Set<Id> setOfCasesIds = new Set<Id>();
            
        //Getting the Cases where Status Age is 7 or 9 to get the Text body of those Case Email that is used to send the Requester.
        for(Case cs : scope) {
        	
        	//Check for the status Age 
        	if(cs.StatusAge__c == 7 || cs.StatusAge__c == 9)
                setOfCasesIds.add(cs.Id);
        }
        
        if(setOfCasesIds.size() > 0) {
            
            //Get the latest Email from the EMailMessage - Status 3 is used for 'Sent'
            for(EmailMessage eM : [Select Id, ParentId, TextBody, Status  From EmailMessage where 
                                             ParentId IN : setOfCasesIds AND Status = '3' order by CreatedDate]) {
                                                    
                mapEmailMessageIdWithText.put(eM.Parentid, eM.TextBody.split('--------------- Original Message ---------------')[0]);
            }
    	}	        
            
       //Check for the case List size
        if(scope != null && scope.size() > 0) {
            
            //Loop through the Case List
             for(Case caseToEmail : scope) {
                 
                 //String to hold the Tempalte Id and To Address and cc Address
                 String EmailTemplateId = '';
                 String toAddress = '';
                 String ccAddress = '';
                 String targetObjectId = '';
                 String cancellationEmailBody = '';
                
                 //V1.3 - CR-20190107-12808 - 01/07/2019 - Modified By Abhinav Sharma.
                //Check for the Status and Age of case
                if(caseToEmail.Status.equalsIgnoreCase('In Progress') && caseToEmail.StatusAge__c >= 3) {
                    
                   EmailTemplateId =  mapNameWithEmailTemplate.get('X2_Days_in_In_Progress_status').Id;
                   toAddress = caseToEmail.Owner.Email;
                   ccAddress = caseToEmail.Support_Manager__r.Email;
                   targetObjectId = caseToEmail.Support_Manager__c;
                }
                
                //Check for the Status and Age of case
                //Modified - Issue--CR10865--QA--00007852 - Abhinav Sharma
                if(caseToEmail.CreatedDate.date().daysBetween(Date.today()) >= 2   && caseToEmail.Status.equalsIgnoreCase('Submitted')) {
                    EmailTemplateId =   mapNameWithEmailTemplate.get('X2_Days_in_New_status').Id; 
                    toAddress = caseToEmail.Support_Manager__r.Email;
                    targetObjectId = caseToEmail.Support_Manager__c;
                }
                
                //Check for the Status and Age of case 
                if(caseToEmail.StatusAge__c  == 7  && caseToEmail.Status.equalsIgnoreCase('Waiting on response from requester')) {
                    EmailTemplateId =   mapNameWithEmailTemplate.get('X3_Days_To_Case_Cancellation').Id;
                    
                    
                    toAddress = caseToEmail.Contact.Email;
                    targetObjectId = caseToEmail.ContactId;
                }
                
                //Check for the Status and Age of case 
                if(caseToEmail.StatusAge__c  == 9  && caseToEmail.Status.equalsIgnoreCase('Waiting on response from requester')) {
                    EmailTemplateId =   mapNameWithEmailTemplate.get('X1_Day_to_case_cancellation').Id; 
                    toAddress = caseToEmail.Contact.Email;
                    targetObjectId = caseToEmail.ContactId;
                }
                
                //Check for the Status and Age of case - If case has No reply from last 10 Days, update the case as close and resolution as No reply From requester side and Notify the Requester
                if(caseToEmail.StatusAge__c  == 10  && caseToEmail.Status.equalsIgnoreCase('Waiting on response from requester')) {
                    EmailTemplateId =   mapNameWithEmailTemplate.get('Case_cancelled_for_non_response').Id; 
                    toAddress = caseToEmail.Contact.Email;
                    targetObjectId = caseToEmail.ContactId;
                    
                    CaseToBeUpdatedAsClose.add(New Case(Id = caseToEmail.Id, Status = 'Closed', Resolution__c = 'No Response from Stakeholder'));
                }
                
                
                //Check for the Status and Age of case  - Check if it is Pending for Verification
                if(caseToEmail.StatusAge__c  == 7 && caseToEmail.Status.equalsIgnoreCase('Pending User Verification')) {
                    
                    EmailTemplateId =   mapNameWithEmailTemplate.get('X3_days_to_case_closure_for_non_verification').Id; 
                    toAddress = caseToEmail.Contact.Email;
                    targetObjectId = caseToEmail.ContactId;
                }
                
                //Check for the Status and Age of case  - Check if it is Pending for Verification
                if(caseToEmail.StatusAge__c  == 10 && caseToEmail.Status.equalsIgnoreCase('Pending User Verification')) {
                    EmailTemplateId =   mapNameWithEmailTemplate.get('Case_closed_10_days_post_fix').Id; 
                    toAddress = caseToEmail.Contact.Email;
                    targetObjectId = caseToEmail.ContactId;
                    
                    CaseToBeUpdatedAsClose.add(New Case(Id = caseToEmail.Id, Status = 'Closed', Resolution__c = 'No Response from Stakeholder'));
                }
                 
                 //Message single email instance
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                 System.debug('EmailTemplateId==='+EmailTemplateId);
                 System.debug('toAddress==='+toAddress);
                 
                //Check for the Email template Ids and To address
                if(String.isNotBlank(EmailTemplateId)  && String.isNotBlank(toAddress)) {
                    
                    //List to hold the Send to email address
                    List<String> sendTo = new List<String>();
                    sendTo.add(toAddress);
                     
                    //Check for the cc addresses is blank
                    if(String.isNotBlank(ccAddress)) {
                        
                        //List to hold the cc addresses
                        List<String> ccTo = new List<String>();
                        ccTo.add(ccAddress);
                        mail.setCcAddresses(ccTo);
                    }
					
                    if(mapEmailMessageIdWithText != null && mapEmailMessageIdWithText.containsKey(caseToEmail.Id))
                    	mail.setplainTextBody(mapIdWithEmailTemplate.get(EmailTemplateId).Body.replace('[email.TextBody]', mapEmailMessageIdWithText.get(caseToEmail.Id)));
                    else
                        mail.setplainTextBody(mapIdWithEmailTemplate.get(EmailTemplateId).Body);
                   
					
					mail.setSubject(mapIdWithEmailTemplate.get(EmailTemplateId).Subject);
                    mail.setToAddresses(sendTo);
                    mail.setWhatId(caseToEmail.Id);
                    mail.setOrgWideEmailAddressId(label.Application_Support_ORG_EMAIL_ID);
                    mail.setSaveAsActivity(false);
                    mail.setTreatBodiesAsTemplate(true);
                   
                    //Adding Email Instance to the list.
                    reminderEmailToRequesterOrCaseOwner.add(mail);
                }else {  	
                    
                    System.debug('-----Else part');
                    continue;
                }
            }
        }  
        
        System.debug('reminderEmailToRequesterOrCaseOwner=========='+reminderEmailToRequesterOrCaseOwner);
        
        //Check for the Case to update
        if(CaseToBeUpdatedAsClose != null && CaseToBeUpdatedAsClose.size() > 0 ) {
            
            update CaseToBeUpdatedAsClose;
        }
        
        
        //Check for the Email Alerts size, Send email to Requester/Owner
        if(reminderEmailToRequesterOrCaseOwner != null && reminderEmailToRequesterOrCaseOwner.size() > 0) {
            
            Messaging.sendEmail(reminderEmailToRequesterOrCaseOwner);
        } 
    }
    
    // Finish method 
    global void finish(Database.BatchableContext BC){
        
      
    }  
}