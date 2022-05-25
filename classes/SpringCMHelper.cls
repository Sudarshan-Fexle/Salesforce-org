/**
 *  Description     :  Class to hold thr SpringCM functionality
 *
 *  Created By      :  Victor Hanson
 *
 *  Created Date    :  05/2/2017
 *
 *  Revision Logs   :   V1.0 - Created - Victor Hanson
 *						V1.0 - Modified - 05/5/2017 - Subhash Garhwal - Do commenting and formating as per API service best practies
 **/
public without sharing class SpringCMHelper {
    
    //variables
    public string documentGUID { get; set; }
    public Id proposalId { get; set; }
    public string workflowParameterString { get; set; }
    
    //Authorization helper
    private OAuthHelper authHelper { get; set; }
    
    //Get all the configuration details 
    public static SpringCM_Configuration__mdt springCMConfig {
        get {
            if (springCMConfig == null) springCMConfig = [Select Id, MasterLabel, DeveloperName, Auth_Endpoint_URL__c, ClientId__c, Client_Secret__c,
                                                          Document_Endpoint_Suffix__c, Download_Endpoint_URL__c, External_Review_Endpoint_Suffix__c,
                                                          Folder_GUID__c, Task_Endpoint_URL__c, Upload_Endpoint_Suffix__c, Upload_Endpoint_URL__c,
                                                          Workflow_Endpoint_Suffix__c, Sender_href__c, Item_href__c
                                                          From SpringCM_Configuration__mdt Where DeveloperName =: Label.SpringCM_Configuration];
            return springCMConfig;
        }
        set;
    }
    
    //Constructor
    public SpringCMHelper(Id proposalId) {
    	this.proposalId = proposalId;
    	//Initialize oauth helper
        authHelper = new OAuthHelper();
    }
    
    /**
	 *	@description	:	Method to upload Documents   
	 *						
	 *	@args			:	Id
	 *
	 *	@return			:	String (document GUID)
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public string uploadDocument(Id contentId, string folderGUID, string fileNameOverride) {
    	
    	try {
    		
	    	//Get the latest content doc
	        List<ContentDocument> contentDoc = [SELECT Id, Title, FileExtension, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentId];
	        
	        //Check for content document
	        if(contentDoc.size() > 0) {
	        	
	        	if(!Test.isRunningTest()) {
	        	
		        	//Get Content Version 
		        	ContentVersion document = [SELECT Id, VersionData from ContentVersion WHERE Id =: contentDoc[0].LatestPublishedVersionId];
                    
                    //override the file name in some cases.  ie: originating document
                    string fileName;
                    if (fileNameOverride == null) fileName = contentDoc[0].Title;
                    else fileName = fileNameOverride;
		        	
		        	//upload document
			        Map<string, Object> uploadResponseMap = uploadDocument(fileName + '.' + contentDoc[0].FileExtension, document.VersionData, folderGUID);
			        
		        
		        	//Get the Document Id
	           		 documentGUID = getGUIDFromURL(uploadResponseMap);
	        	}
                
                return documentGUID;
            } else {
                //check to see if the user is part of the "Read Only - CPQ Editable LOAs Library" public group
                list<groupmember> groupMembers = [SELECT id, Group.Name from groupmember where userorgroupid = :userinfo.getUserId() AND Group.Name = 'Read Only - CPQ Editable LOAs Library'];
                if (groupMembers.size() == 0) 
                {//Must be assigned to this group to send proposals for redline, because it grants read access to the LOA library.
                    throw new customException('You must be part of the \'Read Only - CPQ Editable LOAs Library\' public group to send for Redline.  Please request that you be added to this public group, then try again.');
                } 
                else 
                {//they are part of the public group, so maybe the content record no longer exists
                    throw new customException('There is no document with content Id \'' + contentId + '\'.');
                }
            }
	        // Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
	        //return null;
    	} catch(Exception e) {
            
            //Add Error on page
            throw new customException(e.getMessage());
            
	    // Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
            //return null;
        }
    }
    
    
    /**
	 *	@description	:	Method to download a document   
	 *						
	 *	@args			:	String
	 *
	 *	@return			:	Blob
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public blob downloadDocument(string fileType) {
    	
    	//Set HttpRequest
        HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Download_Endpoint_URL__c + springCMConfig.Document_Endpoint_Suffix__c + documentGUID,
        														   authHelper.token_type + ' ' + authHelper.access_token, null,'GET', 60*1000);
    	if (fileType != null) request.setHeader('ACCEPT', fileType);
        //Send HTTP Request
        HttpResponse res = HTTPService.send(request);
        
        return res.getBodyAsBlob();
    }
    
    /**
	 *	@description	:	Method to download a document   
	 *						
	 *	@args			:	String, String, String
	 *
	 *	@return			:	String
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public static string getContentDocumentName(string proposalName, string docVersion, string typeChar, string nameSuffix) {
        //pad the document version with zeros
        docVersion = docVersion.leftPad(3, '0');
        string docType = 'docx';
        if (typeChar == 'p') docType = 'pdf';
        if (nameSuffix != null) docVersion += nameSuffix;
        return proposalName + '_v' + docVersion + typeChar;
    }
    
    public ContentVersion createContentVersion(SBQQ__Quote__c proposal, string docType) {
        return createContentVersion(proposal, docType, null);
    }
    
    public ContentVersion createContentVersion(SBQQ__Quote__c proposal, string docType, string nameSuffix) {
        
        //
        string fileType = null;
        string contentDocId = null;
        
        if (nameSuffix == null) {
            contentDocId = proposal.LOA_Word_Document_ID__c;
            
            if (docType.equalsIgnoreCase('PDF')) {
                contentDocId = proposal.LOA_PDF_Document_ID__c;
                fileType = 'PDF';
            }
        }
        
        string docTypeChar = docType.subString(0, 1); //either 'd' (Docx) or 'p' (PDF)
        return new ContentVersion(VersionData=downloadDocument(fileType),
                                  ContentDocumentId=contentDocId,
                                  ReasonForChange='Redlines Approved',
                                  pathOnClient='/' + SpringCMHelper.getContentDocumentName(proposal.Name, proposal.LOA_Document_Version__c, docTypeChar, nameSuffix) + '.' + docType,
                                  title=SpringCMHelper.getContentDocumentName(proposal.Name, proposal.LOA_Document_Version__c, docTypeChar, nameSuffix));
    }
    
    public string fullDocPath {
        get {
            return fullDocPath = springCMConfig.Download_Endpoint_URL__c + springCMConfig.Document_Endpoint_Suffix__c + documentGUID;
        }
        set;
    }
    
    /**
	 *	@description	:	Method to start the workflow in SpringCM on a document.
								this waits for response from redline and updates the record in SF once returned from Redline  
	 *						
	 *	@args			:	String
	 *
	 *	@return			:	void
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public map<String, Object> startSpringCMWorkflow(string workflowName) {
        
        if (workflowParameterString == null) throw new customException('workflowParameterString must be set prior to startSpringCMWorkflow()');
        
        //create the redline workflow body
        SpringCMWrapper.workflowBody workflowBody = new SpringCMWrapper.workflowBody(
            workflowName,
            workflowParameterString,
            fullDocPath
        );
        
        //Set HttpRequest
        HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Task_Endpoint_URL__c + springCMConfig.Workflow_Endpoint_Suffix__c,
        														   authHelper.token_type + ' ' + authHelper.access_token, JSON.serialize(workflowBody),'POST', 60*1000);
    	
        //Send HTTP Request
        HttpResponse res = HTTPService.send(request);
        return (map<String, Object>) json.deserializeUntyped(res.getBody());
    }
    
    /**
	 *	@description	:	Method to get the "Status" value from a document in SpringCM
	 *						
	 *	@args			:	String
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public string getDocumentStatus() {
    	
        HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Task_Endpoint_URL__c + springCMConfig.Document_Endpoint_Suffix__c 
                                                                       + documentGUID + '?expand=AttributeGroups',
                                                                       authHelper.token_type + ' ' + authHelper.access_token, null,'GET', 60*1000);
        HttpResponse res = HTTPService.send(request);
        //map<String, Object> o = helper.getDocumentStatus();
        map<String, Object> docMap = (map<String, Object>) json.deserializeUntyped(res.getBody());
        map<String, Object> AttributeGroups = (map<String, Object>) docMap.get('AttributeGroups');
        map<String, Object> Salesforce_Group = (map<String, Object>) AttributeGroups.get('Salesforce_Group');
        map<String, Object> Status = (map<String, Object>) Salesforce_Group.get('Status');
        string statusValue = (string)Status.get('Value');
        system.debug('@@@@statusValue:' + statusValue);
        return statusValue;
    }
    
    /**
	 *	@description	:	Method to add Attributes to the document in SpringCM
	 *						
	 *	@args			:	String
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public map<String, Object> addDocumentAttributes() {
        
        //create the attribute wrapper
    	SpringCMWrapper.DocAttributeWrapper docAttrWrapper = new SpringCMWrapper.DocAttributeWrapper('Sent', proposalId);
        system.debug('@@JSON.serialize(docAttrWrapper):' + JSON.serialize(docAttrWrapper));
    	//Set HttpRequest
        HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Task_Endpoint_URL__c + springCMConfig.Document_Endpoint_Suffix__c + documentGUID,
        														   authHelper.token_type + ' ' + authHelper.access_token, JSON.serialize(docAttrWrapper),'PUT', 60*1000);
        //Send HTTP Request
        HttpResponse res = HTTPService.send(request);
        system.debug('@@addDocumentAttributes res.getBody:' + res.getBody());
        return (map<String, Object>) json.deserializeUntyped(res.getBody());
    }
    
    /**
	 *	@description	:	Method to send a document for redline   
	 *						
	 *	@args			:	String, String, DateTime, String, String, String
	 *
	 *	@return			:	String (Task GUID)
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public string redlineReview(String recipientName, String recipientEmail, DateTime dueDate, String subject, String message) {
        
		try {
			
	        //Pass data into wrapper to setup Json
	        SpringCMWrapper.ExternalReviewTask externalReview = new SpringCMWrapper.ExternalReviewTask(recipientName, recipientEmail, dueDate, documentGUID, subject, message, springCMConfig.Sender_href__c, springCMConfig.Item_href__c);
	        
	        //Set HttpRequest
	        HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Task_Endpoint_URL__c + springCMConfig.External_Review_Endpoint_Suffix__c,
                                                                           authHelper.token_type + ' ' + authHelper.access_token, JSON.serialize(externalReview),'POST', 60*1000);
	        														   
	        //Send HTTP Request
	        HttpResponse res = HTTPService.send(request);
	        
	        //Check for status code
	        if(res.getStatusCode() == 201) {
	        
	        	Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                system.debug('@@@@:' + JSON.serializePretty(responseMap));
                //Get the Task Id
                return getGUIDFromURL(responseMap);
	        } else
				throw new customException(res.getBody());
		    	
		} catch(Exception e) {
            
            //Add Error on page
            throw new customException(e.getMessage());
        }
	// Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
        //return null;
    }
    
     /**
	 *	@description	:	Method to upload Documents   
	 *						
	 *	@args			:	String, Blob, String
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public Map<string, object> uploadDocument(String fileName, Blob document, String folderGUID) {
        
        try {
        	//EmailHandler.sendEmail('hansonv@advisory.com', 'test', EncodingUtil.base64Encode(document));
	        //Set HttpRequest
            HttpRequest request = HTTPRequestBuilder.createSpringCMRequest(springCMConfig.Upload_Endpoint_URL__c 
                                                                           + springCMConfig.Upload_Endpoint_Suffix__c.replace('{id}', folderGUID) 
                                                                           + '?name=' + encodingutil.urlEncode(fileName, 'utf-8'),
                                                                           document, 
                                                                           authHelper.token_type + ' ' + authHelper.access_token, 
                                                                           EncodingUtil.base64Encode(document),
                                                                           'POST', 
                                                                           60*1000);

	        HttpResponse res = HTTPService.send(request);
	        
	        //Check for status
	        if(res.getStatusCode() == 201) {

				String resp = res.getBody();
					
		        //Return the response
		        return (Map<String, Object>) JSON.deserializeUntyped(resp);        	
	        } else
	        	throw new customException(res.getBody());
	    	
		// Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
	    	//return null;
	    	    	
	    } catch(Exception e) {
            
            //Add Error on page
            throw new customException(e.getMessage());
			
	    // Comment By - Rajeev Jain - CR-20200217-13763 - 06/15/2020
            //return null;
        }
    }
    
    /**
	 *	@description	:	Parse the GUID from a URL
	 *						
	 *	@args			:	Map<String, Object>
	 *
	 *	@return			:	String (GUID)
	 *
	 *	@revision Log	:	V_1.0 - 05/2/2017 - Created - Victor Hanson 
	 *
	 **/
    public string getGUIDFromURL(map<String, Object> responseMap) {
        string url = '';
        if(responseMap.size() > 0 && responseMap.containsKey('Href')) {
            
            //get the url that was returned
            String docURL = (String) responseMap.get('Href');
            List<string> docURLSplit = docURL.split('/');
            //return the external GUID
            url = docURLSplit[docURLSplit.size()-1];    	
        }
        return url;
    }
    
    /**
	 *	@description	:	begins the "Compare Documents" workflow that has been defined in SpringCM.
	 *						This process compares the original LOA vs the approved redlined LOA
	 *						
	 *	@args			:	void
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 07/13/2017 - Created - Victor Hanson 
	 *
	 **/
    public map<String, Object> startSpringCMWorkflow_CompareDocs() {
        
        //get the proposal's original document id
        SBQQ__Quote__c proposal = [SELECT id, External_Document_Original_GUID__c, External_Document_GUID__c FROM SBQQ__Quote__c WHERE Id = :proposalId];
        
        //create the parameter string for redline submission
        workflowParameterString = 'Proposal_GUID=\"' + proposalId + '\" DocPath_New=\"' + proposal.External_Document_GUID__c 
            				   									  + '\" DocPath_Old=\"' + proposal.External_Document_Original_GUID__c + '\"';
        
        return startSpringCMWorkflow('Compare Documents');
    }
    
    /**
	 *	@description	:	begins the "Redline Process" workflow that has been defined in SpringCM.
	 *						This process tells SpringCM to wait until the document has been returned from Redline.  Once done, SpringCM updates fields on Proposal.
	 *						
	 *	@args			:	void
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 07/13/2017 - Created - Victor Hanson 
	 *
	 **/
    public map<String, Object> startSpringCMWorkflow_Redline() {
        
        //get the proposal's owner email
        SBQQ__Quote__c proposal = [SELECT id, Owner.Email FROM SBQQ__Quote__c WHERE Id = :proposalId];
        
        //create the parameter string for redline submission
        workflowParameterString = 'Proposal_GUID=\"' + proposalId + '\" DocPath=\"' + documentGUID + '\" ReplyToEmail=\"' + proposal.Owner.Email + '\"';
        
        return startSpringCMWorkflow('Redline Process');
    }
    
    /**
	 *	@description	:	when the External Review GUID contains "Complete", this indicates the document comparison 
	 *						process is complete in SpringCM, and the file should be retrieved and attached to the related Proposal.
	 *						
	 *						
	 *	@args			:	void
	 *
	 *	@return			:	Map<String, Object>
	 *
	 *	@revision Log	:	V_1.0 - 07/13/2017 - Created - Victor Hanson 
	 *
	 **/
    public static void attachComparedLOA(list<SBQQ__Quote__c> quotes, map<Id, SBQQ__Quote__c> oldQuoteMap) {
        
        set<Id> quoteIds = new set<Id>();
        
        for (SBQQ__Quote__c quote : quotes) {
            
            //get the old version of the quote
            SBQQ__Quote__c oldQuote = oldQuoteMap.get(quote.Id);
            
            //check to see if the External_Review_GUID__c field contains 'Complete'
            if (quote.External_Review_GUID__c != null
                && quote.External_Review_GUID__c.contains('Complete')
                && oldQuote.External_Review_GUID__c != quote.External_Review_GUID__c) 
            {
                
                quoteIds.add(quote.Id);
            }
        }
        
        //if there are quotes that have comparison documents, call the future method to get them
        if (quoteIds.size() > 0) attachComparedLOA(quoteIds);
    }
    
    //callouts not supported in triggers, so we have to use a future method to get the compared document
    @future(callout=true)
    public static void attachComparedLOA(set<Id> quoteIds) {
        
        list<ContentVersion> contentVersionsToInsert = new list<ContentVersion>();
        
        for (SBQQ__Quote__c quote : [SELECT Id, Name, External_Document_Original_GUID__c, LOA_Document_Version__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
            
            //instantiate SpringCMHelper
            SpringCMHelper helper = new SpringCMHelper(quote.Id);
            
            //setup the springCMHelper
            helper.proposalId = quote.Id;
            helper.documentGUID = quote.External_Document_Original_GUID__c;
            
            //add a new Word version of document with the copmparison between Original -> Approved version from SpringCM
            ContentVersion cv = helper.createContentVersion(quote, 'docx', '_Comparison_');
            insert cv;
            
            cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            
            //link the content to the Quote
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=quote.Id;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId=cv.ContentDocumentId;
            
            insert contentlink;
        }
        
        if (contentVersionsToInsert.size() > 0) insert contentVersionsToInsert;
    }
}