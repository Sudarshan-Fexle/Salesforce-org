/**
 *  Description     :   Standard controller extension class to have CPQ template record detail page "Update Template" button based logic with it.
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   05/31/2017
 * 
 *  Revision Logs   :   V_1.0 - Created - DS061
**/  
public without sharing class UpdateQ2CTemplateController {
    
    //Q2C template record instance
    public CPQ_Template__c cpqTemplate {get; set;}
    Id cpqTemplateId;
    
    //OSR Record
    public OSR__c osr { get; set; }
    
    //Content version instance
    public ContentVersion contentToUpload {get;set;}
    
    //Blob to hold the file content
    public transient Blob fileContent {get;set;}
    
    //Standard Controller constrcutor
    public UpdateQ2CTemplateController() {
        
        //Memory allocation/insitialization of member instances
        cpqTemplateId = apexpages.currentpage().getparameters().get('Id');
        contentToUpload = new ContentVersion();
        
        //Retrieving additing details for the Q2C template
        cpqTemplate = [SELECT ID, Template_Document_Id__c, Production_Version__c, Name
                       FROM CPQ_Template__c
                       WHERE ID =: cpqTemplateId];
        
        //get the related OSR record
        Id osrID = apexpages.currentpage().getparameters().get('OSRID');
		osr = [SELECT Id, Name, Completed_Date__c, Status__c, Updated_Version_Number__c FROM OSR__c WHERE Id = :osrID];
    }
    
    /**
     *  Description     :   Method to have the logic as:-
	 *                      	When the user clicks save:
     *                       	File should upload as a new ContentVersion of the related ContentDocument (ie: cpqTemplate.Template_Document_Id__c)
     *                       	-cpqTemplate.Production_Version__c should be updated with the related Template Document's new version number
     * 
     *  Created By      :   Abhinav Sharma    
     * 
     *  Created Date    :   05/31/2017
     * 
     *  Revision Logs   :   V_1.0 - Created 
    **/ 
    public PageReference uploadContentAndUpdateQ2CTemplate() {
        
        //Page reference
        PageReference pg;
        
        //Create a save point
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            validate();
            
            //Checking if a file is uploaded onto the VF page
            if(fileContent != null) {
                
                //Checking if Template_Document_Id__c field is populated on CPQ template record or not
                if(String.isNotBlank(cpqTemplate.Template_Document_Id__c)) {
                    
                    //PathOnClient will automatically captured from the VF page itself while uploading the file
                    //Updating fields values on the content version instance
                    contentToUpload.VersionData = fileContent;
                    contentToUpload.ContentDocumentId = cpqTemplate.Template_Document_Id__c;
                    contentToUpload.ReasonForChange = '[Changed per OSR: ' + osr.Name + ']';
                    contentToUpload.title = contentToUpload.PathOnClient;
                    
                } else {
                    
                    //Updating fields values on content version instance
                    contentToUpload.versionData = fileContent;
                    contentToUpload.title = contentToUpload.PathOnClient;
                    contentToUpload.pathOnClient = contentToUpload.PathOnClient;
                    contentToUpload.FirstPublishLocationID = UserInfo.getUserId();
                }
                
                /*we will only need to insert the contentWorkspaceMember if users without Author access on the library need to make an update
                 * ContentWorkspaceMember cwm = new ContentWorkspaceMember(ContentWorkspaceId='058V0000000AohP',
                                                                        ContentWorkspacePermissionId='05PC00000000EzJMAU',
                                                                        MemberId=UserInfo.getUserId());
                insert cwm;*/
                
                //insert content version record
                insert contentToUpload;
                
                //Updating CPQ template instance with updated fields value
                List<ContentVersion> contentVersions = [SELECT ID, VersionNumber, ContentDocumentID 
                                                        FROM ContentVersion
                                                        WHERE ID =: contentToUpload.ID];
                
                //Checking list for size value and updating CPQ template instance with updated field values
                if(contentVersions.size() > 0) {
                    cpqTemplate.Production_Version__c = Integer.valueOf(contentVersions[0].VersionNumber);
                    osr.Updated_Version_Number__c = Integer.valueOf(contentVersions[0].VersionNumber);
                    
                    //Checking if "Template_Document_Id__c" field is having blank/null value with it
                    if(String.isBlank(cpqTemplate.Template_Document_Id__c) 
                    	&& String.isNotBlank(contentVersions[0].ContentDocumentID)
                    )
                    	cpqTemplate.Template_Document_Id__c = String.valueOf(contentVersions[0].ContentDocumentID).subString(0, 15);
                }
                
                //update the OSR's completed date and status fields
                osr.Completed_Date__c = Date.today();
                osr.Status__c = 'Completed';
                
                //insert content version record
                update cpqTemplate;
                update osr;
                
                //Member instances re-initialization
                reInitializeMemberInstances();
                
                //Setting page reference
                return back();
        
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, System.Label.ERROR_FILE_SELECTION_IS_REQUIRED));
                reInitializeMemberInstances();
                return null;
            }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, ex.getMessage()));
            reInitializeMemberInstances();
            Database.rollback(sp);
            return null;
        }
    }
    
    public pageReference back() {
        return new PageReference('/' + osr.Id);
    }
    
    //method to re-initialize the member instances
    public void reInitializeMemberInstances() {
        fileContent = null;
        contentToUpload = new ContentVersion();
    }
    
    /**
     *  Description     :   validate that OSR has not already been completed, and that the user has access to the document.
     * 
     *  Created By      :   Victor Hanson
     * 
     *  Revision Logs   :   V_1.0 - 06/06/2017 - Created 
    **/ 
    public void validate() {
        //make sure the completed date is not already populated
        if (osr.Completed_Date__c != null)
            throw new customException('Cannot perform update, this OSR has already been completed.');
        
        //check to see if the user has access to modify the document
        List<UserRecordAccess> lstUserRecordAccess = [SELECT RecordId, HasEditAccess
                                                      FROM UserRecordAccess 
                                                      WHERE UserId = :UserInfo.getUserId() 
                                                      AND RecordId = :cpqTemplate.Template_Document_Id__c];
        if (!lstUserRecordAccess[0].HasEditAccess)
        	throw new customException('You do not have access to the library where the related template is stored.  Request access to this library then try again.');
    }
}