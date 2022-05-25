/**
 *  Purpose         :	Job Ticket REST service
 *
 *  Revision Logs   :	V_1.0 - 03/02/2020 - Victor Hanson - Created
 * 			V_1.1 - 05/18/2020 - CR-20200515-14047 - Victor Hanson - Added suppressionCount & modified updateJobTicket to support live proof approval
 * 			V_1.2 - 05/27/2020 - CR-20200527-14113 - Victor Hanson - Modified name of Artifact Type 'Live Proof Data' to 'Live Proof' and update createArtifacts()
 * 			V_1.3 - 05/29/2020 - CR-20200529-14122 - Victor Hanson - Updated class to without sharing due to issues vendor attempting to update while record is pending approval
 * 			V_1.4 - 06/01/2020 - CR-20200601-14128 - Victor Hanson - updateJobTicket - Status Detail translation from vendor (PrintingStarted -> Printing Started)
 * 		        V_1.5 - 06/08/2020 - CR-20200608-14153 - Victor Hanson - added component code formula reference
 *                      V_1.6 - 07/06/2020 - CR-20200701-14243 - Abhinav Sharma - Add fields to support cost tracking
 *			V_1.7 - 07/24/2020 - CR-20200721-14348 - Abhinav Sharma - Add actualMailDate field
 *			V_1.8 - 08/14/2020 - CR-20200814-14432 - Victor Hanson - added printedQuantity
 *                      V_1.9 - 09/06/2020 - CR-20200902-14488 - Victor Hanson - added UpdateProductionTracking
 * 			V_2.0 - 10/18/2020 - CR-20201012-14597 - Victor Hanson - added Error reference
 *			V_2.1 - 10/16/2020 - CR-20200917-14523 - Calculate Unit Cost & CPM from Print Total
 *			V_2.2 - 04/27/2021 - CR-20210325-15027 - Mahendra Swarnkar
 *			V_2.3 - 04/21/2021 - CR-20210420-15089 - Victor Hanson
 *			V_2.4 -            - CR-20210310-14983 - Abhinav Sharma 
 *                      V_2.5 - 06/16/2020 - CR-20210326-15039 - Nikita Kumari - Production Tracking update Status Detail = Mail Date Confirmed when callout is received from the Vendor
 * 			V_2.6 - 10/22/2021 - CR-20210924-15459 - Abhinav Sharma - Update the "inventoryUpdate" and "inventoryReceived" callout. 
 *        		V_2.7 - 4/14/2022 - CR-20220302-15977 - Shalu Sharma - Update "CreateProductionTrackingBatch" callout.
 * 
**/


@RestResource(urlMapping='/v1/JobTicket/*')

global without sharing class JobTicketService {
    
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Starts from here
    public static final String REQ_TYPE_Create_Production_Tracking_Batch = 'CreateProductionTrackingBatch';
    public static final Set<String> setJobTIcketClosedStatus = new Set<String>{Constants.JOB_TICKET_STATUS_COMPLETE, Constants.JOB_TICKET_STATUS_CANCELLED};
    public static final Set<String> setProductionTrackingStatus = new Set<String>{Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF, Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT, Constants.PRODUCTION_TRACKING_STATUS_MAILED, Constants.PRODUCTION_TRACKING_STATUS_CANCELLED};
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027  -End here
    
    //Added By - Shalu Sharma - 4/14/2022 - CR-20220302-15977 - Added setOfPTStatuses for PT
    public static final Set<String> setOfPTStatuses = new Set<String>{Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                                      Constants.PRODUCTION_TRACKING_STATUS_APPROVED_BY_CLIENT,
                                                                      Constants.PRODUCTION_TRACKING_STATUS_PROOF};
    
    //static final variables
    public static final String NO_RECORDS_RETURNED = 'No records match that Id.';
    public static final String REQ_TYPE_READY_FOR_PROOF_APPROVAL = 'ReadyForProofApproval';
    public static final String REQ_TYPE_READY_FOR_LIVEPROOF_APPROVAL = 'ReadyForLiveProofApproval';
    public static final String REQ_TYPE_UPDATE_JOB_STATUS = 'UpdateJobStatus';
    public static final String REQ_TYPE_FILE_TRANSFER_STATUS = 'FileTransferStatus';
    //11/15/2020 - Victor Hanson - CR-20201012-14597 - updated to include ready to print
    public static final String REQ_TYPE_READY_TO_PRINT = 'ReadyToPrint';
    //10/18/2020 - CR-20201012-14597 - Victor Hanson - added
    public static final String REQ_TYPE_ERROR = 'Error';
    public static final String REQ_TYPE_MAILED = 'Mailed';
    
    //04/21/2021 - CR-20210420-15089 - Victor Hanson - added - start
    public static final String REQ_TYPE_INVENTORY_PROOF_READY_FOR_APPROVAL = 'InventoryProofReadyForApproval';
    public static final String REQ_TYPE_INVENTORY_PRINTED = 'InventoryPrinted';
    
    public static final String REQ_TYPE_INVENTORY_SHIPPED = 'inventoryShipped';
    public static final String REQ_TYPE_INVENTORY_SHIPPED_NOTIFICATION = 'inventoryShippedNotification';
    public static final String REQ_TYPE_INVENTORY_RECEIVED = 'inventoryReceived';
    public static final String REQ_TYPE_INVENTORY_UPDATE = 'inventoryUpdate';
    
    public static final String INVENTORY_TRANSACTION_STATUS_PRINTED = 'Printed - In Inventory';
    public static final String INVENTORY_TRANSACTION_STATUS_TRANSFER_IN_PROGRESS = 'Transfer In Progress';
    public static final String INVENTORY_TRANSACTION_STATUS_TRANSFER_REQUESTED = 'Transfer Requested';
    public static final String INVENTORY_TRANSACTION_STATUS_TRANSFERRED = 'Transferred';
    public static final String INVENTORY_TRANSACTION_STATUS_ADJUSTMENT = 'Adjustment';
    //04/21/2021 - CR-20210420-15089 - Victor Hanson - added - end
    
    //10/22/2021 - CR-20210924-15459 - Abhinav Sharma - added
    public static final String INVENTORY_TRANSACTION_STATUS_MAILED = 'Mailed';
    public static final String INVENTORY_TRANSACTION_STATUS_SPOILED = 'Spoiled';
    //10/22/2021 - CR-20210924-15459 - Abhinav Sharma - end
    
    public static final String STATUS_SUCCESS = 'success';
    public static final String STATUS_ERROR = 'error';
    
    //static finals for file types
    public static final String FILE_TYPE_ARTWORK_PROOF = 'artwork_proof';
    public static final String FILE_TYPE_LIVE_PROOF = 'live_proof';
    public static final String FILE_TYPE_MAILING_VALIDATION_RESULTS = 'mailing_list_validation_results';
    public static final String FILE_TYPE_MAILING_RESULTS = 'mailing_list_results';
    //11/15/2020 - Victor Hanson - CR-20201012-14597 - added ready to print
    public static final String FILE_TYPE_READY_TO_PRINT = 'ready_to_print';
    
    //09/06/2020 - CR-20200902-14488 - Victor Hanson
    public static final String REQ_TYPE_UPDATE_PRODUCTION_TRACKING = 'UpdateProductionTracking';
    
    //11/15/2020 - Victor Hanson - CR-20201012-14597 - updated to include ready to print
    public static Map<String, String> mapFileTypeToArtifactType {
        get {
            if (mapFileTypeToArtifactType == null) {
                mapFileTypeToArtifactType = new Map<String, String>{ 
                	FILE_TYPE_ARTWORK_PROOF => Constants.ARTIFACT_TYPE_ARTWORK_PROOF,
                	FILE_TYPE_LIVE_PROOF => Constants.ARTIFACT_TYPE_LIVE_PROOF,
                	FILE_TYPE_MAILING_VALIDATION_RESULTS => Constants.ARTIFACT_TYPE_MAILING_LIST_VALIDATION_RESULT,
                    	FILE_TYPE_MAILING_RESULTS => Constants.ARTIFACT_TYPE_MAILING_LIST_RESULT,
                    	FILE_TYPE_READY_TO_PRINT => Constants.ARTIFACT_TYPE_READY_TO_PRINT
                };
            }
            return mapFileTypeToArtifactType;
        }
        set;
    }
    
    //define fields for each type of object
    public static String jobTicketFields = setToCommaDelim(util.getFieldSetFieldsAPINames('Job_Ticket__c', 'Vendor_JT_Callout_Field_Set'));
    
    //06/08/2020 - CR-20200608-14153 - Victor Hanson - added component code formula reference
    public static String componentFields = '(SELECT Id, Component_Code_Formula__c,' + getJobTicketMtMFields() + ' FROM Job_Ticket_MtM__r)';
    
    public static String getProdTrackingFields(String prodTrackingId) {
        String pTrackingFields = '(SELECT ' + setToCommaDelim(util.getFieldSetFieldsAPINames('Production_Tracking__c', 'Vendor_Prod_Tracking_Field_Set')) 
            + ' FROM Fulfillment_Tracking__r ';
        if (prodTrackingId != null) pTrackingFields += ' WHERE Id=\'' + prodTrackingId + '\'';
        pTrackingFields += ')'; //close the subquery
        return pTrackingFields;
    }
    
    /**
     *  Purpose         :   Returns comma-delimited list of fields defined in Job Ticket MtM Field Sets
     *
     *  Revision Logs   :   V_1.0 - Created - 03/02/2020 - Victor Hanson - Created
     *                     
    **/
    public static String getJobTicketMtMFields() {
        Map<String, Set<String>> fieldSetMap = Util.sobjectFieldSetNameWithSetOfFieldsAPIName('Job_Ticket_MtM__c');
        Set<String> uniqueFields = new Set<String>();
        for (Set<String> flds : fieldSetMap.values()) {
            uniqueFields.addAll(flds);
        }
        return String.join(new List<String>(uniqueFields), ',');
    }
    
    /**
     *  Purpose         :   Returns comma-delimited String from a Set of Strings
     *
     *  Revision Logs   :   V_1.0 - Created - 03/02/2020 - Victor Hanson - Created
     *                     
    **/
    public static String setToCommaDelim(Set<String> setStrings) {
        return String.join(new List<String>(setStrings), ',');
    }
    
    /**
     *  Purpose         :   Return SOQL query with job ticket, artifact, fulfillment, and Job Ticket MtM fields
     *
     *  Revision Logs   :   V_1.0 - Created - 03/02/2020 - Victor Hanson - Created
     *                     
    **/
    public static String getJobTicketSOQL(String recordId, String prodTrackingId) {
        
        String whereClause = 'WHERE Id = \'' + recordId + '\'';
        
        //dynamically create SOQL
        String qry = 'SELECT ' + jobTicketFields + ',' + getProdTrackingFields(prodTrackingId) + ',' + componentFields + ' FROM Job_Ticket__c ' + ' ' + whereClause;
        
        return qry;
    }
    
    /**
     *  Purpose         :   Returns the requested Job Ticket(s) and related records
     *
     *  Revision Logs   :   V_1.0 - Created - 03/02/2020 - Victor Hanson - Created
     *                     
    **/
    @HttpGet
    global static Job_Ticket__c getJobTicket() {
        
        //get the record id
        RestRequest req = RestContext.request; 
        RestResponse res = Restcontext.response;
        String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //get list of Component fields
        String qry = getJobTicketSOQL(recordId, null);
        
        List<Job_Ticket__c> jobTickets = database.query(qry);
        
        if (jobTickets.size() == 0) {
            res.statusCode = 500;
            throw new customException(NO_RECORDS_RETURNED + ' (' + recordId + ')');
        }
        else res.statusCode = 200;
        
        return jobTickets[0];
    }
     
    /**
     *  Purpose         :	Updates job ticket/production tracking record based on callout details
     *
     *  Revision Logs   :	V_1.0 - 03/02/2020 - Victor Hanson - Created
     * 				V_1.1 - 05/19/2020 - Victor Hanson - CR-20200515-14047 - Added logic for live proof approval callout
     * 				V_1.2 - 06/01/2020 - Victor Hanson - CR-20200601-14128 - test status detail custom mapping
     * 				V_1.3 - 08/14/2020 - Victor Hanson - CR-20200814-14432 - added printedQuantity
     *              		V_1.4 - 09/06/2020 - Victor Hanson - CR-20200902-14488 - added UpdateProductionTracking
     * 				V_1.5 - 10/16/2020 - Abhinav Sharma - CR-20200917-14523 - Calculate Unit Cost & CPM from Print Total (Comment Unit Cost Field)
     *                     
    **/
    @HttpPost
    global static void updateJobTicket() {
        /*
	 * 1) Convert JSON to job ticket
         * 2) Check for the fields (ie: Status, Errors, etc) that can be updated by the vendor for each related object (ie: Job Ticket, Artifact, Production Tracking)
         * 3) Update the record(s) that need updated 
	 */
        responseWrapper resWrapper = new responseWrapper();
        
        RestRequest req = RestContext.request; 
        RestResponse res = Restcontext.response;
        
        //get the type of request
        String requestType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        //parse the request using the request wrapper
        requestWrapper reqWrapper = (requestWrapper) System.JSON.deserialize(req.requestBody.toString(), requestWrapper.class);
        
        //String jobTicketId = reqWrapper.jobTicketId;
        String productionTrackingId = reqWrapper.productionTrackingId;
        
        Production_Tracking__c pTracking;
        Id cPKGJobticketID;
        Id cPKGPTID;
        
        //initially set status code to 200.  this can change later if we have exceptions
        res.statusCode = 200;
        
        //set a save point in case we need to roll back
        Savepoint sp = Database.setSavepoint();
        
        JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = true;
        
        //Modified By Abhinav Sharma - 10/16/2020 - CR-20200917-14523
        try {
            //get the job ticket details
            if (productionTrackingId != null) {
                //11/24/2020 - CR-20201012-14597 - Victor Hanson - added received by vendor count & final count, JT MtM
                List<Production_Tracking__c> pts = [SELECT Id, Job_Ticket__c, Job_Ticket__r.Drop_Type__c,  Status_Detail__c, Initial_Count__c, Failed_Import_Count__c, Mailed_Students__c, 
                                                    Mailed_Seeds__c, Suppressed_Record_Count__c, Imported_Seeds__c, Imported_Students__c,Job_Ticket_MtM__c,
                                                    /*Unit_Cost__c,*/ Postage_Total__c, Invoice_Number__c, Freight__c, Postage_Per_Piece__c, Mail_Cost_Total__c,
                                                    Received_By_Vendor_Count__c, Final_Count__c, Proof_Generation__c, Status__c
                                                    FROM Production_Tracking__c WHERE Id = :productionTrackingId];
                if (pts.size() > 0)
                    pTracking = pts[0];
                else
                    throw new customException('Invalid productionTrackingId:' + productionTrackingId);
            }
            else {
                //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Added condition to check for the Creative Package request type. if So then do not throw the error
                if (requestType != null && !requestType.equalsIgnoreCase(REQ_TYPE_Create_Production_Tracking_Batch))
                    throw new customException('productionTrackingId cannot be null');
            }
            
            //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - added iff condition to populate the PT fields only of PT is not null
            if(pTracking != null) {
                //09/06/2020 - CR-20200902-14488 - Victor Hanson - fields below can be updated in multiple callouts, so no specific requestType is necessary
                if (reqWrapper.initialImportCount != null)
                    pTracking.Initial_Count__c = reqWrapper.initialImportCount;
                if (reqWrapper.failedImportCount != null)
                    pTracking.Failed_Import_Count__c = reqWrapper.failedImportCount;
                if (reqWrapper.suppressionCount != null)
                    pTracking.Suppressed_Record_Count__c = reqWrapper.suppressionCount;
                if (reqWrapper.seedImportCount != null)
                    pTracking.Imported_Seeds__c = reqWrapper.seedImportCount;
                if (reqWrapper.studentImportCount != null)
                    pTracking.Imported_Students__c = reqWrapper.studentImportCount;
                if (reqWrapper.qualitySampleCount != null)

                    pTracking.Imported_Quality_Samples__c = reqWrapper.qualitySampleCount;
                
                //11/24/2020 - CR-20201012-14597 - Victor Hanson - additional fields that can be updated in multiple callouts
                if (reqWrapper.receivedByVendorCount != null)
                    pTracking.Received_By_Vendor_Count__c = reqWrapper.receivedByVendorCount;
                if (reqWrapper.finalCount != null)
                    pTracking.Final_Count__c = reqWrapper.finalCount;
                if (reqWrapper.studentsMailed != null && reqWrapper.studentsMailed > 0)
                    pTracking.Mailed_Students__c = reqWrapper.studentsMailed;
                if (reqWrapper.seedsMailed != null && reqWrapper.seedsMailed > 0)
                    pTracking.Mailed_Seeds__c = reqWrapper.seedsMailed;
                if(reqWrapper.actualMailDate != null)
                    pTracking.Actual_Mail_Date__c = reqWrapper.actualMailDate;
                if (reqWrapper.totalPostage != null) 
                    pTracking.Postage_Total__c = reqWrapper.totalPostage;
                if (reqWrapper.invoiceNumber!= null) 
                    pTracking.Invoice_Number__c = reqWrapper.invoiceNumber;
            }
            
            if (requestType != null) {
                if (requestType.equalsIgnoreCase(REQ_TYPE_READY_FOR_PROOF_APPROVAL) || requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_PROOF_READY_FOR_APPROVAL)) {
                    //validate the correct files are present
                    boolean hasArtwork = false;
                    for (artifactWrapper aWrapper : reqWrapper.artifacts) {
                        if (aWrapper.fileType != null && aWrapper.fileType.equalsIgnoreCase(FILE_TYPE_ARTWORK_PROOF))
                            hasArtwork = true;
                    }
                    
                    if (!hasArtwork) {
                        throw new customException(REQ_TYPE_READY_FOR_PROOF_APPROVAL + ' requires fileType=' + FILE_TYPE_ARTWORK_PROOF);
                    }
                    
                    //Added By - Abhinav Sharma - CR-20210310-14983 - START FROM HERE
                    //When we receive the InventoryProofReadyForApproval call, the status detail should flip to Pending Approval.
                    if(requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_PROOF_READY_FOR_APPROVAL) 
                       && res != null && res.statusCode == 200) 
                    {
                        if(pTracking != null && pTracking.Id != null) 
                        {
                            pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL;
                            update pTracking;        
                        }
                    }
                    //END HERE
                }
                else if (requestType.equalsIgnoreCase(REQ_TYPE_READY_FOR_LIVEPROOF_APPROVAL)) {
                    //V_1.1 - 05/19/2020 - Victor Hanson - CR-20200515-14047 - Added logic for live proof approval callout
                    //validate the correct files are present
                    boolean hasLiveProofData = false;
                    for (artifactWrapper aWrapper : reqWrapper.artifacts) {
                        if (aWrapper.fileType != null && aWrapper.fileType.equalsIgnoreCase(FILE_TYPE_LIVE_PROOF))
                            hasLiveProofData = true;
                    }
                    
                    if (!hasLiveProofData) {
                        throw new customException(REQ_TYPE_READY_FOR_LIVEPROOF_APPROVAL + ' requires fileType=' + FILE_TYPE_LIVE_PROOF);
                    }
                }
                else if (requestType.equalsIgnoreCase(REQ_TYPE_FILE_TRANSFER_STATUS)) {
                    
                    //figure out which status detail to set on production tracking
                    if (reqWrapper.success) 
                        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_FILE_RECEIVED;
                    else if (!reqWrapper.success) 
                        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_FILE_ISSUE;
                    
                    update pTracking;
                }
                //11/15/2020 - CR-20201012-14597 - Victor Hanson - added
                else if (requestType.equalsIgnoreCase(REQ_TYPE_READY_TO_PRINT)) {
                    //validate the correct files are present
                    boolean hasReadyToPrintFile = false;
                    for (artifactWrapper aWrapper : reqWrapper.artifacts) {
                        if (aWrapper.fileType != null && aWrapper.fileType.equalsIgnoreCase(FILE_TYPE_READY_TO_PRINT))
                            hasReadyToPrintFile = true;
                    }
                    
                    if (!hasReadyToPrintFile) {
                        throw new customException(REQ_TYPE_READY_TO_PRINT + ' requires fileType=' + FILE_TYPE_READY_TO_PRINT);
                    }
                }
		
                //06/21/2021 - CR-20210525-15180 - Abhinav Sharma - Modified
                else if (requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_PRINTED)) 
                {
                    
                    pTracking.Print_Quantity_Actual__c = reqWrapper.printedQuantity;
                    pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PRINTED;
                    
                    //get Inventory Transaction related to this Production Tracking
                    List<Inventory_Transaction__c> invTransactions = [SELECT Id, Quantity__c, Status__c
                                                                      FROM Inventory_Transaction__c 
                                                                      WHERE Job_Ticket_MtM__c = :pTracking.Job_Ticket_MtM__c
                                                                      AND Status__c = :InventoryTransactionTriggerHelper.INVENTORY_TRANSACTION_STATUS_REQUESTED
                                                                      AND RecordTypeId = :InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_PRINT_REQUEST];
                    for (Inventory_Transaction__c invTransaction : invTransactions) 
                    {
                        invTransaction.Status__c = INVENTORY_TRANSACTION_STATUS_PRINTED;
                    }
                    update invTransactions;
                    
                    //update production tracking
                    update pTracking;
                    
                    //06/21/2021 - CR-20210525-15180 - Abhinav Sharma - Added
                    //Start from here
                    if(reqWrapper != null && String.isNotBlank(reqWrapper.inventoryTransactionId)) 
                    {
                        List<Inventory_Transaction__c> invTxns = [SELECT Id, Quantity_Printed__c
                                                                  FROM Inventory_Transaction__c 
                                                                  WHERE Id =: reqWrapper.inventoryTransactionId];
                        if(invTxns.size() > 0) 
                        {
                            invTxns[0].Quantity_Printed__c = reqWrapper.printedQuantity;
                            Util.BypassAllTriggers = true;
                            update invTxns;
                            Util.BypassAllTriggers = false;
                        }
                    }
                    //End here
                }
                //05/12/2021 - CR-20210310-14983 - Abhinav Sharma - Modified
                else if (requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_SHIPPED)) {
                    Inventory_Transaction__c invTransaction = (Inventory_Transaction__c) json.deserialize(req.requestBody.toString(), Inventory_Transaction__c.class);
                    invTransaction.Production_Tracking__c = reqWrapper.productionTrackingId;
                    invTransaction.Status__c = INVENTORY_TRANSACTION_STATUS_TRANSFER_IN_PROGRESS;
                    
                    if (reqWrapper.inventoryTransactionId == null) {
                        throw new customException('inventoryTransactionId is required when calling ' + REQ_TYPE_INVENTORY_SHIPPED);
                    }
                    invTransaction.Id = reqWrapper.inventoryTransactionId;
                    update invTransaction;
                }
                //05/12/2021 - CR-20210310-14983 - Abhinav Sharma - Modified
                else if (requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_RECEIVED)) {
                    Inventory_Transaction__c invTransaction = (Inventory_Transaction__c) json.deserialize(req.requestBody.toString(), Inventory_Transaction__c.class);
                    invTransaction.Production_Tracking__c = reqWrapper.productionTrackingId;
                    invTransaction.Status__c = INVENTORY_TRANSACTION_STATUS_TRANSFERRED;
                    
                    if (reqWrapper.inventoryTransactionId == null) {
                        throw new customException('inventoryTransactionId is required when calling ' + REQ_TYPE_INVENTORY_RECEIVED);
                    }
                    
                    invTransaction.Id = reqWrapper.inventoryTransactionId;
                    //Added by - Abhinav Sharma - 10/29/2021 - CR-20210924-15459 - Also update the source vendor status to Transferred
                    if(invTransaction.Id != null)
                    {
                        List<Inventory_Transaction__c> newInvTransactions = [SELECT Id, Old_Inventory__c, Rollup_Quantity__c FROM Inventory_Transaction__c 
                                                                     		WHERE ID =: invTransaction.Id AND Old_Inventory__c != null];  
                        if(newInvTransactions.size() > 0)
                        {
                            List<Inventory_Transaction__c> oldInvTransactions = [SELECT Id, Status__c, Old_Inventory__c, Rollup_Quantity__c FROM Inventory_Transaction__c 
                                                                                WHERE Inventory__c =: newInvTransactions[0].Old_Inventory__c 
                                                                                AND Status__c = 'Transfer Requested' 
                                                                                AND Rollup_Quantity__c =: (newInvTransactions[0].Rollup_Quantity__c * -1) ORDER BY CreatedDate ASC];
                            if(oldInvTransactions.size() > 0)
                            {
                                oldInvTransactions[0].Status__c = INVENTORY_TRANSACTION_STATUS_TRANSFERRED; 
                                update oldInvTransactions[0];
                            }
                        } 
                        update invTransaction; 
                    }//End
                }
                //Modified By - Abhinav Sharma - 10/22/2021 - CR-20210924-15459 - Update "Adjustment" to "Mailed" and add the logic for Auto-Create Spoilage Inventory Transaction
                else if (requestType.equalsIgnoreCase(REQ_TYPE_INVENTORY_UPDATE)) {
                    
                    if (reqWrapper.inventoryTransactions != null && reqWrapper.inventoryTransactions.size() > 0) {
                        
                        List<Inventory_Transaction__c> invTransactionsToInsert = new List<Inventory_Transaction__c>();
                        
                        Set<String> componentCodes = new Set<String>();
                        
                        //get component codes and check for any errors
                        for (Inventory_Transaction__c iTransaction : reqWrapper.inventoryTransactions) {
                            if (iTransaction.Component_Code__c == null) {
                                throw new customException('Component_Code__c is required when calling ' + REQ_TYPE_INVENTORY_UPDATE);
                            }
                            componentCodes.add(iTransaction.Component_Code__c);
                        }
                        
                        //get all inventory for these component codes
                        List<Inventory__c> invList = [SELECT Id, Inventory_Control_Number__c, Quantity_Available__c 
                                                      FROM Inventory__c 
                                                      WHERE Inventory_Control_Number__c IN :componentCodes
                                                      ORDER BY CreatedDate ASC
                                                     ];
                        
                        Map<String, Inventory__c> componentCodeToInvMap = new Map<String, Inventory__c>();
                        for (Inventory__c inv : invList) {
                            componentCodeToInvMap.put(inv.Inventory_Control_Number__c, inv);
                        }
                        
                        //populate Inventory on Inventory Transaction based on component code
                        for (Inventory_Transaction__c iTransaction : reqWrapper.inventoryTransactions) 
                        {
                            Inventory__c inv = componentCodeToInvMap.get(iTransaction.Component_Code__c);
                            if (inv != null) 
                            {
                                iTransaction.Inventory__c = inv.Id;
                                //10/22/2021 - CR-20210924-15459 - Abhinav Sharma - Update "Adjustment" to "Mailed"
                                iTransaction.Status__c = INVENTORY_TRANSACTION_STATUS_MAILED;
                                
                                //set the recordType = Adjustment Request because we need the Inventory quantity to match quantity remaining that is sent from the Print Vendor
                                iTransaction.RecordTypeId = InventoryTransactionTriggerHelper.INVENTORY_TRACKING_RT_ID_ADJUSTMENT_REQUEST;
                                
                                //update the inventory transaction so the effective quantity will force the Inventory.Quantity_Available__c to match Quantity_Remaining__c
                                if (iTransaction.Quantity_Remaining__c > 0) 
                                {
                                    iTransaction.Effective_Quantity__c = Math.abs(inv.Quantity_Available__c - iTransaction.Quantity_Remaining__c);
                                }
                                
                                //10/22/2021 - CR-20210924-15459 - Abhinav Sharma - Auto-Create Spoilage Inventory Transaction
                                if (iTransaction.Spoilage__c > 0) 
                                {
                                    Inventory_Transaction__c cloneInvTxn = iTransaction.clone();
                                    cloneInvTxn.Quantity__c = iTransaction.Spoilage__c * -1;
                                    cloneInvTxn.Status__c = INVENTORY_TRANSACTION_STATUS_SPOILED;
                                    cloneInvTxn.Mailed__c = 0;
                                    cloneInvTxn.Effective_Quantity__c = 0;
                                    cloneInvTxn.Quantity_Remaining__c = 0;
                                    cloneInvTxn.Quantity_Recycled__c = 0;
                                    invTransactionsToInsert.add(cloneInvTxn);
                                }//End
                                
                                invTransactionsToInsert.add(iTransaction);
                            }
                            else {
                                throw new customException('Component_Code__c (' + iTransaction.Component_Code__c + ') does not match existing inventory ' + REQ_TYPE_INVENTORY_UPDATE);
                            }
                        }
                        
                        if (invTransactionsToInsert.size() > 0)
                            insert invTransactionsToInsert;
                        
                    }
                    else {
                        throw new customException('inventoryTransactions are required when calling ' + REQ_TYPE_INVENTORY_UPDATE);
                    }
                }
                //10/18/2020 - CR-20201012-14597 - Victor Hanson - added
                else if (requestType.equalsIgnoreCase(REQ_TYPE_ERROR)) {
                    
                    //set the Status Detail to error & update the Error Details
                    pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_ERROR;
                    pTracking.Error_Details__c = reqWrapper.message;
                    
                    update pTracking;
                }
                //09/06/2020 - CR-20200902-14488 - Victor Hanson
                else if (requestType.equalsIgnoreCase(REQ_TYPE_UPDATE_PRODUCTION_TRACKING)) 
                {
                    if (reqWrapper.vendorMailDate != null)
                    {
                        pTracking.Vendor_Mail_Date__c = reqWrapper.vendorMailDate;
                        //Added by - Nikita Kumari - CR-20210326-15039 - 06/16/2021 - Update Status Detail to Mail Date Confirmed whenever Vendor Mail Date Updated - start
                        if (pTracking.Status_Detail__c == Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION)
                        {
                            pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_MAIL_DATE_CONFIRMED;
                        }
                        //Added by Nikita Kumari - CR-20210326-15039 - 06/16/2021 - ends here
                    }
        
                    if (String.isNotBlank(reqWrapper.mailDateChangeReason))
                        pTracking.Mail_Date_Change_Reason__c = reqWrapper.mailDateChangeReason;
                    
                    //11/30/2020 - CR-20201012-14597 - Victor Hanson - added
                    if (String.isNotBlank(reqWrapper.componentPackageCountJson)) {
                        pTracking.Component_Package_Count_JSON__c = reqWrapper.componentPackageCountJson;
                        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION;
                    }
                    
                    update pTracking;
                }
                else if (requestType.equalsIgnoreCase(REQ_TYPE_UPDATE_JOB_STATUS)) 
                {
                    if (reqWrapper.status != null) 
                    {
                            //06/01/2020 - CR-20200601-14128 - Victor Hanson - changes start here - get mapping value from custom setting
                            String newStatus = reqWrapper.status;
                            
                            FieldMappingHelper fmh = new FieldMappingHelper('Production_Tracking__c');
                            Map<string, Field_Mapping_Value__mdt> mapStatusVal = fmh.MappingByFieldByValue.get('Status_Detail__c'.toLowerCase());
                            if (mapStatusVal != null && 
                                mapStatusVal.containsKey(reqWrapper.status.toLowerCase()))
                            {
                                newStatus = mapStatusVal.get(reqWrapper.status.toLowerCase()).Target_Value__c;
                            }
                            
                            pTracking.Status_Detail__c = newStatus;
                            //06/01/2020 - CR-20200601-14128 - Victor Hanson - changes end here
                            
                            //update production tracking
                            update pTracking;

                    } 
                }
                else if (requestType.equalsIgnoreCase(REQ_TYPE_MAILED)) {
                        
                    //11/24/2020 - CR-20201012-14597 - Victor Hanson - end here
                    if (reqWrapper.freight != null)
                        pTracking.Freight__c = reqWrapper.freight;
                    if (reqWrapper.postagePerPiece != null)
                        pTracking.Postage_Per_Piece__c = reqWrapper.postagePerPiece;
                    if (reqWrapper.mailCostTotal != null)
                        pTracking.Mail_Cost_Total__c = reqWrapper.mailCostTotal; //End
                    //Added by - Victor Hanson - 08/14/2020 - CR-20200814-14432
                    if (reqWrapper.printedQuantity != null)
                        pTracking.Print_Quantity_Actual__c = reqWrapper.printedQuantity;
                    
                    //update status = mailed if Students Mailed has been returned from Vendor
                    if (pTracking.Mailed_Students__c > 0) {
                        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_MAILED;
                        pTracking.Status_Detail__c = null;
                    }
                    
                    //update production tracking
                    update pTracking;
                }
                
                //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - starts from Here
                //Modified By - Shalu Sharma - 4/14/2022 - CR-20220302-15977 - Update "CreateProductionTrackingBatch" callout.
                //Check for the "Create_Production_Tracking_Batch" request type
                else if (requestType != null && requestType.equalsIgnoreCase(REQ_TYPE_Create_Production_Tracking_Batch))
                {
                    // CHeck if payload is not having the Creative Package counter Id
                    if(reqWrapper.CreativePackageCounterId != null) {
                        List<Creative_Package__c> listCreativePackage = new List<Creative_Package__c>(); 
                        
                        //Get the Creative Package record 
                        for(Creative_Package__c cpkg : [Select Id, Job_Ticket__c, Job_Ticket__r.Status__c, Approval_Status__c, Art_File_Name__c From Creative_Package__c Where Creative_Package_Counter_Id__c =: reqWrapper.CreativePackageCounterId]){
                            listCreativePackage.add(cpkg);
                            cPKGJobticketID = cpkg.Job_Ticket__c;
                        }
                        
                        if(listCreativePackage.size() == 0) 
                            throw new customException('No Creative Package for Counter Id : ' + reqWrapper.CreativePackageCounterId); 
                        
                        //Check If CP Associated with the cancelled or complete JT
                        if(setJobTIcketClosedStatus.contains(listCreativePackage[0].Job_Ticket__r.Status__c))
                            throw new customException('The Creative Package (Counter Id :'+ reqWrapper.CreativePackageCounterId + ') is associated with a Completed or Cancelled Job Ticket.');    
                        
                        //Get all the Production Tracking records associated with the creative package
                        List<Production_Tracking__c> listAllProdTrackingWithCreativePackage =  new List<Production_Tracking__c>();
                        
                        //List TO hold the PT records with status equals to Proof or below.
                        List<Production_Tracking__c> listProdTracking = new List<Production_Tracking__c>();
                        
			//Modified By - Shalu Sharma - 4/14/2022 - CR-20220302-15977
                        for(Production_Tracking__c ptrack : [Select Id,Creative_Package__c, Job_Ticket__c, Drop__c, Proof_Generation__c, Status__c From Production_Tracking__c Where RecordType.DeveloperName =: Constants.PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP AND Job_Ticket__c != null AND Job_Ticket__c =: listCreativePackage[0].Job_Ticket__c ORDER BY Drop__c ASC nulls Last/*DESC nulls Last*/]){
                            listAllProdTrackingWithCreativePackage.add(ptrack);
                            
                            //Modified By - Shalu Sharma - 4/14/2022 - CR-20220302-15977 - Added setOfPTStatuses.contains(ptrack.Status__c) in place of !setProductionTrackingStatus.contains(ptrack.Status__c)
                            if(ptrack.Creative_Package__c != null && ptrack.Creative_Package__c == listCreativePackage[0].ID && setOfPTStatuses.contains(ptrack.Status__c))
                                listProdTracking.add(ptrack);
                        }
                        
                        //If there is no PT record exist with status equals to Proof or below.then create the new mailshop type PT
                        if(listProdTracking.size() == 0) {
                            
                            //Insert Production Tracking record.
                            Production_Tracking__c prodTracking = new Production_Tracking__c();
                            prodTracking.RecordTypeId = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByName().get('Mail Shop').getRecordTypeId();
                            prodTracking.Creative_Package__c = listCreativePackage[0].ID;
                            prodTracking.Job_Ticket__c = listCreativePackage[0].Job_Ticket__c;
                            prodTracking.Proof_Generation__c = Constants.PRODUCTION_TRACKING_PROOF_GENERATION_INTERNAL;
                            prodTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED;
                            prodTracking.Drop__c = (listAllProdTrackingWithCreativePackage.size() > 0 && listAllProdTrackingWithCreativePackage[0].Drop__c != null) ? (listAllProdTrackingWithCreativePackage[0].Drop__c + 1) : 1 ; //(Get all PT records associated with this CPKG.  If this is the first PT, Drop # = 1, otherwise Sort by Drop # and use the largest Drop # + 1.  Also populate PT.Previous Production Tracking if there was a previous PT)
                            prodTracking.Previous_Production_Tracking__c = listAllProdTrackingWithCreativePackage.size() > 0 ? listAllProdTrackingWithCreativePackage[0].ID : null;
                            prodTracking.Drop_Type__c = Constants.PRODUCTION_TRACKING_DROP_TYPE;
                            prodTracking.Art_File_Name__c = listCreativePackage[0].Art_File_Name__c;
                            
                            insert prodTracking;
                            listProdTracking.add(prodTracking);
                            
                            Set<Id> setOfJobTicketIds = new Set<Id>(); 
                            setOfJobTicketIds.add(listCreativePackage[0].Job_Ticket__c);
                            Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(setOfJobTicketIds);
                            Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
                            
                        }
                        //Added By - Shalu Sharma - 4/14/2022 - CR-20220302-15977
						else if(listProdTracking.size() == 1)
                        {
                            Production_Tracking__c productionTracking = [SELECT Id, Status__c, Drop__c FROM Production_Tracking__c
                                                                        WHERE Id IN : listProdTracking 
                                                                        AND RecordType.DeveloperName =: Constants.PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP
                                                                        AND Status__c IN : setOfPTStatuses Order By Drop__c ASC];
                            listProdTracking.add(productionTracking);
                        }
			//Modified By - Shalu Sharma - 4/14/2022 - CR-20220302-15977
                        else if (listProdTracking.size() > 1)
                        {
                            List<Production_Tracking__c> productionTrackings = [SELECT Id, Status__c, Drop__c FROM Production_Tracking__c
                                                                               WHERE Id IN : listProdTracking 
                                                                               AND RecordType.DeveloperName =: Constants.PRODUCTION_TRACKING_RECORDTYPE_MAIL_SHOP
                                                                               AND Status__c IN : setOfPTStatuses Order By Drop__c ASC];
                            
                            if(productionTrackings.size() > 0)
                            {
                            	listProdTracking.add(productionTrackings[0]);
                            }
                        }//End
                        
                        //Check for Batch Type in the Payload
                        if(reqWrapper.BatchType == Constants.BATCH_TYPE_LIVEDATA || reqWrapper.BatchType == Constants.BATCH_TYPE_ARTPROOF /*(reqWrapper.BatchType == 'ArtProof' && (listCreativePackage[0].Approval_Status__c == null || listCreativePackage[0].Approval_Status__c == 'Rejected') )*/){
                            
                            cPKGPTID = listProdTracking[0].Id;
                            
                            // If Art Proof then set the PT status to Proof Submitted with bypassing the Color_Calibration validation ("Bypass_Color_Calibration__c = true")
                            if(listCreativePackage[0].Job_Ticket__c != null 
                                && String.isNotBlank(listCreativePackage[0].Job_Ticket__r.Status__c) 
                                && listCreativePackage[0].Job_Ticket__r.Status__c != Constants.JOB_TICKET_STATUS_DRAFT
                                && reqWrapper.BatchType == Constants.BATCH_TYPE_ARTPROOF)
                            {
                                listProdTracking[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
                                listProdTracking[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
                                
                                update listProdTracking[0];
                                
                                //update Creative Package Status to Submitted.
                                listCreativePackage[0].Approval_Status__c = Constants.CREATIVE_PACKAGE_APPROVAL_STATUS;
                                update listCreativePackage;
                            }
                            
                            //Create a recipient Batch record with Recipient_Batch_Id__c,Data_Posted_Date_Time__c, Data_Posted_Quantity__c, Type__c as mentioned in the Payload, under the selected PT record 
                            Recipient_Batch__c batch = new Recipient_Batch__c();
                            batch.Production_Tracking__c = listProdTracking[0].Id;
                            batch.Type__c = reqWrapper.BatchType != null ? reqWrapper.BatchType : null;
                            batch.Data_Posted_Date_Time__c = reqWrapper.DataPostedDate != null ? reqWrapper.DataPostedDate : null;
                            batch.Data_Posted_Quantity__c = reqWrapper.DataPostedQuantity != null ? reqWrapper.DataPostedQuantity : null; 
                            batch.Recipient_Batch_Id__c = String.isNotBlank(reqWrapper.BatchId)  != null ? reqWrapper.BatchId : null;
                            
                            insert batch;   
                        }
                    } else{
                        throw new customException('Please Provide the CreativePackageCounterId.');
                    }
                }
                //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Ends Here
                
            else {
                     throw new customException('Invalid Request Type (' + requestType + ')');
                 }
            }
            
            //insert any artifacts that need to be pulled from vendor SFTP -> Box
            if (reqWrapper.artifacts != null && reqWrapper.artifacts.size() > 0 && pTracking != null) {
                
                //12/31/2020 - CR-20201012-14597 - Victor Hanson - updates for artifact items start here
                //create the artifacts & artifact transfers
                Map<String, Artifact__c> typeToArtifactMap = createArtifacts(pTracking, reqWrapper.artifacts);
                
                //check for artifact items
                List<Artifact_Item__c> artifactItemsToUpsert = new List<Artifact_Item__c>();
                for (artifactWrapper aw : reqWrapper.artifacts) {
                    if (aw.artifactItems != null) {
                        //if no id is present, we need to create the Artifacts + Artifact Items
                        if (aw.Id == null && aw.fileType != null) {
                            //get the artifact id so we know where to associate the items
                            Artifact__c artifact = typeToArtifactMap.get(mapFileTypeToArtifactType.get(aw.fileType));
                            for (ArtifactItemWrapper aItemWrapper : aw.artifactItems) {
                                artifactItemsToUpsert.add(aItemWrapper.getNewArtifactItem(artifact.Id));
                            }
                        }
                        else {
                            //this must be an existing artifact.  In this scenario, just update the Artifact Item(s) based on Id
                            for (ArtifactItemWrapper aItemWrapper : aw.artifactItems) {
                                Artifact_Item__c aItem = new Artifact_Item__c(Id = aItemWrapper.id,
                                                                              Vendor_Count__c = aItemWrapper.vendorCount);
                                artifactItemsToUpsert.add(aItem);
                            }
                        }
                    }
                }
                if (artifactItemsToUpsert.size() > 0) {
                    upsert artifactItemsToUpsert;
                }
                //12/31/2020 - CR-20201012-14597 - Victor Hanson - updates for artifact items end here
            }
            
            resWrapper.status = STATUS_SUCCESS;
        }
        
        //Modified By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Starts from here
        catch(system.JSONException e) {
            res.statusCode = 500;
            resWrapper.status = STATUS_ERROR;
            resWrapper.message = e.getMessage();
            
            //rollback if we hit an exception
            Database.rollback(sp);
        }
        catch(Exception e) {
            
            res.statusCode = 500;
            
            //Setting Status code to 200  for the request Type "Create_Production_Tracking_Batch" only if exception/error is not related to JSON exception.
            if(requestType != null && requestType.equalsIgnoreCase(REQ_TYPE_Create_Production_Tracking_Batch)){
                res.statusCode = 200;    
            }
            resWrapper.status = STATUS_ERROR;
            resWrapper.message = e.getMessage();
            
            //rollback if we hit an exception
            Database.rollback(sp);
        }
        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Ends here
        
        try {
            //create web service log
            Web_Service_Log__c webServiceLog = new Web_Service_Log__c(RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,
                                                                      Job_Ticket__c = pTracking != null ? pTracking.Job_Ticket__c : (cPKGJobticketID != null ? cPKGJobticketID :null),
                                                                      Production_Tracking__c = pTracking != null ? pTracking.Id : (cPKGPTID != null ? cPKGPTID :null),
                                                                      Web_Service_Method__c = requestType,
                                                                      Request_Sent__c = system.now(),
                                                                      Request_Message_Log__c = JSON.serializePretty(reqWrapper, true),
                                                                      Response_Message__c = resWrapper.status,
                                                                      Response_Message_Log__c = JSON.serializePretty(resWrapper),
                                                                      Requested_By__c = UserInfo.getUserName());
            
            //05/12/2021 - CR-20210310-14983 - Abhinav Sharma - Added - To connect inventory transaction to web service if exists
            //Starts from here
            if(reqWrapper.inventoryTransactionId != null) 
            {
                webServiceLog.Inventory_Transaction__c = reqWrapper.inventoryTransactionId;
                //Added by - Abhinav Sharma - 06/04/2021 - CR-20210524-15178 - OE/BRE-Automation QA/Issues Fixes(For "inventoryShipped" and "invetoryReceived" callouts to check all 
                //			                                                   the attributes that we set from workbench side while making the callouts)
                //06/21/2021 - CR-20210525-15180 - Abhinav Sharma - Modified - To replace Quantity__c by Quantity_Shipped__c in the query
                if(requestType == 'InventoryShipped')
                {
                    List<Inventory_Transaction__c> invTransactions =  [SELECT Quantity_Shipped__c, Ship_Date__c, 
                                                                       Arrival_Date_Anticipated__c, Status__c,
                                                                       Shipping_Method__c, Tracking_Number__c
                                                                       FROM Inventory_Transaction__c 
                                                                       WHERE Id =: reqWrapper.inventoryTransactionId];
                    if (invTransactions.size() > 0)
                    {
                        requestWrapper reqWrap = new requestWrapper();
                        reqWrap.productionTrackingId = reqWrapper.productionTrackingId;
                        reqWrap.inventoryTransactionId = reqWrapper.inventoryTransactionId;
                        reqWrap.componentCode = reqWrapper.componentCode;
                        reqWrap.inventoryTransactions = invTransactions;
                        String jsonString = JSON.serializePretty(reqWrap, true);
                        webServiceLog.Request_Message_Log__c = jsonString;
                    }
                }
                //06/21/2021 - CR-20210525-15180 - Abhinav Sharma - Modified - To replace Quantity__c by Quantity_Received__c in the query
                else if(requestType == 'InventoryReceived')
                {
                    List<Inventory_Transaction__c> invTransactions =  [SELECT Quantity_Received__c, 
                                                                       Arrival_Date_Actual__c
                                                                       FROM Inventory_Transaction__c 
                                                                       WHERE Id =: reqWrapper.inventoryTransactionId];
                    if (invTransactions.size() > 0)
                    {
                        requestWrapper reqWrap = new requestWrapper();
                        reqWrap.productionTrackingId = reqWrapper.productionTrackingId;
                        reqWrap.inventoryTransactionId = reqWrapper.inventoryTransactionId;
                        reqWrap.componentCode = reqWrapper.componentCode;
                        reqWrap.TotalInventoryCount = reqWrapper.TotalInventoryCount;
                        reqWrap.inventoryTransactions = invTransactions;
                        String jsonString = JSON.serializePretty(reqWrap, true);
                        webServiceLog.Request_Message_Log__c = jsonString;
                    } 
                }//End Here
            }
            //End here
            insert webServiceLog;
            
            //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Starts from here
            String receipient = System.Label.CreativePackageMailreceipient;
            
            //Sending the emails to Creative Package members if Creative Package counter Id is invalid 
            if((webServiceLog.Response_Message_Log__c).containsIgnoreCase('No Creative Package for Counter Id : ')){
                
                String emailSubject = 'No Creative Package for Counter Id : ' + reqWrapper.CreativePackageCounterId ;
                String emailMessageBody = 'No Creative Package for Counter Id : ' + reqWrapper.CreativePackageCounterId + '.'
                    + '<br><br> <u><b>Web Service Method:</b></u> <br>' +  requestType
                    + '<br><br> <u><b>Request Message Log:</b></u> <br>' +  JSON.serializePretty(reqWrapper, true)
                    + '<br><br> <u><b>Response Message Log:</b></u> <br>' +  JSON.serializePretty(resWrapper);
                
                sendEmailToCreativePackageMember(emailSubject, receipient, emailMessageBody);
            }
            
            //Sending the emails to Creative Package members if Creative Package Associated with the cancelled or complete Job Ticket
            else if((webServiceLog.Response_Message_Log__c).containsIgnoreCase('The Creative Package (Counter Id :')) {
                
                String emailSubject = 'The Creative Package (Counter Id :'+ reqWrapper.CreativePackageCounterId + ') is associated with a Completed or Cancelled Job Ticket.';
                
                //Send an email to [TBD], notifying them that the Creative Package is associated with a Completed or Cancelled Job Ticket
                String emailMessageBody = 'The Creative Package (Counter Id :'+ reqWrapper.CreativePackageCounterId + ') is associated with a Completed or Cancelled Job Ticket.'
                    + '<br><br> <u><b>Web Service Method:<b><u> <br>' +  requestType
                    + '<br><br> <u><b>Request Message Log:<b><u> <br>' +  JSON.serializePretty(reqWrapper, true)
                    + '<br><br> <u><b>Response Message Log:<b><u> <br>' +  JSON.serializePretty(resWrapper);
                
                sendEmailToCreativePackageMember(emailSubject, receipient, emailMessageBody);     
            }
            //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Ends here
        }
        catch(Exception e) {
            System.debug('@@@@@ exception at JobTicketService ' + e.getStackTraceString());
        }
        
        //set the response body
        res.responseBody = Blob.valueOf(JSON.serialize(resWrapper));
        JobTicketTriggerHelper.Bypass_changeReasonRequiredForLockedRecord = false;
    }
    
    @future
    public static void sendEmailToCreativePackageMember(String emailSubject, String receipient, String emailMessageBody) {
        EmailHandler.sendEmail(receipient, emailSubject , '', emailMessageBody);
    }
    
    /**
     *  Purpose         :	creates artifacts and artifact transfers on the job ticket
     *
     *  Revision Logs   :	V_1.0 - Created - 04/08/2020 - Victor Hanson - Created
     * 				V_1.1 - Modified - 05/27/2020 - Victor Hanson - CR-20200527-14113 - added Source File & Source Directory overrides and set Source & Target for Proofs
     *				V_1.2 - Modified - 12/31/2020 - CR-20201012-14597 - Victor Hanson
     *                     
    **/
    public static Map<String, Artifact__c> createArtifacts(Production_Tracking__c pTracking, List<artifactWrapper> artifactWrappers) {
        List<Artifact__c> artifacts = new List<Artifact__c>();
        for (artifactWrapper aWrapper : artifactWrappers) {
            
            //if an Id is present or there is no file type, do not create a new artifact
            if (aWrapper.Id != null || aWrapper.fileType == null) {
                continue;
            }

            Artifact__c newArtifact = new Artifact__c(Job_Ticket__c = pTracking.Job_Ticket__c,
                                                      Production_Tracking__c = pTracking.Id,
                                                      Type__c = mapFileTypeToArtifactType.get(aWrapper.fileType),
                                                      Name = mapFileTypeToArtifactType.get(aWrapper.fileType),
                                                      Source_File_Name_Exact_Override__c = aWrapper.fileName,
                                                      Source_Directory_Path_Override__c = aWrapper.filePath,
                                                      Proof_Generation__c = pTracking.Proof_Generation__c,
                                                      Status__c = 'Staging',
                                                      Drop_Type__c = pTracking.Job_Ticket__r.Drop_Type__c);
            if (aWrapper.fileType == FILE_TYPE_ARTWORK_PROOF) {
                newArtifact.Source__c = 'Mail Shop - Artwork Proof';
                newArtifact.Target__c = 'EAB - Artwork Proof';
            }
            else if (aWrapper.fileType == FILE_TYPE_LIVE_PROOF) {
                newArtifact.Source__c = 'Mail Shop - Live Proof';
                newArtifact.Target__c = 'EAB - Live Proof';
            }
                
            artifacts.add(newArtifact);
        }
        insert artifacts;
        
        //create a map of artifacts by type so we can properly match them when creating artifact transfer
        Map<String, Artifact__c> fileTypeToArtifactMap = new Map<String, Artifact__c>();
        for (Artifact__c artifact : artifacts) {
            fileTypeToArtifactMap.put(artifact.Type__c, artifact);
        }
        return fileTypeToArtifactMap;
    }
    
    //12/31/2020 - CR-20201012-14597 - Victor Hanson
    //wrapper for artifact details sent from vendor
    public class artifactWrapper {
        public String fileName { get; set; } //27662_AH20_SCH_LR.zip
        public String fileType { get; set; } //artwork_proof, live_proof, mailing_list_validation_results, mailing_list_results
        public String filePath { get; set; } // /test/path
        public String id { get; set; } //artifact transfer Id
        public List<artifactItemWrapper> artifactItems {
            get {
                if (artifactItems == null) artifactItems = new List<artifactItemWrapper>();
                return artifactItems;
            }
            set;
        }
        public artifactWrapper() {}
    }

    //12/31/2020 - CR-20201012-14597 - Victor Hanson - added to support artifact items
    //wrapper for artifact Items sent from XMPie
    public class artifactItemWrapper {
        public String fileName { get; set; } //27662_AH20_SCH_LR.zip
        public String itemType { get; set; } //Ready to Print PDF
        public String filePath { get; set; } // /test/path
        public Integer databaseCount { get; set; } // 600
        public Integer xmpieCount { get; set; } // 600
        public Integer vendorCount { get; set; } // 600
        public Integer recordCount { get; set; } // 600
        public Integer bannerSheetCount { get; set; }
        public String id { get; set; } //artifact Item Id
        public artifactItemWrapper() {}
        public artifactItemWrapper(Artifact_Item__c aItem) {
            this.id = aItem.Id;
            this.fileName = aItem.File_Name__c;
            this.filePath = aItem.File_Path__c;
            this.itemType = aItem.Item_Type__c;
            if (aItem.XMPie_Count__c != null)
            	this.bannerSheetCount = Integer.valueOf(aItem.Banner_Sheet_Count__c);
            if (aItem.XMPie_Count__c != null)
            	this.recordCount = Integer.valueOf(aItem.XMPie_Count__c);
        }
        public Artifact_Item__c getNewArtifactItem(Id artifactId) {
            return new Artifact_Item__c(Artifact__c = artifactId,
                                        File_Name__c = this.fileName,
                                        File_Path__c = this.filePath,
                                        Item_Type__c = this.itemType,
                                        Database_Count__c = this.databaseCount,
                                        XMPie_Count__c = this.xmpieCount,
                                        Vendor_Count__c = this.vendorCount,
                                        Banner_Sheet_Count__c = this.bannerSheetCount
                                        );
        }
    }
    
    //wrapper for updates from vendor
    //VH 05/18/2020 - CR-20200515-14047 - Added suppressionCount
    //09/06/2020 - CR-20200902-14488 - Victor Hanson - Added vendorMailDate & mailDateChangeReason
    //11/24/2020 - CR-20201012-14597 - Victor Hanson - Added receivedByVendorCount & finalCount
    public class requestWrapper {
        public List<artifactWrapper> artifacts {
            get {
                if (artifacts == null) artifacts = new List<artifactWrapper>();
                return artifacts;
            }
            set;
        }
        
        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15028 - Starts from here
        public List<String> approvedPackageList {
            get {
                if (approvedPackageList == null) approvedPackageList = new List<String>();
                return approvedPackageList;
            }
            set;
        }
        
        public List<RecipientBatch> recipientBatchIdList {
            get {
                if (recipientBatchIdList == null) recipientBatchIdList = new List<RecipientBatch>();
                return recipientBatchIdList;
            }
            set;
        }

        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15028 - Ends here
        
        public String jobTicketId { get; set; }
        public String productionTrackingId { get; set; }
        public String status { get; set; }
        public Boolean success { get; set; }
        public Decimal studentsMailed { get; set; }
        public Decimal seedsMailed { get; set; }
        public Decimal initialImportCount { get; set; }
        public Decimal failedImportCount { get; set; }
        public Decimal suppressionCount { get; set; }
        public Decimal seedImportCount { get; set; }
        public Decimal studentImportCount { get; set; }
        public Decimal qualitySampleCount { get; set; }
        //Added by - Abhinav Sharma - 07/24/2020 - CR-20200721-14348(Add actualMailDate field)
        public Date actualMailDate {get;set;}
        public requestWrapper() {}
        //Added by - Abhinav Sharma - 07/06/2020 - CR-20200701-14243(Add fields to support cost tracking)
        public Decimal unitCost { get; set; }
        public Decimal totalPostage { get; set; }
        public String invoiceNumber {get; set; }
        public Decimal freight {get; set; }
        public Decimal postagePerPiece {get; set; }
        public Decimal mailCostTotal {get; set; }
        //Added by - Victor Hanson - 08/14/2020 - CR-20200814-14432
        public Decimal printedQuantity { get; set; }
        //Added by - Victor Hanson - 09/06/2020 - CR-20200902-14488
        public Date vendorMailDate { get; set; }
        public String mailDateChangeReason { get; set; }
        //Added by - Victor Hanson - 10/18/2020 - CR-20201012-14597
        public String message { get; set; }
        public Decimal receivedByVendorCount { get; set; }
        public Decimal finalCount { get; set; }
        public Decimal TotalInventoryCount {get; set;}
        
        //Added by - Victor Hanson - 11/30/2020 - CR-20201012-14597
        public String componentPackageCountJson { get; set; }
        
        //04/23/2021 - CR-20210420-15089 - Victor Hanson - added
        public String componentCode { get; set; }
        public String inventoryTransactionId { get; set; }
        public List<Inventory_Transaction__c> inventoryTransactions { get; set; }
        
        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15028
        public String CreativePackageCounterId { get; set; }
        public String BatchId { get; set; }
        public DateTime DataPostedDate { get; set; }
        public Decimal DataPostedQuantity { get; set; }
        public String BatchType { get; set; }
        public PackageMatrix packageMatrix { get; set; }
        //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Ends here
    }
    
    //wrapper for returning response to vendor
    public class responseWrapper {
        public String status { get; set; }
        public String message { get; set; }
        public responseWrapper() {}
    }
    
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Starts from here
    public class PackageMatrix {
        public Map<String, CreativePackage> CreativePackages { get; set; }
        public packageMatrix() {}
    }
    public class CreativePackage {
        //public String CreativePackageCounterId { get; set; }
        public Map<String, MailPackage> MailPackages { get; set; }
        public CreativePackage() {}
    }
    
    public class MailPackage {
        //public String MailPackageCounterId { get; set; }
        public String MailCopyCode { get; set; }
        public Map<String, PackageComponentMtM> PackageComponents { get; set; }
        public MailPackage() {}
    }
    
    public class PackageComponentMtM {
        //public String PackageComponentCounterId { get; set; }
        public String ComponentType { get; set; }
        public String ComponentCode { get; set; }
        
        public PackageComponentMtM() {}
    }
    
    public class RecipientBatch {
        //public String PackageComponentCounterId { get; set; }
        public String RecipientBatchId { get; set; }
        public Decimal DataPostedQuantity { get; set; }
        public String Type { get; set; }
        
        public RecipientBatch() {}
    }
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 - Ends here   
}