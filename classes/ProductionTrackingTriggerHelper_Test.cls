/**
    * Purpose          :   Test class for ProductionTrackingTriggerHelper
    * 
    * CreatedDate      :   14/02/2020
    * 
    * RevisionLog      :   V_1.0 - Created - Dipesh Gupta
    *                      V_1.1 - Created - Dipesh Gupta - 4/10/2020
    *                      V_1.2 - Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
    *                      V_1.3 - Modified - Victor Hanson - 06/01/2020 - CR-20200601-14128 - updated testArtFileNameUpdate & testcreateArtifactForProductionTracking
    *                      V_1.4 - Modified - Victor Hanson - 06/03/2020 - CR-20200603-14137 - fixed unit test failure
    *                      V_1.5 - Modified - Victor Hanson - 06/11/2020 - CR-20200611-14176 - added testPopulateProductionTrackingFieldsFromJT
    *                      V_1.6 - Modified - Victor Hanson - 06/17/2020 - CR-20200610-14165 - updated testcreateArtifactForProductionTracking
    *                      V_1.7 - Modified - Victor Hanson - 08/18/2020 - CR-20200803-14397 -
    *                      V_1.8 - Modified - Victor Hanson - 09/30/2020 - CR-20200928-14562 - Added reference to custom headers field
    *                      V_1.9 - Modified - Victor Hanson - 12/08/2020 - CR-20201012-14597 - Updated existing methods & added code to test the new Proof Generation Internal/External process
    *                      V_2.0 - Modified - Neha Sharma - 04/1/2020  - CR-20210322-15011 - add new method
    *                      V_2.1 - Modified - Mahendra Swarnkar - CR-20210325-15027
    *                      V_2.2 - Modified - Abhinav Sharma - 06/14/2021 - CR-20210525-15180 - Print Inventory Field additions (Make "Production Tracking" as master-detail on Inventory)
    *                      V_2.3 - Modified - Nikita Kumari - 06/17/2021 - CR-20210517-15150 - Run All test fixes
    *                      V_2.4 - Modified - Nikita Kumari - 10/01/2021 - CR-20210916-15441 - added new test method for populatePostageClassOnPT method.
    *          		   V_2.5 - Modified - CR-20210924-15459 - 10/04/2021 - Shalu Sharma - Added a new methods "test_populateMailshopPTStatusOnInventoryTransaction" and "test_createInventoryAndTransForPrintPT"
    *			   V_2.6 - Modified - Subhash - 10/25/2021 - CR-20210920-15450 - Added calling new method "unLockProductionTrackingRecordOnBackTracking" 
    *			   V_2.7 - Modified - Shalu Sharma - 4/29/2022 - CR-20220428-16145 - Added method i.e. test_getAuthTokenForColorArtVendor
    * Code Coverage    :   96%
    * */
@IsTest
private class ProductionTrackingTriggerHelper_Test
{   
    public static final String STATUS_DETAIL_SUBMITTED = 'Submitted';
    public static final String STATUS_DETAIL_APPROVED = 'Approved';
    private static final String testArtFileName = 'artFile1.zip';
    
    @testSetup static void testSetupData()
    {
        
        //get name of one of the vendors specified in Vendor 
        List<Artifact_Transfer_Setting__mdt> ats = [SELECT Id, Mail_Shop_Vendor__c FROM Artifact_Transfer_Setting__mdt
                                                    WHERE Mail_Shop_Vendor__c != null AND Artifact_Type__c = 'Artwork' AND Proof_Generation__c = 'External' ORDER By MasterLabel ASC];
        
        // Create Account with the vendor name from ATS.Mail_Shop_Vendor__c
        Datetime historicalLinkerOverride = Datetime.newInstance(2011, 1, 1);
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', Historical_Linker__c = ats[0].Mail_Shop_Vendor__c, CreatedDate=historicalLinkerOverride,
                                   r_School_Code__c='abc12', r_CEEB_Code__c='abcd');
        util.bypassAllTriggers = true;
        insert inst;
        util.bypassAllTriggers = false;
        
        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        util.BypassAllTriggers = true;
        insert proj;
        util.BypassAllTriggers = false;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user1 = testUtilities.CreateNewUser(sysAdminProfile, false);
        user1.LastName = 'sysAdminUser';
        util.bypassAllTriggers = true;
        insert user1;
        util.bypassAllTriggers = false;
        
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        //12/08/2020 - CR-20201012-14597 - Victor Hanson - removed campaign reference
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id,Drop_Type__c = 'Pre Planned', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020'));
        insert jobTickets;
        
        //12/09/2020 - CR-20201012-14597 - Victor Hanson - added so we don't have to re-create pTracking records in each unit test
        // Insert Internal & External production_Tracking__c
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 1, Art_File_Name__c = testArtFileName));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 2, Art_File_Name__c = testArtFileName));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, Internal_Data_Drop__c = 3, Art_File_Name__c = testArtFileName));
        insert pTrackings;
        
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
    //Victor Hanson - 06/11/2020 - CR-20200611-14176 - added
    @IsTest static void testPopulateProductionTrackingFieldsFromJT() {
        //get vendor institutions
        List<Account> vendorAccts = [SELECT Id FROM Account WHERE RecordTypeId = :Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR];
        
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Mail_Vendor__c, Project_Manager__c, Status__c FROM Job_Ticket__c];
        
        // Insert production_Tracking__c
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        insert productionTrackings;
        
        //get prod tracking
        productionTrackings = [SELECT Id, Mail_Shop_Vendor__c FROM Production_Tracking__c WHERE Id IN :productionTrackings];
        system.assertEquals(null, productionTrackings[0].Mail_Shop_Vendor__c);
        
        //set mail vendor on job ticket
        jobTickets[0].Mail_Vendor__c = vendorAccts[0].Id;
        update jobTickets[0];
        
        //get prod tracking & verify the mail shop vendor (assigned vendor) is updated
        productionTrackings = [SELECT Id, Mail_Shop_Vendor__c FROM Production_Tracking__c WHERE Id IN :productionTrackings];
        system.assertEquals(jobTickets[0].Mail_Vendor__c, productionTrackings[0].Mail_Shop_Vendor__c);
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
    @IsTest static void testJobTicketTriggerHelper()
    {
        // Query Job_Ticket
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c FROM Job_Ticket__c];
        
        List<Account> institutes = [SELECT Id, Vendor_Sub_Type__c FROM Account ];
        
        Test.startTest();
        
        //Insert inst1;  
        
        // Insert production_Tracking__c
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  institutes[0].Id,Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF, Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  institutes[0].Id,Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF, Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  institutes[0].Id,Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF, Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_APPROVAL,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        insert productionTrackings;
        
        // Query Production Tracking
        List<Production_Tracking__c> prodTrackings = [SELECT Id, JT_Project_Manager__c, Status__c FROM Production_Tracking__c];
        
        system.assertEquals(jobTickets[0].Project_Manager__c,prodTrackings[0].JT_Project_Manager__c);
        system.assertEquals(jobTickets[0].Project_Manager__c,prodTrackings[1].JT_Project_Manager__c);
        
        //productionTrackings[0].Job_Ticket__c = null;
        //update productionTrackings;
        
        //system.assertEquals(null,productionTrackings[0].JT_Project_Manager__c);
        
        Test.stopTest();
        
    }
    
    //06/19/2020 - CR-20200619-14206 - Victor Hanson - test getAuthToken method
    @IsTest static void testgetAuthToken() {
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        //get callout credentials for vendor
        //09/30/2020 - CR-20200928-14562 - Victor Hanson - Added reference to custom headers field
        List<API_Endpoints__mdt> apiEndpoints = [SELECT Id, Endpoint_URL__c, Related_Record_Id__c, Authorization_Token__c,
                                                 Certificate_API_Name__c, Authorize_Endpoint_URL__c, Authorization_Body__c, Custom_Headers__c
                                                 FROM API_Endpoints__mdt
                                                 WHERE Related_Record_Id__c != null 
                                                 AND Authorize_Endpoint_URL__c != null];
        system.assert(apiEndpoints.size() > 0);
        test.startTest();
        String authToken = ProductionTrackingTriggerHelper.getAuthToken(apiEndpoints[0]);
        test.stopTest();
        system.assertEquals(null, authToken, 'should return null when executing within unit test');
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
    //06/17/2020 - CR-20200610-14165 - Victor Hanson - updated testupdateArtifactTransferAndProductionTracking
    //06/03/2020 - CR-20200603-14137 - Victor Hanson - fixed unit test failure 
    @IsTest static void testcreateArtifactForProductionTracking()
    {
        String artFileName = 'artFile.zip';
        String mailingListName = 'mailingListFile.zip';
        // Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Util.bypassAllTriggers = true;
        
        //get the vendor institution
        List<Account> vendorAccts = [SELECT Id FROM Account WHERE Vendor_Sub_Type__c = :Constants.VENDOR_TYPE_DIGITAL];
        system.assertNotEquals(0, vendorAccts.size(), 'At least one vendor Institution should have been returned because it was created in testSetup');
        
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c,Drop_Type__c, Status__c FROM Job_Ticket__c];
        jobTickets[0].Drop_Type__c = 'Pre Planned';
        
        update jobTickets;
        
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Status__c, Status_Detail__c, Art_File_Name__c, BOX_Folder_Link__c, Proof_Generation__c,
                                                            Proof_Approval_Status__c, Suppression_File_Name__c,Live_Proof_Approval_Status__c, Internal_Data_Drop__c
                                                            FROM Production_Tracking__c
                                                            WHERE Job_Ticket__c IN :jobTickets AND (Proof_Generation__c =: ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL OR Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL)
                                                            ORDER BY Internal_Data_Drop__c ASC];
        System.assertEquals(ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, productionTrackings[2].Proof_Generation__c);
        
        //clear out any existing artifacts
        delete [SELECT Id, Type__c, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Job_Ticket__c = :jobTickets[0].Id];
        
        //create the 'proof' artifact
        productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTrackings[2].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        productionTrackings[2].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        productionTrackings[0].Art_File_Name__c = artFileName;
        productionTrackings[2].Art_File_Name__c = artFileName;
        productionTrackings[0].Suppression_File_Name__c = 'Suppress.csv';
        productionTrackings[2].Suppression_File_Name__c = 'Suppress.csv';
        productionTrackings[0].BOX_Folder_Link__c = 'http://www.test.com';
        productionTrackings[2].BOX_Folder_Link__c = 'http://www.test.com';
        
        Util.bypassAllTriggers = false;
        
        update productionTrackings;
        
        Util.bypassAllTriggers = true;
        
        List<Artifact__c> artifacts = [SELECT Id FROM Artifact__c 
                                       WHERE Production_Tracking__c = :productionTrackings[0].Id 
                                       AND Type__c =: Constants.ARTIFACT_TYPE_ARTWORK];
        system.assertEquals(1, artifacts.size());
        
        List<Artifact__c> artifactForInternal = [SELECT Id FROM Artifact__c 
                                                 WHERE Production_Tracking__c = :productionTrackings[2].Id 
                                                 AND Type__c = :Constants.ARTIFACT_TYPE_ARTWORK];
        system.assertEquals(1, artifactForInternal.size());
        
        //Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //set all artifact transfer status to Success
        List<Artifact_Transfer__c> atsToUpdate = [SELECT Id, Status__c, Project_Manager__c FROM Artifact_Transfer__c
                                                  WHERE Artifact__r.Production_Tracking__c =: productionTrackings[0].Id 
                                                  AND Artifact__r.Type__c =: Constants.ARTIFACT_TYPE_ARTWORK];
        system.assertEquals(2, atsToUpdate.size());
        system.assertEquals(jobTickets[0].Project_Manager__c, atsToUpdate[0].Project_Manager__c);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Status__c = 'Success';
            ats.Target_File_Name__c = artFileName;
        }
        Util.bypassAllTriggers = false;
        
        update atsToUpdate;
        
        //create the 'mailing list' artifact
        productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        productionTrackings[2].Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        productionTrackings[2].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        
        //12/01/2020 - CR-20201012-14597 - Victor Hanson - reset artifact generated
        ProductionTrackingTriggerHelper.artifactGenerationHasExecuted = false;
        
        Test.startTest(); 
        
        update productionTrackings;
        
        Util.bypassAllTriggers = true;
        //Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //set all artifact transfer status to Success
        atsToUpdate = [SELECT Id, Status__c FROM Artifact_Transfer__c
                       WHERE Artifact__r.Production_Tracking__c =: productionTrackings[0].Id 
                       AND Artifact__r.Type__c = :Constants.ARTIFACT_TYPE_MAILING_LIST];
        
        system.assert(atsToUpdate.size() > 0);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Status__c = 'Success';
            ats.Target_File_Name__c = mailingListName;
        }

        Util.bypassAllTriggers = false;
        
        update atsToUpdate;
        
        //set ready for print
        productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT;
        productionTrackings[2].Status__c = Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED;
        productionTrackings[2].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED;
        update productionTrackings[0];
        
        //manually create the artifact for artwork proof, because this is normally created via callout
        Artifact__c artworkProof = new Artifact__c(Job_Ticket__c = jobTickets[0].Id, Production_Tracking__c = productionTrackings[0].Id,
                                                   Type__c = Constants.ARTIFACT_TYPE_ARTWORK_PROOF, Status__c = Constants.ARTIFACT_STATUS_STAGING);
        insert artworkProof;
        
        //Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //get artifacts & artifact transfers
        Util.bypassAllTriggers = true;
        
        artifacts = [SELECT Id, Type__c, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Job_Ticket__c = :jobTickets[0].Id];
        system.assertEquals(6, artifacts.size(), 'Should be three artifacts.  One for each status that triggers artifact creation.');
        for (Artifact__c artifact : artifacts) {
            system.assertNotEquals(null, artifact.Artifact_Transfers__r, 'At least one artifact transfer should exist based on the Artifact Transfer Setting');
        }
        
        //update approval status
        productionTrackings[0].Proof_Approval_Status__c = 'Approved';
        productionTrackings[0].Live_Proof_Approval_Status__c = 'Approved';
        
        Util.bypassAllTriggers = false;
        
        update productionTrackings[0];
        
        Util.bypassAllTriggers = true;
        
        artifacts = [SELECT Id, Type__c, Approval_Status__c FROM Artifact__c WHERE Production_Tracking__c = :productionTrackings[0].Id];
        //verify approval status was updated
        for (Artifact__c artifact : artifacts) {
            if (artifact.Type__c == Constants.ARTIFACT_TYPE_ARTWORK_PROOF)
                system.assertEquals('Approved', artifact.Approval_Status__c, 'Approval Status should match production tracking.Proof Approval Status');
            else if (artifact.Type__c == Constants.ARTIFACT_TYPE_LIVE_PROOF_DATA)
                system.assertEquals('Approved', artifact.Approval_Status__c, 'Approval Status should match production tracking.Live Proof Approval Status');
        }
	
        Test.stopTest();
        
        //set all artifact transfer status to Success
        atsToUpdate = [SELECT Id, Status__c, Result__c, Target_File_Name__c, Artifact__r.Production_Tracking__r.Art_File_Name__c FROM Artifact_Transfer__c
                       WHERE Artifact__r.Production_Tracking__c = :productionTrackings[0].Id];
        system.assert(atsToUpdate.size() > 0);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Target_File_Name__c = ats.Artifact__r.Production_Tracking__r.Art_File_Name__c;
            ats.Status__c = 'Success';
        }
        
        Util.bypassAllTriggers = false;
        
        update atsToUpdate;
        /*
        //08/18/2020 - CR-20200803-14397 - Victor Hanson - added retry count reference to fix unit test
        //VH 06/17/2020 - get artifact transfers, mark one as a Failure, and verify the artifact & prod tracking are updated too
        //update artifact transfer to failed
        atsToUpdate[0].Retry_Count__c = Decimal.valueOf(Label.Artifact_Transfer_Max_Retries);
        atsToUpdate[0].Status__c = ArtifactTransferHelper.FAILURE;
        atsToUpdate[0].Result__c = 'file not found';
        update atsToUpdate[0];
        
        Util.bypassAllTriggers = true;
        
        atsToUpdate = [Select Id, Status__c, Artifact__r.Status__c, Artifact__r.Production_Tracking__r.Status_Detail__c 
                       From Artifact_Transfer__c WHERE Id = :atsToUpdate[0].Id LIMIT 1];
        system.assertEquals(ArtifactTransferHelper.FAILURE, atsToUpdate[0].Artifact__r.Status__c);
        system.assertEquals(ArtifactTransferHelper.FILE_ISSUE, atsToUpdate[0].Artifact__r.Production_Tracking__r.Status_Detail__c);
        
        //Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //get the web service logs on the product tracking record and verify 3 exist - one for each callout to the vendor
        // (Proof-Submitted, Live Proof-Submitted, and Ready for Print-Approved)
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c 
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :productionTrackings[0].Id];
        //system.assert(wsLogs.size() > 0, 'a callout should be sent when setting Artwork & Mailing List artifact transfers to success');
        
        //08/18/2020 -  - Victor Hanson - Set Drop2 directly to Live Proof, since the artwork is not changing
        Production_Tracking__c drop2 = productionTrackings[1];
        system.assertEquals(2, drop2.Internal_Data_Drop__c);
        drop2.Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        drop2.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        drop2.Art_File_Name__c = artFileName;
        drop2.BOX_Folder_Link__c = 'http://www.test.com';
        
        //12/01/2020 - CR-20201012-14597 - Victor Hanson - reset artifact generated
        ProductionTrackingTriggerHelper.artifactGenerationHasExecuted = false;
        
        Util.bypassAllTriggers = false;
        
        update drop2;
        
        Util.bypassAllTriggers = true;
        
        //set all artifact transfer status to Success
        atsToUpdate = [SELECT Id, Status__c, Result__c FROM Artifact_Transfer__c
                       WHERE Artifact__r.Production_Tracking__c = :drop2.Id];
        system.assert(atsToUpdate.size() > 0);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Status__c = 'Success';
        }
        
        Util.bypassAllTriggers = false;
        
        update atsToUpdate;
        
        Util.bypassAllTriggers = true;
        
        drop2 = [SELECT Id, Status__c, Status_Detail__c, Job_Ticket__c, Art_File_Name__c
                 FROM Production_Tracking__c WHERE Id = :drop2.Id];
        //get map of artifact transfers
        Map<String, Artifact_Transfer__c> mapJTArtifactTx = ProductionTrackingTriggerHelper.getMapJTArtifactTransfers(new List<Production_Tracking__c> { drop2 });
        JobTicketService.artifactWrapper awArtwork = ProductionTrackingTriggerHelper.getArtifactTransfer(mapJTArtifactTx, drop2, Constants.ARTIFACT_TYPE_ARTWORK, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true);
        JobTicketService.artifactWrapper awMailingList = ProductionTrackingTriggerHelper.getArtifactTransfer(mapJTArtifactTx, drop2, Constants.ARTIFACT_TYPE_MAILING_LIST, Constants.ARTIFACT_TRANSFER_DIRECTION_PUSH, true);
        system.assertNotEquals(null, awArtwork);
        system.assertNotEquals(null, awMailingList);
        
        Util.bypassAllTriggers = false;*/

    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - updated to include proof generation
    //06/01/2020 - CR-20200601-14128 - Victor Hanson - updated so the Prod Tracking status detail is submitted
    //Verify that when the Art File Name changes on the first Production Tracking record, all subsequent tracking records have
    //their art file name updated too
    @IsTest static void testArtFileNameUpdate()
    {
        String artFileName = 'Test1.zip';
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c FROM Job_Ticket__c];
        //get the vendor institution
        List<Account> vendorAccts = [SELECT Id FROM Account WHERE Vendor_Sub_Type__c = :Constants.VENDOR_TYPE_DIGITAL];
        
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Drop__c = 1,Job_Ticket__c = jobTickets[0].Id, Mail_Shop_Vendor__c=vendorAccts[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        productionTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Drop__c = 2,Job_Ticket__c = jobTickets[0].Id, Mail_Shop_Vendor__c=vendorAccts[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL));
        insert productionTrackings;
        
        Test.startTest();
        
        //set the Artifact Transfer to approved
        List<Artifact_Transfer__c> aTx = [SELECT Id, Status__c FROM Artifact_Transfer__c WHERE Status__c != 'Success'];
        for (Artifact_Transfer__c at : aTx) at.Status__c = 'Success';
        update aTx;
        
        productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        productionTrackings[0].Art_File_Name__c = artFileName;
        productionTrackings[0].BOX_Folder_Link__c = 'http://www.test.com';
        update  productionTrackings[0];
        
        Test.stopTest();
        
        //get all production tracking records
        productionTrackings = [SELECT Id, Art_File_Name__c FROM Production_Tracking__c WHERE Id IN :productionTrackings];
        for (Production_Tracking__c pTracking : productionTrackings) {
            system.assertEquals(artFileName, pTracking.Art_File_Name__c);
        }
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - sets Status to Live Proof-Pending Mail Date Confirmation, which sends a callout to vendor
    @IsTest static void testMailDateConfirmationRequest() {
        
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c FROM Production_Tracking__c WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL];
        
        test.startTest();
        
        Util.bypassAllTriggers = true;
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        update pTracking;
        
        Util.BypassAllTriggers = false;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION;
        update pTracking;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c 
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_MAIL_DATE_CONFIRMATION_REQUEST];
        system.assertEquals(1, wsLogs.size(), 'there should be one web service log');
        system.assertEquals(wsLogs[0].Web_Service_Method__c, ProductionTrackingTriggerHelper.COMMAND_MAIL_DATE_CONFIRMATION_REQUEST, 'ws method should be mailDateConfirmationRequest');
        
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - sets the Vendor Mail Date field, which sends a callout to AWS notifying of the confirmed date
    @IsTest static void testMailDateConfirmed() {
        
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c FROM Production_Tracking__c WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL];
        
        test.startTest();
        
        Util.bypassAllTriggers = true;
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION;
        update pTracking;
        
        Util.BypassAllTriggers = false;
        pTracking.Vendor_Mail_Date__c = Date.today();
        update pTracking;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c 
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_MAIL_DATE_CONFIRMED];
        system.assertEquals(1, wsLogs.size(), 'there should be one web service log');
        system.assertEquals(wsLogs[0].Web_Service_Method__c, ProductionTrackingTriggerHelper.COMMAND_MAIL_DATE_CONFIRMED, 'ws method should be mailDateConfirmed');
        
    }

    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - test the callout to AWS when Status is Live Proof-Ready For Print & Proof Generation is Internal
    @IsTest static void testCheckLiveProofApproved() {
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c FROM Production_Tracking__c WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL];
        
        //create Artifact: Type=Ready To Print
        List<Artifact__c> artifacts = new List<Artifact__c>();
        artifacts.add(new Artifact__c(Job_Ticket__c=pTracking.Job_Ticket__c, Production_Tracking__c=pTracking.Id, Type__c=Constants.ARTIFACT_TYPE_ARTWORK, Source_File_Name_Exact_Override__c=testArtFileName, Source_Directory_Path_Override__c='/AG12-1535-2020-ESYRS/', Proof_Generation__c=ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL,Drop_Type__c ='Pre Planned'  ));
        artifacts.add(new Artifact__c(Job_Ticket__c=pTracking.Job_Ticket__c, Production_Tracking__c=pTracking.Id, Type__c=Constants.ARTIFACT_TYPE_READY_TO_PRINT, Source_File_Name_Exact_Override__c=testArtFileName, Source_Directory_Path_Override__c='/AG12-1535-2020-ESYRS/', Proof_Generation__c=ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL , Drop_Type__c ='Pre Planned'));
        insert artifacts;
        
        List<Artifact_Transfer__c> aTxs = [SELECT Id, Status__c FROM Artifact_Transfer__c
                                           WHERE Artifact__c IN :artifacts];
        system.assertNotEquals(null, aTxs);
        system.assert(aTxs.size() > 0);
        for (Artifact_Transfer__c aTx : aTxs) {
            aTx.Status__c = 'Success';
            aTx.Target_File_Name__c = testArtFileName;
        }
        util.bypassAllTriggers = true;
        update aTxs;
        
        test.startTest();
        
        Util.bypassAllTriggers = true;
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_PENDING_MAIL_DATE_CONFIRMATION;
        pTracking.Vendor_Mail_Date__c = Date.today();
        util.bypassAllTriggers = true;
        update pTracking;
        util.bypassAllTriggers = false;
        
        pTracking.Live_Proof_Approval_Status__c = 'Approved';
        pTracking.Live_Proof_File_Received_DateTime__c = system.now();
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED;
        update pTracking;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c 
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_READY_FOR_PRINT_APPROVED];
        system.assertEquals(1, wsLogs.size(), 'there should be one web service log');
        system.assertEquals(wsLogs[0].Web_Service_Method__c, ProductionTrackingTriggerHelper.COMMAND_READY_FOR_PRINT_APPROVED, 'ws method should be readyForPrintApproved');
        
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - test the Proof-Submitted process when Proof Generation=Internal
    @IsTest static void testCheckReadyForProof() {
        
        //get name of one of the vendors specified in Vendor 
        List<Artifact_Transfer_Setting__mdt> ats = [SELECT Id, Mail_Shop_Vendor__c FROM Artifact_Transfer_Setting__mdt
                                                    WHERE Mail_Shop_Vendor__c != null AND Artifact_Type__c	= 'Artwork' AND Proof_Generation__c = 'Internal' AND  Drop_Type__c = 'On Demand' ORDER By MasterLabel ASC];
        
        List<Account> institutions = [SELECT Id,Historical_Linker__c FROM Account WHERE Vendor_Sub_Type__c = :Constants.VENDOR_TYPE_DIGITAL];
        
        institutions[0].Historical_Linker__c = ats[0].Mail_Shop_Vendor__c;
        
        util.bypassAllTriggers = true;
        update institutions;
        util.bypassAllTriggers = false;
        
        
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c, Job_Ticket__r.Drop_Type__c FROM Production_Tracking__c WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL];
        
        //create Artifact: Type=Ready To Print
        List<Artifact__c> artifacts = new List<Artifact__c>();
        artifacts.add(new Artifact__c(Job_Ticket__c=pTracking.Job_Ticket__c, Production_Tracking__c=pTracking.Id, Type__c=Constants.ARTIFACT_TYPE_ARTWORK, Source_File_Name_Exact_Override__c='testArt.zip', Source_Directory_Path_Override__c='/AG12-1535-2020-ESYRS/', 
                                      Proof_Generation__c=ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL , Drop_Type__c = 'On Demand'));
        insert artifacts;
        
        test.startTest();
        
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        update pTracking;
        
        List<Artifact_Transfer__c> aTxs = [SELECT Id, Status__c, Target_File_Name__c FROM Artifact_Transfer__c
                                           WHERE Artifact__c IN :artifacts];
        system.assertNotEquals(null, aTxs);
        for (Artifact_Transfer__c aTx : aTxs) {
            aTx.Status__c = 'Success';
            aTx.Target_File_Name__c = 'test.zip';
        }
        //once the artifact Transfer status changes to Success and the related Artifact's Proof Generation = Internal, it should send callout to AWS for proof submission
        update aTxs;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, URL__c
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_PROOF_SUBMITTED];
    }
    
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - tests a scenario where Proof Generation is Internal, but need to send art externally so vendor has envelope/BRE artwork
    @IsTest static void testCheckReadyForProof_InternalExternal() {
        
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c FROM Production_Tracking__c WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL];
        
        //create Artifact: Type=Ready To Print, Proof Generation=External
        List<Artifact__c> artifacts = new List<Artifact__c>();
        artifacts.add(new Artifact__c(Job_Ticket__c=pTracking.Job_Ticket__c, Production_Tracking__c=pTracking.Id, Type__c=Constants.ARTIFACT_TYPE_ARTWORK, Source_File_Name_Exact_Override__c='testArt.zip', Source_Directory_Path_Override__c='/AG12-1535-2020-ESYRS/', 
                                      Proof_Generation__c=ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Drop_Type__c = 'Pre Planned'));
        insert artifacts;
        
        test.startTest();
        
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED;
        update pTracking;
        
        List<Artifact_Transfer__c> aTxs = [SELECT Id, Status__c, Target_File_Name__c FROM Artifact_Transfer__c
                                           WHERE Artifact__c IN :artifacts];
        system.assertNotEquals(null, aTxs);
        system.assert(aTxs.size() > 0);
        for (Artifact_Transfer__c aTx : aTxs) {
            aTx.Status__c = 'Success';
            aTx.Target_File_Name__c = 'test.zip';
        }
        //once the artifact Transfer status changes to Success and the related Artifact's Proof Generation = Internal, it should send callout to AWS for proof submission
        util.bypassAllTriggers = false;
        update aTxs;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, URL__c
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_PROOF_APPROVED];
        system.assertEquals(1, wsLogs.size(), 'there should be one web service log');
        system.assertEquals(wsLogs[0].Web_Service_Method__c, ProductionTrackingTriggerHelper.COMMAND_PROOF_APPROVED, 'ws method should be proofApproved');
    }
    
    //checkApproved
    //12/07/2020 - CR-20201012-14597 - Victor Hanson - added - when Status Detail is Approved, send a callout to Vendor if Proof Generation = External
    @IsTest static void testCheckApproved() {
        
        // get production tracking where Proof Generation is Internal
        Production_Tracking__c pTracking = [SELECT Id, Mail_Shop_Vendor__c, Status__c, Proof_Generation__c, Job_Ticket__c FROM Production_Tracking__c 
                                            WHERE Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL
                                            LIMIT 1];
        
        //create Artifact: Type=Ready To Print, Proof Generation=External
        List<Artifact__c> artifacts = new List<Artifact__c>();
        artifacts.add(new Artifact__c(Job_Ticket__c=pTracking.Job_Ticket__c, Production_Tracking__c=pTracking.Id, Type__c=Constants.ARTIFACT_TYPE_ARTWORK, Source_File_Name_Exact_Override__c=testArtFileName, Source_Directory_Path_Override__c='/AG12-1535-2020-ESYRS/', 
                                      Proof_Generation__c=ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Drop_Type__c = 'Pre Planned'));
        
        util.bypassAllTriggers = false; 
        insert artifacts;
        
        test.startTest();
        
        List<Artifact_Transfer__c> aTxs = [SELECT Id, Status__c, Target_File_Name__c, Artifact__r.Type__c FROM Artifact_Transfer__c
                                           WHERE Artifact__c IN :artifacts AND Artifact__r.Job_Ticket__c = :pTracking.Job_Ticket__c AND Direction__c = 'Push' AND Artifact__r.Type__c = 'Artwork'];
        system.assertNotEquals(null, aTxs);
        for (Artifact_Transfer__c aTx : aTxs) {
            aTx.Status__c = 'Success';
            aTx.Target_File_Name__c = testArtFileName;
        }
        //once the artifact Transfer status changes to Success and the related Artifact's Proof Generation = Internal, it should send callout to AWS for proof submission
        util.bypassAllTriggers = false;
        update aTxs;
        aTxs = [SELECT Id, Status__c, Target_File_Name__c, Artifact__r.Type__c FROM Artifact_Transfer__c
                WHERE Artifact__c IN :artifacts AND Artifact__r.Job_Ticket__c = :pTracking.Job_Ticket__c AND Direction__c = 'Push' AND Artifact__r.Type__c = 'Artwork'];
        
        pTracking.Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        pTracking.Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED;
        update pTracking;
        
        test.stopTest();
        
        //verify the callout was sent
        List<Web_Service_Log__c> wsLogs = [SELECT Id, Web_Service_Method__c, URL__c, Requested_By__c
                                           FROM Web_Service_Log__c 
                                           WHERE Production_Tracking__c = :pTracking.Id 
                                           AND Web_Service_Method__c = :ProductionTrackingTriggerHelper.COMMAND_PROOF_APPROVED];
    }
    //Added - Abhinav Sharma - 02/12/2021
    @IsTest static void testUpdateJobTicket(){
        //get all Production Trackings
        List<Production_Tracking__c> prodTrackings = [SELECT Id, JT_Project_Manager__c, Status__c,Job_Ticket__c,Job_Ticket__r.Status__c,Actual_Mail_Date__c FROM Production_Tracking__c];
        
        Test.startTest();
        //set Drop and Mail Date
        prodTrackings[0].Drop__c = 1;
        prodTrackings[0].Actual_Mail_Date__c = System.Today();
        update prodTrackings[0];
        Test.stopTest();
        //check if ticket is updated
        Integer countTicket = [SELECT COUNT() FROM Job_Ticket__c WHERE Drop_1_Actual_Mail_Date__c != null];
        System.assertEquals(true, countTicket>0 ,'Ticket is updated');
        
    }
    
    @IsTest static void testPopulate_SLATrackingDateTimeFieldOnPTracking(){
        //get all Production Trackings
        List<Production_Tracking__c> prodTrackings = [SELECT Id, JT_Project_Manager__c,Status_Detail__c, Status__c,Job_Ticket__c,Actual_Mail_Date__c FROM Production_Tracking__c];
        
        Test.startTest();
        
        prodTrackings[0].status__c = 'Proof';
        prodTrackings[0].Status_Detail__c = 'File Received';
        update prodTrackings[0];
        
        prodTrackings[0].Status_Detail__c = 'Pending Approval';
        update prodTrackings[0];
        try{
            prodTrackings[0].Status_Detail__c = 'Approved';
            update prodTrackings[0];    
        }
        catch(Exception e){
            System.debug('Exception '+e);
        }
        
        prodTrackings[0].status__c = 'Live Proof';
        prodTrackings[0].Status_Detail__c = 'File Received';
        update prodTrackings[0];
        
        prodTrackings[0].Status_Detail__c = 'Pending Approval';
        update prodTrackings[0];
        
        try{
            prodTrackings[0].Status_Detail__c = 'Live Proof Approved';
            update prodTrackings[0];    
        }
        catch(Exception e){
            System.debug('Exception '+e);
        }
        
        
        
        Test.stopTest();
        
        Integer countProdTrackings = [SELECT COUNT() FROM Production_Tracking__c WHERE Live_Proof_Pending_Approval_DateTime__c != null];
        
        System.assertEquals(true, countProdTrackings>0, 'Production_Tracking__c updated');
        
    }
    //Added - Abhinav Sharma - 02/12/2021
    @IsTest static void testAllWrappers(){
        ProductionTrackingTriggerHelper.Result resultWrapper= new ProductionTrackingTriggerHelper.Result();
        ProductionTrackingTriggerHelper.authTokenWrapper authWrapper = new ProductionTrackingTriggerHelper.authTokenWrapper();
        ProductionTrackingTriggerHelper.Error errorWrapper = new ProductionTrackingTriggerHelper.Error(); 
        
        resultWrapper.accessToken = '';
        resultWrapper.encryptedAccessToken = '';
        resultWrapper.expireInSeconds = 0;
        resultWrapper.shouldResetPassword = false;
        resultWrapper.userId = 0;
        resultWrapper.requiresTwoFactorVerification = false;
        resultWrapper.refreshToken = '';
        resultWrapper.refreshTokenExpireInSeconds = 0;
        
        errorWrapper.code = 400;
        errorWrapper.message = 'Server Error';
        errorWrapper.details = '';
        
        authWrapper.result = resultWrapper;
        authWrapper.targetUrl= '';
        authWrapper.success= true;
        authWrapper.error = errorWrapper;
        authWrapper.unAuthorizedRequest = false;
        
        System.assertEquals(true, authWrapper.success, 'Success');
        
    }
    
    // CR-20210322-15011 - 04/1/2020 - Neha Sharma
    @IsTest static void testUpdateFieldOnPTracking(){
        //get all Production Trackings
        String artFileName = 'Test1.zip';
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c FROM Job_Ticket__c];
        //get the vendor institution
        List<Account> vendorAccts = [SELECT Id FROM Account WHERE Vendor_Sub_Type__c = :Constants.VENDOR_TYPE_DIGITAL];
        
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Drop__c = 1,Job_Ticket__c = jobTickets[0].Id,
                                                           Mail_Shop_Vendor__c=vendorAccts[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                           Proof_Generation__c = 'Internal'));
        productionTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Drop__c = 2,Job_Ticket__c = jobTickets[0].Id,
                                                           Mail_Shop_Vendor__c=vendorAccts[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                           Proof_Generation__c = 'Internal'));
        insert productionTrackings;
        
        productionTrackings[0].status__c = 'Proof';
        productionTrackings[0].Status_Detail__c = 'Error';
        productionTrackings[0].Error_Details__c = 'Test';
        update productionTrackings[0];
        
        productionTrackings[0].Status_Detail__c = 'File Received';
        update productionTrackings[0];
        
        Test.startTest();
        
        Production_Tracking__c prodTrackings = [SELECT Id, Error_Details__c FROM Production_Tracking__c where Proof_generation__c = 'Internal' and
                                                status__c = 'Proof'];
        
        system.assertEquals(null, prodTrackings.Error_Details__c);
        
        Test.stopTest();
    }
    
    // CR-20210325-15027 - Created By Mahendra Swarnkar
    @isTest static void test_updateCreativePackageApprovalStatus(){
        
        //query Job ticket
        List<Job_Ticket__c> jobTickets = [Select Id, Drop_Type__c From Job_Ticket__c LIMIT 1];
        
        //updating job ticket
        jobTickets[0].Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND;
        
        update jobTickets;
        
        //inserting creative package Data
        List<Creative_Package__c> creativePackages = new List<Creative_Package__c>();
        
        creativePackages.add(new Creative_Package__c(Name = 'Test Creative1', Approval_Status__c = 'Draft', Art_File_Name__c = testArtFileName ));
        creativePackages.add(new Creative_Package__c(Name = 'Test Creative2', Approval_Status__c = 'Submitted' , Art_File_Name__c= testArtFileName));
        creativePackages.add(new Creative_Package__c(Name = 'Test Creative3', Approval_Status__c = 'Submitted', Art_File_Name__c = testArtFileName ));
        
        insert creativePackages;
        
        //Querying for Production Tracking records
        List<Production_Tracking__c> productionTracks = [Select Id, Creative_Package__c, Status__c, Status_Detail__c, Job_Ticket__c, Job_Ticket__r.Drop_Type__c  
                                                         From Production_Tracking__c ];
        
        //manually create the artifact for artwork proof, because this is normally created via callout
        List<Artifact__c> artworkProofs = new List<Artifact__c>();
        artworkProofs.add(new Artifact__c(Job_Ticket__c = jobTickets[0].Id, Production_Tracking__c = productionTracks[0].Id,
                                          Type__c = 'Artwork', Status__c = 'Success'));
        artworkProofs.add(new Artifact__c(Job_Ticket__c = jobTickets[0].Id, Production_Tracking__c = productionTracks[1].Id,
                                          Type__c = 'Artwork', Status__c = 'Success'));
        artworkProofs.add(new Artifact__c(Job_Ticket__c = jobTickets[0].Id, Production_Tracking__c = productionTracks[2].Id,
                                          Type__c = 'Artwork', Status__c = 'Success'));
        insert artworkProofs;
        
        //creating Arti fact transfer records
        List<Artifact_Transfer__c> atsToInsert = new List<Artifact_Transfer__c>();
        atsToInsert.add(new Artifact_Transfer__c(Artifact__c = artworkProofs[0].Id, Direction__c = 'Push', Status__c = 'Success', Target_File_Name__c = testArtFileName));
        atsToInsert.add(new Artifact_Transfer__c(Artifact__c = artworkProofs[1].Id, Direction__c = 'Push', Status__c = 'Success', Target_File_Name__c = testArtFileName));
        atsToInsert.add(new Artifact_Transfer__c(Artifact__c = artworkProofs[2].Id, Direction__c = 'Push', Status__c = 'Success', Target_File_Name__c = testArtFileName));
        
        insert atsToInsert;
        
        //start of test
        Test.startTest();
        
        //updating the production tracking records
        productionTracks[0].Creative_Package__c = creativePackages[0].Id;
        productionTracks[1].Creative_Package__c = creativePackages[1].Id;
        productionTracks[2].Creative_Package__c = creativePackages[2].Id;
        productionTracks[0].Proof_Approval_Status__c = 'Approved';
        productionTracks[1].Proof_Approval_Status__c = 'Approved'; 
        productionTracks[0].Live_Proof_Approval_Status__c = 'Approved';
        productionTracks[1].Live_Proof_Approval_Status__c = 'Approved';
        productionTracks[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTracks[2].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTracks[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED;
        productionTracks[2].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED;
        
        update productionTracks;
        
        //query for creative Packages
        List<Creative_Package__c> updatedPackages = [Select Id, Approval_Status__c From Creative_Package__c];
        //asserting
        System.assertEquals('Approved', updatedPackages[0].Approval_Status__c);
        System.assertEquals('Submitted', updatedPackages[1].Approval_Status__c);
        System.assertEquals('Approved', updatedPackages[2].Approval_Status__c);
        
        //stop of test
        Test.stopTest();
    }
    
    // Added Method to cover CR-20200717-14331 - Milestone tracking for PrintMIS
    @isTest static void testPopulate_DueDateFieldOnPTracking(){
        
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, Account_Formal_Name__c = 'Test Account',
                                   Name = 'Test Account 2', r_School_Code__c='abc13', r_CEEB_Code__c='abce');
        insert inst;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        proj.Fiscal_Year__c = '2020';
        
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user = testUtilities.CreateNewUser(sysAdminProfile, false);
        user.LastName = 'sysAdminUser';
        insert user;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = proj.Id, Status__c = Constants.JOB_TICKET_STATUS_APPROVED_BY_CLIENT, Project_Manager__c = user.Id, 
                                         Drop_Type__c = 'Pre Planned', of_Drops__c = 2, Descriptive_Name__c = 'Test', Art_Director__c = user.Id,
                                         Mail_Quantity__c = 100, Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', 
                                         Fiscal_Year__c='2020', Vendor_Type__c = 'Digital', Mail_Date__c = System.today(), 
                                         Production_Manager__c = user.Id, of_Letter_Versions__c = 2, Insertion_Order__c = 'ADM - Letter driver',
                                         Job_Code__c = 'ABC'));
        insert jobTickets;
        
        Util.BypassAllTriggers = false;
        //Creating Production Tracking record 
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c( Status__c = 'Proof', Status_Detail__c = 'File Issue', Art_Due_to_Vendor_Date__c = System.today(),
                                                  Planned_Mail_Date__c = System.today()+1 ,
                                                  Proof_Approval_Date__c = system.today() +1, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Art_File_Name__c = 'artFile1.zip'));
        
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = 'Live Proof', Status_Detail__c = 'File Issue',
                                                  RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Planned_Mail_Date__c = System.today()+1 ,
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Data_Due_to_Vendor_Date__c = System.today(), Live_Proof_Approval_Due_Date__c = System.today()+1 , Internal_Data_Drop__c = 1, Art_File_Name__c = 'artFile1.zip'));
        
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Status_Detail__c = 'File Issue',
                                                  RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Planned_Mail_Date__c = System.today()+1 ,
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'artFile1.zip'));
        
        
        Test.startTest();
        insert pTrackings;
        
        List<Production_Tracking__c> pTracks = [Select Id, Art_Due_to_Vendor_Date__c, Data_Due_to_Vendor_Date__c, Live_Proof_Approval_Due_Date__c, Proof_Approval_Date__c From Production_Tracking__c Where  Id IN: pTrackings];
        System.assertEquals(null, pTracks[0].Art_Due_to_Vendor_Date__c);
        System.assertEquals(null, pTracks[0].Proof_Approval_Date__c);
        
        System.assertEquals(null, pTracks[1].Data_Due_to_Vendor_Date__c);
        System.assertEquals(null, pTracks[1].Live_Proof_Approval_Due_Date__c);
        
        pTracks[1].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED;
        
        update pTracks;
        Test.stopTest();
    } 
    
    //05/13/2021 - CR-20210310-14983 - Abhinav Sharma - Added
    static testMethod void test_InventoryTransferRequest()
    {
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc13', r_CEEB_Code__c='AE');
        insert inst;
        
        //Create Account
        Account inst1 = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Status__c = 'Active',
                                    Name = 'Test Account 2', r_School_Code__c='abc14', r_CEEB_Code__c='AB');
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
        
        Util.BypassAllTriggers = false;
        
        Test.startTest(); 
        try{
            List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
            Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Original_Vendor__c = inst1.Id, Target_Vendor__c = inst1.Id,
                                                                           Production_Tracking__c = pTrackings[0].Id, Effective_Quantity__c = 10000, 
                                                                           Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                           Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
            inventoryTransactions.add(invTxn);
            insert inventoryTransactions;
        }
        Catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('No API Endpoint where Related Record Id') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);   
            
            //check web service logs
            Web_Service_Log__c webServiceLog = [Select Id,Web_Service_Method__c,Inventory_Transaction__c From Web_Service_Log__c];
            
            //asserts on result
            System.assertNotEquals(null, webServiceLog);
            System.assertEquals('inventoryTransferRequest', webServiceLog.Web_Service_Method__c);
        }
        
        Test.stopTest();
    }
    
    //Added By Mahendra Swarnkar - 04/27/2021 - CR-20210325-15027 
    static testMethod void test_getJobTicketJSONWithCreativePackage() {
        
        DateTime currentDateTime = System.now();
        
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
        
        //Insert Project record
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Project_ID__c = 'test2', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test2', Art_Director__c = user1.Id, Mail_Quantity__c = 101, Change_Reason__c = 'Testing before update2', Creative_Package_Box_Folder_Id__c = '12343', Creative_Package_BOX_Folder_Link__c = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8'));
        insert jobTickets;
        
        List<Job_Ticket_Component__c> jtComponents = new List<Job_Ticket_Component__c>();
        jtComponents.add(new Job_Ticket_Component__c(Component__c = 'Folder'));
        insert jtComponents;
        
        Job_Ticket_MtM__c jobTktMTM = new Job_Ticket_MtM__c(Job_Ticket__c = jobTickets[0].Id, Job_Ticket_Component__c = jtComponents[0].Id, Laser__c = 'Simplex',
                                                            Component_Type__c = 'Folder', Paper_Typex__c = 'Lynx Opaque Smooth Text', Paper_Weightx__c = '70#',
                                                            Component_Code__c = 'testCode', Front_Colors_PMS__c = '2', Apply_Fugitive_Glue_to_Seal_Flap__c = false);
        insert jobTktMTM;
        
        //Insert the Creative Package records
        List<Creative_Package__c> creativePackages = new List<Creative_Package__c>();
        creativePackages.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id, Box_Folder_Link__c  = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8', Box_Folder_Id__c = '12343', Art_File_Name__c = 'ABC.zip'));
        insert creativePackages;
        
        Mail_Copy__c mailCopy = new Mail_Copy__c(Creative_Package__c = creativePackages[0].Id );
        insert mailCopy;
        
        Mail_Package__c mailPackage = new Mail_Package__c(Creative_Package__c = creativePackages[0].Id, Mail_Copy__c = mailCopy.Id);
        insert mailPackage;
        
        Package_Component_MtM__c packageComponentMtM = new Package_Component_MtM__c(Mail_Package__c = mailPackage.Id, Job_Ticket__c = jobTickets[0].Id ,Job_Ticket_MtM__c = jobTktMTM.Id);
        insert packageComponentMtM;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Creative_Package__c = creativePackages[0].Id, Drop__c = 1, Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 2, Art_File_Name__c = 'artFile1.zip'));
        pTrackings.add(new Production_Tracking__c(Creative_Package__c = creativePackages[0].Id, Drop__c = 2, Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, Internal_Data_Drop__c = 3, Art_File_Name__c = 'artFile2.zip'));
        insert pTrackings;
        
        List<Recipient_Batch__c> listRecipient = new List<Recipient_Batch__c>();
        listRecipient.add(new Recipient_Batch__c(Production_Tracking__c = pTrackings[0].Id, Type__c = 'ArtProof', Recipient_Batch_Id__c = 'RB001', Data_Posted_Quantity__c = 2, Data_Posted_Date_Time__c = currentDateTime.addDays(1)));
        listRecipient.add(new Recipient_Batch__c(Production_Tracking__c = pTrackings[0].Id, Type__c = 'ArtProof', Recipient_Batch_Id__c = 'RB002', Data_Posted_Quantity__c = 3, Data_Posted_Date_Time__c = currentDateTime.addDays(2)));
        listRecipient.add(new Recipient_Batch__c(Production_Tracking__c = pTrackings[0].Id, Type__c = 'LiveData', Recipient_Batch_Id__c = 'RB003', Data_Posted_Quantity__c = 2, Data_Posted_Date_Time__c = currentDateTime.addDays(3)));
        listRecipient.add(new Recipient_Batch__c(Production_Tracking__c = pTrackings[0].Id, Type__c = 'LiveData', Recipient_Batch_Id__c = 'RB004', Data_Posted_Quantity__c = 3, Data_Posted_Date_Time__c = currentDateTime.addDays(4)));
        
        insert listRecipient;
        
        jobTickets = ProductionTrackingTriggerHelper.getJobTicketDetails(pTrackings[0]);
        
        //get the json body
        Map<String, Object> deserializedJT = ProductionTrackingTriggerHelper.getJobTicketJSON(jobTickets[0], pTrackings[0]);
        
        Util.BypassAllTriggers = false;
        
        //Test start here 
        Test.startTest();
        
        Map<String, Object> deserializedJTWithCreativePackage = ProductionTrackingTriggerHelper.getJobTicketJSONWithCreativePackage(jobTickets[0], pTrackings[0], deserializedJT, ProductionTrackingTriggerHelper.COMMAND_PROOF_SUBMITTED);
        deserializedJTWithCreativePackage = ProductionTrackingTriggerHelper.getJobTicketJSONWithCreativePackage(jobTickets[0], pTrackings[0], deserializedJT, ProductionTrackingTriggerHelper.COMMAND_LIVE_PROOF_SUBMITTED);
        
        Test.stopTest();
    }
    
    static testMethod void test_updatePTArtFileNameOnStatusChange() {
        
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
        
        //Insert Project record
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id);
        insert project;
        
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = System.Label.DROP_TYPE_ON_DEMAND,ES_Campaign__c = escCampaigns[1].Id, Project__c = project.Id, Project_ID__c = 'test2', Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test2', Art_Director__c = user1.Id, Mail_Quantity__c = 101, Change_Reason__c = 'Testing before update2', Creative_Package_Box_Folder_Id__c = '12343', Creative_Package_BOX_Folder_Link__c = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8'));
        insert jobTickets;
        
        List<Job_Ticket_Component__c> jtComponents = new List<Job_Ticket_Component__c>();
        jtComponents.add(new Job_Ticket_Component__c(Component__c = 'Folder'));
        insert jtComponents;
        
        //Insert the Creative Package records
        List<Creative_Package__c> creativePackages = new List<Creative_Package__c>();
        creativePackages.add(new Creative_Package__c(Job_Ticket__c = jobTickets[0].Id, Box_Folder_Link__c  = 'https://eab.box.com/s/k93p1sqaz2f02tb9au9vnr3zl3hxjh8', Box_Folder_Id__c = '12343', Art_File_Name__c = 'ABC.zip'));
        insert creativePackages;
        
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Drop_Type__c =Constants.PRODUCTION_TRACKING_DROP_TYPE, Creative_Package__c = creativePackages[0].Id, Drop__c = 1, Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, Internal_Data_Drop__c = 2, Art_File_Name__c = 'artFile1.zip'));
        pTrackings.add(new Production_Tracking__c(Drop_Type__c =Constants.PRODUCTION_TRACKING_DROP_TYPE, Creative_Package__c = creativePackages[0].Id, Drop__c = 2, Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED, Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, Internal_Data_Drop__c = 3, Art_File_Name__c = 'artFile2.zip'));
        
        //Test start here 
        Test.startTest();
        
        Util.BypassAllTriggers = false;
        insert pTrackings;
        
        pTrackings[1].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        pTrackings[1].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        Util.BypassAllTriggers = false;
        update pTrackings;
        
        List<Production_Tracking__c> pTrackings1 = [Select ID, Art_File_Name__c, Drop__c, Status__c, Status_Detail__c From Production_Tracking__c Where ID IN : pTrackings ORDER BY Drop__c ASC];
        System.assertEquals( 2, pTrackings1.size());
        
        System.assertEquals( 1, pTrackings1[0].Drop__c);
        System.assertEquals( 'artFile1.zip', pTrackings1[0].Art_File_Name__c);
        
        System.assertEquals( 'ABC.zip', pTrackings1[1].Art_File_Name__c);
        System.assertEquals( 2, pTrackings1[1].Drop__c);
        
        //Update the Creative Package Status to Approved
        pTrackings1[1].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_APPROVED;
        update pTrackings1;
        
        Test.stopTest();
    }
    
    //Added By - Nikita Kumari - CR-20210916-15441 - 10/01/2021
    @IsTest static void testPopulatePostageClassOnPT(){
        
        // Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Sepire',r_School_Code__c = '1234');
        insert inst; 
        
        // get job tickets from setup method 
        Job_Ticket__c jobTicket = [SELECT Id, Mail_Vendor__c, Postage_Class__c ,Project_Manager__c, Status__c FROM Job_Ticket__c LIMIT 1];
        
        //update postage class on job ticket 
        jobTicket.Postage_Class__c = 'Non-Profit (200 Piece Minimum)';
        
        Util.BypassAllTriggers = true;
        update jobTicket;
        Util.BypassAllTriggers = false;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTicket.Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 1));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTicket.Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 2));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTicket.Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 3));
        
        Test.startTest();
        insert pTrackings;
        
        // Query production trackings 
        pTrackings = [SELECT Id, Postage_Class__c FROM Production_Tracking__c WHERE Id IN :pTrackings];
        
        //Assert to check postage class field value 
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[0].Postage_Class__c);
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[1].Postage_Class__c);
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[2].Postage_Class__c);
        
        //update postage class value to null in production tracking records 
        for(Production_Tracking__c ptracking : pTrackings)
        {
            ptracking.Postage_Class__c = null; 
        }
        update pTrackings;
        
        // Query updated production trackings 
        pTrackings = [SELECT Id, Postage_Class__c FROM Production_Tracking__c WHERE Id IN :pTrackings];
        
        //Assert to check postage class field value 
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[0].Postage_Class__c);
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[1].Postage_Class__c);
        System.assertEquals('Non-Profit (200 Piece Minimum)', pTrackings[2].Postage_Class__c);
        
        Test.stopTest();          
    }
     //Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021
     @IsTest static void test_populateMailshopPTStatusOnInventoryTransaction()
     {
         Util.BypassAllTriggers = true;
         
         //Create Account
         Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                    Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                    Name = 'Test1', r_School_Code__c='abc13', r_CEEB_Code__c='AE');
         insert inst;
         
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
         jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
         insert jobTctComponet;
         
         Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
         jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
         jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
         jobTickectMTMs.Component_Code__c = 'AE0012';
         insert jobTickectMTMs;
         
         List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
         pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                   Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, RecordTypeId = JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP, 
                                                   Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                   Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
         insert pTrackings;
         
         Inventory__c inventory = new Inventory__c(Institution__c = inst.Id ,Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                   Inventory_Control_Number__c = 'AE0012', Production_Tracking__c = pTrackings[0].Id);
         insert inventory;
 
         List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
         Inventory_Transaction__c invTxn = new Inventory_Transaction__c(Inventory__c = inventory.Id, Production_Tracking__c = pTrackings[0].Id, 
                                                                         Effective_Quantity__c = 10000,Mailshop_Production_Tracking__c = pTrackings[0].Id,
                                                                        Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                                        Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998');
 
         Inventory_Transaction__c invTxn1 = new Inventory_Transaction__c(Inventory__c = inventory.Id, Production_Tracking__c = pTrackings[0].Id, 
                                                                         Effective_Quantity__c = 10000,Quantity__c = 5000, Ship_Date__c = System.today(),
                                                                         Arrival_Date_Anticipated__c = System.today(),Shipping_Method__c = 'UPS',
                                                                          Tracking_Number__c = '1Z8999999999999998');
         inventoryTransactions.add(invTxn);
         inventoryTransactions.add(invTxn1);
         insert inventoryTransactions;
       
         Util.BypassAllTriggers = false;
 
         Test.startTest();
 
         pTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
         update pTrackings;
 
         inventoryTransactions = [Select Id, Mailshop_PT_Status__c, Mailshop_Production_Tracking__c From Inventory_Transaction__c];
         //Check assert on the results
         System.assertEquals(Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF,inventoryTransactions[0].Mailshop_PT_Status__c);
         System.assertEquals(pTrackings[0].Id,inventoryTransactions[0].Mailshop_Production_Tracking__c);
         System.assert(String.isBlank(inventoryTransactions[1].Mailshop_PT_Status__c));
 
         Test.stopTest();
     }
     
     //Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021
     @IsTest static void test_createInventoryAndTransForPrintPT()
     {   
         Util.BypassAllTriggers = true;
         //Create Account
         Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                    Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                    Name = 'Test1', r_School_Code__c='abc13', r_CEEB_Code__c='AE', Status__c = 'Active');
         insert inst;
         
         //Create Project
         Project__c proj = TestUtilities.createProject(false);
         proj.Institution__c = inst.Id;
         insert proj;
 
         Project__c proj1 = TestUtilities.createProject(false);
         proj.Institution__c = null;
         insert proj1;
         
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
         jobTickets.add(new Job_Ticket__c(Name = 'GW-5242-2021-ESNN-2', Project__c = proj1.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, 
                                          Descriptive_Name__c = 'Test Desciptive', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                          Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020', Drop_Type__c = 'Pre Planned'));
         insert jobTickets;
         
         Job_Ticket_Component__c jobTctComponet = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
         jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
         insert jobTctComponet;
 
         Job_Ticket_Component__c jobTctComponet1 = PrintManagementTestDataFactory.CreateNewJobTicketComponent(false);
         jobTctComponet1.Component__c = Constants.COMPONENT_TYPE_ENVELOPE;
         insert jobTctComponet1;
         
         List<Job_Ticket_MtM__c> jobTickectMTMs = new List<Job_Ticket_MtM__c>();
         Job_Ticket_MtM__c JTMTM = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
         JTMTM.Job_Ticket_Component__c = jobTctComponet.Id;
         JTMTM.Job_Ticket__c = jobTickets[0].Id;
         JTMTM.Component_Code__c = 'AE0012';
         jobTickectMTMs.add(JTMTM);
 
         Job_Ticket_MtM__c JTMTM1 = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
         JTMTM1.Job_Ticket_Component__c = jobTctComponet1.Id;
         JTMTM1.Job_Ticket__c = jobTickets[1].Id;
         JTMTM1.Component_Code__c = 'AE0012';
         jobTickectMTMs.add(JTMTM1);
         insert jobTickectMTMs;
         
         Id RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT = Schema.SObjectType.Production_Tracking__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
 
         List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
         pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                   Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs[0].Id, 
                                                   RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                   Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                   Component__c = Constants.COMPONENT_TYPE_BRE,  Print_Quantity_Planned__c = 500,
                                                   Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
         pTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                   Job_Ticket__c = jobTickets[1].Id, Job_Ticket_MtM__c = jobTickectMTMs[1].Id, 
                                                   RecordTypeId = RECORD_TYPE_ID_PRODUCTION_TRACKING_PRINT, 
                                                   Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, 
                                                   Component__c = Constants.COMPONENT_TYPE_ENVELOPE, Print_Quantity_Planned__c = 500,
                                                   Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip'));
         insert pTrackings;
         Util.BypassAllTriggers = false;
 
         Test.startTest();
         
         pTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
         pTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
         update pTrackings[0];
         
         System.assertEquals(Constants.COMPONENT_TYPE_BRE, pTrackings[0].Component__c);
 
         List<Inventory__c> inventory = [Select Id From Inventory__c];
         System.assertEquals(1, inventory.size());
         
         Test.stopTest();
     }
	 
	//Added By - Shalu Sharma - CR-20210924-15459 - 10/05/2021
    @IsTest static void test_checkInventroyAssociatedWithPT()
    {
        Util.BypassAllTriggers = true;
        
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, 
                                   Name = 'Test1', r_School_Code__c='abc13', r_CEEB_Code__c='AE', Status__c = 'Active');
        insert inst;
        
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
        jobTctComponet.Component__c = Constants.COMPONENT_TYPE_BRE;
        insert jobTctComponet;
        
        Job_Ticket_MtM__c jobTickectMTMs = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTickectMTMs.Job_Ticket_Component__c = jobTctComponet.Id;
        jobTickectMTMs.Job_Ticket__c = jobTickets[0].Id;
        jobTickectMTMs.Component_Code__c = 'AE0012';
        insert jobTickectMTMs;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                  RecordTypeId = JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip',
                                                  Data_Posted_Quantity__c = 100));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,
                                                  Job_Ticket__c = jobTickets[0].Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                                  RecordTypeId = JobTicketTriggerHelper.PRODUCTION_TRACKING_RT_ID_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'Art.zip',
                                                  Data_Posted_Quantity__c = 50));
        insert pTrackings;
        
        List<Inventory__c> inventorys = new List<Inventory__c>();
        inventorys.add(new Inventory__c(Institution__c = inst.Id, Job_Ticket_MtM__c = jobTickectMTMs.Id, 
                                        Inventory_Control_Number__c = 'AE0012', Assigned_Vendor__c = inst.Id,
                                        Production_Tracking__c = pTrackings[1].Id));
        insert inventorys;
        
        List<Inventory_Transaction__c> inventoryTransactions = new List<Inventory_Transaction__c>();
        inventoryTransactions.add(new Inventory_Transaction__c(Inventory__c = inventorys[0].Id, Production_Tracking__c = pTrackings[1].Id, 
                                                               Effective_Quantity__c = 10000, Mailshop_Production_Tracking__c = pTrackings[1].Id,
                                                               Quantity__c = 5000, Ship_Date__c = System.today(), Arrival_Date_Anticipated__c = System.today(),
                                                               Shipping_Method__c = 'UPS', Tracking_Number__c = '1Z8999999999999998',
                                                               Quantity_to_Allocate__c = 60));
        insert inventoryTransactions;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();  
        
        pTrackings[0].Data_Posted_Quantity__c = 200;
        update pTrackings[0];
        
        pTrackings[1].Data_Posted_Quantity__c = 70;
        update pTrackings[1];
        
        
        Test.stopTest();
    }
    
    public static testMethod void unLockProductionTrackingRecordOnBackTrackingTest(){
        Util.BypassAllTriggers = true;
        //Create Account
        Account inst = new Account(RecordTypeId = Constants.RECORD_TYPE_ID_ACCOUNT_VENDOR, Vendor_Type__c = 'Vendor', 
                                   Vendor_Sub_Type__c = Constants.VENDOR_TYPE_DIGITAL, Account_Formal_Name__c = 'Test Account 2',
                                   Name = 'Test Account 2', r_School_Code__c='abc13', r_CEEB_Code__c='abce');
        insert inst;
        
        //Create Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = inst.Id;
        proj.Fiscal_Year__c = '2020';
        insert proj;
        
        //Create a user for running the process
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user = testUtilities.CreateNewUser(sysAdminProfile, false);
        user.LastName = 'sysAdminUser';
        insert user;
        
        Program__c prog = TestUtilities.CreateNewProgram(true);
        
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Descriptive_Name__c = 'Test', Project__c = proj.Id,
                                         Art_Director__c = user.Id, Mail_Quantity__c = 100,
                                         Vendor_Type__c='Digital', Mail_Date__c = System.today(),
                                         Project_Manager__c = user.Id, Production_Manager__c = user.Id,
                                         of_Drops__c = 2, of_Letter_Versions__c = 2,
                                         Fiscal_Year__c='2020', Insertion_Order__c = 'ADM - Letter driver',
                                         Status__c = Constants.JOB_TICKET_STATUS_APPROVED_BY_CLIENT,
                                         Drop_Type__c = 'Pre Planned', 
                                         Change_Reason__c = 'Testing before update', 
                                         Project_ID__c = 'Test', Job_Code__c = '123', Locked__c =  True, Program__c = prog.Id));

        insert jobTickets;
        Util.BypassAllTriggers = false;
        
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = Constants.PRODUCTION_TRACKING_STATUS_MAILED,
                                                  Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, 
                                                  Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ 
                                                  Internal_Data_Drop__c = 1, Art_File_Name__c = 'artFile1.zip'));
        
        insert pTrackings;
        
        Test.startTest();
        List<Production_Tracking__c> updatePT = [Select Id, Internal_Data_Drop__c,Status__c From Production_Tracking__c Where Id =:pTrackings[0].Id];
        updatePT[0].Mail_Shop_Vendor__c = inst.Id;
        updatePT[0].BOX_Folder_Link__c = 'http://www.test.com';
        updatePT[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        update updatePT;
        
        List<Job_Ticket__c> updatedJobs = [Select Id, Status__c From Job_Ticket__c Where Id =: jobTickets[0].Id];
        System.assertEquals(Constants.JOB_TICKET_STATUS_IN_PROGRESS, updatedJobs[0].Status__c);
        
        Test.stopTest();
    }
    
    //Added By - Shalu Sharma - 4/29/2022 - CR-20220428-16145
    @IsTest static void test_getAuthTokenForColorArtVendor()    
    {
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        List<API_Endpoints__mdt> apiEndpoints = [SELECT Id, Endpoint_URL__c, Related_Record_Id__c, Authorization_Token__c,
                                                 Certificate_API_Name__c, Authorize_Endpoint_URL__c, Authorization_Body__c, Custom_Headers__c
                                                 FROM API_Endpoints__mdt
                                                 WHERE Related_Record_Id__c != null 
                                                 AND Authorize_Endpoint_URL__c != null];
        System.assert(apiEndpoints.size() > 0);
        Test.startTest();
        String authToken = ProductionTrackingTriggerHelper.getAuthTokenForColorArtVendor(apiEndpoints[0]);
        Test.stopTest();
        System.assertEquals(null, authToken, 'should return null when executing within unit test');
    }
}