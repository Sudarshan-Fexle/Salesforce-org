/**
 * 	Description		:	Controller class for the AttachmentUpload component
 * 
 * 	Created By		:	Victor Hanson
 * 
 * 	Created Date	:	06/09/2014
 * 
 * 	Revision Logs	:	v1.0 - Created
 **/ 
public without sharing class AttachmentUploadController {
    
    public string parent_Id { get; set; }
    public Attachment attach { get; set; }
    public boolean poll { get; set; }
    
    public AttachmentUploadController() {
        
        //Set the parent_Id
        parent_Id = ApexPages.currentPage().getParameters().get('parent_Id');
        attach = new Attachment();
    }
    
    /**
     *  @description    :   When user clicks upload button on Visualforce Page, perform upload/insert. 
     *						Redirect user to the attachments section of the Case Detail page using the Anchor #attachmentAnchorDiv
     *
     *  @args           :
     *
     *  @return         :   PageReference
     *
     **/
    public ApexPages.Pagereference upload() {
        
        //Set the parentId of the attachment
        attach.ParentId = parent_Id;
        string errorMsg;
        
        try {
    		insert attach;
    	}
    	catch(DMLException ex) {
			//Return DML errors to the VF Page
			errorMsg = ex.getDMLMessage(0);
		}
		catch(Exception ex) {
			//Return any errors to the VF Page
			errorMsg = ex.getMessage();
		}
		
		if (errorMsg != null) {
			//Return errors to the VF Page
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
			return null;
		}
        
        attach = new Attachment();
        
        PageReference pg = ApexPages.currentPage();
        pg.setAnchor('attachmentAnchorDiv');
        pg.setRedirect(true);
        return pg;
    }
    
    //Return all attachments associated with the parent record
    public list<Attachment> attachments {
        get {
            return [SELECT Id, BodyLength, ContentType, Description, IsPrivate, Name, OwnerId, ParentId, 
                    LastModifiedDate, CreatedById, CreatedBy.Name 
                    FROM Attachment WHERE parentId = :parent_Id ORDER BY CreatedDate DESC];
        }
        set;
    }
}