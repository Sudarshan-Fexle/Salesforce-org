/*
 * Purpose		:	Test class for JobTicketTriggerHelper
 * 
 * CreatedDate		:	21/10/2019
 * 
 * RevisionLog		: 	V_1.0 - Created - Dipesh Gupta
 *                      	V_1.1 - Modified By - 04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
 * 			:	V_1.1 - Modified By - Abhishek Mishra - CR-20210517-15149 - 05/28/2021 - Improve code coverage
 * Code Coverage	:	100%
 * */
@IsTest
private class Test_Batch_CreateBoxFolderForJT
{
     @testSetup static void testSetupData()
    {
         Util.ByPassAllTriggers = true;
        
        Id userId = TestUtilities.CreatenewUser(true).Id;
        
        // Create Account
        Account inst = new Account(Vendor_Type__c = 'Vendor', Name = 'Test1',Account_Formal_Name__c = 'Central State University',r_School_Code__c = '1234');
        insert inst;
        
       
        Project__c project = new Project__c(Name = 'Test Project', Institution__c = inst.Id, Fiscal_Year__c = '2020');
        insert project;
        
        //Creating ES Campaign record
        List<ES_Campaign__c> esc = new List<ES_Campaign__c>();
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2019', Status__c = 'Open', School__c = inst.Id, Project_Manager__c = userId));
        esc.add(new ES_Campaign__c(Fiscal_Year__c = '2020', Status__c = 'In Process', School__c = inst.Id, Project_Manager__c = userId));
        insert esc;
        
        //04/30/2021 - CR-20210323-15016 - Neha Sharma - populate drop type
        List<Job_Ticket__c> jobTickets = new List<Job_Ticket__c>();
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[0].Id, Mail_Quantity__c = 500, Status__c = 'Draft', Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', Project_Manager__c = userId, Change_Reason__c = 'Testing before update',Box_Folder_Id__c='12345' ));
        jobTickets.add(new Job_Ticket__c(Project__c = project.Id,Drop_Type__c = 'Pre Planned',ES_Campaign__c = esc[1].Id, Mail_Quantity__c = 1000, Status__c = 'Draft', Art_Director__c = userId, Descriptive_Name__c = '### Test Record ###', Locked__c = true, Project_Manager__c = userId, Change_Reason__c = 'Testing before update'));
        
        insert jobTickets;
        
        Production_Tracking__c prodTracking = new Production_Tracking__c(Box_Folder_Id__c = '1234',Job_Ticket__c = jobTickets[0].Id);
        insert prodTracking;
        
    }

    @IsTest static void testcreateBoxFoldersForJobTicket1(){   
       JobTicketTriggerHelper.Bypass_createBoxFoldersForJobTicket = true;
        Util.ByPassAllTriggers = true;
        
        List<Job_Ticket__c> jobTicketList = [Select id,ES_Campaign__c,Mail_Quantity__c,Status__c,Art_Director__c,Descriptive_Name__c,Project_Manager__c,
                                          Change_Reason__c,Fiscal_Year__c FROM Job_Ticket__c ];
        
        Set<Id> jobTicketids = new  Set<Id>(); 
        jobTicketids.add(jobTicketList[0].Id);
         jobTicketids.add(jobTicketList[1].Id);
        
        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));

        Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(jobTicketids);
        Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));        
        Test.stopTest();
    }
    
    @IsTest static void testcreateBoxFoldersForJobTicket2(){   
       
        Set<Id> jobTicketids = new  Set<Id>(); 
     
        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));
        try{ 
        Batch_CreateBoxFolderForJT batchJobTicket = new Batch_CreateBoxFolderForJT(jobTicketids);
        Database.executeBatch(batchJobTicket, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));
        }
        catch(Exception e)
        {
            system.assertEquals('Please send the valid parameters!', e.getMessage());
        }
        
        Test.stopTest();
        
    }
    
    //Added by Abhishek Mishra - CR-20210517-15149 - 05/28/2021 
    @IsTest static void testcreateBoxFolderForPT1(){
        List<Job_Ticket__c> jobTicketList = [Select id,ES_Campaign__c,Mail_Quantity__c,Status__c,Art_Director__c,Descriptive_Name__c,Project_Manager__c,
                                             Change_Reason__c,Fiscal_Year__c,Box_Folder_Id__c,BOX_Folder_Link__c FROM Job_Ticket__c ];
        
        Set<Id> jobTicketids = new  Set<Id>(); 
        jobTicketids.add(jobTicketList[0].Id);
        jobTicketids.add(jobTicketList[1].Id);  

        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));

        Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(jobTicketids);
        Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));       
        Test.stopTest();
    }
    
    //Added by Abhishek Mishra - CR-20210517-15149 - 05/28/2021 
    @IsTest static void testcreateBoxFolderForPT2(){
        
        Set<Id> jobTicketids = new  Set<Id>();  
     
        Test.startTest();
        String authResponse = BoxTestJsonResponseFactory.AUTH_APP_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, (new BoxTestMockCallout(authResponse, 'OK', 200)));
        try{ 
            Batch_CreateBoxFolderForPT batchProductionTracking = new Batch_CreateBoxFolderForPT(jobTicketids);
            Database.executeBatch(batchProductionTracking, Integer.valueOf(Label.ProductionTracking_BoxBatchSize));    
        }
        catch(Exception e)
        {
            system.assertEquals('Please send the valid parameters!', e.getMessage());
        }
        
        Test.stopTest();
        
    }
}