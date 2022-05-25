/*
Purpose         :   Batch class to create convert attachments to files.

Create By       :   Mahendra Swarnkar

Created Date    :   01/02/2020

Revision Log    :   V1.0 - Created - 01/02/2020 - CR-20180704-12321

*/
global without sharing class Batch_ConvertNotesToContentNotes implements Database.Batchable<SObject>, Database.Stateful 
{
    public String debugLogs = '';
    public String queryStr;
    public List<String> listOfObjectAPIName;
    public String objApiName1;
    
    global Batch_ConvertNotesToContentNotes(String objApiName, List<String> listOfObjectAPIName)
    {
        if(listOfObjectAPIName != null && listOfObjectAPIName.size() > 0)
        {
            this.objApiName1 = listOfObjectAPIName[0];
            Integer removeElimentIndex = listOfObjectAPIName.indexOf(listOfObjectAPIName[0]);
            
            listOfObjectAPIName.remove(removeElimentIndex);
            this.listOfObjectAPIName = listOfObjectAPIName;
        }
        if(String.isBlank(queryStr)) 
        {
            queryStr = '';
            if(objApiName1 != null)
            {
                queryStr = 'SELECT Id, ParentId, Title, Body,OwnerId FROM Note Where ';
                queryStr += ' ParentId IN (Select Id From ' + objApiName1 + ')';
                //Added by Mahendra Swarnkar - 04/30/2020 - CR-20200424-13979
                queryStr += ' AND CreatedDate > 2020-04-23T00:00:00Z AND CreatedBy.Name != \'' + Label.Environment_Manager_Name + '\'';
            }   
        }        
    }
    
    global Database.Querylocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC, list<Note> scope) 
    {
        Map<Id,Note> mapParentIdWithContentNote = new Map<Id,Note>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        
        for(Note nt : scope) 
        {
            //Modified by - Mahendra Swarnkar - 04-14-2020 - CR-20200117-13633
            if(nt.ParentId != null && String.isNotBlank(nt.Title)) 
            {
                // insert ContentNotes
                ContentNote conNote = createContenNotes(nt);
                
                if(conNote != null && conNote.Id != null)
                {
                    mapParentIdWithContentNote.put(conNote.Id,nt);
                }
            }
        }
        
        if(mapParentIdWithContentNote != null && mapParentIdWithContentNote.size() > 0)
        {
            contentDocumentLinks.addAll(createContentDocumentLink(mapParentIdWithContentNote));
        }
        
        if(contentDocumentLinks != null && contentDocumentLinks.size() > 0 )
        {
            Util.byPassAllTriggers = true;
            debugLogs += DatabaseUtilities.createLog(Database.insert(contentDocumentLinks, false));
            Util.byPassAllTriggers = false;
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
                Util.sendBatchStatus(BC.getJobId(), 'Batch_ConvertNotesToFiles', debugLogs, sfAdminUsers[0].Email);        
            }
        }
        
        if(listOfObjectAPIName.size() > 0 ){
            objApiName1 = listOfObjectAPIName[0];
            if(objApiName1 != null){
                Batch_ConvertNotesToContentNotes batch = new Batch_ConvertNotesToContentNotes(objApiName1, listOfObjectAPIName);
                Database.executeBatch(batch, 20);
            }
        }
    }

	 //Modified by - Mahendra Swarnkar - 04-14-2020 - CR-20200117-13633    
	 //Modified escapeXML() 
    private ContentNote createContenNotes(Note nt) 
    {
        ContentNote cn = new ContentNote();
        cn.Title = nt.Title;
        if(nt.Body != null)
        {
        	cn.Content = blob.valueOf(nt.Body.escapeXML() );    
        }
        else
        {
        	cn.Content = blob.valueOf(nt.Title.escapeXML() );    
        }
        cn.CreatedById = nt.OwnerId;
        
        // byPass Trigger
        Util.byPassAllTriggers = true;
        insert cn;
        return cn;
    }
    
    
    private List<ContentDocumentLink> createContentDocumentLink(Map<Id,Note> mapCnIdWithNotes) 
    {
        List<ContentDocumentLink> listOfConDocLink = new List<ContentDocumentLink>();
        for(Id cnId : mapCnIdWithNotes.keySet())
        {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cnId;
            cdl.LinkedEntityId = mapCnIdWithNotes.get(cnId).ParentId;
            cdl.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
            cdl.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
            listOfConDocLink.add(cdl);
        }
        return listOfConDocLink;
    }
}