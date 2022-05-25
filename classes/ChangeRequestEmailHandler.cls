/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
/*
    Create By       :   Simplyforce Technology
    
    Created Date    :   07/22/2012
    
    Revision Log    :   V_1.0 Created
                        V1.1 - Modified By - Abhinav Sharma - 08/13/2014 - CR-20140425-5234
*/
global class ChangeRequestEmailHandler implements Messaging.InboundEmailHandler {
    
    //Method to process email 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //Call method to create change request
        createChangeRequestByEmail(email);
        
        return result;
    }
    
    //This method is to create the ChangeRequest
    public void createChangeRequestByEmail(Messaging.InboundEmail email) {
        
        //Instantiate Change Request instance
        SFDC_Change_Request__c changeRequest = new SFDC_Change_Request__c();
        
        //Get from email address
        System.debug('***** FROM ADDRESS: ' + email.fromAddress);
        String fromAddress = email.fromAddress;
        
        //Get user record from email Id
        List<Contact> contacts = [Select Id from Contact where Email =: fromAddress AND Employee_User_Record__c != null limit 1];
        
        //Check for the email address
        if(contacts.size() > 0) {
            
            //Fetch Selforce Help record type
            List<RecordType> recordTypes = [Select Id from RecordType where Name =: Constants.SALESFORCE_HELP AND 
                                                SObjectType =: Schema.SObjectType.SFDC_Change_Request__c.Name AND IsActive = true limit 1];
                                                
            //Set record Type Salesforce Help
            if(recordTypes.size() > 0)
                changeRequest.RecordTypeId = recordTypes[0].Id;
            
            //Set requested by and body
            changeRequest.Title__c = email.Subject;
            changeRequest.Requested_By2__c = contacts[0].Id;
            
            //Checking if email is having "HTML Body" with it. If yes, then populate corresponding field on CR
            if(email.htmlBody != null)
                changeRequest.Request_Description__c = email.htmlBody.substring(0,Math.min(email.htmlBody.length(),32768));
            
            //assign ownership to IS CRM queue
            Id isCRM = Constants.QUEUE_ID_IS_CRM;
            if(isCRM != null)
                changeRequest.OwnerId = isCRM;
            
            //add change request
            insert changeRequest;
            
            //Added By - Abhinav Sharma - 08/13/2014 - CR-20140425-5234
            //Create a list of attachments
            Map<String, Attachment> mapAttachments = new Map<String, Attachment>();
            
            //Checking if email is having "Binary Attachments" with it. If yes, then populate map with the values 
            if(email.binaryAttachments != null) {
                 
                //Attachments
                for(Messaging.InboundEmail.BinaryAttachment bA : email.binaryAttachments) {
                    
                    System.debug(bA);
                    
                    //Proceed with below mentioned logic only and only if binary attachment is having "header" with it
                    if(bA.headers != null && bA.headers.size() > 0) {
                    
                        //Loop through binary headers attachment size
                        for(integer i = 0; i < bA.headers.size(); i++) {
                                       
                            //Header Value
                            String headerValue = bA.headers[i].value;
                            
                            //Checking if Header starts with 'li' or 'image' tag then proceed with replacement logic and populating map with values
                            if(headerValue.startsWith(Constants.LI_Tag) || headerValue.startsWith(Constants.LESS_THAN + Constants.IMAGE_TAG)) {
                                headerValue = headerValue.replaceAll(Constants.LESS_THAN, '').replaceAll(Constants.GREATER_THAN, '');
                                mapAttachments.put(headerValue, new Attachment(Name = bA.fileName, body = bA.body, ParentId = changeRequest.Id, ContentType = bA.mimeTypeSubType));
                            }
                        }
                    }
                }
            }
 
            //Attachments
            if(mapAttachments.values().size() > 0) {
            
                //Insert attachments
                insert mapAttachments.values();
 
                //Loop through map key values
                for(String headerValue : mapAttachments.keySet()) {
                   
                    //Reference Link
                    system.debug('headerValue:::::' + headerValue);
                    String refLink = Constants.ATTACHMENT_LINK_PREFIX + mapAttachments.get(headerValue).Id;
                    
                    //Debugging for the key values
                    System.debug('@@@@ CR Request Description ' + changeRequest.Request_Description__c);
                    System.debug(changeRequest.Request_Description__c.contains('cid:' + headerValue));
                    
                    //Placing corresponding attachment URL's for the inline images in the Rich Text Area field
                    changeRequest.Request_Description__c = changeRequest.Request_Description__c.replaceAll('cid:' + headerValue, refLink);
                }
                System.debug('changeRequest:::::' + changeRequest.Request_Description__c);
                update changeRequest;
            }
        } else
            throw new CustomException(Constants.ERROR_CHANGE_REQUEST_EMAIL_HANDLER_NO_USER_EXITS);
    }
}