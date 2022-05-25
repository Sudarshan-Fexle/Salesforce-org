/**
     *  Purpose         :   test class for MemberSupportQuickViewExt
     *   
     *  Revision Log    :   v1.0 - Created - 12/17/2019 - Victor Hanson
     *
    **/
@isTest
public class Test_MemberSupportQuickViewExt {
	
    /**
     * Setup the test data by creating an project and site issues
     **/
    @testSetup static void testData() {
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        Project__c proj = TestUtilities.createProject(true);
        
        List<Site_Issue__c> siteIssues = new List<Site_Issue__c>();
        
        //create issue resolved in 5 days
        Site_Issue__c sIssue_5day_DataSiteIssue = TestUtilities.createSiteIssue(proj.Id, false);
        sIssue_5day_DataSiteIssue.Support_Category__c = MemberSupportQuickViewExt.SITE_ISSUE_CATEGORY_DATA_SITE_ISSUE;
        sIssue_5day_DataSiteIssue.Site_Issue_Created_Date__c = DateTime.newInstance(2018, 11, 12);
        sIssue_5day_DataSiteIssue.Actual_Resolution_Date__c = DateTime.newInstance(2018, 11, 19);
        siteIssues.add(sIssue_5day_DataSiteIssue);
        
        //create critical issue resolved in 10 days
        Site_Issue__c sIssue_10day_DataSiteIssue = TestUtilities.createSiteIssue(proj.Id, false);
        sIssue_10day_DataSiteIssue.Support_Category__c = MemberSupportQuickViewExt.SITE_ISSUE_CATEGORY_DATA_SITE_ISSUE;
        sIssue_10day_DataSiteIssue.Site_Issue_Priority__c = 'Critical';
        sIssue_10day_DataSiteIssue.Reason_for_Priority__c = 'test';
        sIssue_10day_DataSiteIssue.Site_Issue_Created_Date__c = DateTime.newInstance(2019, 01, 14);
        sIssue_10day_DataSiteIssue.Actual_Resolution_Date__c = DateTime.newInstance(2019, 01, 28);
        siteIssues.add(sIssue_10day_DataSiteIssue);
        
        //create issue resolved in 4 days
        Site_Issue__c sIssue_4day_ChangeRequest = TestUtilities.createSiteIssue(proj.Id, false);
        sIssue_4day_ChangeRequest.Support_Category__c = MemberSupportQuickViewExt.SITE_ISSUE_CATEGORY_CHANGE_REQUEST;
        sIssue_4day_ChangeRequest.Site_Issue_Created_Date__c = DateTime.newInstance(2018, 11, 12);
        sIssue_4day_ChangeRequest.Actual_Resolution_Date__c = DateTime.newInstance(2018, 11, 16);
        siteIssues.add(sIssue_4day_ChangeRequest);
        
        //create open ssc_rms issue
        Site_Issue__c sIssue_Open_SSC = TestUtilities.createSiteIssue(proj.Id, false);
        sIssue_Open_SSC.RecordTypeId = MemberSupportQuickViewExt.SITE_ISSUE_RT_ID_SSC_RMS;
        sIssue_Open_SSC.Support_Category__c = MemberSupportQuickViewExt.SITE_ISSUE_CATEGORY_CHANGE_REQUEST;
        sIssue_Open_SSC.Site_Issue_Created_Date__c = DateTime.newInstance(2018, 11, 12);
        sIssue_Open_SSC.Site_Issue_Close_Date__c = null;
        sIssue_Open_SSC.Actual_Resolution_Date__c = null;
        siteIssues.add(sIssue_Open_SSC);
        
        //insert site issues
        insert siteIssues;
        
        Map<Id, Site_Issue__c> sIssueMap = new Map<Id, Site_Issue__c>([SELECT Id, Elapsed_Opened_to_Act_Resolution_Date__c FROM Site_Issue__c WHERE Id IN :siteIssues]);
        
        system.assertEquals(5, sIssueMap.get(sIssue_5day_DataSiteIssue.Id).Elapsed_Opened_to_Act_Resolution_Date__c);
        system.assertEquals(10, sIssueMap.get(sIssue_10day_DataSiteIssue.Id).Elapsed_Opened_to_Act_Resolution_Date__c);
        system.assertEquals(4, sIssueMap.get(sIssue_4day_ChangeRequest.Id).Elapsed_Opened_to_Act_Resolution_Date__c);
        system.assertEquals(null, sIssueMap.get(sIssue_Open_SSC.Id).Elapsed_Opened_to_Act_Resolution_Date__c);
        
    }
    
    /**
     *  Purpose         :   test the dataWrapper method
     *   
     *  Revision Log    :   v1.0 - Created - 12/17/2019 - Victor Hanson
     *
    **/
    static testMethod void testDataWrapper() {
        //get the project
        List<Project__c> project = [SELECT Id FROM Project__c];
        
        //get the ticket data
        MemberSupportQuickViewExt.dataWrapper msQuickViewExt = MemberSupportQuickViewExt.getTicketData(project[0].Id, null);
        system.assertEquals(1, msQuickViewExt.numOpenTickets);
        
    }

    static testMethod void testGetOpenCases() {
        //get the project
        List<Project__c> project = [SELECT Id FROM Project__c];
        
        //get the ticket data
        Integer openCases = MemberSupportQuickViewExt.getOpenCases(project[0].Id);
        system.assertEquals(0, openCases);
        
    }
    
    static testMethod void testSearchTickets() {
        //get the project
        List<Project__c> project = [SELECT Id FROM Project__c];
        
        //get the ticket data
        MemberSupportQuickViewExt.dataWrapper msQuickViewExt = 
            MemberSupportQuickViewExt.searchTickets(project[0].Id, null, null, null);
        system.assertEquals(4, msQuickViewExt.numHighOrCriticalTickets_Last_N_Days);
        system.assertEquals(3, msQuickViewExt.numAll);
        system.assertEquals(2, msQuickViewExt.numDataIssue);
        system.assertEquals(8, msQuickViewExt.avgDataIssueResolution);
        system.assertEquals(1, msQuickViewExt.numOpenTicketsRT);
    }

    
    static testMethod void testGetRecordTypes() {
        //get the project
        List<Project__c> project = [SELECT Id FROM Project__c];
        
        //get the record type data
        List<String> recordTypes = 
            MemberSupportQuickViewExt.getRecordTypes(project[0].Id);
        
        system.assert(recordTypes.size() > 0);
    }
}