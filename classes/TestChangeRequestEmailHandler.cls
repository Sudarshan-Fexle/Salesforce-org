/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest(seeAllData=false)
private class TestChangeRequestEmailHandler{
/**
*  Purpose     :   Test class for ChangeRequestEmailHandler
*  
*  Created Date:   07/24/2012
*
*  Created By:     Simplyforce Technology
*  
*  Revision Log:   V1.0 - Created
*                  V1.1 - Modified By - Abhinav Sharma - 08/13/2014 - CR-20140425-5234
*  
*  Coverage    :   V1.0 - 100%
*                  V1.1 - 97%
*/
    static testmethod void myUnitTest() { 

        //Create a new email and envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        List<Messaging.InboundEmail.Header> eHeaders = new List<Messaging.InboundEmail.Header>();

        //Contact Employee Record Type Id
        Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');

        //Insert a test contact
        Contact contact = new Contact(LastName = 'TestContact', Email = 'test@test.com', Employee_User_Record__c = UserInfo.getUserId(), RecordTypeId = employeeRTId);
        insert contact;

        //Setup the data for the email
        email.subject = 'Test Subject';
        email.htmlBody = 'Test Email Body';
        email.fromAddress = contact.Email;
        email.toAddresses = new String[] {'test@test.com'};
        
        //Setting header property
        Messaging.InboundEmail.Header eHeader = new Messaging.InboundEmail.Header();
        eHeader.name = 'image002.png';
        eHeader.value = 'image/png';
        
        Messaging.InboundEmail.Header eHeader_1 = new Messaging.InboundEmail.Header();
        eHeader_1.name = 'Content-Transfer-Encoding';
        eHeader_1.value = 'base64';
        
        Messaging.InboundEmail.Header eHeader_2 = new Messaging.InboundEmail.Header();
        eHeader_2.name = 'Content-ID';
        eHeader_2.value = '<image002.png@01CFB68B.5A3CB0F0>';
        eHeaders.add(eHeader);
        eHeaders.add(eHeader_1);
        eHeaders.add(eHeader_2);
        
        //Set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
        inAtt.headers = eHeaders;
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt};
        
        //Debugging for the Binary attachment
        System.debug('@@@@@@@@ email.binaryAttachments ' + email.binaryAttachments);
        
        //Instantiate Email Handler
        ChangeRequestEmailHandler controller = new ChangeRequestEmailHandler();

        //Start Test from Here
        Test.startTest();

        //Calling coontroller class method having logic with it related to Inbound email processing
        controller.handleInboundEmail(email, env);

        //Fetching Records for SFDC Change Request 
        List<SFDC_Change_Request__c> listSFDCChangeRequest = [SELECT ID, Title__c, Business_Justification__c, Request_Description__c FROM SFDC_Change_Request__c 
                                                                WHERE Requested_By2__c =: contact.Id];

        //Assert Value for SFDC Change Request
        System.assertEquals(1, listSFDCChangeRequest.size());

        //Assert for the results
        System.assertEquals(email.subject, listSFDCChangeRequest[0].Title__c);
        System.assertEquals(email.htmlBody, listSFDCChangeRequest[0].Request_Description__c);

        //Stop Test Here
        Test.stopTest();
    }

    // Tests the use case where the email body is larger than 32,768 characters.
    static testmethod void jumboEmailBodyTest () {

        //Create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        List<Messaging.InboundEmail.Header> eHeaders = new List<Messaging.InboundEmail.Header>();

        //Getting Contact Employee Record Type Id value
        Id employeeRTId = Util.RecordTypeId('Contact', 'Employee');

        //Insert a test contact
        Contact contact = new Contact(LastName = 'TestContact', Email = 'test@test.com', Employee_User_Record__c = UserInfo.getUserId(), RecordTypeId = employeeRTId);
        insert contact;

        //Generate a string longer than 32768
        String bigString = '';
        
        //Constructing a Jumbo Size string
        for(integer i=0;i<=32767; i++) {
            bigString+='1'; 
        }
        bigString+='8';
        System.assertEquals(32769,bigString.length());

        //Setup the data for the email
        email.subject = 'Test Subject';
        email.htmlBody = bigString;
        email.fromAddress = contact.Email;
        email.toAddresses = new String[] {'test@test.com'};
        
        //Setting header property
        Messaging.InboundEmail.Header eHeader = new Messaging.InboundEmail.Header();
        eHeader.name = 'image002.png';
        eHeader.value = 'image/png';
        
        Messaging.InboundEmail.Header eHeader_1 = new Messaging.InboundEmail.Header();
        eHeader_1.name = 'Content-Transfer-Encoding';
        eHeader_1.value = 'base64';
        
        Messaging.InboundEmail.Header eHeader_2 = new Messaging.InboundEmail.Header();
        eHeader_2.name = 'Content-ID';
        eHeader_2.value = '<image002.png@01CFB68B.5A3CB0F0>';
        eHeaders.add(eHeader);
        eHeaders.add(eHeader_1);
        eHeaders.add(eHeader_2);    
        
        //Set the body of the attachment
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
        inAtt.headers = eHeaders;
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt};

        //Instantiate Email Handler
        ChangeRequestEmailHandler controller = new ChangeRequestEmailHandler();

        //Start Test from Here
        Test.startTest();

        //Calling coontroller class method having logic with it related to Inbound email processing
        controller.handleInboundEmail(email, env);

        //Fetching Records for SFDC Change Request 
        List<SFDC_Change_Request__c> listSFDCChangeRequest = [SELECT ID, Title__c, Business_Justification__c, Request_Description__c 
        FROM SFDC_Change_Request__c WHERE Requested_By2__c =: contact.Id];

        //Assert Value for SFDC Change Request
        System.assertEquals(1, listSFDCChangeRequest.size());

        //Assert for the results
        System.assertEquals(email.subject, listSFDCChangeRequest[0].Title__c);
        System.assertEquals(email.htmlBody.substring(0,32768), listSFDCChangeRequest[0].Request_Description__c);
        System.assertNotEquals(true,listSFDCChangeRequest[0].Request_Description__c.contains('8'));

        //Stop Test Here
        Test.stopTest();
    }
}