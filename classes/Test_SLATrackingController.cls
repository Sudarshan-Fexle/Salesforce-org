/**
 * Purpose          :   Test class for SLATrackingController
 * 
 * CreatedDate      :   7/31/2020
 * 
 * RevisionLog      :   V_1.0 - Created - Abhinav Sharma - CR-20200717-14438 - 09/07/2020
 *                      V_1.1 - Modified by - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
 * Code Coverage    :   
 *
**/
@IsTest(seeAllData=false)
private class Test_SLATrackingController {
 
	public static final String STATUS_DETAIL_SUBMITTED = 'Submitted';
    public static final String STATUS_DETAIL_APPROVED = 'Approved';
    private static final String testArtFileName = 'artFile1.zip';
    
    @testSetup static void testSetupData()
    {
        
        //get name of one of the vendors specified in Vendor 
        List<Artifact_Transfer_Setting__mdt> ats = [SELECT Id, Mail_Shop_Vendor__c FROM Artifact_Transfer_Setting__mdt
                                                    WHERE Mail_Shop_Vendor__c != null];
        
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
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = user1.Id, Descriptive_Name__c = 'Test', Art_Director__c = user1.Id, Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020'));
        insert jobTickets;

        //12/09/2020 - CR-20201012-14597 - Victor Hanson - added so we don't have to re-create pTracking records in each unit test
        // Insert Internal & External production_Tracking__c
        List<Production_Tracking__c> pTrackings = new List<Production_Tracking__c>();
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 1, Art_File_Name__c = testArtFileName));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 2, Art_File_Name__c = testArtFileName));
        pTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  inst.Id, Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_INTERNAL, /*Bypass_Color_Calibration__c = true,*/ Internal_Data_Drop__c = 3, Art_File_Name__c = testArtFileName));
        insert pTrackings;
        
    }
    
     @IsTest static void testcreateArtifactForProductionTracking()
    {

        String artFileName = 'artFile.zip';
        String mailingListName = 'mailingListFile.zip';
    	// Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        //get the vendor institution
        List<Account> vendorAccts = [SELECT Id FROM Account WHERE Vendor_Sub_Type__c = :Constants.VENDOR_TYPE_DIGITAL];
        system.assertNotEquals(0, vendorAccts.size(), 'At least one vendor Institution should have been returned because it was created in testSetup');
        
        List<Job_Ticket__c> jobTickets = [SELECT Id, Project_Manager__c, Status__c FROM Job_Ticket__c];
        
	    //Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        /*List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id,Art_File_Name__c = 'Test.zip', Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL,
                                                           Mail_Shop_Vendor__c=vendorAccts[0].Id, Drop__c = 1, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Bypass_Color_Calibration__c = true, Internal_Data_Drop__c = 1));
        
        Production_Tracking__c drop2 = new Production_Tracking__c(Status__c = Constants.PRODUCTION_TRACKING_STATUS_PLANNED,Job_Ticket__c = jobTickets[0].Id,Art_File_Name__c = 'Test.zip', Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL,
                                                                  Mail_Shop_Vendor__c=vendorAccts[0].Id, Drop__c = 2, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP, Bypass_Color_Calibration__c = true, Internal_Data_Drop__c = 1);
        productionTrackings.add(drop2);
        insert productionTrackings;*/
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Status__c, Status_Detail__c, Art_File_Name__c, BOX_Folder_Link__c,
                                                            Proof_Approval_Status__c, Live_Proof_Approval_Status__c, Internal_Data_Drop__c
                                                            FROM Production_Tracking__c
                                                            WHERE Job_Ticket__c IN :jobTickets AND Proof_Generation__c = :ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL
                                                            ORDER BY Internal_Data_Drop__c ASC];
        
        //clear out any existing artifacts
        delete [SELECT Id, Type__c, (SELECT Id FROM Artifact_Transfers__r) FROM Artifact__c WHERE Job_Ticket__c = :jobTickets[0].Id];
        
        //create the 'proof' artifact
        productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_PROOF;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;
        productionTrackings[0].Art_File_Name__c = artFileName;
        productionTrackings[0].BOX_Folder_Link__c = 'http://www.test.com';
        update productionTrackings[0];
        List<Artifact__c> artifacts = [SELECT Id FROM Artifact__c 
                                       WHERE Production_Tracking__c = :productionTrackings[0].Id 
                                       AND Type__c = :Constants.ARTIFACT_TYPE_ARTWORK];
        system.assertEquals(1, artifacts.size());
        
		//Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //set all artifact transfer status to Success
        List<Artifact_Transfer__c> atsToUpdate = [SELECT Id, Status__c, Project_Manager__c FROM Artifact_Transfer__c
                                                  WHERE Artifact__r.Production_Tracking__c = :productionTrackings[0].Id 
                                                  AND Artifact__r.Type__c = :Constants.ARTIFACT_TYPE_ARTWORK];
        system.assertEquals(2, atsToUpdate.size());
        system.assertEquals(jobTickets[0].Project_Manager__c, atsToUpdate[0].Project_Manager__c);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Status__c = 'Success';
            ats.Target_File_Name__c = artFileName;
        }
        update atsToUpdate;
        
        Test.startTest();
		//create the 'mailing list' artifact
		productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_LIVE_PROOF;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_SUBMITTED;

        //12/01/2020 - CR-20201012-14597 - Victor Hanson - reset artifact generated
        ProductionTrackingTriggerHelper.artifactGenerationHasExecuted = false;

        update productionTrackings[0];
        
		//Modified - Victor Hanson - 05/28/2020 - CR-20200527-14113 - updated testcreateArtifactForProductionTracking to verify callouts
        //set all artifact transfer status to Success
        atsToUpdate = [SELECT Id, Status__c FROM Artifact_Transfer__c
                                                  WHERE Artifact__r.Production_Tracking__c = :productionTrackings[0].Id 
                                                  AND Artifact__r.Type__c = :Constants.ARTIFACT_TYPE_MAILING_LIST];
        system.assert(atsToUpdate.size() > 0);
        for (Artifact_Transfer__c ats : atsToUpdate) {
            ats.Status__c = 'Success';
            ats.Target_File_Name__c = mailingListName;
        }
        update atsToUpdate;
        
		//set ready for print
		productionTrackings[0].Status__c = Constants.PRODUCTION_TRACKING_STATUS_READY_FOR_PRINT;
        productionTrackings[0].Status_Detail__c = Constants.PRODUCTION_TRACKING_STATUS_DETAIL_LIVE_PROOF_APPROVED;
        update productionTrackings[0];
        
        Production_Tracking__c drop2 = new Production_Tracking__c(Status__c = 'Planned',Job_Ticket__c = jobTickets[0].Id,Art_File_Name__c = 'Test.zip',
                                                                  Mail_Shop_Vendor__c=vendorAccts[0].Id, Drop__c = 2, RecordTypeId=Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP);
        insert drop2;
        
        List<Production_Tracking__c> pTrackings = [SELECT Id,Proof_File_Received_DateTime__c,status__c,status_detail__c,
                                                           Proof_Pending_Approval_DateTime__c,Actual_Mail_Date__c,
                                                           Proof_Approved_DateTime__c,Live_Proof_File_Received_DateTime__c,
                                                           Job_Ticket__r.Vendor_Type__c,
                                                           Live_Proof_Pending_Approval_DateTime__c,
                                                           ReadyforPrint_LP_Approval_DateTime__c,Planned_Mail_Date__c,
                                                           Art_Received_by_Vendor__c,Data_Received_by_Vendor__c,
                                                           Live_Proofs_Approved__c,Live_Proofs_Received__c,
                                                           Proof_Approved__c,Proof_Received__c
                                                           FROM Production_Tracking__c 
                                                           WHERE Status__c =: Label.SLA_PT_STATUS 
                                                           AND RecordType.DeveloperName = 'Mail_Shop'
                                                           AND Job_Ticket__r.Vendor_Type__c =: Constants.VENDOR_TYPE_DIGITAL];
        
        
		LightningResponseEntity res1 = SLATrackingController.fetchproductionTrackingInfo('');
		system.assertEquals(Label.Insufficient_Access_To_RecordId,res1.message);

		LightningResponseEntity res2 = SLATrackingController.fetchproductionTrackingInfo(drop2.Id);
		system.assertEquals(Label.No_SLA_Records,res2.message);

		//LightningResponseEntity res3 = SLATrackingController.fetchproductionTrackingInfo(pTrackings[0].Id);
		//system.assertEquals(true,res3.Body != null);

        
    }
}