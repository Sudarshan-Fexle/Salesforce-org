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
@isTest(seeAllData = false)
private class testEventNewOverrideExt {
/**
    Purpose         :   Test class for EventNewOverrideExt
                
    Create By       :   
    
    Created Date    :   
    
    Revision Log    :   v1.0 - Created
                        v2.0 - Abhinav Sharma - CR-20150202-8636 - 7/13/2016 - A code refactor CR

    Coverage Log    :   v1.0 - EventNewOverrideExt - 72%
                        V2.0 - EventNewOverrideExt - 91%
`                       
**/
    //Modified By - Abhinav Sharma - CR-20150202-8636 - 7/13/2016 - A code refactor CR
    /** Description : Method to test out various use cases associated with the "EventNewOverrideExt" controller class.                  
    **/
    static testMethod void myUnitTest() {
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Flag for triggers: this is just a test, don't do crazy things.
        Util.isTesting = true;
        
        //Create new account
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        //Query over RecordYype of Contact
        List<RecordType> contactRdTypes = [SELECT ID FROM RecordType WHERE sObjectType = 'Contact' AND IsActive = true
                                            AND DeveloperName = 'Employee'];
        
        //Assert for the results
        System.assert(contactRdTypes != null);
        System.assert(contactRdTypes.size() > 0);
                                            
        //Create new contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, 
                                          Expert__c = true, RecordTypeId = contactRdTypes[0].Id);
        insert con;
        
        //Select Record Types Id from Custom Setting
        Id expertCentersRTTypeId = Util.RecordTypeId(Constants.CASE_OBJECT, TestUtilities.ASK_EAB_CASE_RECORD_TYPE);
        System.assert(expertCentersRTTypeId != null);
        
        //Create a contact
        Contact contact = TestUtilities.CreateNewContact(true);
        
        //Create case 
        Case cse = new Case(RecordTypeId = expertCentersRTTypeId, Origin = 'Email', Subject = 'Test 1', Status = '01-New',
                                Description = 'test 1', AccountId = acc.Id, Priority = 'Low', 
                                ContactId = con.Id);
        insert cse;
        
        //Create new atteachment
        Attachment attach=new Attachment();     
        attach.Name='Unit Test demo.csv';
        attach.body = Blob.valueOf('Unit Test demo.csv');
        attach.parentId=cse.id;
        insert attach;
        
        // create a new PT QA Call event
        String PTQACallRTId = Util.RecordTypeId('Event', 'Quality Assurance');
        
        //Event record
        Event Evt = testUtilities.CreateNewEvent(false);
        //Spring Clean Up - Evt.Syndicated_Resources__c = '';
        insert Evt;
        
        //Standard controller instance
        ApexPages.standardController standardController = new ApexPages.standardController(Evt);
        
        //Call method to get next page URL
        String nextPage = standardController.save().getUrl();

        //Assert for result
        System.assertNotEquals(null, nextPage);
        
        // set the page
        test.setCurrentPage(Page.Event_Edit);
        
        //Setting URL Parameters
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('what_id',acc.id);
        ApexPages.currentPage().getParameters().put('who_id',con.id);
        ApexPages.currentPage().getParameters().put('RecordType', PTQACallRTId);
        
        //Start testing from here
        Test.startTest();
        
        //Calling controller extension
        EventNewOverrideExt controller = new EventNewOverrideExt(standardController);
        
        // assert that it is the correct record type
        system.assertEquals(true, controller.IsPTQACall);
        //system.assertEquals(false, controller.IsPTAM);
        system.assertEquals(false, controller.IsPTMarketing);
        system.assertEquals(false, controller.IsRIAM);
        system.assertEquals(false, controller.IsRIMarketing);
        //system.assertEquals(false, controller.IsTDAM);
        system.assertEquals(false, controller.IsNew);
         
        //Create a new RI QA Call event
        String RIQACallRTId = Util.RecordTypeId('Event', 'Quality Assurance');
        
        //Event instance
        Event testEventREC = testUtilities.CreateNewEvent(false);
        testEventREC.Subject = '';
        //Spring Clean up - testEventREC.Syndicated_Resources__c = 'Test';
        insert testEventREC;
        
        //Standard controller instance
        ApexPages.standardController standardController1 = new ApexPages.standardController(testEventREC);
        
        //Set the current page
        test.setCurrentPage(Page.Event_Edit);
        
        //Setting URL Parameters
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('what_id',acc.id);
        ApexPages.currentPage().getParameters().put('who_id',con.id);
        ApexPages.currentPage().getParameters().put('RecordType', RIQACallRTId);
        
        //Calling controller extension
        controller = new EventNewOverrideExt(standardController1);
        
        //Create a new Goal event
        String GoalRTId = Util.RecordTypeId('Event', 'Goal');
        Event testEventREC1 = testUtilities.CreateNewEvent(false);
        testEventREC1.RecordTypeId = GoalRTId;
        //Spring Clean Up - testEventREC1.Syndicated_Resources__c = 'Adams, Jim';
        insert testEventREC1;
        
        //Standard controller instance
        ApexPages.standardController standardController2 = new ApexPages.standardController(testEventREC1);
        
        //Set the current page
        test.setCurrentPage(Page.Event_Edit);
        
        //Setting URL Parameters
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('what_id',acc.id);
        ApexPages.currentPage().getParameters().put('who_id',con.id);
        ApexPages.currentPage().getParameters().put('RecordType', GoalRTId);
        
        //Calling controller extension
        controller = new EventNewOverrideExt(standardController2);
        
        //Calling controller methods
        controller.redirect();
        controller.SaveDoc();
        
        //Setting controller's variable
        controller.queryString = 'Select Id From Test';
        controller.DifferenceInMinutse(System.today().addDays(80), System.today());
        
        //Set Time value to controller 
        controller.DifferenceInMinutse(System.now(), System.now().addMinutes(-13));
        
        //Define properties
        List<String> selectedValues = new List<String>();
        List<String> unselectedValues = new List<String>();
        List<String> showAsOptions = new List<String>();
        
        //Added value in list
        selectedValues.add('Test1');
        selectedValues.add('Test2');
        unselectedValues.add('Testq');
        unselectedValues.add('Testp');
        
        //Call method
        controller.selectclick();
        controller.getSelectedValues();
        controller.unselectclick();
        controller.getunSelectedValues();
        
        //Add value to controller list
        controller.leftselected.add('Test1');
        controller.leftselected.add('Test2');
        
        //Call method 
        controller.selectclick();
        controller.getSelectedValues();
        controller.Save();
        
        //Call method
        controller.rightselected.add('Testq');
        controller.rightselected.add('Testp');
        controller.unselectclick();  
        controller.getunSelectedValues();
        
        //Set value to controller instance
        controller.NameFile = 'Test.csv';
        
        //Call method
        controller.SaveDoc();
        controller.SaveAndNew();
        controller.SaveAndNewTask();
        controller.Save();
        
        //Setting properties
        controller.RecordId = null;
        
        //Asserting for the results
        //System.assertNotEquals(null, controller.redirect());
        
        //Call method & get value
        List<selectOption> selectOption = controller.ShowAsOptions;
        
        //Assert for result
        System.assert(selectOption != null);
        System.assertEquals(3,selectOption.size());
        
        //Call method
        Pagereference pageRf = controller.cancel();
        
        //Assert for result
        System.assert(pageRf != null);
        
        //Calling controller method from saving the document
        try {
            controller.SaveDoc();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('No file was selected'));    
        }
        
        //Initializing event controller instance to make sure that parentId will not populated on the attachment while invoking
        //the "saveDoc" controller method
        controller.Evt = new Event();
        
        //Setting class variables, which will ideally hold the VF page selected file/attachment name and body attributes values
        controller.EmailAttachment = new Attachment();
        controller.NameFile = 'Unit Test Attachment.csv';
        controller.EmailAttachment.Name = 'Unit Test Attachment.csv';
        controller.EmailAttachment.Body = Blob.valueOf('Test Attachment Body');
        
        //Calling controller method from saving the document
        try {
            controller.SaveDoc();
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains('Please enter a value in the'));    
        }
        
        //Populating URL parameters with values
        ApexPages.currentPage().getParameters().put('who_id', con.Id);
        ApexPages.currentPage().getParameters().put('what_id', acc.Id);
        
        //Loading the VF page again
        ApexPages.StandardController stdcontroller1 = new ApexPages.StandardController(testEventREC1);
        EventNewOverrideExt controller_1 = new EventNewOverrideExt(stdcontroller1);
        
        //Setting class variables, which will ideally hold the VF page 
        //selected file/attachment name and body attributes values
        controller_1.EmailAttachment = new Attachment();
        controller_1.NameFile = 'Unit Test Attachment.csv';
        controller_1.EmailAttachment.Name = 'Unit Test Attachment.csv';
        controller_1.EmailAttachment.Body = Blob.valueOf('Test Attachment Body');
        
        //Calling controller method from saving the document
        controller_1.SaveDoc();
        
        //list of attachments
        List<Attachment> attachments = new List<Attachment>();
        
        //Asserting for the results
        attachments = [SELECT ID, Name, ParentId, Body FROM Attachment ORDER BY Name];
        controller_1.EmailAttachments = attachments;
        
        //Asserting for the results
        System.assert(attachments != null);
        System.assertEquals(3, attachments.size());
        
        //Call method 
        controller_1.ReAssociateDocs();
        
        //Query over Attachments
        attachments = [SELECT ID, Name, ParentId, Body FROM Attachment ORDER BY Name];
        
        //Assert for result
        System.assert(attachments != null);
        System.assertEquals(3, attachments.size());
        
        //Setting email attachments
        controller_1.EmailAttachments = attachments;
       
        //Call method
        controller_1.AttachmentToRemove = 'Unit Test demo.csv';
        controller_1.RemoveAttachment();
        
        //Query over Attachments
        attachments = [SELECT ID, Name, ParentId, Body FROM Attachment ORDER BY Name];
        
        //Assert for result
        System.assert(attachments != null);
        System.assertEquals(2, attachments.size());
        
        // create a new PT QA Call event
        String IsTDAMRTId = Util.RecordTypeId('Event', 'Quality Assurance');
        Event EvtTDAM = testUtilities.CreateNewEvent(false);
        EvtTDAM.WhatId = acc.Id;
        EvtTDAM.RecordTypeId = IsTDAMRTId;
        insert EvtTDAM;
        
        //Create insteance
        ApexPages.standardController standardController3 = new ApexPages.standardController(EvtTDAM);
        
        //Set the page
        test.setCurrentPage(Page.Event_Edit);
        
        //Setting URL parameters
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('RecordType',IsTDAMRTId);
        
        //Calling controller extension
        controller = new EventNewOverrideExt(standardController3);
        
        //Call method
        controller.redirect();
        
        //Create a new RI Marketing event
        String RIMCallRTId = Util.RecordTypeId('Event', 'Sales');
        
        Event testEventREC11 = testUtilities.CreateNewEvent(false);
        testEventREC11.WhatId = acc.Id;
        testEventREC11.RecordTypeId = RIMCallRTId;
        
        //Insert event
        insert testEventREC11;
        
        //Loading the VF page again
        standardController3 = new ApexPages.standardController(testEventREC11);
        
        //Set the page
        test.setCurrentPage(Page.Event_Edit);
        
        //Setting URL Parameters
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('RecordType',RIMCallRTId);
        controller = new EventNewOverrideExt(standardController3);
        
        //Call method
        controller.redirect();
        
        //Create a new RI AM Call event
        //Chanegd RI AM to Account Management by Mahendra Swarnkar -  CR-20190522-13122 - 06/12/2019
        String IsRIAMRTId = Util.RecordTypeId('Event', 'Account Management');
        Event testEventRIAMRT = testUtilities.CreateNewEvent(false);
        testEventRIAMRT.WhatId = acc.Id;
        testEventRIAMRT.RecordTypeId = IsRIAMRTId;
        
        //Insert event record
        insert testEventRIAMRT;
        
        //Re-initailize page instance
        standardController3 = new ApexPages.standardController(testEventRIAMRT);
        
        //Set the page
        test.setCurrentPage(Page.Event_Edit);
        
        //Set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('RecordType',IsRIAMRTId);
        controller = new EventNewOverrideExt(standardController3);
        
        //Call method
        controller.redirect();
        
        //Modified by Mahendra Swarnkar - 06/12/2019 - CR-20190522-13122.
        /*//Create a new RI QA Call event
        String IsPTAMRTId = Util.RecordTypeId('Event', 'PT AM');
        Event testEventPTAMRT = testUtilities.CreateNewEvent(false);
        testEventPTAMRT.WhatId = acc.Id;
        testEventPTAMRT.RecordTypeId = IsPTAMRTId;
        insert testEventPTAMRT;
        
        //Re-initailize page instance
        standardController3 = new ApexPages.standardController(testEventPTAMRT);
        
        //Set the page
        test.setCurrentPage(Page.Event_Edit);
        
        //Set the Account Id as the "Related To Id"
        ApexPages.currentPage().getParameters().put('RelatedToId',acc.id);
        ApexPages.currentPage().getParameters().put('RecordType',IsPTAMRTId);
        controller = new EventNewOverrideExt(standardController3);
        
        //Call method
        controller.redirect();
        
        //Populating URL parameters with values
        ApexPages.currentPage().getParameters().put('who_id', con.Id);
        ApexPages.currentPage().getParameters().put('what_id', null);
        
        //Loading the VF page again
        standardController3 = new ApexPages.standardController(testEventPTAMRT);
        controller = new EventNewOverrideExt(standardController3);*/
        
        //Test will stop here
        Test.stopTest();
        
        //Setting class variables, which will ideally hold the VF page selected file/attachment name and body attributes values
        controller.EmailAttachment = new Attachment();
        controller.NameFile = 'Unit Test 2.csv';
        controller.EmailAttachment.Name = 'Unit Test 2.csv';
        controller.EmailAttachment.Body = Blob.valueOf('Test 2 Body');
       
        //Calling controller method from saving the document
        controller.SaveAndNewTask();
        controller.SaveAndNew();
        controller.Save();  
        
        //Populating URL parameters with values
        ApexPages.currentPage().getParameters().put('who_id', null);
        ApexPages.currentPage().getParameters().put('what_id', contact.Id);
        
        //Loading the VF page again
        //standardController3 = new ApexPages.standardController(testEventPTAMRT);
        //controller = new EventNewOverrideExt(standardController3);
        
        //Calling controller method
        controller.Evt = null;
        controller.SaveDoc(); 
        
        //Populating URL parameters with values
        ApexPages.currentPage().getParameters().put('who_id', contact.Id);
        ApexPages.currentPage().getParameters().put('what_id', null);
        
        //Loading the VF page again
        //standardController3 = new ApexPages.standardController(testEventPTAMRT);
        controller = new EventNewOverrideExt(standardController3);
        controller.Evt = null;
        controller.SaveDoc(); 
    }
}