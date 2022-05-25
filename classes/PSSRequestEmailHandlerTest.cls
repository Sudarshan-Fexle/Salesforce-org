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
private class PSSRequestEmailHandlerTest {    
/**
    Purpose         :   Test class for PSSRequestEmailHandler
                
    Created By       :  Abhinav Sharma
    
    Created Date    :   12/10/2016
    
    Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20160111-9502
                    :   V1.1 - Modified By - Neha Sharma - 11/01/2021 - CR-20180604-12256 - Remove references of OrgWide Email addresses with @Advisory.com
		    :   V1.2 - Modified By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
                    :   V1.3 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
		    
                
**/
    static testmethod void myUnitTest_1() { 
        
        //Bypass Dupeblocker
        Util.IsTest(true);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = true;
        
        //Profile    
        Profile p = [SELECT Id FROM Profile 
                        WHERE Name='System Administrator']; 
        System.assert(p != null);
      
        //User
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        //Users
        List<User> users = new list<user>();
        
        //Run in this user context
        System.runAs(u) {
        
            // The following code runs as user 'u'
            User u1 = new User(Alias = 'standt', Email='standarduse676r@testorg.com', Employee_Id__c = 'Testing 1',
                                EmailEncodingKey='UTF-8', LastName='Testing45465656', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com');
            User u2 = new User(Alias = 'standt', Email='standarduser656@testorg.com', Employee_Id__c = 'Testing 2',
                                EmailEncodingKey='UTF-8', LastName='Testing656556', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com');
            users.add(u1);
            users.add(u2);
            insert users;
        }
        
        //Account
        Account account = new Account(Name = 'Test Acc', Account_Formal_Name__c = 'testacc');
        insert account;
        
        //program
        Program__c prog = TestUtilities.CreateNewProgram(false);
        insert prog;
        
        //Membership
        Membership__c mem = TestUtilities.CreateNewMembership(account.Id, prog.Id, true);
        
        //Util is bypass trigger
        Util.BypassAlltriggers = true;
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'standarduse676r@testorg.com',
                                       Employee_Id__c = 'Testing 1', Title = 'Test', 
                                       Phone = '614-555-8855');
        Contact contact2 = new Contact(LastName = 'TestT', FirstName = 'ConT', Email = 'standarduser656@testorg.com',
                                       Employee_Id__c = 'Testing 2', Title = 'Test', Phone = '614-555-8855');
        contacts.add(contact);
        contacts.add(contact2);                               
        insert contacts;
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];
        System.assert(oppRecord.size() > 0);

        //Insert Opportunity Records
        //Modify By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c 
           
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                    CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                    AccountID = account.Id, Sales_Pursuit_Products__c  = 'APS' //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
                                   ));
        insert oppList;    
        
        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                                WHERE (DeveloperName = 'Core_Marketing' OR DeveloperName = 'Core_AM') 
                                                AND SObjectType = 'Event' AND IsActive = true];
        System.assert(eventRecordType.size() > 0);
        
        //Map to hold record type DeveloperName as key and record type Id as value
        Map<String,Id> mapEventRecordType =  new Map<String,Id>();

        //Populate mapEventRecordType
        for(RecordType rt : eventRecordType){
            mapEventRecordType.put(rt.DeveloperName , rt.Id);
        }
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(RecordTypeId = mapEventRecordType.get('Core_Marketing') ,StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit' ));
        insert events;
       
        //Util is bypass trigger
        Util.BypassAlltriggers = false;
        
        //List of PSS Requests
        List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
        
        //PSS Request
        PSS_Request__c pSSRequest = new PSS_Request__c();
        pSSRequest.Activity_ID__c = events[0].ID;
        pSSRequest.Opportunity__c = events[0].WhatID;
        pSSRequest.Approver__c = contacts[0].Id;
        pSSRequests.add(pSSRequest);
        insert pSSRequests;
        
        //Querying additional details
        pSSRequests = [SELECT ID, Name FROM PSS_Request__c];
        
        // Create a new email and envelope object
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Create the email body  
        email.plainTextBody = 'ABC' + '\n' + System.Label.PSS_Request_ID + '**> ' + pSSRequests[0].ID;
        email.fromAddress ='test@test676687887454344343.com';
        email.ccAddresses = new String[] {contacts[1].Email};
        //Modified By - Neha Sharma - 11/01/2021 - CR-20180604-12256 - Remove references of OrgWide Email addresses with @Advisory.com (Comment Custom Label)
        email.toAddresses = new String[] {/*System.Label.PSS_Requests_Email_Address*/};
        //End 
        email.subject = 'Dummy Testing';
        
        //Email Handler class controller
        PSSRequestsEmailHandler edr = new PSSRequestsEmailHandler();
        
        //Start test from here
        Test.startTest();
        
        //Inbound email request
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        
        //Stop test here
        Test.stopTest();
        
        //Asserting for the success
        System.assert (result.success, 'InboundEmailResult returned a failure message');
        
        //Querying additional details
        pSSRequests = [SELECT ID, PSS_Resource__c, Approved__c
                       FROM PSS_Request__c];
         
        //Asserting for the results
        System.assertEquals(1, pSSRequests.size());
       /* System.assertEquals(true, pSSRequests[0].Approved__c);
        System.assertEquals(contacts[1].ID, pSSRequests[0].PSS_Resource__c);*/
    }    
}