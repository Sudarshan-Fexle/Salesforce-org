/**
 *  Description     :   Helper class for ContentVersion object trigger i.e. Trigger_ContentVersion
 * 
 *  Created By      :   Abhinav Sharma    
 * 
 *  Created Date    :   09/01/2016
 * 
 *  Revision Logs   :   V_1.0 - Created - CR-20160224-9640
 *		        V_1.1 - Modified By - Subhash Garhwal - CR-20181019-12685 - 05/29/2019  - Added a new method "pushCalculatorToProposal"
 *		        V_1.2 - Modified By - Subhash Garhwal - CR-20210811-15348
 *
**/ 
public without sharing class ContentVersionTriggerHelper {
    
    //Added By - Abhinav Sharma - CR-20160224-9640 - 09/01/2016
    /**
     *  @description    :   This method will grant/add additional access to Case/MS record(s) of the newly created file(s).  
     * 
     *  @args           :   List of ContentVersion
     * 
     *  @return         :   void
     * 
    **/ 
    public static void grantAdditionalSharingonFiles(List<ContentVersion> newContentVersions) {
        
        //Set of IDs
        Set<Id> setOfContentVersionIds = new Set<Id>();
        
        //Loop through ContentVersion records and populating collection with value
        for(ContentVersion cV : newContentVersions)
            setOfContentVersionIds.add(cV.Id);
        
        //Calling future method for further processing
        //this is because invoking record sharing is created by SFDC as post commit logic at end of Order of execution
        // Update - 6/9/17 - VH - CR-10808
        if (!system.isBatch() && !system.isFuture() && !system.isScheduled())
            processContentVersionRecords(setOfContentVersionIds);
    }    
    
    @future(callout=false)
    public static void processContentVersionRecords(Set<Id> setOfContentVersionIds) {
        
        //Checking & validating collection for null and size value
        if(setOfContentVersionIds != null && setOfContentVersionIds.size() > 0)
        {
            
            //List of content version (Type casting)
            list<ContentVersion> newContentVersions = [SELECT ID, ContentDocumentId, versionData, Title, FileType, 
                                                       Attachment_Parent_ID__c, Attachment_ID__c 
                                                       FROM ContentVersion
                                                       WHERE ID IN : setOfContentVersionIds];
            
            //Checking list for null and size value
            if(newContentVersions != null && newContentVersions.size() > 0)
            {
                
                //Set of ContentDocumentIDs associated with the new content version records
                Map<Id, ContentVersion> mapOfContentDocumentIDWIthContentVersionIDs = new Map<Id, ContentVersion>();
                
                //Loop through content version records
                for(ContentVersion cV : newContentVersions) 
                {
                    if(cV.ContentDocumentId != null)
                        mapOfContentDocumentIDWIthContentVersionIDs.put(cV.ContentDocumentId, cV);
                }
                
                //Checking set for size value
                if(mapOfContentDocumentIDWIthContentVersionIDs.values().size() > 0) 
                {
                    
                    //Map to hold the content version Id as key and corresponding list of links as value
                    Map<Id, List<ContentDocumentLink>> mapOfContentVersionIdWithListOfLinks = new Map<Id, List<ContentDocumentLink>>();
                    
                    //Content Document IDs string
                    String contentDocumentIdsStr = ContentVersionTriggerHelper.quotedString(mapOfContentDocumentIDWIthContentVersionIDs.keySet());
                    
                    //Looping over the content document links records
                    //Checking for case and MS objects, to whom access is missing
                    for(ContentDocumentLink cL : Database.query('Select Id, LinkedEntityId, ContentDocumentId From ContentDocumentLink Where ' +
                                                                'ContentDocumentId != null AND LinkedEntityId != null AND ContentDocumentId IN ' + contentDocumentIdsStr)) 
                    {
                        
                        //Checking for key presence in the map and accordingly populating it to have the appropriate pair of values
                        if(mapOfContentVersionIdWithListOfLinks.containsKey(cL.ContentDocumentId)) 
                            mapOfContentVersionIdWithListOfLinks.get(cL.ContentDocumentId).add(cL);  
                        else  
                            mapOfContentVersionIdWithListOfLinks.put(cL.ContentDocumentId, new List<ContentDocumentLink>{cL});   
                    }
                    //Checking for the size of the map
                    if(mapOfContentVersionIdWithListOfLinks.values().size() > 0)
                    {
                        
                        //Set to hold the parent case record Ids
                        Set<Id> parentCaseRecordsIds = new set<Id>();
                        
                        //Set to hold the parent MS record Ids
                        Set<Id> parentMSRecordsIds = new set<Id>();
                        
                        //Loop through content version records
                        for(ContentVersion cVn : newContentVersions)
                        {
                            
                            //Checking document ID for null value
                            if(cVn.ContentDocumentId != null) 
                            {
                                
                                //Checking for key presence in the map
                                if(mapOfContentVersionIdWithListOfLinks.containsKey(cVn.ContentDocumentId)
                                   && mapOfContentVersionIdWithListOfLinks.get(cVn.ContentDocumentId) != null) 
                                {
                                    //Loop through content version link records associated with current context "ContentVersion" record
                                    for(ContentDocumentLink cDL : mapOfContentVersionIdWithListOfLinks.get(cVn.ContentDocumentId))
                                    {
                                        
                                        //Checking for LinkedEntityId " Case sObjectType" and accordingly setting correspodning 
                                        //flag values to true
                                        if(cDL.LinkedEntityId != null && String.valueOf(cDL.LinkedEntityId.getSObjectType()) == Constants.CASE_OBJECT)
                                            parentCaseRecordsIds.add(cDL.LinkedEntityId);
                                        
                                        //Checking for LinkedEntityId of "MS sObjectType" and accordingly setting correspodning 
                                        //flag values to true
                                        if(cDL.LinkedEntityId != null && String.valueOf(cDL.LinkedEntityId.getSObjectType()) == MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT)
                                            parentMSRecordsIds.add(cDL.LinkedEntityId); 
                                    }
                                }
                            }
                        }
                        
                        //Map of MS records
                        Map<Id, Site_Issue__c> mapOfMemberSupports = new Map<Id, Site_Issue__c>();
                        
                        //Map of Case records
                        Map<Id, Case> mapOfCases = new Map<Id, Case>();
                        
                        //Checking for size value
                        if(parentCaseRecordsIds.size() > 0)
                        {
                            
                            //Retrieving case records details from the database
                            mapOfCases = new Map<Id, Case>([SELECT ID, Member_Support_Ticket__c FROM Case
                                                            WHERE ID IN : parentCaseRecordsIds 
                                                            AND Member_Support_Ticket__c != null
                                                            AND RecordTypeId != null
                                                            AND RecordType.DeveloperName = 'EAB_Custom'  /*: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST*/]);
                        }
                        
                        //Checking for size value
                        if(parentMSRecordsIds.size() > 0) 
                        {
                            
                            //Retrieving case records details from the database
                            mapOfMemberSupports = new Map<Id, Site_Issue__c>([SELECT ID, 
                                                                              (SELECT ID 
                                                                               FROM Cases__r
                                                                               WHERE RecordTypeId != null
                                                                               AND RecordType.DeveloperName = 'EAB_Custom' /*: Constants.RECORD_TYPE_CASE_DEVELOPER_NAME_PT_SUPPORT_REQUEST*/
                                                                              )
                                                                              FROM Site_Issue__c
                                                                              WHERE ID IN : parentMSRecordsIds
                                                                              AND RecordTypeId != null
                                                                              AND RecordType.DeveloperName =: Constants.RECORD_TYPE_SITE_ISSUE_DEVELOPER_NAME_CCA_SUPPORT_REQUEST
                                                                             ]);
                        }
                        
                        //List of links to be inserted
                        List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
                        
                        //Loop through content version records
                        for(ContentVersion cVr : newContentVersions)
                        {
                            
                            //Checking document ID for null value
                            if(cVr.ContentDocumentId != null)
                            {
                                
                                //Checking for key presence in the map
                                if(mapOfContentVersionIdWithListOfLinks.containsKey(cVr.ContentDocumentId)
                                   && mapOfContentVersionIdWithListOfLinks.get(cVr.ContentDocumentId) != null)
                                {
                                    
                                    //Loop through content version link records associated with current context "ContentVersion" record
                                    for(ContentDocumentLink cDLi : mapOfContentVersionIdWithListOfLinks.get(cVr.ContentDocumentId)) 
                                    {
                                        
                                        //If link is type of case and no sharing exists for MS then add it to the list
                                        if(cDLi.LinkedEntityId != null 
                                           && String.valueOf(cDLi.LinkedEntityId.getSObjectType()) == Constants.CASE_OBJECT) 
                                        {
                                            
                                            //Checking in map for case instance and retrieving it's MS record details    
                                            if(mapOfCases.containsKey(cDLi.LinkedEntityId)
                                               && mapOfCases.get(cDLi.LinkedEntityId) != null)
                                            {
                                                
                                                //Share with MS record          
                                                ContentDocumentLink cdl4 = new ContentDocumentLink();
                                                cdl4.ContentDocumentId = cVr.ContentDocumentId;
                                                cdl4.LinkedEntityId = mapOfCases.get(cDLi.LinkedEntityId).Member_Support_Ticket__c;
                                                cdl4.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                                cdl4.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                                contentDocumentLinksToInsert.add(cdl4);    
                                            }    
                                        } else if(cDLi.LinkedEntityId != null 
                                                  && String.valueOf(cDLi.LinkedEntityId.getSObjectType()) == MemberSupportTriggerUtilities.MEMBER_SUPPORT_OBJECT)
                                        {
                                            
                                            //Checking in map for MS instance and retrieving it's Case record details    
                                            if(mapOfMemberSupports.containsKey(cDLi.LinkedEntityId)
                                               && mapOfMemberSupports.get(cDLi.LinkedEntityId) != null)
                                            {
                                                
                                                //Current context MS record instance
                                                Site_Issue__c sI = mapOfMemberSupports.get(cDLi.LinkedEntityId);
                                    
                                                //Checking for associated case record(s) existance
                                                if(sI.Cases__r != null && sI.Cases__r.size() > 0) 
                                                {
                                                    
                                                    //Share with Case record          
                                                    ContentDocumentLink cdl3 = new ContentDocumentLink();
                                                    cdl3.ContentDocumentId = cVr.ContentDocumentId;
                                                    cdl3.LinkedEntityId = sI.Cases__r[0].Id;
                                                    cdl3.ShareType = System.Label.CONTENTDOCUMENTLINK_SHARETYPE;
                                                    cdl3.Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY;
                                                    contentDocumentLinksToInsert.add(cdl3);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        //Checking for size value
                        if(contentDocumentLinksToInsert.size() > 0)
                        {
                            
                            //Bypassing all triggers
                            Util.byPassAlltriggers = true;
                            
                            //Insert content document links
                            insert contentDocumentLinksToInsert;
                            
                            //Checking for the size of list
                            if(contentDocumentLinksToInsert.size() > 0) 
                            {
                                
                                //List of attachment
                                List<Attachment> attachments = new List<Attachment>();
                                
                                //Loop through newly created files records
                                for(ContentVersion doc : newContentVersions) 
                                {
                                    
                                    //List of parent IDs
                                    List<Id> listOfIds = new List<Id>();
                                    
                                    //Checking for size valye
                                    if(mapOfCases.keySet().size() > 0)
                                    {
                                        
                                        //insert an attachment on the current context Case record
                                        Attachment att = new Attachment();
                                        att.body = doc.versionData;
                                        att.Name = doc.Title;
                                        att.ContentType = doc.FileType;
                                        
                                        //Populating list with set value
                                        listOfIds.addAll(mapOfCases.keySet());
                                        att.ParentId = listOfIds[0];
                                        
                                        if(att.ParentId != null)
                                            attachments.add(att);
                                    }
                                    
                                    //Checking for size valye
                                    else if(mapOfMemberSupports.keySet().size() > 0) 
                                    {
                                        
                                        //insert an attachment on the current context MS record
                                        Attachment att1 = new Attachment();
                                        att1.body = doc.versionData;
                                        att1.Name = doc.Title;
                                        att1.ContentType = doc.FileType;
                                        listOfIds.addAll(mapOfMemberSupports.keySet());
                                        att1.ParentId = listOfIds[0];
                                        
                                        if(att1.ParentId != null)
                                            attachments.add(att1);
                                        
                                        //Member Support Instance
                                        Site_Issue__c sI = mapOfMemberSupports.get(listOfIds[0]);
                                        
                                        //Checking for case records associated with MS record
                                        if(sI.Cases__r != null && sI.Cases__r.size() > 0) {
                                            
                                            //insert an attachment on the current context MS record
                                            Attachment att2 = new Attachment();
                                            att2.body = doc.versionData;
                                            att2.Name = doc.Title;
                                            att2.ContentType = doc.FileType;
                                            att2.ParentId = sI.Cases__r[0].Id;
                                            
                                            if(att2.ParentId != null)
                                                attachments.add(att2);
                                        }
                                    }
                                }
                    
                                //Checking for size value
                                if(attachments.size() > 0) 
                                {
                                    
                                    //Bypassing all triggers
                                    Util.byPassAlltriggers = true;
                                    
                                    //Insert attachments
                                    insert attachments;
                                    
                                    //Enabling again
                                    Util.byPassAlltriggers = false;
                                }
                            }
                        }
                    }        
                }
            }        
        }
    }

    //convert a Set<String> into a quoted, comma separated String literal for inclusion in a dynamic SOQL Query
    private static String quotedString(Set<ID> setOfStrings) {
        String newStr = '' ;
        
        //Loop through List of String
        for(ID myStr : setOfStrings)
        {
            
            String str = String.valueOf(myStr);
            newStr += '\'' + str + '\',';
        }
        
        newStr = newStr.lastIndexOf(',') > 0 ? '(' + newStr.substring(0,newStr.lastIndexOf(',')) + ')' : newStr ;
        
        return newStr;
    }
    
    /**
     *  @description    :   This method will link the ES Calculator to related Proposal  
     * 
     *  @args           :   List<ContentVersion>
     * 
     *  @return         :   void
     *
     *	@Revision Log	:	V1.0 - Subhash Garhwal - 05/29/2019 - CR-20181019-12685 - Created
     * 
    **/
    public static void pushCalculatorToProposal(List<ContentVersion> contentVersions) {
        
        Set<Id> setContentVersionIds = new Set<Id>();
        Map<Id, Id> mapContentVersionIdWithContentDocumentId = new Map<Id, Id>();
        
        //Set to hold the Proposal Names
        Set<String> setProposalNames = new Set<String>();
        
        //Map to hold the Proposal Names with ContentVersion
        Map<String, ContentVersion> mapProposalNameWithContentVersion = new Map<String, ContentVersion>();
        
        //Variable to hold the ES calculator Identifier
        String esCalculatorIdentifier = 'Calculator-Export';
        String LOA_PDF_IDENTIFIER = 'OrderForm';
        
        //Loop over the ContentVersion
        for(ContentVersion cV : contentVersions)
        {
            
            setContentVersionIds.add(cV.Id);
            mapContentVersionIdWithContentDocumentId.put(cV.Id, cV.ContentDocumentId);
            
            //Check for calculator
            if(String.isNotBlank(cV.Title) && cV.Title.containsIgnoreCase(esCalculatorIdentifier))
            {
                
                //Split the File Name to get Proposal Name
                List<String> titleBreak = cV.Title.split('-', 3);
                
                //Check titleBreak List size
                if(titleBreak.size() == 3)
                {
                    
                    //Add Content Version With Proposal Name
                    mapProposalNameWithContentVersion.put(titleBreak[0] + '-' + titleBreak[1], cV);		
                }
            }
            
            /*If(String.isNotBlank(cV.Title) && cV.Title.containsIgnoreCase(LOA_PDF_IDENTIFIER)){

            //Split the File Name to get Proposal Name
            List<String> titleBreak = cV.Title.split('_', 3);
            
            //Check titleBreak List size
            if(titleBreak.size() == 3) {
            
            //Add Content Version With Proposal Name
            mapProposalNameWithContentVersion.put(titleBreak[1], cV);		
            }	
            }
            */
        }
        
        //Check content Version map
        if(mapProposalNameWithContentVersion.size() > 0)
        {
            
            //List to update Proposal
            List<SBQQ__Quote__c> proposals = new List<SBQQ__Quote__c>();
            
            
            //Added by subhash Garhwal - 01/21/2020 - CR-20200121-13641
            //List of contentDocumentLink
            List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            //SOQL over the Proposal
            for(SBQQ__Quote__c proposal : [Select Id, Name, Calculator_Export_File_Id__c, Calculator_Export_File_Name__c From SBQQ__Quote__c Where Name IN : mapProposalNameWithContentVersion.keySet()])
            {
                
                //Check Proposal Name in map
                if(mapProposalNameWithContentVersion.containsKey(proposal.Name))
                {
                    
                    Boolean isChange = false;
                    if(mapProposalNameWithContentVersion.get(proposal.Name).Title.containsIgnoreCase(esCalculatorIdentifier))
                    {
                        
                        //Update Proposal
                        proposal.Calculator_Export_File_Id__c = mapProposalNameWithContentVersion.get(proposal.Name).Id;
                        proposal.Calculator_Export_File_Name__c = mapProposalNameWithContentVersion.get(proposal.Name).Title;
                        
                        isChange = true;
                    } 
                    
                    //Subhash Garhwal - 09/26/2019 - Remove this condition : && mapProposalNameWithContentVersion.get(proposal.Name).Title.endsWith('p') && mapProposalNameWithContentVersion.get(proposal.Name).FileExtension.equalsIgnoreCase('pdf')
                    /*if(mapProposalNameWithContentVersion.get(proposal.Name).Title.containsIgnoreCase(LOA_PDF_IDENTIFIER)){

                    proposal.Contract_Document_Creation_Date__c = System.today();
                    proposal.LOA_PDF_Document_File_Name__c = mapProposalNameWithContentVersion.get(proposal.Name).Title;
                    
                    //Added by mahendra Swarnkar - 09/25/2019 - CR-20190911-13329 - Populate the LOA PDF Document Id(Order Form) 
                    if(proposal.LOA_PDF_Document_ID__c != mapProposalNameWithContentVersion.get(proposal.Name).ContentDocumentId 
                    && mapProposalNameWithContentVersion.get(proposal.Name).FileType != null 
                    && mapProposalNameWithContentVersion.get(proposal.Name).FileType.equalsIgnoreCase('PDF')){
                    proposal.LOA_PDF_Document_ID__c = mapProposalNameWithContentVersion.get(proposal.Name).ContentDocumentId;   
                    }
                    
                    //Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641 Start Here
                    if(mapProposalNameWithContentVersion.get(proposal.Name).OwnerId != Label.EAB_Integration_User_Id){
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = mapProposalNameWithContentVersion.get(proposal.Name).ContentDocumentId;
                    cDocLink.ShareType = 'C';
                    cDocLink.LinkedEntityId = Label.EAB_Integration_User_Id;
                    
                    contentDocumentLinkToInsert.add(cDocLink);
                    }
                    ////Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641 - End Here
                    
                    isChange = true;	  
                    }
                    */
                    
                    //Add Record in list
                    if(isChange)
                        proposals.add(proposal);
                }	
            }
            
            //Check for size
            if(proposals.size() > 0) 
            {
                update proposals;
                /*
                //Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641
                if(contentDocumentLinkToInsert.size() > 0){
                //Insert 
                insert contentDocumentLinkToInsert;
                }
                */
            }
        }
        pushCalculatorToProposal_Future(setContentVersionIds, mapContentVersionIdWithContentDocumentId);
    }
    
    //Added my Mahendra Swarnkar - 06/13/2019 -
    public static void grantPublicSharingOnFilesForCPQExceptionRequest(List<ContentVersion> newContentVersions) {
        Set<Id> setContentVersionIds = new Set<Id>();
        for(ContentVersion cversion: newContentVersions)
            setContentVersionIds.add(cversion.Id);
        
        if (!system.isBatch() && !system.isFuture() && !system.isScheduled())
            grantPublicSharingOnFilesForCPQExceptionRequest_Future(setContentVersionIds);
    }
    
    
    /**
     *  @description    :   This method will grant/add additional access to Case/MS record(s) of the newly created file(s).  
     * 
     *  @args           :   List of ContentVersion
     * 
     *  @return         :   void
     * 
    **/ 
    @future(callout=false)
    public static void grantPublicSharingOnFilesForCPQExceptionRequest_Future(Set<Id> contentVersionIds) {
        
        //newContentVersions
        List<ContentVersion> newContentVersions = [Select Id, ContentDocumentId, Title From ContentVersion where Id IN : contentVersionIds];
        
        //Map Content Document Id with list content version link
        Map<Id,List<ContentVersion>> mapDocumentIdWithContentVersions = new map<Id, List<ContentVersion>>();
        
        //Set of IDs
        Set<Id> setContentVersionIds = new Set<Id>();
        
        //Set of document/File Ids
        Set<Id> setdocumentIds = new Set<Id>();
        
        //Loop through ContentVersion records
        for(ContentVersion cV : newContentVersions)
        {
            
            //Contains check
            if(!mapDocumentIdWithContentVersions.containsKey(cV.ContentDocumentId))
                mapDocumentIdWithContentVersions.put(cV.ContentDocumentId, new List<ContentVersion>());
            
            //populate the map
            mapDocumentIdWithContentVersions.get(cV.ContentDocumentId).add(cV);
        }
        
        //check for size
        if(mapDocumentIdWithContentVersions.size() > 0)
        {
            
            //eligible Content Document/version
            Set<Id> setEligibleDocumentIds = new Set<Id>();
            
            //Query over the ContentDocumentLink 
            for(ContentDocumentLink contDocLink : [SELECT LinkedEntityId, ContentDocumentId, LinkedEntity.type FROM ContentDocumentLink 
                                                   WHERE  LinkedEntityId != null AND ContentDocumentId IN: mapDocumentIdWithContentVersions.keySet()]) 
            {
                // check the Entity type
                if(contDocLink.LinkedEntity.type == 'CPQ_Exception_Request__c')
                    setEligibleDocumentIds.add(contDocLink.ContentDocumentId);
            }
            
            //Check for size
            if(setEligibleDocumentIds.size() > 0)
            {
                
                //List to hold the ContentDistribution records to be insert
                List<ContentDistribution> listContentDistributions = new List<ContentDistribution>();
                
                //Loop over the eligible content document Ids
                for(Id docId : setEligibleDocumentIds)
                {
                    
                    // Size/Contains check
                    if(mapDocumentIdWithContentVersions.containsKey(docId) && mapDocumentIdWithContentVersions.get(docId) != null && mapDocumentIdWithContentVersions.get(docId).size() > 0 )
                    {
                        
                        //Loop over the content version records
                        for(ContentVersion cVersion : mapDocumentIdWithContentVersions.get(docId))
                        {
                            
                            //Popukate the list
                            listContentDistributions.add(new ContentDistribution(ContentVersionId = cVersion.id, Name = cVersion.Title, PreferencesAllowViewInBrowser = true, 
                                                                                 PreferencesLinkLatestVersion = true, PreferencesNotifyOnVisit = false,
                                                                                 PreferencesPasswordRequired = false, PreferencesAllowOriginalDownload = true));
                            
                        }
                    }
                }
                
                //check for size
                if(listContentDistributions.size() > 0)
                {
                    
                    //insert ContentDistribution records
                    insert listContentDistributions;
                }
            }
        }
    }
    
    /**
     *  @description    :   Checks if the related content document name equals an Institution's Counter Id.  If so, set the logo field on Institution
     * 
     *  @args           :   List of ContentVersion
     * 
     *  @return         :   void
     * 
     *  @revision log	:	09/13/2019 - Victor Hanson - Created
     * 
    **/ 
    public static void populateLogoOnAccount(List<ContentVersion> newContentVersions) {
        //map to hold Content Title -> Content Id
        Map<String, Id> titleToId = new Map<String, Id>();
        List<Account> acctsToUpdate = new List<Account>();
        
        //get content document details
        for (ContentVersion cv : newContentVersions)
        {
            //counter id always starts with "N", so only add to the list if this begins with N
            if (cv.Title != null && cv.Title.startsWith('N')) 
            {
                //example: N00011429 => 0682K000003xGd4QAE
                titleToId.put(cv.Title, cv.Id);
            }
        }
        
        
        if (titleToId.size() > 0) 
        {
            //get all institutions that have the same counter id
            for (Account a : [SELECT Id, Logo_Content_Version_Id__c, Counter_ID__c FROM Account WHERE Counter_Id__c IN :titleToId.keySet()]) 
            {
                Id contentVersionId = titleToId.get(a.Counter_ID__c);
                if (contentVersionId != null) 
                {
                    a.Logo_Content_Version_Id__c = contentVersionId;
                    acctsToUpdate.add(a);
                }
            }
            
            //update accounts
            if (acctsToUpdate.size() > 0) 
            {
                util.bypassAllTriggers = true;
                update acctsToUpdate;
                util.bypassAllTriggers = false;
            }
        }
    }
    
    /**
     *  @description    :   This method will populate the LOA PDF Document ID/Name on Proposal with the manually uploaded ORDER FORM by the user on proposal 
     * 			    and then share file with EAB Integration User
     * 
     *  @args           :   Set<Id> , Map<Id, Id>
     * 
     *  @return         :   void
     *
     *	@Revision Log	:   V1.0 - Mahendra Swarnkar - 01/23/2019 - CR-20200121-13641  - Created
     * 
    **/
    @future(callout=false)
    public static void pushCalculatorToProposal_Future(Set<Id> setContentVersionIds, Map<Id, Id> mapContentVersionIdWithContentDocumentId) {
        
        Map<Id, Id> mapContentVersionIdWithProposalId = new Map<Id, Id>();
        Set<Id> setAlreadyLinkedContentDocumentIds = new Set<Id>();
        
        if(mapContentVersionIdWithContentDocumentId != null && mapContentVersionIdWithContentDocumentId.size() > 0 ) 
        {
            
            for(ContentDocumentLink contentDocLink : [Select Id, LinkedEntityId, LinkedEntity.Type, ContentDocumentId From ContentDocumentLink 
                                                      Where ContentDocumentId IN : mapContentVersionIdWithContentDocumentId.values()])
            {
                if(contentDocLink.ContentDocumentId != null && contentDocLink.LinkedEntityId != null  && contentDocLink.LinkedEntity.Type == 'SBQQ__Quote__c')
                    mapContentVersionIdWithProposalId.put(contentDocLink.ContentDocumentId, contentDocLink.LinkedEntityId);
                if(contentDocLink.ContentDocumentId != null && contentDocLink.LinkedEntityId != null && contentDocLink.LinkedEntityId == Label.EAB_Integration_User_Id)
                    setAlreadyLinkedContentDocumentIds.add(contentDocLink.ContentDocumentId);
            }
        }
        
        List<ContentVersion> listEligibleContentVersion = new List<ContentVersion>();
        
        if(setContentVersionIds.size() > 0)
        {
            
            //Variable to hold the Order Form Identifier
            String LOA_PDF_IDENTIFIER = 'OrderForm';
            
            //List to update Proposal
            List<SBQQ__Quote__c> listProposals = new List<SBQQ__Quote__c>();
            //Modified By - Subhash Garhwal - CR-20210811-15348
            //Map to store Proposal
            List<SBQQ__Quote__c> getProposals = [ SELECT Id, Name, Contracted__c, Contract_Document_Creation_Date__c, LOA_PDF_Document_File_Name__c, LOA_PDF_Document_ID__c 
                                                 FROM SBQQ__Quote__c WHERE Id IN: mapContentVersionIdWithProposalId.values() 
                                                ];
            Map<Id,SBQQ__Quote__c> mapIdtoProposal = new Map<Id, SBQQ__Quote__c>();
            if( getProposals.size() > 0 )
            {
                for(SBQQ__Quote__c propsal : getProposals)
                {
                    mapIdtoProposal.put(propsal.Id, propsal);
                }
            }
            
            //Added by subhash Garhwal - 01/21/2020 - CR-20200121-13641
            //List of contentDocumentLink
            List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            for(ContentVersion contentver : [Select Id, Title, ContentDocumentId, FileExtension, FileType, OwnerId From ContentVersion Where Id IN : setContentVersionIds])
            {
                
                if(mapContentVersionIdWithContentDocumentId != null && mapContentVersionIdWithContentDocumentId.size() > 0 && mapContentVersionIdWithContentDocumentId.containsKey(contentver.Id)
                   && mapContentVersionIdWithContentDocumentId.get(contentver.Id) != null && mapContentVersionIdWithProposalId.size() > 0 && mapContentVersionIdWithProposalId.containsKey(mapContentVersionIdWithContentDocumentId.get(contentver.Id))) 
                {
                    
                    
                    //Modified By - Subhash Garhwal - CR-20210811-15348
                    If(String.isNotBlank(contentver.Title) && contentver.Title.containsIgnoreCase(LOA_PDF_IDENTIFIER))
                    {
                        //SBQQ__Quote__c proposal = new SBQQ__Quote__c(Id = mapContentVersionIdWithProposalId.get(mapContentVersionIdWithContentDocumentId.get(contentver.Id)));
                        SBQQ__Quote__c proposal = mapIdtoProposal.get(mapContentVersionIdWithProposalId.get(mapContentVersionIdWithContentDocumentId.get(contentver.Id)));
                        
                        //proposal.Contract_Document_Creation_Date__c = System.today();
                        if(!proposal.Contracted__c)
                        {
                            proposal.Contract_Document_Creation_Date__c = System.today();
                        }
                        
                        proposal.LOA_PDF_Document_File_Name__c = contentver.Title;
                        
                        //Added by mahendra Swarnkar - 09/25/2019 - CR-20190911-13329 - Populate the LOA PDF Document Id(Order Form) 
                        if( contentver.FileType != null 
                           && contentver.FileType.equalsIgnoreCase('PDF'))
                        {
                            proposal.LOA_PDF_Document_ID__c = contentver.ContentDocumentId;   
                        }
                        
                        listProposals.add(proposal);
                        
                        //Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641 Start Here
                        if(!setAlreadyLinkedContentDocumentIds.contains(contentver.ContentDocumentId)
                           && contentver.OwnerId != Label.EAB_Integration_User_Id)
                        {
                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                            cDocLink.ContentDocumentId = contentver.ContentDocumentId;
                            cDocLink.ShareType = 'C';
                            cDocLink.LinkedEntityId = Label.EAB_Integration_User_Id;
                            
                            contentDocumentLinkToInsert.add(cDocLink);
                        }
                        //Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641 - End Here
                    }
                    //listEligibleContentVersion.add(contentver);
                }
            }
            
            //Check for size
            if(listProposals.size() > 0)
            {
                update listProposals;
            }
            
            //Addded by Subhash Garhwal - 01/21/2020 - CR-20200121-13641
            if(contentDocumentLinkToInsert.size() > 0)
            {
                //Insert 
                insert contentDocumentLinkToInsert;
            }
        }
    }
 	

    public static void dataUpdateSteps(String updateName, Boolean isInsert) {
        String csvString;
        //List of contentDocumentLink
        Set<String> setOpportunityStages = new Set<String>{'ATL', 'Closed Won', 'Closed Lost', 'Dropped', 'Void', 'Closed', 'Honorary','Contract Received - Send to Finance', 'Contract Received - Sent to Finance/Credited','Contract Received - Sent to Finance/Booked', 'Sent To Finance - Opp Rejected'};
            
            if(updateName.equalsIgnoreCase('Export LOA Missmatch') ){
                
                csvString = 'CPQ Exception Request ID' + ',' + 'Proposal Id' + ',' + 'Proposal Name' + ','  + 'Proposal Status'+ ','+ 'Proposal\'s Opportunity Stage'+ ','  + 'Proposal.LOA_PDF_Document_ID__c' + ',' + 'Proposal.LOA_PDF_Document_File_Name__c'+ ',' +  '\n';
                
                List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
                Set<Id> setCPQExceptionRequest = new Set<Id>();
                Set<Id> setContentDocumentIdInLoaPdfDoc = new Set<Id>();
                for(ContentDocumentLink cdocLink : [Select Id, ContentDocumentId, ContentDocument.title, LinkedEntityID, LinkedEntity.Name, LinkedEntity.Type from ContentDocumentLink 
                                                    Where ContentDocument.title LIKE '%OrderForm%' And ContentDocument.OwnerId != '005C0000009l4lI'
                                                    AND ( /*LinkedEntityId =: '005C0000009l4lI' OR 
                                                            LinkedEntityId IN : (SELECT Id FROM SBQQ__Quote__c 
                                                            Where SBQQ__Status__c != : 'Locked' AND SBQQ__Opportunity2__c != null 
                                                            AND SBQQ__Opportunity2__r.StageName NOT IN :setOpportunityStages
                                                            )
                                                            OR */
                                                        LinkedEntityId IN  (SELECT Id FROM CPQ_Exception_Request__c 
                                                                            Where Proposal__c != null AND Proposal__r.SBQQ__Status__c != : 'Locked'  
                                                                            AND Proposal__r.SBQQ__Opportunity2__c != null 
                                                                            AND Proposal__r.SBQQ__Opportunity2__r.StageName NOT IN :setOpportunityStages
                                                                           )
                                                    ) order by LinkedEntity.Name DESC ])
                {
                    if(cdocLink.LinkedEntity.Type == 'CPQ_Exception_Request__c')
                    {
                        setContentDocumentIdInLoaPdfDoc.add(cdocLink.ContentDocumentId);
                        setCPQExceptionRequest.add(cdocLink.LinkedEntityID);    
                    }
                    
                    
                    if(cdocLink.LinkedEntity.Type == 'SBQQ__Quote__c') {
                        
                    }
                    
                    /*if(LinkedEntityId == '005C0000009l4lI') {
                    setContentDocumnetIdAlredyHaveEABIntegrationUserId.add(cdocLink.ContentDocumentId);
                    }*/    
                }
                
                Map<ID, SBQQ__Quote__c> mapProposals = new Map<ID, SBQQ__Quote__c>();
                
                for(CPQ_Exception_Request__c cpqER :[SELECT Id, Proposal__c,Proposal__r.Name, Proposal__r.SBQQ__Status__c, Proposal__r.SBQQ__Opportunity2__r.StageName, Proposal__r.LOA_PDF_Document_ID__c, Proposal__r.LOA_PDF_Document_File_Name__c  FROM CPQ_Exception_Request__c Where Id IN : setCPQExceptionRequest AND Proposal__c != null AND Proposal__r.LOA_PDF_Document_ID__c IN : setContentDocumentIdInLoaPdfDoc]){
                    
                    mapProposals.put(cpqER.Proposal__c,new SBQQ__Quote__c(Id = cpqER.Proposal__c, LOA_PDF_Document_ID__c = cpqER.Proposal__r.LOA_PDF_Document_ID__c, LOA_PDF_Document_File_Name__c = cpqER.Proposal__r.LOA_PDF_Document_File_Name__c ));
                    csvString = csvString + cpqER.Id + ',' + cpqER.Proposal__c + ',' + cpqER.Proposal__r.Name + ','  + cpqER.Proposal__r.SBQQ__Status__c + ','+ cpqER.Proposal__r.SBQQ__Opportunity2__r.StageName + ','  + cpqER.Proposal__r.LOA_PDF_Document_ID__c + ',' + cpqER.Proposal__r.LOA_PDF_Document_File_Name__c + ',' +  '\n';    
                }
                
            }
        
        if(updateName.equalsIgnoreCase('EAB Integration Sharing'))
        {
            csvString = 'ContentDocumentId' + ',' + 'ContentDocument.title' + ',' + 'ContentDocument.OwnerId' + ','  + 'LinkedEntity.Name'+ ','+ 'LinkedEntityId'+ ',' +  '\n';
            
            //List of contentDocumentLink
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, ContentDocument.title, ContentDocument.OwnerId, LinkedEntity.Name, LinkedEntityId  
                                                              FROM ContentDocumentLink 
                                                              WHERE ContentDocumentId != null AND ContentDocument.OwnerId != '005C0000009l4lI'
                                                              AND LinkedEntity.Type =: 'SBQQ__Quote__c' AND ContentDocument.title LIKE '%OrderForm%'
                                                              AND LinkedEntityId IN 
                                                              ( SELECT Id FROM SBQQ__Quote__c 
                                                               where SBQQ__Status__c != : 'Locked' AND SBQQ__Opportunity2__c != null 
                                                               AND SBQQ__Opportunity2__r.StageName NOT IN :setOpportunityStages
                                                              )
                                                             ];
            
            List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            Set<Id> setContentDocumnetId = new Set<Id>();
            
            Set<Id> setContentDocumnetIdAlredyHaveEABIntegrationUserId = new Set<Id>();
            
            for(ContentDocumentLink cdLink : contentDocumentLinks)
            {
                setContentDocumnetId.add(cdLink.ContentDocumentId);
            }
            
            if(setContentDocumnetId != null)
            {
                
                for(ContentDocumentLink cdLink : [SELECT ContentDocumentId, ContentDocument.title, ContentDocument.OwnerId, LinkedEntity.Name, LinkedEntityId  
                                                  FROM ContentDocumentLink where LinkedEntityId IN ('005C0000009l4lI' ) 
                                                  And ContentDocument.title LIKE '%OrderForm%' And ContentDocument.OwnerId != '005C0000009l4lI' 
                                                  And ContentDocumentId IN : setContentDocumnetId])
                {
                    
                    setContentDocumnetIdAlredyHaveEABIntegrationUserId.add(cdLink.ContentDocumentId);
                    
                } 
            }
            
            for(ContentDocumentLink cdLink : contentDocumentLinks) 
            {
                
                if(setContentDocumnetIdAlredyHaveEABIntegrationUserId.size() > 0 && !setContentDocumnetIdAlredyHaveEABIntegrationUserId.contains(cdLink.ContentDocumentId))
                {
                    
                    csvString = csvString + cdLink.ContentDocumentId + ',' + cdLink.ContentDocument.title + ',' + cdLink.ContentDocument.OwnerId + ','  + cdLink.LinkedEntity.Name + ','+ cdLink.LinkedEntityId + ',' +  '\n';
                    
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
            
                    cDocLink.ContentDocumentId = cdLink.ContentDocumentId;
            
                    cDocLink.ShareType = 'C';
            
                    cDocLink.LinkedEntityId = '005C0000009l4lI';
            
                    contentDocumentLinkToInsert.add(cDocLink);
                }
            }
            
            if(contentDocumentLinkToInsert.size() > 0 && isInsert)
                insert contentDocumentLinkToInsert;
            
        }
        
        if(!isInsert)
        {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvString);
            string csvname= 'OrderForm_With_Proposal_Details.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {'Mahendra.Swarnkar@fexle.com'};
            String subject ='OrderForm With Proposal Details';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Hi Mahendra, Please find the comparison list attached. Thanks! ');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       
        } 
    }
}