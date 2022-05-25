/** 
  * Description     :   Controller class for ShipIt_ShipmentPrintLabel.
  * 				:	Queries attachment based on passed id in Url and display Bodyy on the Page.
  *
  * Created By      :   Rajeev Jain(Simplyforce)
  *
  * Created Date    :   03/18/2015
  *
  * Version         :   V1.0 Created
  * 
  **/
public without sharing class ShipIt_ShipmentPrintLabelController {
	
    public String attachmentBody{get;set;}
    public String contentType{get;set;}
    
    //Constnact
    public static final String INVALID_ATTACHMENT_ID = 'Invalid attachment id found !';
    
    //Class Constructor
    public ShipIt_ShipmentPrintLabelController(){
        
        //Get id from URL 
        String attachmentId = ApexPages.currentPage().getParameters().get('attachmentId');
        
        //Check If String is not blank
        if( String.isNotBlank(attachmentId)){
        	
            //Query to Get Attchement
            List<Attachment> attachments = [select Id, Name, Body, ParentID, Description, ContentType 
                                            from Attachment where Id = :attachmentId];
            
            ///Check Size of Attachemt
            if(attachments.size() > 0){
            	
                contentType = attachments[0].ContentType;
                //shipmentAttachement.id = attachments[0].id;
                attachmentBody = EncodingUtil.base64Encode(attachments[0].Body);
                
            }else{
                
				///Display error on the Page
            	ShipItHelper.displayErrorMessages(INVALID_ATTACHMENT_ID);                
            }
        }else{
            ///Display error on the Page
            ShipItHelper.displayErrorMessages(INVALID_ATTACHMENT_ID);
        }
	}
}