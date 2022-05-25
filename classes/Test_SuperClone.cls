/**
 *	Purpose            :    Test class for SuperClone 
 *
 *	Created By         :    Abhishek Mishra
 *
 *	Current Version    :    V1.0
 *
 *	Created Date       :    08/09/2021
 *
 *	Revision Log       :    V1.0 - Created - Abhishek Mishra - CR-20211005-15489 - 08/09/2021 - increase code coverage
 *
 **/
@isTest(seeAllData = false)
private class Test_SuperClone 
{
    @testSetup 
    static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        
        //Create Program
        Id programId = TestUtilities.CreateNewProgram(true).Id;
        
        //Create Account
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        
        //Create Project with ES Project Record Type
        String recordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('ES_Project').getRecordTypeId();
        Project__c project = new Project__c(Name = 'Test Project',Product__c = programId, Institution__c = accountId,RecordTypeId = recordTypeId, Fiscal_Year__c = '2021');
        insert project;
        
        //Create Job Ticket
        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Project__c = project.Id;
        insert jobTicket;
        
        //Create Job Ticket Component
        List<Job_Ticket_Component__c> jobTicketComponents = new List<Job_Ticket_Component__c>();
        jobTicketComponents.add(new Job_Ticket_Component__c(Name = 'Test2', Component__c = 'Envelope', Size__c = '4 x 6'));
        insert jobTicketComponents;
        
        //Create Job Ticket MTMs
        List<Job_Ticket_MTM__c> jobTicketMTMs = new List<Job_Ticket_MTM__c>();
        jobTicketMTMs.add(new Job_Ticket_MTM__c(Job_Ticket__c = jobTicket.Id, Job_Ticket_Component__c = jobTicketComponents[0].Id));
        insert jobTicketMTMs;
        
        Util.byPassAllTriggers = false;
    } 
    
    //Create By -  Abhishek Mishra -  08/09/2021 - test method to test doClone Method
    static testMethod void testDoClone()
    {
        List<Job_Ticket__c> jobTicket = [SELECT Id, Project__c FROM Job_Ticket__c];
        System.assertEquals(1, jobTicket.size());
        
        Test.startTest();
        
        //Test for doClone method with proper assertions
        LightningResponseEntity res = SuperClone.doClone(jobTicket[0].Id,jobTicket[0].Project__c);
        System.assertEquals('success', res.status);
        System.assertEquals(true, res.isSuccess);
        
        Test.stopTest();
    }
    
    //Create By - Abhishek Mishra - 08/09/2021 - test method to test retrieveComponentsForSelectedTemplate Method
    static testMethod void testRetrieveComponentsForSelectedTemplate()
    {
        List<Job_Ticket__c> jobTicket = [SELECT Id, Project__c FROM Job_Ticket__c];
        System.assertEquals(1, jobTicket.size());
        
        Test.startTest();
        
        //Test for retrieveComponentsForSelectedTemplate method with proper assertions
        LightningResponseEntity res = SuperClone.retrieveComponentsForSelectedTemplate(jobTicket[0].Id);
        System.assertEquals('success', res.status);
        System.assertEquals(true, res.isSuccess);
        
        Test.stopTest();
    }
    
    //Create By - Abhishek Mishra - 08/09/2021 - Negative Use Case
    static testMethod void test_NegCaseForDoCloneAndRetrieveComponentsForSelectedTemplateMethod()
    {
        Id parentId = null; String projectId = '';
        LightningResponseEntity res = SuperClone.doClone(parentId, projectId);
        LightningResponseEntity lightningResponseEntity1 = SuperClone.retrieveComponentsForSelectedTemplate(parentId);  
    }
}