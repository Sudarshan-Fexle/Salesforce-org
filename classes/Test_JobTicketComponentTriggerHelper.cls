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
*   Purpose         :   Test class for JobTicketComponentHelper
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/04/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*   
*   Coverage        :   V_1.0 - 
*		    :   V_1.1 - Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates
*		    :	V_1.2 - Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
*
**/
@isTest(seeAllData = false)
private class Test_JobTicketComponentTriggerHelper 
{ 
    @testSetup static void dataSetup()
    {
        List<Job_Ticket_Component__c> jobTicketComps = new List<Job_Ticket_Component__c>() ;
        //Modified By - Abhinav Sharma - 02/05/2021 - CR-20210108-14792 - JT Component field and record updates (Change Size picklist value)
        jobTicketComps.add(new Job_Ticket_Component__c(Name = 'Test',Component__c = Label.Component_Type_Value2,
                                                       Paper_Type__c = '80# Gloss, Dull, Matte or Silk Text',Size__c = '9 x 11-1/2'));
        insert jobTicketComps;
        
        Id jobTicketId = PrintManagementTestDataFactory.CreateNewJobTicket(true).Id;
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = new List<Job_Ticket_MtM__c>();
        jobTicketMtMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTicketId, Job_Ticket_Component__c = jobTicketComps[0].Id));
        insert jobTicketMtMs;
        
    }
    
    static testMethod void updateJobTictBasedOnCompChnge()
    {
        List<Job_Ticket_Component__c> jobTicketComps = [SELECT Id, Component__c FROM Job_Ticket_Component__c];
        System.assertEquals(1, jobTicketComps.size());
        
        List<Job_Ticket_MtM__c> jobTicketMtMs = [SELECT Id FROM Job_Ticket_MtM__c];
        System.assertEquals(1, jobTicketMtMs.size());
        
        Test.startTest();
        System.assert(jobTicketComps[0].Component__c != null);
        //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        jobTicketComps[0].Component__c = Constants.COMPONENT_TYPE_BRE;
        update jobTicketComps;
        Test.stopTest();
    }
}