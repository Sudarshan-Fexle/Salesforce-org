/**
 *  Description     :  Controller class for ProposalClone VF page. This class will hold all the logics to clone the proposal
 *
 *  Created By      :  Saurabh Kumar
 *
 *  Created Date    :  05/16/2017
 *
 *  Revision Logs   :   V_1.0 - Created - Saurabh Kumar - CR-20170403-10807 - Clone Proposal If Contract Status is draft/Approved 
 *                      V_1.1 - Modified - 07/27/2017 - Subhash Garhwal - Issue--CR10808--QA--00005160 - Removed additional field values
 *                      V_1.2 - Modified - 07/28/2017 - Subhash Garhwal - Issue--CR10808--QA--00005212
 *                      V_1.3 - Modified - 11/29/2017 - Deepak Kumawat - CR-20171127-11816 - Update the "ProposalCloneController" apex class, in "without" sharing mode.
 *                      V_1.4 - Modified - 4/02/2018 - Suubhash Garhwal - CR-20180327-12129 - updated method "doCloneProposal" for Proposal Line group.
 *                      V_1.5 - Modified - 01/10/2019 - Suubhash Garhwal - CR-20181019-12685 - Enrollment Services CPQ - Modified code to make it more generic to clone Proposal Line correctly.
 *                      V_1.6 - Modified - 09/25/2019 - Suubhash Garhwal - CR-20190911-13329 - Enrollment Services CPQ - Modified code to make it more generic to clone CPQ Exception request/Contract Exceptions and the Attached files under the Proposal and CPQ Excception request  .
 *			V_1.7 - Modified By - 05/27/2020 - Colin McGloin - CR-20200518-14066
 *
 **/
public without sharing class ProposalCloneController {

    //Variable
    public SBQQ__Quote__c proposal {get;set;}
    public List<SBQQ__Quote__c> proposals {get;set;}
    public Boolean checkException {get;set;}

    //Constructor For ProposalCloneController
    public ProposalCloneController(ApexPages.StandardController controller) {

        //Get Current Proposal Record
        proposal = (SBQQ__Quote__c)controller.getRecord();

        checkException = false;
    }
    
    /**
     *  @description    :   This method is used to clone proposal
     *                      
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 04/25/2017 - Created - Saurabh Kumar - CR-20170403-10807
     *
     **/
    public Pagereference doCloneProposal() {

        //Save Point
        Savepoint sp = Database.setSavepoint();

        try {
                        
            //Set to hold the Goal Template Ids
            Set<Id> setProposalIds = new Set<Id>();

           //Check for detail page record (Detail Page clone case)
            if(proposal != null && proposal.Id != null)
                setProposalIds.add(proposal.Id);
    
            //Global describe
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
                
            //Query through the Proposal
            List<SBQQ__Quote__c> proposalToBeClone = (List<SBQQ__Quote__c>)Database.query(buildSOQL(globalDescribe, 'SBQQ__Quote__c') + ' Where Id IN :setProposalIds');
            
            //Check For Proposal Size
            if(proposalToBeClone.Size() > 0) {

            //List to contain the Ids of any Signing Documents already associated with a record that is being cloned
            List<SBQQ__Quote__c> documentToSignIDs = new List<SBQQ__Quote__c>();

            //Added by Colin McGloin - 05/27/2020
            //Loop through our Proposals to be Cloned and see if there is a Signing Document attached
            for (SBQQ__Quote__c quote : proposalToBeClone){
                if (quote.Signing_Document_Id__c != null){
                    documentToSignIDs.add(quote);
                }
            }

            //Clone the Proposal using the standard salesforce Deepclone method
            List<SBQQ__Quote__c> clonedProposals = proposalToBeClone.deepClone(false,false);
            
            //Map to hold ProposalToBeClone as Id and Proposal that is cloned as values
            Map<Id,SBQQ__Quote__c> mapOfProposals = new Map<Id,SBQQ__Quote__c>();
            
            //Map to hold ProposalToBeClone 
            Map<Id,SBQQ__Quote__c> mapOfProposalToBeClone = new Map<Id,SBQQ__Quote__c>();
            
            
            //Loop through cloned Proposal 
            for(Integer i = 0 ; i < clonedProposals.Size(); i++) {
                
                //Primary Field as false
                clonedProposals[i].SBQQ__Primary__c = false;

                //05/22/2020 - Colin McGloin - Grab the Current Document ID from the record
                if (clonedProposals[i].Signing_Document_Id__c != null){

                    //Null the Signing Document Id
                    clonedProposals[i].Signing_Document_Id__c = null;

                }
                
                //07/27/2017 - Subhash Garhwal - Issue--CR10808--QA--00005160 - Removed additional field values
                clonedProposals[i].SBQQ__DocumentStatus__c = '';
                clonedProposals[i].LOA_Document_Version__c = null;
                clonedProposals[i].LOA_Document_Revision__c = null;
                clonedProposals[i].LOA_Word_Document_ID__c = null;
                clonedProposals[i].LOA_PDF_Document_ID__c = null;
                clonedProposals[i].LOA_PDF_Document_File_Name__c = null;
                clonedProposals[i].ApprovalStatus__c = null;
                clonedProposals[i].Calculator_Export_File_Id__c = null;
                clonedProposals[i].Calculator_Export_File_Name__c = null;
                clonedProposals[i].Invoice_Frequency__c = proposalToBeClone[i].Invoice_Frequency__c;
                clonedProposals[i].Contract_Document_Creation_Date__c = null;
                
                //Added by Subhash - 02/19/2020 - CR-20200210-13716 - to address the WF rule: "Reset Approval Status for Cloned Proposal"- Starts from Here
                clonedProposals[i].RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Open').getRecordTypeId();
                clonedProposals[i].SBQQ__Status__c = 'Draft';
                clonedProposals[i].SBQQ__WatermarkShown__c = true;
                //Added by Subhash - 02/19/2020 - CR-20200210-13716 - to address the WF rule: "Reset Approval Status for Cloned Proposal"- Ends Here

                //Add to map
                mapOfProposals.put(proposalToBeClone[i].Id,clonedProposals[i]);
                mapOfProposalToBeClone.put(proposalToBeClone[i].Id,proposalToBeClone[i]);

            }
            //Size Check
            if(mapOfProposals.values().size() > 0){
                //Insert values
                insert mapOfProposals.values();
            }

            //Pass records through to batch to remove current Signed Documents
            if (documentToSignIDs != null){
                Sched_CalculatorDocumentRemoval.scheduleCalculatorDocumentRemoval(documentToSignIDs);
            }
                
            //Clone file
            //cloneFile(mapOfProposals, mapOfProposalToBeClone,null);
                
            //Query for Proposal Line group
            List<SBQQ__QuoteLineGroup__c> proposalLineGroupToBeClone = (List<SBQQ__QuoteLineGroup__c>)Database.query(buildSOQL(globalDescribe,
                                                                             'SBQQ__QuoteLineGroup__c') + ' Where SBQQ__Quote__c IN : setProposalIds');

            //Map to hold Proposal line group
            Map<Id,SBQQ__QuoteLineGroup__c> mapProposalLG = new Map<Id,SBQQ__QuoteLineGroup__c>();

            //Check for size
            if(proposalLineGroupToBeClone.Size()>0){

                //Clone Proposal line group
                List<SBQQ__QuoteLineGroup__c> clonedproposalGroup = proposalLineGroupToBeClone.deepClone(false,true);

                //Loop through Proposal line group
                for(Integer counter = 0 ; counter < clonedproposalGroup.size() ; counter++) {

                    //Process if condition is true
                    if(mapOfProposals.containsKey(proposalLineGroupToBeClone[counter].SBQQ__Quote__c)){

                        //Clone a proposal group
                        clonedproposalGroup[counter].SBQQ__Quote__c = mapOfProposals.get(proposalLineGroupToBeClone[counter].SBQQ__Quote__c).Id;

                    }
                    //Add record to list
                    mapProposalLG.put(proposalLineGroupToBeClone[counter].Id,clonedproposalGroup[counter]);
    
                }
    
                //Insert Proposal Line Item
                insert mapProposalLG.values();

            }

            //Modified by Subhash - CR-20190911-13329 - 09/10/2019 - Start From Here
              
            //Get "CPQ Exception Request" Record Type Id
            Id cpqExceptionRecordTypeId = Schema.SObjectType.CPQ_Exception_Request__c.getRecordTypeInfosByName().get('CPQ Exception Request').getRecordTypeId();
    
            //Query for CPQ Exception Request
            List<CPQ_Exception_Request__c> CPQExceptionRequestsToBeClone = (List<CPQ_Exception_Request__c>)Database.query(buildSOQL(globalDescribe,
                                                                            'CPQ_Exception_Request__c') + ' Where Proposal__c IN : setProposalIds');
            
            //Map to hold CPQExceptionRequestClone as Id and CPQExceptionRequest that is cloned as values.
            Map<Id,CPQ_Exception_Request__c> mapOfCPQExceptionRequest = new Map<Id,CPQ_Exception_Request__c>();
            
            //Check for size
            if(CPQExceptionRequestsToBeClone.size() > 0){
                
                //Clone the CPQExceptionRequest using the standard salesforce Deepclone method
                List<CPQ_Exception_Request__c> clonedCPQExceptionRequests = CPQExceptionRequestsToBeClone.deepClone(false,true);
                
                //Loop through CPQ_ExceptionRequests
                for(Integer i = 0 ; i < clonedCPQExceptionRequests.size() ; i++) {
                    
                    //Process if condition is true
                    if(mapOfProposals.containsKey(CPQExceptionRequestsToBeClone[i].Proposal__c)){
                        //Clone a CPQ_ExceptionRequests
                        clonedCPQExceptionRequests[i].Proposal__c = mapOfProposals.get(CPQExceptionRequestsToBeClone[i].Proposal__c).Id;
                        clonedCPQExceptionRequests[i].Status__c = 'Draft';
                        clonedCPQExceptionRequests[i].recordTypeId = cpqExceptionRecordTypeId;
                    }
                        
                    mapOfCPQExceptionRequest.put(CPQExceptionRequestsToBeClone[i].Id,clonedCPQExceptionRequests[i]);
                }
                
                //Size check
                if(mapOfCPQExceptionRequest.values().size() > 0)
                    insert mapOfCPQExceptionRequest.values();
                
                
                
                //Clone file
                //cloneFile(null,null,mapOfCPQExceptionRequest);
            }    
            
            //Query for CPQ Contract Exception
            List<CPQ_Contract_Exception__c> CPQContractExceptionToBeClone = (List<CPQ_Contract_Exception__c>)Database.query(buildSOQL(globalDescribe,
                                                                            'CPQ_Contract_Exception__c') + ' Where Proposal__c IN : setProposalIds');
            
            //Map to hold CPQContractExceptionClone as Id and CPQContractException that is cloned as values.
            Map<Id,CPQ_Contract_Exception__c> mapOfContractExceptions = new Map<Id,CPQ_Contract_Exception__c>();
            
            if(CPQContractExceptionToBeClone.size() > 0){
                
                //Clone the CPQContractException using the standard salesforce Deepclone method
                List<CPQ_Contract_Exception__c> clonedContractExceptions = CPQContractExceptionToBeClone.deepClone(false,true);
                
                //Loop through CPQContractException
                for(Integer i = 0 ; i < clonedContractExceptions.size() ; i++) {
                    
                    //Process if condition is true
                    if(mapOfProposals.containsKey(CPQContractExceptionToBeClone[i].Proposal__c)){
                        //Clone a CPQContractException
                        clonedContractExceptions[i].Proposal__c = mapOfProposals.get(CPQContractExceptionToBeClone[i].Proposal__c).Id;
                    }   
                    mapOfContractExceptions.put(CPQContractExceptionToBeClone[i].Id,clonedContractExceptions[i]);
                }
                
                //Insert values
                insert mapOfContractExceptions.values();
            }

            //Modified by Mahendra Swarnkar - 09/10/2019 - End Here
              
            //Query for Proposal Line item
            List<SBQQ__QuoteLine__c> proposalLineItemToBeClone = (List<SBQQ__QuoteLine__c>)Database.query(buildSOQL(globalDescribe,
                                                                             'SBQQ__QuoteLine__c') + ' Where SBQQ__Quote__c IN : setProposalIds');
            
            //Check for size
            if(proposallineItemToBeClone.Size() > 0){

                //Subhash Garhwal - 07/28/2017 - Issue--CR10808--QA--00005212 
                
                //Map to hold the old Parent Proposal Line with new Proposal Lines
                Map<Id, SBQQ__QuoteLine__c> mapClonedParentProposalLines = new Map<Id, SBQQ__QuoteLine__c>();
                
                //List to insert Child Proposal Lines
                List<SBQQ__QuoteLine__c> childProposalLines = new List<SBQQ__QuoteLine__c>();
                
                //Clone Proposal line item
                List<SBQQ__QuoteLine__c> clonedproposalLineItem = proposalLineItemToBeClone.deepClone(false,true);
                
                //Loop over the clonedproposalLineItem
                for(Integer i = 0; i < clonedproposalLineItem.size(); i++) {
                    
                    //Update Proposal
                    clonedproposalLineItem[i].SBQQ__Quote__c = mapOfProposals.get(proposalLineItemToBeClone[i].SBQQ__Quote__c).Id;
                    //clonedproposalLineItem[i].Top_Parent_Product__c = null;

                    //Process if condition is true
                    if(mapProposalLG.containsKey(proposalLineItemToBeClone[i].SBQQ__Group__c))              
                        clonedproposalLineItem[i].SBQQ__Group__c = mapProposalLG.get(proposalLineItemToBeClone[i].SBQQ__Group__c).Id;
                    
                    //Subhash Garhwal - 01/10/2019 - CR-20181019-12685 - Enrollment Services CPQ - Commented condition here to update Parent Proposal Line correctly.
                    //Check for Parent Proposal Line
                    //if(clonedproposalLineItem[i].SBQQ__RequiredBy__c == null)
                        mapClonedParentProposalLines.put(proposalLineItemToBeClone[i].Id, clonedproposalLineItem[i]);
                    //else
                        //childProposalLines.add(clonedproposalLineItem[i]);    
                }
                
                //Check for size
                if(mapClonedParentProposalLines.size() > 0) {
                    
                    //Insert
                    insert mapClonedParentProposalLines.values();
                    
                    //Loop over the Child Proposal Lines
                    for(SBQQ__QuoteLine__c pL : mapClonedParentProposalLines.values()) {
                        
                        //Check for Parent PL
                        if(pL.SBQQ__RequiredBy__c != null && mapClonedParentProposalLines.containsKey(pL.SBQQ__RequiredBy__c)) {
                            pL.SBQQ__RequiredBy__c = mapClonedParentProposalLines.get(pL.SBQQ__RequiredBy__c).Id;
                            //pL.Top_Parent_Product__c = null;
                            childProposalLines.add(pL);
                        }
                    }
                    
                    //Update Required By on Proposal Line
                    if(childProposalLines.size() > 0)
                        update childProposalLines;
                }

            }               
            //return
            return new Pagereference('/' + mapOfProposals.get(proposal.Id).Id);
            }
        }catch(Exception e) {
            
            //Roll Back changes
            Database.rollback(sp);
            //System.assert(false,e.getLineNumber());
            checkException = true;
            //Add Error on page
            ApexPages.addMessages(e);

        }

        //return
        return null;
    }
    
    /**
     *  @description    :   This method is used to build the SOQL query string.
     *
     *  @args           :   Map<String, Schema.SObjectType>, String
     *
     *  @return         :   String
     *
     **/
    public String buildSOQL(Map<String, Schema.SObjectType> globalDescribe, String objName) {
        
        //SOQL query
        String SOQL = 'Select ';
        
        //Get the field of the object'
        for(String field : globalDescribe.get(objName).getDescribe().fields.getMap().keySet())
            SOQL += field + ',';
        
        //Remove extra elements and add object
        SOQL = SOQL.removeEnd(',') + ' From ' + objName;
        
        //Return 
        return SOQL;
        
    }
    
   /**
    *  @description    :   This method is used to clone the existing file on the record.
    *
    *  @args           :   Map<Id, sObject>
    *
    *  @return         :   Void
    * 
    *  Created By      :  Mahendra Swarnkar
    *
    *  Created Date    :  09/12/2019
    *
    **/
    /*public static void cloneFile(Map<Id, SBQQ__Quote__c> mapProposalToBeCloneIdWithClonedProposal, Map<Id, SBQQ__Quote__c> mapOfProposalToBeClone, Map<Id, CPQ_Exception_Request__c> mapCPQExRequestToBeCloneIdWithClonedCPQExRequest){
        
        //Set to hold the new proposal ID
        Set<Id>  newProposalIds = new Set<Id>();
        
        //Set to hold the Calculator_Export_File_Id__c
        Map<Id,Id> mapOfProposalToBeCloneWithCalculatorExportFileId = new Map<Id,Id>();
        
        Id CPQExportLibraryID;
        Id CPQCloneLibraryID;
        
        //Check for size
        if(mapProposalToBeCloneIdWithClonedProposal != null){
            
            // Loop over the Proposal To Be Clone ids
            for(Id proposalToBeCloneId : mapProposalToBeCloneIdWithClonedProposal.keySet()){
                
                //Populate the new Proposal Ids set (Cloned Proposals)
                newProposalIds.add(mapProposalToBeCloneIdWithClonedProposal.get(proposalToBeCloneId).Id);
                
                //Populate the set to hold the Calculator export file ids
                mapOfProposalToBeCloneWithCalculatorExportFileId.put(proposalToBeCloneId,mapOfProposalToBeClone.get(proposalToBeCloneId).Calculator_Export_File_Id__c);
            }
        }    
        
        if(mapOfProposalToBeCloneWithCalculatorExportFileId.size() > 0){
            list<ContentWorkspace> listCPQExportLibrary = new List<ContentWorkspace>([SELECT Id FROM ContentWorkspace WHERE Name = 'CPQ Calculator Clone' LIMIT 1]);
            if(listCPQExportLibrary != null && listCPQExportLibrary.size() > 0){
                //CPQExportLibraryID = listCPQExportLibrary[0].Id;
                CPQCloneLibraryID = listCPQExportLibrary[0].Id;
                
            }
        }
        
        //Map to hold new Proposals
        Map<Id, SBQQ__Quote__c> mapOfNewProposals = new Map<Id, SBQQ__Quote__c>([Select Id, Name,Calculator_Export_File_Id__c, Calculator_Export_File_Name__c 
                                                                                 From SBQQ__Quote__c Where Id IN: newProposalIds]);
        
        //Check for Size
        if((mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.size() > 0) || (mapProposalToBeCloneIdWithClonedProposal != null &&mapProposalToBeCloneIdWithClonedProposal.size() > 0 )){
            
            //Map 
            Map<Id, Set<Id>> mapCPQExcToBeCloneIdWithOldContentDocumentIds = new Map<Id, Set<Id>> ();
            Map<Id, Set<Id>> mapProposalToBeCloneIdWithOldContentDocumentIds = new Map<Id, Set<Id>> ();
            
            //Set to hold the old content document Ids
            Set<Id> oldContentDocumentId = new Set<Id>();
            
            //Set to hold the old content document Ids
            Set<Id> setLinkEntityIds = new Set<Id>();
            
            if(mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.size() > 0)
                setLinkEntityIds.addAll(mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.KeySet());
                
            if(mapProposalToBeCloneIdWithClonedProposal != null && mapProposalToBeCloneIdWithClonedProposal.size() > 0)
                setLinkEntityIds.addAll(mapProposalToBeCloneIdWithClonedProposal.KeySet());
            
            //Loop over ContentDocumentLink to get ContentDocumentId
            for(ContentDocumentLink cDocLink : [Select ContentDocumentId, LinkedEntityId From ContentDocumentLink where (LinkedEntityId IN : setLinkEntityIds )]){
                
                //Populate the set
                oldContentDocumentId.add(cDocLink.ContentDocumentId);
                
                //Populate the map
                if(mapProposalToBeCloneIdWithClonedProposal != null && mapProposalToBeCloneIdWithClonedProposal.containsKey(cDocLink.LinkedEntityId)){
                    if(!mapProposalToBeCloneIdWithOldContentDocumentIds.containsKey(cDocLink.LinkedEntityId))
                        mapProposalToBeCloneIdWithOldContentDocumentIds.put(cDocLink.LinkedEntityId, new Set<Id>());
                    mapProposalToBeCloneIdWithOldContentDocumentIds.get(cDocLink.LinkedEntityId).add(cDocLink.ContentDocumentId);
                }
                
                if(mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.containsKey(cDocLink.LinkedEntityId)){
                    if(!mapCPQExcToBeCloneIdWithOldContentDocumentIds.containsKey(cDocLink.LinkedEntityId))
                        mapCPQExcToBeCloneIdWithOldContentDocumentIds.put(cDocLink.LinkedEntityId, new Set<Id>());
                    mapCPQExcToBeCloneIdWithOldContentDocumentIds.get(cDocLink.LinkedEntityId).add(cDocLink.ContentDocumentId);
                }   
            }
            
            //Check for size
            if(oldContentDocumentId.size() > 0 
                || (mapOfProposalToBeCloneWithCalculatorExportFileId != null && mapOfProposalToBeCloneWithCalculatorExportFileId.size() > 0)
                || (mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.size() > 0)){
                
                //List of old ContentVersion
                //List<ContentVersion> existingContentVersion = new List<ContentVersion>();
                Map<Id,ContentVersion> mapContentDocumentIdWithexistingContentVersion = new Map<Id,ContentVersion>();
                Map<Id, ContentVersion> mapExistingCalExportContentVersion = new Map<Id,ContentVersion>();
                
                if(mapProposalToBeCloneIdWithClonedProposal != null && mapProposalToBeCloneIdWithClonedProposal.size() > 0 
                    || (mapOfProposalToBeCloneWithCalculatorExportFileId != null && mapOfProposalToBeCloneWithCalculatorExportFileId.size() > 0 
                        && mapOfProposalToBeCloneWithCalculatorExportFileId.values() != null
                        && mapOfProposalToBeCloneWithCalculatorExportFileId.values().size() > 0)
                    || (oldContentDocumentId.size() > 0)){
                    
                    Set<Id> setTempCalculatorExportIDs = new Set<Id> ();
                    if(mapOfProposalToBeCloneWithCalculatorExportFileId != null && mapOfProposalToBeCloneWithCalculatorExportFileId.size() > 0)
                        setTempCalculatorExportIDs.addAll(mapOfProposalToBeCloneWithCalculatorExportFileId.values());
                     
                    for(ContentVersion cversion : [Select Id, Title, PathOnClient, VersionData, IsLatest, ContentDocumentId, ContentDocument.ParentId, ContentDocument.PublishStatus, OwnerId From ContentVersion 
                                                    Where IsLatest = true AND (Id IN: setTempCalculatorExportIDs OR (ContentDocumentId IN: oldContentDocumentId ))]){ //AND (NOT Title LIKE 'OrderForm%')
                    
                        
                        if(setTempCalculatorExportIDs.size() > 0 && setTempCalculatorExportIDs.contains(cversion.Id))
                            mapExistingCalExportContentVersion.put(cversion.Id, cversion);
                        
                        if(oldContentDocumentId.contains(cversion.ContentDocumentId)&& cversion.Title.startsWithIgnoreCase('OrderForm') == false){
                            //existingContentVersion.add(cversion);
                            mapContentDocumentIdWithExistingContentVersion.put(cversion.ContentDocumentId, cversion);
                        }                                   
                    }
                }
                
                //New list of ContentVersion
                Map<Id,ContentVersion> mapContentVersionToBeCloneWithClonedContentVersion =  new Map<Id,ContentVersion>();
                Map<Id,Set<Id>> mapObjectsToBeCloneWithContentVersionToBeCloneIds =  new Map<Id,Set<Id>>();
                    
                //Check for size
                if(mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.size() > 0){
                
                    //Loop over the CPQ Exception Request To Be Cloned Ids CPQ_Exception_Request__c
                    for( Id cPQExReqToBeCloneId : mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.keySet()) {
                        
                        if(mapCPQExcToBeCloneIdWithOldContentDocumentIds.size() > 0 
                            && mapCPQExcToBeCloneIdWithOldContentDocumentIds.containsKey(cPQExReqToBeCloneId)
                            && mapCPQExcToBeCloneIdWithOldContentDocumentIds.get(cPQExReqToBeCloneId) != null
                            && mapCPQExcToBeCloneIdWithOldContentDocumentIds.get(cPQExReqToBeCloneId).size() > 0
                        ){
                                
                            //Loop over existing Content Document Ids
                            for(Id cDocId : mapCPQExcToBeCloneIdWithOldContentDocumentIds.get(cPQExReqToBeCloneId)){
                            
                                if(mapContentDocumentIdWithexistingContentVersion.size() > 0 
                                    && mapContentDocumentIdWithexistingContentVersion.containsKey(cDocId)) {
                                    
                                    ContentVersion oldCVersion = mapContentDocumentIdWithexistingContentVersion.get(cDocId);
                                        
                                    if(oldCVersion != null ){
                                        ContentVersion clonedContentVersion = new ContentVersion();
                                        clonedContentVersion.PathOnClient = oldCVersion.PathOnClient;
                                        clonedContentVersion.VersionData = oldCVersion.VersionData;
                                        clonedContentVersion.Title  = oldCVersion.Title;
                                        mapContentVersionToBeCloneWithClonedContentVersion.put(oldCVersion.Id, clonedContentVersion);
                                            
                                        if(!mapObjectsToBeCloneWithContentVersionToBeCloneIds.containsKey(cPQExReqToBeCloneId))
                                            mapObjectsToBeCloneWithContentVersionToBeCloneIds.put(cPQExReqToBeCloneId,new Set<Id>());
                                            
                                        mapObjectsToBeCloneWithContentVersionToBeCloneIds.get(cPQExReqToBeCloneId).add(oldCVersion.Id);
                                                                                        
                                        //newContentVersions.add(clonedContentVersion);
                                    }
                                }
                            }   
                        }
                    }
                }
                           
                if(mapProposalToBeCloneIdWithClonedProposal != null && mapProposalToBeCloneIdWithClonedProposal.size() > 0){
                        
                    //Loop over the proposal To Be Cloned Ids proposal
                    for( Id proposalToBeCloneId : mapProposalToBeCloneIdWithClonedProposal.keySet()) {
                    
                        if(mapProposalToBeCloneIdWithOldContentDocumentIds.size() > 0 
                            && mapProposalToBeCloneIdWithOldContentDocumentIds.containsKey(proposalToBeCloneId)
                            && mapProposalToBeCloneIdWithOldContentDocumentIds.get(proposalToBeCloneId) != null
                            && mapProposalToBeCloneIdWithOldContentDocumentIds.get(proposalToBeCloneId).size() > 0
                        ){
                                
                            //Loop over existing Content Document Ids
                            for(Id cDocId : mapProposalToBeCloneIdWithOldContentDocumentIds.get(proposalToBeCloneId)){
                            
                                if(mapContentDocumentIdWithexistingContentVersion.size() > 0 
                                    && mapContentDocumentIdWithexistingContentVersion.containsKey(cDocId)) {
                                    
                                    ContentVersion oldCVersion = mapContentDocumentIdWithexistingContentVersion.get(cDocId);
                                    
                                    if(oldCVersion != null ){
                                    
                                        ContentVersion clonedContentVersion = new ContentVersion();
                                        clonedContentVersion.PathOnClient = oldCVersion.PathOnClient;
                                        clonedContentVersion.VersionData = oldCVersion.VersionData;
                                        clonedContentVersion.OwnerId = Label.EAB_Integration_User_Id;
                                        clonedContentVersion.FirstPublishLocationId = CPQCloneLibraryID;
                                        
                                        String newTitle = oldCVersion.Title;
                                        newTitle = newTitle.replaceAll(mapOfProposalToBeClone.get(proposalToBeCloneId).Name, mapOfNewProposals.get(mapProposalToBeCloneIdWithClonedProposal.get(proposalToBeCloneId).Id).Name);
                                        clonedContentVersion.Title = newTitle;
                                            
                                        mapContentVersionToBeCloneWithClonedContentVersion.put(oldCVersion.Id, clonedContentVersion);
                                            
                                        if(!mapObjectsToBeCloneWithContentVersionToBeCloneIds.containsKey(proposalToBeCloneId))
                                            mapObjectsToBeCloneWithContentVersionToBeCloneIds.put(proposalToBeCloneId,new Set<Id>());
                                            
                                        mapObjectsToBeCloneWithContentVersionToBeCloneIds.get(proposalToBeCloneId).add(oldCVersion.Id);
                                            
                                            //newContentVersions.add(clonedContentVersion); 
                                    }
                                }
                            }   
                        }
                            
                        //Export Files cloning
                        if(mapOfProposalToBeCloneWithCalculatorExportFileId.size() > 0 
                            && mapOfProposalToBeCloneWithCalculatorExportFileId.containsKey(proposalToBeCloneId)
                            && mapOfProposalToBeCloneWithCalculatorExportFileId.get(proposalToBeCloneId) != null
                            && mapExistingCalExportContentVersion.size() > 0 
                            && mapExistingCalExportContentVersion.containsKey(mapOfProposalToBeCloneWithCalculatorExportFileId.get(proposalToBeCloneId)) ){
                                    
                            ContentVersion oldCVersion = mapExistingCalExportContentVersion.get(mapOfProposalToBeCloneWithCalculatorExportFileId.get(proposalToBeCloneId));
                            
                            if(oldCVersion != null){
                            
                                ContentVersion clonedContentVersion = new ContentVersion();
                                clonedContentVersion.PathOnClient  = oldCVersion.PathOnClient;
                                clonedContentVersion.VersionData = oldCVersion.VersionData;
                                clonedContentVersion.OwnerId = Label.EAB_Integration_User_Id;
                                clonedContentVersion.FirstPublishLocationId = CPQCloneLibraryID;
                                
                                String newTitle = oldCVersion.Title;
                                newTitle = newTitle.replaceAll(mapOfProposalToBeClone.get(proposalToBeCloneId).Name, mapOfNewProposals.get(mapProposalToBeCloneIdWithClonedProposal.get(proposalToBeCloneId).Id).Name);
                                clonedContentVersion.Title = newTitle;
                                
                                mapContentVersionToBeCloneWithClonedContentVersion.put(oldCVersion.Id, clonedContentVersion);
                                    
                                if(!mapObjectsToBeCloneWithContentVersionToBeCloneIds.containsKey(proposalToBeCloneId))
                                    mapObjectsToBeCloneWithContentVersionToBeCloneIds.put(proposalToBeCloneId,new Set<Id>());
                                            
                                mapObjectsToBeCloneWithContentVersionToBeCloneIds.get(proposalToBeCloneId).add(oldCVersion.Id);
                                    
                                    //newContentVersions.add(clonedContentVersion);
                            }
                        }
                    }
                }
                    
                //New list of ContentVersion
                List<ContentVersion> newContentVersions =  new List<ContentVersion>();
                
                if(mapContentVersionToBeCloneWithClonedContentVersion.size() > 0){
                
                    for(Id cVToBeCloneId : mapContentVersionToBeCloneWithClonedContentVersion.keySet()){
                        if(mapContentVersionToBeCloneWithClonedContentVersion.get(cVToBeCloneId) != null){
                            newContentVersions.add(mapContentVersionToBeCloneWithClonedContentVersion.get(cVToBeCloneId));
                        }
                    }
                        
                    //Size check
                    if(newContentVersions.size() > 0){
                    
                        //insert
                        insert newContentVersions;
                        
                        //New list of ContentVersion
                        List<ContentVersion> latestContentVersions = new List<ContentVersion>();
                    
                        //New list of ContentVersion of Calculator Export .
                        List<ContentVersion> latestContentVerionForCalculatorExportFile = new List<ContentVersion>();
                    
                        //Variable to hold the ES calculator Identifier
                        String esCalculatorIdentifier = 'Calculator-Export';
                            
                        Map<Id, ContentVersion> mapNewContentVersions = new Map<Id, ContentVersion>();
                    
                        //Loop over the newly created content versions to get content document Ids
                        for(ContentVersion cVersion : [Select Id, Title, ContentDocumentId from ContentVersion where Id IN: newContentVersions AND ContentDocumentId != null]){
                        
                            mapNewContentVersions.put(cVersion.Id, cVersion);
                        }
                            
                        //New list of ContentDocumentLink
                        List<ContentDocumentLink> listContentDocumentLinksToBeInsert = new List<ContentDocumentLink> ();
                    
                        //List of proposal to update
                        List<SBQQ__Quote__c> proposalsToBeUpdated = new List<SBQQ__Quote__c>();            
                        
                        //Loop over object Ids which are cloned proposal/CPQ Exception Request.
                        for(Id ObjectsToBeCloneId : mapObjectsToBeCloneWithContentVersionToBeCloneIds.keySet()) {
                    
                            if(mapObjectsToBeCloneWithContentVersionToBeCloneIds.get(ObjectsToBeCloneId) != null){
                                
                                for(Id oldCVId : mapObjectsToBeCloneWithContentVersionToBeCloneIds.get(ObjectsToBeCloneId)){
                                    
                                    //Check if the it is calculator export file
                                    if(mapOfProposalToBeCloneWithCalculatorExportFileId.containsKey(ObjectsToBeCloneId) 
                                        && mapOfProposalToBeCloneWithCalculatorExportFileId.get(ObjectsToBeCloneId) != null
                                        && oldCVId == (mapOfProposalToBeCloneWithCalculatorExportFileId.get(ObjectsToBeCloneId))        
                                        && mapContentVersionToBeCloneWithClonedContentVersion.containsKey(oldCVId)
                                        && mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId) != null
                                        && mapProposalToBeCloneIdWithClonedProposal.containsKey(ObjectsToBeCloneId)
                                        && mapProposalToBeCloneIdWithClonedProposal.get(ObjectsToBeCloneId) != null
                                        && mapNewContentVersions.containsKey(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id)
                                        && mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id) != null ){
                                                
                                        SBQQ__Quote__c prop = new SBQQ__Quote__c();
                                        prop.ID = mapProposalToBeCloneIdWithClonedProposal.get(ObjectsToBeCloneId).Id;
                                        prop.Calculator_Export_File_Id__c = mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id).ID;
                                        prop.Calculator_Export_File_Name__c = mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id).Title;
                                        
                                        proposalsToBeUpdated.add(prop);
                                        //sytem.debug('@@@@@ ')
                                        //Modified Mahendra Swarnkar - 11/26/2019 - Start
                                        /*if(CPQExportLibraryID != null){
                                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                                            cDocLink.ContentDocumentId = mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id).ContentDocumentId;
                                            cDocLink.ShareType = 'I';
                                            //cdl.Visibility = 'AllUsers';
                                            //cDocLink.LinkedEntityId = CPQExportLibraryID;
                                            cDocLink.LinkedEntityId = '0582K000000555r';
                                            listContentDocumentLinksToBeInsert.add(cDocLink);
                                        }*/
                                            //Modified Mahendra Swarnkar - 11/26/2019 - Stop
                                    /*} else {
                                        
                                        if(mapContentVersionToBeCloneWithClonedContentVersion != null && mapContentVersionToBeCloneWithClonedContentVersion.containsKey(oldCVId)
                                            && mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId) != null
                                            && mapNewContentVersions != null && mapNewContentVersions.containsKey(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id)
                                            && mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id) != null                                            
                                        ) {
                                            
                                            //create the content Document Links
                                            ContentDocumentLink cDocLink = new ContentDocumentLink();
                                            cDocLink.ContentDocumentId = mapNewContentVersions.get(mapContentVersionToBeCloneWithClonedContentVersion.get(oldCVId).Id).ContentDocumentId;
                                            cDocLink.ShareType = 'V';
                                            
                                            if(mapProposalToBeCloneIdWithClonedProposal != null 
                                                && mapProposalToBeCloneIdWithClonedProposal.containsKey(ObjectsToBeCloneId) 
                                                && mapProposalToBeCloneIdWithClonedProposal.get(ObjectsToBeCloneId) != null)
                                                cDocLink.LinkedEntityId = mapProposalToBeCloneIdWithClonedProposal.get(ObjectsToBeCloneId).Id;
                                            
                                            if(mapCPQExRequestToBeCloneIdWithClonedCPQExRequest != null 
                                                && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.containsKey(ObjectsToBeCloneId) 
                                                && mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.get(ObjectsToBeCloneId) != null)
                                                cDocLink.LinkedEntityId = mapCPQExRequestToBeCloneIdWithClonedCPQExRequest.get(ObjectsToBeCloneId).Id;
                                                
                                            listContentDocumentLinksToBeInsert.add(cDocLink);
                                        }
                                    }
                                }
                            }
                        }
                            
                        //Size check
                        if(listContentDocumentLinksToBeInsert.size() > 0){
                            //insert
                            insert listContentDocumentLinksToBeInsert;
                        }

                        //Size CHeck
                        if(proposalsToBeUpdated.size() > 0) {
                        
                            Util.BypassAllTriggers = true;
                            //Update
                            update proposalsToBeUpdated;
                            Util.BypassAllTriggers = false;
                        }
                    }
                }
            }   
        }
    }*/
}