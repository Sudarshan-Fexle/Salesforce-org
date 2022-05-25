/**
*   Purpose         :   Test class for CloneJobTicketController
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   04/09/2020
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta
*   
*   Coverage        :   85%
*
**/
@isTest(seeAllData = false) 
private class Test_CloneJobTicketController 
{
    @testSetup static void dataSetup()
    {
        Util.BypassAllTriggers = true;
        
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        Id programId = TestUtilities.CreateNewProgram(true).Id;
        
        //String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Job Ticket').getRecordTypeId();
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = accountId, Product__c = programId/*, RecordTypeId = jobTicketRecordTypeId*/);
        insert project;
        
        ES_Campaign__c esCampaign = PrintManagementTestDataFactory.CreateNewESCampaign(true);
        
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(true);
        
        Job_Ticket_Component__c jobTicketComponent = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true);
        
        Job_Ticket_MtM__c jobTicketMtM = PrintManagementTestDataFactory.CreateNewJobTicketMTM(false);
        jobTicketMtM.Job_Ticket__c = jobTicket.Id;
        jobTicketMtM.Job_Ticket_Component__c = jobTicketComponent.Id;
        insert jobTicketMtM;
        
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void test_doCloneAndretrieveComponentsForSelectedTemplate()
    {
       	List<Job_Ticket__c> jobTickets = [SELECT Id, Project__c,Fiscal_Year__c FROM Job_Ticket__c];
        System.assertEquals(2, jobTickets.size());
        
        List<ES_Campaign__c> esCampaigns = [SELECT Id,Fiscal_Year__c FROM ES_Campaign__c];
        System.assertEquals(1, esCampaigns.size());
        
        List<Project__c> projects = [SELECT Id FROM Project__c];
        System.assertEquals(1, projects.size());
        
        Test.startTest();
        
        CloneJobTicketController.doclone(jobTickets[0].Id, jobTickets[0].Id, projects[0].Id ,esCampaigns[0].Fiscal_Year__c, false);
        CloneJobTicketController.retrieveComponentsForSelectedTemplate(jobTickets[0].Id);
        CloneJobTicketController.overwriteJobTicket(jobTickets[0].Id, jobTickets[0].Id, projects[0].Id, esCampaigns[0].Fiscal_Year__c, false);
        
        Test.stopTest();

    }
    
    static testMethod void test_NegCase_doCloneAndretrieveComponentsForSelectedTemplate()
    {
        Test.startTest();
        CloneJobTicketController.doclone(null, null, null, null, null);
        CloneJobTicketController.retrieveComponentsForSelectedTemplate(null);
        CloneJobTicketController.overwriteJobTicket(null, null, null, null, null);
        Test.stopTest();
    }  
}