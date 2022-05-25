/**
*   Description     :   Logic Controller which is used by the ET_CPQ Exception Requests email template for the Approval Request Email
*                
*   Created by      :   Subhash Garhwal
*
*   Created Date    :   05/24/2019
*
*   Revision Log    :   V1.0 - Created -
*/
public without sharing class ET_CPQExceptionRequestsController {
    
    public String exceptionString {get; set;}
    //Variables for records
    public String cpqExceptionRequestsIds {get; set;}
    public List <ContentDistribution> associatedAttachments {get; set;}
    
    
    public ET_CPQExceptionRequestsController() {
		        
        associatedAttachments = getAttachmentsLink();
        system.debug('@@@@@@@ in constructor');
        
    } 
    
    /**
     * @description: Grabs the data needed for the ET_CPQExceptionRequests vf component used in Request Legal Approval emails
     **/
    
    public List<ContentDistribution> getAttachments () {
        
        if (associatedAttachments == null) {
            associatedAttachments = getAttachmentsLink();
        }
        return associatedAttachments;
    }
    
    public List<ContentDistribution> getAttachmentsLink () {
        exceptionString = '';
        Map<Id, ContentDistribution> mapDocumentIdWithContentDistribution = new Map<Id, ContentDistribution>();
        
        //Check for CPQ Exception Request Ids.
        if(String.isNotBlank(cpqExceptionRequestsIds)) {
           
            Map<Id, List<ContentVersion>> mapDocumentIdWithContentVersions = new Map<Id, List<ContentVersion>>();
            
            //Loop over ContentDocumentLink.
            for(ContentDocumentLink contentDocLink : [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:cpqExceptionRequestsIds and LinkedEntity.Type='CPQ_Exception_Request__c']){
                
                if(!mapDocumentIdWithContentVersions.containsKey(contentDocLink.ContentDocumentId))
                    mapDocumentIdWithContentVersions.put(contentDocLink.ContentDocumentId, new List<ContentVersion>()); 
            }
            
            //Check for attachments Id.
            if(mapDocumentIdWithContentVersions.size() > 0) {
                
                Set<Id> setContentVersionIds = new Set<Id>();
                
                for(ContentVersion contVersion : [SELECT ID, ContentDocumentId, IsLatest, ContentVersion.Title FROM ContentVersion WHERE ContentDocumentId IN: mapDocumentIdWithContentVersions.KeySet()]) {
                    
                    if(contVersion.IsLatest == true && mapDocumentIdWithContentVersions.containsKey(contVersion.ContentDocumentId)) {
                        
                        mapDocumentIdWithContentVersions.get(contVersion.ContentDocumentId).add(contVersion);
                    
                    	setContentVersionIds.add(contVersion.Id);
                    }
                }
           		
                if(setContentVersionIds.size() > 0){
                    
                    //loop over the content distribution records
                    for(ContentDistribution contDistribution : [Select Id, ContentVersionId, ContentDocumentId, DistributionPublicUrl, ContentVersion.Title, Name 
                                                                		FROM ContentDistribution WHERE ContentVersionId IN : setContentVersionIds]) {
                                                                            
						if(contDistribution.ContentDocumentId != null && !mapDocumentIdWithContentDistribution.containsKey(contDistribution.ContentDocumentId)){
                        	mapDocumentIdWithContentDistribution.put(contDistribution.ContentDocumentId, contDistribution);
                        }                               	
                    }
                }    
        	}
        }
        if(mapDocumentIdWithContentDistribution.size() > 0 && mapDocumentIdWithContentDistribution.values() != null && mapDocumentIdWithContentDistribution.values().size() > 0 ){
            
            List<ContentDistribution> temp = mapDocumentIdWithContentDistribution.values();
                    	
			return temp;
            
        } 
         	
		return null;           
    }
}