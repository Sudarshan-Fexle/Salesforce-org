/**
 * Purpose          :   Test class for CreateApprovalURL
 * 
 * CreatedDate      :   16/07/2020
 * 
 * RevisionLog      :   V_1.0 - Created -
 *                      V_1.1 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
 * Code Coverage    :   
 *
**/
@IsTest
private class Test_CreateApprovalUrl 
{
    @testSetup static void testSetupData()
    { 
        util.BypassAllTriggers = true;
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        //Create the Project
        Project__c proj = TestUtilities.createProject(false);
        proj.Institution__c = accountId;
        insert proj;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        //Creating Job Ticket record 
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Drop_Type__c = 'Pre Planned',Project__c = proj.Id, Status__c = 'Draft', Project_Manager__c = UserInfo.getUserId(), Descriptive_Name__c = 'Test', Art_Director__c = UserInfo.getUserId(), Mail_Quantity__c = 100,
                                         Change_Reason__c = 'Testing before update', Project_ID__c = 'Test', Fiscal_Year__c='2020'));
        insert jobTickets;
        
        List<Production_Tracking__c> productionTrackings = new List<Production_Tracking__c>();
        productionTrackings.add(new Production_Tracking__c(Mail_Shop_Vendor__c =  null, Status__c = 'Planned',Job_Ticket__c = jobTickets[0].Id, 
                                                           RecordTypeId = Constants.RECORD_TYPE_ID_PRODUCTION_TRACKING_MAIL_SHOP));
        insert productionTrackings; 

		 util.BypassAllTriggers = false;        
    }
    
    static testMethod void test_GenerateApprovalURL()
    {
        List<Production_Tracking__c> productionTrackings = [SELECT Id FROM Production_Tracking__c];
        Test.startTest();
        CreateApprovalURL crtApp = new CreateApprovalURL();
        crtApp.caseID = productionTrackings[0].Id;
        String getResult = crtApp.urlStr;
        Test.stopTest();
    }
}