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
*   Purpose         :   Test class for PrintJobTicket_Ext
*            
*   Create By       :   Dipesh Gupta
* 
*   Created Date    :   12/02/2019
*
*   Revision Log    :   V_1.0 - Created - Dipesh Gupta 
*			V_1.1 - Modified - Victor Hanson - 05/08/2020 - CR-20200508-14031 - Added jobTicketName to assertion to test
*			V_1.2 - Modified - Neha Sharma - 08/07/2021 - CR-20201218-14754
*   
*   Coverage        :   V_1.0 - 
*
**/
@isTest(seeAllData = false)
private class Test_PrintJobTicket_Ext 
{
    
    @testSetup static void dataSetup()
    { 
        Util.IsTest(true);
        Util.isTesting = true;
        
        Util.byPassAllTriggers = true;
        Job_Ticket__c jobTickets = PrintManagementTestDataFactory.CreateNewJobTicket(true);
        List<Job_Ticket_Component__c> jobTctComponets = new List<Job_Ticket_Component__c>(); 
        jobTctComponets.add(PrintManagementTestDataFactory.CreateNewJobTicketComponent(true));
        
        List<Job_Ticket_MtM__c> jobTickectMTMs = new List<Job_Ticket_MtM__c>();
        
        if(jobTctComponets.size() > 0)
        {
            jobTickectMTMs.add(new Job_Ticket_MtM__c(Job_Ticket__c = jobTickets.Id, Job_Ticket_Component__c = jobTctComponets[0].Id));
            insert jobTickectMTMs;
        }
        Util.byPassAllTriggers = false;

    }
    
    static testMethod void myUnitTesting()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id, Name FROM Job_Ticket__c];
        System.assertEquals(1, jobTickets.size());
        
        List<Job_Ticket_MtM__c> jobTictMtMs = [SELECT Id FROM Job_Ticket_MtM__c];
        System.assertEquals(1, jobTictMtMs.size());
        
        Test.startTest(); 
        
        ApexPages.StandardController sc = new ApexPages.standardController(jobTickets[0]);
        PrintJobTicket_Ext controller = new PrintJobTicket_Ext(sc);
        
        system.assertEquals(jobTickets[0].Name, controller.jobTicketName);
        
        Test.stopTest();
    }
    
    //Modified - Neha Sharma- 08/07/2021 - CR-20201218-14754 - Added the test method to test the getUserTimeZone method
    static testMethod void test_getUserTimeZone()
    {
        List<Job_Ticket__c> jobTickets = [SELECT Id, Name FROM Job_Ticket__c];
        System.assertEquals(1, jobTickets.size());
        
        List<Job_Ticket_MtM__c> jobTictMtMs = [SELECT Id FROM Job_Ticket_MtM__c];
        System.assertEquals(1, jobTictMtMs.size());
        
        Test.startTest(); 
        
        ApexPages.StandardController sc = new ApexPages.standardController(jobTickets[0]);
        PrintJobTicket_Ext controller = new PrintJobTicket_Ext(sc);
        
        String userTimeZone = UserInfo.getTimeZone().getID();
        Datetime dateTimeInGMT=System.now();
        
        system.assertEquals(dateTimeInGMT.format('MM/dd/yyyy HH:mm a',userTimeZone), controller.dateTimeUserContext);
        
        Test.stopTest();
    }
}