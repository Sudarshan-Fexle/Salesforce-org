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
@isTest(seeAllData=false)
private class testCaseEmailController {
/**
    Purpose         :   Test class for CaseEmailController
                
    Create By       :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
                        v2.0 - Modify By - Abhinav Sharma - CR-20150202-8626 - 06/02/2016
                        v3.0 - Modify By- MAhendra Swarnkar - CR-20160729-10075 - 08/31/2016  
                        
    Coverage Log    :   v1.0 - CaseEmailController - 78%
                        v2.0 - CaseEmailController - 98%
**/    
    
    //Modify By- MAhendra Swarnkar - CR-20160729-10075 - 08/31/2016 
    //Modified by - Abhinav Sharma - CR-20150202-8626 - To refactor the existing code
    /** Description : Method to test out whether "List of available email addresses" finding and fecthing funcationality is
     *                  working as expected on the VF page or not.
     *               
    **/ 
    static testmethod void testAvailableEmails() {
       
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.byPassAllTriggers = true;
        Util.isTesting = true;
        
        // create a user that will be activated/deactivated accordingly
        User newUser = TestUtilities.CreatenewUser(false);
        newUser.Email = 'Test@junkabcadvisory.com';
        insert newUser;
        System.assertEquals(newUser.Email, 'Test@junkabcadvisory.com');
        
        // create an account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Select Record Types Id from Custom Setting
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, 'Ask EAB');
        System.assert(expertCentersRTTypeId != null);
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a sample case record
        Case aCase = new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        
        insert aCase;
        
        //Start Test from here
        Test.startTest(); 
        
        //Loading VF page       
        PageReference pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', aCase.Id);
        
        //Test for other than Expert Center and IRC Request Email type  
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        CaseEmailController controller = new CaseEmailController();
        String str = controller.AvailableEmails;
        // ensure our new user's email address is in the list
        system.assertEquals(false, str.contains(newUser.Email));
        
        //Test for Expert Center Email type  
        pageRef.getParameters().put('type', 'ExpertCenter'); //ExpertCenter , IRCRequest
        
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        controller = new CaseEmailController();
        
        // ensure our new user's email address is in the list
        system.assertEquals(false, controller.AvailableEmails.contains(newUser.Email));
        
        //Test for IRC Request Email type 
        pageRef.getParameters().put('type', 'IRCRequest');  
        
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        controller = new CaseEmailController();
        
        // ensure our new user's email address is in the list
        system.assertEquals(false, controller.AvailableEmails.contains(newUser.Email));
        
        //Query to select User 
        User currentUser = [Select Email from User where Id =: Userinfo.getUserId()];
        System.assertEquals(currentUser.Email, controller.EmailCC);
        
        //Stop Test here
        Test.stopTest();
    }
    
    //Modify By- MAhendra Swarnkar - CR-20160729-10075 - 08/31/2016 
    //Modified by - Abhinav Sharma - CR-20150202-8626 - To refactor the existing code
    /** Description : Method to test out various use cases associated with the "Send" button click on the VF page.
    **/ 
    static testmethod void testSendEmail() { 
        
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.isTesting = true;
        
        //retrieving custom metadata type records
        List<Internal_Applicable_Email_Suffix__mdt> internalDomains = [SELECT Applicable_Record_Types__c,
                                                                      Eligible_Email_Domain__c, Object_API_Name__c,
                                                                      DeveloperName, Production__c 
                                                                      FROM Internal_Applicable_Email_Suffix__mdt];
        
        // create a user that will be activated/deactivated accordingly
        List<User> users = new List<User>();
        User newUser1 = TestUtilities.CreatenewUser(false);
        newUser1.Email = 'hansonva@test.com';
        users.add(newUser1);
        
        User newUser2 = TestUtilities.CreatenewUser(false);
        newUser2.Email = 'hansonv@test.com';
        users.add(newUser2);
        
        User newUser3 = TestUtilities.CreatenewUser(false);
        newUser3.Email = 'hansonv1@test.com';
        users.add(newUser3);
        insert users;
        
        System.assertEquals(3, users.size());
        System.assertEquals(newUser1.Email, 'hansonva@test.com');
        System.assertEquals(newUser2.Email, 'hansonv@test.com');
        System.assertEquals(newUser3.Email, 'hansonv1@test.com');
        
        //Select email template
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE isActive = true LIMIT 1];
        
        // create an account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Expert Center record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, 'Ask EAB');
        System.assert(expertCentersRTTypeId != null);
        
        //EAB Custom record type
        //Id eabCustomRTType = Util.RecordTypeId('Case', 'Ask EAB');
         List<RecordType> rtCase = [Select Id From RecordType where Name = 'Ask EAB' And sobjecttype = 'Case'];
        System.assert(rtCase[0].Id != null);
        
       
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true); 
        
        //List of Case
        List<Case> cases = new List<Case>();
        
        //Create Cases
        //Expert center case
        cases.add(new Case(RecordTypeId = rtCase[0].Id, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id));
        
        //EAB custom case
        cases.add(new Case(RecordTypeId = rtCase[0].Id, Origin = 'Email', Subject = 'Test 2', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id));
        //IRC Request case record
        cases.add(new Case(RecordTypeId = rtCase[0].Id, Origin = 'Web', Subject = 'Test 3', Status = 'New Request',
                                Description = 'test 3', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id));
        
        //Insert Cases
        insert cases;
        
        //retrieving case records details
        cases = [Select ID, RecordTypeID FROM Case ORDER BY Subject ASC];
        
        //Assert for result
        System.assert(cases != null);
        System.assertEquals(3, cases.size());
        
        //Start Test from here
        Test.startTest();  
       
       //Testing in "ASK EAB" record type case record context
       
        //Loading VF Page
        PageReference pageRef = Page.CaseEmail;
        
        //Setting page paramters
        pageRef.getParameters().put('id', cases[1].Id);
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        CaseEmailController controller = new CaseEmailController();
        
        //Set controller variables
        controller.EmailTo = 'hansonva@test.com';
        controller.EmailCC = 'hansonv@test.com';
        controller.EmailBCC = 'hansonv1@test.com';
        controller.EmailSubject = 'Test';
        
        //Setting page parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        // unfortunately getContent() calls are not supported for test methods
        // so verify that we got our canned-htmlbody response
        PageReference pg = controller.SendEmail();
        
        //Testing in "Expert Center" record type case record context
       
       //Testing the same button related funcationality in the context of "Expert Center" case record type case record context
        pageRef.getParameters().put('type', 'ExpertCenter');
        pageRef.getParameters().put('id', cases[0].Id);
        Test.setCurrentPageReference(pageRef);
        
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@junkabcadvisory.com';
        controller.EmailCC = 'hansonv@junkabcadvisory.com';
        controller.EmailBCC = 'hansonv1@junkabcadvisory.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        String ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //User click on the "Send" button on the VF page
        pg = controller.SendEmail();
        system.assertEquals(null, controller.ErrorString);
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBCCList);
        
        pageRef.getParameters().put('type', 'ExpertCenter');
        pageRef.getParameters().put('id', cases[0].Id);
        Test.setCurrentPageReference(pageRef);
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@Test.com';
        controller.EmailSubject = 'Test';
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
        pageRef.getParameters().put('type', 'ExpertCenter');
        pageRef.getParameters().put('id', cases[0].Id);
        Test.setCurrentPageReference(pageRef);
        
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@junkabcadvisory.com';
        controller.EmailCC = 'hansonv@Test.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
        Test.setCurrentPageReference(pageRef);
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@junkabcadvisory.com';
        controller.EmailCC = 'hansonv@junkabcadvisory.com';
        controller.EmailBCC = 'hansonv1@Test.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
    //Testing in "IRC Request type" record type case record context
        
        //Testing the same button related funcationality in the context of "Expert Center" case record type case record context
        pageRef.getParameters().put('type', 'IRCRequest');
        pageRef.getParameters().put('id', cases[2].Id);
        Test.setCurrentPageReference(pageRef);
        
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@Test.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
        Test.setCurrentPageReference(pageRef);
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@junkabcadvisory.com';
        controller.EmailCC = 'hansonv@Test.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
        Test.setCurrentPageReference(pageRef);
        //Re-intialize the controller
        controller = new CaseEmailController();
        controller.EmailTo = 'hansonva@junkabcadvisory.com';
        controller.EmailCC = 'hansonv@junkabcadvisory.com';
        controller.EmailBCC = 'hansonv1@Test.com';
        controller.EmailSubject = 'Test';
        
        //Setting current page URL parameters
        ApexPages.currentPage().getParameters().put('emailBody','emailBody \n emailBody');
        ApexPages.currentPage().getParameters().put('url','https://force.com/EmailPreview');
        
        //Email Body
        ebody = controller.EmailBody;
        
        //Assert for result
        system.assertNotEquals(null, controller.EmailBody);
        system.assertEquals(controller.aCase.AccountId, a.Id);
        
        // make sure the current user is correct
        system.assertEquals(controller.CurrentUser.Name, UserInfo.getName());
        
        //Send the email
        pg = controller.SendEmail();
        
        //Test Will stop Here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8626 - To refactor the existing code
    /** Description : Method to test out the use cases associated with the "Search Contact" based functionality of the VF page.
    **/ 
    static testmethod void testSearchContent() {
        
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.isTesting = true;
        
        //Fteching Expert center case record type
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, 'Ask EAB');
        System.assert(expertCentersRTTypeId != null);
        
        // create an account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a sample case record
        Case aCase = new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        
        insert aCase;
        
        // select a random email template to work with
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE isActive = true LIMIT 1];
        
        // create content documents
        ContentVersion doc1 = new ContentVersion(title='TEST-New Document1', 
                                                 PathOnClient='http://www.advisory.com/_res/img/logo.png', 
                                                 VersionData = blob.valueOf('test'));
        ContentVersion doc2 = new ContentVersion(title='TEST-New Document2', 
                                                    PathOnClient='http://www.advisory.com/_res/img/logo.png', 
                                                    VersionData = blob.valueOf('test'));
        List<ContentVersion> docs = new List<ContentVersion>{ doc1, doc2 };
        insert docs;
        
        //Start Test from here
        Test.startTest(); 
       
        //Loading VF Page
        PageReference pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', aCase.Id);
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        CaseEmailController controller = new CaseEmailController();
        
        // make sure both content types are present
        system.assertEquals(2, controller.getTypes().size());
        
        // set the search string
        controller.SearchString = 'TEST-New Document';
        
        // ensure both of our workspace folders are present
        system.assertNotEquals(0, controller.Workspaces.size());
        
        //Update docs
        for(ContentVersion cV : docs)
            cV.ContentUrl = null;
            
        //Update docs
        update docs;
        
        //Selected workspace
        controller.SelectedWorkspace = 'test';
        List<ContentDocument> contentDocList = controller.getContentDocuments();
        
        //Asserting for the result
        System.assertNotEquals(null, contentDocList);
        System.assertEquals(0, contentDocList.size());
            
        // set the search string
        controller.SearchString = null;
        contentDocList = controller.getContentDocuments();
        
        //Assert for result 
        System.assert(contentDocList != null);
        System.assertEquals(0, contentDocList.size());
        
        //Set controller variable's
        controller.SelectedWorkspace = null;
        contentDocList = controller.getContentDocuments();
        
        //Asserting for the result 
        System.assert(contentDocList != null);
        System.assertEquals(2, contentDocList.size());
        
        //Test will stop Here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8626 - To refactor the existing code
    /** Description : Method to test :- 
     *               a) Attach file funcationality on the VF page is working as expected or not 
     *               b) Remove attachment funcationality on the VF page is working as expected or not
     *               c) Content serach, select and pagaination related fucnationality is working as expected or not
     *               d) Few use cases associated with "Send" funcationality work in conjunction to attach funcationality
    **/
    static testmethod void testSearchContent_Paging() {
    
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.BypassAllTriggers = true; 
        Util.isTesting = true;
        
        //Added by Mahendra Swarnkar - 06/03/2016
        //Select Record Type Id from Custom Setting
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, 'Ask EAB');
        System.assert(expertCentersRTTypeId != null);
        
        // setup a case
        // create an account
        Account a = new Account();
        a.Name = 'testAcct' + crypto.getRandomInteger();
        insert a;
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create a sample case record
        Case aCase = new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = a.Id, Priority = 'Low', ContactId = contact.Id);
        
        insert aCase;
                
        // select a random email template to work with
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE isActive = true LIMIT 1];
        
        // create 20 documents (For enabling the pagaination)
        List<ContentVersion> docs = new List<ContentVersion>();
        for (integer i = 0; i < 20; i++) {
            ContentVersion newDoc = new ContentVersion(title='TEST-New Document'+i, 
                                                       PathOnClient='http://www.advisory.com/_res/img/logo.png', 
                                                       VersionData = blob.valueOf('test'));
            docs.add(newDoc);
        }
        insert docs;
        
        //Test will start from here
        Test.startTest();
        
        //Loading VF page
        PageReference pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', aCase.Id);
        Test.setCurrentPageReference(pageRef);
        
        // create an instance of the controller extension
        CaseEmailController controller = new CaseEmailController();
        
        // set the search string
        controller.SearchString = 'TEST-New Document';
        
        // ensure we returned the proper number of documents
        system.assertEquals(10, controller.getContentDocuments().size());
        system.assertEquals(true, controller.HasNext);
        system.assertEquals(false, controller.HasPrevious);
        
        // page forward
        controller.Next();
        
        // ensure we are still able to page backwards
        system.assertEquals(true, controller.HasPrevious);
        
        // page backwards
        controller.Previous();
        system.assertEquals(false, controller.HasPrevious);
        
        // couple of time page forward
        controller.Next();
        controller.Next();
        
        //Assert for result
        System.assertEquals(false, controller.HasNext);
        
        //Attaching one more attachment
        Attachment attachmnt = new Attachment(Name = 'Test',ContentType = 'Text', Description = 'Testing', 
                                          Body = Blob.valueOf('Test'),
                                          parentId = aCase.Id); 
        insert attachmnt;
        System.assert(attachmnt != null);
        
        //List of attachment
        List<Attachment> attchments = [SELECT ID, Name FROM Attachment WHERE ID =: attachmnt.Id];
        System.assert(attchments != null);
        System.assertEquals(1, attchments.size());
         
        //Setting properties and making a try to remove the attachment
        controller.AttachmentToRemove = attchments[0].Name;
        controller.EmailAttachments = attchments;
        //controller.SendEmail();
        controller.RemoveAttachment();
        
        //Setting email type and checking for Boolean property valeu
        controller.EmailType = null;
        Boolean b = controller.IsAskEAB;
        System.assertEquals(false, b);
        
        //testing for errors when there is no receipient to send an email
        controller.EmailToList = null;
        controller.SendEmail();
        
        //Upto here
        //Test will stop Here
        Test.stopTest();
    }
    
    //Modified by - Abhinav Sharma - CR-20150202-8626 - To refactor the existing code
    //Modified By - Abhinav Sharma - CR-20150914-9243 - 11/27/2015
    //Added By - Abhinav Sharma - 07/05/2014 - CR-20140629-6015
    /** Description : Method to walk various funcationality of the VF page in one go for different case record types
     *                  and asserting for various use cases based results.
    **/
    static testmethod void testRecordTypeDifferences() {  
        
        //Bypass Dupeblocker and triggers for test data creation purpose
        Util.IsTest(true);
        Util.BypassAllTriggers = true;
        Util.IsTesting = true;
        
        // create an account
        Account acct = new Account();
        acct.Name = 'testAcct' + crypto.getRandomInteger();
        
        //Insert accounts
        insert acct;
        
        //Member & Employee case record type
        Id memberAndemployeeSupportRTType = Util.RecordTypeId(Constants.CASE_OBJECT,TestUtilities.CASE_RECORD_TYPE_MEMBER_AND_SUPPORT_REQUEST);
        System.assert(memberAndemployeeSupportRTType != null);

        
        //ASK EAB case record type
        Id eabCustomRTType = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.CASE_RECORD_TYPE_EAB_CUSTOM);
        System.assert(eabCustomRTType != null);
        
        //List to hold the case records
        List<Case> cases = new List<Case>();
                                
        //Create a sample case record
        Case aCase_1 = new Case(RecordTypeId = eabCustomRTType, Origin = 'Email', Subject = 'Test 1', 
                                Description = 'test 1', AccountId = acct.Id, Priority = 'Low');
                                
        //Create a sample case record
        Case aCase_2 = new Case(RecordTypeId = eabCustomRTType, Origin = 'Phone', Subject = 'Test 2', 
                                Description = 'test 2', AccountId = acct.Id, Priority = 'Low');
                                
        //Create a sample case record
        Case aCase_3 = new Case(RecordTypeId = eabCustomRTType, Origin = 'Web', Subject = 'Test 3', 
                                Description = 'test 3', AccountId = acct.Id, Priority = 'Low');
        
        //Create a sample case record
        Case aCase_4 = new Case(RecordTypeId = memberAndemployeeSupportRTType, Origin = 'Zillow', Subject = 'Test 4', 
                                Description = 'test 4', AccountId = acct.Id, Priority = 'Low');
        
        //Populating list with records instances
        cases.add(aCase_1); cases.add(aCase_2); cases.add(aCase_3); cases.add(aCase_4);
        
        //Insert Case
        insert cases;
        
        //Insert program record
        Program__c program = TestUtilities.CreateNewRIProgram(true);
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        //Create Membership record
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = acct.Id, 
                                             Program__c = program.Id, 
                                             Membership_Status_Text__c = 'Member - Pure')
                          );
        membershipList.add(new Membership__c(Name = 'Membership Test2', Account_Name__c = acct.Id, 
                                             Program__c = program.Id, 
                                             Membership_Status_Text__c = 'Member - Pure')
                          );
        insert membershipList;
        
        //Retriveing Case records details
        cases = [SELECT ID FROM Case ORDER By Subject ASC LIMIT 5];
        
        //Assert for the results
        System.assertEquals(4, cases.size());
        
        // Create documents
        ContentVersion document = new ContentVersion(title='TEST-New Document1', 
                                                     PathOnClient='http://www.advisory.com/_res/img/logo.png', 
                                                     VersionData = blob.valueOf('test'));
        insert document;
        
        //Start Test from here
        Test.startTest();
        
        //Setting URL parameters and loading the VF Page for expert center case
        PageReference pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', cases[1].Id);
        pageRef.getParameters().put('type', 'ExpertCenter');
        Test.setCurrentPageReference(pageRef);
        
        //Loading Case Email page controller
        CaseEmailController controller = new CaseEmailController();
        
        //Assert for the results
        System.assert(controller.EmailSubject.contains('Low – TEC Case'));
        
        //Setting URL parameters and loading the VF Page for IRC Request case
        pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', cases[2].Id);
        pageRef.getParameters().put('type', 'IRCRequest');
        Test.setCurrentPageReference(pageRef);
        
        //Loading Case Email page controller
        CaseEmailController controller_1 = new CaseEmailController();
       
        //Setting URL parameters and loading the VF Page for Member & Employee case
        pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', cases[3].Id);
        pageRef.getParameters().put('type', 'AcctMgr');
        Test.setCurrentPageReference(pageRef);
        
        //Loading Case Email page controller
        CaseEmailController controller_2 = new CaseEmailController();
        
        //Assert for the results
        System.assert(controller_2.EmailSubject.contains(Constants.MEMBER_READY_RESPONSE));
        
        //Setting URL parameters and loading the VF Page for ASK EAB case
        pageRef = Page.CaseEmail;
        pageRef.getParameters().put('id', cases[0].Id);
        pageRef.getParameters().put('type', 'AskEAB');
        Test.setCurrentPageReference(pageRef);
        
        //Loading Case Email page controller
        CaseEmailController controller_3 = new CaseEmailController();
        
        //Making a search on the page for receipients
        controller_3.Search();
        controller_3.AddLines('test');
        
        //Adding an attachment on it
        List<String> strList = controller_3.ContentDocIds;
        controller_3.AttachmentType = 'Test';
        controller_3.SelectedId = String.valueOf(aCase_3.Id);
        
        //Setting receipients
        controller_3.EmailTo = 'test@test.com,test1@test.com,test2@test.com';
        List<String> strLst = controller_3.EmailToList;
        
        //Setting email type with the help of current URL
        controller_3.EmailType = 'AskEAB';
        Boolean isAskEab = controller_3.IsAskEAB;
        System.assertEquals(true,isAskEab);
        List<Membership__c> memList = controller_3.Memberships;
        
        //Removing attchment
        controller_3.AttachmentToRemove = 'Test';
        Pagereference pg = controller_3.RemoveAttachment();
        
        //Set controller variable EmailType as null
        controller_3.EmailType = 'test';
        controller_3.SelectedId = document.Id;
        
        //Upto here
        try {
            controller_3.SaveDoc();
        } catch(Exception ex) {}
        
        //Testing related use cases for savDoc
        controller_3.SelectedId = null;
        controller_3.SaveDoc();
        
        //Setting useful getter setters
        controller.NameFile = 'test';
        String s = controller.MembershipsCommaDelim;
        
        //List of Attachment
        List<Attachment> attList = controller_3.EmailAttachments;
        System.assert(attList != null);
        System.assertEquals(1, attList.size());
        
        controller_3.EmailAttachments[0].Body = Blob.valueOf('test');
        controller_3.EmailTo = 'test@test.com';
        controller_3.EmailCC = 'test1@test.com';
        controller_3.EmailBCC = 'test2@test.com';
        controller_3.CaseId = cases[0].Id;
        controller_3.EmailSubject = 'test';
        
        //Call controller's method to see where email message is constructing as expected or not
        Messaging.SingleEmailMessage mail = controller_3.CreateCaseEmail(controller_3.EmailToList, controller_3.EmailCCList, controller_3.CaseId, 'testtecsalesforce@advisory.com', 'testtecsalesforce@advisory.com', controller_3.EmailSubject);
       
        //Asserting for the results
        System.assert(mail != null);
        
        //Stop Test here
        Test.stopTest();  
    }
}