/**
*   Purpose         :   Test class for PrintmisConsoleWizardController
*            
*   Create By       :   Chirag Soni
* 
*   Created Date    :   09/30/2021
*
*   Revision Log    :   V_1.0 - Created By - Chirag Soni
*   
*   Coverage        :   
*
**/
@isTest(seeAllData = false)
private class Test_PrintmisConsoleWizardController 
{
    @testSetup static void dataSetup() 
    {
        //Bypass Flags
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Create job Ticket
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Vendor_Type__c = 'Offset';
        insert jobTicket;
        
        //Create Production Tracking Record with production tracking record history
        List<Production_Tracking__c> prodTrackingList = new List<Production_Tracking__c>();
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), status__c = 'Approved by Partner', Job_Ticket__c = jobTicket.Id);
        prodTrackingList.add(prodTracking);
        insert prodTrackingList;
        
        prodTrackingList[0].status__c = 'Proof';
        prodTrackingList[0].Status_Detail__c = 'Submitted';
        prodTrackingList[0].Proof_Generation__c = ProductionTrackingTriggerHelper.PROOF_GENERATION_EXTERNAL;
        update prodTrackingList[0];
        
        prodTrackingList[0].status__c = 'Proof';
        prodTrackingList[0].Status_Detail__c = 'File Received';
        update prodTrackingList[0];

        //Inserting production tracking history records
        Production_Tracking__History productionTrackingHisory = new Production_Tracking__History();
        productionTrackingHisory.ParentId = prodTrackingList[0].Id;
        productionTrackingHisory.Field = 'status__c';
        insert productionTrackingHisory;
        
        Production_Tracking__History productionTrackingHisory1 = new Production_Tracking__History();
        productionTrackingHisory1.ParentId = prodTrackingList[0].Id;
        productionTrackingHisory1.Field = 'Status_Detail__c';
        insert productionTrackingHisory1;
        
        //Inserting web service log records
        List<Web_Service_Log__c> webServiceLog = new List<Web_Service_Log__c>();
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,
                                                 Web_Service_Method__c = 'FindMeetings',Production_Tracking__c = prodTrackingList[0].Id,Response_Message__c = 'Success',
                                                 CreatedDate = System.Today().addDays(-45)));
        
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,
                                                 Web_Service_Method__c = 'FindMeetings',Production_Tracking__c = prodTrackingList[0].Id, Response_Message__c = 'Success',
                                                 CreatedDate = System.Today().addDays(-35)));
        
        webServiceLog.add(new Web_Service_Log__c(Card_Vendor__c = 'Out side',RecordTypeId = ProductionTrackingTriggerHelper.RT_WEB_SERVICE_LOG_PRODUCTION_TRACKING,
                                                 Web_Service_Method__c = 'FindMeetings',Production_Tracking__c = prodTrackingList[0].Id, Response_Message__c = 'Success',
                                                 CreatedDate = System.Today().addDays(-5)));
        
        insert webServiceLog;

       	Util.byPassAllTriggers = false;
    }
    
    static testMethod void test_fetchDefaultRecord()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.assert(jobTickets.size() > 0);
        Test.startTest();
        sObject sobj = PrintmisConsoleWizardController.fetchDefaultRecord(jobTickets[0].Id, 'Job_Ticket__c');
        System.assert(sobj != null);
        Test.stopTest();
    }
    
    static testMethod void test_fetchLookupData()
    {
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Name FROM Production_Tracking__c];
        System.assert(productionTrackings.size() > 0);
        Test.startTest();

        List<PrintmisConsoleWizardController.SObJectLookUpResult> sobjLookupResults = PrintmisConsoleWizardController.fetchLookupData(productionTrackings[0].Name,'Production_Tracking__c');
		System.assert(sobjLookupResults != null);
        
        Test.stopTest();
    }
    
    static testMethod void test_retrieveProductionTrackingHistory()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.assert(jobTickets.size() > 0);
        
        List<Production_Tracking__c> productionTrackings = [SELECT Id, Name FROM Production_Tracking__c];
        System.assert(productionTrackings.size() > 0);
            
        Test.startTest();
        
        LightningResponseEntity res = PrintmisConsoleWizardController.retrieveProductionTrackingHistory(productionTrackings[0].Id);
        System.assertEquals('success', res.status);
        System.assertEquals(true, res.isSuccess);
        
        LightningResponseEntity response = PrintmisConsoleWizardController.retrieveProductionTrackingHistory(jobTickets[0].Id);
        System.assertEquals('success', response.status);
        System.assertEquals(true, response.isSuccess);
        
        Util.byPassAllTriggers = true;
        delete productionTrackings;
        Util.byPassAllTriggers = false;
        
        LightningResponseEntity resNegCase = PrintmisConsoleWizardController.retrieveProductionTrackingHistory(jobTickets[0].Id);
        System.assertEquals('success', resNegCase.status);
        System.assertEquals(true, resNegCase.isSuccess);
        System.assert(resNegCase.message != null);
        
        Test.stopTest();
    }
}