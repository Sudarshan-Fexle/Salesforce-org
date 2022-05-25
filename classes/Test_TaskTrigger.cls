/**
 *  Purpose         :   Test class for Trigger_Task
 *                
 *  Create By       :   Simplyforce Technology
 *    
 *  Created Date    :   11/03/2011
 *    
 *  Revision Logs   :   V1.0 - Created
 *		    		:   V1.1 - Modified By - Abhinav Sharma - 07/13/2016 - CR-20150202-8648  - A Refactor Code CR
 *		    		:   V1.2 - Modified By - Victor Hanson - 02/17/2017 - CR-20170217-10703 - Lookup Rollup Summary
 *		    		:   V1.3 - Modified By - Subhash Garhwal - 07/06/2017 
 *		    		:   V1.4 - Modified By - Subhash Garhwal - 04/25/2018
 *		    		:   V1.5 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683
 *		    		:   V1.6 - Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426
**/
//Modified By - Nikita Kumari - 09/30/2021 -CR-20210910-15426 - SeeAllData=true to false
@IsTest(SeeAllData=false)
private class Test_TaskTrigger {
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test out the notify user related functionality.
    **/
    static testmethod void testNotifyTaskCreator() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //Create test data
        Task task = new Task(Subject = 'testSubject', Status = TaskTriggerHelper.STATUS_COMPLETED, 
                             //Notify_Task_Creator__c = false, 
                             Event_Type__c = 'test');
        
        //start test from here 
        Test.startTest();
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;        
        
        //insert the task record
      /*  insert task;
        
        //Asserting for the results
        System.assert(task != null);
        
        //update the same task
        task.Notify_Task_Creator__c = true;
        update task;
        
        //Asserting for the results
        System.assert(task != null);
        
        //Asserting for the results
        Integer invocations = Limits.getEmailInvocations();
        System.assert(invocations != null); */
        
        //stop test here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to to check if the Testimonial task is being created, then create a new Feed item 
     *           with user story. Added for CR-20140214-4512
     *
    **/
    @isTest(SeeAllData=true)
    static void testPostMemberImpactStory() {
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        //Get the Testimonial Record Type
        List<RecordType> recordTypes = [Select Id from RecordType 
                                        WHERE Name =: Constants.RECORD_TYPE_TASK_DEVELOPER_NAME_TESTIMONIALS 
                                        AND SObjectType = 'Task' AND ISActive = true];
        
        //Asserting for the results
        System.assert(recordTypes != null);
        System.assertEquals(1, recordTypes.size());
        
        //Get the Account Record Type
        List<RecordType> accRecordTypes = [SELECT Id FROM RecordType 
                                            WHERE DeveloperName =: Constants.RECORD_TYPE_ACCOUNT_DEVELOPER_NAME_US_EDUCATION 
                                            AND SObjectType = 'Account' AND ISActive = true];
        
        //Asserting for the results
        System.assert(accRecordTypes != null);
        System.assertEquals(1, accRecordTypes.size());
        
        
        //AccountId
        Account account = TestUtilities.CreateNewAccount(false);
        account.RecordTypeId = accRecordTypes[0].Id;
        insert account;
        System.assert(account != null);
        
        /*Modified By Dipesh Gupta -CR-20190524-13153 - Date-06/13/2019 */
        //create test data
        Task task = new Task(Subject = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY, 
                             Description = 'TestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTestingTesting',
                             Status = TaskTriggerHelper.STATUS_COMPLETED,
                             Event_Type__c = 'test',
                             RecordTypeId = recordTypes[0].Id, WhatId = account.Id);
        
        //Start testing here
        Test.startTest();
        
        //Enabling trigger again
        Util.byPassAllTriggers = false;
        
        //insert Task
        insert task;
        
        system.assertEquals(true, task.Id != null);
        
        //Check a New Feed Item is created related to the Task
        List<FeedItem> feedItems = [Select Id from FeedItem where ParentId != null AND ParentId =: task.WhatId];
        System.assertEquals(1, feedItems.size());
        
        //Stop testing
        Test.stopTest();
        
        /*Modified By Dipesh Gupta -CR-20190524-13153 - Date-06/13/2019 */
        //create test data
        task = new Task(Subject = Constants.TASK_SUBJECT_MEMBER_IMPACT_STORY, 
                             Status = TaskTriggerHelper.STATUS_COMPLETED,
                             Description = 'testing', Event_Type__c = 'test',
			     RecordTypeId = recordTypes[0].Id, WhatId = account.Id);
        insert task;
        
        //Check a New Feed Item is created related to the Task
        feedItems = [Select Id from FeedItem where ParentId != null AND ParentId =: task.WhatId];
        System.assertEquals(2, feedItems.size());
    }
    
    //Modified by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test "populateFieldsOnConsolidatedInvoice" method related functaionalities.
    **/
    static testmethod void testpopulateFieldsOnConsolidatedInvoice() { 
        
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.assert(p != null);
        
        //User (GMT Time Zone)
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                  LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                  UserName=Math.random() + '@test.com');

    //Running code in context of a "GMT" time zone user
        System.runAs(u) {
        
            //Account
            Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'Testing');
            insert a;
            System.assert(a != null);
            
            //List of consolidate invoice
            List<ConsolidatedInvoice__c> consolidatedInvoices = new List<ConsolidatedInvoice__c>([SELECT ID, Last_Follow_Up_Date__c,
                                                                                                  Last_Follow_Up_Note__c 
                                                                                                  FROM ConsolidatedInvoice__c 
                                                                                                  ORDER BY Name DESC LIMIT 1]);
            
            //Applying assert for the results
            if(consolidatedInvoices != null && consolidatedInvoices.size() > 0) {
                
                //Consolidated Invoice 
                ConsolidatedInvoice__c cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                Util.BypassAllTriggers = true;
                update cI;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Task record
                Task task_1 = new Task(Subject = 'testSubject 1', Status = TaskTriggerHelper.STATUS_COMPLETED, 
                                       //Notify_Task_Creator__c = false, 
                                       ActivityDate = System.today().addDays(-1),
                                       WhatId = cI.Id, Event_Type__c = 'test');
                
                //start test from here 
                Test.startTest();
            
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Insert
                insert task_1;
		system.assert(task_1.Id != null);
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                 
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertNotEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Consolidated Invoice 
                cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                
                //Disbling triggers
                Util.BypassAllTriggers = true;
                update cI;

                //Creating Account record
                Account account = TestUtilities.CreateNewAccount(true);
        
                //Create contact
                Contact contact = new Contact(LastName = 'TestingABC', AccountId = account.Id, Reference_Program_Status__c = 'testing', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
                insert contact;

                //List to hold the record's type 
                List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                                AND DeveloperName ='EAB_Initiating'];
                
                 Contact con = TestUtilities.CreateNewContact(True);
        
                //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
                //Opportunity
                Opportunity opp = TestUtilities.CreateNewOpportunity(false); 
                opp.recordTypeId =  recordTypes[0].Id;
                opp.Main_Contact__c = con.Id;
                opp.Sales_Pursuit_Products__c = 'APS';
                insert opp;

                //Hold SBQQ__Quote__c
                SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
                quote.SBQQ__Primary__c = true;
                quote.SBQQ__Opportunity2__c = opp.Id;
                insert quote;
                
                //Added By Subahsh garhwal  - 04/25/2018 - CR-20180205-11952
                 //List to insert Program records
                List<Program__c> programs = new List<Program__c>();
                programs.add(TestUtilities.CreateNewProgram(false));
                
                 //Add additional field values
                programs[0].Business_line__c = CPQConstants.PROGRAM_BUSINESS_LINE_CLN;
                programs[0].Large_Contract_Threshold__c =  17;
                
                 //Insert
                insert programs;
                
                  //List of Product
                 List<Product2> products = new List<Product2>();
        
                //Inserting Products 
                products.add(new Product2(Name = 'Consulting Product', Family = 'Consulting', Program__c = programs[0].Id,
                                  IsActive = true, ProductCode = 'ConsultingPRO',SBQQ__SortOrder__c = 5));
        
                //Insert
                insert products;
                
                
                //Adding quote lines 
                //List of quote line item to insert
                List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        
                //Add new Quote lines n list
                quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 100));
                quoteLines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = products[0].Id, SBQQ__NetPrice__c = 500));
                
                insert quoteLines;

                //Disbling triggers
                Util.BypassAllTriggers = true;

                opp.SBQQ__PrimaryQuote__c = quote.Id;
                update opp;

                Reference_Request__c referenceRequest = new Reference_Request__c();
                referenceRequest.Requesting_Contact__c = contact.Id;
                referenceRequest.Number_of_References_Needed__c = 8;
                referenceRequest.Source_Opportunity__c  = opp.Id;
                insert referenceRequest;

                Reference_Request_Contact__c referenceRequestContact = new Reference_Request_Contact__c();
                referenceRequestContact.Reference_Contact__c =  contact.Id;
                referenceRequestContact.Reference_Request__c = referenceRequest.Id;
                insert referenceRequestContact;

                //Bypassing Triggers so then test data can be created easily
                Util.byPassAllTriggers = false;

                //Update
                task_1.Status = 'Hold';
                task_1.Subject = TaskTriggerHelper.SUBJECT_FOR_REFERENCE_REQUEST;
                task_1.WhoId = contact.Id;
                task_1.whatId = referenceRequest.Id;
                update task_1;
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                task_1.whatId =opp.Id;
                update task_1;

                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Updating task status
                task_1.Status = 'In progress';
                update task_1;
                
                //stop test here
                Test.stopTest();
                
                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                
                //Disbling triggers
                Util.BypassAllTriggers = true;
                
                //Update
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                update task_1;
               
                //Querying fields values for task records
                ConsolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c FROM ConsolidatedInvoice__c
                                        WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
            }
        }        
  }
    
    //Added by - Abhinav Sharma - 07/13/2016 - CR-20150202-8648 - To refactor the existing code
    /** Description : Method to test "populateFieldsOnConsolidatedInvoice" method related functaionalities.
    **/
    static testmethod void testpopulateFieldsOnConsolidatedInvoice1() { 
         
        //Bypass Dupeblocker and triggers
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.IsTesting = true;
        
        // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.assert(p != null);
        
        //User (GMT Time Zone)
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                  LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                  UserName=Math.random() + '@test.com');

    //Running code in context of a "GMT" time zone user
        System.runAs(u) {
        
            //Account
            Account a = new Account(Name = 'testacc', Account_Formal_Name__c = 'Testing');
            insert a;
            System.assert(a != null);
            
            //List of consolidate invoice
            List<ConsolidatedInvoice__c> consolidatedInvoices = new List<ConsolidatedInvoice__c>([SELECT ID, Last_Follow_Up_Date__c,
                                                                                                  Last_Follow_Up_Note__c 
                                                                                                  FROM ConsolidatedInvoice__c 
                                                                                                  ORDER BY Name DESC LIMIT 1]);
            
            //Applying assert for the results
            if(consolidatedInvoices != null && consolidatedInvoices.size() > 0) {
                
                //Consolidated Invoice 
                ConsolidatedInvoice__c cI = consolidatedInvoices[0];
                cI.Last_Follow_Up_Date__c = null;
                cI.Last_Follow_Up_Note__c = null;
                Util.BypassAllTriggers = true;
                update cI;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //List of Tasks
                List<Task> tasks = [SELECT ID FROM Task 
                                    WHERE WhatId != null AND WhatId =: cI.Id];
                
                //Checking for the null and size value
                if(tasks != null && tasks.size() > 0)
                    delete tasks;
                
                //Task record
                Task task_1 = new Task(Subject = 'testSubject 1', Status = 'In progress', 
                                       //Notify_Task_Creator__c = false, 
                                       ActivityDate = System.today().addDays(1),
                                       WhatId = cI.Id, Event_Type__c = 'test');
                
                //start test from here 
                Test.startTest();
            
                //Enable triggers again
                Util.BypassAllTriggers = false;
                
                //Insert
                insert task_1;
                
                //Asserting for the results
                System.assert(task_1 != null);
                
                //Updateing task
                task_1.Status = TaskTriggerHelper.STATUS_COMPLETED;
                
                Util.BypassAllTriggers = true;
                update task_1;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Date__c);
                System.assertEquals(null, consolidatedInvoices[0].Last_Follow_Up_Note__c);
                
                //Stop test here
                Test.stopTest();
              
                
                Util.BypassAllTriggers = false;
                
                //Delete
                delete task_1;
                
                //Querying for the updated records
                consolidatedInvoices = [SELECT ID, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c 
                                            FROM ConsolidatedInvoice__c
                                            WHERE ID =: cI.Id];
                
                //Asserting for the results
                System.assert(consolidatedInvoices != null);
                System.assertEquals(1, consolidatedInvoices.size());
            }
        }        
  }
    
    /**
     * 
     * @description: CR-20170217-10703 - added to support a newly created Lookup Rollup Summary
     * 
     **/
    static testmethod void testTrigger() {
        // Force the dlrs_TaskTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Task());
    }
    /**
     * 
     *  @description    :   This method used to test updateFieldsOnDevActivity method
     *
     *  @args           :   
     *
     *  @return         :   void
     *
     *  @revision Log   :   V1.1 - Created - 07/06/2017 - Q2C Phase 2 - CR-20170403-10807
     * 
     **/
    static testmethod void testPrimaryProposalRequiredForTask() {

        //Enable triggers again
        Util.BypassAllTriggers = true;
        
        Program__c program = TestUtilities.CreateNewProgram(true);
        Product2 product = TestUtilities.createNewProduct(program.Id, true);
        
        //Creating Account record
        Account account = TestUtilities.CreateNewAccount(true);

        //Create Contract
        Contract StdContract = new Contract(AccountId = account.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 12);
        insert StdContract;

        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                        AND DeveloperName ='EAB_Initiating'];
        
        Contact con = TestUtilities.CreateNewContact(True);

        //Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
        //Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false);
        opp.SBQQ__AmendedContract__c = StdContract.Id;
        opp.recordTypeId =  recordTypes[0].Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        opp.Main_Contact__c = con.Id;
        insert opp;
        
        //Hold SBQQ__Quote__c
        SBQQ__Quote__c quote = TestUtilities.createNewSbqqQuote(false);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;
        
        util.BypassAllTriggers = true;
        SBQQ__QuoteLine__c quoteLine = TestUtilities.createNewQuoteLine(quote.Id, false);
        quoteLine.SBQQ__SegmentIndex__c = 1;
        quoteLine.Product_Category__c = 'Annual Fee';
        quoteLine.SBQQ__Product__c = product.Id;
        quoteLine.Program_Opportunity__c = opp.Id;
        quoteLine.Program_or_Component__c = 'PT';
        
        util.BypassAllTriggers = true;
        insert quoteLine;
        util.BypassAllTriggers = false;
        
        //Task record
        Task task_1 = new Task(Subject = 'testSubject 1', Status = 'In progress', 
                                       //Notify_Task_Creator__c = false, 
                                       ActivityDate = System.today().addDays(1),
                                       WhatId = opp.Id, Event_Type__c = 'test', Priority = 'Normal');

        //Testing start here 
        Test.startTest();

        //Enable triggers again
        Util.BypassAllTriggers = false;

        try {                

            //Insert
            insert task_1;
                 
            //Asserting for the results 
            System.assert(task_1 != null);

        }
        catch(Exception e) {

            String message = e.getMessage();
            system.assert(message.contains('Activity can\'t be saved on the opportunity, without the opportunity having an active primary proposal'), 'message=' + message);
        }

        //Testing stop here 
        Test.stopTest();
    }
    
    //test Class to cover the SFDC Change Fequest Functionality. 
    @isTest Static void SfdcChangeRequestTimeTracking() {
        
        //Bypass All the Triggers
        Util.ByPassAllTriggers = true;
        Util.ByPassDLRSForTest = true;
        
        // Modified - Dipesh Gupta - 2/27/2020 - CR-20191216-13564 Start Here 
        //Query on Profile
        Profile profile1 = [Select Id, Name From Profile Where name = 'System Administrator' LIMIT 1];
        
        // hold User
        User usr = new User(LastName = 'test',
                           FirstName='testing',
                           Alias = 'test',
                           Email = 'test@asdf.com',
                           Username = 'testing@asdf.com',
                           ProfileId = profile1.id,
                           IsActive = true,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        //Insert User
        insert usr;
        
        List<user> userList = [Select Id From user];
        System.assert(userList[0].Id != null);
        System.assert(userList.size() > 0);
        
        // IS_Environment__c 1
        IS_Environment__c is_environment = new IS_Environment__c();
        is_environment.Name = 'Dev2 - Active';
        is_environment.Environment_Type__c = 'Development';
        is_environment.Status__c = 'Active';
        insert is_environment;
        
        List<IS_Environment__c> devEnv = [Select Id From IS_Environment__c];
        System.assert(devEnv[0].Id != null);
        System.assert(devEnv.size() > 0);
        
        // IS_Environment__c 2
        IS_Environment__c is_environment2 = new IS_Environment__c();
        is_environment2.Name = 'Full2 - Active';
        is_environment2.Environment_Type__c = 'UAT';
        is_environment2.Status__c = 'Active';
        insert is_environment2;
        
        List<IS_Environment__c> devEnv2= [Select Id From IS_Environment__c];
        System.assert(devEnv2[1].Id != null);
        System.assert(devEnv.size() > 0);
        
        //Creating the Release, CR, Modification, CR action Item
        SFDC_Release__c release = new SFDC_Release__c(Name='Test1', Environment_Manager__c = usr.Id ,Release_Manager__c = usr.Id ,Status__c = 'Scheduled - Planned', Dev_Sandbox__c = devEnv[0].Id, QA_Sandbox__c = devEnv2[1].Id, UAT_Sandbox__c = devEnv2[1].Id, Release_level__c = 'L2');
        insert release;
        
        //Creaating the CR Records under the Release
        SFDC_Change_Request__c cR = new SFDC_Change_Request__c(Title__c = 'Test Change Request',
                                                               Request_Description__c = 'Test',
                                                               Business_Justification__c = 'Test',
                                                               Release__c = release.Id);
        insert cR;
        
        //Creating the Component Rcecords
        IS_System_Component__c component = new IS_System_Component__c(Name = 'will auto-populate',
                                           Object_Label__c = 'Account',Object_API_Name__c = 'Account',
                                           Object_Type__c = 'Object', SOX_Object__c = TRUE);
        insert component;
        
        //Record type Query to get the Id
        List<RecordType> rtypes = [Select Id From RecordType where SObjectType = 'IS_System_Modification__c' AND DeveloperName = 'Complex'];
        
        //Creating the Modification Records 
        IS_System_Modification__c modification = new IS_System_Modification__c(Change_Request__c = cR.Id,
                                            IS_System_Component__c = component.Id,Type_Of_Modification__c = 'Modify',
                                            SOX_Object__c = FALSE, RecordTypeId = rtypes[0].Id);
        insert modification;
        
        //Clearing the List
        rtypes.clear();
        
        //Query on the Record Type for CR Action Items
        rtypes = [Select Id From RecordType where SObjectType = 'CR_Action_Item__c' AND DeveloperName = 'Deployment_Plan_Step'];
        
        //Creating the CR Action Item under the Modification
        List<CR_Action_Item__c> actionItems = new List<CR_Action_Item__c>();
            
        actionItems.add(new CR_Action_Item__c(IS_System_Modification__c = modification.Id, Time_Estimate_Mins__c = 20,
                                                              Timing__c = 'Post-Deployment', Type__c = 'Configuration', RecordTypeId = rtypes[0].Id));
        
        actionItems.add(new CR_Action_Item__c(IS_System_Modification__c = modification.Id, Time_Estimate_Mins__c = 10,
                                                              Timing__c = 'Pre-Deployment', Type__c = 'Data', RecordTypeId = rtypes[0].Id));
        
        actionItems.add(new CR_Action_Item__c(IS_System_Modification__c = modification.Id, Time_Estimate_Mins__c = 25,
                                                              Timing__c = 'Pre-Validation', Type__c = 'Code', RecordTypeId = rtypes[0].Id));
        
        actionItems.add(new CR_Action_Item__c(IS_System_Modification__c = modification.Id, Time_Estimate_Mins__c = 90,
                                                              Timing__c = 'Other', Type__c = 'Other', RecordTypeId = rtypes[0].Id));
        actionItems.add(new CR_Action_Item__c(IS_System_Modification__c = modification.Id, Time_Estimate_Mins__c = 0,
                                                              Timing__c = 'Other', Type__c = 'Other', RecordTypeId = rtypes[0].Id));
        
        insert actionItems;
        
        Util.BypassAllTriggers = false;
        Util.ByPassDLRSForTest = false;
        
        List<SFDC_Release__c> sfdcRelease = [Select Id From SFDC_Release__c Where Id =: release.Id];
        List<SFDC_Change_Request__c> changeRequest = [Select Id From SFDC_Change_Request__c where id =: CR.Id];
        
        system.assert(changeRequest != null);
        
        //Inserting Task under the CR
        List<Task> tsks = new List<Task>();
        
        tsks.add(new Task(WhatId =  changeRequest[0].Id, Duration_in_Hours__c = 1.5, Type = 'Meetings/Communications'));
        tsks.add(new Task(WhatId =  changeRequest[0].Id, Duration_in_Hours__c = 1, Type = 'Meetings/Communications'));
        tsks.add(new Task(WhatId =  changeRequest[0].Id, Duration_in_Hours__c = 1.5, Type = 'UAT Support'));
        tsks.add(new Task(WhatId =  changeRequest[0].Id, Duration_in_Hours__c = 1.5, Type = 'UAT Support'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 1.5, Type = 'Project Management'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 1, Type = 'Deployment Execution'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 2.5, Type = 'Deployment Preparation'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 3.5, Type = 'Regression Testing'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 0.5, Type = 'Post Project Closure Support'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 2.5, Type = 'Requirements Gathering'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 1.0, Type = 'Meetings/Communications'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 1.5, Type = 'Communications'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 2.0, Type = 'UAT Support'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Duration_in_Hours__c = 1.5, Type = 'Analysis/Design'));
        tsks.add(new Task(WhatId =  sfdcRelease[0].Id, Type = 'Analysis/Design'));
        
        system.assert(tsks.size() > 0);
        
        insert tsks;
        
        ProgramTriggerHelper.CHECK_TRIGGER_EXCEPTION = true;
        
        try {
        
        //Updating one Task     
        update tsks[0];
        }Catch(Exception e) {
            
        }
    }
     //Test the functionality createProductLeadsForTaskContact
    static testmethod void test_CreateProductLeadsForTaskContact_CaseSensitiveTesting() {
        
        String progAcronym = 'EDAF';
        String progAcronym_BHAN = 'BHAN';
        
        /*** START DATA SETUP ***/
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);
        con.Location__c = 'TestClass @@@';
        Util.BypassAllTriggers = true;
        update con; 
		
        Util.BypassAllTriggers = false;
        //Create a new Program and set as Marketable to meet Lookup filter requirements
        List<Program__c> progs = new List<Program__c>();
        Program__c testProg = TestUtilities.CreateNewProgram(false);
        testProg.Program_Acronym__c = progAcronym;
        testProg.Marketable__c = true;
        progs.add(testProg);
        
        Program__c testProg_BHAN = TestUtilities.CreateNewProgram(false);
        testProg_BHAN.Program_Acronym__c = progAcronym_BHAN;
        testProg_BHAN.Marketable__c = true;
        progs.add(testProg_BHAN);
        insert progs;
        
        system.assertEquals(2, progs.size());
        
        //create a new product lead
        Product_Lead__c pl_BHAN = new Product_Lead__c(Contact__c = con.Id,
                                                Program__c = testProg_BHAN.Id,
                                                Stage__c = 'Inquiry');
        insert pl_BHAN;
        
        system.assertEquals(true, pl_BHAN.Id != null);
        
        //List to hold the Tasks.        
        List<Task> tasks = new List<Task>();   
        
        Test.startTest();
        
        
        //Task list.
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Email-test1',
                         SalesLoft_External_ID__c = progAcronym.toLowerCase(), SalesLoft1__SalesLoft_Step_Day__c = 1));
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Email-test2', 
                         SalesLoft_External_ID__c = progAcronym.toLowerCase(), SalesLoft1__SalesLoft_Step_Day__c = 1));
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Call-test3', 
                         SalesLoft_External_ID__c = progAcronym.toLowerCase(), SalesLoft1__SalesLoft_Step_Day__c = 2));
        insert tasks;
        
        //Test stop test.
        Test.stopTest();
        
        List<Product_Lead__c> programLeads = [Select Id, Stage__c, Program__r.Program_Acronym__c From Product_Lead__c Where contact__c =: con.Id ];
        
        System.assertEquals(2, programLeads.size());

        Product_Lead__c pl_EDAF;
        
        for (Product_Lead__c pl : programLeads) {
            if (pl.Program__r.Program_Acronym__c == progAcronym_BHAN) {
                system.assertEquals('Inquiry', pl.Stage__c);
            }
            else if (pl.Program__r.Program_Acronym__c == progAcronym) {
                pl_EDAF = pl;
                system.assertEquals('TGL', pl.Stage__c);
            }
        }
                  
        //List to hold the query results.
        List<Task> newInsertedTasks = [SELECT Id, WhatId, Event_Type__c, Event_Purpose__c,  Product_Lead__c FROM Task 
                                       WHERE Id IN : tasks Order by CreatedDate];
        
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[0].WhatId);
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[0].Product_Lead__c);
        /*system.assertEquals('Email', newInsertedTasks[0].Event_Type__c);
        system.assertEquals('Initial', newInsertedTasks[0].Event_Purpose__c);*/
                  
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[1].WhatId);
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[1].Product_Lead__c);
        /*system.assertEquals('Phone Call', newInsertedTasks[1].Event_Type__c);
        system.assertEquals('Initial', newInsertedTasks[1].Event_Purpose__c);*/
                  
        /*system.assertEquals('Other', newInsertedTasks[2].Event_Type__c);
        system.assertEquals('Follow Up', newInsertedTasks[2].Event_Purpose__c);*/
                  

    }
    
    //Test the functionality createProductLeadsForTaskContact
    static testmethod void test_CreateProductLeadsForTaskContact() {
        
        String progAcronym = 'EDAF';
        String progAcronym_BHAN = 'BHAN';
        
        /*** START DATA SETUP ***/
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);
        con.Location__c = 'TestClass @@@';
        Util.BypassAllTriggers = true;
        update con; 
		
        Util.BypassAllTriggers = false;
        //Create a new Program and set as Marketable to meet Lookup filter requirements
        List<Program__c> progs = new List<Program__c>();
        Program__c testProg = TestUtilities.CreateNewProgram(false);
        testProg.Program_Acronym__c = progAcronym;
        testProg.Marketable__c = true;
        progs.add(testProg);
        
        Program__c testProg_BHAN = TestUtilities.CreateNewProgram(false);
        testProg_BHAN.Program_Acronym__c = progAcronym_BHAN;
        testProg_BHAN.Marketable__c = true;
        progs.add(testProg_BHAN);
        insert progs;
        
        system.assertEquals(2, progs.size());
        
        //create a new product lead
        Product_Lead__c pl_BHAN = new Product_Lead__c(Contact__c = con.Id,
                                                Program__c = testProg_BHAN.Id,
                                                Stage__c = 'Inquiry');
        insert pl_BHAN;
        
        system.assertEquals(true, pl_BHAN.Id != null);
        
        //List to hold the Tasks.        
        List<Task> tasks = new List<Task>();   
        
        Test.startTest();
        
        //Task list.
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Email-test1',
                         SalesLoft_External_ID__c = progAcronym, SalesLoft1__SalesLoft_Step_Day__c = 1));
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Email-test2', 
                         SalesLoft_External_ID__c = progAcronym, SalesLoft1__SalesLoft_Step_Day__c = 1));
        tasks.add(new Task(WhoId = con.Id, whatId = pl_BHAN.Id,
                         Subject = 'Call-test3', 
                         SalesLoft_External_ID__c = progAcronym, SalesLoft1__SalesLoft_Step_Day__c = 2));
        insert tasks;
        
        //Test stop test.
        Test.stopTest();
        
        List<Product_Lead__c> programLeads = [Select Id, Stage__c, Program__r.Program_Acronym__c From Product_Lead__c Where contact__c =: con.Id ];
        
        System.assertEquals(2, programLeads.size());

        Product_Lead__c pl_EDAF;
        
        for (Product_Lead__c pl : programLeads) {
            if (pl.Program__r.Program_Acronym__c == progAcronym_BHAN) {
                system.assertEquals('Inquiry', pl.Stage__c);
            }
            else if (pl.Program__r.Program_Acronym__c == progAcronym) {
                pl_EDAF = pl;
                system.assertEquals('TGL', pl.Stage__c);
            }
        }
                  
        //List to hold the query results.
        List<Task> newInsertedTasks = [SELECT Id, WhatId, Event_Type__c, Event_Purpose__c,  Product_Lead__c FROM Task 
                                       WHERE Id IN : tasks Order by CreatedDate];
        
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[0].WhatId);
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[0].Product_Lead__c);
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[1].WhatId);
        system.assertEquals(pl_EDAF.Id, newInsertedTasks[1].Product_Lead__c);
               

    }
    
    
    // Added By - Dipesh Gupta - 12/30/2019 -- CR-20191023-13455 -- added new method "test_UpdateSalesInvoice"
    // Modified By - Nikita Kumari - 09/30/2021 - CR-20210910-15426 - Added SeeAllData=true for method
    //Test the functionality UpdateSalesInvoice
    @IsTest(SeeAllData=true)
    static void test_UpdateSalesInvoice(){
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
        System.runAs(user1) {
            
            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            //Query for our currency from our setup data
            c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c = :testCompany.Id];
            
            //Grab the General Ledger Account created
            c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];
            
            //Grab the Dimension 1 record from our Test Data Setup
            c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];
            
            //Create the Product needed for the line items
            Program__c prog1 = TestUtilities.CreateNewProgram(true);
            
            //Grab the Product which is created as part of the Program creation process
            Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];
        
            //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            c2g__codaInvoice__c salesInvoice2 = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
            
            //Bypassing the triggers.
            Util.ByPassAllTriggers = true; 
            insert salesInvoice;
            insert salesInvoice2;
            util.ByPassAllTriggers = false;
            
            Task t = TestUtilities.createTask(false,salesInvoice.Id);
            t.Grade__c = 'A+';
            t.CallDisposition = 'Pass';
            t.Status__c = 'Hold';
            t.Next_Steps__c = 'Nothing';
            t.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            t.CreatedDate = system.today().addDays(-1);
            
            //Inserting taks
            insert t;
            
            //Query over sales Invoice to get the updated values.
            c2g__codaInvoice__c updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice.Id LIMIT 1]; 
            
            System.assertEquals(t.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
            
            //Updating values of existing task 
            t.Subject = 'rrr';
            t.Grade__c = 'A';
            t.CallDisposition = 'RRRRR';
            t.Next_Steps__c = 'gggg';
            t.WhatId = salesInvoice2.Id;
            
            //Start our Test
            Test.startTest();
            update t;
            //Stop our Test	
            Test.stopTest();
                        
            updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice2.Id LIMIT 1]; 
            
            System.assertEquals(t.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
            
            Task t1 = TestUtilities.createTask(false,salesInvoice2.Id);
            t1.Grade__c = 'A+';
            t1.CallDisposition = 'Pass';
            t1.Status__c = 'Hold';
            t1.Next_Steps__c = 'Nothing';
            t1.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            
            //Inserting taks
            insert t1;
            
            updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice2.Id LIMIT 1]; 
            
            System.assertEquals(t1.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t1.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t1.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t1.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t1.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t1.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
            
            //Deleting task
            delete t1;
            
            updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice2.Id LIMIT 1]; 
            
            System.assertEquals(t.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
            
            
            Task t3 = TestUtilities.createTask(false,salesInvoice2.Id);
            t3.Subject ='KKKKKK';
            t3.Grade__c = 'B+';
            t3.CallDisposition = 'Fail';
            t3.Status__c = 'Hold';
            t3.Next_Steps__c = 'Nothing';
            t3.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            
            //Inserting taks
            insert t3;
            
            updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice2.Id LIMIT 1]; 
            
            System.assertEquals(t3.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t3.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t3.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t3.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t3.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t3.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
            t3.RecordTypeId = Util.RecordTypeId('Task', 'General');
            update t3;
            
            //System.assert(false,t3);
            updatedSalesInvoice = [SELECT Id, Last_Follow_Up_Date__c, Last_Follow_Up_Note__c, Grade__c, Grading_Notes__c, Follow_Up_Status__c, Follow_Up_Status_Notes__c FROM c2g__codaInvoice__c WHERE Id =: salesInvoice2.Id LIMIT 1]; 
            
            System.assertEquals(t.ActivityDate, updatedSalesInvoice.Last_Follow_Up_Date__c);
            System.assertEquals(t.Subject, updatedSalesInvoice.Last_Follow_Up_Note__c);
            System.assertEquals(t.Grade__c, updatedSalesInvoice.Grade__c);
            System.assertEquals(t.CallDisposition, updatedSalesInvoice.Grading_Notes__c);
            System.assertEquals(t.Status__c, updatedSalesInvoice.Follow_Up_Status__c);
            System.assertEquals(t.Next_Steps__c, updatedSalesInvoice.Follow_Up_Status_Notes__c);
            
        }
    }
    
     static testMethod void testCreateMembershipForContactTaggedInProductLead()
    {
        
        String progAcronym = 'EDAF';
        String progAcronym_BHAN = 'BHAN';
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);

        //Create a new Program and set as Marketable to meet Lookup filter requirements
        List<Program__c> progs = new List<Program__c>();
        Program__c testProg = TestUtilities.CreateNewProgram(false);
        testProg.Program_Acronym__c = progAcronym;
        testProg.Marketable__c = true;
        progs.add(testProg);
        
        Program__c testProg_BHAN = TestUtilities.CreateNewProgram(false);
        testProg_BHAN.Program_Acronym__c = progAcronym_BHAN;
        testProg_BHAN.Marketable__c = true;
        progs.add(testProg_BHAN);
        insert progs;
        
        //create a new product lead
        Product_Lead__c pl_BHAN = new Product_Lead__c(Contact__c = con.Id,
                                                Program__c = testProg_BHAN.Id,
                                                Stage__c = 'Inquiry');
        insert pl_BHAN;
        
        system.assert(true, pl_BHAN.Id != null);
        
        Util.ByPassAllTriggers = true;
        
        Campaign cmp = new Campaign(Name = 'BHCNG_2019-11_CONNECTED', r_Submitted_by__c = con.Id);
        insert cmp;
        
        Util.ByPassAllTriggers = false;
        
        List<Campaign> cmpaigns = [Select Id, Name From Campaign where Id =: cmp.Id];
        //System.assert(false, cmpaigns[0].Name);
        
        test.startTest();
        
        Task tsk = new Task();
        tsk.subject = 'call';
        tsk.SalesLoft1__SalesLoft_Cadence_Name__c = 'BHCNG_2019-11_CONNECTED+Conference';
        tsk.whatId = pl_BHAN.Id;
        tsk.whoId = con.Id;
        insert tsk;
        
        system.assert(true, tsk != null);
        system.assertEquals(Schema.Product_Lead__c.SobjectType, tsk.whatId.getSObjectType());
        
        test.stopTest();
        
        List<CampaignMember> cmpMems = [SELECT Id FROM CampaignMember WHERE ContactId =:con.Id];
        system.assertEquals(true, cmpMems.size() == 1);  
    }
    
    /*static testMethod void testCreateCampMemWIthExistingCampaign()
    {

        String progAcronym = 'EDAF';
        String progAcronym_BHAN = 'BHAN';
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);

        //Create a new Program and set as Marketable to meet Lookup filter requirements
        List<Program__c> progs = new List<Program__c>();
        Program__c testProg = TestUtilities.CreateNewProgram(false);
        testProg.Program_Acronym__c = progAcronym;
        testProg.Marketable__c = true;
        progs.add(testProg);
        
        Program__c testProg_BHAN = TestUtilities.CreateNewProgram(false);
        testProg_BHAN.Program_Acronym__c = progAcronym_BHAN;
        testProg_BHAN.Marketable__c = true;
        progs.add(testProg_BHAN);
        insert progs;
        
        //create a new product lead
        Product_Lead__c pl_BHAN = new Product_Lead__c(Contact__c = con.Id,
                                                Program__c = testProg_BHAN.Id,
                                                Stage__c = 'Inquiry');
        insert pl_BHAN;
        
        system.assert(true, pl_BHAN.Id != null);
        
        
        Campaign cmp = new Campaign(Name = 'Test Campaign', r_Submitted_by__c = con.Id);
        insert cmp;
        system.assert(cmp != null);
        CampaignMember cmpMem = new CampaignMember();
        cmpMem.ContactId = con.Id;
        cmpMem.CampaignId = cmp.Id;
        Insert cmpMem;
        
        test.startTest();
        
        Task tsk = new Task();
        tsk.subject = 'call';
        tsk.SalesLoft1__SalesLoft_Cadence_Name__c = 'Test+123';
        tsk.whatId = pl_BHAN.Id;
        tsk.whoId = con.Id;
        insert tsk;
        
        system.assert(true, tsk != null);
        system.assertEquals(Schema.Product_Lead__c.SobjectType, tsk.whatId.getSObjectType());
        
        test.stopTest();
        
    }*/
    
    //Test class for the method updateContactProtocoledField
    static testMethod void testupdateContactProtocoledField() {
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        //Get Record Type
        //Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Task PT Marketing');
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
        //Modified by Mahendra Swarnkar - 04/30/2020 - CR-20200129-13676 - Start Here
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        Contact con = TestUtilities.CreateNewContact(true);
        
        Task tsk = new Task();
        tsk.RecordTypeId = taskPTMarketingRecordType;
        tsk.subject = 'call';
        tsk.whatId = testAccount.Id;
        tsk.whoId = con.Id;
        tsk.Event_Type__c = 'In Person';
        tsk.Event_Purpose__c = 'Initial';
        tsk.Status = 'Not Started';
        tsk.ActivityDate = System.today();
        tsk.Cancelled_Did_Not_Occur__c = true;
        insert tsk;
        Util.BypassAllTriggers = false;
        
        //Added by - Chirag soni - CR-20210910-15426 - 10/29/2021 - Code coverage increase. - from here
        Test.startTest();
        
        tsk = [SELECT Id , Cancelled_Did_Not_Occur__c FROM Task WHERE Id = :tsk.Id];
        tsk.Cancelled_Did_Not_Occur__c = false;
        
        update tsk;
        
        Test.stopTest();
        
        Contact contact = [SELECT Id, Protocoled_Sales__c FROM Contact WHERE Id = :con.Id];
        
        System.assertEquals(true, contact.Protocoled_Sales__c);
        
        //Added by - Chirag soni - CR-20210910-15426 - 10/29/2021 - Code coverage increase. - till here
        
    }
    //Modified by   - 05/25/2020 - L2 Release - May 2020 - Method calling commented methods in trigger helper.
    // Modified By - Nikita Kumari - 09/30/2021 -CR-20210910-15426 - Added SeeAllData=true for method
    @IsTest(SeeAllData=true)
    static void uncalledFunctions(){
        
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Create a user for running the process
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = testUtilities.CreateNewUser(p, true);
        user1.LastName = 'Ireland';
        update user1;
        
        // Create common test data
        TestUtilities.setUpFinancialForceData(true, User1.Id);
        
        System.runAs(user1) {
            
            //Create the Account needed later for Sales Invoice
            Account testAcc = TestUtilities.CreateNewAccount(true);
            testAcc.CurrencyIsoCode = 'USD';
            testAcc.c2g__CODAAccountTradingCurrency__c = 'USD';
            update testAcc;
            
            //Grab our Company due to Test Class deployment error
            c2g__codaCompany__c testCompany = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'ApexTestCompany'];
            
            //Query for our currency from our setup data
            c2g__codaAccountingCurrency__c testCurrency = [SELECT Id, Name, c2g__OwnerCompany__c FROM c2g__codaAccountingCurrency__c WHERE Name = 'USD' AND c2g__OwnerCompany__c = :testCompany.Id];
            
            //Grab the General Ledger Account created
            c2g__codaGeneralLedgerAccount__c gla1 = [SELECT Id, c2g__ReportingCode__c FROM c2g__codaGeneralLedgerAccount__c WHERE c2g__ReportingCode__c = 'xyz1'];
            
            //Grab the Dimension 1 record from our Test Data Setup
            c2g__codaDimension1__c dim1 = [SELECT Id, c2g__ExternalId__c FROM c2g__codaDimension1__c WHERE c2g__ExternalId__c = '13'];
            
            //Create the Product needed for the line items
            Program__c prog1 = TestUtilities.CreateNewProgram(true);
            
            //Grab the Product which is created as part of the Program creation process
            Product2 product1 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'HCAB'];
        
         //Create our test Sales Invoice record we'll work with
            c2g__codaInvoice__c salesInvoice = new c2g__codaInvoice__c(
                c2g__Account__c = testAcc.Id,
                c2g__DueDate__c = System.today(),
                c2g__InvoiceCurrency__c = testCurrency.Id,
                c2g__InvoiceDate__c = System.Today(),
                c2g__InvoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = True,
                c2g__Dimension1__c = dim1.Id,
                c2g__InvoiceDescription__c = 'Test List 1'
            );
        insert salesInvoice;
            
            Contact con = TestUtilities.CreateNewContact(true);
            
            
            Map<Id, List<Task>> mapOfContactTask = new Map<Id, List<Task>>();
        List<Task> tasks = new List<Task>();
        Task t = TestUtilities.createTask(false,salesInvoice.Id);
            t.Grade__c = 'A+';
            t.CallDisposition = 'Pass';
            t.Status__c = 'Hold';
            t.Next_Steps__c = 'Nothing';
            t.RecordTypeId = Util.RecordTypeId('Task', 'Finance');
            t.CreatedDate = system.today().addDays(-1);
            t.SalesLoft_External_ID__c = null;
        	t.SalesLoft1__SalesLoft_Email_Template_Title__c = null;
        	t.SalesLoft1__SalesLoft_Step_Day__c = 1;
        	//t.SalesLoft1__SalesLoft_Type__c = 'Email';
        
        	tasks.add(t);
            
            mapOfContactTask.put(con.Id, tasks);
            
            //Inserting taks
            insert tasks;
            
     
            
        TaskTriggerHelper.saleloftTaskNotRelatedToProductLead(tasks);
            
        TaskTriggerHelper.saleloftTaskRelatedToMembership(mapOfContactTask);
    }
    }
    
     //Added by - Chirag soni - CR-20210910-15426 - 10/29/2021 - Code coverage increase. 
    static testMethod void unitTestupdateFieldsOnDevActivity(){
        
        //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //create change request
        SFDC_Change_Request__c cR = new SFDC_Change_Request__c(Title__c = 'Test Change Request',
                                                               Request_Description__c = 'Test',
                                                               Business_Justification__c = 'Test');
        insert cR;
        
        //Get Record Type
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
      
        // create contact 
        Contact con = TestUtilities.CreateNewContact(true);
        
        Task tsk = new Task();
        tsk.RecordTypeId = taskPTMarketingRecordType;
        tsk.subject = 'call';
        tsk.whatId = cR.Id;
        tsk.Type = 'Regression Testing';
        tsk.Duration_in_Hours__c = 2.00;
        tsk.whoId = con.Id;
        tsk.Event_Type__c = 'In Person';
        tsk.Event_Purpose__c = 'Initial';
        tsk.Status = 'Not Started';
        tsk.ActivityDate = Date.today();
        tsk.Cancelled_Did_Not_Occur__c = true;
        insert tsk;
        
        
        SFDC_Request_Comment__c reqCmt = new SFDC_Request_Comment__c(
            Activity_Date__c = Date.today(),
            Time__c = 2.00,
            Comment__c = 'Testing',
            SFDC_Change_Request__c = cR.Id,
            Activity_Type__c = 'QA',
            Task_ID__c = tsk.Id
        );
        
        insert reqCmt;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        tsk = [SELECT Id, Description FROM Task WHERE Id = :tsk.Id];
        tsk.Description = 'Testing update fields on DevActivity';
        update tsk;
        
        Test.stopTest();
        reqCmt = [SELECT Id, Activity_Date__c, Activity_Type__c, Comment__c, Time__c, Task_ID__c
                                                       FROM SFDC_Request_Comment__c 
                                                       WHERE Task_ID__c = :tsk.Id];
        
        System.assertEquals('Testing update fields on DevActivity', reqCmt.Comment__c);
        System.assertEquals(Date.today(), reqCmt.Activity_Date__c);
        System.assertEquals('Regression Testing', reqCmt.Activity_Type__c);
        System.assertEquals(2.00, reqCmt.Time__c);
            
    }
    
     //Added by - Chirag soni - CR-20210910-15426 - 10/29/2021 - Code coverage increase.
     static testmethod void testUpdateNameAndRRStatus(){
        
         //Bypass Triggers
        Util.BypassAllTriggers = true;
        
        //Get Record Type
        Id taskPTMarketingRecordType = Util.RecordTypeId('Task', 'Sales Outreach');
        
        //Create an Institution and Contact
        Account testAccount = TestUtilities.CreateNewAccount(true);
        
        //Create contact
        Contact con = new Contact(LastName = 'TestingABC', AccountId = testAccount.Id, Reference_Program_Status__c = 'testing', Email = 'Test'+Math.random()+'@eab.com', Title = 'Test', Phone = '614-555-8855');
        insert con;
        
        //List to hold the record's type 
        List<RecordType> recordTypes = [Select Id, Name from RecordType Where SobjectType = 'Opportunity' AND IsActive = true
                                        AND DeveloperName ='EAB_Initiating'];
        
        //Opportunity
        Opportunity opp = TestUtilities.CreateNewOpportunity(false); 
        opp.recordTypeId =  recordTypes[0].Id;
        opp.Main_Contact__c = con.Id;
        opp.Sales_Pursuit_Products__c = 'APS';
        insert opp;
        
        Task tsk = new Task();
        tsk.RecordTypeId = taskPTMarketingRecordType;
        tsk.subject = 'Schedule & Perform the Reference Call';
        tsk.whatId = opp.Id;
        tsk.whoId = con.Id;
        tsk.Event_Type__c = 'In Person';
        tsk.Event_Purpose__c = 'Initial';
        tsk.Status = 'Not Started';
        tsk.ActivityDate = System.today();
        tsk.Cancelled_Did_Not_Occur__c = true;
        insert tsk;
        
        Reference_Request__c referenceRequest = new Reference_Request__c();
        referenceRequest.Requesting_Contact__c = con.Id;
        referenceRequest.Number_of_References_Needed__c = 8;
        referenceRequest.Source_Opportunity__c  = opp.Id;
        
        insert referenceRequest;
        
        Reference_Request_Contact__c referenceRequestContact = new Reference_Request_Contact__c();
        referenceRequestContact.Reference_Contact__c =  con.Id;
        referenceRequestContact.Reference_Request__c = referenceRequest.Id;
        insert referenceRequestContact;
        
        Util.BypassAllTriggers = false;
        
        Test.startTest();
        
        tsk = [SELECT Id, Status FROM Task WHERE Id = :tsk.id];
        tsk.Status = 'Completed';
        
        update tsk;
        
        Test.stopTest();
        
        referenceRequest = [SELECT Id, Request_Status__c FROM Reference_Request__c WHERE Requesting_Contact__c =:con.Id];
        System.assertEquals('Completed', referenceRequest.Request_Status__c);

    }
}