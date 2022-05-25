/**
*   Purpose         :   Test class for SuperCloneServiceForCloneJobTicket
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   04/09/2020
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta
*   
*   Coverage        :   96%
*
**/
@isTest(seeAllData = false)
public class Test_SuperCloneServiceForCloneJT 
{
    @testSetup static void dataSetup()
    {
        Util.BypassAllTriggers = true;
        
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        Id programId = TestUtilities.CreateNewProgram(true).Id;
        
        //String jobTicketRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('Print').getRecordTypeId();
        
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
    static testMethod void test_doClone()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id,Project__c,Fiscal_Year__c FROM Job_Ticket__c];
        System.assertEquals(2, jobTickets.size());
        
        List<ES_Campaign__c> esCampaigns = [SELECT Id,Fiscal_Year__c FROM ES_Campaign__c];
        System.assertEquals(1, esCampaigns.size());
        
        List<Project__c> projects = [SELECT Id FROM Project__c];
        System.assertEquals(1, projects.size());
        
        SuperCloneServiceForCloneJobTicket cloneJT = new SuperCloneServiceForCloneJobTicket();
        cloneJT.doClone(jobTickets[0].Id, jobTickets[0].Id, projects[0].Id, esCampaigns[0].Fiscal_Year__c, false);
    }
    static testMethod void test_doCloneForElseCondition()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id,Project__c,Fiscal_Year__c FROM Job_Ticket__c];
        System.assertEquals(2, jobTickets.size());
        
        List<ES_Campaign__c> esCampaigns = [SELECT Id,Fiscal_Year__c FROM ES_Campaign__c];
        System.assertEquals(1, esCampaigns.size());
        
        List<Project__c> projects = [SELECT Id FROM Project__c];
        System.assertEquals(1, projects.size());
        
        SuperCloneServiceForCloneJobTicket cloneJT = new SuperCloneServiceForCloneJobTicket();
        cloneJT.doClone(jobTickets[0].Id, jobTickets[0].Id, projects[0].Id, esCampaigns[0].Fiscal_Year__c, true);
    }

}