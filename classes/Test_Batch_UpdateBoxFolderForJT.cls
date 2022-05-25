/*
 * Purpose		:	Test class for Batch_UpdateBoxFolderForJT
 * 
 * CreatedDate		:	21/10/2019
 * 
 * RevisionLog		: 	V_1.0 - Created - Dipesh Gupta
 *                              V_1.1 - Modified by - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
 * Code Coverage	:	100%
 * */
@IsTest
private class Test_Batch_UpdateBoxFolderForJT 
{
    @testSetup static void testSetupData()
    {
         Util.ByPassAllTriggers = true;
        // Create Account
        Id accountId = TestUtilities.CreateNewAccount(true).Id;
        Id userId = TestUtilities.CreatenewUser(true).Id;
        
        Program__c prog = TestUtilities.createNewProgram(null, 'ESNN', 'No', 'Enrollment Services', false);
        insert prog;
        
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = accountId, Fiscal_Year__c = '2019');
        insert project;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Mail_Quantity__c = 500, Drop_Type__c = 'Pre Planned',Status__c = 'Draft', Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', 
                                         Project_Manager__c = userId, Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345', 
                                         Project__c =  project.Id, Program__c = prog.Id));
        jobTickets.add(new Job_Ticket__c(Mail_Quantity__c = 1000, Drop_Type__c = 'Pre Planned',Status__c = 'Draft', Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', 
                                         Locked__c = true, Project_Manager__c = userId, Change_Reason__c = 'Testing before update', 
                                         Project__c =  project.Id, Program__c = prog.Id));
        insert jobTickets;
        
    }
    
    @IsTest static void test_UpdateBoxFolderJT(){   
       JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = true;
        Util.ByPassAllTriggers = true;
        
        List<Job_Ticket__c> jobTicketList = [Select Id, Mail_Quantity__c,Status__c, Art_Director__c, Descriptive_Name__c, Project_Manager__c,
                                             Project__c, Program__c, Change_Reason__c FROM Job_Ticket__c ];
        
        Set<Id> jobTicketids = new  Set<Id>(); 
        jobTicketids.add(jobTicketList[0].Id);
        jobTicketids.add(jobTicketList[1].Id);
        
        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));

        Batch_UpdateBoxFolderForJT batchJobTicket = new Batch_UpdateBoxFolderForJT(jobTicketids);
        Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));        
        Test.stopTest();
    }
    
     @IsTest static void testUpdateBoxFoldersForJT()
     {   
        Set<Id> jobTicketids = new  Set<Id>(); 
        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));
        try
        { 
            Batch_UpdateBoxFolderForJT batchJobTicket = new Batch_UpdateBoxFolderForJT(jobTicketids);
            Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        }
        catch(Exception e){
            system.assertEquals('Please send the valid parameters!', e.getMessage());
        }
        Test.stopTest();
    }

}