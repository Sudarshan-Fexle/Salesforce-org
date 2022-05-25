/**
 * Purpose            :    Test class for CaseCommentTriggerHelper
 *
 * Created By         :    Abhishek Mishra
 *
 * Current Version    :    V1.0
 *
 * Revision Log       :    V1.0 - Abhishek Mishra - CR-20211005-15489 - 07/09/2021
 **/
@isTest(seeAllData=false)
private class Test_CaseCommentTriggerHelper
{
   /**
    * Purpose         :   Test class for CaseCommentTriggerHelper
    * 
    * Created By       :  Abhishek Mishra
    * 
    * Created Date    :   07/09/2021 
    * 
    * Revision Log    :   v_1.0 - Created - Abhishek Mishra - CR-20211005-15489 - 07/09/2021 - Increase Code Coverage
    * 
    **/
    @isTest static void testpopulateCaseCommentNotify()
    {
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        Util.isTest(true);
        
        //create account 
        Account acct_1 = testUtilities.CreateNewAccount(true);
        
        //List to hold the Contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestUtilities.CreateNewContact(acct_1, false));
        contacts.add(TestUtilities.CreateNewContact(acct_1, false));
        contacts.add(TestUtilities.CreateNewContact(acct_1, false));
        insert contacts;
        
        //Inserting Project Records
        Project__c project = TestUtilities.createProject(true);
        
        //List of Member Support
        List<Site_Issue__c> siteIssues = new List<Site_Issue__c>();        
        siteIssues.add(TestUtilities.createSiteIssue(project.Id, false));
        siteIssues.add(TestUtilities.createSiteIssue(project.Id, false));
        siteIssues[0].Visible_in_Portal__c = true;
        siteIssues[1].Visible_in_Portal__c = true;
        insert siteIssues;
        
        Util.byPassAllTriggers = false;
        
        Id rcrdTypeId = Util.RecordTypeId('Case', 'eTech Support');
        
        Test.startTest();
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
        //Create a sample case record to insert and test case trigger
        cases.add(new Case(RecordTypeId = rcrdTypeId,Origin = 'Email', Subject = 'Webhelp Test2',Member_Facing_Resolution_Summary__c = 'test case 1',
                           SuppliedEmail = 'Test1@Test.com',Description = 'Test1',
                           Status = 'Closed',Case_Category__c = 'Website Issues',
                           Member_Support_Ticket__c = siteIssues[0].Id,
                           Resolution__c = 'Question Answered',ContactId = contacts[0].Id));
        
        cases.add(new Case(RecordTypeId = rcrdTypeId,Origin = 'Email', Subject = 'Webhelp Test2',Member_Facing_Resolution_Summary__c = 'test case 2',
                           SuppliedEmail = 'Test2@Test.com',Description = 'Test2',
                           Status = 'Closed',Case_Category__c = 'Website Issues',
                           Member_Support_Ticket__c = siteIssues[0].Id,
                           Resolution__c = 'Question Answered',ContactId = contacts[1].Id));
        
        cases.add(new Case(RecordTypeId = rcrdTypeId,Origin = 'Email', Subject = 'Webhelp Test1', Status = 'Closed',
                           SuppliedEmail = 'Test3@Test.com',Description = 'Test3',
                           Member_Facing_Resolution_Summary__c = 'test case 3',
                           Resolution__c = 'Question Answered',
                           Member_Support_Ticket__c = siteIssues[1].Id,
                           Case_Category__c = 'Website Feature Request',ContactId = contacts[2].Id));
        
        insert cases;
        
        //List to hold case comments
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments.add(TestUtilities.createNewCaseComment(cases[0], false));
        caseComments.add(TestUtilities.createNewCaseComment(cases[1], false));
        caseComments.add(TestUtilities.createNewCaseComment(cases[2], false));
        insert caseComments;
        
        caseComments[0].CommentBody = 'Changed the Description 1';
        caseComments[1].IsPublished  = false;
        
        //delete condition
        delete caseComments[2];
        
        Test.stopTest(); 
        
        update caseComments[0];
        update caseComments[1];
        
        //Fetching Site Issues Records
        siteIssues = [Select Id, Latest_Public_Case_Comment__c From Site_Issue__c Order By Site_Issue_Short_Description__c ASC];
        System.assert(siteIssues.size() == 2);
        System.assertEquals(null, siteIssues[0].Latest_Public_Case_Comment__c);
        System.assertEquals(null, siteIssues[1].Latest_Public_Case_Comment__c);
        
        //Fetching Update Case Case_Comment_Notification__c
        cases = [Select Id, Case_Comment_Notification__c From Case Where Case_Comment_Notification__c!=null Order BY SuppliedEmail ASC];
        System.assertEquals(3,cases.size());
    }
}