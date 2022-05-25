/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
/**
*   Purpose         :   Test class for SuperCloneService
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/05/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
                    :   V_1.1 - Modified By Dipesh Gupta, Issue--CR13887--QA--00009627 (CR-20200325-13887),  to Change the reference of Es Campaign to the Project.
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_SuperCloneService 
{
    @testSetup static void dataSetup()
    {
        Util.IsTest(true);
        Util.isTesting = true;
        Util.byPassAllTriggers = true;
        Id programId = TestUtilities.CreateNewProgram(true).Id;
	Id accountId = TestUtilities.CreateNewAccount(true).Id;

        String recordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByDeveloperName().get('ES_Project').getRecordTypeId();
        Project__c project = new Project__c(Name = 'Test Project',Product__c = programId, Institution__c = accountId,RecordTypeId = recordTypeId, Fiscal_Year__c = '2021');
        insert project;

        Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicket.Project__c = project.Id;
        insert jobTicket;
        Util.byPassAllTriggers = false;
    } 
    
    static testMethod void testDoClone()
    {
        SuperCloneService supClnSer = new SuperCloneService();
        List<Job_Ticket__c> jobTicket = [SELECT Id, Project__c FROM Job_Ticket__c];
        System.assertEquals(1, jobTicket.size());
        
        Test.startTest();
        
        Id recId = supClnSer.doClone(jobTicket[0].Id,jobTicket[0].Project__c);
        System.assert(recId != null);
        
        Test.stopTest();
    }

    static testMethod void testNag_DoClone()
    {
        SuperCloneService supClnSer = new SuperCloneService();
        
        String jobTicket= 'fakeId34';
        String projectId = null;
        
        Test.startTest();
        
        Id recId = supClnSer.doClone(jobTicket,projectId);
        System.assertEquals(null, recId);
        
        Test.stopTest();
    }
}