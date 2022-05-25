/**
 *  Desription      :   Reset the password for the user associated with the email 
 * 
 *  Created By      :   Victor Hanson
 * 
 *  Created Date    :   04/01/2013
 * 
 *  Revision Logs   :   V1.0 - Created
 *
 **/ 
global class ResetPWEmailHandler implements Messaging.InboundEmailHandler {
    
    public boolean IsSuccess { get; set; }
    
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
        // find the user associated with the email address that sent this request
        List<User> users = [SELECT Id FROM User WHERE Email = :envelope.fromAddress AND IsActive = true];
        
        // assuming the user was found, send a password reset email to the user
        if (users.size() == 1) {
        	// if it's not a unit test, reset the password - CR-3677
        	if (!test.isRunningTest()) system.resetPassword(users[0].Id, true);
            IsSuccess = true;
        }
        else {
        	// we have to specify a target object id, so get the SFAdmin user
        	List<User> sfAdminUsers = [SELECT Id FROM User WHERE Name = 'Salesforce Administrator' LIMIT 1];
        	if (sfAdminUsers.size() > 0) {
	        	List<String> toAddresses = new List<String> { envelope.fromAddress };
				EmailTemplate template = [Select id from EmailTemplate where DeveloperName = 'Reset_SF_Password_Internal'];
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(toAddresses);
				mail.setTemplateId(template.id);
				mail.setTargetObjectId(sfAdminUsers[0].Id);
				mail.saveAsActivity = false;
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        	}
        }
        
		return result;
	}
    
}