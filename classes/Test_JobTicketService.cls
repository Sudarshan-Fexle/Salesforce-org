/**
* Purpose          :   Test class for JobTicketService
* 
* RevisionLog      :   V_1.0 - Created - Victor Hanson - CR-20200304-13828
*                      V_1.1 - Modified By Abhinav Sharma - CR-20200721-14348 - updateJobTicket method 
*                      V_1.2 - 12/14/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation field reference
*		       V_1.3 - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
*		       V_1.4 - 05/13/2021 - CR-20210310-14983 - Abhinav Sharma - Updated InventoryShipped and inventoryReceived callouts logic coverage
*		       V_1.5 - Modified By - Abhinav Sharma - 05/20/2021 - CR-20210518-15161 - Update the method "test_approveJobTicketMtM"
*		       V_1.6 - Modified By - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory) 
*		       V_1.7 - Modified By - Shalu Sharma - 04/26/2022 - CR-20220302-15977 - Added "test_CreateProductionTrackingBatchRequest" method
**/
@IsTest(seeAllData=false)
private class Test_JobTicketService {
    
    public static final String ENDPOINT_BASE = '/services/apexrest/v1/JobTicket/';
    
    //setup the test data
    @testSetup static void testSetupData() {
        Util.BypassAllTriggers = true;
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234');
        insert inst;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        Util.BypassAllTriggers = true;
        insert user1;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> escCampaigns = new List<ES_Campaign__c>();
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = user1.id));
        escCampaigns.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = user1.id));
        insert escCampaigns;
        
        //12/14/2020 - CR-20201012-14597 - Victor Hanson - cleanup unused program reference
        //Id programId = TestUtilities.CreateNewProgram(true).Id;
        Util.BypassAllTriggers = true;
        //String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('SSC').getRecordTypeId();
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        Util.BypassAllTriggers = true;
        insert project;
        
	//Modified By - Rajeev Jain - 11/03/2021 - CR-20210924-15459 - Comment Utilbypass check
        //Util.BypassAllTriggers = false;
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',ES_Campaign__c = escCampaigns[0].Id, Project__c = project.Id, Project_ID__c = 'test', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update'));
        Util.BypassAllTriggers = true;
        insert jobTickets;
        
        // Creating Job Ticket Component Records
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test1', Component__c = Constants.COMPONENT_TYPE_BRE)); // BRE Component type
        
        insert jobTicketComponents;
        
        // Creating Job Ticket MTM Record 
        List<Job_Ticket_MTM__c> jobTicketMTMs = new List<Job_Ticket_MTM__c>();
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        
        insert jobTicketMTMs;
        
        Util.BypassAllTriggers = false;
        //12/14/2020 - CR-20201012-14597 - Victor Hanson - added Proof Generation field reference
        
        
        //Get the Creative Package record 
        List<Creative_Package__c> listCreativePackage = new List<Creative_Package__c>();
        listCreativePackage.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id));
        
        Util.BypassAllTriggers = true;
        insert listCreativePackage;
        Util.BypassAllTriggers = false;
        
        String RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();

        //Create Production Trackings
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Drop__c = 1,Art_File_Name__c = 'test', Creative_Package__c = listCreativePackage[0].Id ,Status__c = 'Planned', Job_Ticket__c = jobTickets[0].Id,Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Job_Ticket_MtM__c = jobTicketMTMs[0].Id));
        productionTrackings.add(new Production_Tracking__c(RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, Drop__c = 1,Art_File_Name__c = 'test',Status__c = 'Planned', Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Job_Ticket_MtM__c = jobTicketMTMs[0].Id));

        insert productionTrackings;
        
        Util.BypassAllTriggers = false;
        
        //Creating artifact record
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Type__c = 'Artwork',Status__c ='failure',Production_Tracking__c = productionTrackings[0].Id,Job_Ticket__c = jobTickets[0].Id ));
        //artifactList.add(new Artifact__c(Type__c = 'Artwork',Status__c ='failure',Job_Ticket__c = jobTickets[0].Id,Production_Tracking__c = productionTrackings[0].Id ));
        Insert artifactList;
        Util.BypassAllTriggers = true;
        
        //create inventory record 
        List<Inventory__c> inventoryList = new List<Inventory__c>();
        //Modify by - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
        inventoryList.add(new Inventory__c(Inventory_Control_Number__c = '01TEST01', Production_Tracking__c = productionTrackings[0].Id));
        inventoryList.add(new Inventory__c(Inventory_Control_Number__c = '02TEST02', Production_Tracking__c = productionTrackings[0].Id));
        
        Insert inventoryList;
        
        String INVENTORY_TRACKING_RT_ID_PRINT_REQUEST = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByDeveloperName().get('Print_Request').getRecordTypeId();
        
        // create inventory transactions
        List<Inventory_Transaction__c> inventoryTransactionsList = new  List<Inventory_Transaction__c>();
        inventoryTransactionsList.add(new Inventory_Transaction__c(RecordTypeId = INVENTORY_TRACKING_RT_ID_PRINT_REQUEST, Job_Ticket_MtM__c = jobTicketMTMs[0].Id, Inventory__c = inventoryList[0].Id, Effective_Quantity__c = 2, Quantity_Remaining__c = 1, Status__c = 'Requested', Production_Tracking__c = productionTrackings[1].Id));
        inventoryTransactionsList.add(new Inventory_Transaction__c(RecordTypeId = INVENTORY_TRACKING_RT_ID_PRINT_REQUEST, Job_Ticket_MtM__c = jobTicketMTMs[0].Id, Inventory__c = inventoryList[0].Id, Effective_Quantity__c = 2, Quantity_Remaining__c = 1, Status__c = 'Requested', Production_Tracking__c = productionTrackings[1].Id));
        inventoryTransactionsList.add(new Inventory_Transaction__c(RecordTypeId = INVENTORY_TRACKING_RT_ID_PRINT_REQUEST, Job_Ticket_MtM__c = jobTicketMTMs[0].Id, Inventory__c = inventoryList[1].Id, Effective_Quantity__c = 2, Quantity_Remaining__c = 1, Status__c = 'Requested', Production_Tracking__c = productionTrackings[1].Id));
        inventoryTransactionsList.add(new Inventory_Transaction__c(RecordTypeId = INVENTORY_TRACKING_RT_ID_PRINT_REQUEST, Job_Ticket_MtM__c = jobTicketMTMs[0].Id, Inventory__c = inventoryList[1].Id, Effective_Quantity__c = 2, Quantity_Remaining__c = 1, Status__c = 'Requested', Production_Tracking__c = productionTrackings[1].Id));
        
        insert inventoryTransactionsList ;
        
        Util.BypassAllTriggers = false;
        
    }
    
    //test the getJobTicket method
    static testMethod void testGetJobTicket() {
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c FROM Job_Ticket__c];
        
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + jobTickets[0].Id;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        //req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        JobTicketService.getJobTicket();
        Test.stopTest();
        
        system.assertEquals(200, res.statusCode);
    }
    
    //08/14/2020 - CR-20200814-14432 - Victor Hanson - added test for printedQuantity
    //test the updateJobTicket method
    static testMethod void testUpdateJobTicket() {
        String fName = 'Proof_v1.zip';
        String dPath = '/vendorFolder1/Test/';
        
        Util.BypassAllTriggers = true;
        
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c, (SELECT Id, Job_Ticket__c FROM Fulfillment_Tracking__r) FROM Job_Ticket__c];
        
        system.assertEquals(1, jobTickets.size());
        system.assertEquals(1, jobTickets[0].Fulfillment_Tracking__r.size());
        
        //get the production tracking record
        Production_Tracking__c pTracking = jobTickets[0].Fulfillment_Tracking__r[0];
        
        /////////////////////////////////
        // Scenario 1: Ready for Proof Approval
        ////////////////////////////////
        
        //create artifact wrapper
        JobTicketService.artifactWrapper artWrapper = new JobTicketService.artifactWrapper();
        artWrapper.fileType = JobTicketService.FILE_TYPE_ARTWORK_PROOF;
        artWrapper.fileName = fName;
        artWrapper.filePath = dPath;
        
        //create the request wrapper for the body of the callout
        JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.artifacts.add(artWrapper);
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_READY_FOR_PROOF_APPROVAL;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
        Util.BypassAllTriggers = true;
        
        //verify the artifact was created
        List<Artifact__c> artifacts = [SELECT Id FROM Artifact__c 
                                       WHERE Job_Ticket__c = :pTracking.Job_Ticket__c 
                                       AND Type__c = :JobTicketService.mapFileTypeToArtifactType.get(JobTicketService.FILE_TYPE_ARTWORK_PROOF)];
        system.assertEquals(1, artifacts.size());
        
        /////////////////////////////////
        // Scenario 2: FileTransferStatus
        ////////////////////////////////
        
        //create artifact wrapper
        JobTicketService.artifactWrapper validationResults = new JobTicketService.artifactWrapper();
        validationResults.fileType = JobTicketService.FILE_TYPE_MAILING_VALIDATION_RESULTS;
        validationResults.fileName = fName;
        validationResults.filePath = dPath;
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.initialImportCount = 1000;
        reqWrapper.failedImportCount = 50;
        reqWrapper.suppressionCount = 3;
        reqWrapper.qualitySampleCount = 2;
        reqWrapper.unitCost = 0.05;
        reqWrapper.success = true;
        reqWrapper.jobTicketId = 'testId';
        reqWrapper.message = 'msg';
        reqWrapper.finalCount = 25;
        reqWrapper.receivedByVendorCount = 21;
        reqWrapper.inventoryTransactionId = 'testId';
        reqWrapper.componentCode = 'testCode';
        reqWrapper.BatchId = 'testId';
        reqWrapper.artifacts.add(validationResults);
        
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_FILE_TRANSFER_STATUS;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
		Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
		Util.BypassAllTriggers = true;
		
        //verify the artifact was created
        artifacts = [SELECT Id FROM Artifact__c 
                     WHERE Job_Ticket__c = :pTracking.Job_Ticket__c 
                     AND Type__c = :JobTicketService.mapFileTypeToArtifactType.get(JobTicketService.FILE_TYPE_MAILING_VALIDATION_RESULTS)];
        system.assertEquals(1, artifacts.size());
        
        //get the production tracking record
        pTracking = [SELECT Id, Initial_Count__c, Failed_Import_Count__c, Suppressed_Record_Count__c, Imported_Quality_Samples__c,
                     CPM__c, Postage_Total__c, Invoice_Number__c, Freight__c, Postage_Per_Piece__c, Mail_Cost_Total__c
                     FROM Production_Tracking__c
                     WHERE Id = :pTracking.Id];
        system.assertEquals(1000, pTracking.Initial_Count__c);
        system.assertEquals(50, pTracking.Failed_Import_Count__c);
        system.assertEquals(3, pTracking.Suppressed_Record_Count__c);
        system.assertEquals(2, pTracking.Imported_Quality_Samples__c);
        
        
        /////////////////////////////////
        // Scenario 3: UpdateJobStatus
        ////////////////////////////////
        
        //06/01/2020 - CR-20200601-14128 - Victor Hanson - get one of the field mapping values (translates the value from vendor to readable format)
        List<Field_Mapping_Value__mdt> fldMappingVals = [SELECT Id, Source_Value__c, Target_Value__c FROM Field_Mapping_Value__mdt
                                                        WHERE Field_Mapping__r.Source_Object_API_Name__c = 'Production_Tracking__c'
                                                        AND Field_Mapping__r.Source_Field_API_Name__c = 'Status_Detail__c'];
        
        system.assertNotEquals(0, fldMappingVals.size(), 'should be at least one field mapping value');
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.status = fldMappingVals[0].Source_Value__c;//'Printing'
        
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_UPDATE_JOB_STATUS;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
	Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
		
	Util.BypassAllTriggers = true;
        
        //get the production tracking record
        pTracking = [SELECT Id, Status__c, Status_Detail__c, Live_Proof_Approval_Status__c FROM Production_Tracking__c WHERE Id = :pTracking.Id];
        system.assertEquals(fldMappingVals[0].Target_Value__c, pTracking.Status_Detail__c);
        
        /////////////////////////////////
        // Scenario 4: Mailed
        ////////////////////////////////
        
        //create artifact wrapper
        JobTicketService.artifactWrapper mailingResultsWrapper = new JobTicketService.artifactWrapper();
        mailingResultsWrapper.fileType = JobTicketService.FILE_TYPE_MAILING_RESULTS;
        mailingResultsWrapper.fileName = fName;
        mailingResultsWrapper.filePath = dPath;
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.studentsMailed = 925;
        reqWrapper.seedsMailed = 25;
        reqWrapper.totalPostage = 1000;
        reqWrapper.invoiceNumber = 'inv-0001';
        reqWrapper.freight = 10;
        reqWrapper.postagePerPiece = 0.02;
        reqWrapper.mailCostTotal = 500;
        reqWrapper.artifacts.add(mailingResultsWrapper);
        
        //Added by - Victor Hanson - 08/14/2020 - CR-20200814-14432
        reqWrapper.printedQuantity = 2000;
        
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_MAILED;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
	Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
		
	Util.BypassAllTriggers = true;
        
        //get the production tracking record
        pTracking = [SELECT Id, Status__c, Mailed_Students__c, Mailed_Seeds__c, Job_Ticket__c, Print_Quantity_Actual__c,
                     CPM__c, Postage_Total__c, Invoice_Number__c, Freight__c, Postage_Per_Piece__c, Mail_Cost_Total__c
                     FROM Production_Tracking__c WHERE Id = :pTracking.Id];
        system.assertEquals(925, pTracking.Mailed_Students__c);
        system.assertEquals(25, pTracking.Mailed_Seeds__c);
        system.assertEquals(Constants.PRODUCTION_TRACKING_STATUS_MAILED, pTracking.Status__c);
        system.assertEquals(1000, pTracking.Postage_Total__c);
        system.assertEquals('inv-0001', pTracking.Invoice_Number__c);
        system.assertEquals(10, pTracking.Freight__c);
        system.assertEquals(0.02, pTracking.Postage_Per_Piece__c);
        system.assertEquals(500, pTracking.Mail_Cost_Total__c);
        system.assertEquals(2000, pTracking.Print_Quantity_Actual__c);
        
        //verify the artifact was created
        artifacts = [SELECT Id FROM Artifact__c 
                     WHERE Job_Ticket__c = :pTracking.Job_Ticket__c 
                     AND Type__c = :JobTicketService.mapFileTypeToArtifactType.get(JobTicketService.FILE_TYPE_MAILING_RESULTS)];
        system.assertEquals(1, artifacts.size());
        
                        
        /////////////////////////////////
        // Scenario 5: InventoryPrinted
        /////////////////////////////////
        //Modified By - Rajeev Jain - 11/03/2021 - CR-20210924-15459
        Test.startTest();
        
        //Query inventory transaction 
        List<Inventory_Transaction__c> inventoryTransactions = [SELECT Id, Job_Ticket_MtM__c, Component_Code__c, Production_Tracking__c, Inventory__c, Effective_Quantity__c, Quantity_Remaining__c, Status__c FROM Inventory_Transaction__c];
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = inventoryTransactions[0].Production_Tracking__c;
        reqWrapper.printedQuantity = 200;
        reqWrapper.inventoryTransactions = new List<Inventory_Transaction__c>();
        reqWrapper.inventoryTransactions.addAll(inventoryTransactions);
        
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_PRINTED;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
	Util.BypassAllTriggers = false;
	
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
	Util.BypassAllTriggers = true;
		
        Production_Tracking__c productionTracking = [SELECT Id, Print_Quantity_Actual__c, Status__c FROM
                                                     Production_Tracking__c WHERE Id = :inventoryTransactions[0].Production_Tracking__c]; 
        
        System.assertEquals(200, productionTracking.Print_Quantity_Actual__c);
        System.assertEquals(Constants.PRODUCTION_TRACKING_STATUS_PRINTED, productionTracking.Status__c);
        
        List<Inventory_Transaction__c> updatedInvTransactions = [SELECT Id, Status__c FROM Inventory_Transaction__c];
        
        System.assertEquals(4, updatedInvTransactions.size()); 
        System.assertEquals('Printed - In Inventory', updatedInvTransactions[0].Status__c); 
        System.assertEquals('Printed - In Inventory', updatedInvTransactions[1].Status__c); 
        System.assertEquals('Printed - In Inventory', updatedInvTransactions[2].Status__c); 
        System.assertEquals('Printed - In Inventory', updatedInvTransactions[3].Status__c);
        
                
        ////////////////////////////////////////////
        // Scenario 6: CreateProductionTrackingBatch
        /////////////////////////////////////////////
        
        Creative_Package__c cPackage = [SELECT Id, Creative_Package_Counter_Id__c, Job_Ticket__c FROM Creative_Package__c LIMIT 1];
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.CreativePackageCounterId = cPackage.Creative_Package_Counter_Id__c;
        reqWrapper.BatchType = 'LiveData';
        reqWrapper.DataPostedDate = DateTime.now();
        reqWrapper.DataPostedQuantity = 100;
        reqWrapper.inventoryTransactionId = 'testId';
        reqWrapper.componentPackageCountJson = 'testJson';    
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_Create_Production_Tracking_Batch;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
        
            
	Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
        reqWrapper.BatchType = 'ArtProof';
		
	Util.BypassAllTriggers = true;
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_Create_Production_Tracking_Batch;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
	Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
        
	Util.BypassAllTriggers = true;
		
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_SHIPPED;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        try{
        	JobTicketService.updateJobTicket(); //execute the http post method
        }catch(Exception ex){}
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_RECEIVED;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        try{
        	JobTicketService.updateJobTicket(); //execute the http post method
        }catch(Exception ex){}
        
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_ERROR;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        try{
        	JobTicketService.updateJobTicket(); //execute the http post method
        }catch(Exception ex){}
        
        reqWrapper.BatchType = 'ArtProof';
        reqWrapper.success = false;
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_FILE_TRANSFER_STATUS;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
		
	Util.BypassAllTriggers = false;
		
        JobTicketService.updateJobTicket(); //execute the http post method
		
	Util.BypassAllTriggers = true;
        
        /////////////////////////////////
        // Scenario 7: Ready for Live Proof Approval - CODE COVERAGE INCREASE
        ////////////////////////////////
        
        //create artifact wrapper
        artWrapper = new JobTicketService.artifactWrapper();
        artWrapper.fileType = JobTicketService.FILE_TYPE_LIVE_PROOF;
        artWrapper.fileName = fName;
        artWrapper.filePath = dPath;
        
        //create the request wrapper for the body of the callout
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.artifacts.add(artWrapper);
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_READY_FOR_LIVEPROOF_APPROVAL;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
        Util.BypassAllTriggers = true;
        
         /////////////////////////////////
        // Scenario 8: READY_TO_PRINT - CODE COVERAGE INCREASE
        ////////////////////////////////
        
        //create artifact wrapper
        artWrapper = new JobTicketService.artifactWrapper();
        artWrapper.fileType = JobTicketService.FILE_TYPE_READY_TO_PRINT;
        artWrapper.fileName = fName;
        artWrapper.filePath = dPath;
        
        //create the request wrapper for the body of the callout
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.artifacts.add(artWrapper);
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_READY_TO_PRINT;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
        Util.BypassAllTriggers = true;
        
        /////////////////////////////////
        // Scenario 9: Inventory Update - CODE COVERAGE INCREASE
        ////////////////////////////////
        
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = inventoryTransactions[0].Production_Tracking__c;
        reqWrapper.printedQuantity = 200;
        reqWrapper.inventoryTransactions = new List<Inventory_Transaction__c>();
        reqWrapper.inventoryTransactions.addAll(inventoryTransactions);
        
        //reset request & response
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_UPDATE;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); //execute the http post method
        // status code is 500 beacuse iTransaction.Inventory__c is not rewritable on line 495 in JobTicketService class
        system.assertEquals(500, res.statusCode);
        
        Util.BypassAllTriggers = true;
        
        /////////////////////////////////
        // Scenario 10: Exception-Ready for Proof Approval
        ////////////////////////////////
        
        //create the request wrapper for the body of the callout
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        
        req = new RestRequest(); 
        res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_READY_FOR_PROOF_APPROVAL;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(500, res.statusCode);
        
        Util.BypassAllTriggers = true;
        
        Test.stopTest();
    }
    
     //test the updateJobTicket method - CR-20200721-14348 - Modified By Abhinav Sharma
    static testMethod void testUpdateJobTicket1() {
        
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c, (SELECT Id, Job_Ticket__c FROM Fulfillment_Tracking__r) FROM Job_Ticket__c];
        
        system.assertEquals(1, jobTickets.size());
        system.assertEquals(1, jobTickets[0].Fulfillment_Tracking__r.size());
        
       
        //get the production tracking record
        Production_Tracking__c pTracking = jobTickets[0].Fulfillment_Tracking__r[0];
        
        //create the request wrapper for the body of the callout
        JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.actualMailDate = system.today().addDays(3);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_MAILED;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        JobTicketService.updateJobTicket(); //execute the http post method
        
        system.assertEquals(200, res.statusCode);
        
        //get the production tracking record
        pTracking = [SELECT Id, Status__c, Mailed_Students__c, Mailed_Seeds__c, Job_Ticket__c,
                     CPM__c, Postage_Total__c, Actual_Mail_Date__c,Invoice_Number__c, Freight__c, Postage_Per_Piece__c, Mail_Cost_Total__c
                     FROM Production_Tracking__c WHERE Id = :pTracking.Id];
        system.assertEquals(system.today().addDays(3), pTracking.Actual_Mail_Date__c);
    }
    
    //09/06/2020 - CR-20200902-14488 - Victor Hanson
    //test the updateJobTicket method with RequestType = REQ_TYPE_UPDATE_PRODUCTION_TRACKING
    static testMethod void testUpdateProdTracking() {
        
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c, (SELECT Id, Job_Ticket__c FROM Fulfillment_Tracking__r) FROM Job_Ticket__c];
        
        system.assertEquals(1, jobTickets.size());
        system.assertEquals(1, jobTickets[0].Fulfillment_Tracking__r.size());
       
        //get the production tracking record
        Production_Tracking__c pTracking = jobTickets[0].Fulfillment_Tracking__r[0];
        
        //get picklist field options
        List<String> mailDateChangeReasons = MultiSelectPicklistController.getOptions(new Production_Tracking__c(), 'Mail_Date_Change_Reason__c');
        String changeReason = mailDateChangeReasons[0];
        
        //create the request wrapper for the body of the callout
        JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.productionTrackingId = pTracking.Id;
        reqWrapper.vendorMailDate = system.today().addDays(7);
        reqWrapper.mailDateChangeReason = changeReason;
        reqWrapper.initialImportCount = 10000;
        reqWrapper.failedImportCount = 100;
        reqWrapper.suppressionCount = 200;
        reqWrapper.seedImportCount = 700;
        reqWrapper.studentImportCount = 8000;
        reqWrapper.qualitySampleCount = 1000;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_UPDATE_PRODUCTION_TRACKING;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        JobTicketService.updateJobTicket(); //execute the http post method
        
        system.assertEquals(200, res.statusCode);
        
        //get the production tracking record
        pTracking = [SELECT Id, Status__c, Vendor_Mail_Date__c, Mail_Date_Change_Reason__c,
                     Initial_Count__c, Failed_Import_Count__c, Suppressed_Record_Count__c, 
                     Imported_Seeds__c, Imported_Students__c, Imported_Quality_Samples__c
                     FROM Production_Tracking__c WHERE Id = :pTracking.Id];
        system.assertEquals(system.today().addDays(7), pTracking.Vendor_Mail_Date__c);
        system.assertEquals(changeReason, pTracking.Mail_Date_Change_Reason__c);
        system.assertEquals(10000, pTracking.Initial_Count__c);
        system.assertEquals(100, pTracking.Failed_Import_Count__c);
        system.assertEquals(200, pTracking.Suppressed_Record_Count__c);
        system.assertEquals(700, pTracking.Imported_Seeds__c);
        system.assertEquals(8000, pTracking.Imported_Students__c);
        system.assertEquals(1000, pTracking.Imported_Quality_Samples__c);
    }
    
    // Modified By - Shalu Sharma - PrintMIS: XMPie API Updates release coverage increase
    static testMethod void test_ArtifactItemWrapper() 
    {
        List<Artifact__c> artifacts = [SELECT Id FROM Artifact__c];
        List<Production_Tracking__c> productionTrackings = [SELECT Id FROM Production_Tracking__c];
        
        List<Artifact_Item__c> artifactItemList = new List<Artifact_Item__c>();
        artifactItemList.add(new Artifact_Item__c(Name = 'Test ArtifactItem', Artifact__c = artifacts[0].Id, Item_Type__c = 'Ready to Print PDF',
                                                 Database_Count__c = 16000, XMPie_Count__c = 16000, Banner_Sheet_Count__c = 16, File_Name__c = 'Test.pdf'));
        Insert artifactItemList;
        Id artifactItemId = artifactItemList[0].Id;
        Id productionTrackingId = productionTrackings[0].Id;
        
        Test.startTest();
      	JobTicketService.artifactItemWrapper artfactItemWrap = new JobTicketService.artifactItemWrapper(); 
        artfactItemWrap.fileName = 'Test File';
        artfactItemWrap.itemType = 'Ready to Print PDF';
        artfactItemWrap.filePath = 'Test';
        artfactItemWrap.databaseCount = 1600;
        artfactItemWrap.xmpieCount = 1600;
        artfactItemWrap.vendorCount = 15;
        artfactItemWrap.recordCount = 15;
        artfactItemWrap.bannerSheetCount = 16;
        artfactItemWrap.id = artifactItemList[0].Id;
        Artifact_Item__c artfactItem = artfactItemWrap.getNewArtifactItem(artifactItemId);
        JobTicketService.artifactItemWrapper artfactItemWrapp = new JobTicketService.artifactItemWrapper(artfactItem);
        Test.stopTest();
    }
    
    //05/13/2021 - CR-20210310-14983 - Abhinav Sharma - Added
    static testMethod void test_InventoryShippedAndInventoryReceivedCallout()
    {
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc12', r_CEEB_Code__c='AE');
        insert inst;
        
         //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                   Name = 'Test Account 2', r_School_Code__c='abc11', r_CEEB_Code__c='AB');
        insert inst1;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Name = 'GW-5242-2021-ESNN-2', Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned'));
        insert jobTickets;
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
        insert jobTctComponet;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
        
        //Modify by - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
        Inventory__c inventory = new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                  Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id);
        insert inventory;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                                       Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000,  
                                                                       Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                       Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
        inventoryTransactions.add(invTxn);
        insert inventoryTransactions;
        
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        //create the request wrapper for the body of the callout
        JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.inventoryTransactionId = inventoryTransactions[0].Id;
		reqWrapper.productionTrackingId = pTrackings[0].Id;
		reqWrapper.componentCode = inventory.Inventory_Control_Number__c;
        //reqWrapper.inventoryTransactions = inventoryTransactions;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_SHIPPED;//Request URL  
        req.httpMethod = Constants.HTTP_REQUEST_POST_TYPE;//HTTP Request Type 
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        
        req1.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_RECEIVED;//Request URL  
        req1.httpMethod = Constants.HTTP_REQUEST_POST_TYPE;//HTTP Request Type 
        req1.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req1;
        RestContext.response= res1;
        JobTicketService.updateJobTicket(); //execute the http post method
        system.assertEquals(200, res.statusCode);
        
        Test.stopTest();
    }
    
    //05/13/2021 - CR-20210310-14983 - Abhinav Sharma - Added for -ve use case
    static testMethod void testNegCaseFor_InventoryShippedAndInventoryReceivedCallout()
    { 
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc12', r_CEEB_Code__c='AE');
        insert inst;
        
         //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                   Name = 'Test Account 2', r_School_Code__c='abc11', r_CEEB_Code__c='AB');
        insert inst1;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Name = 'GW-5242-2021-ESNN-2', Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                         Descriptive_Name__c = 'Test Desciptive', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned'));
        insert jobTickets;
        
        Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
        insert jobTctComponet;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
        insert pTrackings;
        
        //Modify by - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
        Inventory__c inventory = new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                  Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id);
        insert inventory;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                                       Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                                       Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                       Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
        inventoryTransactions.add(invTxn); 
        insert inventoryTransactions;
        
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        try
        {
            //create the request wrapper for the body of the callout
            JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
            reqWrapper.inventoryTransactionId = null;
            reqWrapper.productionTrackingId = pTrackings[0].Id;
            reqWrapper.componentCode = inventory.Inventory_Control_Number__c;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_SHIPPED;//Request URL  
            req.httpMethod = Constants.HTTP_REQUEST_POST_TYPE;//HTTP Request Type 
            req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
            RestContext.request = req;
            RestContext.response= res;
            JobTicketService.updateJobTicket(); //execute the http post method
        }
        Catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('inventoryTransactionId is required when calling') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);	    
        }
        
        try{
            
            //create the request wrapper for the body of the callout
            JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
            reqWrapper.inventoryTransactionId = null;
            reqWrapper.productionTrackingId = pTrackings[0].Id;
            reqWrapper.componentCode = inventory.Inventory_Control_Number__c;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_INVENTORY_RECEIVED;//Request URL  
            req.httpMethod = Constants.HTTP_REQUEST_POST_TYPE;//HTTP Request Type 
            req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
            RestContext.request = req;
            RestContext.response= res;
            JobTicketService.updateJobTicket();
        }
        Catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('inventoryTransactionId is required when calling') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);	    
        }
        
        Test.stopTest();
    }
    
    //04/26/2022 - CR-20220302-15977 - Shalu Sharma 
    static testMethod void test_CreateProductionTrackingBatchRequest() 
    {
        String fName = 'Proof_v1.zip';
        String dPath = '/vendorFolder1/Test/';
        
        Util.BypassAllTriggers = true;
        
        //Creating Account record
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test Account 1',
                                   Account_Formal_Name__c = 'Sepire', r_School_Code__c = '4321');
        insert inst;
        
        //Creating a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        insert user1;
        
        //Creating Project record
        Project__c project = new Project__c(Name = 'Test Project 1', Institution__c = inst.Id);
        insert project;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned', Project__c = project.Id, Project_ID__c = '29694', Status__c = 'Draft', 
                                         Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test Job Ticket 1', Art_Director__c = user1.Id, Mail_Quantity__c = 100, 
                                         Change_Reason__c = 'Testing before update'));
        insert jobTickets;
        
        //Creating Job Ticket Component Records
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test Job Ticket Component 1', Component__c = Constants.COMPONENT_TYPE_BRE));
        insert jobTicketComponents;
        
        //Creating Job Ticket MTM Record 
        List<Job_Ticket_MTM__c> jobTicketMTMs = new List<Job_Ticket_MTM__c>();
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        insert jobTicketMTMs;
        
        //Creating the Creative Package record 
        List<Creative_Package__c> listCreativePackage = new List<Creative_Package__c>();
        listCreativePackage.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id));
        insert listCreativePackage;        

        //Creating Production Tracking record
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Drop__c = 1,Art_File_Name__c = 'test', Creative_Package__c = listCreativePackage[0].Id, Status__c = 'Planned',
                                                           Job_Ticket__c = jobTickets[0].Id,Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Job_Ticket_MtM__c = jobTicketMTMs[0].Id));
        productionTrackings.add(new Production_Tracking__c(RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Drop__c = 2,Art_File_Name__c = 'test', Creative_Package__c = listCreativePackage[0].Id, Status__c = 'Planned',
                                                           Job_Ticket__c = jobTickets[0].Id,Status_Detail__c = '',Mail_Shop_Vendor__c = inst.Id, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Job_Ticket_MtM__c = jobTicketMTMs[0].Id));	    
	    insert productionTrackings;
        
        Util.BypassAllTriggers = false;
        
        //Creating artifact record
        List<Artifact__c> artifactList = new List<Artifact__c>();
        artifactList.add(new Artifact__c(Type__c = 'Artwork', Status__c ='failure',Production_Tracking__c = productionTrackings[0].Id, Job_Ticket__c = jobTickets[0].Id ));
        Insert artifactList;
        
        Util.BypassAllTriggers = true;
        
        ////////////////////////////////////////////
        // Scenario 6: CreateProductionTrackingBatch
        /////////////////////////////////////////////
        
        Creative_Package__c cPackage = [SELECT Id, Creative_Package_Counter_Id__c, Job_Ticket__c FROM Creative_Package__c LIMIT 1];
        
        //create the request wrapper for the body of the callout
        JobTicketService.requestWrapper reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper = new JobTicketService.requestWrapper();
        reqWrapper.CreativePackageCounterId = cPackage.Creative_Package_Counter_Id__c;
        reqWrapper.BatchType = 'ArtProof';
        reqWrapper.DataPostedDate = DateTime.now();
        reqWrapper.DataPostedQuantity = 100;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = ENDPOINT_BASE + JobTicketService.REQ_TYPE_Create_Production_Tracking_Batch;  //Request URL
        req.httpMethod = Constants.HTTP_REQUEST_GET_TYPE;//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(reqWrapper)); //include the request wrapper in the body
        RestContext.request = req;
        RestContext.response= res;
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); 
        
        Util.BypassAllTriggers = true;
        
        List<Production_Tracking__c> listOfPTs = [SELECT Id FROM Production_Tracking__c];
        delete listOfPTs[0];
        
        Util.BypassAllTriggers = false;
        
        JobTicketService.updateJobTicket(); 
        
        Util.BypassAllTriggers = true;
    }
}