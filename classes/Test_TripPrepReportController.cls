/**
*  Description     :   Test class for TripPrepReportController. 
*
*  Created By      :   Dipesh Gupta  
* 
*  Created Date    :   05/10/2020
* 
*  Revision Logs   :   V_1.0 - Created - CR-20190702-13205
*		   :   V_1.1 - Modified By - Neha Sharma - 05/03/2021 - CR-20201110-14683 - Test Class fixes
**/
@isTest
public class Test_TripPrepReportController {
    
    @isTest static void testTripPrepReportController(){
        
        Util.byPassAllTriggers = true;
        
        //Query through Opportunity RecordTypes
        List<RecordType> eventRecordType = [SELECT Id , DeveloperName FROM RecordType 
                                            WHERE (DeveloperName = 'Core_Marketing') 
                                            AND SObjectType = 'Event' AND IsActive = true];
        
        //Query through Opportunity RecordTypes
        List<RecordType> oppRecord = [SELECT Id , DeveloperName FROM RecordType 
                                      WHERE DeveloperName = 'BI_Contract_Maintenance' 
                                      AND SObjectType = 'Opportunity'
                                      AND IsActive = true];
        //Creating account records.
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(Name = 'University of North Texas - Denton - TX', Account_Formal_Name__c = 'testacc');
        Account acc2 = new Account(Name = 'University of North Texas - Denton', Account_Formal_Name__c = 'testacc');
        accList.add(acc1);
        accList.add(acc2);
        insert accList;
        
        Contact cont = TestUtilities.CreateNewContact(True);
        //Modified By - Neha Sharma - 05/03/2021 - Test Class fixes
        //Insert Opportunity Records
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity0' , accountId = accList[1].Id, StageName = 'Proposal In Progress' , Amount = 1234 , CloseDate=system.today().addDays(3) ));
        oppList.add(new Opportunity(Sales_Pursuit_Products__c = 'APS',RecordTypeId = oppRecord[0].Id , Name = 'Test Opportunity1' , accountId = accList[0].Id, Amount = 1234 , CloseDate=system.today().addDays(4),StageName = 'Closed Lost',Opportunity_Products__c = 'EDPF',
                                    Primary_Reason_Lost__c= 'Budget Issues', Additional_Info_Primary_Reason_Lost__c = 'Test'));
        Insert oppList;
        
        //List to hold Events
        List<Event> events = new List<Event>();
        
        //Populate List
        events.add(new Event(RecordTypeId = eventRecordType[0].Id ,StartDateTime = system.today().addDays(4), 
                             EndDateTime = system.today().addDays(7) , OwnerId = Userinfo.getUserId(),
                             Subject = 'Will Auto-Populate',   WhatId = oppList[0].Id , Cancelled_Did_Not_Occur__c = false ,  
                             Event_Type__c = 'Web Visit',WhoId = cont.Id));  
        insert events;
        
        //Insert Program data
        List<Program__c> progList = new List<Program__c>();
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = true, 
                                    New_Business_Marketer__c = 'RI Marketer'));         
        
        progList.add(new Program__c(Program_Acronym__c = 'TEST', Program_Formal_Name__c = 'Test Program Formal', 
                                    Business_line__c = 'RI', Name = 'Test Program', Create_Memberships__c = 'No', 
                                    Industry_Member_for_Meetings__c = false, New_Business_Marketer__c = 'RI Marketer'));
        insert progList;
        
        
        //Contract
        Contract__c contract = new Contract__c(Name='Test1', Payer_Account__c = accList[0].ID, Program__c = progList[0].Id, 
                                               Start__c = System.Today().addDays(-10), End__c = System.Today().addDays(355), 
                                               Contract_Renewal_Opportunity__c = oppList[0].Id);
        
        //List to hold Membership data
        List<Membership__c> membershipList = new List<Membership__c>();
        
        membershipList.add(new Membership__c(Name = 'Membership Test1', Account_Name__c = accList[0].Id, 
                                             Program__c = progList[0].Id, Active_Contract_Main_Contact__c = contract.Id,
                                             Membership_Status_Text__c = 'Prospect - pure'));
        
        insert membershipList;
        
        Test.startTest();
        
        PageReference pageRef = Page.TripPrepReport;
        pageRef.getParameters().put('Id', String.valueOf(events[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(events[0]);
        TripPrepReportController conrtl = new TripPrepReportController(sc);
        
        system.assert(conrtl.accountList.size() > 0 );
        system.assert(conrtl.contactList.size() > 0 );
        //system.assert(conrtl.membershipList.size() > 0 );
        //system.assert(conrtl.opportunityEDPFList.size() > 0 );
        
        conrtl.getPrintView();
        Test.stopTest();
        
    }
}