/**
 *  Description     :  Helper class for SBQQ_QuoteTrigger trigger.
 *
 *  Created By      :  Subhash Garhwal 
 *
 *  Created Date    :  06/23/2016
 *
 *  Revision Logs   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762 
 *                      V_1.1 - Modified By - Subhash Garhwal - 05/04/2017 - CR-20170403-10807 - Added a new method autoPopulateFieldOnQuotes
 *                      V_1.2 - Modified By - Subhash Garhwal - 05/12/2017 - CR-20170403-10807 - Added a new method autoPopulateEndDateOnQuotes
 *                      V_1.3 - Modified By - Saurabh Kumar   - 05/24/2017 - CR-20170403-10807 - "updateContractLOAStage" method is updated due to no longer use of Pipeline value
 *                      V_1.4 - Modified By - Subhash Garhwal - 06/06/2017 - CR-20170403-10807 - "autoPopulateFieldsOnProposal" method is update subscription term and proposal version
 *                      V_1.5 - Modified By - Subhash Garhwal - 06/16/2017 - CR-20170403-10807 - "rollUpAnnualizedOpportunityValueonOpportunity"
 *                      V_1.6 - Modified By - Subhash Garhwal - 07/03/2017 - Issue--CR10810--QA--00004844  "updateOpportunityStatus"
 *                      V_1.7 - Modified By - Subhash Garhwal - 08/01/2017 - Added "validateOpportunityProducts" method (Issue--CR10808--QA--00005213)
 *                      V_1.8 - Modified By - Colin McGloin   - 08/08/2017 - Added "preventProposalDeletion" method (Issue--CR11106--UAT--00005362)
 *                      V_1.9 - Modified By - Deepak kumar    - 08/17/2017 - Modified "autoPopulateFieldsOnProposal" method (Issue--CR11094--QA--00005396)
 *                      V_2.0 - Modified By - Subhash Garhwal - 08/21/2017 - Modified "validateOpportunityProducts" remove condition for proposal line 
 *                                                                           SBQQ_QuoteLineTriggerHelper.validateOpportunityProducts() because Rollup_Products_to_Opportunity dlrs is working for the requirement.
 *                      V_2.0 - Modified By - Subhash Garhwal - 11/07/2017 - Added bypass flag (BYPASSPROPOSALTRIGGERFORMERGE)
 *                      V_2.1 - Modified By - Victor Hanson   - 11/30/2017 - CR-20171130-11826
 *                      V_2.2 - Modified By - - Commented Out the Method "validateOpportunityProducts" As per the comments on trigger and Class, this method is not invoke from anywhere. so commented out Method to increase the Coverage of Class.
 *                      V_2.3 - Modified By - Subhash Garhwal - CR-20180126-11917 - New method is added i.e. markFirstProposalAsPrimary
 *                      V_2.4 - Modified By - Subhash Garhwal - 02/02/2018 - CR-20180126-11911 -  New Method is Called populateIntegratedAccounts
 *                      V_2.5 - Modified By - Subhash Garhwal - 02/08/2018 - CR-20180126-11904  - New Method is Called updateFirstYearFeesForRenewalOpp
 *                      V_2.6 - Modified By - Subhash Garhwal - 03/19/2018 - CR-20180205-11952 - New method Added - preventPrimaryCheckUpdate
 *                      V_2.7 - Modified By - Subhash Garhwal - 03/19/2018 - CR-20180316-12110 - sendSignedLOAToOwner - Added a IsLatest = true check in the Query
 *                      V_2.8 - Modified By - Subhash Garhwal - 03/27/2018 - Added checks to avoid SOQL issue for Renewal Proposal (ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL check) 
 *                      V_2.9 - Modified By - Subhash Garhwal - 04/06/2018 - Added Additonal check for end date in method autoPopulateEndDateOnQuotes as per Issue--CR12129--QA--00007950
 *                      V_3.0 - Modified By - Subhash Garhwal - 04/27/2018 - CR-20180427-12188 - Modified populateIntegratedAccounts method
 *                      V_3.1 - Modified By - Victor Hanson   - 05/24/2018 - CR-20180205-11956 - Added recalculatePriceRules method
 *                      V_3.2 - Modified By - Subhash Garhwal - 07/16/2018 - CR-20180205-12018 - Added updateLOANonStandardClauses method
 *                      V_3.3 - Modified By - Subhash Garhwal - 10/26/2018 - CR-20180515-12225 - updated method 'autoPopulateFieldsOnProposal' to update the 'Invoice Frequence' as 'Annual'
 *                      V_3.4 - Modified By - Victor Hanson   - 10/30/2018 - CR-20181026-12713 - modified 'recalculatePriceRules' and added 'recalculatePriceRulesFuture'
 *                      V_3.5 - Modified By - Subhash Garhwal - 01/09/2019 - CR-20181019-12685 - Modified populateIntegratedAccounts method to populate Sync_Calculator_Update_Date__c field value on before update/insert case
 *                      V_3.6 - Modified By - Subhash Garhwal - 01/23/2019 - CR-20181019-12685 - Added populateProgramPackageFields method
 *                      V_3.7 - Modified By - Subhash Garhwal - 05/22/2019 - CR-20181019-12685 - Added populateAccountMSADate method
 *                      V_3.8 - Modified By - Subhash Garhwal - 06/03/2019 - CR-20181019-12685 - Added populateContractDocumentCreationDate method
 *                      V_3.9 - Modified By - Mahendra Swarnakar - 09/25/2019 - CR-20190911-13329 - Added populateMSADetailsFromInstitution method
 *                      V_4.0 - Modified By - Colin McGloin      - 06/01/2020 - CR-20200518-14066
 *                      V_4.1 - Modified By - Subhash Garhwal    - 06/23/2030 - CR-20200619-14207  -   Added check for "MSA Not Needed", "populateAccountMSADate"  method
 *                      V_4.2 - Modified By - Mahendra Swarnakar - Added condition to populate the Contract_Document_Creation_Date__c when the SBQQ__DocumentStatus__c = DOCUMENT_STATUS_SIGNED_MANUAL_UPLOAD
 *                      V_4.3 - Modified By - Subhash Garhwal - CR-20210521-15175
 *                      V_4.4 - Modified By - Subhash Garhwal - CR-20210811-15348
 * 			V_4.5 - Modified By - Colin McGloin - CR-20220217-15924 - Added additional Account mapping logic to autoPopulateFieldsOnProposal method
 *                      
**/ 
public without sharing class SBQQ_QuoteTriggerHelper {
    
    //Flag to contol the Quote Line trigger execution 
    public static Boolean executeUpdateContractLOAStageLogic = true;
    public static Boolean recalculatePriceRulesHasExecuted = false;
    public static Boolean populateGradingCriteriaForContractedProposalExecuteOnce = true;
    
    //Set to hold the Program Opportunity Ids
    //This set will populate in before delete trigger and being used in after delete trigger.
    //Reason : Need to validate Program Opportunities of Child Quote Line and on the deleation of the Master record, child record also deleted
    //but child trigger not executed.
    static Set<Id> setProgramOpportunitiesId = new Set<Id>();
    
    //Add a new flag to bypass the Proposal methods in case of Merge
    public static Boolean BYPASSPROPOSALTRIGGERFORMERGE = false;
    
    //05/20/2019 - Subhash Garhwal - Added flag to control the large deal MSG
    public static Boolean CONTROLLARGEDEALEXECUTION = false;
    
    /**
    *
    *   @description    :   If the Document Status is updated to Sent for Signature, email a copy of the signed LOA to the proposal owner
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Victor Hanson - 06/15/2017
    *                   :   V_1.1 - Subhash Garhwal - 03/19/2018 - CR-20180316-12110 - Added a IsLatest = true check in the Query
    *
    **/
    public static void sendSignedLOAToOwner(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {
        
        //list of proposals that need to be sent this email
        set<Id> proposalIdsToNotify = new set<Id>();
        set<Id> contentIds = new set<Id>();
        list<Messaging.SingleEmailMessage> emailsToSend = new list<Messaging.SingleEmailMessage>();
        
        for(SBQQ__Quote__c proposal : proposals)
        {
            //get the old proposal
            SBQQ__Quote__c oldProposal;
            if (mapOldProposals != null) oldProposal = mapOldProposals.get(proposal.Id);
            
            if (proposal.SBQQ__DocumentStatus__c != null 
                && proposal.SBQQ__DocumentStatus__c != oldProposal.SBQQ__DocumentStatus__c
                && proposal.SBQQ__DocumentStatus__c.equalsIgnoreCase(Label.Document_Status_Sent_For_Signature))
            {
                proposalIdsToNotify.add(proposal.Id);
                contentIds.add(proposal.LOA_PDF_Document_ID__c);
            }
        }
        
        if (proposalIdsToNotify.size() > 0)
        {
            //get the email template id
            list<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Proposal_Ready_Email_Template_Name];
            
            //get map of proposals, so we can get the owner's email address
            map<Id, SBQQ__Quote__c> proposalDetailMap = new map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__SalesRep__r.Email FROM SBQQ__Quote__c WHERE Id IN :proposalIdsToNotify]);
            
            //Updated the Query - Subhash Garhwal - 03/19/2018 - CR-20180316-12110 - Added a IsLatest = true check in the Query
            //get the signed LOA files
            list<Contentversion> signedLOAs = [Select Id, ContentDocumentId, VersionData, Title, FileExtension 
                                               FROM ContentVersion 
                                               WHERE ContentDocumentId IN :contentIds AND IsLatest = true];
            
            //Modified By - Subhash Garhwal - CR-20180316-12110 - Additional Check in the Query.IsLatest = true 
            //VH 11/3/17 - Issue--CR11556--QA--00007098: This is an odd bug, where the ContentVersion is not returning, unless queried twice.
            if (signedLOAs.size() == 0)
            {
                signedLOAs = [Select Id, ContentDocumentId, VersionData, Title, FileExtension 
                              FROM ContentVersion 
                              WHERE ContentDocumentId IN :contentIds AND IsLatest = true];
            }
            
            //throw new customException('@@debugging:' + JSON.serialize(signedLOAs) + JSON.serialize(contentIds));
            map<Id, ContentVersion> docIdToVersion = new map<Id, ContentVersion>();
            for (Contentversion cv : signedLOAs)
                docIdToVersion.put(cv.ContentDocumentId, cv);
            
            for (SBQQ__Quote__c p : proposals)
            {
                //Checking for the null value
                if(p.LOA_PDF_Document_ID__c != null && docIdToVersion.containsKey(p.LOA_PDF_Document_ID__c))
                {
                    //create the attachment
                    ContentVersion cv = docIdToVersion.get(p.LOA_PDF_Document_ID__c);
                    Messaging.EmailFileAttachment efa = EmailHandler.createEmailAttachment(cv.Title + '.' + cv.FileExtension, cv.VersionData);
                    
                    emailsToSend.add(EmailHandler.createEmail(new String[] { proposalDetailMap.get(p.Id).SBQQ__SalesRep__r.Email }, 
                                                              p.Id, 
                                                              p.OwnerId, 
                                                              templates[0].Id,
                                                              new Messaging.EmailFileAttachment[] { efa }
                                                             ));
                }
            }
            
            if (emailsToSend.size() > 0)
                Messaging.sendEmail( emailsToSend );
        }
    }
    
    /**
    *
    *   @description    :   This automation piece will roll up the first year fees from the First Year of the Quote to the Opportunity level
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Colin McGloin - 04/12/2017
    *
    **/
    
    public static void rollUpFirstYearFees(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        
        //Map to hold the quote and Opportunity
        Map<Id, Opportunity> mapQuotes = new Map<Id, Opportunity>();
        
        //List for updates later
        List<Opportunity> OpportunityUpdate = new List <Opportunity>(); 
        
        //Loop over quotes
        for(SBQQ__Quote__c qS : quotes != null ? quotes : mapOldQuotes.values())
        {
            if (qS.SBQQ__Primary__c == TRUE)
            {
                //Insert Case
                if(mapOldQuotes == null && qS.SBQQ__Opportunity2__c != null)
                    mapQuotes.put(qS.Id, new Opportunity(Id = qS.SBQQ__Opportunity2__c));
                
                //Update case
                if(mapOldQuotes != null && quotes != null &&
                   (qS.SBQQ__Opportunity2__c != mapOldQuotes.get(qS.Id).SBQQ__Opportunity2__c
                    || qS.SBQQ__Primary__c  != mapOldQuotes.get(qS.Id).SBQQ__Primary__c
                    || qS.SBQQ__CustomerAmount__c  != mapOldQuotes.get(qS.Id).SBQQ__CustomerAmount__c
                    || qS.X1st_Year_Initiation_or_Imp__c  != mapOldQuotes.get(qS.Id).X1st_Year_Initiation_or_Imp__c
                    || qS.X1st_Year_Annual__c  != mapOldQuotes.get(qS.Id).X1st_Year_Annual__c
                    || qS.X1st_Year_Travel__c  != mapOldQuotes.get(qS.Id).X1st_Year_Travel__c)) 
                {
                    //Check for quote
                    if(qS.SBQQ__Opportunity2__c != null)
                        mapQuotes.put(qS.Id, new Opportunity(Id = qS.SBQQ__Opportunity2__c));
                    
                    //Check for old quote
                    if(mapOldQuotes.get(qS.Id).SBQQ__Opportunity2__c != null)
                        mapQuotes.put(mapOldQuotes.get(qS.Id).Id, new Opportunity(Id = mapOldQuotes.get(qS.Id).SBQQ__Opportunity2__c));                    
                }
                
                //Delete case
                if(quotes == null && qS.SBQQ__Opportunity2__c != null)
                    mapQuotes.put(qS.Id, new Opportunity(Id = qS.SBQQ__Opportunity2__c));
                
            }
            
        }
        
        //Check for size
        if(mapQuotes.size() > 0)
        {
            //Query through QuoteLines
            List <AggregateResult> aggr = [SELECT SBQQ__Quote__c, SUM (SBQQ__CustomerTotal__c) total
                                           FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :mapQuotes.keySet() AND SBQQ__SegmentIndex__c = 1 AND (Product_Category__c = 'Annual Fee' OR Product_Category__c = 'Travel Fee' OR Product_Category__c = 'Implementation Fee')
                                           GROUP BY SBQQ__Quote__c];
            
            for ( AggregateResult ar : aggr)
            {
                Decimal firstYearFees = 0.00;
                
                Id quoteId = (Id)ar.get('SBQQ__Quote__c');
                firstYearFees = (Decimal)ar.get('total');
                
                if (mapQuotes.containsKey(quoteId))
                {
                    Opportunity oppTotal = mapQuotes.get(quoteId);
                    oppTotal.First_Year_Fees__c = firstYearFees;
                    mapQuotes.put(quoteId, oppTotal);
                    
                }
                
            }
            
        }
        
        if (mapQuotes.size() > 0)
        {
            /*  Map<Id, Id> mapQuoteIdWithoppId = new Map<Id, Id>();
            Map<Id, Decimal> mapOppIdWithFirstYearFees = new Map<Id, Decimal>();
            
            for(Id qId : mapQuotes.keySet()){
            mapQuoteIdWithoppId.put(qId, mapQuotes.get(qId).Id);
            mapOppIdWithFirstYearFees.put(mapQuotes.get(qId).Id, mapQuotes.get(qId).First_Year_Fees__c);
            }
            
            rollUpFirstYearFeesFuture(mapQuoteIdWithoppId, mapOppIdWithFirstYearFees);
            */
            update mapQuotes.values();
            
        }
        
    }
    
    @future
    public static void rollUpFirstYearFeesFuture(Map<Id, Id> mapQuoteIdWithoppId, Map<Id, Decimal> mapOppIdWithFirstYearFees) {
        if(mapQuoteIdWithoppId != null && mapQuoteIdWithoppId.size() > 0)
        {
            List<Opportunity> oppToUpdate = new List<Opportunity>();
            for(Id qId : mapQuoteIdWithoppId.keySet())
            {
                if(mapQuoteIdWithoppId.get(qId) != null && mapOppIdWithFirstYearFees != null && mapOppIdWithFirstYearFees.size() > 0 
                   && mapOppIdWithFirstYearFees.containsKey(mapQuoteIdWithoppId.get(qId)))
                { 
                    oppToUpdate.add(new Opportunity(Id = mapQuoteIdWithoppId.get(qId), First_Year_Fees__c = mapOppIdWithFirstYearFees.get(mapQuoteIdWithoppId.get(qId))));
                }
            }
            if(oppToUpdate.size() > 0)
            {
                update oppToUpdate;
            }
        }
        
    }

    /**
	 *
	 *   @description    :   This automation piece will increase the value of "Proposal Version" by 1 every time it's hit or update the field to match LOA Document Version when that field is updated
	 *
	 *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
	 *
	 *   @return         :   void
	 *
	 *   @revision Log   :   V_1.0 - Created - Colin McGloin - 05/02/2017
	 *                       V_1.1 - Modified - Victor Hanson - 11/30/2017: CR-20171130-11826
	 *
	 **/

    public static void updateProposalVersion (List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        
        //Integer for incremeting Proposal Version
        Integer proposalVersion;
        //Decimal for capturing the number of Proposal Lines associated with the Proposal
        Integer numOfProposalLines;
        
        //Loop over quotes
        for(SBQQ__Quote__c qS : quotes != null ? quotes : mapOldQuotes.values())
        {
            //Insert Case - Proposal Version is equal to 0, the value the user set or the the value of the populated LOA Documment Version field
            if(mapOldQuotes == null)
                proposalVersion = 1;
            if (qS.Proposal_Version__c == null && qS.LOA_Document_Version__c != null)
            {
                qS.Proposal_Version__c = qS.LOA_Document_Version__c;
            }
            else if (qS.Proposal_Version__c == null && qS.LOA_Document_Version__c == null)
            {
                qS.Proposal_Version__c = String.valueof(proposalVersion);
            }
            
            //If one of our key fields changes, then update the Proposal Version field counter
            if(mapOldQuotes != null && quotes != null &&
               (qS.SBQQ__ExpirationDate__c != mapOldQuotes.get(qS.Id).SBQQ__ExpirationDate__c
                || qS.SBQQ__StartDate__c  != mapOldQuotes.get(qS.Id).SBQQ__StartDate__c
                || qS.SBQQ__SubscriptionTerm__c  != mapOldQuotes.get(qS.Id).SBQQ__SubscriptionTerm__c
                || qS.SBQQ__EndDate__c  != mapOldQuotes.get(qS.Id).SBQQ__EndDate__c
                || qS.SBQQ__FirstSegmentTermEndDate__c  != mapOldQuotes.get(qS.Id).SBQQ__FirstSegmentTermEndDate__c
                //|| qS.SBQQ__DocumentStatus__c  != mapOldQuotes.get(qS.Id).SBQQ__DocumentStatus__c
                //|| qS.SBQQ__Primary__c  != mapOldQuotes.get(qS.Id).SBQQ__Primary__c //vh commented out 11/30/17: CR-20171130-11826
                //|| qS.Nickname__c  != mapOldQuotes.get(qS.Id).Nickname__c //vh commented out 11/30/17: CR-20171130-11826
                || qS.SBQQ__Opportunity2__c  != mapOldQuotes.get(qS.Id).SBQQ__Opportunity2__c
                || qS.SBQQ__SalesRep__c  != mapOldQuotes.get(qS.Id).SBQQ__SalesRep__c
                || qS.SBQQ__PrimaryContact__c  != mapOldQuotes.get(qS.Id).SBQQ__PrimaryContact__c
                || qS.PrimaryContactTitle__c  != mapOldQuotes.get(qS.Id).PrimaryContactTitle__c
                || qS.PrimaryContactEmail__c  != mapOldQuotes.get(qS.Id).PrimaryContactEmail__c
                || qS.Primary_Contact_Institution__c  != mapOldQuotes.get(qS.Id).Primary_Contact_Institution__c
                || qS.Primary_Contact_Salutation__c  != mapOldQuotes.get(qS.Id).Primary_Contact_Salutation__c
                || qS.X1st_Year_Annual__c  != mapOldQuotes.get(qS.Id).X1st_Year_Annual__c
                || qS.X1st_Year_Initiation_or_Imp__c  != mapOldQuotes.get(qS.Id).X1st_Year_Initiation_or_Imp__c
                || qS.X1st_Year_Travel__c  != mapOldQuotes.get(qS.Id).X1st_Year_Travel__c
                //|| qS.Annualized_Contract_Value__c  != mapOldQuotes.get(qS.Id).Annualized_Contract_Value__c
                || qS.Profit__c  != mapOldQuotes.get(qS.Id).Profit__c
                || qS.LOA_Document_Revision__c  != mapOldQuotes.get(qS.Id).LOA_Document_Revision__c
                || qS.Invoice_Frequency__c  != mapOldQuotes.get(qS.Id).Invoice_Frequency__c
                || qS.Set_Invoice_Date__c  != mapOldQuotes.get(qS.Id).Set_Invoice_Date__c
                || qS.SBQQ__Account__c  != mapOldQuotes.get(qS.Id).SBQQ__Account__c))
            {
                //Check for old quote
                if(mapOldQuotes.get(qS.Id) != null)
                {
                    //Check for proposal version && Line Item Count
                    if(mapOldQuotes.get(qS.Id).Proposal_Version__c != null && mapOldQuotes.get(qS.Id).SBQQ__LineItemCount__c != null)
                    {
                        //Set our two field values from the old record
                        proposalVersion = Integer.valueof(mapOldQuotes.get(qS.Id).Proposal_Version__c);
                        numOfProposalLines = Integer.valueof(qS.SBQQ__LineItemCount__c);
                        
                        //We want to exclude incremeting the proposal version before the Proposal Lines are added for the first time
                        //So if the Proposal Version is 0 and there are no proposal lines - do not increment in this scenario - but increment in all other scenarios
                        if (numOfProposalLines == 0 && proposalVersion == 1)
                        {
                            proposalVersion = 1;
                        }
                        else 
                        {
                            //Add an increment to the value
                            proposalVersion += 1;
                        }
                        //Set the Proposal Version field to the right value
                        qS.Proposal_Version__c = String.valueof(proposalVersion);
                    }
                    
                }
            }
            
            //If the LOA Document Version field is updated, then match Proposal Version to that field's value
            if(mapOldQuotes != null && quotes != null &&
               (qS.LOA_Document_Version__c != mapOldQuotes.get(qS.Id).LOA_Document_Version__c))
            {
                //Check for old quote and populate field as needed
                if(mapOldQuotes.get(qS.Id) != null)
                    qS.Proposal_Version__c = qS.LOA_Document_Version__c;
            }
            //If Integrated_Accounts__c field is updated, then  Proposal verion updated
            if(mapOldQuotes != null && qS.Integrated_Accounts__c != mapOldQuotes.get(qS.Id).Integrated_Accounts__c)
            {
                Integer proposalV;
                proposalV = Integer.valueOf(qS.Proposal_Version__c);
                qS.Proposal_Version__c = String.valueOf(proposalV + 1);
            }
        }
    }
    
   /**
    *
    *   @description    :   This automation piece will kickoff the Batch_SpringCMDocStatus job whenever the Document Status changes to Redlines Pending Approval
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V_1.0 - Created - Victor Hanson - 06/09/2017
    *
    **/
    public static void checkDocumentStatus(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {
        for (SBQQ__Quote__c proposal : proposals)
        {
            SBQQ__Quote__c oldProposal = mapOldProposals.get(proposal.Id);
            if (proposal.SBQQ__DocumentStatus__c == Label.Redlines_Pending_Approval && oldProposal.SBQQ__DocumentStatus__c != proposal.SBQQ__DocumentStatus__c)
            {
                //run the batch job.  The finish method will kickoff a scheduled job to run every 15 minutes, if there are still records that need processed.
                database.executeBatch(new Batch_SpringCMDocStatus(), 1);
            }
        }
    }
    
    /**
     *
     *   @description    :   This automation update field on quotes when LOA_Document_Version__c is updated 
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/04/2017
     *
     **/
    public static void autoPopulateFieldOnQuotes(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Loop through Quotes 
        for(SBQQ__Quote__c proposal: proposals)
        {
            if (mapOldProposals != null && mapOldProposals.containsKey(proposal.Id))
            {
                //if the start date has changed, update the Set Invoice Date field
                if (proposal.SBQQ__StartDate__c != mapOldProposals.get(proposal.Id).SBQQ__StartDate__c)
                {
                    proposal.Set_Invoice_Date__c = proposal.SBQQ__StartDate__c;
                }
            }

            //Check for Conditions (Document Version is updated, and it has never been approved for redlines)
            if(proposal.LOA_Document_Version__c != mapOldProposals.get(proposal.Id).LOA_Document_Version__c 
               && proposal.LOA_Document_Version__c != null && proposal.Redlines_Approved_Date__c == null)
            {
                //Update Fields
                proposal.LOA_Non_Standard__c = false;
                proposal.LOA_Non_Standard_Clauses_Updated__c = false;
                proposal.LOA_Non_Standard_Clauses_Updated_By__c = null;
            }
        }
    }
    
    /**
     *
     *   @description    :   This automation update field on quotes when LOA_Document_Version__c is updated 
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/04/2017
     *
     **/
    public static void createContentDocument(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {

        //Set to hold id of proposal
        Set<Id> setProposalIds = new Set<Id>();
        
        //Set to hold the Opportunity Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Set to hold the Document Id
        Set<Id> setDocumentIds = new Set<Id>();

        //Loop through Quotes 
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Check for the condition
            if(proposal.LOA_PDF_Document_ID__c != null && proposal.LOA_PDF_Document_ID__c instanceof Id
               && proposal.SBQQ__Opportunity2__c != null && proposal.SBQQ__DocumentStatus__c == CPQConstants.DOCUMENT_STATUS_SIGNED
               && proposal.SBQQ__DocumentStatus__c != mapOldProposals.get(proposal.Id).SBQQ__DocumentStatus__c )
            {
                //Add Proposal Ids  
                setProposalIds.add(proposal.Id);
                
                //Add Opportunity Id
                setOppIds.add(proposal.SBQQ__Opportunity2__c);
                
                //Add Document Id
                setDocumentIds.add(proposal.LOA_PDF_Document_ID__c);
            } 
        }

        //Cehck for Set Size 
        if(setProposalIds.Size() > 0)
        {
            //Query for Signed LOA library
            List<ContentWorkspace> cW = [Select Id, Name From ContentWorkspace Where Name =: Label.CONTENTWORKSPACE_SIGNED_LOA LIMIT 1];
            
            //List to hold Content Document Link
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            
            //Map to hold the Library Id OR Opp Id as key and Set of Content Document as value
            Map<Id, Set<Id>> mapDocIdsWithLIbraryOROppId = new Map<Id, Set<Id>>();

            //Process if Signed LOA Content Workspace is found
            if(cW.Size()>0)
            {
                //Loop over the Content ContentDocumentLinks
                for(ContentDocumentLink cDL : [Select Id, ContentDocumentId,LinkedEntityId
                                               From ContentDocumentLink
                                               Where ContentDocumentId IN : setDocumentIds AND (LinkedEntityId IN : setOppIds OR LinkedEntityId =: cW[0].Id)])
                {
                    //Check LinkedEntityId in map
                    if(!mapDocIdsWithLIbraryOROppId.containsKey(cDL.LinkedEntityId))
                        mapDocIdsWithLIbraryOROppId.put(cDL.LinkedEntityId, new Set<Id>());
                    
                    //Add Document Id
                    mapDocIdsWithLIbraryOROppId.get(cDL.LinkedEntityId).add(cDL.ContentDocumentId);
                }
            
                //Loop through updated proposal
                for(SBQQ__Quote__c proposal  : [Select Id, LOA_PDF_Document_ID__c, SBQQ__Opportunity2__c From SBQQ__Quote__c Where Id IN: setProposalIds AND LOA_PDF_Document_ID__c != null])
                {
                    //Process if opportunity Id is not equal to null
                    if(proposal.LOA_PDF_Document_ID__c instanceof Id && proposal.SBQQ__Opportunity2__c != null && (!mapDocIdsWithLIbraryOROppId.containsKey(proposal.SBQQ__Opportunity2__c)
                                                                                                                   || !mapDocIdsWithLIbraryOROppId.get(proposal.SBQQ__Opportunity2__c).contains(Id.valueOf(proposal.LOA_PDF_Document_ID__c))))
                        contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = proposal.LOA_PDF_Document_ID__c,
                                                                         LinkedEntityId = proposal.SBQQ__Opportunity2__c, 
                                                                         ShareType = 'V',
                                                                         Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY));
    
                    //Check Size of Library
                    if(proposal.LOA_PDF_Document_ID__c instanceof Id  && cW.size() > 0 && (!mapDocIdsWithLIbraryOROppId.containsKey(cW[0].Id)
                                                                                           || !mapDocIdsWithLIbraryOROppId.get(cW[0].Id).contains(Id.valueOf(proposal.LOA_PDF_Document_ID__c))))
                        contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = proposal.LOA_PDF_Document_ID__c, LinkedEntityId = cW[0].Id,
                                                                         ShareType = 'I',
                                                                         Visibility = System.Label.CONTENTDOCUMENTLINK_VISIBILITY));
                }

            }

            //Check for Document link size 
            if(contentDocumentLinks.size() > 0)
                insert contentDocumentLinks;
        }
    }
    
    /**
     *
     *   @description    :   This automation update End date based on Subscription Term 
     *
     *   @args           :   List<SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 05/12/2017
     *                       V_1.1 - Modified By - Subhash Garhwal - 04/06/2018 -Additional Check for end date-  as per Issue--CR12129--QA--00007950
     *
     **/
    public static void autoPopulateEndDateOnQuotes(List<SBQQ__Quote__c> proposals){
        
        //Loop through Proposals
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Additional Check for end date
            //Check for Condition
            if(proposal.SBQQ__StartDate__c != null && proposal.SBQQ__SubscriptionTerm__c != null && proposal.SBQQ__EndDate__c == null)
            {
                //Update End Date
                proposal.SBQQ__EndDate__c = proposal.SBQQ__StartDate__c.addMonths(proposal.SBQQ__SubscriptionTerm__c.intValue()).addDays(-1);

            }
        }
    }
	
    /**
     *
     *   @description    :   This automation update subscription Term and Proposal version
     *
     *   @args           :   List<SBQQ__Quote__c> proposals
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 06/06/2017
     *                       V_1.1 - Modified - Victor Hanson - 07/13/2017 - Added logic to populate Existing_Products__c field
     *                       V_1.2 - Modified - Deepak kumar - 08/17/2017 - Added logic to populate the Invoice_Frequency__c Field by default - 'Annual' (Issue--CR11094--QA--00005396)
     *                       V_1.3 - Modified - Subhash GArhwal - 10/26/2018 - CR-20180515-12225 - update the 'Invoice Frequence' as 'Annual'
     * 			     V_1.4 - Modified - Colin McGloin - 02/17/2022 - CR-20220217-15924 - Populate Opt Out values on Proposal based on Account values
     *
     **/
    public static void autoPopulateFieldsOnProposal(List<SBQQ__Quote__c> proposals) {

        //set to hold opportunity Id
        Set<Id> setOpportunityIds = new Set<Id>();
        Set<Id> setContractIds = new set<Id>();
        //Added by Colin McGloin - CR-20220217-15924
        Set<Id> setAccountIds = new set<Id>();
        
        //Loop through Proposals
        for(SBQQ__Quote__c quote : proposals)
        {
            //CR-20180515-12225
            /*if(quote.Invoice_Frequency__c == null && quote.Invoice_Frequency_Override__c == null) {
            quote.Invoice_Frequency__c = CPQConstants.SBQQ_QUOTE_INVOICE_FREQUENECY_ANNUAL;
            }*/
            
            //Added check for "Legacy_Migrated_ES_Client__c != 'Migrated'" on proposal so that it will not override the value while data upload - by Subhash - 02/19/2020 - CR-20200210-13716 
            //Check, if quote type is 'Renewal'
            if(quote.SBQQ__Type__c == CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL && quote.Legacy_Migrated_ES_Client__c != 'Migrated')
                quote.Invoice_Frequency__c = CPQConstants.SBQQ_QUOTE_INVOICE_FREQUENECY_ANNUAL;
            
            //Process if condition are true
            if(quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Type__c == CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL) 
                setOpportunityIds.add(quote.SBQQ__Opportunity2__c);
            
            //get contract ids
            if (quote.SBQQ__MasterContract__c != null)
                setContractIds.add(quote.SBQQ__MasterContract__c);
            
            //default the subscription term to 36 months if EndDate and SubscriptionTerm are blank
            if (quote.SBQQ__EndDate__c == null && quote.SBQQ__SubscriptionTerm__c == null)
                quote.SBQQ__SubscriptionTerm__c = CPQConstants.DEFAULT_PROPOSAL_TERM_36_MONTHS;
            
            //Added by Subhash - 02/19/2020 - CR-20200210-13716 - to address the WF rule: "Reset Approval Status for Cloned Proposal"- Starts from Here
            //Check for Insert Case
            if(Trigger.isInsert && quote.Legacy_Migrated_ES_Client__c != 'Migrated')
            {
                quote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Open').getRecordTypeId();
                quote.SBQQ__Status__c = 'Draft';
                quote.SBQQ__WatermarkShown__c = true;
            }
            //Added by Subhash - 02/19/2020 - CR-20200210-13716 - to address the WF rule: "Reset Approval Status for Cloned Proposal"- Ends Here
            if (quote.SBQQ__Account__c != null){
                setAccountIds.add(quote.SBQQ__Account__c);
            }
        }
        
        //map of opportunities
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
        
        //Process if size of map is greater than zero
        if(setOpportunityIds.Size() >0)
        {
            //Map to hold opportunity
            mapOpportunities = new Map<Id,Opportunity>([Select Id, SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c,
                                                        SBQQ__RenewedContract__r.Main_Contact__c, SBQQ__RenewedContract__r.Main_Contact__r.Contact_Status__c
                                                        From Opportunity Where Id IN: setOpportunityIds AND SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c = true
                                                        AND  SBQQ__RenewedContract__c != null]);
            //Loop through proposal
            for(SBQQ__Quote__c quote : proposals)
            {
                //Check values contain in map
                if(mapOpportunities.containsKey(quote.SBQQ__Opportunity2__c))
                {
                    //Populate subscription term and proposal version
                    quote.SBQQ__SubscriptionTerm__c = mapOpportunities.get(quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c;
                    quote.Proposal_Version__c = '0';
                    quote.LOA_Document_Version__c = '0';
                    
                    if(mapOpportunities.get(quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.Main_Contact__r.Contact_Status__c == 'Active')
                        quote.SBQQ__PrimaryContact__c = mapOpportunities.get(quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.Main_Contact__c;
                    
                    //add contractId to our set of contracts, so we can populate Existing_Products__c
                    setContractIds.add(mapOpportunities.get(quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c);
                }
            }
        }
        
        //if there are related contract ids, find the existing products
        if (setContractIds.size() > 0)
        {
            //get the list of subscriptions related to the master contract
            map<Id, Contract> contracts = new map<Id, Contract>([SELECT Id, (SELECT Id, SBQQ__Product__r.Name
                                                                             FROM SBQQ__Subscriptions__r 
                                                                             WHERE RecordType.DeveloperName = :CPQConstants.SBQQ_SUBSCRIPTION_RECORD_TYPE_DEVELOPERNAME_PROGRAM)
                                                                 FROM Contract WHERE Id IN :setContractIds]);
            
            for (SBQQ__Quote__c q : proposals)
            {
                //list of existing product names
                set<string> productNames = new set<string>();
                string contractId;
                
                //contract id from amendments is on q.MasterContract.  On Renewals, it's taken from Opportunity.RenewedContract
                if (contracts.containsKey(q.SBQQ__MasterContract__c))
                    contractId = q.SBQQ__MasterContract__c;
                else if (mapOpportunities.containsKey(q.SBQQ__Opportunity2__c))
                    contractId = mapOpportunities.get(q.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c;
                
                if (contractId != null)
                {
                    //add the list of product names to our set
                    for (SBQQ__Subscription__c subscription : contracts.get(contractId).SBQQ__Subscriptions__r)
                        productNames.add(subscription.SBQQ__Product__r.Name);
                    
                    //write the list of products to the quote
                    q.Existing_Products__c = string.join(new list<string>(productNames), ',').abbreviate(255);
                }
                
            }
        }
        
        //map of Accounts
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        
        //Check for Account Ids
        if (setAccountIds.size() > 0){
            
            mapAccounts = new Map<Id,Account>([SELECT Id, Name, Opt_Out__c, Opt_out_Penalty_Amount__c, Early_Termination_Date__c
                                            	FROM Account 
                                            	WHERE Id in :setAccountIds]);
            
            //Check to see if we have Account values
            if(mapAccounts.values().size() > 0){
                
                //Loop through out Proposals again
                for(SBQQ__Quote__c quote : proposals){
                    
                    //Check for our Account
                    if (mapAccounts.containsKey(quote.SBQQ__Account__c)){
                        
                        //Account Field Updates
                        if(mapAccounts.get(quote.SBQQ__Account__c).Opt_Out__c != null){
                            quote.Opt_Out__c = mapAccounts.get(quote.SBQQ__Account__c).Opt_Out__c;
                        }
                        if(mapAccounts.get(quote.SBQQ__Account__c).Opt_out_Penalty_Amount__c != null){
                            quote.Opt_Out_Penalty_Amount__c = mapAccounts.get(quote.SBQQ__Account__c).Opt_out_Penalty_Amount__c;
                        }
                        if(mapAccounts.get(quote.SBQQ__Account__c).Early_Termination_Date__c != null){
                            quote.Early_Termination_Date__c = mapAccounts.get(quote.SBQQ__Account__c).Early_Termination_Date__c;
                        }
                    }
                }
            }
        }
    }
    
    /**
     *  @description    :   This method is used to update the Contract LOA Opportunity stage to Pipeline
     *
     *  @args           :   List<SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *                      V_1.1 - Modified By - Saurabh Kumar - 05/24/2017 - CR-20170403-10807 - "updateContractLOAStage" method is updated due to no longer use of Pipeline value
     *
     **/
    /*public static void updateContractLOAStage(List<SBQQ__Quote__c> quotes) {
        
        //Set to hold the Contract LOA Id
        Set<Id> setContractLOAIds = new Set<Id>();
        
        //Loop over Quotes
        for(SBQQ__Quote__c quote : quotes) {
            
            //Check for Contract LOA Opp
            if(quote.SBQQ__Opportunity2__c != null)
                setContractLOAIds.add(quote.SBQQ__Opportunity2__c); 
        }
        
        //Check for set size
        if(setContractLOAIds.size() > 0) {
            
            //List to update the contract LOA opps
            List<Opportunity> opportunities = new List<Opportunity>();
            
            //Query through contract LOA Opps
            for(Opportunity opp : [Select Id, StageName From Opportunity Where Id IN : setContractLOAIds]) {
                
                //Check for stage
                if(opp.StageName != CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE) {
                    
                    //Change Opp stage to pipeline
                    opp.StageName = CPQConstants.OPPORTUNITY_STAGE_ON_PIPELINE;
                    
                    //Add Opportunity in list
                    opportunities.add(opp);
                }
            }
            
            //Check for list size
            if(opportunities.size() > 0)
                update opportunities;
        }
    }*/
     
        
    /**
     *  @description    :   This method is used to update Program Opportunities according to Primary Quoute. 
     *                      Details from Work Order (Process) : Set a Proposal as the Primary for the Opp.  Once saved, the Program(s) on the Proposal will
     *                                                          be updated to reflect the Proposal status.  Any Programs on a different Proposal that
     *                                                          changed from Primary to not-Primary are updated to reflect the Proposal status.
     *
     *  @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20160414-9762
     *
     **/
    /*public static void syncProgramOpportunities(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
        
        //Set to hold the Quote Ids
        Set<Id> setQuoteIds = new Set<Id>();
        
        //Loop over the new quotes
        for(SBQQ__Quote__c quote : quotes) {
            
            //Check SBQQ__Primary__c checkbox
            if(quote.SBQQ__Primary__c != mapOldQuotes.get(quote.Id).SBQQ__Primary__c)
                setQuoteIds.add(quote.Id);  
        }
        
        //Check for set size to proceed further
        if(setQuoteIds.size() > 0) {
            
            //Map to hold the Program Opportunity Id with list of quote lines
            Map<Id, List<SBQQ__QuoteLine__c>> mapParentOppIdWithQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
            
            //Query through the Quote Lines
            for(SBQQ__QuoteLine__c qL : [Select Id,Program_Opportunity__c, Program_Opportunity__r.RecordTypeId, Program_Opportunity__r.RecordType.DeveloperName,
                                                Program_Opportunity__r.StageName, Is_a_Program__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c,
                                                SBQQ__Quote__r.SBQQ__Opportunity2__r.AccountId, SBQQ__Quote__r.SBQQ__Opportunity2__r.Closedate,
                                                SBQQ__Product__c, SBQQ__Product__r.Program__c, SBQQ__Product__r.Program__r.Business_line__c,
                                                Is_Primary_Quote__c,SBQQ__PackageTotal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Name, SBQQ__NetPrice__c,
                                                SBQQ__EffectiveQuantity__c, SBQQ__Existing__c, SBQQ__Renewal__c,SBQQ__ComponentTotal__c,SBQQ__RequiredBy__c,
                                                SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Program__c, Program_or_Component_Formula__c,
                                                SBQQ__RequiredBy__r.Program_or_Component_Formula__c, SBQQ__SegmentIndex__c
                                                From SBQQ__QuoteLine__c
                                                Where SBQQ__Quote__c IN : setQuoteIds AND Program_Opportunity__c != null
                                                ORDER BY Program_or_Component_Formula__c ASC NULLS LAST]) {
                
                //Check Program Opportunity Id in map
                if(!mapParentOppIdWithQuoteLines.containsKey(qL.Program_Opportunity__c))
                    mapParentOppIdWithQuoteLines.put(qL.Program_Opportunity__c, new List<SBQQ__QuoteLine__c>());
                
                //Add Quote Line in list
                mapParentOppIdWithQuoteLines.get(qL.Program_Opportunity__c).add(qL);                                    
            }
            
            //Check for Program Opportunities
            if(mapParentOppIdWithQuoteLines.size() > 0) {
                
                //Map to update the Program Opportunities
                Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
                
                //Loop over Program Opportunity Ids
                for(Id proOppId : mapParentOppIdWithQuoteLines.keySet()) {
                    
                    //Variable to calculate the Amount for Program Opportunity
                    Decimal programOppAmount = 0;
                    Boolean isPrimaryProgram = false;
                    
                    //Instance of Opportunity
                    Opportunity opp = new Opportunity();
                    
                    //Set Id
                    opp.Id = proOppId;
                    
                    //Call utility method to perform the calculations
                    CPQUtility.calculateProgramOppAmount(opp, mapParentOppIdWithQuoteLines.get(proOppId), true);
                    
                    //Add Program Opportunity
                    mapOpportunities.put(proOppId, opp);
                }
                
                //Check for map size
                if(mapOpportunities.size() > 0)
                    upsert mapOpportunities.values();       
            }
        }       
    }*/
    
    /**
     *  @description    :   This method is used to populate setProgramOpportunitiesId set
     *
     *  @args           :   List<SBQQ__Quote__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 08/11/2016 - Subhash Garhwal - CR-20160414-9762
     *
     **/
    /*public static void populateSetProgramOpportunitiesId(List<SBQQ__Quote__c> quotes) {
        
        //Initlize set
        setProgramOpportunitiesId = new Set<Id>();
        
        //Query through Quote Lines
        for(SBQQ__QuoteLine__c qL : [Select Id, Program_Opportunity__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : quotes AND Program_Opportunity__c != null])
            setProgramOpportunitiesId.add(qL.Program_Opportunity__c);       
    }*/
    
    /**
     *  @description    :   This method is used to populate validate Program Opportunities of related quote lines
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - Created - 08/11/2016 - Subhash Garhwal - CR-20160414-9762
     *
     **/
    /*public static void validateProgramOpportunities() {
        
        //Check for Program Opp set
        if(setProgramOpportunitiesId != null && setProgramOpportunitiesId.size() > 0)
            CPQUtility.validateProgramOpportunities(setProgramOpportunitiesId, new Set<Id>());
    }*/
	
   /**
    * 
    *   @description    :   This method used to calucualte total of Annualized_Contract_Value__c on Opportunity from primary proposal Annualized_Contract_Value__c 
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 06/16/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    *                       V1.2  Modified By - Rajeev Jain - 18/02/2020 - CR-20200110-13605 -  Remove zzzFirst Year Credit(Annualized_Contract_Value__c) field on opportunity object
    *                       We have comment this method as this method is used to calucualte total of Annualized_Contract_Value__c on Opportunity from primary proposal Annualized_Contract_Value__c 
                            and Annualized_Contract_Value__c  field is deleted from opportunity.
    **/
    /*public static void rollUpAnnualizedContractValueonOpportunity(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes){
        
        //Added check for insert case
        if(ContractTriggerHelper.BYPASS_CONTRACT_METHODS_FOR_RENEWAL_PROPOSAL && mapOldQuotes == null)
            return;
            
        //Map to hold Opportunity 
        Map<Id,Opportunity> mapOpportunityIdsWithOpportunity = new Map<Id,Opportunity>();

        //Loop through the Opportunity
        for(SBQQ__Quote__c quote : quotes != null ? quotes : mapOldQuotes.values()) {

            //Check for insert case
            if(quote.SBQQ__Opportunity2__c != null && mapOldQuotes == null && quote.Annualized_Contract_Value__c != null  && quote.SBQQ__Primary__c == true)
                mapOpportunityIdsWithOpportunity.put(quote.SBQQ__Opportunity2__c, new Opportunity(Id = quote.SBQQ__Opportunity2__c, Annualized_Contract_Value__c = 0));

            //Check for update casse
            if(quotes != null && mapOldQuotes != null && quote.SBQQ__Primary__c == true &&
                    (quote.SBQQ__Opportunity2__c != mapOldQuotes.get(quote.Id).SBQQ__Opportunity2__c 
                    || quote.Annualized_Contract_Value__c != mapOldQuotes.get(quote.Id).Annualized_Contract_Value__c 
                    || quote.SBQQ__Primary__c != mapOldQuotes.get(quote.Id).SBQQ__Primary__c)) {

                //Check new updated values not equal to null
                if(quote.SBQQ__Opportunity2__c != null )
                    mapOpportunityIdsWithOpportunity.put(quote.SBQQ__Opportunity2__c, new Opportunity(Id = quote.SBQQ__Opportunity2__c ,Annualized_Contract_Value__c = 0));

                //Check for old 
                if(mapOldQuotes.get(quote.Id).SBQQ__Opportunity2__c != null)
                    mapOpportunityIdsWithOpportunity.put(mapOldQuotes.get(quote.Id).SBQQ__Opportunity2__c, new Opportunity(Id = mapOldQuotes.get(quote.Id).SBQQ__Opportunity2__c, Annualized_Contract_Value__c = 0));
            }

            //Check for delete case
            if(quotes == null && quote.Annualized_Contract_Value__c != null && quote.SBQQ__Opportunity2__c != null  && quote.SBQQ__Primary__c == true )
                mapOpportunityIdsWithOpportunity.put(quote.SBQQ__Opportunity2__c, new Opportunity(Id = quote.SBQQ__Opportunity2__c ,Annualized_Contract_Value__c = 0));
        }

        //process if size greater than zero
        if(mapOpportunityIdsWithOpportunity.Size() > 0) {

            //Loop through aggreagate query
            for(AggregateResult aResult : [SELECT sum(Annualized_Contract_Value__c) totalAnnualizedContractValue, SBQQ__Opportunity2__c oppoId FROM SBQQ__Quote__c 
                                            WHERE SBQQ__Opportunity2__c IN: mapOpportunityIdsWithOpportunity.keySet()
                                            AND SBQQ__Primary__c = true
                                            AND SBQQ__Opportunity2__r.RecordType.DeveloperName IN: CPQConstants.SET_OPPORTUNITY_RECORDTYPE_DEVELOPERNAMES
                                            GROUP BY SBQQ__Opportunity2__c]) {
                //Id of Opportunity
                Id OpportunityId = Id.valueOf(String.valueof(aResult.get('oppoId')));

                //Hold total paid amount
                Decimal totalContractValue = (Decimal) aResult.get('totalAnnualizedContractValue');

                //Process if map contain key
                if(mapOpportunityIdsWithOpportunity.ContainsKey(OpportunityId))
                    mapOpportunityIdsWithOpportunity.get(OpportunityId).Annualized_Contract_Value__c = totalContractValue;
            }
            //Updates values
            if(mapOpportunityIdsWithOpportunity.size() > 0) {
                Util.byPassAllTriggers = true;
                update mapOpportunityIdsWithOpportunity.values();
                Util.byPassAllTriggers = false;
                
            }
        }
    }*/
    
   /**
    * 
    *   @description    :   This method used to update opportunity status when Document Status to “Signed” on proposal
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created - 07/03/2017 - Subhash Garhwal - Q2C Phase 2 - CR-20170403-10807
    * 
    **/
    public static void updateOpportunityStatus(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
    
        //Set to hold Opportunity Id
        Set<Id> setOpportunitiesIds = new Set<Id>();

        //Map to hold opportunity
        Map<Id, Opportunity> mapOpportunitiesTobeUpdate = new Map<Id,Opportunity>();

        
        //Loop through Quotes
        for(SBQQ__Quote__c quote : quotes)
        {
            //Check for condition
            if(quote.SBQQ__Primary__c && (quote.SBQQ__Opportunity2__c != mapOldQuotes.get(quote.Id).SBQQ__Opportunity2__c 
                                          && quote.SBQQ__Opportunity2__c != null) || (quote.SBQQ__DocumentStatus__c !=  mapOldQuotes.get(quote.Id).SBQQ__DocumentStatus__c
                                                                                      && quote.SBQQ__DocumentStatus__c == CPQConstants.DOCUMENT_STATUS_SIGNED))
                setOpportunitiesIds.add(quote.SBQQ__Opportunity2__c);
        }

        //Check for Size of Set 
        if(setOpportunitiesIds.Size() > 0)
        {
            //Loop through Quotes
            for(SBQQ__Quote__c quote : quotes)
            {
                //Check for Opportunity
                if(quote.SBQQ__Opportunity2__c != null )
                {
                    mapOpportunitiesTobeUpdate.put(quote.SBQQ__Opportunity2__c, new Opportunity(Id = quote.SBQQ__Opportunity2__c, StageName = CPQConstants.OPPORTUNITY_STAGE_CONTRACT_REC_SEND_TO_FINANCE ));
                }
            }   

            //Check for Map size
            if(mapOpportunitiesTobeUpdate.Size() > 0)
            {
                Util.byPassAllTriggers = true;
                update mapOpportunitiesTobeUpdate.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
	
    /**
     *
     *   @description    :  This method used to update Opportunity Primary Proposal 
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 07/19/2017
     *
     **/

    public static void updateOpportunityPrimaryProposal(List<SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> mapOldQuotes) {
    
        //Set to hold Proposal Ids
        Set<Id> setProposalIds = new Set<Id>();
        
        //Loop over proposal
        for(SBQQ__Quote__c proposal : quotes)
        {
            //Check for condition
            if(proposal.SBQQ__Opportunity2__c != null &&  proposal.SBQQ__Primary__c == true && proposal.SBQQ__Type__c == CPQConstants.SBQQ_QUOTE_TYPE_RENEWAL &&
               (mapOldQuotes == null  || proposal.SBQQ__Primary__c != mapOldQuotes.get(proposal.Id).SBQQ__Primary__c))
            {
                //Add Proposal Id in set
                setProposalIds.add(proposal.Id);
            }
        }

        //Check for size
        if(setProposalIds.Size() >0)
        {
            //Map of Opportunity
            Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
                        
            //Loop through Proposal
            for(SBQQ__Quote__c proposal : [Select Id, SBQQ__Opportunity2__c From SBQQ__Quote__c Where Id IN : setProposalIds AND SBQQ__Opportunity2__r.SBQQ__PrimaryQuote__c = null] )
            {
                //Check Map contains key
                if(!mapOpportunities.containsKey(proposal.SBQQ__Opportunity2__c))
                    mapOpportunities.put(proposal.SBQQ__Opportunity2__c, new Opportunity(Id = proposal.SBQQ__Opportunity2__c, SBQQ__PrimaryQuote__c = proposal.Id));
            }

            //Check for Size 
            if(mapOpportunities.Size() >0 )
            {
                Util.byPassAllTriggers = true;
                update mapOpportunities.values();
                Util.byPassAllTriggers = false;
            }
        }
    }
    
    /**
     *
     *   @description    :  This method used to validate Opportunity Products field 
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - 08/01/2017 - Subhash Garhwal - Q2C Phase 2 - Issue--CR10808--QA--00005213
     *                       V_1.1 - Updated - 08/21/2017 - Subhash Garhwal - remove condition for proposal line 
     *                                                                      - SBQQ_QuoteLineTriggerHelper.validateOpportunityProducts()
     *
     **/
   /* public static void validateOpportunityProducts(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {
        
        //Set to hold the Opportunity Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Map to update Opportunities
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c proposal : proposals != null ? proposals : mapOldProposals.values()) {
            
            //Check appropriate condition to execute the trigger logic
            if(proposals != null && proposal.SBQQ__Opportunity2__c != null && (mapOldProposals == null || proposal.SBQQ__Primary__c != mapOldProposals.get(proposal.Id).SBQQ__Primary__c)) {
                
                //Add Opportunity Id in set
                setOppIds.add(proposal.SBQQ__Opportunity2__c);  
                
                //Check for Primary false
                if(!proposal.SBQQ__Primary__c && !mapOpportunities.containsKey(proposal.SBQQ__Opportunity2__c))
                    mapOpportunities.put(proposal.SBQQ__Opportunity2__c, new Opportunity(Id = proposal.SBQQ__Opportunity2__c, Opportunity_Products__c = ''));
            }
            
            //Delete case
            if(proposals == null && proposal.SBQQ__Primary__c && proposal.SBQQ__Opportunity2__c != null) {
                
                //Add Opportunity Id in set
                setOppIds.add(proposal.SBQQ__Opportunity2__c);  
                
                //Check for Primary false
                if(proposal.SBQQ__Primary__c && !mapOpportunities.containsKey(proposal.SBQQ__Opportunity2__c))
                    mapOpportunities.put(proposal.SBQQ__Opportunity2__c, new Opportunity(Id = proposal.SBQQ__Opportunity2__c, Opportunity_Products__c = ''));
            }
        }
        
        //Check for size
        if(setOppIds.size() > 0) {
            
            //List of Proposal Lines
            List<SBQQ__QuoteLine__c> proposalLines = [Select Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__ProductCode__c From SBQQ__QuoteLine__c
                                                             Where SBQQ__Quote__r.SBQQ__Opportunity2__c IN : setOppIds AND SBQQ__Quote__r.SBQQ__Primary__c = true];
            
            //SOQL over the Proposal Lines
            for(SBQQ__QuoteLine__c pL : proposalLines) {
                
                //Check Opportunity Id in map
                if(mapOpportunities.containsKey(pL.SBQQ__Quote__r.SBQQ__Opportunity2__c))
                    mapOpportunities.remove(pL.SBQQ__Quote__r.SBQQ__Opportunity2__c);   
            }
            
            //Update Opportunity
            if(mapOpportunities.size() > 0) {
                
                //Bypass trigger
                Util.BypassAllTriggers = true;
                update mapOpportunities.values();
                Util.BypassAllTriggers = false; 
            }
            
        }       
    } */

    /**
     *
     *   @description    :  This method is used to prevent Proposals from being deleted by users who do not have the Custom Permission "CPQ Proposal - Delete Permission"
     *
     *   @args           :   Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 08/08/2017 - Colin McGloin - Q2C Phase 2 - Issue--CR11106--UAT--00005362
     *
     **/
    public static void preventProposalDeletion (Map<Id, SBQQ__Quote__c> mapOldProposals) {

        //Modify By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
        //Use the generic Custom Permission Reader to check for the permission & populate our Boolean
        /*CustomPermissionsReader cpr = new CustomPermissionsReader();
        boolean deleteProposal = cpr.hasPermission('CPQ_Proposal_Delete_Permission');*/
        boolean deleteProposal = FeatureManagement.checkPermission('CPQ_Proposal_Delete_Permission');

        //If the user has permission to delete the record then exit the function
        if (deleteProposal){
            return;
        }
        //If the user does not have the permission then throw an Exception and present Custom Label as an error
        else {
            throw new CustomException(Label.PROPOSAL_DELETE_NOT_ALLOWED);
        }

    }
    
    /**
    *
    *   @description    :   Method to mark first proposal as primary
    *
    *   @args           :   List<SBQQ__Quote__c>
    *
    *   @return         :   void
    * 
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 01/31/2018 - CR-20180126-11917 
    *
    **/
    public static void markFirstProposalAsPrimary(List<SBQQ__Quote__c> proposals) {
        
        //Set to hold the Opportunity Ids
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Check for opportunity
            if(proposal.SBQQ__Opportunity2__c != null && proposal.SBQQ__Primary__c == false)
                setOppIds.add(proposal.SBQQ__Opportunity2__c);
        }
        
        //Check for size
        if(setOppIds.size() > 0)
        {
            //Set to hold the opportunities if opportunity already having prposal
            Set<Id> setOppsWithExistingProposals = new Set<Id>();
            
            //SOQL over the Propsoal
            for(SBQQ__Quote__c proposl : [Select Id, SBQQ__Opportunity2__c From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN : setOppIds])
                setOppsWithExistingProposals.add(proposl.SBQQ__Opportunity2__c);
            
            //Loop over the Proposals
            for(SBQQ__Quote__c proposal : proposals)
            {
                //Check for opportunity
                if(proposal.SBQQ__Opportunity2__c != null && proposal.SBQQ__Primary__c == false && !setOppsWithExistingProposals.contains(proposal.SBQQ__Opportunity2__c)) {
                    
                    //Set Propsoal as primary
                    proposal.SBQQ__Primary__c = true;
                    setOppsWithExistingProposals.add(proposal.SBQQ__Opportunity2__c);
                }
            }    
        }
    }
    
    /**
     *
     *   @description    :   Method to populate the integrated Accounts on the Proposal
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     * 
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 02/02/2018
     *                       V_1.1 - Modified - Subhash Garhwal - 04/27/2018 - CR-20180427-12188 - Change code to update Integrated Accounts
     *                       V_1.2 - Modified - Subhash Garhwal - 01/09/2019 - CR-20181019-12685 - added code to populate Sync_Calculator_Update_Date__c field value on before update/insert case 
     *
     **/
    public static void populateIntegratedAccounts(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {
        
        //Map to hold the Set of Account Formal Name of Integrated Account with Respactive opportunity Ids 
        Map<Id, Set<String>> mapAccountFormalNameOfIntegratedAccount = new Map<Id, Set<String>>();
        
        //Loop to get the proposal's Opportunity Ids 
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Added By Subhash Garhwal - 01/09/2019 - CR-20181019-12685 - Starts from here
            //check for field value
            if(proposal.Sync_Calculator_PDF__c == true && (mapOldProposals == null || ( mapOldProposals != null && proposal.Sync_Calculator_PDF__c != mapOldProposals.get(proposal.Id).Sync_Calculator_PDF__c )))
            {
                //Populate the field value based on the date the 'Pricing sheet'/'Comparison sheet' is generated.
                proposal.Sync_Calculator_Update_Date__c = system.today();
            }
            //Added By Subhash Garhwal - 01/09/2019 - CR-20181019-12685 - Ends here
            
            //Check if this is the new case or opportunity is updated on proposal
            if(proposal.SBQQ__Opportunity2__c != null && (mapOldProposals == null || proposal.SBQQ__Opportunity2__c != mapOldProposals.get(proposal.Id).SBQQ__Opportunity2__c
                                                          || proposal.Primary_Contact_Institution__c != mapOldProposals.get(proposal.Id).Primary_Contact_Institution__c))
                mapAccountFormalNameOfIntegratedAccount.put(proposal.SBQQ__Opportunity2__c, new Set<String>());
        }
        
        //Check for the Size of the Set
        if(mapAccountFormalNameOfIntegratedAccount.size() > 0)
        {
            //Query on the Integrated account to get the Account_Formal_Name__c of the Integrated Account.
            for(Integrated_Account__c integratedAcc : [Select Id, Opportunity__c, Account_Formal_Name__c From Integrated_Account__c 
                                                       Where Opportunity__c IN: mapAccountFormalNameOfIntegratedAccount.keySet()])
            {
                
                if(mapAccountFormalNameOfIntegratedAccount.containsKey(integratedAcc.Opportunity__c))                                            
                    mapAccountFormalNameOfIntegratedAccount.get(integratedAcc.Opportunity__c).add(integratedAcc.Account_Formal_Name__c);    
            }
            
            //Now loop on the proposal List
            for(SBQQ__Quote__c prop : proposals)
            {
                //Check if the Map contains the opportunity
                if(mapAccountFormalNameOfIntegratedAccount.size() > 0 && mapAccountFormalNameOfIntegratedAccount.containsKey(prop.SBQQ__Opportunity2__c)
                   && mapAccountFormalNameOfIntegratedAccount.get(prop.SBQQ__Opportunity2__c).size() > 0)
                {
                    //String to hold the Line Seperated Integrated Account Name related to the Same Opportunity
                    String integratedAccountsOfOpportunity = '';
                    
                    //Loop on the Map Values
                    for(String integratedName : mapAccountFormalNameOfIntegratedAccount.get(prop.SBQQ__Opportunity2__c)) 
                        integratedAccountsOfOpportunity += integratedName + '\n';       
                    
                    //Check if the Primary contact contains integrated Account
                    if(String.isNotBlank(integratedAccountsOfOpportunity) && String.isNotBlank(prop.Primary_Contact_Institution__c) && !integratedAccountsOfOpportunity.contains(prop.Primary_Contact_Institution__c))
                        //Populating the Field of proposal
                        prop.Integrated_Accounts__c = prop.Primary_Contact_Institution__c + '\n'+ integratedAccountsOfOpportunity.removeEnd('\n');
                    else
                        prop.Integrated_Accounts__c = integratedAccountsOfOpportunity.removeEnd('\n');
                    
                }else
                {
                    //For those Proposal the opportunity does not contain any Integrated Account 
                    prop.Integrated_Accounts__c = prop.Primary_Contact_Institution__c;
                }
            }
        }   
    }
    
    /**
    *
    *   @description    :   Method to populate the First Year Fees for Renewal Opp
    *
    *   @args           :   List<SBQQ__Quote__c>
    *
    *   @return         :   void
    * 
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 02/02/2018 - CR-20180126-11904
    *
    **/   
    public static void updateFirstYearFeesForRenewalOpp(List<SBQQ__Quote__c> proposals) {
        
        //Set to hold the Opportunity Id
        Set<Id> setOppIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Check for Opportunity
            if(proposal.SBQQ__Opportunity2__c != null)
                setOppIds.add(proposal.SBQQ__Opportunity2__c);  
        }
        
        //Check for set size
        if(setOppIds.size() > 0)
        {
            //Set to hold the Previous Opportunity Ids
            Set<Id> setPreviousOppIds = new Set<Id>();
            
            //List to hold the Opportunity
            List<Opportunity> continuingOpps = new List<Opportunity>();
            
            //SOQL over the Opp
            for(Opportunity opp : [Select Id, Previous_Opportunity__c, First_Year_Fees__c, (Select Id From SBQQ__Quotes2__r LIMIT 1) FROM Opportunity Where Id IN : setOppIds
                                   AND RecordType.DeveloperName IN : CPQConstants.SET_OPP_CONTINUING_RECORDTYPES AND SBQQ__PrimaryQuote__c = null
                                   AND Previous_Opportunity__c != null])
            {
                
                //Check for quote
                if(opp.SBQQ__Quotes2__r == null || opp.SBQQ__Quotes2__r.size() == 0)
                {
                    //Add Record in list
                    continuingOpps.add(opp);
                    
                    //Add Previous opportunity in set
                    setPreviousOppIds.add(opp.Previous_Opportunity__c);
                }
                
            }
            
            //Check for set size
            if(setPreviousOppIds.size() > 0)
            {
                
                //Map to hold the Previous Opportunity and Future Subscription Periods Proposal value
                Map<Id, Decimal> mapPreviousOppWithFutureSubPeriodProposalvalue = new Map<Id, Decimal>();
                
                //Map to hold the Previous Opp with Program Subscriptions
                Map<Id, Set<Id>> mapPreviousOppWithProgramSubIds = new Map<Id, Set<Id>>();
                
                //SOQL over the Subscription Period
                for(Subscription_Period__c sP : [Select Id, Proposal_Value_Number__c, Source_Opportunity__c, Program_Subscription__c From Subscription_Period__c Where Source_Opportunity__c IN : setPreviousOppIds
                                                 AND Stage__c =: CPQConstants.SUBSCRIPTION_PERIOD_STAGE_PENDING ORDER BY Period_Start_Date__c DESC, Source_Opportunity__c])
                {
                    
                    //Check Opportunity Id in map
                    if(!mapPreviousOppWithFutureSubPeriodProposalvalue.containsKey(sP.Source_Opportunity__c))
                    {
                        
                        //Add Proposal value
                        mapPreviousOppWithFutureSubPeriodProposalvalue.put(sP.Source_Opportunity__c, sP.Proposal_Value_Number__c != null ? sP.Proposal_Value_Number__c : 0);
                        
                        //Add Program Sub in map
                        mapPreviousOppWithProgramSubIds.put(sP.Source_Opportunity__c, new Set<Id>{sP.Program_Subscription__c});
                        
                    } else if(!mapPreviousOppWithProgramSubIds.get(sP.Source_Opportunity__c).contains(sP.Program_Subscription__c))
                    {
                        
                        //Check Proposal value
                        if(sP.Proposal_Value_Number__c != null)
                        {
                            //get Proposal value
                            Decimal provalue = mapPreviousOppWithFutureSubPeriodProposalvalue.get(sP.Source_Opportunity__c) + sP.Proposal_Value_Number__c;
                            
                            mapPreviousOppWithFutureSubPeriodProposalvalue.put(sP.Source_Opportunity__c, provalue);
                        }
                        
                        mapPreviousOppWithProgramSubIds.get(sP.Source_Opportunity__c).add(sP.Program_Subscription__c);
                    }
                    
                }
                
                //Check for map size
                if(mapPreviousOppWithFutureSubPeriodProposalvalue.size() > 0)
                {
                    
                    //List to update the First_Year_Fees__c
                    List<Opportunity> continuingOppsToUpdate = new List<Opportunity>();
                    
                    //Loop over continuing opp
                    for(Opportunity opp : continuingOpps)
                    {  
                        //Check for previous Opportunity in map
                        if(mapPreviousOppWithFutureSubPeriodProposalvalue.containsKey(opp.Previous_Opportunity__c))
                        {
                            //Update
                            opp.First_Year_Fees__c = mapPreviousOppWithFutureSubPeriodProposalvalue.get(opp.Previous_Opportunity__c);
                            
                            //Add reocrd in list
                            continuingOppsToUpdate.add(opp);
                        }
                        
                    }
                    
                    //Check for size
                    if(continuingOppsToUpdate.size() > 0)
                    {
                        //Bypass All Trigger
                        Util.ByPassAllTriggers = true;
                        
                        //Update the subscription period List
                        update continuingOppsToUpdate;
                        
                        //Reset the Bypss of trigger            
                        Util.ByPassAllTriggers = false;
                    }
                }
            }
        }
    }
    
    /**
    *
    *   @description    :   This method is used to check if someone is unchecking the primary proposal checkbox from true to false then restrict this Action. 
    *                       Restrict User only and only if this is triggered from the UI.
    *                       Logic - For now we have logic to only have one primary proposal under an opportunity, 
    *                               so check if opportunity doensn't have any primary proposal then add error.
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    * 
    *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 03/19/2018 - CR-20180205-11952
    *
    **/ 
    public static Void preventPrimaryCheckUpdate(List<SBQQ__Quote__c> newProposals, Map<Id, SBQQ__Quote__c> mapOldProposal) {
        
        //Set to hold the Id of Opportunity
        Set<Id> setOpportunityId = new Set<Id>();
        
        //Check for the list Size - If this is from UI then size of the new list has to be one and Oldmap List should not be null.(Update case)
        if(newProposals.size() == 1 && mapOldProposal != null)
        {
            //Loop on the List
            for(SBQQ__Quote__c proposal : newProposals)
            {
                //Check if the Primary Proposla checkbox value has changed 
                if(proposal.SBQQ__Primary__c == false && (mapOldProposal.get(proposal.id).SBQQ__Primary__c != proposal.SBQQ__Primary__c))
                    setOpportunityId.add(proposal.SBQQ__Opportunity2__c);    
            }
            
            //Check for the Size of the Set
            if(setOpportunityId.size() > 0 )
            {
                //Query on the Quote to check if any quote in primary under the Same Opportunity
                List<SBQQ__Quote__c> primaryQuote = [Select Id From SBQQ__Quote__c Where SBQQ__Opportunity2__c IN: setOpportunityId AND SBQQ__Primary__c = true];
                
                //Check for the Size of primaryQuote
                if(primaryQuote.size() == 0 || primaryQuote == null)
                {
                    //Adding error to the List, so that user can not make the Changes.
                    newProposals[0].addError(Label.Primary_Proposal_Uncheck_Restriction);
                }
            }
        }
    }  
    
    
    /**
    *
    *   @description    :   If the Set Invoice Date field is modified after insert and not
    *                       as part of a future or batch execution, recalculate price rules.
    *                       Originally added Set Invoice Date as part of CalculatedFields FieldSet,
    *                       but it caused an error when Contracting.
    *
    *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
    *
    *   @return         :   void
    * 
    *   @revision Log   :   V_1.0 - Created - Victor Hanson - 05/24/2018 - CR-20180205-11956
    *
    **/ 
    public static Void recalculatePriceRules(List<SBQQ__Quote__c> newProposals, Map<Id, SBQQ__Quote__c> mapOldProposal) {
        
        if (recalculatePriceRulesHasExecuted) return;
        recalculatePriceRulesHasExecuted = true;
        
        Set<Id> proposalIds = new Set<Id>();
        
        //don't execute if mapOldProposal is null, or insert or batch/future method
        if (mapOldProposal == null 
            || system.isBatch() 
            || system.isFuture()
            || system.isQueueable()
            || system.isScheduled()) 
        {
            return;
        }
        
        for (SBQQ__Quote__c proposal : newProposals)
        {
            SBQQ__Quote__c oldProposal = mapOldProposal.get(proposal.Id);
            
            if (proposal.SBQQ__StartDate__c != oldProposal.SBQQ__StartDate__c) proposal.Set_Invoice_Date__c = proposal.SBQQ__StartDate__c;
            
            //set trigger the recalculation by changing the value of Execute_Price_Rules__c field
            if (proposal.Set_Invoice_Date__c != oldProposal.Set_Invoice_Date__c)
                proposalIds.add(proposal.Id);
        }
        
        if (proposalIds.size() > 0)
        {
            recalculatePriceRulesFuture(proposalIds);
            /*if (!system.isScheduled()) {
            dateTime sysTime = dateTime.now().addMinutes(5);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('recalculatePriceRulesFuture' + sysTime.getTime(), chron_exp, new Sched_Testing(proposalIds));   
            }*/
        }
    }
    
    /**
    *
    *   @description    :   kicks off a future job that allows the price rules to execute
    *                       when the formula field (Grade_Criteria_Invoicing__c) has the updated value.
    *                       This allows the price rules to populate the correct grade value.
    * 
    *   @revision Log   :   V_1.0 - Created - Victor Hanson - 10/30/2018 - CR-20181026-12713
    *
    **/ 
    @future
    public static void recalculatePriceRulesFuture(Set<Id> proposalIds) {
        List<SBQQ__Quote__c> proposals = [SELECT Id, Execute_Price_Rules__c FROM SBQQ__Quote__c WHERE Id IN :proposalIds];
        
        for (SBQQ__Quote__c proposal : proposals)
            proposal.Execute_Price_Rules__c = !proposal.Execute_Price_Rules__c;
        
        util.bypassAllTriggers = true;
        update proposals;
    }
    
    /**
     *
     *   @description    :   This method is used to update the "LOA Non-Standard Clauses Updated By" field with current login user if LOA Non-Standard Clauses Updated? is updated to true
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     * 
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 07/16/2018 - CR-20180205-12018
     *
     **/
    public static void updateLOANonStandardClauses(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals) {
        
        //Loop over the Proposals
        for(SBQQ__Quote__c proposal : proposals)
        {
            //Check for condition to update
            if(proposal.LOA_Non_Standard_Clauses_Updated__c && (mapOldProposals == null || !mapOldProposals.get(proposal.Id).LOA_Non_Standard_Clauses_Updated__c))
                proposal.LOA_Non_Standard_Clauses_Updated_By__c = UserInfo.getUserId();
            else if(!proposal.LOA_Non_Standard_Clauses_Updated__c && mapOldProposals != null && mapOldProposals.get(proposal.Id).LOA_Non_Standard_Clauses_Updated__c)
                proposal.LOA_Non_Standard_Clauses_Updated_By__c = null;
        }
    }
    
    /**
     *
     *   @description    :   This used to populate the fields on Program Package:- Contract Sent.
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20181019-12685 - 01/23/2019
     *
     **/
    public static void populateProgramPackageFields(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Set to hold the Proposal Ids
        Set<Id> setProposalIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            //Check for conditions
            if(mapOldProposals == null || (mapOldProposals != null 
                                           && (prop.LOA_Signature_Date__c != mapOldProposals.get(prop.Id).LOA_Signature_Date__c
                                               || prop.Sync_Calculator_Update_Date__c != mapOldProposals.get(prop.Id).Sync_Calculator_Update_Date__c)))
            {
                //Populate the set
                setProposalIds.add(prop.Id);
            }
        }
        //Check for size
        if(setProposalIds.size() > 0)
        {
            //Map to hold the Program package records
            Map<Id, Program_Package__c> mapProgramPackage = new Map<Id, Program_Package__c>();
            
            //Loop Over the SPs
            for(Subscription_Period__c subs : [Select Id, Program_Package__c, Program_Package__r.Contract_Sent__c, Program_Package__r.Proposal_Sent__c, 
                                               Program_Subscription__r.SBQQ__QuoteLine__c, Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c,
                                               Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.Sync_Calculator_Update_Date__c From Subscription_Period__c 
                                               Where Program_Package__c != null AND Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c IN : setProposalIds 
                                               ORDER By CreatedDate DESC, Program_Package__c ])
            {         
                //Check for condition
                if(!mapProgramPackage.containsKey(subs.Program_Package__c) && subs.Program_Subscription__r.SBQQ__QuoteLine__c != null && subs.Program_Package__c != null 
                   && (subs.Program_Package__r.Contract_Sent__c != subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c) 
                   || subs.Program_Package__r.Proposal_Sent__c != subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.Sync_Calculator_Update_Date__c )
                {
                    Program_Package__c pPackage = new Program_Package__c(Id = subs.Program_Package__c);
                    
                    //Populate Contract Sent date
                    if(subs.Program_Package__r.Contract_Sent__c != subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c)
                        pPackage.Contract_Sent__c = subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.LOA_Signature_Date__c;
                    
                    //Populate Proposal Sent date
                    if(subs.Program_Package__r.Proposal_Sent__c != subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.Sync_Calculator_Update_Date__c)
                        pPackage.Proposal_Sent__c = subs.Program_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.Sync_Calculator_Update_Date__c;
                    
                    //Populate the map
                    mapProgramPackage.put(subs.Program_Package__c, pPackage);   
                }
            }
            
            //check for size
            if(mapProgramPackage.size() > 0)
            {
                //Disable all triggers
                Util.BypassAllTriggers = true;
                
                //Update Program Package
                update mapProgramPackage.values();
                
                //Enable all triggers
                Util.BypassAllTriggers = false;
            }
        }
    }
    
    
    /**
     * 
     * @description    :  This method is used to Add the warning MSG for Large Deal
     * 
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void  
     *
     *  @revision Log   :   V_1.0 - 05/15/2019 - Created - Subhash Garhwal - CR-20181019-12685
     * 
     **/
   /* public static void validateLargeDeals(List<SBQQ__Quote__c> proposals) {
        
        //VH 6/28/17: This isn't working as intended -- it always displays error.  Commenting out for now.
        //Subhash Garhwal 6/30/2017: un comment the code with some changes
        
        //Added new check
        if(CONTROLLARGEDEALEXECUTION)
            return;
        
        CONTROLLARGEDEALEXECUTION = true;
            
        //Set to hold the UK (Quote Id + ProductId)
        Set<String> setUKQuoteIdAndProductIds = new Set<String>();
        Set<String> setUKQuoteIdAndProductIdToRemoveValidation = new Set<String>();
        
        //Set to hold the UK (Quote Id + ProductId)
        Set<String> setUKQuoteIds = new Set<String>();
        Set<String> setUKQuoteIdsToRemoveValidation = new Set<String>();
        //Loop over the Proposal Lines
        for(SBQQ__Quote__c prop : proposals) {
            
            //Check for Values
            if (prop.Package_Total__c >= Integer.valueOf(Label.PROPOSAL_LINE_PRODUCT_VALUE)) {
                
                //see if we've already warned this user about this large deal
                Boolean hasSeenError;
                
                //Create unique combination
                String uK = prop.Id;
                
                if(Cache.Session.contains('local.Default.' + uK))
                    hasSeenError = (Boolean)Cache.Session.get('local.Default.' + uK);
                
                //Check UK in set
                if(setUKQuoteIds.contains('' + uK) && hasSeenError != null && hasSeenError)
                    hasSeenError = null;
        
                //Check for UK in avoid validation set
                if(setUKQuoteIdsToRemoveValidation.contains('' + uK) && (hasSeenError == null || !hasSeenError))
                    hasSeenError = true;
                
                
                //Check if error already shows to user  
                if(prop.ConfirmedBigDealNotification__c == false) {
                    
                    //Check if MSG already displayed
                    if (hasSeenError == null || !hasSeenError) {
                    
                        //Set MSG
                        prop.Calculator_Error_Message__c = Label.LARGE_DEAL_MSG;
                        prop.ConfirmedBigDealNotification__c = true;
                        
                        //add to the session cache so we know we've seen this error before
                        Cache.Session.put('local.Default.' + uK, true);
                        
                        //Add values in set
                        setUKQuoteIds.add('' + uK);
                    } else {
                        
                        //Set Notification variables to avoid the error MSG again
                        prop.Calculator_Error_Message__c = null;
                        prop.ConfirmedBigDealNotification__c = true;

                        //Update entry in session
                        Cache.Session.put('local.Default.'+ + uK, false);
                        
                        //Add UK in map
                        setUKQuoteIdsToRemoveValidation.add('' + uK);
                    }
                    
                } else
                    prop.Calculator_Error_Message__c = null;
            }
        }
    } */
    
    /**
     * 
     * @description: display an error in the quote line editor when Calculator Error Message is populated.
     * 
     *  @args           :   List<SBQQ__QuoteLine__c>
     *
     *  @return         :   void
     *
     *  @revision Log   :   V_1.0 - 05/15/2019 - Created - Subhash Garhwal - CR-20181019-12685
     * 
     **/
    /*public static void checkErrorsOnQuote(List<SBQQ__Quote__c> proposals) {
        //this is used to avoid duplicate error messages
        set<string> errors = new set<string>();
        
        //Loop over the quote Lines
        for(SBQQ__Quote__c prop : proposals) {
          
            //add calculator error message if there is an error message, and it's unique (don't want to display the same error several times).
            if (String.isNotBlank(prop.Calculator_Error_Message__c) && !errors.contains(prop.Calculator_Error_Message__c)) 
            {
                prop.addError(prop.Calculator_Error_Message__c);
                errors.add(prop.Calculator_Error_Message__c);//add the error to our set so we can avoid displaying duplicate errors
            }
        }
    }*/
    
    /**
     *
     *   @description    :   This used to populate Account MSA Date.
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created By - Subhash Garhwal - CR-20181019-12685
     * 			     V_1.1 - Modified By - Mahendra Swarnkar - CR-20190911-13329 - 09/25/2019 - Added check for "Member Template", If ‘Member Template’ is true, do not automatically update any MSA information.
     *			 :   V_1.1 - Modified By - Subhash Garhwal - CR-20200619-14207 - 06/23/2030 -   Added check for "MSA Not Needed", If ‘MSA Not Needed’ is true, do not automatically update any MSA information.
     *
     **/
    public static void populateAccountMSADate(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Set to hold the Proposal Ids
        Map<Id, SBQQ__Quote__c> mapProposals = new Map<Id, SBQQ__Quote__c>();
        
        //Set to hold the Proposal Ids
        Set<Id> setAccountIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            
            //Modified by - Mahendra Swarnkar - CR-20190911-13329 - Added check for "Member Template"
            //Modified by - Subhash Garhwal -   CR-20200619-14207 - Added check for "MSA Not Needed"
            //Check for conditions
            if(mapOldProposals != null && prop.SBQQ__Primary__c == true && prop.SBQQ__Account__c != null && prop.Member_Template__c == false && prop.MSA_Not_Needed__c == false
               && (prop.Contract_Document_Creation_Date__c != mapOldProposals.get(prop.Id).Contract_Document_Creation_Date__c 
                   || prop.LOA_PDF_Document_ID__c != mapOldProposals.get(prop.Id).LOA_PDF_Document_ID__c
                   || prop.LOA_PDF_Document_File_Name__c != mapOldProposals.get(prop.Id).LOA_PDF_Document_File_Name__c))
            {
                
                //Populate the set
                mapProposals.put(prop.Id, prop);
                setAccountIds.add(prop.SBQQ__Account__c);                
            }
        }
        
        if(setAccountIds.size() > 0 && mapProposals.size() > 0)
        {
            //List to account to update.
            List<Account> listAccountsToBeUpdate = new List<Account>();
            
            //ist Proposals to update
            List<SBQQ__Quote__c> listProposalstoUpdate = new List<SBQQ__Quote__c>();
            
            //Subhash Garhwal - CR-20210811-15348 - get lated ContentDocumentLink for MSA assignment
            List<ContentDocumentLink> latestContentDocument = [ SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType, ContentDocument.Title,ContentDocument.LastModifiedDate, ContentDocument.FileType 
                                                               FROM ContentDocumentLink 
                                                               WHERE LinkedEntityId IN : mapProposals.keySet() 
                                                               Order By ContentDocument.LastModifiedDate DESC LIMIT 1 
                                                              ];
            Map<Id, ContentDocumentLink> proposalToContentDocumentMap = new Map<Id, ContentDocumentLink>();
            if( latestContentDocument != null && latestContentDocument.size() > 0 )
            {
                proposalToContentDocumentMap.put( latestContentDocument[0].LinkedEntityId, latestContentDocument[0] );
            }
            
            //Subhash Garhwal -   CR-20210811-15348 - get lated ContentDocumentLink for MSA assignment
            //Subhash Garhwal -  CR-20210811-15348
            //MSA_Date__c = lastedContentDocument.LastModifiedDate, MSA_Link_Id__c = latestContentDocumentId, MSA_Link_File_Name__c = latestContentDocumentTitle
            //Added MSA_Proposal__r.Contracted__c in query
            for(Account acc : [SELECT Id, MSA_Date__c, MSA_Link_Id__c, MSA_Link_File_Name__c, MSA_Proposal__c, MSA_Proposal__r.Contracted__c FROM Account 
                               WHERE ID IN : setAccountIds AND MSA_Proposal__c != null AND MSA_Proposal__c IN : mapProposals.keySet()])
            {
                
                //Check MSA_Date__c date
                if(mapProposals.containsKey(acc.MSA_Proposal__c))
                {
                    
                    Boolean isChange = false;
                    /*
                    if(mapProposals.get(acc.MSA_Proposal__c).Contract_Document_Creation_Date__c != acc.MSA_Date__c) {
                    acc.MSA_Date__c = mapProposals.get(acc.MSA_Proposal__c).Contract_Document_Creation_Date__c;
                    //Populate the proposal with MSA Date.
                    listProposalstoUpdate.add( new SBQQ__Quote__c(Id = acc.MSA_Proposal__c, MSA_Date__c = acc.MSA_Date__c));
                    
                    isChange = true;
                    
                    }
                    if(mapProposals.get(acc.MSA_Proposal__c).LOA_PDF_Document_ID__c != acc.MSA_Link_Id__c || mapProposals.get(acc.MSA_Proposal__c).LOA_PDF_Document_File_Name__c != acc.MSA_Link_File_Name__c ) { 
                    acc.MSA_Link_Id__c = mapProposals.get(acc.MSA_Proposal__c).LOA_PDF_Document_ID__c;
                    acc.MSA_Link_File_Name__c = mapProposals.get(acc.MSA_Proposal__c).LOA_PDF_Document_File_Name__c;
                    isChange = true;
                    }
                    */
                    
                    if( proposalToContentDocumentMap.size() > 0 && !(acc.MSA_Proposal__r.Contracted__c && proposalToContentDocumentMap.containsKey(acc.MSA_Proposal__c) ) )
                    {
                        ContentDocumentLink contentDocumentData = proposalToContentDocumentMap.get( acc.MSA_Proposal__c );
                        if( contentDocumentData.ContentDocument.LastModifiedDate != acc.MSA_Date__c )
                        {
                            acc.MSA_Date__c = Date.valueOf(contentDocumentData.ContentDocument.LastModifiedDate);
                            //Populate the proposal with MSA Date.
                            listProposalstoUpdate.add( new SBQQ__Quote__c(Id = acc.MSA_Proposal__c, MSA_Date__c = acc.MSA_Date__c));
                            
                            isChange = true;
                        }
                        if( contentDocumentData.ContentDocumentId != acc.MSA_Link_Id__c || contentDocumentData.ContentDocument.Title != acc.MSA_Link_File_Name__c )
                        {
                            acc.MSA_Link_Id__c = contentDocumentData.ContentDocumentId;
                            acc.MSA_Link_File_Name__c = contentDocumentData.ContentDocument.Title;
                            isChange = true;
                        }
                    }
                    
                    if(isChange == true)
                        listAccountsToBeUpdate.add(acc); 
                }
            }  
            
            //Disable all triggers
            Util.BypassAllTriggers = true;
            
            //check for size
            if(listAccountsToBeUpdate.size() > 0)
            {
                //Update Account.
                update listAccountsToBeUpdate;    
            }
            
            //Update Proposals.
            if(listProposalstoUpdate.size() > 0)
                update listProposalstoUpdate;    
            
            //Enable all triggers
            Util.BypassAllTriggers = false;
        }
    }
    
    /**
     *
     *   @description    :   This used to populate Contract_Document_Creation_Date to today if LOA_PDF_Document_ID__c is changed.
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - CR-20181019-12685
     *			 :   V_1.1 - Modified By - Subhash Garhwal - CR-20210811-15348 - add condition i.e. && prop.Contracted__c != true  in the if check
     *
     **/
    public static void populateContractDocumentCreationDate(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals){
            
            //CR-20201229-14765 - Added condition to populate the Contract_Document_Creation_Date__c when the SBQQ__DocumentStatus__c = DOCUMENT_STATUS_SIGNED_MANUAL_UPLOAD
            //Check for conditions
            if(mapOldProposals != null && prop.SBQQ__Primary__c == true && prop.SBQQ__DocumentStatus__c == CPQConstants.DOCUMENT_STATUS_SIGNED_MANUAL_UPLOAD
               && (prop.LOA_PDF_Document_ID__c != mapOldProposals.get(prop.Id).LOA_PDF_Document_ID__c 
                   || prop.LOA_PDF_Document_File_Name__c != mapOldProposals.get(prop.Id).LOA_PDF_Document_File_Name__c 
                   || prop.SBQQ__DocumentStatus__c != mapOldProposals.get(prop.Id).SBQQ__DocumentStatus__c) && prop.Contracted__c != true )
                prop.Contract_Document_Creation_Date__c = System.today();
        }
    }
    
    /**
     *
     *   @description    :   This used to trigger the grading rules for a deal desk user or system admin users, if proposal is contracted.
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Mahendra Swarnkar - 08/13/2019 - CR-20181019-12685
     *
     **/
    public static void populateGradingCriteriaForContractedProposal(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Modify By - Dipesh Gupta - CR-20200102-13584 - 5/29/2020 - 
        //get the CustomPermissionsReader instance.
        /*CustomPermissionsReader cPR = Util.getCustomPermissionsReader(); 

        //Check if current user is a deal desk user(i.e isCurrentUserHasDealDeskPermission = true)  
        Boolean isCurrentUserHasDealDeskPermission = cPR.hasPermission(CPQConstants.CUSTOM_PERMISSION_CPQ_DEAL_DESK);*/
        Boolean isCurrentUserHasDealDeskPermission = FeatureManagement.checkPermission(CPQConstants.CUSTOM_PERMISSION_CPQ_DEAL_DESK);
        
        //Check If current User is a deal desk user or a system admin user
        if(isCurrentUserHasDealDeskPermission == true || (system.UserInfo.getProfileId()).containsIgnoreCase(Label.System_Admin_Profile_Id))
        {
            //Map to hold the Quotes Field set API name with Set of Fields API name in that Field set.
            Map<String, Set<String>> MapFieldSets = Util.sobjectFieldSetNameWithSetOfFieldsAPIName(CPQConstants.OBJECT_SBQQ_QUOTE);
            
            //Loop over the Proposals
            for(SBQQ__Quote__c prop : proposals)
            {
                //Check for conditions and populate the field to initiate the grading rules.
                if(mapOldProposals != null && prop.SBQQ__Primary__c == true && prop.Contracted__c == true)
                {
                    //boolean flag to check if calculating fields in the Field set "SBQQ__CalculatingFields" on Quote is changes or not.
                    Boolean isCalculatingFieldValueChange = false;
                    
                    //Set the flag to true, if calculating fields in the Field set "SBQQ__CalculatingFields" on Quote is changes
                    if(MapFieldSets.size() > 0 && MapFieldSets.containsKey(CPQConstants.FIELD_SET_QUOTE_CALCULATING_FIELDS) &&  MapFieldSets.get(CPQConstants.FIELD_SET_QUOTE_CALCULATING_FIELDS).size() > 0)
                    {
                        //Loop over the ffields in the Field set "SBQQ__CalculatingFields" on Quote
                        for(String calField : MapFieldSets.get(CPQConstants.FIELD_SET_QUOTE_CALCULATING_FIELDS))
                        {
                            //check for value change and set the flag
                            if(prop.get(calField) != mapOldProposals.get(prop.Id).get(calField)){
                                isCalculatingFieldValueChange = true;
                            } 
                            
                        }     
                    }
                    
                    // Check for condition and then populate the field
                    if(isCalculatingFieldValueChange) 
                        prop.Is_Checked_For_Invoicing_Grade__c = true;
                    
                }    
            }
        }
    }
    
    /**
     *
     *   @description    :   This is used to populate the Standard Pricebook on the created proposal.
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal 
     *
     **/
    public static void populateStandardPriceBookOnProposal(List<SBQQ__Quote__c> proposals){
        
        //Query to get standard Pricebook.
        List<Pricebook2> standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 Where IsStandard = true Limit 1];
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            if(!Test.isRunningTest()) {
                prop.SBQQ__PriceBook__c = standardPricebook[0].Id;
                prop.SBQQ__PricebookId__c = standardPricebook[0].Id;    
            }else{
                prop.SBQQ__PriceBook__c = test.getStandardPricebookId();
                prop.SBQQ__PricebookId__c = test.getStandardPricebookId();
            }
            
        }
    }
    
    /**
     *
     *   @description    :   This is used to populate the MSA details on the proposal(Insert case).
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Mahendra Swarnkar - CR-20190911-13329 - 09/25/2019
     *
     **/
    public static void populateMSADetailsFromInstitution(List<SBQQ__Quote__c> proposals) {
        
        //Set Proposal Proposal Ids
        Set<Id> setProposalIds = new Set<Id>();
        
        //Loop over the proposal records
        for( SBQQ__Quote__c proposal : proposals)
        {
            //Populate the set
            if(proposal.SBQQ__Account__c != null)
            {
                setProposalIds.add(proposal.Id);
            }
        }
        
        //Chec for size
        if(setProposalIds.size() > 0)
        {
            //List Proposals to be updated
            List<SBQQ__Quote__c> proposalsToBeUpdate = new List<SBQQ__Quote__c>();
            
            //Query over the proposal records 
            for(SBQQ__Quote__c prop : [Select Id, SBQQ__Account__c, SBQQ__Account__r.MSA_Date__c, Member_Template__c From SBQQ__Quote__c Where ID IN : setProposalIds AND SBQQ__Account__r.MSA_Date__c != null]){
                
                //Check for conditions
                if(prop.SBQQ__Account__c != null && prop.SBQQ__Account__r.MSA_Date__c != null )
                {
                    //Populate the List
                    proposalsToBeUpdate.add(new SBQQ__Quote__c(Id = prop.Id, MSA_Date__c = prop.SBQQ__Account__r.MSA_Date__c));    
                }
            }
            
            //Check for size
            if(proposalsToBeUpdate.size() > 0)
            {
                
                //Disable all the trigger execution
                Util.BypassAllTriggers = true;
                
                //Update the Proposals
                update proposalsToBeUpdate;
                
                //Enable the triggers
                Util.BypassAllTriggers = false;
            }
        }
    }

    /**
     *
     *   @description    :   This is used to populate the Status field on quote.
     * 						Address the below mentioned automations:- 
     * 						a) Process Builder : "Quote Approval Status and Recordtype Changes (Quote_Line_Lock_when_Quote_Record_Changes - version 7)"
     * 						b) Workflow Rule : "Quote - Approval Status Approved"
     * 						c) Workflow Rule : "Quote - Approval Status RejectedorRecalled" 	
     *							
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - - 02/05/2020 - CR-20200204-13688
     *                       V_1.1 - Modified - Colin McGloin - 06/01/2020 - CR-20200518-14066 - Modified logic so that it does not run if the record has been marked as Locked (logic was overriding Document Status - Lock Proposal & Lines PB)
     *
     **/
    public static void populateStatusOnProposal(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        Map<String, Id> mapRecordTypeLabelWithId = Util.recordtypemap('SBQQ__Quote__c');
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            //Added by Colin McGloin - 06/01/2020
            if (prop.SBQQ__Status__c != CPQConstants.PROPOSAL_STATUS_LOCKED)
            {
                // Addresses the Workflow Rule : "Quote - Approval Status Approved"
                //for Approved
                if(prop.ApprovalStatus__c == CPQConstants.PROPOSAL_STATUS_APPROVED)
                {
                    //Set Status and Recod Type
                    prop.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_APPROVED;
                    prop.RecordTypeId = mapRecordTypeLabelWithId.get('Approved Quote');
                    prop.SBQQ__WatermarkShown__c = false;
                }    
                
                // Addresses the Workflow Rule : "Quote - Approval Status RejectedorRecalled"
                //for Rejected/Recalled
                if(prop.ApprovalStatus__c == CPQConstants.PROPOSAL_STATUS_REJECTED)
                {
                    //Set Status and Recod Type
                    prop.RecordTypeId = mapRecordTypeLabelWithId.get('Open');
                    prop.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_REJECTED;
                    prop.SBQQ__WatermarkShown__c = true;
                }
                
                if(prop.ApprovalStatus__c == CPQConstants.PROPOSAL_STATUS_RECALLED)
                {
                    //Set Status and Recod Type
                    prop.RecordTypeId = mapRecordTypeLabelWithId.get('Open');
                    prop.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_DRAFT;
                    prop.SBQQ__WatermarkShown__c = true;
                }
                
                // Addresses the Process Builder : "Quote_Line_Lock_when_Quote_Record_Changes - version 7"
                //for Pending
                if(prop.ApprovalStatus__c == CPQConstants.PROPOSAL_STATUS_PENDING)
                {
                    //Set Status and Recod Type
                    prop.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_IN_REVIEW;
                    prop.RecordTypeId = mapRecordTypeLabelWithId.get('In Review');
                    prop.SBQQ__WatermarkShown__c = true;
                    
                }
                
                if(String.isBlank(prop.ApprovalStatus__c) || prop.ApprovalStatus__c == CPQConstants.PROPOSAL_APPROVAL_STATUS_DRAFT || prop.ApprovalStatus__c == CPQConstants.PROPOSAL_APPROVAL_STATUS_OPEN)
                {
                    //Set Status and Recod Type
                    prop.RecordTypeId = mapRecordTypeLabelWithId.get('Open');
                    prop.SBQQ__Status__c = CPQConstants.PROPOSAL_STATUS_DRAFT;  
                }
            }
        }
    }
    
    /**
     *
     *   @description    :   This is used to Addresses the Process Builder : "Quote_Line_Lock_when_Quote_Record_Changes - version 7".
     *
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 02/05/2020 - CR-20200204-13688
     *
     **/
    public static void populateAmendmentTypeOnContract(List<SBQQ__Quote__c> newProposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        //Set of proposal Ids
        Set<Id> setContractIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : newProposals)
        {
            //Check for conditions
            if(prop.SBQQ__MasterContract__c != null && String.isNotBlank(prop.SBQQ__Type__c) && prop.SBQQ__EndDate__c != null 
               && (mapOldProposals == null || prop.SBQQ__MasterContract__c != mapOldProposals.get(prop.Id).SBQQ__MasterContract__c 
                   || prop.SBQQ__Type__c != mapOldProposals.get(prop.Id).SBQQ__Type__c || prop.SBQQ__EndDate__c != mapOldProposals.get(prop.Id).SBQQ__EndDate__c) )
            {
                //Populate the Set
                setContractIds.add(prop.SBQQ__MasterContract__c); 
            }
        }
        
        //Check for Size
        if(setContractIds.size() > 0)
        {
            // Map to hold the contracts 
            Map<Id,contract> mapContracts = new Map<Id, Contract>();
            for(Contract masterContract : [Select Id, Amendment_Type__c, EndDate From Contract where Id IN : setContractIds ]) {
                mapContracts.put(masterContract.Id, masterContract);
            }
            
            //Check for size
            if(mapContracts.size() > 0)
            {
                //List TO hols the Contract to update
                List<Contract> listContractTupdate = new List<Contract>();
                
                //Loop over the Proposals
                for(SBQQ__Quote__c prop : newProposals)
                {
                    //Check for Conditions to populate the Ammendment type on the Contract
                    if(String.isNotBlank(prop.SBQQ__Type__c) && prop.SBQQ__Type__c == 'Amendment' 
                       && prop.SBQQ__MasterContract__c != null
                       && mapContracts.containsKey(prop.SBQQ__MasterContract__c) 
                       && String.isNotBlank(mapContracts.get(prop.SBQQ__MasterContract__c).Amendment_Type__c)
                       && mapContracts.get(prop.SBQQ__MasterContract__c).Amendment_Type__c != 'Amend & Extend'
                       && prop.SBQQ__EndDate__c != null && mapContracts.get(prop.SBQQ__MasterContract__c).EndDate != null
                       && prop.SBQQ__EndDate__c != mapContracts.get(prop.SBQQ__MasterContract__c).EndDate)
                    {
                        listContractTupdate.add(new Contract(Id = prop.SBQQ__MasterContract__c, Amendment_Type__c = 'Amend & Extend'));
                    }   
                }
                //Check for Size
                if(listContractTupdate.size() > 0 )
                {
                    //Update
                    update listContractTupdate;
                }	
            }
        }
    }
    
    /**
     *
     *   @description    :   This is used to populate the Invoice frequency for Amended proposals from the original proposal 	
     *							
     *   @args           :   List<SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 03/05/2020 - CR-20200210-13716
     *
     **/
    public static void populateAmendedProposalFieldsFromOriginalProposal(List<SBQQ__Quote__c> proposals){
        
        //Set to Hold the Amended Opporrtunity Ids
        Set<Id> setAmendedOpportunityIds = new Set<Id>();
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            //Check of Proposal is an Amended proposal 
            if(String.isNotBlank(prop.SBQQ__Type__c) && prop.SBQQ__Type__c == 'Amendment' && prop.SBQQ__Opportunity2__c != null)
            {
                //Populate the Set
                setAmendedOpportunityIds.add(prop.SBQQ__Opportunity2__c);
            }
        }
        
        //Check for size
        if(setAmendedOpportunityIds.size() > 0)
        {
            //Map to hold the Ammended Opportunity Id with Origional Proposal values
            Map<Id, SBQQ__Quote__c> mapOpportunityIdWithOriginalProposal = new Map<Id, SBQQ__Quote__c>();
            
            // get the opportunity records 
            for(Opportunity opp : [SELECT Id, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.SBQQ__Quote__c, 
                                   SBQQ__AmendedContract__r.SBQQ__Quote__r.Invoice_Frequency__c, SBQQ__AmendedContract__r.SBQQ__Quote__r.Is_Enrollment_Services__c
                                   FROM Opportunity 
                                   WHERE ID IN : setAmendedOpportunityIds 
                                   AND SBQQ__AmendedContract__c != null AND SBQQ__AmendedContract__r.SBQQ__Quote__c != null ])
            {
                //Check for conditions.
                if(opp.SBQQ__AmendedContract__c != null && opp.SBQQ__AmendedContract__r.SBQQ__Quote__c != null)
                {
                    
                    mapOpportunityIdWithOriginalProposal.put(opp.Id, new SBQQ__Quote__c(Id = opp.SBQQ__AmendedContract__r.SBQQ__Quote__c, 
                                                                                        Invoice_Frequency__c = opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Invoice_Frequency__c,
                                                                                        Is_Enrollment_Services__c  = opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Is_Enrollment_Services__c
                                                                                       ));
                }
            }
            
            //Check for size
            if(mapOpportunityIdWithOriginalProposal.size() > 0)
            {
                //Loop over the new proposal list
                for(SBQQ__Quote__c propos : proposals)
                {
                    //Check of Proposal is an Amended proposal 
                    if(String.isNotBlank(propos.SBQQ__Type__c) && propos.SBQQ__Type__c == 'Amendment' && propos.SBQQ__Opportunity2__c != null 
                       && mapOpportunityIdWithOriginalProposal.containsKey(propos.SBQQ__Opportunity2__c) && mapOpportunityIdWithOriginalProposal.get(propos.SBQQ__Opportunity2__c) != null) 
                    {
                        //Get the original Proposal record
                        SBQQ__Quote__c originalProposal = mapOpportunityIdWithOriginalProposal.get(propos.SBQQ__Opportunity2__c);
                        
                        //Check if Invoice frequency is not the same as on the original proposal, then update the invoice frequency
                        if(propos.Invoice_Frequency__c != originalProposal.Invoice_Frequency__c)
                        {
                            propos.Invoice_Frequency__c = originalProposal.Invoice_Frequency__c;
                            propos.Is_Enrollment_Services__c = originalProposal.Is_Enrollment_Services__c;
                        }
                    }
                }
            }
        }
    }
    
    /**
     *
     *   @description    :   This is used to validate the proposal status/record Type/Approval status missmatch. 	
     *							
     *   @args           :   List<SBQQ__Quote__c>, Map<Id, SBQQ__Quote__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V_1.0 - Created - Subhash Garhwal - 03/30/2020 - 
     *                       V_1.1 - Modified By - Colin McGloin - 06/01/2020 - CR-20200518-14066 - Modified so that it allows Locked records to proceed through
     *
     **/
    public static void validateStatusOnProposal(List<SBQQ__Quote__c> proposals, Map<Id, SBQQ__Quote__c> mapOldProposals){
        
        Map<String, Id> mapRecordTypeLabelWithId = Util.recordtypemap('SBQQ__Quote__c');
        
        //Loop over the Proposals
        for(SBQQ__Quote__c prop : proposals)
        {
            //Added by Colin McGloin - CR-20200518-14066
            if(prop.SBQQ__Status__c != CPQConstants.PROPOSAL_STATUS_LOCKED &&
               (prop.ApprovalStatus__c == 'Approved' && prop.SBQQ__Status__c != 'Approved' && prop.RecordTypeId != mapRecordTypeLabelWithId.get('Approved Quote'))
               || (prop.ApprovalStatus__c == 'Rejected' && prop.SBQQ__Status__c != 'Rejected' && prop.RecordTypeId != mapRecordTypeLabelWithId.get('Open'))
               || (prop.ApprovalStatus__c == 'Recalled' && prop.SBQQ__Status__c != 'Draft' && prop.RecordTypeId != mapRecordTypeLabelWithId.get('Open'))
               || (prop.ApprovalStatus__c == 'Pending' && prop.SBQQ__Status__c != 'In Review' && prop.RecordTypeId != mapRecordTypeLabelWithId.get('In Review')))
            {
                String errorMessage;
                
                if(prop.ApprovalStatus__c == 'Approved')
                    errorMessage = CPQConstants.mapApprovalStatusWithErrorMessage.get('Approved');
                
                if(prop.ApprovalStatus__c == 'Rejected')
                    errorMessage = CPQConstants.mapApprovalStatusWithErrorMessage.get('Rejected');
                
                if(prop.ApprovalStatus__c == 'Recalled')
                    errorMessage = CPQConstants.mapApprovalStatusWithErrorMessage.get('Recalled');
                
                if(prop.ApprovalStatus__c == 'Pending')
                    errorMessage = CPQConstants.mapApprovalStatusWithErrorMessage.get('Pending');
                
                if(String.isNotBlank(errorMessage) )
                    prop.addError(errorMessage);
            }
        }
    }
	
    /**
     * 
     *   @description    :   Auto-populates invoiceArrangement on quoteLine so it's transferred to subscription and can be used in billing sched creation 
     *
     *   @args           :   List<SBQQ__QuoteLine__c>
     *
     *   @return         :   void
     *
     *   @revision Log   :   V1.0 - Created - 12/13/2019 - Victor Hanson - CR-20191030-13484
     * 
     **/
    public static void populateInvoicingArrangement(Map<Id, SBQQ__Quote__c> quotes, Map<Id, SBQQ__Quote__c> oldQuoteMap)
    {
        Set<Id> setProposalIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> qlsToUpdate =  new List<SBQQ__QuoteLine__c>();
        
        //Loop over the Proposal Line
        for(SBQQ__Quote__c q : quotes.values())
        {
            //get the old quote
            SBQQ__Quote__c oldQuote;
            if (oldQuoteMap != null)
                oldQuote = oldQuoteMap.get(q.Id);
            
            if (oldQuote != null && q.Invoice_Frequency__c != null && q.Invoice_Frequency__c != oldQuote.Invoice_Frequency__c)
            {
                setProposalIds.add(q.Id);
            }
            
        }
        
        //Check for set size
        if(setProposalIds.size() > 0)
        {
            //Map to hold the quoteLines
            List<SBQQ__QuoteLine__c> quoteLines = [Select Id, Invoicing_Arrangement__c, SBQQ__Quote__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c IN : setProposalIds];
            
            //Loop over the Proposal Line
            for(SBQQ__QuoteLine__c pL : quoteLines)
            {
                //VH 12/13/2019 - added to set invoicing arrangement field on main quoteLine so it transfers to Program Subscription
                SBQQ__Quote__c quote = quotes.get(pL.SBQQ__Quote__c);
                if (quote != null)
                {
                    pL.Invoicing_Arrangement__c = quote.Invoice_Frequency__c;
                    qlsToUpdate.add(pL);
                }
            }
            
            //bypass triggers and update quote lines
            util.bypassAllTriggers = true;
            update qlsToUpdate;
            util.bypassAllTriggers = false;
        }
    }
    
    //Modified By - Subhash Garhwal - CR-20210521-15175
    public static void populateIActiveSTRCO(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuoteMap)
    {
        Set<ID> setAcccountIds = new Set<ID>();
        
        for(SBQQ__Quote__c quote : newQuotes)
        {
            if(quote.SBQQ__Account__c != null )
            {
                setAcccountIds.add(quote.SBQQ__Account__c);
            }
        }
        
        if(setAcccountIds.size() > 0)
        {
            Map<Id, Boolean> mapAccountIdWithIsActiveSTRCOprogramSubscription = new Map<Id, Boolean>(); 
            
            for(SBQQ__Subscription__c subs : [Select ID, Active_Subscription__c, Status__c, SBQQ__Account__c 
                                              From SBQQ__Subscription__c
                                              Where SBQQ__Account__c != null AND SBQQ__Account__c IN : setAcccountIds
                                              AND Active_Subscription__c = true
                                              AND Status__c NOT IN ('Void', 'Closed', 'Dropped', 'Offered', 'Expired', 'Void-Amended')
                                              AND SBQQ__Product__c != null AND SBQQ__Product__r.ProductCode = 'STRCO'])
            {
                mapAccountIdWithIsActiveSTRCOprogramSubscription.put(subs.SBQQ__Account__c, true);
            }
            
            if(mapAccountIdWithIsActiveSTRCOprogramSubscription.size() > 0)
            {
                for(SBQQ__Quote__c quot : newQuotes)
                {
                    if(quot.SBQQ__Account__c != null && mapAccountIdWithIsActiveSTRCOprogramSubscription.containsKey(quot.SBQQ__Account__c)
                       && mapAccountIdWithIsActiveSTRCOprogramSubscription.get(quot.SBQQ__Account__c) == true )
                    {
                        quot.IS_Active_STRCO__c = true;
                    }
                }
            }
        }
    }   

}