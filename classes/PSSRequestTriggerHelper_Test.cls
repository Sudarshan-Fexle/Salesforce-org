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
private class PSSRequestTriggerHelper_Test {
/**
    Purpose         :   Test class for PSSRequestTriggerHelper
                
    Created By       :  Abhinav Sharma
    
    Created Date    :   12/10/2016
    
    Revision Log    :   V1.0 - Created - Abhinav Sharma - CR-20160111-9502
                        V1.1 - Modified By - Mahendra Swarnkar - CR-20170302-10730 - 6/15/2017 - Modify the Test methods as per the new PSS process
			V1.2 - Modified By - Neha sharma - CR-20201110-14683 - add the Sales_Pursuit_Products__c
                        V1.3 - Modified By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
**/

    /*    static testmethod void myUnitTest_1() { 
    
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
            User u1 = new User(Alias = 'standt', Email='standarduse676r@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing45465656', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com', Employee_ID__c = 'Testing 1');
            User u2 = new User(Alias = 'standt', Email='standarduser656@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing656556', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
                                UserName=Math.random() + '@test.com', Employee_ID__c = 'Testing 2');
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
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'test@yetest.com',
                                       Employee_Id__c = 'Testing 1');
        Contact contact2 = new Contact(LastName = 'TestT', FirstName = 'ConT', Email = 'test@ytetest.com',
                                       Employee_Id__c = 'Testing 2');
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
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                    CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                    AccountID = account.Id
                                   ));
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234 , Program__c = prog.Id,
                                    CloseDate=system.today().addDays(3), Membership__c = mem.Id,
                                    AccountID = account.Id
                                   ));
        insert oppList;    
        
        //Query through Opportunity RecordTypes
        List<RecordType> pSSRequestRecordType = [SELECT Id, Name, SObjectType, DeveloperName FROM RecordType 
                                                    WHERE DeveloperName = 'AM_EAB' 
                                                    AND SObjectType = 'PSS_Request__c' AND IsActive = true];
        System.assert(pSSRequestRecordType.size() > 0);
        
        //List Record Type custom setting        
        list<Recordtype_Setting__c> rdTypeSettings = new list<Recordtype_Setting__c>();
        Recordtype_Setting__c rdS = new Recordtype_Setting__c(SFID__c = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name__c = pSSRequestRecordType[0].Name,
                                                                SObjectType__c = pSSRequestRecordType[0].SObjectType);
        rdTypeSettings.add(rdS);
        insert rdS;
        
        //List of PSS Requests
        List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
        
        //PSS Request
        PSS_Request__c pSSRequest = new PSS_Request__c();
        
        pSSRequest.Opportunity__c = oppList[0].Id;
        pSSRequest.Approver__c = contacts[0].ID;
        pSSRequest.PSS_Resource__c = contacts[1].ID;
        pSSRequest.Resource_Requested__c = true;
        pSSRequest.Reason_Requested__c = 'Test ABC1';
        pSSRequest.PSS_Rank__c = System.Label.PSS_RANK_PRIMARY;
        pSSRequest.By_Pass_Process_Builder__c = true;
        
        //PSS Request
        PSS_Request__c pSSRequest1 = new PSS_Request__c();
        pSSRequest1.Opportunity__c = oppList[1].Id;
        pSSRequest1.Approver__c = contacts[1].ID;
        pSSRequest1.Resource_Requested__c = true;
        pSSRequest1.Reason_Requested__c = 'Test ABC2';
        pSSRequest1.PSS_Rank__c = System.Label.PSS_RANK_PRIMARY;
        pSSRequest1.By_Pass_Process_Builder__c = true;
        
        //Adding PSS Request records into the list
        pSSRequests.add(pSSRequest);
        pSSRequests.add(pSSRequest1);
        
        //Start Test from here
        Test.startTest();
        
        //Enabling triggers so then helper class written logic can be execute on DML event
        Util.byPassAllTriggers = false;
        
        //Insert PSS Requests
        insert pSSRequests;
        
        //Querying for the results
        List<PSS_Request__c> pSSRequestsForAsserts = [SELECT ID, Start__c, End__c, Subject__c, Attended__c,
                                                      Event_Type__c, Institution__c, Membership__c, Program__c,
                                                      Approver_User__c, PSS_Resource_User__c, Resource_Requested__c
                                                      FROM PSS_Request__c];
  
        //Asserting for the results
        System.assertEquals(2, pSSRequestsForAsserts.size());
        System.assertEquals(account.Id, pSSRequestsForAsserts[0].Institution__c);
        System.assertEquals(mem.Id, pSSRequestsForAsserts[0].Membership__c);
        System.assertEquals(prog.Id, pSSRequestsForAsserts[0].Program__c);
        System.assertEquals(users[0].Id, pSSRequestsForAsserts[0].Approver_User__c);
        System.assertEquals(users[1].Id, pSSRequestsForAsserts[0].PSS_Resource_User__c);
        System.assertEquals(account.Id, pSSRequestsForAsserts[1].Institution__c);
        System.assertEquals(mem.Id, pSSRequestsForAsserts[1].Membership__c);
        System.assertEquals(prog.Id, pSSRequestsForAsserts[1].Program__c);
        System.assertEquals(users[1].Id, pSSRequestsForAsserts[1].Approver_User__c);
        System.assertEquals(null, pSSRequestsForAsserts[1].PSS_Resource_User__c);
        
        //Profile    
        p = [SELECT Id FROM Profile 
                        WHERE Name='Finance Ops']; 
        System.assert(p != null);
      
        //User
        User u4 = new User(Alias = 'standt', Email='standardusedsdsr@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, department = 'STP',
                            TimeZoneSidKey='America/Los_Angeles', UserName=Math.random() + '@test.com');

        //Run in this user context
        System.runAs(u4) {
            
            //Enabling triggers so then helper class written logic can be execute on DML event
            Util.byPassAllTriggers = false;
        
            //update PSS Requests
            pSSRequests[1].PSS_Resource__c = contacts[0].ID;
            pssRequests[1].By_Pass_Process_Builder__c = true;
            pSSRequests[0].Approved__c = true;
            pssRequests[0].Attended__c = true;
            pssRequests[0].By_Pass_Process_Builder__c = true;
            update pssRequests[0];
        }    
        
        //Querying for the results
        pSSRequestsForAsserts = [SELECT ID, Start__c, End__c, Subject__c, Opportunity__c,
                                 Event_Type__c, Institution__c, Membership__c, Program__c,
                                 Approver_User__c, PSS_Resource_User__c
                                 FROM PSS_Request__c ORDER By LastModifiedDate DESC];
        
        //Asserting for the results
        System.assertEquals(2, pSSRequestsForAsserts.size());
        System.assertEquals(account.Id, pSSRequestsForAsserts[0].Institution__c);
        System.assertEquals(mem.Id, pSSRequestsForAsserts[0].Membership__c);
        System.assertEquals(prog.Id, pSSRequestsForAsserts[0].Program__c);
        System.assertEquals(users[0].ID, pSSRequestsForAsserts[0].Approver_User__c);
        System.assertEquals(users[1].ID, pSSRequestsForAsserts[0].PSS_Resource_User__c);
        System.assertEquals(account.Id, pSSRequestsForAsserts[1].Institution__c);
        System.assertEquals(mem.Id, pSSRequestsForAsserts[1].Membership__c);
        System.assertEquals(prog.Id, pSSRequestsForAsserts[1].Program__c);
        System.assertEquals(users[1].Id, pSSRequestsForAsserts[1].Approver_User__c);
        
        //Updating "Oppotunity" to have null as a value on one of the PSS Request record
        pssRequests[0].Opportunity__c = null;
        update pssRequests[0];
        
        //Querying for the results
        pSSRequestsForAsserts = [SELECT ID, Start__c, End__c, Subject__c, Opportunity__c,
                                 Event_Type__c, Institution__c, Membership__c, Program__c, LastModifiedDate,
                                 Approver_User__c, PSS_Resource_User__c, Activity_ID__c
                                 FROM PSS_Request__c ORDER By LastModifiedDate DESC];
        
        //Asserting for the results
        System.assertEquals(2, pSSRequestsForAsserts.size());
        System.assertEquals(null, pSSRequestsForAsserts[0].Institution__c);
        System.assertEquals(null, pSSRequestsForAsserts[0].Membership__c);
        System.assertEquals(null, pSSRequestsForAsserts[0].Program__c);
        System.assertEquals(users[0].ID, pSSRequestsForAsserts[0].Approver_User__c);
        System.assertEquals(users[1].ID, pSSRequestsForAsserts[0].PSS_Resource_User__c);
        System.assertEquals(account.Id, pSSRequestsForAsserts[1].Institution__c);
        System.assertEquals(mem.Id, pSSRequestsForAsserts[1].Membership__c);
        System.assertEquals(prog.Id, pSSRequestsForAsserts[1].Program__c);
        System.assertEquals(users[1].ID, pSSRequestsForAsserts[1].Approver_User__c);
        
        //Stop Test here
        Test.stopTest();  
    }
    
    static testmethod void myUnitTest_2() {
        
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
            users.add(u1);
            insert users;
        }
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'standarduse676r@testorg.com',
                                       Employee_Id__c = 'Testing 1');
        contacts.add(contact);
        insert contacts;
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                        WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                        AND SObjectType = 'Opportunity'
                                        AND IsActive = true];
        System.assert(oppRecord.size() > 0);
        
        //Insert Opportunity Records
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , 
                                    StageName = 'Proposal In Progress' , Amount = 1234, CloseDate = system.today().addDays(3)));
        insert oppList;    
        
        //Query through Opportunity RecordTypes
        List<RecordType> pSSRequestRecordType = [SELECT Id, Name, SObjectType, DeveloperName FROM RecordType 
                                                    WHERE DeveloperName = 'AM_EAB' 
                                                    AND SObjectType = 'PSS_Request__c' AND IsActive = true];
        System.assert(pSSRequestRecordType.size() > 0);
        
        //List Record Type custom setting        
        list<Recordtype_Setting__c> rdTypeSettings = new list<Recordtype_Setting__c>();
        Recordtype_Setting__c rdS = new Recordtype_Setting__c(SFID__c = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name = String.ValueOf(pSSRequestRecordType[0].Id),
                                                                Name__c = pSSRequestRecordType[0].Name,
                                                                SObjectType__c = pSSRequestRecordType[0].SObjectType);
        rdTypeSettings.add(rdS);
        insert rdS;
        
        //List of PSS Requests
        List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
        
        //PSS Request
        PSS_Request__c pSSRequest = new PSS_Request__c();
        pSSRequest.Opportunity__c = oppList[0].ID;
        
        //Insert PSS Requests
        insert pSSRequest;
        
        //Start Test from here
        Test.startTest();
        
        //Variable to hold email invocations limit value
        Integer emailbefore = Limits.getEmailInvocations();
        
        //Run in this user context
        System.runAs(u) {
        
            //Enabling triggers so then helper class written logic can be execute on DML event
            Util.byPassAllTriggers = false;
            
            //Setting boolean flag true. So then send email based functionality can be asserted
            pSSRequest.Approver__c = contacts[0].ID;
            pSSRequest.Resource_Requested__c = true;
            pssRequest.By_Pass_Process_Builder__c = true;
            update pSSRequest;

        }
                
        //Start Test from here
        Test.stopTest();
        
        //Querying for the results
        List<PSS_Request__c> pSSRequestsForAsserts = [SELECT ID, Resource_Requested__c FROM PSS_Request__c];
  
        //Asserting for the results
        System.assertEquals(1, pSSRequestsForAsserts.size());
        //System.assertEquals(false, pSSRequestsForAsserts[0].Resource_Requested__c);
    }
*/ 
	static testmethod void myUnitTest_3() {
        
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
            users.add(u1);
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
        
        
        //Contacts
        List<Contact> contacts = new List<Contact>();
        Contact contact = new Contact(LastName = 'Test', FirstName = 'Con', Email = 'standarduse676r@testorg.com',
                                       Employee_Id__c = 'Testing 1', Title = 'Test', Phone = '614-555-8855');
        contacts.add(contact);
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
        //Modify By - Chirag Soni - CR-20210927-15464 - 09/28/2021 - Removed the 'Research' picklist value referece and updated to 'APS'
        oppList.add(new Opportunity(RecordTypeId = oppRecord[0].Id, Name = 'Test Opportunity0', Membership__c = mem.Id, Program__c = prog.Id,
                                    Amount = 1234, AccountId = account.Id, StageName = 'Proposal In Progress', Sales_Pursuit_Products__c  = 'APS',CloseDate = system.today().addDays(3)));
        insert oppList;    
        
        //Query through Opportunity RecordTypes
        List<RecordType> pSSRequestRecordType = [SELECT Id, Name, SObjectType, DeveloperName FROM RecordType 
                                                    WHERE DeveloperName = 'AM_EAB' 
                                                    AND SObjectType = 'PSS_Request__c' AND IsActive = true];
        System.assert(pSSRequestRecordType.size() > 0);
        
        //List of PSS Requests
        List<PSS_Request__c> pSSRequests = new List<PSS_Request__c>();
        
        //PSS Request
        PSS_Request__c pSSRequest = new PSS_Request__c();
        pSSRequest.Opportunity__c = oppList[0].ID;
        pSSRequest.Approver__c = contacts[0].Id;
        pSSRequest.Reason_Requested__c = 'Test';
        pSSRequest.Resource_Requested__c = true;
        pSSRequest.PSS_Resource__c = contacts[0].Id;
        pSSRequest.By_Pass_Process_Builder__c = true;
        
        //PSS Request
        PSS_Request__c pSSRequest1 = new PSS_Request__c();
        pSSRequest1.Opportunity__c = oppList[0].ID;
        pSSRequest1.Approver__c = contacts[0].Id;
        pSSRequest1.Reason_Requested__c = 'Test';
        pSSRequest1.Resource_Requested__c = true;
        pSSRequest1.PSS_Resource__c = contacts[0].Id;
        pSSRequest1.By_Pass_Process_Builder__c = true;
        
        //PSS Request
        PSS_Request__c pSSRequest2 = new PSS_Request__c();
        pSSRequest2.Opportunity__c = oppList[0].ID;
        pSSRequest2.Approver__c = contacts[0].Id;
        pSSRequest2.Reason_Requested__c = 'Test';
        pSSRequest2.Resource_Requested__c = true;
        pSSRequest2.PSS_Resource__c = contacts[0].Id;
        pSSRequest2.By_Pass_Process_Builder__c = true;
        
        pSSRequests.add(pSSRequest);
        pSSRequests.add(pSSRequest1);
        pSSRequests.add(pSSRequest2);
        
        //Bypassing Triggers so then test data can be created easily
        Util.byPassAllTriggers = False;
        
        //Insert PSS Requests
        insert pSSRequests;
        
        List<Approval.ProcessWorkitemRequest> listApprovals = new List<Approval.ProcessWorkitemRequest> (); 
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving the Approval Process');
        req.setAction('Approve');
        
        //Start Test from here
        Test.startTest();
        
        //Run in this user context
        System.runAs(u) {
            
            for(ProcessInstanceWorkitem workItem  : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                                                     where ProcessInstanceId != null AND ProcessInstance.TargetObjectId =: pSSRequests[0].Id]) {
                req.setWorkitemId(workItem.Id); 
            }
            
            //Assert for result
            System.assert( req.getWorkitemId() != null);
            
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            
            //Reinstantiate the Approval Process
            req = new Approval.ProcessWorkitemRequest();
            req.setComments('Rejecting the Approval Process');
            req.setAction('Reject');
            
            for(ProcessInstanceWorkitem workItem  : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                                                     where ProcessInstanceId != null AND ProcessInstance.TargetObjectId =: pSSRequests[1].Id]) {
                req.setWorkitemId(workItem.Id);  
            }
            
            //Assert for result
            System.assert( req.getWorkitemId() != null);
            
            // Submit the request for approval
            result =  Approval.process(req);
            
            //Reinstantiate the Approval Process
            req = new Approval.ProcessWorkitemRequest();
            req.setAction('Reject');
        
            for(ProcessInstanceWorkitem workItem  : [Select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                                                     where ProcessInstanceId != null AND ProcessInstance.TargetObjectId =: pSSRequests[2].Id]) {
                req.setWorkitemId(workItem.Id); 
            }
            
            //Assert for result
            System.assert( req.getWorkitemId() != null);
            
            try{
                // Submit the request for approval
                result =  Approval.process(req);   
            }
            catch(Exception e){
                system.assert(e.getMessage().contains('Please populate the comment with rejection reason'), 'Please populate the comment with rejection reason');
            }
        }
        
        //Start Test from here
        Test.stopTest();
        
        //Querying for the results
        List<PSS_Request__c> pSSRequestsForAsserts = [SELECT ID, Resource_Requested__c, Approval_Status__c FROM PSS_Request__c];
  
        //Asserting for the results
        System.assertEquals(3, pSSRequestsForAsserts.size());
        //System.assertEquals('Approved', pSSRequestsForAsserts[0].Approval_Status__c);
        
    }    
}