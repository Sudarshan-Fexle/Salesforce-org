/**
 *  Description     :   Email handler class for PSS Request object trigger
 * 
 *  Created By      :   Abhinav Sharma   
 * 
 *  Created Date    :   12/10/2016
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20160111-9502
 *                  :   V_1.1 - Modified By - Neha Sharma - 11/01/2021 - CR-20180604-12256 - Remove references of OrgWide Email addresses with @Advisory.com
 *
**/ 
global class PSSRequestsEmailHandler implements Messaging.InboundEmailHandler {
    
    //Mathod to have email handler based logic
    //Execute When
        //To: is PSSRequest@advisory.com
        //CC: is not blank
    //Then
        //Identify the Contact record associated with the CC address
        //Identify the PSS Request ID based on the "PSS Request ID: <Name>" value in the body
        //Update the referenced PSS Request
        //PSS Resource = CC'd Contact (if they're different)
        //Approved = True
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
  
        // Try to look up any contacts based on the email from address
        // If there is more than one contact with the same email address,
        // an exception will be thrown and the catch statement will be called.
        try {
            
            if(email != null)
            	system.debug('@@@@@ Email Body ' + email.plainTextBody);
                
            //Identify the Contact record associated with the CC address
            
            //Checking for the eligibility criteria
            //To: is PSSRequest@advisory.com
            //CC: is not blank
            if(email.toAddresses != null 
                && email.toAddresses.size() > 0
                && email.ccAddresses != null
                && email.ccAddresses.size() > 0
            ) {
            
                //temp. variables to hold the To and cc addresses
                String toAddressStr = email.toAddresses[0].trim();
                String ccAddressStr = email.ccAddresses[0].trim();
                
                //Checking for the eligibility
                //Modified By - Neha Sharma - 11/01/2021 - CR-20180604-12256 - Remove references of OrgWide Email addresses with @Advisory.com (Comment Custom Label)
                if(String.isNotBlank(toAddressStr)/*toAddressStr.endsWithIgnoreCase(System.Label.PSS_Requests_Email_Address*/) {
                    
                    //List of contacts
                    List<Contact> matchingContacts = new List<Contact>();
                    
                    //Loop through contact associated with the CC address
                    for(Contact vCon : [SELECT Id, Email 
                                        FROM Contact
                                        WHERE Email != null AND Email !=''
                                        AND Email =: ccAddressStr LIMIT 1]) {
                        matchingContacts.add(vCon);                         
                    }
                    
                    //Identify the PSS Request ID based on the "PSS Request ID: <Name>" value in the body
                    
                    //String to hold the email body
                    String bodyText;
                    
                    //Checking if plain text body and accordingly populating temp. variable to hold appropriate value                    
                    if (string.isEmpty(email.plainTextBody))
                       bodyText = Util.HtmlToText(email.htmlBody);
                    else
                       bodyText = email.plainTextBody;
                        
                    //String to hold the PSS Record record name
                    String pssRequestRecordID = '';    
                    
                    //Loop through the lines and check if there is Manager Name is in Body
                    for(String line : bodyText.split('\n')) {
                        
                        //Check if line contains Manager Name
                        if(line.containsIgnoreCase(System.Label.PSS_Request_ID)) {
                            
                            //Split string to get manager name
                            if(line.contains(System.Label.PSS_Request_ID) && line.contains(':')) {
                        		
                                //Processing of string literal
                                pssRequestRecordID = line.replace(System.Label.PSS_Request_ID, '').replace(':', '').trim();
                                
                                //Checking for the string literal presence
                                if(pssRequestRecordID.contains('*'))
                                	pssRequestRecordID = pssRequestRecordID.replace('*', '').trim();
                                
                                //Checking for the string literal presence
                                if(pssRequestRecordID.contains('*'))
                                	pssRequestRecordID = pssRequestRecordID.replace('*', '').trim();
                                
                                //Checking for the string literal presence
                                if(pssRequestRecordID.contains('>'))
                                	pssRequestRecordID = pssRequestRecordID.replace('>', '').trim();
                            }
                        }
                    }
                    
                    //PSS Request records list
                    List<PSS_Request__c> pssRequests = new List<PSS_Request__c>();
                        
                    //Checking for variable value
                    if(pssRequestRecordID != '' && (pssRequestRecordID instanceof ID)) {
                        
                        //Update the referenced PSS Request
                        //PSS Resource = CC'd Contact (if they're different)
                        //Approved = True
                        PSS_Request__c pssRequest = new PSS_Request__c(ID = pssRequestRecordID);
                        pssRequest.PSS_Resource__c = matchingContacts[0].Id;
                        pssRequest.Approved__c = true;
                        pssRequests.add(pssRequest);            
                    }
                        
                    //Checking for the size value
                    if(pssRequests.size() > 0) {
                            
                        //Update PSS Records
                        update pssRequests;
                    }
                }
            }
        }
        
        // If an exception occurs when the query accesses 
        // the contact record, a QueryException is called.
        // The exception is written to the Apex debug log.
        catch (Exception e) {
           System.debug('Exception : ' + e);
        }
   
        // Set the result to true. No need to send an email back to the user 
        // with an error message
        result.success = true;
   
        // Return the result for the Apex Email Service
        return result;
    }
}