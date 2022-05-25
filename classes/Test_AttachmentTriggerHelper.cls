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
/*  Description     :   Test class for AttachmentTriggerHelper
*
*   Created by      :   
*
*   Created Date    :   
*
*   Revision Log    :   V1.1 - Modified By - Rajeev Jain - 09/06/2016 - CR-20160224-9640 - Release 53 - 
                               Added new method to assert and cover method of the AttachmentTriggerHelper class grantAdditionalSharingOnFiles
                        V1.2 - Modified By - Saurabh Kumar - 07/05/2017 - Added a test method testConverAttachmentToFile.
			V1.3 - Modified    - RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST Deleted. CR-20200217-13756
*/
@isTest
private class Test_AttachmentTriggerHelper{
    
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp
    /*static testMethod void testPurchRequestAttachment() {
        List<RecordType> vendorRecordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor' AND SObjectType='Account' AND IsActive = true LIMIT 1];
        // create an institution
        Account acct = new Account(recordtypeid=vendorRecordTypes[0].Id);
        acct.Status__c = 'Approved';
        insert acct;
        // Insert the purchase request
        Purchase_Request__c purchaseRequest = new Purchase_Request__c(Vendor__c = acct.Id,
                                                                      Purchase_Amount__c = 1000,
                                                                      Department__c = 'ET',
                                                                      Accounting_Manager__c = userInfo.getUserId());
        insert purchaseRequest;
        // add an attachment to the purchase request
        Attachment attachment = new Attachment(Name='Agreement - signed.pdf',Description='Test description',
                                               ParentId=purchaseRequest.Id,Body=Blob.valueOf('test'));
        insert attachment;
        // get the purchase request
        purchaseRequest = [SELECT Id, Has_Attachment__c FROM Purchase_Request__c WHERE Id = :purchaseRequest.Id];
        system.assertEquals(true, purchaseRequest.Has_Attachment__c);
        
        // delete the attachment
        delete attachment;
        // get the purchase request
        purchaseRequest = [SELECT Id, Has_Attachment__c FROM Purchase_Request__c WHERE Id = :purchaseRequest.Id];
        system.assertEquals(false, purchaseRequest.Has_Attachment__c);
    }*/
    
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/08/2019 - #Spring CleanUp
    /*static testMethod void testPaymentRequestAttachment() {
        List<RecordType> vendorRecordTypes = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor' AND SObjectType='Account' AND IsActive = true LIMIT 1];
        // create an institution
        Account acct = new Account(recordtypeid=vendorRecordTypes[0].Id);
        acct.Status__c = 'Approved';
        insert acct;
        // Insert the purchase request
        Payment_Request__c pmtReq = new Payment_Request__c(Amount__c = 100, Payment_Amount__c = 100,
                                                            Status__c = 'Approved - Awaiting Procurement');
        insert pmtReq;
        // add an attachment to the purchase request
        Attachment attachment = new Attachment(Name='Agreement - signed.pdf',Description='Test description',
                                               ParentId=pmtReq.Id,Body=Blob.valueOf('test'));
        insert attachment;
        // get the purchase request
        pmtReq = [SELECT Id, Has_Attachment__c FROM Payment_Request__c WHERE Id = :pmtReq.Id];
        system.assertEquals(true, pmtReq.Has_Attachment__c);
        
        // delete the attachment
        delete attachment;
        // get the purchase request
        pmtReq = [SELECT Id, Has_Attachment__c FROM Payment_Request__c WHERE Id = :pmtReq.Id];
        system.assertEquals(false, pmtReq.Has_Attachment__c);
    }*/
    
    static testMethod void testRestrictMailingCampaignAttachmentToPDF() {
        
        Id mailingCampaignId = [SELECT Id FROM RecordType 
                                    WHERE DeveloperName = :Label.Record_Type_Developer_Name_Mailing_Campaign
                                    AND IsActive = true 
                                    LIMIT 1].Id;
        
        if(mailingCampaignId != null){
        	//create a Mailing Campaign
        	Campaign campaign = new Campaign(Name = 'Mailing Campaign 1',
                                        IsActive = true,
                                        Status = 'In Progress',
                                        RecordTypeId = mailingCampaignId);
        	insert campaign; 
            
            // add a PDF attachment to the campaign
            Attachment pdfAttachment = new Attachment(Name='Agreement - signed.pdf',Description='Test description',ContentType='PDF',
                                                   ParentId=campaign.Id,Body=Blob.valueOf('test'));
            insert pdfAttachment;
            
            //validate the attachment was inserted successfully
            system.assertNotEquals(null, pdfAttachment.Id,
                                  'The PDF attachment should have been inserted successfully.');
            
            // delete the attachment
            delete pdfAttachment;
            
            boolean hasError = false;
            
            // add a non-PDF attachment to the campaign (this should throw an error)
            Attachment txtAttachment = new Attachment(Name='Notepad_Attachment.txt',Description='Test description',ContentType='TXT',
                                                   ParentId=campaign.Id,Body=Blob.valueOf('test'));
            try {
                insert txtAttachment;
            }
            catch(Exception e) {
                hasError = true;
            }
            
            //validate the attachment was inserted successfully
            system.assertEquals(true, hasError,
                                  'The non-PDF attachment should have been thrown an error.');
        }
        
    }
    
    //Spring CleanUp
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp
    /*static testMethod void myUnitTest_3() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c(Paper_Type__c = 'Blank Letterhead Stock (23440A)',
                                                            Campaign__c = mailingCampaign.ID);
        insert customAttachment;
        
        //Attachment
        Attachment attach = new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = customAttachment.id;
        attach.ContentType = '.xml';
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //CLicking on the Attach file button
        try {
            insert attach;
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('Only PDF attachments are allowed on Mailing Campaigns'), 'message=' + ex.getMessage());
        }
        
        //Stop Test here
        Test.stopTest();
    }*/
    
    //Spring CleanUp
    //Modified By - Seemu Saikia -CR-20190501-13072- 05/07/2019 - #Spring CleanUp
    /*static testMethod void myUnitTest_4() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> rdType = [SELECT ID FROM RecordType Where sObjectType = 'Campaign' AND IsActive = true 
                                                AND DeveloperName = 'Mailing_Campaign'];
        
        //Assert for result
        System.assert(rdType != null);
        
        //Camapign record
        Campaign mailingCampaign = new Campaign(Name = 'Test', Mailing_Title__c='Mailing-1', RecordTypeId = rdType[0].ID);
        insert mailingCampaign;
        
        //Custom Attachment
        Attachment__c customAttachment = new Attachment__c(Paper_Type__c = 'Blank Letterhead Stock (23440A)',
                                                            Campaign__c = mailingCampaign.ID);
        insert customAttachment;
        
        //Attachment
        Attachment attach = new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = customAttachment.id;
        attach.ContentType = '.pdf';
        
        //Start test from here
        Test.startTest();
        
        //Enabling triggers
        Util.byPassAllTriggers = false;
        
        //CLicking on the Attach file button
        insert attach;
        
        //Stop Test here
        Test.stopTest();
    }*/
    //V1.1 - Modified By - Rajeev Jain - 09/06/2016 - CR-20160224-9640 - Release 53
    static testMethod void test_GrantAdditionalSharingOnFiles() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Create test data for the Sync Fields custom setting that syncs Mem Support -> Case fields
        TestUtilities.createSyncFields();
        
        //List to hold the Account records
        List<Account> accounts = new List<Account>();
        
        //Create an institution
        Account acct_1 = TestUtilities.CreateNewAccount(false);
        
        //Populating list with account records
        accounts.add(acct_1); 
        
        //Insert accounts
        insert accounts;
        /* RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST Deleted. CR-20200217-13756
        //Querying Details for "Member & Employee Support" record type on Case Object
        List<RecordType> caseRdTypes = [SELECT ID, DeveloperName FROM RecordType 
                                        Where sObjectType = 'Case' 
                                        AND IsActive = true 
                                        AND DeveloperName = :Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST
                                        ORDER By DeveloperName ASC];
                                        
        
        if(caseRdTypes.size() > 0){
            //List to hold the case records
            List<Case> cases = new List<Case>();
            
            //Create a sample case record to insert and test case trigger
            Case aCase_1 = new Case(RecordTypeId = caseRdTypes[0].Id, Origin = 'ABC', Subject = 'Test', 
                                    Description = 'Test', AccountId = accounts[0].Id);
           
            //Populating list with case records
            cases.add(aCase_1); 
            
            //Start test from here
            Test.startTest();
            
            //Enabling triggers
            Util.byPassAllTriggers = false;
           
            //Insert cases
            insert cases;
            
            //Assert for the results
            System.assert(cases != null);
            System.assert(cases.size() == 1);
            
            //Now Insert Attachemen  Below Case and see the sharing of the files with MemberSupport
             //Prepare Attachent Data, which will be inserted below case record and will be shared with Member Support ticket
            Attachment attach = new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = cases[0].id;
            attach.ContentType = '.pdf';
            
            insert attach;
            
            //Requery Case Record To get MemebrSupport Ticket Status Id
            cases = [select Id, Member_Support_Ticket__c from Case where Id = : cases[0].Id];
            
            //Now Assert for Results
            //System.assertEquals(true,cases[0].Member_Support_Ticket__c != null);
            
            //Stop Test
            Test.stopTest();
            
            
        //Query on Memeber Support Records and see if the file is visible below of the Member Support
        List<Site_Issue__c> issues = [select Id from Site_Issue__c where Id = :cases[0].Member_Support_Ticket__c];
        
                
        }*/
        
        //System.assertEquals(true, issues.size() > 0);
        
       // String linkEntityID = issues[0].Id;
        
        //Now Check if Attachment on Case is shared with Member Support Records
        //We can check with this Content Document link on which Member Support Id would be stamped as LinkEntityId
       // List<ContentDocumentLink> documentLink = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId = :linkEntityID];
        
        //System.assertEquals(true, documentLink.size() > 0);
    }
    
    /*  Description     :   The method is used to test converAttachmentToFile method
    *
    *   @args           :   
    *
    *   @return         :   Void
    *
    *   Revision Log    :   V1.0_Created - 07/05/2017 - Q2C Redesign - Beta Release
    **/
    static testMethod void testConverAttachmentToFile(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        Util.isTesting = true;
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Creating document records
        Document document = TestUtilities.createNewDocument(true);
        System.assert(document != null);
        
        //Creating Quote records
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.LOA_PDF_Document_ID__c = document.Id;
        
        insert quote;
        
        //Start testing from here
        Test.startTest();
        
        //Calling method to create record
        Attachment attachment = TestUtilities.createNewAttachment(quote.Id, false);
        attachment.Name = '- signed';
        
        //Set flag to run trigger
        Util.byPassAllTriggers = false;
        
        //Insert attachment
        insert attachment;
        
        
        //Reset flag to run trigger
        Util.byPassAllTriggers = true;
        
        //Query on the contentVersion
        List<ContentVersion> contentVersions = [Select Id,ContentDocumentId From ContentVersion];
        System.assert(contentVersions != null);
        System.assertEquals(1, contentVersions.size());
        
        //Stop testig here
        Test.stopTest();
    }
}