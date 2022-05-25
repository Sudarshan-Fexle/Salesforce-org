/**
 * 	Description		:	Controller class for the AttachmentUpload component
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	06/09/2014
 * 
 * 	Revision Logs	:	v1.0 - Created
 **/ 
@isTest
private class Test_AttachmentUploadController {
	
    //Test uploading an attachment
    static testMethod void testAttachmentController_Upload() {
        
        //create an account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('parent_Id', acct.Id);
        
        AttachmentUploadController controller = new AttachmentUploadController();
        
        //create the attachment
        Attachment att = new Attachment(Name = 'Unit Test Attachment',
                                       Body = Blob.valueOf('Unit Test Attachment Body'));
        controller.Attach = att;
        
        //upload the attachment
        PageReference pg = controller.upload();
        system.assertEquals('attachmentAnchorDiv', pg.getAnchor(),
                           'The anchor should be set to attachmentAnchorDiv so the user is returned to the appropriate area of the page.');
        system.assertEquals(true, pg.getRedirect());
        
        List<Attachment> attachments = [select id, name from Attachment where parentId =: acct.id];
        System.assertEquals(1, attachments.size());
    }
    
    //Test uploading an attachment and receiving an error
    static testMethod void testAttachmentController_Upload_Error() {
        
        //create an account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('parent_Id', acct.Id);
        
        AttachmentUploadController controller = new AttachmentUploadController();
        
        //create the attachment
        Attachment att = new Attachment(Name = null,
                                       Body = null);
        controller.Attach = att;
        
        //upload the attachment
        PageReference pg = controller.upload();
        system.assertEquals(null, pg,
                           'The attachmet name/body was null.  The pageReference should have returned null.');
        
        List<Attachment> attachments = [select id, name from Attachment where parentId =: acct.id];
        System.assertEquals(1, ApexPages.getMessages().size(),
                           'There should be at least one pageMessage present due to the upload error.');
    }
    
    //Test viewing existing attachments based on the parent id
    static testMethod void testAttachmentController_ListView() {
        
        //create an account
        Account acct = TestUtilities.CreateNewAccount(true);
        
        //create the attachment
        Attachment att = new Attachment(Name='Unit Test Attachment',
                                       Body=Blob.valueOf('Unit Test Attachment Body'),
                                       parentId = acct.Id);
        insert att;
        
        //Set currentpage parameters
        ApexPages.currentPage().getParameters().put('parent_Id', acct.Id);
        
        AttachmentUploadController controller = new AttachmentUploadController();
        
        System.assertEquals(1, controller.attachments.size());
    }
}