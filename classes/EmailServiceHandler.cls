/*
    Purpose:    This class is to Serialize Batch Apex
    
    Create By:  Simplyforce - Bhavi - 12/15/2011
    
    Current Version:    v1.0
    
    Revision Log:       Created.
*/
global class EmailServiceHandler implements Messaging.InboundEmailHandler {

	//method to process email message
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        
    	System.debug('Execute_Batch_PopulateRNIAMRestrictionsOnAccount :::::::::' + email.plainTextBody);
    	
    	//Check for the message text and run the appropriate batcb
    	if (email.plainTextBody != null && email.plainTextBody.contains('Execute_Batch_PopulateRNIAMRestrictionsOnAccount')) {
           
	        // execute Batch_PopulateRNIAMRestrictionsOnAccount
	        Database.executeBatch(new Batch_PopulateRNIAMRestrictionsOnAccount(), 200);
        } 
       
        //return messaging result    
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    	return result;
 	}
}