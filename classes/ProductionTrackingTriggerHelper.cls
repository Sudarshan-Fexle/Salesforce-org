/**
    *   Description     :   This is helper class for ProductionTrackingTrigger. Class contains the logic to handle functionalities on Production Tracking object.
    
    *   Created by      :   Dipesh Gupta
    *
    *   Created Date    :   02/14/2020
    *
    *   Revision Log    :   V1.0 - Created  - CR-20200128-13670
    *			    V1.1 - Modified - CR-20200211-13722 - Victor Hanson - added logic to support identification of digital printer
    *			    V1.2 - Modified - CR-20200304-13828 - 04/07/2020 - Victor Hanson - populateActiveProductionTracking & callouts to vendor
    *			    V1.3 - Modified - CR-20200221-13792 - 04/27/2020 - Dipesh Gupta - Added a new method - updateJobTicket 
    *			    V1.4 - Modified - CR-20200515-14047 - 05/18/2020 - Victor Hanson - updated callout methods to work with artifactWrapper
    *			    V1.5 - Modified - CR-20200521-14079 - 05/22/2020 - Dipesh Gupta - Add Suppression File field on Production Tracking
    *			    V1.6 - Modified - CR-20200527-14113 - 05/27/2020 - Victor Hanson - Added reference to Suppression List when sending Live Proof-Submitted callout
    *			    V1.7 - Modified - CR-20200527-14113 - 05/28/2020 - Victor Hanson - Major changes to checkReadyForProof & checkReadyForLiveProof
    *			    V1.8 - Modified - CR-20200529-14122 - 05/29/2020 - Victor Hanson - Updated checkReadyForLiveProof, checkReadyForPrint, checkApproved methods to inlude status and detail
    *			    V1.9 - Modified - CR-20200601-14128 - 06/01/2020 - Victor Hanson - Improved error logging, updated how artifacts are queried
    *			    V2.0 - Modified - CR-20200603-14137 - 06/03/2020 - Victor Hanson - updated fileName to Target File Name on getArtifactTransfer
    *			    V2.1 - Modified - CR-20200619-14206 - 06/19/2020 - Victor Hanson - added custom token authorization to sendCallout() method
    *			    V2.2 - Modified - CR-20200624-14220 - 06/23/2020 - Victor Hanson - added 'Bearer ' to authentication header in SendCallout() method
    *			    V2.3 - Modified - CR-20200611-14176 - 06/29/2020 - Victor Hanson - added updateProductionTrackingFields
    *			    V2.4 - Modified - CR-20200616-14191 - 06/19/2020 -  Dipesh Gupta - created
    *                       V2.5 - Modified - CR-20200812-14419 - 08/14/2020 - Victor Hanson
    *			    V2.6 - Modified - CR-20200717-14331 - 07/31/2020 - Abhinav Sharma - Created
    *			    V2.7 - Modified - CR-20200817-14438 - Abhinav Sharma - Created
    *			    V2.8 - Modified - CR-20200928-14562 - 09/28/2020 - Victor Hanson - updated getAuthToken with custom headers
    *			    V2.9 - Modified - CR-20201012-14597 - 11/12/2020 - Victor Hanson - added logic to support proof generation internal
    *			    V3.0 - Modified - CR-20210322-15011 - 04/1/2020 - Neha Sharma
    *			    V3.1 - Modified - CR-20210625-15252 - 06/28/2021 - Mahendra Swarnkar 
    *			    V3.2 - Modified - CR-20210420-15089 - 04/21/2021 - Victor Hanson 
    *			    V3.3 - Modified - CR-20210310-14983 - 05/12/2021 - Abhinav Sharma
    *			    V3.4 - Modified - CR-20210524-15178 - 06/04/2021 - Abhinav Sharma - Add "inventoryTransactions" details
    *			    V3.5 - Modified - CR-20210423-15103 - 07/28/2021 - Shalu Sharma - Print MIS Sandbox Endpoints
    *			    V3.6 - Modified - CR-20210830-15393 - 08/31/2021 - Abhinav Sharma - Suppression List Artifact not getting populated in Live Proof Submitted Service
    *			    V3.7 - Modified - CR-20210902-15403 - 09/22/2021 - Abhinav Sharma 
    *			    V3.8 - Modified - CR-20210916-15441 - 10/01/2021 - Nikita Kumari - added new method populatePostageClassOnPT.
    *			    V3.9 - Modified - CR-20210924-15459 - 10/04/2021 - Shalu Sharma - Added a new methods  "populateMailshopPTStatusOnInventoryTransaction", "createInventoryAndTransForPrintPT" and "checkInventroyAssociatedWithPT"
    *			    V4.0 - Modified - CR-20210920-15450 - 10/25/2021 - Subhash - Added calling new mehtod "unLockProductionTrackingRecordOnBackTracking"
    *		    	    V5.0 - Modified - CR-20220428-16145 - 04/28/2022 - Shalu Sharma - Added new method i.e. getAuthTokenForColorArtVendor() to get token for the ColorArt Vendor
    */
public without sharing class ProductionTrackingTriggerHelper 
{
    public static boolean isDueDateUpdated = false;
    
    //11/04/2020 - CR-20201012-14597 - Victor Hanson - added static variables
    @TestVisible private static boolean artifactGenerationHasExecuted = false;
    private static boolean readyForPrintHasExecuted = false;
    private static boolean readyForProofHasExecuted = false;
    private static boolean readyForLiveProofHasExecuted = false;
    private static boolean mailDateConfirmedHasExecuted = false;
    private static boolean checkMailDateConfirmationHasExecuted = false;
    private static boolean readyForPrintApprovedHasExecuted = false;
    public static final String PROOF_GENERATION_INTERNAL = 'Internal'; //internal xmpie
    public static final String PROOF_GENERATION_EXTERNAL = 'External'; //external (cenveo / sepire)
    public static final String COMMAND_PROOF_SUBMITTED = 'proofSubmitted';
    public static final String COMMAND_PROOF_APPROVED = 'proofApproved';
    public static final String COMMAND_LIVE_PROOF_SUBMITTED = 'liveProofSubmitted';
    public static final String COMMAND_LIVE_PROOF_APPROVED = 'liveProofApproved';
    public static final String COMMAND_READY_FOR_PRINT_APPROVED = 'readyForPrintApproved';
    public static final String COMMAND_MAIL_DATE_CONFIRMATION_REQUEST = 'mailDateConfirmationRequest';
    public static final String COMMAND_MAIL_DATE_CONFIRMED = 'mailDateConfirmed';
    
    //04/21/2021 - CR-20210420-15089 - Victor Hanson - added inventory commands
    public static final String COMMAND_INVENTORY_PROOF_SUBMITTED = 'inventoryProofSubmitted';
    public static final String COMMAND_INVENTORY_READY_FOR_PRINT_APPROVED = 'inventoryReadyForPrintApproved';
    public static final String COMMAND_INVENTORY_TRANSFER_REQUEST = 'inventoryTransferRequest';
    public static final String COMMAND_INVENTORY_SHIPPED_NOTIFICATION = 'inventoryShippedNotification';
    public static final String PRODUCTION_TRACKING_RT_DEV_NAME_PRINT = 'Print';
    public static final String PRODUCTION_TRACKING_RT_ID_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get(PRODUCTION_TRACKING_RT_DEV_NAME_PRINT).getRecordTypeId();
    
    // Modified By Mahendra Swarnkar - CR-20210625-15252 - 28/June/2021
    public static Boolean EXECUTE_TRIGGER_CALLOUT_AFTER_INSERT_OR_UPDATE = true;
    public static Boolean EXECUTE_TRIGGER_CALLOUT_BEFORE_UPDATE = true; 
    
    //Added - CR-20210924-15459 - 10/04/2021 - Shalu Sharma
    public static final Id PRODUCTION_TRACKING_RT_ID_MAIL_SHOP = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
    public static final Id CURRENT_LOGIN_USER_ID = UserInfo.getUserId();
    public static boolean createInventoryAndTransForPrintPTHasExecuted = false;
    public static final String COMMAND_ADD_NEW_INVENTORY = 'AddNewInventory';    
    
    public static Map<String, String> mapCommandToInternalEndpoint = new Map<String, String> 
    {
        COMMAND_PROOF_SUBMITTED => '/proofing',
        COMMAND_PROOF_APPROVED => '/proofing',
        COMMAND_LIVE_PROOF_SUBMITTED => '/live_proofing',
        COMMAND_MAIL_DATE_CONFIRMED => '/live_proofing',
        COMMAND_READY_FOR_PRINT_APPROVED => '/ready_print'
    };
    
    public static final String RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING = Schema.SObjectType.Web_Service_Log__c.getRecordTypeInfosByDeveloperName().get('Production_Tracking').getRecordTypeId();
    
    //Added By - Shalu Sharma - 04/28/2022 - CR-20220428-16145
    public final static Set<String> COLORART_METADATA_NAMES = new Set<String>{'Cenveo_Print_Endpoint_UAT','Cenveo_Print_Endpoint'};

   /**
    *  Purpose         :    check if Status Detail has been set to Pending Mail Date Confirmation
    *
    *  Revision Logs   :    V_1.0 - Created - 11/23/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void checkMailDateConfirmationRequest(List<Production_Tracking__c> pTrackings, Map<Id, Production_Tracking__c> mapOldPTracking) 
    {
        //only send callout once per invocation
        if (checkMailDateConfirmationHasExecuted) 
        {
            return;
        }
        
        //check if any records fit the criteria
        for (Production_Tracking__c pt : pTrackings) 
        {
            Production_Tracking__c oldPT;
            if (mapOldPTracking != null) oldPT = mapOldPTracking.get(pt.Id);
            
            //check if Status Detail has changed to Pending Mail Date Confirmation & Proof Generation = Internal
            if (oldPT != null && 
                pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION &&
                pt.Status_Detail__c != oldPT.Status_Detail__c
                && pt.Proof_Generation__c == PROOF_GENERATION_INTERNAL) 
            {
                sendMailDateConfirmationRequest(pt, pt.Proof_Generation__c);
                
                //prevent duplicate callouts
                checkMailDateConfirmationHasExecuted = true;
            }
        }
    }
    
   /**
    *  Purpose         :    Sends a callout to AWS when Status Detail = Pending Mail Date Confirmation and the Vendor Mail Date is populated or updated.
    *
    *  Revision Logs   :    V_1.0 - Created - 11/23/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void sendMailDateConfirmationRequest(Production_Tracking__c pTracking, String proofGeneration) 
    {
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(new List<Production_Tracking__c>{pTracking});
        
        //get job ticket details
        List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
        
        if (jTickets.size() > 0) 
        {
            //send each job ticket and artifacts transfer to the future method for vendor callout
            for (Job_Ticket__c jt : jTickets) 
            {
                //get the json body
                Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                
                //send callout & write response back to web service log
                sendCallout(pTracking.Id, JSON.serialize(deserializedJT, false), COMMAND_MAIL_DATE_CONFIRMATION_REQUEST, PROOF_GENERATION_EXTERNAL);
                
            }
        }
    }
    
   /**
    *  Purpose         :    check if vendor mail date was updated while status detail = pending mail date confirmation
    *
    *  Revision Logs   :    V_1.0 - Created - 11/23/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void checkMailDateConfirmed(List<Production_Tracking__c> pTrackings, Map<Id, Production_Tracking__c> mapOldPTracking) 
    {
        //check if any records fit the criteria
        for (Production_Tracking__c pt : pTrackings) 
        {
            Production_Tracking__c oldPT;
            if (mapOldPTracking != null) oldPT = mapOldPTracking.get(pt.Id);
            
            //check if vendor mail date has changed while status detail = pending mail date confirmation
            if (oldPT != null && 
                pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION &&
                pt.Vendor_Mail_Date__c != null && pt.Vendor_Mail_Date__c != oldPT.Vendor_Mail_Date__c) 
            {
                pt.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED;
            }
        }
    }
    
   /**
    *  Purpose         :    check if vendor mail date is populated and status detail is changed to Mail Date Confirmed.  if so, send callout
    *                       note: this has to occur in the afterInsert/afterUpdate portion of the trigger so the vendor mail date & vendor mail date formula are included
    *
    *  Revision Logs   :    V_1.0 - Created - 12/09/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void checkSendMailDateConfirmed(List<Production_Tracking__c> pTrackings, Map<Id, Production_Tracking__c> mapOldPTracking) 
    {
        if (mailDateConfirmedHasExecuted) return;
        
        //check if any records fit the criteria
        for (Production_Tracking__c pt : pTrackings) 
        {
            Production_Tracking__c oldPT;
            if (mapOldPTracking != null) oldPT = mapOldPTracking.get(pt.Id);
            
            if (oldPT != null && 
                pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED &&
                pt.Vendor_Mail_Date__c != null && pt.Status_Detail__c != oldPT.Status_Detail__c) 
            {
                sendMailDateConfirmed(pt, pt.Proof_Generation__c);
                mailDateConfirmedHasExecuted = true;
            }
        }
    }
    
   /**
    *  Purpose         :    Sends a callout to AWS when Status Detail = Pending Mail Date Confirmation and the Vendor Mail Date is populated or updated.
    *
    *  Revision Logs   :    V_1.0 - Created - 11/23/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void sendMailDateConfirmed(Production_Tracking__c pTracking, String proofGeneration) 
    {
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(new List<Production_Tracking__c>{pTracking});
        
        //get job ticket details
        List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
        
        if (jTickets.size() > 0) 
        {
            //send each job ticket and artifacts transfer to the future method for vendor callout
            for (Job_Ticket__c jt : jTickets) 
            {
                //11/13/2020 -  - Victor Hanson - when Proof Generation is Internal, send confirmation to aws
                if (proofGeneration == PROOF_GENERATION_INTERNAL) 
                {
                    //get the json body
                    Map<String, Object> deserializedJT = getJobTicketJSONWithArtifactTx(jt, mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, false);
                    
                    //send callout & write response back to web service log
                    sendCallout(pTracking.Id, JSON.serialize(deserializedJT, false), COMMAND_MAIL_DATE_CONFIRMED, PROOF_GENERATION_INTERNAL);
                }
                
            }
        }
    }
    
   /**
    *  Purpose         :    Sends a callout to AWS when Status is updated to Live Proof and Status Detail=ready for print
    *
    *  Revision Logs   :    V_1.0 - 11/13/2020 - CR-20201012-14597 - Victor Hanson - created
    *                     
    **/
    public static void checkLiveProofApproved(List<Production_Tracking__c> newProdTrackingList) 
    {
        //01/06/2021 - CR-20201012-14597 - Victor Hanson - added variable so this only runs once per invocation
        if (readyForPrintApprovedHasExecuted) return;
        
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
        
        for (Production_Tracking__c pTracking : newProdTrackingList) 
        {
            //12/03/2020 - CR-20201012-14597 - Victor Hanson - replaced dynamic soql with method
            //get job ticket details
            List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
            
            if (jTickets.size() > 0) 
            {
                //send each job ticket and artifacts transfer to the future method for vendor callout
                for (Job_Ticket__c jt : jTickets) 
                {
                    Map<String, Object> deserializedJT = getJobTicketJSONWithArtifactTx(jt, mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, false);
                    
                    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added for On Demand Job tickets only. It will add the Creative package Payload details in the request.
                    Map<String, Object> deserializedJT1 = getJobTicketJSONWithCreativePackage(jt, pTracking, deserializedJT, COMMAND_READY_FOR_PRINT_APPROVED);
                    
                    //send callout & write response back to web service log
                    sendCallout(pTracking.Id, JSON.serialize(deserializedJT1, false), COMMAND_READY_FOR_PRINT_APPROVED, pTracking.Proof_Generation__c);
                    
                    //01/06/2021 - CR-20201012-14597 - Victor Hanson - only execute once per invocation
                    readyForPrintApprovedHasExecuted = true;
                }
            }
        }
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when Status is updated to Proof and Status Detail=Submitted
    *
    *  Revision Logs   :	V_1.0 - Created - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - Modified - 05/28/2020 - CR-20200527-14113 - Victor Hanson - Modified to work with Artifact Transfer Process
    * 				V_1.2 - Modified - 11/13/2020 - pTracking - Victor Hanson - modified to work with a single prod tracking record
    *                     
    **/
    public static void checkReadyForProof(Production_Tracking__c pTracking) 
    {
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(new List<Production_Tracking__c>{pTracking});
        
        //get job ticket details
        List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
        
        if (jTickets.size() > 0) 
        {
            //send each job ticket and artifacts transfer to the future method for vendor callout
            for (Job_Ticket__c jt : jTickets) 
            { 
                //04/22/2021 - CR-20210420-15089 - Victor Hanson - added recordTypeId check so we don't accidentally send proofApproved callout on Print PT
                //11/13/2020 - CR-20201012-14597 - Victor Hanson - when Proof Generation is Internal, send art to xmpie
                //Mail Shop + Proof Generation = Internal
                if (pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL && pTracking.RecordTypeId == Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP) {
                    
                    //when Proof Generation=Internal & Status is Proof-Submitted, submit internally to xmpie
                    // Modified By Mahendra Swarnkar - CR-20210625-15252 - 28/June/2021
                    //if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED && pTracking.Mail_Shop_Vendor__c != null)
                    if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED)
                    {
                        //get the json body
                        //Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                        Map<String, Object> deserializedJT = getJobTicketJSONWithArtifactTx(jt, mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, false);
                        
                        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added for On Demand Job tickets only. It will add the Creative package Payload details in the request.
                        Map<String, Object> deserializedJT1 = getJobTicketJSONWithCreativePackage(jt, pTracking, deserializedJT, COMMAND_PROOF_SUBMITTED);
                        
                        //send callout & write response back to web service log
                        sendReadyForProof(pTracking.Id, JSON.serialize(deserializedJT1, false), PROOF_GENERATION_INTERNAL);
                    }
                    
                    // Modified By Mahendra Swarnkar - CR-20210625-15252 - 28/June/2021
                    //when Proof Generation=Internal & Status is Proof-Approved, send notification to vendor so they can prepare for this mailing
                    //if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED)
                    if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED && pTracking.Mail_Shop_Vendor__c != null)
                    {
                        //get the json body
                        Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                        
                        //send callout to Vendor & write response back to web service log
                        sendCallout(pTracking.Id, JSON.serialize(deserializedJT, false), COMMAND_PROOF_APPROVED, PROOF_GENERATION_EXTERNAL);
                    }
                }
                else 
                {
                    //get the json body
                    Map<String, Object> deserializedJT = getJobTicketJSONWithArtifactTx(jt, mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, false);
                    
                    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added for On Demand Job tickets only. It will add the Creative package Payload details in the request.
                    //Map<String, Object> deserializedJT1 = getJobTicketJSONWithCreativePackage(jt, pTracking, deserializedJT);
                    
                    //send callout & write response back to web service log
                    sendReadyForProof(pTracking.Id, JSON.serialize(deserializedJT, false), null);
                }
                
            }
        }
    }
    
   /**
    *  Purpose         :    Sends a callout to vendor when Proof-Approved
    *
    *  Revision Logs   :    V_1.0 - 01/13/2021 - CR-20200304-13828 - CR-20201012-14597 - Created
    *                     
    **/
    public static void checkProofApproved(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        for (Production_Tracking__c pTracking : newProdTrackingList) 
        {
            Production_Tracking__c oldPTracking = oldMapProductionTracking?.get(pTracking.Id);
            if (pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL 
                && pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
                && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED 
                && (pTracking.Status__c != oldPTracking.Status__c
                    || pTracking.Status_Detail__c != oldPTracking.Status_Detail__c))
            {
                checkReadyForProof(pTracking);
            }
        }
    }
    
    public static Map<String, Object> getJobTicketJSONWithArtifactTx(Job_Ticket__c jt, Map<String, Artifact_Transfer__c> mapJTArtifactTx, Production_Tracking__c pTracking, String artifactType, String transferDirection, boolean isRequired) 
    {
        List<JobTicketService.artifactWrapper> artifactWrappers = new List<JobTicketService.artifactWrapper>();
        
        //get the Artwork artifact transfer where Direction=Push
        JobTicketService.artifactWrapper aTxArtwork = getArtifactTransfer(mapJTArtifactTx, pTracking, artifactType, transferDirection, false);
        if (aTxArtwork.fileName == null) aTxArtwork.fileName = pTracking.Art_File_Name__c;
        artifactWrappers.add(aTxArtwork);
        
        //get the json body
        Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
        
        //04/21/2021 - CR-20210420-15089 - Victor Hanson - added to get inventory transactions
        //get the Inventory Transactions related to the Production Tracking record
        List<Inventory_Transaction__c> invTransactions = getInventoryTransactions(pTracking);
        if (invTransactions.size() > 0) 
        {
            deserializedJT.put('inventoryTransactions', invTransactions);
        }
        
        deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json
        return deserializedJT;
    }
    
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 
    public static Map<String, Object> getJobTicketJSONWithCreativePackage(Job_Ticket__c jt, Production_Tracking__c pTracking, Map<String, Object> deserializedJT, String command) 
    {
        if(jt.Drop_Type__c == System.Label.DROP_TYPE_ON_DEMAND)
        {
            List<String> listCreativePackageCounterIds = getCreativePackageCounterIds(pTracking);
            
            List<Recipient_Batch__c> listReceipientBatchIds = getReceipientBatchIds(pTracking);
            List<JobTicketService.RecipientBatch> listReceipientBatchIdWrapper = new List<JobTicketService.RecipientBatch>();
            
            for(Recipient_Batch__c  rBatch : listReceipientBatchIds){
                
                JobTicketService.RecipientBatch rb = new JobTicketService.RecipientBatch();
                
                rb.DataPostedQuantity = rBatch.Data_Posted_Quantity__c;
                rb.Type = rBatch.Type__c;
                rb.RecipientBatchId = (String) rBatch.Recipient_Batch_Id__c;
                
                if(command == COMMAND_PROOF_SUBMITTED) {
                    
                    if(rBatch.Type__c == Constants.BATCH_TYPE_ARTPROOF){
                        
                        listReceipientBatchIdWrapper.add(rb);
                        break;
                    }
                } else if(command == COMMAND_LIVE_PROOF_SUBMITTED && rBatch.Production_Tracking__c != null && rBatch.Production_Tracking__c == pTracking.ID) {
                    
                    if(rBatch.Type__c == Constants.BATCH_TYPE_LIVEDATA)
                        listReceipientBatchIdWrapper.add(rb);
                }
            }
            
            List<Mail_Package__c> packages = getMailPackageAndRelatedRecords(pTracking); 
            
            Map<String, JobTicketService.CreativePackage> mapCreativePackageCounter = new Map<String, JobTicketService.CreativePackage>();
            
            for(String cpCounterId : listCreativePackageCounterIds){
                
                Map<String, JobTicketService.MailPackage> mapMailPackageCounter = new Map<String, JobTicketService.MailPackage>();
                
                for (Mail_Package__c mPackage: packages) 
                {
                    Map<String, JobTicketService.PackageComponentMtM> mapPackageComponents = new Map<String, JobTicketService.PackageComponentMtM>();
                    
                    //Map<String, Object> mapPackageComponents = new Map<String, Object>();
                    if(mPackage.Package_Component_MtMs__r != null && mPackage.Package_Component_MtMs__r.size() > 0)
                    {
                        for(Package_Component_MtM__c pkgCompMtM : mPackage.Package_Component_MtMs__r)
                        {
                            JobTicketService.PackageComponentMtM pcMtM = new JobTicketService.PackageComponentMtM();
                            pcMtM.ComponentType = pkgCompMtM.Component_Type__c;
                            pcMtM.ComponentCode = pkgCompMtM.Component_Counter_Id__c;
                            
                            mapPackageComponents.put(pkgCompMtM.Package_Component_Counter_Id__c, pcMtM);
                            
                        }
                    }
                    
                    JobTicketService.MailPackage mailPackage = new JobTicketService.MailPackage();
                    mailPackage.MailCopyCode = mPackage.Mail_Copy__r.Mail_Copy_Counter_Id__c;
                    mailPackage.PackageComponents = mapPackageComponents;
                    
                    mapMailPackageCounter.put(mPackage.Mail_Package_Counter_Id__c, mailPackage);
                }
                
                JobTicketService.CreativePackage creativePackageInstance = new JobTicketService.CreativePackage();
                creativePackageInstance.MailPackages = mapMailPackageCounter;
                mapCreativePackageCounter.put(cpCounterId, creativePackageInstance);
            }
            
            JobTicketService.PackageMatrix packageMatrixInstance = new JobTicketService.PackageMatrix();
            packageMatrixInstance.CreativePackages = mapCreativePackageCounter;
            
            deserializedJT.put('packageMatrix', packageMatrixInstance);
            deserializedJT.put('recipientBatchIdList', listReceipientBatchIdWrapper);
        }
        return deserializedJT;
    }
    
    public static Map<String, Object> getJobTicketJSON(Job_Ticket__c jt, Production_Tracking__c pTracking) 
    {
        //get the json body
        Map<String, Object> deserializedJT = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jt, false));
        
        //add jobTicketId, ProductionTrackingId, Status, StatusDetail fields
        deserializedJT.put('jobTicketId', jt.Id);
        deserializedJT.put('productionTrackingId', pTracking.Id);
        deserializedJT.put('status', pTracking.Status__c);
        deserializedJT.put('statusDetail', pTracking.Status_Detail__c);
        return deserializedJT;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when Status is Proof and StatusDetail is Approved
    *
    *  Revision Logs   :	V_1.0 - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - 05/18/2020 - CR-20200515-14047 - Victor Hanson - updated to callout to digital vendor
    * 				V_1.2 - 11/04/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation internal/external logic
    *                     
    **/
    public static void sendReadyForProof(Id pTrackingId, String jsonBody, String proofGeneration) 
    {
        //12/09/2020 - CR-20201012-14597 - Victor Hanson - prevent duplicate sending of callout
        if (readyForProofHasExecuted) return;
        
        //04/21/2021 - CR-20210420-15089 - Victor Hanson - if this is a Print PT, command should be inventoryProofSubmitted - start
        String ptRTDevName = [SELECT Id, RecordType.DeveloperName FROM Production_Tracking__c WHERE Id = :pTrackingId]?.RecordType.DeveloperName;
        String command = COMMAND_PROOF_SUBMITTED;
        
        if (ptRTDevName == PRODUCTION_TRACKING_RT_DEV_NAME_PRINT) 
        {
            command = COMMAND_INVENTORY_PROOF_SUBMITTED;
        }
        
        sendCallout(pTrackingId, jsonBody, command, proofGeneration);
        //04/21/2021 - CR-20210420-15089 - Victor Hanson - if this is a Print PT, command should be inventoryProofSubmitted - end
        
        readyForProofHasExecuted = true;
    }
    
   /**
    *  Purpose         :	Gets the authorization token for vendor
    *
    *  Revision Logs   :	V_1.1 - 06/19/2020 - CR-20200619-14206 - Victor Hanson - created
    * 				V_1.2 - 09/28/2020 - CR-20200928-14562 - Victor Hanson - updated with custom headers
    *                     
    **/
    public static String getAuthToken(API_Endpoints__mdt apiEndpoint) 
    {
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        req.setEndpoint(apiEndpoint.Authorize_Endpoint_URL__c);
        req.setMethod(Constants.HTTP_REQUEST_POST_TYPE);
        req.setTimeout(120000);
        
        //09/28/2020 - CR-20200928-14562 - Victor Hanson - removed and replaced with custom headers below
        //req.setHeader('Abp.TenantId', '15');
        
        //09/28/2020 - CR-20200928-14562 - Victor Hanson - added logic to populate headers dynamically based on custom headers
        if (apiEndpoint.Custom_Headers__c != null) {
            try {
                Map<String, String> customHeaderMap = (Map<String, String>)JSON.deserializeStrict(apiEndpoint.Custom_Headers__c, Map<String, String>.class);
                for (String headerKey : customHeaderMap.keySet()) {
                    String headerValue = customHeaderMap.get(headerKey);
                    req.setHeader(headerKey, headerValue);
                }
            }
            catch(Exception e) {
                throw new customException('Error when attempting to add custom headers.  Not valid: \'' +  + '\'');
            }
        }
        req.setHeader('Content-Type', 'application/json');
        req.setBody(apiEndpoint.Authorization_Body__c);
        res = h.send(req);
        if(!Test.isRunningTest())
        {
            authTokenWrapper tokenWrapper;
            
            //CR-20200928-14562 - 09/28/2020 - Victor Hanson - added try/catch in case there is an auth error
            try {
                tokenWrapper = (authTokenWrapper)JSON.deserialize(res.getBody(), authTokenWrapper.class);
            }
            catch(Exception e) {
                throw new customException('Error deserializing auth token:' + e.getMessage() 
                                          + '\r\n\r\nStack Trace:\r\n' + e.getStackTraceString() 
                                          + '\r\n\r\nResponse Body:\r\n' + res.getBody()
                                          + '\r\n\r\nRequest Endpoint:\r\n' + req.getEndpoint()
                                          + '\r\n\r\nRequest Body:\r\n' + req.getBody());
            }
            
            if (!tokenWrapper.success) {
                throw new customException('Authentication error:' + JSON.serialize(tokenWrapper.error));
            }
            return tokenWrapper.result.accessToken;
        }
        return null;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor
    *
    *  Revision Logs   :	V_1.1 - 05/28/2020 - CR-20200527-14113 - Victor Hanson - modified to work with the new artifact transfer process
    * 				V_1.2 - 06/01/2020 - CR-20200601-14128 - Victor Hanson - updated how response is set
    * 				V_1.3 - 06/19/2020 - CR-20200619-14206 - Victor Hanson - added custom token authorization
    * 				V_1.4 - 11/04/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation internal/external logic
    *                           V_1.5 - 04/22/2021 - CR-20210325-15027 - Victor Hanson - Modified and moved the bulk of the logic into an overloaded method (sendVendorCallout)
    *                     
    **/
    public static void sendCallout(Id pTrackingId, String jsonBody, String command, String proofGeneration) 
    {
        //11/04/2020 - CR-20201012-14597 - Victor Hanson - added proof generation
        Production_Tracking__c pTracking = [SELECT Id, Job_Ticket__c, Status__c, Status_Detail__c, Mail_Shop_Vendor__c, Proof_Generation__c
                                            FROM Production_Tracking__c WHERE Id = :pTrackingId];
        
        //04/22/2021 - CR-20210325-15027 - Victor Hanson - Modified 
        //sendVendorCallout(pTracking.Mail_Shop_Vendor__c, jsonBody, pTracking.Id, pTracking.Job_Ticket__c, null, command, proofGeneration);
        sendVendorCallout(pTracking.Mail_Shop_Vendor__c, pTracking.Id, pTracking.Job_Ticket__c, null, jsonBody, command, proofGeneration);
    }
    
    //04/22/2021 - CR-20210325-15027 - Victor Hanson - created to make callouts to specific mail shops simpler
    @future (callout=true)
    public static void sendVendorCallout(Id mailShopAccountId, Id prodTrackingId, Id jobTicketId, Id invTransactionId, String jsonBody, String command, String proofGeneration) 
    {
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        String response;
        String endpointURL;
        
        try {
            
            //04/23/2021 - CR-20210325-15027 - Victor Hanson - added code to include productiontrackingid, jobticketid, inventorytransactionid
            //11/04/2020 - CR-20201012-14597 - Victor Hanson - updates start here
            //add command to json
            Map<String, Object> deserializedJT = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            deserializedJT.put('command', command); //add command to json
            deserializedJT.put('productionTrackingId', prodTrackingId);
            deserializedJT.put('jobTicketId', jobTicketId);
            
            if (invTransactionId != null) 
            {
                deserializedJT.put('inventoryTransactionId', invTransactionId);
                
                //Added By Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - Did the special handling of School__c in root node
                deserializedJT.put('School__c', deserializedJT.get('School'));
                deserializedJT.put('Job_Ticket__c', deserializedJT.get('JobTicket'));
                
                if(deserializedJT.containsKey('School')) 
                {
                    deserializedJT.remove('School');
                }
                
                if(deserializedJT.containsKey('JobTicket')) 
                {
                    deserializedJT.remove('JobTicket');
                }
            }
            
            jsonBody = JSON.serialize(deserializedJT, false);
            
            String internalEndpointSuffix;
            String qryString = 'SELECT Id, DeveloperName, Endpoint_URL__c, Related_Record_Id__c, Authorization_Token__c,' +
                               ' Certificate_API_Name__c, Authorize_Endpoint_URL__c, Authorization_Body__c, Custom_Headers__c' +
                               ' FROM API_Endpoints__mdt WHERE ';
            
            //Added By - Shalu Sharma - 05/19/2021 - CR-20210423-15103 - Print MIS Sandbox Endpoints
            qryString += 'Instance_Type__c = \'' + (!Util.IS_PRODUCTION_INSTANCE ? Constants.INSTANCE_TYPE_UAT : Constants.INSTANCE_TYPE_PRODUCTION) + '\' AND ';
            
            //send callout to internal AWS XMPie endpoint if proof generation is Internal
            if (proofGeneration == PROOF_GENERATION_INTERNAL) 
            {
                //Added By - Shalu Sharma - 05/19/2021 - CR-20210423-15103 - Print MIS Sandbox Endpoints
                //qryString += 'DeveloperName = \'' + Label.API_Endpoint_AWS + '\'';
                qryString += 'DeveloperName = \'' + (!Util.IS_PRODUCTION_INSTANCE ? Label.API_Endpoint_AWS_XMPie_For_UAT : Label.API_Endpoint_AWS) + '\'';
                
                //get the internal endpoint suffix based on the command
                internalEndpointSuffix = mapCommandToInternalEndpoint.get(command);
            }
            else
                qryString += 'Related_Record_Id__c = \'' + mailShopAccountId + '\'';
            
            //Based on the mail shop vendor, determine callout credentials for vendor
            List<API_Endpoints__mdt> apiEndpoints = database.query(qryString);
            //11/04/2020 - CR-20201012-14597 - Victor Hanson - updates end here
            
            if (apiEndpoints.size() > 0) {
                
                //get token
                String customAuthToken;
                if (apiEndpoints[0].Authorize_Endpoint_URL__c != null) {
                    //Modified By - Shalu Sharma - 04/28/2022 - CR-20220428-16145 - Get Token Based Request Additional Changes for the ColorArt Vendor
                    //customAuthToken = getAuthToken(apiEndpoints[0]);
                    customAuthToken = !COLORART_METADATA_NAMES.contains(apiEndpoints[0].DeveloperName) ? getAuthToken(apiEndpoints[0]) : getAuthTokenForColorArtVendor(apiEndpoints[0]);
                    if (customAuthToken != null) {
                        //06/23/2020 - CR-20200624-14220 - Victor Hanson - Added Bearer to authentication header
                        apiEndpoints[0].Authorization_Token__c = 'Bearer ' + customAuthToken;
                    }
                }
                
                //11/13/2020 - CR-20201012-14597 - Victor Hanson - added logic to populate headers dynamically based on custom headers
                if (apiEndpoints[0].Custom_Headers__c != null) {
                    try {
                        Map<String, String> customHeaderMap = (Map<String, String>)JSON.deserializeStrict(apiEndpoints[0].Custom_Headers__c, Map<String, String>.class);
                        for (String headerKey : customHeaderMap.keySet()) {
                            String headerValue = customHeaderMap.get(headerKey);
                            req.setHeader(headerKey, headerValue);
                        }
                    }
                    catch(Exception e) {
                        throw new customException('Error when attempting to add custom headers.  Not valid: \'' +  + '\'');
                    }
                }
                req.setHeader('Content-Type', 'application/json');
                
                //11/04/2020 - CR-20201012-14597 - Victor Hanson - add endpointURL & add suffix to endpoint if applicable
                endpointURL = apiEndpoints[0].Endpoint_URL__c;
                if (internalEndpointSuffix != null) endpointURL += internalEndpointSuffix;
                req.setEndpoint(endpointURL);
                req.setMethod(Constants.HTTP_REQUEST_POST_TYPE);
                req.setTimeout(120000);
                if (apiEndpoints[0].Certificate_API_Name__c != null)
                    req.setClientCertificateName(apiEndpoints[0].Certificate_API_Name__c);
                
                //11/13/2020 - CR-20201012-14597 - Victor Hanson - check for null
                if (apiEndpoints[0].Authorization_Token__c != null) {
                    req.setHeader('Authorization', apiEndpoints[0].Authorization_Token__c); 
                }
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBody(jsonBody);
                res = h.send(req);
            }
            else {
                throw new customException('No API Endpoint where Related Record Id = \'' + mailShopAccountId + '\'');
            }
            
            //V_1.2 - 06/01/2020 - CR-20200601-14128 - Victor Hanson - updated how response is set
            //set response as the response callout body
            response = res.getBody();
            
	    //Commented By - CR-20210924-15459 - 10/04/2021 - Shalu Sharma
            //Modified By - CR-20210310-14983 - 05/12/2021 - Abhinav Sharma - updated sendVendorCallout method to have a logic 
            //and this is when InventoryTransferRequest callout is sent successfully, the status on the Inventory 
            //Transaction record should be set to Transfer Requested
            //Start from here
            /*if(String.isNotBlank(command) && command.equalsIgnoreCase(COMMAND_INVENTORY_TRANSFER_REQUEST)) 
            {
                if(invTransactionId != null && res != null && res.getStatusCode() == 200) 
                {
                    Inventory_Transaction__c inventoryTxn = new Inventory_Transaction__c();
                    inventoryTxn.Id = invTransactionId;    
                    inventoryTxn.Status__c = JobTicketService.INVENTORY_TRANSACTION_STATUS_TRANSFER_REQUESTED;
                    update inventoryTxn;
                }
            }*/
            //End here
        }
        catch (exception e) {
            response = e.getMessage() + '\r\n\r\n' + e.getStackTraceString();
        }
        
        //11/13/2020 - CR-20201012-14597 - Victor Hanson - add url & modified web service method
        //create web service log
        Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,
                                                                  Job_Ticket__c = jobTicketId,
                                                                  Production_Tracking__c = prodTrackingId,
                                                                  Inventory_Transaction__c = invTransactionId,
                                                                  Web_Service_Method__c = command,
                                                                  Request_Sent__c = system.now(),
                                                                  Request_Message_Log__c = JSON.serializePretty(JSON.deserializeUntyped(jsonBody), false),
                                                                  Response_Message__c = String.valueOf(res.getStatusCode()),
                                                                  Response_Message_Log__c = response,
                                                                  Requested_By__c = UserInfo.getUserName(),
                                                                  URL__c = endpointURL);
        insert webServiceLog;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when Status is updated to Live Proof and Status Detail=Submitted
    *
    *  Revision Logs   :	V_1.0 - Created  - 05/18/2020 - CR-20200515-14047 - Victor Hanson
    * 				V_1.1 - Modified - 05/27/2020 - CR-20200527-14113 - Victor Hanson - Added reference to Suppression List
    * 				V_1.2 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to inlude status and statusDetail in callout body
    * 				V_1.3 - Modified - 06/01/02020 - CR-20200601-14128 - Victor Hanson - check aTxSuppressionList.fileName != null
    * 				V_1.4 - Modified - 11/13/2020 - CR-20201012-14597 - Victor Hanson - replaced duplicative code with getProofData method
    *                      	V_1.5 - Modified - 08/31/2021 - CR-20210830-15393 - Abhinav Sharma - Suppression List Artifact not getting populated in Live Proof Submitted Service
    *                     
    **/
    public static void checkReadyForLiveProof(List<Production_Tracking__c> newProdTrackingList, String artTxProofGeneration) {
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
        
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            
            //12/03/2020 - CR-20201012-14597 - Victor Hanson - replaced dynamic soql with method
            //get job ticket details
            List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
            
            if (jTickets.size() > 0) {
                
                //send each job ticket and artifacts transfer to the future method for vendor callout
                for (Job_Ticket__c jt : jTickets) 
                {
                    List<JobTicketService.artifactWrapper> artifactWrappers = new List<JobTicketService.artifactWrapper>();
                    
                    //11/17/2020 - CR-20201012-14597 - Victor Hanson - only send mailing list if proof generation is null or external
                    if (artTxProofGeneration == null || artTxProofGeneration == PROOF_GENERATION_EXTERNAL) 
                    {
                        
                        //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                        //get the Artwork artifact transfer where Direction=Push
                        artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true));
                        
                        //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                        //get the Mailing List artifact transfer where Direction=Push
                        artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_MAILING_LIST, 
                                                                 Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true));
                        
                        //Modified By - Abhinav Sharma - CR-20210902-15403 - 09/22/2021
                        //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                        //get the Supression List artifact transfer where Direction=Push
                        if(String.isNotBlank(pTracking.Suppression_File_Name__c)) 
                        {
                            artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_SUPPRESSION_LIST, 
                                                                     Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, false));    
                        }
                    }
                    //Modified By - Abhinav Sharma - CR-20210902-15403 - 09/22/2021
                    //else when proof generation = internal
                    else if (artTxProofGeneration == PROOF_GENERATION_INTERNAL) 
                    {
                        //get the Artwork artifact transfer where Direction=Pull
                        artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, true));
                        
                        //Added By - CR-20210830-15393 - 08/09/2021 - Abhinav Sharma - if this is Mail Shop RT, also include the suppression list details
                        //For Live Proof/Submitted "liveProofSubmitted" callout 
                        if(String.isNotBlank(pTracking.Suppression_File_Name__c)) 
                        {
                            artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, 
                                                                     Constants.ARTIFACT_TYPE_SUPPRESSION_LIST, 
                                                                     Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, false));
                        }
                    }
                    
                    //11/13/2020 - CR-20201012-14597 - Victor Hanson - additional changes start here
                    //get the json body
                    Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                    
                    List<JobTicketService.artifactWrapper> artTxWrappers = (List<JobTicketService.artifactWrapper>) deserializedJT.get('artifacts');
                    if (artTxWrappers == null) artTxWrappers = new List<JobTicketService.artifactWrapper>();
                    artTxWrappers.addAll(artifactWrappers);
                    deserializedJT.put('artifacts', artTxWrappers);
                    
                    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added for On Demand Job tickets only. It will add the Creative package Payload details in the request.  
                    Map<String, Object> deserializedJT1 = getJobTicketJSONWithCreativePackage(jt, pTracking, deserializedJT, COMMAND_LIVE_PROOF_SUBMITTED);
                    
                    //send callout & write response back to web service log
                    sendReadyForLiveProof(pTracking.Id, JSON.serialize(deserializedJT1, false), artTxProofGeneration);
                    
                    //commented out the code below because the get proof data method does the same thing
                    //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                    //V_1.3 - Modified - 06/01/02020 - CR-20200601-14128 - Victor Hanson - check aTxSuppressionList.fileName != null
                    //V_1.1 - Modified - 05/27/2020 - CR-20200527-14113 - Victor Hanson - Added reference to Suppression List
                    //add the Suppression List artifact transfer where Direction=Push if it exists (this file is optional)
                    /*JobTicketService.artifactWrapper aTxSuppressionList = getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_SUPPRESSION_LIST, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, false);
                    if (aTxSuppressionList != null && aTxSuppressionList.fileName != null) 
                    artifactWrappers.add(aTxSuppressionList);
                    
                    //get the json body
                    Map<String, Object> deserializedJT = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(jt, false));
                    deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json
                    
                    //V_1.2 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to inlude status and statusDetail in callout body
                    //add jobTicketId, ProductionTrackingId, Status, StatusDetail fields
                    deserializedJT.put('jobTicketId', jt.Id);
                    deserializedJT.put('productionTrackingId', pTracking.Id);
                    deserializedJT.put('status', pTracking.Status__c);
                    deserializedJT.put('statusDetail', pTracking.Status_Detail__c);
                    deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json
                    
                    //send callout & write response back to web service log
                    sendReadyForLiveProof(pTracking.Id, JSON.serialize(deserializedJT, false));*/
                    //11/13/2020 - CR-20201012-14597 - Victor Hanson - end here
                }
            }
        }
    }
    
    /**
    *  Purpose         :	Sends a callout to vendor when Status is Live Proof and StatusDetail is Submitted
    *
    *  Revision Logs   :	V_1.0 - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - 11/04/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation internal/external logic
    *                     
    **/
    public static void sendReadyForLiveProof(Id pTrackingId, String jsonBody, String proofGeneration) 
    {
        //12/09/2020 - CR-20201012-14597 - Victor Hanson - prevent duplicate sending of callout
        if (readyForLiveProofHasExecuted) return;
        sendCallout(pTrackingId, jsonBody, COMMAND_LIVE_PROOF_SUBMITTED, proofGeneration);
        readyForLiveProofHasExecuted = true;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when Status is updated to Ready for Proof and Status Detail=Submitted
    *
    *  Revision Logs   :	V_1.0 - Created - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - Modified - 05/18/2020 - CR-20200515-14047 - Victor Hanson - Added reference to Suppression List
    * 				V_1.2 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to include status and statusDetail in callout body
    *                     
    **/
    public static void checkReadyForPrint(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        //11/29/2020 - CR-20201012-14597 - Victor Hanson - added variable so this only runs once per invocation
        if (readyForPrintHasExecuted) return;
        
        //12/10/2020 - CR-20201012-14597 - Victor Hanson - commented out line below
        //get map of artifact transfers
        //Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
        
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            //get old production tracking if it exists
            Production_Tracking__c oldPTracking;
            if (oldMapProductionTracking != null)
                oldPTracking = oldMapProductionTracking.get(pTracking.Id);
            
            //04/22/2021 - CR-20210420-15089 - Victor Hanson - updated for Print RT
            //if status = Ready for Proof and Status or Status Detail changed to Live Proof Approved, send callout
            if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT &&
                (
                    (pTracking.RecordTypeId == PRODUCTION_TRACKING_RT_ID_PRINT || 
                     pTracking.RecordTypeId != PRODUCTION_TRACKING_RT_ID_PRINT && 
                     oldPTracking == null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED
                     || oldPTracking != null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED)
                    && (oldPTracking.Status__c != pTracking.Status__c || oldPTracking.Status_Detail__c != pTracking.Status_Detail__c
                       ))
               )
            {
                //12/10/2020 - CR-20201012-14597 - Victor Hanson - moved this so it only executes when necessary
                //get map of artifact transfers
                Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
                
                //12/03/2020 - CR-20201012-14597 - Victor Hanson - replaced dynamic soql with method
                //get job ticket details
                List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
                
                if (jTickets.size() > 0) {
                    
                    //send each job ticket and artifacts transfer to the future method for vendor callout
                    for (Job_Ticket__c jt : jTickets) {
                        List<JobTicketService.artifactWrapper> artifactWrappers = new List<JobTicketService.artifactWrapper>();
                        
                        //11/17/2020 - CR-20201012-14597 - Victor Hanson - only send art & suppression when proof generation = Internal
                        String artTxDirection = Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH;
                        if (pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL) {
                            artTxDirection = Constants.ARTIFACT_TRANSFER_DIRECTION_PULL;
                        }
                        
                        //11/17/2020 - CR-20201012-14597 - Victor Hanson - only send mailing & suppression list if proof generation is external
                        if (pTracking.Proof_Generation__c == PROOF_GENERATION_EXTERNAL) {
                            
                            //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                            //get the Artwork artifact transfer where Direction=Push
                            artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true));
                            
                            //04/22/2021 - CR-20210420-15089 - Victor Hanson - if this is Mail Shop RT, also include the mailing list & suppression
                            if (pTracking.RecordTypeId == Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP) {
                                
                                //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                                //get the Mailing List artifact transfer where Direction=Push
                                artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_MAILING_LIST, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true));
                                
                                //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                                //V_1.1 - Modified - 05/18/2020 - CR-20200515-14047 - Victor Hanson - Added
                                //add the Suppression List artifact transfer where Direction=Push if it exists (this file is optional)
                                JobTicketService.artifactWrapper aTxSuppressionList = getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_SUPPRESSION_LIST, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, false);
                                if (aTxSuppressionList != null) 
                                    artifactWrappers.add(aTxSuppressionList);
                            }
                        }
                        else if (pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL) 
                        {
                            JobTicketService.artifactWrapper readyToPrintWrapper = getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_READY_TO_PRINT, Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, true);
                            
                            //12/31/2020 - CR-20201012-14597 - Victor Hanson - get artifact items & add to ready to print wrapper
                            List<Artifact_Item__c> artifactItems = [SELECT Id, File_Name__c, File_Path__c, Item_Type__c, XMPie_Count__c, Banner_Sheet_Count__c
                                                                    FROM Artifact_Item__c
                                                                    WHERE Artifact__c IN (SELECT Artifact__c FROM Artifact_Transfer__c WHERE Id = :readyToPrintWrapper.id)];
                            List<JobTicketService.ArtifactItemWrapper> aItemWrappers = new List<JobTicketService.ArtifactItemWrapper>();
                            if (artifactItems.size() > 0) {
                                for (Artifact_Item__c artifactItem : artifactItems) {
                                    JobTicketService.ArtifactItemWrapper aiw = new JobTicketService.ArtifactItemWrapper(artifactItem);
                                    aItemWrappers.add(aiw);
                                }
                                readyToPrintWrapper.artifactItems = aItemWrappers;
                            }
                            
                            artifactWrappers.add(readyToPrintWrapper);
                            
                            //Modified By - Abhinav Sharma - CR-20210902-15403 - 09/22/2021
                            //08/09/2021 - CR-20210830-15393 - Abhinav Sharma - if this is Mail Shop RT, also include the suppression list details
                            //Ready for Print/Live Proof Approved "readyForPrintApproved" callout
                            //START FROM HERE
                            if (pTracking.RecordTypeId == Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP) 
                            {
                                if(String.isNotBlank(pTracking.Suppression_File_Name__c)) 
                                {
                                    //add the Suppression List artifact transfer where Direction=Pull if it exists (this file is optional)
                                    JobTicketService.artifactWrapper aTxSuppressionList = getArtifactTransfer(mapJTArtifactTx, pTracking, 
                                                                                                              Constants.ARTIFACT_TYPE_SUPPRESSION_LIST, 
                                                                                                              Constants.ARTIFACT_TRANSFER_DIRECTION_PULL, false);
                                    if (aTxSuppressionList != null) 
                                    {
                                        artifactWrappers.add(aTxSuppressionList);        
                                    }        
                                }
                            }
                            //END HERE
                        }
                        
                        //11/13/2020 - CR-20201012-14597 - Victor Hanson - changes start here
                        //get the json body
                        Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                        deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json
                        
                        //V_1.2 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to inlude status and statusDetail in callout body
                        //add jobTicketId, ProductionTrackingId, Status, StatusDetail fields
                        /*deserializedJT.put('jobTicketId', jt.Id);
                        deserializedJT.put('productionTrackingId', pTracking.Id);
                        deserializedJT.put('status', pTracking.Status__c);
                        deserializedJT.put('statusDetail', pTracking.Status_Detail__c);
                        deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json*/
                        
                        //Added By - Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - Add "inventoryTransactions" details
                        List<Inventory_Transaction__c> invTransactions = getInventoryTransactions(pTracking);
                        if (invTransactions.size() > 0) 
                        {
                            deserializedJT.put('inventoryTransactions', invTransactions);
                        }
                        
                        //04/22/2021 - CR-20210420-15089 - Victor Hanson - if this is NOT Print RT, only send the artwork
                        //send callout & write response back to web service log
                        if (pTracking.RecordTypeId == PRODUCTION_TRACKING_RT_ID_PRINT) {
                            //deserializedJT.put('inventoryTransaction', artifactWrappers);
                            sendCallout(pTracking.Id, JSON.serialize(deserializedJT, false), COMMAND_INVENTORY_READY_FOR_PRINT_APPROVED, PROOF_GENERATION_EXTERNAL);
                        }
                        else {
                            //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added for On Demand Job tickets only. It will add the Creative package Payload details in the request.
                            Map<String, Object> deserializedJT1 = getJobTicketJSONWithCreativePackage(jt, pTracking, deserializedJT, COMMAND_READY_FOR_PRINT_APPROVED);
                            sendCallout(pTracking.Id, JSON.serialize(deserializedJT1, false), COMMAND_READY_FOR_PRINT_APPROVED, PROOF_GENERATION_EXTERNAL);
                        }
                        
                        //11/29/2020 - CR-20201012-14597 - Victor Hanson - only execute once per invocation
                        readyForPrintHasExecuted = true;
                        //11/13/2020 - CR-20201012-14597 - Victor Hanson - changes end here
                    }
                }
            }
        }
    }
    
    //08/18/2020 - CR-20200812-14419 - Victor Hanson - this is called in most scenarios where we want to find the latest transfer of an artifact on a speific Production Tracking record
    public static JobTicketService.artifactWrapper getArtifactTransfer(Map<String, Artifact_Transfer__c> mapJTArtifactTx, Production_Tracking__c pTracking, String artifactType, String transferDirection, boolean isRequired) {
        String uk = pTracking.Job_Ticket__c + '-' + pTracking.Id + '-' + artifactType + '-' + transferDirection;
        if (artifactType == Constants.ARTIFACT_TYPE_ARTWORK)
            uk = pTracking.Job_Ticket__c + '-' + pTracking.Art_File_Name__c + '-' + artifactType + '-' + transferDirection;
        return getArtifactTransfer(mapJTArtifactTx, uk, artifactType, transferDirection, isRequired);
    }

    //08/18/2020 - CR-20200812-14419 - Victor Hanson - modified method params
    //06/03/2020 - CR-20200603-14137 - Victor Hanson - updated fileName to Target File Name
    //returns artifact transfer based on Job Ticket, Artifact Type, and Direction (push/pull)
    public static JobTicketService.artifactWrapper getArtifactTransfer(Map<String, Artifact_Transfer__c> mapJTArtifactTx, String uk, String artifactType, String transferDirection, boolean isRequired) {
        
        JobTicketService.artifactWrapper artifactWrapper = new JobTicketService.artifactWrapper();
        Artifact_Transfer__c aTx;
        if (mapJTArtifactTx.containsKey(uk))
            aTx = mapJTArtifactTx.get(uk);
        
        if (aTx != null) {
            //06/03/2020 - CR-20200603-14137 - Victor Hanson - updated fileName to Target File Name
            //01/13/2021 - CR-20201012-14597 - Victor Hanson - updated to pull the file name from source name if target file name is blank
            String fileName = aTx.Target_File_Name__c;
            //if (fileName == null) fileName = aTx.Source_File_Name_Exact__c;
            artifactWrapper.fileName = fileName;
            artifactWrapper.fileType = aTx.Artifact__r.Type__c;
            artifactWrapper.filePath = aTx.Target_Directory_Path__c;
            artifactWrapper.id = aTx.Id;
            
        }
        else if (aTx == null && isRequired) {
            throw new customException('No Artifact Transfer found on Job Ticket where Status=Success, Artifact Type = ' + artifactType + ', and Direction = ' + transferDirection);
        }
        
        return artifactWrapper;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when Status is Ready for Print and StatusDetail is Approved
    *
    *  Revision Logs   :	V_1.0 - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - 11/04/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation internal/external logic
    *                     
    **/
    public static void sendReadyForPrint(Id pTrackingId, String jsonBody, String proofGeneration) 
    {
        sendCallout(pTrackingId, jsonBody, COMMAND_READY_FOR_PRINT_APPROVED, proofGeneration);
    }
    
   /**
    *  Purpose         :	map of the most recent Artifact Transfers in a map of JobTicketId-ArtifactType-Direction -> ArtifactTransfer where Status = success
    * 						[JobTicketId]-[ArtifactType]-[Direction] -> [ArtifactTransfer]
    *
    *  Revision Logs   :	V_1.0 - Created - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - Modified - 06/01/2020 - CR-20200601-14128 - Victor Hanson - added to where clause to filter for Production Tracking and Artifact
    *                     
    **/
    public static Map<String, Artifact_Transfer__c> getMapJTArtifactTransfers(List<Production_Tracking__c> listPTracking) 
    {
        Map<String, Artifact_Transfer__c> mapJTArtifactTransfers = new Map<String, Artifact_Transfer__c>();
        Set<Id> jobTickeIds = new Set<Id>();
        for (Production_Tracking__c pTracking : listPTracking) {
            if (pTracking.Job_Ticket__c != null) jobTickeIds.add(pTracking.Job_Ticket__c);
        }
        
        //06/01/2020 - CR-20200601-14128 - Victor Hanson - added to where clause to filter for Production Tracking and Artifact
        //get all artifact transfers for these job tickets
        List<Artifact_Transfer__c> aTransfers = [SELECT Id, Target_File_Name__c, Artifact__r.Job_Ticket__c, Artifact__r.Type__c, Artifact__r.Production_Tracking__c,
                                                 Direction__c, Target_Directory_Path__c, Artifact__r.File_Name__c, Source_File_Name_Exact__c
                                                 FROM Artifact_Transfer__c 
                                                 WHERE Artifact__r.Job_Ticket__c IN :jobTickeIds 
                                                 /*AND Artifact__r.Production_Tracking__c IN :listPTracking 08/18/2020 - CR-20200812-14419 commented out*/
                                                 AND Artifact__c != null
                                                 ORDER BY CreatedDate DESC];
        
        if (aTransfers != null) {
            for (Artifact_Transfer__c aTransfer : aTransfers) {
                String uk = aTransfer.Artifact__r.Job_Ticket__c + '-' + aTransfer.Artifact__r.Production_Tracking__c + '-' + aTransfer.Artifact__r.Type__c + '-' + aTransfer.Direction__c;
                
                //08/18/2020 - CR-20200812-14419 - Victor Hanson - add special uk for artwork
                if (aTransfer.Artifact__r.Type__c == Constants.ARTIFACT_TYPE_ARTWORK)
                    uk = aTransfer.Artifact__r.Job_Ticket__c + '-' + aTransfer.Target_File_Name__c + '-' + aTransfer.Artifact__r.Type__c + '-' + aTransfer.Direction__c;
                
                if (mapJTArtifactTransfers.containsKey(uk)) {
                    //continue if the latest record was already included
                    continue;
                }
                else {
                    mapJTArtifactTransfers.put(uk, aTransfer);
                }
            }
        }
        
        return mapJTArtifactTransfers;
    }
    
   /**
    *  Purpose         :	Sends a callout to vendor when StatusDetail is Approved and Status is either Ready for Proof or Ready for Print
    *
    *  Revision Logs   :	V_1.0 - Created - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to inlude status, statusDetail, artifacts in callout body
    *                           V_1.2 - Modified - 12/10/2020 - CR-20201012-14597 - Victor Hanson - moved mapJTArtifactTx so it only executes when necessary
    *                     
    **/
    public static void checkApproved(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        //V_1.1 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - added line below
        //get map of artifact transfers
        //Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
        
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            //get old production tracking if it exists
            Production_Tracking__c oldPTracking;
            if (oldMapProductionTracking != null)
                oldPTracking = oldMapProductionTracking.get(pTracking.Id);
            
            //12/03/2020 - CR-20201012-14597 - Victor Hanson - Only send proof approved when proof generation=External.  if internal, we send once artTx is successfully sent to vendor
            //if status = Ready for Proof and Status Detail changed to Submitted, send callout
            if (pTracking.Proof_Generation__c == PROOF_GENERATION_EXTERNAL && (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF || pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT) && 
                ((oldPTracking == null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED)
                 || oldPTracking != null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED && oldPTracking.Status_Detail__c != Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED))
            {
                //12/10/2020 - CR-20201012-14597 - Victor Hanson - moved mapJTArtifactTx so it only executes when necessary
                //get map of artifact transfers
                Map<String, Artifact_Transfer__c> mapJTArtifactTx = getMapJTArtifactTransfers(newProdTrackingList);
                
                //12/03/2020 - CR-20201012-14597 - Victor Hanson - replaced dynamic soql with method
                //get job ticket details
                List<Job_Ticket__c> jTickets = getJobTicketDetails(pTracking);
                
                if (jTickets.size() > 0) {
                    
                    //send each job ticket to the future method for vendor callout
                    for (Job_Ticket__c jt : jTickets) {
                        
                        //11/13/2020 - CR-20201012-14597 - Victor Hanson - changes start here
                        //get the json body
                        Map<String, Object> deserializedJT = getJobTicketJSON(jt, pTracking);
                        
                        //V_1.1 - Modified - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated to inlude status, statusDetail, artifacts in callout body
                        //VH CR-20200304-13828
                        List<JobTicketService.artifactWrapper> artifactWrappers = new List<JobTicketService.artifactWrapper>();
                        
                        //11/17/2020 - CR-20201012-14597 - Victor Hanson - don't include artifact wrappers if proof generation is internal
                        //08/18/2020 - CR-20200812-14419 - Victor Hanson - replaced jtId with pTracking
                        //get the Artwork artifact transfer where Direction=Push
                        if (pTracking.Proof_Generation__c != PROOF_GENERATION_INTERNAL) {
                            artifactWrappers.add(getArtifactTransfer(mapJTArtifactTx, pTracking, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true));
                            deserializedJT.put('artifacts', artifactWrappers);
                        }
                        
                        //add jobTicketId, ProductionTrackingId, Status, StatusDetail fields
                        /*deserializedJT.put('jobTicketId', jt.Id);
                        deserializedJT.put('productionTrackingId', pTracking.Id);
                        deserializedJT.put('status', pTracking.Status__c);
                        deserializedJT.put('statusDetail', pTracking.Status_Detail__c);
                        deserializedJT.put('artifacts', artifactWrappers); //add artifact transfers to the json*/
                        //V_1.1 updates end here
                        
                        //CR-20210325-15028 - Mahendra Swarnkar - Added Check if the Assigned vendor is not blank then only send the call out
                        if(pTracking.Mail_Shop_Vendor__c != null){
                            
                            //send callout & write response back to web service log
                            sendApproved(pTracking.Id, JSON.serialize(deserializedJT, false), null);
                        }
                        //11/13/2020 - CR-20201012-14597 - Victor Hanson - changes end here
                    }
                }
            }
        }
    }
    
   /**
    *  Purpose         :    Sends a callout to vendor when StatusDetail is Approved
    *
    *  Revision Logs   :    V_1.0 - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    *                       V_1.1 - 11/04/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation internal/external logic
    *                       V_1.2 - 06/04/2021 - CR-20210524-15178 - Abhinav Sharma - OE/BRE-Automation QA/Issues Fixes
    *                     
    **/
    public static void sendApproved(Id pTrackingId, String jsonBody, String proofGeneration) {
        //V_1.2 - 06/04/2021 - CR-20210524-15178 - Abhinav Sharma - Add a blank check condition
        if(pTrackingId != null && String.isNotBlank(jsonBody) && String.isNotBlank(proofGeneration)){
            sendCallout(pTrackingId, jsonBody, COMMAND_PROOF_APPROVED, proofGeneration);
        }
    }
    
   /**
    *  Purpose         :	Updates Job Ticket's Active Production Tracking field with the Production Tracking record with the lowest Drop# where Status != mailed
    *
    *  Revision Logs   :	V_1.0 - 04/07/2020 - CR-20200304-13828 - Victor Hanson - Created
    * 				V_1.1 - 06/01/2020 - CR-20200601-14128 - Victor Hanson - updated query so it only looks at mail shop prod tracking records
    *                     
    **/
    public static void populateActiveProductionTracking(List<Production_Tracking__c> newProdTrackingList) {
        Set<Id> jtIds = new Set<Id>();
        List<Job_Ticket__c> jobTicketsToUpdate = new List<Job_Ticket__c>();
        for (Production_Tracking__c pTracking : newProdTrackingList)
            jtIds.add(pTracking.Job_Ticket__c);
        if (jtIds.size() > 0) {
            for (Job_Ticket__c jt : [SELECT Id, Active_Production_Tracking__c, Status__c, 
                                     (SELECT Id, Drop__c FROM Fulfillment_Tracking__r 
                                      WHERE Status__c != 'Mailed' 
                                      AND RecordTypeId = :Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP
                                      ORDER BY Drop__c ASC) 
                                     FROM Job_Ticket__c WHERE Id IN :jtIds]) 
            {
                if (jt.Fulfillment_Tracking__r != null && jt.Fulfillment_Tracking__r.size() > 0) {
                    //if the job ticket's active production tracking record is different than the lowest drop # that isn't mailed, update the job ticket
                    if (jt.Active_Production_Tracking__c != jt.Fulfillment_Tracking__r[0].Id) {
                        jt.Active_Production_Tracking__c = jt.Fulfillment_Tracking__r[0].Id;
                        jobTicketsToUpdate.add(jt);
                    }
                }
            }
            
            //update job tickets with the active production tracking record
            if (jobTicketsToUpdate.size() > 0) {
                JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = true;
                update jobTicketsToUpdate;
                JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = false;
            }
        }
    }
    
    //This method will check if Job Ticket exits on Production Tracking then populate the project manager lookUp value from Job Ticket 
    public static void populateProjectManagerOnProductionTracking(List<Production_Tracking__c> newProdTrackingList,Map<Id,Production_Tracking__c> oldMapProductionTracking){
        
        //Set to hold the Job ticket Ids.
        Set<Id> jobTicketIdSet = new Set<Id>();
        
        //Map to hold the job ticket and project manager Details
        Map<Id,String> mapOfJTWithProjectManager = new Map<Id,String>();
        
        for(Production_Tracking__c  prodTrcking : newProdTrackingList)
        {
            
            //Check for the change if the project manger or job ticket value is changed. 
            if((oldMapProductionTracking == null && prodTrcking.Job_Ticket__c != null && prodTrcking.JT_Project_Manager__c == null) || 
               (oldMapProductionTracking != null && prodTrcking.Job_Ticket__c != null && 
                ((prodTrcking.JT_Project_Manager__c != oldMapProductionTracking.get(prodTrcking.Id).JT_Project_Manager__c)
                 ||(prodTrcking.Job_Ticket__c != oldMapProductionTracking.get(prodTrcking.Id).Job_Ticket__c))))
            {
                //check for job ticket 
                if(prodTrcking.Job_Ticket__c != null){
                    jobTicketIdSet.add(prodTrcking.Job_Ticket__c);
                }
                
            }
        }
        
        //Query the job ticket and fill the map
        if(jobTicketIdSet.size() > 0)
        {
            for(Job_Ticket__c jt : [Select ID,Project_Manager__c From Job_Ticket__c Where Id IN: jobTicketIdSet])
            {
                mapOfJTWithProjectManager.put(jt.Id,jt.Project_Manager__c);
            }
        }
        
        //populate the project manager value from job ticket project manager
        //Loop on the new list
        for(Production_Tracking__c prodTracking : newProdTrackingList)
        {
            if(prodTracking.Job_Ticket__c != null){
                //check map contains the job ticket 
                if(mapOfJTWithProjectManager.ContainsKey(prodTracking.Job_Ticket__c))
                { 
                    //populate the project manager value from job ticket project manager
                    prodTracking.JT_Project_Manager__c = mapOfJTWithProjectManager.get(prodTracking.Job_Ticket__c);
                }
            }
            else if(oldMapProductionTracking != null && prodTracking.Job_Ticket__c != oldMapProductionTracking.get(prodTracking.Id).Job_Ticket__c){
                prodTracking.JT_Project_Manager__c = null;    
            }
        }
        
    }
    
   /**
    *  Purpose         :	This method is used to create the Artifact when the Production tracking is ready for proof and Status_Detail__c = submitted. 
    * 
    *  Revision Logs   :	V_1.0 - Created - 04/10/2020 - CR-20200408-13920
    * 				V_1.1 - 05/18/2020 - CR-20200515-14047 - Victor Hanson - updated live proof logic, commented out ready for prod logic
    *				V_1.2 - 11/12/2020 - CR-20201012-14597 - Victor Hanson - added logic to support proof generation internal
    *                     
    **/
    public static void createArtifactForProductionTracking(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        //11/13/2020 - CR-20201012-14597 - Victor Hanson - added variable so this only runs once per invocation
        if (artifactGenerationHasExecuted) return;
        
        List<Artifact__c> artifactsToBeCreated = new List<Artifact__c>();
        
        //11/13/2020 - CR-20201012-14597 - Victor Hanson - commented out the lines below because they aren't used
        //get all artifacts with artifact transfers
        
        Set<Id> setJobTicketIds = new Set<Id>();
        
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            
            if(pTracking.Job_Ticket__c != null)
                setJobTicketIds.add(pTracking.Job_Ticket__c);
        }
        
        Map<Id, Job_Ticket__c> mapJobTickets = new Map<Id, Job_Ticket__c>();
        if(setJobTicketIds.size() > 0){
            for(Job_Ticket__c jTicket : [Select Id, Drop_Type__c from Job_Ticket__c where ID IN : setJobTicketIds]){
                mapJobTickets.put(jTicket.ID, jTicket);
            }
        }
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            
            //get old production tracking if it exists
            Production_Tracking__c oldPTracking;
            
            if (oldMapProductionTracking != null)
                oldPTracking = oldMapProductionTracking.get(pTracking.Id);
            
            //11/12/2020 - CR-20201012-14597 - Victor Hanson - two different flows depending if proof generation is Internal (XMPie) vs External
            if (pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL) {
                //if status = Ready for Proof and Status Detail changed to Submitted, create Artifact
                //PROOF - SUBMITTED
                if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && 
                    ((oldPTracking == null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED)
                     || oldPTracking != null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED && oldPTracking.Status_Detail__c != Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED))
                {
                    //11/12/2020 - CR-20201012-14597 - Victor Hanson - if this is an internal PT record, create Artifact Transfer that will be sent to our xmpie server
                    artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id, 
                                                             Job_Ticket__c = pTracking.Job_Ticket__c, 
                                                             Type__c = Constants.ARTIFACT_TYPE_ARTWORK,
                                                             Source__c = 'EAB - Artwork',
                                                             Target__c = 'EAB - Archive',
                                                             Proof_Generation__c = PROOF_GENERATION_INTERNAL,
                                                             Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null ));
                    
                }
                //LIVE PROOF - SUBMITTED
                if(pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED 
                   && (oldPTracking == null
                       || (oldPTracking != null 
                           && (oldPTracking.Status__c != pTracking.Status__c || oldPTracking.Status_Detail__c != pTracking.Status_Detail__c))
                      ))
                {
                    if (!String.isBlank(pTracking.Suppression_File_Name__c)) {
                        //Added BY Dipesh Gupta - CR-20200521-14079 - 05/27/2020 - Added Supression List Artifact. 
                        artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id,  
                                                                 Job_Ticket__c = pTracking.Job_Ticket__c,
                                                                 Type__c = Constants.ARTIFACT_TYPE_SUPPRESSION_LIST,
                                                                 Source__c = 'EAB - Suppression List',
                                                                 Target__c = 'EAB - Archive',
                                                                 Source_File_Name_Exact_Override__c = pTracking.Suppression_File_Name__c,
                                                                 Proof_Generation__c = PROOF_GENERATION_INTERNAL,
                                                                 Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null));
                    }
                    else {
                        //if there is no suppression file, send callout for live proof-submitted
                        ProductionTrackingTriggerHelper.checkReadyForLiveProof(new List<Production_Tracking__c> { pTracking }, PROOF_GENERATION_INTERNAL);
                    }
                }
                //LIVE PROOF - APPROVED
                else if(pTracking.Proof_Generation__c == PROOF_GENERATION_INTERNAL 
                        && pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF 
                        && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED
                        && (oldPTracking == null
                            || (oldPTracking != null 
                                && (oldPTracking.Status__c != pTracking.Status__c || oldPTracking.Status_Detail__c != pTracking.Status_Detail__c))
                           ))
                {
                    
                    //send callout to AWS for live proof-approved
                    ProductionTrackingTriggerHelper.checkLiveProofApproved(new List<Production_Tracking__c> { pTracking });
                }
                //READY TO PRINT
                else if(pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED 
                        && (oldPTracking == null
                            || (oldPTracking != null 
                                && (oldPTracking.Status__c != pTracking.Status__c || oldPTracking.Status_Detail__c != pTracking.Status_Detail__c))
                           ))
                {
                    artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id,  
                                                             Job_Ticket__c = pTracking.Job_Ticket__c,
                                                             Type__c = Constants.ARTIFACT_TYPE_READY_TO_PRINT,
                                                             Source__c = 'EAB - Archive',
                                                             Target__c = 'Mail Shop - Ready To Print',
                                                             Proof_Generation__c = PROOF_GENERATION_INTERNAL,
                                                             Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null));
                }
            }
            else {
                //if status = Ready for Proof and Status Detail changed to Submitted, create Artifact
                if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && 
                    ((oldPTracking == null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED)
                     || oldPTracking != null && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED && oldPTracking.Status_Detail__c != Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED))
                {
                    artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id, 
                                                             Job_Ticket__c = pTracking.Job_Ticket__c, 
                                                             Type__c = Constants.ARTIFACT_TYPE_ARTWORK,
                                                             Source__c = 'EAB - Artwork',
                                                             Target__c = 'Mail Shop - Artwork',
                                                             Proof_Generation__c = PROOF_GENERATION_EXTERNAL,
                                                             Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null));
                    
                }
                else if(pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED 
                        && (oldPTracking == null
                            || (oldPTracking != null 
                                && (oldPTracking.Status__c != pTracking.Status__c || oldPTracking.Status_Detail__c != pTracking.Status_Detail__c))
                           ))
                {
                    artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id,  
                                                             Job_Ticket__c = pTracking.Job_Ticket__c,
                                                             Type__c = Constants.ARTIFACT_TYPE_MAILING_LIST,
                                                             Source__c = 'EAB - Archive',
                                                             Target__c = 'Mail Shop - Mailing List',
                                                             Proof_Generation__c = PROOF_GENERATION_EXTERNAL,
                                                             Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null)); 
                    
                    if (!String.isBlank(pTracking.Suppression_File_Name__c))
                    {
                        //Added BY Dipesh Gupta - CR-20200521-14079 - 05/27/2020 - Added Supression List Artifact. 
                        artifactsToBeCreated.add(new Artifact__c(Production_Tracking__c = pTracking.Id,  
                                                                 Job_Ticket__c = pTracking.Job_Ticket__c,
                                                                 Type__c = Constants.ARTIFACT_TYPE_SUPPRESSION_LIST,
                                                                 Source__c = 'EAB - Archive',
                                                                 Target__c = 'Mail Shop - Suppression List',
                                                                 Source_File_Name_Exact_Override__c = pTracking.Suppression_File_Name__c,
                                                                 Proof_Generation__c = PROOF_GENERATION_EXTERNAL,
                                                                 Drop_Type__c = mapJobTickets.containsKey(pTracking.Job_Ticket__c) ? mapJobTickets.get(pTracking.Job_Ticket__c).Drop_Type__c : null));
                    }
                }
            }
            
            
            // End Here
        }
        
        //Check if the list has records. 
        if(artifactsToBeCreated.size() > 0) 
        {
            //11/13/2020 - CR-20201012-14597 - Victor Hanson - prevents duplicate artifacts from being created
            artifactGenerationHasExecuted = true;
            insert artifactsToBeCreated;
        }
    }
    
   /**
    *  Purpose         :   When art file name is changed, update all other Prod Tracking records where Status = planned with the same file name
    * 
    *  Revision Logs   :   V_1.0 - Created - 04/10/2020 - Victor Hanson - CR-20200408-13920
    *                     
    **/
    public static void updateProdTrackingArtFileName(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        List<Production_Tracking__c> prodTrackingToUpdate = new List<Production_Tracking__c>();
        
        //get all job tickets with Production Tracking records where Status = Planned
        Set<Id> jtIds = new Set<Id>();
        for (Production_Tracking__c pTracking : newProdTrackingList) 
            jtIds.add(pTracking.Job_Ticket__c);
        Map<Id, Job_Ticket__c> mapJobTicketsWithProdTracking = new Map<Id, Job_Ticket__c>([SELECT Id, 
                                                                                           (SELECT Id, Art_File_Name__c, Drop__c FROM Fulfillment_Tracking__r 
                                                                                            WHERE Status__c = :Constants.PRODUCTION_TRACKING_STATUS_PLANNED 
                                                                                            AND Id NOT IN :newProdTrackingList)
                                                                                           FROM Job_Ticket__c WHERE Id IN :jtIds]);
        
        if (mapJobTicketsWithProdTracking.size() > 0) {
            for (Production_Tracking__c pTracking : newProdTrackingList) {
                //get old production tracking if it exists
                Production_Tracking__c oldPTracking;
                
                if (oldMapProductionTracking != null)
                    oldPTracking = oldMapProductionTracking.get(pTracking.Id);
                
                //check if Art file name has changed
                if (oldPTracking != null && oldPTracking.Art_File_Name__c != pTracking.Art_File_Name__c) {
                    
                    //update New Art = true if it's not currently checked
                    if (!pTracking.New_Art__c)
                        pTracking.New_Art__c = true;
                    
                    //get the job ticket and all subsequent production tracking records that are planned
                    Job_Ticket__c jt = mapJobTicketsWithProdTracking.get(pTracking.Job_Ticket__c);
                    if (jt != null && jt.Fulfillment_Tracking__r != null) {
                        for (Production_Tracking__c tempPTracking : jt.Fulfillment_Tracking__r) {
                            //only update subsequent production tracking records
                            if (tempPTracking.Drop__c > pTracking.Drop__c) {
                                //update the Art File Name
                                tempPTracking.Art_File_Name__c = pTracking.Art_File_Name__c;
                                prodTrackingToUpdate.add(tempPTracking);
                            }
                        }
                    }
                }
            }
            
            if (prodTrackingToUpdate.size() > 0) {
                util.bypassAllTriggers = true;
                update prodTrackingToUpdate;
                util.bypassAllTriggers = false;
            }
        }
    }
    
   /**
    *  Purpose         :   Updates the Status of the Job Ticket if JT Status=Approved by Client and Production Tracking Status is Proof
    * 
    *  Revision Logs   :   V_1.0 - Created - 04/10/2020 - CR-20200408-13920
    *                     
    **/
    public static void updateJobTicketFields(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        //list of job tickets to update
        List<Job_Ticket__c> jobTicketsToUpdate = new List<Job_Ticket__c>();
        
        //get all job tickets with Production Tracking records where Status = Planned
        Set<Id> jtIds = new Set<Id>();
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            Production_Tracking__c oldPTracking = oldMapProductionTracking.get(pTracking.Id);
            //04/21/2021 - CR-20210420-15089 - Victor Hanson - added criteria to look at record type id.  ignore print RTs
            //get the job ticket id if prod trackign status is updated and it's past the Approved by Client status but isn't mailed
            if (pTracking.Status__c != Constants.PRODUCTION_TRACKING_STATUS_PLANNED 
                && pTracking.Status__c != Constants.PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT 
                && pTracking.Status__c != Constants.PRODUCTION_TRACKING_STATUS_MAILED
                && pTracking.Status__c != oldPTracking.Status__c
                && pTracking.RecordTypeId != PRODUCTION_TRACKING_RT_ID_PRINT)
            {
                jtIds.add(pTracking.Job_Ticket__c);
            }
        }
        
        if (jtIds.size() > 0) {
            Map<Id, Job_Ticket__c> mapJobTicketsWithProdTracking = new Map<Id, Job_Ticket__c>([SELECT Id, Status__c
                                                                                               FROM Job_Ticket__c WHERE Id IN :jtIds]);
            for (Production_Tracking__c pTracking : newProdTrackingList) {
                Job_Ticket__c jt = mapJobTicketsWithProdTracking.get(pTracking.Job_Ticket__c);
                if (jt != null && jt.Status__c == Constants.JOB_TICKET_STATUS_APPROVED_BY_CLIENT) 
                {
                    jt.Status__c = Constants.JOB_TICKET_STATUS_IN_PROGRESS;
                    jobTicketsToUpdate.add(jt);
                }
            }
            
            if (jobTicketsToUpdate.size() > 0) {
                util.bypassAllTriggers = true;
                update jobTicketsToUpdate;
                util.bypassAllTriggers = false;
            }
        }
        
    }
    
   /**
    *  Purpose         :   Updates the Approval Status of the associated Artifact if Proof Approval Status or Live Proof Approval Status is updated
    * 
    *  Revision Logs   :   V_1.0 - Created - 04/23/2020 - CR-20200408-13920
    *                     
    **/
    public static void updateArtifactApprovalStatus(Map<Id,Production_Tracking__c> newMapProdTracking, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        Map<String, Artifact__c> artifactsToUpdate = new Map<String, Artifact__c>();
        
        //check if there are any records where the Approval Status has been modified
        List<Production_Tracking__c> ptWithUpdatedApprovalStatus = new List<Production_Tracking__c>();
        for (Production_Tracking__c pt : newMapProdTracking.values()) {
            //get the old pt record
            Production_Tracking__c oldPT = oldMapProductionTracking.get(pt.Id);
            if (oldPT != null) {
                if (pt.Proof_Approval_Status__c != oldPT.Proof_Approval_Status__c || pt.Live_Proof_Approval_Status__c != oldPT.Live_Proof_Approval_Status__c)
                    ptWithUpdatedApprovalStatus.add(pt);
            }
        }
        
        //if there is at least one record with updated approval status
        if (ptWithUpdatedApprovalStatus.size() > 0) {
            //Artifact Types that need to be approved (ie: Artwork Proof & Live Proof Data)
            List<String> artifactTypesForApproval = new List<String> { Constants.ARTIFACT_TYPE_ARTWORK_PROOF, Constants.ARTIFACT_TYPE_LIVE_PROOF };
            Map<Id, Production_Tracking__c> mapIdToProdTrackingWithArtifacts = new Map<Id, Production_Tracking__c>([SELECT Id, 
            											                    (SELECT Id, Type__c, Approval_Status__c
                                                                                                                     FROM Artifacts__r
                                                                                                                     WHERE Type__c IN :artifactTypesForApproval
                                                                                                                     ORDER BY CreatedDate ASC)
                                                                                                                     FROM Production_Tracking__c
                                                                                                                     WHERE Id IN :newMapProdTracking.keySet()]);
            
            //get production tracking with artifacts
            for (Production_Tracking__c pt : ptWithUpdatedApprovalStatus) {
                Production_Tracking__c ptWithArtifacts = mapIdToProdTrackingWithArtifacts.get(pt.Id);
                
                //get the old pt record
                Production_Tracking__c oldPT = oldMapProductionTracking.get(pt.Id);
                //if it was the 'proof approval status' that got updated, update the last Artwork Proof artifact in the list (ie: latest created date)
                if (newMapProdTracking.get(pt.Id).Proof_Approval_Status__c != oldPT.Proof_Approval_Status__c
                    && ptWithArtifacts != null && ptWithArtifacts.Artifacts__r != null) 
                {
                    for (Artifact__c artifact : ptWithArtifacts.Artifacts__r) {
                        if (artifact.Type__c == Constants.ARTIFACT_TYPE_ARTWORK_PROOF && newMapProdTracking.get(pt.Id).Proof_Approval_Status__c != null) {
                            artifact.Approval_Status__c = newMapProdTracking.get(pt.Id).Proof_Approval_Status__c;
                            artifactsToUpdate.put(pt.Id + '-' + artifact.Type__c, artifact);
                        }
                    }
                }
                
                //if it was the 'live proof approval status' that got updated, update the last Live Proof Data artifact in the list (ie: latest created date)
                if (newMapProdTracking.get(pt.Id).Live_Proof_Approval_Status__c != oldPT.Live_Proof_Approval_Status__c
                    && ptWithArtifacts != null && ptWithArtifacts.Artifacts__r != null) 
                {
                    for (Artifact__c artifact : ptWithArtifacts.Artifacts__r) {
                        if (artifact.Type__c == Constants.ARTIFACT_TYPE_LIVE_PROOF && newMapProdTracking.get(pt.Id).Live_Proof_Approval_Status__c != null) {
                            artifact.Approval_Status__c = newMapProdTracking.get(pt.Id).Live_Proof_Approval_Status__c;
                            artifactsToUpdate.put(pt.Id + '-' + artifact.Type__c, artifact);
                        }
                    }
                }
            }
            
            //update artifact approval status
            if (artifactsToUpdate.size() > 0)
                update artifactsToUpdate.values();
        }
    }
    
   /**
    *  Purpose         :   This method will update the Job ticket when Active mail date is changed and Drop # = 1
    * 
    *  Revision Logs   :   V_1.0 - Created - 04/27/2020 - CR-20200221-13792
    *                     
    **/
    public static void updateJobTicket(List<Production_Tracking__c> newProductionTrackings, Map<Id, Production_Tracking__c> oldMapProductiontrakings) {
        
        //Map to hold the job tickets that needs to be updated.
        Map<Id, Job_Ticket__c> mapJobTicketsToBeUpdated = new Map<Id, Job_Ticket__c>();
        
        //Loop on the Production Tracking.
        for(Production_Tracking__c prod :  newProductionTrackings) {
            
            //If the Production tracking's actual mail data is changed. 
            if(String.isNotBlank(prod.Job_Ticket__c) && oldMapProductiontrakings != null && oldMapProductiontrakings.get(prod.Id).Actual_Mail_Date__c != prod.Actual_Mail_Date__c) {
                
                //Production Tracking Drop # = 1. 
                if(prod.Drop__c == 1) {
                    
                    //Adding the Job Ticket to the Map. 
                    mapJobTicketsToBeUpdated.put(prod.Job_Ticket__c, 
                                                 new Job_Ticket__c(Id = prod.Job_Ticket__c, 
                                                                   Drop_1_Actual_Mail_Date__c =  prod.Actual_Mail_Date__c));    
                }
            }
        }
        
        //Check the size of Map. 
        if(mapJobTicketsToBeUpdated.size() > 0){
            Util.BypassAllTriggers = true; 
            update mapJobTicketsToBeUpdated.values();
            Util.BypassAllTriggers = false;
        }
    }
    
   /**
    *  Purpose         :   updates fields on Production Tracking based on data on the related Job Ticket
    * 
    *  Revision Logs   :   V_1.0 - 06/11/2020 - CR-20200611-14176 - Victor Hanson - created
    *			   V_1.1 - CR-20210924-15459 - 10/04/2021 - Shalu Sharma
    *                     
    **/
    public static void updateProductionTrackingFields(List<Production_Tracking__c> newProductionTrackings) {
        Set<Id> jobTicketIds = new Set<Id>();
        for (Production_Tracking__c pt : newproductionTrackings) {
            if (pt.Job_Ticket__c != null && pt.Mail_Shop_Vendor__c == null && pt.RecordTypeId == JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP) jobTicketIds.add(pt.Job_Ticket__c);
        }
        
        if (jobTicketIds.size() > 0) {
            Map<Id, Job_Ticket__c> mapJobTickets = new Map<Id, Job_Ticket__c>([SELECT Id, Mail_Vendor__c FROM Job_Ticket__c WHERE Id IN :jobTicketIds AND Mail_Vendor__c != null]);
            for (Production_Tracking__c pt : newProductionTrackings) {
                
                //if assigned vendor is null and job ticket mail vendor is populated, update assigned vendor
                if (pt.Mail_Shop_Vendor__c == null 
                    && pt.RecordTypeId == JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP
                    && mapJobTickets.containsKey(pt.Job_Ticket__c)
                    && mapJobTickets.get(pt.Job_Ticket__c).Mail_Vendor__c != null) 
                {
                    pt.Mail_Shop_Vendor__c = mapJobTickets.get(pt.Job_Ticket__c).Mail_Vendor__c;
                }
            }
        }
    }
    
   /**
    *  Purpose         :   Auto-populate JT: PM Manager field with the JT_Project_Manager__r.ManagerId field
    * 
    *  Revision Logs   :   V_1.0 - 06/19/2020 - CR-20200616-14191 - Dipesh Gupta - created
    *                     
    **/
    public static void populate_JT_PMManagerWithJTProjectManagersManagerId(List<Production_Tracking__c> newProductionTrackings, Map<Id, Production_Tracking__c> oldMapProductiontrakings)
    {
        Set<Id> setOfJobTicketIDs = new Set<Id>();
        
        for(Production_Tracking__c pT : newProductionTrackings)
        {
            if(pT.Job_Ticket__c != null)
            {
                setOfJobTicketIDs.add(pT.Job_Ticket__c);
            }
        }
        
        if(setOfJobTicketIDs.size() > 0)
        {
            Map<Id, Job_Ticket__c> mapOfIdWithJobTicket = new Map<Id, Job_Ticket__c>([SELECT Id, Project_Manager__r.ManagerId 
                                                                                      FROM Job_Ticket__c
                                                                                      WHERE Id IN : setOfJobTicketIDs]); 
            
            for(Production_Tracking__c pT : newProductionTrackings)
            {
                if(mapOfIdWithJobTicket.size() > 0 && mapOfIdWithJobTicket.containsKey(pT.Job_Ticket__c)) 
                    pT.JT_PM_Manager__c = mapOfIdWithJobTicket.get(pT.Job_Ticket__c).Project_Manager__r.ManagerId;
            }
        }
    }
    
   /**
    *  Purpose         :	Method to populate due dates field on production Tracking record on the basis of Status and Status Detail
    * 				fields values that will be further used for the milestone tracking purpose.
    * 
    *  Revision Logs   :	V_1.0 - 07/31/2020 - CR-20200717-14331 - Abhinav Sharma - Created
    *                     
    **/
    public static void populate_DueDateFieldOnPTracking(List<Production_Tracking__c> newProductionTrackings, 
                                                        Map<Id, Production_Tracking__c> oldMapProductiontrakings)
    {
        
        
        Map<Integer,Milestone_Tracking__mdt> mapOfMilestoneTracking = new Map<Integer,Milestone_Tracking__mdt>();
        Map<String,List<String>> mapOfstatus = new  Map<String,List<String>>();
        mapOfstatus.put('Proof', new List<String>{'Planned','Approved by Partner'});
        mapOfstatus.put('Live Proof',new List<String>{'Proof','Planned','Approved by Partner'});
        
        List<Production_Tracking__c> pTrackingList  = new List<Production_Tracking__c>();
        
        for(Milestone_Tracking__mdt milestone : [SELECT Id,Order__c,Due_Date_Label__c,Days__c,Help_Text__c,
                                                 Status__c,Status_Details__c,PT_Due_Date_Field_Name__c 
                                                 FROM Milestone_Tracking__mdt
                                                 WHERE Status__c != null AND Status_Details__c != null 
                                                 AND PT_Due_Date_Field_Name__c != null 
                                                 AND Operation_Type__c = 'Due_Dates_Calculations'])
        {
            mapOfMilestoneTracking.put(Integer.valueOf(milestone.order__c),milestone);
        }
        
        if(mapOfMilestoneTracking.size() > 0) 
        {
            for(Production_Tracking__c pT : newProductionTrackings)
            {
                if((pT.Planned_Mail_Date__c != null && (String.isNotBlank(pT.Status__c) 
                                                        || String.isNotBlank(pT.Status_Detail__c)) 
                   )
                   &&
                   (
                       oldMapProductiontrakings == null 
                       || (oldMapProductiontrakings != null 
                           && 
                           (
                               pT.status__c !=  oldMapProductiontrakings.get(pT.Id).status__c 
                               || pT.Status_Detail__c !=  oldMapProductiontrakings.get(pT.Id).Status_Detail__c
                               || pT.Planned_Mail_Date__c !=  oldMapProductiontrakings.get(pT.Id).Planned_Mail_Date__c
                           )
                          )
                   )
                  )
                {
                    
                    if( oldMapProductiontrakings != null && ((mapOfstatus.get('Live Proof')).contains(pT.status__c) &&  oldMapProductiontrakings.get(pT.Id).status__c == 'Live Proof'
                                                             || (mapOfstatus.get('Proof')).contains(pT.status__c) &&  oldMapProductiontrakings.get(pT.Id).status__c == 'Proof')){
                                                                 pT.Art_Due_to_Vendor_Date__c = null;
                                                                 pT.Proof_Approval_Date__c = null;
                                                                 pT.Data_Due_to_Vendor_Date__c = null;
                                                                 pT.Live_Proof_Approval_Due_Date__c = null;
                                                             }
                    else if(pT.status__c == 'Proof' && (pT.Status_Detail__c == 'File Issue' || pT.Status_Detail__c == 'Failure')){
                        pT.Art_Due_to_Vendor_Date__c = null;
                        pT.Proof_Approval_Date__c = null;
                    }
                    else if(pT.status__c == 'Live Proof' && (pT.Status_Detail__c == 'File Issue' || pT.Status_Detail__c == 'Failure')){
                        pT.Data_Due_to_Vendor_Date__c = null;
                        pT.Live_Proof_Approval_Due_Date__c = null;
                    }
                    pTrackingList.add(pT);
                    
                }
            } 
            
            if(pTrackingList.size() > 0 && mapOfMilestoneTracking.size() > 0){
                newProductionTrackings =  PrintmisUtility.checkPTrackingAtRiskOROnTrack(pTrackingList, mapOfMilestoneTracking);
                
            }
        }
    }
    
   /**
    *  Purpose         :	Method to populate due dates field on production Tracking record on the basis of Status and Status Detail
    * 				fields values that will be further used for the SLA tracking purpose.
    * 
    *  Revision Logs   :	V_1.0 - 08/27/2020 - CR-20200817-14438 - Abhinav Sharma - Created
    *                     
    **/
    public static void populate_SLATrackingDateTimeFieldOnPTracking(List<Production_Tracking__c> newProductionTrackings, 
                                                                    Map<Id, Production_Tracking__c> oldMapProductiontrakings)
    {
        for(Production_Tracking__c pTracking : newProductionTrackings){
            if(String.isNotBlank(pTracking.status__c) || String.isNotBlank(pTracking.Status_Detail__c)
               && (oldMapProductiontrakings == null || 
                   (oldMapProductiontrakings != null && 
                    (pTracking.status__c != oldMapProductiontrakings.get(pTracking.Id).status__c 
                     || pTracking.Status_Detail__c != oldMapProductiontrakings.get(pTracking.Id).Status_Detail__c
                    )
                   )
                  )
              )
            {
                if(pTracking.status__c == 'Proof' && pTracking.Status_Detail__c == 'File Received')
                {
                    pTracking.Proof_File_Received_DateTime__c = system.now();
                }
                else if(pTracking.status__c == 'Proof' && pTracking.Status_Detail__c == 'Pending Approval')
                {
                    pTracking.Proof_Pending_Approval_DateTime__c = system.now();
                }
                else if(pTracking.status__c == 'Proof' && pTracking.Status_Detail__c == 'Approved')
                {
                    pTracking.Proof_Approved_DateTime__c = system.now();
                }
                else if(pTracking.status__c == 'Live Proof' && pTracking.Status_Detail__c == 'File Received')
                {
                    pTracking.Live_Proof_File_Received_DateTime__c = system.now();
                }
                else if(pTracking.status__c == 'Live Proof' && pTracking.Status_Detail__c == 'Pending Approval')
                {
                    pTracking.Live_Proof_Pending_Approval_DateTime__c = system.now();
                }
                else if(pTracking.status__c == 'Ready for Print' && pTracking.Status_Detail__c == 'Live Proof Approved')
                {
                    pTracking.ReadyforPrint_LP_Approval_DateTime__c = system.now();
                }
            }
        }
    }
    
   /**
    *  Purpose         :    Method to update Error Details = null when the Production Tracking Status Detail is changed from 'Error' or 'File Issue' to another.
    * 
    *  Revision Logs   :    V_1.0 - 04/1/2020 - CR-20210322-15011 - Neha Sharma - Created
    *                     
    **/
    
    public static void updateFieldsOnPTracking(List<Production_Tracking__c> newProductionTrackings, 
                                               Map<Id, Production_Tracking__c> oldMapProductiontrakings)
    {
        Set<String> setOfPTStatus = new Set<String>{'File Issue', 'Error'}; 
            for (Production_Tracking__c pt : newproductionTrackings) {
                if (oldMapProductiontrakings != null && String.isNotBlank(pt.Error_Details__c)
                    && pt.Status_Detail__c != oldMapProductiontrakings.get(pt.Id).Status_Detail__c
                    && !setOfPTStatus.contains(pt.Status_Detail__c)
                   )
                {
                    if(pt.Error_Details__c != null){
                        pt.Error_Details__c = null;
                    }
                    
                }
            }
    }
    
   /**
    *  Purpose         :    dynamically get fields from field sets on job ticket & related records
    * 
    *  Revision Logs   :    V_1.0 - CR-20201012-14597 - 12/03/2020 - Victor Hanson - created
    *                     
    **/
    public static List<Job_Ticket__c> getJobTicketDetails(Production_Tracking__c pTracking) {
        Id jobTicketId = pTracking.Job_Ticket__c; //NOPMD - variable used in dynamic apex
        //dynamically create SOQL to get Job Ticket, Job Ticket MtM, production tracking
        String jtQuery = 'SELECT ' 
            + JobTicketService.jobTicketFields + ',' 
            + JobTicketService.getProdTrackingFields(pTracking.Id) + ','
            + JobTicketService.componentFields 
            + ' FROM Job_Ticket__c ' 
            + ' WHERE Id = :jobTicketId';
        return database.query(jtQuery);
    }
    
   /**
    *  Purpose         :    dynamically get fields from field sets on Inventory Transaction records
    * 
    *  Revision Logs   :    V_1.0 - CR-20210420-15089 - 04/21/2021 - Victor Hanson - created
    *                     
    **/
    public static List<Inventory_Transaction__c> getInventoryTransactions(Production_Tracking__c pt) {
        String invTransactionQuery = 'SELECT ' + JobTicketService.setToCommaDelim(util.getFieldSetFieldsAPINames('Inventory_Transaction__c', 'Inv_Transaction_Callout_Field_Set')) 
            + ' FROM Inventory_Transaction__c ';
        invTransactionQuery += ' WHERE Production_Tracking__c=\'' + pt.Id + '\'';
        return database.query(invTransactionQuery);
    }
    
   /**
    *  Purpose         :    Update the Creative Package Approval Status to Approved when PT is Proof-Approved and Drop Type on Job Ticket is 'On Demand'
    *
    *  Revision Logs   :    V_1.0 - 04/26/2021 - CR-20210325-15027 - Created By Mahendra Swarnkar
    *                     
    **/
    public static void updateCreativePackageApprovalStatus(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        Set<ID> setPTIds = new Set<ID>();
        for (Production_Tracking__c pTracking : newProdTrackingList) {
            Production_Tracking__c oldPTracking = oldMapProductionTracking?.get(pTracking.Id);
            if (pTracking.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
                && pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED 
                && pTracking.Creative_Package__c != null
                && (pTracking.Status__c != oldPTracking.Status__c
                    || pTracking.Status_Detail__c != oldPTracking.Status_Detail__c))
            {
                setPTIds.add(pTracking.ID);
            }
        }
        if(setPTIds.size() > 0) {
            
            List<Creative_Package__c> listCreativePackageToBeUpdate = new List<Creative_Package__c>();            
            for(Production_Tracking__c pTrack : [Select Id, Creative_Package__c, Status__c, Status_Detail__c, Job_Ticket__c, Job_Ticket__r.Drop_Type__c  
                                                 From Production_Tracking__c where ID IN : setPTIds] ) 
            {
                if(pTrack.Creative_Package__c != null && pTrack.Job_Ticket__c != null 
                   && pTrack.Job_Ticket__r.Drop_Type__c == System.Label.DROP_TYPE_ON_DEMAND
                   && pTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
                   && pTrack.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED  )
                {
                    listCreativePackageToBeUpdate.add(new Creative_Package__c(Id = pTrack.Creative_Package__c, Approval_Status__c = Constants.CREATIVE_PACKAGE_APPROVAL_STATUS_Approved));
                }
            }
            
            if(listCreativePackageToBeUpdate.size() > 0){
                
                update listCreativePackageToBeUpdate;
            }
        }
    }
    //04/26/2021 - CR-20210325-15028 - Created By Mahendra Swarnkar
    public static void updatePTArtFileNameOnStatusChange(List<Production_Tracking__c> newProdTrackingList, Map<Id,Production_Tracking__c> oldMapProductionTracking) {
        
        Set<Id> setCreativePackageIds = new Set<Id> (); 
        for(Production_Tracking__c pt : newProdTrackingList) {
            
            if(oldMapProductionTracking == null 
               || (oldMapProductionTracking != null 
                   && (pt.Status__c != oldMapProductionTracking.get(pt.ID).Status__c 
                       || pt.Status_Detail__c != oldMapProductionTracking.get(pt.ID).Status_Detail__c)) 
              ) {
                  if(pt.Creative_Package__c != null && pt.Drop_Type__c == Constants.PRODUCTION_TRACKING_DROP_TYPE && pt.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
                     && ((oldMapProductionTracking == null && pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED) 
                         || (oldMapProductionTracking != null && pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED) ) 
                    ) {
                        setCreativePackageIds.add(pt.Creative_Package__c);
                    }
              }
        }
        
        if(setCreativePackageIds.size() > 0) {
            Map<Id, Creative_Package__c> mapCreativePackages = new Map<Id, Creative_Package__c>([Select ID, Art_File_Name__c From Creative_Package__c Where ID IN : setCreativePackageIds AND Art_File_Name__c != null AND Art_File_Name__c != '']);
            
            if(mapCreativePackages != null && mapCreativePackages.size() > 0){
                
                for(Production_Tracking__c pt : newProdTrackingList) {
                    
                    if(mapCreativePackages.containsKey(pt.Creative_Package__c) && mapCreativePackages.get(pt.Creative_Package__c) != null) {
                        
                        if(pt.Creative_Package__c != null && pt.Drop_Type__c == Constants.PRODUCTION_TRACKING_DROP_TYPE && pt.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF  
                           && ((oldMapProductionTracking == null  && pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED)
                               || (oldMapProductionTracking != null && pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED))
                          ) {
                              pt.Art_File_Name__c = mapCreativePackages.get(pt.Creative_Package__c).Art_File_Name__c;
                          }
                    }
                }
            }
        }
    }
    
   /**
    *  Purpose         :   Method to populate "Postage_Class__c" field on PT record 
    * 			    	   Logic - When PT record is created or updated and postage class field is blank then populate the 
    *                      postage class field with the value of associated job ticket's postage class field. 
    * 
    *  Revision Logs   :   V_1.0 - 10/01/2021 - CR-20210916-15441 - Nikita Kumari - created
    *                     
    **/
    public static void populatePostageClassOnPT(List<Production_Tracking__c> newProductionTrackings){
        
        //Set to hold Job Ticket Ids
        Set<Id> jobTicketIds = new Set<Id>();
        
        for(Production_Tracking__c prodTracking : newProductionTrackings)
        {
            //check jobticket id, record type and postage class field value 
            if(prodTracking.RecordTypeId == Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP && prodTracking.Job_Ticket__c != null && prodTracking.Postage_Class__c == null)
            {
                jobTicketIds.add(prodTracking.Job_Ticket__c);
            }
        }
        
        if(jobTicketIds.size()>0){
            
            //Query job ticket records in map with Id and record
            Map<Id, Job_Ticket__c> mapJtIdWithJobTicket = new Map<Id, Job_Ticket__c> ([SELECT Id, Postage_Class__c FROM Job_Ticket__c WHERE Id IN :jobTicketIds]);
            
            if(mapJtIdWithJobTicket != null && mapJtIdWithJobTicket.values().size()>0){
                for(Production_Tracking__c prodTracking : newProductionTrackings)
                {
                    if(prodTracking.Job_Ticket__c != null &&   mapJtIdWithJobTicket.get(prodTracking.Job_Ticket__c) != null  && prodTracking.Postage_Class__c == null )
                    {
                        prodTracking.Postage_Class__c = mapJtIdWithJobTicket.get(prodTracking.Job_Ticket__c).Postage_Class__c;
                    }
                }
            }
        }
    }
    
    /**
     *  Purpose         :   Method to populate "Mailshop PT: Status”" field on  Inventory Transaction
     *                      Logic - When PT record with the Record Type of “Mail Shop" is created or updated and Inventory Transaction's Mailshop Production Tracking equals to 
     *                      Production tracking Id then populate the Mailshop PT: Status with production tracking ststus
     *
     *  Revision Logs   :   V_1.0 - 10/04/2021 - CR-20210924-15459 - Shalu Sharma - created
     *                     
     **/
    public static void populateMailshopPTStatusOnInventoryTransaction(List<Production_Tracking__c> newProductionTrackings, 
                                                                        Map<Id, Production_Tracking__c> mapOfOldPTrackings)
    {
         //Map to hold PT id and Status
         Map<Id,String> mapOfPTIdWithPTStatus = new Map<Id,String>();

         for(Production_Tracking__c prodTracking : newProductionTrackings)
        {
            //checking Production Tracking record type and Production tracking Status value
            if(prodTracking.RecordTypeId  == JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP && prodTracking.Status__c != null && 
            (mapOfOldPTrackings == null || prodTracking.Status__c != mapOfOldPTrackings.get(prodTracking.Id).Status__c)
            ){
                //Populating map with Production Tracking Id and Status
                if(!mapOfPTIdWithPTStatus.containsKey(prodTracking.Id)){
                    mapOfPTIdWithPTStatus.put(prodTracking.Id,prodTracking.Status__c);
                }
            }
        }

        //Checking is Size of map
        if(mapOfPTIdWithPTStatus.size() > 0 && mapOfPTIdWithPTStatus.keySet().size() > 0){

            //List To update Inventory Transaction
            List<Inventory_Transaction__c> inventoryTrxnsToUpdate =  new List<Inventory_Transaction__c>();

            for(Inventory_Transaction__c InventroryTrxn : [Select Id,Mailshop_Production_Tracking__c,Mailshop_PT_Status__c From Inventory_Transaction__c Where Mailshop_Production_Tracking__c IN :mapOfPTIdWithPTStatus.keySet()]){
                //Checking Inventory Transaction Mailshop_PT_Status__c and populating list to update Inventory Transaction
                if(InventroryTrxn.Mailshop_Production_Tracking__c != null && InventroryTrxn.Mailshop_PT_Status__c != mapOfPTIdWithPTStatus.get(InventroryTrxn.Mailshop_Production_Tracking__c)){
                    InventroryTrxn.Mailshop_PT_Status__c = mapOfPTIdWithPTStatus.get(InventroryTrxn.Mailshop_Production_Tracking__c);
                    inventoryTrxnsToUpdate.add(InventroryTrxn);
                }
            }

            //Checking the size of List to update
            if(inventoryTrxnsToUpdate.size() > 0){
                //updating the Inventory transaction List
                Update inventoryTrxnsToUpdate;
            }
        }
    }

    /**
     *  Purpose         :   Method to Insert Inventory and Inventory Transaction record for Print Production tracking record when created
     *      
     *  Revision Logs   :   V_1.0 - 10/04/2021 - CR-20210924-15459 - Shalu Sharma - created
     *                     
     **/
    public static void createInventoryAndTransForPrintPT(List<Production_Tracking__c> newProductionTrackings, 
                                                         Map<Id, Production_Tracking__c> mapOfOldPTrackings)
    { 
        if(createInventoryAndTransForPrintPTHasExecuted) return;

        //set to store Production tracking Ids
        Set<Id> setOfProductionTrackingIds = new Set<Id>();
        List<String> listOfEligibleComponentType = System.Label.Eligible_Component_Type_For_Inventory_Manager.split(',');
    	Set<String> setOfEligibleComponentType = new Set<String>(listOfEligibleComponentType);

        for(Production_Tracking__c pt : newProductionTrackings){

            //checking the Production Tracking RecordType and Component
            if(pt.RecordTypeId == PRODUCTION_TRACKING_RT_ID_PRINT
               && setOfEligibleComponentType.contains(pt.Component__c)
               && pt.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
               && pt.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED
               && (mapOfOldPTrackings.get(pt.Id).Status__c != pt.Status__c 
                   || mapOfOldPTrackings.get(pt.Id).Status_Detail__c != pt.Status_Detail__c)
              )
              {
                  //adding the Production tracking Id in Set
                  setOfProductionTrackingIds.add(pt.Id);
              }
        }

        //Checking is size of set
        if(setOfProductionTrackingIds.size() > 0)
        {
            //List of Inventory/ Inventroy Transactions for Inserting
            Map<Id, Inventory__c> mapOfPTWithInventoriesToBeInserted = new Map<Id, Inventory__c>();
            Map<Id, Inventory_Transaction__c> mapOfPTWithInventoryTxToBeInserted = new Map<Id, Inventory_Transaction__c>();

            for(Production_Tracking__c pt : [Select Id,Name,Job_Ticket_MtM__r.Job_Ticket__r.Project__r.Institution__c,
                                             Job_Ticket_MtM__c,Job_Ticket_MtM__r.Job_Ticket__r.Name, Job_Ticket_MtM__r.Component_Code__c,
                                             Mail_Shop_Vendor__c, Print_Quantity_Planned__c, Job_Ticket_MtM__r.Component_Counter_Id__c,
                                             (Select Id, Inventory__c, Inventory__r.Inventory_Control_Number__c, Quantity__c, Quantity_Requested__c from Inventory_Transactions__r)
                                             from Production_Tracking__c Where Id IN : setOfProductionTrackingIds])
            {
                
                if(pt.Inventory_Transactions__r.size() > 0){
                    
                    for(Inventory_Transaction__c invTx : pt.Inventory_Transactions__r){
                        
                        if((invTx.Inventory__r.Inventory_Control_Number__c.contains(pt.Job_Ticket_MtM__r.Component_Code__c) 
                            || invTx.Inventory__r.Inventory_Control_Number__c.contains(pt.Job_Ticket_MtM__r.Component_Counter_Id__c))
                           && (invTx.Quantity__c != pt.Print_Quantity_Planned__c || invTx.Quantity_Requested__c != pt.Print_Quantity_Planned__c)
                          ){
                              //Update the fields of inventory transaction record
                              mapOfPTWithInventoryTxToBeInserted.put(pt.Id, new Inventory_Transaction__c(Id = invTx.Id, Quantity__c = pt.Print_Quantity_Planned__c, Quantity_Requested__c = pt.Print_Quantity_Planned__c));
                          }
                    }
                }
                else
                {
                    //populating the fields of inventory record
                    mapOfPTWithInventoriesToBeInserted.put(pt.Id, new Inventory__c(Production_Tracking__c = pt.Id, Institution__c = pt.Job_Ticket_MtM__r.Job_Ticket__r.Project__r.Institution__c,
                                                                                   Assigned_Vendor__c = pt.Mail_Shop_Vendor__c,
                                                                                   Job_Ticket_MtM__c = pt.Job_Ticket_MtM__c,
                                                                                   Inventory_Control_Number__c = pt.Job_Ticket_MtM__r.Job_Ticket__r.Name + '-' + pt.Job_Ticket_MtM__r.Component_Code__c));
                    //populating the fields of inventory transaction record
                    mapOfPTWithInventoryTxToBeInserted.put(pt.Id, new Inventory_Transaction__c(Production_Tracking__c = pt.Id, Requested_By__c = CURRENT_LOGIN_USER_ID,
                                                                                               Transaction_Type__c = Constants.INVENTORY_TX_TYPE_PRINT_REQUEST_FROM_EAB, 
                                                                                               Status__c = Constants.INVENTORY_TX_STATUS_REQUESTED, 
                                                                                               Original_Vendor__c =  pt.Mail_Shop_Vendor__c,
                                                                                               Job_Ticket_MtM__c = pt.Job_Ticket_MtM__c, 
                                                                                               Quantity__c = pt.Print_Quantity_Planned__c,
                                                                                               Quantity_Requested__c = pt.Print_Quantity_Planned__c,
                                                                                               RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_PRINT_REQUEST));
                }
            }
            
            //checking the size of List
            if(mapOfPTWithInventoriesToBeInserted.size() > 0 && mapOfPTWithInventoriesToBeInserted.values().size() > 0){
                Insert mapOfPTWithInventoriesToBeInserted.values();
            }
            
            //checking the size of List
            if(mapOfPTWithInventoryTxToBeInserted.size() > 0 && mapOfPTWithInventoryTxToBeInserted.keySet().size() > 0 && mapOfPTWithInventoryTxToBeInserted.values().size() > 0){
                
                for(Id ptId : mapOfPTWithInventoryTxToBeInserted.keyset()){
                    
                    if(mapOfPTWithInventoriesToBeInserted != null && mapOfPTWithInventoriesToBeInserted.size() > 0 && mapOfPTWithInventoriesToBeInserted.containsKey(ptId) && mapOfPTWithInventoriesToBeInserted.get(ptId) != null ){
                    	mapOfPTWithInventoryTxToBeInserted.get(ptId).Inventory__c = mapOfPTWithInventoriesToBeInserted.get(ptId).Id;    
                    }
                    
                }
                Upsert mapOfPTWithInventoryTxToBeInserted.values();
                createInventoryAndTransForPrintPTHasExecuted = true;
            }
        }
    }

    
   /**
    *  Purpose         :    dynamically get fields from field sets on Creative Package & related records
    * 
    *  Revision Logs   :    V_1.0 - 04/26/2021 - CR-20210325-15028 - Created By Mahendra Swarnkar
    *                     
    **/
    public static List<String> getCreativePackageCounterIds(Production_Tracking__c pTracking) 
    {
        Id jobTicketId = pTracking.Job_Ticket__c;
        Id creativePackageId = pTracking.Creative_Package__c; 
        
        List<String> listCreativePackageCounterIds = new List<String>();
        if(creativePackageId != null)
        {
            String cpQuery = 'SELECT Id, Creative_Package_Counter_Id__c' 
                + ' FROM Creative_Package__c ' 
                +  ' WHERE Id = :creativePackageId';    
            
            for(Creative_Package__c cp : database.query(cpQuery))
            {
                If(cp.Creative_Package_Counter_Id__c != null )
                    listCreativePackageCounterIds.add(cp.Creative_Package_Counter_Id__c);
            }
        }
        return listCreativePackageCounterIds;
    }
    
    public static List<Recipient_Batch__c> getReceipientBatchIds(Production_Tracking__c pTracking) 
    {
        Id jobTicketId = pTracking.Job_Ticket__c;
        Id creativePackageId = pTracking.Creative_Package__c; 
        Id ProtrackingId = pTracking.Id;
        
        List<Recipient_Batch__c> listReceipientBatchIds = new List<Recipient_Batch__c>();
        if(creativePackageId != null)
        {
            String rbQuery = 'SELECT Id,Production_Tracking__c, Recipient_Batch_Id__c, Type__c, Data_Posted_Quantity__c' 
                + ' FROM Recipient_Batch__c ' 
                + ' WHERE Recipient_Batch_Id__c != null '
                + ' AND Production_Tracking__c != null AND Production_Tracking__r.Creative_Package__c != null '
                + ' AND Production_Tracking__r.Creative_Package__c =: creativePackageId '
                + ' AND Production_Tracking__r.RecordType.DeveloperName = \''+ Constants.PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP +'\''
                + ' AND Production_Tracking__r.Job_Ticket__c != null AND Production_Tracking__r.Job_Ticket__r.Drop_Type__c =  \''+System.Label.DROP_TYPE_ON_DEMAND+'\''
                + ' ORDER BY Data_Posted_Date_Time__c DESC, CreatedDate DESC '; 
            
            for(Recipient_Batch__c rb : database.query(rbQuery))
            {
                listReceipientBatchIds.add(rb); 
            }
        }
        return listReceipientBatchIds;
    }
    
    public static List<Mail_Package__c> getMailPackageAndRelatedRecords(Production_Tracking__c pTracking) 
    {
        Id creativePackageId = pTracking.Creative_Package__c; 
        
        //dynamically create SOQL to get Job Ticket, Job Ticket MtM, production tracking
        String mailPackageQuery = 'SELECT Id, Mail_Package_Counter_Id__c, Mail_Copy__c, Mail_Copy__r.Mail_Copy_Counter_Id__c, (Select Id, Package_Component_Counter_Id__c, Component_Type__c, Component_Counter_Id__c from Package_Component_MtMs__r)' 
            + ' FROM Mail_Package__c ' 
            +  ' WHERE Creative_Package__c != null AND Creative_Package__c = : creativePackageId';  
        
        return database.query(mailPackageQuery);
    }
    
    //Added By - Abhinav Sharma - 10/19/2021 - CR-20210924-15459 - Check Inventory asscoiated with PT or not
    public static void checkInventroyAssociatedWithPT(List<Production_Tracking__c> newProductionTrackings, 
                                                                        Map<Id, Production_Tracking__c> mapOfOldPTrackings) 
    {
        Map<Id, Production_Tracking__c> mapOfProductionTrackingToBeUpdated = new Map<Id, Production_Tracking__c>();        
        
        for(Production_Tracking__c prodTrack : [Select Id, RecordTypeId, Mail_Shop_Vendor__c, Component_Code__c,
                                                Job_Ticket_MtM__r.Component_Counter_Id__c,
                                                Data_Posted_Quantity__c, No_Inventory_Associated__c From Production_Tracking__c
                                                Where Id IN :newProductionTrackings])
        {
            
            //get old map record
            Production_Tracking__c oldPTRec = new Production_Tracking__c();
            if(mapOfOldPTrackings != null) oldPTRec = mapOfOldPTrackings.get(prodTrack.Id);
            
            if(prodTrack.recordTypeId == PRODUCTION_TRACKING_RT_ID_MAIL_SHOP 
               && prodTrack.Mail_Shop_Vendor__c != null && prodTrack.Data_Posted_Quantity__c != null
               && (mapOfOldPTrackings == null 
                || (mapOfOldPTrackings != null 
                    && (
                        (oldPTRec.Mail_Shop_Vendor__c == null && prodTrack.Mail_Shop_Vendor__c != oldPTRec.Mail_Shop_Vendor__c)
                        || prodTrack.Data_Posted_Quantity__c != oldPTRec.Data_Posted_Quantity__c
                        || prodTrack.recordTypeId != oldPTRec.recordTypeId
                    )
                   )
               )
              )
            {
                //add the component code and mark No_Inventory_Associated__c as true
                prodTrack.No_Inventory_Associated__c = true;
                mapOfProductionTrackingToBeUpdated.put(prodTrack.Id, prodTrack);
            }
        }
        
        if(mapOfProductionTrackingToBeUpdated.size() > 0  && mapOfProductionTrackingToBeUpdated.keySet().size() > 0)
        {
            List<Inventory_Transaction__c> inventoryTransToBeCreated = new List<Inventory_Transaction__c>();
            
            for(Inventory__c inv : [Select Inventory_Control_Number__c, Assigned_Vendor__c, Production_Tracking__c,
                                    (Select Id, Mailshop_Production_Tracking__c, Quantity_to_Allocate__c From Inventory_Transactions__r) 
                                    from Inventory__c 
                                    Where Assigned_Vendor__c != null AND Production_Tracking__c != null
                                    AND Inventory_Control_Number__c != null
                                    AND Production_Tracking__c IN :mapOfProductionTrackingToBeUpdated.keySet()])
            {
				if(mapOfProductionTrackingToBeUpdated.containsKey(inv.Production_Tracking__c) 
                   && inv.Assigned_Vendor__c == mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Mail_Shop_Vendor__c
                   && (inv.Inventory_Control_Number__c.contains(mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Component_Code__c)
                       || inv.Inventory_Control_Number__c.contains(mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Job_Ticket_MtM__r.Component_Counter_Id__c)
                      )
                )
                {
                    if(inv.Inventory_Transactions__r.size() > 0){
                        for(Inventory_Transaction__c incTx :inv.Inventory_Transactions__r){
                            if(incTx.Mailshop_Production_Tracking__c == mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Id 
                               && incTx.Quantity_to_Allocate__c != mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Data_Posted_Quantity__c
                              )
                            {
                                inventoryTransToBeCreated.add(new Inventory_Transaction__c(Id = incTx.Id,
                                                                                           Quantity_to_Allocate__c = mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Data_Posted_Quantity__c
                                                                                          ));
                            }
                        }
                    }
                    else{
                        
                        inventoryTransToBeCreated.add(new Inventory_Transaction__c(RecordTypeId = Constants.RECORD_TYPE_ALLOCATION_REQ_ID,
                                                                                   Requested_By__c = CURRENT_LOGIN_USER_ID,
                                                                                   Transaction_Type__c = Constants.INVENTORY_TX_TYPE_ALLOCATION_REQ_FROM_EAB, 
                                                                                   Status__c =Constants.INVENTORY_TX_STATUS_ALLOCATED, Inventory__c = inv.Id,
                                                                                   Quantity_to_Allocate__c = mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).Data_Posted_Quantity__c, 
                                                                                   Mailshop_Production_Tracking__c = inv.Production_Tracking__c));
                    }
                    
                   mapOfProductionTrackingToBeUpdated.get(inv.Production_Tracking__c).No_Inventory_Associated__c = false;
                }
            } 
            
            if(mapOfProductionTrackingToBeUpdated.size() > 0 && mapOfProductionTrackingToBeUpdated.values().size() > 0){
                
                Update mapOfProductionTrackingToBeUpdated.values();
            }
            
            if(inventoryTransToBeCreated.size() > 0){
                
                Upsert inventoryTransToBeCreated;
            }
        }
    }
    
    
    /**
     *  Purpose         :   wrapper class to parse token authorization callout response from sepire
     * 
     *  Revision Logs   :   V_1.0 - CR-20200619-14206 - 06/19/2020 - Victor Hanson - created
     *                     
    **/
    public class Result
    {
        public string accessToken { get; set; }
        public string encryptedAccessToken { get; set; }
        public Integer expireInSeconds { get; set; }
        public Boolean shouldResetPassword { get; set; }
        public Integer userId { get; set; }
        public Boolean requiresTwoFactorVerification { get; set; }
        public string refreshToken { get; set; }
        public Integer refreshTokenExpireInSeconds { get; set; }
    }
    
    public class authTokenWrapper
    {
        public Result result { get; set; }
        public Object targetUrl { get; set; }
        public Boolean success { get; set; }
        public Error error { get; set; }
        public Boolean unAuthorizedRequest { get; set; }
    }
    
    public class Error
    {
        public Integer code { get; set; }
        public String message { get; set; }
        public String details { get; set; }
    }
    
    //CR-20210920-15450 - 10/25/2021 - Subhash - Added calling new mehtod "unLockProductionTrackingRecordOnBackTracking"
    public static void unLockProductionTrackingRecordOnBackTracking(List<Production_Tracking__c> pTrackings, Map<Id, Production_Tracking__c> mapOldPTracking) {
    	
        List<String> setStatusDetails = new List<String>();
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_FILE_ISSUE);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_ERROR);
        setStatusDetails.add(Constants.PRODUCTION_TRACKING_STATUS_DETAIL_FILE_RECEIVED);
        
        List<ID> listUnlockProductionTrackingRecordIds = new List<ID>();
        //Set<String> setStatus = new Set<String>{'Proof','Live Proof','Ready for Print','Mailed'};
        List<String> setStatus = new List<String>();
        setStatus.add(Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF);
        setStatus.add(Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT);
        setStatus.add(Constants.PRODUCTION_TRACKING_STATUS_MAILED);
        setStatus.add(Constants.PRODUCTION_TRACKING_STATUS_PRINTED);
        List<Production_Tracking__c> listProdYrakingToUpdate = new List<Production_Tracking__c>();
        
        for( Production_Tracking__c pTrack: pTrackings){
            
            Production_Tracking__c ptToUdate = new Production_Tracking__c(Id = pTrack.Id);
            if(mapOldPTracking != null && pTrack.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED 
                && (pTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF || pTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF ) 
                && (pTrack.Status__c != mapOldPTracking.get(pTrack.ID).Status__c || pTrack.Status_Detail__c != mapOldPTracking.get(pTrack.ID).Status_Detail__c)
                && ((setStatusDetails.contains(mapOldPTracking.get(pTrack.ID).Status_Detail__c) && setStatus.contains(mapOldPTracking.get(pTrack.ID).Status__c)) 
                    || mapOldPTracking.get(pTrack.ID).Status__c == Constants.PRODUCTION_TRACKING_STATUS_MAILED
                    || mapOldPTracking.get(pTrack.ID).Status__c == Constants.PRODUCTION_TRACKING_STATUS_PRINTED
                    || mapOldPTracking.get(pTrack.ID).Status__c == Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT
                    || ( pTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF 
                        && pTrack.Status__c == mapOldPTracking.get(pTrack.ID).Status__c
                        && pTrack.Status_Detail__c != mapOldPTracking.get(pTrack.ID).Status_Detail__c )
                   ))
            {
                
                if(Approval.isLocked(pTrack.id)){
                    ptToUdate.is_Locked__c = false;
                }
                listUnlockProductionTrackingRecordIds.add(pTrack.Id);
                
                ptToUdate.Live_Proof_Approval_Status__c = null;
                ptToUdate.Live_Proof_File_Received_DateTime__c = null;
                ptToUdate.Live_Proof_Pending_Approval_DateTime__c = null;
                ptToUdate.ReadyforPrint_LP_Approval_DateTime__c = null;
                ptToUdate.Data_Due_to_Vendor_Date__c = null;
                ptToUdate.Live_Proof_Approval_Due_Date__c = null;
                //ptToUdate.IS_Status_Artwork_Proof_Not_Required__c = false;

                if(pTrack.Status__c == Constants.PRODUCTION_TRACKING_STATUS_PROOF && pTrack.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED ){
                	ptToUdate.Proof_Approval_Status__c = null;
                    ptToUdate.Proof_File_Received_DateTime__c = null;
                    ptToUdate.Proof_Pending_Approval_DateTime__c = null;
                    ptToUdate.Proof_Approved_DateTime__c = null;
                    ptToUdate.Art_Due_to_Vendor_Date__c = null;
                    ptToUdate.Proof_Approval_Date__c = null;
                    ptToUdate.Vendor_Mail_Date__c = null;
                    ptToUdate.Mail_Date_Change_Reason__c = null;
                }
                listProdYrakingToUpdate.add(ptToUdate);
            }
        }
        
        if(listUnlockProductionTrackingRecordIds.size() > 0){
			
            //system.Approval.unlock(listUnlockProductionTrackingRecordIds,false);
            
            //Set to hold the Process Instanceids
			Set<Id> setProcessInstanceIds = new Set<Id> ();
          
            //Query all the existing Approval Process Instances for Production Tracking
			for(ProcessInstance pi : [SELECT Id, TargetObjectId 
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId IN : listUnlockProductionTrackingRecordIds 
                                            AND Status='Pending']
			) {
				//Populate the set
            	setProcessInstanceIds.add(pi.Id);
			}
            
            //Check for size
            if(setProcessInstanceIds.size() > 0) {
        
                //Query all the ProcessInstanceWorkitems related to the existing approval Process Instances
        		for(ProcessInstanceWorkitem workItem : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId FROM ProcessInstanceWorkitem 
                                                        where ProcessInstanceId IN : setProcessInstanceIds]
                ) {
                    //String to hold the id
                    String OriginalActorIdstring = workItem.OriginalActorId;
                    
                    //Check for the Prefix and then reject the existing Approval Process (00G --> Public Group) 
                    if(!OriginalActorIdstring.contains('00G')) {
                    
                        //Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                        Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
                        req1.setWorkItemId(workItem.id);
                        req1.setAction('Reject'); // This means to Reject Approval Request
                        req1.setComments('BackTracking of PT by end User ');
                        
                        Approval.ProcessResult result = Approval.process(req1);
                        
                    }
				}   
      		}
        }
        if(listProdYrakingToUpdate.size() > 0){
            update listProdYrakingToUpdate;
        }
    }
	
    
    /**
    *  Purpose         :	Gets the authorization token for ColorArt vendor
    *
    *  Revision Logs   :	V_1.1 - 04/28/2022 - - Shalu Sharma - Created via CR-20220428-16145 - Get Token Based Request Additional Changes for the ColorArt Vendor 
    *                     
    **/
    public static String getAuthTokenForColorArtVendor(API_Endpoints__mdt apiEndpoint) 
    {
        if(apiEndpoint != null)
        {
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            req.setEndpoint(apiEndpoint.Authorize_Endpoint_URL__c);
            req.setMethod(Constants.HTTP_REQUEST_POST_TYPE);
            req.setTimeout(120000);
            
            if (apiEndpoint.Custom_Headers__c != null) 
            {
                try 
                {
                    Map<String, String> customHeaderMap = (Map<String, String>)JSON.deserializeStrict(apiEndpoint.Custom_Headers__c, Map<String, String>.class);
                    for (String headerKey : customHeaderMap.keySet()) 
                    {
                        String headerValue = customHeaderMap.get(headerKey);
                        req.setHeader(headerKey, headerValue);
                    }
                }
                catch(Exception e) 
                {
                    throw new customException('Error when attempting to add custom headers.  Not valid: \'' +  + '\'');
                }
            }
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(apiEndpoint.Authorization_Body__c);
            res = h.send(req);
            if(!Test.isRunningTest())
            {
                try 
                {
                    AuthTokenWrapperForColorArtVendor tokenWrapper;
                    tokenWrapper = (AuthTokenWrapperForColorArtVendor)JSON.deserialize(res.getBody(), AuthTokenWrapperForColorArtVendor.class);
                    if(tokenWrapper != null)
                    {
                    	return tokenWrapper.access_token;    
                    }
                    else
                    {
                        return null;
                    }
                }
                catch(Exception e) 
                {
                    throw new customException('Error deserializing auth token:' + e.getMessage() 
                                              + '\r\n\r\nStack Trace:\r\n' + e.getStackTraceString() 
                                              + '\r\n\r\nResponse Body:\r\n' + res.getBody()
                                              + '\r\n\r\nRequest Endpoint:\r\n' + req.getEndpoint()
                                              + '\r\n\r\nRequest Body:\r\n' + req.getBody());
                }
            }
            else
            {
                return null;
            }
        }
        else 
        {
            return null;
        }
    }
	
   	/**
     *  Purpose         :   wrapper class to parse token authorization callout response from ColorArt
     * 
     *  Revision Logs   :   V_1.1 - 04/28/2022 - - Shalu Sharma - Created via CR-20220428-16145 - Get Token Based Request Additional Changes for the ColorArt Vendor
     *                     
    **/
    public class AuthTokenWrapperForColorArtVendor
    {
        public string access_token { get; set; }
        public string token_type { get; set; }
        public Integer expires_in { get; set; }
    }
}