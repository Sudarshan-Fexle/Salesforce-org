/*
Purpose            :    Test Class for Utilization Reports - This requires SeeAllData because we cannot create a Report purely in code    

Created By         :    Colin McGloin

Current Version    :    v1.0

Revision Log       :    v1.0 - Colin McGloin - CR-20180629-12311 - 09/10/2018
*/

@isTest (SeeAllData='true')
public class Test_UtilizationReportController {
    
    static testmethod void testInstitutionLookup () {
        
        //Pull through our test report
        Report testReport = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Meeting_Utilizations_SB'];
        
        if(testReport != null) {
            
            //Pull through 5 Institutions which have records that would be in our test report
            List<Account> test1 = [SELECT Id, Name FROM Account WHERE Id IN (SELECT Institution__c FROM Meeting_Utilization__c WHERE Institution__c != Null) LIMIT 5];
            
            //Grab our request record type ID
            String requestRTId = Schema.SObjectType.Utilization_Report__c.getRecordTypeInfosByName().get('Utilization Report Request').getRecordTypeId();
            
            //Create our Utilization Report Scenario
            Utilization_Report__c testReq = new Utilization_Report__c();
            testReq.RecordTypeId = requestRTID;
            testReq.Name = 'Test Scenario';
            testReq.Report_ID__c = testReport.Id;
            testReq.Scenario_Type__c = 'Summary Count';
            testReq.Report_Object__c = 'Institution';
            testReq.Active__c = true;
            testReq.Report_Output_Tag_Line__c = 'The count of Meeting Utilizations in this time period is:';
            
            //Create a page reference
            PageReference pageRef = Page.UtilizationReportCreator;
            
            //Set the Page Reference in Test
            Test.setCurrentPage(pageRef);
            
            //Create custom controller
            UtilizationReportController testController = new UtilizationReportController();
            Utilization_Report__c requestRecord = new Utilization_Report__c();
            requestRecord.Report_Start_Date__c = (Date.today() - 365);
            requestRecord.Report_End_Date__c = Date.today();
            requestRecord.Report_Institution__c = test1[0].Id;
            testController.requestRecord = requestRecord;
            
            //Run our Scenarios and get No Active Scenarios error
            PageReference testRS = testController.runScenarios();
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            
            //Loop through our Messages
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(Label.Studybuilder_No_Active_Scenarios, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            }
            
            //Insert our Scenarios and run successfully
            insert testReq;
            PageReference testRS2 = testController.runScenarios();
            
            
        }
    }
}