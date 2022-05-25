/**
 *   Purpose:    This class is to handle email services
 *   
 *   Create By:  Simplyforce - Bhavi - 12/15/2011
 *   
 *   Current Version:    v1.0
 *   
 *   Revision Log:      Created.
 *	 					Added a new method to send the email with Template	
**/
public class EmailHandler {

	//method to send emails
    public static void sendEmail(String toAddress, String subject, String body) {
    
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       // email address of the salesforce email service
       String[] toAddresses = new String[] {toAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject(subject);
       mail.setPlainTextBody(body);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    //method to send emails
    public static void sendEmail(String toAddress, String subject, String body, String htmlBody) {
    
        createEmail(new list<string> { toAddress }, subject, body, htmlBody, true);
    }
    
    //method to send emails
    public static Messaging.SingleEmailMessage createEmail(list<string> toAddresses, String subject, String body, String htmlBody, boolean createAndSend) {
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // email address of the salesforce email service
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setHtmlBody(htmlBody);
        if (createAndSend) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return mail;
    }
    
    //method to send emails
    public static void sendEmail(List<String> toAddresses, Id whatId, Id targetObjectId, Id templateId) {
    
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTemplateId(templateId);
        mail.setToAddresses(toAddresses);
        mail.setWhatId(whatId);
        mail.setTargetObjectId(targetObjectId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    //method to create emails
    public static Messaging.SingleEmailMessage createEmail(List<String> toAddresses, Id whatId, Id targetObjectId, Id templateId, boolean createAndSend) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTemplateId(templateId);
        mail.setToAddresses(toAddresses);
        mail.setWhatId(whatId);
        mail.setTargetObjectId(targetObjectId);
        if (createAndSend) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return mail;
    }
    
    //method to create emails with attachments
    /**
     * 	@description	:	Sending email to users
     * 
     * 	@args			:	list<string>, whatId, targetObjectId, templateId, list<Messaging.EmailFileAttachment>
     * 
     * 	@return			:	Messaging.SingleEmailMessage
     * 
     * 	@revisions		:	Created - 6/15/2017 - VH
     * 
     **/ 
    public static Messaging.SingleEmailMessage createEmail(List<String> toAddresses, Id whatId, Id targetObjectId, 
                                                           Id templateId, list<Messaging.EmailFileAttachment> attachments) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setToAddresses(toAddresses);
        mail.setWhatId(whatId);
        mail.setTargetObjectId(targetObjectId);
        mail.saveAsActivity = false;
        
        if (attachments != null && attachments.size() > 0)
            mail.setFileAttachments(attachments);
        
        return mail;
    }
    
    public static Messaging.EmailFileAttachment createEmailAttachment(string filename, blob body) {
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(filename);
        efa.setBody(body);
        return efa;
    }
    
    /**
     * 	@description	:	Sending email to users
     * 
     * 	@args			:	Users Ids, Subject, Body
     * 
     * 	@return			:	void
     * 
     **/ 
    public static void sendEmail(Set<Id> userIds, String subject, String body) {
    	
    	//Create a list of SingleEmailMessage instance
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	
    	//Loop through the user records and create an email for each user
    	for(User user : [Select Email from User where Id IN: userIds AND IsActive = true]) {
    		
    		//SingleEmailMessage instance
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       		String[] toAddresses = new String[] {user.Email};
			mail.setToAddresses(toAddresses);
			mail.setSubject(subject);
			mail.setPlainTextBody(body);
			emails.add(mail);
    	}
		
		//Send email in bulk
		Messaging.sendEmail(emails);
    }
    
    /**
     * 	@description	:	Method to create emails
     * 
     * 	@args			:	String EmailTemplate Id, String targateObjectId, String WhatId
     * 
     * 	@return			:	Messaging.Singleemailmessage
     * 
     **/
	public static Messaging.Singleemailmessage email(String eTId, String tOId, String wId) {
		
		//Instance of Messaging.Singleemailmessage
		Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
		
		//Set template Id
		mail.setTemplateId(eTId);
		mail.setSaveAsActivity(false);
		
		//Set Target object Id
		mail.setTargetObjectId(tOId);
        
        //Set what Id
        if(String.isNotBlank(wId))
        	mail.setWhatId(wId);
        
        //Return
        return mail;
	}
}