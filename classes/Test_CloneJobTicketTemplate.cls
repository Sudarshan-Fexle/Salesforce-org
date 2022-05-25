/*
Purpose         :  Test class for CloneJobTicketTemplate

Created By      :   Dipesh Gupta

Created Date    :   03/04/2020

Current Version :   v1.0

Revision Log    :   V_1.0 Created - Dipesh Gupta - 03/04/2020
                :   V_1.1 - Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997 - Update the "BRE" to "Reply Envelope (BRE/CRE)"
		:   V_1.2 - Modified By - Shalu Sharma - 03/04/2022 - CR-20220304-15984

Code Coverage   :   88%

*/
@IsTest
private class Test_CloneJobTicketTemplate 
{
    @testSetup static void testSetupData()
    {
        Util.BypassAllTriggers = true;
        
    	Job_Ticket__c jobTicket = PrintManagementTestDataFactory.CreateNewJobTicket(true); 
        
        Job_Ticket__c jobTicketForClone = PrintManagementTestDataFactory.CreateNewJobTicket(false);
        jobTicketForClone.Auto_Generated__c = true;
		jobTicketForClone.Added_Job_Template__c = false;
		jobTicketForClone.Template_Name__c = 'Test';
		insert jobTicketForClone;
        
        Job_Ticket_Component__c jobTicketComp = PrintManagementTestDataFactory.CreateNewJobTicketComponent(true);
        
         //Modify by - Shalu Sharma - 5/18/21 - CR-20210315-14997
        Job_Ticket_MtM__c jobTicketMtM = new Job_Ticket_MtM__c(Job_Ticket__c = jobTicketForClone.Id, 
                                                               Job_Ticket_Component__c = jobTicketComp.Id,
                                                               Component_Type__c = Constants.COMPONENT_TYPE_BRE);
        insert jobTicketMtM;
        Util.BypassAllTriggers = false;
    }
    
    static testMethod void testcheckForAccess()
    {
    	List<Job_Ticket__c> jobTickets = [SELECT Id FROM Job_Ticket__c];
        System.assertEquals(2, jobTickets.size());
        
        List<Job_Ticket__c> listOfJobTickts = [SELECT Id FROM Job_Ticket__c 
                                          	   WHERE Auto_Generated__c = true AND Added_Job_Template__c = false];
        System.assertEquals(1, listOfJobTickts.size());
        
        Test.startTest();
        
        try
        {
            CloneJobTicketTemplate.checkForAccess(jobTickets[0].Id);
        }
        Catch(Exception e)
        {
            //Commented via CR-20220304-15984
            //START FROM HERE
            //Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.No_Data_Message_For_Processing) ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
            //END HERE
        }
        
        LightningResponseEntity response = CloneJobTicketTemplate.doClone(listOfJobTickts[0].Id, listOfJobTickts[0].Id);
        System.assert(response.body != null);
        
        Test.stopTest();
    }
    
    static testMethod void test_CheckForNeg()
    {
        String parentId= null;
        String jobTicketId = null;
        Test.startTest();
        LightningResponseEntity response = CloneJobTicketTemplate.doClone(parentId,jobTicketId);
       	CloneJobTicketTemplate.checkForAccess(jobTicketId);
        Test.stopTest();
    }
}