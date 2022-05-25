/**
*  Description     :   test action that posts to slack
* 
*  Revision Logs   :   V1.0 - 09/22/2020 - CR-20200731-14394 - Victor Hanson - Created
* 
**/
@IsTest
private class Test_PostToSlackAction {
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Vendor_Type__c = 'Digital';
        insert jobTicket;
        
        Production_Tracking__c prodTracking = new Production_Tracking__c(Planned_Mail_Date__c = system.today().addDays(28), 
                                                                         status__c = Constants.JOB_TICKET_STATUS_APPROVED_BY_CLIENT,
                                                                         Print_Quantity_Planned__c = 100,
                                                                         Job_Ticket__c = jobTicket.Id);
        insert prodTracking;
    }
    
    @isTest static void testPostToSlack() {
        //Get Production Tracking
        Id prodTrackingId = [Select Id FROM Production_Tracking__c].Id;
        
        test.startTest();
        
        //Mock class for callout
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        //insert web service log
        Web_Service_Log__c wsl = new Web_Service_Log__c(Production_Tracking__c = prodTrackingId,
                                                       Response_Message__c = '500',
                                                       Response_Message_Log__c = 'Error: some error text');
        insert wsl;
        
        //post to slack
        PostToSlackAction.PostToSlackActionRequest actionReq = new PostToSlackAction.PostToSlackActionRequest();
        actionReq.webServiceLogId = wsl.Id;
        actionReq.slackCalloutMetadataName = Label.Slack_Callout_Metadata_Name;
		actionReq.message = 'test';
        PostToSlackAction.postToSlack(new List<PostToSlackAction.PostToSlackActionRequest> { actionReq });
        
        List<Web_Service_Log__c> wsls = [SELECT Id, Response_Message__c FROM Web_Service_Log__c WHERE Id = :wsl.Id];
        system.assertEquals(1, wsls.size());
        system.assertEquals('500', wsls[0].Response_Message__c);
    }
}