/*
Purpose         :   Batch class to create convert attachments to files.

Create By       :   Mahendra Swarnkar

Created Date    :   01/02/2020

Revision Log    :   V1.0 - Created - 01/02/2020 - CR-20180704-12321

*/
global without sharing class Batch_ConvertAttachmentsToFiles implements Database.Batchable<SObject>, Database.Stateful 
{
    public String debugLogs;
    public String queryStr;
    public List<String> listOfObjectAPIName;
    public String objApiName1;
    
    global Batch_ConvertAttachmentsToFiles(String objApiName, List<String> listOfObjectAPIName)
    {
        if(listOfObjectAPIName != null && listOfObjectAPIName.size() > 0)
        {
            this.objApiName1 = listOfObjectAPIName[0];
            Integer removeElimentIndex = listOfObjectAPIName.indexOf(listOfObjectAPIName[0]);
            
            listOfObjectAPIName.remove(removeElimentIndex);
            this.listOfObjectAPIName = listOfObjectAPIName;
        }
        
        //Event and Task are handled sepretely.
        if(objApiName1 == 'Event' || objApiName1 == 'Task'){
            
            queryStr = 'SELECT Id, ParentId, Name, Body, OwnerId FROM Attachment Where Parent.Type =: objApiName1';
            
        }else if(String.isBlank(queryStr)) 
        {
            queryStr = '';
            if(objApiName1 != null)
            {
                queryStr = 'SELECT Id, ParentId, Name, Body, OwnerId FROM Attachment Where';
                queryStr += ' ParentId IN (Select Id From ' + objApiName1 + ')';
            }   
        }        
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, list<Attachment> scope) 
    {
		List<ContentVersion> listOfContentVersions = new list<ContentVersion>();
        for(Attachment at : (list<Attachment>)scope) 
        {
            if(at.ParentId != null && String.isNotBlank(at.Name) && at.body != null) 
            {
                //populating connection with the instances of files having details from correspodning attachments
                listOfContentVersions.add(createContentVersionInstance(at));
            }
        }
        if(listOfContentVersions.size() > 0) 
        {
            Util.byPassAllTriggers = true;
            
            //Creating files synonyms to the attachments
            debugLogs += DatabaseUtilities.createLog(Database.insert(listOfContentVersions, false));
            
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            for(ContentVersion cV : [SELECT ID, ContentDocumentId, 
                                     Attachment_ID__c, Attachment_Parent_ID__c
                                     FROM ContentVersion
                                     WHERE ID IN : listOfContentVersions]
			) 
            {
                if(String.isNotBlank(cv.Attachment_ID__c) 
					&& string.isNotBlank(cv.Attachment_Parent_ID__c)   
					&& cv.Attachment_ID__c instanceOf ID 
					&& cv.Attachment_Parent_ID__c instanceOf ID 
				) 
                {
                    contentDocumentLinks.add(createContentDocumentLink(cV));
                }
            }
            if(contentDocumentLinks.size() > 0) 
            {
                Util.byPassAllTriggers = true;
                
                //Records for which we have inserted files for the attachments. Now, we are making sure that on files we have
                //required access for those records.
                debugLogs += DatabaseUtilities.createLog(Database.insert(contentDocumentLinks, false));
				
				Util.byPassAllTriggers = false;
            }
        }
    }
    
    //Finish method
    global void finish(Database.BatchableContext BC) 
    {
        if(debugLogs != '') 
        {
            List<User> sfAdminUsers = [Select Email FROM User 
                                       WHERE Name = 'Salesforce Administrator' 
                                       AND IsActive = true 
                                       AND Profile.Name = 'System Administrator' 
                                       AND Email != null LIMIT 1];
            if(sfAdminUsers.size() > 0)    
            {
                Util.sendBatchStatus(BC.getJobId(), 'Batch_ConvertNotesToFiles', debugLogs, 'dipesh.gupta@fexle.com');        
            }
        }
        
        if(listOfObjectAPIName.size() > 0 ){
            objApiName1 = listOfObjectAPIName[0];
            if(objApiName1 != null){
                Batch_ConvertAttachmentsToFiles batch = new Batch_ConvertAttachmentsToFiles(objApiName1, listOfObjectAPIName);
                Database.executeBatch(batch,Integer.valueOf(label.ConvertAttachmentBatchSize));
            }
        }
    }
    
    private ContentVersion createContentVersionInstance(Attachment at) 
    {
        ContentVersion doc = new ContentVersion();
        doc.versionData = at.body;
        doc.title = at.Name;
        doc.pathOnClient = at.Name;
        doc.FirstPublishLocationID = UserInfo.getUserId();
        doc.Attachment_ID__c = at.Id;
        doc.Attachment_Parent_ID__c = at.ParentId;
        return doc;
    }
    
    private ContentDocumentLink createContentDocumentLink(ContentVersion cv) 
    {
        ContentDocumentLink cdl = new ContentDocumentLink();    
        cdl.ContentDocumentId = cV.ContentDocumentId;
        cdl.LinkedEntityId = cv.Attachment_Parent_ID__c;
        cdl.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
        cdl.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
        return cdl;
    }
}